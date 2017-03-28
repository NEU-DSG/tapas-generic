See ~/Documents/tapas/profiling/README.txt for some comments on the
null-terminated record handling.


Since I don't currently use `xmlsh`, or an ant task, or eXist, or an
oXygen mutli-file scenario, or some other mechanism of running `saxon`
multiple times with one load of the Java VM, it is orders of magnitude
faster to run this on a single large directory of input files rather
than on a series of individual files. So, to test it on *all* the test
input I have
 1) Create a single flat directory with the XML files
 2) Run `saxon` on the entire dir.
Note that the output directory goes in this directory so that relative
pointers to CSS and JS work. (No need to check-in that output dir,
though.) 

--------- (1) ---------

 $ cd ~/Documents/tapas-generic/
 $ rm -fr /tmp/IN/; mkdir /tmp/IN/
 $ rm -fr OUT/*

Then, to generate a single directory with all the in vivo XML files w/o 
hierarchy:
 $ time find ~/Documents/tapas/profiling/data -name '*.xml'  -print0 | egrep -Zz '/.*/' | egrep -Zzv 'tei-xsl' | while read -d $'\0' f; do g=`echo "$f" | perl -pe 's, ,_,g;'`; cp "$f" /tmp/IN/`basename $g` ; done

Note that this currently works because the one and only duplicate name
(alexander.xml) is also a duplicate file. :-)

Or, to generate a single directory with all the in vitro XML files:

 $ cp -pr ~/Documents/tapas/rendering/data/test0*.xml /tmp/IN/
 $ cp -pr ~/Documents/tapas/rendering/data/test06_page_images /tmp/IN/

--------- (2) ---------

 $ cd ~/Documents/tapas-generic/
 $ time saxon -xsl:tei2html.xslt -s:/tmp/IN/ -o:OUT/ fullHTML=true
 $ # either change names in Emacs, or use:
 $ for f in OUT/*.xml ; do mv $f `dirname $f`/`basename $f .xml`.xhtml ; done


---------
For previous XSLT 1.0 system (i.e., pre 2015-10-12), use the following
to generate complete HTML output of all profiling and data.

  $ cd ~/Documents/tapas-xq/resources/tapas-generic
  $ time find ~/Documents/tapas/profiling/data -name '*.xml' -print0 | egrep -Zz '/.*/' | egrep -Zzv 'tei-xsl' | while read -d $'\0' f; do echo "---------$f:" ; OUT=OUT/`basename "${f}" .xml`.html; time ( xsltproc tei2html_1.xsl "${f}" > /tmp/TMP.xml ; xsltproc --stringparam fullHTML true tei2html_2.xsl /tmp/TMP.xml > "$OUT" ) ; done

Takes about 7.8 mins from within emacs on my home machine.

