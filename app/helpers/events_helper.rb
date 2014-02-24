module EventsHelper
	#change icon from heart to empty heart and vice-versa
	def toggle_fav(event, user)
		if user_signed_in?
			link_to user.flagged?(event, :fav) ?
				content_tag(:span, " ", :class => "glyphicon glyphicon-heart") :
				content_tag(:span, " ", :class => "glyphicon glyphicon-heart-empty"),
				fav_event_path(event),
				:data => { :fav => event.id },
				:remote => true
		else
			link_to content_tag(:span, " ", :class => "glyphicon glyphicon-heart-empty"), fav_event_path(event) #prompt user to sign in
		end
	end

	def what_cost(cost)
		case cost
			when 0
				"Free"
			when 8888
				"By donation"
			when 9999
				"Sold out"
			else
				number_to_currency(cost).sub('.00', '')
		end
	end

	def event_details_format(details)
		text = sanitize details, tags: %w(a p div br strong)
		text = simple_format(text)
		auto_link(text, :all, :target => "_blank")
	end
end