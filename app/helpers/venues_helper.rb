module VenuesHelper
	def toggle_subscribe(venue, user)
		link_to user.flagged?(venue, :unsubscribe) ?
			content_tag(:span, " ", :class => "glyphicon glyphicon-plus") :
			content_tag(:span, " ", :class => "glyphicon glyphicon-remove"),
			unsubscribe_venue_path(venue)
	end
end
