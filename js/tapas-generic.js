//This JS made possible by the great work done in teibp/js/teibp.js

$(document).ready(function() {
  initializeTapasGeneric();
  
  // Initialize any tooltips.
  $('[data-tapas-tooltip]').tooltip({
    classes: { 'ui-tooltip': "ui-widget-shadow generic-tooltip" },
    content: function() {
      return $(this).data('tapasTooltip');
    },
    items: '[data-tapas-tooltip]', 
    position: { my: 'left+10 center+20' }
  });
  
  
  /*  FUNCTIONS  */

  function clearPageBreaks() {
    $(".tapas-generic pb").css("display","none");
    $(".tapas-generic .tapas-pb").css("display","none");
  }

  function initializeTapasGeneric() {
    /*$('.tapas-generic #pbToggle').click( function(){
      if($(this).is(':checked')){
        clearPageBreaks();
        Tapas.showPbs = false;
      }else{
        addPageBreaks();
        Tapas.showPbs = true;
      }
    });*/
    //$(this).checked = false;
    if ( $("#TOC").length > 0 ) {
      var toc = $('#TOC').offset().top;
    }
  }
});
