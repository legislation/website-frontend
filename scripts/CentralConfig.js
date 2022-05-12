/*
 (c)  Crown copyright

 You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

 http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

 */
// JavaScript for Welsh Lnaguage wrapper

var matches = document.location.pathname.match(/^\/(cy|en)\//);
var LANG = (matches) ? matches[1] : "en";

var config = {
    validate: {
        year: {
            en: 'YYYY',
            cy: 'BBBB'   // will change it later after testing    seach.js  line no 40 -48
        },
        date: {
            en: "DD/MM/YYYY", //  serach.js line no 41,42,43
            cy: "DD/MM/BBBB"
        },
        specificYear: {
            en: 'Any',
            cy: 'Unrhyw un'
        },
        number: {
            en: "Any",
            cy: 'Unrhyw un'
        }
    },
    search: {
        affectingTitle: {
            //cy: "Mae'r holl ddeddfwriaeth (neu nodwch y teitl)",
            cy: "Pob deddfwriaeth (neu rhowch y teitl)",
            en: "All legislation (or insert title)"
        },
        affect: {
            apply: {
                part1: {
                    en: " You want to search for changes that affect ",
                    cy: " Rydych chi eisiau chwilio am newidiadau sy’n effeithio ar "
                },
                part2: {
                    en: " made by ",
                    cy: " a wnaed gan "
                },
                part3: {
                    en: "all legislation ",
                    cy: "bob deddfwriaeth "
                }
            }
        },
        expandCollapse: {
            message1: {
                en: "Modify search", // search.js   line no 63
                cy: "Addasu’r chwiliad"
            },
            message2: {
                en: "Hide search form", // search.js   line no 64
                cy: "Cuddio ffurflen chwilio"
            }
        },
        newSearch: {
            message1: {
                en: "Reset Fields", // search.js   line no 102
                cy: "Ailosod Meysydd"
            }
        },
        showHide: {
            selectTypes: {
                en: "Select types", // search.js   line no 90
                cy: "Dewis mathau"
            }
        },
        extentCombonation: {
            en: "Extent combinations this search will include:", // search.js   line no 211
            cy: "Cyfuniadau graddfa y bydd y chwiliad hwn yn eu cynnwys:"
        }
    },
    pagination: {// minpagination.js  line no 127
        currPageInfo: {
            textPage: {
                en: "Page ",
                cy: "Tudalen "
            },
            textOf: {
                en: " of ",
                cy: " o "
            }
        }

    },
    errorBar: {
        error: {
            en: "Please check the form fields which are highlighted in red", // common.js line no 115
            cy: "Gwiriwch feysydd y ffurflen sydd wedi eu hamlygu mewn coch"
        }
    },
    forms: {
        errormsg1: {
            en: "Not a valid year", // common.js line no 91
            cy: "Ddim yn flwyddyn ddilys"
        },
        errormsg2: {
            en: "Not a valid date (dd/mm/yyyy)", // common.js line no 95
            cy: "Ddim yn ddyddiad dilys (dd/mm/bbbb)"
        },
        errormsg3: {
            en: "Not a valid number", // common.js line no 99
            cy: "Ddim yn rif dilys"
        },
        errormsg4: {
            en: "didn't match any item", // search/JQuery.ui.comboboxFormLinks.js  line no 40
            cy: "ddim yn cyfateb ag unrhyw eitem"
        }
    },
    links: {
        message1: {
            en: "Collapse all -", // chrome.js Line no 211  (chromelnit.js line no  215, 214, 220)
            cy: "Cwympo oll –"
        },
        message2: {
            en: "Expand all +", //chrome.js Line no 211  (chromelnit.js line no  215, 214, 220
            cy: "Ehangu oll +"
        },
        message3: {
            en: "Expand +", // toc ExpandCollapse.js line no 27
            cy: "Ehangu +"
        },
        message4: {
            en: "Collapse -", // toc ExpandCollapse.js line no 27
            cy: "Cwympo -"
        }
    },
    statusWarning: {
        expandCollapseLink: {
            message1: {
                en: "View outstanding changes", // chromelnit.js line no  114
                cy: "Gweld newidiadau sy’n aros"
            },
            message2: {
                en: "status warnings", // chromelnit.js line no  114
                cy: "rhybuddion statws"
            },
            message3: {
                en: "Close", // chromelnit.js line no  114
                cy: "Cau"
            }
        }
    },
    statusWarningSubSections: {
        expandCollapseLink: {
            message1: {
                en: "View changes", // chromelnit.js line no  x
                cy: "Gweld newidiadau"
            },
            message2: {
                en: "View outstanding changes", // chromelnit.js line no  x
                cy: "Gweld newidiadau sy’n aros"
            },
            message3: {
              en: "status warnings", // chromelnit.js line no  114
              cy: "rhybuddion statws"
            },
            message4: {
                en: "Close", // chromelnit.js line no  x
                cy: "Cau"
            }
        }
    },
    statusEffectsAppliedSection: {
        expandCollapseLink: {
            message1: {
                en: "More", // chromelnit.js line no  126
                cy: "Mwy"
            },
            message2: {
                en: "effects to be announced", // chromelnit.js line no  126
                cy: "effeithiau i’w cyhoeddi"
            },
            message3: {
                en: "Close", // chromelnit.js line no  114
                cy: "Cau"
            }

        }
    },
    changesAppliedContent: {
        expandCollapseLink: {
            message1: {
                en: "More", // chromelnit.js line no  135
                cy: "Mwy"
            },
            message2: {
                en: "effects to be announced", // chromelnit.js line no  135
                cy: "effeithiau i'w cyhoeddi"
            },
            message3: {
                en: "Close", // chromelnit.js line no  135
                cy: "Cau"
            }

        }
    },
    outstandingRefs: {
        expandCollapseLink: {
            show: {
                en: "See legislation that may make changes to this Regulation",
                cy: "Gweler deddfwriaeth a all wneud newidiadau i’r Rheoliad hwn"
            },
            hide: {
                en: "Close",
                cy: "Cau"
            }

        }
    },
    commencementAppliedContent: {
        expandCollapseLink: {
            message1: {
                en: "More", // chromelnit.js line no  144
                cy: "Mwy"
            },
            message2: {
                en: "changes to be applied", // chromelnit.js line no  144
                cy: "newidiadau i'w gweithredu"
            },
            message3: {
                en: "Close", // chromelnit.js line no  144
                cy: "Cau"
            }
        }
    },
    quickSearch: {
        expandCollapseLink: {
            message1: {
                en: "Search Legislation", // chromelnit.js line no  151
                cy: "Chwilio"
            },
            message2: {
                en: "Show", // chromelnit.js line no  151
                cy: "Dangos"
            },
            message3: {
                en: "Hide", // chromelnit.js line no  151
                cy: "Cuddio"
            }
        }
    },
    dcAlternativeLink: {
        message1: {
                en: "Show full page title", // chromelnit.js line no  294
                cy: "Dangos"
        },
        message2: {
                en: "Hide full page title", // chromelnit.js line no  294
                cy: "Cuddio"
        }
    },
    modalwin: {
        title: {
            en: "Large image view", //   showMessageDialog.js  line no 170
            cy: "Gwedd delwedd mawr"                     //   showMessageDialog.js  line no 170
        }
    },
    viewLegContents: {
        previous: {
            en: "Previous match", //  prevousNextTextMatches.js   line no:  12
            cy: "Canlyniad blaenorol"                   //
        },
        next: {
            en: "Next match", //  prevousNextTextMatches.js   line no:  12
            cy: "Canlyniad nesaf"
        },
        backToSearch: {
            en: "Back to search results", //  prevousNextTextMatches.js   line no:  16
            cy: "Yn ôl i’r canlyniadau chwilio"
        }

    }
}



/*   this is the configs for "eniw_leg.gov.uk.js"   line no 61 and 62
 explanatory: {
 collapseText:{
 en: "Collapse All Explanatory Notes (ENs)",
 cy: "Collapse Pob Nodyn Esboniadol (ENs)"
 },

 expandText:{
 en: "Expand All Explanatory Notes (ENs)",
 cy: "Ehangu Pob Nodyn Esboniadol (ENs)"
 }
 }

 */


/* Fixing CSS isueu by assing new class
 only work in Welsh version
 */


if (LANG == "cy") {

    $( ).ready(function() {

        $("#title").addClass("titleCy cy");    // about us page dropdown and input box size fixes
        $(".title").addClass("title titlecy");
        $(".type").addClass("typeCy");

        $(".typeCheckBoxDoubleCol").addClass("typeCheckBoxDoubleColCy");  // search Wlesh page css fixing for check boxes

    });
}
;

/**
 * Drop-down message
 */
/*!
 * jQuery Cookie Plugin v1.3.1
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2013 Klaus Hartl
 * Released under the MIT license
 */
$(document).ready(function() {

    (function(factory) {
        if (typeof define === 'function' && define.amd) {
            // AMD. Register as anonymous module.
            define(['jquery'], factory);
        } else {
            // Browser globals.
            factory(jQuery);
        }
    }(function($) {

        var pluses = /\+/g;

        function raw(s) {
            return s;
        }

        function decoded(s) {
            return decodeURIComponent(s.replace(pluses, ' '));
        }

        function converted(s) {
            if (s.indexOf('"') === 0) {
                // This is a quoted cookie as according to RFC2068, unescape
                s = s.slice(1, -1).replace(/\\"/g, '"').replace(/\\\\/g, '\\');
            }
            try {
                return config.json ? JSON.parse(s) : s;
            } catch (er) {
            }
        }

        var config = $.cookie = function(key, value, options) {

            // write
            if (value !== undefined) {
                options = $.extend({}, config.defaults, options);

                if (typeof options.expires === 'number') {
                    var days = options.expires, t = options.expires = new Date();
                    t.setDate(t.getDate() + days);
                }

                value = config.json ? JSON.stringify(value) : String(value);

                return (document.cookie = [
                    config.raw ? key : encodeURIComponent(key),
                    '=',
                    config.raw ? value : encodeURIComponent(value),
                    options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
                    options.path ? '; path=' + options.path : '',
                    options.domain ? '; domain=' + options.domain : '',
                    options.secure ? '; secure' : ''
                ].join(''));
            }

            // read
            var decode = config.raw ? raw : decoded;
            var cookies = document.cookie.split('; ');
            var result = key ? undefined : {};
            for (var i = 0, l = cookies.length; i < l; i++) {
                var parts = cookies[i].split('=');
                var name = decode(parts.shift());
                var cookie = decode(parts.join('='));

                if (key && key === name) {
                    result = converted(cookie);
                    break;
                }

                if (!key) {
                    result[name] = converted(cookie);
                }
            }

            return result;
        };

        config.defaults = {};

        $.removeCookie = function(key, options) {
            if ($.cookie(key) !== undefined) {
                $.cookie(key, '', $.extend(options, {expires: -1}));
                return true;
            }
            return false;
        };

    }));

    /**
     * jQuery Cookies Functions
     */
    function cli_show_cookiebar(html, json_payload) {
        var ACCEPT_COOKIE_NAME = 'close_banner_cookie_2019_07_110900'; //close_banner_cookie_{yyyy_mm_ddHHMM}
        var ACCEPT_COOKIE_EXPIRE = 365;
        var settings = json_payload;

        $('body').prepend(html);
        var cached_header = $(settings.notify_div_id);
        var cached_showagain_tab = $(settings.showagain_div_id);
        var btn_accept = $('#cookie_hdr_accept');
        var btn_decline = $('#cookie_hdr_decline');
        var btn_moreinfo = $('#cookie_hdr_moreinfo');
        var btn_settings = $('#cookie_hdr_settings');

        cached_header.hide();
        if (!settings.showagain_tab) {
            cached_showagain_tab.hide();
        }

        var hdr_args = {
            'background-color': settings.background,
            'color': settings.text,
            'font-family': settings.font_family
        };
        var showagain_args = {
            'background-color': settings.background,
            'color': l1hs(settings.text),
            'position': 'fixed',
            'font-family': settings.font_family
        };
        if (settings.border_on) {
            var border_to_hide = 'border-' + settings.notify_position_vertical;
            showagain_args['border'] = '1px solid ' + l1hs(settings.border);
            showagain_args[border_to_hide] = 'none';
        }
        if (settings.notify_position_vertical == "top") {
            if (settings.border_on) {
                hdr_args['border-bottom'] = '4px solid ' + l1hs(settings.border);
            }
            showagain_args.top = '0';
        }
        else if (settings.notify_position_vertical == "bottom") {
            if (settings.border_on) {
                hdr_args['border-top'] = '4px solid ' + l1hs(settings.border);
            }
            hdr_args['position'] = 'fixed';
            hdr_args['bottom'] = '0';
            showagain_args.bottom = '0';
        }
        if (settings.notify_position_horizontal == "left") {
            showagain_args.left = settings.showagain_x_position;
        }
        else if (settings.notify_position_horizontal == "right") {
            showagain_args.right = settings.showagain_x_position;
        }
        cached_header.css(hdr_args);
        cached_showagain_tab.css(showagain_args);

        if ($.cookie(ACCEPT_COOKIE_NAME) == null) {
            displayHeader();
        }
        else {
            cached_header.hide();
        }

        var main_button = $('.cli-plugin-main-button');
        main_button.css('color', settings.button_1_link_colour);

        if (settings.button_1_as_button) {
            main_button.css('background-color', settings.button_1_button_colour);

            main_button.hover(function() {
                $(this).css('background-color', settings.button_1_button_hover);
            },
                    function() {
                        $(this).css('background-color', settings.button_1_button_colour);
                    });
        }
        var main_link = $('.cli-plugin-main-link');
        main_link.css('color', settings.button_2_link_colour);

        if (settings.button_2_as_button) {
            main_link.css('background-color', settings.button_2_button_colour);

            main_link.hover(function() {
                $(this).css('background-color', settings.button_2_button_hover);
            },
                    function() {
                        $(this).css('background-color', settings.button_2_button_colour);
                    });
        }

        // Action event listener for "show header" event:
        cached_showagain_tab.click(function() {
            cached_showagain_tab.slideUp(settings.animate_speed_hide, function slideShow() {
                cached_header.slideDown(settings.animate_speed_show);
            });
        });

        // Action event listener to capture delete cookies shortcode click. This simply deletes the accepted_cookie_policy cookie. To use:
        // <a href='#' id='cookielawinfo-cookie-delete' class='cookie_hdr_btn'>Delete Cookies</a>
        $("#cookielawinfo-cookie-delete").click(function() {
            $.cookie(ACCEPT_COOKIE_NAME, null, {
                expires: 365,
                path: '/'
            });
            return false;
        });

        // Action event listener for debug cookies value link. To use:
        // <a href='#' id='cookielawinfo-debug-cookie'>Show Cookie Value</a>
        $("#cookielawinfo-debug-cookie").click(function() {
            alert("Cookie value: " + $.cookie(ACCEPT_COOKIE_NAME));
            return false;
        });

        // action event listeners to capture "accept/continue" events:
        $("#cookie_action_close_header").click(function() {
            // Set cookie then hide header:
            $.cookie(ACCEPT_COOKIE_NAME, 'yes', {
                expires: ACCEPT_COOKIE_EXPIRE,
                path: '/'
            });

            if (settings.notify_animate_hide) {
                cached_header.slideUp(settings.animate_speed_hide);
            }
            else {
                cached_header.hide();
            }
            cached_showagain_tab.slideDown(settings.animate_speed_show);
            return false;
        });

        function displayHeader() {
            if (settings.notify_animate_show) {
                cached_header.slideDown(settings.animate_speed_show);
            }
            else {
                cached_header.show();
            }
            cached_showagain_tab.hide();
        }

    }
    ;
    function l1hs(str) {
        if (str.charAt(0) == "#") {
            str = str.substring(1, str.length);
        } else {
            return "#" + str;
        }
        return l1hs(str);
    }

    /**
     * Inject message in English site and normal view
     * renmoved target=\"_blank\" for DEFRALEX link
     */

    if ((LANG != "cy") && (!$("body").hasClass("plainview"))) {
		var a = '<div id="cookie-law-info-bar2" class="cookie-law-info-survey-bar"><div id="survey-banner" class="scenario"><div class="bannercontent"><span class="main">We\'re continuing to make changes to legislation.gov.uk. Please tell us what you think by taking our survey. </span><span class="link"><a href="https://www.smartsurvey.co.uk/s/M24EQW/" id=\"CONSTANT_OPEN_URL\" target=\"_blank\" class=\"cli-plugin-main-survey-link\">Tell us what you think</a></span><span class="close"><a href=\"#\" id=\"cookie_action_close_header\"  class=\"medium cli-plugin-survey-button cli-plugin-main-survey-button\" >X</a></span></div></div></div>',
                b = {"animate_speed_hide":"500","animate_speed_show":"500","background":"","border":"","border_on":"false","button_1_button_colour":"","button_1_button_hover":"","button_1_link_colour":"","button_1_as_button":false,"button_2_button_colour":"","button_2_button_hover":"","button_2_link_colour":"","button_2_as_button":false,"font_family":"","notify_animate_hide":true,"notify_animate_show":false,"notify_div_id":"#cookie-law-info-bar2","notify_position_horizontal":"right","notify_position_vertical":"top","showagain_tab":false,"showagain_background":"","showagain_border":"","showagain_div_id":"#cookie-law-info-again","showagain_x_position":"100px","text":""};
        cli_show_cookiebar(a, b);
    }
	
	
	if ((LANG != "cy") && (!$("body").hasClass("plainview"))) {
		var a = '<div id="cookie-law-info-bar1" class="cookie-law-info-survey-bar"><div id="coronavirus-banner" class="scenario"><div class="bannercontent"><span class="main"><strong>Coronavirus</strong></span><span class="legislation"><strong><a href="/coronavirus" class="link">See Coronavirus legislation</a></strong><br/>on legislation.gov.uk</span><span class="extents">Get Coronavirus guidance from <strong><a href="https://www.gov.uk/coronavirus" class="link" target="_blank">GOV.UK</a></strong><br/>Additional advice for <strong><a href="https://www.gov.scot/coronavirus-covid-19" class="link" target="_blank">Scotland</a> | <a href="https://gov.wales/coronavirus" class="link" target="_blank">Wales</a> | <a href="https://www.nidirect.gov.uk/campaigns/coronavirus-covid-19" class="link" target="_blank">Northern Ireland</a></strong></span> </div></div></div>',
                b = {"animate_speed_hide":"500","animate_speed_show":"500","background":"","border":"","border_on":"false","button_1_button_colour":"","button_1_button_hover":"","button_1_link_colour":"","button_1_as_button":false,"button_2_button_colour":"","button_2_button_hover":"","button_2_link_colour":"","button_2_as_button":false,"font_family":"","notify_animate_hide":true,"notify_animate_show":false,"notify_div_id":"#cookie-law-info-bar1","notify_position_horizontal":"right","notify_position_vertical":"top","showagain_tab":false,"showagain_background":"","showagain_border":"","showagain_div_id":"#cookie-law-info-again","showagain_x_position":"100px","text":""};
        $('body').prepend(a);
    }
	
	if ((LANG == "cy") && (!$("body").hasClass("plainview"))) {
		var a = '<div id="cookie-law-info-bar1" class="cookie-law-info-survey-bar"><div id="coronavirus-banner" class="scenario"><div class="bannercontent"><span class="main-cy"><strong>Coronafirws</strong></span><span class="legislation-cy"><strong><a href="/coronavirus" class="link">Gweler deddfwriaeth coronafirws</a></strong><br/>ar ddeddfwriaeth.gov.uk</span><span class="extents-cy">Sicrhewch ganllaw coronafirws gan <strong><a href="https://www.gov.uk/coronavirus" class="link" target="_blank">GOV.UK</a></strong><br/>Cyngor ychwanegol: <strong><a href="https://www.gov.scot/coronavirus-covid-19" class="link" target="_blank">Yr Alban</a> | <a href="https://llyw.cymru/coronavirus" class="link" target="_blank">Cymru</a> | <a href="https://www.nidirect.gov.uk/campaigns/coronavirus-covid-19" class="link" target="_blank">Gogledd Iwerddon</a></strong></span> </div></div></div>',
                b = {"animate_speed_hide":"500","animate_speed_show":"500","background":"","border":"","border_on":"false","button_1_button_colour":"","button_1_button_hover":"","button_1_link_colour":"","button_1_as_button":false,"button_2_button_colour":"","button_2_button_hover":"","button_2_link_colour":"","button_2_as_button":false,"font_family":"","notify_animate_hide":true,"notify_animate_show":false,"notify_div_id":"#cookie-law-info-bar1","notify_position_horizontal":"right","notify_position_vertical":"top","showagain_tab":false,"showagain_background":"","showagain_border":"","showagain_div_id":"#cookie-law-info-again","showagain_x_position":"100px","text":""};
         $('body').prepend(a);
    }
    
		
});
