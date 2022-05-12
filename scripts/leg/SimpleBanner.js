/*
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

*/
/**
 * Small banner plugin to add banners to the main site.
 *
 * Optionally can have onClose() and onClick() handlers passed to allow for cookie persistence management.
 *
 * The option.doShow() function should return a boolean value to determine if the banner is shown or not.
 *
 * @param {[{[id]: string, [closeBtnSelector]: string, [doShow]: function|boolean, [onClose]: function, [onClick]: function}]} options
 *   Options for the plugin.
 * @returns {[]|jQuery|HTMLElement}
 *   jQuery chaining/fluent interface.
 */
$.fn.simpleBanner = function (options) {

    return $(this).each(function () {

        var defaultOptions = {
            closeBtnSelector: '.banner-close',
            doShow: function () {
                return true;
            }
        };

        options = options || {};
        options = $.extend(defaultOptions, options);

        var $banner = $('<div class="banner" />');
        var context = this;

        if (options.id) {
            $banner.attr('id', options.id);
        }

        $banner.append(this);

        if (options.doShow && options.doShow()) {
            $('#top').after($banner);
        } else {
            return;
        }

        if (options.closeBtnSelector) {

            var $button = $banner.find(options.closeBtnSelector);

            $button.click(function (e) {
                e.preventDefault();
                options.onClose(e);
                context.close();
            });
        }

        if (options.onClick) {
            $banner.click(function (event) {
                options.onClick.call(context, event);
            });
        }

        this.close = function () {
            $banner.slideUp(500, function () {
                $banner.remove();
            });
        }
    });

}
