/*
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

*/
/*Advanced Search Functionality
*
One-liner: Adds validation, default text and show/hide fields to 'advanced search' form
Requirements: jQuery framework: http://jquery.com/
jqueryui 1.4
jquery.ui.datepicker
formFunctions/common.js
 
Notes:
For help, anchor link should be the same as id of associated help box
 
History:
v0.01	TE Created
v0.02	2010-06-08	TE	Fixed positioning
v0.03	2010-06-09	TE	Added input value saving
v0.04	2010-06-28	TE 	Fixed XHTML Strict issues
v0.05  2010-12-08  GE  Consolidated code to use shared functionality
Requires the formFunctions/common.js to preceed it in HTML
*/

$(document).ready(function () {

    $theForm = $("#advancedSearch");

    // Show or hide fields based on radio button choices
    $("input:[name=yearRadio]").showHideFields();

    // validate form - use of ID's rather than input@name is for speed   
    $("#specificYear").validate("year");
    $("#yearStart").validate("year").addDefaultText(config.validate.year[LANG]);
    $("#yearEnd").validate("year").addDefaultText(config.validate.year[LANG]);
    $("#searchNumber").validate("number");
    $(".searchPIT input").validate("date").addDefaultText(config.validate.date[LANG]);
	$("#start").validate("date").addDefaultText(config.validate.date[LANG]);
	$("#end").validate("date").addDefaultText(config.validate.date[LANG]);
    if ($("#PIT").length) {
        $("#specificYear").addDefaultText(config.validate.specificYear[LANG]);
    }

    // Remove these values from the submitted form so that the backend doesn't need to handle them
    $theForm.clearDefaultValues();

    // Add the datepicker for the Point in Time search
    addDatePicker();

    // Add the extent expand/collapse box
    typeShowHide();

    // Show selected extent
    showSelectedExtent();
});

function addDatePicker() {
    var PIT = $("#PIT");
	var start = $("#start");
	var end = $("#end");
    if (PIT != null && PIT.size() > 0) {
        PIT.datepicker({
            showOn: "button",
            buttonText: "",
            dateFormat: 'dd/mm/yy'
        });
    }
	if (start != null && start.size() > 0) {
        start.datepicker({
            showOn: "button",
            buttonText: "",
            dateFormat: 'dd/mm/yy'
        });
    }
	if (end != null && end.size() > 0) {
        end.datepicker({
            showOn: "button",
            buttonText: "",
            dateFormat: 'dd/mm/yy'
        });
    }
}

function typeShowHide() {
    // add show/hide checkbox
    $('#allSecondary').after('<div id="uniqueExtents" class="typeCheckBoxCol extent"><input type="checkbox" id="ind" name="type" value="individual"/><label for="ind">'+config.search.showHide.selectTypes[LANG]+'</label> </div>');

    // Wrap content in a single block to prevent columns of different heights 
    // from animating at different speeds
    $('#primaryLeg, #secondaryLeg').wrapAll('<div id="lex" />');

    // Add the show/hide event and set default view
    $('#uniqueExtents :checkbox')
    .click(function () {
        // Toggle the class of the parent when the animation begins
        // and then when the animation finishes
        var $lex = $('#lex');
        var $controller = $(this);

        if ($controller.is(':checked')) {
            // Start of expand animation
            $controller.parent().addClass('expanded');
            $lex.slideToggle('slow');
        } else {
            // Close the box
            $lex.slideToggle('slow', function () {
                // Change class at animation end
                $controller.parent().removeClass('expanded');
            });
        }
    })
    .is(':checked') ? $('#lex').show() : $('#lex').hide();
}

function showSelectedExtent() {
    // Create the block where the extents will be listed
    $('.searchExtendsTo').append('<div id="extentSearchInfo"/>');

    // Load this block into memory
    var $infoBlock = $('#extentSearchInfo');

    // Load the checkboxes into memory
    $checkboxes = $('input[name="extent"], input[name="extent-match"]')

    // Set initial view
    $infoBlock.showExtentInfo($checkboxes);

    // When any checkboxes are clicked, rework the output
    $checkboxes.click(function () {
    		$checkbox = $(this);
    		if ($checkbox.is(':checked')) {
	    		if ($checkbox.is('[value="uk"]') || $checkbox.is('[value="gb"]') || $checkbox.is('[value="ew"]')) {
	    			$checkboxes.filter('[name="extent"]').not(this).each(function () {
	    				this.checked = false;
	    			});
	    		} else if ($checkbox.is('[name="extent"]')) {
	    			$checkboxes.filter('[value="uk"]')[0].checked = false;
	    			$checkboxes.filter('[value="gb"]')[0].checked = false;
	    			$checkboxes.filter('[value="ew"]')[0].checked = false;
	    		}
	    	}
        $infoBlock.showExtentInfo($checkboxes);
    });
}

// Pugin expects the inputs to include radio btns for the type of combo
$.fn.showExtentInfo = function (inputs) {

    // The extent object - allows easy manipulation
    var extent = function () {
        // Constructor for extent object
				// Contains variables that will be used by the object

        // All combinations of extent
        this.allExtents = ["E", "W", "S", "N.I.", "E+W", "E+S", "E+N.I.", "W+S", "W+N.I.", "S+N.I.", "E+W+S", "E+W+N.I.", "E+S+N.I.", "W+S+N.I.", "E+W+S+N.I."];
        this.applicableExtents = {
            uk: ["E", "W", "S", "N.I.", "E+W", "E+S", "E+N.I.", "W+S", "W+N.I.", "S+N.I.", "E+W+S", "E+W+N.I.", "E+S+N.I.", "W+S+N.I.", "E+W+S+N.I."],
            gb: ["E", "W", "S", "E+W", "E+S", "E+N.I.", "W+S", "W+N.I.", "S+N.I.", "E+W+S", "E+W+N.I.", "E+S+N.I.", "W+S+N.I.", "E+W+S+N.I."],
            ew: ["E", "W", "E+W", "E+S", "E+N.I.", "W+S", "W+N.I.", "E+W+S", "E+W+N.I.", "E+S+N.I.", "W+S+N.I.", "E+W+S+N.I."],
            england: ["E", "E+W", "E+S", "E+N.I.", "E+W+S", "E+W+N.I.", "E+S+N.I.", "E+W+S+N.I."],
            wales: ["W", "E+W", "W+S", "W+N.I.", "E+W+S", "E+W+N.I.", "W+S+N.I.", "E+W+S+N.I."],
            scotland: ["S", "E+S", "W+S", "S+N.I.", "E+W+S", "E+S+N.I.", "W+S+N.I.", "E+W+S+N.I."],
            ni: ["N.I.", "E+N.I.", "W+N.I.", "S+N.I.", "E+W+N.I.", "E+S+N.I.", "W+S+N.I.", "E+W+S+N.I."]
        };
        this.extentSearchCoverage = []; // Bucket for extents that the tickboxes select
        this.html = ''; // String for html output
    }

    // Add methods using Object Notation
    extent.prototype = {
        // Public methods ------------------------

        // Add coverage to the object
        addCoverage: function (typeOfSearch, extendsTo) {
            var newCoverage = [];
            if (typeOfSearch === 'applicable') {
            	newCoverage = this.applicableExtents[extendsTo];
            } else {
            	newCoverage = [extendsTo];
            }
			
            for (var i in newCoverage) {
                this.extentSearchCoverage.push(newCoverage[i]);
            }
            return this;
        },
        // Transform the list of extents to a HTML ready version
        convertExtentListToHtml: function () {

            // First remove duplicates and sort the extent list
            this.extentSearchCoverage = this.eliminateDuplicates(this.extentSearchCoverage); // Eliminate any duplicates that exist
            this.extentSearchCoverage.sort(this.sortOnExtent); // Sort extents based on the position of the first letter

            for (var item in this.extentSearchCoverage) {
                // Add the help title text
                var title = this.extentSearchCoverage[item].replace("E", "England").replace("W", "Wales").replace("S", "Scotland").replace("N.I.", "Northern Ireland").split('+').join(' and ');

                // Add html for the extent
                this.html += '<span class="LegExtentRestriction" title="Applies to ' + title + '"><span class="btr"></span>' + this.extentSearchCoverage[item] + '<span class="bbl"></span><span class="bbr"></span></span>';
            }

            return this; // allow chaining
        },
        // Output the html to a jQuery selector
        outputHtmlToElement: function (jQuerySelector) {
			// First clear the existing html out and replace
            $(jQuerySelector).html('').append('<h4>'+ config.search.extentCombonation[LANG]+ '</h4>' + this.html);
        },

        // Internal methods ------------------------

        // This method is used by the addCoverage method to remove any duplication
        eliminateDuplicates: function (arr) {
            var i,
				len = arr.length,
				out = [],
				obj = {};

            for (i = 0; i < len; i++) {
                obj[arr[i]] = 0;
            }

            for (i in obj) {
                out.push(i);
            }

            return out;
        },
        // Sort arrays based on the lexicon
        // array.sort(sortOnExtent);
        sortOnExtent: function (a, b) {
			if (a.length === b.length) {
				// The order in which countries should be listed
				var lexicon = "\E\W\S\N.I.";
				var x = lexicon.indexOf(a[0]);
				var y = lexicon.indexOf(b[0]);
				// Sort based on the lexicon order
				return x - y;
			} else {
				return a.length - b.length;
			}
        }
    } // prototype extension
	
	// jQuery plugin return (to keep chaining)
    return this.each(function () {
        // the exact extents if necessary
        var exactExtents = [];

        // the radio buttons control the type of search
        var searchType = $(inputs).filter('.radio:checked').val();

        // Create a new extent object for data manipulation
        var ext = new extent();

				var extentFields = $(inputs).filter(':checked[name="extent"]');
				
        // Add the selected extents into the ext.extentList   
				if (searchType === 'applicable') {
					extentFields.each(function () {
						ext.addCoverage(searchType, $(this).val()); // add coverage based on the type of search and the extent range
					});
				} else {
					if (extentFields.is('[value="uk"]')) {
						ext.addCoverage(searchType, 'E+W+S+N.I.');
					} else if (extentFields.is('[value="gb"]')) {
						ext.addCoverage(searchType, 'E+W+S');
					} else if (extentFields.is('[value="ew"]')) {
						ext.addCoverage(searchType, 'E+W');
					} else {
						if (extentFields.is('[value="england"]')) {
							exactExtents.push('E');
						}
						if (extentFields.is('[value="wales"]')) {
							exactExtents.push('W');
						}
						if (extentFields.is('[value="scotland"]')) {
							exactExtents.push('S');
						}
						if (extentFields.is('[value="ni"]')) {
							exactExtents.push('N.I.');
						}
						if (exactExtents.length !== 0) {
							ext.addCoverage(searchType, exactExtents.join('+'));
						}
					}
				}

        // After all extents have been added, convert the array to HTML and output
        ext.convertExtentListToHtml().outputHtmlToElement(this);
		
		// Destroy ext
		ext = '';
		
    }); // End of return.this() plugin
	
}   // End of plugin