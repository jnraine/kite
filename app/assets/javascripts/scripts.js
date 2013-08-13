$('.event-div').click( function() {
  event.preventDefault();
  $(this).children('.event-details').toggle(200)
});