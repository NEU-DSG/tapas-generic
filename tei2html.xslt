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
  <xsl:include href="xml-to-string.xsl"/>
  <xsl:output method="xhtml" indent="no"/>

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
        <xd:li>2017-12-18 by Ashley: Removed vestigal 'genCon' mode. Specified the 
          only cases where a note anchor should be generated (when the value of 
          @anchored is true, and the note isn't linked.)</xd:li>
        <xd:li>2017-11-14 by Ashley: Added parameter 'defaultViewClass', which 
          allows one to decide which view should first render when the page is 
          loaded. The default is 'diplomatic', since that's what TAPAS has used in 
          the past.</xd:li>
        <xd:li>2017-11-06 by Ashley: Disambiguated input element names from HTML 
          names. Reorganized the file by XSLT element type and template mode, 
          converting some comments into documentation.</xd:li>
        <xd:li>2017-10-27 by Ashley: Added a LESS file (generic.less) to remove 
          duplication in the diplomatic/normalized LESS files.</xd:li>
        <xd:li>2017-10-18 by Ashley: Created a convenience wrapper for creating 
          attributes which should be on every transformed TEI element. Cleaned up 
          the 'addRend' template and expanded recognized keywords within `@rend`, 
          but commented out previously-recognized WWO-style rendition ladders. 
          Commented out the 'show/hide page breaks' toggle since it behaves 
          strangely across browsers and depending on diplomatic/normalized view.</xd:li>
        <xd:li>2017-05-15 by Ashley: Renamed the 'body' element so browsers 
          don't eat it.</xd:li>
        <xd:li>2015-10-12 by Syd: Created from tei2html_1 and tei2html_2</xd:li>
      </xd:ul>
    </xd:desc>
  </xd:doc>


<!-- 
  ~~ PARAMETERS and VARIABLES
  -->

  <xsl:param name="teibpHome"  select="'http://dcl.slis.indiana.edu/teibp/'"/>
  <xsl:param name="tapasHome"  select="'http://tapasproject.org/'"/>
  <xsl:param name="tapasTitle" select="'TAPAS: '"/>
  <xsl:param name="less"       select="'styles.less'"/>
  <xsl:param name="lessJS"     select="'less.js'"/>
  <!-- set assets-base parameter to "../" to use locally; path below is for within-TAPAS use -->
  <xsl:param name="assets-base" select="'../'"/>
  <xsl:param name="defaultViewClass" select="'diplomatic'"/>
  <xsl:param name="view.generic" select="concat($assets-base,'css/generic.css')"/>
  <xsl:param name="view.diplo" select="concat($assets-base,'css/tapasGdiplo.css')"/>
  <xsl:param name="view.norma" select="concat($assets-base,'css/tapasGnormal.css')"/>
  <xsl:param name="jqueryUIcss"    select="concat($assets-base,'js/jquery-ui-1.12.1/jquery-ui.css')"/>
  <xsl:param name="jqueryJS"   select="concat($assets-base,'js/jquery/jquery-3.2.1.min.js')"/>
  <xsl:param name="jqueryUIJS" select="concat($assets-base,'js/jquery-ui-1.12.1/jquery-ui.min.js')"/>
  <xsl:param name="jqueryBlockUIJS" select="concat($assets-base,'js/jquery/plugins/jquery.blockUI.min.js')"/>
  <xsl:param name="contextualJS" select="concat($assets-base,'js/contextualItems.js')"/>
  <xsl:param name="genericJS"    select="concat($assets-base,'js/tapas-generic.js')"/>
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
    
  <!-- special characters -->
  <xsl:variable name="quot"><text>"</text></xsl:variable>
  <xsl:variable name="apos"><text>'</text></xsl:variable>
  <xsl:variable name="lcub" select="'{'"/>
  <xsl:variable name="rcub" select="'}'"/>

  <!-- interface text -->
  <xsl:param name="altTextPbFacs" select="'view page image(s)'"/>

  <!-- input document -->
  <xsl:variable name="input" select="/"/>


<!-- 
  ~~ KEYS
  -->

  <xsl:key name="IDs" match="//*" use="@xml:id"/>
  <!--<xsl:key name="localREFs" match="//@corresp[starts-with(.,'#')]">
    <xsl:for-each select="tokenize(.,'\s+')">
      <xsl:value-of select="substring-after(.,'#')"/>
    </xsl:for-each>
  </xsl:key>-->
  <xsl:key name="localREFs" match="//@ref[starts-with(.,'#')]">
    <xsl:for-each select="tokenize(.,'\s+')">
      <xsl:value-of select="substring-after(.,'#')"/>
    </xsl:for-each>
  </xsl:key>
  <xsl:key name="localREFs" match="//@target[starts-with(.,'#')]">
    <xsl:for-each select="tokenize(.,'\s+')">
      <xsl:value-of select="substring-after(.,'#')"/>
    </xsl:for-each>
  </xsl:key>
  <!-- algorithm for DIV and LG depth here should match that for $myDepth in the -->
  <!-- template that matches <div>s and <lg>s in mode "work" -->
  <xsl:key name="DIVs-and-LGs-by-depth"
           match="//lg | //div | //div1 | //div2 | //div3 | //div4 | //div5 | //div6 | //div7"
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


<!-- 
  ~~ TEMPLATES, MATCHED
  -->

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
      <div class="tapas-generic { $defaultViewClass }">
        <xsl:call-template name="generate-toolbox"/>
        <div id="tapas-ref-dialog"/>
        <div id="tei_wrapper">
          <xsl:apply-templates mode="work"/>
        </div>
        <div id="tei_contextual">
          <xsl:copy-of select="$ogEntries"/>
        </div>
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
          <xsl:call-template name="generateHtmlHead"/>
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

<!--  GENERAL-PURPOSE COPY TEMPLATES  -->
  
  <xd:doc>
    <xd:desc>Template to omit processing instructions and comments from output.</xd:desc>
  </xd:doc>
  <xsl:template match="processing-instruction() | comment()" mode="work"/>

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
    <xsl:element name="{ tps:use-tag-name(.) }" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Copy all attribute nodes from source XML tree to
        output document.</xd:desc>
  </xd:doc>
  <xsl:template match="@*" mode="work TOCer makeTOCentry">
    <xsl:copy/>
  </xsl:template>

  <xd:doc>
    <xd:desc>@xml:id becomes @id. If the parent element needs an anchor to one or 
      more pointing notes, a data attribute is created to hold references to those 
      notes. This should only be used when the referencee doesn't point back to the 
      referencer in a way this stylesheet can handle (e.g. @corresp isn't tested).</xd:desc>
  </xd:doc>
  <xsl:template match="@xml:id" mode="work">
    <!-- copy @xml:id to @id, which browsers use for internal links. -->
    <xsl:attribute name="id">
      <xsl:call-template name="generate-unique-id">
        <xsl:with-param name="base" select="data(.)"/>
      </xsl:call-template>
      <!--<xsl:value-of select="concat($idPrefix,.)"/>-->
    </xsl:attribute>
    <xsl:attribute name="data-tapas-xmlid">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <!-- Get anything that targets this identifier. -->
    <xsl:variable name="referencedBySeq" select="key('localREFs',.)"/>
    <xsl:if test="count($referencedBySeq) gt 0">
      <!-- Are any referencing nodes <note>s? -->
      <xsl:variable name="referencedByNotes" select="$referencedBySeq[parent::note]"/>
      <!-- Does this element reference anything? (These will be handled elsewhere.) -->
      <xsl:variable name="referencesSeq" as="item()*">
        <xsl:variable name="tokens" 
          select="if ( ../@ref or ../@target ) then 
                    (../@ref | ../@target)/tokenize(.,'\s+') 
                  else ()"/>
        <xsl:variable name="allReferenced" as="item()*">
          <xsl:variable name="distinctTokens" select="distinct-values($tokens[starts-with(.,'#')])"/>
          <xsl:for-each select="$distinctTokens">
            <xsl:copy-of select="key('IDs',.)"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:copy-of select="$referencedByNotes except $allReferenced"/>
      </xsl:variable>
      <xsl:variable name="numTargets" select="count($referencesSeq)"/>
      <!-- Create a data attribute if any notes reference this identifier (without 
        being handled elsewhere). -->
      <xsl:if test="$numTargets gt 0">
        <!--<xsl:message select="concat(.,'—',$numTargets)"/>-->
        <xsl:attribute name="data-tapas-intermediary-targets">
          <xsl:for-each select="1 to $numTargets">
            <xsl:variable name="index" select="."/>
            <xsl:variable name="linkedNode" select="$referencesSeq[.]"/>
            <xsl:variable name="idref" 
              select="if ( $linkedNode/@xml:id ) then $linkedNode/@xml:id 
                      else generate-id($linkedNode)"/>
            <xsl:value-of select="concat('#',$idref)"/>
            <xsl:if test="$index ne $numTargets">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  
<!--  MAIN MODE (WORK)  -->
  
  <xd:doc>
    <xd:desc>Drop insignificant whitespace nodes.</xd:desc>
  </xd:doc>
  <xsl:template match=" text[descendant::c[matches(text(), '^\s$')]]
                          //text()[normalize-space(.) eq ''][not(parent::c)] 
                      | choice/text()[normalize-space(.) eq '']" mode="work"/>

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
    <span class="tapas-pb">
      <xsl:call-template name="set-reliable-attributes"/>
      <span class="tapas-page-num" data-tapas-n="{$pn}">
        <xsl:if test="@n">
          <xsl:attribute name="data-tei-n">
            <xsl:value-of select="@n"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:text> </xsl:text>
      </span>
      <xsl:if test="@facs">
        <span class="tapas-pb-facs">
          <a class="gallery-facs" rel="prettyPhoto[gallery1]">
            <xsl:attribute name="onclick">
              <xsl:value-of select="concat('Tapas.showFacs(',$apos,@n,$apos,',',$apos,@facs,$apos,',',$apos,$id,$apos,')')"/>
            </xsl:attribute>
            <img alt="{$altTextPbFacs}" class="tapas-thumbnail">
              <xsl:attribute name="src">
                <xsl:value-of select="@facs"/>
              </xsl:attribute>
            </img>
          </a>
        </span>
      </xsl:if>
    </span>
  </xsl:template>
  
  <xsl:template match="head" mode="work" priority="10">
    <tei-head class="heading">
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:apply-templates mode="#current"/>
    </tei-head>
  </xsl:template>
  
  <xsl:template match="gap | supplied | unclear" mode="work">
    <xsl:call-template name="create-mouseover-intervention"/>
  </xsl:template>
  
  <xsl:template match="choice" mode="work">
    <xsl:variable name="childrenSeq" select="*" as="item()*"/>
    <xsl:variable name="numChildren" select="count($childrenSeq)"/>
    <choice>
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:for-each select="1 to $numChildren">
        <xsl:variable name="currentIndex" select="."/>
        <xsl:variable name="siblingEntries" as="item()*">
          <xsl:if test="$currentIndex gt 1">
            <xsl:copy-of select="subsequence($childrenSeq, 1, $currentIndex - 1)"/>
          </xsl:if>
          <xsl:if test="$currentIndex lt $numChildren">
            <xsl:copy-of select="subsequence($childrenSeq, $currentIndex + 1)"/>
          </xsl:if>
        </xsl:variable>
        <xsl:apply-templates select="$childrenSeq[$currentIndex]" mode="#current">
          <xsl:with-param name="siblings" select="$siblingEntries"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </choice>
  </xsl:template>
  
  <xsl:template match="choice/*" mode="work"
    name="create-choice-intervention">
    <xsl:param name="siblings" as="node()*"/>
    <xsl:call-template name="create-mouseover-intervention">
      <xsl:with-param name="tooltip-content" as="xs:string*">
        <xsl:for-each select="$siblings">
          <xsl:variable name="useName">
            <xsl:variable name="base" select="local-name(.)"/>
            <xsl:value-of 
              select="concat( upper-case(substring($base,1,1)), substring($base,2) )"/>
          </xsl:variable>
          <xsl:value-of select="concat( $useName, ': &quot;', normalize-space(.), '&quot;' )"/>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="subst" mode="work">
    <xsl:call-template name="create-mouseover-intervention">
      <xsl:with-param name="gi-gloss">Substitution</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="@style | @html:style" mode="work">
    <xsl:variable name="result" select="normalize-space(.)"/>
    <xsl:value-of select="$result"/>
    <xsl:if test="substring($result,string-length($result),1) ne ';'">
      <xsl:text>; </xsl:text>
    </xsl:if>
  </xsl:template>

  <xd:doc>
    <xd:desc>Transforms each TEI <tt>&lt;ref></tt> or <tt>&lt;ptr></tt>
      to an HTML <tt>&lt;a></tt> (link) element.</xd:desc>
  </xd:doc>
  <xsl:template match="ref[@target] | ptr[@target]" mode="work" priority="99">
    <xsl:variable name="gi">
      <xsl:choose>
        <xsl:when test="normalize-space(.) eq ''">ptr</xsl:when>
        <xsl:otherwise>ref</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="targetContent" select="normalize-space(@target)"/>
    <xsl:variable name="count" as="xs:integer">
      <xsl:choose>
        <xsl:when test="starts-with($targetContent,'#')">
          <xsl:value-of select="count(//*[@xml:id eq substring-after($targetContent,'#')])"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="linkType" 
      select="if ( @data-tapas-target-warning eq 'target not found'
                or $count eq 0  and  starts-with($targetContent,'#') ) then 
                'notFound'
              else if ( $count eq 0 ) then
                'external'
              else if ( $count eq 1 ) then
                'local'
              else 'internals'"/>
    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="$linkType eq 'notFound'">
          <xsl:value-of select="concat($gi,'-not-found')"/>
        </xsl:when>
        <xsl:when test="$linkType eq 'external'">
          <xsl:value-of select="concat($gi,'-external')"/>
        </xsl:when>
        <xsl:when test="$linkType eq 'local'">
          <xsl:value-of select="concat($gi,'-', local-name(//*[@xml:id eq substring-after($targetContent,'#')]) )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($gi,'-internals')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a class="{$class}">
      <xsl:if test="$linkType ne 'local'">
        <xsl:attribute name="target" select="'_blank'"/>
      </xsl:if>
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:if test="$gi eq 'ptr'">
        <xsl:value-of select="$targetContent"/>
      </xsl:if>
    </a>
  </xsl:template>
  
  <xsl:template match="ref/@target | ptr/@target" mode="work">
    <xsl:attribute name="href">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Resolve certain types of links only from within the same document.</xd:desc>
  </xd:doc>
  <xsl:template match="@parts[parent::nym] 
                      | @ref | @target" mode="work">
    <xsl:if test="base-uri(.) eq $starterFile">
      <xsl:variable name="tokens" select="tokenize(.,'\s+')"/>
      <xsl:variable name="attrName" select="name()"/>
      <xsl:if test="count($tokens) gt 0">
        <xsl:if test="count($tokens) gt 1">
          <xsl:attribute name="data-tapas-anchors-extended" select="true()"/>
        </xsl:if>
        <xsl:call-template name="link-ref-among-refs">
          <xsl:with-param name="token" select="$tokens[1]"/>
          <xsl:with-param name="is-primary" select="true()"/>
        </xsl:call-template>
        <!--<xsl:for-each select="subsequence($tokens,2)">
          <xsl:call-template name="link-multiple-refs">
            <xsl:with-param name="token" select="."/>
          </xsl:call-template>
        </xsl:for-each>-->
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>For a given token in a whitespace-separated list of pointers, provide 
      linking functionality for the given element. If the token is considered 
      'primary' (the first pointer), the wrapper element will display in 
      intervention style as references to 'ography entries should. Subsequent tokens 
      are currently (2017-12-19) discarded, but should display as notes with 
      generated anchors.</xd:desc>
    <xd:param name="token">The string representing a single pointer.</xd:param>
    <xd:param name="attribute-name">The name of the attribute which led to this 
      template being called. Optional.</xd:param>
    <xd:param name="is-primary">A boolean value representing whether the input token 
      is the first pointer in the sequence. The default is false.</xd:param>
  </xd:doc>
  <xsl:template name="link-ref-among-refs">
    <xsl:param name="token" as="xs:string" required="yes"/>
    <xsl:param name="attribute-name" select="''" as="xs:string"/>
    <xsl:param name="is-primary" select="false()" as="xs:boolean"/>
    <xsl:variable name="isContextAttr" select=". instance of attribute()" as="xs:boolean"/>
    <xsl:variable name="ident" select="tps:generate-og-id($token)"/>
    <xsl:variable name="gotoentry" select="$ogEntries[@id eq $ident] or $ident = $input//@xml:id"/>
    <xsl:choose>
      <xsl:when test="$is-primary">
        <xsl:if test="$isContextAttr">
          <xsl:attribute 
            name="{ if ( $attribute-name ne '' ) then $attribute-name 
                    else if ( $isContextAttr ) then local-name() 
                    else 'ref' }" 
            select="concat('#',$ident)"/>
        </xsl:if>
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
      </xsl:when>
      <xsl:otherwise>
        <!-- This is not the primary reference link, so we can't add any more attributes to the parent element. -->
        <xsl:if test="$gotoentry">
          <xsl:call-template name="generate-note-marker">
            <xsl:with-param name="anchor-text" select="$token"/>
            <xsl:with-param name="idref" select="$ident"/>
            <xsl:with-param name="additional-classes" select="'misplaced-ref'"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>For hidden data that should be used to populate a dialog box, generate 
      a link to serve as an anchor to that information.</xd:desc>
    <xd:param name="idref">An identifier reference which should point to the 
      information to be placed in the dialog box.</xd:param>
    <xd:param name="anchor-text">A human-readable label, used as the content of the 
      anchor.</xd:param>
    <xd:param name="additional-classes">A sequence of text classnames to be placed 
      on the wrapper &lt;html:a&gt;. Optional.</xd:param>
  </xd:doc>
  <xsl:template name="generate-note-marker">
    <xsl:param name="idref" as="xs:string" required="yes"/>
    <xsl:param name="anchor-text" as="xs:string" required="yes"/>
    <xsl:param name="additional-classes" as="xs:string*"/>
    <xsl:variable name="classVal" 
      select="string-join(('note-marker', $additional-classes),' ')"/>
    <a class="{$classVal}">
      <xsl:variable name="ID">
        <!--<xsl:variable name="useID" 
          select="if ( . instance of node() ) then 
                    if ( exists(@xml:id) ) then 
                      @xml:id 
                    else generate-id()
                  else ."/>-->
        <xsl:call-template name="generate-unique-id">
          <xsl:with-param name="base" select="$idref"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:attribute name="href">
        <xsl:value-of select="concat('#', $idref)"/>
      </xsl:attribute>
      <xsl:value-of select="$anchor-text"/>
    </a>
  </xsl:template>

  <xd:doc>
    <xd:desc>Add an attribute explaining list layout to the CSS</xd:desc>
  </xd:doc>
  <xsl:template match="list" mode="work">
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <!-- special-case to handle P5 used to use rend= for type= of <list> -->
      <xsl:variable name="rend" select="normalize-space( @rend )"/>
      <xsl:if test="not( @type )  and  $rend = ('bulleted','ordered','simple','gloss')">
        <xsl:attribute name="type" select="$rend"/>
      </xsl:if>
      <xsl:call-template name="set-reliable-attributes"/>
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
  <xsl:template match="q[not(@style | @rend | @rendition)]
                 | quote[not(@style | @rend | @rendition)]" mode="work">
    <!-- BUG: should also be checking for a default <rendition> that applies -->
    <xsl:variable name="gi" select="local-name(.)"/>
    <!-- If preceding (non-whitespace only) text ends in whitespace, then -->
    <!-- this element should be inline. We are not using this test at the -->
    <!-- moment, only testing for chunky child elements. -->
    <!--<xsl:variable name="pre"
      select="(preceding-sibling::text()|preceding-sibling::*)
      [last()][self::text()][not(normalize-space(.)='')]"/>
    <xsl:variable name="must-be-inline" select="matches( $pre,'\s$')"/>-->
    <xsl:variable name="must-be-block" select="l | p | ab | table | floatingText | figure | list"/>
    <xsl:variable name="style">
      <xsl:choose>
        <xsl:when test="$must-be-block"> display: block; </xsl:when>
        <xsl:otherwise> display: inline; </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{ if ( $gi = 'q' ) then 'tei-q' else $gi }">
      <xsl:call-template name="set-reliable-attributes">
        <xsl:with-param name="additional-styles" select="$style" tunnel="yes"/>
      </xsl:call-template>
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
  <xsl:template match="lg[ not( ancestor::lg )] | div | div1 | div2 | div3 
                      | div4 | div5 | div6 | div7" mode="work">
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
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
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
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:apply-templates mode="#current"/>
      <xsl:if test="( $cnt mod 5 ) eq 0">
        <xsl:text>&#xA0;</xsl:text>
        <span class="poem-line-count">
          <xsl:value-of select="$cnt"/>
        </span>
      </xsl:if>
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
    <xsl:variable name="hasXmlID" select="exists(@xml:id)"/>
    <xsl:variable name="pointers" as="item()*">
      <xsl:for-each select="(@target | @corresp)">
        <xsl:variable name="tokens" as="xs:string*">
          <xsl:copy-of select="tokenize(.,'\s+')"/>
        </xsl:variable>
        <xsl:for-each select="$tokens">
          <xsl:if test="matches(., '^#') and key('IDs', replace(.,'^#',''), $input)">
            <xsl:value-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <!-- The note needs a generated anchor if:
            (1) the value of @anchored is considered to be true, and
            (2) the note is not linked to any other markup. -->
    <xsl:variable name="needsAnchor" as="xs:boolean"
      select="not(@anchored) or ( exists(@anchored) and @anchored = ('1', 'true') )"/>
    <xsl:variable name="needsGeneratedAnchor" as="xs:boolean"
      select="$needsAnchor and ( 
                not($hasXmlID) or 
                not(key('localREFs', normalize-space(@xml:id))) (:or 
                count($pointers) eq 0:) 
              )"/>
    <xsl:if test="$needsGeneratedAnchor">
      <xsl:call-template name="generate-note-marker">
        <xsl:with-param name="idref">
            <xsl:variable name="useID" 
              select="if ( $hasXmlID ) then @xml:id else generate-id()"/>
            <xsl:call-template name="generate-unique-id">
              <xsl:with-param name="base" select="$useID"/>
            </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="anchor-text" select="$noteNum"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="data-tapas-note-num">
        <xsl:value-of select="$noteNum"/>
      </xsl:attribute>
      <xsl:attribute name="data-tapas-anchored" select="$needsAnchor"/>
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:apply-templates mode="#current"/>
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
    <tei-figure>
      <xsl:call-template name="set-reliable-attributes"/>
      <img src="{graphic/@url}">
        <xsl:if test="figDesc">
          <xsl:attribute name="alt" select="wfn:mult_to_1(figDesc)"/>
        </xsl:if>
      </img>
      <xsl:apply-templates select="* except ( self::graphic, self::figDesc )" mode="#current"/>
    </tei-figure>
  </xsl:template>

  <xsl:template match="eg:egXML" mode="work">
    <xsl:element name="{local-name()}">
      <xsl:call-template name="set-reliable-attributes"/>
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


<!--  CONTEXTUAL INFORMATION  -->
  
  <xsl:template match="*[tps:is-list-like(.)]" mode="work">
    <div>
      <xsl:attribute name="class" select="'list-contextual'"/>
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:choose>
        <!-- Prefer headings that are the direct children of the 'ography. -->
        <xsl:when test="head">
          <xsl:attribute name="data-tapas-tocme" select="true()"/>
          <xsl:apply-templates select="head" mode="work"/>
        </xsl:when>
        <!-- Accept <head> when it occurs immediately before an 'ography, and there 
          are no following siblings of the 'ography to which the <head> might refer. 
          These have already been processed. -->
        <xsl:when test="preceding-sibling::*[1][self::head] and 
          ( not(following-sibling::*) or following-sibling::*[1][self::head] )">
          <!-- This list is only TOC-able if there are other preceding siblings 
            which are not <head>. -->
          <xsl:if test="preceding-sibling::*[not(self::head)]">
            <xsl:attribute name="data-tapas-tocme" select="true()"/>
          </xsl:if>
        </xsl:when>
        <!-- If there is no user-created <head>, generate one. -->
        <xsl:otherwise>
          <xsl:attribute name="data-tapas-tocme" select="true()"/>
          <span class="heading heading-listtype">
            <xsl:call-template name="set-label">
              <xsl:with-param name="is-field-label" select="false()"/>
            </xsl:call-template>
          </span>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="* except head" mode="og-gen">
        <xsl:with-param name="doc-uri" select="base-uri()" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <!-- 'ographies and entries we are currently not equipped to handle. -->
  <xsl:template match="custodialHist | listRef | listRelation | listTranspose" mode="work"/>
  
  <xsl:template match="head[following-sibling::*[not(self::head)][1][tps:is-list-like(.)]]" priority="30" mode="work">
    <tei-head class="heading heading-listtype">
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:apply-templates mode="#current"/>
    </tei-head>
  </xsl:template>
  
  
<!--  RENDITION2STYLE MODE  -->
  
  <xsl:template match="@rend" mode="rendition2style">
    <xsl:variable name="rendVal" select="normalize-space(.)"/>
    <!-- Try to categorize the use of @rend:
            * CSS,
            * rendition ladder, or
            * keyword.
    -->
    <xsl:variable name="rendType"
      select="if ( contains($rendVal, ':') ) then 'css'
              else if ( matches($rendVal, '[\w-]+\(.+\)') ) then 'rendladder'
              else 'keyword'"/>
    <xsl:variable name="rendSplit" 
      select="if ( $rendType eq 'rendladder' ) then 
                tokenize($rendVal, '\) ?')
              else tokenize($rendVal, ' ')" as="xs:string*"/>
    <xsl:variable name="css" as="xs:string*">
      <xsl:choose>
        <!-- @rend as CSS rule(s): output the rules without further intervention. -->
        <xsl:when test="$rendType eq 'css'">
          <xsl:value-of select="."/>
        </xsl:when>
        <!-- @rend as rendition ladder: do nothing. -->
        <xsl:when test="$rendType eq 'rendladder'">
          <!--<xsl:for-each select="$rendSplit">
            <!-\- Normalize casing on the current value, and remove insignificant 
              hyphens. -\->
            <xsl:variable name="thisVal">
              <xsl:variable name="lowercased" select="lower-case(.)"/>
              <xsl:value-of select="replace($lowercased, '(\w)-(\w)', '$1$2')"/>
            </xsl:variable>
            <xsl:variable name="ladderKey" select="substring-before($thisVal,'(')"/>
            <xsl:variable name="ladderVal" select="substring-after($thisVal,'(')"/>
            <xsl:choose>
              <xsl:when test="$ladderKey = ('align', 'textalign')"/>
              <xsl:when test="$ladderKey = ('case')"/>
              <xsl:when test="$ladderKey = ('color')"/>
              <xsl:when test="$ladderKey = ('columns')"/>
              <!-\-<xsl:when test="$ladderKey = ('firstindent')"></xsl:when>-\->
              <xsl:when test="$ladderKey = ('float')"/>
              <xsl:when test="$ladderKey = ('image')"/>
              <!-\-<xsl:when test="$ladderKey = ('indent')"></xsl:when>-\->
              <xsl:when test="$ladderKey = ('pos', 'position')"/>
              <xsl:when test="$ladderKey = ('slant')"/>
              <xsl:when test="$ladderKey = ('valign', 'verticalalign')"/>
              <xsl:otherwise/>
            </xsl:choose>
          </xsl:for-each>-->
        </xsl:when>
        
        <!-- @rend as keyword: resolve basic keywords. -->
        <xsl:otherwise>
          <xsl:for-each select="$rendSplit">
            <!-- Normalize casing on the current value, and remove insignificant hyphens. -->
            <xsl:variable name="thisVal">
              <xsl:variable name="lowercased" select="lower-case(.)"/>
              <xsl:value-of select="if ( $lowercased eq '-' ) then $lowercased
                                    else translate($lowercased, '-', '')"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$thisVal = ('above', 'over', 'sup', 'super', 'supralinear', 'superscript')"
                >vertical-align: super; font-size: 0.85em;</xsl:when>
              <xsl:when test="$thisVal = ('ac', 'allcaps', 'lgcaps')"
                >text-transform: uppercase;</xsl:when>
              <xsl:when test="$thisVal = ('aligncenter', 'alignedcenter', 'center', 'centered', 'textaligncenter')"
                >text-align: center;</xsl:when>
              <xsl:when test="$thisVal = ('alignleft', 'alignedleft', 'left', 'textalignleft')"
                >text-align: left;</xsl:when>
              <xsl:when test="$thisVal = ('alignright', 'alignedright', 'right', 'textalignright')"
                >text-align: right;</xsl:when>
              <xsl:when test="$thisVal = ('b', 'bold', 'bolded')"
                >font-weight: bold;</xsl:when>
              <xsl:when test="$thisVal = ('below', 'sub', 'sublinear', 'subscript', 'under')"
                >vertical-align: sub; font-size: 0.85em;</xsl:when>
              <xsl:when test="$thisVal = ('block')"
                >display: block;</xsl:when> <!-- 'blockquote'? -->
              <!--<xsl:when test="$thisVal = ('border', 'bordered')"
                >border: thin solid gray;</xsl:when>-->
              <xsl:when test="$thisVal = ('crossout', 'strike', 'strikethrough')"
                >text-decoration: line-through;</xsl:when>
              <!-- distinct? -->
              <xsl:when test="$thisVal = ('hidden', 'hide')"
                >display: none;</xsl:when>
              <xsl:when test="$thisVal = ('i', 'ital', 'italic', 'italics', 'italicized')"
                >font-style: italic;</xsl:when>
              <xsl:when test="$thisVal = ('inline')"
                >display: inline;</xsl:when>
              <xsl:when test="$thisVal = ('large', 'larger', '+')"
                >font-size: large;</xsl:when>
              <!-- overstrike, overwrite, overwritten... strikethrough? -->
              <!-- quote, quotes, quoted -->
              <xsl:when test="$thisVal = ('regular')"
                >font-weight: normal;</xsl:when>
              <xsl:when test="$thisVal = ('sc', 'smallcap', 'smallcaps', 'smcaps')"
                >font-variant: small-caps;</xsl:when>
              <xsl:when test="$thisVal = ('small', 'smaller', '-')"
                >font-size: small;</xsl:when>
              <!--<xsl:when test="$thisVal = ('space', 'spacebreak')"
                >display: block; margin: 0.4em 0;</xsl:when>-->
              <xsl:when test="$thisVal = ('underline', 'underlined', 'underscore', 'underscored')"
                >text-decoration: underline;</xsl:when>
              <xsl:when test="$thisVal = ('upright')"
                >font-style: normal;</xsl:when>
              <xsl:when test="$thisVal = ('visible')"
                >display: initial;</xsl:when>
              
              <!--<xsl:when test="$thisVal eq 'blockquote'"       >display: block; padding: 0em 1em;</xsl:when>
              <xsl:when test="$thisVal eq 'indent'"           ></xsl:when>
              <xsl:when test="$thisVal eq 'overstrike'"       >text-decoration: overline;</xsl:when>
              <xsl:when test="$thisVal eq 'spaced'"           >font-stretch: wider;</xsl:when>
              <xsl:when test="$thisVal eq 'typescript'"       ></xsl:when>-->
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Join the generated CSS rules with whitespace between. -->
    <xsl:value-of select="string-join($css,' ')"/>
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
  
  
<!--  STRING MODE  -->
  
  <xsl:template match="persName | placeName | orgName" mode="string">
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
  
  <xsl:template match="text()" mode="string">
    <!-- regularize the whitespace, but leave leading or trailing iff present -->
    <xsl:variable name="mePlus" select="normalize-space( concat('␀',.,'␀') )"/>
    <xsl:variable name="regularized" select="substring( $mePlus, 2, string-length( $mePlus ) -2 )"/>
    <xsl:value-of select="$regularized"/>
  </xsl:template>
  
  <xsl:template match="*" mode="string">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Some of the mode "string" templates have to match in both namespaces,
    as I'm overloading use of this mode for both ogrophy processing (which happens
    in pass 1 on TEI data) and TOC processing (which happens in pass 2 on XHTML
    data).</xd:desc>
  </xd:doc>
  <xsl:template match="choice | html:choice" mode="string">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="cb | gb | lb | pb | milestone | html:cb | html:gb | html:lb | html:pb | html:milestone" mode="string">
    <xsl:text>&#x20;</xsl:text>
  </xsl:template>
  
  <xsl:template match="fw | html:fw" mode="string"/>
  
  
<!--  ATT-INTERVENTION MODE  -->
  
  <xsl:template match="@*" mode="att-intervention" priority="-4"/>
  
  <xsl:template match="@extent" mode="att-intervention">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="*[not(@extent)]/@quantity" mode="att-intervention">
    <xsl:variable name="gloss">
      <xsl:value-of select="."/>
      <xsl:if test="../@unit">
        <xsl:text> </xsl:text>
        <xsl:value-of select="../@unit"/>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="$gloss"/>
  </xsl:template>
  
  <xsl:template match="@reason" mode="att-intervention">
    <xsl:value-of select="concat('Reason: ',.)"/>
  </xsl:template>
  
  
<!--  POSTPROCESSING (TOC MODES)  -->
  
  <xd:doc>
    <xd:desc>Copy nodes over</xd:desc>
  </xd:doc>
  <xsl:template match="node()" mode="TOCer makeTOCentry">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Generate a table of contents, if needed</xd:desc>
  </xd:doc>
  <xsl:template match="html:div[ @class[ starts-with(., 'tapas-generic') ] ]" mode="TOCer">
    <xsl:copy>
      <xsl:apply-templates mode="TOCer" select="@*"/>
      <xsl:apply-templates mode="TOCer"
                           select="html:div[ @id = ('tapasToolbox','tapas-ref-dialog') ]"/>
        <div id="TOC">
          <ol>
            <xsl:apply-templates select=".//*[@data-tapas-tocme]" mode="makeTOCentry"/>
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
        <xsl:number level="multiple" count="html:*[@data-tapas-tocme]"
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
            <xsl:when test="html:*[ @data-tapas-gi eq 'head' ]
                          | html:*[ contains(@class, 'heading') ]">
              <xsl:attribute name="class" select="'TOC-entry-heading'"/>
              <xsl:apply-templates mode="string"
                select="html:*[ @data-tapas-gi eq 'head' ]
                      | html:*[ contains(@class, 'heading') ]"/>
            </xsl:when>
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
    <xd:desc>Don't show any TOC entries that may have been flagged in the &lt;teiHeader&gt;</xd:desc>
  </xd:doc>
  <xsl:template match="html:teiHeader//*[@data-tapas-tocme]" mode="makeTOCentry" priority="11"/>


<!-- 
  ~~ TEMPLATES, NAMED
  -->

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
    <xsl:param name="additional-styles" as="xs:string*" tunnel="yes"/>
    <xsl:variable name="actionableStyles" as="xs:string*"
      select="$additional-styles[normalize-space(.) ne '']"/>
    <xsl:apply-templates select="@rendition" mode="#current"/>
    <xsl:if test="exists($actionableStyles) or @rend or @style or @html:style">
      <xsl:attribute name="style">
        <xsl:apply-templates select="@rend" mode="rendition2style"/>
        <xsl:apply-templates select="@style" mode="#current"/>
        <xsl:apply-templates select="@html:style" mode="#current"/>
        <xsl:if test="count($actionableStyles) gt 0">
          <xsl:for-each select="$actionableStyles">
            <xsl:variable name="normalized" select="normalize-space(.)"/>
            <xsl:value-of select="if ( ends-with($normalized, ';') ) then $normalized
                                  else concat($normalized, ';')"/>
          </xsl:for-each>
        </xsl:if>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="generateHtmlHead">
    <head>
      <meta charset="UTF-8"></meta>
      <xsl:call-template name="generate-html-title"/>
      <xsl:choose>
        <xsl:when test="$lessSide eq 'client'">
          <link rel="stylesheet/less" type="text/css" href="{$less}"></link>
          <script src="{$lessJS}" type="text/javascript"></script>
        </xsl:when>
        <xsl:otherwise>
          <link rel="stylesheet" type="text/css" href="{$view.generic}"></link>
          <link rel="stylesheet" type="text/css" href="{$view.diplo}"></link>
          <link rel="stylesheet" type="text/css" href="{$view.norma}"></link>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Javascript -->
      <script type="text/javascript" src="{$jqueryJS}"></script>
      <script type="text/javascript" src="{$jqueryUIJS}"></script>
      <script type="text/javascript" src="{$jqueryBlockUIJS}"></script>
      <script type="text/javascript" src="{$contextualJS}"></script>
      <link rel="stylesheet" href="{$jqueryUIcss}"></link>
      <script type="text/javascript" src="{$genericJS}"></script>
      <!-- CSS -->
      <xsl:variable name="rendStyles">
        <xsl:call-template name="rendition2style"/>
      </xsl:variable>
      <xsl:if test="normalize-space($rendStyles) ne ''">
        <style type="text/css">
          <xsl:copy-of select="$rendStyles"/>
        </style>
      </xsl:if>
      <!-- Create CSS rules based on TEI document definitions -->
      <xsl:call-template name="tagUsage2style"/>
      <xsl:call-template name="rendition2style"/>
    </head>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Represent the current element as accurately as possible, but also 
      create an explanation of what the element is. This is especially important for 
      transcriptional markers like &lt;gap> and for children of &lt;choice>.</xd:desc>
    <xd:param name="content">The content of the current element. Defaults to 
      applying templates in the current mode.</xd:param>
    <xd:param name="gi-gloss">The label or term used to gloss the current element. 
      Defaults to the name of the element, with the first letter capitalized.</xd:param>
    <xd:param name="tooltip-content">The text to use in a tooltip when the current 
      element (as represented in HTML) is moused-over or tabbed to. The default is 
      the $gi-gloss, followed by any useful information in the attributes of the 
      current element.</xd:param>
  </xd:doc>
  <xsl:template name="create-mouseover-intervention">
    <xsl:param name="content" as="node()*">
      <xsl:apply-templates mode="#current"/>
    </xsl:param>
    <xsl:param name="gi-gloss" as="xs:string">
      <xsl:variable name="firstLetter"
        select="upper-case(substring(local-name(.),1,1))"/>
      <xsl:value-of 
        select="concat($firstLetter,substring(local-name(.),2))"/>
    </xsl:param>
    <xsl:param name="tooltip-content" as="xs:string*">
      <xsl:apply-templates select="@*" mode="att-intervention"/>
    </xsl:param>
    <xsl:variable name="tooltipPhrases" as="xs:string*">
      <xsl:for-each select="( $gi-gloss, $tooltip-content )">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:element name="{ tps:use-tag-name(.) }">
      <xsl:call-template name="set-reliable-attributes"/>
      <xsl:if test="count($tooltipPhrases[. ne '']) gt 0">
        <xsl:attribute name="data-tapas-tooltip">
          <xsl:copy-of select="string-join($tooltipPhrases,'. ')"/>
          <xsl:text>.</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="tabindex" select="0"/>
      <xsl:if test="$content">
        <xsl:copy-of select="$content"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  
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

  <xsl:template name="generate-html-title">
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
  
  <xsl:template name="generate-toolbox">
    <div id="tapasToolbox">
      <!--<div id="tapasToolbox-pb">
        <label for="pbToggle">Hide page breaks</label>
        <input type="checkbox" id="pbToggle"></input>
      </div>-->
      <div id="tapasToolbox-views">
        <label for="viewBox">Views</label>
        <select id="viewBox">
          <!-- this <select> used to have on[cC]hange="switchThemes(this);", but -->
          <!-- that was incorporated into the javascript 2014-04-20 by PMJ. -->
          <option value="diplomatic">
            <xsl:if test="$defaultViewClass eq 'diplomatic'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>diplomatic</xsl:text>
          </option>
          <option value="normal">
            <xsl:if test="$defaultViewClass eq 'normal'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>normalized</xsl:text>
          </option>
        </select>
      </div>
    </div>
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

  <xsl:template name="grab-css">
    <xsl:param name="rendition-id"/>
    <xsl:value-of select="normalize-space(key('IDs',$rendition-id)/text())"/>
  </xsl:template>
  
  <xsl:template name="rendition2style">
    <xsl:apply-templates select="//rendition" mode="rendition2style"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Resolve attributes for a given element.</xd:desc>
  </xd:doc>
  <xsl:template name="set-reliable-attributes">
    <xsl:call-template name="addID"/>
    <xsl:call-template name="save-gi"/>
    <xsl:call-template name="addRend"/>
    <xsl:apply-templates select="@* except ( @rend, @rendition, @style, @ref, @target )" mode="#current"/>
    <xsl:apply-templates select="@ref | @target" mode="#current"/>
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


<!-- 
  ~~ FUNCTIONS
  -->
  
  <xd:doc>
    <xd:desc>Test if an input element has a name that matches an HTML tag.</xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:is-htmlish-tag" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:variable name="useName" select="$element/lower-case(local-name(.))"/>
    <xsl:value-of 
      select="$useName =  (
                            'a', 'abbr', 'acronym', 'address', 'applet', 'area', 
                            'article', 'aside', 'audio', 'b', 'base', 'basefont', 
                            'bdi', 'bdo', 'bgsound', 'big', 'blink', 
                            'blockquote', 'body', 'br', 'button', 'canvas', 
                            'caption', 'center', 'cite', 'code', 'col', 
                            'colgroup', 'command', 'content', 'data', 'datalist', 
                            'dd', 'del', 'details', 'dfn', 'dialog', 'dir', 
                            'dl', 'dt', 'element', 'em', 'embed', 'fieldset', 
                            'figcaption', 'figure', 'font', 'footer', 'form', 
                            'frame', 'frameset', 'head', 'header', 'hgroup', 
                            'hr', 'html', 'i', 'iframe', 'image', 'img', 'input', 
                            'ins', 'isindex', 'kbd', 'keygen', 'label', 'legend', 
                            'li', 'link', 'listing', 'main', 'map', 'mark', 
                            'marquee', 'menu', 'menuitem', 'meta', 'meter', 
                            'multicol', 'nav', 'nobr', 'noembed', 'noframes', 
                            'noscript', 'object', 'ol', 'optgroup', 'option', 
                            'output', 'param', 'picture', 'plaintext', 'pre', 
                            'progress', 'q', 'rp', 'rt', 'rtc', 'ruby', 's', 
                            'samp', 'script', 'section', 'select', 'shadow', 
                            'slot', 'small', 'source', 'spacer', 'span', 
                            'strike', 'strong', 'style', 'sub', 'summary', 'sup', 
                            'table', 'tbody', 'td', 'template', 'textarea', 
                            'tfoot', 'th', 'thead', 'time', 'title', 'tr', 
                            'track', 'tt', 'u', 'ul', 'var', 'video', 'wbr', 
                            'xmp'
                          )
              (:  SPECIAL CASES  :)
              or ( $useName = ('p', 'div') and $element[ancestor::*:p] )"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Get the name to use for the output (HTML) element. Any input (TEI) 
      element that could be confused for HTML has 'tei-' prepended to its name.</xd:desc>
    <xd:param name="element">The element for which a name should be created.</xd:param>
  </xd:doc>
  <xsl:function name="tps:use-tag-name" as="xs:string">
    <xsl:param name="element" as="element()"/>
    <xsl:variable name="localName" select="local-name($element)"/>
    <xsl:value-of select="if ( tps:is-htmlish-tag($element) ) then
                            concat('tei-', $localName)
                          else $localName"/>
  </xsl:function>
  
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
