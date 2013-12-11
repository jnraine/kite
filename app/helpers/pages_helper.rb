module PagesHelper
	def time_of_day_greeting(current_time)
		case current_time
			when 14..18
				"things are<br/>happening"
			when 19..24
				"so long<br/>lame night"
			else
				"something<br/>cool, now"
		end
	end
end