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
  <xsl:variable name="ogEntries" as="item()*">
    <xsl:variable name="refs" select="/TEI/text//*[self::name | self::orgName | self::persName | self::placeName | self::rs ][@ref]/@ref/substring-before(normalize-space(.),'#')"/>
    <xsl:variable name="distinctRefs" select="distinct-values($refs)"/>
    <xsl:call-template name="get-entries">
      <xsl:with-param name="docs" select="$distinctRefs"/>
    </xsl:call-template>
  </xsl:variable>
  
  <!-- TEMPLATES -->
  <xsl:template match="/TEI">
    <html>
      <head>
        <meta charset="UTF-8"></meta>
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
    <xsl:variable name="name" select="if ( $doc eq '' ) then 'local' else $doc"/>
    <!-- Only resolve entries where the document is local (the same TEI file as the 
      rest of the input), or if the document is available for parsing. -->
    <xsl:if test="$doc eq '' or doc-available($doc)">
      <xsl:variable name="refs" select="key('OGs',$doc)"/>
      <xsl:variable name="distinctTargets" select="distinct-values($refs/@ref/substring-after(.,'#'))"/>
      <!--<xsl:value-of select="string-join(distinct-values($refs/@ref),' ~ ')"/>-->
      <xsl:variable name="entries" select="if ( $doc eq '' ) then //*[@xml:id] else doc($doc)"/>
      <xsl:apply-templates select="$entries" mode="og-gen">
        <xsl:with-param name="doc-uri" select="$doc" tunnel="yes"/>
        <xsl:with-param name="idrefs" select="$distinctTargets" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:if>
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
        <xsl:copy-of select="@*"/>
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
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[@xml:id]/*" mode="og-entry">
    <p data-tapas-element="{local-name()}">
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>
  
</xsl:stylesheet>