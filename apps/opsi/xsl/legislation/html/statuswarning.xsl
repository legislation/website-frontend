<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Status Warning Module (re-used in the PDFs and UI)-->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 30/06/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns="http://www.w3.org/1999/xhtml"  version="2.0" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:db="http://docbook.org/ns/docbook"	
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events"
	exclude-result-prefixes="xs tso dc db ukm atom leg xforms ev xhtml"
	>

	<xsl:import href="../../common/utils.xsl"/>

	<xsl:include href="unapplied_effects_xhtml_core.xsl"/>

	<xsl:variable name="g_nstCodeLists" select="document('../../codelists.xml')/CodeLists/CodeList"/>

	<xsl:variable name="ndsLegislation" select="/leg:Legislation"/>
		
	<xsl:key name="versions" match="leg:Version" use="@id"/>
	
	<!-- input parameter doc -->
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>
	<!--  let $version be the value of the version parameter coming through Orbeon  -->
	<xsl:variable name="version" as="xs:string" select="($paramsDoc/parameters/version, '')[1]"/>
	<!--  let $pointInTimeView be true if $version is either castable to a date or the value 'prospective' -->
	<xsl:variable name="pointInTimeView" as="xs:boolean" select="($version castable as xs:date) or $version = 'prospective' "/>
	<!-- let $type be the type of legislation -->
	<xsl:variable name="type" as="xs:string" select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>
	<!-- let $baseDate be the base date for the type of legislation -->
	<xsl:variable name="baseDate" as="xs:string" 
		select="if ($type = ('NorthernIrelandOrderInCouncil', 'NorthernIrelandAct', 'NorthernIrelandParliamentAct')) then '2006-01-01' else '1991-02-01'"/>
	
	<!-- getting the scenario -->
	<xsl:template name="TSOGetScenarios">
		<xsl:param name="type"/>
		
		<xsl:choose>
			<xsl:when test="leg:IsLegislationWeRevise(.) ">
				<xsl:choose>
					<xsl:when test="leg:IsRevisedVersionExists(.)">
						<xsl:choose>
							<xsl:when test="leg:IsOustandingEffectExists(.)">
								<xsl:choose>
									<xsl:when test="leg:IsEnactedExists(.)">
										<xsl:choose>
											<xsl:when test="$type = 'whatversion' ">A</xsl:when>
											<xsl:when test="$type = 'updatestatus' ">
												<xsl:choose>
													<xsl:when test="leg:IsCurrentRevised(.)">5</xsl:when>
													<xsl:otherwise>4</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="$type = 'whatversion' ">C</xsl:when>
											<xsl:when test="$type = 'updatestatus' ">
												<xsl:choose>
													<xsl:when test="leg:IsCurrentRevised(.)">5</xsl:when>
													<xsl:otherwise>4</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="leg:IsEnactedExists(.)">
										<xsl:choose>
											<xsl:when test="$type = 'whatversion' ">A</xsl:when>
											<xsl:when test="$type = 'updatestatus' ">
												<xsl:choose>
													<xsl:when test="leg:IsCurrentRevised(.) ">1</xsl:when>
													<xsl:when test="leg:IsCurrentOriginal(.)">4</xsl:when>
												</xsl:choose>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="$type = 'whatversion' ">C</xsl:when>
											<xsl:when test="$type = 'updatestatus' ">1</xsl:when>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$type = 'whatversion' ">B</xsl:when>
							<xsl:when test="$type = 'updatestatus' ">2</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$type = 'whatversion' ">D</xsl:when>
					<xsl:when test="$type = 'updatestatus' ">3</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- outputting the update status text based on the scenarios-->
	<xsl:template name="TSOOutputUpdateStatusMessage">
		<xsl:param name="AddAppliedEffects" as="xs:boolean" select="false()"/>
		<xsl:param name="includeTooltip" as="xs:boolean" select="false()"/>
		<xsl:variable name="Scenario">
			<xsl:call-template name="TSOGetScenarios">
				<xsl:with-param name="type" select="'updatestatus'"/>
			</xsl:call-template>
		</xsl:variable>
		<div>
			<xsl:choose>
				<xsl:when test="not(leg:IsPDFOnlyNotRevised(.)) and ($Scenario = '1' or  $Scenario = '5' or leg:IsCurrentRevised(.)) ">
					<xsl:attribute name="id">statusWarning</xsl:attribute>
					<xsl:attribute name="class"><xsl:if test="$Scenario = '1'">uptoDate</xsl:if></xsl:attribute>
					<div class="title">
						<h2>Changes to legislation:</h2>
						<p class="intro">
							<xsl:choose>
								<xsl:when test="leg:IsRevisedPDFOnly(.)">
										<xsl:variable name="reviseddate" as="xs:date" select="max(xs:date($ndsLegislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised castable as xs:date]/@Revised))"/>
										<xsl:text>This item of legislation is only available to download and view as PDF. The electronic revised (latest available) version of the </xsl:text>
										<xsl:value-of select="leg:Legislation/ukm:Metadata/dc:title"/>	
										<xsl:text> has been created and contributed by the Department for Work and Pensions.</xsl:text>
										<!--<a href="http://www.legislation.gov.uk/contributors#dwp"><strong> Read more.</strong></a>-->
										<xsl:text> There may be outstanding changes yet to be applied. This version incorporates changes up to </xsl:text>
										<xsl:value-of select="if (exists($reviseddate)) then format-date($reviseddate,'[D]/[M]/[Y]') else 'DD/MM/YYYY'"/>
										<xsl:text>.</xsl:text>
									</xsl:when>
								<xsl:when test="$Scenario = '1' ">
									<xsl:variable name="sectionTitle">
										<xsl:choose>
										<xsl:when test="$nstSelectedSection"><xsl:apply-templates select="$nstSelectedSection" mode="CurrentSectionName" /></xsl:when>
										<xsl:when test="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/introduction' and @title='introduction']/@href = leg:Legislation/ukm:Metadata/dc:identifier">
											<xsl:text>Introductory Text</xsl:text>
										</xsl:when>
									</xsl:choose>
									</xsl:variable>
									<xsl:text>There are currently no known outstanding effects for the </xsl:text><xsl:value-of select="leg:Legislation/ukm:Metadata/dc:title"/>
									<xsl:if test="string-length($sectionTitle) ne 0">
										<xsl:value-of select="concat(', ', $sectionTitle)"/>
									</xsl:if>
									<xsl:text>.</xsl:text>
								</xsl:when>
								<xsl:when test="$Scenario = '5' ">
									<xsl:text>There are outstanding changes not yet made by the legislation.gov.uk editorial team to </xsl:text>
									<xsl:value-of select="leg:Legislation/ukm:Metadata/dc:title"/>
									<xsl:text>.</xsl:text> 
									<!-- The reason for this is that people are seeing this message and wanting to immediately go to the Tables of Effects (now the Changes to Legislation) when really they would be much better off looking at the effects within the Act. -->
									<xsl:if test="leg:IsTOC()">
										<xsl:text> Those changes will be listed when you open the content using the Table of Contents below.</xsl:text>
									</xsl:if>
									<xsl:text> Any changes that have already been made by the team appear in the content and are referenced with annotations.</xsl:text>
								</xsl:when>
								
							</xsl:choose>
							
							<xsl:if test="string-length ($Scenario) > 0 and $includeTooltip">
								<a href="#Scenario{$Scenario}Help" class="helpItem helpItemToBot">
									<img src="/images/chrome/helpIcon.gif" alt=" Help about Changes to Legislation"/>
								</a>
							</xsl:if>
						</p>
							<xsl:if test="$includeTooltip">
								<!-- adding the help tooltip-->
								<xsl:call-template name="TSOOutputStatusHelpTip">
									<xsl:with-param name="scenarioId" select="$Scenario"/>
									<xsl:with-param name="helpTitle">Changes to Legislation</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							<!-- adding the unapplied effects if there are oustanding changes and we are in the content tab -->
							<xsl:if test="$Scenario = '5' and leg:IsContent() and not($pointInTimeView and $version != 'prospective')">
								<xsl:variable name="ndsFilterUnappliedEffects">
									<xsl:apply-templates select="leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata)/ukm:UnappliedEffects" mode="filterUnappliedEffects">
										<xsl:with-param name="includeTooltip" select="$includeTooltip" tunnel="yes"/>													
									</xsl:apply-templates>
								</xsl:variable>
								<xsl:if test="exists($ndsFilterUnappliedEffects/*)">
									<div id="statusWarningSubSections">
										<xsl:copy-of select="$ndsFilterUnappliedEffects/*"/>
									</div>
									<span/>
								</xsl:if>
							</xsl:if>
					</div>
				</xsl:when>
				
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="leg:IsDraft(.)">
							<xsl:attribute name="id">infoDraft</xsl:attribute>							
							<h2>Draft Legislation:</h2>
						</xsl:when>
						<xsl:when test="leg:IsProposedVersion(.)">
							<xsl:attribute name="id">infoProposed</xsl:attribute>
							<h2>Proposed Legislation:</h2>
						</xsl:when>
						
						<xsl:otherwise>
							<xsl:attribute name="id">infoSection</xsl:attribute>							
							<h2>Status:</h2>
						</xsl:otherwise>
					</xsl:choose>
					<p class="intro">
						<xsl:variable name="maintype" as="xs:string" select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>
						<xsl:choose>
							<xsl:when test="leg:IsProposedVersion(.)">
								<strong><xsl:value-of select="/leg:Legislation/ukm:Metadata/dct:alternative" /></strong>
								<xsl:text> This version shows proposed changes to this legislation item. It has no official standing.</xsl:text>
							</xsl:when>
							<xsl:when test="leg:IsDraft(.)">
								<xsl:text>This is a draft item of legislation</xsl:text>
								<!-- 
								For a draft legislation item with a 'superseded' version: 
									Draft Legislation: This is a draft legislation item. This draft has since been made as {legislation type}: {legislation title + number}.
								For a draft legislation item with a later draft: 
									Draft Legislation: This is a draft legislation item and has not yet been made as a {legislation type}. This draft has been replaced by a new draft, {draft legislation title + ISBN} 
								For a draft legislation item: 
									Draft Legislation: This is a draft legislation item and has not yet been made as a {legislation type}.
								-->
								<xsl:choose>
									<xsl:when test="exists(/leg:Legislation/ukm:Metadata/ukm:SupersededBy/ukm:Number)">
										<xsl:text>. This draft has since been made as a </xsl:text>
										<xsl:value-of select="tso:GetSingularTitleFromType(tso:GetTypeFromDraftType($maintype,''),'')"/>
										<xsl:text>: </xsl:text>	
									</xsl:when>
									<xsl:otherwise>
										<xsl:text> and has not yet been made as a </xsl:text>									
										<xsl:value-of select="tso:GetSingularTitleFromType(tso:GetTypeFromDraftType($maintype,''),'')"/>
										<xsl:text>. </xsl:text>
										<xsl:if test="exists(/leg:Legislation/ukm:Metadata/ukm:SupersededBy)">
											<xsl:text>This draft has been replaced by a new draft, </xsl:text>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/ukm:SupersededBy" mode="statuswarning"/>
								<xsl:if test="leg:IsPDFOnly(.)">
									
									<xsl:text>. This item of legislation is only available to download and view as PDF.</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:when test="leg:IsPDFOnly(.)">
					<xsl:text>This item of legislation is only available to download and view as PDF.</xsl:text>
									
							</xsl:when>
							<xsl:when test="$Scenario = '2'">
								<xsl:text>This is the original version (as it was originally </xsl:text>
								<xsl:value-of select="leg:GetCodeSchemaStatus(.)"/>
								<xsl:text>). This item of legislation is currently only available in its original format.</xsl:text>
							</xsl:when>
							<xsl:when test="$Scenario = '3'">
								<xsl:text>This is the original version (as it was originally </xsl:text>
								<xsl:value-of select="leg:GetCodeSchemaStatus(.)"/>
								<xsl:text>). </xsl:text>
								<xsl:value-of select="tso:GetTitleFromType($maintype, ())"/>
								<xsl:text> are not carried in their revised form on this site.</xsl:text>
							</xsl:when>
							<xsl:when test="$Scenario = '4'">
								<xsl:text>This is the original version (as it was originally </xsl:text>
								<xsl:value-of select="leg:GetCodeSchemaStatus(.)"/>
								<xsl:text>).</xsl:text>
							</xsl:when>
						</xsl:choose>
						<xsl:if test="leg:isFromWestlaw(.)">
							<xsl:text> The electronic version of this </xsl:text>
							<xsl:value-of select="tso:GetSingularTitleFromType($maintype,'')" />
							<xsl:text> has been contributed by Westlaw and is taken from the printed publication. </xsl:text>
							<a href="/contributors#westlaw" class="more"><strong>Read more</strong></a>
						</xsl:if>
						
					</p>
				</xsl:otherwise>
			</xsl:choose>
			<!--
				IsLegislationWeRevise: [<xsl:value-of select="leg:IsLegislationWeRevise(.)"/>]
				<br/>
				IsRevisedVersionExists: [<xsl:value-of select="leg:IsRevisedVersionExists(.)"/>]
				<br/>		
					IsOustandingEffectExists: [<xsl:value-of select="leg:IsOustandingEffectExists(.)"/>]
				<br/>		
				IsEnactedExists: [<xsl:value-of select="leg:IsEnactedExists(.)"/>]
				<br/>
				IsCurrentRevised: [<xsl:value-of select="leg:IsCurrentRevised(.)"/>]
				<br/>
				IsCurrentOriginal: [<xsl:value-of select="leg:IsCurrentOriginal(.)"/>]			
				<br/>
				Scenario: [<xsl:value-of select="$Scenario"/>]					
				<br/>
			</xsl:if>	 -->
		</div>
	</xsl:template>
	
	<xsl:template match="ukm:SupersededBy" mode="statuswarning">
		<a href="{leg:FormatURL(concat(replace(@URI,'/id/','/'),'/contents', if (ukm:Number) then '/made' else ()))}"> <!-- {legislation type}: {legislation title + number}. -->
			<xsl:value-of select="dc:title[1]" />
			<xsl:choose>
				<xsl:when test="ukm:Number">
					<xsl:text> No. </xsl:text>
					<xsl:value-of select="ukm:Number/@Value" />
				</xsl:when>
				<xsl:when test="ukm:ISBN">
					<xsl:text> ISBN </xsl:text>
					<xsl:value-of select="tso:formatISBN(ukm:ISBN/@Value)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="tokens" select="tokenize(substring-after(@URI,'/id/'), '/')"/>
					<xsl:variable name="number" as="xs:string?" select="$tokens[3]"/>
					<xsl:choose>
						<xsl:when test="string-length($number) &lt; 5 and $number != ''">
							<xsl:text> No. </xsl:text>
							<xsl:value-of select="$number" />
						</xsl:when>
						<xsl:when test="string-length($number) &gt; 5">
							<xsl:text> ISBN </xsl:text>
							<xsl:value-of select="tso:formatISBN($number)"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- cannot determine the number so display nothing  -->
						</xsl:otherwise>
					</xsl:choose>	
				</xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:template>
	
	<!-- outputting the update status text based on the scenarios-->
	<xsl:template name="TSOOutputUpdateStatus">
		<xsl:param name="AddAppliedEffects" as="xs:boolean" select="false()"/>
		<xsl:param name="includeTooltip" as="xs:boolean" select="false()"/>
		<!-- Status messages for Revised -->
		<xsl:if test="leg:IsCurrentRevised(.)">
			<xsl:call-template name="TSOOutputStatusMessage">
				<xsl:with-param name="includeTooltip" select="$includeTooltip"/>
			</xsl:call-template>
		</xsl:if>
		<!-- Changes to Legislation message/Status(for enacted) message-->
		<xsl:call-template name="TSOOutputUpdateStatusMessage">
			<xsl:with-param name="AddAppliedEffects" select="$AddAppliedEffects"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="TSOOutputStatusMessage">
		<xsl:param name="includeTooltip" as="xs:boolean" select="false()"/>
		<xsl:param name="includeTimeline" as="xs:boolean" select="false()"/>		
		<!-- status messages are only available if there is not content -->
		<xsl:if test="not(leg:IsTOC())">
			<xsl:variable name="strCurrentURIs" select="/leg:Legislation/ukm:Metadata/dc:identifier, /leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasPart']/@href"/>
			<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]"/>
			<!-- status message text retrieved from the section, part, chapter, whole act etc.-->
			<xsl:variable name="status" as="element(tso:status)?">
				<xsl:apply-templates select="$nstSection" mode="TSOStatusMessage"/>
			</xsl:variable>
			<!-- point in time text -->
			<xsl:variable name="pointInTimeText">
				<xsl:choose>
					<xsl:when test="$version = 'prospective'">Point in time view latest with prospective.</xsl:when>
					<xsl:when test="$version castable as xs:date">Point in time view as at <xsl:value-of select="leg:FormatDate($version)"/>. </xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="exists($status) or string-length($pointInTimeText) > 0">
				<!-- displaying the Status message -->
				<div id="infoSection">
					<h2>Status:</h2>
					<p class="intro">
						<xsl:value-of select="$pointInTimeText"/>
						<xsl:sequence select="$status/node()[not(self::tso:extent)]" />
						<xsl:if test="$includeTimeline">
							<xsl:choose>
								<xsl:when test="$status/@scenarioId = 'S2' ">
									<xsl:text> </xsl:text>
									<a href="?timeline=true">Show Timeline of Changes</a>
								</xsl:when>
								<xsl:when test="$status/@scenarioId = xs:string( if ($pointInTimeView) then ('S9') else ('S6') )">
									<xsl:text> </xsl:text>
									<a href="?timeline=true">Show Timeline of Changes</a>
									<xsl:text> to view this provision at an earlier point in time.</xsl:text>
								</xsl:when>
								<xsl:when test="$status/@scenarioId = (if ($pointInTimeView) then 'S12' else 'S9')">
									<xsl:text> </xsl:text>
									<a href="?timeline=true">Show Timeline of Changes</a>
									<xsl:text> to view this provision as it would have been.</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						
						<xsl:if test="string-length ($status/@scenarioId) > 0 and $includeTooltip">
							<a href="#Scenario{$status/@scenarioId}Help" class="helpItem helpItemToBot">
								<img src="/images/chrome/helpIcon.gif" alt=" Help about Status"/>
							</a>
						</xsl:if>
					</p>
					<xsl:if test="exists($status) and $includeTooltip">
						<!-- displaying the help tool tip-->
						<xsl:call-template name="TSOOutputStatusHelpTip">
							<xsl:with-param name="scenarioId" select="$status/@scenarioId"/>
							<xsl:with-param name="helpTitle">Status</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$status/tso:extent">
						<div class="extentMarkerInfo">
							<h2>Skip to: </h2>
							<ul>
								<xsl:for-each select="$status/tso:extent/*">
									<li>
										<xsl:sequence select="."/>
									</li>
								</xsl:for-each>
							</ul>						
						</div>		
					</xsl:if>
				</div>
			</xsl:if>
		</xsl:if>
		<!--
		<xsl:if test="exists($nstSection)">
			<xsl:for-each select="$nstSection/ancestor-or-self::*[@DocumentURI]">
				<br/>		
				[<xsl:value-of select="position()"/> : <xsl:value-of select="name()" />, <xsl:apply-templates select="current()" mode="TSOStatusMessage"/>]
			</xsl:for-each>
			<br/>

		</xsl:if>
		-->
	</xsl:template>
	<!-- template to output the help tip HTML-->
	<xsl:template name="TSOOutputStatusHelpTip">
		<xsl:param name="scenarioId" as="xs:string"/>
		<xsl:param name="helpTitle" as="xs:string"/>
		<xsl:if test="string-length ($scenarioId) > 0">
			<div class="help" id="Scenario{$scenarioId}Help">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>
						<xsl:value-of select="$helpTitle"/>
					</h3>
						<xsl:choose>
							<xsl:when test="leg:IsRevisedPDFOnly(.) ">
								<p>Revised legislation carried on this site may not be fully up to date. Changes and effects are recorded by our editorial team in lists which can be found in the ‘Changes to Legislation’ area.</p>
							</xsl:when>
							<xsl:when test="$scenarioId = '1' ">
								
							<p>Revised legislation carried on this site may not be fully up to date. At the current time any known changes or effects made by subsequent legislation have been applied to the text of the legislation you are viewing by the editorial team.  Please see ‘Frequently Asked Questions’ for details regarding the timescales for which new effects are identified and recorded on this site.</p>
								
							</xsl:when>
						
							
							<xsl:when test="$scenarioId ='5' ">
								<xsl:choose>
									<xsl:when test="$pointInTimeView">
										<p>Changes and effects yet to be applied by the editorial team are only applicable when viewing the latest version or prospective version of legislation. They are therefore not accessible when viewing legislation as at a specific point in time. To view the ‘Changes to Legislation’ information for this provision return to the latest version view using the options provided in the ‘What Version’ box above.</p>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="leg:IsTOC()">
												<p>
													<xsl:text>Revised legislation carried on this site may not be fully up to date. Changes and effects are recorded by our editorial team in lists which can be found in the ‘Changes to Legislation’ area.  Where those effects have yet to be applied to the text of the legislation by the editorial team they are also listed alongside the affected provisions when you open the content using the Table of Contents below.</xsl:text> 							
												</p>
											</xsl:when>
											<xsl:otherwise>
												<p>
													<xsl:text>Revised legislation carried on this site may not be fully up to date. Changes and effects are recorded by our editorial team in lists which can be found in the ‘Changes to Legislation’ area. Where those effects have yet to be applied to the text of the legislation by the editorial team they are also listed alongside the legislation in the affected provisions. Use the ‘more’ link to open the changes and effects relevant to the provision you are viewing.</xsl:text>
												</p>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$scenarioId = '5'  and leg:IsTOC()">
								<p>Revised legislation carried on this site may not be fully up to date. Changes and effects are recorded by our editorial team in lists which can be found in the ‘Changes to Legislation’ area.  Where those effects have yet to be applied to the text of the legislation by the editorial team they are also listed alongside the affected provisions when you open the content using the Table of Contents below.</p>
							</xsl:when>
							<xsl:when test="$scenarioId = '5'  and leg:IsContent()">
								<p>Revised legislation carried on this site may not be fully up to date. Changes and effects are recorded by our editorial team in lists which can be found in the ‘Changes to Legislation’ area. Where those effects have yet to be applied to the text of the legislation by the editorial team they are also listed alongside the legislation in the affected provisions. Use the ‘more’ link to open the changes and effects relevant to the provision you are viewing.</p>
							</xsl:when>
							<xsl:when test="$pointInTimeView">
								<xsl:choose>
									<xsl:when test="$scenarioId = 'S1' ">
										<p>The term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section.  A version of a provision is prospective either: </p>
										<ol>
											<li>where the provision (Part, has never come into force or; </li>
											<li>where the text of the provision is subject to change, but no date has yet been appointed by the appropriate person or body for those changes to come into force.  </li>
										</ol>
										<p>Commencement Orders listed in the ‘Changes to Legislation’ box as not yet applied may bring this prospective version into force.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S2' ">
										<p>The version on screen is currently in force, but there is a version available (prospective version) to show how it could change.  The prosective version remains prospective until a date is appointed by an appropriate person or body to bring it into force.. To see the prospective version, use the Show Timeline of Changes feature under ‘Advanced Features’.</p>
										<p>Commencement Orders listed in the ‘Changes to Legislation’ box as not yet applied may bring changes and effects in the prospective version into force.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S3' ">
										<p>You are viewing this legislation item as it stood at a particular point in time.  A later version of this provision, including subsequent changes and effects, supersedes this version. Note the term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S4' ">
										<p>You are viewing this legislation item as it stood at a particular point in time.  A later version of this or provision, including subsequent changes and effects, supersedes this version.   </p>
										<p>Note the term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section. </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S5' ">
										<p>You are viewing this legislation item as it stood at a particular point in time.  At this point in time multiple versions of this provision exist for differing geographical extents. Sometimes the text of a provision is changed, but the change(s) only apply to a particular geographical area. In some limited cases where this happens, the editorial team create a version for each different geographical area. Multiple versions are only created in this way where the change in question is a substitution so that there are different versions of the text for the different extents.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S6' ">
										<p>You are viewing this legislation item as it stood at a particular point in time.  At this point in time multiple versions of this provision existed for differing geographical extents. Sometimes the text of a provision is changed, but the change(s) only apply to a particular geographical area. In some limited cases where this happens, the editorial team create a version for each different geographical area. Multiple versions are only created in this way where the change in question is a substitution so that there are different versions of the text for the different extents. A later version of this provision including  subsequent changes and effects supersedes these versions. </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S7' ">
										<p>The term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section.  A version of a provision is prospective either: </p>
										<ol>
											<li>where the provision (Part, Chapter or section) has never come into force or; </li>
											<li>where the text of the provision is subject to change, but no date has yet been appointed by the appropriate person or body for those changes to come into force. </li>
										</ol>
										<p>Multiple prospective provisions are most likely to occur where a provision that is not yet in force is subject to a change that is also not yet in force.</p>
										<p>Commencement Orders listed in the ‘Changes to Legislation’ box as not yet applied may bring these prospective versions into force.</p>
										<p>Note: Point in time prospective is the latest available view of the legislation that includes by default all the prospective changes that might come into force.  </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S8' ">
										<p>The term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section. Sometimes the text of a provision is changed, but the change(s) only apply to a particular geographical area. In some limited cases where this happens, the editorial team create a version for each different geographical area. Multiple versions are only created in this way where the change in question is a substitution so that there are different versions of the text for the different extents.  In this case the multiple versions on screen are also prospective, meaning that those changes have not yet been brought into force. Commencement Orders listed in the ‘Changes to Legislation’ box as not yet applied may bring changes and effects in the prospective version into force.</p>
										<p>Note: Point in time prospective is the latest available view of the legislation that includes by default all the prospective changes that might come into force.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S9' ">
										<p>You are viewing this legislation item as it stood at a particular point in time. 'No longer has effect', generally means that this provision has been repealed. Take a look at the annotations at the end of the provision for further information. No subsequent versions of this provision exist.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S10' ">
										<p>The term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section.  A version of a provision is prospective either: </p>
										<ol>
											<li>where the provision (Part, Chapter or section) has never come into force or; </li>
											<li>where the text of the provision is subject to change, but no date has yet been appointed by the appropriate person or body for those changes to come into force.</li>
										</ol>
										<p>Commencement Orders listed in the ‘Changes to Legislation’ box as not yet applied may bring this prospective version into force. </p>
										<p>Note: Point in time prospective is the latest available view of the legislation that includes by default all the prospective changes that might come into force.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S11' ">
										<p>Not valid for this point in time generally means that a provision was not in force for the point in time you have selected to view it on.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S12' ">
										<p>You are viewing this provision as it would have stood if it had come into force. It was repealed before it came into force.</p>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$scenarioId = 'S1' ">
										<p>The term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section.  A version of a provision is prospective either:</p>
										<ol>
											<li>where the provision (Part, Chapter or section) has never come into force or;</li>
											<li>where the text of the provision is subject to change, but no date has yet been appointed by the appropriate person or body for those changes to come into force.</li>
										</ol>
										<p>Commencement Orders listed in the ‘Changes to Legislation’ box as not yet applied may bring this prospective version into force.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S2' ">
										<p>The version on screen is currently in force, but there is a version available (prospective version) to show how it could change.</p>
										<p>The prospective version will remain prospective until a date is appointed by an appropriate person or body to bring those changes into force.</p>
										<p>To see the prospective version, use the Show Timeline of Changes feature under ‘Advanced Features’.</p>
										<p>Commencement Orders listed in the ‘Changes to Legislation’ box as not yet applied may bring changes and effects in the prospective version into force.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S3' ">
										<p>The term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section.</p>
										<p>Sometimes the text of a provision is changed, but the change(s) only apply to a particular geographical area. In some limited cases where this happens, the editorial team create a version for each different geographical area. Multiple versions are only created in this way where the change in question is a substitution so that there are different versions of the text for the different extents. Insertions and repeals of text do not give rise to such multiple versions.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S4' ">
										<p>The term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section.  A version of a provision is prospective either: </p>
										<ol>
											<li>where the provision (Part, Chapter or section) has never come into force or;</li>
											<li>where the text of the provision is subject to change, but no date has yet been appointed by the appropriate person or body for those changes to come into force. </li>
										</ol>
										<p>Multiple prospective provisions are most likely to occur where a provision that is not yet in force is subject to a change that is also not yet in force.</p>
										<p>Commencement Orders listed in the ‘Changes to Legislation’ box as not yet applied may bring these prospective versions into force.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S5' ">
										<p>The term provision is used to describe a definable element in a piece of legislation that has legislative effect – such as a Part, Chapter or section. Sometimes the text of a provision is changed, but the change(s) only apply to a particular geographical area. In some limited cases where this happens, the editorial team create a version for each different geographical area. Multiple versions are only created in this way where the change in question is a substitution so that there are different versions of the text for the different extents.  In this case the multiple versions on screen are also prospective, meaning that those changes have not yet been brought into force. Commencement Orders listed in the ‘Changes to Legislation’ box as not yet applied may bring changes and effects in the prospective version into force. </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S6' ">
										<p>No longer has effect, generally means that this provision has been repealed. Take a look at the annotations at the end of the provision for further information.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S7' ">
										<p>Where an 'has effect from' date is given, it generally means that the provision is not in force on today's date but will come into force with effect from the given date.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S8' ">
										<p>Where provisions have yet to come into effect, it generally means that the provisions are not in force on today's date but will come into force with effect from the given date.</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S9' ">
										<p>Where provisions never came into effect, it generally means that the provision was repealed before it came into force. Take a look at the annotations at the end of the provision for further information.</p>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	<!-- templates to output specific status messages -->
	<xsl:template match="leg:P1" mode="TSOStatusMessage" as="element(tso:status)?">
		<xsl:apply-templates select="parent::*" mode="TSOStatusMessage"/>
	</xsl:template>
	<xsl:template match="leg:P1group" mode="TSOStatusMessage" as="element(tso:status)?">
		<xsl:choose>
			<xsl:when test="$pointInTimeView and 
									@RestrictStartDate castable as xs:date and 
									$version castable as xs:date and 
									xs:date(@RestrictStartDate) &gt; xs:date($version)">
				<tso:status scenarioId="S11">This version of this provision is not valid for this point in time.</tso:status>				
			</xsl:when>	
			<xsl:when test="@Status = 'Prospective'">
				<xsl:choose>
					<xsl:when test="@Concurrent = 'true'">
						<tso:status scenarioId="{if ($pointInTimeView) then 'S8' else 'S5'}">
							<xsl:text>There are multiple prospective versions of this provision on screen. These apply to different geographical extents.</xsl:text>
							<tso:extent><xsl:apply-templates select="." mode="TSOExtentLinks" /></tso:extent>
						</tso:status>
					</xsl:when>
					<xsl:when test="exists(@AltVersionRefs)">
						<tso:status scenarioId="{if ($pointInTimeView) then 'S7' else 'S4'}">There are multiple prospective versions of this provision on screen.</tso:status>
					</xsl:when>
					<xsl:otherwise>
						<tso:status scenarioId="{if ($pointInTimeView) then 
									(if (exists(/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasVersion' and @title castable as xs:date]) ) 
										then  'S1' 
									else 'S10')
								else 'S1'}">This version of this provision is prospective.</tso:status>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@Status = 'Dead'">
				<tso:status scenarioId="{if ($pointInTimeView) then 'S12' else 'S9'}">This version of this provision never came into effect.</tso:status>
			</xsl:when>
			<xsl:when test="@Match = 'false'">
				<xsl:choose>
					<xsl:when test="not($pointInTimeView) and @RestrictStartDate > current-date()">
						<tso:status scenarioId="S7">This version of this provision comes into effect on <xsl:value-of select="format-date(@RestrictStartDate, '[D01]/[M01]/[Y0001]')" />.</tso:status>
					</xsl:when>
					<xsl:otherwise>
						<tso:status scenarioId="{if ($pointInTimeView) then 'S9' else 'S6'}">This version of this provision no longer has effect.</tso:status>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@RestrictEndDate">
				<tso:status>
					<xsl:attribute name="scenarioId"><xsl:choose><xsl:when test="$pointInTimeView"><xsl:choose><xsl:when test="@Concurrent = 'true' and @AltVersionRefs">S6</xsl:when><xsl:when test="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasVersion' and @title = 'prospective']">S3</xsl:when><xsl:otherwise>S4</xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise>S3</xsl:otherwise></xsl:choose></xsl:attribute>
					<xsl:if test="@Concurrent = 'true' and @AltVersionRefs">
						There are multiple versions of this provision on screen. These apply to different geographical extents.
					</xsl:if>
					<xsl:text> This version of this provision has been superseded.</xsl:text>
				</tso:status>
			</xsl:when>
			<xsl:when test="@Concurrent = 'true'">
				<tso:status scenarioId="{if ($pointInTimeView) then 'S5' else 'S3' }">
					<xsl:text>There are multiple versions of this provision on screen. These apply to different geographical extents.</xsl:text>
					<tso:extent><xsl:apply-templates select="." mode="TSOExtentLinks" /></tso:extent>
				</tso:status>
			</xsl:when>
			<xsl:when test="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasVersion' and @title = 'prospective']">
				<tso:status scenarioId="S2">Prospective version(s) available.</tso:status>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*" mode="TSOStatusMessage" as="element(tso:status)?">
		<xsl:choose>
			<xsl:when test="$pointInTimeView and 
									$version castable as xs:date and 
									exists(.//*[@RestrictStartDate castable as xs:date and xs:date(@RestrictStartDate) &gt; xs:date($version)])">
					<tso:status scenarioId="S11">This version of this <xsl:apply-templates select="." mode="TSOStatusMessageXXX"/> contains provisions that are not valid for this point in time.</tso:status>				
			</xsl:when>			
			<xsl:when test="exists(.//*[@Status = 'Prospective'])">
				<tso:status scenarioId="S1">This version of this <xsl:apply-templates select="." mode="TSOStatusMessageXXX"/> contains provisions that are prospective.</tso:status>
			</xsl:when>
			<xsl:when test="not($pointInTimeView) and exists(.//*[@Match = 'false' and @RestrictStartDate > current-date()])">
				<tso:status scenarioId="S8">This version of this <xsl:apply-templates select="." mode="TSOStatusMessageXXX"/> contains provisions that have not yet come into effect.</tso:status>
			</xsl:when>
			<xsl:when test="exists(.//*[@Match='false'])">
				<!-- Issue U439: Only displaying ' no longer has effect' message at Act, Part, Chapter, Sch. Crossheading levels when all the child elements are repealed-->			
				<xsl:if test="(every $child in (* except (leg:Number, leg:Title))
									satisfies ($child/@Match = 'false' and $child/@RestrictEndDate and not($child/@Status = 'Prospective'))
								   )
								  or  
								  (self::leg:Schedule and 
												  (
													  (@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective')) 
													  or 
													  (every $child in (leg:ScheduleBody/*)
														  satisfies ($child/@Match = 'false' and $child/@RestrictEndDate and not($child/@Status = 'Prospective'))
													  )
												  )
								 )">
					<tso:status scenarioId="{if ($pointInTimeView) then 'S9' else 'S6'}">
						<xsl:text>This version of this </xsl:text><xsl:apply-templates select="." mode="TSOStatusMessageXXX"/>
						<xsl:text> no longer has effect.</xsl:text>
					</tso:status>						
				</xsl:if>
				<!--
				<tso:status scenarioId="{if ($pointInTimeView) then 'S9' else 'S6'}">This version of this <xsl:apply-templates select="." mode="TSOStatusMessageXXX"/>
					<xsl:choose>
						<xsl:when test="exists(.//*[@RestrictEndDate and @Match = 'false' and not(@Status = 'Prospective')])">
							<xsl:text> contains provisions that no longer have effect.</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> no longer has effect.</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</tso:status>-->
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="leg:Legislation | leg:Body" mode="TSOStatusMessageXXX">
		<xsl:value-of select="tso:GetCategory($ndsLegislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value)"/>
	</xsl:template>
	<xsl:template match="leg:Part" mode="TSOStatusMessageXXX">part</xsl:template>
	<xsl:template match="leg:Schedule" mode="TSOStatusMessageXXX">schedule</xsl:template>
	<xsl:template match="leg:Pblock" mode="TSOStatusMessageXXX">cross heading</xsl:template>
	<xsl:template match="leg:Chapter" mode="TSOStatusMessageXXX">chapter</xsl:template>
	<xsl:template match="*" mode="TSOStatusMessageXXX"/>
	
	<xsl:template match="*" mode="TSOExtentLinks" as="element(xhtml:a)+">
		<xsl:variable name="results" as="element(xhtml:a)+">
			<xsl:apply-templates select="." mode="TSOExtentLink" />
			<xsl:if test="ancestor-or-self::*[@VersionReplacement = 'True']/@Concurrent = 'true'">
				<xsl:variable name="extent" select="substring-before(ancestor-or-self::*[@VersionReplacement = 'True']/@VersionReference, ' ')" />
				<xsl:apply-templates select="." mode="TSOExtentLink">
					<xsl:with-param name="extent" select="$extent" />
				</xsl:apply-templates>
			</xsl:if>
			<xsl:if test="ancestor-or-self::*/@Concurrent = 'true'">
				<xsl:variable name="otherExtents" 
					select="key('versions', tokenize(ancestor-or-self::*[@AltVersionRefs][1]/@AltVersionRefs, ' '), root())/*" />
				<xsl:apply-templates select="$otherExtents" mode="TSOExtentLink" />
			</xsl:if>
		</xsl:variable>
		<xsl:for-each select="$results">
			<xsl:sort select="contains(@href, 'E')" order="descending" />
			<xsl:sort select="contains(@href, 'W')" order="descending" />
			<xsl:sort select="contains(@href, 'S')" order="descending" />
			<xsl:sequence select="." />
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="*" mode="TSOExtentLink">
		<xsl:param name="extent" as="xs:string" select="(ancestor-or-self::*[@RestrictExtent][1]/@RestrictExtent, 'E+W+S+N.I.')[1]"/>
		<xsl:variable name="extentsToken" select="tokenize($extent, '\+')" />
		<a href="#extent-{translate($extent, '+', '-')}">
			<span class="LegExtentRestriction" title="Applies to {tso:extentDescription($extentsToken)}">
				<span class="btr"></span>
				<xsl:value-of select="$extent"/>
				<span class="bbl"></span>
				<span class="bbr"></span>
			</span>
			<xsl:text> - </xsl:text>
			 <span class="description"><xsl:value-of select="tso:extentDescription($extentsToken)" /> extent</span>
		</a>
	</xsl:template>

	
	<!-- ========== Getting the current section name ==== -->
	<xsl:template match="*" mode="CurrentSectionName"/>
	<xsl:template match="*[leg:Pnumber]" mode="CurrentSectionName" priority="5">
		<!-- Create the relevant 'Section' or 'Subsection' or 'Subsubsection' -->
		<xsl:text>S</xsl:text>
		<xsl:for-each select="ancestor-or-self::*[leg:Pnumber]">
			<xsl:choose>
				<xsl:when test="position() = last()">ection </xsl:when>
				<xsl:otherwise>ubs</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:value-of select="leg:Pnumber" />
	</xsl:template>
	
	<xsl:template match="*[leg:Number]" mode="CurrentSectionName" priority="3">
		<xsl:value-of select="leg:Number" />
	</xsl:template>
	<xsl:template match="*[leg:Title]" mode="CurrentSectionName" priority="2">
		<xsl:value-of select="leg:Title" />
	</xsl:template>
	<xsl:template match="*[leg:TitleBlock]" mode="CurrentSectionName" priority="1">
		<!-- This will pick up the Title from the TitleBlock -->
		<xsl:apply-templates select="leg:TitleBlock" mode="CurrentSectionName" />
	</xsl:template>	
	<xsl:template match="leg:Pblock" mode="CurrentSectionName" priority="3">
		<xsl:text>Cross Heading: </xsl:text><xsl:next-match/>
	</xsl:template>	

	<!-- ========== Useful functions for the UI ========= -->

	<xsl:function name="leg:IsTOC" as="xs:boolean">
		<xsl:sequence select="$paramsDoc/parameters/view ='contents' "/>
	</xsl:function>

	<xsl:function name="leg:IsContent" as="xs:boolean">
		<xsl:sequence select="$paramsDoc/parameters/section !='' or $paramsDoc/parameters/view = ('title', 'body', 'schedules', 'introduction', 'signature', 'note', 'earlier-orders') or not(exists($paramsDoc))"/>
	</xsl:function>

	<xsl:function name="leg:FormatURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:sequence select="leg:FormatURL($url, true())" />
	</xsl:function>

	<xsl:function name="leg:FormatURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:param name="addQueryString" as="xs:boolean" />
		<xsl:sequence select="substring-after($url,'http://www.legislation.gov.uk')"/>
	</xsl:function>

	<xsl:function name="leg:IsRevisedVersionExists" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentStatus/@Value = 'revised'
				  or $legislation/leg:Legislation/ukm:Metadata/atom:link/@title='current'
				  or $legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised]"/>
	</xsl:function>

	<xsl:function name="leg:IsCurrentRevised" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentStatus/@Value = 'revised'
			or ($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised] and $paramsDoc/parameters/version/normalize-space(.) = '')"/>
	</xsl:function>

	<xsl:function name="leg:IsCurrentOriginal" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/dc:publisher != 'Statute Law Database' and
			not($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised] and $paramsDoc/parameters/version/normalize-space(.) = '')"/>
	</xsl:function>

	<xsl:function name="leg:IsEnactedExists" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentStatus/@Value = 'final' or exists($legislation/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasVersion' and @title = ('enacted', 'made', 'created')])"/>
	</xsl:function>

	<xsl:function name="leg:IsWelshExists" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="leg:IsCurrentWelsh($legislation) or 
												$legislation/leg:Legislation/ukm:Metadata/atom:link[@rel= ('alternate','http://purl.org/dc/terms/hasVersion') and @hreflang='cy']"/>
	</xsl:function>	
	
	<xsl:function name="leg:IsCurrentWelsh" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="ends-with($legislation/leg:Legislation/ukm:Metadata/dc:identifier, '/welsh')"/>
	</xsl:function>
	
	<xsl:function name="leg:IsDraft" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="contains($legislation/leg:Legislation/ukm:Metadata/ukm:*/ukm:DocumentClassification/ukm:DocumentMainType/@Value, 'Draft')" />
	</xsl:function>

	<xsl:function name="leg:isFromWestlaw" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()" />
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/dc:publisher = 'Westlaw'" />
	</xsl:function>

	<xsl:function name="leg:IsLegislationWeRevise" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value
			= ('UnitedKingdomPublicGeneralAct', 'UnitedKingdomLocalAct', 'GreatBritainAct', 'EnglandAct', 'ScottishOldAct', 'ScottishAct', 
			'IrelandAct', 'NorthernIrelandParliamentAct', 'NorthernIrelandAssemblyMeasure', 'NorthernIrelandAct',
			'UnitedKingdomChurchMeasure', 'WelshAssemblyMeasure', 'WelshNationalAssemblyAct','NorthernIrelandOrderInCouncil',
			'UnitedKingdomStatutoryInstrument','ScottishStatutoryInstrument', 'WelshStatutoryInstrument', 'NorthernIrelandStatutoryRule' )"/>
	</xsl:function>

	<xsl:function name="leg:IsOustandingEffectExists" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="count($legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata)/ukm:UnappliedEffects) > 0"/>
	</xsl:function>
	
	<xsl:function name="leg:IsPDFOnly" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="not(exists($legislation/leg:Legislation/* except $legislation/leg:Legislation/ukm:Metadata)) and exists($legislation/leg:Legislation/ukm:Metadata/atom:link[@rel='alternate' and @title='PDF'])"/>
	</xsl:function>
	
	<xsl:function name="leg:IsPDFOnlyNotRevised" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="not(exists($legislation/leg:Legislation/* except $legislation/leg:Legislation/ukm:Metadata)) and not(exists($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised])) and exists($legislation/leg:Legislation/ukm:Metadata/atom:link[@rel='alternate' and @title='PDF'])"/>
	</xsl:function>
	
	<xsl:function name="leg:IsRevisedPDFOnly" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
			<xsl:sequence select="exists($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised]) and empty($legislation/leg:Legislation/(leg:Primary|leg:Secondary))"/>
	</xsl:function>
	
	
	<xsl:function name="leg:IsProposedVersion" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentStatus/@Value = 'proposed'"/>
	</xsl:function>
	
	<xsl:function name="leg:IsRevision" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()" />
		<xsl:sequence select="exists($legislation/leg:Legislation/ukm:Metadata/ukm:Revisions)" />
	</xsl:function>
	
	<xsl:function name="leg:IsCheckedOut" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()" />
		<xsl:sequence select="exists($legislation/leg:Legislation/ukm:Metadata/ukm:Checkout)" />
	</xsl:function>

	<xsl:function name="leg:GetCodeSchemaStatus" as="xs:string">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:variable name="documentType" select="$legislation/leg:Legislation/ukm:Metadata//ukm:DocumentMainType/@Value"/>
		<xsl:choose>
			<xsl:when test="count($g_nstCodeLists[@name = 'DocumentMainType']/Code[@schema = $documentType and @status!='revised']) > 0">
				<xsl:value-of select="$g_nstCodeLists[@name = 'DocumentMainType']/Code[@schema = $documentType and @status!='revised'][1]/@status"/>
			</xsl:when>
			<xsl:otherwise>enacted</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="leg:FormatDate" as="xs:string">
		<xsl:param name="dtvalue" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="$dtvalue castable as xs:date">
				<xsl:sequence select="format-date(xs:date($dtvalue), '[D01]/[M01]/[Y0001]')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="concat(upper-case(substring($dtvalue, 1, 1)), substring($dtvalue, 2))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	


</xsl:stylesheet>
