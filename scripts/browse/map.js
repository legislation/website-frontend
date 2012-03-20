/*
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

*/
/*

Browse scripts

One-liner: Highlight links on map hover
Requirements: jQuery framework: http://jquery.com/. jQuery UI effects core
Notes: linkApplies and linkExclusive control link styles. outofHotspotsDelay controls
time before hotspot fades after leaving map, betweenHotspotsDelay controls the delay before switching to the next hotspot. animTime controls the fade animation.


History:
v0.01	TE 2010-05-06	Created
v0.02	GE 2010-05-13	Removed link animation whilst keeping country animation
						Removed the unhighlighting of links when mouse leaves hotspots, links remain highlighted
					

*/
$(document).ready(function(){
	var linkApplies = {
		backgroundColor: '#BBBB'		
	}
	
	var linkExclusive = {
		backgroundColor: '#0066AA'
	}
	
	var linkOff = {
		backgroundColor: '#FFF'
	}

	var mapToLinks = {
		"scotlandarea": {"ukpga": linkApplies, "ukla": linkApplies, "asp": linkExclusive, "aosp": linkExclusive, "apgb": linkApplies, "uksi": linkApplies, "uksro": linkApplies, "ssi": linkExclusive, "dsi": linkApplies, "dssi": linkExclusive},
		"walesarea": {"ukpga": linkApplies, "ukla": linkApplies, "aep": linkApplies, "apgb": linkApplies, "mwa": linkExclusive, "uksi": linkApplies, "uksro": linkApplies, "wsi": linkExclusive, "dsi": linkApplies},
		"englandarea": {"ukpga": linkExclusive, "ukla": linkExclusive, "asp": linkApplies, "nia": linkApplies, "aosp": linkApplies, "aep": linkApplies, "aip": linkApplies, "apgb": linkApplies, "nisr": linkApplies, "mwa": linkApplies, "ukcm": linkApplies, "uksi": linkExclusive, "uksro": linkExclusive, "wsi": linkApplies, "ssi": linkApplies, "nisi": linkApplies, "ukci": linkApplies, "ukmo": linkExclusive, "mnia": linkApplies, "apni": linkApplies, "dsi": linkExclusive, "dnisr": linkApplies, "dssi": linkApplies},
		"niarea": {"ukpga": linkApplies, "ukla": linkApplies, "nia": linkExclusive, "aip": linkExclusive, "nisr": linkExclusive, "uksi": linkApplies, "uksro": linkApplies, "nisi": linkExclusive, "mnia": linkExclusive, "apni": linkExclusive, "dsi": linkApplies, "dnisr": linkExclusive}
	}
	
	var mapToImage = {
		"scotlandarea": "scotland",
		"walesarea": "wales",
		"englandarea": "uk",
		"niarea": "northernireland"
	}	
	
	var	mapImagesPath = "images/maps/";

	var outofHotspotsDelay = 0; // Not used anymore, links always highlighted
	var betweenHotspotsDelay = 500;
	var animTime = 500;
	
	//------------------------------------------
	
	var timerRunning = false;
	var timer;
	var inMapArea = false;	
	var lastHotspot = [];		
	
	$("#map area")
	.hover(mapHandlerIn, mapHandlerOut)
	.focus(mapHandlerIn) // focus and blur handle keyboard focus
	.blur(mapHandlerOut);	
	
	// called by mouseenter, focus or timer
	function mapHandlerIn(e) {					
			// if caller is event, use event target hotspot. If timer, use last hotspot exited
			if (e.type == "mouseenter" || e.type == "focus")
			{
				currentHotspot = this;
				inMapArea = true;
			}	
			else
			{
				currentHotspot = e;
			}
			
			// if timer still running, or cursor out of the map area, don't change hotspot
			if (!timerRunning && inMapArea)
			{
				// show related map image, hide all others
				$(".mapImage").not($("#" + mapToImage[currentHotspot.id])).stop(true).animate({opacity: 0}, animTime);
				$("#" + mapToImage[currentHotspot.id]).stop(true).animate({opacity: 1}, animTime);
				
				var links = mapToLinks[currentHotspot.id];
				
				// Clear links to start highlighting from scratch	
				//$(".legTypes a").parent().delay(outofHotspotsDelay).queue(function() {$(this).stop(true, true).removeClass('legA').removeClass('legE')});
				
				// show related links
				for (var i in links)
				{		
					if (links[i] == linkExclusive)											
						$(".legTypes #" + i).parent().stop(true).animate({opacity: 0.5}, 0).animate({opacity: 1}, 0).removeClass('legA').addClass('legE');
					
					else					
						$(".legTypes #" + i).parent().stop(true).animate({opacity: 0.5}, 0).animate({opacity: 1}, 0).removeClass('legE').addClass('legA');
				}		
				
				// if last highlighted links not in current hotspot, unhighlight
				for (var j in lastHotspot)
				{
					match = false;					
					for (var k in links)
					{
						if (j == k)
							match = true;
					}
					
					if (!match)											
						$(".legTypes #" + j).parent().removeClass('legA').removeClass('legE');
				}	
			}						
	}
	
	// called by mouseleave or focus
	function mapHandlerOut() {
		var links = mapToLinks[this.id];
		lastHotspot = links;
				
		//call mapHandlerIn after betweenHotspotsDelay seconds
		currentHotspot = this;
		inMapArea = false;
		clearTimeout(timer);
		timerRunning = true;
		timer = setTimeout(function() {timerRunning = false; mapHandlerIn(currentHotspot)}, betweenHotspotsDelay);
	}
});