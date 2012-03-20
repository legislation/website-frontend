/*
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

*/
/*

Legislation HelpBox

One-liner: Adds floating helpbox when help link clicked
Requirements: jQuery framework: http://jquery.com/
helpItem - The link that activated popup
help - The popup contents

Notes:


History:
v0.01	TE Created
v0.02	2010-04-27	GE	Modified close link to reference box rather than 'this' hierachy so it will close box in any position
v0.03	2010-04-27	GE	Added options to position where the box appears
v0.04 2010-09-16	TE	Added hover functionality

*/

$.fn.legHelpBox = function(helpBoxOptions) {
		
	$(this).each(function () {		
			// retrieve helpbox associated with link
			var helpbox = $($(this).attr('href'));
			
			// Config area
			var defaults = {
				horizBoxPos: 'right', 
				vertiBoxPos: 'top',
				hover: "no"	
			}
			
			var option = $.extend(defaults, helpBoxOptions); // overwrite defaults if options were passed during init
			
			//set initial state			
			helpbox.css({display: "none", position: "absolute"});
			
			$(this).parent().append(helpbox); // fix tab order
			
			// enable helpbox images
			// enable helpbox arrow
			$(".icon", $(this)).css({
				display: "block"
				});
			
			if (option.hover == "no")
				$(".close", helpbox).show();
			else
				$(".close", helpbox).css("display", "none");
			
			$(".close", helpbox).click(function(e) {
				e.preventDefault(); // disable anchor link
				helpbox.animate({opacity: "hide"}, "fast");
			});
			
			var popup = function(e){
								var offset = $(this).position(); // offset from parent element
								
								/*
								-------- Set the position based on the config and add classes to show arrows -----------
								Use outerWidth() to include padding in measurements as width() does not find this.
							    Include the link height in calculations to get absolute middle
							    The calculation order cascades down with the later conditionals taking precedent over the first
								*/
								// Set the options for vertically positioned top and bottom boxes
								(option.horizBoxPos == 'left') ? leftPosition = 0-(helpbox.outerWidth()) : leftPosition = 20;
								(option.vertiBoxPos == 'top') ?  topShowPosition = 0-(helpbox.outerHeight()+10) : topShowPosition = 15;
								
								// Set the options for middle positioned boxes
								if (option.horizBoxPos == 'middle')
									leftPosition = 0-(helpbox.outerWidth()/2)+$(this).outerWidth()/2;
								
								// Set the options for to the side top positioned boxes
								if (option.horizBoxPos != 'middle' && option.vertiBoxPos == 'top')
									topShowPosition = -15;
									
								// Set the options for to the side middle positioned boxes
								if (option.horizBoxPos != 'middle' && option.vertiBoxPos == 'middle')
									topShowPosition = 0-(helpbox.outerHeight()/2)+$(this).outerHeight()/2;									
									
								topHidePosition = 0;
								
								addClasses();
								
								e.preventDefault(); // disable anchor link		
								
								// fix for IE7 - z-index is reset for positioned list elements. Ensures popup's parent has higher z-index than its siblings
								$(this).parent('li').css('z-index', 5).siblings('li').css('z-index',1);
								
								if (helpbox.css("display") == "none")
								{
									$(".help").animate({opacity: "hide"}, "fast"); // hide other helpboxes
									
									// topShowPosition,topHidePosition & leftPosition from inialisation
									helpbox.css({left: offset["left"] + leftPosition, top: offset["top"] + topHidePosition} ); //reset position
									
									helpbox.animate({opacity: "show", left: offset["left"] + leftPosition, top: offset["top"] + topShowPosition}, "fast", function() {
												
																																								   });
								}
								else
								{
									helpbox.animate({opacity: "hide", left: offset["left"] + leftPosition, top: offset["top"] + topHidePosition}, "fast");
								}
			
					
				
				function addClasses() {
					/* This function decides the class that gets added to the box
					   Format is helpTo[horizontalPosition][verticalPosition]		   
					   Usually this is to add an arrow in the right position, add side highlighting, etc.		
					*/
					
					// Use shorter var names for easier reading
					var opH = option.horizBoxPos;
					var opV = option.vertiBoxPos
					
					if (opH == 'left' && opV =='top'){
						helpbox.addClass('helpToLeftTop');		
					} else if (opH == 'left' && opV =='middle') {
						helpbox.addClass('helpToLeftMid');	
					} else if (opH == 'left' && opV =='bottom') {
						helpbox.addClass('helpToLeftBot');	
					} else if (opH == 'right' && opV =='top') {
						helpbox.addClass('helpToRightTop');	
					} else if (opH == 'right' && opV =='middle') {
						helpbox.addClass('helpToRightMid');	
					} else if (opH == 'right' && opV =='bottom') {
						helpbox.addClass('helpToRightBot');	
					} else if (opH == 'middle' && opV =='top') {
						helpbox.addClass('helpToMidBot');			
						// Middle Middle can't exist as it would put it over the link itself
					} else if (opH == 'middle' && opV =='bottom') {
						helpbox.addClass('helpToMidTop');	
					}
				}
			};
			
			// fade popup in/out on help link click
			$(this)
			.click(popup);
			
			if (option.hover == "yes")
			{
				$(this)
				.hover(popup, function () {
					helpbox.animate({opacity: "hide"}, "fast");
				});
			}
			
	});
};
