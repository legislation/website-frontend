<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Template to convert Unicode characters to corresponding images. -->

<!-- Version 1.01 -->
<!-- Created by Manjit Jootle -->
<!-- Last changed 09/07/2007 by Jeni Tennison -->

<!-- Change history

	09/07/2007	JT	Made the template do less work by passing around relevant entities; also fixed bug whereby image file path wasn't getting passed through, and used style attribute on <img> element (height is deprecated)
	12/10/2006		Created

 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.w3.org/1999/xhtml">


<!-- ========== Global variables ========== -->

<xsl:variable name="g_ndsUnicodeCharsDoc" select="document('unicodecharacterstoimages.xml')"/>

<xsl:variable name="g_ndsUnicodeCharsToConvert" select="$g_ndsUnicodeCharsDoc/entities/entity"/>


<!-- ========== Main code for Unicode characters ========== -->

<xsl:template name="FuncProcessTextForUnicodeChars">
	<xsl:param name="strText"/>
	<xsl:param name="ndsUnicodeCharsToConvert" select="$g_ndsUnicodeCharsToConvert" />
	<xsl:param name="strPathToImages" select="''"/>
	
	<xsl:variable name="ndsEntities"
		select="$ndsUnicodeCharsToConvert[contains($strText, @unicode)]" />
	<xsl:variable name="ndsEntity" select="$ndsEntities[1]" />
	<xsl:choose>
		<xsl:when test="$ndsEntity">
			<!-- Get the text before the "unicode" attribute of the entity and process that. -->
			<xsl:call-template name="FuncProcessTextForUnicodeChars">
				<xsl:with-param name="strText">
					<xsl:value-of select="substring-before($strText, $ndsEntity/@unicode)"/>
				</xsl:with-param>
				<xsl:with-param name="strPathToImages" select="$strPathToImages" />
				<xsl:with-param name="ndsUnicodeCharsToConvert" 
					select="$ndsEntities[position() > 1]" />
			</xsl:call-template>
			
			<!-- Replace the current entity with the corresponding image. -->
			<img class="LegUnicodeCharacter" 
				   src="{$strPathToImages}{$ndsEntity/@image}" 
				   alt="{$ndsEntity/@explanation}" 
				   title="{$ndsEntity/@explanation}" 
				   style="height: 1em;" />
			
			<!-- Get the text after the "unicode" attribute of the entity and process that. -->
			<xsl:call-template name="FuncProcessTextForUnicodeChars">
				<xsl:with-param name="strText">
					<xsl:value-of select="substring-after($strText, $ndsEntity/@unicode)"/>
				</xsl:with-param>
				<xsl:with-param name="strPathToImages" select="$strPathToImages" />
				<xsl:with-param name="ndsUnicodeCharsToConvert" select="$ndsEntities" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$strText"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>
