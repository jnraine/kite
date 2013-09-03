class Venue < ActiveRecord::Base
  attr_accessible :name, :address, :latitude, :longitude

  belongs_to :user
  has_many :events, :dependent => :destroy

  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

  validates :name, :address, :user_id, presence: true
  validates_length_of :name, :address, :maximum => 70

	def self.is_near(city)
		venues_near_city(city).map(&:events).flatten 
	end 

	private 
		def self.venues_near_city(city) 
			self.near(city, 20, :units => :km) 
		end
end