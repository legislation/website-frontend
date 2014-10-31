/*
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

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
