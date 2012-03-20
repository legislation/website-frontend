/*
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

*/

// jQuery tabs
jQuery(document).ready(function () {
    // Hide tabs except first
    $(".tab:not(:first)").hide();

    // IE 6 fix...
    $(".tab:first").show();

    // Highlight first tab
    $(".htabs a:first").addClass('active');

    // tab anchor click
    $(".htabs a").click(function () {

        $('.active').removeClass('active');

        //get the ID of the element we need to show
        stringref = $(this).addClass('active').attr("href").split('#')[1];

        //display our tab fading it in
        $('.tab#' + stringref).fadeIn();

        //hide the tabs that doesn't match the ID
        $('.tab:not(#' + stringref + ')').hide();

        //stay with current page
        return false;
    });
});