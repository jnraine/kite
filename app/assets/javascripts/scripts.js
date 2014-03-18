$(document).ready(function() {
    //update end_time to 3 hours in the future from start_time when creating events
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

    //hide repeating event options until repeat is confirmed
    $("#event_repeat").change(function() {
        var $repeatInput = $(this);
        var $repeatUntilFormGroup = $("[for='event_repeat_until']").parents(".form-group").first();
        if($repeatInput.val() == "") {
            $repeatUntilFormGroup.hide();
        } else {
            $repeatUntilFormGroup.show();
        }
    }).change();

    //make event and venue lists are sortable
    $('#events-table').tablesorter({
        sortList: [[1,0]],
        headers: { 3: { sorter: false }}
    });
    $('#venues-table').tablesorter({
        sortList: [[0,0]],
        headers: { 2: { sorter: false }}
    });

    // 
    // Make polyfills look better
    // 
    function markAsUnsupported($inputs) {
        $inputs.each(function(index, input) {
            $(input).parents(".form-group").first().addClass("unsupported-inputtype");
        });
    }

    if(!Modernizr.inputtypes["datetime-local"]) {
        markAsUnsupported($("[type='datetime-local']"));
    }

    if(!Modernizr.inputtypes["date"]) {
        markAsUnsupported($("[type='date']"));
    }

    // Hacky, but likely to work
    var interval = setInterval(function() {
        $(".unsupported-inputtype span.form-control").removeClass("form-control");
    }, 100);
    
    setTimeout(function() {
        clearInterval(interval);
    }, 2000);

    // Setup pretty checkboxes
    $(".pretty-checkboxes input[type='checkbox']").change(function() {
        var $checkbox = $(this);
        var $button = $checkbox.parents(".btn").first();
        if($checkbox.is(":checked")) {
            $button.addClass("active");
        } else {
            $button.removeClass("active");
        }
    }); 
});

//event details open when user clicks an event div
var lastLoad;
$('.event-div').click( function(event) {
    event.preventDefault();
    openEvent = $(this).children('.event-details'); //get the event details
    screenSize = $(window).height(); //get the screen height

    if(this===lastLoad){  //if same event?
        offset = 0;  //clear the offset to restrict scrolling
    } else {
        offset = $('.event-details:visible').height();
        if(screenSize < offset) offset=screenSize+42; //limit offset size to screen height
        if(offset) offset+=10; //add to offset for event-detail bottom margin
    }

    $('.event-details').not(openEvent).hide(300); //closes all other open events
    openEvent.toggle(300) //toggle details

    $('body').animate({ //scroll to the top of the clicked event
        scrollTop: $(this).position().top-54-offset},   1200
    );

    lastLoad = this;
});

$('.event-details').click( function(event){
  event.stopImmediatePropagation(); //allow links in the details to be clicked on
});