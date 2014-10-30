<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="p" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:p="info:srw/schema/5/picaXML-v1.0">

    <!-- Extrahiert die für DAIA relevanten PICA+ Felder -->

    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:strip-space elements="*"/>
  
    <xsl:template match="/p:record">
        <p:record>
            <xsl:apply-templates select="p:datafield"/> 
        </p:record>
    </xsl:template>

    <!-- 002@ und 003@ -->
    <xsl:template match="p:datafield[@tag='002@' or @tag='003@']">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- 009P und 209R -->
    <xsl:template match="p:datafield[@tag='009P' or @tag='209R']">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- 101@ $a -->
    <xsl:template match="p:datafield[@tag='101@']">
        <p:datafield tag="{@tag}">
            <xsl:copy-of select="p:subfield[@code='a']"/>
        </p:datafield>
    </xsl:template>

    <!-- 209A $adfce -->
    <xsl:template match="p:datafield[@tag='209A']">
        <p:datafield tag="{@tag}">
            <xsl:copy-of select="p:subfield[contains('adfce',@code)]"/>
        </p:datafield>
    </xsl:template>

    <!-- 201@ $lbn -->
    <xsl:template match="p:datafield[@tag='201@']">
        <p:datafield tag="{@tag}">
            <xsl:copy-of select="p:subfield[contains('lbn',@code)]"/>
        </p:datafield>
    </xsl:template>

    <!-- 237A (Exemplarbezogener Kommentar) -->
    <xsl:template match="p:datafield[@tag='237A']">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="*"/>

</xsl:stylesheet>

