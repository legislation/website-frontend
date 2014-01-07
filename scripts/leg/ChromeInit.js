/*
�  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

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
		.legExpandCollapse(['View outstanding changes<span class="accessibleText"> status warnings</span>', 'Close<span class="accessibleText"> status warnings</span>']);
	}
	
	// Effects to be applied
	$("<div/>").addClass("linkContainer").appendTo("#statusEffectsAppliedSection .title");
	
	$("<a/>")
	.attr('href', '#statusEffectsAppliedContent')
	.appendTo("#statusEffectsAppliedSection .title .linkContainer")
	.addClass("expandCollapseLink")
	.legExpandCollapse(['More<span class="accessibleText"> effects to be announced</span>', 'Close<span class="accessibleText"> effects to be announced</span>']);
	
	// Changes to be applied
	$("<div/>").addClass("linkContainer").appendTo("#changesAppliedSection .title");
	
	$("<a/>")
	.attr('href', '#changesAppliedContent')
	.appendTo("#changesAppliedSection .title .linkContainer")
	.addClass("expandCollapseLink")
	.legExpandCollapse(['More<span class="accessibleText"> effects to be announced</span>', 'Close<span class="accessibleText"> effects to be announced</span>']);
	
	// Commencement orders to be applied
	$("<div/>").addClass("linkContainer").appendTo("#commencementAppliedSection .title");
	
	$("<a/>")
	.attr('href', '#commencementAppliedContent')
	.appendTo("#commencementAppliedSection .title .linkContainer")
	.addClass("expandCollapseLink")
	.legExpandCollapse(['More<span class="accessibleText"> changes to be applied</span>', 'Close<span class="accessibleText"> changes to be applied</span>']);				   
});
						   
$(document).ready(function(){	
	// Quicksearch	
	$("#quickSearch").children().filter("a")
	.addClass("expandCollapseLink")
	.legExpandCollapse(['<span>Search Legislation<span class="accessibleText"> Show</span></span>','<span>Search Legislation<span class="accessibleText"> Hide</span></span>'], {
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
			.html("Collapse all -")
			.toggle(function (event) {
					$(this).html("Expand all +");					
					event.preventDefault();
					$("a.expandCollapseTocLink").removeClass("expand").nextAll("ol").hide();								
			},
				function (event) {
					$(this).html("Collapse all -");				
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


  $(document).ready(function(){
	$(this).showModalDialog();
});

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
