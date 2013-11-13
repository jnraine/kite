$('.event-div').click( function() {
	var openEvent = $(this).children('.event-details'); //event details open when user clicks an event div

	$('.event-details').not(openEvent).hide(200); //closes all other open events
	openEvent.toggle(200); //toggle details
});

$('.event-details').click( function(event){
  event.stopImmediatePropagation(); //allow links in the details to be clicked on
});