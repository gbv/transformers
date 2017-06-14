<?xml version="1.0" encoding="UTF-8"?>
<!-- 
     LaZAR-DB Export nach Dublin Core
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.openarchives.org/OAI/2.0/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
  >

  <xsl:output method="xml" indent="yes"/>

  <!-- Wurzelelement -->
  <xsl:template match="objects">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- LaZAR-Objekttyp "Objekttyp" -->
  <xsl:template match="objekttyp">
    <dc:metadata>
      <xsl:apply-templates/>
    </dc:metadata>
  </xsl:template>


  <!-- dc:contributor -->
  <xsl:template match="_nested__objekttyp__contributor">
    <xsl:for-each select="objekttyp__contributor/contributor/person_contributor">
      <dc:contributor>
        <xsl:value-of select="name"/>
      </dc:contributor>
    </xsl:for-each>
  </xsl:template>

  <!-- dc:coverage -->
  <!-- ... -->

  <!-- dc:creator -->
  <xsl:template match="_nested__objekttyp__urheber">
    <xsl:for-each select="objekttyp__urheber/urheber/person_urheber">
      <dc:creator>
        <xsl:value-of select="name"/>
      </dc:creator>
    </xsl:for-each>
  </xsl:template>

  <!-- dc:date -->
  <xsl:template match="_nested__objekttyp__datum">
    <!-- Created -->
    <xsl:for-each select="objekttyp__datum[datumstyp/datumstyp[_id='1']]">
      <dc:date>
        <xsl:value-of select="anfang"/>
      </dc:date>
    </xsl:for-each>
    <!-- Issued -->
    <xsl:for-each select="objekttyp__datum[datumstyp/datumstyp[_id='2']]">
      <dcterms:issued>
        <xsl:value-of select="anfang"/>
      </dcterms:issued>
    </xsl:for-each>
  </xsl:template>

  <!-- dc:description -->
  <!-- beschreibung, methoden -->

  <!-- dc:format -->
  <!-- ... -->

  <!-- dc:identifier -->
  <xsl:template match="_urls | datei">
    <xsl:for-each select="url[@type='easydb-id'] | files/file/versions/version/deep_link_url">
      <dc:identifier>
        <xsl:value-of select="."/>
      </dc:identifier>
    </xsl:for-each>
  </xsl:template>  
  <!-- version, alternative_id...-->

  <!-- dc:language -->
  <!-- ...sprachen -->

  <!-- dc:publisher -->
  <!-- ... -->

  <!-- dc:relation -->
  <!-- relationen, datei... -->

  <!-- dc:source -->
  <!-- ... -->

  <!-- dc:subject -->
  <!-- thema, keywords, orte... -->

  <!-- dc:title -->
  <xsl:template match="_nested__objekttyp__titel">
	  <dc:title>						
      <xsl:value-of select="objekttyp__titel/titel/de-DE"/>
    </dc:title>						
  </xsl:template>

  <!-- dc:type -->
  <!-- ... -->



  <xsl:template match="_parent">
    <dcterms:isPartOf>
      <xsl:text>https://lazardb.gbv.de/detail/</xsl:text>
      <xsl:value-of select="id"/>
    </dcterms:isPartOf>
  </xsl:template>

  <!-- ignore the rest -->
  <xsl:template match="@*|node()"/>

</xsl:stylesheet>
