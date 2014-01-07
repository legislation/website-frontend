<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<!-- UI IA page output  -->

<!-- Version 0.01 -->
<!-- Created by GRiff Chamberlain -->
<!-- Last changed 01/08/2012  -->
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
	<xsl:import href="statuswarning.xsl"/>
	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="uicommon.xsl"/>	
	
	<xsl:variable name="paragraphThreshold" select="200"/>
	<xsl:variable name="dcIdentifier" select="leg:ImpactAssessment/ukm:Metadata/dc:identifier[starts-with(.,'http://')]"/>
	<xsl:variable name="strCurrentURIs" select="/leg:ImpactAssessment/ukm:Metadata/dc:identifier, 
		/leg:ImpactAssessment/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasPart']/@href" />	
	
	<xsl:variable name="language" select="if (/leg:ImpactAssessment/@xml:lang) then /leg:Legislation/@xml:lang else 'en'"/>
	
	<xsl:variable name="impactYear" as="xs:string?" select="leg:ImpactAssessment/ukm:Metadata/ukm:ImpactAssessmentMetadata/ukm:Year/@Value" />
	<xsl:variable name="impactLegYear" as="xs:string?" select="leg:ImpactAssessment/ukm:Metadata/ukm:Legislation//ukm:Year/@Value" />
	<xsl:variable name="impactNumber" as="xs:string?" select="leg:ImpactAssessment/ukm:Metadata/ukm:ImpactAssessmentMetadata/ukm:Number/@Value" />
	
	<xsl:variable name="impactLegNumber" as="xs:string?" select="leg:ImpactAssessment/ukm:Metadata/ukm:Legislation//ukm:Number/@Value" />
	
	<xsl:variable name="impactId" as="xs:string?" select="tokenize(leg:ImpactAssessment/ukm:Metadata/dc:identifier,'/')[last()]" />
	
	<xsl:variable name="legislationTitle"><xsl:call-template name="TSOOutputLegislationTitle"/></xsl:variable>
	
	<xsl:variable name="iaStage" as="xs:string?" select="/leg:ImpactAssessment/ukm:Metadata/ukm:ImpactAssessmentMetadata/ukm:DocumentClassification/ukm:DocumentStage/@Value" />
	
	
	
	<xsl:variable name="iaTitle">
		<xsl:choose>
			<xsl:when test="$language = 'cy' and count(/leg:Legislation/ukm:Metadata/dc:title) &gt; 1">
				<xsl:value-of select="/leg:ImpactAssessment/ukm:Metadata/dc:title[@xml:lang='cy']" />
			</xsl:when>
			<xsl:when test="$language = 'cy' and count(/leg:Legislation/ukm:Metadata/dc:title) = 1 ">
				<xsl:value-of select="/leg:ImpactAssessment/ukm:Metadata/dc:title" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="/leg:ImpactAssessment/ukm:Metadata/dc:title[not(@xml:lang='cy')]" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="introURI" as="xs:string?" select="leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/act/introduction']/@href" />			
	
	<xsl:variable name="iaWholeURI" as="xs:string" select="leg:ImpactAssessment/@DocumentURI" />				
	
	<xsl:variable name="tocURI" as="xs:string?" select="leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/act/toc']/@href" />	
	
	<xsl:variable name="iaTOCURI" as="xs:string?" select="leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents']/@href" />		

			
	<xsl:variable name="resourceURI" as="xs:string" 
		select="leg:ImpactAssessment/ukm:Metadata/atom:link[@title='More Resources']/@href" />				
	
	<xsl:variable name="impactURI" as="xs:string*" 
		select="/leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/impacts'][1]/@href" />	
		
	<xsl:variable name="emURI" as="xs:string?" select="/leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/memorandum/toc']/@href" />
	
	<xsl:variable name="enURI" as="xs:string?" 
		select="/leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/notes/toc']/@href | 
			/leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/executive-note/toc']/@href" />
	
	<xsl:variable name="pnURI" as="xs:string?"
		select="//ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/policy-note/toc']/@href"/>
	
	<xsl:variable name="part" as="element()*" >
		<xsl:sequence select="/leg:ImpactAssessment//ukm:Alternatives">
			
		</xsl:sequence>
	</xsl:variable>
		
		


	<!-- used by uicommon.xsl - this is the legislation main type -->
	<xsl:variable name="documentMainType" as="xs:string?" select="/leg:ImpactAssessment/ukm:Metadata/ukm:Legislation/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>
	
	<xsl:variable name="legislationYear" as="xs:string?" select="/leg:ImpactAssessment/ukm:Metadata/ukm:Legislation/ukm:Year/@Value"/>
	
	<xsl:variable name="legislationNumber" as="xs:string?" select="/leg:ImpactAssessment/ukm:Metadata/ukm:Legislation/ukm:Number/@Value"/>
	
	<xsl:variable name="legislationAlternativeNumber" as="element()*" select="/leg:ImpactAssessment/ukm:Metadata/ukm:Legislation/ukm:AlternativeNumber"/>
	
	<xsl:variable name="uriPrefix" as="xs:string?">
		<xsl:value-of select="if (exists($documentMainType)) then tso:GetUriPrefixFromType($documentMainType, $legislationYear) else ()"/>
	</xsl:variable>
		
		
	<xsl:variable name="IsEnAvailable" as="xs:boolean" select="exists($enURI)"/>
	<xsl:variable name="IsEmAvailable" as="xs:boolean" select="exists($emURI)"/>
	<xsl:variable name="IsPnAvailable" as="xs:boolean" select="exists($pnURI)"/>
	
		
	<xsl:variable name="IsMoreResourcesAvailable" as="xs:boolean" 
		select="if ($documentMainType) then tso:ShowMoreResources(/) else false()"/>	
		
	<xsl:variable name="IsImpactAssessmentsAvailable" as="xs:boolean" 
		select="exists($impactURI)"/>
	
	
	<xsl:variable name="IsLegislationView" as="xs:boolean" 
		select="exists($tocURI)"/>
		
	
	<xsl:variable name="enType" as="xs:string?" select="if (contains($dcIdentifier, '/memorandum')) then 'em' else 'en'" />
	<xsl:variable name="iaLabel" select="'Impact Assessment'" />
	
	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="$legislationTitle"/> - <xsl:value-of select="$iaLabel"/>
				</title>
				<!--<meta name="DC.Date.Modified" content="{/leg:ImpactAssessment/ukm:Metadata/dc:modified}" />-->
				<xsl:apply-templates select="/leg:ImpactAssessment/ukm:Metadata" mode="HTMLmetadata" />
				
				<xsl:call-template name="TSOOutputAddLegislationStyles" />
			</head>		
			<body xml:lang="en" lang="en" dir="ltr" id="leg" about="{$dcIdentifier}"  class="toc">
				<div id="layout2" class="legIAContent">
			
					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>
								
					<!-- adding title -->
					<xsl:call-template name="TSOOutputLegislationHeading"/>
					
					 <!-- breadcrumb -->
					<xsl:call-template name="TSOOutputBreadcrumbItems"	/>

					<!-- Sub Navigation tabs-->
					<xsl:choose>
						<xsl:when test="not($IsLegislationView)">
							<ul id="legSubNav">
								<li id="legIALink">
									<span class="presentation" />
									<a href="{leg:FormatURL($impactURI)}">Impact Assessments</a>
									<a href="#moreIATabHelp" class="helpItem helpItemToBot">
										<img src="/images/chrome/helpIcon.gif" alt=" Help about ImpactAssessments" />
									</a>
								</li>
							</ul>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="TSOOutputSubNavTabs" />
						</xsl:otherwise>
					</xsl:choose>
						
						
					<div class="interface">
						<!-- currently not needed as we only have pdf  -->
						<!--<ul id="wholeNav">
							<li class="wholeuri">
								<xsl:element name="{if ($iaWholeURI != $dcIdentifier and not(leg:IsIaPDFOnly(.))) then 'a' else 'span' }">
									<xsl:choose>
										<xsl:when test="leg:IsIaPDFOnly(.)">
											<xsl:attribute name="class" select="'userFunctionalElement disabled'"/>										
										</xsl:when>									
										<xsl:when test="$iaWholeURI != $dcIdentifier">
											<xsl:attribute name="href" select="leg:FormatENURL($iaWholeURI)"/>
											<xsl:attribute name="class" select="'userFunctionalElement'"/>
											<xsl:attribute name="title">Open <xsl:value-of select="$iaLabel"/></xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="class" select="'userFunctionalElement active'"/>
										</xsl:otherwise>
									</xsl:choose>
									<span class="btl"/>
									<span class="btr"/>
									<xsl:text>Open full IA</xsl:text>  
									<span class="bbl"/>
									<span class="bbr"/>
								</xsl:element>
							</li>		
						</ul>	-->	
					
						<!-- adding the previous/next toc links
						<xsl:call-template name="TSOOutputPreviousTOCNextLinks"/>-->

						<!-- adding the links for view print links
						<xsl:call-template name="TSOOutputViewPrintLinks"/>-->

					</div>
					<!-- /interface  -->					
					
					<div id="tools">
						<xsl:apply-templates select="/leg:ImpactAssessment" mode="TSOOutputWhatVersion"/>
						
						<!-- add in applicable legislation if it is viewed as an orphoned IA  -->
						<xsl:if test="not($IsLegislationView)">
							<xsl:call-template name="TSOOutputApplicableLegislation" />	
						</xsl:if>
						
					</div>
					
					<div id="content">
						<xsl:apply-templates select="/leg:ImpactAssessment" mode="TSOOutputLegislationContent"/>
					<div class="interface">
					
						<!-- adding the previous/next/toc links - currently not needed as we only deal with PDFs-->
						<!--<xsl:call-template name="TSOOutputPreviousTOCNextLinks"/>-->
						
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
				
				<!-- adding the view/print options - not needed as IAs are only PDF
				<xsl:call-template name="TSOOutputPrintOptions"	/>		-->		
				
				<!-- adding help tips-->
				<xsl:call-template name="TSOOutputHelpTips" />
			</body>
		</html>
	</xsl:template>
	
	
	<!-- ========== Standard code for outputing legislation content ========= -->
	
	<xsl:template match="leg:ImpactAssessment" mode="TSOOutputLegislationContent">
		
		
		<xsl:variable name="version" as="xs:string?">
			<xsl:value-of>
				<xsl:text>the </xsl:text>
				<xsl:value-of select="$iaStage" />
				<xsl:text> version of the </xsl:text>
			</xsl:value-of>
		</xsl:variable>
		<div id="infoSection">
			<h2>Status:</h2>
			<p class="intro">This is <xsl:value-of select="$version" />Impact Assessment.</p>
		</div>
		<div id="infoSection">
			<h2>Please note:</h2>
			<p class="intro">This impact assessment is only available to download and view as PDF.</p>
		</div>
		<!--<xsl:variable name="pdf" as="element()*" select="ukm:Metadata/ukm:Alternatives/ukm:Alternative[translate(substring-before(tokenize(@URI,'/')[last()],'.'),'_','') = $impactId]"/>-->
		<xsl:variable name="pdf" as="element()*">
			<xsl:choose>
				<xsl:when test="$impactId = 'impacts' ">
					<xsl:sequence select="ukm:Metadata/ukm:Alternatives/ukm:Alternative[not(exists(tokenize(@URI, '_')[4])) and not(contains(lower-case(@Title),'equality'))]"></xsl:sequence>
				</xsl:when>
				<xsl:when test="contains(//dc:identifier,'ukia') or not(contains($impactId,'ia'))">
					<xsl:sequence select="ukm:Metadata/ukm:Alternatives/ukm:Alternative[not(contains(lower-case(@Title),'equality'))]"></xsl:sequence>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="ukm:Metadata/ukm:Alternatives/ukm:Alternative[translate(substring-before(tokenize(@URI,'/')[last()],'.'),'_','') = $impactId and not(contains(lower-case(@Title),'equality'))]" ></xsl:sequence>
				</xsl:otherwise>
			</xsl:choose>
			</xsl:variable>
		
		<div id="viewLegContents">                            
			<div class="LegSnippet" id="viewLegSnippet">
				<p class="downloadPdfVersion">
	
				<xsl:for-each select="$pdf">
					<xsl:sort select="./@Title"/>
					<a class="pdfLink" href="{leg:FormatURL(./@URI)}">
						<img class="imgIcon" alt="" src="/images/chrome/pdfIconMed.gif" />
						<xsl:text>View PDF</xsl:text>
						<img class="pdfThumb" 
							src="{leg:FormatURL(replace(replace(./@URI, '/pdfs/', '/images/'), '.pdf', '.jpeg'))}"
							title="{$iaTitle}"
							alt="{$iaTitle}" />
					</a>
				</xsl:for-each>	
		</p>
				<span class="LegClearFix" />
			</div>
 		</div>
		<div class="contentFooter">
			<div class="interface"> </div>
		</div>
	</xsl:template>	
	
	<xsl:variable name="assessmentTypes" as="xs:string+" select="('Consultation',  'Enactment', 'Final','Post Implementation')" />
	
	<xsl:template match="leg:ImpactAssessment" mode="TSOOutputWhatVersion">
	<xsl:variable name="iaTitle">
		<xsl:value-of select="$part/*/@Title"/>
	</xsl:variable>
		<div class="section" id="whatVersion">
			<div class="title">
				<h2>What Stage</h2>
				<!-- we dont currently have a help tip for this-->
				<a href="#whatStageIaHelp" class="helpItem helpItemToMidRight">  
					<img src="/images/chrome/helpIcon.gif" alt=" Help about what version" />
				</a>
			</div>
			<div class="content">
				<ul class="toolList">
					<xsl:for-each select="$assessmentTypes">
						<xsl:variable name="assessmentType" as="xs:string" select="." />
						<xsl:variable name="button" as="element()?">
							<xsl:choose>
								<xsl:when test="count($part/*[contains(./@Title,$assessmentType)]) gt 1 and contains($iaTitle,$assessmentType) "></xsl:when>
								<xsl:otherwise>
									<span class="background">
									<span class="btl" /><span class="btr" /><xsl:value-of select="$assessmentType" /><span class="bbl" /><span class="bbr" />
								</span></xsl:otherwise>
							</xsl:choose>
							
							
						</xsl:variable>
						<li>
							<xsl:choose>
								
								<xsl:when test="starts-with($iaStage, $assessmentType) and not(contains(lower-case($iaTitle),lower-case($iaStage)))  and (count($part/*) le 2 ) ">
									<span class="userFunctionalElement active">
										<xsl:sequence select="$button" />
									</span>
								</xsl:when>
								
								<xsl:when test="contains($iaTitle,$assessmentType)   and (count($part/*[contains(@Title,$assessmentType)]) = 1 )">
									<span class="userFunctionalElement active">
										<xsl:sequence select="$button" />
									</span>
								</xsl:when>
								<xsl:when test="contains($iaTitle,$assessmentType) and count($part/*[contains(@Title,$assessmentType)]) gt 1"/>
									
									
								<xsl:when test="exists($iaStage[starts-with(., $assessmentType)])">
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
						<xsl:if test="count($part/*[contains(@Title,$assessmentType)]) gt 1 and contains($iaTitle,$assessmentType)  ">
							<xsl:choose>
								<xsl:when test="$impactId = 'impacts' ">
									<xsl:for-each select="$part/*[contains(@Title,$assessmentType)]">
										<xsl:sort select="@URI" order="ascending"></xsl:sort>
										<xsl:variable name="uri">
											<xsl:value-of select="translate(substring-before(tokenize(@URI,'/')[last()],'.'),'_','')"/>
										</xsl:variable>
										<xsl:variable name="iauri">
											<xsl:value-of select="/leg:ImpactAssessment/ukm:Metadata/atom:link[@title = 'Impact Assessment']/@href[tokenize(.,'/')[last()] = $impactId]"/>
										</xsl:variable>
										<xsl:variable name="ia" select="tokenize(@URI, '_')" />
										<xsl:variable name="iaNo">
											<xsl:choose>
												<xsl:when test="exists($ia[4])">
													<xsl:value-of select="number(substring($ia[4],3,1)) + 1 "/>
												</xsl:when>
												<xsl:otherwise>1</xsl:otherwise>
											</xsl:choose>
										
										</xsl:variable>
										<xsl:variable name="buttonPart" as="element()">
											<span class="background">
												<span class="btl" /><span class="btr" /><xsl:value-of select="concat($assessmentType,' part ',$iaNo)" /><span class="bbl" /><span class="bbr" />
											</span>
										</xsl:variable>
										<li>
										<xsl:choose>
											<xsl:when test="position() = 1">
												<span class="userFunctionalElement active">
													<xsl:sequence select="$buttonPart" />
												</span>
												<!--<a class="userFunctionalElement" href="{/leg:ImpactAssessment/ukm:Metadata/dc:identifier}">
													<xsl:sequence select="$buttonPart" />
												</a>-->
											</xsl:when>
											<xsl:otherwise>
												<a class="userFunctionalElement" href="{concat(/leg:ImpactAssessment/ukm:Metadata/dc:identifier,'/',$impactLegYear,'/',$uri)}">
													<xsl:sequence select="$buttonPart" />
												</a>
											</xsl:otherwise>
										</xsl:choose>
										
								
									</li>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="$part/*[contains(@Title,$assessmentType)]">
										<xsl:sort select="@URI" order="ascending"></xsl:sort>
										<xsl:variable name="uri">
											<xsl:value-of select="translate(substring-before(tokenize(@URI,'/')[last()],'.'),'_','')"/>
										</xsl:variable>
										<xsl:variable name="iauri">
											<xsl:value-of select="/leg:ImpactAssessment/ukm:Metadata/atom:link[@title = 'Impact Assessment']/@href[tokenize(.,'/')[last()] = $impactId]"/>
										</xsl:variable>
										
										<xsl:variable name="ia" select="tokenize(@URI, '_')" />
										<xsl:variable name="iaNo">
											<xsl:choose>
												<xsl:when test="exists($ia[4])">
													
													<xsl:value-of select="number(substring($ia[4],3,1)) + 1 "/>
													
												</xsl:when>
												<xsl:otherwise>1</xsl:otherwise>
											</xsl:choose>
											
										</xsl:variable>
										<xsl:variable name="buttonPart" as="element()">
											<span class="background">
												<span class="btl" /><span class="btr" /><xsl:value-of select="concat($assessmentType,' part ',$iaNo)" /><span class="bbl" /><span class="bbr" />
											</span>
										</xsl:variable>
										<li>
											
										<xsl:choose>
											<xsl:when test="$uri = $impactId">
												<span class="userFunctionalElement active">
													<xsl:sequence select="$buttonPart" />
												</span>
											
											</xsl:when>
											<xsl:otherwise>
												<a class="userFunctionalElement" href="{replace(/leg:ImpactAssessment/ukm:Metadata/dc:identifier,$impactId,$uri)}">
														<xsl:sequence select="$buttonPart" />
													</a>
												
											</xsl:otherwise>
										</xsl:choose>
				
										</li>
									</xsl:for-each>
									
								</xsl:otherwise>
							</xsl:choose>

						</xsl:if>
					</xsl:for-each>
				</ul>
			</div>
		</div>
	</xsl:template>
	
	


	<xsl:function name="leg:IsIaTOC" as="xs:boolean">
		 <xsl:sequence select="$paramsDoc/parameters/view ='contents' " />
	</xsl:function>	
	
	<!-- this will need verifying if and when we ever start to use IA XML -->
	<xsl:function name="leg:IsIaPDFOnly" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()" />
		 <xsl:sequence select="not(exists($legislation/leg:ImpactAssessment/leg:Contents) or exists($legislation/leg:ImpactAssessment/leg:IA))" />
	</xsl:function>		
	
	<!-- ========== Standard code for legislation title ========= -->	
	<xsl:template name="TSOOutputLegislationHeading">
		<h1 class="pageTitle{if (leg:IsDraft(.)) then ' draft' else ''}">
			<xsl:value-of select="$legislationTitle"/>
		</h1>	
	</xsl:template>
	
	<xsl:template name="TSOOutputLegislationTitle">
		<xsl:choose>
			<xsl:when test="starts-with(leg:ImpactAssessment/ukm:Metadata/dc:title[not(@xml:lang='cy')],'Impact Assessment to ')">
				<xsl:value-of select="substring-after(leg:ImpactAssessment/ukm:Metadata/dc:title[not(@xml:lang='cy')],'Impact Assessment to ')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="leg:ImpactAssessment/ukm:Metadata/dc:title[not(@xml:lang='cy')]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- ========== Breadcrumb ======================== -->
	<xsl:template name="TSOOutputBreadcrumbItems">
		  <!--/#breadcrumbControl --> 
			<div id="breadCrumb">
				<h3 class="accessibleText">You are here:</h3>		
				<ul>
					<xsl:apply-templates select="/leg:ImpactAssessment" mode="TSOBreadcrumbItem"/>
				</ul>
			</div>
	</xsl:template>	
	
	

	
	<!-- creating link for the whole act  -->
	<xsl:template match="leg:ImpactAssessment" mode="TSOBreadcrumbItem" priority="20">
		<xsl:variable name="isbn" as="xs:string?"
			select="/leg:ImpactAssessment/ukm:Metadata/ukm:Legislation/ukm:ISBN/@Value" />	
		<xsl:variable name="breadcrumb">
			<xsl:choose>
				<xsl:when test="$legislationNumber">
					<xsl:value-of select="$legislationYear"/>&#160;<xsl:value-of select="tso:GetNumberForLegislation($documentMainType, $legislationYear, $legislationNumber)" /><xsl:apply-templates select="$legislationAlternativeNumber" mode="series"/>
				</xsl:when>
				<xsl:when test="$isbn">
					<xsl:text>ISBN </xsl:text>
					<xsl:value-of select="tso:formatISBN($isbn)" />
				</xsl:when>
				<xsl:otherwise>
					<li class="activetext">Impact Assessment </li>
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
		<li class="activetext">
			<xsl:choose>
				<xsl:when test="$IsLegislationView">
					<xsl:text>Impact Assessment </xsl:text>
					 <xsl:value-of select="$impactYear"/> No.<xsl:value-of select="$impactNumber"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$impactYear"/> No.<xsl:value-of select="$impactNumber"/> 
				</xsl:otherwise>
			</xsl:choose>
		</li>
		<xsl:choose>
			<xsl:when test="leg:IsIaPDFOnly(/)"/>
			<xsl:when test="leg:IsTOC()">
				<li class="activetext">Table of contents</li>
			</xsl:when>
			<xsl:when test="$iaWholeURI = $strCurrentURIs">
				<li class="activetext">
					<xsl:text>Open full Impact Assessment</xsl:text>
				</li>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
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
	<!--<xsl:template name="TSOOutputViewPrintLinks">
		<ul id="viewPrintControl">
			<li class="view">		
				<xsl:element name="{if (leg:IsIaPDFOnly(.)) then 'span' else 'a'}">		
					<xsl:choose>
						<xsl:when test="leg:IsIaPDFOnly(.)">
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
				<xsl:element name="{if (leg:IsIaPDFOnly(.)) then 'span' else 'a'}">			
					<xsl:choose>
						<xsl:when test="leg:IsIaPDFOnly(.)">
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
	-->
	
	<!--<xsl:template name="TSOOutputPrintOptions">
		<div id="printOptions" class="interfaceOptions ">
			<h3 class="accessibleText">Print Options</h3>
			<ul class="optionList">
				<xsl:choose>
					<xsl:when test="leg:IsIaTOC()">
						<xsl:apply-templates select="leg:ImpactAssessment" mode="TSOPrintOptions"/>
					</xsl:when>				
					<xsl:otherwise>
						<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]" />
						<xsl:if test="exists($nstSection)">
							<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]" mode="TSOPrintOptions"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</ul>
		</div>	
		<xsl:choose>
			<xsl:when test="leg:IsIaTOC()">
					<xsl:apply-templates select="leg:ImpactAssessment" mode="TSOPrintOptionsWarnings"/>
			</xsl:when>				
			<xsl:otherwise>
				<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]" />
				<xsl:if test="exists($nstSection)">
					<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]" mode="TSOPrintOptionsWarnings"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->
		
	
	
	<!-- for print options -->
	<!--<xsl:template match="leg:ImpactAssessment" mode="TSOPrintOptions" priority="1000">
		<xsl:choose>
			<xsl:when test="leg:IsIaPDFOnly(/)">
				<xsl:for-each select="ukm:Metadata/ukm:Alternatives/ukm:Alternative">
					<li class="printToc">
						<xsl:variable name="title" select="concat($iaLabel, ' - ', if (@Date) then @Date else position() )"/>

						<h4><span class="accessibleText">Print </span> <xsl:value-of select="$title"/></h4>
						<ul>
							<li><a href="{@URI}" target="_blank" class="pdfLink">PDF<span class="accessibleText"> </span></a></li>
						</ul>
					</li>				
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="leg:IsIaTOC()">
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
	
	<xsl:template match="leg:ImpactAssessment | leg:Division | leg:SubDivision | leg:CommentaryPart | leg:CommentaryChapter | leg:CommentaryP1" mode="TSOPrintOptions" >
		<li class="printWhole">
			<xsl:variable name="displayText">
				 <xsl:choose>
					<xsl:when test="@DocumentURI = $dcIdentifier and not(self::leg:ImpactAssessment)">This <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/> only</xsl:when>
						<xsl:otherwise>The <xsl:if test="not(self::leg:ImpactAssessment)">Whole </xsl:if><xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/></xsl:otherwise>						
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
	
	<xsl:template match="leg:ImpactAssessment" mode="TSOPrintOptionsXXX">
		<xsl:variable name="category" select="if ($documentMainType) then tso:GetCategory($documentMainType) else ()"/>
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
	-->	
		
	<!--
	<xsl:template match="leg:ImpactAssessment | leg:Division | leg:SubDivision | leg:CommentaryPart | leg:CommentaryChapter | leg:CommentaryP1" mode="TSOPrintOptionsWarnings" >
		<xsl:if test="@NumberOfProvisions > $paragraphThreshold">
		
			<xsl:variable name="displayText">
				 <xsl:choose>
						<xsl:when test="@DocumentURI = $dcIdentifier and not(self::leg:ImpactAssessment)">This <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/> only</xsl:when>
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
	-->	

	<!-- ========== Standard code for previous and next ========= -->

	<!-- <xsl:template name="TSOOutputPreviousTOCNextLinks">
		adding the previous next section 
		<xsl:variable name="prev" as="element(atom:link)?" select="leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='prev']" />
		<xsl:variable name="next" as="element(atom:link)?" select="leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='next']" />
		

		
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
					<xsl:element name="{if (leg:IsIaTOC() or leg:IsIaPDFOnly(.)) then 'span' else 'a' }">
						<xsl:choose>
							<xsl:when test="leg:IsIaPDFOnly(.)">
								<xsl:attribute name="class" select="'userFunctionalElement disabled'" />
							</xsl:when>						
							<xsl:when test="leg:IsIaTOC()">
								<xsl:attribute name="class" select="'userFunctionalElement active nav'" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="iaTOCURI" as="xs:string" select="leg:ImpactAssessment/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents']/@href" />			
								<xsl:attribute name="href" select="leg:FormatENURL($iaTOCURI)"/>
								<xsl:attribute name="class" select="'userFunctionalElement nav'" />
								<xsl:attribute name="title"><xsl:value-of select="$iaLabel"/> Table of contents</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<span class="btl"/>
						<span class="btr"/>
						<xsl:value-of select="$iaLabel"/><xsl:if test="not(leg:IsIaPDFOnly(.))"> Table of contents</xsl:if>
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
	</xsl:template> -->
	
	<xsl:template name="TSOOutputApplicableLegislation">
		<xsl:if test="exists(/leg:ImpactAssessment/ukm:Metadata/ukm:Legislation)">
			<div class="section" id="moreResources">
				<div class="title">
				  <h2>Applicable Legislation</h2>
						<!--<a href="#moreResourcesHelp" class="helpItem helpItemToMidRight">
							<img src="/images/chrome/helpIcon.gif" alt=" Help about more resources"/>
					</a>-->
				</div>
				<div class="content">
					<ul class="toolList">
						
					
						<xsl:for-each select="/leg:ImpactAssessment/ukm:Metadata/ukm:Legislation">
							
							
							<li>
								<xsl:variable name="tokens" select="tokenize(substring-after(@URI,'http://www.legislation.gov.uk/id/'),'/')"/>
								
								<xsl:variable name="year" select="$tokens[2]" as="xs:string?"/>
								<xsl:variable name="number" select="$tokens[3]" as="xs:string?"/>
								<xsl:variable name="type" select="$tso:legTypeMap[@abbrev = $tokens[1]]" as="element(tso:legType)?"/>
								
								
								<a href="{@URI}">
									<xsl:choose>
										<!--added revised version-->
										<xsl:when test="exists(@Title)">
											<xsl:value-of select="@Title"/>
										</xsl:when>
										<xsl:when test="exists($year) and exists($number) and exists($type)">
											<xsl:value-of select="concat($tokens[2],' ',tso:GetNumberForLegislation($type/@schemaType,$year,$number))"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Applicable Legislation</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</a>	
							</li>
						</xsl:for-each>
						
						
	
						
					</ul>
				</div>
								
			</div> 



		</xsl:if>
	</xsl:template>	
	
	<!-- ========== CSS Styles for Legislation =============-->
	<xsl:template name="TSOOutputAddLegislationStyles">
		<style type="text/css">
			/* Legislation stylesheets - load depending on content type */
			@import "/styles/explanatoryNotes.css";						
			
			<xsl:choose>
				<xsl:when test="$uriPrefix ='ukpga' or  $uriPrefix ='ukla'  or  $uriPrefix ='cukla'  or  $uriPrefix ='ukcm'  ">
					<xsl:text>
						@import "/styles/legislation.css";
						@import "/styles/primarylegislation.css";
					</xsl:text>
				</xsl:when>				
				<xsl:when test="$uriPrefix ='apgb' or  $uriPrefix ='aosp'  or  $uriPrefix ='aip'  or  $uriPrefix ='mnia'  or  $uriPrefix ='apni'  or  $uriPrefix ='mwa'">
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
				<xsl:otherwise>
					<xsl:text>
						@import "/styles/explanatoryNotes.css";						
						@import "/styles/legislation.css";
						@import "/styles/primarylegislation.css";
					</xsl:text>	
				</xsl:otherwise>
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
		<xsl:call-template name="TSOOutputIAsHelpTips"/>
		<div class="help" id="whatStageIaHelp">
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
	
	
	


	<xsl:function name="leg:IsDraft" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="contains($documentMainType, 'Draft')" />
	</xsl:function>
	

</xsl:stylesheet>
