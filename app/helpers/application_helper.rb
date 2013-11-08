module ApplicationHelper
	def root_path?
	  request.path == "/" ? true : false
	end
end