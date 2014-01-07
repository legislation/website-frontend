/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
/*

Legislation.gov.uk Chrome Initialisation

** The file ../chrome.js is created by Ant concatenation of 
** all files within the leg directory with the ChromeInit.js
** file containing all initialisation scripts. Only edits
** scripts withing the Leg directory.

One-liner: All script initialisation for UI viewing is placed here
Requirements: 
	jQuery framework: http://jquery.com/
	jquery.cookie.js
	leg/ExpandCollapse.js
	leg/ToCExpandCollapse.js
	leg/GeoExtent.js
	leg/InterfaceOptions.js
	leg/ModalWin.js
	leg/TocExpandCollapse.js
	leg/HelpItem.js

History:
v0.01	GM	Created
v0.02	GM	2010-03-13	ToC scripts changed to reflect positioning changes and added global expand/collapse
v0.03	GM	2010-03-14	Status warning box: moved open/close element for static positioning, added logic when to add
						the open/close link.
v0.04	GM	2010-03-15	Added functionality for the Legislation interface options
v0.05	GM	2010-03-15	Changed open/close text from 'open' to 'more'
v0.05	GM	2010-03-23	Added breadcrumb expand and collapse
v0.06	GM	2010-03-25	Added test modal window links, added preloadBg animation
v0.07	GM	2010-03-25	Added logic to ToC script so expand all only initialised if class is available onload
v0.08	GM	2010-04-01	Amended StatusWarningOptions to only appear if #statusWarningSubSections are available
v0.09	GM	2010-04-08	Added div to Open/Close links to fix IE layout
v0.10	GM	2010-04-19	Added page variables and implemented ToC persistance
v0.11	GM	2010-04-26	Added basic GeoExtent functionality
v0.12	GM	2010-04-30	Enabled help items
v0.13	TE 	2010-06-22	Added persistance using cookie to legExpandCollapse
v0.14	GM	2010-07-05	Scripts of a similar type placed into seperated document.ready functions to prevent single 
						script failure preventing other scripts from loading.

*/

var legGlobals = new Object();
$(document).ready(function(){
	initGlobals();		
});

function initGlobals (){											
											
	// Page variables - currently used for ToC persistance
	// Uses the content URI to find the legislation number for basic unique ID
	// Added to the legGlobals object for Global Access outside of the document.ready function
	
	var contentUri, regExpForToCId, legPageId, cookieId, legCookieExpire, legTocType, tocCookieId;
	legPageId = []; // initialise the variable as array
	
	// find if the page is a Toc page and if so what type, can be used for tests
	if ($("#layout2.legToc").length){
		legTocType = "leg";
	} else if($("#layout2.legEnToc").length){
		legTocType = "en";
	}
	
	// Only populate on ToC page
	if (legTocType){	
		if ($("#legContentLink a").length){
			contentUri     = $("#legContentLink a").attr("href");	
	  		regExpForToCId = /^\/([a-z]*)\/([^\/]*)\/([^\/]*)/i;
			legPageId      = contentUri.match(regExpForToCId);
		
			// Creates a toc cookie id in format:
			// toc_typeOfLeg_Year/Geo_UniqueNum
			tocCookieId	   = "toc"+"_"+legPageId[1]+"_"+legPageId[2]+"_"+legPageId[3];
        } else {
			legTocType = "";
		}
	}		
	legCookieExpire = 5;  //days to keep persistance	
							   
	// Add the class .js to swtich JavaScript styles on
	$("#layout1")
	.addClass("js");
		
	// Asign values to the global object:
	if (legTocType)
		legGlobals.legTocType = legTocType;
	if (tocCookieId)
		legGlobals.tocCookieId = tocCookieId;
	legGlobals.legCookieExpire = legCookieExpire;
	// global object to hold legExpandCollapse values
	legGlobals.expandCollapseState = new Object();
}



$(document).ready(function(){
	// Status warning box, only add open/close link if there is more than intro text or there are div children
	// Use .length to get conditional value rather than getElementById so we can use the jQuery framework selectors and 
	// use the object further if needed.
	if ($("#statusWarningSubSections").length){ 
		$("p.intro:first", "#statusWarning")
		.after($("<div/>").addClass("linkContainer"));		
		
		$("<a/>")
		.attr('href', '#statusWarningSubSections')
		.appendTo("#statusWarning .title:first .linkContainer")
		.addClass("expandCollapseLink")
		.legExpandCollapse([config.statusWarning.expandCollapseLink.message1[LANG] + '<span class="accessibleText">' + config.statusWarning.expandCollapseLink.message2[LANG] + '</span>', config.statusWarning.expandCollapseLink.message3[LANG] + '<span class="accessibleText">' + config.statusWarning.expandCollapseLink.message2[LANG] +'</span>']);
	}
	
	// Effects to be applied
	$("<div/>").addClass("linkContainer").appendTo("#statusEffectsAppliedSection .title");
	
	$("<a/>")
	.attr('href', '#statusEffectsAppliedContent')
	.appendTo("#statusEffectsAppliedSection .title .linkContainer")
	.addClass("expandCollapseLink")
	.legExpandCollapse([config.statusEffectsAppliedSection.expandCollapseLink.message1[LANG] + '<span class="accessibleText">' + config.statusEffectsAppliedSection.expandCollapseLink.message2[LANG] + '</span>', config.statusEffectsAppliedSection.expandCollapseLink.message3[LANG] + '<span class="accessibleText">' +  config.statusEffectsAppliedSection.expandCollapseLink.message2[LANG] + '</span>']);
	
	// Changes to be applied
	$("<div/>").addClass("linkContainer").appendTo("#changesAppliedSection .title");
	
	$("<a/>")
	.attr('href', '#changesAppliedContent')
	.appendTo("#changesAppliedSection .title .linkContainer")
	.addClass("expandCollapseLink")
	.legExpandCollapse([config.changesAppliedContent.expandCollapseLink.message1[LANG] + '<span class="accessibleText">' + config.changesAppliedContent.expandCollapseLink.message2[LANG] + '</span>', config.changesAppliedContent.expandCollapseLink.message3[LANG]+  '<span class="accessibleText">' + config.changesAppliedContent.expandCollapseLink.message2[LANG] + '</span>']);
	
	// Commencement orders to be applied
	$("<div/>").addClass("linkContainer").appendTo("#commencementAppliedSection .title");
	
	$("<a/>")
	.attr('href', '#commencementAppliedContent')
	.appendTo("#commencementAppliedSection .title .linkContainer")
	.addClass("expandCollapseLink")
	.legExpandCollapse([config.commencementAppliedContent.expandCollapseLink.message1[LANG] + '<span class="accessibleText">'+ config.commencementAppliedContent.expandCollapseLink.message2[LANG]+'</span>',  config.commencementAppliedContent.expandCollapseLink.message3[LANG] + '<span class="accessibleText">' + config.commencementAppliedContent.expandCollapseLink.message2[LANG]+ '</span>']);				   
});
						   
$(document).ready(function(){	
	// Quicksearch	
	$("#quickSearch").children().filter("a")
	.addClass("expandCollapseLink")
	.legExpandCollapse(['<span>' + config.quickSearch.expandCollapseLink.message1[LANG] + '<span class="accessibleText">' + config.quickSearch.expandCollapseLink.message2[LANG] + '</span></span>','<span>' + config.quickSearch.expandCollapseLink.message1[LANG] + '<span class="accessibleText">' +config.quickSearch.expandCollapseLink.message3[LANG] + '</span></span>','<span>'], {
		state: legGlobals.expandCollapseState,
		expires: legGlobals.legCookieExpire,
		open: "open"
	});	
});
                                       
$(document).ready(function(){
	// ToC Scripts -----------------------------------------
	// Create the links that expand/collapse the small trees 
	if (legGlobals.legTocType) {
		
		// create unique ids for all parts, required for persistance
		var idCount = 0;
		$("li.tocDefaultExpanded, li.tocDefaultCollapse").each(function () {
			 $(this).attr("id", "id" + idCount);
			 idCount++;
			 });
		
		$("<a/>")
		.attr('href', '#')
		.addClass("expandCollapseTocLink userFunctionalElement")
		.prependTo("li.tocDefaultExpanded")
		.legTocExpandCollapse(legGlobals.tocCookieId, legGlobals.legCookieExpire);
		
		$("<a/>")
		.attr('href', '#')
		.addClass("expandCollapseTocLink userFunctionalElement")
		.prependTo("li.tocDefaultCollapse")
		.legTocExpandCollapse(legGlobals.tocCookieId, legGlobals.legCookieExpire);
		
		// Create the area to hold the expand all/collapse all scripts only if tocControlsAdded.
		if ($("#tocControlsAdded").length != 0){
			$('<ul class="tocGlobalControls"><li></li></ul>')
			.prependTo("div.LegContents");
		
			/*$("<a/>")
			.attr('href', '#')
			.addClass("userFunctionalElement tocCollapseAll")
			.appendTo(".tocGlobalControls li:first")
			.html("Collapse all")
			.click(function(event){
							event.preventDefault();
							$("a.expandCollapseTocLink").removeClass("expand").nextAll("ol").hide();
							});
							
			*/
			
			$("<a/>")
			.attr('href', '#')
			.addClass("userFunctionalElement tocExpandAll")
			.appendTo(".tocGlobalControls li:last")
			.html(config.links.message1[LANG])
			.toggle(function (event) {
					$(this).html(config.links.message2[LANG]);					
					event.preventDefault();
					$("a.expandCollapseTocLink").removeClass("expand").nextAll("ol").hide();								
			},
				function (event) {
					$(this).html(config.links.message1[LANG]);				
					event.preventDefault();
					$("a.expandCollapseTocLink").removeClass("expand").addClass("expand").nextAll("ol").show();						
			});
		}	
	}				   
});

$(document).ready(function(){
	// Interface control buttons
	$("a", "#breadcrumbControl").legInterfaceOptions();
	$(".print a", "#viewPrintControl").legInterfaceOptions();		   
});

$(document).ready(function(){
	// Modal windows for interface controls, only functions on a link if the class 'warning' is present
	$(".warning", "#printOptions").legModalWin();
	$(".warning", "#openingOptions").legModalWin();				   
});


//  $(document).ready(function(){
//	$(this).showModalDialog();
//});

$(document).ready(function(){
	// Slightly different way of adding the links, wrap the <a> element around the <h2> inner HTML
	var $openingOptionsTitle = $(".title:first", "#openingOptions").children("h2");
	var openingOptionsTitleTxt = $openingOptionsTitle.html();	 
	// Reset the inner HTML to nothing as added when open/close link is added
	$openingOptionsTitle.html("");
	
	$("<a/>")
	.attr('href', '#openingOptionsContent')
	.addClass("expandCollapseLink")	
	.appendTo($openingOptionsTitle)
	.legExpandCollapse([openingOptionsTitleTxt+'<span class="accessibleText">Expand opening options</span>',openingOptionsTitleTxt+'<span class="accessibleText">Collapse opening options</span>'], {
		state: legGlobals.expandCollapseState,
		expires: 5
	});	
});

$(document).ready(function(){
	// Geographical extent show/hide
	function legGeoExt(){
		// load the control into a variable for continued use
		var $chkBox = $("input#geoExt");
		
		$chkBox.click(function(event){
			$(".LegExtentRestriction").toggle();		
		});
		
		$chkBox = ""; // release memory from control
	}
	legGeoExt(); // initialise function		   
});

$(document).ready(function(){
	// Helpbox popups
	$("a.helpItemToTop").legHelpBox({horizBoxPos: 'middle', vertiBoxPos: 'top'});	
	$("a.helpItemToBot").legHelpBox({horizBoxPos: 'middle', vertiBoxPos: 'bottom'});
	$("a.helpItemToMidLeft").legHelpBox({horizBoxPos: 'left', vertiBoxPos: 'middle'});	
	$("a.helpItemToMidRight").legHelpBox({horizBoxPos: 'right',	vertiBoxPos: 'middle'});	
	$("a.helpItemToLeft").legHelpBox({horizBoxPos: 'left',vertiBoxPos: 'top'});	
	$("a.helpItemToRight").legHelpBox({horizBoxPos: 'right',	vertiBoxPos: 'top'});
	$("a.hover").legHelpBox({horizBoxPos: 'left', vertiBoxPos: 'middle', hover: "yes"});				   
});

$(document).ready(function(){
	// Img replacement
	$(".userFeedbackImg").imgReplace();					   
});

$(document).ready(function(){
	//Text search matches skip links - only should be added if a match ID exists
	if ($('#match-1').length) {
		previousNextTextMatchLinks();
	}
});

$(document).ready(function(){
	if (document.location.hash !== '') {
		//After a search, use the hash of the document location to add a query to the ToC link
		$('#legTocLink a').each(function () { 
			$(this).attr('href', $(this).attr('href') + '?' + encodeURI(document.location.hash.substring(1))); 
		});
		//and preserve the hash through links to other views of the document
		$('.prevNextNav a').each(function () { 
			$(this).attr('href', $(this).attr('href') + '#' + encodeURIComponent(document.location.hash.substring(1))); 
		});
		$('#openingOptionsContent a').each(function () { 
			$(this).attr('href', $(this).attr('href') + '#' + encodeURIComponent(document.location.hash.substring(1))); 
		});
	}
});
/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
/*
Legislation Expand and Collapse

One-liner: Expand and collapse box with the controlling link being created by another function
Usage: .legExpandCollapse(['More', 'Close'], cookieArray);
Requirements: jQuery framework: http://jquery.com/
Notes:
CSS - position: relative on the expanding element causes problems with IE by rendering all child
elements after the animation, avoid if possible. By using on a child element that element is 
rendered before the animation has begun and could look confusing.
CookieArray is an object used to store cookie key value pairs. If it isnt passed, will default to contracted

History:
v0.01	GM	Created
v0.02	GM	2010-03-15	Changed open/close text from 'open' to 'more'
v0.03	TE 	2010-06-22	Added persistance using cookie

*/
$.fn.legExpandCollapse = function(htmlValues_arr, options){

	if (options)
	{
		var cookieArray = options.state;
		var expires = options.expires;
		if (!expires)
			expires = 0;
		var open = options.open;
	}
	
	if (cookieArray)
		readCookie("legExpandCollapse", cookieArray);
	var href = $(this).attr("href");
	
	var htmlExpanded, htmlContracted;
	
	// Check to see if any values have been passed to overwrite the defaults
	if (htmlValues_arr) {
		htmlContracted = htmlValues_arr[0];
		htmlExpanded = htmlValues_arr[1];
	}
	else {
		htmlContracted = "More";
		htmlExpanded = "Close";
	}
	
	// default is to hide the element
	if (href && cookieArray && (cookieArray[href.substring(1)] == "show")) {
		$(this).html(htmlExpanded).addClass("close");
		$($(this).attr('href')).show();
	}
	else if (href && cookieArray && (cookieArray[href.substring(1)] == "hide")) {
		$(this).html(htmlContracted)
		$($(this).attr('href')).hide();
	}
	//default open
	else if (open)
	{
		$(this).html(htmlExpanded).addClass("close");
		$($(this).attr('href')).show();
	}
	else {	
		$(this).html(htmlContracted);
		$($(this).attr('href')).hide();
	}
	
	// Event Handlers
	return $(this).click(function(e){
		if (!$(this).hasClass("close")) {
			var href = $(this).attr("href");
			$(href).slideDown(400);
			$(this).html(htmlExpanded).toggleClass("close");
			if (cookieArray)
				updateid("legExpandCollapse", cookieArray, href.substring(1), "show", expires);
			e.preventDefault();
		}
		else {
			var href = $(this).attr("href");
			$(href).slideUp(400);
			$(this).html(htmlContracted).toggleClass("close");
			if (cookieArray)
				updateid("legExpandCollapse", cookieArray, href.substring(1), "hide", expires);
			e.preventDefault();
		}
	});
		
	/*
	 * Cookie Code
	 */
	
	function updateid(cookieName, cookieContents, id, value, cookieExpire) {
		cookieContents[id] = value;
		updateCookie(cookieName, cookieContents, cookieExpire);
	}
	
	function deleteid(cookieName, cookieContents, id, cookieExpire) {
		delete cookieContents[id];		
		updateCookie(cookieName, cookieContents, cookieExpire);
	}
	
	function updateCookie(cookieName, cookieContents, cookieExpire) {
		var temp = "";
		for (var i in cookieContents)
		{
				temp += (i + "#" + cookieContents[i] + ";");
		}		
		
		if (!cookieExpire)
			var cookieExpire = null;
		
		$.cookie(cookieName, temp, {path: '/', expires: cookieExpire});
	}
	
	// format is id#page;id#page
	function readCookie(cookieName, cookieContents) {
		var cookie = $.cookie(cookieName);
		if (cookie)
		{
			var elements = cookie.split(';');
		
			for (var i = 0; i < elements.length; i++) {
				if (elements[i] != "") 
				{
					var value = elements[i].split("#");
					var page = value[0];
					var value = value[1];
					cookieContents[page] = value;
				}				
			}		
		}		
	}
	
	function eraseCookie(cookieName) {
		$.cookie(cookieName, null, {path: "/"});
	}	
};
/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

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
/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
/*

Legislation Img Replace

One-liner: Progressive enhancement image swap
Usage: html: <a href="#"><img src="basename_default" class="userFeedbackImg"></a>
		$(".userFeedbackImg").imgReplace();
		the script looks for all elements with this class in a page and applies the appropriate event listeners
		and image preloaders.
Requirements: jQuery framework: http://jquery.com/

History:
v0.01	2010_21_06	GM	Created

*/
$.fn.imgReplace = function(){
	
	$(this).each(function () {
		
		// Load images for preload
		var defaultImg 	= this.src;
		var hoverImg 	= this.src.replace("_default","_hover");	
		var disabledImg = this.src.replace("_default","_disabled");	
		//$.preloadImages(defaultImg, hoverImg);
		
		
			// Add event handlers
			$(this).hover(
				 function()
				 {
					 // Only run if the link/img is not disabled
					 if(!$(this).parent().hasClass("disabled"))
					 	this.src = hoverImg;
				 },
				 function()
				 {
						this.src = defaultImg;
				 }
			);	
	});
	
	// return this to keep chaining alive
	return this;
};
/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

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
/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
/*

Legislation Modal Window

One-liner: Overlays a div on top of the main content

Usage: $(.linkClass).legModalWin()

Requirements: 
jQuery framework- http://jquery.com/
<div id="modalBg"> to be attached to the XHTML document
CSS to control z-index for overlays
Div acting as modal window to already have been loaded

Notes:
Parts of this function are taken from 
http://www.queness.com/post/77/simple-jquery-modal-window-tutorial
The initial link @href needs to contain the id of the modal window that it will initialise for this script to work.

History:
v0.01	GM	Created
v0.02	2010-03-25	GM	Changed to work with adjustments made to layout, now picks up the link href target as the modal window
v0.03	Bug fixed: added jQuery chaining ability
v0.04	Fixed Google Chrome positioning bug by making W3C window size method the first, jQuery method second

*/

$.fn.legModalWin = function(options){
	// required for chaining, refer to jQuery API for more details
	$(this).each(function () {
						   
		// Create variables and constants for storage, these can be overwritten in the normal jQuery way
		var modalWinJquery_str;
		var settings = {  
		 type: 'defaultWin',
		 fadeLength: 400,  
		 bgJqueryStr: '#modalBg',
		 closeLinkId_str: '#',
		 closeLinkIdJQuery_str: '#',  
		 closeLinkTxt: 'Cancel'
		};  
		var option = $.extend(settings, options);
		
		if (option.type == 'defaultWin'){			
			// The default modal window is a link to a pre-existing disalogue box
			modalWinJquery_str = $($(this).attr('href'));
			// Create a close this window link and attach to the modal window, along with the event handler
			$("<li/>")
			.addClass('cancel')
			.html('<a href="#" class="userFunctionalElement"><span class="btl"></span><span class="btr"></span>'+option.closeLinkTxt+'<span class="bbl"></span><span class="bbr"></span></a>')
			.prependTo($(modalWinJquery_str).children("div:last").children("ul"))
			.click(function(event){
				event.preventDefault();		
				closeModWin();	
			});
			
			// Once user clicks continue, the modalwin closes
			$("li.continue a", modalWinJquery_str).click(closeModWin());
		}
		else if(option.type=='testingModal'){
			modalWinJquery_str = option.parentDiv;
			// Create a close this window link and attach to the modal window, along with the event handler
			var close= modalWinJquery_str.find('.close')
			.click(function(event){
				event.preventDefault();		
				closeModWin();
			});
			
		}
		// When the link that opens the modal win is clicked
		$(this).click(function(event){	
				event.preventDefault();	
				
				//Get the window height and width  
				var winH = window.innerHeight; // get W3C val for browsers that can handle it
				if (!winH)
					winH = $(window).height(); // use jQuery if they can't 
				var winW = window.innerWidth;
				if (!winW)	
					winW = $(window).width();
				
				// Work out centering of the window and special functions
				var topPos, leftPos, height, width;
				if (option.type == 'defaultWin'){
					// The default option requires minor positioning
					topPos  = winH/2-$(modalWinJquery_str).height()/2;
					leftPos = winW/2-$(modalWinJquery_str).width()/2;
					height  = 'auto'
				} 
				else {	
					// The previewImg type of modal window is a link from a thumbnail or preview image
					
					// Find the Image URI and create the SRC attribute for iFrame
					var modalWinIframeSrc = 'http://www.legislation.gov.uk/tools/displayimage?URL=' + $(this).attr('href');
			
					// As this <div> isn;t embedded into the XHTML the modal win needs to be created here
					$('<div>')
					.attr('id', 'previewImgWin')
					.addClass('modWin')
					.appendTo('#leg')					
					
					modalWinJquery_str = '#previewImgWin'; // Set this to apply css and event handlers
								
					// Add the iframe and pass the URi as an argument for the destination HTML to parse
					$(modalWinJquery_str)
					.html('<iframe src="' + modalWinIframeSrc + '"></iframe>')
					.prepend('<a href="#" class="closeLink"><img src="/images/chrome/closeIcon.gif" alt="Close"/></a>')
					.prepend('<h2 class="title">Large image view</h2>')
					
					// If the closelink is pressed, close the window
					$('a', modalWinJquery_str)
					.click(function(e) {
					  e.preventDefault();
					  closeModWin()
					});
					
					// Set the width and height as large as the viewable window
					height  = 0.9 * winH
					width   = 0.9 * winW
					
					// Set the positioning
					topPos  = $(window).scrollTop() + (0.0125 * winH);
					leftPos = winW/2-width/2;
					
					// Remove scrollbars from the bg					
					$('body').css('overflow', 'hidden');
				}
				
				// IE6 doesn't support fixed position
				if ($.browser.msie && parseInt($.browser.version) < 7) {
					var position = "absolute";
				} else if (option.type == 'previewImg') {
					var position = "absolute";
				} else {
					var position = "fixed";
				}			
				
				// Apply the popup window to center and style elements within
				$(modalWinJquery_str).css({'top': topPos, 'position': position, 'height': height, 'width': width, 'left': leftPos}); 
				$('iframe', modalWinJquery_str).css({height: '90%', width: '98%'}).hide // used for image option
				
				// Set the background width to the window width so that there's no
				// horizontal nav bars
				$(option.bgJqueryStr).css({'width':$(document).width(),'height':$(document).height()});
				
				// Show animation
				$(modalWinJquery_str).show(option.fadeLength);
				$(option.bgJqueryStr).fadeTo(option.fadeLength, 0.8).css({'width':$(document).width(),'height':$(document).height()});	
				
				$('iframe', modalWinJquery_str).fadeIn("slow");

				
			});
		
			// Escape key also closes the modalwin
			$(document).keypress(function(e) {
				if (e.keyCode == 27) {
					closeModWin()
				}
			});
			
			// Close function
			function closeModWin() {
				if (option.type == 'previewImg') {
					$(modalWinJquery_str).remove();
					$('body').css('overflow', 'visible');
				} else {
					$(modalWinJquery_str).hide(option.fadeLength);
				}
				$(option.bgJqueryStr).fadeOut(option.fadeLength);		
			}
	});
		
	
	// return this to keep chaining alive
	return this;				   
};
/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
/*

Legislation Table of Content Expand and Collapse

One-liner: Expand and collapse ToC elements with the controlling link being created by another function
Usage: .legToCExpandCollapse();
Requirements: jQuery framework: http://jquery.com/

History:
v0.01	GM	Created
v0.02	GM	2010-03-12	Modified to include different default states, initiated by class driven by XHTML
v0.03	TE	2010-04-19	Added Cookie persistance

*/
$.fn.legTocExpandCollapse = function(pageID, cookieExpire){
	
	// using this method for inserting text and relying on CSS to show correct atrribute as less intensive on DOM.
	// The divider is made availalable in case CSS is disabled.
	
	$(this).html('<span class="tocExpandText">' + config.links.message3[LANG] + '</span><span class="tocTextDivider">/</span><span class="tocCollapseText">' + config.links.message4[LANG] + '</span>');

 

	// Find the default state from the XHTML and apply
	var tocDefaultState;
	
	////////////////////////////////////////////////////////
		
	var oldPageID = "default";
	var associativeArray = readCookie();
	
	if (oldPageID != pageID) {
		eraseCookie();
		associativeArray = new Object();
	}
		
	// if cookie stored for related id, expand part
	$(this).each(function () {
			var part = $(this).parent();		
			
			// if saved and default expanded, collapse. Saved and default collapsed, expand
			if(readid(part.attr("id")) != null)
			{
				if (part.is(".tocDefaultExpanded"))
					$(this).nextAll("ol").slideUp(0);				
				else																					
					$(this).addClass("expand");				
			}
			
			// default expanded: expand. default collapsed: collapse
			else 
			{
				if(part.is(".tocDefaultExpanded"))
					$(this).addClass("expand");				
				else																					
					$(this).nextAll("ol").slideUp(0);				
			}
	 });
	
	// toggle between expand and collapse. State appended to cookie if different from default
	$(this).each(function () {
			$(this).click(function(e){
					e.preventDefault(); // disable anchor link
					var part = $(this).parent();
					$(this).toggleClass("expand");
					$(this).nextAll("ol").slideToggle(400).toggleClass("expanded");
					
					if (part.is(".tocDefaultExpanded") && !$(this).is(".expand"))			
								updateid(part.attr("id"));						
					else if (part.is(".tocDefaultCollapse") && $(this).is(".expand"))					
								updateid(part.attr("id"));		
					else
								deleteid(part.attr("id"));
			});
	});
	
	// add click handler to Expand all and Collapse all buttons
	$(".tocCollapseAll").click(function(event){
					event.preventDefault();					
					$("a.expandCollapseTocLink").removeClass("expand").nextAll("ol").hide();
					
					$("a.expandCollapseTocLink").each(function() {	
							var part = $(this).parent();																			 
							if (part.is(".tocDefaultExpanded"))			
								updateid(part.attr("id"));	
							else
								deleteid(part.attr("id"));
					});					
	});
	
	$(".tocExpandAll").click(function(event){
					event.preventDefault();					
					$(".expandCollapseTocLink").addClass("expand").nextAll("ol").show();
					
					$("a.expandCollapseTocLink").each(function() {
							var part = $(this).parent();																			 
							if (part.is(".tocDefaultCollapse"))					
								updateid(part.attr("id"));		
							else
								deleteid(part.attr("id"));
					});					
	});

	function updateid(id) {
		associativeArray[id] = "";		
		updateCookie();
	}
	
	function deleteid(id) {
		delete associativeArray[id];		
		updateCookie();
	}
	
	// write associativeArray contents to cookie
	function updateCookie() {
		
		var temp = pageID + ";";
		for (var i in associativeArray)
		{
				temp += (i + "#");
		}		
		
		$.cookie("legTocExpandCollapse", temp, {path: '/', expires: cookieExpire});
		//document.cookie = pageID + "=" + temp + expires + "; path=/";
	}
	
	function readCookie(){
		var associative = new Object();
		
		var name = $.cookie("legTocExpandCollapse")
		if (name) {
			var split = name.split(";");
			
			if (split.length > 1) {
				oldPageID = split[0];
				var values = split[1].split("#");
				
				for (var i = 0; i < values.length; i++) {
					if (values[i] != "")
						associative[values[i]] = "";
				}
			}
		}
		return associative;
		
	}
	
	function readid(value)
	{
		if (associativeArray != null)
			return associativeArray[value];
		else
			return null;
	}
	
	function eraseCookie() {
		$.cookie("legTocExpandCollapse", null, {path: "/"});
	}
};
/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
function previousNextTextMatchLinks(){
		
	// Add the skip links
	$("#viewLegContents").prepend('<ul id="skipLinks"><li><a href="" id="previous">' + config.viewLegContents.previous[LANG] + '</a></li><li><a href="" id="next">' + config.viewLegContents.next[LANG] + '</a></li></ul>');
	
	// If the referrer is a text search, add a button back to search
	if (document.referrer.match(/^http:\/\/www\.legislation\.gov\.uk\/.*(\?|&)text=.*/)){
		$('#skipLinks li:first').after('<li><a href="javascript:history.back()" id="backToSearch">' + config.viewLegContents.backToSearch[LANG] + '</a></li>');
	}

	
	var previousLink = 0;
	// Test if anchor is for next/previous links
	var currentLink  = window.location.hash.match(/match-[0-9]*/) ? window.location.hash.split('-')[1] : 1;				
	// Find the number of matches for comparisons
	var lastMatchNum = $('.LegSearchResult:last').attr('id').split('-')[1];
	// If the next match is higher than the total, reset to the highest
	if (currentLink > lastMatchNum) {
		currentLink = lastMatchNum;	
	}		
	var nextLink     = Number(currentLink)+1;
	var $nextLink 	 = $('#next');
	var $prevLink 	 = $('#previous');		
	
	// Initialise the next/previous links
	setPreviouslink();
	setNextLink();
	
	// Event handlers
	$nextLink.click(function(e) {	
		e.preventDefault();    	
		var matchAnchor = $(this).attr('href');
		$('html').stop().animate({scrollTop: $(matchAnchor).offset().top}, 500);
		
		// add limit logic
		if (currentLink<lastMatchNum) {
			currentLink++;
		}
		
		setPreviouslink();
		setNextLink();	
	});
	
	$prevLink.click(function(e) {	
		e.preventDefault();			
		var matchAnchor = $(this).attr('href');
		$('html').stop().animate({scrollTop: $(matchAnchor).offset().top}, 500);
		
		// add limit logic
		if (currentLink>1) {
			currentLink--;
		}
		
		setPreviouslink();
		setNextLink();				
	});
	
	// Private functions
	function setPreviouslink(){
		previousLink = Number(currentLink) - 1;
		
		// Check the limits, if there are no previous links, then amend the html
		if (previousLink<1) {
			$prevLink.html('First match').attr('href', '#match-1');
		} else {
			$prevLink.html('Previous match').attr('href', '#match-' + previousLink);
		}
	}
	
	function setNextLink(){
		nextLink = Number(currentLink) + 1;
		
		// Check the limits, if the nextLink is out of the limit then amend the html
		if (nextLink<=lastMatchNum) {
			$nextLink.html('Next match').attr('href', '#match-' + nextLink);
		} else {
			$nextLink.html('Last match').attr('href', '#match-'+lastMatchNum);
		}
	}
};

/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
/*

Legislation Modal Window

One-liner: Overlays a div on top of the main content containing useful information to be displayed

Usage: $(.linkClass).showModalDialog()

Requirements: 
jQuery framework- http://jquery.com/
<div id="modalBg"> to be attached to the XHTML document
CSS to control z-index for overlays
Div acting as modal window to already have been loaded


*/
/*$.fn.showModalDialog = function(options) {
	
		var defaults = {
			classes: {
				modalWindow: 'modWin',
				messageTitle: 'title webWarningTitle',
				message: 'content',
				messageINterface: 'interface'
			},
			modalId: 'invitationToSurvey',
			titleText: 'Invitiation to survey',
			textLine1: 'Thank you for using legislation.gov.uk',
			textLine2: 'Can you help us to better understand how users read and interact with legislation by taking our survey? ',
			textLine3: 'Survey closes on 22 September 2012.',
			debug: false,
			continueURL: function() {return '/'}
		},
		cfg = $.extend(defaults, options),

		$modalDialog = $('<div />').addClass(cfg.classes.modalWindow).attr('id', cfg.modalId)
		
		$('<div />').addClass(cfg.classes.messageTitle)
				.append( $('<div /> ').addClass(cfg.classes.message)
						.append('<h3>' + cfg.textLine1+ '</h3>')
							.append ('<p>' + cfg.textLine2 + '</p>')
									.append('<p>' + cfg.textLine3 + '</p>')	)
											.append('<div class="interface"><ul><li class="close">	<a class="userFunctionalElement" href="#"><span class="btl"></span>	<span class="btr"></span>Close<span class="bbl"></span>	<span class="bbr"></span></a></li><li class="continue">	<a class="userFunctionalElement" href="http://www.surveygizmo.co.uk/s3/987479/legislation-survey-0812" target="new"><span class="btl"></span>	<span class="btr"></span>Ok<span class="bbl"></span>	<span class="bbr"></span></a></li></ul></div>')
												.appendTo($modalDialog);
			var homePage= $("body").find("#siteLinks");
			if(homePage.length)console.log("home");
		 $("#siteLinks").append($modalDialog);


		 var parentDiv= $("body").find('#invitationToSurvey');
		 
		 var continueUrl =window.location.pathname.split('/');
		 var welsh =  continueUrl[1];
			if($("body").attr('id') != 'error'){
			//	if((welsh == 'mwa') || (welsh == 'anaw') || (welsh == 'wsi') || (welsh == 'wdsi'))
			//	{
			//		if(($("body").find('#layout2').attr('class') == "legToc") && ($("body").find('#layout2').attr('class') != undefined) && ($("body").find('#layout2').attr('class') != '')){
						
			//			$(this).legModalWinOnce({type: 'testingModal', closeLinkTxt: 'Close', parentDiv: parentDiv});
			//		}
			//	}
			}
};
*/

/*
 * Opens the modal window to display a message on page load, this function does not require any click event to trigger itself.
 * 
 */
$.fn.legModalWinOnce = function(options){
	// required for chaining, refer to jQuery API for more details

						   
		// Create variables and constants for storage, these can be overwritten in the normal jQuery way
		var modalWinJquery_str;
		var settings = {  
		 type: 'defaultWin',
		 fadeLength: 400,  
		 bgJqueryStr: '#modalBg',
		 closeLinkId_str: '#',
		 closeLinkIdJQuery_str: '#',  
		 closeLinkTxt: 'Cancel'
		};  
		var option = $.extend(settings, options);
		
		if (option.type == 'defaultWin'){			
			// The default modal window is a link to a pre-existing disalogue box
			modalWinJquery_str = $($(this).attr('href'));
			// Create a close this window link and attach to the modal window, along with the event handler
			$("<li/>")
			.addClass('cancel')
			.html('<a href="#" class="userFunctionalElement"><span class="btl"></span><span class="btr"></span>'+option.closeLinkTxt+'<span class="bbl"></span><span class="bbr"></span></a>')
			.prependTo($(modalWinJquery_str).children("div:last").children("ul"))
			.click(function(event){
				event.preventDefault();		
				closeModWin();	
			});
			
			// Once user clicks continue, the modalwin closes
			$("li.continue a", modalWinJquery_str).click(closeModWin());
		}
	/*	else if(option.type=='testingModal'){
			modalWinJquery_str = option.parentDiv;
			// Create a close this window link and attach to the modal window, along with the event handler
			var close= modalWinJquery_str.find('.close')
			close.click(function(event){
				event.preventDefault();		
				closeModWin();
			});
			var survey =modalWinJquery_str.find('.continue a');
			survey.click(function(event){
				event.preventDefault();	
				closeModWin();				
				window.open("http://www.surveygizmo.co.uk/s3/987479/legislation-survey-0812");
				
			});
		}
		*/
		// When the link that opens the modal win is clicked

				
				//Get the window height and width  
				var winH = window.innerHeight; // get W3C val for browsers that can handle it
				if (!winH)
					winH = $(window).height(); // use jQuery if they can't 
				var winW = window.innerWidth;
				if (!winW)	
					winW = $(window).width();
				
				// Work out centering of the window and special functions
				var topPos, leftPos, height, width;
				if (option.type == 'defaultWin'){
					// The default option requires minor positioning
					topPos  = winH/2-$(modalWinJquery_str).height()/2;
					leftPos = winW/2-$(modalWinJquery_str).width()/2;
					height  = 'auto'
				} else if (option.type == 'testingModal'){
					topPos  = winH/2-$(modalWinJquery_str).height()/2;
					leftPos = winW/2-$(modalWinJquery_str).width()/2;
					height  = 'auto'	
				}
				
				else {	
					// The previewImg type of modal window is a link from a thumbnail or preview image
					
					// Find the Image URI and create the SRC attribute for iFrame
					var modalWinIframeSrc = 'http://www.legislation.gov.uk/tools/displayimage?URL=' + $(this).attr('href');
			
					// As this <div> isn;t embedded into the XHTML the modal win needs to be created here
					$('<div>')
					.attr('id', 'previewImgWin')
					.addClass('modWin')
					.appendTo('#leg')					
					
					modalWinJquery_str = '#previewImgWin'; // Set this to apply css and event handlers
								
					// Add the iframe and pass the URi as an argument for the destination HTML to parse
					$(modalWinJquery_str)
					.html('<iframe src="' + modalWinIframeSrc + '"></iframe>')
					.prepend('<a href="#" class="closeLink"><img src="/images/chrome/closeIcon.gif" alt="Close"/></a>')
					.prepend('<h2 class="title">'+ config.modalwin.title[LANG] + '</h2>')
					
					// If the closelink is pressed, close the window
					$('a', modalWinJquery_str)
					.click(function(e) {
					  e.preventDefault();
					  closeModWin()
					});
					
					// Set the width and height as large as the viewable window
					height  = 0.9 * winH
					width   = 0.9 * winW
					
					// Set the positioning
					topPos  = $(window).scrollTop() + (0.0125 * winH);
					leftPos = winW/2-width/2;
					
					// Remove scrollbars from the bg					
					$('body').css('overflow', 'hidden');
				}
				
				// IE6 doesn't support fixed position
				if ($.browser.msie && parseInt($.browser.version) < 7) {
					var position = "absolute";
				} else if (option.type == 'previewImg') {
					var position = "absolute";
				} else {
					var position = "fixed";
				}			
				
				// Apply the popup window to center and style elements within
				$(modalWinJquery_str).css({'top': topPos, 'position': position, 'height': height, 'width': width, 'left': leftPos}); 
				$('iframe', modalWinJquery_str).css({height: '90%', width: '98%'}).hide // used for image option
				
				// Set the background width to the window width so that there's no
				// horizontal nav bars
				$(option.bgJqueryStr).css({'width':$(document).width(),'height':$(document).height()});
				
				// Show animation
				$(modalWinJquery_str).show(option.fadeLength);
				$(option.bgJqueryStr).fadeTo(option.fadeLength, 0.8).css({'width':$(document).width(),'height':$(document).height()});	
				
				$('iframe', modalWinJquery_str).fadeIn("slow");

		
			// Escape key also closes the modalwin
			$(document).keypress(function(e) {
				if (e.keyCode == 27) {
					closeModWin()
				}
			});
			
			// Close function
			function closeModWin() {
				if (option.type == 'previewImg') {
					$(modalWinJquery_str).remove();
					$('body').css('overflow', 'visible');
				} else {
					$(modalWinJquery_str).hide(option.fadeLength);
				}
				$(option.bgJqueryStr).fadeOut(option.fadeLength);		
			}
			   
};


