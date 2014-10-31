<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Table of Contents/Version History page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 17/02/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"  version="2.0" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:db="http://docbook.org/ns/docbook"	
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events"
	>
	<xsl:import href="toc_xhtml.xsl"/>
	<xsl:template match="/">
		<html>
			<head>
				<!--this css does not exist deleted 2010-07-19 
				<xsl:comment><![CDATA[[if lte IE 7]>
					<link rel="stylesheet" href="/styles/IEadditions.css" type="text/css" />
					<![endif]]]></xsl:comment>-->
				<title>
					<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title" />
				</title>
				<xsl:call-template name="TSOOutputAddLegislationStyles" />
			</head>
			<body xml:lang="en" lang="en" dir="ltr" id="leg" class="plainView">
			
				<div id="layout2">
			
					<!-- adding the title of the legislation-->
					<xsl:call-template name="TSOOutputLegislationTitle"/>

					<div id="content">
						<div>
							<ul>
		
								<xsl:for-each select="//atom:link[@rel='http://purl.org/dc/terms/hasVersion'] ">
									<li>
										<a href="{leg:FormatURL(@href)}"><xsl:value-of select="@title"/></a>
									</li>								
								</xsl:for-each>
							</ul>
						</div>					
					</div>
					<!--/content-->
				</div>
				<!--layout2 -->
			</body>
		</html>
	</xsl:template>
	
	<xsl:function name="leg:FormatURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:sequence select="substring-after($url,'http://www.legislation.gov.uk')"/>
	</xsl:function>	
	
	
</xsl:stylesheet>
