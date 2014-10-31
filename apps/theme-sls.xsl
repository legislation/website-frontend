<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xhtml xs">

<xsl:output method="xhtml" indent="no" encoding="UTF-8" exclude-result-prefixes="xhtml"
	omit-xml-declaration="yes" />

<xsl:preserve-space elements="*" />

<xsl:variable name="g_nstRequest" as="document-node()" select="doc('input:request')" />
<xsl:variable name="g_ndsSecurity" as="document-node()" select="doc('input:request-security')" />

<xsl:variable name="g_strBaseURL" select="'/'" />
<xsl:variable name="g_strUri">
	<xsl:value-of select="$g_nstRequest//request-path" />
	<xsl:if test="$g_nstRequest//query-string != ''">
		<xsl:text>?</xsl:text>
		<xsl:value-of select="$g_nstRequest//query-string" />
	</xsl:if>
</xsl:variable>

<xsl:variable name="g_strUriRegex" as="xs:string">(apni|asp|mnia|nia|nisi|slsi|sr|ssi|ukcm|ukla|ukpga|uklsi|uksi|wsi|wlsi)/([0-9]{4}|([^/]+/[-0-9]+))/([0-9]{1,4})</xsl:variable>

<xsl:template match="/*">
	<html xml:lang="en" lang="en">
		<xsl:sequence select="namespace::*" />
		<xsl:apply-templates select="@*" />
		<head>
			<xsl:sequence select="xhtml:head/namespace::*" />
			<!--<base href="http://www.legislation.gov.uk/" />-->
			<xsl:copy-of select="xhtml:head/xhtml:title" copy-namespaces="no" />
			<xsl:if test="not(xhtml:head/xhtml:title)">
				<title>
					<xsl:text>Single Legislation Service</xsl:text>
				</title>
			</xsl:if>
			<link rel="stylesheet" href="{$g_strBaseURL}styles/styles.css" />
			<xsl:copy-of select="xhtml:head/node() except xhtml:head/xhtml:title" copy-namespaces="no" />
		</head>
		<body>
			<xsl:sequence select="xhtml:body/namespace::*" />
			<xsl:copy-of select="xhtml:body/@*" />
			<xsl:call-template name="GetMenu" />
			<div id="leftNavArea">
				<h5>Legislation</h5>
				<ul>
					<li><a href="http://www.legislation.gov.uk/search">Search</a></li>
				</ul>
			</div>
			<div id="rightNavArea">
				<xsl:choose>
					<xsl:when test="matches($g_strUri, $g_strUriRegex, 'x')">
						<!--<h5>Alternative Views</h5>
						<ul>
							<xsl:variable name="strPdfUri">
								<xsl:choose>
									<xsl:when test="ends-with($g_strUri, '.htm')">
										<xsl:value-of select="substring-before($g_strUri, '.htm')" />
										<xsl:text>.pdf</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$g_strUri" />
										<xsl:text>/</xsl:text>
										<xsl:value-of select="translate(substring($g_strUri, 2), '/', '-')" />
										<xsl:text>.pdf</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="not(contains($g_strUri, '-contents'))">
								<li><a href="{$strPdfUri}">Generate PDF</a></li>
							</xsl:if>
							<xsl:analyze-string select="$g_strUri" regex="{$g_strUriRegex}" flags="x">
								<xsl:matching-substring>
									<li><a href="/{.}/contents">Table of Contents</a></li>
									<li><a href="/{.}/citations">Where Cited</a></li>
								</xsl:matching-substring>
							</xsl:analyze-string>
						</ul>-->
					</xsl:when>
					<xsl:when test="contains($g_strUri, 'developer')">
						<h5>Developer Links</h5>
						<ul>
							<li><a href="/developer/contents">Contents</a></li>
							<li><a href="http://www.legislation.gov.uk/id">API Search</a></li>							
							<li><a href="/developer/samples">Samples</a></li>
							<li><a href="/developer/faq"><acronym title="Frequently Asked Questions">FAQ</acronym></a></li>
						</ul>
					</xsl:when>
				</xsl:choose>
			</div>
			<div id="contentArea">
				<xsl:copy-of select="xhtml:body/node()" copy-namespaces="no" />
			</div>
			<div id="footerArea">
				<p>Copyright 2009</p>
			</div>
		</body>
	</html>
</xsl:template>

<!-- Simply copy everything that's not matched -->
<xsl:template match="@*|node()" priority="-2">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" />
	</xsl:copy>
</xsl:template>

<xsl:template name="GetMenu">
	<div id="headerArea">
		<xsl:if test="$g_ndsSecurity//remote-user != ''">
			<p>Logged in as: <xsl:value-of select="$g_ndsSecurity//remote-user" /></p>
		</xsl:if>
		<h1>
			<xsl:text>Test Legislation API</xsl:text>
			<xsl:if test="contains($g_strUri, 'developer')">
				<xsl:text> (Developer Zone)</xsl:text>
			</xsl:if>
		</h1>
	</div>
	<div class="navBar">
		<div class="mainNavigation">
			<ul>
				<li><a href="/index">Home</a></li>
				<li><a href="/aboutus">About OPSI</a></li>
				<li><a href="/contactus">Contact Us</a></li>
				<li><a href="/developer">Developer Zone</a></li>
			</ul>
		</div>
	</div>
</xsl:template>

</xsl:stylesheet>
