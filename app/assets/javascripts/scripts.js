$(document).ready(function() {
	function oneHourInFuture(iso8601NoTimezone) {
		var date = moment(iso8601NoTimezone);
		date.set("hour", date.hour() + 3);
		window.date = date;
		return date.format("YYYY-MM-DDTHH:mm:SS");
	}

	$("#event_local_start_time").blur(function() {
		var $startTime = $(this);
		var newEndTime = oneHourInFuture($startTime.val())
		$("#event_local_end_time").val(newEndTime);
	});

	$("#event_repeat").change(function() {
		var $repeatInput = $(this);
		var $repeatUntilFormGroup = $("#event_repeat_until").parents(".form-group").first();
		console.log($repeatInput, $repeatInput.val());
		if($repeatInput.val() == "") {
			$repeatUntilFormGroup.hide();
		} else {
			$repeatUntilFormGroup.show();
		}
	}).change();

	//event and venue lists are sortable
	$('#events-table').tablesorter({
		sortList: [[1,0]],
		headers: { 3: { sorter: false }}
	});
	$('#venues-table').tablesorter({
		sortList: [[0,0]],
		headers: { 2: { sorter: false }}
	});
});

$('.event-div').click( function() {
	event.preventDefault();
	openEvent = $(this).children('.event-details'); //event details open when user clicks an event div
	if(typeof offset === "undefined"){
		offset = $('.event-details:visible').height();
	} else {
		offset = $('.event-details:visible').height()+4;
	};

	$('.event-details').not(openEvent).hide(200); //closes all other open events
	openEvent.toggle(200) //toggle details and scrolls
	scrollAmount = $(this).position().top - 54 - offset;
	$("body").animate({scrollTop: scrollAmount},800);
});

$('.event-details').click( function(event){
  event.stopImmediatePropagation(); //allow links in the details to be clicked on
});