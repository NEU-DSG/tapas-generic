/*  Create a TAPAS-specific namespace by applying the TAPAS object to a 
    self-invoking function wrapper containing all the functions which need to 
    be namespaced. */
var Tapas = {};

(function() {
  
  /*  PUBLIC FUNCTIONS
      By assigning public functions to static 'this', the TAPAS namespace can 
      be applied to them without unnecessary duplication.
  */

  this.displayNoteData = function(e) {
      var html = '';
      var target = $(e.target);
      var coords = [e.pageX, e.pageY];
      var tapasNoteNum = target.text();
      var note = $(".tapas-generic note[data-tapas-note-num = '" + tapasNoteNum + "']");
      html = note.html();
      refreshDialog(html, target, coords);
      console.log("note data is: " + html);
  };

  //Set up an object to help deal with the needs of negotiating through the document-database
  this.displayRefData = function(e) {
      var html = '';
      var target = e.target;
      var ref = $(target).attr('ref');
      console.log("ref is "+ref);
      while (typeof ref == "undefined") {
          var target = target.parentNode;
          ref = $(target).attr('ref');
      }
      var coords = [e.clientX, e.clientY];

      var aTarget = findATarget(ref);

      console.log(aTarget);
      console.log("aTarget length is "+ aTarget.length);
      if (  aTarget.length !== 0  ) {
          //bop back up to the enclosing p@class='contextualItem'. it looks like that's the most reliable container
          //var parentTarget = aTarget.parent("[class='contextualItem']");
        
          //new version, go to the parent div
          //var parentTarget = aTarget.parent("div");
          //console.log(parentTarget);
          //if (aTarget) {
              //html += "<p class='tei-element'>TEI element: " + e.target.nodeName + "</p>";
              html += aTarget.children('div.og-entry').html();
              //console.log("ref data is " + html);
            
              //send the parentTarget (the ography element to the dialog so it can
              //dig up the identifier text
              refreshDialog(html, aTarget, coords);
          /*} else {
              console.log('failed finding target');
          }*/
      } else {
          console.log('no aTarget!');
      }
  };
  
  this.showFacs = function(num, url, id) {
    console.log("showing facs for num:"+num+" , url:"+url+", id:"+id);
    $(".tapas-generic").append(
      '<div class="modal fade" id="modal_'+id+'">'
      + '<div class="modal-dialog">'
        + '<div class="modal-content">'
          + '<div class="modal-header">'
            + '<button type="button" class="close" data-dismiss="modal" aria-label="Close">'
              + '<span aria-hidden="true">&times;</span>'
            + '</button>'
          + '</div>'
          + '<div class="modal-body">'
            + '<img src="'+url+'" id="resizable_'+id+'" class="img-resizable ui-widget-content" />'
          + '</div>'
        + '</div><!-- /.modal-content -->'
      + '</div><!-- /.modal-dialog -->'
    + '</div><!-- /.modal -->'
    );
    $("#modal_"+id).modal('show');
    $("#resizable_"+id).resizable({ minWidth: 150 });
  };
  
  
  /*  PRIVATE FUNCTIONS
      Private functions are assigned to declared variables, so that they can be 
      easily referenced from within the anonymous object by the public 
      functions and each other. These variables only work within this scope, so 
      they aren't publicly available.
  */
  
  var findATarget = function(ref) {
      var aTarget = $("[id='" + ref + "']");

      if ( aTarget.length != 0 ) {
          return aTarget;
      }
      // ref = ref.replace('#', '');
      ref = ref.split('#');
      ref = ref[1];
      aTarget = $("[id='" + ref + "']");

      if ( aTarget.length != 0 ) {
          return aTarget;
      }

      //try using the fancy character
      aTarget = $("[id='Ћ." + ref + "']");
      console.log("[id='Ћ." + ref + "']");
      return aTarget;
  };
  
  var linkifyExternalRef = function(el) {
    var aEl = document.createElement('a');
    $(aEl).text($(el).text());
    $(el.attributes).each(function(index, att) {
        if(att.nodeName == 'ref') {
            aEl.setAttribute('href', att.nodeValue);
        } else {
            aEl.setAttribute(att.nodeName, att.nodeValue);
        }
    });
    return aEl;
  };

  var refreshDialog = function(html, target, coords) {
      $("#tapas-ref-dialog").dialog('close');
      var ogHeader = target.children('.heading-og'),
          headerTitle = ogHeader.length === 0 ? $(target).text() : $(ogHeader).text(),
          hasEntry = html.length > 0 || $(html).text() !== '',
          useTitle = hasEntry ? headerTitle : null,
          useHTML = hasEntry ? html : headerTitle;
      //console.log("tapas ref dialog text is '"+useHTML+"'");
      // Set the position of the dialog.
      $('#tapas-ref-dialog').dialog('option', 'position', {
        my:"left top",
        at: "left+50 top",
        of: window
      });
      //console.log(target);
      $("#tapas-ref-dialog").html(useHTML);
      $("#tapas-ref-dialog").dialog( "option", "title", useTitle);
      $("#tapas-ref-dialog").dialog('open');
  };

  var rewriteExternalRefs = function() {
    var externalRefNodes = $(".tapas-generic [ref*='http']");
    externalRefNodes.each(function(index, el) {
       $(el).addClass('external-ref').unbind('mouseover');
       //$(el).replaceWith(Tapas.linkifyExternalRef(el));
    });
  };
  
}).apply(Tapas); // Inject the TAPAS namespace into the anonymous object.


// Slap on the events/eventHandlers
$(document).ready(function() {
  //Tapas.addPageBreaks();
  var refs = $(".tapas-generic [ref]");
  refs.click(Tapas.displayRefData);
  var notes = $(".tapas-generic [class='note-marker']");
  notes.click(Tapas.displayNoteData);
  //Tapas.rewriteExternalRefs();
  Tapas.notes = notes;
  Tapas.refs = refs; // not sure yet if we'll need this data on the Tapas object
  // Figure out what the starting view is for the TEI document. The default is 'diplomatic'.
  if ( $('.tapas-generic').hasClass('normal') ) {
    Tapas.currentTheme  = 'normal';
  } else {
    Tapas.currentTheme  = 'diplomatic';
    if ( !$('.tapas-generic').hasClass('diplomatic') ) {
      $(".tapas-generic").addClass('diplomatic');
    }
  }
  Tapas.showPbs = true;
  // Initialize the dialog, which is handled by Tapas.displayRefData
  $("#tapas-ref-dialog").dialog({autoOpen: false});
});
