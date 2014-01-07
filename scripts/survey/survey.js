/*
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

*/
/*Survey
 *
 One-liner: Adds survey link to right of page
 Requirements: jQuery framework: http://jquery.com/
 
 Notes:
 
 History:
 v0.01	TE Created
 
 */
 $(document).ready(function(){
	 
	 var link = "http://surveyanalytics.com/t/AFNKsZNyBb";
	 
	 $("body").append('<div id="feedback"><a href="#" /></div><div id="survey"></div>');	 
	 
	 // problems with z-index and positioning, open external window instead
	 //if($.browser.msie && $.browser.version < 7){
		 $("#feedback")
		 .hover(function() {
			 $(this).animate({width: "35px"}, {duration: 100, queue: false});
		 },
		 function() {
				$(this).animate({width: "25px"}, {duration: 100, queue: false});
		 })
		 
		 $("#feedback").click(function(){
				window.open(link);
		 });
		 
		 // move up if obscured
		 if ($(window).height() < 450)
		 {
				 $("#feedback").css("top", "240px");
		 }
		 
	 /*}
	 else
	 {
			 $("#feedback")
		 .hover(function() {
			 $(this).animate({width: "40px"}, {duration: 100, queue: false});
		 },
		 function() {
				$(this).animate({width: "30px"}, {duration: 100, queue: false});
		 })
		 
		  $("#feedback").click(function(){
				window.open(link);
		 });
		 /*
	 		$("#feedback")
		 // toggle between survey visible and hidden
		 .toggle(function() {
			 // Set the background width to the window width so that there's no
				// horizontal nav bars
				$("#modalBg").css({'width':$(document).width(),'height':$(document).height()})
				.fadeTo(400, 0.8);	 
			 
				 $("#survey").html('<div id="closeSurvey"><span id="loading">Loading...</span><a id="cancel" href="#" class="userFunctionalElement"><span class="btl"></span><span class="btr"></span>Close<span class="bbl"></span><span class="bbr"></span></a></div><iframe frameborder="0" width="100%" height="100%" src="' + link + '"><p>Your browser doesn\'t support iframes</p></iframe>')
				 .css("background", "#4B4C4E")
				 .show();	
				 
				 $("iframe").load(function() {
		 			$("#loading").hide(); 
	 			});
			 
				// hide survey if cancel button clicked
				 $("#cancel")
			 .click(function() {
				 $("#feedback").click();
			 });	 
		 },
		 
		 // hide survey if feedback clicked while survey open
		 function() {
			 hide();
		 });
	 }
	 
	 
	 
	 function hide()
	 {
		 $("#survey").hide();
			 
		 $("#modalBg").css({'width':$(document).width(),'height':$(document).height()})
				.fadeTo(400, 0);	
				$("#modalBg").hide();
				
	 }*/
 });