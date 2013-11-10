class Day < ActiveRecord::Base
  attr_accessible :date, :event_id
  belongs_to :event

  validates :date, presence: true
end