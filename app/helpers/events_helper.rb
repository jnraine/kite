module EventsHelper
	def toggle_fav(event, user)
		if user_signed_in?
			link_to user.flagged?(event, :fav) ?
				content_tag(:span, " ", :class => "glyphicon glyphicon-heart") :
				content_tag(:span, " ", :class => "glyphicon glyphicon-heart-empty"),
				fav_event_path(event)
				#:remote => true
		else
			link_to content_tag(:span, " ", :class => "glyphicon glyphicon-heart-empty"), new_user_session_path
		end
	end
end