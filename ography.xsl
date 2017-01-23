<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:eg="http://www.tei-c.org/ns/Examples"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:wfn="http://www.wwp.northeastern.edu/ns/functions"
  xmlns:tps="http://tapas.northeastern.edu"
  exclude-result-prefixes="#all">

  <xsl:output method="xhtml"/>
  
  
  <!-- PARAMETERS -->
  
  <xsl:param name="assetsPrefix" select="'../'"/>
  
  
  <!-- KEYS -->
  
  <xsl:key name="OGs" 
    match="//*[@ref][ self::name | self::orgName | self::persName | self::placeName | self::rs | self::title ]" 
    use="substring-before(@ref,'#')"/>
  
  
  <!-- GLOBAL VARIABLES -->
  
  <xsl:variable name="labelMap" as="item()*">
    <entry key="addName"        >additional name</entry>
    <entry key="bibl"           >citation</entry>
    <entry key="birth"          >born</entry>
    <entry key="castGroup"      >Cast List Grouping</entry>
    <entry key="castItem"       >cast list entry</entry>
    <entry key="castList"       >Cast List</entry>
    <entry key="death"          >died</entry>
    <entry key="genName"        >general name component</entry>
    <entry key="geo"            >geographical coordinates</entry>
    <entry key="geogFeat"       >geographical feature</entry>
    <entry key="geogName"       >geographical name</entry>
    <entry key="langKnowledge"  >language knowledge</entry>
    <entry key="listBibl"       >Bibliography</entry>
    <entry key="listEvent"      >List of Events</entry>
    <entry key="listNym"        >List of Canonical Names</entry>
    <entry key="listOrg"        >List of Organizations</entry>
    <entry key="listPerson"     >List of Persons</entry>
    <entry key="listPlace"      >List of Places</entry>
    <entry key="nameLink"       >name link</entry>
    <entry key="org"            >organization</entry>
    <entry key="orgName"        >organization name</entry>
    <entry key="persName"       >personal name</entry>
    <entry key="personGrp"      >personal group</entry>
    <entry key="placeName"      >place name</entry>
    <entry key="pubPlace"       >publication place</entry>
    <entry key="roleName"       >role</entry>
    <entry key="socecStatus"    >socio-economic status</entry>
  </xsl:variable>
  
  <xsl:variable name="ogMap" as="item()*">
    <xsl:variable name="uris" 
      select="/TEI/text
              //*[ self::name | self::orgName | self::persName | self::placeName | self::rs | self::title ][@ref]
              /@ref/substring-before(normalize-space(.),'#')"/>
    <xsl:variable name="distinctURIs" select="for $uri in distinct-values($uris) return $uri"/>
    <!-- 'Ography entries located in the local TEI document are always identified with 
      the prefix 'og0'. -->
    <xsl:for-each-group select="$distinctURIs" group-by="if ( . eq '' ) then 0 else 1">
      <xsl:sort select="current-grouping-key()"/>
      <xsl:for-each select="current-group()">
        <xsl:variable name="uri" select="."/>
        <xsl:variable name="num" select="if ( $uri eq '' ) then 0 else position()"/>
        <!-- Only resolve entries where the document is local (the same TEI file as the 
          rest of the input), or if the document is TEI and available for parsing. -->
        <xsl:if test="$uri eq '' or ( doc-available($uri) and doc($uri)/TEI )">
          <entry key="{$uri}">og<xsl:value-of select="$num"/></entry>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each-group>
  </xsl:variable>
  
  <xsl:variable name="ogEntries" as="item()*">
    <xsl:variable name="distinctURIs" select="$ogMap/@key"/>
    <xsl:variable name="pass1" as="item()*">
      <xsl:call-template name="get-entries">
        <xsl:with-param name="docs" select="$distinctURIs"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy-of select="$pass1"/>
  </xsl:variable>
  
  
  <!-- FUNCTIONS -->
  
  <xsl:function name="tps:generate-og-id" as="xs:string?">
    <xsl:param name="idref" as="xs:string"/>
    <xsl:variable name="refSeq" select="tokenize($idref,'#')"/>
    <xsl:variable name="prefix" select="tps:get-og-prefix($refSeq[1])"/>
    <!-- Because this function may be used while making 'ography entries, no testing 
      is done on whether or not the referenced entry actually exists. -->
    <xsl:value-of select="if ( $prefix ) then
                            if ( $prefix eq 'og0' ) then $refSeq[2]
                            else concat($prefix,'-',$refSeq[2])
                          else ()"/>
  </xsl:function>
  
  <xsl:function name="tps:get-og-prefix" as="xs:string?">
    <xsl:param name="filename" as="xs:string"/>
    <xsl:value-of select="$ogMap[@key eq $filename]"/>
  </xsl:function>
  
  <xsl:function name="tps:is-desc-like" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:value-of select="exists($element
                                  [ self::desc | self::note | self::p | self::roleDesc ]
                                )"/>
  </xsl:function>
  
  <xsl:function name="tps:is-og-entry" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:value-of select="exists($element
                                  [ (self::bibl | self::biblStruct)[parent::listBibl] 
                                  | self::event[parent::listEvent]
                                  | self::org[parent::listOrg]
                                  | (self::person | self::personGrp)[parent::listPerson]
                                  | self::place[parent::listPlace] ]
                                )"/>
  </xsl:function>
  
  
  <!-- TEMPLATES -->
  
  <xsl:template match="/TEI">
    <html>
      <head>
        <title>
          <xsl:value-of select="normalize-space(descendant::teiHeader/fileDesc/titleStmt/title)"/>
        </title>
        <link id="maincss" rel="stylesheet" type="text/css" href="{concat($assetsPrefix,'css/tapasGdiplo.css')}"></link>
        <script type="application/javascript" src="{concat($assetsPrefix,'js/jquery/jquery.min.js')}"/>
        <script type="application/javascript" src="{concat($assetsPrefix,'js/jquery-ui/ui/minified/jquery-ui.min.js')}"/>
        <script type="application/javascript" src="{concat($assetsPrefix,'js/jquery/plugins/jquery.blockUI.js')}"/>
        <script type="application/javascript" src="{concat($assetsPrefix,'js/contextualItems.js')}"/>
        <script type="application/javascript" src="{concat($assetsPrefix,'js/tapas-generic.js')}"/>
        <style type="text/css">
          <![CDATA[
            .contextualItem {
              padding: 1.4em 0 1em;
              border-bottom: thin solid lightgray;
              width: 600px;
            }
            .contextualItem .metadata {
              margin: 0 2em;
            }
            [data-tapas-ogref] {
              background-color: limegreen;
            }
          ]]>
        </style>
      </head>
      <body style="width: 100%;">
        <div class="tapas-generic">
          <div>
            <xsl:copy-of select="$ogEntries"/>
            <!--<xsl:value-of select="$labelMap[@key eq 'bibl']"/>-->
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <!-- Modify the names of <head> and <title>, since HTML has different expectations 
    for elements with those names. -->
  <xsl:template match="head | title" mode="og-entry work">
    <xsl:param name="entryHeading" select="''" tunnel="yes"/>
    <xsl:choose>
      <!-- If the current node exactly matches the heading of an 'ography entry (and 
        has no child elements), suppress it. -->
      <xsl:when test="$entryHeading ne '' and $entryHeading eq normalize-space(.) and not(*)"/>
      <xsl:otherwise>
        <xsl:element name="tei-{local-name()}">
          <xsl:call-template name="get-attributes"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- MODES: 'OGRAPHY GENERATION -->
  
  <xsl:template match="text()" mode="og-gen" priority="-10"/>
  
  <xsl:template match="*" mode="og-entry" priority="-50">
    <xsl:element name="{local-name()}">
      <xsl:call-template name="get-attributes"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*" mode="og-gen og-entry" name="make-data-attr" priority="-20">
    <xsl:attribute name="data-tapas-{name()}" select="data(.)"/>
  </xsl:template>
  
  <xsl:template match="*[tps:is-og-entry(.)]" mode="og-gen">
    <xsl:param name="doc-uri" as="xs:string" tunnel="yes"/>
    <xsl:param name="idrefs" as="xs:string*" tunnel="yes"/>
    <xsl:if test="count($idrefs) eq 0 or @xml:id = $idrefs">
      <div class="contextual-item {local-name()}">
        <xsl:call-template name="save-gi"/>
        <xsl:apply-templates select="@*" mode="#current">
          <xsl:with-param name="doc-uri" select="$doc-uri" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:variable name="header">
          <xsl:apply-templates mode="og-head"/>
        </xsl:variable>
        <span class="heading heading-og">
          <xsl:value-of select="$header"/>
        </span>
        <!-- Display metadata first, then contextual <note>s and <p>s. -->
        <div class="og-entry">
          <div class="og-metadata">
            <xsl:apply-templates select="*[not(tps:is-desc-like(.))]" mode="og-entry">
              <xsl:with-param name="entryHeading" select="$header" tunnel="yes"/>
            </xsl:apply-templates>
          </div>
          <div class="og-context">
            <xsl:apply-templates select="*[tps:is-desc-like(.)]" mode="og-entry"/>
          </div>
        </div>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@xml:id" mode="og-gen og-entry">
    <xsl:param name="doc-uri" as="xs:string" tunnel="yes"/>
    <xsl:variable name="id" select="data(.)"/>
    <xsl:variable name="ns" select="tps:get-og-prefix($doc-uri)"/>
    <xsl:attribute name="id" select="if ( $ns eq 'og0' ) then $id 
                                     else concat($ns,'-',$id)"/>
  </xsl:template>
  
  <xsl:template match="@ref" mode="og-gen og-entry">
    <xsl:param name="doc-uri" as="xs:string" tunnel="yes"/>
    <!-- Make a standard data attribute for the @ref. -->
    <xsl:call-template name="make-data-attr"/>
    <!-- As a temporary (?) measure, don't resolve any nested 'ography references 
      unless the current entry occurs within the input TEI document. -->
    <xsl:if test="$doc-uri eq ''">
      <!-- If there's an 'ography mapped to the base URI, add @data-tapas-ogref. -->
      <xsl:variable name="ogRef" select="tps:generate-og-id(.)">
      </xsl:variable>
      <xsl:if test="$ogRef">
        <xsl:attribute name="data-tapas-ogref">
          <xsl:value-of select="concat('#',$ogRef)"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[@xml:id or self::persName]/*" mode="og-entry" priority="-20">
    <xsl:param name="entryHeading" select="''" tunnel="yes"/>
    <xsl:variable name="me" select="local-name(.)"/>
    <xsl:choose>
      <!-- If the current node exactly matches the heading of an 'ography entry (and 
        has no child elements), suppress it. -->
      <xsl:when test="$entryHeading ne '' and $entryHeading eq normalize-space(.) and not(*)"/>
      <xsl:otherwise>
        <xsl:element name="{$me}">
          <xsl:call-template name="get-attributes"/>
          <xsl:attribute name="class" select="'og-metadata-item'"/>
          <xsl:element name="label">
            <xsl:call-template name="set-label"/>
          </xsl:element>
          <xsl:text> </xsl:text>
          <xsl:apply-templates mode="#current"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="note[not(@xml:id) or not(@xml:id = key('OGs','')/@ref/substring-after(data(.),'#'))]" mode="og-entry">
    <xsl:element name="{local-name()}">
      <xsl:call-template name="get-attributes"/>
      <xsl:attribute name="data-tapas-anchored" select="'false'"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  
  <!-- MODE: 'OGRAPHY HEADING -->
  
  <xsl:template match="* | text()" mode="og-head" priority="-30"/>
  
  <xsl:template match="bibl/title[@type eq 'main' or position() eq 1] 
                      | head
                      | org/orgName[@type eq 'main' or position() eq 1] 
                      | person/persName[@type eq 'main' or position() eq 1] 
                      | place/placeName[@type eq 'main' or position() eq 1]" mode="og-head">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="biblStruct/analytic/title[@type eq 'main' or position() eq 1]" mode="og-head">
    <xsl:value-of select="concat('“',normalize-space(.),'”—')"/>
  </xsl:template>
  
  <xsl:template match="biblStruct/monogr/title[@type eq 'main' or position() eq 1]" mode="og-head">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  
  <!-- SUPPLEMENTAL TEMPLATES -->
  
  <!-- Apply templates on attributes. -->
  <xsl:template name="get-attributes">
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:call-template name="save-gi"/>
  </xsl:template>
  
  <!-- Create 'ography entries for external references. -->
  <xsl:template name="get-entries">
    <xsl:param name="docs" as="xs:string*"/>
    <xsl:variable name="doc" select="$docs[1]"/>
    <xsl:variable name="refs" select="key('OGs',$doc)"/>
    <xsl:variable name="distinctTargets" select="distinct-values($refs/@ref/substring-after(.,'#'))"/>
    <xsl:variable name="entries" select="if ( $doc eq '' ) then () else doc($doc)"/>
    <xsl:apply-templates select="$entries" mode="og-gen">
      <xsl:with-param name="doc-uri" select="$doc" tunnel="yes"/>
      <xsl:with-param name="idrefs" select="$distinctTargets" tunnel="yes"/>
    </xsl:apply-templates>
    <!-- If $docs has more than one URI in it, strip out $doc (which this template 
      just resolved) and run this template again on the subset. -->
    <xsl:if test="count($docs) gt 1">
      <xsl:text> </xsl:text>
      <xsl:call-template name="get-entries">
        <xsl:with-param name="docs" select="subsequence($docs,2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!-- Create a data attribute to store the name of the current TEI element. -->
  <xsl:template name="save-gi">
    <xsl:attribute name="data-tapas-gi" select="local-name(.)"/>
  </xsl:template>
  
  <!-- Generate a metadata label using the current element context. No wrapper is 
    added, so that this template can be used to create 'ography headings as well. -->
  <xsl:template name="set-label">
    <xsl:param name="is-header" as="xs:boolean" select="false()"/>
    <xsl:variable name="me" select="local-name()"/>
    <xsl:value-of select="if ( $me = $labelMap/@key ) then
                            $labelMap[@key eq $me]/normalize-space(.)
                          else $me"/>
    <xsl:if test="@type">
      <xsl:text>, </xsl:text>
      <xsl:value-of select="@type"/>
    </xsl:if>
    <xsl:if test="not($is-header)">
      <xsl:text>: </xsl:text>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>