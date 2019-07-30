/*

Legislation.gov.uk Homepage Chrome Initialisation

One-liner: All script initialisation for Homepage is placed here
Requirements:
	jQuery framework: http://jquery.com/

History:
v0.01	GM	Created
v2.0	chiich	- Refactored code to become a jQuery plugin. Call ref: HA093549
*/
/*
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/

$(document).ready(function(){
	// add js class to layout1 to prevent selector bugs in IE6
	$("#layout1").addClass("js");

	// Initialise SlideShow config object
	var config = {
		fadetime: 250,
		slidetime: 10000,
		currentSlideIndex: 0,
		slideContainer: $('#intro'),
		slideContent: $('#animContent'),
		slideNavbar: $('#countryLeg')
	}

	$('#intro').slideShow( config );
});

$.fn.slideShow = function(options) {
	var $slideNavbar = options.slideNavbar;
	var $slideContainer = options.slideContainer;
	var $slideContent = options.slideContent;
	var timer;
	var navClicked = false;

	if ( $slideNavbar.length ) {
		var $slideNavbarLinks = $slideNavbar.find('a');

		$slideNavbarLinks.click( function(e) { // Event Handler
			e.preventDefault();

			clearTimeout(timer); // Stop the animation

			navClicked = true; // Flag set
			options.prevIndex = options.currentSlideIndex; // temp-store
			options.currentSlideIndex = $slideNavbarLinks.index(e.target);
			timedTransition(); // Call the effect
		});

		$slideContent.css('backgroundColor', '#f5f5f5'); // bg-color update

		timedTransition(); // Begin the slideshow animation
	}

	function fadeTransition(_incomingSlideId) {
		$slideContainer.removeClass();
		$slideContent.children('.' + _incomingSlideId).fadeIn(options.fadetime, function() {
			$slideContainer.addClass(_incomingSlideId);
			timer = setTimeout( timedTransition, options.slidetime );
		});
	}

	function timedTransition() {
		var incomingSlideId, previousSlideId = null;

		// At carousel edge; reset to start
		if ( options.currentSlideIndex > ($slideNavbarLinks.length-1) ) {
			options.currentSlideIndex = 0;
			previousSlideId = $slideNavbarLinks.eq( ($slideNavbarLinks.length-1) ).attr('id');
		}

		// After initial carousel load AND the current exec is not for a carousel-tem click
		if ( options.currentSlideIndex > 0 && !navClicked ) {
			previousSlideId = $slideNavbarLinks.eq( (options.currentSlideIndex - 1) ).attr('id');
		}

		// a carousel-tem click has occurred
		if ( navClicked ) {
			navClicked = false; // Reset flag
			previousSlideId = $slideNavbarLinks.eq( (options.prevIndex-1) ).attr('id');
			delete options.prevIndex; // Removing temp-store
		}

		incomingSlideId = $slideNavbarLinks.eq(options.currentSlideIndex).attr('id');

		options.currentSlideIndex++; // Adjust pointer for next Slide

		if (previousSlideId) {
			$slideContent.children('.' + previousSlideId).fadeOut(options.fadetime, function() {
				fadeTransition(incomingSlideId);
			});
		} else {
			fadeTransition(incomingSlideId);
		}
	}
}