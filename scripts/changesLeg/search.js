/*
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

*/
/*Changes to Legislation Search Functionality
 *
 One-liner: Various form interactivity
 Requirements: jQuery framework: http://jquery.com/
 jqueryui 1.4
 
 Detailed info:
 Adds show/hide functionality for sub groups
 A line showing details of the search term in an easy to understand line for the user.
 
 Notes:
 For help, anchor link should be the same as id of associated help box
 
 History:
 v0.01	TE Created
 v0.02	2010-06-08	TE	Fixed positioning
 v0.03	2010-06-09	TE	Added input value saving
 v0.04	2010-06-28	TE 	Fixed XHTML Strict issues
 v0.05	2010-09-07	GE	Amended to use jQuery plugin code
 v0.06	2010-09-20	TE	Updated validation code
 v0.07  2010-12-09  GE  Consolidated code to use shared functionality
                        Requires the formFunctions/common.js to preceed it in HTML
 */
$(document).ready(function(){
	
	styleRadios();
	
	// Add the correct hooks to enable overlay traversing
	$(".yearChoice").addClass("formGroup");
	
	// Set the transparent overlay to detect when someone clicks into a box
	$("input:[name=affected-year-choice]").showHideFields();
	$("input:[name=affecting-year-choice]").showHideFields();   
	
	// Add the form hints to the textboxes (selects should already be populated)
	$("#affected-year").validate("year").addDefaultText("Any");		
	$("#affected-number, #affecting-number").validate("number").addDefaultText('Any');	
	$("#affected-start-year, #affected-end-year").validate("year").addDefaultText("YYYY");	
	$("#affected-title, #affecting-title").addDefaultText("All legislation (or insert title)");
	$("#affected-type, #affecting-type").data("defaultText", $("#affected-type option:first").text()); // the first option is the default text
	
	// Remove these values from the submitted form so that the backend doesn't need to handle them
    $("#searchChanges").clearDefaultValues();
	
	// show Modify Search button if appropriate
	if ($("#newSearch").length) {
		$("#newSearch").show();
		$("#searchChanges").addClass("modifySearchBtnAdded");
	}
	
    // Set the show/hide functions for the modify search box
	if ($(".results", "#content").length > 0){
		$("#modifySearch")
		.legExpandCollapse(
			['<span class="btl"></span><span class="btr"></span>Modify search<span class="bbl"></span><span class="bbr"></span>',
			 '<span class="btl"></span><span class="btr"></span>Hide search form<span class="bbl"></span><span class="bbr"></span>']
		).click(function() {
			// if the initial view of the form is hidden then so are the overlays used in the showHideFields plugin, these need resetting
			$("input:[name=affected-year-choice]").showHideFields();
			$("input:[name=affecting-year-choice]").showHideFields();	
		});
		
		// show hide reset button
		$("#modifySearch").toggle(function() {
			$("#resetSearch").css("display","inline-block");
		},
		function() {
			$("#resetSearch").css("display", "none");
		});
	} else {
		// Hide this functionality
		$("#modifySearch").hide();
	}
	
	// Set the text preview area output and populate with the default form values
	$previewArea = $("p", "#searchInfo")
	searchQueryPreviewTxt($previewArea);
	
	// Add event handlers for the required fields and run the preview script when they occur
	$("#searchChanges").find("input, select").change(function(){
		searchQueryPreviewTxt($previewArea);
	}).keyup(function(event) {
		if (event.ctrlKey || event.altKey || event.metaKey) {
			// Don't do anything with these values
			return;
		}
		searchQueryPreviewTxt($previewArea);		
	}).click(function(){
		searchQueryPreviewTxt($previewArea);		
	});
	
	// Add the reset button
	$("#newSearch")
	.append('<a id="resetSearch" href="#searchChanges" class="userFunctionalElement"><span class="btl" /><span class="btr" />Reset Fields<span class="bbl" /><span class="bbr" /></a>')
	.show();
	
	// Reset button functionality
	$("#resetSearch")
	.click(function (e) {
		
		$(':input','#searchChanges')
		.not(':button, :submit, :reset, :hidden, :radio')
		.val("");
		
		$("#affected-year-specific").attr("checked", "checked");
		$("#affecting-year-choice-specific").attr("checked", "checked");
		// Reset the type checkboxes, also emulate click on span to apply special styling
		$("#appliedAll").attr("checked", "checked").siblings("span:first").trigger('click'); 

		
		$("input:[name=affected-year-choice]").showHideFields();
		$("input:[name=affecting-year-choice]").showHideFields(); 
		
		// reset to default
		$(".jsDefaultVal").each(function () {
			$(this).val($(this).data("defaultText")); 
		});	
			
		$(".errorMessage").remove();			
		$(".error").removeClass("error");
		
		// reset preview
		searchQueryPreviewTxt($previewArea);
		
		e.preventDefault();
	});
	
	// Show the button by default, but hide if the 'modify search' button is off
	if ($(".results", "#content").length > 0){
		$("#resetSearch").hide();
	}	
});


// Adds special radio button styles
function styleRadios()
{
	$("#effectsOptions input").each(function () {
		$(this)
		.css("display", "none");		
		if ($(this)[0].checked)		
				$(this).before('<span class="radio checked"></span>');
		else
				$(this).before('<span class="radio"></span>');				
	});
	
	$("#effectsOptions span").click(function () {
		if (!$(this).hasClass("checked"))
		{
			$(this).addClass("checked").next("input")[0].checked = true;
			$("#effectsOptions span").not(this).removeClass("checked");
			
		}
	});
}

function searchQueryPreviewTxt($applyTo){
	var changesBy = new Object();
	var affects   = new Object();
		
	// Prepare all of the object for reference later
	// note: $ used to show that this is a jQuery obj
	affects = {
		"$titleObj"       : $('#affected-title'),
		"$yrChoice"       : $('input[name=affected-year-choice]:checked'),
		"$yrSpecificObj"  : $('#affected-year'),
		"$number"         : $('#affected-number'),
		"$yrRangeBeginObj": $('#affected-start-year'),
		"$yrRangeEndObj"  : $('#affected-end-year'),
		"$typeObj"				:	$('#affected-type')
	};
	
	changesBy = {
		"$titleObj"       : $('#affecting-title'),
		"$yrChoice"       : $('input[name=affecting-year-choice]:checked'),
		"$yrSpecificObj"  : $('#affecting-year'),
		"$number"         : $('#affecting-number'),
		"$yrRangeBeginObj": $('#affecting-start-year'),
		"$yrRangeEndObj"  : $('#affecting-end-year'),
		"$typeObj"				:	$('#affecting-type')
	}
	
	// Add text to variables, either using a prepared function or directly using the jQuery .val() method
	
	affects.title  = byTitle(affects);
	affects.type = byType(affects);
	affects.year   = byYear(affects);
	affects.number = byNumber(affects);
	
	changesBy.title  = byTitle(changesBy);
	changesBy.type = byType(changesBy);
	changesBy.year   = byYear(changesBy);
	changesBy.number   = byNumber(changesBy);
	
	$applyTo.html("You want to search for changes that affect " + affects.type + affects.year + affects.number + " made by " + changesBy.type + changesBy.year + changesBy.number);
	
	// Pattern for testing/amending output within function:
	// (Only need to use this if the input cannot be directly passes straight to variable)
	// Pass the relevent top level object containing the sub objects so that the same function can be used
	// for different types
	function byNumber(obj){
		if (obj.$yrChoice.val() == "specific") {
			if (obj.$number.val() =="" || obj.$number.val() == obj.$number.data("defaultText")){
				return "";
			} else {
				return " numbered <strong>" + obj.$number.val().escapeHTML() + "</strong>";;
			}
		} else {
			return "";
		}
	}
	
	// Check to see if the value has changed from the default
	function byType(obj) {
		var type = $("option:selected", obj.$typeObj).text();
		
		if (type === obj.$typeObj.data("defaultText") || type == "") {
			// default
			//return "<strong>all Legislation</strong>";
			return "all legislation";
		} else {				
			// Grab the data from the amended fields
			return "<strong>" + type.escapeHTML() + "</strong>";
		}			
	};
	
	// Check to see if the value has changed from the default
	function byTitle(obj) {
		if (obj || obj.$titleObj.val() === obj.$titleObj.data("defaultText") || obj.$titleObj.val() == "") {
			// default
			//return "<strong>all Legislation</strong>";
			return "all legislation";
		} else {				
			// Grab the data from the amended fields
			return "Legislation title/keywords <strong>" + obj.$titleObj.val().escapeHTML() + "</strong>";
		}			
	};
	
	function byYear(obj) {
		
		// Check to see if a range of years
		if (obj.$yrChoice.val()=="specific") {
			// One year
			if (obj.$yrSpecificObj.val() == obj.$yrSpecificObj.data("defaultText") || obj.$yrSpecificObj.val() == "") {
				// return nil so response does not exist unless changed
				return "";
			} else {
				return " in <strong>" + obj.$yrSpecificObj.val().escapeHTML() + "</strong>";
			}			
			
		} else if (obj.$yrChoice.val()=="range") {
			
			// Range of years
			if (obj.$yrRangeBeginObj.val() == obj.$yrRangeBeginObj.data("defaultText") || obj.$yrRangeBeginObj.val() == "" || obj.$yrRangeEndObj.val() == "" || obj.$yrRangeEndObj.val() == obj.$yrRangeEndObj.data("defaultText")) {
				// return nil so response does not exist unless changed
				return "";
			} else {
				return " between <strong>" + obj.$yrRangeBeginObj.val().escapeHTML() + " and " + obj.$yrRangeEndObj.val().escapeHTML() + "</strong>";
			}
			
		} else {
			// default
			return "";
		}			
	};
}


String.prototype.escapeHTML = function () {
    return (
		this.replace(/&/g, '&amp;').
			 replace(/>/g, '&gt;').
			 replace(/</g, '&lt;').
			 replace(/"/g, '&quot;')
	);
};