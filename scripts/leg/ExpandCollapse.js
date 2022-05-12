/*
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/
/**
 * Legislation Expand and Collapse jQuery plugin.
 *
 * Expand and collapse box with the controlling link being created by another function, e.g.:
 * $(link).legExpandCollapse(['More', 'Close'], {state:, expires: 0});
 *
 * Notes:
 * CSS - position: relative on the expanding element causes problems with IE by rendering all child
 * elements after the animation, avoid if possible. By using on a child element that element is
 * rendered before the animation has begun and could look confusing.
 * CookieArray is an object used to store cookie key value pairs. If it isnt passed, will default to contracted
 *
 * @param {array} htmlValues
 *   Values to use for the HTML text, e.g. ['More', 'Close'].
 * @param {{state: [], expires: null|number, open: string}} options
 *   Options for initialisation.
 * @returns {void | jQuery}
 *   jQuery chaining/fluent interface.
 */
$.fn.legExpandCollapse = function (htmlValues, options) {

    var href = $(this).attr('href');
    var $this = $(this);
    var $target = $($this.attr('href'));

    // Set any supplied options
    var openByDefault = options ? options.open : false;
    var cookieArray = options ? options.state : {};
    var expires = options ? options.expires : 0;

    // We can only persist state if the user has allowed the use of cookies.
    var useCookies = function () {
        return window.legGlobals.cookiePolicy.settings && !!cookieArray;
    }

    // Check to see if any values have been passed to overwrite the defaults
    var htmlContracted = htmlValues ? htmlValues[0] : 'More';
    var htmlExpanded = htmlValues ? htmlValues[1] : 'Close';

    if (useCookies()) {
        readCookie('legExpandCollapse', cookieArray);
    } else {
        eraseCookie('legExpandCollapse');
    }

    // default is to hide the element
    if (href && useCookies() && (cookieArray[href.substring(1)] === 'show')) {
        $this.html(htmlExpanded).addClass('close');
        $target.show();
    } else if (href && useCookies() && (cookieArray[href.substring(1)] === 'hide')) {
        $this.html(htmlContracted)
        $target.hide();
    } else if (openByDefault) {
        $this.html(htmlExpanded).addClass('close');
        $target.show();
    } else {
        $this.html(htmlContracted);
        $target.hide();
    }

    // Event Handlers
    return $this.click(function (e) {
        e.preventDefault();

        if (!$this.hasClass('close')) {
            $target.slideDown(400);
            $this.html(htmlExpanded).toggleClass('close');
            if (useCookies()) {
                updateIdInCookie('legExpandCollapse', cookieArray, href.substring(1), 'show', expires);
            }
        } else {
            $target.slideUp(400);
            $this.html(htmlContracted).toggleClass('close');
            if (useCookies()) {
                updateIdInCookie('legExpandCollapse', cookieArray, href.substring(1), 'hide', expires);
            }
        }
    });

    // ------------------------------
    // Cookie functions
    // ------------------------------

    /**
     * Update the cookie value for item with given ID.
     *
     * @param {string} cookieName
     * @param {object} cookieContents
     * @param {string} id
     * @param {string} value
     * @param {number} cookieExpire
     */
    function updateIdInCookie(cookieName, cookieContents, id, value, cookieExpire) {
        cookieContents[id] = value;
        updateCookie(cookieName, cookieContents, cookieExpire);
    }

    /**
     * Persist data to cookie by serializing object into a string.
     *
     * @param {string} cookieName
     * @param {object} cookieContents
     * @param {number|null} cookieExpire
     */
    function updateCookie(cookieName, cookieContents, cookieExpire) {
        var contentAsString = '';

        for (var i in cookieContents) {
            contentAsString += (i + '#' + cookieContents[i] + ';');
        }

        if (!cookieExpire) {
            cookieExpire = null;
        }

        $.cookie(cookieName, contentAsString, {path: '/', expires: cookieExpire});
    }

    /**
     * Deserializes the cookie string into an object.
     *
     * Cookie string format is id#page;id#page
     *
     * @param {string} cookieName
     * @param {object} cookieContents
     * @returns {object}
     */
    function readCookie(cookieName, cookieContents) {
        var cookie = $.cookie(cookieName);
        if (cookie) {
            var elements = cookie.split(';');

            for (var i = 0; i < elements.length; i++) {
                if (elements[i] != '') {
                    var value = elements[i].split('#');
                    var page = value[0];
                    var value = value[1];
                    cookieContents[page] = value;
                }
            }
        }

        return cookieContents;
    }

    /**
     * Remove persisted cookie.
     *
     * @param {string} cookieName
     */
    function eraseCookie(cookieName) {
        if ($.cookie(cookieName)) {
            $.removeCookie(cookieName, {path: '/'});
        }
    }
};
