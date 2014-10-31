/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

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
