/*
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/
$(window).load(function(){
	$("#timeline").addSlider({"timerValue": 40,	"sliderStep": 2, "keyNavigation": 1,"viewPos": "right"});
});

/*
Timeline Slider

One-liner: Adds custom slider and optional fisheye to timeline
Usage: .addSlider(options);
timerValue - the speed of the slider (time in milliseconds between each move)
sliderStep - the amount to move the slider when arrow button clicked
keyNavigation - enable global arrow key handler

Required structure:

Fisheye enabled if #resultsTimeline has class "fisheye"

#resultsTimeline #timeline #timelineData
#resultsTimeline #decades

JS Requirements: jQuery 1.6, jQuery UI 1.8, jQuery UI slider plugin

History:
v0.01	TE 2010-05-21	Created
v0.02	GE 2010-05-27	Set so that initial view is set to the far right (to the latest section of a timeline/histogram)
						if init option value 'viewPos': 'right'
v0.03	GE 2010-05-28	Slider positioning logic to place above the 'decades' block if it exists, else just append to the end of $timelineContainer.
						Default fisheye position moved to right if viewPos=right
v0.04 	TE 2010-02-06	Fixed for xhtml content type
v0.05	TE 2010-02-08	Adapted for Point in Time
v0.06	TE 2010-06-21	Added global persistance for slider position
v0.07	TE 2010-06-23	Removed cookie, timeline now centres on relevant date, point in time on currentversion
v.0.8 	TE 2010-07-14	Fixed focus for timelines with centuries view

*/
$.fn.addSlider = function(values){
	var $timeline = $(this);
	var $timelineData = $timeline.find("#timelineData");

	if ($timelineData.outerWidth() >= $timeline.outerWidth()) {
		var timer, down = false;
		var scrollPos = 0,sliderPos = 0, fisheyeOffset = 0; // default position of histogram view
		var timelineWidth = 0, timelineDataWidth = 0, decadesMarginLeft = 0, decadesWidth = 0;
		var $timelineContainer, $decadeList;
		var $fisheye, $scrollbar, $slider, $arrowLeft, $arrowRight;
		var timerValue = values["timerValue"],
				sliderStep = values["sliderStep"],
				keyNavigation = values["keyNavigation"],
				timelineViewPos = values["viewPos"]; // default: to the left

		$timelineContainer = getTimelineContainer();
		timelineDataWidth = $timelineData.outerWidth();
		timelineWidth = $timeline.outerWidth();


		$decadeList = $timelineContainer.find('.decades').first();

		initScrollbar();

		if ($decadeList.length > 0) {
			decadesMarginLeft = parseInt( $decadeList.css("marginLeft") );
			decadesWidth = $decadeList.outerWidth();
			// $timelineContainer.append('<div id="scrollbar"></div>'); // Default at the end of block.  Position the scrollbar depending on whether there is a decades list
			initFisheye();
		}

		scrollToDefault();
	}

	// console.log('Mumford', timelineDataWidth, decadesMarginLeft);

	function getTimelineContainer() {
		return $timeline.closest('#resultsTimeline').length
						? $timeline.closest('#resultsTimeline')
						: $timeline.closest('#changesOverTime');
	}

	function initScrollbar() {
		var _scrollbar = '<div id="scrollbar"><a href="#" id="arrowLeft" class="arrow arrowLeftDisabled"><span class="accessibleText">Left</span></a><div id="slider"></div><a href="#" id="arrowRight" class="arrow arrowRightEnabled"><span class="accessibleText">Right</span></a></div>';
		$(_scrollbar).insertAfter($timeline); // Insert the newly-formed scrollbar to be AFTER the timeline

		$scrollbar = $timelineContainer.find("#scrollbar"); // Fetch reference to newly-created scrollbar
		$slider = $scrollbar.find("#slider");
		$arrowLeft = $scrollbar.find("#arrowLeft");
		$arrowRight = $scrollbar.find("#arrowRight");
		$slider.slider({animate:false, change: update, slide: update, step: sliderStep,value:sliderPos});

		initScrollbarEventHandlers();

		$timeline.css("overflow", "hidden"); // hide existing scrollbar
		// console.log('Nouveau', $scrollbar );
	}

	function initFisheye() {
		// add fisheye if parent has fisheye class
		// if ($timelineContainer.hasClass("fisheye")) {
		if ( $("#fisheye").length ) {
			// $timelineContainer.append('<div id="fisheye"></div>');
			$fisheye = $("#fisheye").css('visibility', 'visible');

			// account for absolute positioning offset
			fisheyeOffset = parseInt( $fisheye.css('left') + decadesMarginLeft );
			$fisheye.width(timelineWidth / timelineDataWidth * decadesWidth);

			// console.log(decadesMarginLeft, 'WorkOut', $decadeList, $fisheye.css('left'));
		}
	}

	function initScrollbarEventHandlers() {
		$scrollbar.find('.arrow').click( function(e) { // Click event handler
			e.preventDefault();
		});

		// move slider on mousedown or keydown. When held down, mousedown fires only once, keydown repeatedly.
		$arrowLeft
		.mousedown(moveLeft)
		.keydown(function(e) {
			// ignore all but initial keydown event. ignore all but enter key
			if (!down && e.keyCode == 13)
			{
				down = true;
				moveLeft();
			}
		})
		.mouseup(function() {clearTimeout(timer)})
		// .mouseleave(function() {clearTimeout(timer)})
		.keyup(function() {down = false; clearTimeout(timer)});

		$arrowRight
		.mousedown(moveRight)
		.keydown(function(e) {
			if (!down && e.keyCode == 13)
			{
				down = true;
				moveRight();
			}
		})
		.mouseup(function() {clearTimeout(timer)})
		// .mouseleave(function() {clearTimeout(timer)})
		.keyup(function() {down = false; clearTimeout(timer)});

		// hook arrow keys
		if (keyNavigation) {
			$(document).keydown(function(e) {

					if (!down && e.keyCode == 37)
					{
						down = true;
						moveLeft();
					}
					else if (!down && e.keyCode == 39)
					{
						down = true;
						moveRight();
					}
			})
			.keyup(function() {down = false; clearTimeout(timer)});
		}

	}

	function scrollToDefault() {
		// timeline
		// match /ukpga/1977 etc
		// var path = location.pathname;
		// var regex = /\/[^\/]*\/\d*-?\d*$/;

		// var year = path.match(regex);

		// if (year) {
		// 	console.log('OBI', year);
		// 	year = year[0];
		// }else{
		// 	console.log('WAN', $timelineData.find('.currentYear'));
		// }


		// var $link = $("a[href$='" + year + "']", $timeline);

		var $link = ( $timelineData.find('.currentYear').length )
								? $timelineData.find('.currentYear').first() // Changes over time
								: $timelineData.find('.currentVersion').first(); // Point in time


		// if ($link.length != 1) {
		// 	$link = $("#timeline #timelineData .currentVersion");
		// }

		if ($link.length === 1) {
			var linkPosition = $link.offset().left - $timelineData.offset().left - (timelineWidth / 2);
			sliderPos = linkPosition * 100 / (timelineDataWidth - timelineWidth); // (divided by maxscroll)

			// console.log('Ant', linkPosition);

		} else {
			// console.log('Opie', $link);

			// Set vars for histogram view
			if (timelineViewPos === "right") { // view to right
				sliderPos = 100;  // Set initial view of timeline
				scrollPos = timelineDataWidth - timelineWidth;

				// $timeline.scrollLeft(scrollPos);

				// $fisheye.css("left", ($timeline.scrollLeft() * decadesWidth / timelineDataWidth) + fisheyeOffset); // Set default pos to right if required
				// checkArrows( {value: sliderPos} ); // disable arrow if slider right
				// console.log('Mascha Car', scrollPos);
			}
		}
		// $timeline.scrollLeft(scrollPos);
		// update(null, { value: sliderPos });
		$slider.slider("option", "value", sliderPos);
	}

	// //prevent default link action
	// $(".arrow").click(function () {
	// 	return false;
	// });

	// // disable arrow if slider right
	// if (timelineViewPos === "right") {
	// 	var temp = new Object();
	// 	temp.value = 100;
	// 	checkArrows(temp);
	// }

	/*
	// save clicked link to cookie using href, centre in timeline when page next visited
	if (values["cookie"]) {
		var cookieArray = new Object();
		var key = location.pathname;
		readCookie("sliderPos", cookieArray);

		if (cookieArray[key])
		{
			var link = $("a[href$=\"" + cookieArray[key] + "\"]", timeline);
			var linkPosition = link.offset().left - $timelineData.offset().left - ($timeline.width() / 2);
			$timeline.scrollLeft(linkPosition);

			var ui = new Object();
			ui["value"] = linkPosition * 100 / (timelineDataWidth - $timeline.width());
			update(null, ui);

			slider.slider("option", "value", ui["value"]);
		}

		// save link's href attribute to cookie
		$("a", timeline).click(function(event) {
			updateid("sliderPos", cookieArray, key, $(this).attr("href"), cookieExpire);
		});
	}*/




	// move slider one step
	function moveLeft() {
		var value = $slider.slider("option", "value");
		$slider.slider("option", "value", (value - sliderStep));

		checkSliderWithinBounds();
		timer = setTimeout(moveLeft, timerValue);
	}

	function moveRight() {
		var value = $slider.slider("option", "value");
		$slider.slider("option", "value", (value + sliderStep));

		checkSliderWithinBounds();
		timer = setTimeout(moveRight, timerValue);
	}

	// update timeline and fisheye position
	function update(e, ui) {
		// account for part of timeline within view
		var maxScroll = timelineDataWidth - timelineWidth;
		scrollPos = maxScroll * ui.value / 100;

		$timeline.scrollLeft( scrollPos );

		// console.log('cur-pos', scrollPos, {tdw: timelineDataWidth, tw: timelineWidth, uiv: ui.value});

		$fisheye.css("left", ($timeline.scrollLeft() * decadesWidth / timelineDataWidth) + fisheyeOffset);

		checkArrows(ui);
	}

	//disable arrows at limits
	function checkArrows(ui) {
		if (ui.value == 0) {
			$arrowLeft.addClass("arrowLeftDisabled").removeClass("arrowLeftEnabled");
			$arrowRight.addClass("arrowLeftEnabled").removeClass("arrowLeftDisabled");
		}
		else if (ui.value == 100) {
			$arrowLeft.addClass("arrowLeftEnabled").removeClass("arrowLeftDisabled");
			$arrowRight.addClass("arrowRightDisabled").removeClass("arrowRightEnabled");
		}
		else {
			$arrowLeft.addClass("arrowLeftEnabled").removeClass("arrowLeftDisabled");
			$arrowRight.addClass("arrowRightEnabled").removeClass("arrowRightDisabled");
		}
	}

	// slider plugin allows out of range values, breaking arrow buttons
	function checkSliderWithinBounds() {
		if ($slider.slider("option", "value") <= 0) {
			$slider.slider("option", "value", 0);
		} else if ($slider.slider("option", "value") >= 100) {
			$slider.slider("option", "value", 100);
		}
	}
};

