<?xml version="1.0" encoding="UTF-8"?>
<!--
     LaZAR-DB Export nach DataCite
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:datacite="http://datacite.org/schema/kernel-4">

  <xsl:output method="xml" indent="yes"/>

  <!-- Wurzelelement -->
  <xsl:template match="objects">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- LaZAR-Objekttyp "Objekttyp" -->
  <xsl:template match="objekttyp">
    <datacite:resource
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd">
      <!-- mandatory fields -->
      <identifier identifierType="DOI">
        <!-- TODO (mandatory!) -->
      </identifier>
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
      <xsl:call-template name="descriptions"/>
      <xsl:call-template name="dates"/>
      <xsl:call-template name="alternateIdentifiers"/>
      <xsl:call-template name="relatedIdentifiers"/>
      <xsl:call-template name="size"/>
      <xsl:apply-templates select="version"/>
      <xsl:call-template name="rights"/>
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
    <xsl:for-each select="titel/*[string()]">
      <datacite:title xml:lang="{substring-before(local-name(),'-')}">
        <xsl:if test="$titleType!=''">
          <xsl:attribute name="titleType">
            <xsl:value-of select="normalize-space($titleType)"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="."/>
      </datacite:title>
    </xsl:for-each> 
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
      <!-- TODO: this is required! -->
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
      <!-- Datei oder Ausschnitt -->
      <xsl:otherwise>
        <xsl:variable name="class" select="datei/files/file/class"/>
        <!-- Datei-Klasse -->
        <xsl:variable name="type">
          <xsl:choose>
            <xsl:when test="$class='image'">Image</xsl:when>
            <xsl:when test="$class='video'">Audiovisual</xsl:when>
            <!-- not tested! -->
            <xsl:when test="$class='audio'">Sound</xsl:when>
            <!-- not tested! -->
            <xsl:when test="$class='office'">Text</xsl:when>
            <xsl:otherwise>Other</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <datacite:resourceType resourceTypeGeneral="{$type}">
          <xsl:value-of select="$type"/>
        </datacite:resourceType>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 11 AlternativeIdentifier (optional) -->
  <xsl:template name="alternateIdentifiers">
    <datacite:alternateIdentifiers>
      <datacite:alternateIdentifier alternateIdentifierType="LaZAR URL">
        <xsl:value-of select="_urls/url[@type='easydb-id']"/>
      </datacite:alternateIdentifier>
      <datacite:alternateIdentifier alternateIdentifierType="UUID">
        <xsl:value-of select="_uuid"/>
      </datacite:alternateIdentifier>
      <xsl:for-each select="_nested__objekttyp__alternative_id/objekttyp__alternative_id">
        <datacite:alternateIdentifier alternateIdentifierType="unknown">
          <xsl:value-of select="name"/>
        </datacite:alternateIdentifier>
      </xsl:for-each>
    </datacite:alternateIdentifiers>
  </xsl:template>

  <!-- 12 RelatedIdentifier (optional) -->
  <xsl:template name="relatedIdentifiers">
    <datacite:relatedIdentifiers>
      <!-- Deep Link to record view in easydb -->
      <datacite:relatedIdentifier relatedIdentifierType="URL" relationType="isIdenticalTo">
        <xsl:value-of select="_urls/url[@type='easydb-id']"/>
      </datacite:relatedIdentifier>
      <xsl:if test="tags/tag[@id='2']">
        <datacite:relatedIdentifier relatedIdentifierType="URL" relationType="isIdenticalTo">
          <xsl:value-of select="datei/files/file/versions/version[1]/deep_link_url"/>
        </datacite:relatedIdentifier>
      </xsl:if>
    </datacite:relatedIdentifiers>
  </xsl:template>

  <!-- 13 Size (optional) -->
  <xsl:template name="size">
    <xsl:variable name="size">
      <xsl:choose>
        <!-- Datei -->
        <xsl:when test="tags/tag[@id='2']">
          <xsl:value-of select="substring-after(datei/files/file/compiled,', ')"/>
        </xsl:when>
        <!-- TODO: Konvolute und Ausschnitte? -->
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string($size)">
      <datacite:sizes>
        <datacite:size>
          <xsl:value-of select="$size"/>
        </datacite:size>
      </datacite:sizes>
    </xsl:if>
  </xsl:template>

  <!-- 14 Format (optional): TODO -->

  <!-- 15 Version (optional) -->
  <xsl:template match="version">
    <datacite:version>
      <xsl:value-of select="."/>
    </datacite:version>
  </xsl:template>

  <!-- 16 Rights (optional) -->
  <xsl:template name="rights">
    <xsl:choose>
      <xsl:when test="tags/tag[@id='10']">
        <datacite:rightsList>
          <datacite:rights rightsURI="https://creativecommons.org/publicdomain/zero/1.0/">CC0 1.0 Universal (CC0 1.0) Public Domain Dedication</datacite:rights>
        </datacite:rightsList>
      </xsl:when>
      <xsl:when test="tags/tag[@id='11']">
        <datacite:rightsList>
          <datacite:rights rightsURI="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International (CC BY 4.0)</datacite:rights>
        </datacite:rightsList>
      </xsl:when>
      <xsl:when test="tags/tag[@id='12']">
        <datacite:rightsList>
          <datacite:rights rightsURI="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)</datacite:rights>
        </datacite:rightsList>
      </xsl:when>
      <xsl:when test="tags/tag[@id='13']">
        <datacite:rightsList>
          <datacite:rights rightsURI="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)</datacite:rights>
        </datacite:rightsList>
      </xsl:when>
      <xsl:when test="tags/tag[@id='14']">
        <datacite:rightsList>
          <datacite:rights rightsURI="http://creativecommons.org/licenses/by-nc-nd/4.0/">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)</datacite:rights>
        </datacite:rightsList>
      </xsl:when>
      <xsl:when test="tags/tag[@id='22']">
        <datacite:rightsList>
          <datacite:rights rightsURI="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)</datacite:rights>
        </datacite:rightsList>
      </xsl:when>
      <xsl:when test="tags/tag[@id='17']">
        <datacite:rightsList>
          <datacite:rights rightsURI="http://creativecommons.org/licenses/by-nd/4.0/">Creative Commons Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)</datacite:rights>
        </datacite:rightsList>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- 17 Description (optional) -->
  <xsl:template name="descriptions">
    <xsl:variable name="descriptions" select="beschreibung/*[string()]"/>
    <!-- TODO: Methoden => Methods -->
    <xsl:if test="$descriptions">
      <datacite:descriptions>
        <xsl:for-each select="$descriptions">
          <xsl:variable name="language" select="substring-before(local-name(),'-')"/>
          <datacite:description descriptionType="Abstracts" xml:lang="{$language}">
            <xsl:value-of select="."/>
          </datacite:description>
        </xsl:for-each>
      </datacite:descriptions>
    </xsl:if>
  </xsl:template>

  <!-- 18 Geolocation (optional): TODO -->

  <!-- 19 FundingReference (optional): n/a -->

  <!-- ignore the rest -->
  <xsl:template match="@*|node()"/>

</xsl:stylesheet>
