<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<!-- Creates some HTML describing the status of a PDF document -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns="http://www.w3.org/1999/xhtml"
  xmlns:html="http://www.w3.org/1999/xhtml"
 	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
  xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/"
  xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
  exclude-result-prefixes="xs leg ukm tso dc dct">
	
<xsl:import href="common/utils.xsl"/>
<xsl:import href="legislation/html/quicksearch.xsl"/>

<xsl:output method="xhtml"/>

<xsl:template match="/">
	<xsl:variable name="type" select="/ukm:Metadata/ukm:CommonMetadata/ukm:DocumentMainType/@Value" />
	<xsl:variable name="year" select="/ukm:Metadata/ukm:Year/@Value" />
	<xsl:variable name="number" select="/ukm:Metadata/ukm:Number/@Value" />
	<xsl:variable name="section" select="/ukm:Metadata/ukm:Section/@Value" />
	<xsl:variable name="reference">
		<xsl:value-of select="tso:GetSingularTitleFromType($type, $year)" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="$year" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="tso:GetNumberForLegislation($type, $year, $number)" />
	</xsl:variable>
	<html>
		<head>
			<title><xsl:value-of select="$reference" /></title>
		</head>
		<body id="doc" xml:lang="en" lang="en" dir="ltr">
			<div id="layout2">
				<xsl:call-template name="TSOOutputQuickSearch" />
				<div id="title">
					<h1 id="pageTitle">Found References</h1>
				</div>
				<div id="content">
					<h2 class="intro"><xsl:value-of select="$reference" /></h2>
					<p>This item of legislation isn’t available on this site as it isn’t currently available in a web-publishable format.  We are always striving to complete our dataset by adding older legislation to the site. If this is an item you would particularly like to see on this site, please let us know via <a href="mailto: legislation@nationalarchives.gsi.gov.uk?subject=Legislation%20Enquiry?subject={$reference}">legislation@nationalarchives.gsi.gov.uk</a>.</p>
					<p>You may be interested to know that <xsl:value-of select="tso:GetShortCitation($type, $year, $number, $section)" /> is also referenced by other legislation items such as:</p>
					<ul>
						<xsl:apply-templates select="/ukm:Metadata/ukm:Citations/ukm:Citation" />
					</ul>
				</div>
			</div>
		</body>
	</html>
</xsl:template>

<xsl:template match="ukm:Citation">
	<li><a href="{@URI}"><xsl:value-of select="@Title" /></a></li>
</xsl:template>

</xsl:stylesheet>
