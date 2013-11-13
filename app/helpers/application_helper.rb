module ApplicationHelper
	def root_path? #is the root page being viewed?
	  request.path == "/" ? true : false
	end
end