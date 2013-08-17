$('.event-div').click( function() {
	var openEvent = $(this).children('.event-details');

	$('.event-details').not(openEvent).hide(50);
	openEvent.toggle(50);
});

// $('.form-popover').popover( { placement: 'auto' })