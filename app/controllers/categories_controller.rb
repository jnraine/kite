class CategoriesController < ApplicationController
	def index
		@categories = Category.all
		@time_of_day = Time.now.hour
		@url_location = root_path
	end
end