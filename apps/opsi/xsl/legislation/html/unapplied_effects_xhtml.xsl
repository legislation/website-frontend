<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
xmlns:xs="http://www.w3.org/2001/XMLSchema"


exclude-result-prefixes="leg xhtml xsl ukm xs tso">





<xsl:import href="../../common/utils.xsl"/>

<xsl:import href="unapplied_effects_xhtml_core.xsl"/>

<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

<xsl:template match="/">
	<div class="LegSnippet" xmlns="http://www.w3.org/1999/xhtml">
		<xsl:apply-templates/>
	</div>
</xsl:template>


<xsl:template match="node() | @*">
	<xsl:apply-templates select="node() | @*"/>
</xsl:template>

<xsl:template match="ukm:UnappliedEffects">
	<xsl:apply-templates select="self::*" mode="filterUnappliedEffects"/>
</xsl:template>


</xsl:stylesheet>