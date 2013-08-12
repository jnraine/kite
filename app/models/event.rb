class Event < ActiveRecord::Base
  attr_accessible :address, :cost, :date, :details, :end_time, :fav, :start_time, :title, :venue

  #validates :address, :cost, :title, :venue, presence: true
end