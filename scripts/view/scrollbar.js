/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/

$(document).ready(function(){
	
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

JS Requirements: jQuery 1.4, jQuery UI 1.8, jQuery UI slider plugin

History:
v0.01	TE 2010-05-21	Created
v0.02	GE 2010-05-27	Set so that initial view is set to the far right (to the latest section of a 

timeline/histogram)
						if init option value 'viewPos': 'right'
v0.03	GE 2010-05-28	Slider positioning logic to place above the 'decades' block if it exists, else just append to the end of #timeline.parent().
						Default fisheye position moved to right if viewPos=right
v0.04 	TE 2010-02-06	Fixed for xhtml content type
v0.05	TE 2010-02-08	Adapted for Point in Time
v0.06	TE 2010-06-21	Added global persistance for slider position
v0.07	TE 2010-06-23	Removed cookie, timeline now centres on relevant date, point in time on currentversion
v.0.8 	TE 2010-07-14	Fixed focus for timelines with centuries view
		
*/
$.fn.addSlider = function(values){
	
	var timer;
	var down = false;
	var timerValue = values["timerValue"];
	var sliderStep = values["sliderStep"];	
	var keyNavigation = values["keyNavigation"];
	var timelineViewPos = values["viewPos"]; // default: to the left
	
	var timeline = $(this);
	var timelineData = $("#timeline #timelineData");
		
	// include padding in width. timelineDataWidth.outerWidth() won't be right for padded children
	var timelineDataWidth = 0;	
	timelineData.children("ul,div").each(function () {
		timelineDataWidth += $(this).outerWidth();
	});
	
	var decades = $(".decades");
	var fisheye = $("");
	
	if (decades.length > 0)
		var decadesMarginLeft = parseInt(decades.css("margin-left").replace("px", "")); // forcetype as integer
	var scrollPos,sliderPos; 	
	
		
	if (timelineDataWidth >= timeline.width())
	{		
		// Set vars for default position of histogram view	
		if (timelineViewPos==="right"){ // view to right
			sliderPos = 100;
			scrollPos = timelineDataWidth - timeline.width();
			
		} else { // view to left
			sliderPos = 0;
			scrollPos = 0;
		}
		
		// hide existing scrollbar
		timeline.css("overflow", "hidden");
		
		// Position the scrollbar depending on whether there is a decades list
		timeline.parent().append('<div id="scrollbar"></div>'); // Default at the end of block
		if (decades.length){
			timeline.parent().append(decades); // Move the decades block after the slider if it exists
		}
		
		var scrollbar = $("#scrollbar");	
		scrollbar.append('<div id="handle" class="ui-slider-handle"></div>');		
		scrollbar.append('<a id="arrowLeft" class="arrow arrowLeftDisabled" href=""></a><span class="sliderEnd"></span><div id="slider"></div><span class="sliderEnd"></span><a id="arrowRight" class="arrow arrowRightEnabled" href=""></a>');
		
		var slider = $("#slider");
		var arrowLeft = $("#arrowLeft");
		var arrowRight = $("#arrowRight");
		slider.slider({animate:false, change: update, slide: update, step: sliderStep,value:sliderPos});
		
		// Set initial view of timeline
		timeline.scrollLeft(scrollPos);
		
		// add fisheye if parent has fisheye class
		if (timeline.parent().hasClass("fisheye"))
		{		
			timeline.parent().append('<div id="fisheye"></div>');		
			fisheye =	$("#fisheye");
			
			// account for absolute positioning offset
			var fisheyeOffset = $("#fisheye").position()["left"] + decadesMarginLeft;
			fisheye.width(timeline.width() / timelineDataWidth * decades.width());
			
			// Set default pos to right if required
			if (timelineViewPos==="right"){
				fisheye.css("left", (timeline.scrollLeft() * decades.width() / 

timelineDataWidth) + fisheyeOffset);
			
			}
		}
		
		// move slider on mousedown or keydown. When held down, mousedown fires only once, keydown repeatedly.
		arrowLeft
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
		.mouseleave(function() {clearTimeout(timer)})
		.keyup(function() {down = false; clearTimeout(timer)});
		
		arrowRight
		.mousedown(moveRight)
		.keydown(function(e) {
			if (!down && e.keyCode == 13) 
			{
				down = true;
				moveRight();
			}
		})
		.mouseup(function() {clearTimeout(timer)})
		.mouseleave(function() {clearTimeout(timer)})
		.keyup(function() {down = false; clearTimeout(timer)});
		
		// hook arrow keys
		if (keyNavigation)
		{		
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
		
		//prevent default link action
		$(".arrow").click(function () {
			return false;
		});
		
		// disable arrow if slider right		
		if (timelineViewPos === "right") {
			var temp = new Object();
			temp.value = 100;
			checkArrows(temp);
		}
		
		/*
		// save clicked link to cookie using href, centre in timeline when page next visited
		if (values["cookie"]) {			
			var cookieArray = new Object();
			var key = location.pathname;
			readCookie("sliderPos", cookieArray);
			
			if (cookieArray[key])
			{
				var link = $("a[href$=\"" + cookieArray[key] + "\"]", timeline);
				var linkPosition = link.offset().left - timelineData.offset().left - (timeline.width() / 2);
				timeline.scrollLeft(linkPosition);
			
				var ui = new Object();
				ui["value"] = linkPosition * 100 / (timelineDataWidth - timeline.width());
				update(null, ui);	
			
				slider.slider("option", "value", ui["value"]);
			}			
			
			// save link's href attribute to cookie
			$("a", timeline).click(function(event) {								
				updateid("sliderPos", cookieArray, key, $(this).attr("href"), cookieExpire);
			});			
		}*/
		
		// timeline
		// match /ukpga/1977 etc
		var path = location.pathname;
		var regex = /\/[^\/]*\/\d*-?\d*$/;
		
		var year = path.match(regex);
		
		if (year)
			year = year[0];
		
		var link = $("a[href$='" + year + "']", timeline);
		
		// point in time
		if (link.length != 1) {
			var link = $("#timeline #timelineData .currentVersion");
		}
		
		if (link.length == 1)
		{			
			var linkPosition = link.offset().left - timelineData.offset().left - (timeline.width() / 2);
			timeline.scrollLeft(linkPosition);
			
			var ui = new Object();
			
			// (divided by maxscroll)
			ui["value"] = linkPosition * 100 / (timelineDataWidth - timeline.width());
			update(null, ui);
			
			slider.slider("option", "value", ui["value"]);
		}
	}
	
	// move slider one step
	function moveLeft()
	{
		var value = slider.slider("option", "value");
		slider.slider("option", "value", value - sliderStep);
		
		checkSliderWithinBounds();
		timer = setTimeout(moveLeft, timerValue);
	}
	
	function moveRight()
	{
		var value = slider.slider("option", "value");		
		slider.slider("option", "value", value + sliderStep);	
		
		checkSliderWithinBounds();		
		timer = setTimeout(moveRight, timerValue);		
	}
	
	// update timeline and fisheye position
	function update(e, ui)
	{	
		// account for part of timeline within view				
		var maxScroll = timelineDataWidth - timeline.width();
		
		timeline.scrollLeft(maxScroll * ui.value / 100);
		
		//console.log(ui.value);
				
		fisheye.css("left", (timeline.scrollLeft() * decades.width() / timelineDataWidth) + 

fisheyeOffset);	
		
		checkArrows(ui);		
	}
	
	//disable arrows at limits
	function checkArrows(ui)
	{
		if (ui.value == 0) {
			arrowLeft.addClass("arrowLeftDisabled").removeClass("arrowLeftEnabled");
			arrowRight.addClass("arrowLeftEnabled").removeClass("arrowLeftDisabled");
		}
		else if (ui.value == 100) {
			arrowLeft.addClass("arrowLeftEnabled").removeClass("arrowLeftDisabled");
			arrowRight.addClass("arrowRightDisabled").removeClass("arrowRightEnabled");				
		}
		else {
			arrowLeft.addClass("arrowLeftEnabled").removeClass("arrowLeftDisabled");
			arrowRight.addClass("arrowRightEnabled").removeClass("arrowRightDisabled");
		}			
	}
	
	// slider plugin allows out of range values, breaking arrow buttons
	function checkSliderWithinBounds()
	{		
		if (slider.slider("option", "value") <= 0)
			slider.slider("option", "value", 0);			
		else if (slider.slider("option", "value") >= 100)		
			slider.slider("option", "value", 100);
	}	
};

