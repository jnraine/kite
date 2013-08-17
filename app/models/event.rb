class Event < ActiveRecord::Base
  attr_accessible :address, :cost, :date, :details, :end_time, :fav, :start_time, :title, :venue
  belongs_to :user
  validates :address, :cost, :title, :user_id, :venue, presence: true
  validates_length_of :title, :maximum => 70
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?
end