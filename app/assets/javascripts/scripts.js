$('.event-div').click( function() {
	var openEvent = $(this).children('.event-details');

	$('.event-details').not(openEvent).hide(200);
	openEvent.toggle(200);
});

$('.event-details').click( function(event){
  event.stopImmediatePropagation();
});