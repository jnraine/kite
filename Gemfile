source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '3.2.13'
gem 'jquery-rails'
gem 'devise' #for user accounts
gem "simple_form", "~> 2.1.0"
gem 'rails_autolink', '~> 1.1.0' #allows user text containing links to be active links
gem 'geocoder'
gem 'make_flaggable', :git => 'git://github.com/cavneb/make_flaggable.git'
gem 'ice_cube' #for recurrence calculation
gem 'recurring_select' #for recurrence ui via select box

group :development, :test do
  gem "chronic"
  gem "timecop", "~> 0.6.3"
  gem "rspec-rails", "~> 2.14.0"
end

group :production do
	gem 'pg'
	gem 'rails_12factor'
	gem 'newrelic_rpm'
end

group :development do
	gem 'pg'
end

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end