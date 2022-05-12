/**
 * Add to the global variables with cookie policy information properties and set methods.
 *
 * Note: This method does not wait for Document.ready before firing so the globals are available immediately.
 */
(function () {

    /**
     * Cookie name that stores cookie policy information.
     *
     * @type {string}
     */
    var COOKIE = 'accepted_cookie_policy';

    /**
     * How long before the cookie policy information expires.
     *
     * @type {number}
     */
    var EXPIRES = 90;

    // Safely create the legGlobals on the window to prevent error if it is not already present.
    window.legGlobals = window.legGlobals || {};

    /**
     * Default properties that are used for cookie management.
     *
     * @type {{analytics: boolean, settings: boolean, userSet: boolean}}
     */
    window.legGlobals.cookiePolicy = {

        /**
         * Whether the user has explicitly set a cookie usage policy.
         */
        userSet: false,

        /**
         * Whether the user accepts the use of cookies to remember site settings, e.g. expand/collapse state.
         */
        settings: false,

        /**
         * Whether the user accepts the use of analytics cookies.
         */
        analytics: false
    };

    /**
     * Retrieve the JSON serialized.
     *
     * @returns {undefined|Object}
     *   Parsed cookie values in Object format.
     */
    window.legGlobals.cookiePolicy.getCookie = function () {
        var cookieValues = $.cookie(COOKIE);

        if (!cookieValues) {
            cookieValues = undefined;
        } else {
            // The old cookie policy used a string, 'Yes', to set the policy.
            // If the old policy exists we must delete the old cookie for the user to reset the policy.
            try {
                cookieValues = JSON.parse(cookieValues);
            } catch (e) {
                $.removeCookie(COOKIE, {path: '/'});
            }
        }

        return cookieValues;
    };

    /**
     * Find if the user has set the cookie policy.
     *
     * @returns {boolean}
     *   Whether the user has set the cookie policy (accepted or not).
     */
    window.legGlobals.cookiePolicy.isSet = function () {
        var acceptedCookiePolicy = this.getCookie();

        return (acceptedCookiePolicy) ?
            acceptedCookiePolicy.userSet :
            false;
    };

    /**
     * Load the cookie defined in COOKIE and set properties on the object.
     *
     * The defaults properties are set to the values that assume a user has not accepted the cookie policy
     * in any way so they are only overwritten in the case where the user has set preferences.
     */
    window.legGlobals.cookiePolicy.serialize = function () {

        var cookieContents;

        if (this.isSet()) {
            cookieContents = this.getCookie();
            this.userSet = cookieContents.userSet;
            this.analytics = cookieContents.analytics;
            this.settings = cookieContents.settings;
        }

    }

    /**
     * Set the values for the cookie policy into a locally stored cookie.
     *
     * @param {boolean} analytics
     *   Whether the user accepts the use of analytics cookies.
     * @param {boolean} settings
     *   Whether the user accepts the use of cookies to remember site settings, e.g. expand/collapse state.
     */
    window.legGlobals.cookiePolicy.setValues = function (analytics, settings) {
        var cookieContents = JSON.stringify({
            userSet: true,
            analytics: analytics,
            settings: settings
        });

        this.userSet = true;
        this.analytics = analytics;
        this.settings = settings;

        $.cookie(COOKIE, cookieContents, {expires: EXPIRES, path: '/'});
    }

    // On initialisation serialize the preferences that have been saved (if they exist).
    window.legGlobals.cookiePolicy.serialize();

})();
