$('.event-div').click( function() {
	var openEvent = $(this).children('.event-details');

	$('.event-details').not(openEvent).hide(200);
	openEvent.toggle(200);
});

// $('.form-popover').popover( { placement: 'auto' })

/* Hammer('.event-div').on("swipeleft", function() {
	var swipeMenu = $(this).children('.event-menu');

  console.log("You swiped");
  swipeMenu.toggle("slide", { direction: "left" });
}); */
//for ( var a = 0; a < 10; a++ )
//{
/*$(".event-menu").mmenu({
  configuration: {
	  menuNodetype: "div"
	}, 
  dragOpen :{
    open: true,
    threshold: 75,
    pageNode: $(".event-div")
  }
});*/
//}

//$(".event-menu").trigger( "setPage.mm", [ $(".event-div") ] );