class CategoriesController < ApplicationController
	def index
		@categories = Category.all
		@time_of_day = Time.now.hour
	end
end