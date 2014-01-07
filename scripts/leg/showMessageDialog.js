
/*
�  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

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
$.fn.showModalDialog = function(options) {
	
		var defaults = {
			classes: {
				modalWindow: 'modWin',
				messageTitle: 'title webWarningTitle',
				message: 'content',
				messageINterface: 'interface'
			},
			modalId: 'invitationToTest',
			titleText: 'Invitation to test new functionality',
			onePoint: 'improve how we present dual language versions of Welsh legislation',
			secondPoint: 'provide a Welsh language version of the website',
			textLine1: 'As part of our current development work to legislation.gov.uk we are looking to: ',
			textLine2: 'We have turned our ideas into prototypes that we would like to obtain user feedback on and have face to face and online testing sessions being run the week commencing 21st May.',
			textLine3: 'Would you like to take part?',
			debug: false,
			continueURL: function() {return '/'}
		},
		cfg = $.extend(defaults, options),

		$modalDialog = $('<div />').addClass(cfg.classes.modalWindow).attr('id', cfg.modalId)
		
		$('<div />').addClass(cfg.classes.messageTitle).append('<h3>' + cfg.titleText+ '</h3>')
				.append( $('<div /> ').addClass(cfg.classes.message)
					.append('<p>' + cfg.textLine1 + '</p>')
							.append('<ul> <li>'+ cfg.onePoint+ '</li> <li>'+ cfg.secondPoint+ '</li> </ul>')
								.append ('<p>' + cfg.textLine2 + '</p>')
									.append('<p>' + cfg.textLine3+ '</p>')
										.append ('<p> <a href="mailto: publishing.legislation@nationalarchives.gsi.gov.uk?subject=Testing Enquiry"> Please let us know</a> and we can help arrange a time for you to take part. </p>'))
											.append('<div class="interface"><ul><li class="close">	<a class="userFunctionalElement" href="#"><span class="btl"></span>	<span class="btr"></span>Close<span class="bbl"></span>	<span class="bbr"></span></a></li></ul></div>')
												.appendTo($modalDialog);
		 $("body").append($modalDialog);
		 var parentDiv= $("body").find('#invitationToTest');
		 
		 var continueUrl =window.location.pathname.split('/');
		 var welsh =  continueUrl[1]
	if($("body").attr('id') != 'error'){
		if((welsh == 'mwa') || (welsh == 'anaw') || (welsh == 'wsi') || (welsh == 'wdsi'))
		{
			if(($("body").find('#layout2').attr('class') == "legToc") && ($("body").find('#layout2').attr('class') != undefined) && ($("body").find('#layout2').attr('class') != '')){
				
				$(this).legModalWinOnce({type: 'testingModal', closeLinkTxt: 'Close', parentDiv: parentDiv});
			}
		}
	}
};

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
		else if(option.type=='testingModal'){
			modalWinJquery_str = option.parentDiv;
			// Create a close this window link and attach to the modal window, along with the event handler
			var close= modalWinJquery_str.find('.close')
			close.click(function(event){
				event.preventDefault();		
				closeModWin();
			});
			
		}
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


