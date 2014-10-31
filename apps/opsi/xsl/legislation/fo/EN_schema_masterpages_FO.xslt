<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<!-- Construct master page definitions -->
<xsl:template name="TSOoutputMasterSet">
	<fo:layout-master-set>

		<!-- Define master page templates -->
		<fo:simple-page-master master-name="first-page" page-height="{$g_dblPageHeight}pt" page-width="{$g_dblPageWidth}pt">
			<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
		</fo:simple-page-master>		
		
		<fo:simple-page-master master-name="footer-only-page" page-height="{$g_dblPageHeight}pt" page-width="{$g_dblPageWidth}pt"> 
			<xsl:choose>
				<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
					<fo:region-body margin-top="90pt" margin-bottom="90pt" margin-left="108pt" margin-right="108pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="footer-only-before"/>
					<fo:region-after extent="72pt" display-align="before" region-name="footer-only-after"/>					
				</xsl:when>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-after extent="72pt" display-align="before" region-name="footer-only-after"/>					
				</xsl:when>
				<xsl:otherwise>
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-after extent="72pt" display-align="before" region-name="footer-only-after"/>					
				</xsl:otherwise>
			</xsl:choose>
		</fo:simple-page-master>		

		<fo:simple-page-master master-name="even-page" page-height="{$g_dblPageHeight}pt" page-width="{$g_dblPageWidth}pt">
			<xsl:choose>
				<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
					<fo:region-body margin-top="90pt" margin-bottom="90pt" margin-left="108pt" margin-right="108pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="even-before"/>
					<fo:region-after extent="72pt" display-align="before" region-name="even-after"/>
				</xsl:when>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="even-before"/>
					<fo:region-after extent="72pt" display-align="before" region-name="even-after"/>
				</xsl:when>
				<xsl:otherwise>
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="even-before"/>
					<fo:region-after extent="72pt" display-align="before" region-name="even-after"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:simple-page-master>		

		<fo:simple-page-master master-name="even-page-first" page-height="{$g_dblPageHeight}pt" page-width="{$g_dblPageWidth}pt">
			<xsl:choose>
				<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
					<fo:region-body margin-top="90pt" margin-bottom="90pt" margin-left="108pt" margin-right="108pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="even-before-first"/>
					<fo:region-after extent="72pt" display-align="before" region-name="even-after"/>
				</xsl:when>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="even-before-first"/>
					<fo:region-after extent="72pt" display-align="before" region-name="even-after"/>
				</xsl:when>
				<xsl:otherwise>
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="even-before-first"/>
					<fo:region-after extent="72pt" display-align="before" region-name="even-after"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:simple-page-master>		

		<fo:simple-page-master master-name="odd-page" page-height="{$g_dblPageHeight}pt" page-width="{$g_dblPageWidth}pt">
			<xsl:choose>
				<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
					<fo:region-body margin-top="90pt" margin-bottom="90pt" margin-left="108pt" margin-right="108pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="odd-before"/>
					<fo:region-after extent="72pt" display-align="before" region-name="odd-after"/>	
				</xsl:when>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="odd-before"/>
					<fo:region-after extent="72pt" display-align="before" region-name="odd-after"/>	
				</xsl:when>
				<xsl:otherwise>
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="odd-before"/>
					<fo:region-after extent="72pt" display-align="before" region-name="odd-after"/>	
				</xsl:otherwise>
			</xsl:choose>
		</fo:simple-page-master>

		<fo:simple-page-master master-name="odd-page-first" page-height="{$g_dblPageHeight}pt" page-width="{$g_dblPageWidth}pt">
			<xsl:choose>
				<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
					<fo:region-body margin-top="90pt" margin-bottom="90pt" margin-left="108pt" margin-right="108pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="odd-before-first"/>
					<fo:region-after extent="72pt" display-align="before" region-name="odd-after"/>	
				</xsl:when>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="odd-before-first"/>
					<fo:region-after extent="72pt" display-align="before" region-name="odd-after"/>	
				</xsl:when>
				<xsl:otherwise>
					<fo:region-body margin-top="72pt" margin-bottom="72pt" margin-left="90pt" margin-right="90pt"/>
					<fo:region-before extent="72pt" display-align="before" region-name="odd-before-first"/>
					<fo:region-after extent="72pt" display-align="before" region-name="odd-after"/>	
				</xsl:otherwise>
			</xsl:choose>
		</fo:simple-page-master>

		<!-- Front sequence of pages -->
		<fo:page-sequence-master master-name="front-sequence">
			<fo:single-page-master-reference master-reference="footer-only-page"/>				
			<fo:repeatable-page-master-alternatives>
				<fo:conditional-page-master-reference master-reference="odd-page" odd-or-even="odd"/>					
				<fo:conditional-page-master-reference master-reference="even-page" odd-or-even="even"/>
			</fo:repeatable-page-master-alternatives>
		</fo:page-sequence-master>			

		<!-- Contents sequence of pages -->
		<fo:page-sequence-master master-name="contents-sequence">
			<fo:single-page-master-reference master-reference="footer-only-page"/>
			<fo:repeatable-page-master-alternatives>
				<fo:conditional-page-master-reference master-reference="odd-page" odd-or-even="odd"/>					
				<fo:conditional-page-master-reference master-reference="even-page" odd-or-even="even"/>
			</fo:repeatable-page-master-alternatives>
		</fo:page-sequence-master>			

		<!-- Main sequence of pages -->
		<fo:page-sequence-master master-name="main-sequence">
			<fo:single-page-master-reference master-reference="footer-only-page"/>
			<fo:repeatable-page-master-alternatives>
				<fo:conditional-page-master-reference master-reference="odd-page" odd-or-even="odd"/>					
				<fo:conditional-page-master-reference master-reference="even-page" odd-or-even="even"/>
			</fo:repeatable-page-master-alternatives>
		</fo:page-sequence-master>			

		<!-- Schedule sequence of pages -->
		<fo:page-sequence-master master-name="annex-sequence">
			<fo:repeatable-page-master-alternatives>
				<!-- NI Acts needs a slightly different first page in the schedules -->
				<xsl:if test="$g_strDocType = 'NorthernIrelandAct'">
					<fo:conditional-page-master-reference master-reference="odd-page-first" odd-or-even="odd" page-position="first"/>					
					<fo:conditional-page-master-reference master-reference="even-page-first" odd-or-even="even" page-position="first"/>
				</xsl:if>
				<fo:conditional-page-master-reference master-reference="odd-page" odd-or-even="odd" page-position="any"/>					
				<fo:conditional-page-master-reference master-reference="even-page" odd-or-even="even" page-position="any"/>
			</fo:repeatable-page-master-alternatives>
		</fo:page-sequence-master>			

	</fo:layout-master-set>
</xsl:template>

</xsl:stylesheet>