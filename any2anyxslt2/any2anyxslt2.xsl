<?xml version="1.0" encoding="UTF-8"?>
<!-- Identity transformation with XSLT 2.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="for $e in @*|node() return $e"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
