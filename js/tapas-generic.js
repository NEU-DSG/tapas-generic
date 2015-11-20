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
	var toc = jQuery('#TOC').offset().top;
	fixTOC(toc);
	jQuery(window).scroll(function() {
	    fixTOC(toc);
	});
	jQuery(window).resize(function(){
			fixTOC(toc);
	})

}

function fixTOC(toc){
	if (jQuery(window).width() > 1000){
		var currentScroll = jQuery(window).scrollTop();
		if (currentScroll >= toc) {
				jQuery('#TOC').css({
						position: 'fixed',
						top: jQuery("#navbar").height() + 40,
						width: jQuery(".reader_tapas_generic").width() * .25 - 15,
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
	// facsWindow = window.open ("about:blank")
	// facsWindow.document.write("<html>")
	// facsWindow.document.write("<head>")
	// facsWindow.document.write("<title>TEI Boilerplate Facsimile Viewer</title>")
	// facsWindow.document.write(jQuery('#maincss')[0].outerHTML)
	// facsWindow.document.write(jQuery('#customcss')[0].outerHTML)
	// facsWindow.document.write("<link rel='stylesheet' href='../js/jquery-ui/themes/base/jquery.ui.all.css'>")
	// facsWindow.document.write(jQuery('style')[0].outerHTML)
	// facsWindow.document.write("<script type='text/javascript' src='../js/jquery/jquery.min.js'></script>")
	// facsWindow.document.write("<script type='text/javascript' src='../js/jquery-ui/ui/jquery-ui.js'></script>")
	// facsWindow.document.write("<script type='text/javascript' src='../js/jquery/plugins/jquery.scrollTo-1.4.3.1-min.js'></script>")
	// facsWindow.document.write("<script type='text/javascript' src='../js/teibp.js'></script>")
	// facsWindow.document.write("<script type='text/javascript'>")
	// facsWindow.document.write("jQuery(document).ready(function() {")
	// facsWindow.document.write("jQuery('.facsImage').scrollTo(jQuery('#" + id + "'))")
	// facsWindow.document.write("})")
	// facsWindow.document.write("</script>")
	// facsWindow.document.write("<script>	jQuery(function() {jQuery( '#resizable' ).resizable();});</script>")
	// facsWindow.document.write("</head>")
	// facsWindow.document.write("<body>")
	// facsWindow.document.write(jQuery("teiHeader")[0].outerHTML)
	// //facsWindow.document.write("<teiHeader>" + jQuery("teiHeader")[0].html() + "</teiHeader>")
	// //facsWindow.document.write(jQuery('<teiHeader>').append(jQuery('teiHeader').clone()).html();)
	//
	// //facsWindow.document.write(jQuery("teiHeader")[0].outerHTML)
	// facsWindow.document.write("<div id='resizable'>")
	// facsWindow.document.write("<div class='facsImage'>")
	// jQuery(".-teibp-thumbnail").each(function() {
	// 	facsWindow.document.write("<img id='" + jQuery(this).parent().parent().parent().attr('id') + "' src='" + jQuery(this).attr('src') + "' alt='facsimile page image'/>")
	// })
	// facsWindow.document.write("</div>")
	// facsWindow.document.write("</div>")
	// facsWindow.document.write(jQuery("footer")[0].outerHTML)
	//
	// facsWindow.document.write("</body>")
	// facsWindow.document.write("</html>")
	// facsWindow.document.close()
}
