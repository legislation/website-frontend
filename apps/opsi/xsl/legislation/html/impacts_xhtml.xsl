<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<!-- UI Legislation Resources page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 31/08/2010 by Faiz Muhammad -->
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
	<xsl:import href="toc_xhtml.xsl"/>	
	
	<xsl:variable name="requestDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>	
	<xsl:variable name="g_impactAssessmentType" as="xs:string" select="$requestDoc/parameters/impact-assessment" />
	
	<xsl:output indent="yes" method="xhtml" />

	<xsl:template match="/">
		<xsl:variable name="ias" as="element(ukm:ImpactAssessment)*" select="leg:Legislation/ukm:Metadata/ukm:ImpactAssessments/ukm:ImpactAssessment" />
		<xsl:variable name="ias" select="if ($g_impactAssessmentType != '') then $ias[starts-with(lower-case(translate(@Title, ' ', '-')), $g_impactAssessmentType)] else $ias" />
		<xsl:variable name="ias" as="element(ukm:ImpactAssessment)*">
			<xsl:perform-sort select="$ias">
				<xsl:sort select="index-of($assessmentTypes, substring-before(@Title, ' Impact Assessment'))" order="descending" />
			</xsl:perform-sort>
		</xsl:variable>
		<xsl:variable name="ia" as="element(ukm:ImpactAssessment)?">
			<xsl:choose>
				<xsl:when test="$ias[@Language = 'Mixed']">
					<xsl:sequence select="$ias[@Language = 'Mixed'][1]" />
				</xsl:when>
				<xsl:when test="$ias[empty(@Language)]">
					<xsl:sequence select="$ias[empty(@Language)][1]" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$ias[1]" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<html>
			<head>
				<title>
					<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title" />
				</title>
				<xsl:apply-templates select="/leg:Legislation/ukm:Metadata" mode="HTMLmetadata" />
				
				<script type="text/javascript" src="/scripts/view/tabs.js"></script>				
				<xsl:call-template name="TSOOutputAddLegislationStyles" />
				
			</head>
			<body xml:lang="en" lang="en" dir="ltr" id="leg" about="{$dcIdentifier}" class="impacts">
			
				<div id="layout2" class="legIA">
				
					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>
				
					<!-- adding the title of the legislation-->
					<xsl:call-template name="TSOOutputLegislationTitle"/>
					
					 <!-- breadcrumb -->
					<xsl:call-template name="TSOOutputBreadcrumbItems"	/>
					
					 <!-- tabs -->
					<xsl:call-template name="TSOOutputSubNavTabs"/>			
						
					<div class="interface"/>
					<!--./interface -->
					
					<!-- left-hand navigation -->
					<div id="tools">
						<xsl:apply-templates select="/leg:Legislation" mode="TSOOutputWhatVersion">
							<xsl:with-param name="ia" select="$ia" />
						</xsl:apply-templates>
					</div>

					
					<div id="content">
					
						<!-- outputing the legislation content-->
						<xsl:apply-templates select="/leg:Legislation" mode="TSOOutputLegislationContent">
							<xsl:with-param name="ia" select="$ia" />
						</xsl:apply-templates>

						<p class="backToTop">
							<a href="#top">Back to top</a>
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
		<xsl:param name="ia" as="element(ukm:ImpactAssessment)?" required="yes" />
		<xsl:variable name="theTitle">
			<xsl:choose>
				<xsl:when test="count(/leg:Legislation/ukm:Metadata/dc:title) = 1">
					<xsl:value-of select="concat(if (starts-with(/leg:Legislation/ukm:Metadata/dc:title, 'The ')) then '' else 'the ', /leg:Legislation/ukm:Metadata/dc:title)"/>
				</xsl:when>
				<xsl:when test="$language = 'cy'">
					<xsl:value-of select="concat(if (starts-with(/leg:Legislation/ukm:Metadata/dc:title[@xml:lang='cy'], 'The ')) then '' else 'the ', /leg:Legislation/ukm:Metadata/dc:title[@xml:lang='cy'])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat(if (starts-with(/leg:Legislation/ukm:Metadata/dc:title[not(@xml:lang='cy')], 'The ')) then '' else 'the ', /leg:Legislation/ukm:Metadata/dc:title[not(@xml:lang='cy')])"/>	
				</xsl:otherwise>
			</xsl:choose>	 
		</xsl:variable>
		<xsl:variable name="version" as="xs:string?">
			<xsl:if test="contains($ia/@Title, ' Impact Assessment')">
				<xsl:value-of>
					<xsl:text>the </xsl:text>
					<xsl:value-of select="substring-before($ia/@Title, ' Impact Assessment')" />
					<xsl:text> version of the </xsl:text>
				</xsl:value-of>
			</xsl:if>
		</xsl:variable>
		<div id="infoSection">
			<h2>Status:</h2>
			<p class="intro">This is <xsl:value-of select="$version" />Impact Assessment for <xsl:value-of select="$theTitle" />.</p>
		</div>
		<div id="infoSection">
			<h2>Please note:</h2>
			<p class="intro">This impact assessment is only available to download and view as PDF.</p>
		</div>
		<div id="viewLegContents">                            
			<div class="LegSnippet" id="viewLegSnippet">
				<xsl:apply-templates select="$ia">
					<xsl:with-param name="legislationTitle" select="$theTitle" />
				</xsl:apply-templates>
				<span class="LegClearFix" />
			</div>
 		</div>
		<div class="contentFooter">
			<div class="interface"> </div>
		</div>
	</xsl:template>

	<xsl:template match="ukm:ImpactAssessment">
		<xsl:param name="legislationTitle" as="xs:string" required="yes" />
		<p class="downloadPdfVersion">
			<a class="pdfLink" href="{leg:FormatURL(@URI)}">
				<img class="imgIcon" alt="" src="/images/chrome/pdfIconMed.gif" />
				<xsl:text>View PDF</xsl:text>
				<img class="pdfThumb" 
					src="{leg:FormatURL(replace(replace(@URI, '/pdfs/', '/images/'), '.pdf', '.jpeg'))}"
					title="{@Title} for {$legislationTitle}"
					alt="{@Title} for {$legislationTitle}" />
			</a>
		</p>
	</xsl:template>

	<xsl:variable name="assessmentTypes" as="xs:string+" select="('Consultation', 'Final', 'Enactment', 'Post Implementation')" />
	
	<xsl:template match="leg:Legislation" mode="TSOOutputWhatVersion">
		<xsl:param name="ia" as="element(ukm:ImpactAssessment)?" required="yes" />
		<xsl:variable name="ias" as="element(ukm:ImpactAssessment)*" select="ukm:Metadata/ukm:ImpactAssessments/ukm:ImpactAssessment" />
		<div class="section" id="whatVersion">
			<div class="title">
				<h2>What Version</h2>
				<a href="#whatVersionIaHelp" class="helpItem helpItemToMidRight">
					<img src="/images/chrome/helpIcon.gif" alt=" Help about what version" />
				</a>
			</div>
			<div class="content">
				<ul class="toolList">
					<xsl:for-each select="$assessmentTypes">
						<xsl:variable name="assessmentType" as="xs:string" select="." />
						<xsl:variable name="button" as="element()">
							<span class="background">
								<span class="btl" /><span class="btr" /><xsl:value-of select="$assessmentType" /><span class="bbl" /><span class="bbr" />
							</span>
						</xsl:variable>
						<li>
							<xsl:choose>
								<xsl:when test="starts-with($ia/@Title, $assessmentType)">
									<span class="userFunctionalElement active">
										<xsl:sequence select="$button" />
									</span>
								</xsl:when>
								<xsl:when test="exists($ias[starts-with(@Title, $assessmentType)])">
									<a class="userFunctionalElement" href="{leg:FormatURL(concat($impactURI, '/', lower-case(replace($assessmentType, ' ', '-'))))}">
										<xsl:sequence select="$button" />
									</a>
								</xsl:when>
								<xsl:otherwise>
									<span class="userFunctionalElement disabled">
										<xsl:sequence select="$button" />
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</div>
	</xsl:template>
	
	<!-- ========== Standard code for breadcrumb ========= -->
	<xsl:template name="TSOOutputBreadcrumbItems">
		  <!--/#breadcrumbControl --> 
			<div id="breadCrumb">
				<h3 class="accessibleText">You are here:</h3>		
				<ul>
					<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
					<xsl:choose>
						<xsl:when test="$g_impactAssessmentType = ''">
							<li class="activetext">Impact Assessments</li>
						</xsl:when>
						<xsl:otherwise>
							<li><a href="{leg:FormatURL($impactURI)}">Impact Assessments</a></li>
							<li class="activetext">
								<xsl:value-of separator=" ">
									<xsl:for-each select="tokenize($g_impactAssessmentType, '-')">
										<xsl:value-of select="concat(upper-case(substring(., 1, 1)), substring(., 2))" />
									</xsl:for-each>
								</xsl:value-of>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
		</div>
	</xsl:template>

	
	<!-- ========== Standard code for opening options ========= -->	
	<xsl:template name="TSOOutputHelpTips">
		<xsl:call-template name="TSOOutputENsHelpTips"/>
		<div class="help" id="whatVersionIaHelp">
			<span class="icon" />
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif" />
				</a>
				<h3>Impact Assessments are published at different stages of the legislation making process.  These different versions can be viewed on legislation.gov.uk where available:</h3>
				<dl>
					<dt>Consultation:</dt>
					<dd>This version/stage refers to when a formal public consultation is published and focuses on the cost and benefits of each option under consideration.</dd>
					<dt>Final:</dt>
					<dd>When a preferred option has been decided upon following the consultation stage, a ‘Final’ version is published. This is the version that accompanied the proposed legislation when it was introduced to Parliament. It is the version that accompanies any Draft Statutory Instrument which requires and Impact Assessment.</dd>
					<dt>Enactment:</dt>
					<dd>Published when the legislation is enacted, (sometimes this may be the same as the Final version depending whether changes have been introduced to the final proposal during the Parliamentary process);</dd>
					<dt>Post Implementation Review:</dt>
					<dd>This stage captures the impact of the implemented policy, and assesses any modifications to the policy objectives or its implementation recommended as a result of the review.</dd>
				</dl>
			</div>
		</div>
	</xsl:template>	

	
</xsl:stylesheet>
