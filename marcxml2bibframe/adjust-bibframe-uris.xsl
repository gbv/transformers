<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
    xmlns:bflc="http://id.loc.gov/ontologies/bflc/">

  <!--
	Change "http://example.org/{PPN}#Instance" 
        to "http://uri.gbv.de/document/gvk:ppn:{PPN}"
  -->

  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>

  <!-- TODO: use dbkey instead of gvk -->
  <xsl:variable name="prefix">http://uri.gbv.de/document/gvk:</xsl:variable>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*[name()='rdf:about' or name()='rdf:resource']">
    <xsl:apply-templates select="." mode="URI"/>
  </xsl:template>

  <xsl:template match="@*" mode="URI">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="@*[substring(.,string-length(.)-8) = '#Instance']" mode="URI">
	<xsl:attribute name="{name()}">
      <xsl:value-of select="$prefix"/>
      <xsl:text>ppn:</xsl:text>
	  <xsl:value-of select="substring(.,20,string-length(.)-28)"/>
	</xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
