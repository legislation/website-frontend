/* -------------------------------------------------------------------------
 *
 * COOKIE DIRECTIVE
 *
 * Display cookie directive banner
 *
 * -------------------------------------------------------------------------
 */
$(function(){
  // (function($){
      var linkHref = $("#cookies-content-link").attr("href"),
      a = '<div id="cookie-law-info-bar"><span>legislation.gov.uk uses cookies to make the site simpler. <a href=\"#\" id=\"cookie_action_close_header\" class=\"medium cli-plugin-button cli-plugin-main-button\">Got it</a> <a href=\"' + linkHref + '\" id=\"CONSTANT_OPEN_URL\" class=\"cli-plugin-main-link\"  >Find out more about cookies</a></span></div>',
      b = '{"animate_speed_hide":"500","animate_speed_show":"500","background":"","border":"","border_on":"false","button_1_button_colour":"","button_1_button_hover":"","button_1_link_colour":"","button_1_as_button":false,"button_2_button_colour":"","button_2_button_hover":"","button_2_link_colour":"","button_2_as_button":false,"font_family":"","notify_animate_hide":true,"notify_animate_show":false,"notify_div_id":"#cookie-law-info-bar","notify_position_horizontal":"right","notify_position_vertical":"top","showagain_tab":false,"showagain_background":"","showagain_border":"","showagain_div_id":"#cookie-law-info-again","showagain_x_position":"100px","text":""}';
      cli_show_cookiebar(a,b);
  // })(jQuery);
});

