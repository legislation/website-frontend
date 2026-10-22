<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dct="http://purl.org/dc/terms/" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions">

	<xsl:template name="TSO_EUPrelims">
		<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" line-height="{$g_strLineHeight}" white-space-collapse="false" line-height-shift-adjustment="disregard-shifts">

			
				<fo:marker marker-class-name="runninghead2">
					<xsl:apply-templates select="leg:abridgeContent(/leg:Legislation/ukm:Metadata/dc:title, 13)"  mode="header"/>
				</fo:marker>
			
			<fo:block font-size="12pt" line-height="14pt" margin-top="12pt" text-align="center">
				<xsl:choose>
					<xsl:when test="$g_ndsLegPrelims/leg:Title">
						<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:block>
			
			<xsl:apply-templates select="/leg:Legislation/leg:EURetained/leg:EUPrelims/*[not(self::leg:Title)]"/>
			<xsl:if test="not(/leg:Legislation/leg:EURetained/leg:EUPrelims/@AltVersionRefs)">
				<xsl:apply-templates select="/leg:Legislation/leg:EURetained/leg:EUPrelims" mode="ProcessAnnotations"/>
			</xsl:if>
			
			<!--<xsl:apply-templates select="$g_ndsLegPrelims/leg:LongTitle"/>
			<xsl:apply-templates select="$g_ndsLegPrelims/leg:IntroductoryText"/>
			<xsl:apply-templates select="$g_ndsLegPrelims/leg:PrimaryPreamble/leg:EnactingText"/>		
			<xsl:apply-templates select="/leg:Legislation/leg:Primary/leg:PrimaryPrelims" mode="ProcessAnnotations"/>-->
			<xsl:apply-templates select="/leg:Legislation/leg:EURetained/leg:EUBody"/>
			
			<!-- #HA057536 - MJ: output resources if file contains no main content -->
			<xsl:apply-templates select="/leg:Legislation/leg:Resources[not(preceding-sibling::leg:EURetained)]"/>
			
			<!-- this is a bodge fix to get around a FOP issue when there is not enough space on the end page for all the footnotes but if it takes a footnote over to the next page then there is enough space for the content to fit in on the first page where it tries to render the footnote back on the first page thus resulting in a loop --> 
			<xsl:if test="/leg:Legislation/leg:Footnotes">
				<fo:block font-size="{$g_strBodySize}" space-before="36pt" text-align="left" keep-with-next="always">
					<xsl:text>&#8203;</xsl:text>
				</fo:block>
			</xsl:if>
			
		</fo:flow>
	</xsl:template>


	
	<xsl:template match="leg:EURetained/leg:EUPrelims">
		<xsl:apply-templates select="leg:Draft"/>
		<xsl:apply-templates select="leg:Title"/>
		<xsl:apply-templates select="leg:EUPreamble/*"/>
	</xsl:template>		

	<xsl:template match="leg:EUPrelims/leg:MultilineTitle">
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<xsl:template match="leg:EUPrelims//leg:Draft">
		<xsl:apply-templates/>
	</xsl:template>	
	
	<xsl:template match="leg:EUPrelims//leg:Draft/leg:Para">
		<xsl:apply-templates/>
	</xsl:template>	
	
	<xsl:template match="leg:EUPrelims//leg:Draft/leg:Para/leg:Text" priority="10">
		<fo:block text-align="center" space-before="12pt" space-after="12pt" font-weight="normal">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>	
	
	<xsl:template match="leg:EUPrelims/leg:MultilineTitle/leg:Text">
		<fo:block text-align="center" space-before="12pt" space-after="12pt" font-weight="normal">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>			

</xsl:stylesheet>