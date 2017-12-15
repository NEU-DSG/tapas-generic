/*  Create a TAPAS-specific namespace by applying the TAPAS object to a 
    self-invoking function wrapper containing all the functions which need to 
    be namespaced. */
var Tapas = {};

(function() {
  
  var context = this, /*  This variable references the current scope so it can 
                          be referenced within functions where the scope changes 
                          (generally event handlers). */
      isVerbose = false,
      validThemes = ['diplomatic', 'normal'],
      currentTheme = 'diplomatic',
      dialogPos = {
        my:"left top",
        at: "left+50 top",
        of: window
      };
  
  /*  PUBLIC FUNCTIONS
      By assigning public functions to static 'this', the TAPAS namespace can 
      be applied to them without unnecessary duplication.
  */
  
  this.displayNoteData = function(e) {
      var html = '',
          target = $(e.target),
          coords = [e.pageX, e.pageY],
          tapasNoteNum = target.text(),
          note = $(".tapas-generic note[data-tapas-note-num = '" + tapasNoteNum + "']");
      html = note.html();
      refreshDialog(html, target, coords);
      if ( isVerbose ) console.log("note data is: " + html);
  };

  //Set up an object to help deal with the needs of negotiating through the document-database
  this.displayRefData = function(e) {
      var html = '',
          target = e.target,
          ref = $(target).attr('ref');
      if ( isVerbose ) console.log("ref is "+ref);
      while ( typeof ref == "undefined" ) {
        var target = target.parentNode;
        ref = $(target).attr('ref');
      }
      var coords = [e.clientX, e.clientY],
          aTarget = findATarget(ref);
      if ( isVerbose ) { 
        console.log(aTarget);
        console.log("aTarget length is "+ aTarget.length);
      }
      if ( aTarget.length !== 0 ) {
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
          console.warn('No aTarget!');
      }
  };
  
  this.getTheme = function() {
    return currentTheme;
  };
  
  this.setTheme = function(label) {
    var rmThemes = validThemes.join(" ");
    if ( validThemes.indexOf(label) !== -1 ) {
      currentTheme = label;
      $(".tapas-generic").removeClass(rmThemes).addClass(currentTheme);
      if ( isVerbose ) console.log('Set theme to '+ currentTheme);
    } else {
      console.error('Could not set invalid theme "'+ label +'"');
    }
    return this.getTheme();
  };
  
  this.showFacs = function(num, url, id) {
    if ( isVerbose ) console.log("showing facs for num:"+num+" , url:"+url+", id:"+id);
    $("#tapas-ref-dialog").dialog('close');
    if ( $("#facs_"+id).length === 0 ) {
      $(".tapas-generic").append(
        '<div id="facs_'+id+'">'
        + '<img src="'+url+'" id="resizable_'+id+'" class="img-resizable ui-widget-content"'
          + ' style="min-height: 30px; min-width: 30px;" />'
      + '</div>'
      );
      $("#facs_"+id).dialog();
      $("#facs_"+id).dialog('option', 'position', dialogPos);
    }
    $("#facs_"+id).dialog('open');
    $("#resizable_"+id).resizable({
      aspectRatio: true,
      containment: "parent",
      minWidth: 30
    });
  };
  
  this.switchThemes = function(e) {
    var newTheme = $(e.target).val();
    context.setTheme(newTheme);
  };
  
  /*  Get and toggle wordy console logs.  */
  this.getVerbosity = function() {
    return isVerbose;
  };
  this.toggleVerbosity = function() {
    isVerbose = isVerbose ? false : true;
    return this.getVerbosity();
  };
  
  
  /*  PRIVATE FUNCTIONS
      Private functions are assigned to declared variables, so that they can be 
      easily referenced from within the function wrapper by the public 
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
      if ( isVerbose ) console.log("[id='Ћ." + ref + "']");
      return aTarget;
  };
  
  var linkifyExternalRef = function(el) {
    var aEl = document.createElement('a');
    $(aEl).text($(el).text());
    $(el.attributes).each(function(index, att) {
        if ( att.nodeName === 'ref' ) {
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
      if ( isVerbose ) console.log("tapas ref dialog text is '"+useHTML+"'");
      // Set the position of the dialog.
      $('#tapas-ref-dialog').dialog('option', 'position', dialogPos);
      if ( isVerbose ) console.log(target);
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
  
}).apply(Tapas); // Inject the TAPAS namespace into the self-invoking function.


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
    Tapas.setTheme('normal');
  } else {
    //Tapas.setTheme('diplomatic');
    if ( !$('.tapas-generic').hasClass('diplomatic') ) {
      $(".tapas-generic").addClass('diplomatic');
    }
  }
  Tapas.showPbs = true;
  // Initialize the dialog, which is handled by Tapas.displayRefData
  $("#tapas-ref-dialog").dialog({autoOpen: false});
  // Change views when the user selects a different option.
  $(".tapas-generic #viewBox").change(Tapas.switchThemes);
});
