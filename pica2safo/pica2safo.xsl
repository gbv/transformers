<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="p" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:p="info:srw/schema/5/picaXML-v1.0">

    <!--
        Konvertiert PICA+ Normdatensätze der GND in eine einfache XML-Struktur für
        Normdatensätze (siehe https://gist.github.com/nichtich/5309729)
    -->

    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    
    <xsl:variable name="gnduri" select="/p:record/p:datafield[@tag='003U']/p:subfield[@code='a']"/>
    <xsl:variable name="type" select="substring(/p:record/p:datafield[@tag='002@']/p:subfield[@code='0'],1,2)"/>

    <xsl:template match="/p:record">
        <xsl:choose>
            <xsl:when test="$type='Tp'">
                <xsl:apply-templates select="." mode="Person"/>
            </xsl:when>
            <!-- TODO: andere typen -->
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="Error"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

   
    <xsl:template match="p:record" mode="Person">
        <Person id="{$gnduri}">
            <xsl:apply-templates select="p:datafield"/>
        </Person>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='003@']">
        <gvkppn><xsl:value-of select="p:subfield[@code='0']"/></gvkppn>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='028A']">
        <Name>
            <Given><xsl:value-of select="p:subfield[@code='d']"/></Given>
            <Surname><xsl:value-of select="p:subfield[@code='a']"/></Surname>
        </Name>
    </xsl:template>

    <xsl:template name="ppn">
        <xsl:value-of select="p:datafield[@tag='003@']/p:subfield[@code='0']"/>
    </xsl:template>


    <!-- Kein Mapping möglich -->

    <xsl:template match="p:record" mode="Error">
        <Error>
            <xsl:apply-templates select="p:datafield[@tag='003@']"/>
            <Message>
                <xsl:choose>
                    <xsl:when test="substring($type,1,1)!='T'">
                        <xsl:text>not an authority record</xsl:text>
                    </xsl:when>
                    <xsl:when test="not($gnduri)">
                        <xsl:text>not a GND record</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>unsupported record type: </xsl:text>
                        <xsl:value-of select="$type"/>
                    </xsl:otherwise>
                </xsl:choose>
            </Message>
        </Error>
    </xsl:template>
 
    <xsl:template match="*"/>

</xsl:stylesheet>

