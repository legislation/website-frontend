/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/

$(document).ready(function() {
	$("#yearPagination").miniPagination();	
	// Img replacement - added feature
	$(".userFeedbackImg").imgReplace();
});

/*

Legislation Img Replace

One-liner: 
Count the number of first-child divs within an ID, create a pagination
set of links around them that automatically add/remove links
		
Usage:
$("#container").miniPagination();

The #container div within the XHTML contains a number of items referred to as 'pages'. Each one has the class 'page' added:

<div id="container">
	<div class="page">
	
	</div>
	<div class="page">
	
	</div>
</div>

History:
v0.01	2010_21_06	GM	Created

*/

$.fn.miniPagination = function(miniPaginationOptions){
		
	$(this).each(function () {
		
		// Config area
		var defaults = {
			firstPageLink : "yes",
			lastPageLink  : "yes",			
			startPage     : 1
		}
		
		var option = $.extend(defaults, miniPaginationOptions); // overwrite defaults if options were passed during init

		// Variable creation
		var currentPage, numPages, $container, $miniPageNav, $linkFirst, $linkPrev, $linkNext, $linkLast, $currPageInfo;
		
		// Create objects for ease of reference
		$container = $(this);
		//Init vars
		currentPage = 1; // Default is startPage
		numPages = $container.find("ul.page").length;
		
		// Create the navigation
		$container.append('<ul id="miniPageNav"><li id="miniPageNavPrev"><a href="#"><img src="/images/chrome/miniNavPrev_default.gif" alt="Prev" class="userFeedbackImg" /></a></li><li id="miniPageNavCurrent">XXX</li><li id="miniPageNavNext"><a href="#"><img src="/images/chrome/miniNavNext_default.gif" alt="Prev" class="userFeedbackImg" /></a></li></ul>');
		// create object for swift reuse + to speed DOM reference
		$miniPageNav = $("#miniPageNav") 
		$linkPrev = $("#miniPageNavPrev a");
		$linkNext = $("#miniPageNavNext a");
		$currPageInfo = $("#miniPageNavCurrent");
		
		if (option.firstPageLink) {
			$miniPageNav.prepend('<li id="miniPageNavFirst"><a href="#"><img src="/images/chrome/miniNavFirst_default.gif" alt="First" class="userFeedbackImg" /></a></li>');
			$linkFirst = $("#miniPageNavFirst a");
		}
		
		if (option.lastPageLink) {
			$miniPageNav.append('<li id="miniPageNavLast"><a href="#"><img src="/images/chrome/miniNavLast_default.gif" alt="Last" class="userFeedbackImg" /></a></li>');
			$linkLast = $("#miniPageNavLast a");
		}
		
		// Set the default view
		updatePageView();
		
		/* Event handlers */
		$linkPrev.click(function(e) {
			e.preventDefault();
			if (!$(this).hasClass("disabled")){	
				currentPage--;								
				updatePageView()
			}
		});
		$linkNext.click(function(e) {
			e.preventDefault();
			if (!$(this).hasClass("disabled")){
				currentPage++;
				updatePageView()
			}
		});
		$linkFirst.click(function(e) {
			e.preventDefault();
			if (!$(this).hasClass("disabled")){
				currentPage=1;
				updatePageView()
			}
		});
		$linkLast.click(function(e) {
			e.preventDefault();
			if (!$(this).hasClass("disabled")){
				currentPage=numPages;
				updatePageView()
			}
		});				
		
		// Hides all pages and shows the current page	
		function updatePageView() {
			updateNavLinks(); // check bounds and enable links as appropriate
		
			$(".page", $container)
			.css({"display" : "none"})// Hide the pages
			.end()					
			
			$(".page:eq(" + (currentPage-1) + ")", $container)
			.css({"display" : "block"});// Shows the current page
						
			$currPageInfo.text(config.pagination.currPageInfo.textPage[LANG] + currentPage + config.pagination.currPageInfo.textOf[LANG] + numPages);							
		}
		
		// Checks bounds of links and enables/disables links as appropriate
		function updateNavLinks(){
			if (currentPage<2) {
				$miniPageNav.children("li").children("a").removeClass("disabled");
				$linkPrev.addClass("disabled");
				$linkFirst.addClass("disabled");
			} else if (currentPage>=numPages) {
				$miniPageNav.children("li").children("a").removeClass("disabled");
				$linkNext.addClass("disabled");
				$linkLast.addClass("disabled");							
			} else {
				$miniPageNav.children("li").children("a").removeClass("disabled");
			}	
		}
	});

// return this to keep chaining alive
return this;
}