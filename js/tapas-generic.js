//This JS made possible by the great work done in teibp/js/teibp.js
function clearPageBreaks(){
	jQuery(".tapas-generic pb").css("display","none");
	jQuery(".tapas-generic .-teibp-pb").css("display","none");
}

function addPageBreaks(){
	console.log("in add page breaks");
    if (Tapas.currentTheme == 'diplomatic') {
    	jQuery(".tapas-generic pb").css("display","block");
    	jQuery(".tapas-generic .-teibp-pb").css("display","block");
    } else {
    	jQuery(".tapas-generic pb").css("display","inline");
    	jQuery(".tapas-generic .-teibp-pb").css("display","inline");
    }
}

function initialize_tapas_g(){
	jQuery('.tapas-generic #pbToggle').click( function(){
		if(jQuery(this).is(':checked')){
			clearPageBreaks();
			Tapas.showPbs = false;
		}else{
			addPageBreaks();
			Tapas.showPbs = true;
		}
	});
	addPageBreaks();
	jQuery(this).checked = false;
	if (jQuery("#TOC").length > 0){
		var toc = jQuery('#TOC').offset().top;
		jQuery(window).scroll(function() {
			var toc = jQuery('#TOC').offset().top;
		  fixTOC(toc);
		});
		jQuery(window).resize(function(){
			fixTOC();
		})
	}
}

function fixTOC(toc){
	if (jQuery(window).width() > 1000){
		var currentScroll = jQuery(window).scrollTop();
		if (currentScroll >= toc) {
        var navbarHeight = jQuery("#navbar").height();
        var readerWidth = jQuery(".reader_tapas_generic").width();
				jQuery('#TOC').css({
            position: 'fixed',
						top: navbarHeight === null ? '0' : navbarHeight + 40,
						width: readerWidth === null ? '25%' : readerWidth * .25 - 15,
						height: jQuery(window).height() - jQuery("#navbar").height() - 40
				});
		} else {
			jQuery('#TOC').css({
					position: 'static'
			});
		}
	} else {
		jQuery('#TOC').css({
				position: 'static',
				top: 'auto',
				width: '100%',
				height: 'auto'
		});
	}
}

jQuery(document).ready(function(){
	initialize_tapas_g();
});

function switchTapasThemes(event) {
	jQuery(".tapas-generic").removeClass('diplomatic').removeClass('normal').addClass(jQuery(event.target).val());
	Tapas.currentTheme = jQuery(event.target).val();
}

function showFacs(num, url, id) {
	console.log("showing facs for num:"+num+" , url:"+url+", id:"+id);
	jQuery(".tapas-generic").append('<div class="modal fade" id="modal_'+id+'"><div class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></div><div class="modal-body"><img src="'+url+'" id="resizable_'+id+'" class="img-resizable ui-widget-content"/></div></div><!-- /.modal-content --></div><!-- /.modal-dialog --></div><!-- /.modal -->');
	jQuery("#modal_"+id).modal('show');
	jQuery("#resizable_"+id).resizable({minWidth: 150});
}
