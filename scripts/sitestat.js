// Copyright (c) 1999-2004 Nedstat B.V.
// All rights reserved.
// By using this software, you are agreeing to be bound by the
// terms of this license: http://www.nedstat.com/terms.html
var ns_scriptversion="132";// 2004-05-24












































																																																									function ns_14(){var ns_02 = navigator.appVersion;var ns_00 = parseInt(ns_02.substring(ns_02.indexOf("MSIE")+5, ns_02.indexOf("MSIE")+6));if (ns_00 > 0) ns_02 = 0;else ns_02 = parseInt(ns_02);return ns_02;}function ns_22(){var ns_02 = navigator.appVersion;var ns_01 = parseInt(ns_02.substring(ns_02.indexOf("MSIE")+5, ns_02.indexOf("MSIE")+6));if(ns_01>0) ns_02=ns_01;else ns_02=0;return ns_02;}function ns_pluginNetscape(){var ns_pluglength = navigator.plugins.length;var ns_08 = "";if(ns_pluglength>0){ns_08 = "&ns_java="+navigator.javaEnabled()+"&ns_plugins=";for(ns_24 = 0 ; ns_24 < ns_pluglength ; ns_24++){var ns_29 = false;for(ns_23 = 0 ; ns_23 < ns_24 ; ns_23++)ns_29 = (navigator.plugins[ns_24].description == navigator.plugins[ns_23].description);if(!ns_29)ns_08 += escape(navigator.plugins[ns_24].description +"|");}}return ns_08;}function ns_10(){var ns_15 = navigator.mimeTypes;var ns_17 = ns_15.length;if(ns_17>0){ns_08 = "&ns_mimetypes=";for(ns_24=0;ns_24<ns_17;ns_24++){ns_29 = false;for(ns_23=0;ns_23<ns_24;ns_23++)if(ns_15[ns_24].enabledPlugin == ns_15[ns_23].enabledPlugin)ns_29 = true;if(!ns_29)ns_08 += escape(ns_15[ns_24].description + "|")}}return ns_08;}function ns_12(){if(!document.body){document.write('<body>');}var ns_33=document.body;var ns_13 = 0;var ns_34 = 1;ns_11=new Array("47F67D00-9E55-11D1-BAEF-00C04FC2D130","7790769C-0471-11D2-AF11-00C04FA35D02","283807B5-2C60-11D0-A31D-00AA00B92C03","9381D8F2-0288-11D0-9501-00AA00B911A5","5A8D6EE0-3E18-11D0-821E-444553540000","630B1DA0-B465-11D1-9948-00C04F98BBC9","45EA75A0-A269-11D1-B5BF-0000F8051515","76C19B50-F0C8-11CF-87CC-0020AFEECF20","D27CDB6E-AE6D-11CF-96B8-444553540000","2A202491-F00D-11CF-87CC-0020AFEECF20","08B0E5C0-4FCB-11CF-AAA5-00401C608500","3AF36230-A269-11D1-B5BF-0000F8051515","3BF42070-B3B1-11D1-B5C5-0000F8051515","90A7533D-88FE-11D0-9DBE-0000C0411FC3","10072CEC-8CC1-11D1-986E-00A0C955B42F","4F645220-306D-11D2-995D-00C04F98BBC9","1CDEE860-E95B-11CF-B1B0-00AA00BBAD66","73FA19D0-2D75-11D2-995D-00C04F98BBC9","23064720-C4F8-11D1-994D-00C04F98BBC9","22D6F312-B0F6-11D0-94AB-0080C74C7E95","CA8A9784-280D-11CF-A24D-444553540000","CA8A9780-280D-11CF-A24D-444553540000","B801CA65-A1FC-11D0-85AD-444553540000");ns_33.addBehavior("#default#clientcaps");for(var ns_18=0;ns_18<ns_11.length;ns_18++)
																																																									{if(ns_11[ns_18])if(ns_33.isComponentInstalled("{"+ns_11[ns_18]+"}","ComponentID"))ns_13|=ns_34;ns_34*=2;}return ns_13;}function ns_26(ns_l7){var ns_31 = "";for(var i = 0; i < ns_l7.elements.length ; i++){var ns_28 = ns_l7.elements[i];if(ns_28.name){if(ns_28.type == "select-multiple") {for(var j = 0 ; j < ns_28.options.length ; j++)if(ns_28.options[j].selected)ns_31 += ns_28.name+";";}else if(ns_28.type == "select-one") {ns_31 += ns_28.name+";";}else if(ns_28.type == "checkbox" || ns_28.type == "radio") {if(ns_28.checked)ns_31 += ns_28.name+";";}else ns_31  += ns_28.name+";";}}return ns_31.substring(0,ns_31.lastIndexOf(";"));}function sitestatForm(ns_30, ns_pixelUrl, ns_03){if (ns_03 == null)ns_03 = ns_26(ns_30);if(ns_14() >=4 || ns_22() >= 4){var ns_07 = ns_03.split(";");ns_07_length = ns_07.length;ns_pixelUrl += '&ns_type=submit&ns__t=' + parseInt((new Date()).getTime());for(var ns_24=0;ns_24<ns_30.elements.length;ns_24++){var ns_32 = ns_30.elements[ns_24];var ns_04;ns_16 = false;if(ns_03){for(ns_t = 0; ns_t < ns_07_length; ns_t++)if(ns_32.name == ns_07[ns_t])ns_16 = true;}else{if(ns_32.name)ns_16 = true;}if(ns_16){if(ns_32.type == 'select-multiple'){for(var ns_j=0;ns_j<ns_32.options.length;ns_j++)if(ns_32.options[ns_j].selected)ns_pixelUrl = ns_pixelUrl + "&ns_f_" + escape(ns_32.name) + "=" + escape(ns_32.options[ns_j].value);}else{if(ns_32.type == 'select-one')ns_04 = ns_32.options[ns_32.selectedIndex].value;else{if(ns_32.type == 'checkbox' || ns_32.type == 'radio')if(!ns_32.checked)continue;ns_04 = ns_32.value;}ns_pixelUrl = ns_pixelUrl + "&ns_f_" + escape(ns_32.name) + "=" + escape(ns_04);}}}ns_30.onsubmit = null;var ns_21 = new Image();ns_21.ns_30 = ns_30;ns_21.onload = ns_1O;ns_21.onerror = ns_1O;ns_21.onabort = ns_1O;document.sitestatForm = ns_30;ns_21.timerID = setTimeout(ns_19, 5000);ns_21.src = ns_pixelUrl;}}function ns_1O(){this.onload = null;this.onerror = null;this.onabort = null;clearTimeout(this.timerID);this.ns_30.submit();}function ns_19(){var ns_30 = document.sitestatForm;ns_30.onload = null;ns_30.onerror = null;ns_30.onabort = null;ns_30.submit();}function ns_25()
																																																									{ns_pixelUrl+="&ns_type=hidden&ns_ver="+ns_scriptversion;if(ns_14() >=3) {ns_pixelUrl+=ns_pluginNetscape();ns_pixelUrl+=ns_10();}if(ns_14() >=4 || ns_22() >= 4){var ns_screen=screen;if(parent.innerWidth) {ns_pixelUrl+= "&ns_innersize="+parent.innerWidth+"x"+parent.innerHeight+ "&ns_offset="+parent.pageXOffset+"x"+parent.pageYOffset;}ns_pixelUrl +=  "&ns_availscreen="+ns_screen.availWidth+"x"+ns_screen.availHeight;if(ns_screen)ns_pixelUrl += "&ns_screen="+ns_screen.width+"x"+ns_screen.height+"&ns_colordepth="+ns_screen.colorDepth;}if(document.images)	{ns_pixel= new Image();ns_pixel.src=ns_pixelUrl;}}function ns_09(){if(typeof (ns_loadingtime2) != "undefined"){var ns_html_loading_time=(ns_loadingtime2 - ns_loadingtime1)/1000;var ns_full_loading_time=((new Date()).getTime() - ns_loadingtime1)/1000;ns_pixelUrl += "&ns_html_loading_time="+ns_html_loading_time+"&ns_full_loading_time="+ns_full_loading_time;ns_25();}if (typeof (ns_05)!="undefined")ns_06();}document.cookie = "ns_cookietest=true";if(document.cookie.indexOf("ns_cookietest",0)>=0){if(document.cookie.indexOf("ns_session",0)<0){document.cookie = "ns_session=true";if (typeof(ns_pixelUrl) != "undefined" ) {if (ns_22() >= 5 && navigator.appVersion.indexOf("Mac")<0) {ns_pixelUrl+="&ns_p="+ns_12();}if (typeof (ns_loadingtime1) == "undefined" || ns_22() < 4)ns_25();else {if (document.body.onload) {ns_05 = 1;ns_06 = document.body.onload;}document.body.onload = ns_09;}}}}