<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

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
	<xsl:import href="legislation_xhtml_consolidation.xslt"/>

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

	<xsl:variable 	name="g_strIntroductionUri"  as="xs:string?"
		select="(/(leg:ImpactAssessment)/ukm:Metadata/atom:link[@rel = ('http://www.legislation.gov.uk/def/navigation/introduction', 'http://www.legislation.gov.uk/def/navigation/act/introduction')]/@href)[1]"/>

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

	<xsl:variable name="associatedIAs" as="element(atom:link)*"
		select="/leg:ImpactAssessment/ukm:Metadata/atom:link[starts-with(@rel, 'http://www.legislation.gov.uk/def/navigation/impacts')]" />


	<!-- used by uicommon.xsl - this is the legislation main type -->
	<xsl:variable name="documentMainType" as="xs:string?" select="/leg:ImpactAssessment/ukm:Metadata/ukm:Legislation/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>

	<xsl:variable name="iaDocumentMainType" as="xs:string?" select="/leg:ImpactAssessment/ukm:Metadata/ukm:ImpactAssessmentMetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>

	<xsl:variable 	name="strSchemaDefinitions" select="$tso:legTypeMap[@schemaType = ($documentMainType, $iaDocumentMainType)[1]]"/>
	<xsl:variable 	name="strShortType" select="$strSchemaDefinitions/@abbrev"/>

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
		select="exists($impactURI) or /leg:ImpactAssessment"/>


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
			<body xml:lang="{$TranslateLang}" dir="ltr" id="leg" about="{$dcIdentifier}"  class="toc">
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
									<a href="{leg:FormatURL($impactURI)}"><xsl:value-of select="leg:TranslateText('Impact Assessments')"/></a>
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
						<a href="#top"><xsl:value-of select="leg:TranslateText('Back to top')"/></a>
					</p>

					</div>
					<!--/content-->



				</div>
				<!--#layout2-->

				<!-- Where all of the Help divs and modal windows are loaded -->
				<h2 class="interfaceOptionsHeader"><xsl:value-of select="leg:TranslateText('Options')"/>/<xsl:value-of select="leg:TranslateText('Help')"/></h2>

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
				<xsl:value-of select="leg:TranslateText('the')"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="leg:TranslateText(if ($iaStage != '') then translate($iaStage,'-',' ') else 'Final')" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="leg:TranslateText('version of the')"/>
				<xsl:text> </xsl:text>
			</xsl:value-of>
		</xsl:variable>
		<div id="infoSection-status">
			<h2><xsl:value-of select="leg:TranslateText('Status')"/>:</h2>
			<p class="intro"><xsl:value-of select="leg:TranslateText('Ia_status_message',concat('version=',$version))"/></p>
		</div>
		<div id="infoSection-note">
			<h2><xsl:value-of select="leg:TranslateText('Please note')"/>:</h2>
			<p class="intro"><xsl:value-of select="leg:TranslateText('Please_note_message')"/></p>
		</div>
		<!-- there should only really be one alternative pdf so we will use that  -->
		<xsl:variable name="pdf" as="element()*" select="if (count(ukm:Metadata/ukm:Alternatives/ukm:Alternative) = 1 and (ends-with(ukm:Metadata/ukm:Alternatives/ukm:Alternative/@URI,'.pdf'))) then ukm:Metadata/ukm:Alternatives/ukm:Alternative else ukm:Metadata/ukm:Alternatives/ukm:Alternative[translate(substring-before(tokenize(@URI,'/')[last()],'.'),'_','') = $impactId]"/>
		<!--<xsl:variable name="pdf" as="element()*">
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
			</xsl:variable>-->

		<div id="viewLegContents">
			<div class="LegSnippet" id="viewLegSnippet">
				<p class="downloadPdfVersion">

				<xsl:for-each select="$pdf">
					<xsl:sort select="./@Title"/>
					<a class="pdfLink" href="{leg:FormatURL(./@URI)}">
						<img class="imgIcon" alt="PDF Icon" src="/images/chrome/pdfIconMed.gif" />
						<xsl:value-of select="leg:TranslateText('View PDF')"/>
						<img class="pdfThumb"
							src="{leg:FormatURL(replace(replace(./@URI, '/pdfs/', '/images/'), '.pdf', '.jpg'))}"
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

	<xsl:variable name="assessmentTypes" as="xs:string+" select="('Consultation', 'Final', 'Enactment', 'Post Implementation')" />

	<xsl:template match="leg:ImpactAssessment" mode="TSOOutputWhatVersion">
	<xsl:variable name="iaTitle">
		<xsl:value-of select="$part/*/@Title"/>
	</xsl:variable>

	<xsl:variable name="orderedAssociatedIAs" as="element()*">
		<xsl:for-each select="$associatedIAs">
			<xsl:variable name="uriTokens" select="tokenize(substring-after(@href,'impacts/'),'/')"/>
			<associatedIA stage="{translate(lower-case(substring-after(@rel,'http://www.legislation.gov.uk/def/navigation/impacts/')),'_',' ')}"
							uri="{@href}"
							title="{@title}"
							year="{$uriTokens[1]}"
							number="{$uriTokens[2]}"/>
		</xsl:for-each>
		<!--  TNA request - treat as a final stage if there is no stage declared  -->
		<!--  The hyphen removal is to align the post-implementation stage with the string sequence  -->
		<associatedIA stage="{if ($iaStage != '') then lower-case(translate($iaStage,'-',' ')) else 'final'}"
							uri=""
							title=""
							year="{$impactYear}"
							number="{$impactNumber}"
							self="true"/>
	</xsl:variable>
	<xsl:variable name="orderedAssociatedIAs" as="element()*">
		<xsl:for-each select="$orderedAssociatedIAs">
			<xsl:sort select="@stage"/>
			<xsl:sort select="@year"/>
			<xsl:sort select="@number"/>
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:variable>


		<div class="section" id="whatVersion">
			<div class="title">
				<h2><xsl:value-of select="leg:TranslateText('What Stage')"/></h2>
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
							<span class="background">
								<span class="btl" /><span class="btr" /><xsl:value-of select="leg:TranslateText($assessmentType)" /><span class="bbl" /><span class="bbr" />
							</span>
						</xsl:variable>


						<xsl:variable name="intTotalStage" select="count($orderedAssociatedIAs[lower-case(@stage) = lower-case($assessmentType)])"/>
						<xsl:for-each select="$orderedAssociatedIAs[lower-case(@stage) = lower-case($assessmentType)]">
							<xsl:variable name="intIaNo" select="position()"/>
							<xsl:variable name="buttonPart" as="element()">
								<span class="background">
									<span class="btl" /><span class="btr" /><xsl:value-of select="concat($assessmentType,' ',leg:TranslateText('part'),' ',$intIaNo)" /><span class="bbl" /><span class="bbr" />
								</span>
							</xsl:variable>
							<li>
							<xsl:choose>
								<xsl:when test="$intTotalStage &gt; 1 and @self = 'true'">
									<span class="userFunctionalElement active">
										<xsl:sequence select="$buttonPart" />
									</span>
								</xsl:when>
								<xsl:when test="$intTotalStage &gt; 1">
									<a class="userFunctionalElement" href="{@uri}">
										<xsl:sequence select="$buttonPart" />
									</a>
								</xsl:when>
								<xsl:when test="@self = 'true'">
									<span class="userFunctionalElement active">
										<xsl:sequence select="$button" />
									</span>
								</xsl:when>
								<xsl:otherwise>
									<a class="userFunctionalElement" href="{@uri}">
										<xsl:sequence select="$button" />
									</a>
								</xsl:otherwise>
							</xsl:choose>
							</li>
						</xsl:for-each>
						<!-- this will add in a blank button for the stage if no IAs are available  -->
						<xsl:if test="not($orderedAssociatedIAs[lower-case(@stage) = lower-case($assessmentType)])">
							<li>
								<span class="userFunctionalElement disabled">
									<xsl:sequence select="$button" />
								</span>
							</li>
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
		<h1 id="pageTitle" class="pageTitle{if (leg:IsDraft(.)) then ' draft' else ''}">
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
				<h2 class="accessibleText">You are here:</h2>
				<ul>
					<li class="first">
						<a href="{concat('/', $strShortType)}">
							<xsl:value-of select="$strSchemaDefinitions/@plural"/>
						</a>
					</li>
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
					<xsl:value-of select="leg:TranslateText('ISBN')"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="tso:formatISBN($isbn)" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$breadcrumb and $breadcrumb != ''">
			<li>
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
		</xsl:if>
		<li class="activetext">
			<xsl:choose>
				<xsl:when test="$IsLegislationView">
					<xsl:value-of select="leg:TranslateText('Impact Assessment')"/>
					 <xsl:text> </xsl:text>
					<xsl:value-of select="$impactYear"/><xsl:text> </xsl:text> <xsl:value-of select="leg:TranslateText('No.')"/><xsl:value-of select="$impactNumber"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$impactYear"/><xsl:text> </xsl:text><xsl:value-of select="leg:TranslateText('No.')"/><xsl:value-of select="$impactNumber"/>
				</xsl:otherwise>
			</xsl:choose>
		</li>
		<xsl:choose>
			<xsl:when test="leg:IsIaPDFOnly(/)"/>
			<xsl:when test="leg:IsTOC()">
				<li class="activetext"><xsl:value-of select="leg:TranslateText('Table of contents')"/></li>
			</xsl:when>
			<xsl:when test="$iaWholeURI = $strCurrentURIs">
				<li class="activetext">
					<xsl:value-of select="leg:TranslateText('Open_full_Impact_Assessment')"/>
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
											<xsl:value-of select="leg:TranslateText('Applicable Legislation')"/>
										</xsl:otherwise>
									</xsl:choose>
								</a>
							</li>
						</xsl:for-each>
					</ul>
				</div>

			</div>



		</xsl:if>

		<xsl:if test="exists(/leg:ImpactAssessment/ukm:Metadata/ukm:AssociatedIAs/ukm:AssociatedIA)">
			<div class="section" id="moreResources">
				<div class="title">
				  <h2>Associated IAs</h2>
						<!--<a href="#moreResourcesHelp" class="helpItem helpItemToMidRight">
							<img src="/images/chrome/helpIcon.gif" alt=" Help about more resources"/>
					</a>-->
				</div>
				<div class="content">
					<ul class="toolList">


						<xsl:for-each select="/leg:ImpactAssessment/ukm:Metadata/ukm:AssociatedIAs/ukm:AssociatedIA">


							<li>
								<xsl:variable name="tokens" select="tokenize(substring-after(@URI,'http://www.legislation.gov.uk/id/'),'/')"/>

								<xsl:variable name="year" select="@Year" as="xs:string?"/>
								<xsl:variable name="number" select="@Number" as="xs:string?"/>
								<xsl:variable name="type" select="$tso:legTypeMap[@abbrev = $tokens[1]]" as="element(tso:legType)?"/>


								<a href="{@URI}">
									<xsl:choose>
										<!--added revised version-->
										<xsl:when test="exists(@Title)">
											<xsl:value-of select="@Title"/>
										</xsl:when>
										<xsl:when test="exists($year) and exists($number)">
											<xsl:value-of select="concat('IA ',$year, ' No.',$number)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="leg:TranslateText('Impact Assessment')"/>
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
				<xsl:when test="$uriPrefix = ('eut', 'eur', 'eudr', 'eudn') ">
					<xsl:text>@import "/styles/legislation.css";</xsl:text>
					<xsl:text>@import "/styles/eulegislation.css";</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix ='ukpga' or  $uriPrefix ='ukla'  or  $uriPrefix ='cukla' ">
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
				<xsl:when test="$uriPrefix = ('aep', 'asp', 'ukcm')">
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
				<xsl:when test="$uriPrefix = ('uksi', 'ukmd', 'ssi', 'wsi', 'nisr', 'ukci', 'nisi', 'ukmo', 'uksro', 'nisro')">
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
					@import "/styles/IE/ie7LegAdditions.css";
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
				<h3><xsl:value-of select="leg:TranslateText('whatStageIaHelp_para1')"/>:</h3>
				<dl>
					<dt><xsl:value-of select="leg:TranslateText('Consultation')"/>:</dt>
					<dd><xsl:value-of select="leg:TranslateText('whatStageIaHelp_para2')"/></dd>
					<dt><xsl:value-of select="leg:TranslateText('Final')"/>:</dt>
					<dd><xsl:value-of select="leg:TranslateText('whatStageIaHelp_para3')"/></dd>
					<dt><xsl:value-of select="leg:TranslateText('Enactment')"/>:</dt>
					<dd><xsl:value-of select="leg:TranslateText('whatStageIaHelp_para4')"/></dd>
					<dt><xsl:value-of select="leg:TranslateText('Post Implementaion Review')"/>:</dt>
					<dd><xsl:value-of select="leg:TranslateText('whatStageIaHelp_para5')"/></dd>
				</dl>
			</div>
		</div>
	</xsl:template>





	<xsl:function name="leg:IsDraft" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="contains($documentMainType, 'Draft')" />
	</xsl:function>


</xsl:stylesheet>
