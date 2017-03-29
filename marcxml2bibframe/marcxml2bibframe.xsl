<?xml version="1.0"?>
<xsl:stylesheet xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:bflc="http://id.loc.gov/ontologies/bflc/" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="xsl marc">

  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="baseuri" select="'http://example.org/'"/>
  <xsl:param name="idfield" select="'001'"/>
  <xsl:param name="serialization" select="'rdfxml'"/>

  <xsl:template match="marc:datafield" mode="xmllang">
    <xsl:if test="marc:subfield[@code='6'] and ../marc:controlfield[@tag='008']">
      <xsl:variable name="vLang008"><xsl:value-of select="substring(../marc:controlfield[@tag='008'],36,3)"/></xsl:variable>
      <xsl:variable name="vScript6"><xsl:value-of select="substring-after(marc:subfield[@code='6'],'/')"/></xsl:variable>
      <xsl:variable name="vScript6simple">
        <xsl:choose>
          <xsl:when test="contains(vScript6,'/')"><xsl:value-of select="substring-before($vScript6,'/')"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$vScript6"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="vLang"><xsl:value-of select="$languageMap/xml-langs/language/iso6392[text()=$vLang008]/parent::*/@xmllang"/></xsl:variable>
      <xsl:variable name="vScript">
        <xsl:choose>
          <xsl:when test="$vScript6simple='(3'">arab</xsl:when>
          <xsl:when test="$vScript6simple='(B'">latn</xsl:when>
          <xsl:when test="$vScript6simple='$1' and $vLang008='kor'">hang</xsl:when>
          <xsl:when test="$vScript6simple='$1' and $vLang008='chi'">hani</xsl:when>
          <xsl:when test="$vScript6simple='$1' and $vLang008='jpn'">jpan</xsl:when>
          <xsl:when test="$vScript6simple='(N'">cyrl</xsl:when>
          <xsl:when test="$vScript6simple='(S'">grek</xsl:when>
          <xsl:when test="$vScript6simple='(2'">hebr</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$vLang != '' and $vScript != ''"><xsl:value-of select="concat($vLang,'-',$vScript)"/></xsl:if>
    </xsl:if>
  </xsl:template><xsl:template name="chopBrackets">
    <xsl:param name="chopString"/>
    <xsl:param name="punctuation">
      <xsl:text>.:,;/ </xsl:text>
    </xsl:param>
    <xsl:variable name="string">
      <xsl:call-template name="chopPunctuation">
	<xsl:with-param name="chopString" select="$chopString"/>
        <xsl:with-param name="punctuation" select="$punctuation"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="substring($string,1,1)='['">
        <xsl:call-template name="chopBrackets">
          <xsl:with-param name="chopString" select="substring-after($string,'[')"/>
          <xsl:with-param name="punctuation" select="$punctuation"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="substring($string,string-length($string),1) = ']'">
        <xsl:call-template name="chopBrackets">
          <xsl:with-param name="chopString" select="substring($string,1,string-length($string)-1)"/>
          <xsl:with-param name="punctuation" select="$punctuation"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$string"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template name="chopParens">
    <xsl:param name="chopString"/>
    <xsl:param name="punctuation">
      <xsl:text>.:,;/ </xsl:text>
    </xsl:param>
    <xsl:variable name="string">
      <xsl:call-template name="chopPunctuation">
	<xsl:with-param name="chopString" select="$chopString"/>
        <xsl:with-param name="punctuation" select="$punctuation"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="substring($string,1,1)='('">
        <xsl:call-template name="chopParens">
          <xsl:with-param name="chopString" select="substring-after($string,'(')"/>
          <xsl:with-param name="punctuation" select="$punctuation"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="substring($string,string-length($string),1) = ')'">
        <xsl:call-template name="chopParens">
          <xsl:with-param name="chopString" select="substring($string,1,string-length($string)-1)"/>
          <xsl:with-param name="punctuation" select="$punctuation"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$string"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template name="chopPunctuation">
    <xsl:param name="chopString"/>
    <xsl:param name="punctuation">
      <xsl:text>.:,;/ </xsl:text>
    </xsl:param>
    <xsl:variable name="length" select="string-length($chopString)"/>
    <xsl:choose>
      <xsl:when test="$length=0"/>
      <xsl:when test="contains($punctuation, substring($chopString,$length,1))">
	<xsl:call-template name="chopPunctuation">
	  <xsl:with-param name="chopString" select="substring($chopString,1,$length - 1)"/>
	  <xsl:with-param name="punctuation" select="$punctuation"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="not($chopString)"/>
      <xsl:otherwise>
	<xsl:value-of select="$chopString"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:record" mode="recordid">
    <xsl:param name="baseuri" select="'http://example.org/'"/>
    <xsl:param name="idfield" select="'001'"/>
    <xsl:param name="recordno"/>
    <xsl:variable name="tag" select="substring($idfield,1,3)"/>
    <xsl:variable name="subfield">
      <xsl:choose>
        <xsl:when test="substring($idfield,4,1)">
          <xsl:value-of select="substring($idfield,4,1)"/>
        </xsl:when>
        <xsl:otherwise>a</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="recordid">
      <xsl:choose>
        <xsl:when test="$tag &lt; 10">
          <xsl:if test="count(marc:controlfield[@tag=$tag]) = 1">
            <xsl:value-of select="marc:controlfield[@tag=$tag]"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="count(marc:datafield[@tag=$tag]/marc:subfield[@code=$subfield]) = 1">
            <xsl:value-of select="normalize-space(marc:datafield[@tag=$tag]/marc:subfield[@code=$subfield])"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$recordid != ''">
        <xsl:value-of select="$baseuri"/><xsl:value-of select="$recordid"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">
          <xsl:text>WARNING: Unable to determine record ID for record </xsl:text><xsl:value-of select="$recordno"/><xsl:text>. Using generated ID.</xsl:text>
        </xsl:message>
        <xsl:value-of select="$baseuri"/><xsl:value-of select="generate-id(.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template match="*" mode="concat-nodes-space">
    <xsl:value-of select="."/><xsl:text> </xsl:text>
  </xsl:template><xsl:template match="marc:subfield" mode="marcKey">
    <xsl:text>$</xsl:text><xsl:value-of select="@code"/><xsl:value-of select="."/>
  </xsl:template><xsl:template name="u2x">
    <xsl:param name="dateString"/>
    <xsl:choose>
      <xsl:when test="contains($dateString,'u')">
        <xsl:call-template name="u2x">
          <xsl:with-param name="dateString" select="concat(substring-before($dateString,'u'),'X',substring-after($dateString,'u'))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($dateString,'U')">
        <xsl:call-template name="u2x">
          <xsl:with-param name="dateString" select="concat(substring-before($dateString,'U'),'X',substring-after($dateString,'U'))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$dateString"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template name="edtfFormat">
    <xsl:param name="pDateString"/>
    <!-- convert '-' to 'X' -->
    <xsl:choose>
      <xsl:when test="contains(substring($pDateString,1,12),'-')">
        <xsl:call-template name="edtfFormat">
          <xsl:with-param name="pDateString" select="concat(substring-before($pDateString,'-'),'X',substring-after($pDateString,'-'))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="vDatePart">
          <xsl:choose>
            <xsl:when test="substring($pDateString,7,2) != ''">
              <xsl:value-of select="concat(substring($pDateString,1,4),'-',substring($pDateString,5,2),'-',substring($pDateString,7,2))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(substring($pDateString,1,4),'-',substring($pDateString,5,2))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vTimePart">
          <xsl:if test="substring($pDateString,9,4) != ''">
            <xsl:value-of select="concat('T',substring($pDateString,9,2),':',substring($pDateString,11,2),':00')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="vTimeDiff">
          <xsl:if test="substring($pDateString,13,5) != ''">
            <xsl:value-of select="concat(substring($pDateString,13,3),':',substring($pDateString,16,2))"/>
          </xsl:if>
        </xsl:variable>
        <xsl:value-of select="concat($vDatePart,$vTimePart,$vTimeDiff)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:subfield" mode="generateProperty">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pProp"/>
    <xsl:param name="pResource"/>
    <xsl:param name="pProcess"/>
    <xsl:param name="pPunctuation">
      <xsl:text>.:,;/ </xsl:text>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:element name="{$pProp}">
          <xsl:element name="{$pResource}">
            <rdfs:label>
              <xsl:choose>
                <xsl:when test="$pProcess='chopPunctuation'">
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString"><xsl:value-of select="."/></xsl:with-param>
                    <xsl:with-param name="punctuation" select="$pPunctuation"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="$pProcess='chopParens'">
                  <xsl:call-template name="chopParens">
                    <xsl:with-param name="chopString"><xsl:value-of select="."/></xsl:with-param>
                    <xsl:with-param name="punctuation" select="$pPunctuation"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="$pProcess='chopBrackets'">
                  <xsl:call-template name="chopBrackets">
                    <xsl:with-param name="chopString"><xsl:value-of select="."/></xsl:with-param>
                    <xsl:with-param name="punctuation" select="$pPunctuation"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
              </xsl:choose>
            </rdfs:label>
            <xsl:apply-templates select="../marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </xsl:element>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:subfield" mode="subfield0orw">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="source" select="substring(substring-after(text(),'('),1,string-length(substring-before(text(),')'))-1)"/>
    <xsl:variable name="value">
      <xsl:choose>
        <xsl:when test="$source != ''"><xsl:value-of select="substring-after(text(),')')"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:identifiedBy>
          <bf:Identifier>
            <rdf:value><xsl:value-of select="$value"/></rdf:value>
            <xsl:if test="$source != ''">
              <bf:source>
                <bf:Source>
                  <rdfs:label><xsl:value-of select="$source"/></rdfs:label>
                </bf:Source>
              </bf:source>
            </xsl:if>
          </bf:Identifier>
        </bf:identifiedBy>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:subfield" mode="subfield2">
    <xsl:param name="serialization" select="'rdfxsml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="parent::*" mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:source>
          <bf:Source>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="."/>
            </rdfs:label>
          </bf:Source>
        </bf:source>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:subfield" mode="subfield3">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="parent::*" mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bflc:appliesTo>
          <bflc:AppliesTo>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </rdfs:label>
          </bflc:AppliesTo>
        </bflc:appliesTo>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:subfield" mode="subfield5">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bflc:applicableInstitution>
          <bf:Agent>
            <bf:code><xsl:value-of select="."/></bf:code>
          </bf:Agent>
        </bflc:applicableInstitution>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:subfield" mode="subfield7">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="substring(.,1,1) = 'a'">Text</xsl:when>
        <xsl:when test="substring(.,1,1) = 'c'">NotatedMusic</xsl:when>
        <xsl:when test="substring(.,1,1) = 'd'">NotatedMusic</xsl:when>
        <xsl:when test="substring(.,1,1) = 'e'">Cartography</xsl:when>
        <xsl:when test="substring(.,1,1) = 'f'">Cartography</xsl:when>
        <xsl:when test="substring(.,1,1) = 'g'">MovingImage</xsl:when>
        <xsl:when test="substring(.,1,1) = 'i'">Audio</xsl:when>
        <xsl:when test="substring(.,1,1) = 'j'">Audio</xsl:when>
        <xsl:when test="substring(.,1,1) = 'k'">StillImage</xsl:when>
        <xsl:when test="substring(.,1,1) = 'o'">MixedMaterial</xsl:when>
        <xsl:when test="substring(.,1,1) = 'p'">MixedMaterial</xsl:when>
        <xsl:when test="substring(.,1,1) = 'r'">Object</xsl:when>
        <xsl:when test="substring(.,1,1) = 't'">Text</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="issuance">
      <xsl:choose>
        <xsl:when test="substring(.,2,1) = 'a'">m</xsl:when>
        <xsl:when test="substring(.,2,1) = 'b'">s</xsl:when>
        <xsl:when test="substring(.,2,1) = 'd'">d</xsl:when>
        <xsl:when test="substring(.,2,1) = 'i'">i</xsl:when>
        <xsl:when test="substring(.,2,1) = 'm'">m</xsl:when>
        <xsl:when test="substring(.,2,1) = 's'">s</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <xsl:if test="$type != ''">
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/><xsl:value-of select="$type"/></xsl:attribute>
          </rdf:type>
        </xsl:if>
        <xsl:if test="$issuance != ''">
          <bf:issuance>
            <bf:Issuance>
              <bf:code><xsl:value-of select="$issuance"/></bf:code>
            </bf:Issuance>
          </bf:issuance>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:subfield" mode="subfieldu">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <rdfs:label>
          <xsl:attribute name="rdf:datatype"><xsl:value-of select="concat($xs,'anyURI')"/></xsl:attribute>
          <xsl:value-of select="."/>
        </rdfs:label>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:leader" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:choose>
          <xsl:when test="substring(.,6,1) = 'a'">
            <bf:status>
              <bf:Status>
                <bf:code>c</bf:code>
              </bf:Status>
            </bf:status>
          </xsl:when>
          <xsl:when test="substring(.,6,1) = 'c'">
            <bf:status>
              <bf:Status>
                <bf:code>c</bf:code>
              </bf:Status>
            </bf:status>
          </xsl:when>
          <xsl:when test="substring(.,6,1) = 'n'">
            <bf:status>
              <bf:Status>
                <bf:code>n</bf:code>
              </bf:Status>
            </bf:status>
          </xsl:when>
          <xsl:when test="substring(.,6,1) = 'p'">
            <bf:status>
              <bf:Status>
                <bf:code>p</bf:code>
              </bf:Status>
            </bf:status>
          </xsl:when>
        </xsl:choose>
        <bflc:encodingLevel>
          <bflc:EncodingLevel>
            <bf:code>
              <xsl:choose>
                <xsl:when test="substring(.,18,1) = ' '">f</xsl:when>
                <xsl:when test="substring(.,18,1) = '1'">1</xsl:when>
                <xsl:when test="substring(.,18,1) = '2'">7</xsl:when>
                <xsl:when test="substring(.,18,1) = '3'">3</xsl:when>
                <xsl:when test="substring(.,18,1) = '4'">4</xsl:when>
                <xsl:when test="substring(.,18,1) = '5'">5</xsl:when>
                <xsl:when test="substring(.,18,1) = '7'">7</xsl:when>
                <xsl:when test="substring(.,18,1) = '8'">8</xsl:when>
                <xsl:otherwise>u</xsl:otherwise>
              </xsl:choose>
            </bf:code>
          </bflc:EncodingLevel>
        </bflc:encodingLevel>
        <bf:descriptionConventions>
          <bf:DescriptionConventions>
            <bf:code>
              <xsl:choose>
                <xsl:when test="substring(.,19,1) = 'a'">aacr</xsl:when>
                <xsl:when test="substring(.,19,1) = 'c'">isbd</xsl:when>
                <xsl:when test="substring(.,19,1) = 'i'">isbd</xsl:when>
                <xsl:when test="substring(.,19,1) = 'p'">aacr</xsl:when>
                <xsl:when test="substring(.,19,1) = 'r'">aacr</xsl:when>
                <xsl:otherwise>unknown</xsl:otherwise>
              </xsl:choose>
            </bf:code>
          </bf:DescriptionConventions>
        </bf:descriptionConventions>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:leader" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:variable name="workType">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">Text</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">NotatedMusic</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">NotatedMusic</xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'">Cartography</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">Cartography</xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'">MovingImage</xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'">Audio</xsl:when>
            <xsl:when test="substring(.,7,1) = 'j'">Audio</xsl:when>
            <xsl:when test="substring(.,7,1) = 'k'">StillImage</xsl:when>
            <xsl:when test="substring(.,7,1) = 'o'">MixedMaterial</xsl:when>
            <xsl:when test="substring(.,7,1) = 'p'">MixedMaterial</xsl:when>
            <xsl:when test="substring(.,7,1) = 'r'">Object</xsl:when>
            <xsl:when test="substring(.,7,1) = 't'">Text</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$workType != ''">
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
          </rdf:type>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:leader" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="issuanceUri">
      <xsl:choose>
        <xsl:when test="substring(.,8,1) = 'a'"><xsl:value-of select="concat($issuance,'mono')"/></xsl:when>
        <xsl:when test="substring(.,8,1) = 'b'"><xsl:value-of select="concat($issuance,'serl')"/></xsl:when>
        <xsl:when test="substring(.,8,1) = 'i'"><xsl:value-of select="concat($issuance,'intg')"/></xsl:when>
        <xsl:when test="substring(.,8,1) = 'm'"><xsl:value-of select="concat($issuance,'mono')"/></xsl:when>
        <xsl:when test="substring(.,8,1) = 's'"><xsl:value-of select="concat($issuance,'serl')"/></xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:variable name="instanceType">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'd'">Manuscript</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">Manuscript</xsl:when>
            <xsl:when test="substring(.,7,1) = 'm'">Electronic</xsl:when>
            <xsl:when test="substring(.,7,1) = 't'">Manuscript</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$instanceType != ''">
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$instanceType)"/></xsl:attribute>
          </rdf:type>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="substring(.,8,1) = 'c' or substring(.,8,1) = 'd'">
            <rdf:type>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Collection')"/></xsl:attribute>
            </rdf:type>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="$issuanceUri != ''">
          <bf:issuance>
            <bf:Issuance>
              <xsl:attribute name="rdf:about"><xsl:value-of select="$issuanceUri"/></xsl:attribute>
            </bf:Issuance>
          </bf:issuance>
        </xsl:if>
        <xsl:if test="substring(.,9,1) = 'a'">
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>Archival</xsl:attribute>
          </rdf:type>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:controlfield[@tag='001']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization= 'rdfxml'">
        <bf:identifiedBy>
          <bf:Local>
            <rdf:value><xsl:value-of select="."/></rdf:value>
          </bf:Local>
        </bf:identifiedBy>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:controlfield[@tag='003']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization= 'rdfxml'">
        <bf:source>
          <bf:Source>
            <bf:code><xsl:value-of select="."/></bf:code>
          </bf:Source>
        </bf:source>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:controlfield[@tag='005']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="changeDate" select="concat(substring(.,1,4),'-',substring(.,5,2),'-',substring(.,7,2),'T',substring(.,9,2),':',substring(.,11,2),':',substring(.,13,2))"/>
    <xsl:choose>
      <xsl:when test="$serialization= 'rdfxml'">
        <bf:changeDate>
          <xsl:attribute name="rdf:datatype"><xsl:value-of select="$xs"/>dateTime</xsl:attribute>
          <xsl:value-of select="$changeDate"/>
        </bf:changeDate>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:controlfield[@tag='007']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="workType">
      <xsl:choose>
        <xsl:when test="substring(.,1,1) = 'a'">Cartography</xsl:when>
        <xsl:when test="substring(.,1,1) = 'd'">Cartography</xsl:when>
        <xsl:when test="substring(.,1,1) = 'g'">StillImage</xsl:when>
        <xsl:when test="substring(.,1,1) = 'k'">StillImage</xsl:when>
        <xsl:when test="substring(.,1,1) = 'm'">MovingImage</xsl:when>
        <xsl:when test="substring(.,1,1) = 's'">Audio</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- map -->
      <xsl:when test="substring(.,1,1) = 'a'">
        <xsl:variable name="genreForm">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'd'">atlas</xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'">diagram</xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'">map</xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'">profile</xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'">model</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">remote-sensing image</xsl:when>
            <xsl:when test="substring(.,2,1) = 's'">map section</xsl:when>
            <xsl:when test="substring(.,2,1) = 'y'">map view</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genreUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($marcgt,'atl')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'"><xsl:value-of select="concat($marcgt,'map')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'"><xsl:value-of select="concat($marcgt,'mod')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($marcgt,'rem')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">paper</xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'">wood</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">stone</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">metal</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">skin</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">textile</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">plastic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">glass</xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'">vinyl</xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'">vellum</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">plaster</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">leather</xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'">parchment</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'"><xsl:value-of select="concat($mmaterial,'wod')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'"><xsl:value-of select="concat($mmaterial,'sto')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'"><xsl:value-of select="concat($mmaterial,'ski')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'"><xsl:value-of select="concat($mmaterial,'tex')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'"><xsl:value-of select="concat($mmaterial,'vny')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'"><xsl:value-of select="concat($mmaterial,'vel')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'"><xsl:value-of select="concat($mmaterial,'plt')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'"><xsl:value-of select="concat($mmaterial,'lea')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'"><xsl:value-of select="concat($mmaterial,'par')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'e' and substring(../marc:leader,7,1) != 'f'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <xsl:if test="$genreForm != ''">
              <bf:genreForm>
                <bf:GenreForm>
                  <xsl:if test="$genreUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$genreUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$genreForm"/></rdfs:label>
                </bf:GenreForm>
                </bf:genreForm>
            </xsl:if>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- electronic resource -->
      <xsl:when test="substring(.,1,1) = 'c'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'g'">gray scale</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'g'"><xsl:value-of select="concat($mcolor,'gry')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- globe -->
      <xsl:when test="substring(.,1,1) = 'd'">
        <xsl:variable name="genreForm">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'">celestial globe</xsl:when>
            <xsl:when test="substring(.,2,1) = 'b'">planetary or lunar globe</xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'">terrestrial globe</xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'">earth moon globe</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'e' and substring(../marc:leader,7,1) != 'f'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <bf:genreForm>
              <bf:GenreForm>
                <xsl:attribute name="rdf:about"><xsl:value-of select="concat($marcgt,'glo')"/></xsl:attribute>
                <rdfs:label>globe</rdfs:label>
              </bf:GenreForm>
            </bf:genreForm>
            <xsl:if test="$genreForm != ''">
              <bf:genreForm>
                <bf:GenreForm>
                  <rdfs:label><xsl:value-of select="$genreForm"/></rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:if>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- projected graphic -->
      <xsl:when test="substring(.,1,1) = 'g'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'">hand colored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'g'"><xsl:value-of select="concat($mcolor,'hnd')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'k'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- microform -->
      <xsl:when test="substring(.,1,1) = 'h'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,10,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,10,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- nonprojected graphic -->
      <xsl:when test="substring(.,1,1) = 'k'">
        <xsl:variable name="genreForm">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'">activity card</xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'">collage</xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'">drawing</xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'">painting</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">photomechanical print</xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'">photonegative</xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'">photoprint</xsl:when>
            <xsl:when test="substring(.,2,1) = 'i'">picture</xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'">print</xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'">poster</xsl:when>
            <xsl:when test="substring(.,2,1) = 'l'">technical drawing</xsl:when>
            <xsl:when test="substring(.,2,1) = 'n'">chart</xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'">flash card</xsl:when>
            <xsl:when test="substring(.,2,1) = 'p'">postcard</xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'">icon</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">radiograph</xsl:when>
            <xsl:when test="substring(.,2,1) = 's'">study print</xsl:when>
            <xsl:when test="substring(.,2,1) =                             'v'">photograph</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genreFormUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($graphicMaterials,'tgm002269')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($graphicMaterials,'tgm003277')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'"><xsl:value-of select="concat($graphicMaterials,'tgm007391')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($graphicMaterials,'tgm007730')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'"><xsl:value-of select="concat($graphicMaterials,'tgm007028')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'"><xsl:value-of select="concat($graphicMaterials,'tgm007718')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'i'"><xsl:value-of select="concat($graphicMaterials,'tgm007779')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'"><xsl:value-of select="concat($graphicMaterials,'tgm008237')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'"><xsl:value-of select="concat($graphicMaterials,'tgm008104')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'l'"><xsl:value-of select="concat($marcgt,'ted')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'n'"><xsl:value-of select="concat($graphicMaterials,'tgm001907')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'"><xsl:value-of select="concat($marcgt,'fla')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'p'"><xsl:value-of select="concat($graphicMaterials,'tgm008103')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'"><xsl:value-of select="concat($graphicMaterials,'tgm005289')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($graphicMaterials,'tgm008530')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'v'"><xsl:value-of select="concat($graphicMaterials,'tgm007721')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'">hand colored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'"><xsl:value-of select="concat($mcolor,'hnd')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'k'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <xsl:if test="$genreForm != ''">
              <bf:genreForm>
                <bf:GenreForm>
                  <xsl:if test="$genreFormUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$genreFormUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$genreForm"/></rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:if>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- motion picture -->
      <xsl:when test="substring(.,1,1) = 'm'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'">hand colored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'"><xsl:value-of select="concat($mcolor,'hnd')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genreForm2">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'a'">workprint</xsl:when>
            <xsl:when test="substring(.,10,1) = 'b'">trims</xsl:when>
            <xsl:when test="substring(.,10,1) = 'c'">outtakes</xsl:when>
            <xsl:when test="substring(.,10,1) = 'd'">rushes</xsl:when>
            <xsl:when test="substring(.,10,1) = 'e'">mixing tracks</xsl:when>
            <xsl:when test="substring(.,10,1) = 'f'">title bands, intertitle rolls</xsl:when>
            <xsl:when test="substring(.,10,1) = 'g'">production rolls</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genreForm2Uri">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'c'"><xsl:value-of select="concat($genreForms,'gf2011026435')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 'd'"><xsl:value-of select="concat($genreForms,'gf2011026551')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'g'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <bf:genreForm>
              <bf:GenreForm>
                <xsl:attribute name="rdf:about">http://id.loc.gov/authorities/genreForms/mot</xsl:attribute>
              </bf:GenreForm>
            </bf:genreForm>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
            <xsl:if test="$genreForm2 != ''">
              <bf:genreForm>
                <bf:GenreForm>
                  <xsl:if test="$genreForm2Uri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$genreForm2Uri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$genreForm2"/></rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- sound recording -->
      <xsl:when test="substring(.,1,1) = 's'">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'i' and substring(../marc:leader,7,1) != 'j'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- videorecording -->
      <xsl:when test="substring(.,1,1) = 'v'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <bf:genreForm>
              <bf:GenreForm>
                <xsl:attribute name="rdf:about">http://id.loc.gov/authorities/genreForms/gf2011026723</xsl:attribute>
              </bf:GenreForm>
            </bf:genreForm>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:controlfield[@tag='007']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <!-- map -->
      <xsl:when test="substring(.,1,1) = 'a'">
        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'f'">facsimile</xsl:when>
            <xsl:when test="substring(.,6,1) = 'z'">other type of reproduction</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generation2">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">photocopy, blueline print</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">photocopy</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">pre-production</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">film</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarity">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'">positive</xsl:when>
            <xsl:when test="substring(.,8,1) = 'b'">negative</xsl:when>
            <xsl:when test="substring(.,8,1) = 'm'">mixed polarity</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarityUri">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'"><xsl:value-of select="concat($mpolarity,'pos')"/></xsl:when>
            <xsl:when test="substring(.,8,1) = 'b'"><xsl:value-of select="concat($mpolarity,'neg')"/></xsl:when>
            <xsl:when test="substring(.,8,1) = 'm'"><xsl:value-of select="concat($mpolarity,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
            <xsl:if test="$generation2 != ''">
              <bf:generation>
                <bf:Generation>
                  <rdfs:label><xsl:value-of select="$generation2"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
            <xsl:if test="$polarity != ''">
              <bf:polarity>
                <bf:Polarity>
                  <xsl:if test="$polarityUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$polarityUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$polarity"/></rdfs:label>
                </bf:Polarity>
              </bf:polarity>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- electronic resource -->
      <xsl:when test="substring(.,1,1) = 'c'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'">computer tape cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'b'">computer chip cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'">computer disc cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'">computer disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'">computer disc cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">computer tape cassette</xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'">computer tape reel</xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'">computer disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'">computer card</xsl:when>
            <xsl:when test="substring(.,2,1) = 'm'">computer disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'">computer disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">online resource</xsl:when>
            <xsl:when test="substring(.,2,1) = 'z'">other electronic carrier</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'"><xsl:value-of select="concat($carriers,'ca')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'b'"><xsl:value-of select="concat($carriers,'cb')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'ce')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'cd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'"><xsl:value-of select="concat($carriers,'ce')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'cf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'"><xsl:value-of select="concat($carriers,'ch')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'"><xsl:value-of select="concat($carriers,'ce')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'"><xsl:value-of select="concat($carriers,'ck')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'm'"><xsl:value-of select="concat($carriers,'cd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'"><xsl:value-of select="concat($carriers,'cd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($carriers,'cr')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'z'"><xsl:value-of select="concat($carriers,'cz')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">3 1/2 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">12 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">4 3/4 in. or 12 cm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">1 1/8 x 2 3/8 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">3 7/8 x 2 1/2 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">5 1/4 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'u'">unknown</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">8 in.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContent">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '">silent</xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'">sound on medium</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="imageBitDepth">
          <xsl:choose>
            <xsl:when test="substring(.,7,3) = 'mmm'">multiple</xsl:when>
            <xsl:when test="substring(.,7,3) = 'nnn'"/>
            <xsl:when test="substring(.,7,3) = '---'"/>
            <xsl:when test="substring(.,7,3) = '|||'"/>
            <xsl:otherwise><xsl:value-of select="substring(.,7,3)"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="encodingFormat">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'a'">one file format</xsl:when>
            <xsl:when test="substring(.,10,1) = 'm'">multiple file formats</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'm'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Electronic')"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/c</xsl:attribute>
                  <rdfs:label>computer</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$dimensions != ''">
              <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
            </xsl:if>
            <xsl:if test="$soundContent != ''">
              <bf:soundContent>
                <bf:SoundContent>
                  <rdfs:label><xsl:value-of select="$soundContent"/></rdfs:label>
                </bf:SoundContent>
              </bf:soundContent>
            </xsl:if>
            <xsl:if test="$imageBitDepth != ''">
              <bf:digitalCharacteristic>
                <bf:DigitalCharacteristic>
                  <rdf:type>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bflc,'ImageBitDepth')"/></xsl:attribute>
                  </rdf:type>
                  <rdfs:label><xsl:value-of select="$imageBitDepth"/></rdfs:label>
                </bf:DigitalCharacteristic>
              </bf:digitalCharacteristic>
            </xsl:if>
            <xsl:if test="$encodingFormat != ''">
              <bf:digitalCharacteristic>
                <bf:DigitalCharacteristic>
                  <rdf:type>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'EncodingFormat')"/></xsl:attribute>
                  </rdf:type>
                  <rdfs:label><xsl:value-of select="$encodingFormat"/></rdfs:label>
                </bf:DigitalCharacteristic>
              </bf:digitalCharacteristic>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- globe -->
      <xsl:when test="substring(.,1,1) = 'd'">
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">paper</xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'">wood</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">stone</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">metal</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">skin</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">textile</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">plastic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">glass</xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'">vinyl</xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'">vellum</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">plaster</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">leather</xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'">parchment</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'"><xsl:value-of select="concat($mmaterial,'wod')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'"><xsl:value-of select="concat($mmaterial,'sto')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'"><xsl:value-of select="concat($mmaterial,'ski')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'"><xsl:value-of select="concat($mmaterial,'tex')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'"><xsl:value-of select="concat($mmaterial,'vny')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'"><xsl:value-of select="concat($mmaterial,'vel')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'"><xsl:value-of select="concat($mmaterial,'plt')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'"><xsl:value-of select="concat($mmaterial,'lea')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'"><xsl:value-of select="concat($mmaterial,'par')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'f'">facsimile</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- projected graphic -->
      <xsl:when test="substring(.,1,1) = 'g'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'">filmstrip cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'">filmslip</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">filmstrip</xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'">film roll</xsl:when>
            <xsl:when test="substring(.,2,1) = 's'">slide</xsl:when>
            <xsl:when test="substring(.,2,1) = 't'">overhead transparency</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'gc')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'gd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'gf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'"><xsl:value-of select="concat($carriers,'mo')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 's'"><xsl:value-of select="concat($carriers,'gs')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 't'"><xsl:value-of select="concat($carriers,'gt')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'd'">glass</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">safety film</xsl:when>
            <xsl:when test="substring(.,5,1) = 'k'">film base (not safety)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'">mixed collection</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">paper</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'k'"><xsl:value-of select="concat($mmaterial,'nsf')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContent">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '">silent</xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'">sound on medium</xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'">sound separate from medium</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMedium">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">optical sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">magnetic audio tape in cartridge</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">sound disc</xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'">magnetic audio tape on reel</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">magnetic audio tape in cassette</xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'">optical and magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'h'">videotape</xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'">videodisc</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'">standard 8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'b'">super 8 mm., single 8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'c'">9.5 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'd'">16 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'e'">28 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'f'">35 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'g'">70 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'j'">2x2 in. or 5x5 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'k'">2 1/4 in. x 2 1/4 in. or 6x6 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 's'">4x5 in. or 10x13 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 't'">15x7 in. or 13x18 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'v'">18x10 in. or 21x26 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'w'">9x9 in. or 23x23 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'x'">10x10 in. or 26x26 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'y'">17x7 in. or 18x18 cm.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mount">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'c'">cardboard</xsl:when>
            <xsl:when test="substring(.,9,1) = 'd'">glass</xsl:when>
            <xsl:when test="substring(.,9,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,9,1) = 'h'">metal</xsl:when>
            <xsl:when test="substring(.,9,1) = 'j'">metal</xsl:when>
            <xsl:when test="substring(.,9,1) = 'k'">synthetic</xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'">mixed collection</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mount2">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'j'">glass</xsl:when>
            <xsl:when test="substring(.,9,1) = 'k'">glass</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mountUri">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'c'"><xsl:value-of select="concat($mmaterial,'crd')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'd'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'h'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'j'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'k'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mountUri2">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'j'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'k'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/g</xsl:attribute>
                  <rdfs:label>projected</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$soundContent != ''">
              <bf:soundContent>
                <bf:SoundContent>
                  <rdfs:label><xsl:value-of select="$soundContent"/></rdfs:label>
                </bf:SoundContent>
              </bf:soundContent>
            </xsl:if>
            <xsl:if test="$recordingMedium != ''">
              <bf:soundCharacteristic>
                <bf:RecordingMedium>
                  <rdfs:label><xsl:value-of select="$recordingMedium"/></rdfs:label>
                </bf:RecordingMedium>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$dimensions != ''">
              <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
            </xsl:if>
            <xsl:if test="$mount != ''">
              <bf:mount>
                <bf:Mount>
                  <xsl:if test="$mountUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$mountUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$mount"/></rdfs:label>
                </bf:Mount>
              </bf:mount>
            </xsl:if>
            <xsl:if test="$mount2 != ''">
              <bf:mount>
                <bf:Mount>
                  <xsl:if test="$mountUri2 != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$mountUri2"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$mount2"/></rdfs:label>
                </bf:Mount>
              </bf:mount>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- microform -->
      <xsl:when test="substring(.,1,1) = 'h'">
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'"><xsl:value-of select="concat($carriers,'ha')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'b'"><xsl:value-of select="concat($carriers,'hb')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'hc')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'hd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'"><xsl:value-of select="concat($carriers,'he')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'hf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'"><xsl:value-of select="concat($carriers,'hg')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'"><xsl:value-of select="concat($carriers,'hh')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'"><xsl:value-of select="concat($carriers,'hj')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarity">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">positive</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">negative</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed polarity</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarityUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mpolarity,'pos')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mpolarity,'neg')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mpolarity,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">8 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">16 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">35 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">70 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'h'">105 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'">13x5 in. or 8x13 cm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'">4x6 in. or 11x15 cm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">6x9 in. or 16x23 cm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">3 1/4 x 7 3/8 in. or 9x19 cm.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="reductionRatioNote">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'a'">low reduction range</xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'">normal reduction range</xsl:when>
            <xsl:when test="substring(.,6,1) = 'c'">high reduction range</xsl:when>
            <xsl:when test="substring(.,6,1) = 'd'">very high reduction range</xsl:when>
            <xsl:when test="substring(.,6,1) = 'e'">ultra high reduction range</xsl:when>
            <xsl:when test="substring(.,6,1) = 'v'">reduction rate varies</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="reductionRatio">
          <xsl:choose>
            <xsl:when test="substring(.,7,3) = '|||'"/>
            <xsl:when test="substring(.,7,3) = '---'"/>
            <xsl:otherwise><xsl:value-of select="substring(.,7,3)"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="emulsion">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'">silver halide</xsl:when>
            <xsl:when test="substring(.,11,1) = 'b'">diazo</xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'">vesicular</xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'">mixed emulsion</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="emulsionUri">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'"><xsl:value-of select="concat($mmaterial,'slh')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'b'"><xsl:value-of select="concat($mmaterial,'dia')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'"><xsl:value-of select="concat($mmaterial,'ves')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,12,1) = 'a'">first generation (master)</xsl:when>
            <xsl:when test="substring(.,12,1) = 'b'">printing master</xsl:when>
            <xsl:when test="substring(.,12,1) = 'c'">service copy</xsl:when>
            <xsl:when test="substring(.,12,1) = 'm'">mixed generation</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'">safety base</xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'">acetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'">diacetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'p'">polyester</xsl:when>
            <xsl:when test="substring(.,13,1) = 'r'">safety base, mixed</xsl:when>
            <xsl:when test="substring(.,13,1) = 't'">triacetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'i'">nitrate base</xsl:when>
            <xsl:when test="substring(.,13,1) = 'm'">mixed nitrate and safety base</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'"><xsl:value-of select="concat($mmaterial,'ace')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'"><xsl:value-of select="concat($mmaterial,'dia')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'p'"><xsl:value-of select="concat($mmaterial,'pol')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'r'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 't'"><xsl:value-of select="concat($mmaterial,'tri')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'i'"><xsl:value-of select="concat($mmaterial,'nit')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/h</xsl:attribute>
                  <rdfs:label>microform</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrierUri != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$polarity != ''">
              <bf:polarity>
                <bf:Polarity>
                  <xsl:if test="$polarityUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$polarityUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$polarity"/></rdfs:label>
                </bf:Polarity>
              </bf:polarity>
            </xsl:if>
            <xsl:if test="$dimensions != ''">
              <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
            </xsl:if>
            <xsl:if test="$reductionRatioNote != ''">
              <bf:reductionRatio>
                <bf:ReductionRatio>
                  <bf:note>
                    <bf:Note>
                      <rdfs:label><xsl:value-of select="$reductionRatioNote"/></rdfs:label>
                    </bf:Note>
                  </bf:note>
                  <xsl:if test="$reductionRatio != ''">
                    <rdfs:label><xsl:value-of select="$reductionRatio"/></rdfs:label>
                  </xsl:if>
                </bf:ReductionRatio>
              </bf:reductionRatio>
            </xsl:if>
            <xsl:if test="$emulsion != ''">
              <bf:emulsion>
                <bf:Emulsion>
                  <xsl:if test="$emulsionUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$emulsionUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$emulsion"/></rdfs:label>
                </bf:Emulsion>
              </bf:emulsion>
            </xsl:if>
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- nonprojected graphic -->
      <xsl:when test="substring(.,1,1) = 'k'">
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">canvas</xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'">bristol board</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">cardboard</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">glass</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">skin</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">textile</xsl:when>
            <xsl:when test="substring(.,5,1) = 'h'">metal</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">plastic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'">vinyl</xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'">mixed collection</xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'">vellum</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">paper</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">plaster</xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'">hardboard</xsl:when>
            <xsl:when test="substring(.,5,1) = 'r'">porcelain</xsl:when>
            <xsl:when test="substring(.,5,1) = 's'">stone</xsl:when>
            <xsl:when test="substring(.,5,1) = 't'">wood</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">leather</xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'">parchment</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'"><xsl:value-of select="concat($mmaterial,'can')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'"><xsl:value-of select="concat($mmaterial,'brb')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'"><xsl:value-of select="concat($mmaterial,'crd')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaterial,'gla')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'"><xsl:value-of select="concat($mmaterial,'ski')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'"><xsl:value-of select="concat($mmaterial,'tex')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'h'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'"><xsl:value-of select="concat($mmaterial,'vny')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'"><xsl:value-of select="concat($mmaterial,'vel')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'"><xsl:value-of select="concat($mmaterial,'plt')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'"><xsl:value-of select="concat($mmaterial,'hdb')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'r'"><xsl:value-of select="concat($mmaterial,'por')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 's'"><xsl:value-of select="concat($mmaterial,'sto')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 't'"><xsl:value-of select="concat($mmaterial,'wod')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'"><xsl:value-of select="concat($mmaterial,'lea')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'"><xsl:value-of select="concat($mmaterial,'par')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mount">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'a'">canvas</xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'">bristol board</xsl:when>
            <xsl:when test="substring(.,6,1) = 'c'">cardboard</xsl:when>
            <xsl:when test="substring(.,6,1) = 'd'">glass</xsl:when>
            <xsl:when test="substring(.,6,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,6,1) = 'f'">skin</xsl:when>
            <xsl:when test="substring(.,6,1) = 'g'">textile</xsl:when>
            <xsl:when test="substring(.,6,1) = 'h'">metal</xsl:when>
            <xsl:when test="substring(.,6,1) = 'i'">plastic</xsl:when>
            <xsl:when test="substring(.,6,1) = 'l'">vinyl</xsl:when>
            <xsl:when test="substring(.,6,1) = 'm'">mixed collection</xsl:when>
            <xsl:when test="substring(.,6,1) = 'n'">vellum</xsl:when>
            <xsl:when test="substring(.,6,1) = 'o'">paper</xsl:when>
            <xsl:when test="substring(.,6,1) = 'p'">plaster</xsl:when>
            <xsl:when test="substring(.,6,1) = 'q'">hardboard</xsl:when>
            <xsl:when test="substring(.,6,1) = 'r'">porcelain</xsl:when>
            <xsl:when test="substring(.,6,1) = 's'">stone</xsl:when>
            <xsl:when test="substring(.,6,1) = 't'">wood</xsl:when>
            <xsl:when test="substring(.,6,1) = 'v'">leather</xsl:when>
            <xsl:when test="substring(.,6,1) = 'w'">parchment</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mountUri">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'a'"><xsl:value-of select="concat($mmaterial,'can')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'"><xsl:value-of select="concat($mmaterial,'brb')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'c'"><xsl:value-of select="concat($mmaterial,'crd')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'd'"><xsl:value-of select="concat($mmaterial,'gla')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'f'"><xsl:value-of select="concat($mmaterial,'ski')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'g'"><xsl:value-of select="concat($mmaterial,'tex')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'h'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'i'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'l'"><xsl:value-of select="concat($mmaterial,'vny')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'n'"><xsl:value-of select="concat($mmaterial,'vel')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'o'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'p'"><xsl:value-of select="concat($mmaterial,'plt')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'q'"><xsl:value-of select="concat($mmaterial,'hdb')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'r'"><xsl:value-of select="concat($mmaterial,'por')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 's'"><xsl:value-of select="concat($mmaterial,'sto')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 't'"><xsl:value-of select="concat($mmaterial,'wod')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'v'"><xsl:value-of select="concat($mmaterial,'lea')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'w'"><xsl:value-of select="concat($mmaterial,'par')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$mount != ''">
              <bf:mount>
                <bf:Mount>
                  <xsl:if test="$mountUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$mountUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$mount"/></rdfs:label>
                </bf:Mount>
              </bf:mount>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- motion picture -->
      <xsl:when test="substring(.,1,1) = 'm'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'">film cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">film cassette</xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'">film roll</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">film reel</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'mc')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'mf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'"><xsl:value-of select="concat($carriers,'mo')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($carriers,'mr')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="projectionCharacteristic">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">standard sound aperture (reduced frame)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'">nonanamorphic (wide-screen)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">3D</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">anamorphic (wide-screen)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">other wide-screen</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">standard silent aperture (full frame)</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContent">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '">silent</xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'">sound on medium</xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'">sound separate from medium</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMedium">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">optical sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">magnetic audio tape in cartridge</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">sound disc</xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'">magnetic audio tape on reel</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">magnetic audio tape in cassette</xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'">optical and magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'h'">videotape</xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'">videodisc</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'">8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'b'">super 8 mm., single 8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'c'">9.5 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'd'">16 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'e'">28 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'f'">35 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'g'">70 mm.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackChannels">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'k'">mixed</xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'">monaural</xsl:when>
            <xsl:when test="substring(.,9,1) = 'q'">quadraphonic, multichannel or surround</xsl:when>
            <xsl:when test="substring(.,9,1) = 's'">stereophonic</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackUri">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'k'"><xsl:value-of select="concat($mplayback,'mix')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'"><xsl:value-of select="concat($mplayback,'mon')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'q'"><xsl:value-of select="concat($mplayback,'mul')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 's'"><xsl:value-of select="concat($mplayback,'ste')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarity">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'">positive</xsl:when>
            <xsl:when test="substring(.,11,1) = 'b'">negative</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarityUri">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'"><xsl:value-of select="concat($mpolarity,'pos')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'b'"><xsl:value-of select="concat($mpolarity,'neg')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,12,1) = 'd'">duplicate</xsl:when>
            <xsl:when test="substring(.,12,1) = 'e'">master</xsl:when>
            <xsl:when test="substring(.,12,1) = 'o'">original</xsl:when>
            <xsl:when test="substring(.,12,1) = 'r'">reference print, viewing copy</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'">safety base</xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'">acetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'">diacetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'p'">polyester</xsl:when>
            <xsl:when test="substring(.,13,1) = 'r'">safety base</xsl:when>
            <xsl:when test="substring(.,13,1) = 't'">triacetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'i'">nitrate base</xsl:when>
            <xsl:when test="substring(.,13,1) = 'm'">mixed nitrate and safety base</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'"><xsl:value-of select="concat($mmaterial,'ace')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'"><xsl:value-of select="concat($mmaterial,'dia')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'p'"><xsl:value-of select="concat($mmaterial,'pol')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'r'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 't'"><xsl:value-of select="concat($mmaterial,'tri')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'i'"><xsl:value-of select="concat($mmaterial,'nit')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="completeness">
          <xsl:choose>
            <xsl:when test="substring(.,17,1) = 'c'">complete</xsl:when>
            <xsl:when test="substring(.,17,1) = 'i'">incomplete</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="inspectionDate">
          <xsl:choose>
            <xsl:when test="substring(.,18,6) = '||||||'"/>
            <xsl:when test="substring(.,18,6) = '------'"/>
            <xsl:otherwise><xsl:value-of select="concat(substring(.,18,4),'-',substring(.,22,2))"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/g</xsl:attribute>
                  <rdfs:label>projected</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$projectionCharacteristic != ''">
              <bf:projectionCharacteristic>
                <bf:ProjectionCharacteristic>
                  <rdfs:label><xsl:value-of select="$projectionCharacteristic"/></rdfs:label>
                </bf:ProjectionCharacteristic>
              </bf:projectionCharacteristic>
            </xsl:if>
            <xsl:if test="$soundContent != ''">
              <bf:soundContent>
                <bf:SoundContent>
                  <rdfs:label><xsl:value-of select="$soundContent"/></rdfs:label>
                </bf:SoundContent>
              </bf:soundContent>
            </xsl:if>
            <xsl:if test="$recordingMedium != ''">
              <bf:soundCharacteristic>
                <bf:RecordingMedium>
                  <rdfs:label><xsl:value-of select="$recordingMedium"/></rdfs:label>
                </bf:RecordingMedium>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$dimensions != ''">
              <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
            </xsl:if>
            <xsl:if test="$playbackChannels != ''">
              <bf:soundCharacteristic>
                <bf:PlaybackChannels>
                  <xsl:if test="$playbackUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$playbackUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$playbackChannels"/></rdfs:label>
                </bf:PlaybackChannels>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$polarity != ''">
              <bf:polarity>
                <bf:Polarity>
                  <xsl:if test="$polarityUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$polarityUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$polarity"/></rdfs:label>
                </bf:Polarity>
              </bf:polarity>
            </xsl:if>
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$completeness != ''">
              <bf:note>
                <bf:Note>
                  <bf:noteType>completeness</bf:noteType>
                  <rdfs:label><xsl:value-of select="$completeness"/></rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:if>
            <xsl:if test="$inspectionDate != ''">
              <bf:note>
                <bf:Note>
                  <bf:noteType>film inspection date</bf:noteType>
                  <rdfs:label>
                    <xsl:attribute name="rdf:datatype"><xsl:value-of select="$xs"/>gYearMonth</xsl:attribute>
                    <xsl:value-of select="$inspectionDate"/>
                  </rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- sound recording -->
      <xsl:when test="substring(.,1,1) = 's'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'd'">sound disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'">cylinder</xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'">sound cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'i'">sound-track film</xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'">roll</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">remote</xsl:when>
            <xsl:when test="substring(.,2,1) = 's'">sound cassette</xsl:when>
            <xsl:when test="substring(.,2,1) = 't'">sound-tape reel</xsl:when>
            <xsl:when test="substring(.,2,1) = 'w'">wire recording</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'sd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'"><xsl:value-of select="concat($carriers,'se')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'"><xsl:value-of select="concat($carriers,'sg')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'i'"><xsl:value-of select="concat($carriers,'si')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'"><xsl:value-of select="concat($carriers,'sq')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($carriers,'cr')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 's'"><xsl:value-of select="concat($carriers,'sg')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 't'"><xsl:value-of select="concat($carriers,'st')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'w'"><xsl:value-of select="concat($carriers,'sw')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playingSpeed">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">16 rpm</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">13 1/3 rpm</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">45 rpm</xsl:when>
            <xsl:when test="substring(.,4,1) = 'd'">78 rpm</xsl:when>
            <xsl:when test="substring(.,4,1) = 'e'">8 rpm</xsl:when>
            <xsl:when test="substring(.,4,1) = 'f'">1.4 m. per sec.</xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'">120 rpm</xsl:when>
            <xsl:when test="substring(.,4,1) = 'i'">160 rpm</xsl:when>
            <xsl:when test="substring(.,4,1) = 'k'">15/16 ips</xsl:when>
            <xsl:when test="substring(.,4,1) = 'l'">1 7/8 ips</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">3 3/4 ips</xsl:when>
            <xsl:when test="substring(.,4,1) = 'o'">7 1/2 ips</xsl:when>
            <xsl:when test="substring(.,4,1) = 'p'">15 ips</xsl:when>
            <xsl:when test="substring(.,4,1) = 'r'">30 ips</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackChannels">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'm'">monaural</xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'">quadraphonic, multichannel or surround</xsl:when>
            <xsl:when test="substring(.,5,1) = 's'">stereophonic</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'm'"><xsl:value-of select="concat($mplayback,'mon')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'"><xsl:value-of select="concat($mplayback,'mul')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 's'"><xsl:value-of select="concat($mplayback,'ste')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="grooveCharacteristic">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'm'">microgroove/fine</xsl:when>
            <xsl:when test="substring(.,6,1) = 's'">coarse/standard</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">3 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">5 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">7 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">10 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'">12 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">16 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'">4 3/4 in. or 12 cm.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'j'">3 7/8 x 2 1/2 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'o'">5 1/4 x 3 7/8 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 's'">2 3/4 x 4 in.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tapeWidth">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'l'">1/8 in. tape width</xsl:when>
            <xsl:when test="substring(.,8,1) = 'm'">1/4 in. tape width</xsl:when>
            <xsl:when test="substring(.,8,1) = 'o'">1/2 in. tape width</xsl:when>
            <xsl:when test="substring(.,8,1) = 'p'">1 in. tape width</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tapeConfig">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'a'">full (1)</xsl:when>
            <xsl:when test="substring(.,9,1) = 'b'">half (2)</xsl:when>
            <xsl:when test="substring(.,9,1) = 'c'">quarter (4)</xsl:when>
            <xsl:when test="substring(.,9,1) = 'd'">8</xsl:when>
            <xsl:when test="substring(.,9,1) = 'e'">12</xsl:when>
            <xsl:when test="substring(.,9,1) = 'f'">16</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'a'">master tape</xsl:when>
            <xsl:when test="substring(.,10,1) = 'b'">tape duplication master</xsl:when>
            <xsl:when test="substring(.,10,1) = 'd'">disc master (negative)</xsl:when>
            <xsl:when test="substring(.,10,1) = 'i'">instantaneous (recorded on the spot)</xsl:when>
            <xsl:when test="substring(.,10,1) = 'm'">mass produced</xsl:when>
            <xsl:when test="substring(.,10,1) = 'r'">mother (positive)</xsl:when>
            <xsl:when test="substring(.,10,1) = 's'">stamper (negative)</xsl:when>
            <xsl:when test="substring(.,10,1) = 't'">test pressing</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'b'">cellulose nitrate</xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'">acetate tape</xsl:when>
            <xsl:when test="substring(.,11,1) = 'g'">glass</xsl:when>
            <xsl:when test="substring(.,11,1) = 'i'">aluminum</xsl:when>
            <xsl:when test="substring(.,11,1) = 'r'">paper</xsl:when>
            <xsl:when test="substring(.,11,1) = 'l'">metal</xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'">plastic</xsl:when>
            <xsl:when test="substring(.,11,1) = 'p'">plastic</xsl:when>
            <xsl:when test="substring(.,11,1) = 's'">shellac</xsl:when>
            <xsl:when test="substring(.,11,1) = 'w'">wax</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'b'"><xsl:value-of select="concat($mmaterial,'lac')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'"><xsl:value-of select="concat($mmaterial,'ace')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'g'"><xsl:value-of select="concat($mmaterial,'gla')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'i'"><xsl:value-of select="concat($mmaterial,'alu')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'r'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'l'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'p'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 's'"><xsl:value-of select="concat($mmaterial,'she')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'w'"><xsl:value-of select="concat($mmaterial,'wax')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="emulsion">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'">lacquer coating</xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'">ferrous oxide</xsl:when>
            <xsl:when test="substring(.,11,1) = 'g'">lacquer</xsl:when>
            <xsl:when test="substring(.,11,1) = 'i'">lacquer</xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'">metal</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="emulsionUri">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'"><xsl:value-of select="concat($mmaterial,'lac')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'"><xsl:value-of select="concat($mmaterial,'fer')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'g'"><xsl:value-of select="concat($mmaterial,'lac')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'i'"><xsl:value-of select="concat($mmaterial,'lac')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cutting">
          <xsl:choose>
            <xsl:when test="substring(.,12,1) = 'h'">hill-and-dale cutting</xsl:when>
            <xsl:when test="substring(.,12,1) = 'l'">lateral or combined cutting</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackCharacteristic">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'">NAB standard</xsl:when>
            <xsl:when test="substring(.,13,1) = 'b'">CCIR standard</xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'">Dolby-B encoded</xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'">dbx encoded</xsl:when>
            <xsl:when test="substring(.,13,1) = 'e'">digital recording</xsl:when>
            <xsl:when test="substring(.,13,1) = 'f'">Dolby-A encoded</xsl:when>
            <xsl:when test="substring(.,13,1) = 'g'">Dolby-C encoded</xsl:when>
            <xsl:when test="substring(.,13,1) = 'h'">CX encoded</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/s</xsl:attribute>
                  <rdfs:label>audio</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$playingSpeed != ''">
              <bf:soundCharacteristic>
                <bf:PlayingSpeed>
                  <rdfs:label><xsl:value-of select="$playingSpeed"/></rdfs:label>
                </bf:PlayingSpeed>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$playbackChannels != ''">
              <bf:soundCharacteristic>
                <bf:PlaybackChannels>
                  <xsl:if test="$playbackUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$playbackUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$playbackChannels"/></rdfs:label>
                </bf:PlaybackChannels>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$grooveCharacteristic != ''">
              <bf:soundCharacteristic>
                <bf:GrooveCharacteristic>
                  <rdfs:label><xsl:value-of select="$grooveCharacteristic"/></rdfs:label>
                </bf:GrooveCharacteristic>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$dimensions != ''">
              <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
            </xsl:if>
            <xsl:if test="$tapeWidth != ''">
              <bf:dimensions><xsl:value-of select="$tapeWidth"/></bf:dimensions>
            </xsl:if>
            <xsl:if test="$tapeConfig != ''">
              <bf:soundCharacteristic>
                <bf:TapeConfig>
                  <rdfs:label><xsl:value-of select="$tapeConfig"/></rdfs:label>
                </bf:TapeConfig>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$emulsion != ''">
              <bf:emulsion>
                <bf:Emulsion>
                  <xsl:if test="$emulsionUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$emulsionUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$emulsion"/></rdfs:label>
                </bf:Emulsion>
              </bf:emulsion>
            </xsl:if>
            <xsl:if test="$cutting != ''">
              <bf:soundCharacteristic>
                <bf:GrooveCharacteristic>
                  <rdfs:label><xsl:value-of select="$cutting"/></rdfs:label>
                </bf:GrooveCharacteristic>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$playbackCharacteristic != ''">
              <bf:soundCharacteristic>
                <bf:PlaybackCharacteristic>
                  <rdfs:label><xsl:value-of select="$playbackCharacteristic"/></rdfs:label>
                </bf:PlaybackCharacteristic>
              </bf:soundCharacteristic>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- videorecording -->
      <xsl:when test="substring(.,1,1) = 'v'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'">videocartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'">videodisc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">videocassette</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">videotape reel</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'vc')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'vd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'vf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($carriers,'vr')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="videoFormat">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">Beta (1/2 in.videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'">VHS (1/2 in.videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">U-matic  (3/4 in.videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">EIAJ (1/2 in.reel)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">Type C  (1 in.reel)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">Quadruplex (1 in.or 2 in. reel)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">Laserdisc</xsl:when>
            <xsl:when test="substring(.,5,1) = 'h'">CED (Capacitance Electronic Disc)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">Betacam (1/2 in., videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">Betacam SP (1/2 in., videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'k'">Super-VHS (1/2 in. videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'">M-II (1/2 in., videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">D-2 (3/4 in., videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">8 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'">Hi-8 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 's'">Blu-ray disc</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">DVD</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContent">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'a'">sound on medium</xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'">sound separate from medium</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMedium">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">optical sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">magnetic audio tape in cartridge</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">sound disc</xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'">magnetic audio tape on reel</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">magnetic audio tape in cassette</xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'">optical and magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'h'">videotape</xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'">videodisc</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'">8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'm'">1/4 in.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'o'">1/2 in.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'p'">1 in.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'q'">2 in.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'r'">3/4 in.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackChannels">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'k'">mixed</xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'">monaural</xsl:when>
            <xsl:when test="substring(.,9,1) = 'q'">quadraphonic, multichannel or surround</xsl:when>
            <xsl:when test="substring(.,9,1) = 's'">stereophonic</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackUri">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'k'"><xsl:value-of select="concat($mplayback,'mix')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'"><xsl:value-of select="concat($mplayback,'mon')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'q'"><xsl:value-of select="concat($mplayback,'mul')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 's'"><xsl:value-of select="concat($mplayback,'ste')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/v</xsl:attribute>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$videoFormat != ''">
              <bf:videoCharacteristic>
                <bf:VideoFormat>
                  <rdfs:label><xsl:value-of select="$videoFormat"/></rdfs:label>
                </bf:VideoFormat>
              </bf:videoCharacteristic>
            </xsl:if>
            <xsl:if test="$soundContent != ''">
              <bf:soundContent>
                <bf:SoundContent>
                  <rdfs:label><xsl:value-of select="$soundContent"/></rdfs:label>
                </bf:SoundContent>
              </bf:soundContent>
            </xsl:if>
            <xsl:if test="$recordingMedium != ''">
              <bf:soundCharacteristic>
                <bf:RecordingMedium>
                  <rdfs:label><xsl:value-of select="$recordingMedium"/></rdfs:label>
                </bf:RecordingMedium>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$dimensions != ''">
              <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
            </xsl:if>
            <xsl:if test="$playbackChannels != ''">
              <bf:soundCharacteristic>
                <bf:PlaybackChannels>
                  <xsl:if test="$playbackUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$playbackUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$playbackChannels"/></rdfs:label>
                </bf:PlaybackChannels>
              </bf:soundCharacteristic>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <local:millus xmlns:local="local:">
    <a href="http://id.loc.gov/vocabulary/millus/ill">illustrations</a>
    <b href="http://id.loc.gov/vocabulary/millus/map">maps</b>
    <c href="http://id.loc.gov/vocabulary/millus/por">portraits</c>
    <d href="http://id.loc.gov/vocabulary/millus/chr">charts</d>
    <e href="http://id.loc.gov/vocabulary/millus/pln">plans</e>
    <f href="http://id.loc.gov/vocabulary/millus/plt">plates</f>
    <g href="http://id.loc.gov/vocabulary/millus/mus">music</g>
    <h href="http://id.loc.gov/vocabulary/millus/fac">facsimiles</h>
    <i href="http://id.loc.gov/vocabulary/millus/coa">coats of arms</i>
    <j href="http://id.loc.gov/vocabulary/millus/gnt">geneological tables</j>
    <k href="http://id.loc.gov/vocabulary/millus/for">forms</k>
    <l href="http://id.loc.gov/vocabulary/millus/sam">samples</l>
    <m href="http://id.loc.gov/vocabulary/millus/pho">phonodisc, phonowire</m>
    <o href="http://id.loc.gov/vocabulary/millus/pht">photographs</o>
    <p href="http://id.loc.gov/vocabulary/millus/ilm">illuminations</p>
  </local:millus><local:maudience xmlns:local="local:">
    <a href="http://id.loc.gov/vocabulary/maudience/pre">preschool</a>
    <b href="http://id.loc.gov/vocabulary/maudience/pri">primary</b>
    <c href="http://id.loc.gov/vocabulary/maudience/pad">pre-adolescent</c>
    <d href="http://id.loc.gov/vocabulary/maudience/ado">adolescent</d>
    <e href="http://id.loc.gov/vocabulary/maudience/adu">adult</e>
    <f href="http://id.loc.gov/vocabulary/maudience/spe">specialized</f>
    <g href="http://id.loc.gov/vocabulary/maudience/gen">general</g>
    <j href="http://id.loc.gov/vocabulary/maudience/juv">juvenile</j>
  </local:maudience><local:carrier xmlns:local="local:">
    <a href="http://id.loc.gov/vocabulary/mediaTypes/h">microfilm</a>
    <b href="http://id.loc.gov/vocabulary/carriers/he">microfiche</b>
    <c href="http://id.loc.gov/vocabulary/carriers/hg">microopaque</c>
    <o href="http://id.loc.gov/vocabulary/carriers/cr">online resource</o>
    <q>direct electronic</q>
    <r>regular print reproduction</r>
    <s>electronic</s>
  </local:carrier><local:marcgt xmlns:local="local:">
    <a href="http://id.loc.gov/vocabulary/marcgt/abs">abstract or summary</a>
    <b href="http://id.loc.gov/vocabulary/marcgt/bib">bibliography</b>
    <c href="http://id.loc.gov/vocabulary/marcgt/cat">catalog</c>
    <d href="http://id.loc.gov/vocabulary/marcgt/dic">dictionary</d>
    <e href="http://id.loc.gov/vocabulary/marcgt/enc">encyclopedia</e>
    <f href="http://id.loc.gov/vocabulary/marcgt/han">handbook</f>
    <g href="http://id.loc.gov/vocabulary/marcgt/lea">legal article</g>
    <h href="http://id.loc.gov/vocabulary/marcgt/bio">biography</h>
    <i href="http://id.loc.gov/vocabulary/marcgt/ind">index</i>
    <j href="http://id.loc.gov/vocabulary/marcgt/pat">patent</j>
    <k href="http://id.loc.gov/vocabulary/marcgt/dis">discography</k>
    <l href="http://id.loc.gov/vocabulary/marcgt/leg">legislation</l>
    <m href="http://id.loc.gov/vocabulary/marcgt/the">thesis</m>
    <n href="http://id.loc.gov/vocabulary/marcgt/sur">survey of literature</n>
    <o href="http://id.loc.gov/vocabulary/marcgt/rev">review</o>
    <p href="http://id.loc.gov/vocabulary/marcgt/pro">programmed text</p>
    <q href="http://id.loc.gov/vocabulary/marcgt/fil">filmography</q>
    <r href="http://id.loc.gov/vocabulary/marcgt/dir">directory</r>
    <s href="http://id.loc.gov/vocabulary/marcgt/sta">statistics</s>
    <t href="http://id.loc.gov/vocabulary/marcgt/ter">technical report</t>
    <u href="http://id.loc.gov/vocabulary/marcgt/stp">standard of specification</u>
    <v href="http://id.loc.gov/vocabulary/marcgt/lec">legal case and case notes</v>
    <w href="http://id.loc.gov/vocabulary/marcgt/law">law report or digest</w>
    <y href="http://id.loc.gov/vocabulary/marcgt/yea">yearbook</y>
    <z href="http://id.loc.gov/vocabulary/marcgt/tre">treaty</z>
    <x2 href="http://id.loc.gov/vocabulary/marcgt/off">offprint</x2>
    <x5 href="http://id.loc.gov/vocabulary/marcgt/cal">calendar</x5>
    <x6 href="http://id.loc.gov/vocabulary/marcgt/cgn">comic or graphic novel</x6>
  </local:marcgt><local:litform xmlns:local="local:">
    <x1 href="http://id.loc.gov/vocabulary/marcgt/fic">fiction</x1>
    <d href="http://id.loc.gov/vocabulary/marcgt/fic">drama</d>
    <e href="http://id.loc.gov/vocabulary/marcgt/fic">essay</e>
    <f href="http://id.loc.gov/vocabulary/marcgt/fic">novel</f>
    <h href="http://id.loc.gov/vocabulary/marcgt/fic">humor, satire</h>
    <i href="http://id.loc.gov/vocabulary/marcgt/fic">letter</i>
    <j href="http://id.loc.gov/vocabulary/marcgt/fic">short story</j>
    <m href="http://id.loc.gov/vocabulary/marcgt/fic">mixed fiction</m>
    <p href="http://id.loc.gov/vocabulary/marcgt/fic">poetry</p>
    <s href="http://id.loc.gov/vocabulary/marcgt/fic">speech</s>
  </local:litform><local:bioform xmlns:local="local:">
    <a href="http://id.loc.gov/vocabulary/marcgt/aut">autobiography</a>
    <b href="http://id.loc.gov/vocabulary/marcgt/bio">individual biography</b>
    <c href="http://id.loc.gov/vocabulary/marcgt/bio">collective biography</c>
    <d href="http://id.loc.gov/vocabulary/marcgt/bio">contains biographical information</d>
  </local:bioform><local:computerFileType xmlns:local="local:">
    <a href="http://id.loc.gov/vocabulary/marcgt/num">numeric data</a>
    <b href="http://id.loc.gov/vocabulary/marcgt/com">computer program</b>
    <c href="http://id.loc.gov/vocabulary/marcgt/rep">representational</c>
    <d href="http://id.loc.gov/vocabulary/marcgt/doc">document (computer)</d>
    <e href="http://id.loc.gov/vocabulary/marcgt/bda">bibliographic data</e>
    <f href="http://id.loc.gov/vocabulary/marcgt/fon">font</f>
    <g href="http://id.loc.gov/vocabulary/marcgt/gam">game</g>
    <h>sound</h>
    <i href="http://id.loc.gov/vocabulary/marcgt/inm">interactive multimedia</i>
    <j href="http://id.loc.gov/vocabulary/marcgt/ons">online system or service</j>
    <m>computer file combination</m>
  </local:computerFileType><local:carttype xmlns:local="local:">
    <a prop="issuance">single map</a>
    <b prop="issuance">map series</b>
    <c prop="issuance">map serial</c>
    <d prop="genreForm" href="http://id.loc.gov/vocabulary/marcgt/glo">globe</d>
    <e prop="genreForm" href="http://id.loc.gov/vocabulary/marcgt/atl">atlas</e>
    <f prop="issuance">map supplement to another work</f>
    <g prop="issuance">map bound as part of another work</g>
  </local:carttype><local:mapform xmlns:local="local:">
    <e href="http://id.loc.gov/vocabulary/marcgt/man">manuscript</e>
    <j href="http://id.loc.gov/vocabulary/marcgt/pos">picture card, post card</j>
    <k href="http://id.loc.gov/vocabulary/marcgt/cal">calendar</k>
    <l href="http://id.loc.gov/vocabulary/marcgt/puz">puzzle</l>
    <n href="http://id.loc.gov/vocabulary/marcgt/gam">game</n>
    <o href="http://id.loc.gov/vocabulary/marcgt/wal">wall map</o>
    <p href="http://id.loc.gov/vocabulary/marcgt/pla">playing cards</p>
    <r href="http://id.loc.gov/vocabulary/marcgt/loo">loose-leaf</r>
  </local:mapform><local:musicTextForm xmlns:local="local:">
    <a href="http://id.loc.gov/vocabulary/marcgt/aut">autobiography</a>
    <b href="http://id.loc.gov/vocabulary/marcgt/bio">biography</b>
    <c href="http://id.loc.gov/vocabulary/marcgt/cpl">conference proceedings</c>
    <d href="http://id.loc.gov/vocabulary/marcgt/dra">drama</d>
    <e href="http://id.loc.gov/vocabulary/marcgt/ess">essays</e>
    <f href="http://id.loc.gov/vocabulary/marcgt/fic">fiction</f>
    <g href="http://id.loc.gov/vocabulary/marcgt/rpt">reporting</g>
    <h href="http://id.loc.gov/vocabulary/marcgt/his">history</h>
    <i href="http://id.loc.gov/vocabulary/marcgt/ins">instruction</i>
    <j href="http://id.loc.gov/vocabulary/marcgt/lan">language instruction</j>
    <k href="http://id.loc.gov/vocabulary/marcgt/cod">comedy</k>
    <l href="http://id.loc.gov/vocabulary/marcgt/spe">lectures, speeches</l>
    <m href="http://id.loc.gov/vocabulary/marcgt/mem">memoirs</m>
    <o href="http://id.loc.gov/vocabulary/marcgt/fol">folktales</o>
    <p href="http://id.loc.gov/vocabulary/marcgt/poe">poetry</p>
    <r href="http://id.loc.gov/vocabulary/marcgt/reh">rehearsals</r>
    <s href="http://id.loc.gov/vocabulary/marcgt/sou">sounds</s>
    <t href="http://id.loc.gov/vocabulary/marcgt/int">interviews</t>
  </local:musicTextForm><local:frequency xmlns:local="local:">
    <a href="http://id.loc.gov/vocabulary/frequencies/ann">annual</a>
    <b href="http://id.loc.gov/vocabulary/frequencies/bmn">bimonthly</b>
    <c href="http://id.loc.gov/vocabulary/frequencies/swk">semiweekly</c>
    <d href="http://id.loc.gov/vocabulary/frequencies/dyl">daily</d>
    <e href="http://id.loc.gov/vocabulary/frequencies/bwk">biweekly</e>
    <f href="http://id.loc.gov/vocabulary/frequencies/san">semiannual</f>
    <g href="http://id.loc.gov/vocabulary/frequencies/bin">biennial</g>
    <h href="http://id.loc.gov/vocabulary/frequencies/ten">triennial</h>
    <i href="http://id.loc.gov/vocabulary/frequencies/ttw">three times a week</i>
    <j href="http://id.loc.gov/vocabulary/frequencies/ttm">three times a month</j>
    <k href="http://id.loc.gov/vocabulary/frequencies/con">continuously updated</k>
    <m href="http://id.loc.gov/vocabulary/frequencies/mon">monthly</m>
    <q href="http://id.loc.gov/vocabulary/frequencies/grt">quarterly</q>
    <s href="http://id.loc.gov/vocabulary/frequencies/smn">semimonthly</s>
    <t href="http://id.loc.gov/vocabulary/frequencies/tty">three times a year</t>
    <w href="http://id.loc.gov/vocabulary/frequencies/wkl">weekly</w>
  </local:frequency><local:crtype xmlns:local="local:">
    <d href="http://id.loc.gov/vocabulary/marcgt/dtd">updating database</d>
    <l href="http://id.loc.gov/vocabulary/marcgt/loo">updating loose-leaf</l>
    <m href="http://id.loc.gov/vocabulary/marcgt/ser">monographic series</m>
    <n href="http://id.loc.gov/vocabulary/marcgt/new">newspaper</n>
    <p href="http://id.loc.gov/vocabulary/marcgt/per">periodical</p>
    <w href="http://id.loc.gov/vocabulary/marcgt/web">updating web site</w>
  </local:crtype><local:visualtype xmlns:local="local:">
    <a href="http://id.loc.gov/vocabulary/marcgt/aro">art original</a>
    <b href="http://id.loc.gov/vocabulary/marcgt/kit">kit</b>
    <c href="http://id.loc.gov/vocabulary/marcgt/art">art reproduction</c>
    <d href="http://id.loc.gov/vocabulary/marcgt/dio">diorama</d>
    <f href="http://id.loc.gov/vocabulary/marcgt/fls">filmstrip</f>
    <g href="http://id.loc.gov/vocabulary/marcgt/gam">game</g>
    <i href="http://id.loc.gov/vocabulary/marcgt/pic">picture</i>
    <k href="http://id.loc.gov/vocabulary/marcgt/gra">graphic</k>
    <l href="http://id.loc.gov/vocabulary/marcgt/ted">technical drawing</l>
    <m href="http://id.loc.gov/vocabulary/marcgt/mot">motion picture</m>
    <n href="http://id.loc.gov/vocabulary/marcgt/cha">chart</n>
    <o href="http://id.loc.gov/vocabulary/marcgt/fla">flash card</o>
    <p href="http://id.loc.gov/vocabulary/marcgt/mic">microscope slide</p>
    <q href="http://id.loc.gov/vocabulary/marcgt/mod">model</q>
    <r href="http://id.loc.gov/vocabulary/marcgt/rea">realia</r>
    <s href="http://id.loc.gov/vocabulary/marcgt/sli">slide</s>
    <t href="http://id.loc.gov/vocabulary/marcgt/tra">transparency</t>
    <v href="http://id.loc.gov/vocabulary/marcgt/vid">videorecording</v>
    <w href="http://id.loc.gov/vocabulary/marcgt/toy">toy</w>
  </local:visualtype><xsl:template xmlns:local="local:" match="marc:controlfield[@tag='006']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <!-- continuing resources -->
    <xsl:if test="substring(.,1,1) = 's'">
      <xsl:call-template name="entryConvention008">
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="code" select="substring(.,18,1)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:controlfield[@tag='008']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="marcYear" select="substring(.,1,2)"/>
    <xsl:variable name="creationYear">
      <xsl:choose>
        <xsl:when test="$marcYear &lt; 50"><xsl:value-of select="concat('20',$marcYear)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat('19',$marcYear)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization= 'rdfxml'">
        <bf:creationDate>
          <xsl:attribute name="rdf:datatype"><xsl:value-of select="$xs"/>date</xsl:attribute>
          <xsl:value-of select="concat($creationYear,'-',substring(.,3,2),'-',substring(.,5,2))"/>
        </bf:creationDate>
      </xsl:when>
    </xsl:choose>
    <!-- continuing resources -->
    <xsl:if test="substring(../marc:leader,7,1) = 'a' and                   (substring(../marc:leader,8,1) = 'b' or                    substring(../marc:leader,8,1) = 'i' or                    substring(../marc:leader,8,1) = 's')">
      <xsl:call-template name="entryConvention008">
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="code" select="substring(.,35,1)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" name="entryConvention008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="code"/>
    <xsl:variable name="convention">
      <xsl:choose>
        <xsl:when test="$code='0'">0 - successive</xsl:when>
        <xsl:when test="$code='1'">1 - latest</xsl:when>
        <xsl:when test="$code='2'">2 - integrated</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$convention != ''">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:note>
            <bf:Note>
              <bf:noteType>metadata entry convention</bf:noteType>
              <rdfs:label><xsl:value-of select="$convention"/></rdfs:label>
            </bf:Note>
          </bf:note>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:controlfield[@tag='006']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <!-- select call appropriate 008 template based on pos 0 -->
    <xsl:choose>
      <!-- books -->
      <xsl:when test="substring(.,1,1) = 'a' or                       substring(.,1,1) = 't'">
        <xsl:call-template name="work008books">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- computer files -->
      <xsl:when test="substring(.,1,1) = 'm'">
        <xsl:call-template name="work008computerfiles">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- maps -->
      <xsl:when test="substring(.,1,1) = 'e' or                       substring(.,1,1) = 'f'">
        <xsl:call-template name="work008maps">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- music -->
      <xsl:when test="substring(.,1,1) = 'c' or                       substring(.,1,1) = 'd' or                       substring(.,1,1) = 'i' or                       substring(.,1,1) = 'j'">
        <xsl:call-template name="work008music">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- continuing resources -->
      <xsl:when test="substring(.,1,1) = 's'">
        <xsl:call-template name="work008cr">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- visual materials -->
      <xsl:when test="substring(.,1,1) = 'g' or                       substring(.,1,1) = 'k' or                       substring(.,1,1) = 'o' or                       substring(.,1,1) = 'r'">
        <xsl:call-template name="work008visual">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:controlfield[@tag='008']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="language">
      <xsl:choose>
        <xsl:when test="substring(.,36,3) = '   '"/>
        <xsl:otherwise><xsl:value-of select="substring(.,36,3)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$language != ''">
          <bf:language>
            <bf:Language>
              <xsl:attribute name="rdf:about"><xsl:value-of select="concat($languages,$language)"/></xsl:attribute>
            </bf:Language>
          </bf:language>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <!-- books -->
      <xsl:when test="(substring(../marc:leader,7,1) = 'a' or substring(../marc:leader,7,1 = 't')) and                       (substring(../marc:leader,8,1) = 'a' or substring(../marc:leader,8,1) = 'c' or substring(../marc:leader,8,1) = 'd' or substring(../marc:leader,8,1) = 'm')">
        <xsl:call-template name="work008books">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- computer files -->
      <xsl:when test="substring(../marc:leader,7,1) = 'm'">
        <xsl:call-template name="work008computerfiles">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- maps -->
      <xsl:when test="substring(../marc:leader,7,1) = 'e' or substring(../marc:leader,7,1) = 'f'">
        <xsl:call-template name="work008maps">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- music -->
      <xsl:when test="substring(../marc:leader,7,1) = 'c' or                       substring(../marc:leader,7,1) = 'd' or                       substring(../marc:leader,7,1) = 'i' or                       substring(../marc:leader,7,1) = 'j'">
        <xsl:call-template name="work008music">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- continuing resources -->
      <xsl:when test="substring(../marc:leader,7,1) = 'a' and                       (substring(../marc:leader,8,1) = 'b' or                         substring(../marc:leader,8,1) = 'i' or                         substring(../marc:leader,8,1) = 's')">
        <xsl:call-template name="work008cr">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- visual materials -->
      <xsl:when test="substring(../marc:leader,7,1) = 'g' or                       substring(../marc:leader,7,1) = 'k' or                       substring(../marc:leader,7,1) = 'o' or                       substring(../marc:leader,7,1) = 'r'">
        <xsl:call-template name="work008visual">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="work008books">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:call-template name="intendedAudience008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,5,1)"/>
    </xsl:call-template>
    <xsl:call-template name="genreForm008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="contents" select="substring($dataElements,7,4)"/>
    </xsl:call-template>
    <xsl:call-template name="govdoc008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,11,1)"/>
    </xsl:call-template>
    <xsl:call-template name="conference008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,12,1)"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="substring($dataElements,13,1) = '1'">
          <bf:genreForm>
            <bf:GenreForm>
              <xsl:attribute name="rdf:about"><xsl:value-of select="concat($marcgt,'fes')"/></xsl:attribute>
              <rdfs:label>festschrift</rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
    <xsl:for-each select="document('')/*/local:litform/*[name() = substring($dataElements,16,1)] |                           document('')/*/local:litform/*[name() = concat('x',substring($dataElements,16,1))]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:genreForm>
            <bf:GenreForm>
              <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="document('')/*/local:bioform/*[name() = substring($dataElements,17,1)]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:genreForm>
            <bf:GenreForm>
              <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template><xsl:template xmlns:local="local:" name="work008computerfiles">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:call-template name="intendedAudience008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,5,1)"/>
    </xsl:call-template>
    <xsl:for-each select="document('')/*/local:computerFileType/*[name() = substring($dataElements,9,1)]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:genreForm>
            <bf:GenreForm>
              <xsl:if test="@href">
                <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
              </xsl:if>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:call-template name="govdoc008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,11,1)"/>
    </xsl:call-template>
  </xsl:template><xsl:template xmlns:local="local:" name="work008maps">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:call-template name="govdoc008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,11,1)"/>
    </xsl:call-template>
    <xsl:call-template name="mapform008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="form" select="substring($dataElements,16,2)"/>
    </xsl:call-template>
  </xsl:template><xsl:template xmlns:local="local:" name="work008music">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:variable name="compform">
      <xsl:choose>
        <xsl:when test="substring($dataElements,1,2) = 'an'">anthems</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'bd'">ballads</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'bg'">bluegrass music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'bl'">blues</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'bt'">ballets</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'ca'">chaconnes</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cb'">chants, other religions</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cc'">chant, Christian</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cg'">concerti grossi</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'ch'">chorales</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cl'">chorale preludes</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cn'">canons and rounds</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cp'">chansons, polyphonic</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cr'">carols</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cs'">chance compositions</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'ct'">cantatas</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cy'">country music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'cz'">canzonas</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'df'">dance forms</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'dv'">divertimentos, serenades, cassations, divertissements, notturni</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'fg'">fugues</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'fl'">flamenco</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'fm'">folk music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'ft'">fantasias</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'gm'">gospel music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'hy'">hymns</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'jz'">jazz</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'mc'">musical revues and comedies</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'md'">madrigals</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'mi'">minuets</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'mo'">motets</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'mp'">motion picture music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'mr'">marches</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'ms'">masses</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'mu'">multiple forms</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'mz'">mazurkas</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'nc'">nocturnes</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'op'">operas</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'or'">oratorios</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'ov'">overtures</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'pg'">program music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'pm'">passion music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'po'">polonaises</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'pp'">popular music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'pr'">preludes</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'ps'">passacaglias</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'pt'">part-songs</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'pv'">pavans</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'rc'">rock music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'rd'">rondos</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'rg'">ragtime music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'ri'">ricercars</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'rp'">rhapsodies</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'rq'">requiems</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'sd'">square dance music</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'sg'">songs</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'sn'">sonatas</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'sp'">symphonic poems</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'st'">studies and exercises</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'su'">suites</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'sy'">symphonies</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'tc'">toccatas</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'tl'">teatro lirico</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'ts'">trio-sonatas</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'vi'">villancicos</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'vr'">variations</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'wz'">waltzes</xsl:when>
        <xsl:when test="substring($dataElements,1,2) = 'za'">arzuelas</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="musicformat">
      <xsl:choose>
        <xsl:when test="substring($dataElements,3,1) = 'a'">full score</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'b'">full score, miniature or study size</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'c'">accompaniment reduced for keyboard</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'd'">voice score with accompaniment omitted</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'e'">condensed score or piano-conductor score</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'g'">close score</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'h'">chorus score</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'i'">condensed score</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'j'">performer-conducter part</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'k'">vocal score</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'l'">score</xsl:when>
        <xsl:when test="substring($dataElements,3,1) = 'm'">multiple score formats</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="intendedAudience008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,5,1)"/>
    </xsl:call-template>
    <xsl:call-template name="suppContentMusic008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="accomp" select="substring($dataElements,7,6)"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$compform != ''">
          <bf:genreForm>
            <bf:GenreForm>
              <bf:code><xsl:value-of select="substring($dataElements,1,2)"/></bf:code>
              <rdfs:label><xsl:value-of select="$compform"/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:if>
        <xsl:if test="$musicformat != ''">
          <bf:musicFormat>
            <bf:MusicFormat>
              <bf:code><xsl:value-of select="substring($dataElements,3,1)"/></bf:code>
              <rdfs:label><xsl:value-of select="$musicformat"/></rdfs:label>
            </bf:MusicFormat>
          </bf:musicFormat>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="musicTextForm008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="litform" select="substring($dataElements,13,2)"/>
    </xsl:call-template>
  </xsl:template><xsl:template xmlns:local="local:" name="work008cr">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:variable name="script">
      <xsl:choose>
        <xsl:when test="substring($dataElements,16,1) = 'a'">basic roman</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'b'">extended roman</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'c'">cyrillic</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'd'">japanese</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'e'">chinese</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'f'">arabic</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'g'">greek</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'h'">hebrew</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'i'">thai</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'j'">devanagari</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'k'">korean</xsl:when>
        <xsl:when test="substring($dataElements,16,1) = 'l'">tamil</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="genreForm008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="contents" select="substring($dataElements,7,4)"/>
    </xsl:call-template>
    <xsl:call-template name="govdoc008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,11,1)"/>
    </xsl:call-template>
    <xsl:call-template name="conference008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,12,1)"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$script != ''">
          <bf:notation>
            <bf:Script>
              <bf:code><xsl:value-of select="substring($dataElements,16,1)"/></bf:code>
              <rdfs:label><xsl:value-of select="$script"/></rdfs:label>
            </bf:Script>
          </bf:notation>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="work008visual">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:variable name="duration">
      <xsl:choose>
        <xsl:when test="substring($dataElements,1,3) = '000'">more than 999 minutes</xsl:when>
        <xsl:when test="substring($dataElements,1,3) = '---'"/>
        <xsl:when test="substring($dataElements,1,3) = 'nnn'"/>
        <xsl:when test="substring($dataElements,1,3) = '|||'"/>
        <xsl:otherwise><xsl:value-of select="substring($dataElements,1,3)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="intendedAudience008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,5,1)"/>
    </xsl:call-template>
    <xsl:call-template name="govdoc008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,11,1)"/>
    </xsl:call-template>
    <xsl:for-each select="document('')/*/local:visualtype/*[name() = substring($dataElements,16,1)]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:genreForm>
            <bf:GenreForm>
              <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$duration != ''">
          <bf:duration>
            <xsl:choose>
              <xsl:when test="substring($dataElements,1,3) != '000'">
                <xsl:attribute name="rdf:datatype"><xsl:value-of select="concat($xs,'duration')"/></xsl:attribute>
              </xsl:when>
            </xsl:choose>
            <xsl:value-of select="$duration"/>
          </bf:duration>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="intendedAudience008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="code"/>
    <xsl:for-each select="document('')/*/local:maudience/*[name() = $code]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:intendedAudience>
            <bf:IntendedAudience>
              <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:IntendedAudience>
          </bf:intendedAudience>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template><xsl:template xmlns:local="local:" name="genreForm008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="contents"/>
    <xsl:param name="i" select="1"/>
    <xsl:if test="$i &lt; 5">
      <xsl:for-each select="document('')/*/local:marcgt/*[name() = substring($contents,$i,1)] |                             document('')/*/local:marcgt/*[name() = concat('x',substring($contents,$i,1))]">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <bf:genreForm>
              <bf:GenreForm>
                <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
                <rdfs:label><xsl:value-of select="."/></rdfs:label>
              </bf:GenreForm>
            </bf:genreForm>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      <xsl:call-template name="genreForm008">
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="contents" select="$contents"/>
        <xsl:with-param name="i" select="$i + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" name="govdoc008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="code"/>
    <xsl:variable name="govdoc">
      <xsl:choose>
        <xsl:when test="$code = 'a'">autonomous or semi-autonomous government publication</xsl:when>
        <xsl:when test="$code = 'c'">multilocal government publication</xsl:when>
        <xsl:when test="$code = 'f'">federal or national government publication</xsl:when>
        <xsl:when test="$code = 'i'">international intergovernmental government publication</xsl:when>
        <xsl:when test="$code = 'l'">local government publication</xsl:when>
        <xsl:when test="$code = 'm'">multistate government publication</xsl:when>
        <xsl:when test="$code = 'o'">government publication</xsl:when>
        <xsl:when test="$code = 's'">state, provincial, territorial, dependant government publication</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$govdoc != ''">
          <bf:genreForm>
            <bf:GenreForm>
              <xsl:attribute name="rdf:about"><xsl:value-of select="concat($marcgt,'gov')"/></xsl:attribute>
              <rdfs:label><xsl:value-of select="$govdoc"/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="conference008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="code"/>
    <xsl:if test="$code = '1'">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:genreForm>
            <bf:GenreForm>
              <xsl:attribute name="rdf:about"><xsl:value-of select="concat($marcgt,'cpb')"/></xsl:attribute>
              <rdfs:label>conference publication</rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" name="mapform008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="form"/>
    <xsl:param name="i" select="1"/>
    <xsl:if test="$i &lt; 3">
      <xsl:for-each select="document('')/*/local:mapform/*[name() = substring($form,$i,1)]">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <bf:genreForm>
              <bf:GenreForm>
                <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
                <rdfs:label><xsl:value-of select="."/></rdfs:label>
              </bf:GenreForm>
            </bf:genreForm>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      <xsl:call-template name="mapform008">
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="form" select="$form"/>
        <xsl:with-param name="i" select="$i + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" name="suppContentMusic008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="accomp"/>
    <xsl:param name="i" select="1"/>
    <xsl:if test="$i &lt; 7">
      <xsl:variable name="supp">
        <xsl:choose>
          <xsl:when test="substring($accomp,$i,1) = 'a'">discography</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'b'">bibliography</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'c'">thematic index</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'd'">libretto or text</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'e'">biography of composer or author</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'f'">biography of performer or history of ensemble</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'g'">technical and/or historical information on instruments</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'h'">technical information on music</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'i'">historical information</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'k'">ethnological information</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 'r'">instructional materials</xsl:when>
          <xsl:when test="substring($accomp,$i,1) = 's'">music</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$supp != ''">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <bf:supplementaryContent>
              <bf:SupplementaryContent>
                <bf:code><xsl:value-of select="substring($accomp,$i,1)"/></bf:code>
                <rdfs:label><xsl:value-of select="$supp"/></rdfs:label>
              </bf:SupplementaryContent>
            </bf:supplementaryContent>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:call-template name="suppContentMusic008">
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="accomp" select="$accomp"/>
        <xsl:with-param name="i" select="$i + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" name="musicTextForm008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="litform"/>
    <xsl:param name="i" select="1"/>
    <xsl:if test="$i &lt; 3">
      <xsl:for-each select="document('')/*/local:musicTextForm/*[name() = substring($litform,$i,1)]">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <bf:genreForm>
              <bf:GenreForm>
                <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
                <rdfs:label><xsl:value-of select="."/></rdfs:label>
              </bf:GenreForm>
            </bf:genreForm>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      <xsl:call-template name="musicTextForm008">
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="litform" select="$litform"/>
        <xsl:with-param name="i" select="$i + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:controlfield[@tag='006']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <!-- select call appropriate 008 template based on pos 0 -->
    <xsl:choose>
      <!-- books -->
      <xsl:when test="substring(.,1,1) = 'a' or                       substring(.,1,1) = 't'">
        <xsl:call-template name="instance008books">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- computer files -->
      <xsl:when test="substring(.,1,1) = 'm'">
        <xsl:call-template name="instance008computerfiles">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- maps -->
      <xsl:when test="substring(.,1,1) = 'e' or                       substring(.,1,1) = 'f'">
        <xsl:call-template name="instance008maps">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- mixed materials -->
      <xsl:when test="substring(.,1,1) = 'p'">
        <xsl:call-template name="instance008mixed">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- music -->
      <xsl:when test="substring(.,1,1) = 'c' or                       substring(.,1,1) = 'd' or                       substring(.,1,1) = 'i' or                       substring(.,1,1) = 'j'">
        <xsl:call-template name="instance008music">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- continuing resources -->
      <xsl:when test="substring(.,1,1) = 's'">
        <xsl:call-template name="instance008cr">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- visual materials -->
      <xsl:when test="substring(.,1,1) = 'g' or                       substring(.,1,1) = 'k' or                       substring(.,1,1) = 'o' or                       substring(.,1,1) = 'r'">
        <xsl:call-template name="instance008visual">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,2,17)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:controlfield[@tag='008']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="provisionDate">
      <xsl:choose>
        <xsl:when test="substring(.,7,1) = 'c'">
          <xsl:call-template name="u2x">
            <xsl:with-param name="dateString" select="concat(substring(.,8,4),'/..')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="substring(.,7,1) = 'd' or                         substring(.,7,1) = 'i' or                         substring(.,7,1) = 'k' or                         substring(.,7,1) = 'm' or                         substring(.,7,1) = 'q' or                         substring(.,7,1) = 'u'">
          <xsl:call-template name="u2x">
            <xsl:with-param name="dateString" select="concat(substring(.,8,4),'/',substring(.,12,4))"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="substring(.,7,1) = 'e'">
          <xsl:choose>
            <xsl:when test="substring(.,14,2) = '  '">
              <xsl:call-template name="u2x">
                <xsl:with-param name="dateString" select="concat(substring(.,8,4),'-',substring(.,12,4))"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="u2x">
                <xsl:with-param name="dateString" select="concat(substring(.,8,4),'-',substring(.,12,4),'-',substring(.,14,2))"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="substring(.,7,1) = 'p' or                         substring(.,7,1) = 'r' or                         substring(.,7,1) = 's' or                         substring(.,7,1) = 't'">
          <xsl:call-template name="u2x">
            <xsl:with-param name="dateString" select="substring(.,8,4)"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pubPlace">
      <xsl:choose>
        <xsl:when test="substring(.,18,1) = ' '"><xsl:value-of select="substring(.,16,2)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="substring(.,16,3)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:choose>
          <xsl:when test="$provisionDate != ''">
            <bf:provisionActivity>
              <bf:ProvisionActivity>
                <xsl:choose>
                  <xsl:when test="substring(.,7,1) = 'c' or                                   substring(.,7,1) = 'd' or                                   substring(.,7,1) = 'e' or                                   substring(.,7,1) = 'm' or                                   substring(.,7,1) = 'q' or                                   substring(.,7,1) = 'r' or                                   substring(.,7,1) = 's' or                                   substring(.,7,1) = 't' or                                   substring(.,7,1) = 'u'">
                    <rdf:type>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Publication')"/></xsl:attribute>
                    </rdf:type>
                  </xsl:when>
                  <xsl:when test="substring(.,7,1) = 'i' or                                   substring(.,7,1) = 'k'">
                    <rdf:type>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Production')"/></xsl:attribute>
                    </rdf:type>
                    <bf:note>
                      <bf:Note>
                        <xsl:choose>
                          <xsl:when test="substring(.,7,1) = 'i'">
                            <rdfs:label>inclusive collection dates</rdfs:label>
                          </xsl:when>
                          <xsl:otherwise>
                            <rdfs:label>bulk collection dates</rdfs:label>
                          </xsl:otherwise>
                        </xsl:choose>
                      </bf:Note>
                    </bf:note>
                  </xsl:when>
                  <xsl:when test="substring(.,7,1) = 'p'">
                    <rdf:type>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Distribution')"/></xsl:attribute>
                    </rdf:type>
                  </xsl:when>
                </xsl:choose>
                <bf:date>
                  <xsl:attribute name="rdf:datatype"><xsl:value-of select="concat($edtf,'edtf')"/></xsl:attribute>
                  <xsl:value-of select="$provisionDate"/>
                </bf:date>
                <xsl:if test="$pubPlace != ''">
                  <bf:place>
                    <bf:Place>
                      <xsl:attribute name="rdf:about"><xsl:value-of select="concat($countries,$pubPlace)"/></xsl:attribute>
                    </bf:Place>
                  </bf:place>
                </xsl:if>
              </bf:ProvisionActivity>
            </bf:provisionActivity>
            <xsl:choose>
              <xsl:when test="substring(.,7,1) = 'c'">
                <bf:note>
                  <bf:Note>
                    <rdfs:label>Currently published</rdfs:label>
                  </bf:Note>
                </bf:note>
              </xsl:when>
              <xsl:when test="substring(.,7,1) = 'd'">
                <bf:note>
                  <bf:Note>
                    <rdfs:label>Ceased publication</rdfs:label>
                  </bf:Note>
                </bf:note>
              </xsl:when>
              <xsl:when test="substring(.,7,1) = 'p'">
                <bf:provisionActivity>
                  <bf:ProvisionActivity>
                    <rdf:type>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Production')"/></xsl:attribute>
                    </rdf:type>
                    <bf:date>
                      <xsl:attribute name="rdf:datatype"><xsl:value-of select="concat($edtf,'edtf')"/></xsl:attribute>
                      <xsl:call-template name="u2x">
                        <xsl:with-param name="dateString" select="substring(.,12,4)"/>
                      </xsl:call-template>
                    </bf:date>
                  </bf:ProvisionActivity>
                </bf:provisionActivity>
              </xsl:when>
              <xsl:when test="substring(.,7,1) = 't'">
                <bf:copyrightDate>
                  <xsl:attribute name="rdf:datatype"><xsl:value-of select="concat($edtf,'edtf')"/></xsl:attribute>
                  <xsl:call-template name="u2x">
                    <xsl:with-param name="dateString" select="substring(.,12,4)"/>
                  </xsl:call-template>
                </bf:copyrightDate>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$pubPlace != ''">
              <bf:provisionActivity>
                <bf:ProvisionActivity>
                  <rdf:type>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Publication')"/></xsl:attribute>
                  </rdf:type>
                  <bf:place>
                    <bf:Place>
                      <xsl:attribute name="rdf:about"><xsl:value-of select="concat($countries,$pubPlace)"/></xsl:attribute>
                    </bf:Place>
                  </bf:place>
                </bf:ProvisionActivity>
              </bf:provisionActivity>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <!-- books -->
      <xsl:when test="(substring(../marc:leader,7,1) = 'a' or substring(../marc:leader,7,1 = 't')) and                       (substring(../marc:leader,8,1) = 'a' or substring(../marc:leader,8,1) = 'c' or substring(../marc:leader,8,1) = 'd' or substring(../marc:leader,8,1) = 'm')">
        <xsl:call-template name="instance008books">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
          <xsl:with-param name="leader" select="../marc:leader"/>
        </xsl:call-template>
      </xsl:when>
      <!-- computer files -->
      <xsl:when test="substring(../marc:leader,7,1) = 'm'">
        <xsl:call-template name="instance008computerfiles">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- maps -->
      <xsl:when test="substring(../marc:leader,7,1) = 'e' or substring(../marc:leader,7,1) = 'f'">
        <xsl:call-template name="instance008maps">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- music -->
      <xsl:when test="substring(../marc:leader,7,1) = 'c' or                       substring(../marc:leader,7,1) = 'd' or                       substring(../marc:leader,7,1) = 'i' or                       substring(../marc:leader,7,1) = 'j'">
        <xsl:call-template name="instance008music">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- continuing resources -->
      <xsl:when test="substring(../marc:leader,7,1) = 'a' and                       (substring(../marc:leader,8,1) = 'b' or                         substring(../marc:leader,8,1) = 'i' or                         substring(../marc:leader,8,1) = 's')">
        <xsl:call-template name="instance008cr">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- visual materials -->
      <xsl:when test="substring(../marc:leader,7,1) = 'g' or                       substring(../marc:leader,7,1) = 'k' or                       substring(../marc:leader,7,1) = 'o' or                       substring(../marc:leader,7,1) = 'r'">
        <xsl:call-template name="instance008visual">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- mixed materials -->
      <xsl:when test="substring(../marc:leader,7,1) = 'p'">
        <xsl:call-template name="instance008mixed">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="dataElements" select="substring(.,19,17)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="instance008books">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:param name="leader"/>
    <xsl:call-template name="illustrativeContent008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="illustrations" select="substring($dataElements,1,4)"/>
    </xsl:call-template>
    <xsl:call-template name="carrier008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,6,1)"/>
    </xsl:call-template>
    <xsl:call-template name="supplementaryContent008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,14,1)"/>
    </xsl:call-template>
    <xsl:variable name="instanceType">
      <xsl:choose>
        <xsl:when test="substring($dataElements,6,1) = 'o' or substring($dataElements,6,1) = 's'">
          <xsl:if test="substring($leader,7,1) != 'm'"><xsl:value-of select="concat($bf,'Electronic')"/></xsl:if>
        </xsl:when>
        <xsl:when test="substring($dataElements,6,1) = 'r'"><xsl:value-of select="concat($bf,'Print')"/></xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:choose>
          <xsl:when test="substring($dataElements,6,1) = 'd'">
            <bf:fontSize>
              <bf:FontSize>
                <rdfs:label>large print</rdfs:label>
              </bf:FontSize>
            </bf:fontSize>
          </xsl:when>
          <xsl:when test="substring($dataElements,6,1) = 'f'">
            <bf:notation>
              <bf:TactileNotation>
                <rdfs:label>braille</rdfs:label>
              </bf:TactileNotation>
            </bf:notation>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="$instanceType != ''">
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$instanceType"/></xsl:attribute>
          </rdf:type>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="instance008computerfiles">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:if test="substring($dataElements,6,1) = 'o' or substring($dataElements,6,1) = 'q'">
      <xsl:call-template name="carrier008">
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="code" select="substring($dataElements,6,1)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" name="instance008maps">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:variable name="projection">
      <xsl:choose>
        <xsl:when test="substring($dataElements,5,2) = 'aa'">Aitoff</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'ab'">Gnomic</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'ac'">Lambert's azimuthal equal area</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'ad'">Orthographic</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'ae'">Azimuthal equidistant</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'af'">Stereographic</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'ag'">General vertical near-sided</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'am'">Modified stereographic for Alaska</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'an'">Chamberlin trimetric</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'ap'">polar stereographic</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'au'">Azimuthal, specific type unknown</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'az'">Azimuthal, other</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'ba'">Gali</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bb'">Goode's homiographic</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bc'">Lambert's cylindrical equal area</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bd'">Mercator</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'be'">Miller</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bf'">Mollweide</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bg'">Sinusoidal</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bh'">Transverse Mercator</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bi'">Gauss-Kruger</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bj'">Equirectangular</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bk'">Krovak</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bl'">Cassini-Soldner</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bo'">Oblique Mercator</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'br'">Robinson</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bs'">Space oblique Mercator</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bu'">Cylindrical, specific type unknown</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'bz'">Cylindrical, other</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'ca'">Alber's equal area</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'cb'">Bonne</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'cc'">Lambert's conformal conic</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'ce'">Equidistant conic</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'cp'">Polyconic</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'cu'">Conic, specific type unknown</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'cz'">Conic, other</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'da'">Armadillo</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'db'">Butterfly</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'dc'">Eckert</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'dd'">Goode's homolosine</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'de'">Miller's bipolar oblique conformal conic</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'df'">Van Der Grinten</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'dg'">Dimaxion</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'dh'">Cordiform</xsl:when>
        <xsl:when test="substring($dataElements,5,2) = 'dl'">Lambert conformal</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="cartographicAttributes008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="relief" select="substring($dataElements,1,4)"/>
    </xsl:call-template>
    <xsl:call-template name="supplementaryContent008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,14,1)"/>
    </xsl:call-template>
    <xsl:for-each select="document('')/*/local:carttype/*[name() = substring($dataElements,8,1)]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <xsl:if test="@prop = 'genreForm'">
            <bf:genreForm>
              <bf:GenreForm>
                <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
                <rdfs:label><xsl:value-of select="."/></rdfs:label>
              </bf:GenreForm>
            </bf:genreForm>
          </xsl:if>
          <xsl:if test="@prop = 'issuance'">
            <bf:issuance>
              <bf:Issuance>
                <rdfs:label><xsl:value-of select="."/></rdfs:label>
              </bf:Issuance>
            </bf:issuance>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:call-template name="carrier008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,12,1)"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$projection != ''">
          <bf:projection>
            <bf:Cartographic>
              <bf:code><xsl:value-of select="substring($dataElements,5,2)"/></bf:code>
              <rdfs:label><xsl:value-of select="$projection"/></rdfs:label>
            </bf:Cartographic>
          </bf:projection>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="instance008music">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:call-template name="carrier008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,6,1)"/>
    </xsl:call-template>
  </xsl:template><xsl:template xmlns:local="local:" name="instance008cr">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:variable name="regularity">
      <xsl:choose>
        <xsl:when test="substring($dataElements,2,1) = 'n'">normalized irregular</xsl:when>
        <xsl:when test="substring($dataElements,2,1) = 'r'">regular</xsl:when>
        <xsl:when test="substring($dataElements,2,1) = 'x'">completely irregular</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="document('')/*/local:frequency/*[name() = substring($dataElements,1,1)]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:frequency>
            <bf:Frequency>
              <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:Frequency>
          </bf:frequency>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="document('')/*/local:crtype/*[name() = substring($dataElements,4,1)]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:genreForm>
            <bf:GenreForm>
              <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="document('')/*/local:carrier/*[name() = substring($dataElements,5,1)]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:note>
            <bf:Note>
              <xsl:if test="@href">
                <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
              </xsl:if>
              <bf:noteType>form of original item</bf:noteType>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:Note>
          </bf:note>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:call-template name="carrier008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,6,1)"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$regularity != ''">
          <bf:frequency>
            <bf:Frequency>
              <rdfs:label><xsl:value-of select="$regularity"/></rdfs:label>
            </bf:Frequency>
          </bf:frequency>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="instance008visual">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:variable name="technique">
      <xsl:choose>
        <xsl:when test="substring($dataElements,17,1) = 'a'">animation</xsl:when>
        <xsl:when test="substring($dataElements,17,1) = 'c'">animation and live action</xsl:when>
        <xsl:when test="substring($dataElements,17,1) = 'l'">live action</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="carrier008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,12,1)"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$technique != ''">
          <bf:note>
            <bf:Note>
              <bf:noteType>technique</bf:noteType>
              <rdfs:label><xsl:value-of select="$technique"/></rdfs:label>
            </bf:Note>
          </bf:note>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="instance008mixed">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="dataElements"/>
    <xsl:call-template name="carrier008">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="code" select="substring($dataElements,6,1)"/>
    </xsl:call-template>
  </xsl:template><xsl:template xmlns:local="local:" name="illustrativeContent008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="illustrations"/>
    <xsl:param name="i" select="1"/>
    <xsl:if test="$i &lt; 5">
      <xsl:for-each select="document('')/*/local:millus/*[name() = substring($illustrations,$i,1)]">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <bf:illustrativeContent>
              <bf:Illustration>
                <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
                <rdfs:label><xsl:value-of select="."/></rdfs:label>
              </bf:Illustration>
            </bf:illustrativeContent>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      <xsl:call-template name="illustrativeContent008">
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="illustrations" select="$illustrations"/>
        <xsl:with-param name="i" select="$i + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" name="carrier008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="code"/>
    <xsl:for-each select="document('')/*/local:carrier/*[name() = $code]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:carrier>
            <bf:Carrier>
              <xsl:if test="@href">
                <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
              </xsl:if>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:Carrier>
          </bf:carrier>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template><xsl:template xmlns:local="local:" name="cartographicAttributes008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="relief"/>
    <xsl:param name="i" select="1"/>
    <xsl:if test="$i &lt; 5">
      <xsl:variable name="note">
        <xsl:choose>
          <xsl:when test="substring($relief,$i,1) = 'a'">contours</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'b'">shading</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'c'">gradient and bathymetric tints</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'd'">hachures</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'e'">bathymetry/soundings</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'f'">form lines</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'g'">spot heights</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'i'">pictorially</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'j'">land forms</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'k'">bathymetry/isolines</xsl:when>
          <xsl:when test="substring($relief,$i,1) = 'm'">rock drawings</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$note != ''">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <bf:cartographicAttributes>
              <bf:Cartographic>
                <bf:note>
                  <bf:Note>
                    <bf:noteType>relief</bf:noteType>
                    <rdfs:label><xsl:value-of select="$note"/></rdfs:label>
                  </bf:Note>
                </bf:note>
              </bf:Cartographic>
            </bf:cartographicAttributes>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:call-template name="cartographicAttributes008">
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="relief" select="$relief"/>
        <xsl:with-param name="i" select="$i + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" name="supplementaryContent008">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="code"/>
    <xsl:if test="$code = '1'">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:supplementaryContent>
            <bf:SupplementaryContent>
              <rdfs:label>Index present</rdfs:label>
            </bf:SupplementaryContent>
          </bf:supplementaryContent>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  <local:marctimeperiod xmlns:local="local:">
    <a0>-XXXX/-3000</a0>
    <b0>-29XX</b0>
    <b1>-28XX</b1>
    <b2>-27XX</b2>
    <b3>-26XX</b3>
    <b4>-25XX</b4>
    <b5>-24XX</b5>
    <b6>-23XX</b6>
    <b7>-22XX</b7>
    <b8>-21XX</b8>
    <b9>-20XX</b9>
    <c0>-19XX</c0>
    <c1>-18XX</c1>
    <c2>-17XX</c2>
    <c3>-16XX</c3>
    <c4>-15XX</c4>
    <c5>-14XX</c5>
    <c6>-13XX</c6>
    <c7>-12XX</c7>
    <c8>-11XX</c8>
    <c9>-10XX</c9>
    <d0>-09XX</d0>
    <d1>-08XX</d1>
    <d2>-07XX</d2>
    <d3>-06XX</d3>
    <d4>-05XX</d4>
    <d5>-04XX</d5>
    <d6>-03XX</d6>
    <d7>-02XX</d7>
    <d8>-01XX</d8>
    <d9>-00XX</d9>
    <e>00</e>
    <f>01</f>
    <g>02</g>
    <h>03</h>
    <i>04</i>
    <j>05</j>
    <k>06</k>
    <l>07</l>
    <m>08</m>
    <n>09</n>
    <o>10</o>
    <p>11</p>
    <q>12</q>
    <r>13</r>
    <s>14</s>
    <t>15</t>
    <u>16</u>
    <v>17</v>
    <w>18</w>
    <x>19</x>
    <y>20</y>
  </local:marctimeperiod><local:instrumentCode xmlns:local="local:">
    <ba property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass</bf:instrumentType><rdfs:label>horn</rdfs:label></ba>
    <bb property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass</bf:instrumentType><rdfs:label>trumpet</rdfs:label></bb>
    <bc property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass</bf:instrumentType><rdfs:label>coronet</rdfs:label></bc>
    <bd property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass</bf:instrumentType><rdfs:label>trombone</rdfs:label></bd>
    <be property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass</bf:instrumentType><rdfs:label>tuba</rdfs:label></be>
    <bf property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass</bf:instrumentType><rdfs:label>baritone</rdfs:label></bf>
    <bn property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass</bf:instrumentType></bn>
    <bu property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass</bf:instrumentType></bu>
    <by property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass, ethnic</bf:instrumentType></by>
    <bz property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>brass</bf:instrumentType></bz>
    <ea property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>electronic</bf:instrumentType><rdfs:label>electronic synthesizer</rdfs:label></ea>
    <eb property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>electronic</bf:instrumentType><rdfs:label>electronic tape</rdfs:label></eb>
    <ec property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>electronic</bf:instrumentType><rdfs:label>computer</rdfs:label></ec>
    <ed property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>electronic</bf:instrumentType><rdfs:label>ondes martinot</rdfs:label></ed>
    <en property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>electronic</bf:instrumentType></en>
    <eu property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>electronic</bf:instrumentType></eu>
    <ez property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>electronic</bf:instrumentType></ez>
    <ka property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard</bf:instrumentType><rdfs:label>piano</rdfs:label></ka>
    <kb property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard</bf:instrumentType><rdfs:label>organ</rdfs:label></kb>
    <kc property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard</bf:instrumentType><rdfs:label>harpsichord</rdfs:label></kc>
    <kd property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard</bf:instrumentType><rdfs:label>clavichord</rdfs:label></kd>
    <ke property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard</bf:instrumentType><rdfs:label>continuo</rdfs:label></ke>
    <kf property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard</bf:instrumentType><rdfs:label>celeste</rdfs:label></kf>
    <kn property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard</bf:instrumentType></kn>
    <ku property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard</bf:instrumentType></ku>
    <ky property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard, ethnic</bf:instrumentType></ky>
    <kz property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>keyboard</bf:instrumentType></kz>
    <pa property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>percussion</bf:instrumentType><rdfs:label>timpani</rdfs:label></pa>
    <pb property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>percussion</bf:instrumentType><rdfs:label>xylophone</rdfs:label></pb>
    <pc property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>percussion</bf:instrumentType><rdfs:label>marimba</rdfs:label></pc>
    <pd property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>percussion</bf:instrumentType><rdfs:label>drum</rdfs:label></pd>
    <pn property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>percussion</bf:instrumentType></pn>
    <pu property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>percussion</bf:instrumentType></pu>
    <py property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>percussion, ethnic</bf:instrumentType></py>
    <pz property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>percussion</bf:instrumentType></pz>
    <sa property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType><rdfs:label>violin</rdfs:label></sa>
    <sb property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType><rdfs:label>viola</rdfs:label></sb>
    <sc property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType><rdfs:label>violoncello</rdfs:label></sc>
    <sd property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType><rdfs:label>double bass</rdfs:label></sd>
    <se property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType><rdfs:label>viol</rdfs:label></se>
    <sf property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType><rdfs:label>viola d'amore</rdfs:label></sf>
    <sg property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType><rdfs:label>viola da gamba</rdfs:label></sg>
    <sn property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType></sn>
    <su property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType></su>
    <sy property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed, ethnic</bf:instrumentType></sy>
    <sz property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, bowed</bf:instrumentType></sz>
    <ta property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, plucked</bf:instrumentType><rdfs:label>harp</rdfs:label></ta>
    <tb property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, plucked</bf:instrumentType><rdfs:label>guitar</rdfs:label></tb>
    <tc property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, plucked</bf:instrumentType><rdfs:label>lute</rdfs:label></tc>
    <td property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, plucked</bf:instrumentType><rdfs:label>mandolin</rdfs:label></td>
    <tn property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, plucked</bf:instrumentType></tn>
    <tu property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, plucked</bf:instrumentType></tu>
    <ty property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, plucked, ethnic</bf:instrumentType></ty>
    <tz property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>string, plucked</bf:instrumentType></tz>
    <wa property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType><rdfs:label>flute</rdfs:label></wa>
    <wb property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType><rdfs:label>oboe</rdfs:label></wb>
    <wc property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType><rdfs:label>clarinet</rdfs:label></wc>
    <wd property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType><rdfs:label>bassoon</rdfs:label></wd>
    <we property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType><rdfs:label>piccolo</rdfs:label></we>
    <wf property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType><rdfs:label>English horn</rdfs:label></wf>
    <wg property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType><rdfs:label>bass clarinet</rdfs:label></wg>
    <wh property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType><rdfs:label>recorder</rdfs:label></wh>
    <wi property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType><rdfs:label>saxophone</rdfs:label></wi>
    <wn property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType></wn>
    <wu property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType></wu>
    <wy property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind, ethnic</bf:instrumentType></wy>
    <wz property="bf:instrument" entity="bf:MusicInstrument"><bf:instrumentType>woodwind</bf:instrumentType></wz>
    <oa property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental</bf:ensembleType><rdfs:label>orchestra</rdfs:label></oa>
    <ob property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental</bf:ensembleType><rdfs:label>chamber orchestra</rdfs:label></ob>
    <oc property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental</bf:ensembleType><rdfs:label>string orchestra</rdfs:label></oc>
    <od property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental</bf:ensembleType><rdfs:label>band</rdfs:label></od>
    <oe property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental</bf:ensembleType><rdfs:label>dance orchestra</rdfs:label></oe>
    <of property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental</bf:ensembleType><rdfs:label>brass band</rdfs:label></of>
    <on property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental</bf:ensembleType></on>
    <ou property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental</bf:ensembleType></ou>
    <oy property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental, ethnic</bf:ensembleType></oy>
    <oz property="bf:ensemble" entity="bf:MusicEnsemble"><bf:ensembleType>instrumental</bf:ensembleType></oz>
    <ca property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>chorus</bf:voiceType><rdfs:label>mixed chorus</rdfs:label></ca>
    <cb property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>chorus</bf:voiceType><rdfs:label>female chorus</rdfs:label></cb>
    <cc property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>chorus</bf:voiceType><rdfs:label>male chorus</rdfs:label></cc>
    <cd property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>chorus</bf:voiceType><rdfs:label>children chorus</rdfs:label></cd>
    <cn property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>chorus</bf:voiceType></cn>
    <cu property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>chorus</bf:voiceType></cu>
    <cy property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>chorus, ethnic</bf:voiceType></cy>
    <va property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>soprano</rdfs:label></va>
    <vb property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>mezzo soprano</rdfs:label></vb>
    <vc property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>alto</rdfs:label></vc>
    <vd property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>tenor</rdfs:label></vd>
    <ve property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>baritone</rdfs:label></ve>
    <vf property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>bass</rdfs:label></vf>
    <vg property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>counter tenor</rdfs:label></vg>
    <vh property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>high voice</rdfs:label></vh>
    <vi property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>medium voice</rdfs:label></vi>
    <vj property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType><rdfs:label>low voice</rdfs:label></vj>
    <vn property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType></vn>
    <vu property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice</bf:voiceType></vu>
    <vy property="bf:voice" entity="bf:MusicVoice"><bf:voiceType>voice, ethnic</bf:voiceType></vy>
  </local:instrumentCode><xsl:template xmlns:local="local:" match="marc:datafield[@tag='038']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bflc:metadataLicensor>
            <rdfs:label><xsl:value-of select="."/></rdfs:label>
          </bflc:metadataLicensor>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='040']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='c']">
          <bf:source>
            <bf:Source>
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Agent')"/></xsl:attribute>
              </rdf:type>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:Source>
          </bf:source>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='b']">
          <bf:descriptionLanguage>
            <bf:Language>
              <xsl:choose>
                <xsl:when test="string-length(.) = 3">
                  <xsl:attribute name="rdf:about"><xsl:value-of select="concat($languages,.)"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <bf:code><xsl:value-of select="."/></bf:code>
                </xsl:otherwise>
              </xsl:choose>
            </bf:Language>
          </bf:descriptionLanguage>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='d']">
          <bf:descriptionModifier>
            <bf:Agent>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:Agent>
          </bf:descriptionModifier>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='e']">
          <bf:descriptionConventions>
            <bf:DescriptionConventions>
              <xsl:choose>
                <xsl:when test="string-length(normalize-space(.))                   -                   string-length(translate(normalize-space(.),' ','')) +1                   = 1">
                <xsl:attribute name="rdf:about"><xsl:value-of select="concat($descriptionConventions,.)"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                </xsl:otherwise>
              </xsl:choose>
            </bf:DescriptionConventions>
          </bf:descriptionConventions>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='042']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:descriptionAuthentication>
            <bf:DescriptionAuthentication>
              <xsl:attribute name="rdf:about"><xsl:value-of select="concat($marcauthen,.)"/></xsl:attribute>
            </bf:DescriptionAuthentication>
          </bf:descriptionAuthentication>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='022']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='l'] | marc:subfield[@code='m']">
          <bf:identifiedBy>
            <bf:IssnL>
              <rdf:value><xsl:value-of select="."/></rdf:value>
              <xsl:if test="@code = 'm'">
                <bf:status>
                  <bf:Status>
                    <rdfs:label>canceled</rdfs:label>
                  </bf:Status>
                </bf:status>
              </xsl:if>
              <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:IssnL>
          </bf:identifiedBy>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='033']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vDate">
      <xsl:choose>
        <xsl:when test="@ind1 = '0'">
          <xsl:call-template name="edtfFormat">
            <xsl:with-param name="pDateString" select="marc:subfield[@code='a']"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@ind1 = '2'">
          <xsl:variable name="vConcatDate">
            <xsl:for-each select="marc:subfield[@code='a']">
              <xsl:variable name="vFormattedDate">
                <xsl:call-template name="edtfFormat">
                  <xsl:with-param name="pDateString" select="."/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:value-of select="concat('/',$vFormattedDate)"/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="substring-after($vConcatDate,'/')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vNote">
      <xsl:choose>
        <xsl:when test="@ind2 = '1'">broadcast</xsl:when>
        <xsl:when test="@ind2 = '2'">finding</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:capture>
          <bf:Capture>
            <xsl:if test="$vNote != ''">
              <bf:note>
                <bf:Note>
                  <rdfs:label><xsl:value-of select="$vNote"/></rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:if>
            <xsl:if test="$vDate != ''">
              <bf:date>
                <xsl:attribute name="rdf:datatype"><xsl:value-of select="$edtf"/>edtf</xsl:attribute>
                <xsl:value-of select="$vDate"/>
              </bf:date>
            </xsl:if>
            <xsl:if test="@ind1 = '1'">
              <xsl:for-each select="marc:subfield[@code='a']">
                <bf:date>
                  <xsl:attribute name="rdf:datatype"><xsl:value-of select="$edtf"/>edtf</xsl:attribute>
                  <xsl:call-template name="edtfFormat">
                    <xsl:with-param name="pDateString" select="."/>
                  </xsl:call-template>
                </bf:date>
              </xsl:for-each>
            </xsl:if>
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:place>
                <bf:Place>
                  <rdf:value><xsl:value-of select="normalize-space(concat(.,' ',following-sibling::*[position()=1][@code='c']))"/></rdf:value>
                  <bf:source>
                    <bf:Source>
                      <rdfs:label>lcc-g</rdfs:label>
                    </bf:Source>
                  </bf:source>
                </bf:Place>
              </bf:place>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='p']">
              <bf:place>
                <bf:Place>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                  <xsl:apply-templates mode="subfield2" select="following-sibling::*[position()=1][@code='2']">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </bf:Place>
              </bf:place>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='3']">
              <xsl:apply-templates mode="subfield3" select=".">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:for-each>
          </bf:Capture>
        </bf:capture>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='034']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vCoordinates">
      <xsl:apply-templates select="marc:subfield[@code='d' or @code='e' or @code='f' or @code='g']" mode="concat-nodes-space"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$vCoordinates != ''">
          <bf:cartographicAttributes>
            <bf:Cartographic>
              <bf:coordinates><xsl:value-of select="normalize-space($vCoordinates)"/></bf:coordinates>
              <xsl:for-each select="marc:subfield[@code='3']">
                <xsl:apply-templates select="." mode="subfield3">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </xsl:for-each>
            </bf:Cartographic>
          </bf:cartographicAttributes>
        </xsl:if>
        <xsl:for-each select="marc:subfield[@code='a']">
          <xsl:if test="text() = 'a' and not(../marc:subfield[@code='b' or @code='c'])">
            <bf:scale>
              <bf:Scale>
                <bf:note>
                  <bf:Note>
                    <rdfs:label>linear scale</rdfs:label>
                  </bf:Note>
                </bf:note>
              </bf:Scale>
            </bf:scale>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='b']">
          <xsl:apply-templates mode="work034scale" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="pScaleType">linear horizontal</xsl:with-param>
          </xsl:apply-templates>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='c']">
          <xsl:apply-templates mode="work034scale" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="pScaleType">linear vertical</xsl:with-param>
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:subfield" mode="work034scale">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pScaleType"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:scale>
          <bf:Scale>
            <rdfs:label><xsl:value-of select="."/></rdfs:label>
            <bf:note>
              <bf:Note>
                <rdfs:label><xsl:value-of select="$pScaleType"/></rdfs:label>
              </bf:Note>
            </bf:note>
            <xsl:for-each select="../marc:subfield[@code='3']">
              <xsl:apply-templates select="." mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:for-each>
          </bf:Scale>
        </bf:scale>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='041']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vSource">
      <xsl:choose>
        <xsl:when test="@ind2 = ' '">marc</xsl:when>
        <xsl:when test="@ind2 = '7'"><xsl:value-of select="marc:subfield[@code='2']"/></xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="@ind1 = '1'">
          <bf:note>
            <bf:Note>
              <rdfs:label>Includes translation</rdfs:label>
            </bf:Note>
          </bf:note>
        </xsl:if>
        <xsl:for-each select="marc:subfield[@code = 'a'] |                               marc:subfield[@code = 'b'] |                               marc:subfield[@code = 'd'] |                               marc:subfield[@code = 'e'] |                               marc:subfield[@code = 'f'] |                               marc:subfield[@code = 'g'] |                               marc:subfield[@code = 'h'] |                               marc:subfield[@code = 'j'] |                               marc:subfield[@code = 'k'] |                               marc:subfield[@code = 'm'] |                               marc:subfield[@code = 'n']">
          <xsl:variable name="vPart">
            <xsl:choose>
              <xsl:when test="@code = 'b'">summary</xsl:when>
              <xsl:when test="@code = 'd'">sung or spoken text</xsl:when>
              <xsl:when test="@code = 'e'">libretto</xsl:when>
              <xsl:when test="@code = 'f'">table of contents</xsl:when>
              <xsl:when test="@code = 'g'">accompanying material</xsl:when>
              <xsl:when test="@code = 'h'">original</xsl:when>
              <xsl:when test="@code = 'j'">subtitles or captions</xsl:when>
              <xsl:when test="@code = 'k'">intermediate translations</xsl:when>
              <xsl:when test="@code = 'm'">original accompanying materials</xsl:when>
              <xsl:when test="@code = 'n'">original libretto</xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <!-- marc language codes can be stacked in the subfield -->
            <xsl:when test="$vSource = 'marc'">
              <xsl:call-template name="parse041">
                <xsl:with-param name="pLang" select="."/>
                <xsl:with-param name="pPart" select="$vPart"/>
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <bf:language>
                <bf:Language>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                  <xsl:if test="$vPart != ''">
                    <bf:part><xsl:value-of select="$vPart"/></bf:part>
                  </xsl:if>
                  <xsl:if test="$vSource != ''">
                    <bf:source>
                      <bf:Source>
                        <xsl:choose>
                          <xsl:when test="$vSource = 'iso639-1'">
                            <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/iso639-1</xsl:attribute>
                          </xsl:when>
                          <xsl:otherwise>
                            <rdfs:label><xsl:value-of select="$vSource"/></rdfs:label>
                          </xsl:otherwise>
                        </xsl:choose>
                      </bf:Source>
                    </bf:source>
                  </xsl:if>
                </bf:Language>
              </bf:language>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="parse041">
    <xsl:param name="pLang"/>
    <xsl:param name="pPart"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pStart" select="1"/>
    <xsl:if test="string-length(substring($pLang,$pStart,3)) = 3">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:language>
            <bf:Language>
              <xsl:attribute name="rdf:about"><xsl:value-of select="concat($languages,substring($pLang,$pStart,3))"/></xsl:attribute>
              <xsl:if test="$pPart != ''">
                <bf:part><xsl:value-of select="$pPart"/></bf:part>
              </xsl:if>
              <bf:source>
                <bf:Source>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/languages</xsl:attribute>
                </bf:Source>
              </bf:source>
            </bf:Language>
          </bf:language>
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="parse041">
        <xsl:with-param name="pLang" select="$pLang"/>
        <xsl:with-param name="pPart" select="$pPart"/>
        <xsl:with-param name="serialization" select="$serialization"/>
        <xsl:with-param name="pStart" select="$pStart + 3"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='043']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c']">
          <bf:geographicCoverage>
            <bf:GeographicCoverage>
              <xsl:choose>
                <xsl:when test="@code='a'">
                  <xsl:variable name="vCode">
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                      <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:attribute name="rdf:about"><xsl:value-of select="concat($geographicAreas,$vCode)"/></xsl:attribute>
                </xsl:when>
                <xsl:when test="@code='b' or @code='c'">
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                  <xsl:choose>
                    <xsl:when test="@code='c'">
                      <bf:source>
                        <bf:Source>
                          <rdfs:label>ISO 3166</rdfs:label>
                        </bf:Source>
                      </bf:source>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="following-sibling::*[position()=1 or position()=2][@code='2']" mode="subfield2">
                        <xsl:with-param name="serialization" select="$serialization"/>
                      </xsl:apply-templates>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </bf:GeographicCoverage>
          </bf:geographicCoverage>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='045']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:temporalCoverage>
            <xsl:attribute name="rdf:datatype"><xsl:value-of select="$edtf"/>edtf</xsl:attribute>
            <xsl:call-template name="work045aDate">
              <xsl:with-param name="pDate" select="."/>
            </xsl:call-template>
          </bf:temporalCoverage>
        </xsl:for-each>
        <xsl:choose>
          <xsl:when test="@ind1 = '2'">
            <xsl:variable name="vDate1">
              <xsl:call-template name="work045bDate">
                <xsl:with-param name="pDate" select="marc:subfield[@code='b'][1]"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="vDate2">
              <xsl:call-template name="work045bDate">
                <xsl:with-param name="pDate" select="marc:subfield[@code='b'][2]"/>
              </xsl:call-template>
            </xsl:variable>
            <bf:temporalCoverage>
              <xsl:attribute name="rdf:datatype"><xsl:value-of select="$edtf"/>edtf</xsl:attribute>
              <xsl:value-of select="concat($vDate1,'/',$vDate2)"/>
            </bf:temporalCoverage>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:temporalCoverage>
                <xsl:attribute name="rdf:datatype"><xsl:value-of select="$edtf"/>edtf</xsl:attribute>
                <xsl:call-template name="work045bDate">
                  <xsl:with-param name="pDate" select="."/>
                </xsl:call-template>
              </bf:temporalCoverage>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="work045aDate">
    <xsl:param name="pDate"/>
    <xsl:variable name="vDate1">
      <xsl:choose>
        <xsl:when test="substring($pDate,1,1) = 'a'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,1,2)]"/></xsl:when>
        <xsl:when test="substring($pDate,1,1) = 'b'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,1,2)]"/></xsl:when>
        <xsl:when test="substring($pDate,1,1) = 'c'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,1,2)]"/></xsl:when>
        <xsl:when test="substring($pDate,1,1) = 'd'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,1,2)]"/></xsl:when>
        <xsl:when test="substring($pDate,1,1) = 'e'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,1,2)]"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat(document('')/*/local:marctimeperiod/*[name() = substring($pDate,1,1)],substring($pDate,2,1),'X')"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vDate2">
      <xsl:choose>
        <xsl:when test="substring($pDate,3,1) = 'a'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,3,2)]"/></xsl:when>
        <xsl:when test="substring($pDate,3,1) = 'b'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,3,2)]"/></xsl:when>
        <xsl:when test="substring($pDate,3,1) = 'c'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,3,2)]"/></xsl:when>
        <xsl:when test="substring($pDate,3,1) = 'd'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,3,2)]"/></xsl:when>
        <xsl:when test="substring($pDate,3,1) = 'e'"><xsl:value-of select="document('')/*/local:marctimeperiod/*[name() = substring($pDate,3,2)]"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat(document('')/*/local:marctimeperiod/*[name() = substring($pDate,3,1)],substring($pDate,4,1),'X')"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$vDate1 = $vDate2"><xsl:value-of select="$vDate1"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="concat($vDate1,'/',$vDate2)"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" name="work045bDate">
    <xsl:param name="pDate"/>
    <xsl:variable name="vYear">
      <xsl:choose>
        <xsl:when test="substring($pDate,1,1) = 'c'"><xsl:value-of select="concat('-',substring($pDate,2,4))"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="substring($pDate,2,4)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vMonth" select="substring($pDate,6,2)"/>
    <xsl:variable name="vDay" select="substring($pDate,8,2)"/>
    <xsl:variable name="vHour" select="substring($pDate,10,2)"/>
    <xsl:choose>
      <xsl:when test="$vHour != ''"><xsl:value-of select="concat($vYear,'-',$vMonth,'-',$vDay,'T',$vHour)"/></xsl:when>
      <xsl:when test="$vDay != ''"><xsl:value-of select="concat($vYear,'-',$vMonth,'-',$vDay)"/></xsl:when>
      <xsl:when test="$vMonth != ''"><xsl:value-of select="concat($vYear,'-',$vMonth)"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$vYear"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='047']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:genreForm>
            <bf:GenreForm>
              <xsl:choose>
                <xsl:when test="../@ind2 = ' '">
                  <xsl:attribute name="rdf:about"><xsl:value-of select="concat($marcmuscomp,.)"/></xsl:attribute>
                  <bf:source>
                    <bf:Source>
                      <rdfs:label>marcmuscomp</rdfs:label>
                    </bf:Source>
                  </bf:source>
                </xsl:when>
                <xsl:otherwise>
                  <bf:code><xsl:value-of select="."/></bf:code>
                  <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='048']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <!-- only attempt to code if ind2 = ' ' -->
    <xsl:if test="@ind2 = ' '">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <xsl:for-each select="marc:subfield[@code='a' or @code='b']">
            <xsl:if test="document('')/*/local:instrumentCode/*[name() = substring(.,1,2)]">
              <xsl:variable name="vCode" select="substring(.,1,2)"/>
              <xsl:variable name="vCount" select="substring(.,3,2)"/>
              <xsl:element name="{document('')/*/local:instrumentCode/*[name() = $vCode]/@property}">
                <xsl:element name="{document('')/*/local:instrumentCode/*[name() = $vCode]/@entity}">
                  <xsl:for-each select="document('')/*/local:instrumentCode/*[name() = $vCode]/*">
                    <xsl:element name="{name()}"><xsl:value-of select="."/></xsl:element>
                  </xsl:for-each>
                  <xsl:if test="$vCount != ''">
                    <bf:count><xsl:value-of select="number($vCount)"/></bf:count>
                  </xsl:if>
                </xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template><xsl:template xmlns:local="local:" mode="instance" match="marc:datafield[@tag='010'] |                                        marc:datafield[@tag='015'] |                                        marc:datafield[@tag='016'] |                                        marc:datafield[@tag='017'] |                                        marc:datafield[@tag='020'] |                                        marc:datafield[@tag='022'] |                                        marc:datafield[@tag='024'] |                                        marc:datafield[@tag='025'] |                                        marc:datafield[@tag='027'] |                                        marc:datafield[@tag='028'] |                                        marc:datafield[@tag='030'] |                                        marc:datafield[@tag='032'] |                                        marc:datafield[@tag='035'] |                                        marc:datafield[@tag='036'] |                                        marc:datafield[@tag='074'] |                                        marc:datafield[@tag='088']">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="@tag='010'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Lccn</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='015'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Nbn</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='016'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Nban</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='017'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:CopyrightNumber</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='020'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Isbn</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
          <xsl:with-param name="pChopPunct" select="true()"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='022'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Issn</xsl:with-param>
          <xsl:with-param name="pIncorrectLabel">incorrect</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">canceled</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='024'">
        <xsl:variable name="vIdentifier">
          <xsl:choose>
            <xsl:when test="@ind1 = '0'">bf:Isrc</xsl:when>
            <xsl:when test="@ind1 = '1'">bf:Upc</xsl:when>
            <xsl:when test="@ind1 = '2'">bf:Ismn</xsl:when>
            <xsl:when test="@ind1 = '3'">bf:Ean</xsl:when>
            <xsl:when test="@ind1 = '4'">bf:Sici</xsl:when>
            <xsl:otherwise>bf:Identifier</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier"><xsl:value-of select="$vIdentifier"/></xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='025'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:LcOverseasAcq</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='027'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Strn</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='028'">
        <xsl:variable name="vIdentifier">
          <xsl:choose>
            <xsl:when test="@ind1 = '0'">bf:AudioIssueNumber</xsl:when>
            <xsl:when test="@ind1 = '1'">bf:MatrixNumber</xsl:when>
            <xsl:when test="@ind1 = '2'">bf:MusicPlate</xsl:when>
            <xsl:when test="@ind1 = '3'">bf:MusicPublisherNumber</xsl:when>
            <xsl:when test="@ind1 = '4'">bf:VideoRecordingNumber</xsl:when>
            <xsl:otherwise>bf:PublisherNumber</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier"><xsl:value-of select="$vIdentifier"/></xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='030'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Coden</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='032'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:PostalRegistration</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='035'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Local</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='036'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:StudyNumber</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='074'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Identifier</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='088'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:ReportNumber</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield" mode="instanceId">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pIdentifier" select="'bf:Identifier'"/>
    <xsl:param name="pIncorrectLabel" select="'incorrect'"/>
    <xsl:param name="pInvalidLabel" select="'invalid'"/>
    <xsl:param name="pChopPunct" select="false()"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='y' or @code='z']">
          <xsl:variable name="vId">
            <xsl:choose>
              <!-- for 035, extract value after parentheses -->
              <xsl:when test="../@tag='035' and contains(.,')')"><xsl:value-of select="substring-after(.,')')"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <bf:identifiedBy>
            <xsl:element name="{$pIdentifier}">
              <rdf:value>
                <xsl:choose>
                  <xsl:when test="$pChopPunct">
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString"><xsl:value-of select="$vId"/></xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$vId"/>
                  </xsl:otherwise>
                </xsl:choose>
              </rdf:value>
              <xsl:if test="@code = 'z'">
                <bf:status>
                  <bf:Status>
                    <rdfs:label><xsl:value-of select="$pInvalidLabel"/></rdfs:label>
                  </bf:Status>
                </bf:status>
              </xsl:if>
              <xsl:if test="@code = 'y'">
                <bf:status>
                  <bf:Status>
                    <rdfs:label><xsl:value-of select="$pIncorrectLabel"/></rdfs:label>
                  </bf:Status>
                </bf:status>
              </xsl:if>
              <xsl:for-each select="../marc:subfield[@code='c']">
                <bf:acquisitionTerms>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString"><xsl:value-of select="."/></xsl:with-param>
                    <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                  </xsl:call-template>
                </bf:acquisitionTerms>
              </xsl:for-each>
              <xsl:for-each select="../marc:subfield[@code='q']">
                <bf:qualifier>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString"><xsl:value-of select="."/></xsl:with-param>
                    <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                  </xsl:call-template>
                </bf:qualifier>
              </xsl:for-each>
              <!-- special handling for 017 -->
              <xsl:if test="../@tag='017'">
                <xsl:variable name="date"><xsl:value-of select="../marc:subfield[@code='d'][1]"/></xsl:variable>
                <xsl:variable name="dateformatted"><xsl:value-of select="concat(substring($date,1,4),'-',substring($date,5,2),'-',substring($date,7,2))"/></xsl:variable>
                <xsl:if test="$date != ''">
                  <bf:date>
                    <xsl:attribute name="rdf:datatype"><xsl:value-of select="$xs"/>date</xsl:attribute>
                    <xsl:value-of select="$dateformatted"/>
                  </bf:date>
                </xsl:if>
                <xsl:for-each select="../marc:subfield[@code='i']">
                  <bf:note>
                    <bf:Note>
                      <rdfs:label>
                        <xsl:call-template name="chopPunctuation">
                          <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                          <xsl:with-param name="chopString">
                            <xsl:value-of select="."/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </rdfs:label>
                    </bf:Note>
                  </bf:note>
                </xsl:for-each>
              </xsl:if>
              <!-- special handling for 024 -->
              <xsl:if test="../@tag='024'">
                <xsl:if test="@code = 'a'">
                  <xsl:for-each select="../marc:subfield[@code='d']">
                    <bf:note>
                      <bf:Note>
                        <bf:noteType>additional codes</bf:noteType>
                        <rdfs:label><xsl:value-of select="."/></rdfs:label>
                      </bf:Note>
                    </bf:note>
                  </xsl:for-each>
                </xsl:if>
              </xsl:if>
              <!-- special handling for source ($2) -->
              <xsl:choose>
                <xsl:when test="../@tag='016'">
                  <xsl:choose>
                    <xsl:when test="../@ind1 = ' '">
                      <bf:source>
                        <bf:Source>
                          <rdfs:label>Library and Archives Canada</rdfs:label>
                        </bf:Source>
                      </bf:source>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                        <xsl:with-param name="serialization" select="$serialization"/>
                      </xsl:apply-templates>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="../@tag='017' or ../@tag='028' or ../@tag='032' or ../@tag='036'">
                  <xsl:for-each select="../marc:subfield[@code='b']">
                    <bf:source>
                      <bf:Source>
                        <rdfs:label>
                          <xsl:call-template name="chopPunctuation">
                            <xsl:with-param name="chopString">
                              <xsl:value-of select="."/>
                            </xsl:with-param>
                          </xsl:call-template>
                        </rdfs:label>
                      </bf:Source>
                    </bf:source>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="../@tag='024'">
                  <xsl:if test="../@ind1='7'">
                    <xsl:for-each select="../marc:subfield[@code='2']">
                      <rdfs:label><xsl:value-of select="."/></rdfs:label>
                    </xsl:for-each>
                  </xsl:if>
                </xsl:when>
                <xsl:when test="../@tag='035'">
                  <xsl:variable name="vSource" select="substring-before(substring-after(.,'('),')')"/>
                  <xsl:if test="$vSource != ''">
                    <bf:source>
                      <bf:Source>
                        <rdfs:label><xsl:value-of select="$vSource"/></rdfs:label>
                      </bf:Source>
                    </bf:source>
                  </xsl:if>
                </xsl:when>
                <xsl:when test="../@tag='074'">
                  <bf:source>
                    <bf:Source>
                      <rdfs:label>US GPO</rdfs:label>
                    </bf:Source>
                  </bf:source>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
          </bf:identifiedBy>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='026']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="parsed">
      <xsl:apply-templates select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d']" mode="concat-nodes-space"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:identifiedBy>
          <bf:Fingerprint>
            <xsl:choose>
              <xsl:when test="$parsed != ''">
                <rdf:value><xsl:value-of select="normalize-space($parsed)"/></rdf:value>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="marc:subfield[@code='e']">
                  <rdf:value><xsl:value-of select="."/></rdf:value>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="marc:subfield[@code='2']">
              <xsl:apply-templates select="." mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='5']">
              <xsl:apply-templates select="." mode="subfield5">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:for-each>
          </bf:Fingerprint>
        </bf:identifiedBy>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='037']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vAcqSource">
      <xsl:choose>
        <xsl:when test="@ind1 = '2'">intervening source</xsl:when>
        <xsl:when test="@ind1 = '3'">current source</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:acquisitionSource>
          <bf:AcquisitionSource>
            <xsl:if test="$vAcqSource != ''">
              <bf:note>
                <bf:Note>
                  <rdfs:label><xsl:value-of select="$vAcqSource"/></rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:if>
            <xsl:for-each select="marc:subfield[@code='3']">
              <xsl:apply-templates select="." mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='a']">
              <bf:identifiedBy>
                <bf:StockNumber>
                  <rdf:value><xsl:value-of select="."/></rdf:value>
                </bf:StockNumber>
              </bf:identifiedBy>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='b']">
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='c']">
              <bf:acquisitionTerms><xsl:value-of select="."/></bf:acquisitionTerms>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='f']">
              <bf:note>
                <bf:Note>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='g' or @code='n']">
              <bf:note>
                <bf:Note>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='5']">
              <xsl:apply-templates select="." mode="subfield5">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:for-each>
          </bf:AcquisitionSource>
        </bf:acquisitionSource>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template xmlns:local="local:" match="marc:datafield[@tag='044']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c']">
          <bf:place>
            <bf:Place>
              <xsl:choose>
                <xsl:when test="@code='a'">
                  <xsl:attribute name="rdf:about"><xsl:value-of select="concat($countries,.)"/></xsl:attribute>
                </xsl:when>
                <xsl:when test="@code='b' or @code='c'">
                  <bf:code><xsl:value-of select="."/></bf:code>
                  <xsl:choose>
                    <xsl:when test="@code='c'">
                      <bf:source>
                        <bf:Source>
                          <rdfs:label>ISO 3166</rdfs:label>
                        </bf:Source>
                      </bf:source>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="following-sibling::*[position()=1 or position()=2][@code='2']" mode="subfield2">
                        <xsl:with-param name="serialization" select="$serialization"/>
                      </xsl:apply-templates>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </bf:Place>
          </bf:place>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='050']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work050" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='050' or @tag='880']" mode="work050">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:classification>
            <bf:ClassificationLcc>
              <xsl:if test="../@ind2 = '0'">
                <bf:source>
                  <bf:Source>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="concat($organizations,'dlc')"/></xsl:attribute>
                  </bf:Source>
                </bf:source>
              </xsl:if>
              <bf:classificationPortion>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </bf:classificationPortion>
              <xsl:if test="position() = 1">
                <xsl:for-each select="../marc:subfield[@code='b'][position()=1]">
                  <bf:itemPortion>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </bf:itemPortion>
                </xsl:for-each>
              </xsl:if>
            </bf:ClassificationLcc>
          </bf:classification>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='052']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work052" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='052' or @tag='880']" mode="work052">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='b']">
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:geographicCoverage>
                <bf:Place>
                  <xsl:apply-templates mode="place052" select="..">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="pBpos" select="position()"/>
                  </xsl:apply-templates>
                </bf:Place>
              </bf:geographicCoverage>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <bf:geographicCoverage>
              <bf:Place>
                <xsl:apply-templates mode="place052" select=".">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </bf:Place>
            </bf:geographicCoverage>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='052' or @tag='880']" mode="place052">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pBpos"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vPlaceValue">
      <xsl:choose>
        <xsl:when test="$pBpos != ''"><xsl:value-of select="concat(marc:subfield[@code='a'],' ',marc:subfield[@code='b'][position()=$pBpos])"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="marc:subfield[@code='a']"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <rdf:value><xsl:value-of select="$vPlaceValue"/></rdf:value>
        <xsl:for-each select="marc:subfield[@code='d']">
          <rdfs:label>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
          </rdfs:label>
        </xsl:for-each>
        <xsl:if test="@ind1 = ' '">
          <bf:source>
            <bf:Source>
              <xsl:attribute name="rdf:about"><xsl:value-of select="concat($classSchemes,'lcc')"/></xsl:attribute>
            </bf:Source>
          </bf:source>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='055']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work055" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='055' or @tag='880']" mode="work055">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
          <bf:classification>
            <bf:ClassificationLcc>
              <xsl:for-each select="marc:subfield[@code='a']">
                <bf:classificationPortion>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="."/>
                </bf:classificationPortion>
              </xsl:for-each>
              <xsl:for-each select="marc:subfield[@code='b']">
                <bf:itemPortion>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="."/>
                </bf:itemPortion>
              </xsl:for-each>
              <xsl:if test="@ind2 = '0' or @ind2 = '1' or @ind2 = '2'">
                <bf:source>
                  <bf:Source>
                    <rdfs:label>Library and Archives Canada</rdfs:label>
                  </bf:Source>
                </bf:source>
              </xsl:if>
            </bf:ClassificationLcc>
          </bf:classification>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='060']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:classification>
          <bf:ClassificationNlm>
            <xsl:for-each select="marc:subfield[@code='a']">
              <bf:classificationPortion><xsl:value-of select="."/></bf:classificationPortion>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:itemPortion><xsl:value-of select="."/></bf:itemPortion>
            </xsl:for-each>
            <xsl:if test="@ind2 = '0'">
              <bf:source>
                <bf:Source>
                  <rdfs:label>National Library of Medicine</rdfs:label>
                </bf:Source>
              </bf:source>
            </xsl:if>
          </bf:ClassificationNlm>
        </bf:classification>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='070']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:classification>
          <bf:Classification>
            <xsl:for-each select="marc:subfield[@code='a']">
              <bf:classificationPortion><xsl:value-of select="."/></bf:classificationPortion>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:itemPortion><xsl:value-of select="."/></bf:itemPortion>
            </xsl:for-each>
            <bf:source>
              <bf:Source>
                <rdfs:label>National Agricultural Library</rdfs:label>
              </bf:Source>
            </bf:source>
          </bf:Classification>
        </bf:classification>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='072']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work072" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='072' or @tag='880']" mode="work072">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vSubjectValue">
      <xsl:apply-templates select="marc:subfield[@code='a' or @code='x']" mode="concat-nodes-space"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:subject>
          <rdfs:Resource>
            <rdf:value>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="normalize-space($vSubjectValue)"/>
            </rdf:value>
            <xsl:choose>
              <xsl:when test="@ind2 = '0'">
                <bf:source>
                  <bf:Source>
                    <rdfs:label>agricola</rdfs:label>
                  </bf:Source>
                </bf:source>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="marc:subfield[@code='2']" mode="subfield2">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </rdfs:Resource>
        </bf:subject>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='084']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work084" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='084' or @tag='880']" mode="work084">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:classification>
            <bf:Classification>
              <bf:classificationPortion>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </bf:classificationPortion>
              <xsl:if test="position() = 1">
                <xsl:for-each select="../marc:subfield[@code='b']">
                  <bf:itemPortion>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </bf:itemPortion>
                </xsl:for-each>
              </xsl:if>
              <xsl:if test="../marc:subfield[@code='q']">
                <bf:adminMetadata>
                  <bf:AdminMetadata>
                    <xsl:for-each select="../marc:subfield[@code='q']">
                      <bf:assigner>
                        <bf:Agent>
                          <rdfs:label>
                            <xsl:if test="$vXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="."/>
                          </rdfs:label>
                        </bf:Agent>
                      </bf:assigner>
                    </xsl:for-each>
                  </bf:AdminMetadata>
                </bf:adminMetadata>
              </xsl:if>
              <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                <xsl:with-param name="serialization" select="'rdfxml'"/>
              </xsl:apply-templates>
            </bf:Classification>
          </bf:classification>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='082']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work082" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='082' or @tag='880']" mode="work082">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:classification>
            <bf:ClassificationDdc>
              <bf:classificationPortion>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </bf:classificationPortion>
              <xsl:if test="position() = 1">
                <xsl:for-each select="../marc:subfield[@code='b']">
                  <bf:itemPortion>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </bf:itemPortion>
                </xsl:for-each>
              </xsl:if>
              <xsl:for-each select="../marc:subfield[@code='2']">
                <bf:edition>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="."/>
                </bf:edition>
              </xsl:for-each>
              <xsl:choose>
                <xsl:when test="../@ind1 = '0'"><bf:edition>full</bf:edition></xsl:when>
                <xsl:when test="../@ind1 = '1'"><bf:edition>abridged</bf:edition></xsl:when>
              </xsl:choose>
              <xsl:apply-templates select="../marc:subfield[@code='q']" mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:if test="../@ind2 = '0'">
                <bf:source>
                  <bf:Source>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="concat($organizations,'dlc')"/></xsl:attribute>
                  </bf:Source>
                </bf:source>
              </xsl:if>
            </bf:ClassificationDdc>
          </bf:classification>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='086']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance086">
      <xsl:with-param name="serialization" select="'rdfxml'"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='086' or @tag='880']" mode="instance086">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='z']">
          <bf:classification>
            <bf:Classification>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
              <xsl:if test="@code='z'">
                <bf:status>
                  <bf:Status>
                    <rdfs:label>invalid</rdfs:label>
                  </bf:Status>
                </bf:status>
              </xsl:if>
              <xsl:choose>
                <xsl:when test="../@ind1='0'">
                  <bf:source>
                    <bf:Source>
                      <rdfs:label>sudocs</rdfs:label>
                    </bf:Source>
                  </bf:source>
                </xsl:when>
                <xsl:when test="../@ind1='1'">
                  <bf:source>
                    <bf:Source>
                      <rdfs:label>Government of Canada Publications</rdfs:label>
                    </bf:Source>
                  </bf:source>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="../marc:subfield[@code='2']">
                    <bf:source>
                      <bf:Source>
                        <rdfs:label>
                          <xsl:if test="$vXmlLang != ''">
                            <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                          </xsl:if>
                          <xsl:value-of select="."/>
                        </rdfs:label>
                      </bf:Source>
                    </bf:source>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </bf:Classification>
          </bf:classification>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='050' or @tag='060']" mode="hasItem">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vItemUri"><xsl:value-of select="$recordid"/>#Item<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:hasItem>
          <xsl:apply-templates select="." mode="newItem">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="recordid" select="$recordid"/>
            <xsl:with-param name="pItemUri" select="$vItemUri"/>
          </xsl:apply-templates>
        </bf:hasItem>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='050']" mode="newItem">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pItemUri"/>
    <xsl:variable name="vShelfMark">
      <xsl:choose>
        <xsl:when test="marc:subfield[@code='b']">
          <xsl:choose>
            <xsl:when test="substring(marc:subfield[@code='b'],1,1) = '.'"><xsl:value-of select="normalize-space(concat(marc:subfield[@code='a'][1],marc:subfield[@code='b'][1]))"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="normalize-space(concat(marc:subfield[@code='a'][1],' ',marc:subfield[@code='b']))"/></xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="normalize-space(marc:subfield[@code='a'][1])"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Item>
          <xsl:attribute name="rdf:about"><xsl:value-of select="$pItemUri"/></xsl:attribute>
          <bf:shelfMark>
            <bf:ShelfMarkLcc>
              <rdfs:label><xsl:value-of select="$vShelfMark"/></rdfs:label>
              <xsl:if test="@ind2 = '0'">
                <bf:source>
                  <bf:Source>
                    <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/organizations/dlc</xsl:attribute>
                  </bf:Source>
                </bf:source>
              </xsl:if>
            </bf:ShelfMarkLcc>
          </bf:shelfMark>
          <xsl:for-each select="../marc:datafield[@tag='051']">
            <xsl:variable name="vClassLabel">
              <xsl:choose>
                <xsl:when test="marc:subfield[@code='b']">
                  <xsl:choose>
                    <xsl:when test="substring(marc:subfield[@code='b'],1,1) = '.'"><xsl:value-of select="normalize-space(concat(marc:subfield[@code='a'],marc:subfield[@code='b'],' ',marc:subfield[@code='c']))"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="normalize-space(concat(marc:subfield[@code='a'],' ',marc:subfield[@code='b'],' ',marc:subfield[@code='c']))"/></xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="normalize-space(concat(marc:subfield[@code='a'],' ',marc:subfield[@code='c']))"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <bf:shelfMark>
              <bf:ShelfMarkLcc>
                <rdfs:label>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString"><xsl:value-of select="$vClassLabel"/></xsl:with-param>
                  </xsl:call-template>
                </rdfs:label>
              </bf:ShelfMarkLcc>
            </bf:shelfMark>
          </xsl:for-each>
          <bf:itemOf>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
          </bf:itemOf>
        </bf:Item>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='060']" mode="newItem">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pItemUri"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="@ind1='0'">
          <bf:Item>
            <xsl:attribute name="rdf:about"><xsl:value-of select="$pItemUri"/></xsl:attribute>
            <bf:heldBy>
              <bf:Agent>
                <rdfs:label>National Library of Medicine</rdfs:label>
              </bf:Agent>
            </bf:heldBy>
          </bf:Item>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='100' or @tag='110' or @tag='111']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="workName" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='600' or @tag='610' or @tag='611']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work6XXName" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="recordid" select="$recordid"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work6XXName">
    <xsl:param name="agentiri"/>
    <xsl:param name="workiri"/>
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vSourceCode"><xsl:value-of select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/code"/></xsl:variable>
    <xsl:variable name="vMADSClass">
      <xsl:choose>
        <xsl:when test="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">ComplexSubject</xsl:when>
        <xsl:when test="marc:subfield[@code='t']">NameTitle</xsl:when>
        <xsl:when test="$vTag='600'">Name</xsl:when>
        <xsl:when test="$vTag='610'">CorporateName</xsl:when>
        <xsl:when test="$vTag='611'">ConferenceName</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vNameLabel">
      <xsl:apply-templates select="." mode="tNameLabel"/>
    </xsl:variable>
    <xsl:variable name="vTitleLabel">
      <xsl:apply-templates select="." mode="tTitleLabel"/>
    </xsl:variable>
    <xsl:variable name="vMADSLabel">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
        <xsl:with-param name="chopString">
          <xsl:call-template name="chopPunctuation">
            <xsl:with-param name="chopString" select="normalize-space(concat($vNameLabel,' ',$vTitleLabel))"/>
            <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
          </xsl:call-template>
          <xsl:text>--</xsl:text>
          <xsl:for-each select="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
            <xsl:value-of select="concat(.,'--')"/>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:variable name="vSource">
          <xsl:choose>
            <xsl:when test="$vSourceCode != ''">
              <bf:source>
                <bf:Source>
                  <bf:code><xsl:value-of select="$vSourceCode"/></bf:code>
                </bf:Source>
              </bf:source>
            </xsl:when>
            <xsl:when test="@ind2='7'">
              <bf:source>
                <bf:Source>
                  <bf:code><xsl:value-of select="marc:subfield[@code='2']"/></bf:code>
                </bf:Source>
              </bf:source>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <bf:subject>
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='t']">
              <bf:Work>
                <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
                <rdf:type>
                  <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($madsrdf,$vMADSClass)"/></xsl:attribute>
                </rdf:type>
                <madsrdf:authoritativeLabel>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="$vMADSLabel"/>
                </madsrdf:authoritativeLabel>
                <xsl:for-each select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/madsscheme">
                  <madsrdf:isMemberofMADSScheme>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
                  </madsrdf:isMemberofMADSScheme>
                </xsl:for-each>                  
                <xsl:if test="$vSource != ''">
                  <xsl:copy-of select="$vSource"/>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="substring($vTag,2,2)='11'">
                    <xsl:apply-templates select="marc:subfield[@code='j']" mode="contributionRole">
                      <xsl:with-param name="serialization" select="$serialization"/>
                      <xsl:with-param name="pMode">relationship</xsl:with-param>
                      <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
                    </xsl:apply-templates>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="marc:subfield[@code='e']" mode="contributionRole">
                      <xsl:with-param name="serialization" select="$serialization"/>
                      <xsl:with-param name="pMode">relationship</xsl:with-param>
                      <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
                    </xsl:apply-templates>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:for-each select="marc:subfield[@code='4']">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,substring(.,1,3))"/></xsl:attribute>
                        </rdfs:Resource>
                      </bflc:relation>
                      <bf:relatedTo>
                        <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
                      </bf:relatedTo>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:for-each>
                <xsl:apply-templates select="." mode="workName">
                  <xsl:with-param name="recordid" select="$recordid"/>
                  <xsl:with-param name="agentiri" select="$agentiri"/>
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </bf:Work>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="agent">
                <xsl:with-param name="agentiri" select="$agentiri"/>
                <xsl:with-param name="serialization" select="$serialization"/>
                <xsl:with-param name="pMADSClass" select="$vMADSClass"/>
                <xsl:with-param name="pSource" select="$vSource"/>
                <xsl:with-param name="recordid" select="$recordid"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </bf:subject>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='700' or @tag='710' or @tag='711' or @tag='720']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work7XX" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work7XX">
    <xsl:param name="agentiri"/>
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="marc:subfield[@code='t']">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:choose>
              <xsl:when test="@ind2='2'">
                <bf:hasPart>
                  <bf:Work>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
                    <xsl:apply-templates mode="workName" select=".">
                      <xsl:with-param name="agentiri" select="$agentiri"/>
                      <xsl:with-param name="serialization" select="$serialization"/>
                    </xsl:apply-templates>
                  </bf:Work>
                </bf:hasPart>
              </xsl:when>
              <xsl:otherwise>
                <bf:relatedTo>
                  <bf:Work>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
                    <xsl:apply-templates mode="workName" select=".">
                      <xsl:with-param name="agentiri" select="$agentiri"/>
                      <xsl:with-param name="serialization" select="$serialization"/>
                    </xsl:apply-templates>
                  </bf:Work>
                </bf:relatedTo>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="marc:subfield[@code='i']">
              <bflc:relationship>
                <bflc:Relationship>
                  <bflc:relation>
                    <rdfs:Resource>
                      <rdfs:label>
                        <xsl:if test="$vXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="chopPunctuation">
                          <xsl:with-param name="chopString">
                            <xsl:value-of select="."/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </rdfs:label>
                    </rdfs:Resource>
                  </bflc:relation>
                  <bf:relatedTo>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$workiri"/></xsl:attribute>
                  </bf:relatedTo>
                </bflc:Relationship>
              </bflc:relationship>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="workName" select=".">
          <xsl:with-param name="agentiri" select="$agentiri"/>
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
        <xsl:for-each select="marc:subfield[@code='i']">
          <bflc:relationship>
            <bflc:Relationship>
              <bflc:relation>
                <rdfs:Resource>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </rdfs:Resource>
              </bflc:relation>
              <bf:relatedTo><xsl:value-of select="$agentiri"/></bf:relatedTo>
            </bflc:Relationship>
          </bflc:relationship>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='800' or @tag='810' or @tag='811' or @tag='400' or @tag='410' or @tag='411']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work8XX" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work8XX">
    <xsl:param name="agentiri"/>
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:hasSeries>
          <bf:Work>
            <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
            <xsl:apply-templates mode="workName" select=".">
              <xsl:with-param name="agentiri" select="$agentiri"/>
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Work>
        </bf:hasSeries>
        <xsl:for-each select="marc:subfield[@code='v']">
          <bf:seriesEnumeration>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:seriesEnumeration>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield" mode="workName">
    <xsl:param name="agentiri"/>
    <xsl:param name="recordid"/>
    <xsl:param name="serialization"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rolesFromSubfields">
      <xsl:choose>
        <xsl:when test="substring($tag,2,2)='11'">
          <xsl:apply-templates select="marc:subfield[@code='j']" mode="contributionRole">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="marc:subfield[@code='e']" mode="contributionRole">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="marc:subfield[@code='4']" mode="contributionRoleCode">
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:contribution>
          <bf:Contribution>
            <xsl:if test="substring($tag,1,1) = '1'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bflc,'PrimaryContribution')"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <bf:agent>
              <xsl:apply-templates mode="agent" select=".">
                <xsl:with-param name="agentiri" select="$agentiri"/>
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:agent>
            <xsl:choose>
              <xsl:when test="substring($tag,1,1)='6'">
                <bf:role>
                  <bf:Role>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,'ctb')"/></xsl:attribute>
                  </bf:Role>
                </bf:role>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="(substring($tag,3,1) = '0' and marc:subfield[@code='e']) or                                   (substring($tag,3,1) = '1' and marc:subfield[@code='j']) or                                   marc:subfield[@code='4']">
                    <xsl:copy-of select="$rolesFromSubfields"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <bf:role>
                      <bf:Role>
                        <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,'ctb')"/></xsl:attribute>
                      </bf:Role>
                    </bf:role>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </bf:Contribution>
        </bf:contribution>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="marc:subfield[@code='t']">
      <xsl:apply-templates mode="workUnifTitle" select=".">
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template><xsl:template match="marc:subfield[@code='4']" mode="contributionRoleCode">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:role>
          <bf:Role>
            <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,substring(.,1,3))"/></xsl:attribute>
          </bf:Role>
        </bf:role>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:subfield" mode="contributionRole">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pMode" select="'role'"/>
    <xsl:param name="pRelatedTo"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="parent::*" mode="xmllang"/></xsl:variable>
    <xsl:call-template name="splitRole">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="roleString" select="."/>
      <xsl:with-param name="pMode" select="$pMode"/>
      <xsl:with-param name="pRelatedTo" select="$pRelatedTo"/>
      <xsl:with-param name="pXmlLang" select="$vXmlLang"/>
    </xsl:call-template>
  </xsl:template><xsl:template name="splitRole">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="roleString"/>
    <xsl:param name="pMode" select="'role'"/>
    <xsl:param name="pRelatedTo"/>
    <xsl:param name="pXmlLang"/>
    <xsl:choose>
      <xsl:when test="contains($roleString,',')">
        <xsl:if test="string-length(normalize-space(substring-before($roleString,','))) &gt; 0">
          <xsl:variable name="vRole"><xsl:value-of select="normalize-space(substring-before($roleString,','))"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$serialization='rdfxml'">
              <xsl:choose>
                <xsl:when test="$pMode='role'">
                  <bf:role>
                    <bf:Role>
                      <rdfs:label>
                        <xsl:if test="$pXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="$vRole"/>
                      </rdfs:label>
                    </bf:Role>
                  </bf:role>
                </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$vRole"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="splitRole">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="roleString" select="substring-after($roleString,',')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($roleString,' and')">
        <xsl:if test="string-length(normalize-space(substring-before($roleString,' and'))) &gt; 0">
          <xsl:variable name="vRole"><xsl:value-of select="normalize-space(substring-before($roleString,' and'))"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$serialization='rdfxml'">
              <xsl:choose>
                <xsl:when test="$pMode='role'">
                  <bf:role>
                    <bf:Role>
                      <rdfs:label>
                        <xsl:if test="$pXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(substring-before($roleString,' and'))"/>
                      </rdfs:label>
                    </bf:Role>
                  </bf:role>
                </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$vRole"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="splitRole">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="roleString" select="substring-after($roleString,' and')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($roleString,'&amp;')">
        <xsl:if test="string-length(normalize-space(substring-before($roleString,'&amp;'))) &gt; 0">
          <xsl:variable name="vRole"><xsl:value-of select="normalize-space(substring-before($roleString,'&amp;'))"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$serialization='rdfxml'">
              <xsl:choose>
                <xsl:when test="$pMode='role'">
                  <bf:role>
                    <bf:Role>
                      <rdfs:label>
                        <xsl:if test="$pXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(substring-before($roleString,'&amp;'))"/>
                      </rdfs:label>
                    </bf:Role>
                  </bf:role>
                </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$vRole"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="splitRole">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="roleString" select="substring-after($roleString,'&amp;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$serialization='rdfxml'">
            <xsl:choose>
              <xsl:when test="$pMode='role'">
                <bf:role>
                  <bf:Role>
                    <rdfs:label>
                      <xsl:if test="$pXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="normalize-space($roleString)"/>
                    </rdfs:label>
                  </bf:Role>
                </bf:role>
              </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="normalize-space($roleString)"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield" mode="agent">
    <xsl:param name="agentiri"/>
    <xsl:param name="pMADSClass"/>
    <xsl:param name="pSource"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="tNameLabel"/>
    </xsl:variable>
    <xsl:variable name="vMADSLabel">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
        <xsl:with-param name="chopString">
          <xsl:if test="$label != ''">
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="$label"/>
              <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
            </xsl:call-template>
            <xsl:text>--</xsl:text>
          </xsl:if>
          <xsl:for-each select="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
            <xsl:value-of select="concat(.,'--')"/>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="marckey">
      <xsl:apply-templates mode="marcKey"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:Agent>
          <xsl:attribute name="rdf:about"><xsl:value-of select="$agentiri"/></xsl:attribute>
          <rdf:type>
            <xsl:choose>
              <xsl:when test="$tag='720'">
                <xsl:if test="@ind1='1'">
                  <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>Person</xsl:attribute>
                </xsl:if>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='00'">
                <xsl:choose>
                  <xsl:when test="@ind1='3'">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>Family</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>Person</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='10'">
                <xsl:choose>
                  <xsl:when test="@ind1='1'">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Jurisdiction')"/></xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Organization')"/></xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='11'">
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Meeting')"/></xsl:attribute>
              </xsl:when>
            </xsl:choose>
          </rdf:type>
          <xsl:if test="substring($tag,1,1)='6'">
            <xsl:if test="$pMADSClass != ''">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($madsrdf,$pMADSClass)"/></xsl:attribute>
              </rdf:type>
              <xsl:if test="$vMADSLabel != ''">
                <madsrdf:authoritativeLabel>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="$vMADSLabel"/>
                </madsrdf:authoritativeLabel>
              </xsl:if>
              <xsl:for-each select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/madsscheme">
                <madsrdf:isMemberofMADSScheme>
                  <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
                </madsrdf:isMemberofMADSScheme>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="$pSource != ''">
              <xsl:copy-of select="$pSource"/>
            </xsl:if>
            <xsl:if test="not(marc:subfield[@code='t'])">
              <xsl:choose>
                <xsl:when test="substring($tag,2,2)='11'">
                  <xsl:apply-templates select="marc:subfield[@code='j']" mode="contributionRole">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="pMode">relationship</xsl:with-param>
                    <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
                  </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="marc:subfield[@code='e']" mode="contributionRole">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="pMode">relationship</xsl:with-param>
                    <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:for-each select="marc:subfield[@code='4']">
                <bflc:relationship>
                  <bflc:Relationship>
                    <bflc:relation>
                      <rdfs:Resource>
                        <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,substring(.,1,3))"/></xsl:attribute>
                      </rdfs:Resource>
                    </bflc:relation>
                    <bf:relatedTo>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
                    </bf:relatedTo>
                  </bflc:Relationship>
                </bflc:relationship>
              </xsl:for-each>
            </xsl:if>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="substring($tag,2,2)='00'">
              <xsl:if test="$label != ''">
                <bflc:name00MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:name00MatchKey>
                <xsl:if test="substring($tag,1,1) = '1'">
                  <bflc:primaryContributorName00MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:primaryContributorName00MatchKey>
                </xsl:if>
              </xsl:if>
              <bflc:name00MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:name00MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='10'">
              <xsl:if test="$label != ''">
                <bflc:name10MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:name10MatchKey>
              </xsl:if>
              <bflc:name10MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:name10MarcKey>
                <xsl:if test="substring($tag,1,1) = '1'">
                  <bflc:primaryContributorName10MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:primaryContributorName10MatchKey>
                </xsl:if>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='11'">
              <xsl:if test="$label != ''">
                <bflc:name11MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:name11MatchKey>
              </xsl:if>
              <bflc:name11MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:name11MarcKey>
                <xsl:if test="substring($tag,1,1) = '1'">
                  <bflc:primaryContributorName11MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:primaryContributorName11MatchKey>
                </xsl:if>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="normalize-space($label)"/>
            </rdfs:label>
          </xsl:if>
          <xsl:if test="not(marc:subfield[@code='t'])">
            <xsl:apply-templates mode="subfield0orw" select="marc:subfield[@code='0']">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="subfield3" select="marc:subfield[@code='3']">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="subfield5" select="marc:subfield[@code='5']">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </xsl:if>
        </bf:Agent>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield" mode="tNameLabel">
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$tag='720'"><xsl:value-of select="marc:subfield[@code='a']"/></xsl:when>
      <xsl:when test="substring($tag,2,2)='00'">
        <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                      @code='b' or                                       @code='c' or                                      @code='d' or                                      @code='j' or                                      @code='q']"/>
      </xsl:when>
      <xsl:when test="substring($tag,2,2)='10'">
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='t']">
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[@code='a' or                                          @code='b' or                                           @code='c' or                                          @code='d' or                                          @code='n' or                                          @code='g']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                          @code='b' or                                           @code='c' or                                          @code='d' or                                          @code='n' or                                          @code='g']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="substring($tag,2,2)='11'">
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='t']">
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[@code='a' or                                          @code='c' or                                          @code='d' or                                          @code='e' or                                          @code='n' or                                          @code='g' or                                          @code='q']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                          @code='c' or                                          @code='d' or                                          @code='e' or                                          @code='n' or                                          @code='g' or                                          @code='q']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='210']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="instance210" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='210' or @tag='880']" mode="instance210">
    <xsl:param name="serialization"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:title>
          <xsl:apply-templates mode="title210" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='210' or @tag='880']" mode="title210">
    <xsl:param name="serialization"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>VariantTitle</xsl:attribute>
          </rdf:type>
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>AbbreviatedTitle</xsl:attribute>
          </rdf:type>
          <xsl:if test="@ind2 = ' '">
            <bf:source>
              <bf:Source>
                <rdf:value>issnkey</rdf:value>
              </bf:Source>
            </bf:source>
          </xsl:if>
          <xsl:variable name="label">
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='b']"/>
          </xsl:variable>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="substring($label,1,string-length($label)-1)"/>
            </rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="substring($label,1,string-length($label)-1)"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:for-each select="marc:subfield[@code='a']">
            <bf:mainTitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="."/>
            </bf:mainTitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='b']">
            <bf:qualifier>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopParens">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
                <xsl:with-param name="punctuation">
                  <xsl:text>:,;/ </xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </bf:qualifier>
          </xsl:for-each>
          <xsl:apply-templates select="marc:subfield[@code='2']" mode="subfield2">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='222']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="instance222" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='222' or @tag='880']" mode="instance222">
    <xsl:param name="serialization"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:title>
          <xsl:apply-templates mode="title222" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='222' or @tag='880']" mode="title222">
    <xsl:param name="serialization"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>VariantTitle</xsl:attribute>
          </rdf:type>
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>KeyTitle</xsl:attribute>
          </rdf:type>
          <xsl:variable name="label">
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='b']"/>
          </xsl:variable>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="substring($label,1,string-length($label)-1)"/>
            </rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="substring($label,@ind2+1,(string-length($label)-@ind2)-1)"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:for-each select="marc:subfield[@code='a']">
            <bf:mainTitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:mainTitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='b']">
            <bf:qualifier>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopParens">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:qualifier>
          </xsl:for-each>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='242']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="instance242" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='242' or @tag='880']" mode="instance242">
    <xsl:param name="serialization"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:title>
          <xsl:apply-templates mode="title242" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='242' or @tag='880']" mode="title242">
    <xsl:param name="serialization"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>VariantTitle</xsl:attribute>
          </rdf:type>
          <bf:variantType>translated</bf:variantType>
          <xsl:variable name="label">
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                                                    @code='b' or                                                                    @code='c' or                                                                    @code='h' or                                                                    @code='n' or                                                                    @code='p']"/>
          </xsl:variable>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="substring($label,1,string-length($label)-1)"/>
            </rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="substring($label,@ind2+1,(string-length($label)-@ind2)-1)"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:for-each select="marc:subfield[@code='a']">
            <bf:mainTitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:mainTitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='b']">
            <bf:subtitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:subtitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='n']">
            <bf:partNumber>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partNumber>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='p']">
            <bf:partName>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partName>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='y']">
            <bf:language>
              <bf:Language>
                <xsl:attribute name="rdf:resource">http://id.loc.gov/vocabulary/languages/<xsl:value-of select="."/></xsl:attribute>
              </bf:Language>
            </bf:language>
          </xsl:for-each>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='243']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work243" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='243' or @tag='880']" mode="work243">
    <xsl:param name="serialization"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:title>
          <xsl:apply-templates mode="title243" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='243' or @tag='880']" mode="title243">
    <xsl:param name="serialization"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>VariantTitle</xsl:attribute>
          </rdf:type>
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>CollectiveTitle</xsl:attribute>
          </rdf:type>
          <xsl:variable name="label">
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                          @code='d' or                                          @code='f' or                                          @code='g' or                                          @code='k' or                                          @code='l' or                                          @code='m' or                                          @code='n' or                                          @code='o' or                                          @code='p' or                                          @code='r' or                                          @code='s']"/>
          </xsl:variable>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="substring($label,1,string-length($label)-1)"/>
            </rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="substring($label,@ind2+1,(string-length($label)-@ind2)-1)"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:for-each select="marc:subfield[@code='a']">
            <bf:mainTitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:mainTitle>
          </xsl:for-each>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='245']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:if test="not(../marc:datafield[@tag='130']) and not(../marc:datafield[@tag='240'])">
      <xsl:variable name="label">
        <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                      @code='b' or                                      @code='f' or                                       @code='g' or                                      @code='k' or                                      @code='n' or                                      @code='p' or                                      @code='s']"/>
      </xsl:variable>
      <xsl:apply-templates mode="work245" select=".">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template><xsl:template match="marc:datafield[@tag='245' or @tag='880']" mode="work245">
    <xsl:param name="label"/>
    <xsl:param name="serialization"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$label != '' and @tag='245'">
          <rdfs:label>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="normalize-space($label)"/>
          </rdfs:label>
        </xsl:if>
        <bf:title>
          <xsl:apply-templates mode="title245" select=".">
            <xsl:with-param name="label" select="$label"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
        <xsl:for-each select="marc:subfield[@code='f' or @code='g']">
          <bf:originDate>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:originDate>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='h']">
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopBrackets">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='s']">
          <bf:version>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:version>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='245']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="label">
      <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                    @code='b' or                                    @code='f' or                                     @code='g' or                                    @code='k' or                                    @code='n' or                                    @code='p' or                                    @code='s']"/>
    </xsl:variable>
    <xsl:apply-templates mode="instance245" select=".">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='245' or @tag='880']" mode="instance245">
    <xsl:param name="label"/>
    <xsl:param name="serialization"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$label != '' and @tag='245'">
          <rdfs:label>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="normalize-space($label)"/>
          </rdfs:label>
        </xsl:if>
        <bf:title>
          <xsl:apply-templates mode="title245" select=".">
            <xsl:with-param name="label" select="$label"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
        <xsl:for-each select="marc:subfield[@code='c']">
          <bf:responsibilityStatement>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:responsibilityStatement>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='h']">
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopBrackets">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='245' or @tag='880']" mode="title245">
    <xsl:param name="label"/>
    <xsl:param name="serialization"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="substring($label,1,string-length($label)-1)"/>
            </rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="substring($label,@ind2+1,(string-length($label)-@ind2)-1)"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:for-each select="marc:subfield[@code='a']">
            <bf:mainTitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:mainTitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='b']">
            <bf:subtitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:subtitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='n']">
            <bf:partNumber>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partNumber>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='p']">
            <bf:partName>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partName>
          </xsl:for-each>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='246']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="instance246" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='246' or @tag='880']" mode="instance246">
    <xsl:param name="serialization"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:title>
          <xsl:apply-templates mode="title246" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='246' or @tag='880']" mode="title246">
    <xsl:param name="serialization"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>VariantTitle</xsl:attribute>
          </rdf:type>
          <xsl:choose>
            <xsl:when test="@ind2 = '0'">
              <bf:variantType>portion</bf:variantType>
            </xsl:when>
            <xsl:when test="@ind2 = '1'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>ParallelTitle</xsl:attribute>
              </rdf:type>
            </xsl:when>
            <xsl:when test="@ind2 = '2'">
              <bf:variantType>distinctive</bf:variantType>
            </xsl:when>
            <xsl:when test="@ind2 = '4'">
              <bf:variantType>cover</bf:variantType>
            </xsl:when>
            <xsl:when test="@ind2 = '5'">
              <bf:variantType>added title page</bf:variantType>
            </xsl:when>
            <xsl:when test="@ind2 = '6'">
              <bf:variantType>caption</bf:variantType>
            </xsl:when>
            <xsl:when test="@ind2 = '7'">
              <bf:variantType>running</bf:variantType>
            </xsl:when>
            <xsl:when test="@ind2 = '8'">
              <bf:variantType>spine</bf:variantType>
            </xsl:when>
          </xsl:choose>
          <xsl:variable name="label">
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                          @code='b' or                                          @code='g' or                                          @code='n' or                                          @code='p']"/>
          </xsl:variable>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="substring($label,1,string-length($label)-1)"/>
            </rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="substring($label,1,string-length($label)-1)"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:for-each select="marc:subfield[@code='a']">
            <bf:mainTitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:mainTitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='b']">
            <bf:subtitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:subtitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='f']">
            <bf:date>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:date>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='n']">
            <bf:partNumber>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partNumber>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='p']">
            <bf:partName>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partName>
          </xsl:for-each>
          <xsl:apply-templates mode="subfield5" select="marc:subfield[@code='5']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='247']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="instance247" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='247' or @tag='880']" mode="instance247">
    <xsl:param name="serialization"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:title>
          <xsl:apply-templates mode="title247" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='247' or @tag='880']" mode="title247">
    <xsl:param name="serialization"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <rdf:type>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>VariantTitle</xsl:attribute>
          </rdf:type>
          <bf:variantType>former</bf:variantType>
          <xsl:variable name="label">
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                          @code='b' or                                          @code='g' or                                          @code='n' or                                          @code='p']"/>
          </xsl:variable>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="substring($label,1,string-length($label)-1)"/>
            </rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="substring($label,1,string-length($label)-1)"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:for-each select="marc:subfield[@code='a']">
            <bf:mainTitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:mainTitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='b']">
            <bf:subtitle>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:subtitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='f']">
            <bf:date>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:date>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='g']">
            <bf:qualifier>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:call-template name="chopParens">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
            </bf:qualifier>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='n']">
            <bf:partNumber>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partNumber>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='p']">
            <bf:partName>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partName>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='x']">
            <bf:identifiedBy>
              <bf:Issn>
                <rdf:value>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </rdf:value>
              </bf:Issn>
            </bf:identifiedBy>
          </xsl:for-each>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='130' or @tag='240']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="workUnifTitle" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='630']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work630-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work630" select=".">
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="recordid" select="$recordid"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work630">
    <xsl:param name="recordid"/>
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vSourceCode"><xsl:value-of select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/code"/></xsl:variable>
    <xsl:variable name="vMADSClass">
      <xsl:choose>
        <xsl:when test="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">ComplexSubject</xsl:when>
        <xsl:otherwise>Title</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vTitleLabel">
      <xsl:apply-templates select="." mode="tTitleLabel"/>
    </xsl:variable>
    <xsl:variable name="vMADSLabel">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
        <xsl:with-param name="chopString">
          <xsl:call-template name="chopPunctuation">
            <xsl:with-param name="chopString" select="$vTitleLabel"/>
            <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
          </xsl:call-template>
          <xsl:text>--</xsl:text>
          <xsl:for-each select="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
            <xsl:value-of select="concat(.,'--')"/>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:variable name="vSource">
          <xsl:choose>
            <xsl:when test="$vSourceCode != ''">
              <bf:source>
                <bf:Source>
                  <bf:code><xsl:value-of select="$vSourceCode"/></bf:code>
                </bf:Source>
              </bf:source>
            </xsl:when>
            <xsl:when test="@ind2='7'">
              <bf:source>
                <bf:Source>
                  <bf:code><xsl:value-of select="marc:subfield[@code='2']"/></bf:code>
                </bf:Source>
              </bf:source>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <bf:subject>
          <bf:Work>
            <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
            <rdf:type>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($madsrdf,$vMADSClass)"/></xsl:attribute>
            </rdf:type>
            <madsrdf:authoritativeLabel><xsl:value-of select="$vMADSLabel"/></madsrdf:authoritativeLabel>
            <xsl:for-each select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/madsscheme">
              <madsrdf:isMemberofMADSScheme>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
              </madsrdf:isMemberofMADSScheme>
            </xsl:for-each>                  
            <xsl:if test="$vSource != ''">
              <xsl:copy-of select="$vSource"/>
            </xsl:if>
            <xsl:apply-templates select="marc:subfield[@code='e']" mode="contributionRole">
              <xsl:with-param name="serialization" select="$serialization"/>
              <xsl:with-param name="pMode">relationship</xsl:with-param>
              <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
            </xsl:apply-templates>
            <xsl:for-each select="marc:subfield[@code='4']">
              <bflc:relationship>
                <bflc:Relationship>
                  <bflc:relation>
                    <rdfs:Resource>
                      <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,substring(.,1,3))"/></xsl:attribute>
                    </rdfs:Resource>
                  </bflc:relation>
                  <bf:relatedTo>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
                  </bf:relatedTo>
                </bflc:Relationship>
              </bflc:relationship>
            </xsl:for-each>
            <xsl:apply-templates select="." mode="workUnifTitle">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Work>
        </bf:subject>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='730' or @tag='740']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="workiri">
      <xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/>
    </xsl:variable>
    <xsl:apply-templates mode="work730" select=".">
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work730">
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:choose>
          <xsl:when test="@ind2='2'">
            <bf:hasPart>
              <bf:Work>
                <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
                <xsl:apply-templates select="." mode="workUnifTitle">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </bf:Work>
            </bf:hasPart>
          </xsl:when>
          <xsl:otherwise>
            <bf:relatedTo>
              <bf:Work>
                <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
                <xsl:apply-templates select="." mode="workUnifTitle">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </bf:Work>
            </bf:relatedTo>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="marc:subfield[@code='i']">
          <bflc:relationship>
            <bflc:Relationship>
              <bflc:relation>
                <rdfs:Resource>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </rdfs:Resource>
              </bflc:relation>
              <bf:relatedTo><xsl:value-of select="$workiri"/></bf:relatedTo>
            </bflc:Relationship>
          </bflc:relationship>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='830' or @tag='440']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work830" select=".">
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work830">
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:hasSeries>
          <bf:Work>
            <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
            <xsl:apply-templates mode="workUnifTitle" select=".">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Work>
        </bf:hasSeries>
        <xsl:for-each select="marc:subfield[@code='v']">
          <bf:seriesEnumeration>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:seriesEnumeration>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield" mode="workUnifTitle">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="tTitleLabel"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$label != ''">
          <rdfs:label>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="normalize-space($label)"/>
          </rdfs:label>
        </xsl:if>
        <bf:title>
          <xsl:apply-templates mode="titleUnifTitle" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="label" select="$label"/>
          </xsl:apply-templates>
        </bf:title>
        <xsl:choose>
          <xsl:when test="substring($tag,2,2='10')">
            <xsl:for-each select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='d']">
              <bf:legalDate>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopParens">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </bf:legalDate>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="substring($tag,2,2)='30' or substring($tag,2,2)='40'">
            <xsl:for-each select="marc:subfield[@code='d']">
              <bf:legalDate>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopParens">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </bf:legalDate>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
        <xsl:for-each select="marc:subfield[@code='f']">
          <bf:originDate>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:originDate>
        </xsl:for-each>
        <xsl:choose>
          <xsl:when test="substring($tag,2,2)='30' or substring($tag,2,2)='40'">
            <xsl:for-each select="marc:subfield[@code='g']">
              <bf:genreForm>
                <bf:GenreForm>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='g']">
              <bf:genreForm>
                <bf:GenreForm>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="marc:subfield[@code='h']">
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopBrackets">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>        
        <xsl:for-each select="marc:subfield[@code='k']">
          <bf:natureOfContent>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:natureOfContent>
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>        
        <xsl:for-each select="marc:subfield[@code='l']">
          <bf:language>
            <bf:Language>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <rdfs:label>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:Language>
          </bf:language>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='m']">
          <bf:musicMedium>
            <bf:MusicMedium>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:MusicMedium>
          </bf:musicMedium>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='o' or @code='s']">
          <bf:version>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:version>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='r']">
          <bf:musicKey>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:musicKey>
        </xsl:for-each>
        <xsl:if test="substring($tag,1,1)='7' or substring($tag,1,1)='8'">
         <xsl:for-each select="marc:subfield[@code='x']">
           <bf:identifiedBy>
             <bf:Issn>
               <rdf:value><xsl:value-of select="."/></rdf:value>
             </bf:Issn>
           </bf:identifiedBy>
         </xsl:for-each>
        </xsl:if>
        <xsl:if test="substring($tag,2,2)='30' or $tag='240' or marc:subfield[@code='t']">
          <xsl:apply-templates mode="subfield0orw" select="marc:subfield[@code='0']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
          <xsl:apply-templates mode="subfield3" select="marc:subfield[@code='3']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
          <xsl:apply-templates mode="subfield5" select="marc:subfield[@code='5']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
        <xsl:apply-templates mode="subfield0orw" select="marc:subfield[@code='w']">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
        <xsl:if test="$tag='830'">
          <xsl:apply-templates mode="subfield7" select="marc:subfield[@code='7']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield" mode="titleUnifTitle">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="label"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="nfi">
      <xsl:choose>
        <xsl:when test="$tag='130' or $tag='630' or $tag='730' or $tag='740'">
          <xsl:value-of select="@ind1"/>
        </xsl:when>
        <xsl:when test="$tag='240' or $tag='830' or $tag='440'">
          <xsl:value-of select="@ind2"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="marckey">
      <xsl:apply-templates mode="marcKey"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <xsl:choose>
            <xsl:when test="substring($tag,2,2)='00'">
              <xsl:if test="$label != ''">
                <bflc:title00MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title00MatchKey>
              </xsl:if>
              <bflc:title00MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title00MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='10'">
              <xsl:if test="$label != ''">
                <bflc:title10MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title10MatchKey>
              </xsl:if>
              <bflc:title10MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title10MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='11'">
              <xsl:if test="$label != ''">
                <bflc:title11MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title11MatchKey>
              </xsl:if>
              <bflc:title11MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title11MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='30'">
              <xsl:if test="$label != ''">
                <bflc:title30MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title30MatchKey>
              </xsl:if>
              <bflc:title30MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title30MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='40' and $tag != '740'">
              <xsl:if test="$label != ''">
                <bflc:title40MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title40MatchKey>
              </xsl:if>
              <bflc:title40MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title40MarcKey>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="$label != ''">
            <rdfs:label><xsl:value-of select="normalize-space($label)"/></rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="normalize-space(substring($label,$nfi+1))"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="substring($tag,2,2)='30' or substring($tag,2,2)='40'">
              <xsl:for-each select="marc:subfield[@code='a']">
                <bf:mainTitle>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:mainTitle>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="marc:subfield[@code='t']">
                <bf:mainTitle>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:mainTitle>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="substring($tag,2,2) = '11'">
              <xsl:for-each select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='n']">
                <bf:partNumber>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:partNumber>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="marc:subfield[@code='n']">
                <bf:partNumber>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:partNumber>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:for-each select="marc:subfield[@code='p']">
            <bf:partName>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partName>
          </xsl:for-each>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield" mode="tTitleLabel">
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="substring($tag,2,2)='00'">
        <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='t'] |                                      marc:subfield[@code='t']/following-sibling::marc:subfield[@code='f' or                                      @code='g' or                                       @code='k' or                                      @code='l' or                                      @code='m' or                                      @code='n' or                                      @code='o' or                                      @code='p' or                                      @code='r' or                                      @code='s']"/>
      </xsl:when>
      <xsl:when test="substring($tag,2,2)='10'">
        <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='t'] |                                      marc:subfield[@code='t']/following-sibling::marc:subfield[@code='d' or                                      @code='f' or                                      @code='g' or                                      @code='k' or                                      @code='l' or                                      @code='m' or                                      @code='n' or                                      @code='o' or                                      @code='p' or                                      @code='r' or                                      @code='s']"/>
      </xsl:when>
      <xsl:when test="substring($tag,2,2)='11'">
        <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='t'] |                                      marc:subfield[@code='t']/following-sibling::marc:subfield[@code='f' or                                      @code='g' or                                      @code='k' or                                      @code='l' or                                      @code='n' or                                      @code='p' or                                      @code='s']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                      @code='d' or                                      @code='f' or                                      @code='g' or                                       @code='k' or                                      @code='l' or                                      @code='m' or                                      @code='n' or                                      @code='o' or                                      @code='p' or                                      @code='r' or                                      @code='s']"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='255']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work255">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='255' or @tag='880']" mode="work255">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vCoordinatesChopPunct">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString" select="marc:subfield[@code='c']"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="vCoordinates">
      <xsl:call-template name="chopParens">
        <xsl:with-param name="chopString" select="$vCoordinatesChopPunct"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- because $d and $e can have matching parens across subfield boundary,
         some monkey business is required -->
    <xsl:variable name="vZoneChopPunct">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString" select="marc:subfield[@code='d']"/>
        <xsl:with-param name="punctuation"><xsl:text>).:,;/ </xsl:text></xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="vZone">
      <xsl:choose>
        <xsl:when test="substring($vZoneChopPunct,1,1) = '('">
          <xsl:value-of select="substring($vZoneChopPunct,2,string-length($vZoneChopPunct)-1)"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$vZoneChopPunct"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vEquinoxChopPunct">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString" select="marc:subfield[@code='e']"/>
        <xsl:with-param name="punctuation"><xsl:text>).:,;/ </xsl:text></xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="vEquinox">
      <xsl:choose>
        <xsl:when test="substring($vEquinoxChopPunct,1,1) = '('">
          <xsl:value-of select="substring($vEquinoxChopPunct,2,string-length($vEquinoxChopPunct)-1)"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$vEquinoxChopPunct"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:scale>
            <bf:Scale>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdfs:label>
            </bf:Scale>
          </bf:scale>
        </xsl:for-each>
        <bf:cartographicAttributes>
          <bf:Cartographic>
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:projection>
                <bf:Projection>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <!-- leave trailing period for abbreviations -->
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                      <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:Projection>
              </bf:projection>
            </xsl:for-each>
            <xsl:if test="$vCoordinates != ''">
              <bf:coordinates>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$vCoordinates"/>
              </bf:coordinates>
            </xsl:if>
            <xsl:if test="$vZone != ''">
              <bf:ascensionAndDeclination>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$vZone"/>
              </bf:ascensionAndDeclination>
            </xsl:if>
            <xsl:if test="$vEquinox != ''">
              <bf:equinox>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$vEquinox"/>
              </bf:equinox>
            </xsl:if>
            <xsl:for-each select="marc:subfield[@code='f']">
              <bf:outerGRing>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </bf:outerGRing>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='g']">
              <bf:exclusionGRing>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </bf:exclusionGRing>
            </xsl:for-each>
          </bf:Cartographic>
        </bf:cartographicAttributes>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='250']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance250">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='250' or @tag='880']" mode="instance250">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vEditionStatementRaw">
      <xsl:apply-templates select="marc:subfield[@code='a' or @code='b']" mode="concat-nodes-space"/>
    </xsl:variable>
    <xsl:variable name="vEditionStatement">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString" select="$vEditionStatementRaw"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:editionStatement>
          <xsl:if test="$vXmlLang != ''">
            <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
          </xsl:if>
          <xsl:value-of select="$vEditionStatement"/>
        </bf:editionStatement>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='254']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance254">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='254' or @tag='880']" mode="instance254">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:note>
          <bf:Note>
            <bf:noteType>Musical presentation</bf:noteType>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString" select="marc:subfield[@code='a']"/>
              </xsl:call-template>
            </rdfs:label>
          </bf:Note>
        </bf:note>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='256']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance256">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='256' or @tag='880']" mode="instance256">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:note>
          <bf:Note>
            <bf:noteType>Computer file characteristics</bf:noteType>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString" select="marc:subfield[@code='a']"/>
              </xsl:call-template>
            </rdfs:label>
          </bf:Note>
        </bf:note>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='257']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance257">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='257' or @tag='880']" mode="instance257">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:provisionActivity>
            <bf:Production>
              <bf:place>
                <bf:Place>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </rdfs:label>
                  <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </bf:Place>
              </bf:place>
            </bf:Production>
          </bf:provisionActivity>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='260' or @tag='262' or @tag='264']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance260">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='260' or @tag='262' or @tag='264' or @tag='880']" mode="instance260">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vProvisionActivity">
      <xsl:choose>
        <xsl:when test="$vTag='264'">
          <xsl:choose>
            <xsl:when test="@ind2='0'">Production</xsl:when>
            <xsl:when test="@ind2='1'">Publication</xsl:when>
            <xsl:when test="@ind2='2'">Distribution</xsl:when>
            <xsl:when test="@ind2='3'">Manufacture</xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>Publication</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vStatement">
      <xsl:apply-templates select="marc:subfield[@code='a' or @code='b' or @code='c']" mode="concat-nodes-space"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <xsl:choose>
          <xsl:when test="$vTag='264' and @ind2='4'">
            <bf:copyrightDate>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="normalize-space($vStatement)"/>
            </bf:copyrightDate>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="marc:subfield[@code='a' or @code='b' or @code='c']">
              <bf:provisionActivity>
                <bf:ProvisionActivity>
                  <rdf:type>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$vProvisionActivity)"/></xsl:attribute>
                  </rdf:type>
                  <xsl:if test="$vTag='260' or $vTag='264'">
                    <xsl:if test="@ind1 = '3'">
                      <bf:status>
                        <bf:Status>
                          <rdfs:label>current</rdfs:label>
                        </bf:Status>
                      </bf:status>
                    </xsl:if>
                    <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
                      <xsl:with-param name="serialization" select="$serialization"/>
                    </xsl:apply-templates>
                  </xsl:if>
                  <xsl:for-each select="marc:subfield[@code='a']">
                    <bf:place>
                      <bf:Place>
                        <rdfs:label>
                          <xsl:if test="$vXmlLang != ''">
                            <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                          </xsl:if>
                          <xsl:call-template name="chopBrackets">
                            <xsl:with-param name="chopString" select="."/>
                            <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                          </xsl:call-template>
                        </rdfs:label>
                      </bf:Place>
                    </bf:place>
                  </xsl:for-each>
                  <xsl:for-each select="marc:subfield[@code='b']">
                    <bf:agent>
                      <bf:Agent>
                        <rdfs:label>
                          <xsl:if test="$vXmlLang != ''">
                            <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                          </xsl:if>
                          <xsl:call-template name="chopBrackets">
                            <xsl:with-param name="chopString" select="."/>
                            <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                          </xsl:call-template>
                        </rdfs:label>
                      </bf:Agent>
                    </bf:agent>
                  </xsl:for-each>
                  <xsl:for-each select="marc:subfield[@code='c']">
                    <bf:date>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:call-template name="chopBrackets">
                        <xsl:with-param name="chopString" select="."/>
                      </xsl:call-template>
                    </bf:date>
                  </xsl:for-each>
                </bf:ProvisionActivity>
              </bf:provisionActivity>
              <bf:provisionActivityStatement>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="normalize-space($vStatement)"/>
              </bf:provisionActivityStatement>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$vTag = '260' and marc:subfield[@code='e' or @code='f' or @code='g']">
          <bf:provisionActivity>
            <bf:ProvisionActivity>
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Manufacture')"/></xsl:attribute>
              </rdf:type>
              <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:for-each select="marc:subfield[@code='e']">
                <bf:place>
                  <bf:Place>
                    <rdfs:label>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:call-template name="chopParens">
                        <xsl:with-param name="chopString" select="."/>
                      </xsl:call-template>
                    </rdfs:label>
                  </bf:Place>
                </bf:place>
              </xsl:for-each>
              <xsl:for-each select="marc:subfield[@code='f']">
                <bf:agent>
                  <bf:Agent>
                    <rdfs:label>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:call-template name="chopParens">
                        <xsl:with-param name="chopString" select="."/>
                      </xsl:call-template>
                    </rdfs:label>
                  </bf:Agent>
                </bf:agent>
              </xsl:for-each>
              <xsl:for-each select="marc:subfield[@code='g']">
                <bf:date>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopParens">
                    <xsl:with-param name="chopString" select="."/>
                  </xsl:call-template>
                </bf:date>
              </xsl:for-each>
            </bf:ProvisionActivity>
          </bf:provisionActivity>
        </xsl:if>
        <xsl:if test="$vTag = '260'">
          <xsl:for-each select="marc:subfield[@code='d']">
            <bf:identifiedBy>
              <bf:PublisherNumber>
                <rdf:value><xsl:value-of select="."/></rdf:value>
              </bf:PublisherNumber>
            </bf:identifiedBy>
          </xsl:for-each>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='261']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance261">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='261' or @tag='880']" mode="instance261">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vStatement">
      <xsl:apply-templates select="marc:subfield[@code='a' or @code='b' or @code='d' or @code='f']" mode="concat-nodes-space"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:provisionActivity>
          <bf:ProvisionActivity>
            <rdf:type>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Production')"/></xsl:attribute>
            </rdf:type>
            <xsl:for-each select="marc:subfield[@code='a' or @code='b']">
              <bf:agent>
                <bf:Agent>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:Agent>
              </bf:agent>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='d']">
              <bf:date>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </bf:date>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='f']">
              <bf:place>
                <bf:Place>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:Place>
              </bf:place>
            </xsl:for-each>
          </bf:ProvisionActivity>
        </bf:provisionActivity>
        <bf:provisionActivityStatement><xsl:value-of select="normalize-space($vStatement)"/></bf:provisionActivityStatement>
        <xsl:if test="marc:subfield[@code='e']">
          <bf:provisionActivity>
            <bf:ProvisionActivity>
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Manufacture')"/></xsl:attribute>
              </rdf:type>
              <xsl:for-each select="marc:subfield[@code='e']">
                <bf:agent>
                  <bf:Agent>
                    <rdfs:label>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString" select="."/>
                      </xsl:call-template>
                    </rdfs:label>
                  </bf:Agent>
                </bf:agent>
              </xsl:for-each>
            </bf:ProvisionActivity>
          </bf:provisionActivity>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='263']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance263">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='263' or @tag='880']" mode="instance263">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vDate">
      <xsl:call-template name="edtfFormat">
        <xsl:with-param name="pDateString" select="marc:subfield[@code='a']"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$vDate != ''">
          <bflc:projectedPubDate>
            <xsl:attribute name="rdf:datatype"><xsl:value-of select="concat($edtf,'edtf')"/></xsl:attribute>
            <xsl:value-of select="$vDate"/>
          </bflc:projectedPubDate>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='265']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:acquisitionSource><xsl:value-of select="."/></bf:acquisitionSource>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='336']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="rdaResource">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pProp">bf:content</xsl:with-param>
      <xsl:with-param name="pResource">bf:Content</xsl:with-param>
      <xsl:with-param name="pUriStem"><xsl:value-of select="$contentType"/></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='351']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work351">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='351' or @tag='880']" mode="work351">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:arrangement>
          <bf:Arrangement>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:for-each select="marc:subfield[@code='c']">
              <bf:hierarchicalLevel>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString"><xsl:value-of select="."/></xsl:with-param>
                </xsl:call-template>
              </bf:hierarchicalLevel>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='a']">
              <bf:organization>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString"><xsl:value-of select="."/></xsl:with-param>
                </xsl:call-template>
              </bf:organization>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:pattern>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString"><xsl:value-of select="."/></xsl:with-param>
                </xsl:call-template>
              </bf:pattern>
            </xsl:for-each>
          </bf:Arrangement>
        </bf:arrangement>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='380']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work380">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='380' or @tag='880']" mode="work380">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:apply-templates select="marc:subfield[@code='a']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:genreForm</xsl:with-param>
          <xsl:with-param name="pResource">bf:GenreForm</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='382']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work382">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='382' or @tag='880']" mode="work382">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='d' or @code='p']">
          <xsl:variable name="vNodeId" select="generate-id()"/>
          <bf:musicMedium>
            <bf:MusicMedium>
              <xsl:if test="@code='d'">
                <bf:status>
                  <bf:Status>
                    <rdfs:label>doubling</rdfs:label>
                  </bf:Status>
                </bf:status>
              </xsl:if>
              <xsl:if test="@code='p'">
                <bf:status>
                  <bf:Status>
                    <rdfs:label>alternative</rdfs:label>
                  </bf:Status>
                </bf:status>
              </xsl:if>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
              <xsl:for-each select="following-sibling::marc:subfield[@code='a' or @code='b' or @code='d' or @code='p' or @code='r' or @code='s' or @code='t'][position()=1]/preceding-sibling::marc:subfield[@code='n' or @code='e']">
                <xsl:if test="generate-id(preceding-sibling::marc:subfield[@code='a' or @code='b' or @code='d' or @code='p'][position()=1])=$vNodeId">
                  <bf:count>
                    <xsl:value-of select="."/>
                  </bf:count>
                </xsl:if>
              </xsl:for-each>
              <xsl:for-each select="following-sibling::marc:subfield[@code='a' or @code='b' or @code='d' or @code='p' or @code='r' or @code='s' or @code='t'][position()=1]/preceding-sibling::marc:subfield[@code='v']">
                <xsl:if test="generate-id(preceding-sibling::marc:subfield[@code='a' or @code='b' or @code='d' or @code='p'][position()=1])=$vNodeId">
                  <bf:note>
                    <bf:Note>
                      <rdfs:label>
                        <xsl:if test="$vXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="."/>
                      </rdfs:label>
                    </bf:Note>
                  </bf:note>
                </xsl:if>
              </xsl:for-each>
              <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="../marc:subfield[@code='3']" mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:MusicMedium>
          </bf:musicMedium>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='r' or @code='s' or @code='t'] | marc:subfield[@code='v'][preceding-sibling::marc:subfield[@code='r' or @code='s' or @code='t']]">
          <xsl:variable name="vDisplayConstant">
            <xsl:choose>
              <xsl:when test="@code='r'">Total performers alongside ensembles: </xsl:when>
              <xsl:when test="@code='s'">Total performers: </xsl:when>
              <xsl:when test="@code='t'">Total ensembles: </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <bf:musicMedium>
            <bf:MusicMedium>
              <bf:note>
                <bf:Note>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="concat($vDisplayConstant,.)"/>
                  </rdfs:label>
                </bf:Note>
              </bf:note>
              <xsl:apply-templates select="../marc:subfield[@code='3']" mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:MusicMedium>
          </bf:musicMedium>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='383']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work383">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='383' or @tag='880']" mode="work383">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:musicSerialNumber>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="."/>
              <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
            </xsl:call-template>
          </bf:musicSerialNumber>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='b']">
          <bf:musicOpusNumber><xsl:value-of select="."/></bf:musicOpusNumber>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='c' or @code='d']">
          <bf:musicThematicNumber><xsl:value-of select="."/></bf:musicThematicNumber>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='385' or @tag='386']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work385or386">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='385' or @tag='386' or @tag='880']" mode="work385or386">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vProp">
      <xsl:choose>
        <xsl:when test="$vTag='385'">bf:intendedAudience</xsl:when>
        <xsl:when test="$vTag='386'">bflc:creatorCharacteristic</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vResource">
      <xsl:choose>
        <xsl:when test="$vTag='385'">bf:IntendedAudience</xsl:when>
        <xsl:when test="$vTag='386'">bflc:CreatorCharacteristic</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <xsl:element name="{$vProp}">
            <xsl:element name="{$vResource}">
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
              <xsl:for-each select="following-sibling::marc:subfield[@code='b'][position()=1]">
                <bf:code><xsl:value-of select="."/></bf:code>
              </xsl:for-each>
              <xsl:for-each select="../marc:subfield[@code='m' or @code='n']">
                <bflc:demographicGroup>
                  <bflc:DemographicGroup>
                    <rdfs:label>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="."/>
                    </rdfs:label>
                  </bflc:DemographicGroup>
                </bflc:demographicGroup>
              </xsl:for-each>
              <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="../marc:subfield[@code='3']" mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='336' or @tag='337' or @tag='338' or @tag='880']" mode="rdaResource">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pProp"/>
    <xsl:param name="pResource"/>
    <xsl:param name="pUriStem"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='b']">
          <xsl:element name="{$pProp}">
            <xsl:element name="{$pResource}">
              <xsl:attribute name="rdf:about"><xsl:value-of select="concat($pUriStem,.)"/></xsl:attribute>
              <xsl:if test="preceding-sibling::marc:subfield[position()=1]/@code = 'a'">
                <rdfs:label>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="preceding-sibling::marc:subfield[position()=1]"/>
                </rdfs:label>
              </xsl:if>
              <xsl:if test="following-sibling::marc:subfield[position()=1]/@code = '0'">
                <xsl:apply-templates select="following-sibling::marc:subfield[position()=1]" mode="subfield0orw">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </xsl:if>
              <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="../marc:subfield[@code='3']" mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='a']">
          <xsl:if test="following-sibling::marc:subfield[position()=1]/@code != 'b'">
            <xsl:element name="{$pProp}">
              <xsl:element name="{$pResource}">
                <rdfs:label>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="."/>
                </rdfs:label>
                <xsl:if test="following-sibling::marc:subfield[position()=1]/@code = '0'">
                  <xsl:apply-templates select="following-sibling::marc:subfield[position()=1]" mode="subfield0orw">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:if>
                <xsl:for-each select="../marc:subfield[@code='2']">
                  <xsl:choose>
                    <xsl:when test="contains(.,'rda')">
                      <bf:source>
                        <bf:Source>
                          <rdfs:label>rda</rdfs:label>
                        </bf:Source>
                      </bf:source>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="." mode="subfield2">
                        <xsl:with-param name="serialization" select="$serialization"/>
                      </xsl:apply-templates>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
                <xsl:apply-templates select="../marc:subfield[@code='3']" mode="subfield3">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </xsl:element>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='300']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance300">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='300' or @tag='880']" mode="instance300">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vExtentRaw">
      <xsl:apply-templates select="marc:subfield[@code='a' or @code='f' or @code='g']" mode="concat-nodes-space"/>
    </xsl:variable>
    <xsl:variable name="vExtent">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString" select="$vExtentRaw"/>
        <xsl:with-param name="punctuation"><xsl:text>+:,;/ </xsl:text></xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <xsl:if test="$vExtent != ''">
          <bf:extent>
            <bf:Extent>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="normalize-space($vExtent)"/>
              </rdfs:label>
              <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:Extent>
          </bf:extent>
        </xsl:if>
        <xsl:for-each select="marc:subfield[@code='b' or @code='e']">
          <bf:note>
            <bf:Note>
              <bf:noteType>
                <xsl:choose>
                  <xsl:when test="@code='b'">Physical details</xsl:when>
                  <xsl:when test="@code='e'">Accompanying materials</xsl:when>
                </xsl:choose>
              </bf:noteType>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                  <xsl:with-param name="punctuation"><xsl:text>+:,;/ </xsl:text></xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
              <xsl:apply-templates select="../marc:subfield[@code='3']" mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:Note>
          </bf:note>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='c']">
          <bf:dimensions>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="."/>
              <xsl:with-param name="punctuation"><xsl:text>+:,;/ </xsl:text></xsl:with-param>
            </xsl:call-template>
          </bf:dimensions>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='306']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance306">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='306' or @tag='880']" mode="instance306">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:duration>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
          </bf:duration>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='310' or @tag='321']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance310">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='310' or @tag='321' or @tag='880']" mode="instance310">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:frequency>
            <bf:Frequency>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                  <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
              <xsl:for-each select="../marc:subfield[@code='b']">
                <bf:date>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="."/>
                </bf:date>
              </xsl:for-each>
            </bf:Frequency>
          </bf:frequency>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='337']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="rdaResource">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pProp">bf:media</xsl:with-param>
      <xsl:with-param name="pResource">bf:Media</xsl:with-param>
      <xsl:with-param name="pUriStem"><xsl:value-of select="$mediaType"/></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='338']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="rdaResource">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pProp">bf:carrier</xsl:with-param>
      <xsl:with-param name="pResource">bf:Carrier</xsl:with-param>
      <xsl:with-param name="pUriStem"><xsl:value-of select="$carriers"/></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='340']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance340">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='340' or @tag='880']" mode="instance340">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:apply-templates select="marc:subfield[@code='a']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:baseMaterial</xsl:with-param>
          <xsl:with-param name="pResource">bf:BaseMaterial</xsl:with-param>
        </xsl:apply-templates>
        <xsl:for-each select="marc:subfield[@code='b']">
          <bf:dimensions><xsl:value-of select="."/></bf:dimensions>
        </xsl:for-each>
        <xsl:apply-templates select="marc:subfield[@code='c']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:appliedMaterial</xsl:with-param>
          <xsl:with-param name="pResource">bf:AppliedMaterial</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='d']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:productionMethod</xsl:with-param>
          <xsl:with-param name="pResource">bf:ProductionMethod</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='e']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:mount</xsl:with-param>
          <xsl:with-param name="pResource">bf:Mount</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='f']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:reductionRatio</xsl:with-param>
          <xsl:with-param name="pResource">bf:ReductionRatio</xsl:with-param>
        </xsl:apply-templates>
        <xsl:for-each select="marc:subfield[@code='i']">
          <bf:systemRequirements><xsl:value-of select="."/></bf:systemRequirements>
        </xsl:for-each>
        <xsl:apply-templates select="marc:subfield[@code='j']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:generation</xsl:with-param>
          <xsl:with-param name="pResource">bf:Generation</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='k']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:layout</xsl:with-param>
          <xsl:with-param name="pResource">bf:Layout</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='m']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:bookFormat</xsl:with-param>
          <xsl:with-param name="pResource">bf:BookFormat</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='n']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:fontSize</xsl:with-param>
          <xsl:with-param name="pResource">bf:FontSize</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='o']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:polarity</xsl:with-param>
          <xsl:with-param name="pResource">bf:Polarity</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='344']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance344">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='344' or @tag='880']" mode="instance344">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:apply-templates select="marc:subfield[@code='a']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:soundCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:RecordingMethod</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='b']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:soundCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:RecordingMedium</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='c']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:soundCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:PlayingSpeed</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='d']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:soundCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:GrooveCharacteristics</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='e']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:soundCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:TrackConfig</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='f']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:soundCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:TapeConfig</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='g']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:soundCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:PlaybackChannels</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='h']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:soundCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:PlaybackCharacteristic</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='345']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance345">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='345' or @tag='880']" mode="instance345">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:apply-templates select="marc:subfield[@code='a']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:projectionCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:PresentationFormat</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='b']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:projectionCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:ProjectionSpeed</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='346']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance346">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='346' or @tag='880']" mode="instance346">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:apply-templates select="marc:subfield[@code='a']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:videoCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:VideoFormat</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='b']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:videoCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:BroadcastStandard</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='347']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance347">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='347' or @tag='880']" mode="instance347">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:apply-templates select="marc:subfield[@code='a']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:digitalCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:FileType</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='b']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:digitalCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:EncodingFormat</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='c']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:digitalCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:FileSize</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='d']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:digitalCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:Resolution</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='e']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:digitalCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:RegionalEncoding</xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="marc:subfield[@code='f']" mode="generateProperty">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:digitalCharacteristic</xsl:with-param>
          <xsl:with-param name="pResource">bf:EncodedBitrate</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='348']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance348">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='348' or @tag='880']" mode="instance348">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:musicFormat>
            <bf:MusicFormat>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
              <xsl:for-each select="following-sibling::marc:subfield[@code='b'][position()=1]">
                <bf:code><xsl:value-of select="."/></bf:code>
              </xsl:for-each>
              <xsl:apply-templates select="following-sibling::marc:subfield[@code='0'][position()=1]" mode="subfield0orw">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="../marc:subfield[@code='3']" mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:MusicFormat>
          </bf:musicFormat>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='350']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance350">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='350' or @tag='880']" mode="instance350">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:acquisitionSource>
            <bf:AcquisitionSource>
              <bf:acquisitionTerms>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </bf:acquisitionTerms>
            </bf:AcquisitionSource>
          </bf:acquisitionSource>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='352']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance352">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='352' or @tag='880']" mode="instance352">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='q']">
          <xsl:variable name="vResource">
            <xsl:choose>
              <xsl:when test="@code='a'">bf:CartographicDataType</xsl:when>
              <xsl:when test="@code='q'">bf:EncodingFormat</xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="vProcess">
            <xsl:choose>
              <xsl:when test="@code='a'">chopPunctuation</xsl:when>
              <xsl:when test="@code='q'">chopPunctuation</xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:apply-templates select="." mode="generateProperty">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="pProp">bf:digitalCharacteristic</xsl:with-param>
            <xsl:with-param name="pResource" select="$vResource"/>
            <xsl:with-param name="pProcess" select="$vProcess"/>
          </xsl:apply-templates>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='b']">
          <bf:digitalCharacteristic>
            <bf:CartographicObjectType>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdfs:label>
              <xsl:if test="following-sibling::marc:subfield[position()=1]/@code = 'c'">
                <bf:count>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopParens">
                    <xsl:with-param name="chopString" select="following-sibling::marc:subfield[position()=1]"/>
                  </xsl:call-template>
                </bf:count>
              </xsl:if>
            </bf:CartographicObjectType>
          </bf:digitalCharacteristic>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='362']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance362">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='362' or @tag='880']" mode="instance362">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vFirstIssue"><xsl:value-of select="substring-before(marc:subfield[@code='a'],'-')"/></xsl:variable>
    <xsl:variable name="vLastIssue"><xsl:value-of select="substring-after(marc:subfield[@code='a'],'-')"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:choose>
          <xsl:when test="@ind1='0'">
            <xsl:if test="$vFirstIssue != ''">
              <bf:firstIssue>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$vFirstIssue"/>
              </bf:firstIssue>
            </xsl:if>
            <xsl:if test="$vLastIssue != ''">
              <bf:lastIssue>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$vLastIssue"/>
              </bf:lastIssue>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <bf:note>
              <bf:Note>
                <bf:noteType>Numbering</bf:noteType>
                <rdfs:label>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="marc:subfield[@code='a']"/>
                </rdfs:label>
              </bf:Note>
            </bf:note>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='530' or @tag='533' or @tag='534']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates select="." mode="hasInstance5XX">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
      <xsl:with-param name="recordid" select="$recordid"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='530' or @tag='533' or @tag='534' or @tag='880']" mode="hasInstance5XX">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:hasInstance>
          <bf:Instance>
            <xsl:attribute name="rdf:about"><xsl:value-of select="$pInstanceUri"/></xsl:attribute>
            <bf:instanceOf>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
            </bf:instanceOf>
            <xsl:choose>
              <xsl:when test="$vTag='533'">
                <bf:title>
                  <xsl:apply-templates mode="title245" select="../marc:datafield[@tag='245']">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="label">
                      <xsl:apply-templates mode="concat-nodes-space" select="../marc:datafield[@tag='245']/marc:subfield[@code='a' or                                                    @code='b' or                                                    @code='f' or                                                     @code='g' or                                                    @code='k' or                                                    @code='n' or                                                    @code='p' or                                                    @code='s']"/>
                    </xsl:with-param>
                  </xsl:apply-templates>
                </bf:title>
              </xsl:when>                  
              <xsl:when test="$vTag='534' and marc:subfield[@code='t']">
                <bf:title>
                  <bf:InstanceTitle>
                    <rdfs:label>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="marc:subfield[@code='t']"/>
                    </rdfs:label>
                  </bf:InstanceTitle>
                </bf:title>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="../marc:datafield[@tag='130']">
                    <bf:title>
                      <xsl:apply-templates mode="titleUnifTitle" select="../marc:datafield[@tag='130']">
                        <xsl:with-param name="serialization" select="$serialization"/>
                        <xsl:with-param name="label">
                          <xsl:apply-templates mode="concat-nodes-space" select="../marc:datafield[@tag='130']/marc:subfield[@code='a' or                                                        @code='d' or                                                        @code='f' or                                                        @code='g' or                                                         @code='k' or                                                        @code='l' or                                                        @code='m' or                                                        @code='n' or                                                        @code='o' or                                                        @code='p' or                                                        @code='r' or                                                        @code='s']"/>
                        </xsl:with-param>                    
                      </xsl:apply-templates>
                    </bf:title>
                  </xsl:when>
                  <xsl:when test="../marc:datafield[@tag='240']">
                    <bf:title>
                      <xsl:apply-templates mode="titleUnifTitle" select="../marc:datafield[@tag='240']">
                        <xsl:with-param name="serialization" select="$serialization"/>
                        <xsl:with-param name="label">
                          <xsl:apply-templates mode="concat-nodes-space" select="../marc:datafield[@tag='240']/marc:subfield[@code='a' or                                                        @code='d' or                                                        @code='f' or                                                        @code='g' or                                                         @code='k' or                                                        @code='l' or                                                        @code='m' or                                                        @code='n' or                                                        @code='o' or                                                        @code='p' or                                                        @code='r' or                                                        @code='s']"/>
                        </xsl:with-param>                    
                      </xsl:apply-templates>
                    </bf:title>
                  </xsl:when>
                  <xsl:otherwise>
                    <bf:title>
                      <xsl:apply-templates mode="title245" select="../marc:datafield[@tag='245']">
                        <xsl:with-param name="serialization" select="$serialization"/>
                        <xsl:with-param name="label">
                          <xsl:apply-templates mode="concat-nodes-space" select="../marc:datafield[@tag='245']/marc:subfield[@code='a' or                                                        @code='b' or                                                        @code='f' or                                                         @code='g' or                                                        @code='k' or                                                        @code='n' or                                                        @code='p' or                                                        @code='s']"/>
                        </xsl:with-param>
                      </xsl:apply-templates>
                    </bf:title>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="$vTag='530'">
                <xsl:apply-templates select="." mode="hasInstance530">
                  <xsl:with-param name="serialization" select="$serialization"/>
                  <xsl:with-param name="pInstanceUri" select="$pInstanceUri"/>
                  <xsl:with-param name="recordid" select="$recordid"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:when test="$vTag='533'">
                <xsl:apply-templates select="." mode="hasInstance533">
                  <xsl:with-param name="serialization" select="$serialization"/>
                  <xsl:with-param name="pInstanceUri" select="$pInstanceUri"/>
                  <xsl:with-param name="recordid" select="$recordid"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:when test="$vTag='534'">
                <xsl:apply-templates select="." mode="hasInstance534">
                  <xsl:with-param name="serialization" select="$serialization"/>
                  <xsl:with-param name="pInstanceUri" select="$pInstanceUri"/>
                  <xsl:with-param name="recordid" select="$recordid"/>
                </xsl:apply-templates>
              </xsl:when>
            </xsl:choose>
          </bf:Instance>
        </bf:hasInstance>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='530' or @tag='880']" mode="hasInstance530">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:otherPhysicalFormat>
          <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
        </bf:otherPhysicalFormat>
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:note>
            <bf:Note>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdfs:label>
            </bf:Note>
          </bf:note>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='b']">
          <bf:acquisitionSource>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
          </bf:acquisitionSource>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='c']">
          <bf:acquisitionTerms>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
          </bf:acquisitionTerms>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='d']">
          <bf:identifiedBy>
            <bf:StockNumber>
              <rdf:value>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdf:value>
            </bf:StockNumber>
          </bf:identifiedBy>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='u']">
          <bf:hasItem>
            <bf:Item>
              <bf:itemOf>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="$pInstanceUri"/></xsl:attribute>
              </bf:itemOf>
              <bf:electronicLocator>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
              </bf:electronicLocator>
            </bf:Item>
          </bf:hasItem>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='3']">
          <xsl:apply-templates select="." mode="subfield3">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='533' or @tag='880']" mode="hasInstance533">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:reproductionOf>
          <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
        </bf:reproductionOf>
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:carrier>
            <bf:Carrier>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdfs:label>
            </bf:Carrier>
          </bf:carrier>
        </xsl:for-each>
        <xsl:if test="marc:subfield[@code='b' or @code='c' or @code='d']">
          <bf:provisionActivity>
            <bf:ProvisionActivity>
              <xsl:for-each select="marc:subfield[@code='b']">
                <bf:place>
                  <bf:Place>
                    <rdfs:label>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString" select="."/>
                      </xsl:call-template>
                    </rdfs:label>
                  </bf:Place>
                </bf:place>
              </xsl:for-each>
              <xsl:for-each select="marc:subfield[@code='c']">
                <bf:agent>
                  <bf:Agent>
                    <rdfs:label>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString" select="."/>
                      </xsl:call-template>
                    </rdfs:label>
                  </bf:Agent>
                </bf:agent>
              </xsl:for-each>
              <xsl:for-each select="marc:subfield[@code='d']">
                <bf:date>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString" select="."/>
                  </xsl:call-template>
                </bf:date>
              </xsl:for-each>
            </bf:ProvisionActivity>
          </bf:provisionActivity>
        </xsl:if>
        <xsl:for-each select="marc:subfield[@code='e']">
          <bf:extent>
            <bf:Extent>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdfs:label>
            </bf:Extent>
          </bf:extent>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='f']">
          <bf:seriesStatement>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopParens">
              <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
          </bf:seriesStatement>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='n']">
          <bf:note>
            <bf:Note>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
            </bf:Note>
          </bf:note>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='3' or @code='m']">
          <xsl:apply-templates select="." mode="subfield3">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='5']">
          <xsl:apply-templates select="." mode="subfield5">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:for-each>
        <xsl:if test="(following-sibling::marc:datafield[position()=1]/@tag='535'                       and following-sibling::marc:datafield[position()=1]/@ind1='2') or                       (following-sibling::marc:datafield[position()=1]/@tag='880'                       and following-sibling::marc:datafield[position()=1]/marc:subfield[@code='6'][starts-with(.,'535')]                       and following-sibling::marc:datafield[position()=1]/@ind1='2')">
          <xsl:apply-templates select="following-sibling::marc:datafield[position()=1]" mode="hasItem535">
            <xsl:with-param name="pInstanceUri" select="$pInstanceUri"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='534' or @tag='880']" mode="hasInstance534">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:originalVersionOf>
          <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
        </bf:originalVersionOf>
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:contribution>
            <bf:Contribution>
              <bf:agent>
                <bf:Agent>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:Agent>
              </bf:agent>
            </bf:Contribution>
          </bf:contribution>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='b']">
          <bf:editionStatement>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
          </bf:editionStatement>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='c']">
          <bf:provisionActivityStatement>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
          </bf:provisionActivityStatement>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='e']">
          <bf:extent>
            <bf:Extent>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdfs:label>
            </bf:Extent>
          </bf:extent>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='f']">
          <bf:seriesStatement>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopParens">
              <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
          </bf:seriesStatement>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='k']">
          <bf:title>
            <bf:KeyTitle>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdfs:label>
            </bf:KeyTitle>
          </bf:title>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='m' or @code='n']">
          <bf:note>
            <bf:Note>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdfs:label>
            </bf:Note>
          </bf:note>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='x' or @code='z']">
          <xsl:variable name="vIdentifier">
            <xsl:choose>
              <xsl:when test="@code='x'">bf:Issn</xsl:when>
              <xsl:when test="@code='z'">bf:Isbn</xsl:when>
            </xsl:choose>
          </xsl:variable>
          <bf:identifiedBy>
            <xsl:element name="{$vIdentifier}">
              <rdf:value>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdf:value>
            </xsl:element>
          </bf:identifiedBy>
        </xsl:for-each>
        <xsl:apply-templates select="marc:subfield[@code='p' or @code='3']" mode="subfield3">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
        <xsl:if test="(following-sibling::marc:datafield[position()=1]/@tag='535'                       and following-sibling::marc:datafield[position()=1]/@ind1='1') or                       (following-sibling::marc:datafield[position()=1]/@tag='880'                       and following-sibling::marc:datafield[position()=1]/marc:subfield[@code='6'][starts-with(.,'535')]                       and following-sibling::marc:datafield[position()=1]/@ind1='1')">
          <xsl:apply-templates select="following-sibling::marc:datafield[position()=1]" mode="hasItem535">
            <xsl:with-param name="pInstanceUri" select="$pInstanceUri"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='535' or @tag='880']" mode="hasItem535">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vAddress">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
        <xsl:with-param name="chopString">
          <xsl:for-each select="marc:subfield[@code='b' or @code='c' or @code='d']">
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
              <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
            <xsl:text>; </xsl:text>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:hasItem>
          <bf:Item>
            <bf:itemOf>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="$pInstanceUri"/></xsl:attribute>
            </bf:itemOf>
            <xsl:if test="marc:subfield[@code='a' or @code='b' or @code='c']">
              <bf:heldBy>
                <bf:Agent>
                  <xsl:for-each select="marc:subfield[@code='a']">
                    <rdfs:label>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                        <xsl:with-param name="chopString" select="."/>
                      </xsl:call-template>
                    </rdfs:label>
                  </xsl:for-each>
                  <xsl:if test="$vAddress != ''">
                    <bf:place>
                      <bf:Place>
                        <rdf:type>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($madsrdf,'Address')"/></xsl:attribute>
                        </rdf:type>
                        <rdfs:label><xsl:value-of select="$vAddress"/></rdfs:label>
                      </bf:Place>
                    </bf:place>
                  </xsl:if>
                </bf:Agent>
              </bf:heldBy>
            </xsl:if>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Item>
        </bf:hasItem>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='490']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:seriesStatement>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="."/>
              <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
            </xsl:call-template>
          </bf:seriesStatement>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='v']">
          <bf:seriesEnumeration>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="."/>
              <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
            </xsl:call-template>
          </bf:seriesEnumeration>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='x']">
          <bf:hasSeries>
            <bf:Instance>
              <bf:identifiedBy>
                <bf:Issn>
                  <rdf:value>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                      <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                    </xsl:call-template>
                  </rdf:value>
                </bf:Issn>
              </bf:identifiedBy>
            </bf:Instance>
          </bf:hasSeries>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='510']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance510">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='510' or @tag='880']" mode="instance510">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bflc:indexedIn>
          <bf:Instance>
            <xsl:for-each select="marc:subfield[@code='a']">
              <bf:title>
                <bf:Title>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                      <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:Title>
              </bf:title>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='b' or @code='c']">
              <bf:note>
                <bf:Note>
                  <bf:noteType>
                    <xsl:choose>
                      <xsl:when test="@code='b'">Coverage</xsl:when>
                      <xsl:when test="@code='c'">Location</xsl:when>
                    </xsl:choose>
                  </bf:noteType>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                      <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='x']">
              <bf:identifiedBy>
                <bf:Issn>
                  <rdf:value>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                      <xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>
                    </xsl:call-template>
                  </rdf:value>
                </bf:Issn>
              </bf:identifiedBy>
            </xsl:for-each>
          </bf:Instance>
        </bflc:indexedIn>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='530']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance530-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates select="." mode="instance530">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='530' or @tag='880']" mode="instance530">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:otherPhysicalFormat>
          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pInstanceUri"/></xsl:attribute>
        </bf:otherPhysicalFormat>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='533']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance533-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates select="." mode="instance533">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='533' or @tag='880']" mode="instance533">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:hasReproduction>
          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pInstanceUri"/></xsl:attribute>
        </bf:hasReproduction>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='534']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance534-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates select="." mode="instance534">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='534' or @tag='880']" mode="instance534">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:originalVersion>
          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pInstanceUri"/></xsl:attribute>
        </bf:originalVersion>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='502']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work502">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='502' or @tag='880']" mode="work502">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:dissertation>
          <bf:Dissertation>
            <xsl:for-each select="marc:subfield[@code='a']">
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:degree>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </bf:degree>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='c']">
              <bf:grantingInstitution>
                <bf:Agent>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </rdfs:label>
                </bf:Agent>
              </bf:grantingInstitution>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='d']">
              <bf:date>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </bf:date>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='g']">
              <bf:note>
                <bf:Note>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='o']">
              <bf:identifiedBy>
                <bf:DissertationIdentifier>
                  <rdf:value><xsl:value-of select="."/></rdf:value>
                </bf:DissertationIdentifier>
              </bf:identifiedBy>
            </xsl:for-each>
          </bf:Dissertation>
        </bf:dissertation>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='508' or @tag='511']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="workCreditsNote">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='518']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work518">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='518' or @tag='880']" mode="work518">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='d' or @code='o' or @code='p']"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:capture>
          <bf:Capture>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="normalize-space($vLabel)"/>
            </rdfs:label>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Capture>
        </bf:capture>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='520']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work520">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='520' or @tag='880']" mode="work520">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='b']"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:summary>
          <bf:Summary>
            <xsl:if test="normalize-space($vLabel) != ''">
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="normalize-space($vLabel)"/>
              </rdfs:label>
            </xsl:if>
            <xsl:for-each select="marc:subfield[@code='u']">
              <bf:source>
                <bf:Source>
                  <xsl:apply-templates select="." mode="subfieldu">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </bf:Source>
              </bf:source>
            </xsl:for-each>
            <xsl:apply-templates select="marc:subfield[@code='c']" mode="subfield2">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Summary>
        </bf:summary>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='522']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work522">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='522' or @tag='880']" mode="work522">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:geographicCoverage>
            <bf:GeographicCoverage>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
            </bf:GeographicCoverage>
          </bf:geographicCoverage>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='546']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work546">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='546' or @tag='880']" mode="work546">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:language>
          <bf:Language>
            <bf:note>
              <bf:Note>
                <xsl:for-each select="marc:subfield[@code='a']">
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                    </xsl:call-template>
                  </rdfs:label>
                </xsl:for-each>
                <xsl:for-each select="marc:subfield[@code='b']">
                  <bf:notation>
                    <bf:Notation>
                      <rdfs:label>
                        <xsl:if test="$vXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="chopPunctuation">
                          <xsl:with-param name="chopString" select="."/>
                        </xsl:call-template>
                      </rdfs:label>
                    </bf:Notation>
                  </bf:notation>
                </xsl:for-each>
                <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </bf:Note>
            </bf:note>
          </bf:Language>
        </bf:language>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='580']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work580">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='580' or @tag='880']" mode="work580">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:note>
          <bf:Note>
            <xsl:for-each select="marc:subfield[@code='a']">
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
            </xsl:for-each>
          </bf:Note>
        </bf:note>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='508' or @tag='511' or @tag='880']" mode="workCreditsNote">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vDisplayConst">
      <xsl:choose>
        <xsl:when test="$vTag='511' and @ind1='1'">Cast: </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:credits>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$vDisplayConst"/><xsl:value-of select="."/>
          </bf:credits>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template mode="instance" match="marc:datafield[@tag='500'] | marc:datafield[@tag='501'] |                                        marc:datafield[@tag='504'] | marc:datafield[@tag='513'] |                                        marc:datafield[@tag='515'] | marc:datafield[@tag='516'] |                                        marc:datafield[@tag='536'] | marc:datafield[@tag='544'] |                                        marc:datafield[@tag='545'] | marc:datafield[@tag='547'] |                                        marc:datafield[@tag='550'] | marc:datafield[@tag='555'] |                                        marc:datafield[@tag='556'] | marc:datafield[@tag='581'] |                                        marc:datafield[@tag='585'] | marc:datafield[@tag='586'] |                                        marc:datafield[@tag='588']">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instanceNote5XX">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='505']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance505">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='505' or @tag='880']" mode="instance505">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='g' or @code='r' or @code='t']"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:tableOfContents>
          <bf:TableOfContents>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="normalize-space($vLabel)"/>
            </rdfs:label>
          </bf:TableOfContents>
        </bf:tableOfContents>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='506']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance506">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='506' or @tag='880']" mode="instance506">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='e' or @code='f']"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:usageAndAccessPolicy>
          <bf:UsageAndAccessPolicy>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="normalize-space($vLabel)"/>
            </rdfs:label>
            <xsl:apply-templates select="marc:subfield[@code='u']" mode="subfieldu">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='5']" mode="subfield5">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:UsageAndAccessPolicy>
        </bf:usageAndAccessPolicy>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='507']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance507">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='507' or @tag='880']" mode="instance507">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='b']"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:scale>
          <xsl:if test="$vXmlLang != ''">
            <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
          </xsl:if>
          <xsl:value-of select="normalize-space($vLabel)"/>
        </bf:scale>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='521']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance521">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='521' or @tag='880']" mode="instance521">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vNote">
      <xsl:choose>
        <xsl:when test="@ind1='0'">reading grade level</xsl:when>
        <xsl:when test="@ind1='1'">interest age level</xsl:when>
        <xsl:when test="@ind1='2'">interest grade level</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:intendedAudience>
            <bf:IntendedAudience>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
              <xsl:if test="$vNote != ''">
                <bf:note>
                  <bf:Note>
                    <rdfs:label><xsl:value-of select="$vNote"/></rdfs:label>
                  </bf:Note>
                </bf:note>
              </xsl:if>
              <xsl:apply-templates select="../marc:subfield[@code='b']" mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="../marc:subfield[@code='3']" mode="subfield3">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:IntendedAudience>
          </bf:intendedAudience>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='524']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance524">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='524' or @tag='880']" mode="instance524">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:preferredCitation>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
          </bf:preferredCitation>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='525']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance525">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='525' or @tag='880']" mode="instance525">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:supplementaryContent>
            <bf:SupplementaryContent>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
            </bf:SupplementaryContent>
          </bf:supplementaryContent>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='538']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance538">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='538' or @tag='880']" mode="instance538">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:systemRequirements>
          <bf:SystemRequirements>
            <xsl:for-each select="marc:subfield[@code='a']">
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
            </xsl:for-each>
            <xsl:apply-templates select="marc:subfield[@code='u']" mode="subfieldu">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='5']" mode="subfield5">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:SystemRequirements>
        </bf:systemRequirements>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='540']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="instance540">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='540' or @tag='880']" mode="instance540">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:usageAndAccessPolicy>
          <bf:UsePolicy>
            <xsl:for-each select="marc:subfield[@code='a']">
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </rdfs:label>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='c']">
              <bf:source>
                <bf:Source>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:Source>
              </bf:source>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='d']">
              <xsl:variable name="vLabel">
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString" select="."/>
                </xsl:call-template>
              </xsl:variable>
              <bf:note>
                <bf:Note>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:text>Authorized users: </xsl:text><xsl:value-of select="$vLabel"/>
                  </rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:for-each>
            <xsl:apply-templates select="marc:subfield[@code='u']" mode="subfieldu">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='5']" mode="subfield5">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:UsePolicy>
        </bf:usageAndAccessPolicy>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield" mode="instanceNote5XX">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pNoteType"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:choose>
        <xsl:when test="$vTag='513' or $vTag='545'">
          <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='b']"/>
        </xsl:when>
        <xsl:when test="$vTag='544'">
          <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='e' or @code='n']"/>
        </xsl:when>
        <xsl:when test="$vTag='555'">
          <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a']"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vNoteType">
      <xsl:choose>
        <xsl:when test="$vTag='501'">with</xsl:when>
        <xsl:when test="$vTag='504'">bibliography</xsl:when>
        <xsl:when test="$vTag='513'">report type</xsl:when>
        <xsl:when test="$vTag='515'">issuance information</xsl:when>
        <xsl:when test="$vTag='516'">type of computer data</xsl:when>
        <xsl:when test="$vTag='536'">funding information</xsl:when>
        <xsl:when test="$vTag='544' or $vTag='581'">related material</xsl:when>
        <xsl:when test="$vTag='545'">
          <xsl:choose>
            <xsl:when test="@ind1='0'">biographical data</xsl:when>
            <xsl:when test="@ind1='1'">administrative history</xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$vTag='550'">issuing body</xsl:when>
        <xsl:when test="$vTag='555'">
          <xsl:choose>
            <xsl:when test="@ind1=' '">index</xsl:when>
            <xsl:when test="@ind1='0'">finding aid</xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$vTag='585'">exhibition</xsl:when>
        <xsl:when test="$vTag='586'">award</xsl:when>
        <xsl:when test="$vTag='588'">description source</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:note>
          <bf:Note>
            <xsl:if test="$vLabel != ''">
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="normalize-space($vLabel)"/>
              </rdfs:label>
            </xsl:if>
            <xsl:if test="$vNoteType != ''">
              <bf:noteType><xsl:value-of select="$vNoteType"/></bf:noteType>
            </xsl:if>
            <!-- special handling for other subfields -->
            <xsl:choose>
              <xsl:when test="$vTag='504'">
                <xsl:for-each select="marc:subfield[@code='b']">
                  <bf:count><xsl:value-of select="."/></bf:count>
                </xsl:for-each>
              </xsl:when>
              <xsl:when test="$vTag='536'">
                <xsl:for-each select="marc:subfield[@code='b' or @code='c' or @code='d' or @code='e' or @code='f' or @code='g' or @code='h']">
                  <xsl:variable name="vDisplayConst">
                    <xsl:choose>
                      <xsl:when test="@code='b'">Contract: </xsl:when>
                      <xsl:when test="@code='c'">Grant: </xsl:when>
                      <xsl:when test="@code='e'">Program element: </xsl:when>
                      <xsl:when test="@code='f'">Project: </xsl:when>
                      <xsl:when test="@code='g'">Task: </xsl:when>
                      <xsl:when test="@code='h'">Work unit: </xsl:when>
                    </xsl:choose>
                  </xsl:variable>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$vDisplayConst"/><xsl:value-of select="."/>
                  </rdfs:label>
                </xsl:for-each>
              </xsl:when>
              <xsl:when test="$vTag='581'">
                <xsl:for-each select="marc:subfield[@code='z']">
                  <bf:identifiedBy>
                    <bf:Isbn>
                      <rdf:value><xsl:value-of select="."/></rdf:value>
                    </bf:Isbn>
                  </bf:identifiedBy>
                </xsl:for-each>
              </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="marc:subfield[@code='u']" mode="subfieldu">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='5']" mode="subfield5">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Note>
        </bf:note>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='541' or @tag='561' or @tag='563' or @tag='583']" mode="hasItem">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vItemUri"><xsl:value-of select="$recordid"/>#Item<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="marc:subfield[@code='3' or @code='5']">
        <xsl:choose>
          <xsl:when test="$serialization='rdfxml'">
            <bf:hasItem>
              <bf:Item>
                <xsl:attribute name="rdf:about"><xsl:value-of select="$vItemUri"/></xsl:attribute>
                <xsl:apply-templates select="." mode="item5XX">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
                <bf:itemOf>
                  <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
                </bf:itemOf>
                <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="marc:subfield[@code='5']" mode="subfield5">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </bf:Item>
            </bf:hasItem>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="generate-id(.) = generate-id(../marc:datafield[@tag='541' or @tag='561' or @tag='563' or @tag='583'][not(marc:subfield[@code='3' or @code='5'])][position()=1])">
          <xsl:apply-templates select="../marc:datafield[@tag='541' or @tag='561' or @tag='563' or @tag='583'][not(marc:subfield[@code='3' or @code='5'])]" mode="hasItem5XX">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="recordid" select="$recordid"/>
            <xsl:with-param name="pItemUri" select="$vItemUri"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='541' or @tag='561' or @tag='563' or @tag='583']" mode="hasItem5XX">
    <xsl:param name="recordid"/>
    <xsl:param name="pItemUri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
      <xsl:if test="position() = 1">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <bf:hasItem>
              <bf:Item>
                <xsl:attribute name="rdf:about"><xsl:value-of select="$pItemUri"/></xsl:attribute>
                <xsl:apply-templates select="../marc:datafield[@tag='541' or @tag='561' or @tag='563' or @tag='583'][not(marc:subfield[@code='3' or @code='5'])]" mode="item5XX">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
                <bf:itemOf>
                  <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
                </bf:itemOf>
              </bf:Item>
            </bf:hasItem>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
  </xsl:template><xsl:template match="marc:datafield[@tag='541']" mode="item5XX">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vLabel">
      <xsl:apply-templates select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='e' or @code='f' or @code='h' or @code='n' or @code='o']" mode="concat-nodes-space"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:immediateAcquisition>
          <bf:ImmediateAcquisition>
            <rdfs:label><xsl:value-of select="normalize-space($vLabel)"/></rdfs:label>
          </bf:ImmediateAcquisition>
        </bf:immediateAcquisition>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='561']" mode="item5XX">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:custodialHistory><xsl:value-of select="."/></bf:custodialHistory>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='563']" mode="item5XX">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:note>
            <bf:Note>
              <bf:noteType>binding</bf:noteType>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:Note>
          </bf:note>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='583']" mode="item5XX">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:note>
          <bf:Note>
            <bf:noteType>action</bf:noteType>
            <xsl:for-each select="marc:subfield[@code='a']">
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='c']">
              <bf:date><xsl:value-of select="."/></bf:date>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='h']">
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='k']">
              <bf:agent>
                <bf:Agent>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                </bf:Agent>
              </bf:agent>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='l']">
              <bf:status>
                <bf:Status>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                </bf:Status>
              </bf:status>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='z']">
              <bf:note>
                <bf:Note>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:for-each>
            <xsl:apply-templates select="marc:subfield[@code='u']" mode="subfieldu">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='2']" mode="subfield2">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Note>
        </bf:note>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='648' or @tag='650' or @tag='651'] |                        marc:datafield[@tag='655'][@ind1=' ']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vTopicUri">
      <xsl:choose>
        <xsl:when test="@tag='648'">
          <xsl:value-of select="$recordid"/>#Temporal<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/>
        </xsl:when>
        <xsl:when test="@tag='655'">
          <xsl:value-of select="$recordid"/>#GenreForm<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$recordid"/>#Topic<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="." mode="work6XXAuth">
      <xsl:with-param name="pTopicUri" select="$vTopicUri"/>
      <xsl:with-param name="recordid" select="$recordid"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work6XXAuth">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:param name="pTopicUri"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vProp">
      <xsl:choose>
        <xsl:when test="$vTag='655'">bf:genreForm</xsl:when>
        <xsl:otherwise>bf:subject</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vResource">
      <xsl:choose>
        <xsl:when test="$vTag='648'">bf:Temporal</xsl:when>
        <xsl:when test="$vTag='651'">bf:Place</xsl:when>
        <xsl:when test="$vTag='655'">bf:GenreForm</xsl:when>
        <xsl:otherwise>bf:Topic</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vSourceCode"><xsl:value-of select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/code"/></xsl:variable>
    <xsl:variable name="vMADSClass">
      <xsl:choose>
        <xsl:when test="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">ComplexSubject</xsl:when>
        <xsl:when test="$vTag='648'">Temporal</xsl:when>
        <xsl:when test="$vTag='650'">
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='b' or @code='c' or @code='d']">ComplexSubject</xsl:when>
            <xsl:otherwise>Topic</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$vTag='651'">
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='b']">ComplexSubject</xsl:when>
            <xsl:otherwise>Geographic</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$vTag='655'">GenreForm</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
        <xsl:with-param name="chopString">
          <xsl:choose>
            <xsl:when test="$vTag='650'">
              <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='v' or @code='x' or @code='y' or @code='z']">
                <xsl:value-of select="concat(.,'--')"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$vTag='651'">
              <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='v' or @code='x' or @code='y' or @code='z']">
                <xsl:value-of select="concat(.,'--')"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="marc:subfield[@code='a' or @code='v' or @code='x' or @code='y' or @code='z']">
                <xsl:value-of select="concat(.,'--')"/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:element name="{$vProp}">
          <xsl:element name="{$vResource}">
            <xsl:attribute name="rdf:about"><xsl:value-of select="$pTopicUri"/></xsl:attribute>
            <rdf:type>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($madsrdf,$vMADSClass)"/></xsl:attribute>
            </rdf:type>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$vLabel"/>
            </rdfs:label>
            <madsrdf:authoritativeLabel>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$vLabel"/>
            </madsrdf:authoritativeLabel>
            <xsl:for-each select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/madsscheme">
              <madsrdf:isMemberofMADSScheme>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
              </madsrdf:isMemberofMADSScheme>
            </xsl:for-each>
            <!-- build the ComplexSubject -->
            <xsl:if test="$vMADSClass='ComplexSubject'">
              <madsrdf:componentList rdf:parseType="Collection">
                <xsl:choose>
                  <xsl:when test="$vTag='650'">
                    <xsl:apply-templates select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='v' or @code='x' or @code='y' or @code='z']" mode="complexSubject">
                      <xsl:with-param name="serialization" select="$serialization"/>
                      <xsl:with-param name="pTag" select="$vTag"/>
                      <xsl:with-param name="pXmlLang" select="$vXmlLang"/>
                    </xsl:apply-templates>
                  </xsl:when>
                  <xsl:when test="$vTag='651'">
                    <xsl:apply-templates select="marc:subfield[@code='a' or @code='b' or @code='v' or @code='x' or @code='y' or @code='z']" mode="complexSubject">
                      <xsl:with-param name="serialization" select="$serialization"/>
                      <xsl:with-param name="pTag" select="$vTag"/>
                      <xsl:with-param name="pXmlLang" select="$vXmlLang"/>
                    </xsl:apply-templates>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="marc:subfield[@code='a' or @code='v' or @code='x' or @code='y' or @code='z']" mode="complexSubject">
                      <xsl:with-param name="serialization" select="$serialization"/>
                      <xsl:with-param name="pTag" select="$vTag"/>
                      <xsl:with-param name="pXmlLang" select="$vXmlLang"/>
                    </xsl:apply-templates>
                  </xsl:otherwise>
                </xsl:choose>
              </madsrdf:componentList>
            </xsl:if>
            <xsl:for-each select="marc:subfield[@code='g']">
              <bf:note>
                <bf:Note>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:for-each>
            <xsl:choose>
              <xsl:when test="$vSourceCode != ''">
                <bf:source>
                  <bf:Source>
                    <bf:code><xsl:value-of select="$vSourceCode"/></bf:code>
                  </bf:Source>
                </bf:source>
              </xsl:when>
              <xsl:when test="@ind2='7'">
                <bf:source>
                  <bf:Source>
                    <bf:code><xsl:value-of select="marc:subfield[@code='2']"/></bf:code>
                  </bf:Source>
                </bf:source>
              </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="marc:subfield[@code='e']" mode="contributionRole">
              <xsl:with-param name="serialization" select="$serialization"/>
              <xsl:with-param name="pMode">relationship</xsl:with-param>
              <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
            </xsl:apply-templates>
            <xsl:for-each select="marc:subfield[@code='4']">
              <bflc:relationship>
                <bflc:Relationship>
                  <bflc:relation>
                    <rdfs:Resource>
                      <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,substring(.,1,3))"/></xsl:attribute>
                    </rdfs:Resource>
                  </bflc:relation>
                  <bf:relatedTo>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
                  </bf:relatedTo>
                </bflc:Relationship>
              </bflc:relationship>
            </xsl:for-each>
            <xsl:apply-templates mode="subfield0orw" select="marc:subfield[@code='0']">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="subfield3" select="marc:subfield[@code='3']">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="subfield5" select="marc:subfield[@code='5']">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </xsl:element>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='653']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work653">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work653">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vProp">
      <xsl:choose>
        <xsl:when test="@ind2='6'">bf:genreForm</xsl:when>
        <xsl:otherwise>bf:subject</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vResource">
      <xsl:choose>
        <xsl:when test="@ind2='1'">bf:Person</xsl:when>
        <xsl:when test="@ind2='2'">bf:Organization</xsl:when>
        <xsl:when test="@ind2='3'">bf:Meeting</xsl:when>
        <xsl:when test="@ind2='4'">bf:Temporal</xsl:when>
        <xsl:when test="@ind2='5'">bf:Place</xsl:when>
        <xsl:when test="@ind2='6'">bf:GenreForm</xsl:when>
        <xsl:otherwise>bf:Topic</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
        <xsl:with-param name="chopString">
          <xsl:for-each select="marc:subfield[@code='a']">
            <xsl:value-of select="concat(.,'--')"/>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:element name="{$vProp}">
          <xsl:element name="{$vResource}">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$vLabel"/>
            </rdfs:label>
          </xsl:element>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='656']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work656">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work656">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
        <xsl:with-param name="chopString">
          <xsl:for-each select="marc:subfield[@code='a' or @code='z']">
            <xsl:value-of select="concat(.,'--')"/>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:subject>
          <bf:Topic>
            <rdf:type>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($madsrdf,'ComplexSubject')"/></xsl:attribute>
            </rdf:type>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$vLabel"/>
            </rdfs:label>
            <madsrdf:componentList rdf:parseType="Collection">
              <xsl:apply-templates select="marc:subfield[@code='a' or @code='k' or @code='v' or @code='x' or @code='y' or @code='z']" mode="complexSubject">
                <xsl:with-param name="serialization" select="$serialization"/>
                <xsl:with-param name="pTag" select="$vTag"/>
                <xsl:with-param name="pXmlLang" select="$vXmlLang"/>
              </xsl:apply-templates>
            </madsrdf:componentList>
            <xsl:apply-templates select="marc:subfield[@code='0']" mode="subfield0orw">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='2']" mode="subfield2">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Topic>
        </bf:subject>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='662']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="work662">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work662">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
        <xsl:with-param name="chopString">
          <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='f' or @code='g' or @code='h']">
            <xsl:value-of select="concat(.,'--')"/>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:subject>
          <bf:Place>
            <rdf:type>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($madsrdf,'HierarchicalGeographic')"/></xsl:attribute>
            </rdf:type>
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$vLabel"/>
            </rdfs:label>
            <madsrdf:componentList rdf:parseType="Collection">
              <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='f' or @code='g' or @code='h']">
                <xsl:variable name="vResource">
                  <xsl:choose>
                    <xsl:when test="@code='a'">madsrdf:Country</xsl:when>
                    <xsl:when test="@code='b'">madsrdf:County</xsl:when>
                    <xsl:when test="@code='c'">madsrdf:State</xsl:when>
                    <xsl:when test="@code='d'">madsrdf:City</xsl:when>
                    <xsl:when test="@code='f'">madsrdf:CitySection</xsl:when>
                    <xsl:when test="@code='g'">madsrdf:Region</xsl:when>
                    <xsl:when test="@code='h'">madsrdf:ExtraterrestrialArea</xsl:when>
                  </xsl:choose>
                </xsl:variable>
                <xsl:element name="{$vResource}">
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                    </xsl:call-template>
                  </rdfs:label>
                </xsl:element>
              </xsl:for-each>
            </madsrdf:componentList>
            <xsl:apply-templates select="marc:subfield[@code='0']" mode="subfield0orw">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='2']" mode="subfield2">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Place>
        </bf:subject>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:subfield" mode="complexSubject">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pTag"/>
    <xsl:param name="pXmlLang"/>
    <xsl:variable name="vLabelProp">
      <xsl:choose>
        <xsl:when test="$pTag='656'">rdfs:label</xsl:when>
        <xsl:otherwise>madsrdf:authoritativeLabel</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vMADSClass">
      <xsl:choose>
        <xsl:when test="@code='v'">madsrdf:GenreForm</xsl:when>
        <xsl:when test="@code='x'">madsrdf:Topic</xsl:when>
        <xsl:when test="@code='y'">madsrdf:Temporal</xsl:when>
        <xsl:when test="@code='z'">madsrdf:Geographic</xsl:when>
        <xsl:when test="$pTag='648'">madsrdf:Temporal</xsl:when>
        <xsl:when test="$pTag='650'">
          <xsl:choose>
            <xsl:when test="@code='c'">madsrdf:Geographic</xsl:when>
            <xsl:when test="@code='d'">madsrdf:Temporal</xsl:when>
            <xsl:otherwise>madsrdf:Topic</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$pTag='651'">madsrdf:Geographic</xsl:when>
        <xsl:when test="$pTag='655'">madsrdf:GenreForm</xsl:when>
        <xsl:when test="$pTag='656'">
          <xsl:choose>
            <xsl:when test="@code='a'">madsrdf:Occupation</xsl:when>
            <xsl:when test="@code='k'">madsrdf:GenreForm</xsl:when>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:element name="{$vMADSClass}">
          <xsl:element name="{$vLabelProp}">
            <xsl:if test="$pXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString" select="."/>
            </xsl:call-template>
          </xsl:element>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='752']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:apply-templates select="." mode="work752">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="recordid" select="$recordid"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work752">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="vLabel">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
        <xsl:with-param name="chopString">
          <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='f' or @code='g' or @code='h']">
            <xsl:value-of select="concat(.,'--')"/>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:place>
          <bf:Place>
            <rdf:type>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($madsrdf,'HierarchicalGeographic')"/></xsl:attribute>
            </rdf:type>
            <rdfs:label><xsl:value-of select="$vLabel"/></rdfs:label>
            <madsrdf:componentList rdf:parseType="Collection">
              <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='f' or @code='g' or @code='h']">
                <xsl:variable name="vResource">
                  <xsl:choose>
                    <xsl:when test="@code='a'">madsrdf:Country</xsl:when>
                    <xsl:when test="@code='b'">madsrdf:County</xsl:when>
                    <xsl:when test="@code='c'">madsrdf:State</xsl:when>
                    <xsl:when test="@code='d'">madsrdf:City</xsl:when>
                    <xsl:when test="@code='f'">madsrdf:CitySection</xsl:when>
                    <xsl:when test="@code='g'">madsrdf:Region</xsl:when>
                    <xsl:when test="@code='h'">madsrdf:ExtraterrestrialArea</xsl:when>
                  </xsl:choose>
                </xsl:variable>
                <xsl:element name="{$vResource}">
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                    </xsl:call-template>
                  </rdfs:label>
                </xsl:element>
              </xsl:for-each>
            </madsrdf:componentList>
            <xsl:apply-templates select="marc:subfield[@code='0']" mode="subfield0orw">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='2']" mode="subfield2">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='e']" mode="contributionRole">
              <xsl:with-param name="pMode">relationship</xsl:with-param>
              <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:for-each select="marc:subfield[@code='4']">
              <bflc:relationship>
                <bflc:Relationship>
                  <bflc:relation>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($relators,substring(.,1,3))"/></xsl:attribute>
                  </bflc:relation>
                  <bf:relatedTo>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
                  </bf:relatedTo>
                </bflc:Relationship>
              </bflc:relationship>
            </xsl:for-each>
          </bf:Place>
        </bf:place>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='753']" mode="instance">
    <xsl:param name="serialization" select="$serialization"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c']">
          <xsl:variable name="vResource">
            <xsl:choose>
              <xsl:when test="@code='a'">bflc:MachineModel</xsl:when>
              <xsl:when test="@code='b'">bflc:ProgrammingLanguage</xsl:when>
              <xsl:when test="@code='c'">bflc:OperatingSystem</xsl:when>
            </xsl:choose>
          </xsl:variable>
          <bf:systemRequirement>
            <xsl:element name="{$vResource}">
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
              <xsl:if test="following-sibling::marc:subfield[position()=1]/@code='0'">
                <xsl:apply-templates select="following-sibling::marc:subfield[position()=1]" mode="subfield0orw">
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </xsl:if>
              <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:element>
          </bf:systemRequirement>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template mode="work" match="marc:datafield[@tag='765'] |                                    marc:datafield[@tag='767'] |                                    marc:datafield[@tag='770'] |                                    marc:datafield[@tag='772'] |                                    marc:datafield[@tag='773'] |                                    marc:datafield[@tag='774'] |                                    marc:datafield[@tag='775'] |                                    marc:datafield[@tag='777'] |                                    marc:datafield[@tag='780'] |                                    marc:datafield[@tag='785'] |                                    marc:datafield[@tag='786'] |                                    marc:datafield[@tag='787']">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vWorkUri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates select="." mode="work7XXLinks">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pWorkUri" select="$vWorkUri"/>
      <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="work7XXLinks">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pWorkUri"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vProperty">
      <xsl:choose>
        <xsl:when test="$vTag='765'">bf:translationOf</xsl:when>
        <xsl:when test="$vTag='767'">bf:translation</xsl:when>
        <xsl:when test="$vTag='770'">bf:supplement</xsl:when>
        <xsl:when test="$vTag='772'">bf:supplementTo</xsl:when>
        <xsl:when test="$vTag='773'">bf:partOf</xsl:when>
        <xsl:when test="$vTag='774'">bf:hasPart</xsl:when>
        <xsl:when test="$vTag='775'">bf:otherEdition</xsl:when>
        <xsl:when test="$vTag='777'">bf:issuedWith</xsl:when>
        <xsl:when test="$vTag='780'">
          <xsl:choose>
            <xsl:when test="@ind2='0'">bf:continues</xsl:when>
            <xsl:when test="@ind2='1'">bf:continuesInPart</xsl:when>
            <xsl:when test="@ind2='4'">bf:mergerOf</xsl:when>
            <xsl:when test="@ind2='5' or @ind2='6'">bf:absorbed</xsl:when>
            <xsl:when test="@ind2='7'">bf:separatedFrom</xsl:when>
            <xsl:otherwise>bf:precededBy</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$vTag='785'">
          <xsl:choose>
            <xsl:when test="@ind2='0' or @ind2='8'">bf:continuedBy</xsl:when>
            <xsl:when test="@ind2='1'">bf:continuedInPartBy</xsl:when>
            <xsl:when test="@ind2='4' or @ind2='5'">bf:absorbedBy</xsl:when>
            <xsl:when test="@ind2='6'">bf:splitInto</xsl:when>
            <xsl:when test="@ind2='7'">bf:mergedToForm</xsl:when>
            <xsl:otherwise>bf:succeededBy</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$vTag='786'">bf:dataSource</xsl:when>
        <xsl:when test="$vTag='787'">bf:relatedTo</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="." mode="link7XX">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pTag" select="$vTag"/>
      <xsl:with-param name="pProperty" select="$vProperty"/>
      <xsl:with-param name="pElement">bf:Work</xsl:with-param>
      <xsl:with-param name="pWorkUri" select="$pWorkUri"/>
      <xsl:with-param name="pInstanceUri" select="$pInstanceUri"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='760' or @tag='762']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vWorkUri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates select="." mode="instance7XXLinks">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pWorkUri" select="$vWorkUri"/>
      <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="instance7XXLinks">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pWorkUri"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vProperty">
      <xsl:choose>
        <xsl:when test="$vTag='760'">bf:hasSeries</xsl:when>
        <xsl:when test="$vTag='762'">bf:hasSubseries</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="." mode="link7XX">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pTag" select="$vTag"/>
      <xsl:with-param name="pProperty" select="$vProperty"/>
      <xsl:with-param name="pElement">bf:Work</xsl:with-param>
      <xsl:with-param name="pWorkUri" select="$pWorkUri"/>
      <xsl:with-param name="pInstanceUri" select="$pInstanceUri"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='776']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vWorkUri"><xsl:value-of select="$recordid"/>#Work</xsl:variable>
    <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates select="." mode="instance776">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pWorkUri" select="$vWorkUri"/>
      <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield[@tag='776' or @tag='880']" mode="instance776">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pWorkUri"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="." mode="link7XX">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="pTag" select="$vTag"/>
      <xsl:with-param name="pProperty">bf:otherPhysicalFormat</xsl:with-param>
      <xsl:with-param name="pElement">bf:Instance</xsl:with-param>
      <xsl:with-param name="pWorkUri" select="$pWorkUri"/>
      <xsl:with-param name="pInstanceUri" select="$pInstanceUri"/>
    </xsl:apply-templates>
  </xsl:template><xsl:template match="marc:datafield" mode="link7XX">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pTag"/>
    <xsl:param name="pProperty"/>
    <xsl:param name="pElement"/>
    <xsl:param name="pWorkUri"/>
    <xsl:param name="pInstanceUri"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:element name="{$pProperty}">
          <xsl:element name="{$pElement}">
            <xsl:attribute name="rdf:about">
              <xsl:choose>
                <xsl:when test="$pTag='776'"><xsl:value-of select="$pInstanceUri"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$pWorkUri"/></xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:for-each select="marc:subfield[@code='a']">
              <bf:contribution>
                <bflc:PrimaryContribution>
                  <bf:agent>
                    <bf:Agent>
                      <rdfs:label>
                        <xsl:if test="$vXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="."/>
                      </rdfs:label>
                    </bf:Agent>
                  </bf:agent>
                </bflc:PrimaryContribution>
              </bf:contribution>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='c']">
              <bf:title>
                <bf:Title>
                  <bf:qualifier>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </bf:qualifier>
                </bf:Title>
              </bf:title>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='e']">
              <bf:language>
                <bf:Language>
                  <xsl:attribute name="rdf:about"><xsl:value-of select="concat($languages,.)"/></xsl:attribute>
                </bf:Language>
              </bf:language>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='i']">
              <bflc:relationship>
                <bflc:Relationship>
                  <bflc:relation>
                    <rdfs:Resource>
                      <rdfs:label>
                        <xsl:if test="$vXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="chopPunctuation">
                          <xsl:with-param name="chopString">
                            <xsl:value-of select="."/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </rdfs:label>
                    </rdfs:Resource>
                  </bflc:relation>
                  <bf:relatedTo>
                    <xsl:attribute name="rdf:resource">
                      <xsl:choose>
                        <xsl:when test="$pTag='776'"><xsl:value-of select="substring-before($pWorkUri,'#')"/>#Instance</xsl:when>
                        <xsl:otherwise><xsl:value-of select="substring-before($pWorkUri,'#')"/>#Work</xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                  </bf:relatedTo>
                </bflc:Relationship>
              </bflc:relationship>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='s']">
              <bf:title>
                <bf:Title>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </rdfs:label>
                </bf:Title>
              </bf:title>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='v']">
              <bf:note>
                <bf:Note>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:for-each>
            <xsl:apply-templates select="marc:subfield[@code='w']" mode="subfield0orw">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code='3']" mode="subfield3">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
            <xsl:choose>
              <xsl:when test="$pTag='776'">
                <xsl:apply-templates select="." mode="link7XXinstance">
                  <xsl:with-param name="serialization" select="$serialization"/>
                  <xsl:with-param name="pWorkUri" select="$pWorkUri"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <bf:hasInstance>
                  <bf:Instance>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$pInstanceUri"/></xsl:attribute>
                    <xsl:apply-templates select="." mode="link7XXinstance">
                      <xsl:with-param name="serialization" select="$serialization"/>
                      <xsl:with-param name="pWorkUri" select="$pWorkUri"/>
                    </xsl:apply-templates>
                  </bf:Instance>
                </bf:hasInstance>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield" mode="link7XXinstance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pWorkUri"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='b']">
          <bf:editionStatement>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
          </bf:editionStatement>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='d']">
          <bf:provisionActivityStatement>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
          </bf:provisionActivityStatement>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='f']">
          <bf:provisionActivity>
            <bf:ProvisionActivity>
              <bf:place>
                <bf:Place>
                  <xsl:attribute name="rdf:about"><xsl:value-of select="concat($countries,.)"/></xsl:attribute>
                </bf:Place>
              </bf:place>
            </bf:ProvisionActivity>
          </bf:provisionActivity>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='g']">
          <bf:part>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
          </bf:part>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='h']">
          <bf:extent>
            <bf:Extent>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
            </bf:Extent>
          </bf:extent>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='k']">
          <bf:seriesStatement>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
          </bf:seriesStatement>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='m' or @code='n']">
          <bf:note>
            <bf:Note>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
            </bf:Note>
          </bf:note>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='r']">
          <bf:identifiedBy>
            <bf:ReportNumber>
              <rdf:value><xsl:value-of select="."/></rdf:value>
            </bf:ReportNumber>
          </bf:identifiedBy>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='t']">
          <bf:title>
            <bf:Title>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rdfs:label>
            </bf:Title>
          </bf:title>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='u' or @code='x' or @code='y' or @code='z']">
          <xsl:variable name="vIdentifier">
            <xsl:choose>
              <xsl:when test="@code='u'">bf:Strn</xsl:when>
              <xsl:when test="@code='x'">bf:Issn</xsl:when>
              <xsl:when test="@code='y'">bf:Coden</xsl:when>
              <xsl:when test="@code='z'">bf:Isbn</xsl:when>
            </xsl:choose>
          </xsl:variable>
          <bf:identifiedBy>
            <xsl:element name="{$vIdentifier}">
              <rdf:value><xsl:value-of select="."/></rdf:value>
            </xsl:element>
          </bf:identifiedBy>
        </xsl:for-each>
        <bf:instanceOf>
          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pWorkUri"/></xsl:attribute>
        </bf:instanceOf>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='856']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:if test="marc:subfield[@code='u'] and                   (@ind2='1' or                   (@ind2 != '0' and @ind2 != '2' and                   substring(../marc:leader,7,1) != 'm' and                   substring(../marc:controlfield[@tag='007'],1,1) != 'c' and                   substring(../marc:controlfield[@tag='008'],24,1) != 'q' and                   substring(../marc:controlfield[@tag='008'],24,1) != 's'))">
      <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
      <xsl:variable name="vItemUri"><xsl:value-of select="$recordid"/>#Item<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:hasInstance>
            <bf:Instance>
              <xsl:attribute name="rdf:about"><xsl:value-of select="$vInstanceUri"/></xsl:attribute>
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Electronic')"/></xsl:attribute>
              </rdf:type>
              <xsl:if test="../marc:datafield[@tag='245']">
                <bf:title>
                  <xsl:apply-templates mode="title245" select="../marc:datafield[@tag='245']">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="label">
                      <xsl:apply-templates mode="concat-nodes-space" select="../marc:datafield[@tag='245']/marc:subfield[@code='a' or                                                    @code='b' or                                                    @code='f' or                                                     @code='g' or                                                    @code='k' or                                                    @code='n' or                                                    @code='p' or                                                    @code='s']"/>
                    </xsl:with-param>
                  </xsl:apply-templates>
                </bf:title>
              </xsl:if>
              <bf:hasItem>
                <bf:Item>
                  <xsl:attribute name="rdf:about"><xsl:value-of select="$vItemUri"/></xsl:attribute>
                  <xsl:apply-templates select="." mode="locator856">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="pProp">bf:electronicLocator</xsl:with-param>
                  </xsl:apply-templates>
                  <bf:itemOf>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$vInstanceUri"/></xsl:attribute>
                  </bf:itemOf>
                </bf:Item>
              </bf:hasItem>
              <bf:instanceOf>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
              </bf:instanceOf>
            </bf:Instance>
          </bf:hasInstance>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template><xsl:template match="marc:datafield[@tag='856']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:if test="marc:subfield[@code='u'] and @ind2='2'">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <xsl:apply-templates select="." mode="locator856">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="pProp">bf:supplementaryContent</xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template><xsl:template match="marc:datafield[@tag='850' or @tag='852']" mode="hasItem">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vItemUri"><xsl:value-of select="$recordid"/>#Item<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="vAddress">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:for-each select="marc:subfield[@code='e' or @code='n']">
            <xsl:value-of select="concat(.,', ')"/>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:hasItem>
            <bf:Item>
              <xsl:attribute name="rdf:about"><xsl:value-of select="$vItemUri"/></xsl:attribute>
              <bf:heldBy>
                <bf:Agent>
                  <xsl:choose>
                    <xsl:when test="string-length(.) &lt; 10">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="concat($organizations,.)"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <rdfs:label><xsl:value-of select="."/></rdfs:label>
                    </xsl:otherwise>
                  </xsl:choose>
                </bf:Agent>
              </bf:heldBy>
              <xsl:if test="../@tag='852'">
                <xsl:for-each select="../marc:subfield[@code='b']">
                  <bf:subLocation>
                    <bf:SubLocation>
                      <rdfs:label><xsl:value-of select="."/></rdfs:label>
                    </bf:SubLocation>
                  </bf:subLocation>
                </xsl:for-each>
                <xsl:if test="$vAddress != ''">
                  <bf:subLocation>
                    <bf:SubLocation>
                      <rdfs:label><xsl:value-of select="$vAddress"/></rdfs:label>
                    </bf:SubLocation>
                  </bf:subLocation>
                </xsl:if>
                <xsl:for-each select="../marc:subfield[@code='u']">
                  <bf:electronicLocator>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
                  </bf:electronicLocator>
                </xsl:for-each>
                <xsl:for-each select="../marc:subfield[@code='x' or @code='z']">
                  <bf:note>
                    <bf:Note>
                      <rdfs:label><xsl:value-of select="."/></rdfs:label>
                    </bf:Note>
                  </bf:note>
                </xsl:for-each>
              </xsl:if>
              <bf:itemOf>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
              </bf:itemOf>
            </bf:Item>
          </bf:hasItem>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='856']" mode="hasItem">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:if test="marc:subfield[@code='u'] and                   (@ind2='0' or                   substring(../marc:leader,7,1)='m' or                   substring(../marc:controlfield[@tag='007'],1,1)='c' or                   substring(../marc:controlfield[@tag='008'],24,1)='q' or                   substring(../marc:controlfield[@tag='008'],24,1)='s')">
      <xsl:variable name="vItemUri"><xsl:value-of select="$recordid"/>#Item<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:hasItem>
            <bf:Item>
              <xsl:attribute name="rdf:about"><xsl:value-of select="$vItemUri"/></xsl:attribute>
              <xsl:apply-templates select="." mode="locator856">
                <xsl:with-param name="serialization" select="$serialization"/>
                <xsl:with-param name="pProp">bf:electronicLocator</xsl:with-param>
              </xsl:apply-templates>
              <bf:itemOf>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
              </bf:itemOf>
            </bf:Item>
          </bf:hasItem>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template><xsl:template match="marc:datafield[@tag='856']" mode="locator856">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pProp"/>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <xsl:for-each select="marc:subfield[@code='u']">
          <xsl:element name="{$pProp}">
            <xsl:choose>
              <xsl:when test="../marc:subfield[@code='z' or @code='y' or @code='3']">
                <rdfs:Resource>
                  <bflc:locator>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
                  </bflc:locator>
                  <xsl:for-each select="../marc:subfield[@code='z' or @code='y' or @code='3']">
                    <bf:note>
                      <bf:Note>
                        <rdfs:label><xsl:value-of select="."/></rdfs:label>
                      </bf:Note>
                    </bf:note>
                  </xsl:for-each>
                </rdfs:Resource>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='880']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization"/>
    <xsl:variable name="tag"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$tag='052'">
        <xsl:apply-templates mode="work052" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='055'">
        <xsl:apply-templates mode="work055" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='072'">
        <xsl:apply-templates mode="work072" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='082'">
        <xsl:apply-templates mode="work082" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='084'">
        <xsl:apply-templates mode="work084" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='100' or $tag='110' or $tag='111'">
        <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates mode="workName" select=".">
          <xsl:with-param name="agentiri" select="$agentiri"/>
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='130' or $tag='240'">
        <xsl:apply-templates mode="workUnifTitle" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='243'">
        <xsl:apply-templates mode="work243" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='245'">
        <xsl:if test="not(../marc:datafield[@tag='130']) and not(../marc:datafield[@tag='240'])">
          <xsl:variable name="label">
            <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                          @code='b' or                                          @code='f' or                                           @code='g' or                                          @code='k' or                                          @code='n' or                                          @code='p' or                                          @code='s']"/>
          </xsl:variable>
          <xsl:apply-templates mode="work245" select=".">
            <xsl:with-param name="label" select="$label"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$tag='255'">
        <xsl:apply-templates mode="work255" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='336'">
        <xsl:apply-templates select="." mode="rdaResource">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:content</xsl:with-param>
          <xsl:with-param name="pResource">bf:Content</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='351'">
        <xsl:apply-templates select="." mode="work351">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='380'">
        <xsl:apply-templates select="." mode="work380">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='382'">
        <xsl:apply-templates select="." mode="work382">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='383'">
        <xsl:apply-templates select="." mode="work383">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='385' or $tag='386'">
        <xsl:apply-templates select="." mode="work385or386">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='502'">
        <xsl:apply-templates select="." mode="work502">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='508' or $tag='511'">
        <xsl:apply-templates select="." mode="workCreditsNote">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='518'">
        <xsl:apply-templates select="." mode="work518">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='520'">
        <xsl:apply-templates select="." mode="work520">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='522'">
        <xsl:apply-templates select="." mode="work522">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='530' or $tag='533' or $tag='534'">
        <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates select="." mode="hasInstance5XX">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
          <xsl:with-param name="recordid" select="$recordid"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='546'">
        <xsl:apply-templates select="." mode="work546">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='580'">
        <xsl:apply-templates select="." mode="work580">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='600' or $tag='610' or $tag='611'">
        <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates mode="work6XXName" select=".">
          <xsl:with-param name="agentiri" select="$agentiri"/>
          <xsl:with-param name="workiri" select="$workiri"/>
          <xsl:with-param name="recordid" select="$recordid"/>
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='630'">
        <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates mode="work630" select=".">
          <xsl:with-param name="workiri" select="$workiri"/>
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="recordid" select="$recordid"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="($tag='648' or $tag='650' or $tag='651') or ($tag='655' and @ind1=' ')">
        <xsl:variable name="vTopicUri">
          <xsl:choose>
            <xsl:when test="$tag='655'">
              <xsl:value-of select="$recordid"/>#GenreForm880-<xsl:value-of select="position()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$recordid"/>#Topic880-<xsl:value-of select="position()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates select="." mode="work6XXAuth">
          <xsl:with-param name="pTopicUri" select="$vTopicUri"/>
          <xsl:with-param name="recordid" select="$recordid"/>
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='653'">
        <xsl:apply-templates select="." mode="work653">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='656'">
        <xsl:apply-templates select="." mode="work656">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='662'">
        <xsl:apply-templates select="." mode="work662">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='700' or $tag='710' or $tag='711' or $tag='720'">
        <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates mode="work7XX" select=".">
          <xsl:with-param name="agentiri" select="$agentiri"/>
          <xsl:with-param name="workiri" select="$workiri"/>
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='730' or $tag='740'">
        <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates mode="work730" select=".">
          <xsl:with-param name="workiri" select="$workiri"/>
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='752'">
        <xsl:apply-templates select="." mode="work752">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="recordid" select="$recordid"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='765' or $tag='767' or $tag='770' or $tag='772' or $tag='773' or $tag='774' or $tag='775' or $tag='780' or $tag='785' or $tag='786' or $tag='787'">
        <xsl:variable name="vWorkUri"><xsl:value-of select="$recordid"/>#Work880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates select="." mode="work7XXLinks">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pWorkUri" select="$vWorkUri"/>
          <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
        </xsl:apply-templates>
      </xsl:when>        
      <xsl:when test="$tag='800' or $tag='810' or $tag='811'">
        <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates mode="work8XX" select=".">
          <xsl:with-param name="agentiri" select="$agentiri"/>
          <xsl:with-param name="workiri" select="$workiri"/>
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>        
      <xsl:when test="$tag='830'">
        <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates mode="work830" select=".">
          <xsl:with-param name="workiri" select="$workiri"/>
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>        
    </xsl:choose>
  </xsl:template><xsl:template match="marc:datafield[@tag='880']" mode="instance">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="tag"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$tag='086'">
        <xsl:apply-templates mode="instance086" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='210'">
        <xsl:apply-templates mode="instance210" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='222'">
        <xsl:apply-templates mode="instance222" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='242'">
        <xsl:apply-templates mode="instance242" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='245'">
        <xsl:variable name="label">
          <xsl:apply-templates mode="concat-nodes-space" select="marc:subfield[@code='a' or                                        @code='b' or                                        @code='f' or                                         @code='g' or                                        @code='k' or                                        @code='n' or                                        @code='p' or                                        @code='s']"/>
        </xsl:variable>
        <xsl:apply-templates mode="instance245" select=".">
          <xsl:with-param name="label" select="$label"/>
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='246'">
        <xsl:apply-templates mode="instance246" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='247'">
        <xsl:apply-templates mode="instance247" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='250'">
        <xsl:apply-templates mode="instance250" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='254'">
        <xsl:apply-templates mode="instance254" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='256'">
        <xsl:apply-templates mode="instance256" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='257'">
        <xsl:apply-templates mode="instance257" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='260' or $tag='262' or $tag='264'">
        <xsl:apply-templates mode="instance260" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='261'">
        <xsl:apply-templates mode="instance261" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='263'">
        <xsl:apply-templates mode="instance263" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='300'">
        <xsl:apply-templates mode="instance300" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='306'">
        <xsl:apply-templates mode="instance306" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='310' or $tag='321'">
        <xsl:apply-templates mode="instance310" select=".">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='337'">
        <xsl:apply-templates select="." mode="rdaResource">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:media</xsl:with-param>
          <xsl:with-param name="pResource">bf:Media</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='338'">
        <xsl:apply-templates select="." mode="rdaResource">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pProp">bf:carrier</xsl:with-param>
          <xsl:with-param name="pResource">bf:Carrier</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='340'">
        <xsl:apply-templates select="." mode="instance340">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='344'">
        <xsl:apply-templates select="." mode="instance344">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='345'">
        <xsl:apply-templates select="." mode="instance345">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='346'">
        <xsl:apply-templates select="." mode="instance346">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='347'">
        <xsl:apply-templates select="." mode="instance347">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='348'">
        <xsl:apply-templates select="." mode="instance348">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='350'">
        <xsl:apply-templates select="." mode="instance350">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='352'">
        <xsl:apply-templates select="." mode="instance352">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='362'">
        <xsl:apply-templates select="." mode="instance362">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='500' or $tag='501' or $tag='504' or                       $tag='513' or $tag='515' or $tag='516' or                       $tag='536' or $tag='544' or $tag='545' or                       $tag='547' or $tag='550' or $tag='555' or                       $tag='556' or $tag='581' or $tag='585' or                       $tag='586' or $tag='588'">
        <xsl:apply-templates select="." mode="instanceNote5XX">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='505'">
        <xsl:apply-templates select="." mode="instance505">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='506'">
        <xsl:apply-templates select="." mode="instance506">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='507'">
        <xsl:apply-templates select="." mode="instance507">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='510'">
        <xsl:apply-templates select="." mode="instance510">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='521'">
        <xsl:apply-templates select="." mode="instance521">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='525'">
        <xsl:apply-templates select="." mode="instance525">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='530'">
        <xsl:apply-templates select="." mode="instance530">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='533'">
        <xsl:apply-templates select="." mode="instance533">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='534'">
        <xsl:apply-templates select="." mode="instance534">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='538'">
        <xsl:apply-templates select="." mode="instance538">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='540'">
        <xsl:apply-templates select="." mode="instance540">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='760' or $tag='762'">
        <xsl:variable name="vWorkUri"><xsl:value-of select="$recordid"/>#Work880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates select="." mode="instance7XXLinks">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pWorkUri" select="$vWorkUri"/>
          <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$tag='766'">
        <xsl:variable name="vWorkUri"><xsl:value-of select="$recordid"/>#Work</xsl:variable>
        <xsl:variable name="vInstanceUri"><xsl:value-of select="$recordid"/>#Instance880-<xsl:value-of select="position()"/></xsl:variable>
        <xsl:apply-templates select="." mode="instance776">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pWorkUri" select="$vWorkUri"/>
          <xsl:with-param name="pInstanceUri" select="$vInstanceUri"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- namespace URIs -->
  <xsl:variable name="bf">http://id.loc.gov/ontologies/bibframe/</xsl:variable>
  <xsl:variable name="bflc">http://id.loc.gov/ontologies/bflc/</xsl:variable>
  <xsl:variable name="edtf">http://id.loc.gov/datatypes/</xsl:variable>
  <xsl:variable name="madsrdf">http://www.loc.gov/mads/rdf/v1#</xsl:variable>
  <xsl:variable name="xs">http://www.w3.org/2001/XMLSchema#</xsl:variable>

  <!-- id.loc.gov vocabulary stems -->
  <xsl:variable name="carriers">http://id.loc.gov/vocabulary/carriers/</xsl:variable>
  <xsl:variable name="classSchemes">http://id.loc.gov/vocabulary/classSchemes/</xsl:variable>
  <xsl:variable name="contentType">http://id.loc.gov/vocabulary/contentType/</xsl:variable>
  <xsl:variable name="countries">http://id.loc.gov/vocabulary/countries/</xsl:variable>
  <xsl:variable name="descriptionConventions">http://id.loc.gov/vocabulary/descriptionConventions/</xsl:variable>
  <xsl:variable name="genreForms">http://id.loc.gov/authorities/genreForms/</xsl:variable>
  <xsl:variable name="geographicAreas">http://id.loc.gov/vocabulary/geographicAreas/</xsl:variable>
  <xsl:variable name="graphicMaterials">http://id.loc.gov/vocabulary/graphicMaterials/</xsl:variable>
  <xsl:variable name="issuance">http://id.loc.gov/vocabulary/issuance/</xsl:variable>
  <xsl:variable name="languages">http://id.loc.gov/vocabulary/languages/</xsl:variable>
  <xsl:variable name="marcgt">http://id.loc.gov/vocabulary/marcgt/</xsl:variable>
  <xsl:variable name="mcolor">http://id.loc.gov/vocabulary/mcolor/</xsl:variable>
  <xsl:variable name="mediaType">http://id.loc.gov/vocabulary/mediaType/</xsl:variable>
  <xsl:variable name="mmaterial">http://id.loc.gov/vocabulary/mmaterial/</xsl:variable>
  <xsl:variable name="mplayback">http://id.loc.gov/vocabulary/mplayback/</xsl:variable>
  <xsl:variable name="mpolarity">http://id.loc.gov/vocabulary/mpolarity/</xsl:variable>
  <xsl:variable name="marcauthen">http://id.loc.gov/vocabulary/marcauthen/</xsl:variable>
  <xsl:variable name="marcmuscomp">http://id.loc.gov/vocabulary/marcmuscomp/</xsl:variable>
  <xsl:variable name="organizations">http://id.loc.gov/vocabulary/organizations/</xsl:variable>
  <xsl:variable name="relators">http://id.loc.gov/vocabulary/relators/</xsl:variable>

  <!-- configuration files -->

  <!-- subject thesaurus map -->
  <xsl:variable name="subjectThesaurus" select="document('conf/subjectThesaurus.xml')"/>

  <!-- language map -->
  <xsl:variable name="languageMap" select="document('conf/languageCrosswalk.xml')"/>

  <xsl:template match="/">

    <!-- RDF/XML document frame -->
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <rdf:RDF>

          <xsl:apply-templates>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
          
        </rdf:RDF>
      </xsl:when>
    </xsl:choose>
    
  </xsl:template>

  <xsl:template match="marc:collection">
    <xsl:param name="serialization"/>

    <!-- pass marc:record nodes on down -->
    <xsl:apply-templates>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="marc:record[@type='Bibliographic' or not(@type)]">
    <xsl:param name="serialization"/>

    <xsl:variable name="recordno"><xsl:value-of select="position()"/></xsl:variable>

    <xsl:variable name="recordid">
      <xsl:apply-templates mode="recordid" select=".">
        <xsl:with-param name="baseuri" select="$baseuri"/>
        <xsl:with-param name="idfield" select="$idfield"/>
        <xsl:with-param name="recordno" select="$recordno"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <!-- generate main Work entity -->
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Work>
          <xsl:attribute name="rdf:about"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
          <bf:adminMetadata>
            <bf:AdminMetadata>
              <!-- pass fields through conversion specs for AdminMetadata properties -->
              <xsl:apply-templates mode="adminmetadata">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:AdminMetadata>
          </bf:adminMetadata>
          <!-- pass fields through conversion specs for Work properties -->
          <xsl:apply-templates mode="work">
            <xsl:with-param name="recordid" select="$recordid"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
          <bf:hasInstance>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
          </bf:hasInstance>
        </bf:Work>
      </xsl:when>
    </xsl:choose>
    
    <!-- generate main Instance entity -->
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Instance>
          <xsl:attribute name="rdf:about"><xsl:value-of select="$recordid"/>#Instance</xsl:attribute>
          <!-- pass fields through conversion specs for Instance properties -->
          <xsl:apply-templates mode="instance">
            <xsl:with-param name="recordid" select="$recordid"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
          <bf:instanceOf>
            <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
          </bf:instanceOf>
          <!-- generate hasItem properties -->
          <xsl:apply-templates mode="hasItem">
            <xsl:with-param name="recordid" select="$recordid"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:Instance>
      </xsl:when>
    </xsl:choose>

  </xsl:template>

  <!-- suppress text from unmatched nodes -->
  <xsl:template match="text()" mode="adminmetadata"/>
  <xsl:template match="text()" mode="work"/>
  <xsl:template match="text()" mode="instance"/>
  <xsl:template match="text()" mode="hasItem"/>

  <!-- warn about other elements -->
  <xsl:template match="*">

    <xsl:message terminate="no">
      <xsl:text>WARNING: Unmatched element: </xsl:text><xsl:value-of select="name()"/>
    </xsl:message>

    <xsl:apply-templates/>

  </xsl:template>

</xsl:stylesheet>
