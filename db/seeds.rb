# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
["Live Music",
 "Night Clubs",
 "Theatre",
 "Comedy",
 "Sports",
 "Art Exhibitions",
 "Shopping Sales",
 "Drink Specials",
 "Food Specials",
 "Community"
 ].each do |category|
    Category.find_or_create_by_name(category)
end