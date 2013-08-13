$('.event-div').click( function() {
  $(this).children('.event-details').toggle(200)
});

function showPosition(position) {
  //alert('Lat: ' + position.coords.latitude + ', Lon: ' + position.coords.longitude);
}
if (navigator.geolocation){
  navigator.geolocation.getCurrentPosition(showPosition);
}