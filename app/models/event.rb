class Event < ActiveRecord::Base
  attr_accessible :address, :category_id, :cost, :date, :details, :end_time, :fav, :start_time, :title, :venue
  belongs_to :user
  belongs_to :category
  validates :address, :cost, :title, :user_id, :venue, presence: true
  validates_length_of :title, :maximum => 70
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

	scope :have_favs, where(:fav => true)
	#def self.is_today
		#where(:date => Date.today)
	#end
	scope :is_today#, where(:date => Date.today)
end