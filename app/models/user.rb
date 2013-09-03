class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, #:recoverable,
  			 :rememberable, :trackable, :validatable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  has_many :venues, :dependent => :destroy
  has_many :events, :through => :venues
  has_many :flagged_events, :through => :flaggings, :source => :flaggable, :source_type => 'Event'

  make_flagger
end