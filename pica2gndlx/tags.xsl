<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="g" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://d-nb.info/standards/elementset/gnd#">

   <xsl:output encoding="UTF-8" method="text"/>
    
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="g:*">
        <xsl:value-of select="name(.)"/>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
   
    <xsl:template match="text()"/>

</xsl:stylesheet>

