class Event < ActiveRecord::Base
  attr_accessible :address, :cost, :date, :details, :end_time, :fav, :start_time, :title, :venue
  belongs_to :user
  validates :user_id, presence: true
  #validates :address, :cost, :title, :venue, presence: true
end