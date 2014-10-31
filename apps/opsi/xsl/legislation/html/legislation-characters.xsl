<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
    xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.tso.co.uk/assets/namespace/error"
    xmlns:tso="http://www.tso.co.uk/assets/namespace/function"
xmlns:dc="http://purl.org/dc/elements/1.1/"
version="2.0">

<xsl:template match="leg:Character">
	<xsl:choose>
		<xsl:when test="@Name = 'DotPadding'">
			<xsl:text> ... ... ... ...</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'ThinSpace'">
			<xsl:text>&#160;</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'LinePadding'">
			<!--<span style="color: red">LINE PADDING TO SORT OUT</span>-->
		</xsl:when>
		<xsl:when test="@Name = 'NonBreakingSpace'">
			<xsl:text>&#160;</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'EnSpace'">
			<xsl:text>&#160;&#160;</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'EmSpace'">
			<xsl:text>&#160;&#160;</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<span style="color: red">CHARACTER TO SORT OUT</span>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="FuncCheckForEndOfQuote"/>	
</xsl:template>

</xsl:stylesheet>
