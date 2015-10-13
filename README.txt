See ~/Documents/tapas/profiling/README.txt for some comments on the
null-terminated record handling.


For current (2015-10-12) system (which uses 2 XSLT 1.0 pgms), use the
following to generate complete HTML output of all profiling and data.

  $ cd ~/Documents/tapas-xq/resources/tapas-generic
  $ time find ~/Documents/tapas/profiling/data -name '*.xml' -print0 | egrep -Zz '/.*/' | egrep -Zzv 'tei-xsl' | while read -d $'\0' f; do echo "---------$f:" ; OUT=OUT/`basename "${f}" .xml`.html; time ( xsltproc tei2html_1.xsl "${f}" > /tmp/TMP.xml ; xsltproc --stringparam fullHTML true tei2html_2.xsl /tmp/TMP.xml > "$OUT" ) ; done

Takes about 7.8 mins from within emacs on my home machine.

---------

To generate a single directory with all the desired XML files w/o 
hierarchy, issue
 $ mkdir /tmp/IN/
 $ time find ~/Documents/tapas/profiling/data -name '*.xml'  -print0 | egrep -Zz '/.*/' | egrep -Zzv 'tei-xsl' | while read -d $'\0' f; do g=`echo "$f" | perl -pe 's, ,_,g;'`; cp "$f" /tmp/IN/`basename $g` ; done

Note that this currently works because the one and only duplicate name
(alexander.xml) is also a duplicate file. :-)
