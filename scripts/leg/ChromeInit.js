/*
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

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

var legGlobals = window.legGlobals = window.legGlobals || {};
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

  $("#quickSearch").children().filter("a")
	.addClass("expandCollapseLink")
	.legExpandCollapse(['<span>' + config.quickSearch.expandCollapseLink.message1[LANG] + '<span class="accessibleText">' + config.quickSearch.expandCollapseLink.message2[LANG] + '</span></span>','<span>' + config.quickSearch.expandCollapseLink.message1[LANG] + '<span class="accessibleText">' +config.quickSearch.expandCollapseLink.message3[LANG] + '</span></span>','<span>'], {
		state: legGlobals.expandCollapseState,
		expires: legGlobals.legCookieExpire,
		open: "open"
	});
	// Status warning box, only add open/close link if there is more than intro text or there are div children
	// Use .length to get conditional value rather than getElementById so we can use the jQuery framework selectors and
	// use the object further if needed.
	if ($("#statusWarningSubSections").length) {
		var $target = $("#statusWarningSubSections");
    var $link = $target.siblings('a').first();
    var isValidLink = $link.length && $link.attr('href').slice(1) === $target.attr('id')

    if (isValidLink) {
      var showText = $link.text(); // Default init
      var hideText = config.statusWarningSubSections.expandCollapseLink.message4[LANG];
      var a11yText = config.statusWarningSubSections.expandCollapseLink.message3[LANG];

      if ($link.hasClass('js-IsRevisedEUPDFOnly')) {
        showText = config.statusWarningSubSections.expandCollapseLink.message1[LANG];
      }else{
        showText = config.statusWarningSubSections.expandCollapseLink.message2[LANG];
      }

      $link.wrap("<div class='linkContainer'></div>");

      // use as CONFIG the data-* attributes expected on it
      $link
        .addClass('expandCollapseLink')
        .legExpandCollapse([
          showText + '<span class="accessibleText">' + a11yText + '</span>',
          hideText + '<span class="accessibleText">' + a11yText + '</span>'
        ]);

    }

		// if (typeof linkText === 'string') {
    //   linkText = linkText.trim(); // take out any spurious whitespace
    //   if ( linkText ) {
    //     $link.attr('data-'+LANG+'-expand', linkText); // Provided text should override data-* attrib
    //   }else if ( !linkText && $link.attr('data-'+LANG+'-expand') ) {
    //     $link.text( $link.attr('data-'+LANG+'-expand') ); // if it can be helped, make sure link text isn't empty by default
    //   }
		// }


    // $("p.intro:first", "#statusWarning")
    // .after($("<div/>").addClass("linkContainer"));

		// $("<a/>")
		// .attr('href', '#statusWarningSubSections')
		// .appendTo("#statusWarning .title:first .linkContainer")
		// .addClass("expandCollapseLink")
		// .legExpandCollapse([config.statusWarning.expandCollapseLink.message1[LANG] + '<span class="accessibleText">' + config.statusWarning.expandCollapseLink.message2[LANG] + '</span>', config.statusWarning.expandCollapseLink.message3[LANG] + '<span class="accessibleText">' + config.statusWarning.expandCollapseLink.message2[LANG] +'</span>']);
	}

	// Effects to be applied
	$("<div/>").addClass("linkContainer").appendTo("#statusEffectsAppliedSection .title");

	$("<a/>")
	.attr('href', '#statusEffectsAppliedContent')
	.appendTo("#statusEffectsAppliedSection .title .linkContainer")
	.addClass("expandCollapseLink")
	.legExpandCollapse([config.statusEffectsAppliedSection.expandCollapseLink.message1[LANG] + '<span class="accessibleText">' + config.statusEffectsAppliedSection.expandCollapseLink.message2[LANG] + '</span>', config.statusEffectsAppliedSection.expandCollapseLink.message3[LANG] + '<span class="accessibleText">' +  config.statusEffectsAppliedSection.expandCollapseLink.message2[LANG] + '</span>']);

	// EU outstanding references
	$("<a/>")
		.attr('href', '#outstandingRefsContent')
		.addClass("expandCollapseLink")
		.appendTo("#outstandingRefs .title")
		.legExpandCollapse([
			config.outstandingRefsContent.expandCollapseLink.show[LANG],
			config.outstandingRefsContent.expandCollapseLink.hide[LANG]
		], {
			open: true
		});

	$("<a/>")
		.attr('href', '#outstandingRefs')
		.insertBefore("#outstandingRefs")
		.addClass("expandCollapseLink")
		.legExpandCollapse([config.outstandingRefs.expandCollapseLink.show[LANG], config.outstandingRefs.expandCollapseLink.hide[LANG]]);

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

// 'PDF Versions' section
$(document).ready(function(){
	var pdfVersion = [
		{
			title: '#pdfVersions',
			target: '#pdfVersionsContent',
			textExpand: 'Expand PDF versions',
			textCollapse: 'Collapse PDF versions'
		},
		{
			title: '#pdfVersionsSub',
			target: '#pdfVersionsSubContent',
			textExpand: 'Expand PDFs from EUR-Lex',
			textCollapse: 'Collapse PDFs from EUR-Lex'
		}
	];

	// Slightly different way of adding the links, wrap the <a> element around the <h2> inner HTML
	$.each(pdfVersion, function(index, item) {
		// The assumption here is that the first 'item' (i.e. of index '0') is the only title with a 'h2' element -
		// the rest (i.e. subtitles) are assumed to be 'h3'
		var $title = $(".title:first", item.title).children( index === 0 ? "h2" : "h3" );
		var titleText = $title.html();
		// Reset the inner HTML to nothing as added when open/close link is added
		$title.html("");

		$("<a/>")
		.attr('href', item.target)
		.addClass("expandCollapseLink")
		.appendTo($title)
		.legExpandCollapse(
			[
			titleText+'<span class="accessibleText">'+ item.textExpand+'</span>',
			titleText+'<span class="accessibleText">'+ item.textCollapse+'</span>'
			],
			{
			state: legGlobals.expandCollapseState,
			expires: 5
			});
	});
});

// 'dct:alternative' Show/Hide
$(document).ready(function(){
	var TITLE, TOGGLER_TEXT_STATUS, $titleToggler, $pageTitle, $fullTitle;
	$fullTitle = $('.fullTitle:first');

	if ( $fullTitle.length > 0 ) {
		// ===< Variables init >===
		$pageTitle = $('.pageTitle:first');
		$titleToggler = $pageTitle.find('.pageTitleToggleLink');
		TITLE = {
			full: $fullTitle.text(),
			alt: $pageTitle.find('span').text()
		};
		TOGGLER_TEXT_STATUS = {
			full: $titleToggler.text() === "Dangos y teitl llawn" ? "Cuddio’r teitl llawn" :"Hide full title",
			alt: $titleToggler.text()
		}

		$pageTitle.attr('data-title-type', 'alt'); // Default

		$titleToggler.click(function(e) {
			togglePageTitle( $pageTitle.attr('data-title-type') );
			toggleTogglerText( $pageTitle.attr('data-title-type') );
		});
	}


		function togglePageTitle(currentTitleType) {
			// Toggle titles
			if ( currentTitleType === 'alt') {
				$pageTitle.find('span').text(TITLE.full);
				$pageTitle.attr('data-title-type', 'full');

			}else {
				$pageTitle.find('span').text(TITLE.alt);
				$pageTitle.attr('data-title-type', 'alt');
			}
		}

		function toggleTogglerText( currentPageTitleType ) {
			// Toggle toggler-link text, AFTER THE PAGE TITLE HAS BEEN TOGGLED!
			$titleToggler.text( TOGGLER_TEXT_STATUS[currentPageTitleType] );
		}
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

$(document).ready(function () {
	//PiT form hide/show
	if($('#PiTselector .text strong').length > 0) {
        var text = $('#PiTselector .text strong')[0].innerText;
        $('#PiTselector .text strong').replaceWith(
            $('<a href="#pitSearch" class="expandCollapseLink"/>')
                .legExpandCollapse([text + ' <span class="accessibleText">, hide form</span>', text + ' <span class="accessibleText">, show Form</span>'], {
                    state: legGlobals.expandCollapseState,
                    expires: 5
                })
        );
    }
});

// Banners
$(function () {

	//var RECRUITMENT_BANNER_HTML = {
	//	en: '<div class="bannercontent">' +
	//		'<div class="recruit-main"><span class="heading">' +
	//		'Join the team' +
	//		'</span><br/>' +
	//		'<span>We&apos;re currently recruiting for a Service and Performance Manager. If you&apos;d like to join the legislation.gov.uk team please apply by 26th October.</span>' +
	//		'</div>' +
	//		'<ul>' +
	//		'<li><a href="https://www.civilservicejobs.service.gov.uk/csr/jobs.cgi?jcode=1749362 " target="_blank" class="join">Apply to join the team</a></li>' +
	//		'<li><a href="#" class="recruitment-close">Close</a></li>' +
	//		'</ul>' +
	//		'</div>',
	//	cy: '<div class="bannercontent">' +
	//		'<div class="recruit-main"><span class="heading">' +
	//		'Join the team' +
	//		'</span><br/>' +
	//		'<span>We&apos;re currently recruiting for a Service and Performance Manager. If you&apos;d like to join the legislation.gov.uk team please apply by 26th October.</span>' +
	//		'</div>' +
	//		'<ul>' +
	//		'<li><a href="https://www.civilservicejobs.service.gov.uk/csr/jobs.cgi?jcode=1749362" target="_blank" class="join">Apply to join the team</a></li>' +
	//		'<li><a href="#" class="recruitment-close">Close</a></li>' +
	//		'</ul>' +
	//		'</div>',
	//}
	//var RECRUITMENT_COOKIE_NAME = 'recruitment_banner';
	//$(RECRUITMENT_BANNER_HTML[LANG]).simpleBanner({
	//	id: 'recruitment-banner',
	//	closeBtnSelector: '.recruitment-close',
	//	doShow: function () {
	//		// By default the banner is shown unless the user has allowed cookies.
	//		// Check the cookie to see if the banner has been closed before and hide
	//		// if it has.
	//		var show = true;
	//		var cookie;

	//		if (window.legGlobals.cookiePolicy.settings) {
	//			cookie = $.cookie(RECRUITMENT_COOKIE_NAME);

	//			if (cookie && cookie === 'Yes') {
	//				show = false;
	//			}
	//		} else {
	//			$.removeCookie(RECRUITMENT_COOKIE_NAME, {path: '/'});
	//		}

	//		return show;
	//	},
	//	onClose: function () {
	//		if (window.legGlobals.cookiePolicy.settings) {
	//			$.cookie(RECRUITMENT_COOKIE_NAME, 'Yes', {expire: 30, path: '/'});
	//		}
	//	}
	//});

	var COVID_BANNER_HTML = {
		en: '<div class="bannercontent">' +			
			'<h2 class="accessibleText">Coronavirus</h2> ' +
			'<span class="legislation">' +
			'<strong>' +
			'<a href="/coronavirus" class="link">Browse Coronavirus legislation</a>' +
			'</strong>' +
			' on legislation.gov.uk</span>' +
			'<span class="extents">' +
			
			'Get Coronavirus guidance for the ' +
			'<strong>' +
			'<a href="https://www.gov.uk/coronavirus" class="link" target="_blank">UK</a>, ' +
			'<a href="https://www.gov.scot/coronavirus-covid-19" class="link" target="_blank">Scotland</a>, ' +
			'<a href="https://gov.wales/coronavirus" class="link" target="_blank">Wales</a>, and ' +
			'<a href="https://www.nidirect.gov.uk/campaigns/coronavirus-covid-19" class="link" target="_blank">Northern Ireland</a>' +
			'</strong>' +
			'</span>' +
			'</div>',
		cy: '<div class="bannercontent">' +
			'<h2 class="accessibleText">Coronafeirws</h2> ' +
			'<span class="legislation">' +
			'<strong>' +
			'<a href="/coronavirus" class="link">Pori deddfwriaeth Coronafeirws</a>' +
			'</strong>' +
			' ar ddeddfwriaeth.gov.uk' +
			'</span>' +
			'<span class="extents">' +			 
			' Cael cyngor Coronafeirws ar gyfer y ' +
			'<strong>' +
			'<a href="https://www.gov.uk/coronavirus" class="link" target="_blank">DU</a>, ' +
			'<a href="https://www.gov.scot/coronavirus-covid-19" class="link" target="_blank">Yr Alban</a>, ' +
			'<a href="https://llyw.cymru/coronavirus" class="link" target="_blank">Cymru</a>, a ' +
			'<a href="https://www.nidirect.gov.uk/campaigns/coronavirus-covid-19" class="link" target="_blank">Gogledd Iwerddon</a>' +
			'</strong>' +
			'</span>'+
			'</div>'
	}

	// The banners are added *after* the ID '#top' so should be called in the opposite order to how they should appear.
	// Uncomment to add survey banner
	// window.legGlobals.addSurvey();

	// If the coronavirus banner already exists on the page via HTML then do not add the JS version
	//if (!$('#coronavirus-banner').length) {
	//	$(COVID_BANNER_HTML[LANG]).simpleBanner({id: 'coronavirus-banner'});
	//}

})
