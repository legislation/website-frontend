/*
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/
/**
 * Legislation Table of Contents (ToC) Expand and Collapse.
 *
 * Used to add expand/collapse functionality to a ToC link element (that is created by another process), e.g.:
 * $(link).legTocExpandCollapse('pageId', 5);
 *
 * @param {string} pageId
 *   Uniquely identifiable page name.
 * @param {number} cookieExpire
 *   How long to persist the cookie.
 * @returns {jQuery}
 *   jQuery chaining/fluent interface.
 */
$.fn.legTocExpandCollapse = function (pageId, cookieExpire) {

    var COOKIE_ID = 'legTocExpandCollapse';
    var state = {};
    var $this = $(this);
    var useCookies = function () {
        return window.legGlobals.cookiePolicy.settings;
    };

    if (useCookies()) {
        state = readCookie();
    } else {
        eraseCookie();
    }

    // Using this method for inserting text and relying on CSS to show correct attribute as less intensive on DOM.
    // The divider is made available in case CSS is disabled.
    $this
        .html('<span class="tocExpandText">' + config.links.message3[LANG] + '</span>' +
            '<span class="tocTextDivider">/</span>' +
            '<span class="tocCollapseText">' + config.links.message4[LANG] + '</span>');

    // if cookie stored for related id, expand part
    $this.each(function () {
        var $link = $(this);
        var $part = $link.parent();

        // if saved and default expanded, collapse. Saved and default collapsed, expand
        if (readIdInState($part.attr('id'))) {
            if ($part.is('.tocDefaultExpanded')) {
                $link.nextAll('ol').slideUp(0);
            } else {
                $link.addClass('expand');
            }
        } else {
            // default expanded: expand. default collapsed: collapse
            if ($part.is('.tocDefaultExpanded')) {
                $link.addClass('expand');
            } else {
                $link.nextAll('ol').slideUp(0);
            }
        }
    });

    // toggle between expand and collapse. State appended to cookie if different from default
    $this.each(function () {

        $(this).click(function (e) {
            var $link = $(this);

            // disable anchor link
            e.preventDefault();

            var $part = $link.parent();

            $link.toggleClass('expand');
            $link.nextAll('ol').slideToggle(400).toggleClass('expanded');

            if ($part.is('.tocDefaultExpanded') && !$link.is('.expand')) {
                updateId($part.attr('id'));
            } else if ($part.is('.tocDefaultCollapse') && $link.is('.expand')) {
                updateId($part.attr('id'));
            } else {
                deleteId($part.attr('id'));
            }
        });
    });

    /**
     * Update the state with the value of the ID.
     *
     * @param {string} id
     */
    function updateId(id) {
        state[id] = '';

        if (useCookies()) {
            updateCookie();
        }
    }

    /**
     * Delete the ID from the state.
     *
     * @param {string} id
     */
    function deleteId(id) {
        delete state[id];

        if (useCookies()) {
            updateCookie();
        }
    }

    // ------------------------------
    // Cookie functions
    // ------------------------------

    /**
     * Write state contents to cookie.
     */
    function updateCookie() {

        var cookieContents = pageId + ';';
        for (var i in state) {
            cookieContents += (i + '#');
        }

        $.cookie(COOKIE_ID, cookieContents, {path: '/', expires: cookieExpire});
    }

    /**
     * Read and deserialize the cookie values into an object.
     *
     * @returns {{}}
     *   Values by ID key.
     */
    function readCookie() {
        var associative = {};

        var name = $.cookie(COOKIE_ID);
        if (name) {
            var split = name.split(';');

            if (split.length > 1) {
                var values = split[1].split('#');

                for (var i = 0; i < values.length; i++) {
                    if (values[i] !== '') {
                        associative[values[i]] = '';
                    }
                }
            }
        }

        return associative;
    }

    /**
     * Read the value of the passed ID.
     *
     * @param {string} id
     * @returns {*|null}
     */
    function readIdInState(id) {
        return state && state[id] === '';
    }

    /**
     * Delete the cookie used for persistence.
     */
    function eraseCookie() {
        if ($.cookie(COOKIE_ID)) {
            $.removeCookie(COOKIE_ID, {path: '/'});
        }
    }

    return $this;
};
