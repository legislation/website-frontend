<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
  xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs err tso"
	version="2.0">

<xsl:variable name="strCurrentURIs" select="/leg:Legislation/ukm:Metadata/dc:identifier, 
	/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasPart']/@href" />
<xsl:variable name="nstSelectedSection" as="element()?" 
	select="/leg:Legislation/(leg:Primary | leg:Secondary)/(leg:Body | leg:Schedules)//*[@id != '' and @DocumentURI = $strCurrentURIs]" />

<xsl:variable name="g_nstCodeLists" select="document('../codelists.xml')/CodeLists/CodeList"/>

<xsl:variable name="tso:legTypeMap" as="element()+">
	<!-- The order here is significant; it's a preferential order for displaying the types in lists -->
  <tso:legType schemaType="UnitedKingdomPublicGeneralAct" abbrev="ukpga" class="primary" category="Act" 
  	en="Explanatory Notes" singular="UK Public General Act" plural="UK Public General Acts"
  	start="1801" complete="1988" revised="true" />
  <tso:legType schemaType="UnitedKingdomLocalAct" abbrev="ukla" class="primary" category="Act" 
  	singular="UK Local Act" plural="UK Local Acts"
  	start="1857" complete="1991" revised="false" />
  <tso:legType schemaType="ScottishAct" abbrev="asp" class="primary" category="Act" 
  	en="Explanatory Notes" singular="Act of the Scottish Parliament" plural="Acts of the Scottish Parliament"
  	start="1999" complete="1999" revised="true" />
  <tso:legType schemaType="WelshAssemblyMeasure" class="primary" category="Measure" abbrev="mwa" 
	en="Explanatory Notes" singular="Measure of the National Assembly for Wales" plural="Measures of the National Assembly for Wales"
  	start="2008" complete="2008" revised="true" />
  <tso:legType schemaType="UnitedKingdomChurchMeasure" class="primary" category="Measure" abbrev="ukcm" 
  	singular="Church Measure" plural="Church Measures"
  	start="1920" complete="1988" revised="true" />
  <tso:legType schemaType="NorthernIrelandAct" class="primary" category="Act" abbrev="nia" 
  	en="Explanatory Notes" singular="Act of the Northern Ireland Assembly" plural="Acts of the Northern Ireland Assembly"
  	start="2000" complete="2000" revised="true" />
  <tso:legType schemaType="ScottishOldAct" abbrev="aosp" class="primary" category="Act" 
  	singular="Act of the Old Scottish Parliament" plural="Acts of the Old Scottish Parliament"
  	start="1424" end="1707" timeline="century" revised="true" />
  <tso:legType schemaType="EnglandAct" abbrev="aep" class="primary" category="Act" 
  	singular="Act of the English Parliament" plural="Acts of the English Parliament"
  	start="1267" end="1706" timeline="century" revised="true" />
  <tso:legType schemaType="IrelandAct" abbrev="aip" class="primary" category="Act" 
  	singular="Act of the Old Irish Parliament" plural="Acts of the Old Irish Parliament"
  	start="1495" end="1800" timeline="century" revised="true" />
	<tso:legType schemaType="GreatBritainAct" abbrev="apgb" class="primary" category="Act" 
		singular="Act of the Parliament of Great Britain" plural="Acts of the Parliament of Great Britain"
		start="1707" end="1800" revised="true" />
	<!-- half way point -->
	<tso:legType schemaType="UnitedKingdomStatutoryInstrument" class="secondary" category="Instrument" abbrev="uksi" 
		en="Executive Note" em="Explanatory Memorandum" singular="UK Statutory Instrument" plural="UK Statutory Instruments"
		start="1948" complete="1987" revised="false" />
  <tso:legType schemaType="WelshStatutoryInstrument" class="secondary" category="Instrument" abbrev="wsi" 
		em="Explanatory Memorandum" singular="Wales Statutory Instrument" plural="Wales Statutory Instruments"
  	start="1999" complete="1999" revised="false" />
  <tso:legType schemaType="ScottishStatutoryInstrument" class="secondary" category="Instrument" abbrev="ssi" 
  	en="Executive Note" singular="Scottish Statutory Instrument" plural="Scottish Statutory Instruments"
  	start="1999" complete="1999" revised="false" />
  <tso:legType schemaType="NorthernIrelandOrderInCouncil" class="primary" category="Order" abbrev="nisi" 
  	em="Explanatory Memorandum" singular="Northern Ireland Order in Council" plural="Northern Ireland Orders in Council"
  	start="1972" complete="1987" revised="true" />
  <tso:legType schemaType="NorthernIrelandStatutoryRule" class="secondary" category="Rule" abbrev="nisr" 
  	em="Explanatory Memorandum" singular="Northern Ireland Statutory Rule" plural="Northern Ireland Statutory Rules"
  	start="1991" complete="1991" revised="false" />
  <tso:legType schemaType="UnitedKingdomChurchInstrument" class="secondary" category="Instrument" abbrev="ukci" 
  	singular="Church Instrument" plural="Church Instruments"
  	start="1991" complete="1991" revised="false" />
  <tso:legType schemaType="UnitedKingdomMinisterialOrder" class="secondary" category="Order" abbrev="ukmo" 
  	singular="UK Ministerial Order" plural="UK Ministerial Orders"
  	start="1992" timeline="none" revised="false" />
	<tso:legType schemaType="UnitedKingdomStatutoryRuleOrOrder" class="secondary" category="Order" abbrev="uksro" 
		en="Executive Note" em="Explanatory Memorandum" singular="UK Statutory Rule Or Order" plural="UK Statutory Rules and Orders"
		end="1948" revised="false" />
	<tso:legType schemaType="NorthernIrelandAssemblyMeasure" class="primary" category="Measure" abbrev="mnia" 
		singular="Measure of the Northern Ireland Assembly" plural="Measures of the Northern Ireland Assembly"
		start="1974" end="1974" timeline="none" revised="true" />
  <tso:legType schemaType="NorthernIrelandParliamentAct" class="primary" category="Act" abbrev="apni" 
  	singular="Act of the Northern Ireland Parliament" plural="Acts of the Northern Ireland Parliament"
  	start="1921" end="1972" revised="true" />
	<!-- draft types -->
	<tso:legType schemaType="UnitedKingdomDraftStatutoryInstrument" class="draft" category="Instrument" abbrev="ukdsi" 
		en="Draft Executive Notes" em="Draft Explanatory Memorandum" singular="UK Draft Statutory Instrument" plural="UK Draft Statutory Instruments"
		start="1998" complete="1998" legType="UnitedKingdomStatutoryInstrument" revised="false" />
	<!--
  <tso:legType schemaType="WelshDraftStatutoryInstrument" class="draft" category="Instrument" abbrev="wdsi" 
		em="Explanatory Memorandum" singular="Wales Draft Statutory Instrument" plural="Wales Draft Statutory Instruments"
  	start="1999" complete="1999" legType="WelshStatutoryInstrument" />
  -->
  <tso:legType schemaType="ScottishDraftStatutoryInstrument" class="draft" category="Instrument" abbrev="sdsi" 
  	en="Draft Executive Notes" singular="Scottish Draft Statutory Instrument" plural="Scottish Draft Statutory Instruments"
  	start="2001" complete="2001" legType="ScottishStatutoryInstrument" revised="false" />
  <tso:legType schemaType="NorthernIrelandDraftStatutoryRule" class="draft" category="Rule" abbrev="nidsr" 
  	em="Draft Explanatory Memorandum" singular="Northern Ireland Draft Statutory Rule" plural="Northern Ireland Draft Statutory Rules"
  	start="2000" complete="2000" legType="NorthernIrelandStatutoryRule" revised="false" />
	
	<tso:legType schemaType="UnitedKingdomImpactAssessment" class="IA" category="Impact Assemssment" abbrev="ukia" 
  	em="" singular="UK Impact Assessment" plural="UK Impact Assessments"
  	start="2008" complete="2008" legType="UnitedKingdomImpactAssessment" revised="false" />
	
</xsl:variable>

<xsl:function name="tso:getType" as="element(tso:legType)?">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string?" />
	<xsl:choose>
		<xsl:when test="$legType = 'ScottishAct'">
			<xsl:choose>
				<xsl:when test="if ($legYear castable as xs:integer) then xs:integer($legYear) &lt; 1800 else false()">
					<xsl:sequence select="$tso:legTypeMap[@abbrev = 'aosp']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$tso:legTypeMap[@abbrev = 'asp']" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$tso:legTypeMap[@schemaType = $legType]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:GetEffectingTypes" as="element(tso:legType)+">
	<xsl:sequence select="$tso:legTypeMap[not(@class = 'draft') and (@start >= 2002 or @complete >= 2002 or not(@end))]"/>
</xsl:function>

<xsl:function name="tso:ShowMoreResources" as="xs:boolean">
	<xsl:param name="item" as="document-node()" />
	<xsl:variable name="documentMainType" as="xs:string" select="$item/*/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:ENmetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />
	<xsl:sequence select="
		(: PDF documents :)
		exists($item/*/ukm:Metadata/(ukm:Notes|ukm:Alternatives|ukm:TableOfDestinations|ukm:TableOfOrigins|ukm:CorrectionSlip|ukm:TableOfEffects|ukm:CodeOfPractice|ukm:OrderInCouncil|ukm:OrdersInCouncil|ukm:OtherDocument)//*[contains(@URI, '.pdf')]) or
		(: reference to draft legislation :)
		$item/*/ukm:Metadata/ukm:Supersedes or
		(: revised legislation reference to affects on this :)
		$g_nstCodeLists[@name = 'DocumentMainType']/Code[@schema = $documentMainType]/@status = 'revised' or
		(: potentially affecting legislation :)
		(exists(tso:GetEffectingTypes()[@schemaType = $documentMainType]) and $item/*/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:ENmetadata)/ukm:Year/@Value >= 2002)" />
</xsl:function>

<xsl:function name="tso:ShowImpactAssessments" as="xs:boolean">
	<xsl:param name="item" as="document-node()" />
	<xsl:sequence select="exists($item/*/ukm:Metadata/ukm:ImpactAssessments//*[ends-with(@URI, '.pdf')])" />
</xsl:function>

<!-- Convert schema document types to URI prefixes -->
<xsl:function name="tso:GetUriPrefixFromType">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, $legYear)" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@abbrev" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:GetTitleFromType">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, $legYear)" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@plural" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:GetTypeFromDraftType">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, $legYear)" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@legType" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:GetSingularTitleFromType" as="xs:string">
  <xsl:param name="legType" as="xs:string" />
  <xsl:param name="legYear" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, $legYear)" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@singular" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="tso:TypeSelect" as="element()">
	<xsl:param name="selected" as="xs:string" select="''" />
	<xsl:param name="showPrimary" as="xs:boolean" select="true()" />
	<xsl:param name="showSecondary" as="xs:boolean" select="true()" />	
	<xsl:param name="showDraft" as="xs:boolean" select="true()" />
	<xsl:param name="showImpacts" as="xs:boolean" select="true()" />
	<xsl:param name="showUnrevised" as="xs:boolean" select="true()" />
	<xsl:param name="error" as="xs:boolean" select="false()" />	
	<xsl:param name="allowMultipleLines" as="xs:boolean" select="false()" />		
	<xsl:param name="maxLineLength" as="xs:integer" select="0" />			
	
	<select name="type" id="type">
		<xsl:if test="$error"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
	
		<xsl:if test="$showPrimary and $showSecondary">
			<option value="all">
				<xsl:if test="$selected = ''">
					<xsl:attribute name="selected" select="'selected'" />
				</xsl:if>
				<xsl:text>All </xsl:text>
				<xsl:if test="not($showUnrevised)">Revised </xsl:if>
				<xsl:text>Legislation</xsl:text>
				<xsl:if test="$showUnrevised"> (excluding draft)</xsl:if>
			</option>
		</xsl:if>	
		
		<xsl:if test="$showPrimary">
			<xsl:if test="$showSecondary and $showUnrevised">
				<option value="primary">
					<xsl:if test="$selected = 'primary'">
						<xsl:attribute name="selected" select="'selected'" />
					</xsl:if>
					<xsl:text>All Primary Legislation</xsl:text>
				</option>
			</xsl:if>
			<xsl:apply-templates select="$tso:legTypeMap[@class = 'primary' and ($showUnrevised or @revised = 'true')]" mode="DisplaySelectOptions">
				<xsl:with-param name="selected" select="$selected"/>
				<xsl:with-param name="allowMultipleLines" select="$allowMultipleLines"/>				
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:apply-templates>

		</xsl:if>
		
		<xsl:if test="$showSecondary">
			<xsl:if test="$showPrimary and $showUnrevised">
				<option value="secondary">
					<xsl:if test="$selected = 'secondary'">
						<xsl:attribute name="selected" select="'selected'" />
					</xsl:if>			
					<xsl:text>All Secondary Legislation</xsl:text>
				</option>
			</xsl:if>
			
			<xsl:apply-templates select="$tso:legTypeMap[@class = 'secondary' and ($showUnrevised or @revised = 'true')]" mode="DisplaySelectOptions">
				<xsl:with-param name="selected" select="$selected"/>
				<xsl:with-param name="allowMultipleLines" select="$allowMultipleLines"/>				
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:apply-templates>
		
		</xsl:if>
		
		<xsl:if test="$showDraft">
			<option value="draft">
				<xsl:if test="$selected = 'draft'">
					<xsl:attribute name="selected" select="'selected'" />
				</xsl:if>			
				<xsl:text>All Draft Legislation</xsl:text>
			</option>
			
			<xsl:apply-templates select="$tso:legTypeMap[@class='draft']" mode="DisplaySelectOptions">
				<xsl:with-param name="selected" select="$selected"/>
				<xsl:with-param name="allowMultipleLines" select="$allowMultipleLines"/>				
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="$showImpacts">
			<option value="draft">
				<xsl:if test="$selected = 'draft'">
					<xsl:attribute name="selected" select="'selected'" />
				</xsl:if>			
				<xsl:text>All Impact Assessments</xsl:text>
			</option>
			
			<xsl:apply-templates select="$tso:legTypeMap[@class='IA']" mode="DisplaySelectOptions">
				<xsl:with-param name="selected" select="$selected"/>
				<xsl:with-param name="allowMultipleLines" select="$allowMultipleLines"/>				
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:apply-templates>
		</xsl:if>
	</select>
</xsl:template>

<xsl:template match="tso:legType" mode="DisplaySelectOptions">
	<xsl:param name="selected" as="xs:string"/>		
	<xsl:param name="allowMultipleLines" as="xs:boolean"/>
	<xsl:param name="maxLineLength" as="xs:integer"/>
	<xsl:choose>
		<xsl:when test="$allowMultipleLines and string-length(@plural) &gt; $maxLineLength ">

			<xsl:call-template name="DisplayOptionOnMultipleLines">
				<xsl:with-param name="displayText" select="@plural"/>
				<xsl:with-param name="abbrev" select="@abbrev"/>	
				<xsl:with-param name="selected" select="$selected"/>		
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:call-template>
									
		</xsl:when>
		<xsl:otherwise>
			<option value="{@abbrev}">
				<xsl:if test="$selected eq @abbrev">
					<xsl:attribute name="selected" select="'selected'" />
				</xsl:if>
				<xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
				<xsl:if test="$allowMultipleLines">
					<xsl:text>-&#160;</xsl:text>								
				</xsl:if>
				<xsl:value-of select="@plural"/>
			</option>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<xsl:template name="DisplayOptionOnMultipleLines">
	<xsl:param name="displayText" as="xs:string"/>
	<xsl:param name="abbrev" as="xs:string"/>	
	<xsl:param name="selected" as="xs:string"/>		
	<xsl:param name="maxLineLength" as="xs:integer"/>
		
	<xsl:variable name="displayLines" as="element()+">
			<xsl:call-template name="SplitTextOnMultipleLines">
				<xsl:with-param name="textTokens" select="tokenize($displayText,'\s+')" />
				<xsl:with-param name="text" select="''" />
				<xsl:with-param name="pos" select="1" />	
				<xsl:with-param name="maxLineLength" select="$maxLineLength" />
			</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="abbrev" select="$abbrev"/>
	
	<xsl:for-each select="$displayLines">
		<option value="{$abbrev}">
			<xsl:if test="position() = 1 and $selected eq $abbrev">
				<xsl:attribute name="selected" select="'selected'" />
			</xsl:if>
			<xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
			<xsl:choose>
				<xsl:when test="position() = 1">
					<xsl:text>-&#160;</xsl:text>									
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>&#160;&#160;&#160;</xsl:text>				
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="."/>
		</option>							
	</xsl:for-each>
</xsl:template>

 <xsl:template name="SplitTextOnMultipleLines" as="element()+">
	<xsl:param name="textTokens" as="xs:string+"/>
	<xsl:param name="text" as="xs:string"/>
	<xsl:param name="pos" as="xs:integer"/>	
	<xsl:param name="maxLineLength" as="xs:integer"/>		
	

	
	<xsl:choose>
		<xsl:when test="$pos &gt; count($textTokens)">
			<xsl:if test="string-length($text) ne 0 ">
				<tso:line><xsl:value-of select="$text"/></tso:line>		
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="textAdd" select="normalize-space(concat($text, ' ' , $textTokens[$pos]))"/>					
			<xsl:choose>
				<xsl:when test="string-length($textAdd) &gt; $maxLineLength"> 
					<tso:line><xsl:value-of select="$text"/></tso:line>
					<xsl:call-template name="SplitTextOnMultipleLines">
						<xsl:with-param name="textTokens" select="$textTokens" />
						<xsl:with-param name="text" select="''" />
						<xsl:with-param name="pos" select="$pos" />	
						<xsl:with-param name="maxLineLength" select="$maxLineLength" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="SplitTextOnMultipleLines">
						<xsl:with-param name="textTokens" select="$textTokens" />
						<xsl:with-param name="text" select="$textAdd" />
						<xsl:with-param name="pos" select="$pos+1" />	
						<xsl:with-param name="maxLineLength" select="$maxLineLength" />
					</xsl:call-template>			
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	
<xsl:template name="tso:TypeChoice" as="element()*">
	<xsl:param name="showPrimary" as="xs:boolean" select="true()" />
	<xsl:param name="showSecondary" as="xs:boolean" select="true()" />	
	<xsl:param name="showDraft" as="xs:boolean" select="false()" />	
	<xsl:param name="showImpacts" as="xs:boolean" select="false()" />	
	<xsl:param name="selected" as="xs:string" select="''" />	
	<div id="checkboxes">
		<div class="searchCol2">
			<xsl:choose>
				<xsl:when test="$showDraft">
					<div class="typeCheckBoxDoubleCol">
							<input type="checkbox" name="type" value="draft" checked="checked">
								<xsl:if test="contains($selected, 'draft')">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label>All Draft</label>	
					</div>				
				</xsl:when>
				<xsl:when test="$showImpacts">
					<div class="typeCheckBoxDoubleCol">
							<input type="checkbox" name="type" value="ukia" checked="checked">
								<xsl:if test="contains($selected, 'impacts')">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label>UK Impact Assessments</label>	
					</div>				
				</xsl:when>
				<xsl:otherwise>
					<div class="typeCheckBoxDoubleCol">
						<xsl:if test="$showPrimary and $showSecondary">
									<input type="checkbox" name="type" value="all">
										<xsl:if test="contains($selected, 'all')">
											<xsl:attribute name="checked"/>
										</xsl:if>
									</input>
							<label>All Legislation</label>
						</xsl:if>
				
						<xsl:if test="$showPrimary">
									<input type="checkbox" name="type" value="primary">
										<xsl:if test="contains($selected, 'primary')">
											<xsl:attribute name="checked"/>
										</xsl:if>
									</input>
							<label>All Primary</label>
						</xsl:if>
					</div>
						
					<xsl:if test="$showSecondary">
							<div id="allSecondary"  class="typeCheckBoxCol">
								<input type="checkbox" name="type" value="secondary">
									<xsl:if test="contains($selected, 'secondary')">
										<xsl:attribute name="checked"/>
									</xsl:if>					
								</input>
						<label>All Secondary</label>	
							</div>
					</xsl:if>					
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="$showPrimary">
						<div id="primaryLeg" class="typeCheckBoxCol">
					<xsl:for-each select="$tso:legTypeMap[@class = 'primary']">
						<div>
									<input type="checkbox" id="type{@abbrev}" name="type" value="{@abbrev}">
										<xsl:if test="contains($selected, @abbrev)">
											<xsl:attribute name="checked"/>
										</xsl:if>					
									</input>
							<label for="type{@abbrev}"><xsl:value-of select="@plural"/></label>
						</div>
					</xsl:for-each>	
				</div>
			</xsl:if>
		
			<xsl:if test="$showSecondary">
				<div id="secondaryLeg" class="typeCheckBoxCol">
					<xsl:for-each select="$tso:legTypeMap[@class = 'secondary']">
						<div>
							<input type="checkbox" name="type" value="{@abbrev}">
								<xsl:if test="contains($selected, @abbrev)">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label for="type"><xsl:value-of select="@plural"/></label>
						</div>
					</xsl:for-each>	
				</div>
			</xsl:if>
			
			<xsl:if test="$showDraft">
				<div id="draftLeg" class="typeCheckBoxCol">
					<xsl:for-each select="$tso:legTypeMap[@class = 'draft']">
						<div>
							<input type="checkbox" name="type" value="{@abbrev}">
								<xsl:if test="contains($selected, @abbrev)">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label for="type"><xsl:value-of select="@plural"/></label>
						</div>
					</xsl:for-each>	
				</div>
			</xsl:if>			
		</div>
	</div>
</xsl:template>
	
<xsl:function name="tso:GetNumberForLegislation" as="xs:string">
	<xsl:param name="type" as="xs:string" />
	<xsl:param name="year" as="xs:string" />
	<xsl:param name="number" as="xs:string" />
	<xsl:value-of>
		<xsl:choose>
			<xsl:when test="$type = ('UnitedKingdomPublicGeneralAct', 'GreatBritainAct', 'EnglandAct', 'IrelandAct', 'NorthernIrelandAct', 'ScottishOldAct')">
				<xsl:text>c. </xsl:text>
				<xsl:value-of select="$number" />
			</xsl:when>
			<xsl:when test="$type = ('UnitedKingdomLocalAct', 'UnitedKingdomLocalActRevised')">
				<xsl:text>c. </xsl:text>
				<xsl:number format="i" value="$number" />
			</xsl:when>
			<xsl:when test="$type = 'ScottishAct'">
				<xsl:choose>
					<xsl:when test="if ($year castable as xs:integer) then xs:integer($year) &lt; 1800 else false()">c. <xsl:value-of select="$number" /></xsl:when>
					<xsl:otherwise>asp <xsl:value-of select="$number" /></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = ('NorthernIrelandParliamentAct', 'NorthernIrelandAssemblyMeasure')">Chapter <xsl:value-of select="$number" /></xsl:when>
			<xsl:when test="$type = 'WelshAssemblyMeasure'">nawm <xsl:value-of select="$number" /></xsl:when>
			<xsl:otherwise>No. <xsl:value-of select="$number" /></xsl:otherwise>
		</xsl:choose>
	</xsl:value-of>
</xsl:function>

<xsl:function name="tso:TitleCase">
	<xsl:param name="strText" />
	<xsl:value-of select="upper-case(substring($strText, 1, 1))" />
	<xsl:variable name="strRest" select="substring($strText, 2)" />
	<xsl:choose>
		<xsl:when test="contains($strText, ' ')">
			<xsl:value-of select="substring-before($strRest, ' ')" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="tso:TitleCase(substring-after($strRest, ' '))"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$strRest" />
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:function>

<!-- Wording for Category (Act, Rule, Measure, Instrument, Order) , used in opening options on ui -->
<xsl:function name="tso:GetCategory">
	<xsl:param name="legType" as="xs:string" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@category" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- Wording for EN  tab/label -->
<xsl:function name="tso:GetENLabel">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="enType" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
		<xsl:when test="exists($type/@en) and $enType ='en'">
			<xsl:value-of select="$type/@en"/>
		</xsl:when>
		<xsl:when test="exists($type/@em) and $enType ='em' ">
			<xsl:value-of select="$type/@em"/>
		</xsl:when>		
		<xsl:when test="exists($type) and exists($type/@en)">
			<xsl:value-of select="$type/@en"/>
		</xsl:when>
		<xsl:when test="exists($type) and exists($type/@em)">
			<xsl:value-of select="$type/@em"/>
		</xsl:when>
		<xsl:otherwise>
			()
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- Default Type for EN /EM tab -->
<xsl:function name="tso:GetDefaultENType">
	<xsl:param name="legType" as="xs:string" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
		<xsl:when test="exists($type) and exists($type/@em)"> <!-- getting the default For UKSI -->
			<xsl:value-of select="'em' "/>
		</xsl:when>		
		<xsl:when test="exists($type) and exists($type/@en)">
			<xsl:value-of select="'en'"/>
		</xsl:when>		
		<xsl:otherwise>
			()
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:ENInterweavedAllowed" as="xs:boolean">
	<xsl:param name="type" as="xs:string" />
	<xsl:value-of select="$type = ('UnitedKingdomPublicGeneralAct', 'WelshAssemblyMeasure', 'ScottishAct', 'NorthernIrelandOrderInCouncil')" /> 
</xsl:function>


<xsl:function name="tso:GetShortCitation">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string" />
	<xsl:param name="leg:Number" as="xs:string" />
	<xsl:sequence select="tso:GetShortCitation($legType, $legYear, $leg:Number, ())" />
</xsl:function>

<xsl:function name="tso:GetShortCitation">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string" />
	<xsl:param name="legNumber" as="xs:string" />
	<xsl:param name="legSection" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
	  <xsl:when test="$type/@class = 'primary' and not($legType = 'NorthernIrelandOrderInCouncil')">
	  	<xsl:value-of select="$legYear" />
	  	<xsl:text> </xsl:text>
	  	<xsl:value-of select="tso:GetNumberForLegislation($legType, $legYear, $legNumber)" />
	  	<xsl:if test="$legType = ('NorthernIrelandAct', 'NorthernIrelandAssemblyMeasure', 'NorthernIrelandParliamentAct')"> (N.I.)</xsl:if>
	  </xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$legType = 'WelshStatutoryInstrument'">W.S.I. </xsl:when>
				<xsl:when test="$legType = 'ScottishStatutoryInstrument'">S.S.I. </xsl:when>
				<xsl:when test="$legType = 'NorthernIrelandStatutoryRule'">S.R. </xsl:when>
				<xsl:otherwise>S.I. </xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$legYear" />
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$legNumber" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:GetShortOPSIPrefix">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string" />
	<xsl:param name="legNumber" as="xs:string" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
	  <xsl:when test="$type/@class = 'primary' and not($legType = 'NorthernIrelandOrderInCouncil')">
	  	<xsl:value-of select="$legYear" />
	  	<xsl:text> </xsl:text>
	  	<xsl:value-of select="tso:GetNumberForLegislation($legType, $legYear, $legNumber)" />
	  </xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$legType = 'ScottishStatutoryInstrument'">SSI </xsl:when>
				<xsl:when test="$legType = 'NorthernIrelandStatutoryRule'">SR </xsl:when>
				<xsl:otherwise>SI </xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$legYear" />
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$legNumber" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:httpDateTime" as="xs:string">
	<xsl:param name="dateTime" as="xs:dateTime" />
	<xsl:sequence select="format-dateTime(adjust-dateTime-to-timezone($dateTime, xs:dayTimeDuration('PT0H')), '[FNn,3-3], [D01] [MNn,3-3] [Y] [H01]:[m]:[s] GMT')"/>
</xsl:function>

<xsl:function name="tso:countryType" as="xs:string">
	<xsl:param name="legType" as="xs:string" />
	<xsl:choose>
		<xsl:when test="contains($legType, 'UnitedKingdom')">United Kingdom</xsl:when>
		<xsl:when test="contains($legType, 'Scottish')">Scotland</xsl:when>
		<xsl:when test="contains($legType, 'NorthernIreland') or contains($legType, 'Ireland')">Northern Ireland</xsl:when>
		<xsl:when test="contains($legType, 'Welsh')">Wales</xsl:when>
		<xsl:otherwise>()</xsl:otherwise>
	</xsl:choose>
</xsl:function>	

<!--
<xsl:function name="tso:effectKey" as="xs:string">
	<xsl:param name="effect" as="element()" />
	<xsl:sequence select="$effect/string-join((
		@AffectedClass, @AffectedYear, @AffectedNumber, 
		if (exists(@AffectedSectionRef)) then 
			@AffectedSectionRef
		else if (exists(@AffectedStartSectionRef)) then 
			(@AffectedStartSectionRef, @AffectedEndSectionRef)
		else
			@AffectedProvision,
		@Type,
		if (@CommencingClass) then (
			@CommencingClass, @CommencingYear, @CommencingNumber
		) else (
			@AffectingClass, @AffectingYear, @AffectingNumber
		),
		@Applied,
		@Note
	), '+')" />
</xsl:function>
-->

<xsl:function name="tso:formatISBN" as="xs:string">
	<xsl:param name="strISBN" as="xs:string" />
	<xsl:value-of>
		<xsl:choose>
			<xsl:when test="$strISBN = ''" />
			<xsl:when test="string-length($strISBN) = 13">
				<xsl:value-of select="substring($strISBN, 1, 3)" />
				<xsl:text>-</xsl:text>
				<xsl:value-of select="tso:formatISBN(substring($strISBN, 4))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring($strISBN, 1, 1)" />
				<xsl:text>-</xsl:text>
				<xsl:choose>
					<xsl:when test="substring($strISBN, 2, 1) = ('0', '1')">
						<xsl:value-of select="substring($strISBN, 2, 2)" />
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring($strISBN, 4, 6)" />
					</xsl:when>
					<xsl:when test="xs:integer(substring($strISBN, 2, 1)) &lt; 7">
						<xsl:value-of select="substring($strISBN, 2, 3)" />
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring($strISBN, 5, 5)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring($strISBN, 2, 4)" />
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring($strISBN, 6, 4)" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>-</xsl:text>
				<xsl:value-of select="substring($strISBN, 10)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:value-of>
</xsl:function>

<xsl:function name="tso:extentDescription">
	<xsl:param name="extentsToken" as="xs:string+" />
	<xsl:sequence select="tso:extentDescription($extentsToken, ' and ', false())" />
</xsl:function>

<xsl:function name="tso:extentDescription">
	<xsl:param name="extentsToken" as="xs:string+" />
	<xsl:param name="finalSeparator" as="xs:string" />
	<xsl:param name="emphasise" as="xs:boolean" />
	<xsl:for-each select="$extentsToken">
		<xsl:variable name="country" as="xs:string?">
			<xsl:choose>
				<xsl:when test=". = 'uk'">the United Kingdom</xsl:when>
				<xsl:when test=". = 'gb'">Great Britain</xsl:when>
				<xsl:when test=". = 'ew'">England &amp; Wales</xsl:when>
				<xsl:when test=". = ('england', 'E')">England</xsl:when>
				<xsl:when test=". = ('wales', 'W')">Wales</xsl:when>
				<xsl:when test=". = ('ni', 'N.I.')">Northern Ireland</xsl:when>
				<xsl:when test=". = ('scotland', 'S')">Scotland</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$emphasise"><strong><xsl:value-of select="$country" /></strong></xsl:when>
			<xsl:otherwise><xsl:value-of select="$country" /></xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="position () = (last() - 1)"><xsl:value-of select="$finalSeparator" /></xsl:when>
			<xsl:when test="position() != last()">, </xsl:when>
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
	<token token="contents" text="contents" />
</xsl:variable>

<xsl:function name="tso:formatSection" as="xs:string">
	<xsl:param name="string" as="xs:string"/>
	<xsl:param name="token" as="xs:string"/>
	<xsl:sequence select="tso:formatSection($string, $token, ())" />
</xsl:function>

<!-- Produce readable text of a section reference. -->
<xsl:function name="tso:formatSection" as="xs:string">
	<xsl:param name="string" as="xs:string"/>
	<xsl:param name="token" as="xs:string"/>
	<xsl:param name="relativeTo" as="xs:string?" />
	<xsl:variable name="tokenised" as="xs:string+" select="tokenize($string, $token)"/>
	<xsl:variable name="relativeToTokenised" select="tokenize($relativeTo, $token)" />
	<xsl:variable name="skip" as="xs:integer*">
		<xsl:for-each select="$tokenised">
			<xsl:variable name="i" select="position()" />
			<xsl:if test="not(. = $relativeToTokenised[$i])">
				<xsl:sequence select="$i" />
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="skip" as="xs:integer" select="if (empty($skip)) then count($tokenised) else $skip[1]" />
	<xsl:variable name="output" select="subsequence($tokenised, $skip)" />
	<xsl:value-of>
		<xsl:for-each select="$output">
			<xsl:variable name="position" select="position()"/>
			<xsl:variable name="previousToken" select="$tokenised[($skip - 1) + ($position - 1)]" />
			<xsl:choose>
				<xsl:when test=". = $sectionTokens/@token">
					<!-- sometimes a schedule does not have a number so we do not want a double space - exclude if the previous token is a section token  -->
					<xsl:if test="$position &gt; 1 and not($previousToken = $sectionTokens/@token)">
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="$sectionTokens[@token = current()]/@text" />
					<xsl:if test="$sectionTokens[@token = current()]/@text != 'contents' and not(position() = last())">
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$previousToken = $sectionTokens/@token">
					<xsl:value-of select="." />
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

</xsl:stylesheet>
