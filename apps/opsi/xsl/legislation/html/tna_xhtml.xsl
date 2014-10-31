<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Table of Content/Content page output  -->
<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 17/02/2010 by Faiz Muhammad -->
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
	<!-- ========== Standard code for outputing UI wireframes========= -->
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title"/>
				</title>
			</head>
			<body xml:lang="en" lang="en" dir="ltr">
			
				<xsl:variable name="externalPage" select="concat('../../../www/', $paramsDoc/parameters/page, '.xhtml') "/>
				<xsl:variable name="comingsoonPage" select="concat('../../../www/', 'comingsoon', '.xhtml') "/>					
				<xsl:variable name="pageDoc" as="document-node()?">
					<xsl:choose>
						<xsl:when test="doc-available($externalPage)"><xsl:sequence select="doc($externalPage)"/></xsl:when>
						<xsl:when test="doc-available($comingsoonPage)"><xsl:sequence select="doc($comingsoonPage)"/></xsl:when>							
					</xsl:choose>
				</xsl:variable>
				
				<xsl:if test="exists($pageDoc)">
					<xsl:copy-of select="$pageDoc/xhtml:html/xhtml:body/@*"/>
				</xsl:if>
								
				<div id="layout2" >
					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>
					
					<div id="content">
						<xsl:if test="exists($pageDoc)">
							<xsl:copy-of select="$pageDoc/xhtml:html/xhtml:body/node()" />	
						</xsl:if>
					</div>						
				</div>
				<!--layout2 -->
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
