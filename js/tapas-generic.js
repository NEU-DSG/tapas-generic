//This JS made possible by the great work done in teibp/js/teibp.js

$(document).ready(function(){
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

  function addPageBreaks() {
    console.log("in add page breaks");
    if (Tapas.currentTheme == 'diplomatic') {
      $(".tapas-generic pb").css("display","block");
      $(".tapas-generic .-teibp-pb").css("display","block");
    } else {
      $(".tapas-generic pb").css("display","inline");
      $(".tapas-generic .-teibp-pb").css("display","inline");
    }
  }

  function clearPageBreaks() {
    $(".tapas-generic pb").css("display","none");
    $(".tapas-generic .-teibp-pb").css("display","none");
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
    addPageBreaks();
    $(this).checked = false;
    if ( $("#TOC").length > 0 ) {
      var toc = $('#TOC').offset().top;
    }
    $(".tapas-generic #viewBox").change(function(e){
      switchTapasThemes(e);
    });
  }

  function showFacs(num, url, id) {
    console.log("showing facs for num:"+num+" , url:"+url+", id:"+id);
    $(".tapas-generic").append(
      '<div class="modal fade" id="modal_'+id+'"><div class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></div><div class="modal-body"><img src="'+url+'" id="resizable_'+id+'" class="img-resizable ui-widget-content"/></div></div><!-- /.modal-content --></div><!-- /.modal-dialog --></div><!-- /.modal -->');
    $("#modal_"+id).modal('show');
    $("#resizable_"+id).resizable({minWidth: 150});
  }

  function switchTapasThemes(event) {
    var newTheme = $(event.target).val();
    $(".tapas-generic").removeClass('diplomatic').removeClass('normal').addClass(newTheme);
    Tapas.currentTheme = newTheme;
    console.log(newTheme);
  }
});
