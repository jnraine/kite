class Event < ActiveRecord::Base
	include IceCube

	attr_accessible :title, :start_time, :end_time, :end_date, :details, :cost, :schedule, :venue_id, :category_id, :days_attributes

  belongs_to :user
  belongs_to :venue
  belongs_to :category
  has_many :days
  accepts_nested_attributes_for :days
 
  validates :title, :start_time, :end_time, :cost, :venue_id, :category_id, presence: true
  validates_length_of :title, :maximum => 70
  validates_presence_of :end_date, :if => :schedule? #all repeating events need an ending date
  #before_save :update_days

  make_flaggable :fav

	scope :is_near, lambda {|city| Venue.near(city, 20, :units => :km).includes(:events).map(&:events).flatten } #checks geocoded venue address against user location
	scope :categorize, lambda { |category| where(:category_id => category) }
	scope :occurs_on, lambda {|date| joins(:days).where("days.date = ?", date).sort_days}
	scope :occurs_between, lambda {|from, to| joins(:days).where("days.date BETWEEN ? and ?", from, to).sort_days}
	scope :not_over, lambda {|now = Time.now| where("CAST(end_time AS time) > ?", now)}
	scope :sort_days, order(:date, "CAST(start_time AS time)")

	def self.subscribed(user)
		if user.flagged_venues.empty?
			scoped #show all venues' events
		else
			self.where("venue_id not in (?)", user.flagged_venues) #filter unsubscribed venues from events
		end
	end

  #this commented code is from a stackoverflow question:
  #http://stackoverflow.com/questions/17054670/ice-cube-and-recurring-select-gems-and-occurrences

  #serialize :schedule, Hash

  #def schedule=(new_schedule)
  #  write_attribute(:schedule, RecurringSelect.dirty_hash_to_rule(new_schedule).to_hash)
  #end

  #def converted_schedule
  #  the_schedule = Schedule.new(days)#(self.start_date)
  #  the_schedule.add_recurrence_rule(RecurringSelect.dirty_hash_to_rule(self.schedule))
  #  the_schedule
  #end

  #was also looking into impletmenting it from this question:
  #http://stackoverflow.com/questions/10148960/recurring-events-in-calendar-rails

  #your code below

  #def schedule
  #  @schedule ||= Schedule.new(schedule_hash)
  #end

  #def schedule=(new_schedule)
  #  self.schedule_hash = new_schedule.to_hash
  #end

  #def occurs_on?(date)
  #  schedule.occurs_on?(date)
  #end

  # Update the days this occurs on before saving if the schedule_hash changed
  #def update_days
  #  return unless schedule_hash_changed?
  #  end_time = Date.today + 32.days # more or less depending on how many we want to cache
  #  occurences = schedule.occurences(end_time).map(&:to_datetime) # this returns an array of datetime objects
  #  days ||= build_days_for(occurrences)
  #end

  #def build_days_for(datetimes)
  #  datetimes.map do |datetime|
  #    days.build.tap {|day| day.datetime = datetime }
  #  end
  #end
end