# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# fitness, outdoor,

["Live Music",
 "Night Clubs",
 "Theatre Performances",
 "Stand-up Comedy",
 "Sporting Events",
 "Art Shows",
 "Shopping Sales",
 "Drink Specials",
 "Food Specials",
 "Community Events",
 "Games and Trivia",
 "Workshops and Classes"
 ].each do |category|
    Category.find_or_create_by_name(category)
end