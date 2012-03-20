/*
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

*/
function previousNextTextMatchLinks(){
		
	// Add the skip links
	$("#viewLegContents").prepend('<ul id="skipLinks"><li><a href="" id="previous">Previous match</a></li><li><a href="" id="next">Next match</a></li></ul>');
	
	// If the referrer is a text search, add a button back to search
	if (document.referrer.match(/^http:\/\/www\.legislation\.gov\.uk\/.*(\?|&)text=.*/)){
		$('#skipLinks li:first').after('<li><a href="javascript:history.back()" id="backToSearch">Back to search results</a></li>');
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
