/*

Legislation.gov.uk Homepage Chrome Initialisation

One-liner: All script initialisation for Homepage is placed here
Requirements: 
	jQuery framework: http://jquery.com/

History:
v0.01	GM	Created

*/
/*
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

*/
// Create namespace values for SlideShow variables, denoted 'ss'
var ss = new function(){};

$(document).ready(function(){	
	
	ss.TRANSITION_LENGTH = 250;
	ss.DISPLAY_LENGTH = 10000;
	ss.curLink = -1;
	ss.CONTAINER_JQ = $("#intro");
	ss.CONTENT_JQ = $("#animContent");	
	
	// add js class to layout1 to prevent selector bugs in IE6
	$("#layout1").addClass("js");
	
	slideShow($("#countryLeg"), ss.TRANSITION_LENGTH, ss.DISPLAY_LENGTH);		
});



// Basic function, this sets up and creates the default animation
function slideShow($linkList, TRANSITION_LENGTH, DISPLAY_LENGTH){
	this.$linkList = $linkList;
	this.TRANSITION_LENGTH = TRANSITION_LENGTH;
	this.DISPLAY_LENGTH = DISPLAY_LENGTH;
	
	// Event Handler
	$("a", $linkList).click(function(event){
		event.preventDefault();
				
		// Stop the animation
		clearTimeout(ss.timeout);
		
		// Call the effect
		fadeTransition($(this).attr('id'), TRANSITION_LENGTH);	
	});
	
	// Bring the linkList into focus to begin with
	$linkList.fadeTo(TRANSITION_LENGTH, 1);
	
	// Begin the slideshow animation
	timedTransition($linkList);
	
}

function fadeTransition(newSectionId){
	// load all of the DOM manipulation into variables
	// to speed client side access and prevent animation
	// delays during the script
	this.$newSection = $("#"+newSectionId);
				
	// default change animation animation
	// works for both event handlers and normal animation
	ss.CONTENT_JQ.fadeOut(ss.TRANSITION_LENGTH, function() {		
		ss.CONTAINER_JQ.addClass($newSection.attr("id"));
		ss.CONTENT_JQ.fadeIn();
	});
ss.CONTAINER_JQ.removeClass();
}


function timedTransition($linkList)
{
	this.$linkList = $linkList;
				
	var linkAry = $("a", $linkList);
	var newSectionId, currentLinkObj;
	
	
	if (ss.curLink<linkAry.length-1){
		ss.curLink++;
		currentLinkObj = linkAry[ss.curLink];
		newSectionId = $(currentLinkObj).attr("id");		
	} else {
		ss.curLink = 0;
		currentLinkObj = linkAry[ss.curLink];
		newSectionId = $(currentLinkObj).attr("id");
	}
	
	// Play the animation
	fadeTransition(newSectionId);
	
	// Create a loop using basic JavaScript timing
	// make the timeout an object so it can be halted
	// on an event
	ss.timeout = setTimeout("timedTransition($linkList)",ss.DISPLAY_LENGTH);
}