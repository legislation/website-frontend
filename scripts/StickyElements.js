$(function () {
  var Controller = new ScrollMagic.Controller();
  var cookieBarScene = CookieBarScene();
  // var brexitScenario = BrexitScenarioScene();


  Controller.addScene(cookieBarScene);
  // Controller.addScene(brexitScenario.scene);


  function CookieBarScene() {
    var cookiebarSel = '#cookie-law-info-bar';
    var $cookiebarDeleteBtn = $(cookiebarSel).find('#cookie_action_close_header');
  
    var cookiebar = new ScrollMagic.Scene({
      triggerElement: cookiebarSel,
      triggerHook: 'onLeave'
    });
  
    cookiebar.setPin(cookiebarSel);

    // Effectively removing the cookiebar
    $cookiebarDeleteBtn.click(function(e) {
      cookiebar.destroy(true);
    });
    
    return cookiebar;
  }

  function BrexitScenarioScene() {
    var brexitScenarioBannerSel = '#brexit-scenario-banner';
    var offsetTargets = ['#cookie-law-info-bar']; 
    var defaultOffset = 0;
    var additionalOffset = calculateAdditionalOffset(offsetTargets);
    var calculatedOffset = defaultOffset + additionalOffset;

    initaliseDOM();
  
    var brexitScenarioBanner = new ScrollMagic.Scene({
      offset: calculatedOffset,
      triggerElement: brexitScenarioBannerSel,
      triggerHook: 'onLeave'
    });
  
    brexitScenarioBanner.setPin(brexitScenarioBannerSel);
  
    return {
      scene: brexitScenarioBanner,
      offset: {
        current: calculatedOffset,
        addition: additionalOffset
      }
    };

    function initaliseDOM() {
      // In the site-width styelsheet, 'screen.css', the element '#contentSearch' has 
      // a 'z-index' property set to '38990'. 
      // Without adding it to banner as seen below, the banner hides behind '#contentSearch'
      $(brexitScenarioBannerSel).css('z-index', 38990);
    }
  }


  // ==========================
  // EVENT HANDLERS
  // ==========================


  cookieBarScene.on('destroy', function(e) {
    // console.log('Removing the Cookie Banner...', e);
    
    // resetOffset(brexitScenario.scene, brexitScenario.scene.offset(), brexitScenario.offset.addition);
  });



  // ==========================
  // UTILITIES
  // ==========================

  /**
   * This will return a negated value which represents the amount
   * by which to push down a pinned element at initialisation
   * 
   * @param {Array} target This is set to be an array to account for instances where 
   * calculating the offset of more than one element is desired
   */
  function calculateAdditionalOffset(target) {
    var additionalHeight = 0;

    var targetString = target.join(',');
    var $target = $(targetString);


    $target.each(function(i,element) {
      // console.log('target.', element.offsetHeight);
      additionalHeight += element.offsetHeight;
    });
    
    if (additionalHeight > 0) {
      // console.log('cumulative.', additionalHeight, targetString);
    }

    return -additionalHeight;
  }

/**
 * 
 * @param {ScrollMagic.Scene} scene 
 * @param {Number} currentOffset Current offset of the scene
 * @param {Number} excessOffset an output from calculateAdditionalOffset()
 * 
 * Resets the offset of a scene.
 */
  function resetOffset(scene, currentOffset, excessOffset) {
    scene.offset(currentOffset - excessOffset);
    scene.update(true);
    // console.log('current.', currentOffset);
    // console.log('additional atm.', excessOffset);
    // console.log('refreshed.', scene.offset());
  }

});