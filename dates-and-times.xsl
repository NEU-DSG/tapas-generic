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
  
  <!-- Test if a given attribute is a date-like member of TEI's att.datable, 
    excluding @calendar, @period, @datingPoint, and @datingMethod. -->
  <xsl:function name="tps:is-date-like-attr" as="xs:boolean">
    <xsl:param name="attribute" as="attribute()"/>
    <xsl:value-of select="name($attribute) = $allDateAttrs"/>
  </xsl:function>
  
  <!-- Test if a given attribute is a member of TEI's att.datable.custom. -->
  <xsl:function name="tps:is-date-like-attr-custom" as="xs:boolean">
    <xsl:param name="attribute" as="attribute()"/>
    <xsl:value-of select="name($attribute) = $dateAttrsCustom"/>
  </xsl:function>
  
  <!-- Test if a given attribute is a member of TEI's att.datable.iso. -->
  <xsl:function name="tps:is-date-like-attr-iso" as="xs:boolean">
    <xsl:param name="attribute" as="attribute()"/>
    <xsl:value-of select="name($attribute) = $dateAttrsISO"/>
  </xsl:function>
  
  <!-- Test if a given attribute is a member of TEI's att.datable.w3c. -->
  <xsl:function name="tps:is-date-like-attr-w3c" as="xs:boolean">
    <xsl:param name="attribute" as="attribute()"/>
    <xsl:value-of select="name($attribute) = $dateAttrsW3C"/>
  </xsl:function>
  
  <!-- Test if a given attribute both (A) belongs to TEI's att.datable model, and 
    (B) is some variant of @when. -->
  <xsl:function name="tps:is-when-like-attr" as="xs:boolean">
    <xsl:param name="attribute" as="attribute()"/>
    <xsl:value-of select="tps:is-date-like-attr($attribute) and matches(name($attribute),'^when')"/>
  </xsl:function>
  
  <!-- Given an attribute presumed to belong to att.datable, return a human-readable 
    version. -->
  <xsl:function name="tps:make-date-attribute-readable" as="xs:string?">
    <xsl:param name="attribute" as="attribute()"/>
    <!-- Proceed only if the attribute falls within a subset of TEI's att.datable. 
      (http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-att.datable.html) -->
    <xsl:if test="tps:is-date-like-attr($attribute)">
      <xsl:choose>
        <xsl:when test="tps:is-date-like-attr-w3c($attribute)">
          <xsl:value-of select="tps:make-date-readable-w3c(data($attribute))"/>
        </xsl:when>
        <xsl:when test="tps:is-date-like-attr-iso($attribute)">
          <xsl:value-of select="tps:make-date-readable-iso(data($attribute))"/>
        </xsl:when>
        <xsl:when test="tps:is-date-like-attr-custom($attribute)">
          <xsl:value-of select="tps:make-date-readable-custom(data($attribute))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:function>
  
  <!-- Given a string, determine if it can be cast into one of the W3C date/time 
    formats. -->
  <xsl:function name="tps:is-date-w3c-castable" as="xs:boolean">
    <xsl:param name="date" as="xs:string"/>
    <xsl:value-of select=" $date castable as xs:dateTime
                        or $date castable as xs:date
                        or $date castable as xs:time
                        or $date castable as xs:gYearMonth
                        or $date castable as xs:gMonthDay
                        or $date castable as xs:gMonth
                        or $date castable as xs:gDay
                        or $date castable as xs:gYear"/>
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
  
  <!-- Given a string presumed to be in the ISO 8601 date/time format, create a 
    human-readable version. -->
  <xsl:function name="tps:make-date-readable-iso" as="xs:string?">
    <xsl:param name="isoDate" as="xs:string"/>
    <!-- The characters which are used only for ISO times, rather than ISO dates. 
      NOTE: I (Ashley Clark) am including the Unicode minus sign character (U+2212) 
      used to represent time offsets from UTC, even though the TEI schema requires 
      the use of hyphens instead, at least as of 2017-06-02. If the character 
      constraint on teidata.temporal.iso is ever modified to include the minus sign, 
      this variable should continue to work. -->
    <xsl:variable name="timeGlyphs" select="'[:\.,+Z−]'"/>
    <xsl:variable name="isDateTime" select="contains($isoDate,'T')"/>
    <xsl:variable name="isoMain" select="if ( $isDateTime ) then substring-before($isoDate,'T') else $isoDate"/>
    <!-- If there is no 'T' in $isoDate, there is a chance that the input 
      represents a time rather than a date. If the input string contains glyphs 
      seeming to indicate time, no attempt is made to determine a readable date. -->
    <xsl:variable name="date">
      <xsl:if test="not(matches($isoMain, $timeGlyphs))">
        <xsl:variable name="hasSeparators" select="matches($isoMain,'\d-')"/>
        <xsl:choose>
          <!-- Ordinal dates -->
          <xsl:when test="matches($isoMain,'^-?\d\d\d\d-?\d\d\d$')">
            <xsl:variable name="year" select="replace($isoMain,'^(-?\d\d\d\d)-?\d\d\d$','$1')"/>
            <xsl:variable name="jan1" select="xs:date(concat($year,'-01-01'))"/>
            <xsl:variable name="addDays">
              <xsl:variable name="dayOfYear" select="replace($isoMain,'^-?\d\d\d\d-?(\d\d\d)$','$1')"/>
              <xsl:value-of select="xs:integer(tps:replace-leading-zeroes($dayOfYear)) - 1"/>
            </xsl:variable>
            <xsl:variable name="w3cDate" select="$jan1 + xs:dayTimeDuration(concat('P',$addDays,'D'))"/>
            <xsl:value-of select="tps:make-date-readable-w3c(xs:string($w3cDate))"/>
          </xsl:when>
          <!-- If the input string is castable as a W3C date/time, use 
            tps:make-date-readable-w3c() to make human-readable output. -->
          <xsl:when test="tps:is-date-w3c-castable($isoMain)">
            <xsl:value-of select="tps:make-date-readable-w3c($isoMain)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$isoMain"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <!-- If there is no 'T' in $isoDate, there is a chance that the input represents 
      a date rather than a time. Unless $isoTime contains glyphs seeming to indicate 
      time (or a pattern matching a time offset), no attempt is made to determine a 
      readable time. -->
    <xsl:variable name="time">
      <xsl:variable name="isoTime" select="if ( $isDateTime ) then substring-after($isoDate,'T') else $isoMain"/>
      <xsl:variable name="hasTimeGlyphs" select="matches($isoTime, $timeGlyphs)"/>
      <xsl:variable name="hasFractional" select="matches($isoTime,'\d\d[\.,]\d')"/>
      <xsl:variable name="hasOffset" select="matches($isoTime,'(Z|[+−-]\d\d(:?\d\d)?)$')"/>
      <xsl:if test="$hasTimeGlyphs or $hasOffset">
        <xsl:variable name="timeNoOffset" select="replace($isoTime,'^(.+)(Z|[+−-]\d\d(:?\d\d)?)','$1')"/>
        <xsl:variable name="timeNoFractional">
          <xsl:if test="$hasFractional">
            <xsl:variable name="split" select="tokenize($timeNoOffset,'[\.,]')" as="xs:string+"/>
            <xsl:variable name="baseTime" select="$split[1]"/>
            <xsl:variable name="baseDigits" select="translate($baseTime,':','')"/>
            <xsl:variable name="fraction" select="xs:decimal(concat('.',$split[2]))"/>
            <xsl:value-of select="$baseTime"/>
            <xsl:choose>
              <!-- Fraction of a second -->
              <xsl:when test="string-length($baseDigits) eq 6"/>
              <!-- Fraction of a minute -->
              <xsl:when test="string-length($baseDigits) eq 4">
                <xsl:variable name="duration" select="seconds-from-duration(xs:dayTimeDuration('PT1M') * $fraction)"/>
                <xsl:variable name="seconds" select=" if ( string-length(string($duration)) lt 2 ) then 
                                                        concat('0',$duration) 
                                                      else $duration"/>
                <xsl:value-of select="concat(':',$seconds)"/>
              </xsl:when>
              <!-- Fraction of an hour -->
              <xsl:when test="string-length($baseDigits) eq 2">
                <xsl:variable name="duration" select="xs:dayTimeDuration('PT1H') * $fraction"/>
                <xsl:variable name="durationMin" select="minutes-from-duration($duration)"/>
                <xsl:variable name="durationSec" select="seconds-from-duration($duration)"/>
                <xsl:variable name="minutes" select=" if ( string-length(string($durationMin)) lt 2 ) then 
                                                        concat('0',$durationMin) 
                                                      else $durationMin"/>
                <xsl:variable name="seconds" select=" if ( string-length(string($durationSec)) lt 2 ) then 
                                                        concat('0',$durationSec) 
                                                      else $durationSec"/>
                <xsl:value-of select="concat(':',$minutes)"/>
                <xsl:if test="$durationSec ne 0">
                  <xsl:value-of select="concat(':',$seconds)"/>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="timeNearFinal" select="if ( $hasFractional ) then $timeNoFractional else $timeNoOffset"/>
        <xsl:value-of select="tps:replace-leading-zeroes($timeNearFinal)"/>
        <xsl:if test="$hasOffset">
          <xsl:variable name="offset" select="replace($isoTime,'^.+(Z|[+−-]\d\d(:?\d\d)?)','$1')"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$offset"/>
        </xsl:if>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="if ( count(($date, $time)[exists(.) and . ne '']) eq 2 ) then 
                            concat($date,', ',$time) 
                          else ( $date, $time )[exists(.) and . ne '']"/>
  </xsl:function>
  
  <!-- Given a string in some custom date/time format, attempt to create a 
    human-readable version. -->
  <xsl:function name="tps:make-date-readable-custom" as="xs:string?">
    <xsl:param name="customDate" as="xs:string"/>
    <!-- If the input string is castable as an ISO or W3C date/time, use 
      tps:make-date-readable-iso() to make human-readable output. -->
    <xsl:variable name="isoCast" select="tps:make-date-readable-iso($customDate)"/>
    <xsl:choose>
      <xsl:when test="$isoCast ne '' and $isoCast ne $customDate">
        <xsl:value-of select="$isoCast"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$customDate"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Remove leading zeroes from a string. This is useful for numeric strings 
    representing dates, such as '0013-04'. -->
  <xsl:function name="tps:replace-leading-zeroes" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of select="replace($string,'^0+','')"/>
  </xsl:function>
  
</xsl:stylesheet>