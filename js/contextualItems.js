var Tapas = {};

Tapas.findATarget = function(ref) {
    var aTarget = $(".tapas-generic a[id='" + ref + "']");

    if(aTarget.length !=0 ) {
        return aTarget;
    }
    ref = ref.replace('#', '');
    aTarget = $(".tapas-generic a[id='" + ref + "']");

    if(aTarget.length !=0 ) {
        return aTarget;
    }

    //try using the fancy character
    aTarget = $(".tapas-generic a[id='Ћ." + ref + "']");
    console.log(".tapas-generic a[id='Ћ." + ref + "']");
    return aTarget;
}

//Set up an object to help deal with the needs of negiating through the document-database
Tapas.displayRefData = function(e) {
    var html = '';
    var target = e.target;
    var ref = $(target).attr('ref');
    while (typeof ref == "undefined") {
        var target = target.parentNode;
        ref = $(target).attr('ref');
    }
    var coords = [e.clientX, e.clientY];

    var aTarget = Tapas.findATarget(ref);

    console.log(aTarget);
    if(aTarget.length != 0  ) {
        //bop back up to the enclosing p@class='contextualItem'. it looks like that's the most reliable container
        //var parentTarget = aTarget.parent("[class='contextualItem']");

        //new version, go to the parent div
        var parentTarget = aTarget.parent("div");
        if(parentTarget) {
            //html += "<p class='tei-element'>TEI element: " + e.target.nodeName + "</p>";
            //desperate effort to produce a consistent, non-code duplicating way to build HTML for the info dialog
            html += Tapas.ographyToHtml(parentTarget);

            //send the parentTarget (the ography element to the dialog so it can
            //dig up the identifier text
            Tapas.refreshDialog(html, parentTarget, coords);
        } else {
            console.log('failed finding target');
        }
    } else {
        console.log('no aTarget!');
    }
}

Tapas.refreshDialog = function(html, target, coords) {
    $("#tapas-ref-dialog").dialog('close');
    $("#tapas-ref-dialog").html(html);
    //placing the dialog for data display in the big white space currently there. Adjust position via jQueryUI rules for different behavior
    $("#tapas-ref-dialog").dialog( "option", "position", { my: "right top+"+coords[0]/2, at: "right top+"+coords[0]/2, of: window });

    var identifierEl = target.children('p.identifier');
    if(identifierEl.length == 0) {
        //dialog title by mouseovered text, where the mouseovered element is passed as target, usually a note
        $("#tapas-ref-dialog").dialog( "option", "title", $(target).text());
    } else {
        //dialog title by identifier, usually an ography
        $("#tapas-ref-dialog").dialog( "option", "title", $(identifierEl).text());
    }
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
}

Tapas.displayRefNoteData = function(e) {
    var html = '';
    var target = $(e.target);
    var href = target.attr('href');
    if (typeof href != 'undefined' && href.charAt(0) == '#') {
        var noteId = href.substring(1);
        var note = $(".tapas-generic note#" + noteId);
        html = note.html();
        var noteType = note.attr('type');
        var noteNumber = note.data('tapas-note-num');
        if (typeof noteType == 'undefined') {
            noteType = '';
        } else {
            noteType = noteType.charAt(0).toUpperCase() + noteType.slice(1);
        }
        var dialogTitle = noteType + " Note " + noteNumber;
        var notePlace = note.attr('place');
        if (typeof notePlace != 'undefined') {
            html += "<p>Original Location: " + notePlace + "</p>";
        }

        //works slightly differently from the other notes, so sad duplication of Tapas.refreshDialog here
        $("#tapas-ref-dialog").dialog('close');
        $("#tapas-ref-dialog").html(html);
        //placing the dialog for data display in the big white space currently there. Adjust position via jQueryUI rules for different behavior
        $("#tapas-ref-dialog").dialog( "option", "position", { my: "right top+"+coords[0]/2, at: "right top+"+coords[0]/2, of: window });
        $("#tapas-ref-dialog").dialog( "option", "title", dialogTitle);
        $("#tapas-ref-dialog").dialog('open');

    }
}

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

/**
 * Produce the HTML to stuff into the modal (popup) for displaying more data
 * Branch around the "ography" type passed in to get to the right nodes, and the right data within them
 *
 * Currently this is half-built. it might be abandoned, depending on the needs and complexit for data display in the modal
 */

Tapas.ographyToHtml = function(ography) {
    //designers will want to watch the classes assigned here. dialog, ography, and ographyType to customize the jQueryUi elements
    //themeroller might be our friend here
    var wrapperHtml = "<div class='wrapper dialog ography '>";

    var html = '';
    var children = ography.children("[data-tapas-label]");
    children.each(function(index, child) {
        switch($(child).data('tapasLabel')) {

            default:
                var childHtml = $(child).html();
                if(childHtml) {
                    html += "<p>" + "<span class='ography-data'>" + $(child).data('tapasLabel') + ": </span> " + childHtml + "</p>";
                }
            break;
        }
    });
    if(html == '') {
        html = "<p>No additional data</p>";
    }
    return wrapperHtml + html + "</div>";
}

Tapas.closeDialog = function() {
   $("#tapas-ref-dialog").dialog('close');
}

Tapas.findOgraphyType = function(ography) {
    //console.log(ography);
}

//Slap on the events/eventHandlers

$(document).ready(function() {
   var refs = $(".tapas-generic [ref]");
   refs.mouseover(Tapas.displayRefData);
   var notes = $(".tapas-generic [class='note-marker']");
   notes.mouseover(Tapas.displayNoteData);
   var refNotes = $(".tapas-generic a.ref-note");
   refNotes.mouseover(Tapas.displayRefNoteData);
   //Tapas.rewriteExternalRefs();
   Tapas.notes = notes;
   Tapas.refs = refs; // not sure yet if we'll need this data on the Tapas object
   Tapas.currentTheme = 'diplomatic';
   $(".tapas-generic").addClass('diplomatic');
   Tapas.showPbs = true;
   $("#tapas-ref-dialog").dialog({autoOpen: false}); //initialize the dialog, placing and data in it handled by Tapas.displayRefData
   $("#viewBox").change(function(e){
     switchThemes(e);
   });
});
