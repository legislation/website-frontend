<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Table of Contents/Content page output  -->

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
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events"
	>
	
	<!-- ========== Standard code for outputing UI wireframes========= -->
	
	<xsl:import href="legislation_xhtml_consolidation.xslt"/>
	
	<xsl:output indent="yes" method="xhtml" />
	
	<xsl:variable name="dcIdentifier" select="leg:Legislation/ukm:Metadata/dc:identifier"/>
	
	<xsl:variable name="nstSection" as="element()?"
		select="if ($nstSelectedSection/parent::leg:P1group) then $nstSelectedSection/.. else $nstSelectedSection" />
	
	
	<!-- getting the document type -->
	<xsl:function name="leg:GetDocumentMainType" as="xs:string">
		<xsl:param name="legislation" as="document-node()" />
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />
	</xsl:function>	
	
	<!-- uri Prefix-->
	<xsl:variable name="uriPrefix" as="xs:string"><xsl:value-of select="tso:GetUriPrefixFromType(leg:GetDocumentMainType(.), /leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value)"/></xsl:variable>
	<xsl:variable name="documentMainType" as="xs:string" select="leg:GetDocumentMainType(.)"/>


	
	<xsl:template match="/">
		<html version="highlight">
			<head>
				<!-- this css does not exist deleted 2010-07-19 
				<xsl:comment><![CDATA[[if lte IE 7]>
					<link rel="stylesheet" href="/styles/IEadditions.css" type="text/css" />
					<![endif]]]></xsl:comment>-->
				<xsl:call-template name="TSOOutputAddLegislationStyles" />
			</head>
			<body>
				<xsl:call-template name="TSOOutputContent" />
			</body>
		</html>
	</xsl:template>
	<!-- outputing the content -->
	<xsl:template name="TSOOutputContent">
		<xsl:apply-templates select="leg:Legislation">
			<xsl:with-param name="showSection" select="$nstSection" tunnel="yes" />
			<xsl:with-param name="includeTooltip" select="false()" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>

<!-- ========== CSS Styles for Legislation =============-->
	<xsl:template name="TSOOutputAddLegislationStyles">
		<style type="text/css">
			<xsl:text>/* Legislation stylesheets - load depending on content type */&#xA;</xsl:text>
			<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="$uriPrefix = ('eut', 'eur', 'eudr', 'eudn') ">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/eulegislation.css";&#xA;</xsl:text>
				</xsl:when>	
				<xsl:when test="$uriPrefix ='ukpga' or  $uriPrefix ='ukla'  or  $uriPrefix ='cukla'  or  $uriPrefix ='ukcm'  ">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/primarylegislation.css";&#xA;</xsl:text>
				</xsl:when>				
				<xsl:when test="$uriPrefix ='apgb' or  $uriPrefix ='aosp'  or  $uriPrefix ='aip'  or  $uriPrefix ='mnia'  or  $uriPrefix ='apni'  or  $uriPrefix ='mwa' or  $uriPrefix ='anaw' or  $uriPrefix ='asc'">
					<xsl:text>@import "/styles/SPOprimarylegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/SPOlegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/primarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix ='aep' or  $uriPrefix ='asp' ">
					<xsl:text>@import "/styles/SPOlegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/primarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix ='nia' ">
					<xsl:text>@import "/styles/NIlegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/secondarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix ='uksi' or $uriPrefix ='ukmd' or $uriPrefix ='ssi'  or  $uriPrefix ='wsi'  or  $uriPrefix ='nisr'  or  $uriPrefix ='ukci'  or  $uriPrefix ='nisi' or  $uriPrefix ='ukmo' or  $uriPrefix ='nisro' ">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/secondarylegislation.css";&#xA;</xsl:text>
				</xsl:when>												
				<xsl:when test="$uriPrefix ='ukdsi' or  $uriPrefix ='sdsi'  or  $uriPrefix ='wdsi'  or  $uriPrefix ='nidsr'">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/secondarylegislation.css";&#xA;</xsl:text>
				</xsl:when>	
			</xsl:choose>
			<xsl:text>@import "/styles/legislationOverwrites.css";&#xA;</xsl:text>			
			<xsl:text>/* End of Legislation stylesheets */&#xA;</xsl:text>	
		</style>							

		<xsl:comment><![CDATA[[if IE 6]>
	<style type="text/css">
		@import "/styles/IE/ie6LegAdditions.css";
	</style>
<![endif]]]></xsl:comment>
		<xsl:comment><![CDATA[[if IE 7]>
	<style type="text/css">
		@import "/styles/IE/ie7LegAdditions.css";
	</style>
<![endif]]]></xsl:comment>		
	</xsl:template>	
	
</xsl:stylesheet>
