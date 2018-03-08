<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:p="info:srw/schema/5/picaXML-v1.0"
    xmlns="info:srw/schema/5/picaXML-v1.0">

    <!-- Extrahiert PICA+ Titel-Felder (Ebene 0) -->

    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:strip-space elements="p:datafield"/>
    <xsl:preserve-space elements="p:subfield"/>
  
    <xsl:template match="/p:record">
      <record>
        <xsl:for-each select="p:datafield[substring(@tag,1,1)='0']">
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </record>
    </xsl:template>

    <xsl:template match="*"/>

</xsl:stylesheet>

