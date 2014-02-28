module ApplicationHelper
	def navigation_icon
		if @url_location == root_path
			link_to "here", root_path, :class => "lg-icon logo"
		else
			@url_location ||= root_path
			link_to content_tag(:span, " ", :class => "glyphicon glyphicon-arrow-left lg-icon"), @url_location
		end
	end
	def root_path?
  	request.path == "/" ? true : false
	end
end