<?xml version="1.0" encoding="UTF-8"?>
<!-- 
     LaZAR-DB Export nach DataCite 
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.openarchives.org/OAI/2.0/"
  xmlns:datacite="http://datacite.org/schema/kernel-4">

  <xsl:output method="xml" indent="yes"/>

  <!-- Wurzelelement -->
  <xsl:template match="objects">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- LaZAR-Objekttyp "Objekttyp" -->
  <xsl:template match="objekttyp">
    <datacite:resource>
      <!-- mandatory fields -->
      <!-- TODO: identifier -->
      <datacite:creators>
        <xsl:apply-templates select="_nested__objekttyp__urheber/objekttyp__urheber"/>
      </datacite:creators>
      <datacite:titles>
        <xsl:apply-templates select="_nested__objekttyp__titel/objekttyp__titel"/>
      </datacite:titles>
      <xsl:call-template name="publisher"/>
      <xsl:call-template name="publicationYear"/>
      <xsl:call-template name="resourceType"/>
      <!-- optional fields -->
      <xsl:call-template name="dates"/>
      <xsl:call-template name="alternateIdentifiers"/>
      <xsl:apply-templates select="version"/>
    </datacite:resource>
  </xsl:template>

  <!-- 1 Identifier (mandatory) -->
  <!-- TODO: DOI -->
  
  <!-- 2 Creator (mandatory) --> 
  <xsl:template match="objekttyp__urheber">
    <datacite:creator>
      <xsl:apply-templates select="urheber/person_urheber"/>
      <!-- 2.3 affiliation -->
      <xsl:if test="string(affiliation)">
        <datacite:affiliation>
          <xsl:value-of select="affiliation"/>
        </datacite:affiliation>
      </xsl:if>  
    </datacite:creator>
  </xsl:template>

  <xsl:template match="person_urheber">
    <!-- 2.1 creatorName -->
    <datacite:creatorName>
      <xsl:value-of select="name"/>
    </datacite:creatorName>
    <!-- TODO: GND/ORCID/GRID werden nicht in easydb-XML mitgeliefert (!!) -->
    <!-- 2.2 nameIdentifier -->
    <xsl:choose>
      <xsl:when test="string(orcid)">
        <datacite:nameIdentifier nameIdentifierScheme="ORCID" schemeURI="http://orcid.org/">
          <xsl:value-of select="orcid"/>
        </datacite:nameIdentifier>
      </xsl:when>
      <xsl:when test="string(grid)">
        <!-- TODO: add schemeURI. Which? -->
        <datacite:nameIdentifier nameIdentifierScheme="GRID">
          <xsl:value-of select="grid"/>
        </datacite:nameIdentifier>
      </xsl:when>
      <xsl:when test="string(gnd)">
        <!-- TODO: add schemeURI. Which? -->
        <datacite:nameIdentifier nameIdentifierScheme="GND">
          <xsl:value-of select="gnd"/>
        </datacite:nameIdentifier>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- 3 Title (mandatory) -->
  <xsl:template match="objekttyp__titel">
    <!-- Titeltyp -->
    <xsl:variable name="titleTypeName" select="typ/object_title_type/name/de-DE"/>
    <xsl:variable name="titleType">
      <xsl:choose>
        <xsl:when test="$titleTypeName='Haupttitel'">
          <!-- default -->
        </xsl:when>
        <xsl:when test="$titleTypeName='Alternativer Titel'">
          AlternativeTitle
        </xsl:when>
        <xsl:when test="$titleTypeName='Ergänzender Titel'">
          Subtitle
        </xsl:when>
        <xsl:when test="$titleTypeName='Übersetzter Titel'">
          TranslatedTitle
        </xsl:when>
        <xsl:otherwise>
          Other
        </xsl:otherwise>
      </xsl:choose>  
    </xsl:variable>
    <!-- Deutscher Titel -->
    <xsl:if test="string(titel/de-DE)">
      <datacite:title xml:lang="de">
        <xsl:if test="$titleType!=''">
          <xsl:attribute name="titleType" select="normalize-space($titleType)"/>
        </xsl:if>
        <xsl:value-of select="titel/de-DE"/>
      </datacite:title>
    </xsl:if>  
    <!-- Englischer Titel -->
    <xsl:if test="string(titel/en-US)">
      <datacite:title xml:lang="en">
        <xsl:if test="$titleType!=''">
          <xsl:attribute name="titleType" select="normalize-space($titleType)"/>
        </xsl:if>
        <xsl:value-of select="titel/en-US"/>
      </datacite:title>
    </xsl:if>  
  </xsl:template>

  <!-- 4 Publisher (mandatory) -->
  <xsl:template name="publisher">
    <datacite:publisher>LaZAR</datacite:publisher>
  </xsl:template>

  <!-- 5 Publication Year (mandatory) -->
  <xsl:template name="publicationYear">
    <xsl:variable name="dates" select="_nested__objekttyp__datum/objekttyp__datum"/>
    <xsl:variable name="pubdates" select="$dates[datumstyp/datumstyp/name/de-DE='Publikationsdatum']"/>
    <xsl:variable name="year" select="substring($pubdates/anfang,1,4)"/>
    <xsl:if test="string($year)">
      <datacite:publicationYear>
        <xsl:value-of select="$year"/>
      </datacite:publicationYear>
    </xsl:if>
  </xsl:template>

  <!-- 8 Date (optional) -->
  <xsl:template name="dates">
    <!-- Entstehungs- und/oder Publikationsdatum -->
    <xsl:variable name="dates" select="_nested__objekttyp__datum/objekttyp__datum"/>
    <xsl:if test="$dates">
      <datacite:dates>
        <xsl:for-each select="$dates">
          <datacite:date>
            <xsl:attribute name="dateType">
              <xsl:choose>
                <xsl:when test="datumstyp/datumstyp[_id='2']">Issued</xsl:when>
                <xsl:otherwise>Created</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <!-- Datumswert, ggf. als Zeitraum -->
            <xsl:value-of select="anfang"/>
            <xsl:if test="string(ende)">
              <xsl:text>/</xsl:text>
              <xsl:value-of select="ende"/>
            </xsl:if>
          </datacite:date>
        </xsl:for-each>
      </datacite:dates>
    </xsl:if>
  </xsl:template>

  <!-- 9 Language (optional): TODO -->

  <!-- 10 Resource Type (mandatory) -->
  <xsl:template name="resourceType">
    <xsl:choose>
      <!-- Konvolut -->
      <xsl:when test="tags/tag[@id='1']">
        <datacite:resourceType resourceTypeGeneral="Collection">Collection</datacite:resourceType>
      </xsl:when>
      <!-- Datei -->
      <xsl:when test="tags/tag[@id='2']">
        <!-- TODO: check files for specific type (datei/files/class: image etc.) -->
      </xsl:when>
      <!-- Ausschnitt -->
      <xsl:when test="tags/tag[@id='3']">
        <!-- TODO -->
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- 11 AlternativeIdentifier (optional) -->
  <xsl:template name="alternateIdentifiers">
    <xsl:variable name="ids" select="_nested__objekttyp__alternative_id/objekttyp__alternative_id"/>  
    <datacite:alternateIdentifiers>
      <datacite:alternateIdentifier alternateIdentifierType="LaZAR URL">
        <xsl:value-of select="_urls/url[@type='easydb-id']"/>
      </datacite:alternateIdentifier>
      <datacite:alternateIdentifier alternateIdentifierType="UUID">
        <xsl:value-of select="_uuid"/>
      </datacite:alternateIdentifier>
      <xsl:for-each select="$ids">
        <datacite:alternateIdentifier alternateIdentifierType="unknown">
          <xsl:value-of select="name"/>
        </datacite:alternateIdentifier>
      </xsl:for-each>
    </datacite:alternateIdentifiers>
  </xsl:template>

  <!-- 12 RelatedIdentifier (optional): TODO -->

  <!-- 13 Size (optional): TODO -->

  <!-- 14 Format (optional): TODO -->

  <!-- 15 Version (optional) -->
  <xsl:template match="version">
    <datacite:version>
      <xsl:value-of select="."/>
    </datacite:version>
  </xsl:template>

  <!-- 16 Rights (optional): TODO -->

  <!-- 17 Description (optional): TODO -->

  <!-- 18 Geolocation (optional): TODO -->

  <!-- 19 FundingReference (optional): n/a -->

  <!-- ignore the rest -->
  <xsl:template match="@*|node()"/>

</xsl:stylesheet>
