<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:bibo="http://purl.org/ontology/bibo/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"

	exclude-result-prefixes="xlink mods" version="1.0">

<!--
    This script converts a MODS record to RDF/XML with common ontologies.
    Only the basic elements are supported.
-->

	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <rdf:RDF>
            <xsl:apply-templates/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="mods:mods">
        <rdf:Description> <!-- TODO: about -->
            <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
            <xsl:apply-templates/>
        </rdf:Description>
    </xsl:template>

    <!-- title -->
    <xsl:template match="mods:titleInfo[mods:title]">
        <dc:title><xsl:value-of select="mods:title"/></dc:title>
    </xsl:template>

    <!-- contributors (author, editor, etc.) -->
    <xsl:template match="mods:name[@type='personal'][@valueURI]">
        <dc:contributor rdf:resource="{@valueURI}"/>
    </xsl:template>

    <!-- subjects -->
    <xsl:template match="mods:subject[@valueURI]">
        <dc:subject rdf:resource="{@valueURI}"/>
    </xsl:template>
    
    <xsl:template match="*"/>

</xsl:stylesheet>
