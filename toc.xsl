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
          li { list-style-position: outside; }
          li span.toc-item { padding-left: 0.5em; color: black; } ]]>
        </style>
      </head>
      <body>
        <h1><xsl:copy-of select="$fileTitle"/></h1>
        
        <xsl:variable name="headersMarked">
          <xsl:apply-templates select="TEI/text"/>
        </xsl:variable>
        <xsl:apply-templates select="$headersMarked" mode="toc"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="*" priority="-10">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[head]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="data-tapas-tocme" select="true()"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- TOC mode -->
  
  <xsl:template match="*" priority="-10" mode="toc">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="toc"/>
  
  <xsl:template name="tocList" match="*[@data-tapas-tocme][1]" mode="toc" priority="-5">
    <xsl:param name="depth" select="0" as="xs:integer" tunnel="yes"/>
    <xsl:param name="otherMembers" select="following-sibling::*[@data-tapas-tocme]" as="node()*"/>
    <xsl:choose>
      <!-- If this is the outermost item, and there are no other items on this level, 
        suppress the heading and continue applying templates using a $depth of 0. -->
      <xsl:when test="$depth eq 0 and not(exists($otherMembers))">
        <xsl:apply-templates select="*" mode="toc">
          <xsl:with-param name="suppress-heading" select="true()"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <ol>
          <xsl:attribute name="type">
            <xsl:variable name="numberType" select="('I', '1', 'A', '1', 'a', '1', 'i')"/>
            <xsl:variable name="useIndex" select="($depth + 1) mod count($numberType)"/>
            <xsl:value-of select="$numberType[$useIndex]"/>
          </xsl:attribute>
          <li>
            <xsl:apply-templates mode="#current">
              <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
            </xsl:apply-templates>
          </li>
          <xsl:if test="exists($otherMembers)">
            <xsl:for-each select="$otherMembers">
              <li>
                <xsl:apply-templates select="*" mode="toc">
                  <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
                </xsl:apply-templates>
              </li>
            </xsl:for-each>
          </xsl:if>
        </ol>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[@data-tapas-tocme][position() ne 1]" mode="toc"/>
  
  <xsl:template match="*[@data-tapas-tocme]/head | titleStmt/title" mode="toc">
    <xsl:param name="suppress-heading" select="false()" as="xs:boolean"/>
    <xsl:if test="not($suppress-heading)">
      <span class="toc-item"><xsl:value-of select="."/></span>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
