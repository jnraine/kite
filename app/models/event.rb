class Event < ActiveRecord::Base
  include IceCube

  attr_accessible :title, :details, :cost, :schedule, :venue_id, :category_id, :local_start_time, :local_end_time, :repeat, :repeat_until
  delegate :end_time, :end_time=, :start_time, :start_time=, :occurs_on?, to: :schedule

  belongs_to :host
  belongs_to :venue
  belongs_to :category

  has_many :occurrences, class_name: "EventOccurrence", autosave: true, dependent: :destroy
 
  validates :title, :cost, :venue_id, :category_id, :local_start_time, :local_end_time, presence: true
  validates_length_of :title, :maximum => 70
  validates_presence_of :repeat_until, :if => :repeat # all repeating events need an ending date

  before_save :serialize_schedule_and_generate_occurrences
  after_create :create_future_occurrences # these are generated for a new record once it has an ID

  make_flaggable :fav

  serialize :schedule_hash, Hash

  scope :is_near, lambda {|city| Venue.near(city, 20, :units => :km).includes(:events).map(&:events).flatten } #checks geocoded venue address against user location
  scope :categorize, lambda { |category| where(:category_id => category) }
  scope :not_over, lambda { includes(:occurrences).where("event_occurrences.end_time > ?", Time.now) }
  scope :sort_days, order(:date, "CAST(start_time AS time)")
  
  scope :on, lambda {|date| includes(:occurrences).where('"event_occurrences"."start_time" OR "event_occurrences"."end_time" BETWEEN ? AND ?', date.beginning_of_day, date.end_of_day + 4.hours) }
  scope :between, lambda {|start_date, end_date| includes(:occurrences).where('"event_occurrences"."start_time" BETWEEN ? AND ?', start_date.beginning_of_day, end_date.end_of_day) }

  # Convert IceCube::Schedule object into hash for database. This is run as
  # part of serialize_schedule_and_generate_occurrences will rarely need to 
  # be called manually.
  def serialize_schedule
    self.schedule_hash = schedule.to_hash
  end

  # Ensures future occurrences are built when schedule has changed. Called
  # as a before_save callback and will rarely need to be called manually.
  # Due to nil ID, future occurrences are not built for new records.
  def serialize_schedule_and_generate_occurrences
    serialize_schedule
    build_future_occurrences if schedule_hash_changed? and !new_record?
  end

  def default_schedule
    Schedule.new(Time.parse("tomorrow, 7pm"), duration: 3.hours)
  end

  # Created from the schedule_hash, or default_schedule when schedule_hash is 
  # nil.
  def schedule
    @schedule ||= schedule_hash.present? ? Schedule.from_hash(schedule_hash) : default_schedule
  end

  def schedule=(new_schedule)
    @schedule = new_schedule
  end

  # Builds associated occurrence records for this event. Specify until_time: 
  # argument to specify how far in the future to create the occurrences for,
  # otherwise, defaults to 90 days in the future.
  def build_future_occurrences(until_time: Date.today + 90.days)
    self.occurrences = []

    new_occurrences = []
    schedule.occurrences(until_time).each do |ice_cube_occurrence|
      new_occurrences << occurrences.build.tap do |o|
        o.start_time = ice_cube_occurrence.start_time
        o.end_time = ice_cube_occurrence.end_time
      end
    end

    self.occurrences = new_occurrences
  end

  # Builds and saves future occurrences. Called as an after_create callback and
  # will rarely need to be called manually. This is done after record creation
  # because the event record needs an ID to be properly associated to occurrence
  # records.
  def create_future_occurrences
    build_future_occurrences
    save
  end

  # Remove all recurrence rules from schedule and add a new rule created from
  # the passed hash.
  def recurring_rule_hash=(recurring_rule_hash)
    remove_scheduled_recurrence
    schedule.add_recurrence_rule(Rule.from_hash(recurring_rule_hash))
  end

  # Return recurrence_rule serialized to hash.
  def recurring_rule_hash
    return nil if recurrence_rule
    recurrence_rule.to_hash
  end

  # Removes all recurrence rules from the schedule.
  def remove_scheduled_recurrence
    schedule.recurrence_rules.each do |rule|
      schedule.remove_recurrence_rule(rule)
    end
  end

  # Used in the view. Conforms to datetime-local HTML5 input element. This
  # could be moved to a decorator object in the future.
  def local_start_time
    start_time.iso8601_no_timezone
  end

  # See local_start_time for more info.
  def local_start_time=(iso8601_no_timezone)
    self.start_time = Time.parse(iso8601_no_timezone)
  end

  # See local_start_time for more info.
  def local_end_time
    end_time.iso8601_no_timezone
  end

  # See local_start_time for more info.
  def local_end_time=(iso8601_no_timezone)
    self.end_time = Time.parse(iso8601_no_timezone)
  end

  # Sets daily repeat on specific day, or everday
  def repeat=(interval)
    interval = interval.to_sym

    if interval == :daily
      repeat_daily
    elsif interval == :weekly
      repeat_weekly
    else
      repeat_never
    end

    dump_cached_schedule_attributes
  end

  def recurrence_rule
    schedule.recurrence_rules.first
  end

  # Dump any schedule attributes that happen to be stored in the event. At this
  # time, only the repeat_until attribute is stored this way. This is done to
  # allow us to apply aspects to new recurrence rules.
  def dump_cached_schedule_attributes
    return unless recurrence_rule
    recurrence_rule.until repeat_until
  end

  # Returns what time of repeat this is. Possible values: :daily, :weekly, or nil.
  def repeat
    if recurrence_rule.is_a?(IceCube::DailyRule)
      :daily
    elsif recurrence_rule.is_a?(IceCube::WeeklyRule)
      :weekly
    end
  end

  # Write attribute as per usual, then dump schedule attributes. This ensures
  # the recurrence_rule has the proper attributes immediately after setting
  # this value.
  def repeat_until=(date)
    if date == ""
      write_attribute(:repeat_until, date)
    else
      write_attribute(:repeat_until, Date.parse(date).end_of_day)
    end
    dump_cached_schedule_attributes
  end

  # Replace existing recurrence_rule with a daily rule.
  def repeat_daily
    remove_scheduled_recurrence
    schedule.add_recurrence_rule(IceCube::Rule.daily)
  end

  # Replace existing recurrence_rule with a weekly rule.
  def repeat_weekly
    remove_scheduled_recurrence
    schedule.add_recurrence_rule(IceCube::Rule.weekly)
  end

  # Remove recurrence_rule
  def repeat_never
    remove_scheduled_recurrence
  end

  # Used in the view; what appears in the "Repeat" select menu.
  def repeat_options
    [
      ["Never", ""],
      ["Daily", "daily"],
      ["Weekly", "weekly"]
    ]
  end

  # Format next 5 occurrences into a human readable date format.
  def upcoming_dates
    start_times = occurrences.where("start_time > ?", Date.today).take(5).map(&:start_time)

    current_month = nil
    formatted_dates = start_times.map do |start_time|
      if current_month == start_time.month
        start_time.strftime("%-d")
      else
        current_month = start_time.month
        start_time.strftime("%B %-d")
      end
    end

    formatted_dates.join(", ")
  end
end