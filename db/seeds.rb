# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# "Fitness and Training",
# "Outdoor Activities",
# "Indoor Activities",
# "Local Attractions", 
# "Stand-up Comedy",
# "Shopping Sales",
# "Drink Specials",
# "Food Specials",
# "Community Events",
# "Games and Trivia",
# "Workshops and Classes"
# "Sporting Events",
# "Discussions"

["Live Music",
 "Nightlife",
 "Theatre Performances",
 "Art Shows"
 ].each do |category|
    Category.find_or_create_by_name(category)
end

if Rails.env == "development"
  user = User.find_by_email("admin@example.com")
  user.destroy if user
  
  Host.new.tap do |u|
    u.email = "admin@example.com"
    u.password = "password"
    u.save!
  end
end
