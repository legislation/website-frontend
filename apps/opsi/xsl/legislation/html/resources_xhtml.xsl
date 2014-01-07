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
Chunyu 23/11/2012 Changed the display for accociated documents according to the requirement of VSRS. Two major changes. One is to display all docs in one column. The other is to seperate IAs to a invidual list
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
	
	<!-- TNA confirmed that they do not revised the Local Acts however they would like to leave the codelists.xml with revised configurations for local acts-->
	<xsl:variable name="isRevised"  as="xs:boolean" 
		select="exists($g_nstCodeLists[@name = 'DocumentMainType' ]/Code[@status='revised' and @schema = $documentMainType]) and $documentMainType != 'UnitedKingdomLocalAct' "/>
		
	<xsl:variable name="isEffectingTypeValid" as="xs:boolean"
		select="exists(tso:GetEffectingTypes()[@schemaType = $documentMainType]) and /leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value >=2002"/>
	
	<xsl:variable name="hasXML" as="xs:boolean"
		select="exists(/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents'])" />
	
	<xsl:output indent="yes" method="xhtml" />

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title" />
				</title>
				<xsl:apply-templates select="/leg:Legislation/ukm:Metadata" mode="HTMLmetadata" />
				
				<script type="text/javascript" src="/scripts/view/tabs.js"></script>				
				<xsl:call-template name="TSOOutputAddLegislationStyles" />
				
			</head>
			<body xml:lang="en" lang="en" dir="ltr" id="leg" about="{$dcIdentifier}" class="resources">
			
				<div id="layout2" class="legResources">
				
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
					
					<div id="content">
					
						<!-- outputing the legislation content-->
						<xsl:apply-templates select="/leg:Legislation" mode="TSOOutputLegislationContent"/>

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
		<div class="innerContent">
			<h2 class="accessibleText">
				<xsl:text>More resources for </xsl:text>
				<xsl:value-of select="$theTitle"/>
			</h2>
			
			<!--
			<div class="intro colSection s_7 p_one">
				<p>
					<xsl:text>This page provides further information about </xsl:text>
					<xsl:value-of select="$theTitle"/>
					<xsl:text>. You can access the original print PDFs where we have them and any associated documents.  Further information will be added to this page in future releases.</xsl:text>
				</p>
			</div>
			-->
		
			<xsl:if test="ukm:Metadata/ukm:Alternatives/ukm:Alternative[not(@Revised)]">
				<xsl:variable name="status" select="leg:GetCodeSchemaStatus(/)" />
				<div class="printPdf colSection s_4">
					<h3>
						<xsl:text>Original Print PDF</xsl:text>
						
							<!--<xsl:when test="$status = 'draft'">draft</xsl:when>-->
						<xsl:if test="not($isDraft)"> of as <xsl:value-of select="$status"/> version</xsl:if>
						
					</h3>
					<img id="printPDFIcon" src="/images/chrome/largePdfIcon.gif"/>
					<p>
						<xsl:choose>
							<xsl:when test="$isDraft">
								<xsl:text>This is the print PDF version of this draft legislation item.</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>This PDF does not include any changes made by correction slips.</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<a class="helpItem helpItemToTop" href="#printHelp">
							<img alt=" Help about Print PDF" src="/images/chrome/helpIcon.gif"/>
						</a>
					</p>
					<div class="help" id="printHelp">
						<span class="icon"/>
						<div class="content">
							<a href="#" class="close">
								<img alt="Close" src="/images/chrome/closeIcon.gif"/>
							</a>
							<h3>Original Print PDF</h3>
							<xsl:choose>
								<xsl:when test="$isDraft">
									<p>This is the original PDF that was used to publish the printed copy. The printed copy of this draft would have been laid before parliament. Please note, that draft legislation items may be replaced with another draft version and/or be superseded by a numbered SI if it has been subsequently made by the Government department. You can find out if this has happened by entering the title of the instrument using the search bar at the top of this page. In the search results, any relevant replacement/superseding information will be displayed underneath the title.</p>
								</xsl:when>
								<xsl:otherwise>
									<p>This is the original PDF of the as <xsl:value-of select="leg:GetCodeSchemaStatus(/)"/> version that was used to publish the official printed copy. It therefore does not include any changes made by correction slips issued after it was published. Correction slips if issued will be listed separately under 'Associated Documents' and will have been applied to the HTML version viewable via the content tab.</p>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
					<ul class="plainList">
						<xsl:for-each select="ukm:Metadata/ukm:Alternatives/ukm:Alternative[not(@Revised)]">
							<xsl:sort select="@Title = 'Print Version'" order="descending" />
							<xsl:sort select="@Title"/>
							<!-- put English first -->
							<xsl:sort select="exists(@Language)" />
							<xsl:sort select="@Language = 'English'" order="descending" />
							<!-- put Mixed language last -->
							<xsl:sort select="@Language = 'Mixed'" />
							<xsl:variable name="strLanguageSuffix">
								<xsl:if test="(not(@Title) and count(../ukm:Alternative[not(@Title)]) > 1) or
									(if (@Title = ('', 'Print Version', 'Mixed Language Measure')) then
										count(../ukm:Alternative[@Title = ('', 'Print Version', 'Mixed Language Measure')]) > 1
									else
										count(../ukm:Alternative[@Title = current()/@Title]) > 1)">
									<xsl:choose>
										<xsl:when test="@Language = 'Mixed'"> - Mixed Language</xsl:when>
										<xsl:when test="exists(@Language)">
											<xsl:text> - </xsl:text>
											<xsl:value-of select="@Language" />
										</xsl:when>
										<xsl:when test="matches(@URI, '_en(_[0-9]{3})?.pdf$')"> - English</xsl:when>
										<xsl:when test="matches(@URI, '_we(_[0-9]{3})?.pdf$')"> - Welsh</xsl:when>
										<xsl:when test="matches(@URI, '_mi(_[0-9]{3})?.pdf$')"> - Mixed Language</xsl:when>
									</xsl:choose>
								</xsl:if>
							</xsl:variable>
							<li>
								<a href="{@URI}">
									<xsl:choose>
										<!-- if there is no title then display the download label-->
										<xsl:when test="@Title = '' or not(@Title)">Download<xsl:value-of select="$strLanguageSuffix" /></xsl:when>
										<!-- if the title is print then display the Download label-->
										<xsl:when test="@Title = 'Print Version' or @Title = 'Mixed Language Measure'">Download<xsl:value-of select="$strLanguageSuffix" /></xsl:when>
										<!-- for anything else display the title -->
										<xsl:otherwise>Download <xsl:value-of select="@Title"/><xsl:value-of select="$strLanguageSuffix" /></xsl:otherwise>
									</xsl:choose>
								</a>
								<span class="filesize"><xsl:sequence select="tso:GetFileSize(@Size)"/></span>
							</li>
						</xsl:for-each>
					</ul>
					<p class="helpAside"><a href="http://get.adobe.com/reader/" target="_blank">Requires Adobe Acrobat Reader <img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" /></a></p>
				</div>
			</xsl:if>
			<!-- displaying the associated documents -->
			<xsl:call-template name="AssociatedDocuments">
				<xsl:with-param name="associatedDocuments">
					<xsl:apply-templates select="ukm:Metadata//*[not(name() = 'ukm:ImpactAssessment' or name() = 'ukm:Supersedes')][@URI]" mode="AssociatedDocuments">
						<!-- alternative versions first -->
						<xsl:sort select="@Title = 'Print Version'" order="descending" />
						<xsl:sort select=". instance of element(ukm:Alternative)" order="descending" />
						<!-- ENs & EMs after print PDFs -->
						<xsl:sort select="exists(ancestor::ukm:Notes)" order="descending" />
						<!-- group by type - this comes first as we cannot trust the title -->
						<xsl:sort select="local-name(.)" />
						<!-- ENs & EMs after print PDFs -->
						<xsl:sort select="@Title = 'Explanatory Note' " order="descending" />
						<xsl:sort select="@Title = 'Executive Note' " order="descending" />
						<xsl:sort select="@Title = 'Policy Note' " order="descending" />
						<xsl:sort select="@Title = 'Explanatory Memorandum' " order="descending" />
						
						<!-- sort by title -->
						<xsl:sort select="@Title"/>
						<!-- English first -->
						<xsl:sort select="exists(@Language)" />
						<!-- Mixed language last -->
						<xsl:sort select="@Language = 'Mixed'" />
						<!-- Most recent first -->
						<xsl:sort select="@URI" order="ascending"/>
						<!--<xsl:sort select="xs:date(@Date)" order="descending" />-->
					</xsl:apply-templates>
					<xsl:apply-templates select="ukm:Supersedes" mode="AssociatedDocuments"/>
				</xsl:with-param>
			</xsl:call-template>
			
			<!-- perform the sort first so that we can determine the part number correctly  -->
			<xsl:variable name="sortedIAs">
				<xsl:perform-sort select="ukm:Metadata//ukm:ImpactAssessments/ukm:ImpactAssessment[@URI]">
					<xsl:sort select="@Stage" order="ascending"/>
					<xsl:sort select="@Year" order="ascending"/>
					<xsl:sort select="@Number" order="ascending"/>
					<!-- English first -->
					<xsl:sort select="exists(@Language)" />
					<!-- Mixed language last -->
					<xsl:sort select="@Language = 'Mixed'" />
					<!-- Most recent first -->
					<!-- <xsl:sort select="xs:date(@Date)" order="descending" /> -->
				</xsl:perform-sort>
			</xsl:variable>
			
			<xsl:call-template name="AssociatedImpact">
				<xsl:with-param name="associatedDocuments">
					<!-- determine the display order of the IA stages -->
					<!-- first will be all non-IA IA's -->
					<xsl:apply-templates select="$sortedIAs/ukm:ImpactAssessment[not(@Stage = ('Post-Implementation','Enactment','Final','Consultation'))]" mode="AssociatedDocuments"/>
					<!-- then follow the order used in the IA tab -->
					<xsl:apply-templates select="$sortedIAs/ukm:ImpactAssessment[@Stage = 'Consultation']" mode="AssociatedDocuments"/>
					<xsl:apply-templates select="$sortedIAs/ukm:ImpactAssessment[@Stage = 'Final']" mode="AssociatedDocuments"/>
					<xsl:apply-templates select="$sortedIAs/ukm:ImpactAssessment[@Stage = 'Enactment']" mode="AssociatedDocuments"/>
					<xsl:apply-templates select="$sortedIAs/ukm:ImpactAssessment[@Stage = 'Post-Implementation']" mode="AssociatedDocuments"/>
				</xsl:with-param>
			</xsl:call-template>
			

	
	
	
			
			
			<xsl:call-template name="ListAllChanges">
				<xsl:with-param name="theTitle" select="$theTitle"/>
			</xsl:call-template>

			<xsl:call-template name="SectionsThat"/>

			<!-- displaying related legislation --> 							
			<!--<xsl:call-template name="RelatedLegislation"/>-->

			<!-- displaying further information --> 
			<xsl:call-template name="FurtherInformation"/>
		</div>
	 </xsl:template>
	 
	 

	<xsl:template name="AssociatedDocuments">
		<xsl:param name="associatedDocuments" />

		<div class="assocDocs filesizeShow colSection p_one s_7">
			<h3>Associated Documents</h3>
			<xsl:choose>
				<xsl:when test="count($associatedDocuments/*) &gt; 0">
					<xsl:variable name="columns" as="xs:integer" select="1" />
					<xsl:variable name="groups" as="xs:integer"
						select="xs:integer(ceiling(count($associatedDocuments/*) div $columns))" />
					<!-- adjust the groups size to make sure there are at lease 3 three items in the list -->
					<xsl:variable name="groups" as="xs:integer"
						select="if ($groups &lt; $columns) then $columns else $groups" />

					<xsl:variable name="minColumn" as="xs:integer" select="1" />
					<!-- adjust the maxColumn to make sure there are at most three groups -->
					<xsl:variable name="maxColumn" as="xs:integer"
						select="if ($groups &gt; $columns) then $columns else $groups" />


					<xsl:for-each select="$minColumn to $maxColumn">
						<xsl:variable name="startGroup" as="xs:integer" select="((.-1) * $groups) + 1" />
						<xsl:variable name="endGroup" as="xs:integer" select=". * $groups" />
						<!--<div class="column1 s_3_5 p_{if (. = 1) then 'one' else 'two'}">-->
							<div>
							<ul class="plainList">
								<xsl:copy-of
									select="$associatedDocuments/*[position() &gt;= $startGroup and position() &lt;= $endGroup]"
								 />
							</ul>
						</div>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<!-- default message -->
					<p>There are no associated documents for this legislation.</p>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="AssociatedImpact">
		<xsl:param name="associatedDocuments" />

		<div class="assocDocs filesizeShow colSection p_one s_7">
			<h4>Impact Assessments</h4>
			<xsl:choose>
				<xsl:when test="count($associatedDocuments/*) &gt; 0">
					<xsl:variable name="columns" as="xs:integer" select="1" />
					<xsl:variable name="groups" as="xs:integer"
						select="xs:integer(ceiling(count($associatedDocuments/*) div $columns))" />
					<!-- adjust the groups size to make sure there are at lease 3 three items in the list -->
					<xsl:variable name="groups" as="xs:integer"
						select="if ($groups &lt; $columns) then $columns else $groups" />

					<xsl:variable name="minColumn" as="xs:integer" select="1" />
					<!-- adjust the maxColumn to make sure there are at most three groups -->
					<xsl:variable name="maxColumn" as="xs:integer"
						select="if ($groups &gt; $columns) then $columns else $groups" />


					<xsl:for-each select="$minColumn to $maxColumn">
						<xsl:variable name="startGroup" as="xs:integer" select="((.-1) * $groups) + 1" />
						<xsl:variable name="endGroup" as="xs:integer" select=". * $groups" />
						<!--<div class="column1 s_3_5 p_{if (. = 1) then 'one' else 'two'}">-->
						<div>
							<ul class="plainList">
								<xsl:copy-of
									select="$associatedDocuments/*[position() &gt;= $startGroup and position() &lt;= $endGroup]"
								 />
							</ul>
						</div>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<!-- default message -->
					<p>There are no associated impact assessments for this legislation.</p>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	
	<!-- ia generation of an associated document list item -->
	<xsl:template match="ukm:ImpactAssessment" mode="AssociatedDocuments">
		<xsl:variable name="stage" select="@Stage"/>
		<xsl:variable name="totalStage" as="xs:integer" select="count(../ukm:ImpactAssessment[@Stage = $stage])"/>
		<xsl:variable name="iaTitle"  as="xs:string?" select="if (@Stage = 'Impact Assessment') then () else 'Impact Assessment '"/>
		<xsl:variable name="draftText" as="xs:string?" select="if ($isDraft) then 'Draft ' else ()"/>
		<xsl:variable name="title" select="if ($totalStage &gt; 1) then 
					concat($draftText, $stage, ' ', $iaTitle, 'part ', count(preceding-sibling::ukm:ImpactAssessment[@Stage = $stage]) + 1) 
					else 
					concat($draftText, $stage, ' ', $iaTitle)"/>
		<xsl:sequence select="tso:makeAssociatedDocListItem(@URI,$title,@Size)"/>
	</xsl:template>

	<!-- tod generation of an associated document list item -->
	<xsl:template match="ukm:TableOfDestinations" mode="AssociatedDocuments">
		<xsl:variable name="draftText" as="xs:string?" select="if ($isDraft) then 'Draft ' else ()"/>
		<xsl:sequence select="tso:makeAssociatedDocListItem(@URI,concat($draftText, 'Table of Destinations'),@Size)"/>
	</xsl:template>

	<!-- too generation of an associated document list item -->
	<xsl:template match="ukm:TableOfOrigins" mode="AssociatedDocuments">
		<xsl:variable name="draftText" as="xs:string?" select="if ($isDraft) then 'Draft ' else ()"/>
		<xsl:sequence select="tso:makeAssociatedDocListItem(@URI,concat($draftText, 'Table of Origins'),@Size)"/>
	</xsl:template>
	
	<!-- cop generation of an associated document list item -->
	<xsl:template match="ukm:CodeOfPractice" mode="AssociatedDocuments">
		<xsl:variable name="draftText" as="xs:string?" select="if ($isDraft) then 'Draft ' else ()"/>
		<xsl:sequence select="tso:makeAssociatedDocListItem(@URI,concat($draftText, 'Code of Practice'),@Size)"/>
	</xsl:template>	

	
	<!-- this will generate the list item for associated documents from the supplied parameters -->
	<xsl:function name="tso:makeAssociatedDocListItem" as="element(xhtml:li)">
		<xsl:param name="uri" as="xs:string?"/>
		<xsl:param name="title" as="xs:string?"/>
		<xsl:param name="size" as="xs:integer?"/>
		<li>
			<a href="{$uri}" class="pdfLink">
				<xsl:value-of select="$title"/>
			</a>
			<xsl:text>   </xsl:text>
			<span class="filesize"><xsl:sequence select="tso:GetFileSize($size)"/></span>
		</li>
	</xsl:function>



	<!-- generation of an associated document list item - this really needs separating out as above -->
	<xsl:template match="ukm:Metadata/ukm:Alternatives/ukm:Alternative 
	 	| ukm:Metadata/ukm:Notes/ukm:Alternatives/ukm:Alternative 
	 	|ukm:CorrectionSlip
	 	|ukm:TableOfEffects
	 	|ukm:OrderInCouncil
	 	|ukm:OrdersInCouncil
	 	|ukm:UKRPCOpinion
	 	|ukm:TranspositionNote
	 	|ukm:CodeofConduct
	 	|ukm:UKExplanatoryMemorandum
	 	|ukm:NIExplanatoryMemorandum
	 	|ukm:OtherDocument" mode="AssociatedDocuments">
		 <xsl:if test="not(self::ukm:Alternative) or (self::ukm:Alternative and ancestor::ukm:Notes) or @Revised">
			 <!-- if draft legislation then all alternative versions(print) will also be included -->
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
		 			<xsl:when test="exists(@Revised)">Revised Version</xsl:when>
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
			<!--chunyu:Multiple versions of associated documents-->
		 	<xsl:variable name="ia" select="tokenize(@URI, '_')" />
		  	<li>
				<a href="{@URI}" class="pdfLink">
					<xsl:choose>
						<xsl:when test="starts-with($title, 'Mixed Language')"><xsl:value-of select="concat(substring-after($title, 'Mixed Language'), $dateSuffix, ' - ', 'Mixed Language')"/></xsl:when>
						<xsl:when test="@Language = 'Mixed'"><xsl:value-of select="concat($title, $dateSuffix, ' - Mixed Language')" /></xsl:when>
						<xsl:when test="exists(@Language)"><xsl:value-of select="concat($title, $dateSuffix, ' - ', @Language)" /></xsl:when>
						<xsl:when test="matches(@URI, '_en(_[0-9]{3})?.pdf$') and leg:GetDocumentMainType(./root()) = ('WelshAssemblyMeasure','WelshStatutoryInstrument','WelshNationalAssemblyAct')"><xsl:value-of select="concat($title, $dateSuffix, ' - English')"/></xsl:when>
						<!-- There are sometimes Welsh-language versions of UKSIs, so don't restrict this to MWAs & WSIs -->
						<xsl:when test="matches(@URI, '_we(_[0-9]{3})?.pdf$')"><xsl:value-of select="concat($title, $dateSuffix, ' - Welsh')"/></xsl:when>
						
						<xsl:when test="$isDraft">
							<xsl:if test="not(contains(@Title, 'Draft'))">
								<xsl:text>Draft </xsl:text>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="self::ukm:CorrectionSlip">
									<xsl:text>Correction Slip - </xsl:text>
									<xsl:value-of select="leg:FormatDate(@Date)"/>
								</xsl:when>
																		
								<xsl:when test="self::ukm:Alternative[exists($ia[4])]">
									<xsl:value-of select="$title"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select="number(replace($ia[4],'.pdf','','i')) + 1 "/>
								</xsl:when>
								<xsl:when test="self::ukm:Alternative[preceding-sibling::*[self::ukm:Alternative] and not(following-sibling::*)]						
									">
									<xsl:value-of select="$title"/>
									
								</xsl:when>
								<xsl:when test="self::ukm:ComingIntoForce[exists($ia[4])]  | 
									self::ukm:UKRPCOpinion[exists($ia[4])] |
									self::ukm:CodeofConduct[exists($ia[4])] | 
									self::ukm:OtherDocument[exists($ia[4])] | 
									self::ukm:UKExplanatoryMemorandum[exists($ia[4])] | 
									self::ukm:NIExplanatoryMemorandum[exists($ia[4])] | 
									self::ukm:TranspositionNote[exists($ia[4])] ">
									<xsl:value-of select="$title"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select="number(replace($ia[4],'.pdf','','i')) + 1 "/>
									
								</xsl:when>
								<xsl:when test="self::ukm:ComingIntoForce[preceding-sibling::*[self::ukm:ComingIntoForce] and not(following-sibling::*)]
									| self::ukm:UKRPCOpinion[preceding-sibling::*[self::ukm:UKRPCOpinion] and not(following-sibling::*)]
									| self::ukm:CodeofConduct[preceding-sibling::*[self::ukm:CodeofConduct] and not(following-sibling::*)]
									| self::ukm:OtherDocument[preceding-sibling::*[self::ukm:OtherDocument] and not(following-sibling::*)]
									| self::ukm:TranspositionNote[preceding-sibling::*[self::ukm:TranspositionNote] and not(following-sibling::*)]
									| self::ukm:UKExplanatoryMemorandum[preceding-sibling::*[self::ukm:UKExplanatoryMemorandum] and not(following-sibling::*)]
									| self::NIExplanatoryMemorandum[preceding-sibling::*[self::NIExplanatoryMemorandum] and not(following-sibling::*)]
									">
									<xsl:value-of select="$title"/>
									<xsl:text> 1</xsl:text>
								</xsl:when>	
								<xsl:otherwise>
									<xsl:value-of select="$title" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						
						<xsl:when test="self::ukm:CorrectionSlip">
							<xsl:text>Correction Slip - </xsl:text>
							<xsl:value-of select="leg:FormatDate(@Date)"/>
						</xsl:when>
						
						<xsl:when test="self::ukm:Alternative[exists($ia[4])]">
							<xsl:value-of select="$title"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="number(replace($ia[4],'.pdf','','i')) + 1 "/>
							
						</xsl:when>
						<xsl:when test="self::ukm:Alternative[preceding-sibling::*[self::ukm:Alternative] and not(following-sibling::*)]						
							">
							<xsl:value-of select="$title"/>
							
							
						</xsl:when>
						<xsl:when test="self::ukm:ComingIntoForce[exists($ia[4])] | 
							self::ukm:UKRPCOpinion[exists($ia[4])] |
							self::ukm:CodeofConduct[exists($ia[4])] | 
							self::ukm:OtherDocument[exists($ia[4])] | 
							self::ukm:UKExplanatoryMemorandum[exists($ia[4])] | 
							self::ukm:NIExplanatoryMemorandum[exists($ia[4])] | 
							self::ukm:TranspositionNote[exists($ia[4])] ">
								<xsl:value-of select="$title"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="number(replace($ia[4],'.pdf','','i')) + 1 "/>
						
						</xsl:when>
						<xsl:when test="self::ukm:ComingIntoForce[preceding-sibling::*[self::ukm:ComingIntoForce] and not(following-sibling::*)]
							| self::ukm:UKRPCOpinion[preceding-sibling::*[self::ukm:UKRPCOpinion] and not(following-sibling::*)]
							| self::ukm:CodeofConduct[preceding-sibling::*[self::ukm:CodeofConduct] and not(following-sibling::*)]
							| self::ukm:OtherDocument[preceding-sibling::*[self::ukm:OtherDocument] and not(following-sibling::*)]
							| self::ukm:TranspositionNote[preceding-sibling::*[self::ukm:TranspositionNote] and not(following-sibling::*)]
							| self::ukm:UKExplanatoryMemorandum[preceding-sibling::*[self::ukm:UKExplanatoryMemorandum] and not(following-sibling::*)]
							| self::NIExplanatoryMemorandum[preceding-sibling::*[self::NIExplanatoryMemorandum] and not(following-sibling::*)]
							">
							<xsl:value-of select="$title"/>
							<xsl:text> 1</xsl:text>
							
						</xsl:when>	
						<!--<xsl:value-of select="$dateSuffix" />-->
						<xsl:otherwise>
							<xsl:value-of select="$title" />
							
						</xsl:otherwise>
					</xsl:choose>
				</a>
				<xsl:text>   </xsl:text>
				<span class="filesize"><xsl:sequence select="tso:GetFileSize(@Size)"/></span>
			</li>
		</xsl:if>
	 </xsl:template>
	 
	 <xsl:template match="ukm:Supersedes" mode="AssociatedDocuments">
		 <xsl:if test="not($isDraft)"> <!-- only showing the current legislation is not draft-->
			<li>
				<a href="{concat(replace(@URI,'/id/','/'),'/contents')}" class="htmLink">
					<xsl:text>Draft Version</xsl:text>
				</a>
			</li>
		</xsl:if>			
	 </xsl:template>	 
	 
	 <xsl:template match="*" mode="AssociatedDocuments"/>
	 
	<xsl:template name="RelatedLegislation">
		<div class="relLeg colSection p_one">
			<h3>Related Legislation</h3>
			<div class="column1 s_4 p_one">
				<h4>Rel docs heading 1</h4>
				<ul class="plainList">
					<li><a href="#">Rel doc 1 <img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a></li>
					<li><a href="#">Rel doc 2 <img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a></li>
					<li><a href="#">Rel doc 3 <img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a></li>
				</ul>
			</div>
			<div class="column2 s_4 p_two">
				<h4>Rel docs heading 2</h4>
				<ul class="plainList">
					<li><a href="#">Rel doc 4 <img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a></li>
					<li><a href="#">Rel doc 5 <img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a></li>
					<li><a href="#">Rel doc 6 <img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a></li>
				</ul>
			</div>		
		</div>	
	</xsl:template>
	
	<xsl:template name="ListAllChanges">
		<xsl:param name="theTitle" as="xs:string" />

		<xsl:if test="($isRevised or $isEffectingTypeValid) and $hasXML">
			<div class="colSection p_one s_7">
					<div class="allChanges">
						<h3>List of all changes <em class="aside">(made to the revised version after 2002)</em>:</h3>
						<a class="helpItem helpItemToTop" href="#listAllChangesHelp">
								<img alt="Help about List of all changes" src="/images/chrome/helpIcon.gif"/>
						</a>
					</div>
					<ul class="plainList">
						<xsl:if test="$isRevised">
							<li>
								<a href="/changes/affected/{$uriPrefix}/{ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value}/{ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Number/@Value}">
									<strong>Affecting <xsl:value-of select="$theTitle"/></strong>
								</a>
								<span class="pageLinkIcon"/>	
							</li>
						</xsl:if>
						<xsl:if test="$isEffectingTypeValid">
							<li>
								<a href="/changes/affecting/{$uriPrefix}/{ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value}/{ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Number/@Value}">
									<strong>Made by <xsl:value-of select="$theTitle"/> affecting other Legislation</strong>
								</a>
								<span class="pageLinkIcon"/>									
							</li>
						</xsl:if>
					</ul>			
			</div>
		</xsl:if>
	</xsl:template>


	<xsl:template name="FurtherInformation">
		<div class="relDocs colSection p_one">
			<div class="furtherInfo column1 s_4 p_one half_col_margin">
				<h3>Further Information</h3>
				<ul class="plainList">
					<li>
						<a href="http://www.parliament.uk" target="_blank">UK Parliament website<img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a>
					</li>
					<xsl:if test="tso:countryType($documentMainType) = 'Scotland'">
						<li>
							<a href="http://www.scottish.parliament.uk" target="_blank">Scottish Parliament website<img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a>
						</li>
					</xsl:if>
					<xsl:if test="tso:countryType($documentMainType) = 'Wales'">
						<li>
							<a href="http://www.assemblywales.org" target="_blank">National Assembly for Wales<img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a>
						</li>
					</xsl:if>
					<xsl:if test="tso:countryType($documentMainType) = 'Northern Ireland'">
						<li>
							<a href="http://www.niassembly.gov.uk" target="_blank">Northern Ireland Assembly<img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)" class="newWin" /></a>
						</li>																		
					</xsl:if>	
					<!--<li><a href="">Further info 2</a></li>-->
				</ul>			
			</div>
				
			<div class="furtherInfo s_7_5 p_two">
				<h3>Next Steps</h3>
				<ul class="plainList">
					<li><a href="/{$uriPrefix}">
						More <xsl:value-of select="tso:GetTitleFromType($documentMainType, ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value)"/> <span class="pageLinkIcon"/>
					</a>
					</li>
					<li><a href="/{$uriPrefix}/{ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value}">
						More <xsl:value-of select="tso:GetTitleFromType($documentMainType, ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value)"/> from <xsl:value-of select="ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value"/> <span class="pageLinkIcon"/>
					</a>
					</li>
					<li><a href="/search">Advanced Search<span class="pageLinkIcon"/></a></li>
				</ul>			
			</div>
		</div>	
	</xsl:template>
	
	<xsl:template name="SectionsThat">

		<xsl:if test="leg:IsLegislationWeRevise(/)">
		<xsl:variable name="numUL" select="ceiling(count(ukm:Metadata/ukm:ConfersPower) div 3)"/>
		<xsl:variable name="numUL" select="if ($numUL &gt; 4) then 4 else $numUL"/>
	
		<div class="colSection p_one s_12">
		<!-- this needs a s_(3 * num) class based upon the larget number of the <ul> elements within each .confers_section, e.g. if 
			there are 3 <ul> elements then the classs added would be s_9 (3 * 3), if there were 4 <ul> elements then it would be s_12 -->				
			
				<h3 class="confers_title">Sections that <span class="accessibleText">Confers power or Apply Blanket Amendments </span>:
					<a class="helpItem helpItemToMidRight" href="#sectionsThatHelp">
							<img alt="Help about Sections That" src="/images/chrome/helpIcon.gif"/>
					</a>						
				</h3>					
	
							
				<ul class="anchors jsShownText s_12 htabs">
					<li><a href="#confers">Confers power</a></li>
					<li><a href="#blanket">Apply Blanket Amendments</a></li>
				</ul>
				
				<div id="confers" class="confers_section tab">
					<h4 class="jsHiddenText">Confers power</h4>
					<xsl:choose>
						<xsl:when test="exists(ukm:Metadata/ukm:ConfersPower)">
							<table>
								<tbody>
									<xsl:for-each-group select="ukm:Metadata/ukm:ConfersPower" group-ending-with="ukm:Metadata/ukm:ConfersPower[position() mod 4 = 0]">
										<tr>
											<xsl:if test="position() mod 2 = 1">
												<xsl:attribute name="class">oddRow</xsl:attribute>
											</xsl:if>
											<xsl:for-each select="current-group()">
												<td>
													<xsl:apply-templates select="."/>
												</td>
											</xsl:for-each>
										</tr>
									</xsl:for-each-group>
								</tbody>
							</table>
						</xsl:when>
						<xsl:otherwise>
							<p>There are currently no matches for this criteria.</p>
						</xsl:otherwise>
					</xsl:choose>
	
				</div><!--/#confers-->
				
				<div id="blanket" class="confers_section tab">
					<h4 class="jsHiddenText">Apply blanket amendments</h4>
					<xsl:choose>
						<xsl:when test="exists(ukm:Metadata/ukm:BlanketAmendment)">
							<table>
								<tbody>
									<xsl:for-each-group select="ukm:Metadata/ukm:BlanketAmendment" group-ending-with="ukm:Metadata/ukm:BlanketAmendment[position() mod 4 = 0]">
										<tr>
											<xsl:if test="position() mod 2 = 1">
												<xsl:attribute name="class">oddRow</xsl:attribute>
											</xsl:if>
											<xsl:for-each select="current-group()">
												<td>
													<xsl:apply-templates select="."/>
												</td>
											</xsl:for-each>
										</tr>
									</xsl:for-each-group>
									</tbody>
							</table>
						</xsl:when>
						<xsl:otherwise>
							<p>There are currently no matches for this criteria</p>
						</xsl:otherwise>
					</xsl:choose>
				</div><!--/#blanked amendments-->
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ukm:ConfersPower | ukm:BlanketAmendment">
        <xsl:variable name="InputString" select="@title"/>
        <xsl:variable name="Section" select="normalize-space(substring-before($InputString,':'))"/>
        <xsl:variable name="Title" select="normalize-space(substring-after($InputString,':'))"/>
		<a href="{@IdURI}" title="{$Title}">
			<xsl:value-of select="$Section"/>
		</a>
	</xsl:template>
	
	<!-- ========== Standard code for breadcrumb ========= -->
	<xsl:template name="TSOOutputBreadcrumbItems">
		  <!--/#breadcrumbControl --> 
			<div id="breadCrumb">
				<h3 class="accessibleText">You are here:</h3>		
				<ul>
					<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
					<li class="activetext">More Resources</li>
				</ul>
		</div>
	</xsl:template>

	
	<!-- ========== Standard code for opening options ========= -->	
	<xsl:template name="TSOOutputHelpTips">
		<xsl:call-template name="TSOOutputENsHelpTips"/>
		
		<xsl:if test="$isRevised or $isEffectingTypeValid">
			<div class="help" id="listAllChangesHelp">
				<span class="icon" />
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif" />
					</a>
					<h3>List of all changes</h3>
					<p>
						Link(s) to the Changes to Legislation facility which provides access to lists detailing changes made by all legislation enacted from 2002 - present to the revised legislation held on legislation.gov.uk, along with details about those changes which have and have not been applied by the legislation.gov.uk editorial team to this legislation item. Details of changes are only available back to 2002. Changes made before 2002 are already incorporated into the text of the revised legislation on legislation.gov.uk
					</p>	
				</div>
			</div>
		</xsl:if>
		
		<xsl:if test="leg:IsLegislationWeRevise(/)">
			<div class="help" id="sectionsThatHelp">
				<span class="icon" />
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif" />
					</a>
					<h3>Sections that</h3>
					<p>
						These lists are based on information contained in latest available (revised) version as recorded by the legislation.gov.uk editorial team. For legislation enacted before the basedate (1/1/2006 for Northern Ireland legislation and 1/2/1991 for all other revised legislation) this information may not be available.
					</p>	
				</div>
			</div>		
		</xsl:if>
		
	</xsl:template>	

	<!-- ========== File size ========= -->	
	<xsl:function  name="tso:GetFileSize" as="xs:string?">
		<xsl:param name="fileSize" as="xs:integer?"/>
		<xsl:if test="$fileSize castable as xs:integer and $fileSize &gt; 0">
			<xsl:variable name="kb" select="$fileSize div 1024" />
			<xsl:choose>
				<xsl:when test="$kb > 1000">
					<xsl:sequence select="concat(format-number($kb div 1024, '0.##'), 'MB')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="concat(format-number($kb, '0'), 'kB')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:function>	
	
</xsl:stylesheet>
