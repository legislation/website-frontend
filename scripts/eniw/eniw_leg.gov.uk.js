/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/
/*
*
*   EN Interweave v0.4
*   
*/


$(document).ready(function () {

	// Load the plugin if conditions are met
	if ($('#legEnLink').length) {
		$('.LegSnippet:first').ENInterweave();
	}  

});

// EN interweave plugin
$.fn.ENInterweave = function () {
	
	return this.each(function() {
		/*
		*	Some constants
		*/	
		var ENABLE_DEBUG_WITH_FIREBUG_CONSOLE = false;	// set this to false on deploy
		var SHOWSTATE = {
			global: null,
			local: null
		};
		var $LEX_BLOCK = $(this);
		var pageHasENLinks = false; // Controls display of the global show/hide button
		
		var $welsh = $('.LegSnippet:first').parent().attr('xml:lang') == 'cy';
		
		/*
		 * Replace default 'show EN' HTML function with AJAX actions
		 */
		addShowHideENBtn();
		
		/*
		* Add Global show hide button
		*/
		if (pageHasENLinks) {
			addGlobalShowHideBtn($LEX_BLOCK, $welsh);
		}
		
		/*
		 * Button functions
		 */
		function addGlobalShowHideBtn($prependTo, $welsh) {

			var $globalShowHideBtn = $('<a id="__ENExpandExplanatory" style="position: absolute;right: 8px;z-index: 2;"/>');
			
			$collaspsText = $welsh ? "Cau\'r holl Nodiadau Esboniadol" : 'Collapse All Explanatory Notes (ENs)';
			$expandedText = $welsh ? 'Ehangu\'r holl Nodiadau Esboniadol' :  'Expand All Explanatory Notes (ENs)';
			// Use .data() to add btn text to the object for self contained data
			$globalShowHideBtn
			.data('text', {
				uiCollapseText: $collaspsText,
				uiExpandText: $expandedText
			})
			.html(function() {
				// Show appropriate text label on init
				if (SHOWSTATE.global === "collapsed" || SHOWSTATE.global === null) {
					return $globalShowHideBtn.data('text').uiExpandText;
				}
				return $globalShowHideBtn.data('text').uiCollapseText;
			})
			.addClass("bigNoteLink")
			.click(function(event) {
				var $btn = $(this);
				//SHOWSTATE.local = $.cookies.get(ACT);
				if(SHOWSTATE.global === "collapsed" || SHOWSTATE.global === null) {  
					$btn.html($btn.data('text').uiCollapseText);
					/*$.cookies.set("eniw", "expanded", {
						hoursToLive: 87600
					});  */
					SHOWSTATE.global = "expanded";  
				} else {
					$btn.html($btn.data('text').uiExpandText);
					/*$.cookies.set("eniw", "collapsed");*/
					SHOWSTATE.global = "collapsed"; 
				}
				
				// Add the event handlers for opening/closing all items
				__debuglog("in click:"+SHOWSTATE.global);		  
			   
		 		if(SHOWSTATE.global == "collapsed" || SHOWSTATE.global === null) {
					 changeAllBtnStates('hide', $btn);   	 			
		 		} else {
					changeAllBtnStates('show', $btn);  	
		 		}
				
				 __debuglog("bang done:"+SHOWSTATE.global);	   
			});		
			
			// Add global button 
			$prependTo.prepend($globalShowHideBtn);
			__debuglog("Global show/hide btn added");
			
			/*
			 * Function to open and close all other buttons
			 */
			function changeAllBtnStates(showOrHide, $globalBtn) {
				
				$("a.noteLink").trigger({
					type:"click",
					message: showOrHide
				}); 
				
				if (showOrHide === 'show'){
					$globalBtn.html($globalBtn.data('text').uiCollapseText);
					//$.cookies.set(ACT, "expanded");  
					SHOWSTATE.global = "expanded";
				} else {
					$globalBtn.html($globalBtn.data('text').uiExpandText);
					//$.cookies.set(ACT, "collapsed");
					SHOWSTATE.global = "collapsed";
				}
			}
		}
		
		
		function addShowHideENBtn() {
			
			__debuglog('Amending HTML request to AJAX request');
			var $welsh = $('.LegSnippet:first').parent().attr('xml:lang') == 'cy';
			// Find relevant links and attach 
			$('.noteLink').each(function() {
				pageHasENLinks = true;
				var $UIElement = $(this);
				var sectionID = $UIElement.parent().prevAll('.LegAnchorID').attr('id');
				var AttrEnId = false;	// The ID attribute is only set on when the EN fragment is shown
				__debuglog($UIElement);
				
				// Add the actions to the UI element
				$UIElement
				.data('ENFragGot', false)
				.bind( "showENFragment", function() {
					// bind a show event to the link
					
					// Only perform AJAX request if the fragment hasn't been download before.
					var $text = $welsh ? $UIElement.text("Cuddio EN"): $UIElement.text("Hide EN");
					if(!$UIElement.data('ENFragGot')) {
						$.get($UIElement.attr('href') + '/data.xht', function(ENContent) {
							
							// Create the fragment ID so it can be removed easily	
							AttrEnId = "__eniw_" + sectionID;
							
							// Add the data ENFragGot to the UI Element to make the AJAX request happen once					
							$UIElement
							.data('ENFragGot', true)
							.after(
								// Add the content to a wrapper div and append after the show link
								$("<div class='fragment'/>")
								.append(
									// Repurpose the EN Snippet
									$(ENContent)
									.first('.LegSnippet').end()
									.find('h1, h2, h3, h4, h5').remove().end()
									.html()
								)
								.attr("id", AttrEnId)
							)					
							.text($text);
						},'html');  
					} else {
						// Repopulate AttrEnId
						AttrEnId = "__eniw_" + sectionID;
						$UIElement.text($text);
						$('#' + AttrEnId).show();					
					}
				})
			   	.bind( "hideENFragment", function() { 
			   		// bind a hide event to the link
					var $text = $welsh? $UIElement.text("Dangos EN"): $UIElement.text("Show EN");
					if(AttrEnId != false) {
						// Hide EN fragment
						$("#"+AttrEnId).hide();
						$UIElement.text($text);
						AttrEnId = false; 
					 }   
				}).click(function(event) {
					/* 
					 * Bind an onclick event - which triggers show and hide events
					 * This may be triggered from the global show/hide components
					 */
					event.preventDefault();
					
					if(event.message == "show") {
						$UIElement.trigger("showENFragment"); 
					} else if (event.message == "hide") {
						$UIElement.trigger("hideENFragment");   
					} else {
						/*	default behaviour	*/
						if(AttrEnId) {
							$UIElement.trigger("hideENFragment");	
						} else {
							$UIElement.trigger("showENFragment"); 
						}  
					}
				}); 
			});
			
			
			//prepareStateFromCookie($UIElement);
		}
	
		/*	======================	DEBUG FUNCTION	======================	*/
	
		/*
		*	Debug function
		*	if you are not using firefox change to alert or whatever
		*	and if you are not debugging commment out 
		*/
		function __debuglog(message) {
			if (ENABLE_DEBUG_WITH_FIREBUG_CONSOLE) {
				if ($.browser.mozilla) {
					console.log(message);
				}
			}
		}
	});
};