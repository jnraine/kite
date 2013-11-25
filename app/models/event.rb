class Event < ActiveRecord::Base
	include IceCube

	attr_accessible :title, :details, :cost, :schedule, :venue_id, :category_id, :local_start_time, :local_end_time, :repeat
  delegate :end_time, :end_time=, :start_time, :start_time=, :occurs_on?, to: :schedule

  belongs_to :user
  belongs_to :venue
  belongs_to :category

  has_many :occurrences, class_name: "EventOccurrence", autosave: true, dependent: :destroy
 
  validates :title, :cost, :venue_id, :category_id, :local_start_time, :local_end_time, presence: true
  validates_length_of :title, :maximum => 70
  # validates_presence_of :end_date, :if => :schedule? # all repeating events need an ending date

  before_save :serialize_schedule_and_generate_occurrences
  after_create :create_future_occurrences # these are generated for a new record once it has an ID

  make_flaggable :fav

  serialize :schedule_hash, Hash

	scope :is_near, lambda {|city| Venue.near(city, 20, :units => :km).includes(:events).map(&:events).flatten } #checks geocoded venue address against user location
	scope :categorize, lambda { |category| where(:category_id => category) }
	scope :not_over, lambda { includes(:occurrences).where("event_occurrences.end_time > ?", Time.now) }
	scope :sort_days, order(:date, "CAST(start_time AS time)")
  
  scope :on, lambda {|date| includes(:occurrences).where('"event_occurrences"."start_time" BETWEEN ? AND ?', date.beginning_of_day, date.end_of_day) }
  scope :between, lambda {|start_date, end_date| includes(:occurrences).where('"event_occurrences"."start_time" BETWEEN ? AND ?', start_date.beginning_of_day, end_date.end_of_day) }

	def self.subscribed(user)
		if user.flagged_venues.empty?
			scoped #show all venues' events
		else
			self.where("venue_id not in (?)", user.flagged_venues) #filter unsubscribed venues from events
		end
	end

  def serialize_schedule
    self.schedule_hash = schedule.to_hash
  end

  def serialize_schedule_and_generate_occurrences
    serialize_schedule
    build_future_occurrences if schedule_hash_changed? and !new_record?
  end

  def default_schedule
    Schedule.new(Time.parse("tomorrow, 7pm"), duration: 1.hour)
  end

  def schedule
    @schedule ||= schedule_hash.present? ? Schedule.from_hash(schedule_hash) : default_schedule
  end

  def schedule=(new_schedule)
    @schedule = new_schedule
  end

  def build_future_occurrences(until_time: Date.today + 30.days)
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

  def create_future_occurrences(until_time: Date.today + 7.days)
    build_future_occurrences
    save
  end

  def recurring_rule_hash=(recurring_rule_hash)
    remove_scheduled_recurrence
    schedule.add_recurrence_rule(Rule.from_hash(recurring_rule_hash))
  end

  def recurring_rule_hash
    return nil if schedule.recurrence_rules.empty?
    schedule.recurrence_rules.first.to_hash
  end

  def remove_scheduled_recurrence
    schedule.recurrence_rules.each do |rule|
      schedule.remove_recurrence_rule(rule)
    end
  end

  def local_start_time
    start_time.iso8601_no_timezone
  end

  def local_start_time=(iso8601_no_timezone)
    self.start_time = Time.parse(iso8601_no_timezone)
  end

  def local_end_time
    end_time.iso8601_no_timezone
  end

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
  end

  def repeat
    recurrence_rule = schedule.recurrence_rules.first
    if recurrence_rule.is_a?(IceCube::DailyRule)
      :daily
    elsif recurrence_rule.is_a?(IceCube::WeeklyRule)
      :weekly
    end
  end

  def repeat_daily
    remove_scheduled_recurrence
    schedule.add_recurrence_rule(IceCube::Rule.daily)
  end

  def repeat_weekly
    remove_scheduled_recurrence
    schedule.add_recurrence_rule(IceCube::Rule.weekly)
  end

  def repeat_never
    remove_scheduled_recurrence
  end

  def repeat_options
    [
      ["Never", ""],
      ["Daily", "daily"],
      ["Weekly", "weekly"]
    ]
  end

  def upcoming_dates
    start_times = occurrences.take(7).map(&:start_time)

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