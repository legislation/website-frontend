<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs leg ukm err tso xhtml"
	version="2.0">

<xsl:output indent="no" />

<xsl:key name="acronyms" match="leg:Acronym" use="." />
<xsl:key name="abbreviations" match="leg:Abbreviation" use="." />
<xsl:key name="matchText" match="leg:Contents" use="tokenize(@MatchTextEntries, ' ')" />

<xsl:template match="/">
	<xsl:apply-templates select="." mode="filter" />
</xsl:template>

<!-- These templates are used to filter the acronyms and abbreviations down to the first occurrence -->

<xsl:template match="leg:Acronym" mode="filter">
	<xsl:choose>
		<xsl:when test="key('acronyms', .)[1] is .">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="filter" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:Abbreviation" mode="filter">
	<xsl:choose>
		<xsl:when test="key('abbreviations', .)[1] is .">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="filter" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- These templates are used to add MatchText attributes on relevant contents items -->
<!--Chunyu HA051073	Added the condition for the instances of replicated section ids. see aosp/1690/7-->
<xsl:template match="*[@ContentRef]" mode="filter">
	<xsl:copy>
		<xsl:if test="key('matchText', @ContentRef)">
			<xsl:attribute name="MatchText" select="'true'" />
		</xsl:if>
		<xsl:if test="key('matchText', concat(parent::*/@ContentRef,'-',@ContentRef))">
			<xsl:attribute name="MatchText" select="'true'" />
		</xsl:if>
		<xsl:apply-templates select="@*|node()" mode="filter" />
	</xsl:copy>
</xsl:template>

<xsl:template match="leg:Contents/@MatchTextEntries" mode="filter">
	<xsl:variable name="values" as="xs:string*" select="tokenize(., ' ')[. = ('introduction', 'body', 'schedules', 'signature', 'note', 'earlier-orders')]" />
	<xsl:if test="exists($values)">
		<xsl:attribute name="MatchTextEntries" select="$values" />
	</xsl:if>
</xsl:template>

<xsl:template match="node()|@*" mode="filter">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" mode="#current" />
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
