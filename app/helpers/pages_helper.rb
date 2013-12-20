module PagesHelper
	def time_of_day_greeting(current_time)
		case current_time
			when 3..5
				"go home<br/>yr drunk"
			when 6..10
				"a city built<br/>on breakfast"
			when 14..18
				"things are<br/>happening"
			when 19..24
				"so long<br/>lame night"
			else
				"something<br/>cool, now"
		end
	end
end