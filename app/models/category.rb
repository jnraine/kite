class Category < ActiveRecord::Base
  attr_protected :name
  has_many :events, :dependent => :destroy

  default_scope order('name ASC')
end