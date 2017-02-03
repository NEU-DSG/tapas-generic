<xsl:stylesheet version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:eg="http://www.tei-c.org/ns/Examples"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:tps="http://tapas.northeastern.edu"
  xmlns:wfn="http://www.wwp.northeastern.edu/ns/functions"
  exclude-result-prefixes="#all">
  
  <xsl:import href="ography.xsl"/>

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> 2013-10-12 by Syd Bauman, based
      very heavily on the previous 'tei2html_1' and 'tei2html_2', which
      were (together) an XSLT 1.0 version of this program. The first of
      those was heavily based on 'teibp.xsl' (part of TEI Bolerplate) by
      John A. Walsh</xd:p>
      <xd:p>TEI to HTML for TAPAS generic: Copies a TEI document, with a very
      few modifications into an HTML 5 shell, which provides access to
      javascript and other features from the html/browser environment.</xd:p>
      <xd:p><xd:b>change log:</xd:b></xd:p>
      <xd:ul>
        <xd:li>2015-10-12 by Syd: Created from tei2html_1 and tei2html_2</xd:li>
      </xd:ul>
    </xd:desc>
  </xd:doc>

  <xsl:include href="xml-to-string.xsl"/>

  <xsl:output method="xhtml" indent="no"/>

  <xsl:param name="teibpHome"  select="'http://dcl.slis.indiana.edu/teibp/'"/>
  <xsl:param name="tapasHome"  select="'http://tapasproject.org/'"/>
  <xsl:param name="tapasTitle" select="'TAPAS: '"/>
  <xsl:param name="less"       select="'styles.less'"/>
  <xsl:param name="lessJS"     select="'less.js'"/>
  <!-- set assets-base parameter to "../" to use locally; path below is for within-TAPAS use -->
  <xsl:param name="assets-base" select="'../'"/>
  <xsl:param name="view.diplo" select="concat($assets-base,'css/tapasGdiplo.css')"/>
  <xsl:param name="view.norma" select="concat($assets-base,'css/tapasGnormal.css')"/>
  <xsl:param name="jqueryUIcss"    select="concat($assets-base,'css/jquery-ui-1.10.3.custom/css/smoothness/jquery-ui-1.10.3.custom.css')"/>
  <xsl:param name="jqueryJS"   select="concat($assets-base,'js/jquery/jquery.min.js')"/>
  <xsl:param name="jqueryUIJS" select="concat($assets-base,'js/jquery-ui/ui/minified/jquery-ui.min.js')"/>
  <xsl:param name="jqueryBlockUIJS" select="concat($assets-base,'js/jquery/plugins/jquery.blockUI.js')"/>
  <xsl:param name="contextualJS" select="concat($assets-base,'js/contextualItems.js')"/>
  <xsl:param name="teibpJS"    select="concat($assets-base,'js/tapas-generic.js')"/>
  <xsl:param name="fullHTML"   select="'false'"/> <!-- set to 'true' to get browsable output for debugging -->
  <xsl:variable name="root" select="/" as="node()"/>
  <xsl:variable name="htmlFooter">
    <div id="footer"> This is the <a href="{$tapasHome}">TAPAS</a> generic view.</div>
  </xsl:variable>
  <xsl:param name="lessSide" select="'server'"/><!-- 'server' or 'client' -->
  <xsl:param name="idPrefix" select="'tg-'"/> <!-- Ensures unique identifiers when other reading interfaces are present. -->

  <xsl:variable name="numNoteFmt">
    <xsl:variable name="numNotes" select="count( /TEI/text//note ) cast as xs:string"/>
    <!-- WARNING: above line ignores possibility of a <teiCorpus> -->
    <xsl:variable name="nNF1" select="translate( $numNotes, '0123456789','0000000000')"/>
    <xsl:variable name="nNF2" select="substring( $nNF1, 1, string-length( $nNF1 ) - 1 )"/>
    <xsl:value-of select="concat( $nNF2, '1' )"/>
  </xsl:variable>

  <xsl:key name="IDs" match="//*" use="@xml:id"/>
  <xsl:key name="REFs" match="//name" use="@ref"/>
  <xsl:key name="REFs" match="//orgName" use="@ref"/>
  <xsl:key name="REFs" match="//persName" use="@ref"/>
  <xsl:key name="REFs" match="//placeName" use="@ref"/>
  <xsl:key name="REFs" match="//rs" use="@ref"/>
  <!-- algorithm for DIV and LG depth here should match that for $myDepth in the -->
  <!-- template that matches <div>s and <lg>s in mode "work" -->
  <xsl:key name="DIVs-and-LGs-by-depth"
           match="//lg|//div|//div1|//div2|//div3|//div4|//div5|//div6|//div7"
           use="count(
                       ancestor-or-self::div
                     | ancestor-or-self::div1
                     | ancestor-or-self::div2
                     | ancestor-or-self::div3
                     | ancestor-or-self::div4
                     | ancestor-or-self::div5
                     | ancestor-or-self::div6
                     | ancestor-or-self::div7
                     | ancestor-or-self::lg
                     )"/>
  <xsl:key name="TOCables" match="//div"  use="count( p | ab ) gt 5  or  lg  or  div"/>
  <xsl:key name="TOCables" match="//div1" use="count( p | ab ) gt 5  or  lg  or  div2"/>
  <xsl:key name="TOCables" match="//div2" use="count( p | ab ) gt 5  or  lg  or  div3"/>
  <xsl:key name="TOCables" match="//div3" use="count( p | ab ) gt 5  or  lg  or  div4"/>
  <xsl:key name="TOCables" match="//div4" use="count( p | ab ) gt 5  or  lg  or  div5"/>
  <xsl:key name="TOCables" match="//div5" use="count( p | ab ) gt 5  or  lg  or  div6"/>
  <xsl:key name="TOCables" match="//div6" use="count( p | ab ) gt 5  or  lg  or  div7"/>
  <xsl:key name="TOCables" match="//div7" use="count( p | ab ) gt 5  or  lg"/>
  <xsl:key name="TOCables" match="//lg[ not( ancestor::lg | ancestor::sp ) ]"
    use="count( ../lg | ../p | ../ab ) gt 1"/>
    
  <!-- special characters -->
  <xsl:variable name="quot"><text>"</text></xsl:variable>
  <xsl:variable name="apos"><text>'</text></xsl:variable>
  <xsl:variable name="lcub" select="'{'"/>
  <xsl:variable name="rcub" select="'}'"/>

  <!-- interface text -->
  <xsl:param name="altTextPbFacs" select="'view page image(s)'"/>

  <!-- input document -->
  <xsl:variable name="input" select="/"/>

  <xd:doc>
    <xd:desc>
      <xd:p>Match document root, and process the input
      the TEI document in several passes which copy it, with some modification, into an
      HTML <tt>&lt;div></tt>. Then, depending on value of the 'fullHTML' parameter,
      output that <tt>&lt;div></tt> in an HTML5 wrapper (so the result can
        be viewed stand-alone, mostly for debugging), or only the <tt>&lt;div></tt>
        itself.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/" priority="-3">
    <DEBUG>
      <xsl:for-each select="key('TOCables',true())">
        <xsl:value-of select="concat(
          if (@xml:id) then @xml:id
          else concat(
            local-name(.),
            '#',
            count(preceding::*[local-name(.) eq local-name(current())])),
            ': ',
            substring( normalize-space(.), 1, 23 ),
          '&#x0A;'
          )"/>
      </xsl:for-each>
    </DEBUG>
  </xsl:template>
  <xsl:template match="/" name="htmlShell" priority="42" mode="#default">
    <xsl:message> tei2html( <xsl:value-of
      select="tokenize( document-uri(/),'/')[last()]"/> ) at <xsl:value-of
        select="replace( current-dateTime() cast as xs:string,'-[0-9][0-9]:[0-9][0-9]$','')"/> </xsl:message>
    <!-- pass 1, "work" = most of the heavy lifting: -->
    <!-- input is TEI, output is XHTML -->
    <xsl:variable name="pass1">
      <div class="tapas-generic">
        <xsl:call-template name="toolbox"/>
        <xsl:call-template name="dialog"/>
        <xsl:call-template name="wrapper"/>
        <xsl:call-template name="contextual"/>
        <!-- commented out 2014-09-28 by Syd xsl:copy-of select="$htmlFooter"/ -->
      </div>
    </xsl:variable>
    <!-- pass 2, "TOCer" insert a TOC -->
    <!-- input and output are both XHTML (so XPaths may need have prefixes) -->
    <xsl:variable name="pass2">
      <xsl:choose>
        <xsl:when test="count( $pass1//@data-tapas-tocme ) gt 2">
          <xsl:message>debug: <xsl:value-of select="count( $pass1//@data-tapas-tocme )"/> tocme, so do it!</xsl:message>
          <xsl:apply-templates mode="TOCer" select="$pass1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>debug: <xsl:value-of select="count( $pass1//@data-tapas-tocme )"/> tocme, so relax.</xsl:message>
          <xsl:copy-of select="$pass1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- now output: -->
    <xsl:choose>
      <xsl:when test="$fullHTML eq 'true'">
        <html>
          <xsl:call-template name="htmlHead"/>
          <body>
            <xsl:copy-of select="$pass2"/>
          </body>
        </html>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$fullHTML ne 'false'">
          <xsl:message>WARNING: unrecognized value of 'fullHTML' parameter; presuming false</xsl:message>
        </xsl:if>
        <xsl:copy-of select="$pass2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ****************************** -->
  <!-- general-purpose copy templates -->
  <!-- ****************************** -->

  <xd:doc>
    <xd:desc>Copy all attribute nodes from source XML tree to
        output document.</xd:desc>
  </xd:doc>
  <xsl:template match="@*" mode="TOCer work makeTOCentry">
    <xsl:copy/>
  </xsl:template>

  <xd:doc>
    <xd:desc>Except @xml:id, which becomes @id</xd:desc>
  </xd:doc>
  <xsl:template match="@xml:id" mode="work">
    <!-- copy @xml:id to @id, which browsers use for internal links. -->
    <xsl:attribute name="id">
      <xsl:value-of select="concat($idPrefix,.)"/>
    </xsl:attribute>
    <xsl:attribute name="data-tapas-xmlid">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@ref | @target" mode="work">
    <xsl:variable name="ident" select="tps:generate-og-id(data(.))"/>
    <xsl:attribute name="{local-name()}" select="concat('#',$ident)"/>
    <xsl:variable name="gotoentry" select="$ogEntries[@id eq $ident] or key('IDs',$ident)"/>
    <xsl:attribute name="data-tapas-gotoentry" select="$gotoentry"/>
    <!-- If there *is* a valid 'ography entry and there is no user-supplied label, 
      use a generated header. This template will create the content of an element, 
      so it MUST be run after all other attributes have been added. -->
    <xsl:if test="$gotoentry and parent::*[not(*) and not(text())]">
      <xsl:variable name="ogMatch" as="node()" select="($ogEntries[@id eq $ident], key('IDs',$ident))[1]"/>
      <xsl:variable name="heading">
        <xsl:call-template name="get-entry-header">
          <xsl:with-param name="element" select="$ogMatch"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="normalize-space($heading)"/>
    </xsl:if>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Template for elements, main "work" mode
        <xd:ul>
          <xd:li>ensure there is an <xd:i>id</xd:i> to every element (copy existing <xd:i>xml:id</xd:i> or add new)</xd:li>
          <xd:li>process rendition attributes</xd:li>
          <xd:li>copy over other (non-rendition) attributes</xd:li>
          <!-- xd:li>chase the <xd:i>ref</xd:i> attributes, and copy over whatever they point to</xd:li -->
          <xd:li>copy all content</xd:li>
        </xd:ul>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*" mode="work">
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="addID"/>
      <xsl:call-template name="addRend"/>
      <xsl:apply-templates select="@* except ( @rend, @rendition, @style, @ref, @target )" mode="#current"/>
      <xsl:apply-templates select="@ref | @target" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>For other modes, copy nodes over</xd:desc>
  </xd:doc>
  <xsl:template match="node()" mode="TOCer makeTOCentry">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Template to omit processing instructions and comments from output.</xd:desc>
  </xd:doc>
  <xsl:template match="processing-instruction()|comment()" mode="work"/>
  
  <!-- ********************************************* -->
  <!-- Subroutines of the root "htmlShell" and its   -->
  <!-- "tapas-generic" <div>: "htmlHead", "toolbox", -->
  <!-- "dialog", "wrapper", and "contextual".        -->
  <!-- ********************************************* -->
  
  <xsl:template name="htmlHead">
    <head>
      <meta charset="UTF-8"></meta>
      <xsl:choose>
        <xsl:when test="$lessSide eq 'client'">
          <link rel="stylesheet/less" type="text/css" href="{$less}"></link>
          <script src="{$lessJS}" type="text/javascript"></script>
        </xsl:when>
        <xsl:otherwise>
          <link id="maincss" rel="stylesheet" type="text/css" href="{$view.diplo}"></link>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="javascript"/>
      <xsl:call-template name="css"/>
      <xsl:call-template name="tagUsage2style"/>
      <xsl:call-template name="rendition2style"/>
      <xsl:call-template name="generate-title"/>
    </head>
  </xsl:template>
  
  <xsl:template name="toolbox">
    <div id="tapasToolbox">
      <div id="tapasToolbox-pb">
        <label for="pbToggle">Hide page breaks</label>
        <input type="checkbox" id="pbToggle"></input>
      </div>
      <div id="tapasToolbox-views">
        <label for="viewBox">Views</label>
        <select id="viewBox">
          <!-- this <select> used to have on[cC]hange="switchThemes(this);", but -->
          <!-- that was incorporated into the javascript 2014-04-20 by PMJ. -->
          <option value="diplomatic" selected="selected">diplomatic</option>
          <option value="normal">normalized</option>
        </select>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="dialog">
    <div id="tapas-ref-dialog"></div>
  </xsl:template>

  <xsl:template name="wrapper">
    <div id="tei_wrapper">
      <xsl:apply-templates mode="work"/>
    </div>
  </xsl:template>

  <xsl:template name="contextual">
    <div id="tei_contextual">
      <!--<xsl:variable name="list_of_refs"
        select="tokenize( string-join(
            //name/@ref
          | //orgName/@ref
          | //persName/@ref
          | //placeName/@ref
          | //rs/@ref,' '),'\s+')"/>
      <xsl:for-each select="distinct-values( $list_of_refs )">
        <xsl:variable name="thisRef" select="."/>
        <xsl:call-template name="generateContextItem">
          <xsl:with-param name="ref" select="$thisRef"/>
        </xsl:call-template>
      </xsl:for-each>-->
      <xsl:copy-of select="$ogEntries"/>
    </div>
  </xsl:template>

  <xd:doc>
    <xd:desc>
      <xd:p>A hack because JavaScript was doing weird things with
      &lt;title>, probably due to confusion with HTML title. There is
      no TEI namespace in the TEI Boilerplate output because
      JavaScript, or at least JQuery, cannot manipulate the TEI
      elements/attributes if they are in the TEI namespace, so the TEI
      namespace is stripped from the output.</xd:p>
      <xd:p>2015-09-18: Changed the match expression to affect all TEI titles.
      ~Ashley</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="title" mode="work">
    <tei-title>
      <xsl:call-template name="addID"/>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </tei-title>
  </xsl:template>

  <xd:doc>
    <xd:desc>Transforms each TEI <tt>&lt;ref></tt> or <tt>&lt;ptr></tt>
      to an HTML <tt>&lt;a></tt> (link) element.</xd:desc>
  </xd:doc>
  <xsl:template match="ref[@target]|ptr[@target]" mode="work" priority="99">
    <xsl:variable name="gi">
      <xsl:choose>
        <xsl:when test="normalize-space(.) eq ''">ptr</xsl:when>
        <xsl:otherwise>ref</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="target" select="normalize-space(@target)"/>
    <xsl:variable name="class">
      <xsl:variable name="count" as="xs:integer">
        <xsl:choose>
          <xsl:when test="starts-with($target,'#')">
            <xsl:value-of select="count(//*[@xml:id eq substring-after($target,'#')])"/>
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="@data-tapas-target-warning eq 'target not found'">
          <xsl:value-of select="concat($gi,'-not-found')"/>
        </xsl:when>
        <xsl:when test="$count eq 0  and  starts-with($target,'#')">
          <xsl:value-of select="concat($gi,'-not-found')"/>
        </xsl:when>
        <xsl:when test="$count eq 0">
          <xsl:value-of select="concat($gi,'-external')"/>
        </xsl:when>
        <xsl:when test="$count eq 1">
          <xsl:value-of select="concat($gi,'-', local-name(//*[@xml:id eq substring-after($target,'#')]) )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($gi,'-internals')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a href="{$target}" class="{$class}" target="_blank">
      <xsl:apply-templates select="@* except @target" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:if test="$gi eq 'ptr'">
        <xsl:value-of select="$target"/>
      </xsl:if>
    </a>
  </xsl:template>

  <xd:doc>
    <xd:desc>Add an attribute explaining list layout to the CSS</xd:desc>
  </xd:doc>
  <xsl:template match="list" mode="work">
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="addID"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <!-- special-case to handle P5 used to use rend= for type= of <list> -->
      <xsl:variable name="rend" select="normalize-space( @rend )"/>
      <xsl:choose>
        <xsl:when test="not( @type )  and  $rend = ('bulleted','ordered','simple','gloss')">
          <xsl:attribute name="type" select="$rend"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addRend"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:attribute name="data-tapas-list-type">
        <xsl:variable name="labels" select="count( label )"/>
        <xsl:variable name="items"  select="count( item  )"/>
        <!-- items with label as 1st child -->
        <xsl:variable name="iwla1c"  select="count( item[
          child::node()[ not(
                self::comment()
            or  self::processing-instruction()
            or  self::text()[normalize-space(.) eq '']
            ) ][1][ self::label ] 
          ] )"/>
        <xsl:choose>
          <xsl:when test="$labels eq $items">
            <!-- label item pairs -->
            <xsl:text>LIP</xsl:text>
          </xsl:when>
          <xsl:when test="label  and  item">
            <!-- label item pairs, but with a mismatch (not valid) -->
            <xsl:text>lip</xsl:text>
          </xsl:when>
          <xsl:when test="$items = $iwla1c">
            <!-- labels in items -->
            <xsl:text>LII</xsl:text>
          </xsl:when>
          <xsl:when test="$iwla1c > ( $items div 3 )">
            <!-- well, at least some items have label as 1st child -->
            <xsl:text>lii</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>idunno</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Try to tease out which <gi>quote</gi>s are block-level and which are inline</xd:desc>
  </xd:doc>
  <xsl:template match="q[not(@style|@rend|@rendition)]
                 | quote[not(@style|@rend|@rendition)]" mode="work">
    <!-- BUG: should also be checking for a default <rendition> that applies -->
    <xsl:variable name="gi" select="local-name(.)"/>
    <!-- If preceding (non-whitespace only) text ends in whitespace, then -->
    <!-- this element should be inline. We are not using this test at the -->
    <!-- moment, only testing for chunky child elements. -->
    <!--<xsl:variable name="pre"
      select="(preceding-sibling::text()|preceding-sibling::*)
      [last()][self::text()][not(normalize-space(.)='')]"/>
    <xsl:variable name="must-be-inline" select="matches( $pre,'\s$')"/>-->
    <xsl:variable name="must-be-block" select="l|p|ab|table|floatingText|figure|list"/>
    <xsl:variable name="style">
      <xsl:choose>
        <xsl:when test="$must-be-block"> display: block; </xsl:when>
        <xsl:otherwise> display: inline; </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$gi}">
      <xsl:apply-templates select="@* except @style" mode="#current"/>
      <xsl:attribute name="style" select="concat( replace( @style,';\s*$',''), $style )"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xd:doc>
    <xd:desc>
      <xd:p>Indicate which <xd:i>div</xd:i>s and <xd:i>lg</xd:i>s should be in TOC</xd:p>
      <xd:p>Note that we are also putting out <tt>html:div</tt> even if the input
      was a TEI numbered division.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="lg[ not( ancestor::lg )]|div|div1|div2|div3|div4|div5|div6|div7" mode="work">
    <xsl:variable name="gi" select="replace( local-name(.),'[1-7]$','')"/>
    <xsl:element name="{$gi}" namespace="http://www.w3.org/1999/xhtml">
      <!-- algorithm for calculating $myDepth should match that for the use= of -->
      <!-- the DIVs-and-LGs-by-depth key. -->
      <xsl:variable name="myDepth"
        select="count(
          ancestor-or-self::div
        | ancestor-or-self::div1
        | ancestor-or-self::div2
        | ancestor-or-self::div3
        | ancestor-or-self::div4
        | ancestor-or-self::div5
        | ancestor-or-self::div6
        | ancestor-or-self::div7
        | ancestor-or-self::lg
        )"/>
      <xsl:attribute name="data-tapas-debug-consider-tocme" select="true()"/>
      <!-- does my parent have an entry in the TOC? -->
      <xsl:variable name="parent-TOCable" select="key('DIVs-and-LGs-by-depth',$myDepth -1) = key('TOCables',true())"/>
      <!-- if anything at my DIV level is TOCable, then I am ... -->
      <xsl:if test="key('DIVs-and-LGs-by-depth',$myDepth ) = key('TOCables',true() )">
        <xsl:attribute name="data-tapas-debug-maybe-tocme" select="true()"/>
        <!-- unless my parent is already in the TOC and I am pretty much the only thing in my parent -->
        <xsl:if test="not( count( ../lg | ../p | ../ab ) eq 1  and   $parent-TOCable )">
          <xsl:attribute name="data-tapas-tocme" select="true()"/>
        </xsl:if>
      </xsl:if>
      <xsl:call-template name="addID"/>
      <xsl:call-template name="addRend"/>
      <xsl:apply-templates select="@* except ( @rend, @rendition, @style )" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Insert an HTML note-anchor before each <tt>&lt;note></tt>, except those
    that already have something pointing at them</xd:desc>
  </xd:doc>
  <xsl:template match="text//note" priority="99" mode="work">
    <xsl:variable name="noteNum">
      <xsl:number value="count( preceding::note[ancestor::text] )+1" format="{$numNoteFmt}"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@xml:id  and  ( //@target ) = concat('#', normalize-space( @xml:id ) )"/>
      <xsl:otherwise>
        <a class="note-marker">
          <xsl:variable name="ID">
            <xsl:call-template name="generate-unique-id">
              <xsl:with-param name="base" select="generate-id()"/>
            </xsl:call-template>
          </xsl:variable>          
          <xsl:attribute name="href">
            <xsl:value-of select="concat('#', $ID )"/>
          </xsl:attribute>
          <xsl:value-of select="$noteNum"/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="data-tapas-note-num">
        <xsl:value-of select="$noteNum"/>
      </xsl:attribute>
      <xsl:call-template name="addID"/>
      <xsl:call-template name="addRend"/>
      <xsl:apply-templates select="@* except ( @rend, @rendition, @style )" mode="#current"/>
      <xsl:attribute name="data-tapas-anchored" select="'true'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!-- need something else for images with captions; specifically
       may want to catch figure/p, figure/floatingText, and figure/head
       with separate templates. -->
  <xd:doc>
    <xd:desc>
      <xd:p>Transforms TEI figure element to html img element.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="figure[graphic[@url]]" priority="99" mode="work">
    <!-- Checking all data as of 2015-08-29, there are no <figure>s -->
    <!-- that use <media>, <formula>, or <binaryObject>, nor any that -->
    <!-- have multiple <head>s. However, there are 2 cases (in 7 files -->
    <!-- due to version duplication, I think) that have multiple -->
    <!-- <figDesc> children. -->
    <xsl:element name="{local-name(.)}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="addID"/>
      <img src="{graphic/@url}">
        <xsl:if test="figDesc">
          <xsl:attribute name="alt" select="wfn:mult_to_1(figDesc)"/>
        </xsl:if>
      </img>
      <xsl:apply-templates select="* except ( self::graphic, self::figDesc )" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="addID">
    <xsl:if test="not( @xml:id ) and not( ancestor::eg:egXML )">
      <xsl:attribute name="id">
        <xsl:call-template name="generate-unique-id">
          <xsl:with-param name="base" select="generate-id()"/>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="addRend">
    <xsl:apply-templates select="@rendition" mode="#current"/>
    <xsl:if test="@rend | @html:style | @style">
      <xsl:attribute name="style">
        <xsl:variable name="rend">
          <xsl:apply-templates select="@rend" mode="rendition2style"/>
        </xsl:variable>
        <xsl:value-of select="$rend"/>
        <xsl:if test="$rend  and  substring($rend,string-length($rend),1) ne ';'">
          <xsl:text>; </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="@style" mode="#current"/>
        <xsl:apply-templates select="@html:style" mode="#current"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@style | @html:style" mode="work">
    <xsl:variable name="result" select="normalize-space(.)"/>
    <xsl:value-of select="$result"/>
    <xsl:if test="substring($result,string-length($result),1) ne ';'">
      <xsl:text>; </xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@rend" mode="rendition2style">
    <xsl:variable name="rend" select="normalize-space(.)"/>
    <xsl:variable name="css">
      <xsl:choose>
        <xsl:when test="contains( $rend, ':' )"><xsl:value-of select="."/></xsl:when>   <!-- 30937 -->
        <xsl:when test="$rend eq 'italic'"           >font-style: italic;</xsl:when>     <!-- 24857 -->
        <xsl:when test="$rend eq 'italics'"          >font-style: italic;</xsl:when>     <!--     0 -->
        <xsl:when test="$rend eq 'visible'"          ></xsl:when>                        <!--  1673 -->
        <xsl:when test="$rend eq 'superscript'"      >vertical-align: super;</xsl:when>  <!--  1175 -->
        <xsl:when test="$rend eq 'bold'"             >font-weight: bold;</xsl:when>      <!--   920 -->
        <xsl:when test="$rend eq 'ti-1'"             ></xsl:when>                        <!--   741 -->
        <xsl:when test="$rend eq 'center'"           >text-align: center;</xsl:when>     <!--   657 -->
        <xsl:when test="$rend eq 'rectangle'"        ></xsl:when>                        <!--   639 -->
        <xsl:when test="$rend eq 'right'"            >text-align: right;</xsl:when>      <!--   617 -->
        <xsl:when test="$rend eq 'i'"                >font-style: italic;</xsl:when>     <!--   449 -->
        <xsl:when test="$rend eq 'ul'"               >text-decoration: underline;</xsl:when> <!--   381 -->
        <xsl:when test="$rend eq 'align(center)'"    >text-align: center;</xsl:when>     <!--   301 -->
        <xsl:when test="$rend eq ''"                 ></xsl:when>                        <!--   207 -->
        <xsl:when test="$rend eq 'align(CENTER)'"    >text-align: center;</xsl:when>     <!--   202 -->
        <xsl:when test="$rend eq 'headerlike'"       ></xsl:when>                        <!--   189 -->
        <xsl:when test="$rend eq 'super'"            >vertical-align: super;</xsl:when>  <!--   161 -->
        <xsl:when test="$rend eq 'align(RIGHT)'"     >text-align: right;</xsl:when>      <!--   111 -->
        <xsl:when test="$rend eq 'valign(bottom)'"   >vertical-align: bottom;</xsl:when> <!--   104 -->
        <xsl:when test="$rend eq 'align(right)'"     >text-align: right;</xsl:when>      <!--   101 -->
        <xsl:when test="$rend eq 'blockquote'"       >display: block; padding: 0em 1em;</xsl:when>                        <!--    85 -->
        <xsl:when test="$rend eq 'ti-3'"             ></xsl:when>                        <!--    84 -->
        <xsl:when test="$rend eq 'run-in'"           >display: run-in;</xsl:when>        <!--    80 -->
        <xsl:when test="$rend eq 'valign(TOP)'"      >vertical-align: top;</xsl:when>    <!--    78 -->
        <xsl:when test="$rend eq 'distinct'"         ></xsl:when>                        <!--    78 -->
        <xsl:when test="$rend eq 'valign(top)'"      >vertical-align: top;</xsl:when>    <!--    77 -->
        <xsl:when test="$rend eq 'ti-2'"             ></xsl:when>                        <!--    73 -->
        <xsl:when test="$rend eq '+'"                ></xsl:when>                        <!--    63 -->
        <xsl:when test="$rend eq 'valign(BOTTOM)'"   >vertical-align: bottom;</xsl:when> <!--    55 -->
        <xsl:when test="$rend eq 'large b'"          >font-size: larger;font-weight: bold;</xsl:when> <!--    55 -->
        <xsl:when test="$rend eq 'frame'"            ></xsl:when>                        <!--    44 -->
        <xsl:when test="$rend eq 'ti-4'"             ></xsl:when>                        <!--    29 -->
        <xsl:when test="$rend eq 'sup'"              >vertical-align: super;</xsl:when>  <!--    27 -->
        <xsl:when test="$rend eq 'b'"                >font-weight: bold;</xsl:when>      <!--    27 -->
        <xsl:when test="$rend eq 'vertical'"         ></xsl:when>                        <!--    21 -->
        <xsl:when test="$rend eq 'LHLineStart'"      ></xsl:when>                        <!--    15 -->
        <xsl:when test="$rend eq 'indent'"           ></xsl:when>                        <!--    15 -->
        <xsl:when test="$rend eq 'sc'"               >font-variant: small-caps;</xsl:when> <!--    10 -->
        <xsl:when test="$rend eq 'overstrike'"       >text-decoration: overline;</xsl:when> <!--    10 -->
        <xsl:when test="$rend eq 'spaced'"           >font-stretch: wider;</xsl:when>    <!--     8 -->
        <xsl:when test="$rend eq 'left'"             >text-align: left;</xsl:when>       <!--     8 -->
        <xsl:when test="$rend eq 'AboveCenter'"      ></xsl:when>                        <!--     7 -->
        <xsl:when test="$rend eq 'subscript'"        >vertical-align: sub;</xsl:when>    <!--     6 -->
        <xsl:when test="$rend eq 'sc center'"        >font-variant: small-caps;text-align: center;</xsl:when> <!--     6 -->
        <xsl:when test="$rend eq 'underline'"        >text-decoration: underline;</xsl:when> <!--     5 -->
        <xsl:when test="$rend eq 'printed'"          ></xsl:when>                        <!--     5 -->
        <xsl:when test="$rend eq 'hidden'"           >display: none;</xsl:when>          <!--     5 -->
        <xsl:when test="$rend eq 'continued'"        ></xsl:when>                        <!--     5 -->
        <xsl:when test="$rend eq 'c'"                ></xsl:when>                        <!--     5 -->
        <xsl:when test="$rend eq 'inline'"           ></xsl:when>                        <!--     4 -->
        <xsl:when test="$rend eq 'typescript'"       ></xsl:when>                        <!--     3 -->
        <xsl:when test="$rend eq 'sc right'"         >font-variant: small-caps;text-align: right;</xsl:when> <!--     3 -->
        <xsl:when test="$rend eq 'LHMargin'"         ></xsl:when>                        <!--     3 -->
        <xsl:when test="$rend eq 'foot'"             ></xsl:when>                        <!--     3 -->
        <xsl:when test="$rend eq 'strikethrough'"    >text-decoration: line-through;</xsl:when> <!--     2 -->
        <xsl:when test="$rend eq 'small caps'"       >font-variant: small-caps;</xsl:when> <!--     2 -->
        <xsl:when test="$rend eq 'gothic'"           ></xsl:when>                        <!--     2 -->
        <xsl:when test="$rend eq 'font-size; 225%'"  ></xsl:when>                        <!--     2 -->
        <xsl:when test="$rend eq 'font-size; 200%'"  ></xsl:when>                        <!--     2 -->
        <xsl:when test="$rend eq 'chapter'"          ></xsl:when>                        <!--     2 -->
        <xsl:when test="$rend eq 'center i'"         >text-align: center;font-style: italic;</xsl:when> <!--     2 -->
        <xsl:when test="$rend eq 'uc'"               >text-transform: uppercase;</xsl:when> <!--     1 -->
        <xsl:when test="$rend eq 'ti-5'"             ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'ti=3'"             ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'ti=2'"             ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'text-align-left;'" ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'noborder center'"  ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'margin-bottom;'"   ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'italic bold'"      ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'i distinct'"       ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'font-size;225%'"   ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'font-size;150%'"   ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'font-size; 150%'"  ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'center ti-8'"      ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'center b'"         ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'Center'"           ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq 'above'"            ></xsl:when>                        <!--     1 -->
        <xsl:when test="$rend eq '20'"               ></xsl:when>                        <!--     1 -->
        <!-- above from profiling data; below from elsewhere or my head -->
        <xsl:when test="$rend eq 'case(upper)'"      >text-transform: uppercase;</xsl:when>
        <xsl:when test="$rend eq 'align(center)case(upper)'"      >text-align:center; text-transform:uppercase;</xsl:when>
        <xsl:when test="$rend eq 'case(upper)align(center)'"      >text-align:center; text-transform:uppercase;</xsl:when>
        <xsl:otherwise>
          <!-- xsl:message>WARNING: I don't know what to do with rend="<xsl:value-of select="."/>"</xsl:message -->
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$css"/>
  </xsl:template>

  <xd:doc>
    <xd:desc>
      <xd:p>The generate-id() function does not guarantee the generated id will not conflict
      with existing ids in the document. This template checks for conflicts and appends a
      number (hexedecimal 'f') to the id. The template is recursive and continues until no
      conflict is found</xd:p>
    </xd:desc>
    <xd:param name="root">The root, or base, id used to check for conflicts</xd:param>
    <xd:param name="suffix">The suffix added to the root id if a conflict is
    detected.</xd:param>
  </xd:doc>
  <xsl:template name="generate-unique-id">
    <xsl:param name="base"/>
    <xsl:param name="suffix"/>
    <xsl:variable name="id" select="concat($idPrefix,$base,$suffix)"/>
    <xsl:choose>
      <xsl:when test="key('IDs', $id, $input)">
        <xsl:call-template name="generate-unique-id">
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="suffix" select="concat($suffix,'f')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="javascript">
    <script type="text/javascript" src="{$jqueryJS}"></script>
    <script type="text/javascript" src="{$jqueryUIJS}"></script>
    <script type="text/javascript" src="{$jqueryBlockUIJS}"></script>
    <script type="text/javascript" src="{$contextualJS}"></script>
    <link rel="stylesheet" href="{$jqueryUIcss}"></link>
    <script type="text/javascript" src="{$teibpJS}"></script>
  </xsl:template>

  <xsl:template name="css">
    <!-- the one hard-coded rule (for #tapas-ref-dialog) in this <style> element should
      probably be nuked, moving this one rule to tapasG.css. But we're not sure exactly
      what effect that will have, so we're holding off for now. -->
    <style type="text/css">
      #tapas-ref-dialog{
      z-index:1000;
      }
      <xsl:call-template name="rendition2style"/>
    </style>
  </xsl:template>

  <xsl:template name="rendition2style">
    <xsl:apply-templates select="//rendition" mode="rendition2style"/>
  </xsl:template>

  <xsl:template match="rendition[@xml:id and @scheme eq 'css']" mode="rendition2style">
    <xsl:value-of select="concat('[rendition~=&quot;#',@xml:id,'&quot;]')"/>
    <xsl:if test="@scope">
      <xsl:value-of select="concat(':',@scope)"/>
    </xsl:if>
    <xsl:value-of select="concat('{ ',normalize-space(.),'}&#x000A;')"/>
  </xsl:template>

  <xsl:template match="rendition[not(@xml:id) and @scheme eq 'css' and @corresp]" mode="rendition2style">
    <xsl:value-of select="concat('[rendition~=&quot;#',substring-after(@corresp,'#'),'&quot;]')"/>
    <xsl:if test="@scope">
      <xsl:value-of select="concat(':',@scope)"/>
    </xsl:if>
    <xsl:value-of select="concat('{ ',normalize-space(.),'}&#x000A;')"/>
  </xsl:template>

  <xsl:template match="pb" mode="work">
    <xsl:variable name="pn">
      <xsl:number count="//pb" level="any"/>
    </xsl:variable>
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@xml:id">
          <xsl:value-of select="@xml:id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="generate-id()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <span class="-teibp-pb">
      <xsl:call-template name="addID"/>
      <a class="-teibp-pageNum" data-tapas-n="{$pn}">
        <xsl:if test="@n">
          <xsl:attribute name="data-tei-n">
            <xsl:value-of select="@n"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:text> </xsl:text>
      </a>
      <xsl:if test="@facs">
        <span class="-teibp-pbFacs">
          <a class="gallery-facs" rel="prettyPhoto[gallery1]">
            <xsl:attribute name="onclick">
              <xsl:value-of select="concat('showFacs(',$apos,@n,$apos,',',$apos,@facs,$apos,',',$apos,$id,$apos,')')"/>
            </xsl:attribute>
            <img  alt="{$altTextPbFacs}" class="-teibp-thumbnail">
              <xsl:attribute name="src">
                <xsl:value-of select="@facs"/>
              </xsl:attribute>
            </img>
          </a>
        </span>
      </xsl:if>
    </span>
  </xsl:template>

  <xsl:template match="eg:egXML" mode="work">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="addID"/>
      <xsl:call-template name="xml-to-string">
        <xsl:with-param name="node-set">
          <xsl:copy-of select="node()"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template match="eg:egXML//comment()" mode="work">
    <xsl:comment><xsl:value-of select="."/></xsl:comment>
  </xsl:template>

  <xsl:template name="tagUsage2style">
    <xsl:variable name="tagusage-css">
      <xsl:for-each select="//namespace[@name eq 'http://www.tei-c.org/ns/1.0']/tagUsage">
        <xsl:value-of select="concat('&#x0A;',@gi,' { ')"/>
        <xsl:call-template name="tokenize">
          <xsl:with-param name="string" select="@render"/>
        </xsl:call-template>
        <xsl:value-of select="'}&#x0A;'"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="normalize-space($tagusage-css) ne ''">
      <style type="text/css" id="tagusage-css">
        <xsl:copy-of select="$tagusage-css"/>
      </style>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tokenize">
    <xsl:param name="string" />
    <xsl:param name="delimiter" select="' '" />
    <xsl:choose>
      <xsl:when test="$delimiter and contains($string, $delimiter)">
        <xsl:call-template name="grab-css">
          <xsl:with-param name="rendition-id" select="substring-after(substring-before($string, $delimiter),'#')" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:call-template name="tokenize">
          <xsl:with-param name="string"
                          select="substring-after($string, $delimiter)" />
          <xsl:with-param name="delimiter" select="$delimiter" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="grab-css">
          <xsl:with-param name="rendition-id" select="substring-after($string,'#')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="grab-css">
    <xsl:param name="rendition-id"/>
    <xsl:value-of select="normalize-space(key('IDs',$rendition-id)/text())"/>
  </xsl:template>

  <xsl:template name="generate-title">
    <title>
      <xsl:value-of select="$tapasTitle"/>
      <xsl:choose>
        <xsl:when test="count( /TEI/teiHeader/fileDesc/titleStmt/title ) eq 1">
          <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title"/>
        </xsl:when>
        <xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'short']">
          <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'short']">
            <xsl:value-of select="concat(.,' ')"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'filing']">
          <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'filing']">
            <xsl:value-of select="concat(.,' ')"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'uniform']">
          <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'uniform']">
            <xsl:value-of select="concat(.,' ')"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'main']">
          <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'main']">
            <xsl:value-of select="concat(.,' ')"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'marc245a']">
          <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/title[@type eq 'marc245a']">
            <xsl:value-of select="concat(.,' ')"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@level eq 'a']">
          <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/title[@level eq 'a']">
            <xsl:value-of select="concat(.,' ')"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/title">
            <xsl:value-of select="concat(.,' ')"/>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </title>
  </xsl:template>
  
  <xsl:template match="head" mode="work">
    <tei-head class="heading">
      <xsl:call-template name="get-attributes"/>
      <xsl:apply-templates select="*|text()"/>
    </tei-head>
  </xsl:template>

  <xd:doc>
    <xd:desc>add line numbers to poetry</xd:desc>
  </xd:doc>
  <xsl:template match="lg/l[ not(@prev) and not( @part = ('M','F') )]" mode="work">
    <xsl:variable name="cnt" select="count(
      preceding::l
        [ not(@prev) and not( @part = ('M','F') ) ]
        [ ancestor::lg[ not( ancestor::lg ) ] is current()/ancestor::lg[ not( ancestor::lg ) ] ]
      ) +1"/>
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="addRend"/>
      <xsl:apply-templates select="@* except ( @rend, @rendition, @style )" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:if test="( $cnt mod 5 ) eq 0">
        <xsl:text>&#xA0;</xsl:text>
        <span class="poem-line-count">
          <xsl:value-of select="$cnt"/>
        </span>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Template to drop insignificant whitespace nodes</xd:desc>
  </xd:doc>
  <xsl:template match="choice/text()[normalize-space(.) eq '']" mode="work"/>

  <!-- ***************************** -->
  <!-- handle contextual information -->
  <!-- ***************************** -->
  
  <!-- ignore lists of contextual info when they occur in normal processing -->
  <!--<xsl:template match="nymList|listOrg|listPerson|placeList|nym|org|person|place" mode="work"/>-->
  
  <xsl:template match="castList|listBibl|listEvent|listNym|listOrg|listPerson|listPlace" mode="work">
    <div>
      <xsl:call-template name="addID"/>
      <xsl:call-template name="addRend"/>
      <xsl:attribute name="class" select="'list-contextual'"/>
      <xsl:attribute name="data-tapas-tocme" select="true()"/>
      <xsl:choose>
        <xsl:when test="head">
          <xsl:apply-templates select="head" mode="work"/>
        </xsl:when>
        <xsl:otherwise>
          <span class="heading heading-listtype">
            <xsl:call-template name="set-label">
              <xsl:with-param name="is-field-label" select="false()"/>
            </xsl:call-template>
          </span>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="* except head" mode="og-gen">
        <xsl:with-param name="doc-uri" select="''" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <!-- 'ographies and entries we are currently not equipped to handle. -->
  <xsl:template match="custodialHist|listRef|listRelation|listTranspose" mode="work"/>

  <xd:doc>
    <xd:desc>Generate an entry for the separate "contextual information" block</xd:desc>
  </xd:doc>
  <xsl:template name="generateContextItem">
    <xsl:param name="ref"/>
    <xsl:variable name="uri" select="normalize-space($ref)"/>
    <xsl:variable name="scheme" select="substring-before($uri,':')"/>
    <xsl:variable name="fragID" select="substring-after($uri,'#')"/>
    <xsl:variable name="non-NCName-chars" select="concat(';?~ !@$%^&amp;*()+=[]&lt;&gt;,/\',$lcub,$rcub,$quot,$apos)"/>
    <xsl:choose>
      <xsl:when test="$scheme eq ''  and  $fragID eq ''  and
        translate( $uri, $non-NCName-chars, '') eq $uri">
        <!-- looks like encoder probably forgot initial sharp symbol ("#") -->
        <xsl:comment> debug 1: </xsl:comment>
        <xsl:comment> uri=<xsl:value-of select="$uri"/> </xsl:comment>
        <xsl:comment> scheme=<xsl:value-of select="$scheme"/> </xsl:comment>
        <xsl:comment> fragID=<xsl:value-of select="$fragID"/> </xsl:comment>
        <xsl:variable name="IDentified" as="element()?">
          <xsl:for-each select="$input">
            <xsl:copy-of select="id( $uri )"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:comment> IDentified, which is a <xsl:value-of select="local-name($IDentified)"/>=<xsl:value-of select="$IDentified"/>.</xsl:comment>
        <xsl:if test="$IDentified">
          <xsl:apply-templates select="$IDentified" mode="genCon">
            <xsl:with-param name="ref" select="$ref"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$scheme eq ''  and  $fragID ne ''  and  substring-before($uri,'#') eq ''">
        <xsl:comment> debug 2: </xsl:comment>
        <xsl:comment> uri=<xsl:value-of select="$uri"/> </xsl:comment>
        <xsl:comment> scheme=<xsl:value-of select="$scheme"/> </xsl:comment>
        <xsl:comment> fragID=<xsl:value-of select="$fragID"/> </xsl:comment>
        <!-- just a bare name identifier, i.e. local -->
        <xsl:variable name="IDentified" as="element()?">
          <xsl:for-each select="$input">
            <xsl:copy-of select="id( $fragID )"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:comment> IDentified, which is a <xsl:value-of select="local-name($IDentified)"/>=<xsl:value-of select="$IDentified"/>.</xsl:comment>
        <xsl:if test="$IDentified">
          <xsl:apply-templates select="$IDentified" mode="genCon">
            <xsl:with-param name="ref" select="$ref"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
      <xsl:when test="starts-with( $scheme,'http')  and  contains($uri,'wikipedia.org/')">
        <xsl:comment> debug 3: Wikipedia!</xsl:comment>
        <div class="contextualItem-world-wide-web">
          <a name="{$uri}" href="{$uri}">Wikipedia article</a>          
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment> debug 4: </xsl:comment>
        <xsl:comment> uri=<xsl:value-of select="$uri"/> </xsl:comment>
        <xsl:comment> scheme=<xsl:value-of select="$scheme"/> </xsl:comment>
        <xsl:comment> fragID=<xsl:value-of select="$fragID"/> </xsl:comment>
        <xsl:if test="doc-available( $uri )">
          <xsl:apply-templates select="document( $uri, $input )" mode="genCon">
            <xsl:with-param name="ref" select="$ref"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- In general, just copy stuff over, changing namespace and ditching -->
  <!-- xml:id=, comments, and PIs -->
  <xsl:template match="*" mode="genCon">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="*|@*|text()" mode="genCon"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="@*" mode="genCon" priority="2">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="@xml:id" mode="genCon"/>
  <xsl:template match="html:script
                      |script
                      |processing-instruction()
                      |comment()" mode="genCon"/>
  
  <!-- For the outer contextual element we want to -->
  <!-- generate output in a particular order. Note that we are ignoring -->
  <!-- the possibility of <personGrp> or <nym> because there are *none* in -->
  <!-- the profiling data. -->
  <xsl:template match="org|person|place" mode="genCon">
    <div class="contextualItem-{local-name(.)}">
      <!-- This node *has* to have an @xml:id, or we would never have gotten here -->
      <a id="{@xml:id}"/>
      <p class="identifier">
        <!-- We're relying on the fact that <orgName> does not appear as -->
        <!-- a child of <person> or <place>, <persName> does not appear -->
        <!-- as a child of <org> or <place>, etc. -->
        <xsl:choose>
          <xsl:when test="
               self::org and not( orgName )
            or self::person and not( persName )
            or self::place and not( placeName )
            ">
            <xsl:choose>
              <xsl:when test="@xml:id">
                <xsl:value-of select="@xml:id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat(
                  local-name(.),
                  '-',
                  count( preceding::*[ local-name(.) eq local-name(current()) ] )
                  )"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="count( orgName | persName | placeName ) eq 1">
            <xsl:apply-templates select="orgName | persName | placeName" mode="string"/>
          </xsl:when>
          <xsl:when test="( orgName | persName | placeName )[ @type eq 'main']">
            <xsl:apply-templates select="( orgName | persName | placeName )[ @type eq 'main'][1]" mode="string"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>WARNING: not doing a good job of identifying <xsl:value-of
              select="local-name(.)"/> #<xsl:value-of
                select="count(preceding::*[local-name(.) eq local-name(current())])+1"/>, “<xsl:value-of
                  select="normalize-space(.)"/>”</xsl:message>
            <xsl:apply-templates select="( orgName | persName | placeName )[1]" mode="string"/>
          </xsl:otherwise>
        </xsl:choose>
      </p>
      <xsl:comment>debug: Y; <xsl:value-of select="count( persName )"/></xsl:comment>
      <xsl:apply-templates select="orgName|persName|placeName" mode="genCon"/>
      <xsl:comment>debug: Z</xsl:comment>
      <xsl:apply-templates select="ab|p|desc" mode="genCon"/>
      <xsl:choose>
        <xsl:when test="sex">
          <xsl:apply-templates select="sex" mode="genCon"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@sex" mode="genCon"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="birth" mode="genCon"/>
      <xsl:apply-templates select="location" mode="genCon"/>
      <xsl:apply-templates select="death" mode="genCon"/>
      <xsl:apply-templates select="*[ not(
            self::orgName
         or self::persName
         or self::placeName
         or self::ab
         or self::p
         or self::desc
         or self::sex
         or self::birth
         or self::location
         or self::death
         or self::note ) ]" mode="genCon">
        <xsl:sort select="concat( local-name(.), @when, @from, @notBefore, @to, @notAfter )"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="note" mode="genCon"/>
    </div>
  </xsl:template>

  <!-- In all our test data there is only 1 <org> that has > 1 <orgName>, and -->
  <!-- it looks like an error. So for <org>s, we just presume the identifier  -->
  <!-- above is sufficient. -->
  <xsl:template match="orgName" mode="genCon" priority="3"/>
  
  <!-- We have no test gazeteers, so for the moment presume that the identifier -->
  <!-- above is sufficient for <place>s, too. -->
  <xsl:template match="placeName" mode="genCon" priority="3"/>
  
  <!-- <persName>s, however, are a pain -->
  <xsl:template match="persName" mode="genCon" priority="3">
    <xsl:choose>
      <xsl:when test="not( preceding-sibling::persName | following-sibling::persName )">
        <xsl:comment>debug A</xsl:comment>
        <!-- No siblings, I was used for the identifier, ignore me -->
      </xsl:when>
      <xsl:when test="not(*) and @type eq 'main'">
        <xsl:comment>debug B</xsl:comment>
        <!-- there are sibling <persName>s, but this one was already used -->
        <!-- for the identifier, so ignore it -->
      </xsl:when>
      <xsl:when test="*">
        <xsl:comment>debug C</xsl:comment>
        <xsl:apply-templates select="*" mode="genCon" >
          <xsl:with-param name="labelPart" select="@type"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>debug D</xsl:comment>
        <xsl:variable name="label">
          <xsl:choose>
            <xsl:when test="@type">
              <xsl:value-of select="@type"/>
            </xsl:when>
            <xsl:otherwise>alternate</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <p data-tapas-label="name, {$label}">
          <span><xsl:value-of select="normalize-space(.)"/></span>
        </p>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template mode="string" match="persName|placeName|orgName">
    <xsl:choose>
      <xsl:when test="not(*)">
        <!-- only text, no child elements -->
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:when test="not( text()[ string-length( normalize-space(.) ) gt 0 ] )">
        <!-- only child elements, no text -->
        <!-- We need heuristics in here to put out a useful string in the right order -->
        <xsl:apply-templates select="node()" mode="string"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- a mix of elements and text, in which case encoder is responsible for getting -->
        <!-- whitespace right. -->
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="forename|surname|genName|roleName" mode="genCon" priority="3">
    <xsl:param name="labelPart"/>
    <xsl:param name="labelAdd">
      <xsl:choose>
        <xsl:when test="$labelPart">
          <xsl:value-of select="concat('-',$labelPart)"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:param>
    <xsl:variable name="label" select="concat( local-name(.), $labelAdd )"/>
    <span data-tapas-label="{$label}"><xsl:apply-templates mode="#current"/></span>
  </xsl:template>
  <xsl:template mode="string" match="text()">
    <!-- regularize the whitespace, but leave leading or trailing iff present -->
    <xsl:variable name="mePlus" select="normalize-space( concat('␀',.,'␀') )"/>
    <xsl:variable name="regularized" select="substring( $mePlus, 2, string-length( $mePlus ) -2 )"/>
    <xsl:value-of select="$regularized"/>
  </xsl:template>
  <xsl:template mode="string" match="*">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  <xd:doc>
    <xd:desc>Some of the mode "string" templates have to match in both namespaces,
    as I'm overloading use of this mode for both ogrophy processing (which happens
    in pass 1 on TEI data) and TOC processing (which happens in pass 2 on XHTML
    data).</xd:desc>
  </xd:doc>
  <xsl:template mode="string" match="choice|html:choice">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template mode="string" match="cb|gb|lb|pb|milestone|html:cb|html:gb|html:lb|html:pb|html:milestone">
    <xsl:text>&#x20;</xsl:text>
  </xsl:template>
  <xsl:template mode="string" match="fw|html:fw"/>
  
  <!-- If an element has no descendants, don't transform it. -->
  <xsl:template match="*[normalize-space(.) eq '' and not( descendant-or-self::*/@* )]" priority="50" mode="genCon"/>
  <xsl:template match="person/* | place/* | org/*" mode="genCon">
    <xsl:variable name="me" select="local-name(.)"/>
    <xsl:choose>
      <xsl:when test="self::socecStatus[@scheme]">
        <xsl:variable name="sesLabel">
          <xsl:text>status (</xsl:text>
          <xsl:value-of select="substring-after(@scheme,'#')"/>
          <xsl:text>)</xsl:text>
        </xsl:variable>
        <p data-tapas-label="{$sesLabel}">
          <span><xsl:apply-templates select="node()" mode="#current"/></span>
        </p>
      </xsl:when>
      <xsl:when test="self::note"> <!-- Notes can contain problematic child elements, so flatten for now. -->
        <p data-tapas-label="note">
          <span><xsl:apply-templates select="node()" mode="string"/></span>
        </p>
      </xsl:when>
      <xsl:when test="not( preceding-sibling::*[ local-name(.) eq $me ] )">
        <xsl:variable name="mylabel">
          <xsl:choose>
            <xsl:when test="self::socecStatus">social-economic status</xsl:when>
            <xsl:when test="self::death">died</xsl:when>
            <xsl:when test="self::birth">born</xsl:when>
            <xsl:when test="self::bibl">citation</xsl:when><!-- only 1, and it's empty -->
            <xsl:otherwise><xsl:value-of select="local-name(.)"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="label">
          <xsl:choose>
            <xsl:when test="$me = ('affiliation','residence','faith','age','bibl','occupation')
              and
              following-sibling::*[local-name(.) eq $me]">
              <xsl:value-of select="concat( $mylabel,'s')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$mylabel"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <p data-tapas-label="{$label}">
          <xsl:call-template name="processGenCon">
            <xsl:with-param name="this" select="."/>
          </xsl:call-template>
          <xsl:for-each select="( following-sibling::*[local-name(.) eq $me] )">
            <xsl:call-template name="processGenCon">
              <xsl:with-param name="this" select="."/>
            </xsl:call-template>
          </xsl:for-each>
        </p>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sex|@sex" mode="genCon" priority="3">
    <p data-tapas-label="sex">
      <span>
        <xsl:choose>
          <xsl:when test="not( self::sex )">
            <!-- this is an attribute -->
            <xsl:call-template name="getSex">
              <xsl:with-param name="sexCode" select="normalize-space(.)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="normalize-space(.) ne ''">
            <!-- this is an element with content, use the content -->
            <xsl:apply-templates select="." mode="string"/>
          </xsl:when>
          <xsl:when test="@value">
            <!-- this is an element w/ a value= attr, use it -->
            <xsl:call-template name="getSex">
              <xsl:with-param name="sexCode" select="normalize-space(@value)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment>where am I supposed to find sex?</xsl:comment>
            <xsl:call-template name="getSex">
              <xsl:with-param name="sexCode" select="'?'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </p>
  </xsl:template>
  
  <xsl:template name="getSex">
    <xsl:param name="sexCode" select="lower-case(.)"/>
    <xsl:choose>
      <xsl:when test="$sexCode eq '0'">unknown</xsl:when>
      <xsl:when test="$sexCode eq 'u'">unknown</xsl:when>
      <xsl:when test="$sexCode eq '1'">male</xsl:when>
      <xsl:when test="$sexCode eq 'm'">male</xsl:when>
      <xsl:when test="$sexCode eq '2'">female</xsl:when>
      <xsl:when test="$sexCode eq 'f'">female</xsl:when>
      <xsl:when test="$sexCode eq 'O'">other</xsl:when>
      <xsl:when test="$sexCode eq '9'">not applicable</xsl:when>
      <xsl:when test="$sexCode eq 'n'">none or not applicable</xsl:when>
      <xsl:otherwise><xsl:value-of select="$sexCode"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="processGenCon">
    <xsl:param name="this"/>
    <xsl:for-each select="$this">
      <span>
        <xsl:if test="@when|@notBefore|@from|@to|@notAfter">
          <span class="normalized-date">
            <xsl:choose>
              <xsl:when test="@when">
                <xsl:value-of select="@when"/>
              </xsl:when>
              <xsl:when test="@from and @to">
                <xsl:value-of select="concat(@from,'–',@to)"/>
              </xsl:when>
              <xsl:when test="@notBefore and @notAfter">
                <xsl:text>sometime between </xsl:text>
                <xsl:value-of select="concat( @notBefore, ' and ', @notAfter )"/>
              </xsl:when>
              <xsl:when test="
                   ( @notAfter  and @to   )
                or ( @notBefore and @from )
                or ( @notAfter  and @from )
                or ( @notBefore and @to   )
                ">
                <xsl:message>unable to determine normalized date of <xsl:value-of
                  select="concat( local-name(.),' with ' )"
                /><xsl:for-each select="@*"><xsl:value-of select="concat( name(.),' ')"/></xsl:for-each>.</xsl:message>
                <xsl:apply-templates select="./node()" mode="#current"/>
              </xsl:when>
              <xsl:when test="@notAfter">
                <xsl:text>sometime before </xsl:text>
                <xsl:value-of select="@notAfter"/>
              </xsl:when>
              <xsl:when test="@notBefore">
                <xsl:text>sometime after </xsl:text>
                <xsl:value-of select="@notBefore"/>
              </xsl:when>
              <xsl:when test="@from">
                <xsl:value-of select="concat(@from,'–present')"/>
              </xsl:when>
              <xsl:when test="@to">
                <xsl:value-of select="concat('?–',@to)"/>
              </xsl:when>
            </xsl:choose>
          </span>
        </xsl:if>
        <xsl:apply-templates select="./node()" mode="#current"/>
      </span>
    </xsl:for-each>
  </xsl:template>

  <xd:doc>
    <xd:desc>Generate a table of contents, if needed</xd:desc>
  </xd:doc>
  <xsl:template match="html:div[ @class eq 'tapas-generic']" mode="TOCer">
    <xsl:copy>
      <xsl:apply-templates mode="TOCer" select="@*"/>
      <xsl:apply-templates mode="TOCer"
                           select="html:div[ @id = ('tapasToolbox','tapas-ref-dialog') ]"/>
        <div id="TOC">
          <ol>
            <xsl:apply-templates mode="makeTOCentry" select=".//*[@data-tapas-tocme]"/>
          </ol>
        </div>
      <xsl:apply-templates mode="TOCer"
                           select="html:div[ @id = ('tei_wrapper','tei_contextual') ]"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create TOC entry</xd:desc>
  </xd:doc>
  <xsl:template match="*[@data-tapas-tocme]" mode="makeTOCentry">
    <xsl:variable name="gi" select="local-name(.)"/>
    <xsl:variable name="maxlen" select="34"/>
    <li>
      <xsl:variable name="label">
        <xsl:number level="multiple" count="html:div[@data-tapas-tocme]|html:lg[@data-tapas-tocme]"
          format="I. 1. A. 1. a. 1. i. "/>
      </xsl:variable>
      <xsl:attribute name="data-tapas-toc-depth" select="count( tokenize( normalize-space( $label ),' '))"/>
      <xsl:variable name="id">
        <xsl:choose>
          <xsl:when test="@id">
            <xsl:value-of select="normalize-space(@id)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="generate-unique-id">
              <xsl:with-param name="base" select="generate-id()"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <a href="#{$id}">
        <span class="TOC-entry-label">
          <xsl:value-of select="$label"/>
        </span>
        <span class="">
          <xsl:choose>
            <xsl:when test="count( html:head ) eq 1">
              <xsl:attribute name="class" select="'TOC-entry-heading'"/>
              <xsl:apply-templates mode="string" select="html:head[1]"/>
            </xsl:when>
            <xsl:when test="html:head">
              <xsl:attribute name="class" select="'TOC-entry-heading'"/>
              <xsl:apply-templates mode="string" select="(
                html:head[ @type eq 'main'],
                html:head[ @type eq 'supplied'],
                html:head[ not( @type ) ],
                html:head[ @type ne 'sub']
                )[1]"/>
            </xsl:when>
            <xsl:when test="html:label[
              not(
                   preceding-sibling::html:p
                 | preceding-sibling::html:ab
                 | preceding-sibling::html:figure
                 | preceding-sibling::html:table
                 ) ]">
              <xsl:attribute name="class" select="'TOC-entry-heading'"/>
              <xsl:apply-templates mode="string" select="html:label[
                not(
                     preceding-sibling::html:p
                   | preceding-sibling::html:ab
                   | preceding-sibling::html:figure
                   | preceding-sibling::html:table
                   ) ][1]"/>
            </xsl:when>
            <xsl:when test="@n">
              <xsl:attribute name="class" select="'TOC-entry-heading-generated'"/>
              <xsl:if test="@type">
                <xsl:value-of select="concat( @type,' #')"/>
              </xsl:if>
              <xsl:value-of select="@n"/>
            </xsl:when>
            <xsl:when test="@type">
              <xsl:variable name="mytype" select="@type"/>
              <xsl:attribute name="class" select="'TOC-entry-heading-generated'"/>
              <xsl:value-of select="@type"/>
              <xsl:if test="count( ../*[ local-name(.) eq $gi ][ @type eq $mytype ] ) gt 1">
                <xsl:value-of select="concat(' #',count( preceding-sibling::*[ local-name(.) eq $gi ][ @type eq $mytype ] ) + 1)"/>
              </xsl:if>
            </xsl:when>
            <xsl:when test="html:p | html:ab | html:lg | html:l">
              <xsl:attribute name="class" select="'TOC-entry-heading-1stline'"/>
              <xsl:variable name="me">
                <xsl:apply-templates mode="string" select="( html:p | html:ab | html:lg | html:l )[1]"/>
              </xsl:variable>
              <xsl:variable name="mylen" select="string-length( $me )"/>
              <xsl:value-of select="if ( $mylen lt $maxlen )
                then $me
                else concat( substring( $me, 1, $maxlen - 1 ),'…')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class" select="'TOC-entry-heading-content'"/>
              <xsl:variable name="me">
                <xsl:apply-templates mode="string"/>
              </xsl:variable>
              <xsl:variable name="mylen" select="string-length( $me )"/>
              <xsl:value-of select="if ( $mylen lt $maxlen )
                then $me
                else concat( substring( $me, 1, $maxlen - 1 ),'…')"/>
            </xsl:otherwise>
          </xsl:choose>
        </span>
      </a>
    </li>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Take one or more nodes (most likely child elements),
    and convert to a single string</xd:desc>
  </xd:doc>
  <xsl:function name="wfn:mult_to_1">
    <xsl:param name="nodes"/>
    <!-- need to add heuristics someday to insert proper punction -->
    <xsl:variable name="one">
      <xsl:for-each select="$nodes">
        <xsl:value-of select="concat(.,' ')"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="normalize-space( $one )"/>
  </xsl:function>

</xsl:stylesheet>
