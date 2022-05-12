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
	<xsl:import href="legislation_global_variables.xslt"/>

	<xsl:include href="unapplied_effects_xhtml_core.xsl"/>
	<xsl:include href="legislation_xhtml_utilities_dates.xslt"/>


	<xsl:variable name="g_nstCodeLists" select="document('../../codelists.xml')/CodeLists/CodeList"/>

	<xsl:variable name="ndsLegislation" select="/leg:Legislation"/>

	<xsl:variable name="status-legtitle"
				select="if ($dcalternative) then $dcalternative else $dctitle"/>

	<xsl:key name="versions" match="leg:Version" use="@id"/>

	<!-- input parameter doc -->
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>
	<!--  let $version be the value of the version parameter coming through Orbeon  -->
	<xsl:variable name="version" as="xs:string" select="($paramsDoc/parameters/version, '')[1]"/>
	<!--  let $pointInTimeView be true if $version is either castable to a date or the value 'prospective' -->
	<xsl:variable name="pointInTimeView" as="xs:boolean" select="($version castable as xs:date) or $version = 'prospective' "/>
	<!-- let $type be the type of legislation -->
	<xsl:variable name="type" as="xs:string" select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>
	<!-- let $baseDate be the base date for the type of legislation -->
	<xsl:variable name="baseDate" as="xs:string" select="string(leg:base-date($type))"/>

	<!-- getting the scenario -->
	<xsl:template name="TSOGetScenarios">
		<xsl:param name="type"/>

		<xsl:choose>
			<xsl:when test="leg:IsLegislationWeRevise(.) ">
				<xsl:choose>
					<xsl:when test="leg:IsRevisedVersionExists(.)">
						<xsl:choose>
							<xsl:when test="leg:IsOutstandingEffectExists(.)">
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
		<xsl:variable name="IsEditedByEPP" select="leg:IsEditedByEPP(.)" />
		<xsl:variable name="sectionTitle">
			<xsl:choose>
				<xsl:when test="$nstSelectedSection"><xsl:apply-templates select="$nstSelectedSection" mode="CurrentSectionName" /></xsl:when>
				<xsl:when test="$g_strIntroductionUri = $dcIdentifier">
					<xsl:value-of select="leg:TranslateText('Introductory Text')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		
		<xsl:if test="not($g_strDocumentMainType = ('EuropeanUnionDirective', 'EuropeanUnionTreaty', 'UnitedKingdomChurchInstrument', 'UnitedKingdomMinisterialDirection', 'UnitedKingdomMinisterialOrder', 'UnitedKingdomStatutoryRuleOrOrder', 'NorthernIrelandStatutoryRuleOrOrder')) ">
			<xsl:call-template name="TSOOutputStatusMessage">
				<xsl:with-param name="includeTooltip" select="$includeTooltip"/>
			</xsl:call-template>
		</xsl:if>

		<div>
			<xsl:choose>
				<!-- EU treaty messages -->
				<xsl:when test="$g_isEUtreaty and not(leg:IsEUPDFOnlyNotRevised(.))">
					<xsl:attribute name="id">infoSection</xsl:attribute>
					<h2>
            <xsl:value-of select="leg:TranslateText('swhead_status')"/>
          </h2>
					<p class="intro">
						<xsl:choose>
							<xsl:when test="leg:IsCurrentRevised(.)">
								<xsl:sequence select="leg:revisedTreatyText($g_strDocumentName, leg:FormatDate(leg:legislationStartDate(.)))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(leg:TranslateText('status_waring_original_version'),'.')"/>
							</xsl:otherwise>
						</xsl:choose>
					</p>
				</xsl:when>
				<!-- EU directives messages -->
				<xsl:when test="$g_strDocumentMainType = 'EuropeanUnionDirective'  and $g_strDocumentStatus = 'revised'">
					<xsl:attribute name="id">infoSection</xsl:attribute>
					<h2>
            			<xsl:value-of select="leg:TranslateText('statuswarning_revised_eudirective_head')"/>
          			</h2>
					<p class="intro">
						<xsl:value-of select="leg:TranslateText('statuswarning_revised_eudirective_body')"/>
					</p>
				</xsl:when>
				<!-- EU PDF only data that has unapplied effects should allow these to be shown -->
				<xsl:when test="leg:IsRevisedEUPDFOnly(.) and leg:IsOutstandingEffectExists(.)">
					<xsl:attribute name="id">statusWarning</xsl:attribute>
					<div class="title">
						<h2>
						  <xsl:value-of select="leg:TranslateText('statuswarning_changes_with_effects_head')"/>
						</h2>
						<p class="intro">
							<xsl:value-of select="leg:TranslateText('statuswarning_changes_with_effects_content_p1')"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$status-legtitle"/>
							<xsl:text>. </xsl:text>
							<xsl:value-of select="leg:TranslateText('statuswarning_changes_with_effects_content_p2')"/>
						</p>
						<xsl:call-template name="processEffects">
							<xsl:with-param name="includeTooltip" select="$includeTooltip" tunnel="yes"/>
							<xsl:with-param name="IsRevisedEUPDFOnly" select="leg:IsRevisedEUPDFOnly(.)" tunnel="yes"/>
						</xsl:call-template>
					</div>
				</xsl:when>
				<xsl:when test="leg:IsRevisedEUPDFOnly(.)">
					<xsl:attribute name="id">statusWarning</xsl:attribute>
					<xsl:attribute name="class">uptoDate</xsl:attribute>
					<div class="title">
						<h2>
						  <xsl:value-of select="leg:TranslateText('swhead_changes_to_legislation')"/>
						</h2>
						<p class="intro">
							<xsl:value-of select="leg:TranslateText('swcontent_tocmsg_eupdf_p1')"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$status-legtitle"/>
							<xsl:text>. </xsl:text>
							<xsl:value-of select="leg:TranslateText('swcontent_tocmsg_eupdf_p2')"/>
						</p>
					</div>
				</xsl:when>
				<!-- EU PDF adopted only data that has unapplied effects should allow these to be shown -->
				<xsl:when test="leg:IsEUPDFOnlyNotRevised(.) and leg:IsOutstandingEffectExists(.)">
					<xsl:attribute name="id">infoSection</xsl:attribute>
					<div class="title">
						<h2><xsl:value-of select="leg:TranslateText('infoSection_head')"/> </h2>
						<p class="intro">
							<xsl:value-of select="leg:TranslateText('infoSection_content')"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$status-legtitle"/>
							<xsl:text>.</xsl:text>
						</p>
						<p class="c2a">
							<a href="{if($TranslateLangPrefix='/cy') then $TranslateLangPrefix else ''}/changes/unapplied/affected/{$g_strShortType}/{$g_strDocumentYear}/{$g_strDocumentNumber}">
								<xsl:value-of select="leg:TranslateText('infoSection_actionlink')"/>
							</a>
						</p>
					</div>
				</xsl:when>
				<xsl:when test="leg:IsEUPDFOnlyNotRevised(.)">
					<xsl:attribute name="id">infoSection</xsl:attribute>
					<h2>
						<xsl:value-of select="leg:TranslateText('swhead_status')"/>
					</h2>
					<p class="intro">
						 <xsl:value-of select="leg:TranslateText('swcontent_revisedpdf')"/>
					</p>
				</xsl:when>
				<xsl:when test="(not(leg:IsPDFOnlyNotRevised(.)) and ($Scenario = '1' or  $Scenario = '5' or leg:IsCurrentRevised(.)) )">
					<xsl:attribute name="id">statusWarning</xsl:attribute>
					<xsl:attribute name="class"><xsl:if test="($Scenario = '1' or ($Scenario = '5' and $IsEditedByEPP and leg:IsOutstandingEffectsOnlyProspectiveOrFutureDate(.))) and empty($g_powerToAmend)">uptoDate</xsl:if></xsl:attribute>

					<xsl:if test="leg:isFromWestlaw(.)">
						<div class="title">
						<h2>
						  <xsl:value-of select="leg:TranslateText('swhead_status')"/>
						</h2>
						<p class="intro">
						<xsl:value-of select="concat(' ',leg:TranslateText('status_warning_revised_is_from_westlaw_pt1'))"/>
						<a href="/contributors#westlaw" class="more"><strong><xsl:value-of select="leg:TranslateText('Read more')"/></strong></a>
						</p>
						</div>
					</xsl:if>

					<div class="title">
						<h2>
						  <xsl:value-of select="leg:TranslateText('swhead_changes_to_legislation')"/>
						</h2>
						<p class="intro">

							<xsl:choose>
								<!--<xsl:when test="leg:IsRevisedEUPDFOnly(.)">
										<xsl:variable name="reviseddate" as="xs:date" select="max(for $d in ($ndsLegislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised castable as xs:date]/@Revised) return xs:date($d))"/>
										<xsl:text>This item of legislation is only available to download and view as PDF. There may be outstanding changes yet to be applied. This version incorporates changes up to </xsl:text>
										<xsl:value-of select="if (exists($reviseddate)) then format-date($reviseddate,'[D]/[M]/[Y]') else 'DD/MM/YYYY'"/>
										<xsl:text>.</xsl:text>
								</xsl:when>-->
								<xsl:when test="leg:IsRevisedPDFOnly(.)">
										<xsl:variable name="reviseddate" as="xs:date" select="max(for $d in ($ndsLegislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised castable as xs:date]/@Revised) return xs:date($d))"/>
										<xsl:value-of select="leg:TranslateText('swcontent_revisedpdf')"/>
										<xsl:text> The electronic revised (latest available) version of the </xsl:text>
										<xsl:value-of select="$status-legtitle"/>
										<xsl:text> has been created and contributed by the Department for Work and Pensions.</xsl:text>
										<!--<a href="http://www.legislation.gov.uk/contributors#dwp"><strong> Read more.</strong></a>-->
										<xsl:text> There may be outstanding changes yet to be applied. This version incorporates changes up to </xsl:text>
										<xsl:value-of select="if (exists($reviseddate)) then format-date($reviseddate,'[D]/[M]/[Y]') else 'DD/MM/YYYY'"/>
										<xsl:text>.</xsl:text>
								</xsl:when>
								<xsl:when test="$Scenario = '1'">
									<xsl:value-of select="leg:TranslateText('no_outstanding_effects')"/><xsl:text> </xsl:text>
									<xsl:value-of select="$status-legtitle"/>
									<xsl:if test="string-length($sectionTitle) ne 0">
										<xsl:value-of select="concat(', ', $sectionTitle)"/>
									</xsl:if>
									<xsl:text>.</xsl:text>
								</xsl:when>
								<xsl:when test="$Scenario = '5'">
									<xsl:choose>
										<xsl:when test="$IsEditedByEPP and leg:IsOutstandingEffectsOnlyProspectiveOrFutureDate(.)">
											<xsl:choose>
												<!-- status_warning_effects_pt1 -->
												<xsl:when test="leg:IsTOC()">
													<xsl:value-of select="$status-legtitle"/>
													<xsl:value-of select="concat(' ',leg:TranslateText('status_warning_effects_pt1'),' ')"/>
													<xsl:call-template name="TranslateLongDate">
														<xsl:with-param name="strInputDate" select="xs:string(current-date())" as="xs:string"/>
													</xsl:call-template>
													<xsl:value-of select="concat('. ',leg:TranslateText('status_warning_effects_pt2'),'.')"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$status-legtitle"/>
													<xsl:if test="string-length($sectionTitle) ne 0">
														<xsl:value-of select="concat(', ', $sectionTitle)"/>
													</xsl:if>
													<xsl:value-of select="concat(' ',leg:TranslateText('status_warning_effects_pt1'),' ')"/>
													<xsl:call-template name="TranslateLongDate">
														<xsl:with-param name="strInputDate" select="xs:string(current-date())" as="xs:string"/>
													</xsl:call-template>
													<xsl:value-of select="concat('. ',leg:TranslateText('status_warning_effects_pt2'),'.')"/>
													<xsl:value-of select="concat(' ',leg:TranslateText('status_warning_effects_pt3'),'.')"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:when test="leg:IsEURetained(.)">
											<xsl:value-of select="leg:TranslateText('statuswarning_euretained_p1')"/>
											<xsl:text> </xsl:text>
											<xsl:value-of select="$status-legtitle"/>
											<xsl:text>.</xsl:text>
											<xsl:if test="leg:IsTOC()">
												<xsl:text> </xsl:text>
												<xsl:value-of select="leg:TranslateText('status_warning_eu_retained_p_toc')"/>
											</xsl:if>
											<xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('statuswarning_euretained_p2')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="leg:TranslateText('swcontent_tocmsg_p1')"/>
											<xsl:text> </xsl:text>
											<xsl:value-of select="$status-legtitle"/>
											<xsl:text>.</xsl:text>
											<!-- The reason for this is that people are seeing this message and wanting to immediately go to the Tables of Effects (now the Changes to Legislation) when really they would be much better off looking at the effects within the Act. -->
											<xsl:if test="leg:IsTOC()">
												<xsl:text> </xsl:text>
												<xsl:value-of select="leg:TranslateText('swcontent_tocmsg_p2')"/>
											</xsl:if>
											<xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('swcontent_tocmsg_p3')"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>

							</xsl:choose>

							<xsl:if test="string-length ($Scenario) > 0 and $includeTooltip">
								<a href="#Scenario{$Scenario}Help" class="helpItem helpItemToBot">
									<img src="/images/chrome/helpIcon.gif" alt=" Help about Changes to Legislation"/>
								</a>
							</xsl:if>
						</p>

						<xsl:sequence select="leg:formatPowerToAmendText($g_powerToAmend)"/>

							<xsl:if test="$includeTooltip">
								<!-- adding the help tooltip-->
								<xsl:call-template name="TSOOutputStatusHelpTip">
									<xsl:with-param name="scenarioId" select="$Scenario"/>
									<xsl:with-param name="helpTitle">Changes to Legislation</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							<!-- adding the unapplied effects if there are oustanding changes and we are in the content tab -->
							<xsl:if test="($Scenario = '5' and leg:IsContent() and not($pointInTimeView and $version != 'prospective'))">
								<xsl:call-template name="processEffects">
									<xsl:with-param name="includeTooltip" select="$includeTooltip" tunnel="yes"/>
									<xsl:with-param name="IsEURetained" select="leg:IsEURetained(.)" tunnel="yes"/>
								</xsl:call-template>
							</xsl:if>
					</div>
				</xsl:when>

				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="leg:IsDraft(.) and /leg:Legislation/ukm:Metadata/ukm:BillMetadata">
							<xsl:attribute name="id">infoDraft</xsl:attribute>
							<h2><xsl:value-of select="leg:TranslateText('Draft Bill')" />:</h2>
						</xsl:when>
						<xsl:when test="leg:IsDraft(.)">
							<xsl:attribute name="id">infoDraft</xsl:attribute>
							<h2><xsl:value-of select="leg:TranslateText('Draft Legislation')" />:</h2>
						</xsl:when>
						<xsl:when test="leg:IsProposedVersion(.)">
							<xsl:attribute name="id">infoProposed</xsl:attribute>
							<h2><xsl:value-of select="leg:TranslateText('Proposed Legislation')" />:</h2>
						</xsl:when>

						<xsl:otherwise>
							<xsl:attribute name="id">infoSection</xsl:attribute>
							<h2>
								<xsl:value-of select="leg:TranslateText('swhead_status')"/>
							 </h2>
						</xsl:otherwise>
					</xsl:choose>
					<p class="intro">
						<xsl:choose>
							<xsl:when test="(leg:IsDraft(.) or leg:IsProposedVersion(.)) and $g_strDocumentMainType = 'UnitedKingdomDraftPublicBill'" >
								<xsl:text> </xsl:text>
								<xsl:value-of select="leg:TranslateText('status_warning_intro_draft_bill_item') " />
							</xsl:when>
							<xsl:when test="leg:IsProposedVersion(.)">
								<strong><xsl:value-of select="/leg:Legislation/ukm:Metadata/dct:alternative" /></strong>
								<xsl:text> </xsl:text>
								<xsl:value-of select="leg:TranslateText('status_warning_intro_proposed_version')"/>
							</xsl:when>
							<xsl:when test="leg:IsDraft(.)">
								<xsl:value-of select="leg:TranslateText('status_warning_intro_draft_legislation')"/>
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
										<xsl:value-of select="concat('. ',leg:TranslateText('This draft has since been made as a'),' ')"/>
										<xsl:value-of select="tso:GetSingularTitleFromType(tso:GetTypeFromDraftType($g_strDocumentMainType,''),'')"/>
										<xsl:text>: </xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat(' ',leg:TranslateText('and has not yet been made as a'),' ')"/>
										<xsl:value-of select="tso:GetSingularTitleFromType(tso:GetTypeFromDraftType($g_strDocumentMainType,''),'')"/>
										<xsl:text>. </xsl:text>
										<xsl:if test="exists(/leg:Legislation/ukm:Metadata/ukm:SupersededBy)">
											<xsl:value-of select="concat(leg:TranslateText('This draft has been replaced by a new draft'),', ')"/>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/ukm:SupersededBy" mode="statuswarning"/>
								<xsl:if test="leg:IsPDFOnly(.)">
									<xsl:text>. </xsl:text>
									<xsl:value-of select="leg:TranslateText('item_available_as_pdf_only')"/>
								</xsl:if>
							</xsl:when>
							<xsl:when test="leg:IsPDFOnly(.)">
								<xsl:value-of select="leg:TranslateText('item_available_as_pdf_only')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> </xsl:text>
								<xsl:value-of select="leg:TranslateText('status_warning_original_version',(concat('type=',leg:GetCodeSchemaStatus(.))))" />
								<xsl:if test="$Scenario = '2' or $Scenario = '3'">
									<xsl:value-of select="leg:TranslateText(concat('status_warning_original_version',$Scenario))" />
								</xsl:if>
								<xsl:text>.</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="leg:isFromWestlaw(.)">
							<xsl:value-of select="concat(' ',leg:TranslateText('status_warning_is_from_westlaw_pt1'))"/>
							<xsl:value-of select="concat(' ',tso:GetSingularTitleFromType($g_strDocumentMainType,''),' ')" />
							<xsl:value-of select="concat(leg:TranslateText('status_warning_is_from_westlaw_pt2'),'. ')"/>
							<a href="/contributors#westlaw" class="more"><strong><xsl:value-of select="leg:TranslateText('Read more')"/></strong></a>
						</xsl:if>
					</p>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template name="TranslateLongDate">
		<xsl:param name="strInputDate" select="''"/>
		<xsl:variable name="longDateString">
			<xsl:call-template name="FormatLongDate">
				<xsl:with-param name="strInputDate" select="$strInputDate" as="xs:string"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="tokenizedDate" select="tokenize($longDateString,' ')"/>
		<xsl:value-of select="string-join(($tokenizedDate[1],leg:TranslateText($tokenizedDate[2]),$tokenizedDate[3]),' ')"/>
	</xsl:template>

	<xsl:template name="processEffects">
		<xsl:param name="includeTooltip"  select="false()" as="xs:boolean"/>
		<xsl:param name="IsEURetained" as="xs:boolean" tunnel="yes" select="false()"/>
		<xsl:param name="IsRevisedEUPDFOnly" as="xs:boolean" tunnel="yes" select="false()"/>
		<xsl:variable name="ndsFilterUnappliedEffects">
			<xsl:apply-templates select="leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata|ukm:EUMetadata)/ukm:UnappliedEffects" mode="filterUnappliedEffects">
				<xsl:with-param name="includeTooltip" select="$includeTooltip" tunnel="yes"/>
				<xsl:with-param name="IsEURetained" select="$IsEURetained" tunnel="yes"/>
				<xsl:with-param name="IsRevisedEUPDFOnly" tunnel="yes" select="$IsRevisedEUPDFOnly"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:if test="exists($ndsFilterUnappliedEffects/*)">
			<a href="#statusWarningSubSections">
        <xsl:attribute name="class">
				  <xsl:value-of select="if ($IsRevisedEUPDFOnly) then 'expandCollapseLink js-IsRevisedEUPDFOnly' else 'expandCollapseLink'"/>
        </xsl:attribute>
        View outstanding changes
				<!-- <xsl:value-of select="if ($IsRevisedEUPDFOnly) then 'View changes' else 'View outstanding changes'"/> -->
			</a>
			<div id="statusWarningSubSections">
				<xsl:copy-of select="$ndsFilterUnappliedEffects/*"/>
			</div>
			<span/>
		</xsl:if>
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
					<xsl:when test="$version = 'prospective'"><xsl:value-of select="leg:TranslateText('status_warning_PiT_ prospective')"/>.</xsl:when>
					<xsl:when test="$version castable as xs:date"><xsl:value-of select="concat(leg:TranslateText('status_warning_PiT_at'),' ')"/><xsl:value-of select="leg:FormatDate($version)"/>. </xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="exists($status) or string-length($pointInTimeText) > 0">
				<!-- displaying the Status message -->
				<div id="infoSection">
					<h2>
            <xsl:value-of select="leg:TranslateText('swhead_status')"/>
          </h2>
					<p class="intro">
						<xsl:value-of select="$pointInTimeText"/>
						<xsl:sequence select="$status/node()[not(self::tso:extent)]" />
						<xsl:if test="$includeTimeline">
							<xsl:choose>
								<xsl:when test="$status/@scenarioId = 'S2' ">
									<xsl:text> </xsl:text>
									<a href="?timeline=true"><xsl:value-of select="leg:TranslateText('status_warning_PiT_timeline_changes_p1')"/></a>
								</xsl:when>
								<xsl:when test="$status/@scenarioId = xs:string( if ($pointInTimeView) then ('S9') else ('S6') )">
									<xsl:text> </xsl:text>
									<a href="?timeline=true"><xsl:value-of select="leg:TranslateText('status_warning_PiT_timeline_changes_p1')"/></a>
									<xsl:value-of select="concat(' ',leg:TranslateText('status_warning_PiT_timeline_changes_p1_1'))"/>
								</xsl:when>
								<xsl:when test="$status/@scenarioId = (if ($pointInTimeView) then 'S12' else 'S9')">
									<xsl:text> </xsl:text>
									<a href="?timeline=true"><xsl:value-of select="leg:TranslateText('status_warning_PiT_timeline_changes_p1')"/></a>
									<xsl:value-of select="concat(' ',leg:TranslateText('status_warning_PiT_timeline_changes_p1_2'))"/>
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
							<xsl:with-param name="helpTitle"><xsl:value-of select="leg:TranslateText('Status')"/></xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$status/tso:extent">
						<div class="extentMarkerInfo">
							<h2><xsl:value-of select="leg:TranslateText('Skip to')"/>:</h2>
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
							<xsl:when test="leg:IsRevisedPDFOnly(.)">
									<p>
										<xsl:value-of select="leg:TranslateText('status_warning_revised_p1')"/><xsl:text> </xsl:text>
										<xsl:value-of select="leg:TranslateText('status_warning_revised_p2')"/>
									</p>
							</xsl:when>
							<xsl:when test="$scenarioId = '1' ">

							<p>
								<xsl:value-of select="leg:TranslateText('status_warning_revised_p1')"/><xsl:text> </xsl:text>
								<xsl:value-of select="leg:TranslateText('status_warning_revised_p3')"/><xsl:text> </xsl:text>
								<xsl:value-of select="leg:TranslateText('status_warning_revised_p4')"/>
							</p>
							</xsl:when>


							<xsl:when test="$scenarioId ='5' ">
								<xsl:choose>
									<xsl:when test="$pointInTimeView">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p5')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p6')"/>
										</p>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="leg:IsTOC() and not(leg:IsRevisedEUPDFOnly)">
												<p>
													<xsl:value-of select="leg:TranslateText('status_warning_revised_p1')"/><xsl:text> </xsl:text>
													<xsl:value-of select="leg:TranslateText('status_warning_revised_p2')"/><xsl:text> </xsl:text>
													<xsl:value-of select="leg:TranslateText('status_warning_revised_p7')"/>
												</p>
											</xsl:when>
											<xsl:otherwise>
												<p>
													<xsl:value-of select="leg:TranslateText('status_warning_revised_p1')"/><xsl:text> </xsl:text>
													<xsl:value-of select="leg:TranslateText('status_warning_revised_p2')"/><xsl:text> </xsl:text>
													<xsl:value-of select="leg:TranslateText('status_warning_revised_p8')"/><xsl:text> </xsl:text>
													<xsl:value-of select="leg:TranslateText('status_warning_revised_p9')"/>
												</p>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$scenarioId = '5'  and leg:IsTOC() and not(leg:IsRevisedEUPDFOnly(.))">
								<p>
									<xsl:value-of select="leg:TranslateText('status_warning_revised_p1')"/><xsl:text> </xsl:text>
									<xsl:value-of select="leg:TranslateText('status_warning_revised_p2')"/><xsl:text> </xsl:text>
									<xsl:value-of select="leg:TranslateText('status_warning_revised_p7')"/>
								</p>
							</xsl:when>
							<xsl:when test="$scenarioId = '5'  and (leg:IsContent() or leg:IsRevisedEUPDFOnly(.))">
								<p>
									<xsl:value-of select="leg:TranslateText('status_warning_revised_p1')"/><xsl:text> </xsl:text>
									<xsl:value-of select="leg:TranslateText('status_warning_revised_p2')"/><xsl:text> </xsl:text>
									<xsl:value-of select="leg:TranslateText('status_warning_revised_p10')"/><xsl:text> </xsl:text>
								 <xsl:value-of select="leg:TranslateText('status_warning_revised_p9')"/>
								</p>
							</xsl:when>
							<xsl:when test="$pointInTimeView">
								<xsl:choose>
									<xsl:when test="$scenarioId = 'S1' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p11')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p12')"/>
										</p>
										<ol>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12i')"/></li>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12ii')"/></li>
										</ol>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p13')"/></p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S2' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p14')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p15')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p16')"/>
										</p>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p17')"/></p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S3' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p18')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p19')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p20')"/>
										</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S4' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p18')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p21')"/>
										</p>
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p20')"/>
										</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S5' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p18')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p22')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p23')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p24')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p25')"/>
										</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S6' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p18')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p22i')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p23')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p24')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p25')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p21i')"/>
										</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S7' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p11')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p12')"/>
										</p>
										<ol>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12i')"/></li>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12ii')"/></li>
										</ol>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p26')"/></p><xsl:text> </xsl:text>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p27')"/></p><xsl:text> </xsl:text>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p28')"/></p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S8' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p11')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p23')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p24')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p25')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p29')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p17')"/>
										</p>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p28')"/></p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S9' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p18')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p30')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p31')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p32')"/>
										</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S10' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p11')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p12')"/>
										</p>
										<ol>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12i')"/></li>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12ii')"/></li>
										</ol>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p13')"/></p>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p28')"/></p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S11' ">
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p33')"/> </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S12' ">
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p34')"/> </p>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$scenarioId = 'S1' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p11')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p12')"/>
										</p>
										<ol>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12i')"/></li>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12ii')"/></li>
										</ol>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p13')"/> </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S2' ">
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p14')"/> </p>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p35')"/> </p>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p16')"/> </p>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p17')"/> </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S3' ">
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p11')"/></p>
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p23')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p24')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p25')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p36')"/>
										</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S4' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p11')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p12')"/>
										</p>
										<ol>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12i')"/></li>
											<li><xsl:value-of select="leg:TranslateText('status_warning_revised_p12ii')"/></li>
										</ol>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p26')"/> </p>
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p27')"/> </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S5' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p11')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p23')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p24')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p25')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p29')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p17')"/>
										</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S6' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p37')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p31')"/>
										</p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S7' ">
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p38')"/> </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S8' ">
										<p><xsl:value-of select="leg:TranslateText('status_warning_revised_p39')"/> </p>
									</xsl:when>
									<xsl:when test="$scenarioId = 'S9' ">
										<p>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p40')"/><xsl:text> </xsl:text>
											<xsl:value-of select="leg:TranslateText('status_warning_revised_p31')"/>
										</p>
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
				<tso:status scenarioId="S11"><xsl:value-of select="leg:TranslateText('status_warning_revised_p41')"/></tso:status>
			</xsl:when>
			<xsl:when test="@Status = 'Prospective'">
				<xsl:choose>
					<xsl:when test="@Concurrent = 'true'">
						<tso:status scenarioId="{if ($pointInTimeView) then 'S8' else 'S5'}">
							<xsl:value-of select="leg:TranslateText('status_warning_revised_p42')"/><xsl:text> </xsl:text>
							<xsl:value-of select="leg:TranslateText('status_warning_revised_p43')"/>
							<tso:extent><xsl:apply-templates select="." mode="TSOExtentLinks" /></tso:extent>
						</tso:status>
					</xsl:when>
					<xsl:when test="exists(@AltVersionRefs)">
						<tso:status scenarioId="{if ($pointInTimeView) then 'S7' else 'S4'}"><xsl:value-of select="leg:TranslateText('status_warning_revised_p42')"/></tso:status>
					</xsl:when>
					<xsl:otherwise>
						<tso:status scenarioId="{if ($pointInTimeView) then
									(if (exists(/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasVersion' and @title castable as xs:date]) )
										then  'S1'
									else 'S10')
								else 'S1'}"><xsl:value-of select="leg:TranslateText('status_warning_revised_p44')"/> </tso:status>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@Status = 'Dead'">
				<tso:status scenarioId="{if ($pointInTimeView) then 'S12' else 'S9'}"><xsl:value-of select="leg:TranslateText('status_warning_revised_p45')"/></tso:status>
			</xsl:when>
			<xsl:when test="@Match = 'false'">
				<xsl:choose>
					<xsl:when test="not($pointInTimeView) and @RestrictStartDate > current-date()">
						<tso:status scenarioId="S7"><xsl:value-of select="leg:TranslateText('status_warning_revised_p46')"/> <xsl:value-of select="format-date(@RestrictStartDate, '[D01]/[M01]/[Y0001]')" />.</tso:status>
					</xsl:when>
					<xsl:otherwise>
						<tso:status scenarioId="{if ($pointInTimeView) then 'S9' else 'S6'}"><xsl:value-of select="leg:TranslateText('status_warning_revised_p47')"/> </tso:status>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@RestrictEndDate">
				<tso:status>
					<xsl:attribute name="scenarioId"><xsl:choose><xsl:when test="$pointInTimeView"><xsl:choose><xsl:when test="@Concurrent = 'true' and @AltVersionRefs">S6</xsl:when><xsl:when test="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasVersion' and @title = 'prospective']">S3</xsl:when><xsl:otherwise>S4</xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise>S3</xsl:otherwise></xsl:choose></xsl:attribute>
					<xsl:if test="@Concurrent = 'true' and @AltVersionRefs">
						<xsl:value-of select="leg:TranslateText('status_warning_revised_p42')"/>
						<xsl:value-of select="leg:TranslateText('status_warning_revised_p43')"/>
					</xsl:if>
					<xsl:value-of select="leg:TranslateText('status_warning_revised_p49')"/> <xsl:value-of select="leg:TranslateText('status_warning_revised_p50')"/>
				</tso:status>
			</xsl:when>
			<xsl:when test="@Concurrent = 'true'">
				<tso:status scenarioId="{if ($pointInTimeView) then 'S5' else 'S3' }">
					<xsl:value-of select="leg:TranslateText('status_warning_revised_p42')"/>
					<xsl:value-of select="leg:TranslateText('status_warning_revised_p43')"/>
					<tso:extent><xsl:apply-templates select="." mode="TSOExtentLinks" /></tso:extent>
				</tso:status>
			</xsl:when>
			<xsl:when test="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasVersion' and @title = 'prospective']">
				<tso:status scenarioId="S2"><xsl:value-of select="leg:TranslateText('status_warning_revised_p48')"/></tso:status>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*" mode="TSOStatusMessage" as="element(tso:status)?">
		<xsl:choose>
			<xsl:when test="$pointInTimeView and
									$version castable as xs:date and
									exists(.//*[@RestrictStartDate castable as xs:date and xs:date(@RestrictStartDate) &gt; xs:date($version)])">
					<tso:status scenarioId="S11"><xsl:value-of select="leg:TranslateText('status_warning_revised_p49')"/> <xsl:apply-templates select="." mode="TSOStatusMessageXXX"/> <xsl:value-of select="leg:TranslateText('status_warning_revised_p51')"/></tso:status>
			</xsl:when>
			<xsl:when test="exists(.//*[@Status = 'Prospective'])">
				<tso:status scenarioId="S1"><xsl:value-of select="leg:TranslateText('status_warning_revised_p49')"/> <xsl:apply-templates select="." mode="TSOStatusMessageXXX"/> <xsl:value-of select="leg:TranslateText('status_warning_revised_p52')"/></tso:status>
			</xsl:when>
			<xsl:when test="not($pointInTimeView) and exists(.//*[@Match = 'false' and @RestrictStartDate > current-date()])">
				<tso:status scenarioId="S8"><xsl:value-of select="leg:TranslateText('status_warning_revised_p49')"/> <xsl:apply-templates select="." mode="TSOStatusMessageXXX"/> <xsl:value-of select="leg:TranslateText('status_warning_revised_p53')"/></tso:status>
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
						<xsl:value-of select="leg:TranslateText('status_warning_revised_p49')"/>
						<xsl:apply-templates select="." mode="TSOStatusMessageXXX"/>
						<xsl:text> no longer has effect.</xsl:text>
					</tso:status>
				</xsl:if>
				<!--
				<tso:status scenarioId="{if ($pointInTimeView) then 'S9' else 'S6'}"><xsl:value-of select="leg:TranslateText('status_warning_revised_p49')"/> <xsl:apply-templates select="." mode="TSOStatusMessageXXX"/>
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
	<xsl:template match="leg:Legislation | leg:Body | leg:EUBody" mode="TSOStatusMessageXXX">
		<xsl:value-of select="tso:GetCategory($ndsLegislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value)"/>
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
		<xsl:param name="extent" as="xs:string" select="tso:resolveExtentFormatting((ancestor-or-self::*[@RestrictExtent][1]/@RestrictExtent, 'E+W+S+N.I.')[1])"/>
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
		<!-- if ancestor had 'schedule' then it is 'Paragraph', else relevant 'Section', both with 'SubX', 'SubsubX' etc options -->
		<xsl:variable name="sectionType">
			<xsl:if test="not($g_isEURetainedOrEUTreaty)">
				<xsl:for-each select="ancestor-or-self::*[leg:Pnumber]">
					<xsl:choose>
						<xsl:when test="position() != last()">sub</xsl:when>
						<xsl:when test="ancestor::*[leg:Schedule]">paragraph </xsl:when>
						<xsl:otherwise>section </xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="concat(upper-case(substring($sectionType, 1, 1)), substring($sectionType, 2),leg:Pnumber)" />
	</xsl:template>

	<xsl:template match="leg:Division[leg:Number]" mode="CurrentSectionName" priority="13">
		<xsl:value-of select="concat(leg:DivisionName(.), ' ', leg:Number)" />
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
		<xsl:text>Cross Heading: </xsl:text>
		<xsl:next-match/>
	</xsl:template>

	<!-- ========== Useful functions for the UI ========= -->

	<xsl:function name="leg:IsTOC" as="xs:boolean">
		<xsl:sequence select="$paramsDoc/parameters/view ='contents'"/>
	</xsl:function>

	<xsl:function name="leg:IsContent" as="xs:boolean">
		<xsl:sequence select="$paramsDoc/parameters/section !='' or $paramsDoc/parameters/view = ('title', 'body', 'schedules', 'introduction', 'signature', 'note', 'earlier-orders', 'annexes', 'attachments') or not(exists($paramsDoc))"/>
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
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata|ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentStatus/@Value = 'revised'
				  or $legislation/leg:Legislation/ukm:Metadata/atom:link/@title='current'
				  or $legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised]"/>
	</xsl:function>

	<xsl:function name="leg:IsCurrentRevised" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata|ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentStatus/@Value = 'revised'
			or ($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised] and $paramsDoc/parameters/version/normalize-space(.) = '')"/>
	</xsl:function>

	<xsl:function name="leg:IsCurrentOriginal" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="not($legislation/leg:Legislation/ukm:Metadata/dc:publisher = 'Statute Law Database') and
			not($legislation/leg:Legislation/ukm:Metadata/ukm:EUMetadata//ukm:DocumentStatus/@Value = 'revised') and
			not($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised] and $paramsDoc/parameters/version/normalize-space(.) = '')"/>
	</xsl:function>

	<xsl:function name="leg:IsEnactedExists" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata|ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentStatus/@Value = 'final' or exists($legislation/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasVersion' and @title = ('enacted', 'made', 'created', 'adopted')])"/>
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

	<xsl:function name="leg:IsBill" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="contains($legislation/leg:Legislation/ukm:Metadata/ukm:*/ukm:DocumentClassification/ukm:DocumentMainType/@Value, 'Bill')" />
	</xsl:function>

	<xsl:function name="leg:isFromWestlaw" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()" />
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/dc:publisher = 'Westlaw'" />
	</xsl:function>

	<xsl:function name="leg:IsLegislationWeRevise" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata|ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value
			= ('UnitedKingdomPublicGeneralAct', 'UnitedKingdomLocalAct', 'GreatBritainAct', 'EnglandAct', 'ScottishOldAct', 'ScottishAct',
			'IrelandAct', 'NorthernIrelandParliamentAct', 'NorthernIrelandAssemblyMeasure', 'NorthernIrelandAct',
			'UnitedKingdomChurchMeasure', 'WelshAssemblyMeasure', 'WelshNationalAssemblyAct','WelshParliamentAct','NorthernIrelandOrderInCouncil',
			'UnitedKingdomStatutoryInstrument','ScottishStatutoryInstrument', 'WelshStatutoryInstrument', 'NorthernIrelandStatutoryRule', 'NorthernIrelandStatutoryRuleOrOrder', 'EuropeanUnionRegulation', 'EuropeanUnionRegulation', 'EuropeanUnionDecision', 'EuropeanUnionDirective', 'EuropeanUnionTreaty' )"/>
	</xsl:function>

	<xsl:function name="leg:IsOutstandingEffectExists" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="count($legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata|ukm:EUMetadata)/ukm:UnappliedEffects/ukm:UnappliedEffect[not(@RequiresApplied='false')]) > 0"/>
	</xsl:function>

	<xsl:function name="leg:IsOutstandingEffectsOnlyProspectiveOrFutureDate" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="
			every $t in $legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata|ukm:EUMetadata)/ukm:UnappliedEffects/ukm:UnappliedEffect[not(@RequiresApplied='false')]/ukm:InForceDates/ukm:InForce
			satisfies $t[@Prospective='true' or xs:date(@Date) &gt; current-date()]
			"/>
	</xsl:function>

	<xsl:function name="leg:IsEditedByEPP" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="
			exists($legislation/leg:Legislation/ukm:Metadata/dc:contributor[. = 'Expert Participation']) or
			not(contains($legislation/leg:Legislation/@ValidDates, ' '))
			"/>
	</xsl:function>

	<xsl:function name="leg:IsPDFOnly" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="not(exists($legislation/leg:Legislation/* except $legislation/leg:Legislation/ukm:Metadata)) and exists($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@URI])"/>
	</xsl:function>

	<xsl:function name="leg:IsPDFOnlyNotRevised" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="not(exists($legislation/leg:Legislation/* except $legislation/leg:Legislation/ukm:Metadata)) and not(exists($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised])) and exists($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@URI])"/>
	</xsl:function>

	<xsl:function name="leg:IsEUPDFOnlyNotRevised" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="
		empty($legislation/leg:Legislation/leg:EURetained) and
		exists($legislation/leg:Legislation/ukm:Metadata/ukm:EUMetadata) and
		not(exists($legislation/leg:Legislation/* except $legislation/leg:Legislation/ukm:Metadata)) and exists($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@URI]) and
		matches($dcIdentifier, 'adopted')"/>
	</xsl:function>

	<xsl:function name="leg:IsRevisedPDFOnly" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
			<xsl:sequence select="exists($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised]) and empty($legislation/leg:Legislation/(leg:Primary|leg:Secondary|leg:EURetained))"/>
	</xsl:function>

	<xsl:function name="leg:IsRevisedEUPDFOnly" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
			<xsl:sequence select="
			empty($legislation/leg:Legislation/leg:EURetained) and
			exists($legislation/leg:Legislation/ukm:Metadata/ukm:EUMetadata) and exists($legislation/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised]) and not(matches($dcIdentifier, 'adopted'))"/>
	</xsl:function>

	<xsl:function name="leg:IsEURetained" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
			<xsl:sequence select="exists($legislation/leg:Legislation/leg:EURetained)"/>
	</xsl:function>


	<xsl:function name="leg:IsProposedVersion" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata|ukm:SecondaryMetadata|ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentStatus/@Value = 'proposed'"/>
	</xsl:function>

	<xsl:function name="leg:IsRevision" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()" />
		<xsl:sequence select="exists($legislation/leg:Legislation/ukm:Metadata/ukm:Revisions)" />
	</xsl:function>

	<xsl:function name="leg:IsCheckedOut" as="xs:boolean">
		<xsl:param name="legislation" as="document-node()" />
		<xsl:sequence select="exists($legislation/leg:Legislation/ukm:Metadata/ukm:Checkout)" />
	</xsl:function>

	<xsl:function name="leg:unappliedAffectingURIs" as="xs:string*">
		<xsl:param name="legislation" as="document-node()" />
		<xsl:sequence select="$legislation/leg:Legislation/ukm:Metadata/*/ukm:UnappliedEffects/ukm:UnappliedEffect/@AffectingURI" />
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

	<xsl:function name="leg:legislationStartDate" as="xs:string?">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="
			($legislation/leg:Legislation/@RestrictStartDate, $legislation/leg:Legislation/ukm:Metadata/dct:valid)[1]"/>
	</xsl:function>

	<xsl:function name="leg:DivisionName" as="xs:string">
		<xsl:param name="divelement" as="element()"/>
		<xsl:value-of select="if ($divelement/@Type = 'EUTitle' and not(matches($divelement/leg:Number, 'title', 'i'))) then 'Title'
									else if ($divelement/@Type = 'EUPart' and not(matches($divelement/leg:Number, 'part', 'i'))) then 'Part'
									else if ($divelement/@Type = 'EUChapter' and not(matches($divelement/leg:Number, 'chapter', 'i'))) then 'Chapter'
									else if ($divelement/@Type = 'EUSection' and not(matches($divelement/leg:Number, 'section', 'i'))) then 'Section'
									else if ($divelement/@Type = 'EUSubsection' and not(matches($divelement/leg:Number, 'section', 'i'))) then 'Sub-Section'
									else if ($divelement/@Type = 'Annotations' and not(matches($divelement/leg:Number, 'annotation', 'i'))) then 'Annotations'
									else if ($divelement/@Type = 'Annotation' and not(matches($divelement/leg:Number, 'annotation', 'i'))) then 'Annotation'
									else 'Division'"/>
	</xsl:function>

	<xsl:function name="leg:revisedTreatyText" as="xs:string">
		<xsl:param name="treatyname" as="xs:string"/>
		<xsl:param name="date" as="xs:string"/>
		<xsl:value-of>
			<xsl:choose>
				<xsl:when test="$treatyname = 'euratom'">
					<xsl:value-of select="leg:TranslateText('treaty_default')"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$date"/>
					<xsl:text>. </xsl:text>
					<xsl:value-of select="leg:TranslateText('treaty_euratom')"/>
				</xsl:when>
				<xsl:when test="$treatyname = 'teec'">
					<xsl:value-of select="leg:TranslateText('treaty_default')"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$date"/>
					<xsl:text>. </xsl:text>
					<xsl:value-of select="leg:TranslateText('treaty_teec')"/>
				</xsl:when>
				<xsl:when test="$treatyname = 'teu'">
					<xsl:value-of select="leg:TranslateText('treaty_default')"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$date"/>
					<xsl:text>. </xsl:text>
					<xsl:value-of select="leg:TranslateText('treaty_teu')"/>
				</xsl:when>
				<xsl:when test="$treatyname = 'eea-agreement'">
					<xsl:value-of select="leg:TranslateText('treaty_default')"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$date"/>
					<xsl:text>. </xsl:text>
					<xsl:value-of select="leg:TranslateText('treaty_eea')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="leg:TranslateText('treaty_default')"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$date"/>
					<xsl:text>.</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:value-of>
	</xsl:function>

	<xsl:variable name="powerToAmendLinks" as="element()">
		<links>
			<link string="Payment Systems Regulator" link="https://www.psr.org.uk/psr-publications/policy-statements/onshoring-eu-regulatory-technical-standards-under-ifr" scenario="deal nodeal extension"/>
			<link string="Financial Conduct Authority" link="https://www.handbook.fca.org.uk/instrument" scenario="deal nodeal"/>
			<link string="Financial Conduct Authority" link="https://www.fca.org.uk/" scenario="extension"/>
			<link string="Bank of England" link="https://www.bankofengland.co.uk/paper/2019/the-boes-amendments-to-financial-services-legislation-under-the-eu-withdrawal-act-2018" scenario="deal nodeal extension"/>
			<link string="Prudential Regulation Authority" link="https://www.bankofengland.co.uk/paper/2019/the-boes-amendments-to-financial-services-legislation-under-the-eu-withdrawal-act-2018" scenario="deal nodeal extension"/>
		</links>
	</xsl:variable>

	<xsl:function name="leg:formatPowerToAmendText">
		<xsl:param name="atomLinks"/>
		<xsl:for-each select="$atomLinks">
			<xsl:variable name="affectingURI" select="@href"/>
			<p>
				<xsl:value-of select="concat(upper-case($g_strShortType), ' ', $g_strDocumentYear, ' No. ', $g_strDocumentNumber)"/>
				<xsl:sequence select="leg:replaceStringWithElement(replace(@title, 'XXXX', '', 'i'), (distinct-values($powerToAmendLinks//@string), '(S\.I\.\s[0-9]{4}/[0-9]+)'), 'a', $affectingURI)"/>
			</p>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="leg:replaceStringWithElement">
		<xsl:param name="string" as="xs:string+"/>
		<xsl:param name="words" as="xs:string+"/>
		<xsl:param name="wrapper-name" as="xs:string"/>
		<xsl:param name="link" as="xs:string?"/>

		<xsl:analyze-string select="$string" regex="{string-join($words, '|')}">
			<xsl:matching-substring>
				<xsl:variable name="current" select="."/>
				<xsl:choose>
					<xsl:when test="matches(regex-group(1), 'S.I. ', 'i')">
						<xsl:element name="{$wrapper-name}">
							<xsl:attribute name="href" select="$link"/>
							<xsl:value-of select="regex-group(1)"/>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{$wrapper-name}">
						<xsl:attribute name="href" select="$powerToAmendLinks//*[@string = $current][$brexitType = (tokenize(@scenario, ' '))]/@link"/>
						<xsl:attribute name="target" select="'_blank'"/>
						<xsl:value-of select="$current"/>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:function>


</xsl:stylesheet>
