/*
 (c)  Crown copyright

 You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

 http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

 */
// JavaScript for Welsh Lnaguage wrapper

var LANG;
try {
    LANG = document.location.pathname.substr(1).split('/').shift() === 'cy' ? 'cy' : 'en';
} catch (e) {
    LANG = 'en';
}

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
                en: "View results",
                cy: "Gweld canlyniadau"
            },
            hide: {
                en: "Close",
                cy: "Cau"
            }

        }
    },
    outstandingRefsContent: {
        expandCollapseLink: {
            show: {
                en: "Expand", // toc ChromeInit.js line no 173
                cy: "Ehangu"
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

    },
    cookieShowHideTable: {
        settings: {
            show: {
                en: 'Show details of these <span class="accessibleText">settings </span> cookies',
                cy: 'Dangoswch fanylion y  <span class="accessibleText">cwcis </span> gosodiadau hyn'
            },
            hide: {
                en: 'Hide details of these <span class="accessibleText">settings </span> cookies',
                cy: 'Cuddiwch fanylion y <span class="accessibleText">cwcis </span> gosodiadau hyn'
            }
        },
        analytics: {
            show: {
                en: 'Show details of these <span class="accessibleText">analytics </span> cookies',
                cy: 'Dangoswch fanylion y <span class="accessibleText">cwcis </span> dadansoddiadau hyn'
            },
            hide: {
                en: 'Hide details of these <span class="accessibleText">analytics </span> cookies',
                cy: 'Cuddiwch fanylion y <span class="accessibleText">cwcis </span> dadansoddiadau hyn'
            }
        },
        essential: {
            show: {
                en: 'Show details of these <span class="accessibleText">essential </span> cookies',
                cy: 'Dangoswch fanylion y <span class="accessibleText">cwcis </span> hanfodol hyn'
            },
            hide: {
                en: 'Hide details of these <span class="accessibleText">essential </span> cookies',
                cy: 'Cuddiwch fanylion y <span class="accessibleText">cwcis </span> hanfodol hyn'
            }
        }
    },
    cookieFormSave: {
        en: 'Save your settings',
        cy: 'Cadwch eich gosodiadau'
    },
    carousel: {
        play: {
            en: 'Play',
            cy: 'Play'
        },
        pause: {
            en: 'Pause',
            cy: 'Pause'
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

    $().ready(function () {

        $("#title").addClass("titleCy cy");    // about us page dropdown and input box size fixes
        $(".title").addClass("title titlecy");
        $(".type").addClass("typeCy");

        $(".typeCheckBoxDoubleCol").addClass("typeCheckBoxDoubleColCy");  // search Wlesh page css fixing for check boxes

    });
}
;

/*!
 * jQuery Cookie Plugin v1.3.1
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2013 Klaus Hartl
 * Released under the MIT license
 */
$(document).ready(function () {

    (function (factory) {
        if (typeof define === 'function' && define.amd) {
            // AMD. Register as anonymous module.
            define(['jquery'], factory);
        } else {
            // Browser globals.
            factory(jQuery);
        }
    }(function ($) {

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

        var config = $.cookie = function (key, value, options) {

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

        $.removeCookie = function (key, options) {
            if ($.cookie(key) !== undefined) {
                $.cookie(key, '', $.extend(options, {expires: -1}));
                return true;
            }
            return false;
        };

    }));

});
