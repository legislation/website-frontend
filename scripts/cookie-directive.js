/**
 * Cookie directive banner.
 *
 * A banner appended to the top of the page that informs the user whether they would like to accept all cookies
 * or instead be taken to the page that allows them to choose them.
 */
$(function () {

    /**
     * Cookie directive banner markup and text for both English and Welsh.
     *
     * @type {{cy: ([]|jQuery), en: ([]|jQuery)}}
     */
    var $cookieBanner = {
        en: $('<div class="cookie-preferences-banner">' +
            '<div class="content">' +
            '<h2>Cookies on Legislation.gov.uk</h2>' +
            '<p>The cookies on legislation.gov.uk do two things: they remember any settings you\'ve chosen so you ' +
            'don\'t have to choose them on every page, and they help us understand how people browse our website, so we ' +
            'can make improvements and fix problems. We need your consent to use some of these cookies.</p>' +
            '<ul class="cookie-actions">' +
            '<li>' +
            '<button class="btn accept-all-cookies">Yes, these cookies are OK</button>' +
            '</li>' +
            '<li>' +
            '<a class="btn set-individual-cookies" href="/cookiepolicy">' +
            'Find out more or set individual cookie preferences' +
            '</a>' +
            '</li>' +
            '<li>' +
            '<button class="btn reject-all-cookies">No, I want to reject all cookies</button>' +
            '</li>' +
            '</ul>' +
            '</div>' +
            '</div>'),
        cy: $('<div class="cookie-preferences-banner">' +
            '<div class="content">' +
            '<h2>Cwcis ar Ddeddfwriaeth.gov.uk</h2>' +
            '<p>Mae\'r cwcis ar deddfwriaeth.gov.uk yn gwneud dau beth: maent yn cofio unrhyw osodiadau rydych chi wedi\'u dewis ' +
            'felly does dim rhaid i chi eu dewis ar bob tudalen, ac maent yn ein helpu i ddeall sut mae pobl yn pori ein gwefan, ' +
            'er mwyn i ni allu gwneud gwelliannau a thrwsio problemau. Mae angen eich caniatâd arnom i ddefnyddio rhai o\'r cwcis hyn.</p>' +
            '<ul class="cookie-actions">' +
            '<li>' +
            '<button class="btn cy accept-all-cookies">Ydyn, mae\'r cwcis hyn yn IAWN</button>' +
            '</li>' +
            '<li>' +
            '<a class="btn cy set-individual-cookies" href="/cy/cookiepolicy">' +
            'Dysgu mwy neu osod dewisiadau unigol ar gyfer cwcis' +
            '</a>' +
            '</li>' +
            '<li>' +
            '<button class="btn cy reject-all-cookies">Nac ydyn, hoffwn wrthod yr holl gwcis</button>' +
            '</li>' +
            '</ul>' +
            '</div>' +
            '</div>')
    };

    /**
     * Success message banner to be shown after accepting all cookies.
     *
     * @type {{cy: ([]|jQuery), en: ([]|jQuery)}}
     */
    var $cookieBannerSuccess = {
        en: $('<div class="cookie-preferences-banner updated">' +
            '<div class="content">' +
            '<h2>Cookie preferences updated</h2>' +
            '<p>You can change your cookie settings at any time using our <a href="/cookiepolicy">cookies page</a></p>' +
            '<ul class="cookie-actions">' +
            '<li>' +
            '<button class="btn dismiss-banner">Dismiss</button>' +
            '</li>' +
            '</ul>' +
            '</div>' +
            '</div>'),
        cy: $('<div class="cookie-preferences-banner updated">' +
            '<div class="content">' +
            '<h2>Dewisiadau cwcis wedi\’u diweddaru</h2>' +
            '<p>Gallwch newid eich gosodiadau cwcis ar unrhyw adeg trwy ddefnyddio ein <a href="/cy/cookiepolicy">tudalen cwcis</a></p>' +
            '<ul class="cookie-actions">' +
            '<li>' +
            '<button class="btn dismiss-banner">Gwrthod</button>' +
            '</li>' +
            '</ul>' +
            '</div>' +
            '</div>')
    };

    // Append the banner before the navigation skip links so that it is the first thing that assistive technology
    // can find.
    if (!window.legGlobals.cookiePolicy.isSet()) {
        $('#top')
            .after($cookieBanner[LANG]);
    }

    var isCookiePolicyPage = window.location.pathname.split('/').pop() === 'cookiepolicy';

    // Event listeners are placed on the body (and use event bubbling) to prevent duplication of listeners on
    // different language banners.
        $('body')
        .click(function (event) {
            var $target = $(event.target);

            // User has accepted all cookies
            if ($target.hasClass('accept-all-cookies')) {
                window.legGlobals.cookiePolicy.setValues(true, true);

                $('body').trigger('cookie.preferences.saved.banner');
                bannerActions();
            }

            // User has rejected all cookies
            if ($target.hasClass('reject-all-cookies')) {
                window.legGlobals.cookiePolicy.setValues(false, false);
                bannerActions();
            }

            if ($target.hasClass('dismiss-banner')) {
                $cookieBannerSuccess[LANG]
                    .slideUp();
            }

        });

    bannerActions = function() {
        // Remove the cookie banner and replace with a success message.
        $cookieBanner[LANG]
            .slideUp(function () {
                $(this).remove();

                $('#top')
                    .after($cookieBannerSuccess[LANG]);

                $cookieBannerSuccess[LANG]
                    .hide();

                $cookieBannerSuccess[LANG]
                    .slideDown();
            });
    }

    if (isCookiePolicyPage) {
        $cookieBanner[LANG]
            .find('.cookie-policy-link')
            .click(function (e) {
                e.preventDefault();
                $('html,body')
                    .animate({
                            scrollTop: $('#pageTitle').offset().top
                        },
                        'fast');
            });

        // If the cookie preferences form is saved then show the success message.
        $('body')
            // Note: .live used for compatibility with jQuery 1.6, in future should be .on
            .live('cookie.preferences.saved', function () {
                $cookieBanner[LANG].remove();

                $('#top')
                    .after($cookieBannerSuccess[LANG]);
                $cookieBannerSuccess[LANG].show();
            });
    }

    // If cookies are not accepted then images are injected onto the site for server-side analytics
    if (!window.legGlobals.cookiePolicy.userSet) {
        $('body').append('<img src="/images/analytics/cookiesBannerIgnored.gif" alt="" />');
    } else if (!window.legGlobals.cookiePolicy.analytics) {
        $('body').append('<img src="/images/analytics/cookiesForAnalyticsRejected.gif" alt="" />');
    }

});

/**
 * Cookie directive page form.
 *
 * Injects form elements onto the page for cookie preferences to be collected and set via JS *only*.
 *
 * Requires a <form> with the ID of "cookie-preferences-management" to be available. In this form there should be
 * elements matching the selectors:
 * - .cookie-form-hook.settings-cookies
 * - .cookie-form-hook.analytics-cookies
 * - .cookie-form-hook.essential-cookies
 *
 * Will not be added to any page other than the urls:
 * - /cookiepolicy
 * - /cy/cookiepolicy
 *
 */
$(function () {

    // Only run this script if we are on the cookie policy page.
    if (window.location.pathname.split('/').pop() !== 'cookiepolicy') {
        return;
    }

    /**
     * Create & return a jQuery radio button element and associated label.
     *
     * @param {boolean} isSelected
     *   Whether this element should be selected/checked.
     * @param {string|boolean} value
     *   The value that the radio should have.
     * @param {string} name
     *   The name of the input group.
     * @param {string} id
     *   Input ID.
     * @param {string} label
     *   Text label associated with element.
     * @returns {jQuery}
     *   Newly created radio button jQuery element.
     */
    function createRadioElement(isSelected, value, name, id, label) {
        var $el = $('<div class="cookie-form-element"></div>');

        var $input = $('<input type="radio" />');
        var $label = $('<label>' + label + '</label>');

        $label
            .attr('for', id);

        $input
            .attr('name', name)
            .attr('id', id)
            .attr('value', value);

        if (isSelected) {
            $input.attr('checked', 'checked');
        }

        $el
            .append($input)
            .append($label);

        return $el;
    }

    /**
     * Create the form elements and event handler to save cookie preferences individually.
     */
    function createForm() {
        var preferences = window.legGlobals.cookiePolicy.getCookie() || {};
        var isSet = window.legGlobals.cookiePolicy.isSet();
        var $form = $('#cookie-preferences-management');
        var $settingsSection = $form.find('.cookie-form-hook.settings-cookies');
        var $analyticsSection = $form.find('.cookie-form-hook.analytics-cookies');

        // Create the radio buttons and append them to the appropriate portion of the page.
        var settingsEls = [
            createRadioElement((isSet) ? preferences.settings : false, true, 'cookie-settings', 'cookie-settings-accept', 'Use cookies that remember my settings on legislation.gov.uk'),
            createRadioElement((isSet) ? !preferences.settings : false, false, 'cookie-settings', 'cookie-settings-reject', 'Do not use cookies that remember my settings on legislation.gov.uk')
        ];

        var analyticsEls = [
            createRadioElement((isSet) ? preferences.analytics : false, true, 'cookie-analytics', 'cookie-analytics-accept', 'Use cookies that help the Legislation team understand how people use legislation.gov.uk'),
            createRadioElement((isSet) ? !preferences.analytics : false, false, 'cookie-analytics', 'cookie-analytics-reject', 'Do not use cookies that help the Legislation team understand how people use legislation.gov.uk')
        ]

        $.each(settingsEls, function (idx, $el) {
            $settingsSection.append($el);
        });

        $.each(analyticsEls, function (idx, $el) {
            $analyticsSection.append($el);
        });

        // Create the button that submits the form.
        var $button = $('<button type="submit" class="btn"></button>').appendTo($form);

        // If the settings are updated by the banner then update the radios on the page.
        $('body').live('cookie.preferences.saved.banner', function () {

            preferences = window.legGlobals.cookiePolicy.getCookie();

            $('#cookie-settings-accept').prop('checked', preferences.settings);
            $('#cookie-settings-reject').prop('checked', !preferences.settings);

            $('#cookie-analytics-accept').prop('checked', preferences.analytics);
            $('#cookie-analytics-reject').prop('checked', !preferences.analytics);
        });

        $button
            .text(window.config.cookieFormSave[LANG])
            .click(function (e) {
                e.preventDefault();

                var userPreferences = {};

                $.each($('#cookie-preferences-management').serializeArray(), function (idx, setting) {
                    userPreferences[setting.name.split('-').pop()] = setting.value === 'true';
                });

                window.legGlobals.cookiePolicy.setValues(
                    userPreferences.analytics,
                    userPreferences.settings
                );

                // Inform the banner that the preferences have been updated.
                $('body').trigger('cookie.preferences.saved');

                $('html, body').animate({scrollTop: 0}, 'fast');
            });
    }

    /**
     * Remove the non-JS messaging to prevent confusing messages.
     */
    function removeNonJsMessaging() {
        $('.cookie-form-hook').find('.no-js').remove();
    }

    // Initialisation
    createForm();
    removeNonJsMessaging();

});

/**
 * Cookie page expand/collapse headers.
 *
 * The functionality for these expand and collapse section headers is unique as they are injected into the page
 * so this custom code manages this.
 */
$(function () {

    /**
     * Inject and expand/collapse link into the text when a heading doesn't already exist.
     *
     * @param {{show: string, hide: string}} text
     * @param {string} targetSelector
     * @returns {jQuery}
     */
    function createExpandCollapseLink(text, targetSelector) {

        var $button = $('<button class="btn show-hide">' + text.show + '</button>');
        var $target = $(targetSelector);
        var isHidden = true;
        var isAnimating = false;

        // Hide the target element by default
        $target.hide();

        $button.click(function (e) {
            e.preventDefault();

            if (isAnimating) {
                return;
            }

            // Set the state of the animation and end state.
            isAnimating = true;
            isHidden = !isHidden;

            $button
                .html(isHidden ? text.show : text.hide)
                .toggleClass('close');

            $target.slideToggle(400, function () {
                isAnimating = false;
            });
        });

        return $button;

    }

    // @todo these text strings to be brought out into the EN/CY translation block
    $('.details.settings-cookies')
        .before(createExpandCollapseLink({
            show: window.config.cookieShowHideTable.settings.show[LANG],
            hide: window.config.cookieShowHideTable.settings.hide[LANG]
        }, '.details.settings-cookies'));

    $('.details.analytics-cookies')
        .before(createExpandCollapseLink({
            show: window.config.cookieShowHideTable.analytics.show[LANG],
            hide: window.config.cookieShowHideTable.analytics.hide[LANG]
        }, '.details.analytics-cookies'));

    $('.details.essential-cookies')
        .before(createExpandCollapseLink({
            show: window.config.cookieShowHideTable.essential.show[LANG],
            hide: window.config.cookieShowHideTable.essential.hide[LANG]
        }, '.details.essential-cookies'))

});
