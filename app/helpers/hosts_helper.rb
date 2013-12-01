module HostsHelper
	def toggle_subscribe(host, user)
		if user_signed_in? #change icon from x to + and vice-versa
			link_to user.flagged?(host, :unsubscribe) ?
				content_tag(:span, " ", :class => "glyphicon glyphicon-plus") :
				content_tag(:span, " ", :class => "glyphicon glyphicon-remove"),
				unsubscribe_host_path(host),
				:remote => true
		else
			link_to content_tag(:span, " ", :class => "glyphicon glyphicon-remove"), unsubscribe_host_path(host) #prompt user to sign in
		end
	end
end