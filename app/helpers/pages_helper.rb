module PagesHelper
	def time_of_day_greeting(current_time)
		case current_time
			when 3..4
				"go home<br/>yr drunk"
			when 6..9
				"a city built<br/>on breakfast"
			when 15..17
				"things are<br/>happening"
			when 20..24
				"so long<br/>lame night"
			else
				"something<br/>cool, now"
		end
	end
end