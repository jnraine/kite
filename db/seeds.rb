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
# "Nightlife",
# "Discussions"

["Live Music",
 "Night Clubs",
 "Theatre Performances",
 "Art Shows"
 ].each do |category|
    Category.find_or_create_by_name(category)
end