/*
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/
/**
 * Manage & add the annual survey via a simple banner on the page.
 *
 * Adjust the constants to the appropriate values if they change.
 *
 * Call the function in the initialisation section of the page to ensure that banners are added in order.
 */
$(function () {
    window.legGlobals.addSurvey = function () {
        var SURVEY_URL = "https://www.smartsurvey.co.uk/s/8VQDYJ/";
        var SURVEY_COOKIE_NAME = 'close_banner_cookie_2019_07_110900';
        var SURVEY_HTML = {
            en: '<div class="content">' +
                '<p>' +
                '<span class="survey-text">We\'re continuing to make changes to legislation.gov.uk. Please tell us what you think by taking our survey.</span>' +
                '<a class="survey-link" href="' + SURVEY_URL + '" target="_blank">Tell us what you think</a>' +
                '</p>' +
                '<button class="banner-close">X<span class="accessibleText"> Close</span></button>' +
                '</div>',
            cy: '<div class="content">' +
                '<p>' +
                '<span class="survey-text">We\'re continuing to make changes to legislation.gov.uk. Please tell us what you think by taking our survey.</span>' +
                '<a class="survey-link" href="' + SURVEY_URL + '" target="_blank">Tell us what you think</a>' +
                '</p>' +
                '<button class="banner-close">Close</button>' +
                '</div>'
        }

        // Add the survey banner for English view only
        if (LANG !== 'cy' && !$('body').hasClass('plainview')) {

            $(SURVEY_HTML[LANG]).simpleBanner({
                id: 'survey-banner',
                closeBtnSelector: '.banner-close',
                doShow: function () {
                    // By default the banner is shown unless the user has allowed cookies.
                    // Check the cookie to see if the banner has been closed before and hide
                    // if it has.
                    var show = true;
                    var cookie;

                    if (window.legGlobals.cookiePolicy.settings) {
                        cookie = $.cookie(SURVEY_COOKIE_NAME);

                        if (cookie && cookie === 'Yes') {
                            show = false;
                        }
                    } else {
                        $.removeCookie(SURVEY_COOKIE_NAME, {path: '/'});
                    }

                    return show;
                },
                onClose: function () {
                    if (window.legGlobals.cookiePolicy.settings) {
                        $.cookie(SURVEY_COOKIE_NAME, 'Yes', {expire: 365, path: '/'});
                    }
                },
                onClick: function (event) {
                    if ($(event.target).hasClass('survey-link')) {
                        this.close();
                        if (window.legGlobals.cookiePolicy.settings) {
                            $.cookie(SURVEY_COOKIE_NAME, 'Yes', {expire: 365, path: '/'});
                        }
                    }

                }
            });

        }
    }

});
