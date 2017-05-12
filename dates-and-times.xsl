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
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wfn="http://www.wwp.northeastern.edu/ns/functions"
  xmlns:tps="http://tapas.northeastern.edu"
  exclude-result-prefixes="#all">
  
  <!-- 2017-05-10: Created based on the Women Writers Project XSLT function library. -->
  
  <!-- VARIABLES -->
  
  <xsl:variable name="allDateAttrs" as="xs:string+"
    select="( $dateAttrsW3C, $dateAttrsISO, $dateAttrsCustom )"/>
  
  <xsl:variable name="dateAttrsW3C" as="xs:string+"
    select="('when', 'from', 'to', 'notBefore', 'notAfter')"/>
  
  <xsl:variable name="dateAttrsISO" as="xs:string+">
    <xsl:for-each select="$dateAttrsW3C">
      <xsl:value-of select="concat(.,'-iso')"/>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="dateAttrsCustom" as="xs:string+">
    <xsl:for-each select="$dateAttrsW3C">
      <xsl:value-of select="concat(.,'-custom')"/>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="monthsReadable" as="xs:string+" 
    select="( 'January', 'February', 'March', 
              'April', 'May', 'June', 
              'July', 'August', 'September', 
              'October', 'November', 'December' )"/>
  
  
  <!-- FUNCTIONS -->
  
  <xsl:function name="tps:replace-leading-zeroes" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of select="replace($string,'^0+','')"/>
  </xsl:function>
  
  <xsl:function name="tps:make-date-attribute-readable" as="xs:string?">
    <xsl:param name="attribute" as="attribute()"/>
    <!-- Proceed only if the attribute falls within a subset of TEI's att.datable. 
      (http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-att.datable.html) -->
    <xsl:if test="name($attribute) = $allDateAttrs">
      <xsl:choose>
        <xsl:when test="name($attribute) = $dateAttrsW3C">
          <xsl:value-of select="tps:make-date-readable-w3c(data($attribute))"/>
        </xsl:when>
        <xsl:when test="name($attribute) = $dateAttrsISO">
          
        </xsl:when>
        <xsl:when test="name($attribute) = $dateAttrsCustom">
          
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:function>
  
  <!-- Given a string presumed to be in a W3C date/time format, create a human 
    readable version. For example, "YYYY-MM-DD" would become "MONTH DAY, YEAR". -->
  <xsl:function name="tps:make-date-readable-w3c" as="xs:string?">
    <xsl:param name="w3cDate" as="xs:string"/>
    <xsl:variable name="isBCE" select="matches($w3cDate,'^-')"/>
    <xsl:variable name="datePicture">
      <xsl:value-of select="'[MNn] [Do], [Y]'"/>
      <!-- Only display the era if the date is BCE. Saxon will output 'BC' if we add 
        '[E]' to the picture, but 'BCE' seems a more appropriate descriptor. -->
      <xsl:if test="$isBCE">
        <xsl:value-of select="' BCE'"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="timePicture" select="'[H1]:[m01]'"/>
    <xsl:variable name="dateTimePicture" select="concat($datePicture,', ',$timePicture)"/>
    <xsl:choose>
      <xsl:when test="$w3cDate castable as xs:dateTime">
        <xsl:value-of select="format-dateTime(xs:dateTime($w3cDate),$dateTimePicture)"/>
      </xsl:when>
      <xsl:when test="$w3cDate castable as xs:date">
        <xsl:value-of select="format-date(xs:date($w3cDate),$datePicture)"/>
      </xsl:when>
      <xsl:when test="$w3cDate castable as xs:time">
        <xsl:value-of select="format-time(xs:time($w3cDate),$timePicture)"/>
      </xsl:when>
      <xsl:when test=" $w3cDate castable as xs:gYearMonth 
                    or $w3cDate castable as xs:gMonthDay
                    or $w3cDate castable as xs:gMonth
                    or $w3cDate castable as xs:gDay
                    or $w3cDate castable as xs:gYear">
        <xsl:variable name="month">
          <xsl:analyze-string select="$w3cDate" regex="^(-?\d\d\d\d|-)-(\d\d)">
            <xsl:matching-substring>
              <xsl:variable name="usableMonth" select="tps:replace-leading-zeroes(regex-group(2))"/>
              <xsl:value-of select="$monthsReadable[xs:integer($usableMonth)]"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="day">
          <xsl:analyze-string select="$w3cDate" regex="^(-?\d\d\d\d|-)-(\d\d)?-(\d\d)">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="year">
          <xsl:analyze-string select="$w3cDate" regex="^-?(\d\d\d\d)">
            <xsl:matching-substring>
              <xsl:value-of select="tps:replace-leading-zeroes(regex-group(1))"/>
              <xsl:if test="$isBCE">
                <xsl:text> BCE</xsl:text>
              </xsl:if>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="string-join(($month, $day, $year)[exists(.) and . ne ''], ' ')"/>
      </xsl:when>
      <!-- If all else fails, just output the string unchanged. -->
      <xsl:otherwise>
        <xsl:value-of select="$w3cDate"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>