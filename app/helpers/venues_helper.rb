module VenuesHelper
	def toggle_subscribe(venue, user)
		if user_signed_in? #change icon from x to + and vice-versa
			link_to user.flagged?(venue, :unsubscribe) ?
				content_tag(:span, " ", :class => "glyphicon glyphicon-plus") :
				content_tag(:span, " ", :class => "glyphicon glyphicon-remove"),
				unsubscribe_venue_path(venue),
				:remote => true
		else
			link_to content_tag(:span, " ", :class => "glyphicon glyphicon-remove"), unsubscribe_venue_path(venue) #prompt user to sign in
		end
	end
end