<?xml version="1.0" encoding="UTF-8"?>

<!-- Extract the metadata record from an OAI-PMH GetRecord response -->
<xsl:stylesheet 
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  >

  <!-- extract first metadata element -->
  <xsl:template match="/oai:OAI-PMH">
    <xsl:copy-of select="oai:GetRecord/oai:record/oai:metadata/*"/>
  </xsl:template>

  <!-- ignore the rest -->
  <xsl:template match="@*|node()"/>

</xsl:stylesheet>  
