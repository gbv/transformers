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
        <xsl:choose>
            <xsl:when test="$TYPE='Tp' and $GNDURI">
                <Person uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="Person"/>
                </Person>
            </xsl:when>
            <xsl:when test="$TYPE='Ts' and $GNDURI">
               <SubjectHeading uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="SubjectHeading"/>
                </SubjectHeading>
            </xsl:when>
            <xsl:when test="$TYPE='Tg' and $GNDURI">
               <PlaceOrGeographicName uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="PlaceOrGeographicName"/>
                </PlaceOrGeographicName>
            </xsl:when>
            <xsl:when test="$TYPE='Tb' and $GNDURI">
               <CorporateBody uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="CorporateBody"/>
                </CorporateBody>
            </xsl:when>
            <xsl:when test="$TYPE='Tf' and $GNDURI">
               <ConferenceOrEvent uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="ConferenceOrEvent"/>
                </ConferenceOrEvent>
            </xsl:when>
            <xsl:when test="$TYPE='?' and $GNDURI">
               <Family uri="{$GNDURI}" ppn="{key('sf','003@$0')}">
                    <xsl:apply-templates select="p:datafield" mode="Family"/>
                </Family>
            </xsl:when>
            <xsl:when test="$TYPE='Tu' and $GNDURI">
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
        <preferredName>
            <xsl:apply-templates mode="name"/>
        </preferredName>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='028@' or @tag='028E']" mode="Person">
        <!--<xsl:if test="not(p:subfield[@code='4'])">-->
            <variantName>
                <xsl:apply-templates mode="name"/>
            </variantName>
        <!--</xsl:if>-->
    </xsl:template>

    <xsl:template match="p:subfield[@code='d']" mode="name">
       <!-- <xsl:if test="normalize-space(.) != '...'">-->
            <forename><xsl:value-of select="."/></forename>
        <!--</xsl:if>-->
    </xsl:template>

    <xsl:template match="p:subfield[@code='a']" mode="name">
        <xsl:if test="normalize-space(.) != '...'">
            <surname><xsl:value-of select="."/></surname>
        </xsl:if>
    </xsl:template>

    <xsl:template match="p:subfield[@code='c']" mode="name">
        <prefix><xsl:value-of select="."/></prefix>
    </xsl:template>

    <xsl:template match="p:subfield[@code='l']" mode="name">
        <epithetGenericNameTitleOrTerritory><xsl:value-of select="."/></epithetGenericNameTitleOrTerritory>
    </xsl:template>

    <xsl:template match="p:subfield[@code='P']" mode="name">
        <personalName><xsl:value-of select="."/></personalName>
    </xsl:template>

    <xsl:template match="p:subfield[@code='n']" mode="name">
        <counting><xsl:value-of select="."/></counting>
    </xsl:template>

    <!-- name additions (subfield $v = MARC21 100 $9) are ignored  -->

    <xsl:template match="*|text()" mode="name"/>

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

    <xsl:template match="p:datafield[@tag='041R'][p:subfield[@code='0']]" mode="Person">
        <professionOrOccupation>
            <xsl:call-template name="gnduriattr"/>
            <xsl:value-of select="p:subfield[@code='a']"/>
        </professionOrOccupation>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='060R'][p:subfield[@code='4']='datl']" mode="Person">
        <xsl:if test="p:subfield[@code='a']">
            <dateOfBirth>
                <xsl:value-of select="p:subfield[@code='a']"/>
            </dateOfBirth>
        </xsl:if>
        <xsl:if test="p:subfield[@code='b']">
            <dateOfDeath>
                <xsl:value-of select="p:subfield[@code='b']"/>
            </dateOfDeath>
        </xsl:if>
        <!-- TODO: check whether some records contain subfield $c and $d -->
    </xsl:template>

    <xsl:template match="p:datafield[@tag='032T']" mode="Person">
        <xsl:variable name="gender" select="p:subfield[@code='a']"/>
        <!-- TODO: urge DNB to ontroduce transexual and more genders -->
        <xsl:if test="$gender='m' or $gender='w'">
            <gender><xsl:value-of select="$gender"/></gender>
        </xsl:if>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='050G'][p:subfield[@code='b']]" mode="Person">
        <biographicalOrHistoricalInformation>
            <xsl:value-of select="p:subfield[@code='b']"/>
        </biographicalOrHistoricalInformation>
    </xsl:template>

    <!-- SubjectHeading ............................................ -->

    <xsl:template match="p:datafield[@tag='041A']" mode="SubjectHeading">
        <preferredName>
            <xsl:value-of select="p:subfield[@code='a']"/>
            <xsl:apply-templates select="p:subfield[@code='g']" mode="addition"/>
        </preferredName>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='041@']" mode="SubjectHeading">
        <variantName>
            <xsl:value-of select="p:subfield[@code='a']"/>
            <xsl:apply-templates select="p:subfield[@code='g']" mode="addition"/>
            <xsl:apply-templates select="p:subfield[@code='x']" mode="additionslash"/>
            <xsl:apply-templates select="p:subfield[@code='v']" mode="additionbrackets"/>
        </variantName>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='050H']" mode="SubjectHeading">
        <definition>
            <xsl:value-of select="p:subfield[@code='a']"/>
        </definition>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='041R']" mode="SubjectHeading">
        <xsl:call-template name="broader"/>
    </xsl:template>

    <!-- CorporateBody ............................................. -->

    <xsl:template match="p:datafield[@tag='029A']" mode="CorporateBody">
        <preferredName>
            <xsl:value-of select="p:subfield[@code='a']"/>
            <xsl:if test="p:subfield[@code='b']">
                <xsl:text> / </xsl:text>
                <xsl:value-of select="p:subfield[@code='b']"/>
            </xsl:if>
            <xsl:apply-templates select="p:subfield[@code='g']" mode="addition"/>       
            <!-- TODO: weitere Teile? -->
        </preferredName>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='029@']" mode="CorporateBody">
        <xsl:if test="p:subfield[@code='4'] != ''">
            <variantName>
                <xsl:value-of select="p:subfield[@code='a']"/>
                <xsl:apply-templates select="p:subfield[@code='g']" mode="addition"/>
                <xsl:apply-templates select="p:subfield[@code='b']" mode="additionslash"/>
            </variantName>
        </xsl:if>     
    </xsl:template>

    <xsl:template match="p:datafield[@tag='041R']" mode="CorporateBody">
        <xsl:call-template name="broader"/>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='065R'][p:subfield[@code='4']='orta']" mode="CorporateBody">
        <placeOfBusiness>
            <xsl:call-template name="gnduriattr"/>
            <xsl:value-of select="p:subfield[@code='a']"/>
        </placeOfBusiness>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='065R'][p:subfield[@code='4']='adue']" mode="CorporateBody">
        <xsl:call-template name="broader"/>
    </xsl:template>

    <xsl:template match="p:datafield[@tag='060R']" mode="CorporateBody">
        <xsl:if test="p:subfield[@code='a'] != ''">
            <dateOfEstablishment>
                <xsl:value-of select="p:subfield[@code='a']"/>   
            </dateOfEstablishment>        
        </xsl:if>             
        <xsl:if test="p:subfield[@code='b'] != ''">
            <dateOfTermination>
                <xsl:value-of select="p:subfield[@code='b']"/>   
            </dateOfTermination>        
        </xsl:if>  
    </xsl:template>

    <xsl:template match="p:datafield[@tag='029R'][p:subfield[@code='4']='vorg']" mode="CorporateBody">
        <precedingCorporateBody>
            <xsl:call-template name="gnduriattr"/>
            <xsl:value-of select="p:subfield[@code='a']"/>
            <xsl:apply-templates select="p:subfield[@code='g']" mode="addition"/>
        </precedingCorporateBody>
    </xsl:template>
    
    <!-- ConferenceOrEvent ......................................... -->

    <!-- TODO -->

        <!-- dateOfConferenceOrEvent -->

    <!-- PlaceOrGeographicName ..................................... -->
 
    <xsl:template match="p:datafield[@tag='042B']" mode="PlaceOrGeographicName">
        <areacode>
            <xsl:value-of select="."/>
        </areacode>     
    </xsl:template>      
  
    <xsl:template match="p:datafield[@tag='004B']" mode="PlaceOrGeographicName">
        <type>
            <xsl:value-of select="."/>
        </type>     
    </xsl:template>   
    
    <xsl:template match="p:datafield[@tag='029@']" mode="PlaceOrGeographicName">
        <variantName>
            <xsl:value-of select="p:subfield[@code='a']"/>
            <xsl:apply-templates select="p:subfield[@code='g']" mode="addition"/>
            <xsl:apply-templates select="p:subfield[@code='b']" mode="additionslash"/>
        </variantName>
    </xsl:template>   
    
    <xsl:template match="p:datafield[@tag='065@']" mode="PlaceOrGeographicName">
        <variantName>
            <xsl:value-of select="p:subfield[@code='a']"/>
            <xsl:apply-templates select="p:subfield[@code='g']" mode="addition"/>
        </variantName>
    </xsl:template>  
    
    <xsl:template match="p:datafield[@tag='065A']" mode="PlaceOrGeographicName">
        <preferredName>
            <xsl:value-of select="."/>
        </preferredName>     
    </xsl:template>   

    <!-- Family..................................................... -->

    <!-- TODO -->

    <!-- Work ...................................................... -->

    <!-- TODO: date = dateOfPublication -->
    <!-- dateOfDiscovery ? -->

    <!-- TODO -->

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

    <xsl:template match="p:subfield[@code='g']" mode="addition">
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>
    
    <xsl:template match="p:subfield[@code='x'] | p:subfield[@code='b']" mode="additionslash">
        <xsl:text> / </xsl:text>
        <xsl:value-of select="."/>
    </xsl:template>   
    
    <xsl:template match="p:subfield[@code='v']" mode="additionbrackets">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>)</xsl:text>
    </xsl:template>     

    <xsl:template name="broader">
        <xsl:variable name="rel" select="p:subfield[@code='4']"/>
        <xsl:if test="$rel='obal' or $rel='obge' or $rel='obin' or $rel = 'obpa' or $rel='adue'">
            <broaderTerm>
                <xsl:call-template name="gnduriattr"/>
                <xsl:value-of select="p:subfield[@code='a']"/>
            </broaderTerm>
        </xsl:if>
    </xsl:template>

    <!-- ignore everything else -->
    <xsl:template match="*|text()"/>
    <xsl:template match="*|text()" mode="ConferenceOrEvent"/>
    <xsl:template match="*|text()" mode="CorporateBody"/>
    <xsl:template match="*|text()" mode="Family"/>
    <xsl:template match="*|text()" mode="Person"/>
    <xsl:template match="*|text()" mode="PlaceOrGeographicName"/>
    <xsl:template match="*|text()" mode="SubjectHeading"/>
    <xsl:template match="*|text()" mode="Work"/>

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

