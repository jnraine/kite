class Event < ActiveRecord::Base
  attr_accessible :address, :category_id, :cost, :date, :details, :end_time, :fav, :start_time, :title, :venue
  belongs_to :user
  belongs_to :category
  validates :address, :cost, :title, :user_id, :venue, presence: true
  validates_length_of :title, :venue, :address, :maximum => 70
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

	scope :have_favs, where(:fav => true)
	scope :is_today, lambda {|now = Time.current| where("end_time > ?", now)} #.where(:date => Date.today)
	scope :sort_today, is_today.order(:start_time)
	scope :is_near, lambda {|city| self.near(city, 20, :units => :km)}

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