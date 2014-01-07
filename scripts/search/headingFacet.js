/*
�  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

*/

/*
 * Heading Search Facet
 * 
 * Take a list of links to search headings and create a jQuery UI autocomplete combox from them
 * with a button that jumps to the sub heading page on click
 * 
 * Requires: jQueryUI
 */
$(document).ready(function() {
    
    var 
        $selectSubHeadingComboBox = $( "#subheading ul:first" )
                                        .comboboxFromLinks()
                                        .parent()
                                            .find('.ui-combobox'),                                        
        $navJumpBtn = $('<a class="userFunctionalElement disabled" />').attr({
                            'id': 'submitHeading',
                            'name': 'submitHeading',
                            'href': '#'
                        })
                        .append('<span class="btl"/>')
                        .append('<span class="btr"/>')
                        .append('View subheading results')
                        .append('<span class="bbl"/>')
                        .append('<span class="bbr"/>')
                        .button();
    
    // Add to DOM and bind events
    $selectSubHeadingComboBox
                .after($navJumpBtn) // Insert the nav jump button
                .children('.ui-combobox-input')
                    .bind('autocompleteselect', function(event, ui) {
                        setJumpBtnDestination(ui.item);
                    })
                    .bind('autocompletechange', function(event, ui) {
                        setJumpBtnDestination(ui.item);
                    })
                    .filter(function() {
                        // on document init()
                        setJumpBtnDestination($(this).data('autocomplete').selectedItem);
                        return this;
                    })
                
       
       /**
        * Logic to enable/disable and change nav jump button 'href' attribute
        * 
        * @param selectedSubheadingItem Object containing a reference to the selected link from $selectSubHeadingComboBox
        */
       function setJumpBtnDestination(selectedSubheadingItem) {
            
            // Find the selected element from the combobox
            var selectedSubheadingElement = (selectedSubheadingItem) ? selectedSubheadingItem.option : null;
                
            // As long as an element has been selected
            if (selectedSubheadingElement) {
                
                $navJumpBtn
                    // Enable the button
                    .removeClass( "disabled" )
                    .button( "option", "disabled", false )
                    // Change the window location
                    .attr('href', $(selectedSubheadingElement).attr('href')); 

            } else {

                // disable the button
                $navJumpBtn
                    .addClass( "disabled" )
                    .button( "option", "disabled", true );

            }
       }
    
});