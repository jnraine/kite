# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# fitness and training, outdoor activities, indoor activities, local attractions 
# "Stand-up Comedy",
# "Shopping Sales",
# "Drink Specials",
# "Food Specials",
# "Community Events",
# "Games and Trivia",
# "Workshops and Classes"

["Live Music",
 "Night Clubs",
 "Theatre Performances",
 "Sporting Events",
 "Art Shows"
 ].each do |category|
    Category.find_or_create_by_name(category)
end