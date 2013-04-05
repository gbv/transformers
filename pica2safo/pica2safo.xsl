<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="p" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:p="info:srw/schema/5/picaXML-v1.0"
    xmlns="http://d-nb.info/standards/elementset/gnd#">

    <!--
        Konvertiert PICA+ Normdatensätze der GND in eine einfache XML-Struktur für
        Normdatensätze (siehe https://gist.github.com/nichtich/5309729)

        Die XML-Elementbezeichnungen entsprechen soweit möglich den 
        Klassen- und Property-Namen der GND-Ontology:
            http://d-nb.info/standards/elementset/gnd
    -->

    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    
    <xsl:variable name="GNDURI" select="key('sf','003U$a')"/>
    <xsl:variable name="TYPE" select="substring(key('sf','002@$0'),1,2)"/>

    <xsl:template match="/p:record">
        <xsl:variable name="mode">Person</xsl:variable>
        <xsl:choose>
            <xsl:when test="$TYPE='Tp' and $GNDURI">
                <Person uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="Person"/>
                </Person>
            </xsl:when>
            <xsl:when test="$TYPE='?' and $GNDURI">
               <SubjectHeading uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="SubjectHeading"/>
                </SubjectHeading>
            </xsl:when>
            <xsl:when test="$TYPE='?' and $GNDURI">
               <PlaceOrGeographicName uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="PlaceOrGeographicName"/>
                </PlaceOrGeographicName>
            </xsl:when>
            <xsl:when test="$TYPE='?' and $GNDURI">
               <CorporateBody uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="CorporateBody"/>
                </CorporateBody>
            </xsl:when>
            <xsl:when test="$TYPE='?' and $GNDURI">
               <ConferenceOrEvent uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="ConferenceOrEvent"/>
                </ConferenceOrEvent>
            </xsl:when>
            <xsl:when test="$TYPE='?' and $GNDURI">
               <Family uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="Family"/>
                </Family>
            </xsl:when>
            <xsl:when test="$TYPE='?' and $GNDURI">
               <Work uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="Work"/>
                </Work>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="Error"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
    <!-- Person .................................................... -->

    <xsl:template match="p:datafield[@tag='028A']" mode="Person">
        <Name>
            <forename><xsl:value-of select="p:subfield[@code='d']"/></forename>
            <surname><xsl:value-of select="p:subfield[@code='a']"/></surname>
        </Name>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='065R']" mode="Person">
        <xsl:variable name="element">
            <xsl:if test="p:subfield[@code='4']='ortg'">placeOfBirth</xsl:if>
            <xsl:if test="p:subfield[@code='4']='orts'">placeOfDeath</xsl:if>
        </xsl:variable>
        <xsl:if test="$element">
            <xsl:element name="{$element}">
                <xsl:call-template name="gnduriattr"/>
                <xsl:value-of select="p:subfield[@code='a']"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- SubjectHeading ............................................ -->

    <!-- ConferenceOrEvent ......................................... -->

    <!-- CorporateBody ............................................. -->

    <!-- PlaceOrGeographicName ..................................... -->

    <!-- Family..................................................... -->

    <!-- Work ...................................................... -->

    <!-- Error ..................................................... -->

    <xsl:template match="p:record" mode="Error">
        <Error ppn="{key('sf','003@$0')}">
            <xsl:choose>
                <xsl:when test="substring($TYPE,1,1)!='T'">
                    <xsl:text>not an authority record</xsl:text>
                </xsl:when>
                <xsl:when test="not($GNDURI)">
                    <xsl:text>not a GND record</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>unsupported record type: </xsl:text>
                    <xsl:value-of select="$TYPE"/>
                </xsl:otherwise>
            </xsl:choose>
        </Error>
    </xsl:template>

    <!-- utility templates ......................................... -->

    <xsl:template name="gnduriattr">
        <xsl:for-each select="p:subfield[@code='0'][substring(.,1,4)='gnd/'][1]"> 
            <xsl:attribute name="uri">
                <xsl:text>http://d-nb.info/gnd/</xsl:text>
                <xsl:value-of select="substring(.,5)"/>
            </xsl:attribute>
        </xsl:for-each>
    </xsl:template>

    <!-- ignore everything else -->
    <xsl:template match="*"/>
    <xsl:template match="*" mode="ConferenceOrEvent"/>
    <xsl:template match="*" mode="CorporateBody"/>
    <xsl:template match="*" mode="Family"/>
    <xsl:template match="*" mode="Person"/>
    <xsl:template match="*" mode="PlaceOrGeographicName"/>
    <xsl:template match="*" mode="SubjectHeading"/>
    <xsl:template match="*" mode="Work"/>

    <!-- useful to select PICA+ fields and subfields -->
    <xsl:key name="field" match="p:datafield" use="concat( @tag ,
      substring( 
        concat('/',@occurrence),
        1, 
        number( string-length(@occurrence) &gt; 0 )
        * ( string-length(@occurrence) + 1 )
      )
    )"/>

    <xsl:key name="sf" match="p:subfield" use="concat( parent::p:datafield/@tag,
      substring( 
        concat('/',parent::p:datafield/@occurrence),
        1, 
        number( string-length(parent::p:datafield/@occurrence) &gt; 0 )
        * (string-length( parent::p:datafield/@occurrence ) + 1 )
      ),
      '$',@code
    )"/>

</xsl:stylesheet>

