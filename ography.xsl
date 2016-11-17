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
  <xsl:key name="OGs" match="//*[self::name | self::orgName | self::persName | self::placeName | self::rs ][@ref]" 
    use="substring-before(@ref,'#')"/>
  
  <!-- GLOBAL VARIABLES -->
  <xsl:variable name="ogMap" as="item()*">
    <xsl:variable name="uris" select="/TEI/text
                                      //*[self::name | self::orgName | self::persName | self::placeName | self::rs ][@ref]
                                      /@ref/substring-before(normalize-space(.),'#')"/>
    <xsl:variable name="distinctURIs" select="for $uri in distinct-values($uris) return $uri"/>
    <!-- 'ography entries located in the local TEI document are always identified with the prefix 'og0'. -->
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
    <xsl:call-template name="get-entries">
      <xsl:with-param name="docs" select="$distinctURIs"/>
    </xsl:call-template>
  </xsl:variable>
  
  
  <!-- FUNCTIONS -->
  <xsl:function name="tps:get-og-prefix" as="xs:string?">
    <xsl:param name="filename" as="xs:string"/>
    <xsl:value-of select="$ogMap[@key eq $filename]"/>
  </xsl:function>
  
  <xsl:function name="tps:make-ography-ref" as="xs:string?">
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
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template name="get-entries">
    <xsl:param name="docs" as="xs:string*"/>
    <xsl:variable name="doc" select="$docs[1]"/>
    <xsl:variable name="refs" select="key('OGs',$doc)"/>
    <xsl:variable name="distinctTargets" select="distinct-values($refs/@ref/substring-after(.,'#'))"/>
    <xsl:variable name="entries" select="if ( $doc eq '' ) then //*[@xml:id] else doc($doc)"/>
    <xsl:apply-templates select="$entries" mode="og-gen">
      <xsl:with-param name="doc-uri" select="$doc" tunnel="yes"/>
      <xsl:with-param name="idrefs" select="$distinctTargets" tunnel="yes"/>
    </xsl:apply-templates>
    <!-- If $docs has more than one URI in it, strip out $doc (just resolved) and 
      run this template again with the subset. -->
    <xsl:if test="count($docs) gt 1">
      <xsl:text> </xsl:text>
      <xsl:call-template name="get-entries">
        <xsl:with-param name="docs" select="subsequence($docs,2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text()" mode="og-gen" priority="-10"/>
  
  <xsl:template match="*[@xml:id]" mode="og-gen">
    <xsl:param name="doc-uri" as="xs:string" tunnel="yes"/>
    <xsl:param name="idrefs" as="xs:string*" tunnel="yes"/>
    <xsl:if test="@xml:id = $idrefs">
      <div class="contextualItem {local-name()}">
        <xsl:apply-templates select="@*" mode="#current">
          <xsl:with-param name="doc-uri" select="$doc-uri" tunnel="yes"/>
        </xsl:apply-templates>
        <!-- Display metadata first, then contextual <note>s and <p>s. -->
        <div class="metadata">
          <xsl:apply-templates select="* except ( note | p )" mode="og-entry"/>
        </div>
        <div class="context">
          <xsl:apply-templates select="note | p" mode="og-entry"/>
        </div>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*" mode="og-entry" priority="-20">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*" mode="og-gen og-entry" name="make-data-attr" priority="-20">
    <xsl:attribute name="data-tapas-{name()}" select="data(.)"/>
  </xsl:template>
  
  <xsl:template match="@xml:id" mode="og-gen og-entry">
    <xsl:param name="doc-uri" as="xs:string" tunnel="yes"/>
    <xsl:variable name="id" select="data(.)"/>
    <xsl:variable name="ns" select="tps:get-og-prefix($doc-uri)"/>
    <xsl:attribute name="id" select="if ( $ns eq 'og0' ) then $id 
                                     else concat($ns,'-',$id)"/>
  </xsl:template>
  
  <xsl:template match="@ref" mode="og-gen og-entry">
    <!-- Make a standard data attribute for the @ref. -->
    <xsl:call-template name="make-data-attr"/>
    <!-- If there's an 'ography mapped to the base URI, add @data-tapas-ogref. -->
    <xsl:variable name="ogRef" select="tps:make-ography-ref(.)">
    </xsl:variable>
    <xsl:if test="$ogRef">
      <xsl:attribute name="data-tapas-ogref">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$ogRef"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[@xml:id]/*" mode="og-entry">
    <p data-tapas-element="{local-name()}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>
  
</xsl:stylesheet>