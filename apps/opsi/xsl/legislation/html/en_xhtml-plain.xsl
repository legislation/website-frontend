<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Table of Contents/Plain View page output  -->

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
	<xsl:import href="en_xhtml.xsl"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="$legislationTitle"/> - <xsl:value-of select="$enLabel"/>
				</title>
				<xsl:call-template name="TSOOutputAddLegislationStyles" />
			</head>
			<body xml:lang="en" lang="en" dir="ltr" id="leg" class="plainView">
			
				<div id="layout2">
			
					<!-- adding the title of the legislation-->
					<h1 class="pageTitle">
						<xsl:value-of select="concat($legislationTitle, ' ' , $enLabel)"/>
					</h1>
				
					<div class="interface">
						
						<!-- adding the links for previous and next links-->
						<xsl:call-template name="TSOOutputPreviousTOCNextLinks"/>
						
					</div>
					<!--./interface -->

					<div id="content">

						<!-- outputing the legislation content-->
					<xsl:call-template name="TSOOutputLegislationContent" />
	
					<div class="interface">
						
						<!-- adding the links for previous and next links-->
						<xsl:call-template name="TSOOutputPreviousTOCNextLinks"/>
						
					</div>
					<!--./interface -->
					
						<p class="backToTop">
							<a href="#top">Back to top</a>
						</p>							
	
				</div>
					<!--/content-->
					
				</div>
				<!--layout2 -->
				
			</body>
		</html>
	</xsl:template>
	
	<xsl:function name="leg:FormatURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:sequence select="concat(substring-after($url,'http://www.legislation.gov.uk'), '?view=plain') "/>
	</xsl:function>	
	
	
</xsl:stylesheet>
