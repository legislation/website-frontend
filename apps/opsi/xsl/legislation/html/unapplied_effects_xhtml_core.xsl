<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
xmlns:dc="http://purl.org/dc/elements/1.1/" 
xmlns:dct="http://purl.org/dc/terms/"
xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:atom="http://www.w3.org/2005/Atom" 
exclude-result-prefixes="leg xhtml xsl ukm xs tso atom">

<!-- Provisions to put under "Changes and effects yet to be applied to
     the whole..." heading. -->
<xsl:variable name="largerProvisions" select="'act','blanket amendment','measure', 'order'" as="xs:string+" />

<xsl:template match="ukm:UnappliedEffects" mode="filterUnappliedEffects">
	<xsl:param name="includeTooltip" as="xs:boolean" tunnel="yes" select="false()"/>
	<xsl:param name="IsEURetained" as="xs:boolean" tunnel="yes" select="false()"/>
	<xsl:param name="IsRevisedEUPDFOnly" as="xs:boolean" tunnel="yes" select="false()"/>
	
	<!-- Don't use the global variable as this will not be in the call from the status warning  -->
	<xsl:variable name="strDocType" select="ancestor::ukm:Metadata//ukm:DocumentClassification/ukm:DocumentMainType/@Value" as="xs:string"/>
	<xsl:variable name="strTitle" select="ancestor::ukm:Metadata/dc:title" as="xs:string"/>
	<xsl:variable name="strAlternativeTitle" select="ancestor::ukm:Metadata/dct:alternative" as="xs:string?"/>
	<xsl:variable name="commencementOrders" as="element(ukm:UnappliedEffect)*" select="*[ukm:Commenced or @Type = 'Commencement Order']" />
	<xsl:variable name="effects" as="element(ukm:UnappliedEffect)*" select="*[not(ukm:Commenced)]" />
	
	<!--Chunyu HA050183 changed the condition for section as there are more than one section. See http://www.legislation.gov.uk/ukpga/2005/5/section/2	-->
	<xsl:variable name="largerEffects"
								as="element(ukm:UnappliedEffect)*"
								select="($effects except $commencementOrders)
													[ukm:AffectedProvisions//*[name() = 'ukm:Section'][@FoundRef or @Missing = 'true'] or
													     ukm:AffectedProvisions//ukm:SectionRange[@FoundStart or @FoundEnd or @MissingStart = 'true' or @MissingEnd = 'true'] or
													 @AffectedProvisions[normalize-space(lower-case(.)) = $largerProvisions] or (
													 @AffectedProvisions = '' and empty(ukm:AffectedProvisions//*[name() = 'ukm:Section']) and empty(ukm:AffectedProvisions//ukm:SectionRange)
													 )]" />
	<xsl:variable name="sectionEffects"
								as="element(ukm:UnappliedEffect)*"
								select="$effects except ($commencementOrders, $largerEffects)" />


	<!-- FM Issue 261: Changes to Legislation for the introductory text - we don't really want to show all the outstanding effects for the whole Act in here -  as there won't ever be any effects listed that are for just for the introductory text - please can you just remove the category which lists effects for the specific provision you are - so there should only be ones for the whole Act and the commencement orders listed at this level -->
	<xsl:variable name="introURI" select="ancestor::ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/introduction' and @title='introduction']/@href"/>
	
	<xsl:variable name="isEUPDF" as="xs:boolean" select="ancestor::ukm:Metadata/ukm:EUMetadata and exists(ancestor::ukm:Metadata/ukm:Alternatives/ukm:Alternative) and empty(ancestor::leg:Legislation/leg:EURetained)"/>
	
	<xsl:variable name="hasFutureSectionEffects" as="xs:boolean" 
			select="not($sectionEffects//ukm:InForceDates) or
					(some $date in $sectionEffects//ukm:InForceDates/ukm:InForce[@Date castable as xs:date] satisfies (xs:date($date/@Date) gt current-date()))"/>
					
	<xsl:variable name="hasFutureLargerEffects" as="xs:boolean" 
			select="not($largerEffects//ukm:InForceDates) or
					(some $date in $largerEffects//ukm:InForceDates/ukm:InForce[@Date castable as xs:date] satisfies (xs:date($date/@Date) gt current-date()))"/>				

	<xsl:if test="exists($sectionEffects) and ($introURI != ancestor::ukm:Metadata/dc:identifier or $isEUPDF)">
		<div class="section" id="statusEffectsAppliedSection">
			<div class="title{if ($hasFutureSectionEffects) then ' future' else ()}">
				<xsl:variable name="test"><xsl:value-of select="tso:TitleCase(translate($paramsDoc/parameters/section,'/',' '))"/></xsl:variable>
				<h3>
					<xsl:choose>
						<xsl:when test="$IsRevisedEUPDFOnly">
							<xsl:value-of select="leg:TranslateText('Changes and effects to ')"/>
							<xsl:value-of select="if ($strAlternativeTitle) then $strAlternativeTitle else $strTitle"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="leg:TranslateText('unapp_effects_applied_section',concat('test=',$test))"/>
						</xsl:otherwise>
					</xsl:choose>
				</h3>
				<xsl:if test="$includeTooltip">
					<a href="#ChangesEffectSectionHelp" class="helpItem helpItemToBot">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about changes and effects"/>
					</a>
					<div class="help" id="ChangesEffectSectionHelp">
						<span class="icon"/>
						<div class="content">
							<a href="#" class="close">
								<img alt="Close" src="/images/chrome/closeIcon.gif"/>
							</a>
							<h3><xsl:value-of select="leg:TranslateText('Changes and effects')"/></h3>
							<p><xsl:value-of select="leg:TranslateText('unapp_effects_sectionList_message')"/></p>
						</div>
					</div>				
				</xsl:if>
			</div>
			<div class="content" id="statusEffectsAppliedContent">
			<ul>
				<xsl:apply-templates select="$sectionEffects" mode="filterUnappliedEffects">
					<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 1) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 1) else 1"/>
					<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 2) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 2) else 1"/>
					<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 3) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 3) else 1"/>
					<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 4) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 4) else 1"/>
					<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 5) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 5) else 1"/>
					<xsl:sort select="@AffectedURI"/>
					<xsl:sort select="@Type"/>
					<xsl:sort select="@AffectingURI"/>
				</xsl:apply-templates>
			</ul>
			</div>
		</div>	
	</xsl:if>
	<xsl:if test="exists($largerEffects)">
		<div class="section" id="changesAppliedSection">
			<div class="title{if ($hasFutureLargerEffects) then ' future' else ()}">
				<h3>
					<xsl:choose>
						<xsl:when test="$IsRevisedEUPDFOnly">
							<xsl:value-of select="leg:TranslateText('Changes and effects to ')"/>
							<xsl:value-of select="if ($strAlternativeTitle) then $strAlternativeTitle else $strTitle"/>
						</xsl:when>
						<xsl:when test="$IsEURetained">
							<xsl:value-of select="leg:TranslateText('unapp_effects_generic_changes_app_section')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="leg:TranslateText('unapp_effects_changes_app_section',concat('docType=',tso:type($strDocType)))"/>
						</xsl:otherwise>
					</xsl:choose>
				
				</h3>				
				<xsl:if test="$includeTooltip">
					<a href="#ChangesEffectWholeHelp" class="helpItem helpItemToBot">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about changes and effects"/>
					</a>
					<div class="help" id="ChangesEffectWholeHelp">
						<span class="icon"/>
						<div class="content">
							<a href="#" class="close">
								<img alt="Close" src="/images/chrome/closeIcon.gif"/>
							</a>
							<h3><xsl:value-of select="leg:TranslateText('Changes and effects')"/></h3>
							<p><xsl:value-of select="leg:TranslateText('unapp_effect_tooltip_wholehelp',concat('docType=',tso:type($strDocType)))"/></p>
						</div>
					</div>
				</xsl:if>				
			</div>
			<div class="content" id="changesAppliedContent">
				<xsl:if test="exists($largerEffects[@AffectedProvisions[normalize-space(lower-case(.)) = $largerProvisions]])">
					<ul>
						<xsl:apply-templates select="$largerEffects[@AffectedProvisions[normalize-space(lower-case(.)) = $largerProvisions]]" mode="filterUnappliedEffects">
							<xsl:sort select="@AffectedURI"/>
							<xsl:sort select="@Type"/>
							<xsl:sort select="@AffectingURI"/>
						</xsl:apply-templates>
					</ul>
				</xsl:if>
				<xsl:if test="exists($largerEffects[not(@AffectedProvisions[normalize-space(lower-case(.)) = $largerProvisions])])">
					<xsl:if test="not($IsEURetained)">
						<p class="coIntro"><xsl:value-of select="leg:TranslateText('unapp_effect_wholeprovision',concat('docType=',tso:type($strDocType)))"/></p>
					</xsl:if>
					<ul>
						<xsl:apply-templates select="$largerEffects[not(@AffectedProvisions[normalize-space(lower-case(.)) = $largerProvisions])]" mode="filterUnappliedEffects">
							<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 1) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 1) else 1"/>
							<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 2) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 2) else 1"/>
							<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 3) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 3) else 1"/>
							<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 4) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 4) else 1"/>
							<xsl:sort select="if (ukm:AffectedProvisions//ukm:Section or ukm:AffectedProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectedProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 5) else if (@AffectedProvisions) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'), 5) else 1"/>
							<xsl:sort select="@AffectedURI"/>
							<xsl:sort select="@Type"/>
							<xsl:sort select="@AffectingURI"/>
						</xsl:apply-templates>
					</ul>
				</xsl:if>
			</div>
		</div>	
	</xsl:if>
	<xsl:if test="exists($commencementOrders)">
		<div class="section" id="commencementAppliedSection">
			<div class="title">
				<h3><xsl:value-of select="leg:TranslateText('unapp_effect_commencement_orders',concat('title=',$strTitle))"/></h3>
				<xsl:if test="$includeTooltip">
					<a href="#CommencementOrdersHelp" class="helpItem helpItemToBot">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about changes and effects"/>
					</a>
					<div class="help" id="CommencementOrdersHelp">
						<span class="icon"/>
						<div class="content">
							<a href="#" class="close">
								<img alt="Close" src="/images/chrome/closeIcon.gif"/>
							</a>
							<h3><xsl:value-of select="leg:TranslateText('Commencement Orders')"/></h3>
							<p><xsl:value-of select="leg:TranslateText('unapp_effect_tooltip_commencement_orders',concat('docType=',tso:type($strDocType)))"/></p>
						</div>
					</div>	
				</xsl:if>			
			</div>
			<div class="content" id="commencementAppliedContent">				
				<xsl:if test="$commencementOrders[not(matches(@Type, 'Commencement Order', 'i'))]">
					<p class="coIntro"><xsl:value-of select="leg:TranslateText('unapp_effect_commencement_orders_provisions',concat('docType=',tso:type($strDocType)))"/></p>
					<ul>
						<xsl:apply-templates select="$commencementOrders[not(matches(@Type, 'Commencement Order', 'i'))]" mode="filterUnappliedEffects">
							<xsl:sort select="if (@AffectingURI = ancestor::leg:Legislation/@IdURI) then 1 else 2"/>
							<xsl:sort select="if (@AffectingClass) then tso:orderClass(@AffectingClass) else 1"/>
							<xsl:sort select="if (@AffectingYear) then @AffectingYear else 1"/>
							<xsl:sort select="if (@AffectingNumber) then @AffectingNumber else 1" data-type="number"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 1) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 1) else 1"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 2) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 2) else 1"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 3) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 3) else 1"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 4) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 4) else 1"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 5) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 5) else 1"/>
							<xsl:sort select="@AffectingURI"/>
						</xsl:apply-templates>
					</ul>
				</xsl:if>
				<xsl:if test="$commencementOrders[matches(@Type, 'Commencement Order', 'i')]">
					<p class="coIntro"><xsl:value-of select="leg:TranslateText('unapp_effect_commencement_orders_legislation',concat('docType=',tso:type($strDocType)))"/></p>					
					<ul>
						<xsl:apply-templates select="$commencementOrders[matches(@Type, 'Commencement Order', 'i')]" mode="filterUnappliedEffects">
							<xsl:sort select="if (@AffectingURI = ancestor::leg:Legislation/@IdURI) then 1 else 2"/>
							<xsl:sort select="if (@AffectingClass) then tso:orderClass(@AffectingClass) else 1"/>
							<xsl:sort select="if (@AffectingYear) then @AffectingYear else 1"/>
							<xsl:sort select="if (@AffectingNumber) then @AffectingNumber else 1" data-type="number"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 1) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 1) else 1"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 2) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 2) else 1"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 3) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 3) else 1"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 4) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 4) else 1"/>
							<xsl:sort select="if (ukm:AffectingProvisions//ukm:Section or ukm:AffectingProvisions//ukm:SectionRange) then tso:SortOrder((ukm:AffectingProvisions//(ukm:Section/@Ref | ukm:SectionRange/@Start))[1], 5) else if (@AffectingProvisions) then tso:SortOrder(translate(@AffectingProvisions,' ()','---'), 5) else 1"/>
							<xsl:sort select="@AffectingURI"/>
						</xsl:apply-templates>
					</ul>
				</xsl:if>
			</div>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="ukm:UnappliedEffect[@Type != 'Commencement Order'][not(ukm:Commenced)]" mode="filterUnappliedEffects">
	<xsl:param name="IsEURetained" as="xs:boolean" tunnel="yes" select="false()"/>
	<xsl:variable name="documentMainType" select="ancestor::ukm:Metadata//ukm:DocumentMainType[1]/@Value"/>
	<xsl:variable name="IdURI" select="ancestor::leg:Legislation/@IdURI"/>
	<!-- debug ordering-->
	<xsl:if test="false()">
		<xsl:message>
			<xsl:value-of select="if (@AffectedSectionRef) then @AffectedSectionRef else if (@AffectedStartSectionRef) then @AffectedStartSectionRef else if (@AffectedProvisions ) then @AffectedProvisions else 1"/>
			<xsl:text>///</xsl:text>
			<xsl:value-of select="if (@AffectedSectionRef) then tso:SortOrder(@AffectedSectionRef,1) else if (@AffectedStartSectionRef) then tso:SortOrder(@AffectedStartSectionRef,1) else if (@AffectedProvisions ) then tso:SortOrder(translate(@AffectedProvisions,' ()','---'),1) else 1"/>
		</xsl:message>
	</xsl:if>
	<li>
		<xsl:if test="$IsEURetained">
			<xsl:attribute name="class" select="if (@AffectingClass = ($g_euTypes, 'EuropeanUnionOther')) then 'eu-effect' else 'uk-effect'"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="ukm:AffectedProvisions">
				<xsl:apply-templates select="ukm:AffectedProvisions" mode="filterUnappliedEffects" />
			</xsl:when>
			<xsl:when test="@AffectedProvisions">
				<xsl:value-of select="tso:normalizeString(@AffectedProvisions)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="tso:GetType($documentMainType)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
		<xsl:value-of select="@Type"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="leg:TranslateText('by')"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="ukm:AffectingProvisions" mode="filterUnappliedEffects" />
		<xsl:if test="normalize-space(@Notes) != ''">
			<span class="notes"> (<xsl:value-of select="@Notes"/>)</span>
		</xsl:if>
	</li>
</xsl:template>

<xsl:template match="ukm:UnappliedEffect[@Type = 'Commencement Order'] | ukm:UnappliedEffect[ukm:Commenced]"  mode="filterUnappliedEffects">
	<xsl:variable  name="documentMainType" select="ancestor::ukm:Metadata//ukm:DocumentMainType[1]/@Value"/>
	<xsl:variable  name="IdURI" select="ancestor::leg:Legislation/@IdURI"/>
	<xsl:variable name="CommencingURI" select="ukm:Commenced/ukm:Citation[1]/@URI"/>

	<xsl:choose>
		<xsl:when test="@TypeNotes">
			<li>
				<xsl:apply-templates select="ukm:AffectingProvisions" mode="filterUnappliedEffects" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="@TypeNotes" />
			</li>
		</xsl:when>
		<xsl:otherwise>
			<!-- this test will determine distinct orders (some orders affect specific parts of the host legislation and are therefore duplicated) -->
			<xsl:if test="not(@AffectingURI = preceding-sibling::*[ukm:Commenced/ukm:Citation[1]/@URI = $CommencingURI]/@AffectingURI)">
				<li>
					<xsl:apply-templates select="ukm:AffectingProvisions" mode="filterUnappliedEffects" />
					<xsl:text> </xsl:text>
					<xsl:value-of select="leg:TranslateText('commences')"/>
					<xsl:text> </xsl:text>
					<xsl:text>(</xsl:text>
					<!-- in certain instances we may not get the correct commencing attributes and the processing will be arse about face - so just in case this happens check that we do have the @CommencingURI -->
					<xsl:choose>
						<xsl:when test="ukm:Commenced/ukm:Citation">
							<xsl:for-each select="ukm:Commenced/ukm:Citation">
								<a href="{@URI}">
									<xsl:value-of select="tso:abbreviation(@Class, @Year, @Number)"/>
								</a>
								<xsl:choose>
									<xsl:when test="position() = last() - 1"> and </xsl:when>
									<xsl:when test="position() != last()">, </xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="if (matches(@Notes,'commencement order for','i')) then normalize-space(substring-after(@Notes,'commencement order for')) else @Notes"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>)</xsl:text>
				</li>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ukm:AffectingProvisions" mode="filterUnappliedEffects">
	<xsl:variable name="affectingURI" as="xs:string?" select="../@AffectingURI"/>
	<xsl:variable name="link">
		<xsl:choose>
			<xsl:when test="matches($affectingURI, '^https://eur-lex\.europa\.eu')">
				<xsl:value-of select="tso:generateWebArchiveURI($affectingURI)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$affectingURI"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<a href="{$link}">
		<xsl:choose>
			<xsl:when test="exists(../@AffectingClass) and exists(../@AffectingYear) and exists(../@AffectingNumber)">
				<xsl:value-of select="tso:abbreviation(../@AffectingClass, ../@AffectingYear, ../@AffectingNumber)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="leg:TranslateText('see_amending_legislation')"/>
			</xsl:otherwise>
		</xsl:choose>
	</a>
	<xsl:text> </xsl:text>
	<xsl:apply-templates mode="filterUnappliedEffects" />
</xsl:template>

<!-- Don't create links for affected sections -->
<xsl:template match="ukm:AffectedProvisions//ukm:Section" mode="filterUnappliedEffects">
	<span class="LegAffected">
		<xsl:apply-templates mode="filterUnappliedEffects" />
	</span>
</xsl:template>

<xsl:template match="ukm:Section" mode="filterUnappliedEffects">
	<a href="{@URI}">
		<xsl:apply-templates mode="filterUnappliedEffects" />
	</a>
</xsl:template>

<xsl:template match="ukm:SectionRange" mode="filterUnappliedEffects">
	<xsl:apply-templates mode="filterUnappliedEffects" />
</xsl:template>

<xsl:function name="tso:generateWebArchiveURI" as="xs:string?">
	<xsl:param name="eurlexURI" as="xs:string" />
	<xsl:value-of select="concat('https://webarchive.nationalarchives.gov.uk/eu-exit/', $eurlexURI)"/>
</xsl:function>

<xsl:function name="tso:orderClass" as="xs:integer">
	<xsl:param name="strName" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$strName = ('UnitedKingdomPublicGeneralAct','UnitedKingdomLocalAct','GreatBritainAct','EnglandAct','UnitedKingdomLocalActRevised')">
			<xsl:number value="1"/>
		</xsl:when>
		<xsl:when test="$strName = ('ScottishAct')">
			<xsl:number value="2"/>
		</xsl:when>
		<xsl:when test="$strName = ('IrelandAct')">
			<xsl:number value="3"/>
		</xsl:when>
		<xsl:when test="$strName = ('NorthernIrelandParliamentAct','NorthernIrelandAssemblyMeasure','NorthernIrelandAct')">
			<xsl:number value="3"/>
		</xsl:when>
		<xsl:when test="$strName = ('UnitedKingdomChurchMeasure')">
			<xsl:number value="4"/>
		</xsl:when>
		<xsl:when test="$strName = ('WelshAssemblyMeasure','WelshNationalAssemblyAct','WelshParliamentAct')">
			<xsl:number value="5"/>
		</xsl:when>
		<xsl:when test="$strName = ('UnitedKingdomStatutoryInstrument','WelshStatutoryInstrument')">
			<xsl:number value="6"/>
		</xsl:when>
		<xsl:when test="$strName = 'ScottishStatutoryInstrument'">
			<xsl:number value="7"/>
		</xsl:when>
		<xsl:when test="$strName = ('NorthernIrelandStatutoryRule', 'NorthernIrelandStatutoryRuleOrOrder')">
			<xsl:number value="8"/>
		</xsl:when>
		<xsl:when test="$strName = 'NorthernIrelandOrderInCouncil'">
			<xsl:number value="9"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:number value="1000"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:function name="tso:type" as="xs:string">
	<xsl:param name="strName" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$strName = ('UnitedKingdomPublicGeneralAct','UnitedKingdomLocalAct','GreatBritainAct','EnglandAct','UnitedKingdomLocalActRevised','ScottishAct','IrelandAct','NorthernIrelandParliamentAct','NorthernIrelandAct','WelshNationalAssemblyAct','WelshParliamentAct')">
			<xsl:value-of select="'Act'"/>
		</xsl:when>
		<xsl:when test="$strName = ('NorthernIrelandAssemblyMeasure', 'UnitedKingdomChurchMeasure','WelshAssemblyMeasure')">
			<xsl:value-of select="'Measure'"/>
		</xsl:when>
		<xsl:when test="$strName = ('UnitedKingdomChurchInstrument','UnitedKingdomStatutoryInstrument','WelshStatutoryInstrument','ScottishStatutoryInstrument')">
			<xsl:value-of select="'Instrument'"/>
		</xsl:when>
		<xsl:when test="$strName = ('UnitedKingdomMinisterialDirection')">
			<xsl:value-of select="'Direction'"/>
		</xsl:when>		
		<xsl:when test="$strName = ('NorthernIrelandOrderInCouncil', 'UnitedKingdomMinisterialOrder')">
			<xsl:value-of select="'Order'"/>
		</xsl:when>		
		<xsl:when test="$strName = 'NorthernIrelandStatutoryRule'">
			<xsl:value-of select="'Rule'"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="'Act'"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:function name="tso:abbreviation" as="xs:string">
	<xsl:param name="strName" as="xs:string" />
	<xsl:param name="strYear" as="xs:string" />
	<xsl:param name="strNumber" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$strName = ('UnitedKingdomPublicGeneralAct','UnitedKingdomLocalAct','GreatBritainAct','EnglandAct','UnitedKingdomLocalActRevised')">
			<xsl:value-of select="concat($strYear,' c. ',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('ScottishAct')">
			<xsl:value-of select="concat($strYear,' asp ',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('ScottishOldAct')">
			<xsl:value-of select="concat($strYear,' c. ',$strNumber,' (S.)')"/>
		</xsl:when>
		<xsl:when test="$strName = ('IrelandAct')">
			<xsl:value-of select="concat($strYear,' c. ',$strNumber,' (I.)')"/>
		</xsl:when>
		<xsl:when test="$strName = ('NorthernIrelandParliamentAct','NorthernIrelandAssemblyMeasure','NorthernIrelandAct')">
			<xsl:value-of select="concat($strYear,' c. ',$strNumber,' (N.I.)')"/>
		</xsl:when>
		<xsl:when test="$strName = ('UnitedKingdomChurchMeasure')">
			<xsl:value-of select="concat($strYear,' No. ',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('WelshAssemblyMeasure')">
			<xsl:value-of select="concat($strYear,' nawm ',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('WelshNationalAssemblyAct')">
			<xsl:value-of select="concat($strYear,' anaw ',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = 'WelshParliamentAct'">
			<xsl:value-of select="concat($strYear,' asc ',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('UnitedKingdomChurchInstrument')">
			<xsl:value-of select="concat($strYear,' No. ',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('UnitedKingdomStatutoryInstrument','WelshStatutoryInstrument')">
			<xsl:value-of select="concat('S.I. ',$strYear,'/',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = 'ScottishStatutoryInstrument'">
			<xsl:value-of select="concat('S.S.I. ',$strYear,'/',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('NorthernIrelandStatutoryRule', 'NorthernIrelandStatutoryRuleOrOrder')">
			<xsl:value-of select="concat('S.R. ',$strYear,'/',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = 'NorthernIrelandOrderInCouncil'">
			<xsl:value-of select="concat('S.I. ',$strYear,'/',$strNumber,' (N.I.)')"/><!-- need to add in series number to the square brackets but where do we take it from???? -->
		</xsl:when>
		<xsl:when test="$strName = ('EuropeanUnionRegulation')">
			<xsl:value-of select="concat('EUR ',$strYear,'/',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('EuropeanUnionDecision')">
			<xsl:value-of select="concat('EUDN ',$strYear,'/',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('EuropeanUnionDirective')">
			<xsl:value-of select="concat('EUDR ',$strYear,'/',$strNumber)"/>
		</xsl:when>
		<xsl:when test="$strName = ('EuropeanUnionTreaty')">
			<xsl:value-of select="concat('EUT ',$strYear,'/',$strNumber)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$strName"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- function to remove leading zeros from section references -->
<xsl:function name="tso:normalizeString">
	<xsl:param name="string" as="xs:string"/>
	<xsl:variable name="tokenised" select="tokenize(normalize-space($string),' ')"/>
	<xsl:for-each select="$tokenised">
		<xsl:choose>
			<xsl:when test="starts-with(.,'000')">
				<xsl:value-of select="substring(.,4)"/>
				<xsl:if test="not(position() = last())">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="starts-with(.,'00')">
				<xsl:value-of select="substring(.,3)"/>
				<xsl:if test="not(position() = last())">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="starts-with(.,'0')">
				<xsl:value-of select="substring(.,2)"/>
				<xsl:if test="not(position() = last())">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
				<xsl:if test="not(position() = last())">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:function>

<!-- Maps between some tokens and corresponding text to show. -->
<xsl:variable name="sectionTokens" as="element()+">
	<token token="appendix" text="Appendix" />
	<token token="article" text="art." />
	<token token="chapter" text="Ch." />
	<token token="form" text="Form" />
	<token token="paragraph" text="para." />
	<token token="part" text="Pt." />
	<token token="regulation" text="reg." />
	<token token="rule" text="rule" />
	<token token="schedule" text="Sch." />
	<token token="section" text="s." />
	<token token="annex" text="Annex"  />
	<token token="title" text="Title" />
	<token token="signature" text="Signature" />
</xsl:variable>

<!-- Produce readable text of a section reference. -->
<xsl:function name="tso:formatSection" as="xs:string">
	<xsl:param name="string" as="xs:string"/>
	<xsl:param name="token" as="xs:string"/>
	<xsl:variable name="tokenised" select="tokenize($string,$token)"/>
	<xsl:value-of>
		<xsl:for-each select="$tokenised">
			<xsl:variable name="position" select="position()"/>
			<xsl:choose>
				<xsl:when test=". = $sectionTokens/@token">
					<xsl:if test="$position &gt; 1">
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="$sectionTokens[@token = current()]/@text" />
					<xsl:text> </xsl:text>
				</xsl:when>
				<xsl:when test="$tokenised[$position - 1] = $sectionTokens/@token">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>(</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>)</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:value-of>
</xsl:function>

<xsl:function name="tso:GetType" as="xs:string">
	<xsl:param name="legType" as="xs:string" />
	<xsl:sequence select="tso:type($legType)"/>
	<!--
		<xsl:choose>
		<xsl:when test="contains('UnitedKingdomPublicGeneralAct, UnitedKingdomLocalAct, UnitedKingdomLocalActRevised, GreatBritainAct, EnglandAct, ScottishAct, IrelandAct, NorthernIrelandParliamentAct, NorthernIrelandAct',$legType)">Act</xsl:when>
		<xsl:when test="contains('WelshAssemblyMeasure, UnitedKingdomChurchMeasure, NorthernIrelandAssemblyMeasure',$legType)">Measure</xsl:when>
		<xsl:when test="$legType = 'UnitedKingdomLocalActRevised'">Order</xsl:when>
		<xsl:otherwise><xsl:value-of select="$legType" /></xsl:otherwise>
	</xsl:choose>-->
</xsl:function>





<xsl:function name="tso:SortOrder" as="xs:integer">
	<xsl:param name="ref" as="xs:string" />
	<xsl:param name="item" as="xs:integer" />
	<!--provisions may well result in double dashes so we need to remove these-->
	<xsl:variable name="tokenizedRef" select="tokenize(replace($ref,'--','-'),'-')"/>
	
	<xsl:choose>
		<xsl:when test="$tokenizedRef[$item]='' or not($tokenizedRef[$item])">
			<xsl:number value="0"/>
		</xsl:when>
		<!-- this is to weed out text from the provisions -->
		<xsl:when test="contains($tokenizedRef[$item],'title') or contains($tokenizedRef[$item],'cross')">
			<xsl:number value="0"/>
		</xsl:when>
		<xsl:when test="matches($tokenizedRef[$item],'act','i')">
			<xsl:number value="5"/>
		</xsl:when>
		<xsl:when test="$tokenizedRef[$item]='part' or $tokenizedRef[$item]='Pt.'">
			<xsl:number value="10"/>
		</xsl:when>
		<xsl:when test="$tokenizedRef[$item]='chapter' or $tokenizedRef[$item]='Ch.'">
			<xsl:number value="15"/>
		</xsl:when>
		<xsl:when test="$tokenizedRef[$item]='section' or $tokenizedRef[$item]='s.'">
			<xsl:number value="20"/>
		</xsl:when>
		<xsl:when test="$tokenizedRef[$item]='schedule' or $tokenizedRef[$item]='Sch.'">
			<xsl:number value="30"/>
		</xsl:when>
		<xsl:when test="$tokenizedRef[1]='paragraph'">
			<xsl:number value="40"/>
		</xsl:when>
		
		<!--BASIC ALPHANUMERIC LISTS -->
		<!--   When ordering lists we need to order basic alphanumeric values as: 
				24
				24A
				24B
				24AA etc
		-->
		<!--  allow for basic integer values whcih will give us a value of 3XXX0000-->
		<xsl:when test="$tokenizedRef[$item] castable as xs:integer">
			<xsl:number value="3000000000 + (number($tokenizedRef[$item]) * 1000000)"/>
		</xsl:when>
		<!-- now allow for instances such as 23A - this will tanslate into a value such as 3XXX0000aa-->
		<xsl:when test="substring($tokenizedRef[$item],0,string-length($tokenizedRef[$item])) castable as xs:integer">
			<xsl:number value="3000000000 + (number(substring($tokenizedRef[$item],0,string-length($tokenizedRef[$item]))) * 1000000) + (number(tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item])))))"/>			
		</xsl:when>
		<!-- now allow for instances such as 23GA- this will tanslate into a value such as 3XXX00bbaa -->
		<xsl:when test="string-length($tokenizedRef[$item]) &gt; 2 and substring($tokenizedRef[$item],0,string-length($tokenizedRef[$item]) - 1) castable as xs:integer">
		
			<xsl:number value="3000000000 + (number(substring($tokenizedRef[$item],0,string-length($tokenizedRef[$item]) - 1)) * 1000000) +
			(number(tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item])-1,1))) * 100) +
			number(tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item]))))"/>
		</xsl:when>
		
		<!-- now allow for instances such as 23GAB- this will tanslate into a value such as 3XXXccbbaa -->
		<xsl:when test="string-length($tokenizedRef[$item]) &gt; 3 and substring($tokenizedRef[$item],0,string-length($tokenizedRef[$item]) - 2) castable as xs:integer">
			<xsl:number value="3000000000 + (number(substring($tokenizedRef[$item],0,string-length($tokenizedRef[$item]) - 2)) * 1000000) +
			(number(tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item])-2,1))) * 10000) +
			(number(tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item])-1,1))) * 100) +
			number(tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item]))))"/>
		</xsl:when>
		
		
		<!--BASIC ROMAN LISTS -->
		<!--roman numerals appear in sections at position 5 -->
		<xsl:when test="$item = 5 and ($tokenizedRef[1]='section' or $tokenizedRef[1]='s.') and (tso:romanPosition($tokenizedRef[$item]) != 0)">
			<xsl:value-of select="80000000 + tso:romanPosition($tokenizedRef[$item])"/>
		</xsl:when>
		<!-- if reference is character based determine how many characters then let the uri order it-->
		<!-- next order single characters- ie 'a'-->
		
		
		<!--BASIC ALPHABETIC LISTS -->
		<!--   When ordering lists we need to order basic alphanumeric values as: 
				a
				b
				aa
				ab 
				ba
				bb
				aaa
				etc
		-->
		<!--   basic single letter will result in  50aa0000 -->
		<xsl:when test="string-length($tokenizedRef[$item]) = 1">
			<xsl:number value="50000000 + (tso:characterPosition($tokenizedRef[$item]))*1000"/>
		</xsl:when>
		<!-- next order double characters- ie 'aa' -  50aabb00  -->
		<xsl:when test="string-length($tokenizedRef[$item]) = 2">
			<xsl:number value="530000000 + (tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item])-1,1)))*1000 + 
			(tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item])))*100)"/><!--<xsl:message><xsl:value-of select="$ref"/></xsl:message>-->
		</xsl:when>
		<!-- next order triple characters- ie 'aa' -  50aabbcc  -->
		<xsl:when test="string-length($tokenizedRef[$item]) = 3">
			<xsl:number value="56000000 + (tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item])-2,1)))*1000 + 
			(tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item])-1,1))*100) +
			(tso:characterPosition(substring($tokenizedRef[$item],string-length($tokenizedRef[$item]))))"/>
		</xsl:when>
		
		<xsl:otherwise>
			<xsl:number value="70000000"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>



<xsl:function name="tso:characterPosition" as="xs:integer">
	<xsl:param name="char" as="xs:string"/>
	<xsl:variable name="characterSet" as="item()+" select="'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'"/>
	<xsl:choose>
		<xsl:when test="index-of($characterSet,lower-case($char))">
			<xsl:value-of select="index-of($characterSet,lower-case($char))"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:number value="0"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:romanPosition" as="xs:integer">
	<xsl:param name="char" as="xs:string"/>
	<xsl:variable name="characterSet" as="item()+" select="'i','ii','iii','iv','v','vi','vii','viii','ix','x',
	'xi','xii','xiii','xiv','xv','xvi','xvii','xviii','xix','xx',
	'xxi','xxii','xxiii','xxiv','xxv','xxvi','xxvii','xxviii','xxix','xxx',
	'xxxi','xxxii','xxxiii','xxxiv','xxxv','xxxvi','xxxvii','xxxviii','xxxix','xl'"/>
	<xsl:choose>
		<xsl:when test="index-of($characterSet,lower-case($char))">
			<xsl:value-of select="index-of($characterSet,lower-case($char))"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:number value="0"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


</xsl:stylesheet>