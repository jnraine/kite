module EventsHelper
	def toggle_fav(event, user)
		link_to user.flagged?(event, :fav) ?
			content_tag(:span, " ", :class => "glyphicon glyphicon-heart") :
			content_tag(:span, " ", :class => "glyphicon glyphicon-heart-empty"),
			fav_event_path(event)
			#:remote => true
	end
end