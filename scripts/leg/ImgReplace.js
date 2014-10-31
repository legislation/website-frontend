/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

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
