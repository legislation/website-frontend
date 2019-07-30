<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Browse output  -->
<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 07/05/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="2.0"
				xmlns:xhtml="http://www.w3.org/1999/xhtml"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
				xmlns:dc="http://purl.org/dc/elements/1.1/"
				xmlns:db="http://docbook.org/ns/docbook"
				xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
				xmlns:atom="http://www.w3.org/2005/Atom"
				xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
				xmlns:xforms="http://www.w3.org/2002/xforms"
				xmlns:ev="http://www.w3.org/2001/xml-events">

	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="../../common/utils.xsl"/>

	<!-- ========== Standard code for outputing UI wireframes========= -->
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

	<xsl:template match="/">
		<html>
			<head>
				<title><xsl:value-of select="leg:TranslateText('Browse Legislation')"/></title>
				<link type="text/css" href="/styles/legBrowseCards.css" rel="stylesheet"/>
				<xsl:comment>
					<![CDATA[[if lte IE 6]><link rel="stylesheet" href="/styles/IE/ie6browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<xsl:comment>
					<![CDATA[[if IE 7]><link rel="stylesheet" href="/styles/IE/ie7browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
			</head>
			<!-- TSOBrowseHome has a different body@class -->
			<body lang="{$TranslateLang}" xml:lang="{$TranslateLang}" dir="ltr" id="browse" class="intro">
				<div id="layout2">
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle">
							<xsl:value-of select="leg:TranslateText('Browse')"/>
						</h1>
					</div>
					<div id="content">
						<xsl:for-each select="('browsecards_parliaments','browsecards_new','browsecards_types','browsecards_ia','browsecards_defra')">
							<xsl:variable name="file" select="concat('../../../www/browse/',.,'.atom.xml')"/>
							<xsl:if test="doc-available($file)">
								<xsl:apply-templates select="doc($file)" mode="cards"/>
							</xsl:if>
						</xsl:for-each>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="atom:feed" mode="cards">
		<div class="card_list">
			<xsl:apply-templates select="node() except atom:entry" mode="cards"/>
			<ul class="cards">
				<xsl:apply-templates select="atom:entry" mode="cards"/>
			</ul>
		</div>
	</xsl:template>

	<xsl:template match="atom:title" mode="cards">
		<h2>
			<xsl:apply-templates mode="cards"/>
		</h2>
	</xsl:template>
	<xsl:template match="atom:entry/atom:title" mode="cards">
		<h3>
			<xsl:apply-templates mode="cards"/>
		</h3>
	</xsl:template>

	<xsl:template match="atom:entry" mode="cards">
		<!--Hide list item if the category is eu and configuration set to hide eu data -->
		<xsl:if test="not($hideEUdata and ./atom:category/@term = 'eu')">
			<xsl:variable name="id" select="tokenize(./atom:id,'#')[2]"/>
			<li class="card" id="{$id}">
				<a>
					<xsl:attribute name="href">
						<xsl:if test="not(./atom:category/@term = 'en-only')">
							<xsl:value-of select="$TranslateLangPrefix"/>
						</xsl:if>
						<xsl:value-of select="./atom:link/@href"/>
					</xsl:attribute>
					<div>
						<xsl:attribute name="class">
							<xsl:text>header</xsl:text>
							<xsl:if test="exists(atom:content)">
								<xsl:text> rule</xsl:text>
							</xsl:if>
						</xsl:attribute>
						<xsl:apply-templates select="* except atom:content" mode="cards"/>
					</div>
					<xsl:apply-templates select="atom:content" mode="cards"/>
				</a>
			</li>
		</xsl:if>
	</xsl:template>
	<!--paragraph with the class of element name-->
	<xsl:template match="atom:summary|atom:content" mode="cards">
		<p class="{local-name()}">
			<xsl:apply-templates mode="cards"/>
		</p>
	</xsl:template>
	<!--Don't output these-->
	<xsl:template match="atom:link|atom:id|atom:updated|atom:category" mode="cards"/>

	<xsl:template match="text()" mode="cards" priority="1">
		<xsl:value-of select="leg:TranslateText(.)"/>
	</xsl:template>
</xsl:stylesheet>