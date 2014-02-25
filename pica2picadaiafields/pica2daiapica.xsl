<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="p" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:p="info:srw/schema/5/picaXML-v1.0">

    <!-- Extrahiert die für DAIA relevanten PICA+ Felder -->

    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="GNDURI" select="key('sf','003U$a')"/>
    <xsl:variable name="TYPE" select="substring(key('sf','002@$0'),1,2)"/>
   
    <xsl:template match="/p:record">
        <p:record>
            <xsl:apply-templates select="p:datafield"/> 
        </p:record>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='003@' or 
        @tag='101@' or @tag='209A' or @tag='201@' or @tag='237A']">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="*"/>
</xsl:stylesheet>

