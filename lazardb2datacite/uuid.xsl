<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:edb="http://schema.programmfabrik.de/easydb-data/1.0">
  <xsl:output method="text"/>
  <xsl:template match="edb:objects">
    <xsl:value-of select="edb:objekttyp/edb:_uuid"/>
  </xsl:template>
</xsl:stylesheet>
