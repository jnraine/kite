class Event < ActiveRecord::Base
	include IceCube

	attr_accessible :title, :details, :cost, :schedule, :venue_id, :category_id
  delegate :end_time, :end_time=, :start_time, :start_time=, :occurs_on?, to: :schedule

  belongs_to :user
  belongs_to :venue
  belongs_to :category

  has_many :occurrences, class_name: "EventOccurrence", autosave: true, dependent: :destroy
 
  # validates :title, :cost, :venue_id, :category_id, presence: true
  validates_length_of :title, :maximum => 70
  # validates_presence_of :end_date, :if => :schedule? # all repeating events need an ending date

  before_save :serialize_schedule

  make_flaggable :fav

  serialize :schedule_hash, Hash

	scope :is_near, lambda {|city| Venue.near(city, 20, :units => :km).includes(:events).map(&:events).flatten } #checks geocoded venue address against user location
	scope :categorize, lambda { |category| where(:category_id => category) }
	scope :occurs_on, lambda {|date| joins(:days).where("days.date = ?", date).sort_days}
	scope :occurs_between, lambda {|from, to| joins(:days).where("days.date BETWEEN ? and ?", from, to).sort_days}
	scope :not_over, lambda {|now = Time.now| includes(:occurrences).where("event_occurrences.end_time > ?", now)}
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

  def default_schedule
    Schedule.new(Date.tomorrow, duration: 1.hour)
  end

  def schedule
    @schedule ||= schedule_hash.present? ? Schedule.from_hash(schedule_hash) : default_schedule
  end

  def schedule=(new_schedule)
    @schedule = new_schedule
  end

  def build_future_occurrences(until_time: Date.today + 7.days)
    self.occurrences = []

    schedule.occurrences(until_time).each do |ice_cube_occurrence|
      self.occurrences << occurrences.build.tap do |o|
        o.start_time = ice_cube_occurrence.start_time
        o.end_time = ice_cube_occurrence.end_time
      end
    end

    self.occurrences
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

  # Here is a bunch of virtual attributes to be used in HTML forms to manipulate the schedule
  # def recurrence_type
  #   return @recurrence_type if @recurrence_type

  #   recurrence_rule = schedule.recurrence_rules.first
  #   if recurrence_rule.is_a? DailyRule
  #     :daily
  #   elsif recurrence_rule.is_a? WeeklyRule
  #     :weekly
  #   else
  #     :none
  #   end
  # end

  # def recurrence_type=(recurrence_type)
  #   @recurrence_type = recurrence_type.to_sym
  # end

  # def days_of_week=(weekdays)
  #   remove_scheduled_recurrence
  #   schedule.add_recurrence_rule(Rule.weekly.day(weekdays))
  # end

  # def days_of_week
    
  # end
end