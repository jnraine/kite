class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, #:recoverable,
         :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :subscribed, :type
  
  #has_many :venues, :dependent => :destroy
  #has_many :events, :through => :venues
  has_many :flagged_events, :through => :flaggings, :source => :flaggable, :source_type => 'Event'
  has_many :flagged_hosts, :through => :flaggings, :source => :flaggable, :source_type => 'Host'

  make_flagger

  def favourite_events
    flaggings.map(&:flaggable).delete_if {|flaggable| !flaggable.is_a? Event }
  end
end