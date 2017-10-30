var Tapas = {};

Tapas.findATarget = function(ref) {
    var aTarget = $("[id='" + ref + "']");

    if(aTarget.length !=0 ) {
        return aTarget;
    }
    // ref = ref.replace('#', '');
    ref = ref.split('#');
    ref = ref[1];
    aTarget = $("[id='" + ref + "']");

    if(aTarget.length !=0 ) {
        return aTarget;
    }

    //try using the fancy character
    aTarget = $("[id='Ћ." + ref + "']");
    console.log("[id='Ћ." + ref + "']");
    return aTarget;
}

//Set up an object to help deal with the needs of negotiating through the document-database
Tapas.displayRefData = function(e) {
    var html = '';
    var target = e.target;
    var ref = $(target).attr('ref');
    console.log("ref is "+ref);
    while (typeof ref == "undefined") {
        var target = target.parentNode;
        ref = $(target).attr('ref');
    }
    var coords = [e.clientX, e.clientY];

    var aTarget = Tapas.findATarget(ref);

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
            Tapas.refreshDialog(html, aTarget, coords);
        /*} else {
            console.log('failed finding target');
        }*/
    } else {
        console.log('no aTarget!');
    }
}

Tapas.refreshDialog = function(html, target, coords) {
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
      at: "left+10 top",
      of: window
    });
    //console.log(target);
    $("#tapas-ref-dialog").html(useHTML);
    $("#tapas-ref-dialog").dialog( "option", "title", useTitle);
    $("#tapas-ref-dialog").dialog('open');
}

Tapas.displayNoteData = function(e) {
    var html = '';
    var target = $(e.target);
    var coords = [e.pageX, e.pageY];
    var tapasNoteNum = target.text();
    var note = $(".tapas-generic note[data-tapas-note-num = '" + tapasNoteNum + "']");
    html = note.html();
    Tapas.refreshDialog(html, target, coords);
    console.log("note data is: " + html);
}

// Tapas.displayRefNoteData = function(e) {
//     var html = '';
//     var target = $(e.target);
//     var href = target.attr('href');
//     if (typeof href != 'undefined' && href.charAt(0) == '#') {
//         var noteId = href.substring(1);
//         var note = $(".tapas-generic note#" + noteId);
//         html = note.html();
//         var noteType = note.attr('type');
//         var noteNumber = note.data('tapas-note-num');
//         if (typeof noteType == 'undefined') {
//             noteType = '';
//         } else {
//             noteType = noteType.charAt(0).toUpperCase() + noteType.slice(1);
//         }
//         var dialogTitle = noteType + " Note " + noteNumber;
//         var notePlace = note.attr('place');
//         if (typeof notePlace != 'undefined') {
//             html += "<p>Original Location: " + notePlace + "</p>";
//         }
//
//         //works slightly differently from the other notes, so sad duplication of Tapas.refreshDialog here
//         $("#tapas-ref-dialog").dialog('close');
//         $("#tapas-ref-dialog").html(html);
//         //placing the dialog for data display in the big white space currently there. Adjust position via jQueryUI rules for different behavior
//         $("#tapas-ref-dialog").dialog( "option", "position", { my: "right top+"+coords[0]/2, at: "right top+"+coords[0]/2, of: window });
//         $("#tapas-ref-dialog").dialog( "option", "title", dialogTitle);
//         $("#tapas-ref-dialog").dialog('open');
//         console.log("ref note data is " + html);
//     }
// }

Tapas.rewriteExternalRefs = function() {
    var externalRefNodes = $(".tapas-generic [ref*='http']");
    externalRefNodes.each(function(index, el) {
       $(el).addClass('external-ref').unbind('mouseover');
       //$(el).replaceWith(Tapas.linkifyExternalRef(el));
    });
}
Tapas.linkifyExternalRef = function(el) {
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
}

function initialize_tapas_generic(){
  var refs = $(".tapas-generic [ref]");
  refs.click(Tapas.displayRefData);
  var notes = $(".tapas-generic [class='note-marker']");
  notes.click(Tapas.displayNoteData);
  // var refNotes = $(".tapas-generic a.ref-note");
  // refNotes.mouseover(Tapas.displayRefNoteData);
  //Tapas.rewriteExternalRefs();
  Tapas.notes = notes;
  Tapas.refs = refs; // not sure yet if we'll need this data on the Tapas object
  Tapas.currentTheme = 'diplomatic';
  $(".tapas-generic").addClass('diplomatic');
  Tapas.showPbs = true;
  $("#tapas-ref-dialog").dialog({autoOpen: false}); //initialize the dialog, placing and data in it handled by Tapas.displayRefData
  $(".tapas-generic #viewBox").change(function(e){
    switchTapasThemes(e);
  });
}

// Slap on the events/eventHandlers

$(document).ready(function() {
  initialize_tapas_generic();
});
