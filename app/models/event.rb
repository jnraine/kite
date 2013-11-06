class Event < ActiveRecord::Base
  attr_accessible :title, :details, :start_time, :end_time, :date, :cost, :venue_id, :category_id
 
  belongs_to :user
  belongs_to :venue
  belongs_to :category

  validates :title, :start_time, :end_time, :date, :cost, :venue_id, :category_id, presence: true
  validates_length_of :title, :maximum => 70
 
  scope :not_over, lambda {|now = Time.now| where("end_time > ?", now)}
	scope :is_today, where(:date => Date.today).not_over
	scope :sort_today, is_today.order(:start_time)
	scope :is_near, lambda {|city| Venue.near(city, 20, :units => :km).includes(:events).map(&:events).flatten }

	make_flaggable :fav

	def self.subscribed(user)
		if user.flagged_venues.empty?
			scoped
		else
			self.where("venue_id not in (?)", user.flagged_venues)
		end
	end

	def set_start_time_date
		self.start_time = DateTime.new(date.year, date.month, date.day, start_time.hour, start_time.min, start_time.sec)
		return true
	end
	def set_end_time_date
		self.end_time = DateTime.new(date.year, date.month, date.day, end_time.hour, end_time.min, end_time.sec)
		return true
	end
	before_save :set_start_time_date
	before_save :set_end_time_date
end