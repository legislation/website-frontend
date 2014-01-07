<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<!-- UI EN Table of Content/Content page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 01/03/2010 by Faiz Muhammad -->
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
	
	<!-- ========== Standard code for outputing UI wireframes========= -->
	<xsl:import href="../../common/utils.xsl" />
	<xsl:import href="EN_xhtml_consolidation.xslt"/>	
	<xsl:import href="statuswarning.xsl"/>
	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="uicommon.xsl"/>	
	
	<xsl:variable name="paragraphThreshold" select="200"/>
	<xsl:variable name="dcIdentifier" select="leg:EN/ukm:Metadata/dc:identifier"/>
	<xsl:variable name="strCurrentURIs" select="/leg:EN/ukm:Metadata/dc:identifier, 
		/leg:EN/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasPart']/@href" />	
	<xsl:variable name="nstSelectedSection" as="element()?" select="/leg:EN/leg:ExplanatoryNotes/leg:Body//*[@id != '' and @DocumentURI = $strCurrentURIs]"/>
	<xsl:variable name="nstSection" as="element()?" select="if ($nstSelectedSection/parent::leg:SubDivision) then $nstSelectedSection/.. else $nstSelectedSection"/>
	
	<xsl:variable name="language" select="if (/leg:EN/@xml:lang) then /leg:Legislation/@xml:lang else 'en'"/>
	
	<xsl:variable name="legislationTitle"><xsl:call-template name="TSOOutputLegislationTitle"/></xsl:variable>

	<xsl:variable name="introURI" as="xs:string?" select="leg:EN/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/act/introduction']/@href" />			
	<xsl:variable name="explanatoryNotesWholeURI" as="xs:string" select="leg:EN/@DocumentURI" />				
	<xsl:variable name="tocURI" as="xs:string?" select="leg:EN/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/act/toc']/@href" />	
	<xsl:variable name="explanatoryNotesTOCURI" as="xs:string?" select="leg:EN/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents']/@href" />		

	<xsl:variable name="legislationIdURI"  select="replace(/leg:EN/@IdURI, '/notes', '')"/>		
	<xsl:variable name="resourceURI" as="xs:string" 
		select="/leg:EN/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/resources']/@href" />				
	<xsl:variable name="impactURI" as="xs:string" 
		select="/leg:EN/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/impacts']/@href" />				
	<xsl:variable name="emURI" as="xs:string?" select="/leg:EN/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/memorandum/toc']/@href" />
	<xsl:variable name="enURI" as="xs:string?" 
		select="/leg:EN/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/notes/toc']/@href | 
			/leg:EN/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/executive-note/toc']/@href |
			/leg:EN/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents']/@href" />
	<xsl:variable name="pnURI" as="xs:string?" 
		select="/leg:EN/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/policy-note/toc']/@href" />		

	<xsl:variable name="uriPrefix" as="xs:string" 
		select="tso:GetUriPrefixFromType(/leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value, /leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:Year/@Value)"/>
	<xsl:variable name="documentMainType" as="xs:string" select="/leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>	
	
	<xsl:variable name="IsEnAvailable" as="xs:boolean" select="exists($enURI)"/>
	<xsl:variable name="IsEmAvailable" as="xs:boolean" select="exists($emURI)"/>
	<xsl:variable name="IsPnAvailable" as="xs:boolean" select="exists($pnURI)"/>
		
	<xsl:variable name="IsMoreResourcesAvailable" as="xs:boolean" 
		select="tso:ShowMoreResources(/)"/>			
	<xsl:variable name="IsImpactAssessmentsAvailable" as="xs:boolean" 
		select="tso:ShowImpactAssessments(/)"/>			
	
	<xsl:variable name="enType" as="xs:string?" select="if (contains(/leg:EN/ukm:Metadata/dc:identifier, '/memorandum')) then 'em' 
						else if (contains(/leg:EN/ukm:Metadata/dc:identifier, '/policy-note')) then 'pn' else 'en'" />
	<xsl:variable name="enLabel" select="tso:GetENLabel(/leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value, $enType)" />
	
	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="$legislationTitle"/> - <xsl:value-of select="$enLabel"/>
				</title>
				<!--<meta name="DC.Date.Modified" content="{/leg:EN/ukm:Metadata/dc:modified}" />-->
				<xsl:apply-templates select="/leg:EN/ukm:Metadata" mode="HTMLmetadata" />
				
				<xsl:call-template name="TSOOutputAddLegislationStyles" />
			</head>		
			<body xml:lang="en" lang="en" dir="ltr" id="leg" about="{$dcIdentifier}"  class="toc">
				<div id="layout2" class="leg{if ($enType='en' or $enType='' ) then 'En' else if ($enType='pn') then 'Pn' else 'Em'}{if (leg:IsEnTOC()) then 'Toc' else 'Content'}">
			
					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>
								
					<!-- adding title -->
					<xsl:call-template name="TSOOutputLegislationHeading"/>
					
					 <!-- breadcrumb -->
					<xsl:call-template name="TSOOutputBreadcrumbItems"	/>

					<!-- Sub Navigation tabs-->
					<xsl:call-template name="TSOOutputSubNavTabs" />
						
						
					<div class="interface">
					
						<ul id="wholeNav">
							<li class="wholeuri">
								<xsl:element name="{if ($explanatoryNotesWholeURI != $dcIdentifier and not(leg:IsEnPDFOnly(.))) then 'a' else 'span' }">
									<xsl:choose>
										<xsl:when test="leg:IsEnPDFOnly(.)">
											<xsl:attribute name="class" select="'userFunctionalElement disabled'"/>										
										</xsl:when>									
										<xsl:when test="$explanatoryNotesWholeURI != $dcIdentifier">
											<xsl:attribute name="href" select="leg:FormatENURL($explanatoryNotesWholeURI)"/>
											<xsl:attribute name="class" select="'userFunctionalElement'"/>
											<xsl:attribute name="title">Open <xsl:value-of select="$enLabel"/></xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="class" select="'userFunctionalElement active'"/>
										</xsl:otherwise>
									</xsl:choose>
									<span class="btl"/>
									<span class="btr"/>
									<xsl:text>Open full </xsl:text>  
									<xsl:choose>
										<xsl:when test="contains($enLabel, 'Explanatory Notes')">notes</xsl:when>
										<xsl:when test="contains($enLabel, 'Executive Note')">note</xsl:when>
										<xsl:when test="contains($enLabel, 'Policy Note')">note</xsl:when>
										<xsl:when test="contains($enLabel, 'Explanatory Memorandum')">memorandum</xsl:when>
									</xsl:choose>									
									<span class="bbl"/>
									<span class="bbr"/>
								</xsl:element>
							</li>		
						</ul>		
					
						<!-- adding the previous/next toc links-->
						<xsl:call-template name="TSOOutputPreviousTOCNextLinks"/>

						<!-- adding the links for view print links-->
						<xsl:call-template name="TSOOutputViewPrintLinks"/>

					</div>
					<!-- /interface  -->					
					
					<div id="content">
											
							<xsl:if test="leg:IsEnTOC()">
								<div id="info{if (leg:IsDraft(.)) then 'Draft' else 'Section'}">
									<h2>Please note: </h2>
									<p class="intro">
										<xsl:choose>
											<xsl:when test="leg:IsEnPDFOnly(.)">
													
												<xsl:variable name="enShortLabel">
													<xsl:choose>
														<xsl:when test="contains($enLabel, 'Explanatory Notes') or contains($enLabel, 'Executive Note')  or contains($enLabel, 'Policy Note')">Note</xsl:when>
														<xsl:when test="contains($enLabel, 'Explanatory Memorandum')">Memorandum</xsl:when>
													</xsl:choose>
												</xsl:variable>															
												<xsl:choose>

													<xsl:when test="leg:IsDraft(.)">
														<xsl:text>This is a draft </xsl:text>
														<xsl:value-of select="$enShortLabel"/>
														<xsl:text> to accompany this </xsl:text>
														<xsl:value-of select="tso:GetTitleFromType($documentMainType,'')"/>
														<xsl:text>.</xsl:text>
													</xsl:when>

													<xsl:when test="$uriPrefix = 'uksi' and $IsEnAvailable and $IsEmAvailable">
														<xsl:text>This Statutory Instrument was laid before the UK Parliament and the Scottish Parliament and is, therefore, accompanied by an Explanatory Memorandum and an Executive Note for each parliament respectively. Navigate between the two documents using the tabs above. The Memorandum and the Note are only available to view and download in PDF.</xsl:text>
													</xsl:when>
													<xsl:when test="$uriPrefix = 'mwa' and exists(/leg:EN/ukm:Metadata/ukm:Alternatives/ukm:Alternative[contains(@URI, concat($enType,'_')) and contains(@Title, 'Mixed Language')])">
															<xsl:text>This is the mixed language version of these Notes. See the More Resources tab for links to the Welsh language and English language versions. These Notes are only available to download and view in PDF.</xsl:text>													
													</xsl:when>
													<xsl:when test="$uriPrefix = 'anaw' and exists(/leg:EN/ukm:Metadata/ukm:Alternatives/ukm:Alternative[contains(@URI, concat($enType,'_')) and contains(@Title, 'Mixed Language')])">
															<xsl:text>This is the mixed language version of these Notes. See the More Resources tab for links to the Welsh language and English language versions. These Notes are only available to download and view in PDF.</xsl:text>													
													</xsl:when>
													<xsl:when test="exists(/leg:EN/ukm:Metadata/ukm:Alternatives/ukm:Alternative[contains(@URI, concat($enType,'_')) and contains(@Title, 'Revised')])">
															<xsl:text>This is a revised </xsl:text><xsl:value-of select="$enShortLabel"/><xsl:text> to </xsl:text>
															<xsl:value-of select="$legislationTitle"/>
															<xsl:text>. The unrevised version of the </xsl:text><xsl:value-of select="$enShortLabel"/><xsl:text> can be accessed via the More Resources tab. This </xsl:text><xsl:value-of select="$enShortLabel"/><xsl:text> is only available to download and view in PDF.</xsl:text>
													</xsl:when>
													<xsl:otherwise>
														<xsl:text>This </xsl:text>
														<xsl:value-of select="$enShortLabel"/>
														<xsl:text> is only available to download and view as PDF.</xsl:text>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>All reference to 'Parts' and 'sections' are from the </xsl:text><xsl:value-of select="$legislationTitle"/>
												<xsl:text>. For more information about understanding </xsl:text><xsl:value-of select="concat($enLabel, ' ')"/><a href="/help#faqs">click here</a>.
											</xsl:otherwise>
										</xsl:choose>
									</p>
								</div>
							</xsl:if>
											
							<!-- outputing the legislation content-->
							<xsl:call-template name="TSOOutputLegislationContent" />
							
					<div class="interface">
					
						<!-- adding the previous/next/toc links-->
						<xsl:call-template name="TSOOutputPreviousTOCNextLinks"/>
						
					</div>
					<!-- /interface  -->						
					
					<p class="backToTop">
						<a href="#top">Back to top</a>
					</p>							
					
					</div>
					<!--/content-->
					
					
					
				</div>
				<!--#layout2-->
				
				<!-- Where all of the Help divs and modal windows are loaded -->
				<h2 class="interfaceOptionsHeader">Options/Help</h2>
				
				<!-- adding the view/print options-->
				<xsl:call-template name="TSOOutputPrintOptions"	/>				
				
				<!-- adding help tips-->
				<xsl:call-template name="TSOOutputHelpTips" />
			</body>
		</html>
	</xsl:template>
	
	
	<!-- ========== Standard code for outputing legislation content ========= -->
	
	<xsl:template name="TSOOutputLegislationContent">
		<div id="viewLegContents">
			<div class="LegSnippet">
				<xsl:choose>
					<xsl:when test="leg:IsEnPDFOnly(.)">
						<!-- If EN/EM is only available in PDFOnly then display PDF link -->
						<p class="downloadPdfVersion">
						
							<xsl:variable name="pdfLinks" 
								select="/leg:EN/ukm:Metadata/ukm:Alternatives/ukm:Alternative[contains(@URI, concat($enType,'_'))]"/>
						
							<!-- filter out if we have mixed language available -->
							<xsl:variable name="pdfLinks"
								select="if ($documentMainType = ('WelshAssemblyMeasure','WelshStatutoryInstrument','WelshNationalAssemblyAct')) then 
												if (exists($pdfLinks[@Language = 'Mixed' or contains(@Title, 'Mixed Language')])) then 
													$pdfLinks[@Language = 'Mixed' or contains(@Title, 'Mixed Language')]
												else 
													$pdfLinks
											else 
												if (exists($pdfLinks[contains(@Title, 'Revised')])) then 
													$pdfLinks[contains(@Title, 'Revised')]
												else 
													$pdfLinks">
							</xsl:variable>			

							<xsl:choose>
								<xsl:when test="count($pdfLinks) > 1">
									<!-- if there are multiple PDFs and then add a span around it so that they are displayed in two columns-->
									<span>
										<xsl:apply-templates select="$pdfLinks" mode="PDFOnly"/>
									</span>
								</xsl:when>
								<xsl:otherwise>
										<xsl:apply-templates select="$pdfLinks" mode="PDFOnly"/>
								</xsl:otherwise>
							</xsl:choose>
						</p>		

					</xsl:when>
					<xsl:otherwise>
						<!-- adding the tocControlsAddress to the table of contents when it is not PDFOnly-->
						<xsl:if test="count(//leg:ContentsDivision[* except (leg:ContentsNumber, leg:ContentsTitle)]) > 0">
							<xsl:attribute name="id">tocControlsAdded</xsl:attribute>								
						</xsl:if>
						
						<!-- output the legislation content-->
						<xsl:call-template name="TSOOutputContent"/>							
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>		
		
	</xsl:template>		
	
	<xsl:template match="ukm:Alternative" mode="PDFOnly">

	 	<xsl:variable name="dateSuffix">
			<!-- add a date suffix if there are other versions of this type with the same Title and Language -->
			<xsl:if test="count(../*[concat(@Title, ':', @Language) = current()/concat(@Title, ':', @Language)]) > 1">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="format-date(xs:date(@Date), '[D01]/[M01]/[Y0001]')" />
				<xsl:text>)</xsl:text>
			</xsl:if>
		 </xsl:variable>
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="exists(@Title)">
					<xsl:value-of select="@Title" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:analyze-string select="local-name(.)" regex="[A-Z][a-z]+">
						<xsl:matching-substring>
							<xsl:choose>
								<xsl:when test=". = ('Of', 'In')"><xsl:value-of select="lower-case(.)" /></xsl:when>
								<xsl:when test=". = 'Alternative'">Notes</xsl:when>
								<xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
							</xsl:choose>
							<xsl:if test="position() != last()">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		 	

		<xsl:variable name="title" >
			<xsl:choose>
				<xsl:when test="starts-with($title, 'Mixed Language')"><xsl:value-of select="concat(substring-after($title, 'Mixed Language'), $dateSuffix, ' - ', 'Mixed Language')"/></xsl:when>
				<xsl:when test="@Language = 'Mixed'"><xsl:value-of select="concat($title, $dateSuffix, ' - Mixed Language')" /></xsl:when>
				<xsl:when test="exists(@Language)"><xsl:value-of select="concat($title, $dateSuffix, ' - ', @Language)" /></xsl:when>
				<xsl:when test="matches(@URI, '_en(_[0-9]{3})?.pdf$') and $documentMainType = ('WelshAssemblyMeasure','WelshStatutoryInstrument','WelshNationalAssemblyAct')"><xsl:value-of select="concat($title, $dateSuffix, ' - English')"/></xsl:when>
				<!-- There are sometimes Welsh-language versions of UKSIs, so don't restrict this to MWAs & WSIs -->
				<xsl:when test="matches(@URI, '_we(_[0-9]{3})?.pdf$')"><xsl:value-of select="concat($title, $dateSuffix, ' - Welsh')"/></xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="$title" />
					<xsl:value-of select="$dateSuffix" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<a class="pdfLink" href="{@URI}">
			<img class="imgIcon" alt="" src="/images/chrome/pdfIconMed.gif"/>										
				 <xsl:text>View PDF</xsl:text>
			<img class="pdfThumb"  src="{replace(replace(substring-after(@URI, 'http://www.legislation.gov.uk'), '/pdfs/', '/images/'), '.pdf', '.jpg')}" 
			  title="{$title}" 
			  alt="{$title}" />
		</a>	
	</xsl:template>
	
	
	<xsl:template name="TSOOutputContent">
		<xsl:apply-templates select="leg:EN">
			<xsl:with-param name="showSection" select="$nstSection" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="leg:Contents/leg:ContentsTitle" priority="1000">
		<!-- legislation EN titles will not be displayed on the table of content page -->
		<!--<h1 class="ENTitle"><xsl:value-of select="$enLabel"/></h1>
		<h1 class="ENTitle"><xsl:value-of select="$legislationTitle"/></h1>
		<xsl:call-template name="TSOOutputLegislationNumber"/>-->
	</xsl:template>
	
	<!-- only displaying the legislation title. No need to display the heading Explanatory Notes/Explanatory Memorandum-->
	<xsl:template match="leg:ENprelims/leg:Title">
		<h2 class="ENTitle">
			<xsl:apply-templates/>
		</h2>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>
	
	<xsl:template name="TSOOutputLegislationNumber">
		<xsl:choose>
			<xsl:when test="/leg:EN/ukm:Metadata/ukm:SecondaryMetadata">
				<xsl:variable name="nstMetadata" as="element()" select="/leg:EN/ukm:Metadata/ukm:SecondaryMetadata"/>
				<h2 class="ENNo">
					<xsl:value-of select="$nstMetadata/ukm:Year/@Value"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="tso:GetNumberForLegislation($nstMetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value, $nstMetadata/ukm:Year/@Value, $nstMetadata/ukm:Number/@Value)"/>
					<xsl:for-each select="$nstMetadata/ukm:AlternativeNumber">
						<xsl:text> (</xsl:text>
						<xsl:value-of select="@Category"/>
						<xsl:text>. </xsl:text>
						<xsl:value-of select="@Value"/>
						<xsl:text>)</xsl:text>
					</xsl:for-each>
				</h2>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="FuncOutputENPrelimsPreContents"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="leg:DateOfEnactment"/>
	
	<xsl:template match="leg:ContentsDivision[* except (leg:ContentsNumber, leg:ContentsTitle)]">
		<xsl:variable name="html" as="element()">
			<xsl:next-match />
		</xsl:variable>
		<li class="{$html/@class} tocDefaultExpanded">
			<xsl:sequence select="$html/*" />
		</li>
	</xsl:template>	

	<xsl:function name="leg:IsEnTOC" as="xs:boolean">
		 <xsl:sequence select="$paramsDoc/parameters/view ='contents' " />
	</xsl:function>	
	
	<xsl:function name="leg:IsEnPDFOnly" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()" />
		 <xsl:sequence select="not(exists($legislation/leg:EN/leg:Contents) or exists($legislation/leg:EN/leg:ExplanatoryNotes))" />
	</xsl:function>		
	
	<!-- ========== Standard code for legislation title ========= -->	
	<xsl:template name="TSOOutputLegislationHeading">
		<h1 class="pageTitle{if (leg:IsDraft(.)) then ' draft' else ''}">
			<xsl:value-of select="$legislationTitle"/>
		</h1>	
	</xsl:template>
	
	<xsl:template name="TSOOutputLegislationTitle">
		<xsl:variable name="category" as="xs:string" select="leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentCategory/@Value" />
		<xsl:variable name="mainType" as="xs:string" select="leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />
		<xsl:variable name="number" as="xs:string" select="leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:Number/@Value" />
		<xsl:variable name="year" as="xs:integer?" select="leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:Year/@Value" />
		<xsl:variable name="altNumbers" as="element(ukm:AlternativeNumber)*" select="leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:AlternativeNumber" />
		
			<xsl:choose>
				<xsl:when test="starts-with(leg:EN/ukm:Metadata/dc:title[not(@xml:lang='cy')],'Explanatory Notes to ')">
					<xsl:value-of select="substring-after(leg:EN/ukm:Metadata/dc:title[not(@xml:lang='cy')],'Explanatory Notes to ')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="leg:EN/ukm:Metadata/dc:title[not(@xml:lang='cy')]"/>
				</xsl:otherwise>
			</xsl:choose>
		
		<!--	Hiding the chapter number from the title
			<xsl:choose>
				<xsl:when test="$mainType = 'UnitedKingdomChurchInstrument'" />
				<xsl:when test="$category = 'secondary'">
					<xsl:text> (</xsl:text>
					<xsl:choose>
						<xsl:when test="$mainType = 'ScottishStatutoryInstrument'">S.S.I. </xsl:when>
						<xsl:when test="$mainType = 'NorthernIrelandStatutoryRule'">S.R. </xsl:when>
						<xsl:otherwise>S.I. </xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="concat($year, '/', $number, ')')" />
					<xsl:for-each select="$altNumbers">
						<xsl:text> (</xsl:text>
						<xsl:choose>
							<xsl:when test="@Category = 'NI'">
								<xsl:text>N.I. </xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(@Category, '. ')" />
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="concat(@Value, ')')" />
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$mainType = 'UnitedKingdomChurchMeasure'">
					<xsl:value-of select="concat(' (No. ', $number, ')')" />
				</xsl:when>
				<xsl:when test="$mainType = 'ScottishAct' and $year > 1500">
					<xsl:value-of select="concat(' (asp ', $number, ')')" />
				</xsl:when>
				<xsl:when test="$mainType = 'WelshAssemblyMeasure'">
					<xsl:value-of select="concat(' (nawm ', $number, ')')" />
				</xsl:when>
				<xsl:when test="$mainType = 'WelshNationalAssemblyAct'">
					<xsl:value-of select="concat(' (anaw ', $number, ')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> (</xsl:text>
					<xsl:if test="$altNumbers[@Category = 'Regnal']">
						<xsl:value-of select="concat(translate($altNumbers[@Category = 'Regnal']/@Value, '_', ' '), ' ')" />
					</xsl:if>
					<xsl:value-of select="concat('c. ', $number)" />
					<xsl:if test="$mainType = 'ScottishAct'"> [S]</xsl:if>
					<xsl:if test="$mainType = 'IrelandAct'"> [I]</xsl:if>
					<xsl:text>)</xsl:text>
				</xsl:otherwise>
			</xsl:choose> -->
	</xsl:template>


	<!-- ========== Breadcrumb ======================== -->
	<xsl:template name="TSOOutputBreadcrumbItems">
		  <!--/#breadcrumbControl --> 
			<div id="breadCrumb">
				<h3 class="accessibleText">You are here:</h3>		
				<ul>
					<xsl:choose>
						<xsl:when test="leg:IsTOC()">
							<xsl:apply-templates select="/leg:EN" mode="TSOBreadcrumbItem"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]" />
							<xsl:choose>
								<xsl:when test="exists($nstSection)">
									<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]" mode="TSOBreadcrumbItem"/>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
	</xsl:template>	
	
	
	<!--
	<xsl:template name="TSOOutputBreadcrumbItems">
			<div id="breadCrumb">
				<h3 class="accessibleText">You are here:</h3>		
				<ul>
					<xsl:apply-templates select="/leg:EN" mode="TSOBreadcrumbItem"/>
					<li class="activetext"><xsl:value-of select="$enLabel" /></li>
				</ul>
			</div>
	</xsl:template>-->
	
	<!-- creating link for the whole act  -->
	<xsl:template match="leg:EN" mode="TSOBreadcrumbItem" priority="20">
		<xsl:variable name="nstMetadata" as="element()"
			select="/leg:EN/ukm:Metadata/(ukm:ENmetadata)" />
		<xsl:variable name="breadcrumb">
			<xsl:choose>
				<xsl:when test="$nstMetadata/ukm:Number">
					<xsl:value-of select="$nstMetadata/ukm:Year/@Value"/>&#160;<xsl:value-of select="tso:GetNumberForLegislation($nstMetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value, $nstMetadata/ukm:Year/@Value, $nstMetadata/ukm:Number/@Value)" /><xsl:apply-templates select="$nstMetadata/ukm:AlternativeNumber" mode="series"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>ISBN </xsl:text>
					<xsl:value-of select="tso:formatISBN($nstMetadata/ukm:ISBN/@Value)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<li class="first">
			<xsl:choose>
				<xsl:when test="exists($tocURI)">
					<a href="{leg:FormatURL($tocURI)}">
						<xsl:sequence select="$breadcrumb" /> 
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$breadcrumb" />
				</xsl:otherwise>
			</xsl:choose>
		</li>	
		<li>
			<xsl:choose>
				<xsl:when test="string-length($explanatoryNotesTOCURI) ne 0">
					<a href="{leg:FormatENURL($explanatoryNotesTOCURI)}">
						<xsl:sequence select="$enLabel" /> 
					</a>								
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$enLabel" />
				</xsl:otherwise>
			</xsl:choose>
		</li>
		<xsl:choose>
			<xsl:when test="leg:IsEnPDFOnly(/)"/>
			<xsl:when test="leg:IsTOC()">
				<li class="activetext">Table of contents</li>
			</xsl:when>
			<xsl:when test="$explanatoryNotesWholeURI = $strCurrentURIs">
				<li class="activetext">
					<xsl:text>Open full </xsl:text>
					<xsl:choose>
						<xsl:when test="contains($enLabel, 'Explanatory Notes')">notes</xsl:when>					
						<xsl:when test="contains($enLabel, 'Executive Note') ">note</xsl:when>
						<xsl:when test="contains($enLabel, 'Policy Note') ">note</xsl:when>
						<xsl:when test="contains($enLabel, 'Explanatory Memorandum') ">memorandum</xsl:when>
					</xsl:choose>
				</li>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	

	<xsl:template match="*[@DocumentURI]" mode="TSOBreadcrumbItem" priority="10">
		<li>
			<xsl:choose>
				<xsl:when test="$strCurrentURIs = @DocumentURI">
					<xsl:attribute name="class" select="'active'"/>
						<xsl:next-match />
				</xsl:when>
				<xsl:otherwise>
					<a href="{leg:FormatENURL(@DocumentURI)}">
						<xsl:next-match />
					</a>
				</xsl:otherwise>
			</xsl:choose>		
		</li>
	</xsl:template>	
	
	<xsl:template match="*[leg:Title]" mode="TSOBreadcrumbItem" priority="2">
		<xsl:apply-templates select="leg:Title" mode="TSOBreadcrumbItem"/>
	</xsl:template>
	
	<xsl:template match="*[leg:Number]" mode="TSOBreadcrumbItem" priority="2">
		<xsl:apply-templates select="leg:Number" mode="TSOBreadcrumbItem"/>
	</xsl:template>
	
	<xsl:template match="leg:Title" mode="TSOBreadcrumbItem">
		<xsl:choose>
			<xsl:when test="leg:CitationSubRef"><xsl:value-of select="leg:CitationSubRef" separator=" / " /></xsl:when>
			<xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	

	<!-- ========== Standard code for view/print ========= -->	
	<xsl:template name="TSOOutputViewPrintLinks">
		<ul id="viewPrintControl">
			<li class="view">		
				<xsl:element name="{if (leg:IsEnPDFOnly(.)) then 'span' else 'a'}">		
					<xsl:choose>
						<xsl:when test="leg:IsEnPDFOnly(.)">
							<xsl:attribute name="class">userFunctionalElement disabled</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">userFunctionalElement</xsl:attribute>						
							<xsl:attribute name="href" select="concat('?', leg:set-query-params('view', 'plain' ))"/>
						</xsl:otherwise>
					</xsl:choose>
					<span class="btl"/>
					<span class="btr"/>
					Plain View
					<span class="bbl"/>
					<span class="bbr"/>
				</xsl:element>
			</li>
			<li class="print">
				<xsl:element name="{if (leg:IsEnPDFOnly(.)) then 'span' else 'a'}">			
					<xsl:choose>
						<xsl:when test="leg:IsEnPDFOnly(.)">
							<xsl:attribute name="class">userFunctionalElement disabled</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
							<xsl:attribute name="href">#printOptions</xsl:attribute>					
						</xsl:otherwise>
					</xsl:choose>				
					<span class="btl"/>
					<span class="btr"/>Print Options
					<span class="bbl"/>
					<span class="bbr"/>
				</xsl:element>
			</li>
		</ul>		
		
	</xsl:template>
	
	
<xsl:template name="TSOOutputPrintOptions">
		<div id="printOptions" class="interfaceOptions ">
			<h3 class="accessibleText">Print Options</h3>
			<ul class="optionList">
				<xsl:choose>
					<xsl:when test="leg:IsEnTOC()">
						<xsl:apply-templates select="leg:EN" mode="TSOPrintOptions"/>
					</xsl:when>				
					<xsl:otherwise>
						<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]" />
						<xsl:if test="exists($nstSection)">
<!--							<xsl:for-each select="$nstSection/ancestor-or-self::*[@DocumentURI]">
								<br/>		
								[<xsl:value-of select="position()"/> : <xsl:value-of select="name()" />]
							</xsl:for-each>
							<br/>			-->				
							<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]" mode="TSOPrintOptions"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</ul>
		</div>	
			
		<xsl:choose>
			<xsl:when test="leg:IsEnTOC()">
					<xsl:apply-templates select="leg:EN" mode="TSOPrintOptionsWarnings"/>
			</xsl:when>				
			<xsl:otherwise>
				<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]" />
				<xsl:if test="exists($nstSection)">
					<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]" mode="TSOPrintOptionsWarnings"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
			
		
	</xsl:template>
		
	
	
	<!-- for print options -->
	<xsl:template match="leg:EN" mode="TSOPrintOptions" priority="1000">
		<xsl:choose>
			<xsl:when test="leg:IsEnPDFOnly(/)">
				<xsl:for-each select="ukm:Metadata/ukm:Alternatives/ukm:Alternative">
					<li class="printToc">
						<xsl:variable name="title" select="concat($enLabel, ' - ', if (@Date) then @Date else position() )"/>

						<h4><span class="accessibleText">Print </span> <xsl:value-of select="$title"/></h4>
						<ul>
							<li><a href="{@URI}" target="_blank" class="pdfLink">PDF<span class="accessibleText"> </span></a></li>
						</ul>
					</li>				
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="leg:IsEnTOC()">
			<li class="printToc">
				<h4><span class="accessibleText">Print </span>Table of Contents</h4>
				<ul>
					<li><a href="{leg:FormatPDFDataURL($dcIdentifier)}" target="_blank" class="pdfLink">PDF<span class="accessibleText"> table of contents</span></a></li>
					<li><a href="{leg:FormatHTMLDataURL($dcIdentifier)}" target="_blank" class="htmLink">Web page<span class="accessibleText"> table of contents</span></a></li>
				</ul>
			</li>				
			</xsl:when>
		</xsl:choose>
		<xsl:next-match/>
	</xsl:template>
	
	<xsl:template match="leg:EN | leg:Division | leg:SubDivision | leg:CommentaryPart | leg:CommentaryChapter | leg:CommentaryP1" mode="TSOPrintOptions" >
		<li class="printWhole">
			<xsl:variable name="displayText">
				 <xsl:choose>
					<xsl:when test="@DocumentURI = $dcIdentifier and not(self::leg:EN)">This <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/> only</xsl:when>
						<xsl:otherwise>The <xsl:if test="not(self::leg:EN)">Whole </xsl:if><xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/></xsl:otherwise>						
				</xsl:choose>					
			</xsl:variable>			
	
			<xsl:variable name="provisions" as="xs:integer">
				<xsl:choose>
					<xsl:when test="@NumberOfProvisions"><xsl:value-of select="xs:integer(@NumberOfProvisions)"/></xsl:when>					
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
	
			<h4><span class="accessibleText">Print </span><xsl:value-of select="$displayText"/></h4>
			<ul>
						<li><a class="pdfLink">
							<xsl:choose>
						<xsl:when test="$provisions > $paragraphThreshold">
							<xsl:attribute name="href" select="concat ('#print',  name(), 'ModPdf')"/>
							<xsl:attribute name="class" select="'pdfLink warning'"/>							
								</xsl:when>
								<xsl:otherwise>
							<xsl:attribute name="href" select="leg:FormatPDFDataURL(@DocumentURI)"/>
							<xsl:attribute name="target">_blank</xsl:attribute>							
								</xsl:otherwise>
							</xsl:choose>	
					PDF<span class="accessibleText"> <xsl:value-of select="$displayText"/></span></a></li>
				<li><a class="htmLink">
							<xsl:choose>
						<xsl:when test="$provisions > $paragraphThreshold">
							<xsl:attribute name="href" select="concat ('#print',  name(), 'ModHtm')"/>
							<xsl:attribute name="class" select="'htmLink warning'"/>							
								</xsl:when>
								<xsl:otherwise>
							<xsl:attribute name="href" select="leg:FormatHTMLDataURL(@DocumentURI)"/>
							<xsl:attribute name="target">_blank</xsl:attribute>							
								</xsl:otherwise>
							</xsl:choose>	
					Web page<span class="accessibleText"> <xsl:value-of select="$displayText"/></span></a></li>
			</ul>
		</li>		
	</xsl:template>	
	<xsl:template match="*" mode="TSOPrintOptions"/>	
	
	<xsl:template match="leg:EN" mode="TSOPrintOptionsXXX">
		<xsl:variable name="category" select="tso:GetCategory(ukm:Metadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value)"/>
		<xsl:choose>
				<xsl:when test="$category =('Act', 'Measure')">Full Notes</xsl:when>
				<xsl:when test="$category =('Instrument', 'Order', 'Rule')">Full Memorandum</xsl:when>
		</xsl:choose>	
	</xsl:template>	
	<xsl:template match="leg:Division" mode="TSOPrintOptionsXXX">Division</xsl:template>
	<xsl:template match="leg:SubDivision" mode="TSOPrintOptionsXXX">Sub Division</xsl:template>	
	<xsl:template match="leg:CommentaryPart" mode="TSOPrintOptionsXXX">Part</xsl:template>		
	<xsl:template match="leg:CommentaryChapter" mode="TSOPrintOptionsXXX">Chapter</xsl:template>			
	<xsl:template match="leg:CommentaryP1" mode="TSOPrintOptionsXXX">Section</xsl:template>			
	<xsl:template match="*" mode="TSOPrintOptionsXXX"/>	
		
		
	
	<xsl:template match="leg:EN | leg:Division | leg:SubDivision | leg:CommentaryPart | leg:CommentaryChapter | leg:CommentaryP1" mode="TSOPrintOptionsWarnings" >
		<xsl:if test="@NumberOfProvisions > $paragraphThreshold">
		
			<xsl:variable name="displayText">
				 <xsl:choose>
						<xsl:when test="@DocumentURI = $dcIdentifier and not(self::leg:EN)">This <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/> only</xsl:when>
						<xsl:otherwise>The Whole <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/></xsl:otherwise>						
				</xsl:choose>					
			</xsl:variable>		
					
		<xsl:call-template name="TSOOutputWarningMessage">
				<xsl:with-param name="messageId" select="concat('print',  name(), 'ModHtm')"/>	
			<xsl:with-param  name="messageType" select=" 'webWarning' " />
				<xsl:with-param  name="messageHeading" >You have chosen to open <xsl:value-of select="$displayText" /></xsl:with-param>
				<xsl:with-param  name="message"><xsl:value-of select="$displayText"/> you have selected contains over <xsl:value-of select="$paragraphThreshold"/> provisions and might take some time to download.</xsl:with-param>		
				<xsl:with-param  name="continueURL" select="leg:FormatHTMLDataURL(@DocumentURI)" />							
		</xsl:call-template>	
		 
		<xsl:call-template name="TSOOutputWarningMessage">
				<xsl:with-param name="messageId" select="concat('print',  name(), 'ModPdf')"/>	
			<xsl:with-param  name="messageType" select=" 'pdfWarning' " />
				<xsl:with-param  name="messageHeading" >You have chosen to open <xsl:value-of select="$displayText" /> as a PDF</xsl:with-param> 
				<xsl:with-param  name="message"><xsl:value-of select="$displayText"/> you have selected contains over <xsl:value-of select="$paragraphThreshold"/> provisions and might take some time to download.</xsl:with-param>		
				<xsl:with-param  name="continueURL" select="leg:FormatPDFDataURL(@DocumentURI)" />							
		</xsl:call-template>	
			
		</xsl:if>
	</xsl:template>
	<xsl:template match="*" mode="TSOPrintOptionsWarnings"/>				
		
	
	<xsl:function name="leg:FormatHTMLDataURL" as="xs:string">
		<xsl:param name="url"/>
		
		<xsl:variable name="legislationDataURL">
			<xsl:choose>
				<xsl:when test="$requestInfoDoc/request/server-name = 'staging.legislation.gov.uk'">http://staging.legislation.data.gov.uk</xsl:when>
				<xsl:when test="$requestInfoDoc/request/server-name = 'test.legislation.gov.uk'">http://test.legislation.data.gov.uk</xsl:when>
				<xsl:otherwise>http://legislation.data.gov.uk</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence select="concat($legislationDataURL, substring-after($url,'http://www.legislation.gov.uk'), '/data.htm?',leg:set-query-params('wrap', 'true' )) "/>
	</xsl:function>		
	
	
	<xsl:function name="leg:FormatPDFDataURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:sequence select="concat(substring-after($url,'http://www.legislation.gov.uk'), '/data.pdf') "/>
</xsl:function>		
		

	<!-- ========== Standard code for previous and next ========= -->

	<xsl:template name="TSOOutputPreviousTOCNextLinks">
		<!-- adding the previous next section -->
		<xsl:variable name="prev" as="element(atom:link)?" select="leg:EN/ukm:Metadata/atom:link[@rel='prev']" />
		<xsl:variable name="next" as="element(atom:link)?" select="leg:EN/ukm:Metadata/atom:link[@rel='next']" />
		

		
		<div class="prevNextNav">
			<ul>
				<li class="prev">
					<xsl:element name="{if (exists($prev)) then 'a' else 'span'}">
						<xsl:choose>
							<xsl:when test="exists($prev)">
								<xsl:attribute name="href" select="leg:FormatENURL($prev/@href)" />
								<xsl:attribute name="class" select="concat('userFunctionalElement', ' nav')" />
								<xsl:attribute name="title">
									<xsl:choose>
										<xsl:when test="exists($prev/@title)">
											<xsl:value-of select="lower-case($prev/@title)" />
										</xsl:when>
									</xsl:choose>
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class" select="'userFunctionalElement disabled'" />
							</xsl:otherwise>
						</xsl:choose>
						<span class="btl"/>
						<span class="btr"/>
						<xsl:text>Previous</xsl:text>
						<span class="bbl"/>
						<span class="bbr"/>
					</xsl:element>
				</li>
				<li class="toc">
					<xsl:element name="{if (leg:IsEnTOC() or leg:IsEnPDFOnly(.)) then 'span' else 'a' }">
						<xsl:choose>
							<xsl:when test="leg:IsEnPDFOnly(.)">
								<xsl:attribute name="class" select="'userFunctionalElement disabled'" />
							</xsl:when>						
							<xsl:when test="leg:IsEnTOC()">
								<xsl:attribute name="class" select="'userFunctionalElement active nav'" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="explanatoryNotesTocURI" as="xs:string" select="leg:EN/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents']/@href" />			
								<xsl:attribute name="href" select="leg:FormatENURL($explanatoryNotesTocURI)"/>
								<xsl:attribute name="class" select="'userFunctionalElement nav'" />
								<xsl:attribute name="title"><xsl:value-of select="$enLabel"/> Table of contents</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<span class="btl"/>
						<span class="btr"/>
						<xsl:value-of select="$enLabel"/><xsl:if test="not(leg:IsEnPDFOnly(.))"> Table of contents</xsl:if>
						<span class="bbl"/>
						<span class="bbr"/>
					</xsl:element>
				</li>				
				<li class="next">
					<xsl:element name="{if (exists($next)) then 'a' else 'span'}">
						<xsl:choose>
							<xsl:when test="exists($next)">
								<xsl:attribute name="href" select="leg:FormatENURL($next/@href)" />
								<xsl:attribute name="class" select="concat('userFunctionalElement', ' nav')" />
								<xsl:attribute name="title">
									<xsl:choose>
										<xsl:when test="exists($next/@title)">
											<xsl:value-of select="lower-case($next/@title)" />
										</xsl:when>
									</xsl:choose>
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class" select="'userFunctionalElement disabled'" />
							</xsl:otherwise>
						</xsl:choose>
						<span class="btl"/>
						<span class="btr"/>
						<xsl:text>Next</xsl:text>
						<span class="bbl"/>
						<span class="bbr"/>
					</xsl:element>
				</li>
			</ul>
		</div>
	</xsl:template>
	
	<!-- ========== CSS Styles for Legislation =============-->
	<xsl:template name="TSOOutputAddLegislationStyles">
		<style type="text/css">
			/* Legislation stylesheets - load depending on content type */
			@import "/styles/explanatoryNotes.css";						
			<xsl:variable name="uriPrefix" as="xs:string"><xsl:value-of select="tso:GetUriPrefixFromType(/leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value, /leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:Number/@Value)"/></xsl:variable>
			<xsl:choose>
				<xsl:when test="$uriPrefix ='ukpga' or  $uriPrefix ='ukla'  or  $uriPrefix ='cukla'  or  $uriPrefix ='ukcm'  ">
					<xsl:text>
						@import "/styles/legislation.css";
						@import "/styles/primarylegislation.css";
					</xsl:text>
				</xsl:when>				
				<xsl:when test="$uriPrefix ='apgb' or  $uriPrefix ='aosp'  or  $uriPrefix ='aip'  or  $uriPrefix ='mnia'  or  $uriPrefix ='apni'  or  $uriPrefix ='mwa'  or  $uriPrefix ='anaw'">
					<xsl:text>
						@import "/styles/SPOprimarylegislation.css";
						@import "/styles/SPOlegislation.css";
						@import "/styles/legislation.css";
						@import "/styles/primarylegislation.css";
					</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix ='aep' or  $uriPrefix ='asp' ">
					<xsl:text>
						@import "/styles/SPOlegislation.css";
						@import "/styles/legislation.css";
						@import "/styles/primarylegislation.css";
					</xsl:text>					
				</xsl:when>
				<xsl:when test="$uriPrefix ='nia' ">
					<xsl:text>
						@import "/styles/NIlegislation.css";
						@import "/styles/legislation.css";
						@import "/styles/secondarylegislation.css";			
					</xsl:text>					
				</xsl:when>
				<xsl:when test="$uriPrefix = ('uksi', 'ssi', 'wsi', 'nisr', 'ukci', 'nisi', 'ukmo', 'uksro')">
					<xsl:text>
						@import "/styles/legislation.css";
						@import "/styles/secondarylegislation.css";
					</xsl:text>					
				</xsl:when>												
			</xsl:choose>
			@import "/styles/legislationOverwrites.css";			
			/* End of Legislation stylesheets */	
		</style>		
		
		<xsl:comment><![CDATA[[if IE 6]>
				<style type="text/css">
					@import "/styles/IE/ie6LegAdditions.css";
				</style>
			<![endif]]]></xsl:comment>
		<xsl:comment><![CDATA[[if IE 7]>
				<style type="text/css">
					@import "/styles/ie7LegAdditions.css";
				</style>
			<![endif]]]></xsl:comment>				
							
	</xsl:template>	


	<!-- ========== Help Tips ========================= -->
	
	<xsl:template name="TSOOutputHelpTips">
		<!-- displaying the output help tips for EN/EM tabs -->
		<xsl:call-template name="TSOOutputENsHelpTips"/>
	</xsl:template>	
	
	<xsl:function name="leg:FormatENURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:choose>
			<xsl:when test="string-length($url) ne 0">
				<!-- todo: post launch <xsl:value-of select="string-join((substring-after($url,'http://www.legislation.gov.uk'), $requestInfoDoc/request/request-querystring), '?')"/>-->
				<xsl:value-of select="concat(substring-after($url,'http://www.legislation.gov.uk'), if (string-length($requestInfoDoc/request/query-string) >0) then concat('?',$requestInfoDoc/request/query-string) else '') "/>
			</xsl:when>
			<xsl:otherwise>
				<!-- if the $url is not available then link to the same page -->
				<xsl:value-of select="string-join(($requestInfoDoc/request/request-url, $requestInfoDoc/request/request-querystring), '?')"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>

	<xsl:function name="leg:IsDraft" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="contains($legislation/leg:EN/ukm:Metadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value, 'Draft')" />
	</xsl:function>
	

</xsl:stylesheet>
