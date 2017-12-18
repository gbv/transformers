<?xml version="1.0" encoding="UTF-8"?>
<!--
Extract one easyDB XML from OAI-PMH getRecord request.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:oai="http://www.openarchives.org/OAI/2.0/"
  xmlns:datacite="http://datacite.org/schema/kernel-4"
  xmlns="http://schema.programmfabrik.de/easydb-data/1.0"
  exclude-result-prefixes="oai datacite">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="oai:OAI-PMH">
    <xsl:apply-templates select="oai:GetRecord/oai:record/oai:metadata/*"/>
  </xsl:template>

  <xsl:template match="objects">
    <objects xmlns="http://schema.programmfabrik.de/easydb-data/1.0">
      <xsl:apply-templates/>
    </objects>
  </xsl:template>

  <xsl:template match="*">
    <xsl:element name="{local-name(.)}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="normalize-space()" />
  </xsl:template>

</xsl:stylesheet>
