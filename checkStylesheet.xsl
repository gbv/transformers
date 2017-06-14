<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <!--
  USAGE: xsltproc checkStylesheet.xsl $STYLESHEET
   -->

  <xsl:template match="/xsl:stylesheet">
    <xsl:if test="@version != '1.0'">
      <xsl:message terminate="yes">only XSLT 1.0 supported</xsl:message>
    </xsl:if>
    <xsl:if test="xsl:include">
      <xsl:message terminate="yes">stylesheet must not use xsl:include!</xsl:message>
    </xsl:if>
  </xsl:template>
 
</xsl:stylesheet>
