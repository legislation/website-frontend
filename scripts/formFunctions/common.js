/*
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/
/*Changes to Legislation Search Functionality
*
One-liner: common form interactivity
Requirements: jQuery framework: http://jquery.com/

Detailed info:
Adds show/hide functionality for sub groups
Validates forms before sending form
The different tests need each other to work correctly

History:
v0.01	2010-12-08	GE	Created
*/

$.fn.clearDefaultValues = function () {
    // Remove these values from the submitted form so that the backend doesn't need to handle these values
    return this.each(function () {
        $(this).submit(function (e) {
            if (!$(this).hasClass("error")) {
                $(".jsDefaultVal").each(function () {
                    if ($(this).val() == $(this).data("defaultText"))
                        $(this).val("");
                });
                $("#errorBar").remove();
            } else {
                e.preventDefault();
            }
        });
    });
}

$.fn.addDefaultText = function (defaultText) {
    // Add default values to text boxes that disappear when clicked on but
    // are added back if the user doesn't input anything
    return this.each(function () {
        // Save the field for later use
        var $field = $(this);

        // Add this information to the object for detection upon form submissal
        $field.data("defaultText", defaultText);

        $field.addClass("jsDefaultVal");

        if ($field.val() == "")
            $field.val(defaultText);

        $field
		.focus(function () {
		    if ($(this).val() == defaultText)
		        $(this).val("");
		})
		.blur(function () {
		    if ($(this).val() == "")
		        $(this).val(defaultText);
		});
    });
}

$.fn.validate = function (type) {

    // Provide validtion for call later

    // Provide default argument if left blank
    if (!type) {
        type = "year";
    }

    return this.each(function () {

        var errorMsg, $errorBlock, testRegexp, $fieldValTrimmed, $form, $fieldParent, $field = $(this);

        $field.closest("form").submit(function (event) {
            // Clear the previous error messages and start process again
            $field.parent().find(".errorMessage").remove();
            $field.parent().find(".error").removeClass("error");

            $form = $(this);

            // Paterns and responses for each data type
            switch (type) {
                case "year":
                    testRegexp = /(^$)|(YYYY)|(BBBB)|(Unrhyw un)|(Any)|(^\d{4}$)/;
                    errorMsg = config.forms.errormsg1[LANG];
                    break;
                case "date":
                    testRegexp = /(^$)|(^(\d{1,2}\/\d{1,2}\/\d{4})*$)|(^^DD\/MM\/BBBB$)|(^^DD\/MM\/YYYY$)/;
                    errorMsg = config.forms.errormsg2[LANG];
                    break;
                case "number":
                    testRegexp = /(^$)|(^\d*$)|(Unrhyw un)|(Any)/;
                    errorMsg =  config.forms.errormsg3[LANG]
                    break;
            }

            // If the field is enabled run the test
            if ($field.parent().find("input:enabled").length) {

                // Tes that the string matches the 'type' testRegexp, trim it of whirespace first
                if (!$field.val().replace(/^\s+|\s+$/g, "").match(testRegexp)) {

                    // Create the error message area containing the appropriate error text
                    $errorBlock = $("<span/>").addClass("error errorMessage").html(errorMsg);

                    // If the error message hasn't been added yet, add it
                    if (!$("#errorBar", $form).length) {
                        $form
						.prepend('<div id="errorBar" class="error errorMessage">' + config.errorBar.error[LANG] + '</div>' )
                    }

                    $form.addClass("error");

                    // Add error details to the field
                    if (!$field.hasClass("error")) {
                        $field
						.addClass("error")
						.closest("div")
						.append($errorBlock);

                        // add error class to associated label
                        $("label[for=" + $field.attr("id") + "]").addClass("error");

                        // Add the layover back to the fields
                        $(".jsController", $form).showHideFields();

                        // If fields have a default value, fake a user clicking on them to restore it
                        // This currently stops the prevent action... unsure of fix
                        //$(".jsDefaultVal", $form).click().blur();

                    }
                    event.preventDefault();

                    // Scroll to error message
                    if ($("#newSearch").length) {
                        $(window).scrollTop($("#newSearch").position().top)
                    } else {
                        $(window).scrollTop($("#errorBar").position().top)
                    }
                }
            }
        });
    });
}

$.fn.showHideFields = function () {

    // Grab the array of jQuery Objects (necessary to loop over in a non-jquery way)
    var controller = this;

    return this.each(function () {
        // purpose: disabled inputs don't fire events, put overlay span over input to capture click. once click registered
        // set the fields focus, enable them and remove overlays. The child fields of the non-selected radio buttons are then disabled
        // Requires: a div surrounding each group of related fields to the checkbox named .formGroup

        // create variables with scope of the .each function
        var $field, controllerParent;

        // On initilaisation, gives default view
        enableDisableFields();

        // A normal user click kicks off the function, also add a class to let other scripts pick this up as a controller
        $(controller).addClass("jsController").click(function () {
            enableDisableFields();
        });

        function enableDisableFields($focusField) {

            for (i = 0; i < controller.length; i++) {
                controllerParent = controller.parent("div")[i];
                $field = $(controllerParent).find("input:text, select");

                $field.addClass("jsControlledField");

                // find the checked radioBtn, easier using regular JS for this bit rather than jQuery
                if (controller[i].checked) {
                    // Show the relevant children
                    $field.removeAttr("disabled").removeClass("disabled");

                    // Set the focus if this parameter has been set
                    if ($focusField) {
                        $focusField.focus();
                    }
                } else {
                    // disable these children
                    $field
                        .attr('disabled', 'disabled')
                        .addClass('disabled'); // For IE consistent CSS to be applied
                }
                // Once the view has been amended add/remove the appropriates overlays
                addRemoveOverlays();
            }
        }

        function addRemoveOverlays() {

            // Don't add any overlays on the side refine search bar
            if ($('#refineSearch').length) {
                return false;
            }

            // Expect a jQuery obj with one or more objects in
            $field.each(function () {

                var $currentField = $(this);
                var $parent = $(this).parent();
                var $overlay = $('<span class="overlay"/>');
                var $formGroup = $(this).closest(".formGroup");

                // remove previously set overlays to provide a clean form for new ones to be applied
                $parent.children(".overlay").remove();

                if ($(this).hasClass("disabled")) {

                    // Add the overlay to the selected element
                    $parent.append($overlay);

                    // Style the overalys
                    $overlay.css({
                        backgroundColor: "#FFFFFF",
                        opacity: 0,
                        position: "absolute",
                        top: $(this).position().top + parseInt($(this).css("margin-top")),
                        left: $(this).position().left + parseInt($(this).css("margin-left")),
                        width: $(this).outerWidth(),
                        height: $(this).outerHeight(),
                        zIndex: 200
                    }).click(function () {
                        // Gives the same functionality as if the user had clicked on the radio
                        $formGroup.find("input:radio").click();
                        // emulate a click event on the input so that other functions can find when a user accesses it
                        $currentField.click();
                        //alert($currentField.attr("id"));
                        enableDisableFields($currentField);
                    });
                }
                else {
                    // Destroy existing overlay to access item
                    $parent.children(".overlay").remove();
                }
            });
        }
    });
}

