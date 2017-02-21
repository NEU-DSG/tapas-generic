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

  <xsl:output method="xhtml"/>
  
  
  <!-- PARAMETERS -->
  
  <xsl:param name="assets-base" select="'../'"/>
  
  
  <!-- KEYS -->
  
  <xsl:key name="OGs" 
    match="//*[@ref][ self::name | self::orgName | self::persName | self::placeName | self::rs | self::title ]" 
    use="substring-before(@ref,'#')"/>
  
  
  <!-- GLOBAL VARIABLES -->
  
  <xsl:variable name="labelMap" as="item()*">
    <!-- elements -->
    <entry key="addName"        >Additional Name</entry>
    <entry key="accMat"         >Accompanying Materials</entry>
    <entry key="altIdentifier"  >Alternate Identifier</entry>
    <entry key="appInfo"        >Application Information</entry>
    <entry key="bibl"           >Bibliographic Entry</entry>
    <entry key="biblScope"      >Scope of Bibliographic Reference</entry>
    <entry key="bindingDesc"    >Binding Description</entry>
    <entry key="birth"          >Born</entry>
    <entry key="castGroup"      >Cast List Grouping</entry>
    <entry key="castItem"       >Cast List Entry</entry>
    <entry key="castList"       >Cast List</entry>
    <entry key="catRef"         >Category</entry>
    <entry key="cit"            >Citation</entry>
    <entry key="citedRange"     >Cited Range</entry>
    <entry key="colloc"         >Collocated</entry>
    <entry key="custEvent"      >Custodial Event</entry>
    <entry key="death"          >Died</entry>
    <entry key="etym"           >Etymology</entry>
    <entry key="form"           >Form Information Group</entry>
    <entry key="gen"            >Gender</entry>
    <entry key="genName"        >General Name Component</entry>
    <entry key="geo"            >Geographical Coordinates</entry>
    <entry key="geogFeat"       >Geographical Feature</entry>
    <entry key="geogName"       >Geographical Name</entry>
    <entry key="gram"           >Grammatical Information</entry>
    <entry key="gramGrp"        >Grammatical Information Group</entry>
    <entry key="hom"            >Homograph</entry>
    <entry key="hyph"           >Hyphenation</entry>
    <entry key="lbl"            >Label</entry>
    <entry key="idno"           >Identifier</entry>
    <entry key="iType"          >Inflectional Class</entry>
    <entry key="langKnowledge"  >Language Knowledge</entry>
    <entry key="listBibl"       >Bibliography</entry>
    <entry key="listEvent"      >List of Events</entry>
    <entry key="listNym"        >List of Canonical Names</entry>
    <entry key="listOrg"        >List of Organizations</entry>
    <entry key="listPerson"     >List of Persons</entry>
    <entry key="listPlace"      >List of Places</entry>
    <entry key="monogr"         >Monograph</entry>
    <entry key="musicNotation"  >Musical Notation</entry>
    <entry key="nameLink"       >Name Link</entry>
    <entry key="nym"            >Canonical Name</entry>
    <entry key="objectType"     >Object Type</entry>
    <entry key="org"            >Organization</entry>
    <entry key="orgName"        >Organization Name</entry>
    <entry key="origDate"       >Date of Origin</entry>
    <entry key="origPlace"      >Place of Origin</entry>
    <entry key="orth"           >Orthographic Form</entry>
    <entry key="person"         >Grammatical Person</entry>
    <entry key="persName"       >Personal Name</entry>
    <entry key="personGrp"      >Personal Group</entry>
    <entry key="placeName"      >Place Name</entry>
    <entry key="pos"            >Part of Speech</entry>
    <entry key="pron"           >Pronunciation</entry>
    <entry key="re"             >Related Entry</entry>
    <entry key="pubPlace"       >Publication Place</entry>
    <entry key="relatedItem"    >Related Item</entry>
    <entry key="roleName"       >Role Name</entry>
    <entry key="secFol"         >Second Folio</entry>
    <entry key="socecStatus"    >Socio-economic Status</entry>
    <entry key="subc"           >Subcategorization</entry>
    <entry key="syll"           >Syllabification</entry>
    <entry key="tns"            >Tense</entry>
    <entry key="usg"            >Usage</entry>
    <entry key="xr"             >Cross-Reference Phrase</entry>
    <!-- Attributes -->
    <entry key="copyOf"         >Copy of</entry>
    <entry key="corresp"        >Corresponds to</entry>
    <entry key="notAfter"       >Not after</entry>
    <entry key="notBefore"      >Not before</entry>
    <entry key="sameAs"         >Same as</entry>
    <entry key="synch"          >Synchronous with</entry>
    <!-- Both -->
    <entry key="sex"            >Gender</entry>
  </xsl:variable>
  
  <xsl:variable name="model.nameLike" as="xs:string*" 
    select="( $model.placeStateLike, 'addName', 'forename', 'genName', 'geogFeat', 
      'idno', 'lang', 'name', 'nameLink', 'offset', 'orgName', 'persName', 
      'roleName', 'rs', 'surname' 
      )"/>
  
  <xsl:variable name="model.placeStateLike" as="xs:string*"
    select="( 'bloc', 'climate', 'country', 'district', 'geogName', 'location', 
      'placeName', 'population', 'region', 'settlement', 'state', 'terrain', 'trait' 
      )"/>
  
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
  
  <xsl:variable name="starterFile" select="base-uri(.)"/>
  
  <!-- FUNCTIONS -->
  
  <!-- Given a reference pointer, create an 'ography identifier using a generated 
    prefix for the filename. Because this function may be used while making 'ography 
    entries, no testing is done on whether or not the referenced entry actually 
    exists. User-created prefixes cannot yet be handled. -->
  <xsl:function name="tps:generate-og-id" as="xs:string?">
    <xsl:param name="idref" as="xs:string"/>
    <xsl:variable name="refSeq" select="tokenize($idref,'#')"/>
    <xsl:variable name="prefix" select="tps:get-og-prefix($refSeq[1])"/>
    <!--  -->
    <xsl:value-of select="if ( $prefix ) then
                            if ( $prefix eq 'og0' ) then $refSeq[2]
                            else concat($prefix,'-',$refSeq[2])
                          else ()"/>
  </xsl:function>
  
  <!-- Using the map of ography keys, figure out the (generated) 'ography prefix 
    from a filename. -->
  <xsl:function name="tps:get-og-prefix" as="xs:string?">
    <xsl:param name="filename" as="xs:string"/>
    <xsl:value-of select="$ogMap[@key eq $filename]"/>
  </xsl:function>
  
  <!-- Tests an element to see if it might function as narrative context for an 
    'ograpy entry. -->
  <xsl:function name="tps:is-desc-like" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:value-of select="exists($element[self::*]
                                  [ self::desc 
                                  | ( self::def | self::etym )[parent::nym] 
                                  | self::note | self::p | self::roleDesc ]
                                )"/>
  </xsl:function>
  
  <!-- Tests an element to see if it contains both elements and non-whitespace text. -->
  <xsl:function name="tps:is-mixed-content" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:value-of select="exists($element/*) and 
                          exists($element/text()[not(normalize-space(.) eq '')])"/>
  </xsl:function>
  
  <!-- Tests an element for membership in model.nameLike. -->
  <xsl:function name="tps:is-name-like" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:value-of select="exists($element[self::*]
                                  [ local-name() = $model.nameLike ]
                                )"/>
  </xsl:function>
  
  <!-- Tests an element to see if it is an 'ography entry. -->
  <xsl:function name="tps:is-og-entry" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:value-of select="exists($element[self::*]
                                  [ (self::bibl | self::biblStruct)[parent::listBibl] 
                                  | self::event[parent::listEvent]
                                  | self::org[parent::listOrg]
                                  | self::nym[parent::listNym]
                                  | (self::person | self::personGrp)[parent::listPerson]
                                  | self::place[parent::listPlace] ]
                                )"/>
  </xsl:function>
  
  <!-- Tests an element for membership in model.persStateLike or model.placeStateLike -->
  <xsl:function name="tps:is-state-like" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:value-of select="exists($element[self::*]
                                  [ self::affiliation | self::age | self::climate | self::education 
                                  | self::faith | self::floruit | self::langKnowledge 
                                  | self::location | self::nationality | self::occupation 
                                  | self::persName | self::population | self::residence | self::sex 
                                  | self::socecStatus | self::state | self::terrain | self::trait ]
                                )"/>
  </xsl:function>
  
  
  <!-- TEMPLATES -->
  
  <xsl:template match="/TEI">
    <html>
      <head>
        <title>
          <xsl:value-of select="normalize-space(descendant::teiHeader/fileDesc/titleStmt/title)"/>
        </title>
        <link id="maincss" rel="stylesheet" type="text/css" href="{concat($assets-base,'css/tapasGdiplo.css')}"></link>
        <script type="application/javascript" src="{concat($assets-base,'js/jquery/jquery.min.js')}"/>
        <script type="application/javascript" src="{concat($assets-base,'js/jquery-ui/ui/minified/jquery-ui.min.js')}"/>
        <script type="application/javascript" src="{concat($assets-base,'js/jquery/plugins/jquery.blockUI.js')}"/>
        <script type="application/javascript" src="{concat($assets-base,'js/contextualItems.js')}"/>
        <script type="application/javascript" src="{concat($assets-base,'js/tapas-generic.js')}"/>
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
  <xsl:template match="head[not(ancestor::*[tps:is-desc-like(.)])] 
                     | title[not(ancestor::*[tps:is-desc-like(.)])]" mode="og-entry">
    <xsl:param name="entryHeading" select="''" tunnel="yes"/>
    <xsl:choose>
      <!-- If the current node exactly matches the heading of an 'ography entry (and 
        has no child elements), suppress it. -->
      <xsl:when test="$entryHeading ne '' and $entryHeading eq normalize-space(.) and not(*)"/>
      <xsl:otherwise>
        <div class="og-metadata-item">
          <span class="og-label">
            <xsl:call-template name="set-label"/>
          </span>
          <xsl:element name="tei-{local-name()}">
            <xsl:call-template name="get-attributes">
              <xsl:with-param name="labelled" select="true()"/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
          </xsl:element>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- MODES: 'OGRAPHY GENERATION -->
  
  <xsl:template match="text()" mode="og-gen" priority="-15"/>
  
  <xsl:template name="passthru-og-element" match="*" mode="og-entry" priority="-50">
    <xsl:element name="{local-name()}">
      <xsl:call-template name="get-attributes"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*" mode="og-gen og-entry" name="make-data-attr" priority="-20">
    <xsl:attribute name="data-tapas-att-{local-name()}" select="data(.)"/>
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
          <xsl:call-template name="get-entry-header"/>
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
  
  <xsl:template match="@parts[parent::nym] | @ref | @target" mode="og-gen og-entry">
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
  
  <xsl:template match="*[@xml:id or self::persName or self::analytic or self::monogr or self::imprint]/*" mode="og-entry" priority="-20">
    <xsl:param name="entryHeading" select="''" tunnel="yes"/>
    <xsl:variable name="me" select="local-name(.)"/>
    <xsl:choose>
      <!-- If the current node exactly matches the heading of an 'ography entry (and 
        has no child elements), suppress it. -->
      <xsl:when test="$entryHeading ne '' and $entryHeading eq normalize-space(.) and not(*)"/>
      <xsl:otherwise>
        <div class="og-metadata-item">
          <span class="og-label">
            <xsl:call-template name="set-label"/>
          </span>
          <xsl:element name="{$me}">
            <xsl:call-template name="get-attributes">
              <xsl:with-param name="labelled" select="true()"/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
          </xsl:element>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="respStmt" mode="og-entry">
    <div class="og-metadata-item">
      <span class="og-label">
        <xsl:variable name="respRoles" select="string-join(resp/normalize-space(.)[not(. eq '')],', ')"/>
        <!-- If there is no usable content in $respRoles, use the generic term "contributor". -->
        <xsl:value-of select="if ( $respRoles ne '' ) then $respRoles
                              else 'contributor'"/>
        <xsl:text>:</xsl:text>
      </span>
      <xsl:call-template name="passthru-og-element"/>
    </div>
  </xsl:template>
  
  <!-- On elements serving as indicators of events, W3C-datable attributes should 
    come before any field content. -->
  <xsl:template match="birth | date | death | floruit | residence" mode="og-entry"> <!-- XD -->
    <div>
      <xsl:attribute name="class" select="'og-metadata-item'"/>
      <span class="og-label">
        <xsl:call-template name="set-label"/>
      </span>
      <xsl:element name="{local-name()}">
        <xsl:call-template name="save-gi"/>
        <xsl:apply-templates select="@* except (@when, @from, @to, @notBefore, @notAfter)" mode="#current"/>
        <xsl:attribute name="class" select="'og-labelled'"/>
        <xsl:variable name="attrDates" as="item()*">
          <xsl:apply-templates select="@when | @from | @to | @notBefore | @notAfter" mode="og-datelike"/>
        </xsl:variable>
        <xsl:variable name="content" as="item()*">
          <xsl:apply-templates mode="#current"/>
        </xsl:variable>
        <xsl:if test="$attrDates">
          <!-- Test if this <birth> or <death> contains a year-like pattern, or a 
            <date>. This should reduce most repetition when these elements are tagged 
            with a W3C date attribute but also contain plain-text representations of 
            dates. XD: It will *not* handle years with 1-3 digits! -->
          <xsl:if test="not(matches(normalize-space(),'\d\d\d\d')) and not(descendant::date)">
            <xsl:copy-of select="$attrDates"/>
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </xsl:element>
    </div>
  </xsl:template>
  
  <!-- Places mentioned inside event-like elements are given an label " in ". -->
  <xsl:template match="*[local-name() = $model.placeStateLike]
                        [parent::birth or parent::death or parent::floruit or parent::residence]" mode="og-entry">
    <xsl:text> </xsl:text>
    <span class="og-label og-label-inner">in</span>
    <xsl:text> </xsl:text>
    <xsl:call-template name="passthru-og-element"/>
  </xsl:template>
  
  <xsl:template match="biblScope | citedRange" mode="og-entry">
    <div class="og-metadata-item">
      <span class="og-label">
        <xsl:choose>
          <xsl:when test="self::biblScope and @unit">
            <xsl:value-of select="@unit"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="set-label"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
      <xsl:choose>
        <xsl:when test=".[not(normalize-space(.) eq '')][@from or @to]">
          <xsl:element name="{local-name()}">
            <xsl:call-template name="get-attributes">
              <xsl:with-param name="labelled" select="true()"/>
            </xsl:call-template>
            <xsl:value-of select="@from"/>
            <xsl:if test="not(@to) or .[@from][@to[not(. eq ../@from)]]">
              <xsl:text>-</xsl:text>
              <xsl:value-of select="@to"/>
            </xsl:if>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="passthru-og-element"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="idno" mode="og-entry">
    <div class="og-metadata-item">
      <xsl:call-template name="get-attributes"/>
      <span class="og-label">
        <xsl:call-template name="set-label"/>
      </span>
      <xsl:choose>
        <xsl:when test="@type eq 'URI' or starts-with(normalize-space(),'http')">
          <xsl:variable name="uri" select="normalize-space()"/>
          <a target="_blank">
            <xsl:attribute name="href" select="$uri"/>
            <xsl:value-of select="if ( @subtype ) then @subtype else $uri"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="desc 
                      | note[not(@xml:id) or not(@xml:id = key('OGs','')/@ref/substring-after(data(.),'#'))]
                      | *[tps:is-og-entry(.)]/p | roleDesc" mode="og-entry">
    <xsl:element name="{local-name()}">
      <xsl:call-template name="get-attributes"/>
      <xsl:attribute name="data-tapas-anchored" select="'false'"/>
      <xsl:apply-templates mode="work"/>
    </xsl:element>
  </xsl:template>
  
  
  <!-- MODE: 'OGRAPHY HEADING -->
  
  <!-- Generate a sequence of potential entry headers, and choose the first. -->
  <xsl:template name="get-entry-header">
    <xsl:param name="element" select="." as="node()"/>
    <xsl:variable name="options" as="item()*">
      <xsl:apply-templates select="$element/*" mode="og-head"/>
    </xsl:variable>
    <xsl:variable name="not-blank" as="item()*" select="$options[normalize-space(.) ne '']"/>
    <xsl:copy-of select="if ( $not-blank[1] ) then $not-blank[1] 
                         else $element/@xml:id/data(.)"/>
  </xsl:template>
  
  <xsl:template match="* | text()" mode="og-head" priority="-30"/>
  
  <xsl:template match="biblStruct/*" mode="og-head">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="head
                      | label[not(preceding-sibling::head)][not(preceding-sibling::label)]
                      | org/orgName[@type eq 'main' or position() eq 1] 
                      | person/persName[@type eq 'main' or position() eq 1][not(*)]
                      | place/*[local-name() = $model.placeStateLike][@type eq 'main' or position() eq 1]" mode="og-head">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="analytic/title[@type eq 'main' or position() eq 1] 
                      | bibl/title[@level eq 'a']" mode="og-head" priority="11">
    <xsl:value-of select="concat('“',normalize-space(.),'”')"/>
  </xsl:template>
  
  <xsl:template match="monogr[1]/title[@type eq 'main' or position() eq 1]
                      | bibl/title[@type eq 'main' or position() eq 1 or @level eq 'm']" mode="og-head" priority="30">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <!-- If the first relevant <persName> has child elements, test the naming 
    convention used within this particular <persName> (is there a <surname> without 
    a preceding <forename>?). Then, run "og-head-persname" mode to join the children 
    together, using commas to separate word parts as necessary. -->
  <xsl:template match="person/persName[@type eq 'main' or position() eq 1][*]" mode="og-head">
    <xsl:variable name="surname-forename" 
      select="exists(surname) and exists(surname[not(preceding-sibling::forename)])" as="xs:boolean"/>
    <xsl:variable name="header">
      <xsl:apply-templates mode="og-head-persname">
        <xsl:with-param name="surname-forename" select="$surname-forename"/>
      </xsl:apply-templates>
    </xsl:variable>
    <!-- Replace any whitespace introduced before a comma. -->
    <xsl:value-of select="replace($header,'\s+(, )','$1')"/>
  </xsl:template>
  
  
  <!-- MODE: PERSNAMES FOR 'OGRAPHY HEADINGS -->
  
  <!-- Turn whitespace-only text nodes into a single space. -->
  <xsl:template match="text()[normalize-space(.) eq '']" mode="og-head-persname">
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="*" mode="og-head-persname">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <!-- Insert a comma following the surname if: 
    (1) the naming convention is "last name, first name", and 
    (2) there is at least one following name part, and 
    (3) the very next part is not a surname. -->
  <xsl:template match="surname" mode="og-head-persname">
    <xsl:param name="surname-forename" as="xs:boolean"/>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="$surname-forename and 
                  exists(following-sibling::node()[not(self::text()[normalize-space(.) eq ''])]) and 
                  not(following-sibling::*[1][self::surname])">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <!-- Insert a comma before the role name if:
    (1) the role isn't first of the name components, and
    (2) a comma hasn't already been inserted due to a preceding surname in 
        "last name, first name" convention. -->
  <xsl:template match="roleName" mode="og-head-persname">
    <xsl:param name="surname-forename" as="xs:boolean"/>
    <xsl:variable name="precededByNonwhitespaceText" 
      select="exists(preceding-sibling::node()[1][self::text()[not(normalize-space(.) eq '')]])"/>
    <xsl:variable name="theGiBefore" select="preceding-sibling::*[1]"/>
    <xsl:if test="($precededByNonwhitespaceText or $theGiBefore) and
                  not($surname-forename and exists($theGiBefore[self::surname]))">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  
  <!-- MODE: W3C DATES -->
  
  <xsl:template match="@when" mode="og-datelike">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="@from | @to | @notBefore | @notAfter" mode="og-datelike">
    <span class="og-label og-label-inner">
      <xsl:call-template name="set-label">
        <xsl:with-param name="is-inner-label" select="true()"/>
      </xsl:call-template>
    </span>
    <xsl:value-of select="."/>
  </xsl:template>
  
  
  <!-- SUPPLEMENTAL TEMPLATES -->
  
  <!-- Apply templates on attributes. -->
  <xsl:template name="get-attributes">
    <xsl:param name="labelled" select="false()" as="xs:boolean"/>
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:call-template name="save-gi"/>
    <xsl:if test="$labelled">
      <xsl:attribute name="class" select="'og-labelled'"/>
    </xsl:if>
    <xsl:if test="@ref[. ne ''] or self::ref[@target[. ne '']]">
      <xsl:call-template name="og-referrer"/>
    </xsl:if>
  </xsl:template>
  
  <!-- If an 'ography entry is referenced within an 'ography entry internal to the 
    input document, use "work" mode to create a data attribute for linking. 
    For sanity's sake, references are not linked from within external 'ography 
    entries. -->
  <xsl:template name="og-referrer">
    <xsl:if test="base-uri(.) eq $starterFile">
      <xsl:apply-templates select="@ref" mode="work"/>
    </xsl:if>
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
    <xsl:param name="is-field-label" as="xs:boolean" select="true()"/>
    <xsl:param name="is-inner-label" as="xs:boolean" select="false()"/>
    <xsl:variable name="me" select="local-name()"/>
    <xsl:variable name="label" select="$labelMap[@key eq $me]/normalize-space(.)"/>
    <xsl:value-of 
      select="if ( $label ) then
                if ( $is-field-label ) then
                  lower-case($label)
                else $label
              else $me"/>
    <xsl:variable name="specializations" as="item()*">
      <xsl:variable name="lang" select="@xml:lang"/>
      <!-- XD: get description from IANA registry? 
        http://www.iana.org/assignments/language-subtag-registry/language-subtag-registry -->
      <xsl:copy-of select="@type | @unit"/>
      <xsl:copy-of select="$lang"/>
    </xsl:variable>
    <xsl:for-each select="$specializations">
      <xsl:text>, </xsl:text>
      <xsl:value-of select="."/>
    </xsl:for-each>
    <xsl:if test="$is-field-label and not($is-inner-label)">
      <xsl:text>: </xsl:text>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>