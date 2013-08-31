class Category < ActiveRecord::Base
  attr_protected :name
  has_many :events
end