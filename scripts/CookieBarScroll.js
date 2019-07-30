$(function () {
  var cookiebarSel = '#cookie-law-info-bar';
  var $cookiebarDeleteBtn = $(cookiebarSel).find('#cookie_action_close_header');

  var controller = new ScrollMagic.Controller();
  var scene = new ScrollMagic.Scene({
    triggerElement: cookiebarSel,
    triggerHook: 'onLeave'
  });

  scene.setPin(cookiebarSel);
  scene.addTo(controller);

  // Effectively removing the cookiebar
  $cookiebarDeleteBtn.click(function(e) {
    scene.destroy(true);
  });

});