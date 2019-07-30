<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Resources page output  -->

<!-- Version 0.01 -->
<!-- Created by GRiff Chamberlain  -->
<!-- Adapted from resources_xhtml.xsl  -->

<!-- Change history

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="2.0"
				xmlns:xhtml="http://www.w3.org/1999/xhtml"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
				xmlns:dc="http://purl.org/dc/elements/1.1/"
				xmlns:db="http://docbook.org/ns/docbook"
				xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
				xmlns:dct="http://purl.org/dc/terms/"
				xmlns:atom="http://www.w3.org/2005/Atom"
				xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
				xmlns:xforms="http://www.w3.org/2002/xforms"
				xmlns:ev="http://www.w3.org/2001/xml-events"
>

	<!-- ========== Standard code for outputing UI wireframes========= -->
	<xsl:import href="toc_xhtml.xsl"/>

	<xsl:variable name="hasXML" as="xs:boolean"
				  select="exists(/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents'])"/>

	<xsl:variable name="documentMainType" as="xs:string"
				  select="leg:GetDocumentMainType(/)"/>

	<!-- the fd_335 variable is the EU controlled vocabulary module fd_335 which is taken from the EU website
		http://publications.europa.eu/resource/cellar/fab6e9a8-12fc-11e8-9253-01aa75ed71a1.0001.04/DOC_6
		A full list of controlled volcabularies can be found at:
		https://publications.europa.eu/en/web/eu-vocabularies/atto-tables
	-->

	<xsl:variable name="fd_330-filename" select="'eu-vocab-fd_330.xml'"/>
	<xsl:variable name="doc-fd_330" select="if (doc-available($fd_330-filename)) then doc($fd_330-filename) else ()"/>
	<xsl:variable name="fd_335-filename" select="'eu-vocab-fd_335.xml'"/>
	<xsl:variable name="doc-fd_335" select="if (doc-available($fd_335-filename)) then doc($fd_335-filename) else ()"/>
	<xsl:variable name="places-filename" select="'eu-vocab-places.xml'"/>
	<xsl:variable name="doc-places" select="if (doc-available($places-filename)) then doc($places-filename) else ()"/>

	<xsl:output indent="yes" method="xhtml"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title"/>
				</title>
				<xsl:apply-templates select="/leg:Legislation/ukm:Metadata" mode="HTMLmetadata"/>

				<script type="text/javascript" src="/scripts/view/tabs.js"></script>
				<xsl:call-template name="TSOOutputAddLegislationStyles"/>

			</head>
			<body xml:lang="{$TranslateLang}" lang="{$TranslateLang}" dir="ltr" id="leg" about="{$dcIdentifier}"
				  class="resources">

				<div id="layout2" class="legInForceInfo">

					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>

					<!-- adding the title of the legislation-->
					<xsl:call-template name="TSOOutputLegislationTitle"/>

					<!-- breadcrumb -->
					<xsl:call-template name="TSOOutputBreadcrumbItems"/>

					<!-- tabs -->
					<xsl:call-template name="TSOOutputSubNavTabs"/>

					<div class="interface"/>
					<!--./interface -->

					<div id="content">

						<!-- outputing the legislation content-->
						<xsl:apply-templates select="/leg:Legislation" mode="TSOOutputLegislationContent"/>

						<p class="backToTop">
							<a href="#top">
								<xsl:value-of select="leg:TranslateText('Back to top')"/>
							</a>
						</p>

					</div>
					<!--/content-->

				</div>
				<!--layout2 -->

				<!-- help tips -->
				<xsl:call-template name="TSOOutputHelpTips"/>

			</body>
		</html>

	</xsl:template>

	<!-- ========== Standard code for outputing legislation content ========= -->
	<xsl:template match="leg:Legislation" mode="TSOOutputLegislationContent">
		<xsl:variable name="theTitle">
			<xsl:choose>
				<xsl:when test="count(/leg:Legislation/ukm:Metadata/dc:title) = 1">
					<xsl:value-of
							select="concat(if (starts-with(/leg:Legislation/ukm:Metadata/dc:title, 'The ')) then '' else 'the ', /leg:Legislation/ukm:Metadata/dc:title)"/>
				</xsl:when>
				<xsl:when test="$language = 'cy'">
					<xsl:value-of
							select="concat(if (starts-with(/leg:Legislation/ukm:Metadata/dc:title[@xml:lang='cy'], 'The ')) then '' else 'the ', /leg:Legislation/ukm:Metadata/dc:title[@xml:lang='cy'])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
							select="concat(if (starts-with(/leg:Legislation/ukm:Metadata/dc:title[not(@xml:lang='cy')], 'The ')) then '' else 'the ', /leg:Legislation/ukm:Metadata/dc:title[not(@xml:lang='cy')])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="innerContent">
			<h2 class="accessibleText">
				<xsl:text>In Force Information for </xsl:text>
				<xsl:value-of select="$theTitle"/>
			</h2>
			<xsl:apply-templates select="ukm:Metadata/ukm:EUMetadata"/>
		</div>
	</xsl:template>


	<xsl:template match="ukm:EUMetadata">
		<div class="assocDocs filesizeShow colSection p_one s_7">
			<h3>
				<xsl:value-of select="leg:TranslateText('Dates')"/>
			</h3>

			<!--
			Date of document: 27/10/2004
				Date of effect: 29/12/2004; Entry into force Date pub. + 20 See Art 22
				Date of effect: 29/12/2005; Partial application See Art 22
				Date of effect: 29/12/2006; Partial application See Art 22
				Date of end of validity: 16/01/2020; Repealed by 32017R2394
			-->

			<xsl:choose>
				<xsl:when
						test="exists(*:RESOURCE_LEGAL_DATE_ENTRY-INTO-FORCE)  or exists(*:RESOURCE_LEGAL_DATE_END-OF-VALIDITY) or exists(*:RESOURCE_LEGAL_DATE_SIGNATURE)">
					<div>
						<table class="inForceInformation">
							<xsl:apply-templates select="ukm:EnactmentDate"/>
							<xsl:apply-templates select=".//*:RESOURCE_LEGAL_DATE_SIGNATURE"/>
							<xsl:apply-templates select=".//*:RESOURCE_LEGAL_DATE_ENTRY-INTO-FORCE">
								<xsl:sort select="*:VALUE"/>
							</xsl:apply-templates>
							<xsl:apply-templates select=".//*:RESOURCE_LEGAL_DATE_END-OF-VALIDITY"/>
						</table>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<table class="inForceInformation">
						<tbody>
							<xsl:apply-templates select="ukm:EnactmentDate"/>
						</tbody>
					</table>
					<!-- default message -->
					<p>
						<xsl:value-of select="leg:TranslateText('There are no In Force data avaialable for this document')"/>
					</p>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template match="ukm:EnactmentDate">
	<tr>
		<th class="title">
			<xsl:value-of select="leg:TranslateText('Date of document')"/>
		</th>
		<td colspan="3">
			<xsl:value-of select="format-date(@Date,'[D01]/[M01]/[Y0001]')"/>
		</td>
	</tr>
</xsl:template>

	<xsl:template
			match="*:RESOURCE_LEGAL_DATE_ENTRY-INTO-FORCE | *:RESOURCE_LEGAL_DATE_END-OF-VALIDITY | *:RESOURCE_LEGAL_DATE_SIGNATURE">
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="self::*:RESOURCE_LEGAL_DATE_END-OF-VALIDITY">
					<xsl:value-of select="leg:TranslateText('Date of end of validity')"/>
				</xsl:when>
				<xsl:when test="self::*:RESOURCE_LEGAL_DATE_SIGNATURE">
					<xsl:value-of select="leg:TranslateText('Date of signature')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="leg:TranslateText('Date of effect')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="date">
			<xsl:value-of select="*:DAY"/>
			<xsl:text>/</xsl:text>
			<xsl:value-of select="*:MONTH"/>
			<xsl:text>/</xsl:text>
			<xsl:value-of select="*:YEAR"/>
		</xsl:variable>
		<xsl:variable name="trueyear" select="*:YEAR &gt; 1100"/>
		<!-- we can have multiple annotations for the same date
			these require to be formatted as individual lines - see 2010 EUR 837 as example -->
		<xsl:for-each select="*:ANNOTATION">
			<tr>
				<th>
					<xsl:value-of select="$title"/>
				</th>
				<td>
					<xsl:choose>
						<xsl:when test="$trueyear">
							<xsl:value-of select="$date"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="leg:TranslateText('N/A')"/>
						</xsl:otherwise>
					</xsl:choose>
				</td>
				<td>
					<xsl:for-each select="tokenize(*:TYPE_OF_DATE, '\{|\}')">
						<xsl:sequence select="tso:translate-EU-vocabulary(.)"/>
					</xsl:for-each>
				</td>
				<td>
					<xsl:for-each select="tokenize(*:COMMENT_ON_DATE, '\{|\}')">
						<xsl:sequence select="tso:translate-EU-vocabulary(.)"/>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:for-each>
	</xsl:template>


	<!-- ========== Standard code for breadcrumb ========= -->
	<xsl:template name="TSOOutputBreadcrumbItems">
		<!--/#breadcrumbControl -->
		<div id="breadCrumb">
			<h3 class="accessibleText">You are here:</h3>
			<ul>
				<xsl:call-template name="legtypeBreadcrumb"/>
				<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
				<li class="activetext">
					<xsl:value-of select="leg:TranslateText('In Force Information')"/>
				</li>
			</ul>
		</div>
	</xsl:template>


	<!-- ========== Standard code for opening options ========= -->
	<xsl:template name="TSOOutputHelpTips">
		<xsl:call-template name="TSOOutputENsHelpTips"/>
	</xsl:template>

	<!-- ========== translate EU vocabulary ========= -->


	<xsl:function name="tso:translate-EU-vocabulary" as="xs:string?">
		<xsl:param name="vocab" as="xs:string?"/>
		<xsl:choose>
			<xsl:when test="matches($vocab, '\|http://publications.europa.eu/resource/authority/fd_330')">
				<xsl:variable name="eu-code" as="xs:string?" select="substring-before($vocab, '|')"/>
				<xsl:variable name="getcode" as="xs:string?" select="$doc-fd_330//LIBELLE[@CODE = $eu-code]/text()"/>
				<xsl:sequence select="if ($getcode) then $getcode else $eu-code"/>
			</xsl:when>
			<xsl:when test="matches($vocab, '\|http://publications.europa.eu/resource/authority/fd_335')">
				<xsl:variable name="eu-code" as="xs:string?" select="substring-before($vocab, '|')"/>
				<xsl:variable name="getcode" as="xs:string?" select="$doc-fd_335//LIBELLE[@CODE = $eu-code]/text()"/>
				<xsl:sequence select="if ($getcode) then $getcode else $eu-code"/>
			</xsl:when>
			<xsl:when test="matches($vocab, '\|http://publications.europa.eu/resource/celex/')">
				<xsl:sequence select="substring-before($vocab, '|')"/>
			</xsl:when>
			<xsl:when test="matches($vocab, '\|http://publications.europa.eu/resource/authority/place/')">
				<xsl:variable name="eu-code" as="xs:string?" select="substring-before($vocab, '|')"/>
				<xsl:variable name="getcode" as="xs:string?" select="$doc-places//LIBELLE[@CODE = $eu-code]/text()"/>
				<xsl:sequence select="if ($getcode) then $getcode else $eu-code"/>
			</xsl:when>
			<xsl:when test="not(matches($vocab, 'http://publications.europa.eu'))">
				<xsl:sequence select="$vocab"/>
			</xsl:when>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
