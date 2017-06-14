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
      <xsl:apply-templates select="_nested__objekttyp__urheber/objekttyp__urheber"/>
      <datacite:dates>
        <xsl:apply-templates select="_nested__objekttyp__datum/objekttyp__datum"/>
      </datacite:dates>
    </datacite:resource>
  </xsl:template>
 
  <xsl:template match="objekttyp__urheber">
    <datacite:creator>
      <datacite:creatorName>
        <xsl:value-of select="urheber/person_urheber/name"/>
      </datacite:creatorName>
    </datacite:creator>
  </xsl:template>

  <!-- Publikations- oder Entstehungsdatum -->
  <xsl:template match="objekttyp__datum">
    <datacite:date>
      <xsl:attribute name="dateType">
        <xsl:apply-templates select="datumstyp/datumstyp"/>
      </xsl:attribute>
      <xsl:value-of select="anfang"/>
    </datacite:date>
  </xsl:template>

  <!-- Entstehungsdatum -->
  <xsl:template match="datumstyp[_id='1']">Created</xsl:template>

  <!-- Publikationsdatum -->
  <xsl:template match="datumstyp[_id='2']">Issued</xsl:template>

  <!-- ignore the rest -->
  <xsl:template match="@*|node()"/>
 
</xsl:stylesheet>
