class Venue < ActiveRecord::Base
  attr_accessible :name, :address, :latitude, :longitude

  belongs_to :user
  has_many :events, :dependent => :destroy

  validates :name, :address, :user_id, presence: true
  validates_length_of :name, :address, :maximum => 70
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

  make_flaggable :unsubscribe
end