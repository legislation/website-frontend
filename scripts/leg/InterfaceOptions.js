/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/
/*

Legislation interface options

One-liner: Opens the interface options boxes when the resepective userInterfaceElement is clicked
Requirements: jQuery framework: http://jquery.com/

Notes:
Tab index cannot be improved upon for accessibility without potentially overlaying other UI items
such as the 'previous' or 'next' buttons.
CSS - the .js class is used to initially hide the boxes within the CSS file, not a JS function. This
is to reduce the client processing on loadup.

History:
v0.01	GM	2010-03-15 Created
v0.02	GM	2010-03-24 Changed to overlay and made into a generic plugin rather than code specific function
v0.03	GM	2010-03-25 Corrected the 'return' so that chaining works correctly
v0.04	GM	2010-04-15 Simplified the 'close link into a function to prevent the duplication of code

*/

$.fn.legInterfaceOptions = function() {
	// Apply to each item in the array
	this.each(function () {
		// create a jQuery control with the link that was clicked
		var legIntControlLink = $(this);
		
		// retrieve helpbox associated with link as a jQuery obj
		var intOption = $($(this).attr('href'));
		
		// insert via DOM injection above content
		$("#content div:first").before($($(intOption))); 			
			
		// insert close link inside the intOption
		$("<a/>")
		.attr("href", "#")
		.html('<img src="/images/chrome/closeIcon.gif" alt="Close" />')
		.addClass("closeLink")
		.prependTo(intOption)
		.click(function(e) {
			// event handler to close the intOption box
			e.preventDefault();  // disable anchor link
			intOption.slideUp(400);
			
			// Remove all other userFunctionalElement highlighting
			removeControlHighlights();
		});
			
		// Open/close the box on click		
		return $(this).click(function(e){
			e.preventDefault(); // disable anchor link	
			
			// Remove all other userFunctionalElement highlighting
			removeControlHighlights();
			
			// Find all the interface options, this variable is used later
			// to find out if all the 'close' animations have finished
			var legIntAllOptions = $(".interfaceOptions").length;
			
			if (intOption.css("display") == "none")
			{	
				// OPEN the intOption box
			
				// Create the animation count variable
				var legIntOptAnimationCount = 0;
								
				// hide other interface options
				$(".interfaceOptions").slideUp(400, function(){													 
					
					// Count the closing animations
					legIntOptAnimationCount++;
					
					// once the hiding animation has finished, open up the new option
					if (legIntOptAnimationCount === legIntAllOptions){	
						// add the class to show that the controlling link has been activated
						legIntControlLink.removeClass("close").addClass("close");
						intOption.slideDown(400);
					}
				});	
			} else {
				// CLOSE the intOption box
				intOption.slideUp(400);
			}
		});
	});
	
	function removeControlHighlights(){
			// Remove userFunctionalElement highlighting
			$(".interface a").removeClass("close");		
	}
	
	return this;
};
