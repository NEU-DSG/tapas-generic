<?xml version="1.0" encoding="UTF-8"?>
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
  
  <xsl:output indent="yes"/>
  
  <xsl:template match="/">
    <xsl:variable name="fileTitle">
      <xsl:apply-templates select="TEI/teiHeader/fileDesc/titleStmt/title" mode="toc"/>
    </xsl:variable>
    <html>
      <head>
        <title>
          <xsl:value-of select="$fileTitle[1]"/>
        </title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <style>
<![CDATA[ ol { margin-left: 2em; color: gray; }
          li ol { margin-left: 0; }
          li { margin-top: 0.25em; list-style-position: outside; }
          li span.toc-item { padding-left: 0.5em; display: block; color: black; } ]]>
        </style>
      </head>
      <body>
        <h1><xsl:copy-of select="$fileTitle"/></h1>
        
        <xsl:variable name="headersMarked">
          <xsl:apply-templates select="TEI/text"/>
        </xsl:variable>
        <xsl:variable name="toc">
          <xsl:apply-templates select="$headersMarked" mode="toc"/>
        </xsl:variable>
        <xsl:copy-of select="$toc"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="*" priority="-10">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[ dateline | head | opener ]" priority="-5">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="data-tapas-tocme" select="true()"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="docTitle | titlePage">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <!-- TOC mode -->
  
  <xsl:template match="*" priority="-10" mode="toc toc-outer">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="toc toc-outer"/>
  
  <xsl:template match="/text" mode="toc">
    <xsl:variable name="tocMes" 
      select="descendant::*[@data-tapas-tocme][not(ancestor::*[@data-tapas-tocme])]"/>
    <xsl:variable name="typeAttr" as="attribute()">
      <xsl:call-template name="list-type">
        <xsl:with-param name="depth" select="0"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count($tocMes) eq 0"/>
      <xsl:when test="count($tocMes) eq 1">
        <ol>
          <xsl:copy-of select="$typeAttr"/>
          <xsl:apply-templates select="$tocMes/*" mode="toc-outer">
            <xsl:with-param name="depth" select="1" tunnel="yes"/>
          </xsl:apply-templates>
        </ol>
      </xsl:when>
      <xsl:otherwise>
        <ol>
          <xsl:copy-of select="$typeAttr"/>
          <xsl:for-each select="( 1 to count($tocMes) )">
            <xsl:variable name="index" select="."/>
            <xsl:variable name="textChild" select="$tocMes[$index]"/>
            <xsl:variable name="following" select="subsequence($tocMes, $index + 1)"/>
            <xsl:apply-templates select="$textChild" mode="toc-outer">
              <xsl:with-param name="depth" select="1" tunnel="yes"/>
              <xsl:with-param name="other-members" select="$following"/>
            </xsl:apply-templates>
          </xsl:for-each>
        </ol>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[@data-tapas-tocme]" mode="toc-outer">
    <xsl:param name="other-members" select="following-sibling::*[@data-tapas-tocme]" as="node()*"/>
    <li>
      <xsl:apply-templates select="*" mode="toc"/>
    </li>
  </xsl:template>
  
  <xsl:template match="*[@data-tapas-tocme][1]" mode="toc" priority="-5">
    <xsl:param name="depth" select="0" as="xs:integer" tunnel="yes"/>
    <xsl:param name="other-members" select="following-sibling::*[@data-tapas-tocme]" as="node()*"/>
    <ol>
      <li>
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
        </xsl:apply-templates>
      </li>
      <xsl:if test="exists($other-members)">
        <xsl:for-each select="$other-members">
          <li>
            <xsl:apply-templates select="*" mode="toc">
              <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
            </xsl:apply-templates>
          </li>
        </xsl:for-each>
      </xsl:if>
    </ol>
  </xsl:template>
  
  <xsl:template match="*[@data-tapas-tocme][position() ne 1]" mode="toc"/>
  
  <xsl:template match="titleStmt/title
                    | *[@data-tapas-tocme]/dateline
                    | *[@data-tapas-tocme]/head
                    | *[@data-tapas-tocme]/opener
                    | *[@data-tapas-tocme]/opener/dateline" mode="toc">
    <xsl:param name="suppress-heading" select="false()" as="xs:boolean"/>
    <xsl:choose>
      <xsl:when test="$suppress-heading"/>
      <xsl:when test="self::opener[dateline]">
        <xsl:apply-templates mode="toc"/>
      </xsl:when>
      <xsl:otherwise>
        <span class="toc-item"><xsl:value-of select="."/></span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="list-type">
    <xsl:param name="depth" as="xs:integer" required="yes"/>
    <xsl:attribute name="type">
      <xsl:variable name="numberType" select="('I', '1', 'A', '1', 'a', '1', 'i')"/>
      <xsl:variable name="useIndex" select="($depth + 1) mod count($numberType)"/>
      <xsl:value-of select="$numberType[$useIndex]"/>
    </xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>
