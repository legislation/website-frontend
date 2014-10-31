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
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	exclude-result-prefixes="#all">
<xsl:output method="xhtml" indent="no" encoding="UTF-8" exclude-result-prefixes="xhtml" omit-xml-declaration="yes"/>

<xsl:preserve-space elements="*"/>

<xsl:template match="/*">
	<!-- content -->
	<!--<xsl:copy-of select="*" copy-namespaces="no" />-->
	<div class="LegSnippet">
		<xsl:copy-of select="xhtml:body/node()" copy-namespaces="no" />
	</div>	
	
<!--	<html xmlns="http://www.w3.org/1999/xhtml" xmlns:dct="http://purl.org/dc/terms/" lang="en" xml:lang="en">
		<xsl:apply-templates select="@*"/>
		<head>
			<xsl:copy-of select="xhtml:head/node() except xhtml:head/xhtml:meta[@http-equiv]" copy-namespaces="no" />
			<xsl:copy-of select="xhtml:head/xhtml:meta[lower-case(@http-equiv) = 'refresh']" copy-namespaces="no" />
			<link rel="stylesheet" href="/styles/print.css" type="text/css" media="print" />
			<style>
				em.hithighlight
				{
					background: yellow;
					color: black;
					font-style:normal;
				}
			</style>
		</head>
		<body>
			<xsl:copy-of select="xhtml:body/@*"/>
			
			<div class="LegSnippet">

				<xsl:copy-of select="xhtml:body/node()" copy-namespaces="no" />
			</div>
		</body>
	</html>-->
</xsl:template>

</xsl:stylesheet>
