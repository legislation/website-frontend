<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet
xmlns:fo="http://www.w3.org/1999/XSL/Format"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="2.0"
xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata"
xmlns:leg="http://www.tso.co.uk/assets/namespace/legislation"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:output method="xml" version="1.0" omit-xml-declaration="no"  indent="no" standalone="no"/>

<xsl:variable name="g_strFolder" select="'file://c:/legislationdemo/fragments/'"/>

<xsl:template match="/">
	<xsl:apply-templates mode="Master"/>
</xsl:template>

<xsl:template match="*" mode="Master">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates mode="Master"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="*">
	<xsl:copy>
		<xsl:copy-of select="@*[not(local-name() = 'schemaLocation')]"/>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<xsl:template match="processing-instruction('FragmentFile')" mode="Master">
	<xsl:variable name="strDQ">"</xsl:variable>
	<xsl:variable name="strFilename" select="substring-before(substring-after(., $strDQ), $strDQ)"/>
	<xsl:apply-templates select="document(concat($g_strFolder, $strFilename))/leg:Legislation/*/*[self::leg:Body or self::leg:EUBody or self::leg:Schedules]/*"/>
</xsl:template>

</xsl:stylesheet>