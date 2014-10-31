<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml" version="2.0" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:db="http://docbook.org/ns/docbook"
	xmlns:sls="http://sls" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:atom="http://www.w3.org/2005/Atom" xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/">
	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="../../common/utils.xsl"/>
	<xsl:import href="unapplied_effects_xhtml.xsl"/>
	<xsl:import href="searchcommon_xhtml.xsl"/>



	<xsl:variable name="paramsDoc" as="document-node()">
		<xsl:choose>
			<xsl:when test="doc-available('input:request')">
				<xsl:sequence select="doc('input:request')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:document>
					<parameters xmlns="">
						<type>aep</type>
					</parameters>
				</xsl:document>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="requestInfoDoc" as="document-node()?">
		<xsl:if test="doc-available('input:request-info')">
			<xsl:sequence select="doc('input:request-info')"/>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="g_nstCodeLists" select="document('../../codelists.xml')/CodeLists/CodeList"/>

	<xsl:variable name="sort" as="xs:string?" select="$paramsDoc/parameters/sort"/>
	<xsl:variable name="order" as="xs:string?" select="$paramsDoc/parameters/order"/>


	<xsl:template match="/">
		<html>
			<head>
				<!--
				<xsl:variable name="lastModified" as="xs:dateTime?" select="max((/atom:feed/atom:updated, /atom:feed/atom:entry/atom:updated)/xs:dateTime(.))" />
				<xsl:variable name="lastModified" as="xs:dateTime" select="if (exists($lastModified)) then $lastModified else current-dateTime()" />
 				<meta name="DC.Date.Modified" content="{adjust-date-to-timezone(xs:date($lastModified), ())}" />
				<meta http-equiv="Last-Modified" content="{tso:httpDateTime($lastModified)}" />
-->
                <script type="text/javascript" src="/scripts/formFunctions/common.js"></script>
                <script type="text/javascript" src="/scripts/changesLeg/search.js"></script>
				<link type="text/css" href="/styles/per/changeLeg.css" rel="stylesheet"/>
				
				<xsl:apply-templates select="/atom:feed/atom:link" mode="HTMLmetadata"/>
			</head>

			<body lang="{$TranslateLang}" xml:lang="{$TranslateLang}" dir="ltr" id="doc" class="changeLeg">

				<div id="layout2">
					<!-- <span class="debug">
						[Title is: <xsl:value-of select="$paramsDoc/parameters/title"/>]
						[Year is: <xsl:value-of select="$paramsDoc/parameters/year"/>]
						[Number is: <xsl:value-of select="$paramsDoc/parameters/number"/>]
						[Type is: <xsl:value-of select="$paramsDoc/parameters/type"/>]
						[ID is: <xsl:value-of select="$id"/>]
						[Class is: <xsl:value-of select="$class"/>]
					</span> -->

					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>

					<div>
						<div class="info">
						
							<h1 id="pageTitle">
								<xsl:variable name="pageTitle">
									<xsl:text>Changes to Legislation</xsl:text>
									<xsl:if test="atom:feed"><xsl:text> Results</xsl:text></xsl:if>
								</xsl:variable>
								<xsl:value-of select="leg:TranslateText($pageTitle)"/>
							</h1>

							<!-- adding search summary -->
							<xsl:apply-templates select="atom:feed" mode="summary"/>
						</div>
					</div>

					<div id="content">
						<xsl:if test="not(atom:feed)">
							<div class="s_12 p_one introWrapper">
								<h2><xsl:value-of select="leg:TranslateText('New_subtitle')"/></h2>
								<p><xsl:value-of select="leg:TranslateText('New_p1')"/></p>
								<p><xsl:value-of select="leg:TranslateText('New_p2')"/></p>
								<p><xsl:value-of select="leg:TranslateText('New_p3')"/></p>
							</div>
						</xsl:if>
						<div class="s_12 p_one tabWrapper createNewSearchOpt">
							<h2 class="accessibleText"><xsl:value-of select="leg:TranslateText('Search')"/></h2>
							<xsl:choose>
								<xsl:when test="atom:feed">
									<div id="existingSearch">
										<div id="newSearch" class="interface">
											<a id="modifySearch" href="#searchChanges"
												class="userFunctionalElement">
												<span class="btl"/>
												<span class="btr"/>
												<xsl:value-of select="leg:TranslateText('Modify existing search')"/>
												<span class="bbl"/>
												<span class="bbr"/>
											</a>
										</div>
										<xsl:call-template name="TSOOutputChangesSearch"/>
									</div>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="TSOOutputChangesSearch"/>
								</xsl:otherwise>							
							</xsl:choose>
						</div>
						
						<xsl:if test="not(atom:feed)">
							<div class="s_12 p_one introWrapper">
								<h2><xsl:value-of select="leg:TranslateText('Changes to Local and Private and Personal Acts')"/></h2>
								<p><xsl:value-of select="leg:TranslateText('Changes_chnoTable_desc')"/></p>
								<ul class="linkList">
									<li>
										<a href="http://www.legislation.gov.uk/changes/chron-tables/local"><xsl:value-of select="leg:TranslateText('Chronological Table of Local Acts')"/> <span class="pageLinkIcon"></span></a>
									</li>
									<li>
										<a href="http://www.legislation.gov.uk/changes/chron-tables/private"><xsl:value-of select="leg:TranslateText('Chronological Table of Private and Personal Acts')"/> <span class="pageLinkIcon"></span></a>
									</li>
								</ul>
							</div>
						</xsl:if>

						<!-- displaying the search results-->
						<xsl:apply-templates select="atom:feed" mode="results"/>
						<!--/#content-->
					</div>
					<!--/#layout1-->
					
					<xsl:call-template name="TSOOutputTooltips"/>
				</div>
			</body>
		</html>
	</xsl:template>	

	<!-- ========== Standard code for search summary========= -->
	<xsl:template match="atom:feed" mode="summary">
		<h2>
			<xsl:variable name="searchResultMessage">
				<xsl:text>Your search for</xsl:text>
				<xsl:apply-templates select="$paramsDoc/parameters/applied" mode="summary"/>
				<xsl:text> that affect</xsl:text>
				<xsl:apply-templates select="$paramsDoc/parameters/affected-type" mode="summary"/>
				<xsl:apply-templates select="$paramsDoc/parameters/affected-year" mode="summary"/>			
				<xsl:apply-templates select="$paramsDoc/parameters/affected-number" mode="summary"/>			
				<xsl:text> made by</xsl:text>			
				<xsl:apply-templates select="$paramsDoc/parameters/affecting-type" mode="summary"/>
				<xsl:apply-templates select="$paramsDoc/parameters/affecting-year" mode="summary"/>			
				<xsl:apply-templates select="$paramsDoc/parameters/affecting-number" mode="summary"/>		
				<xsl:text> has returned </xsl:text>
	
				<xsl:variable name="pageSize" as="xs:integer" select="20"/>
				<xsl:choose>
					<xsl:when test="openSearch:totalResults > 200">more than 200</xsl:when>
					<xsl:when test="openSearch:totalResults">
						<xsl:value-of select="openSearch:totalResults" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="round-half-to-even((leg:page + leg:morePages) * $pageSize, -1) > 200">  more than 200 </xsl:when>
							<xsl:otherwise> about <xsl:value-of select="round-half-to-even((leg:page + leg:morePages) * $pageSize, -1)"/></xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>			
				<xsl:text> results:</xsl:text>		
			</xsl:variable>
			<!-- added this code to display messages in welsh language for welsh version of site-->
			<xsl:variable name="fr" select="('Your search for','changes','that affect','has returned','more than','results','made by','all legislation','in','between','and','unapplied','applied','numbered')"/>
			<xsl:variable name="to" select="('Mae eich chwiliad am','newidiadau','sy’n effeithio ar','wedi dod o hyd i ','fwy na','o ganlyniadau','a wnaed gan','holl ddeddfwriaeth','yn','rhwng','a','heb eu gweithredu','weithredwyd','rhifo')"/>
			<xsl:choose>
				<xsl:when test="$TranslateLang='cy'"><xsl:value-of select="leg:replace-multi($searchResultMessage,$fr,$to)"/></xsl:when>
				<xsl:otherwise>	<xsl:value-of select="$searchResultMessage"/></xsl:otherwise>
			</xsl:choose>		
		</h2>
	</xsl:template>
	<xsl:template match="affected-type | affecting-type" mode="summary">
		<xsl:choose>
			<xsl:when test="string-length(.) > 0 and . != 'all' and . != '*' ">
				<xsl:variable name="type" select="."/>
				<xsl:text> </xsl:text>
				<strong><xsl:value-of select="$tso:legTypeMap[@abbrev=$type]/@plural"/></strong>
			</xsl:when>		
			<xsl:otherwise>
				<xsl:text> all legislation</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="affected-year | affecting-year" mode="summary">
		<xsl:choose>
			<xsl:when test="contains(., '-')">
				<xsl:text> between </xsl:text>
				<strong><xsl:value-of select="substring-before(.,'-')"/>
				<xsl:text> and </xsl:text>
				<xsl:value-of select="substring-after(.,'-')"/></strong>
			</xsl:when>
			<xsl:when test=". = '*' "/>
			<xsl:when test="string-length(.) > 0">
				<xsl:text> in </xsl:text>
				<strong><xsl:value-of select="."/></strong>
			</xsl:when>
		</xsl:choose>
	</xsl:template>	
	<xsl:template match="affected-number | affecting-number" mode="summary">
		<xsl:if test="string-length(.) > 0">
			<xsl:text> numbered </xsl:text>
			<strong><xsl:value-of select="."/></strong>
		</xsl:if>
	</xsl:template>	
	<xsl:template match="applied" mode="summary">
		<xsl:choose>
			<xsl:when test=". = 'applied' ">
				<strong>
					<xsl:text> applied</xsl:text>
				</strong>
			</xsl:when>	
			<xsl:when test=". = 'unapplied' ">
				<strong>
					<xsl:text> unapplied</xsl:text>
				</strong>
			</xsl:when>	
		</xsl:choose>	
		<xsl:text> changes</xsl:text>
	</xsl:template>


	<!-- ========== Standard code for search form========= -->
	<xsl:template name="TSOOutputChangesSearch">
		<form action="{$TranslateLangPrefix}/changes" id="searchChanges" class="s_12 p_one">
			<xsl:if test="/errorsearching">
				<div id="errorBar" class="error errorMessage"><xsl:value-of select="leg:TranslateText('Please check the form fields which are highlighted in red')"/></div>		
			</xsl:if>
			<fieldset id="affect" class="s_5 p_one">
				<div>
					<a class="helpItem helpItemToTop" href="#changesThatAffectHelp">
						<img alt="Changes that affect help" src="/images/chrome/helpIcon.gif" />
					</a>
					<legend><xsl:value-of select="leg:TranslateText('Changes that affect')"/>:</legend>						
				</div>
				<div class="title">
					<label for="affected-title"><xsl:value-of select="leg:TranslateText('Title')"/>:</label>
					<input id="affected-title" name="affected-title" type="text" value="{$paramsDoc/parameters/affected-title}"/>
				</div>
				<div class="typeChoice">
					
					<xsl:variable name="invalidAffectedType" as="xs:boolean"
						select="exists($paramsDoc/parameters/affected-type[not(. = ('', 'all',$g_nstCodeLists[@name = 'DocumentMainType']/Code[@status='revised']/@uri) )])"/>
						
					<label for="affected-type">
						<xsl:if test="$invalidAffectedType">
							<xsl:attribute name="class">error</xsl:attribute>						
						</xsl:if>
						<xsl:value-of select="leg:TranslateText('Legislation type')"/>
						<xsl:text>:</xsl:text>
					</label>
					<select id="affected-type" name="affected-type">
						<xsl:if test="$invalidAffectedType">
							<xsl:attribute name="class">error</xsl:attribute>						
						</xsl:if>					
						<option value=""><xsl:value-of select="leg:TranslateText('Any')"/></option>
						<xsl:for-each
							select="$g_nstCodeLists[@name = 'DocumentMainType']/Code[@status='revised']">
							<option value="{@uri}">
								<xsl:if test="$paramsDoc/parameters/affected-type = @uri">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="tso:GetTitleFromType(@schema,'')"/>
							</option>
						</xsl:for-each>
					</select>
					<xsl:if test="$invalidAffectedType">
						<span class="error errorMessage"><xsl:value-of select="leg:TranslateText('Not a valid revised legislation type')"/></span>									
					</xsl:if>					
				</div>



				<div class="yearChoice">
				
					<xsl:variable name="invalidAffectedYear" as="xs:boolean"
						select="exists($paramsDoc/parameters/affected-year[. castable as xs:integer
									and xs:integer(.) &gt; year-from-date(current-date())])"/>
													
					<input type="radio" name="affected-year-choice" id="affected-year-specific"
						value="specific" class="yearChoice radio" checked="checked">
						<xsl:if test="$paramsDoc/parameters/affected-year-choice = 'specific'
							or $paramsDoc/parameters/affected-year[not(contains(., '-'))]">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="affected-year-specific"><xsl:value-of select="leg:TranslateText('Specific year and number')"/></label>
					<div class="yearChoiceFields" id="affectsSingleYear">
						<div class="from">
							<label for="affected-year">
								<xsl:if test="$invalidAffectedYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Year')"/>
								<xsl:text>:</xsl:text>
							</label>
							
							<input id="affected-year" name="affected-year" type="text"
								value="{if ($paramsDoc/parameters/affected-year[contains(.,'-') or . = '*']) then '' else $paramsDoc/parameters/affected-year}">
								<xsl:if test="$invalidAffectedYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>								
							</input>
							
							<xsl:if test="$invalidAffectedYear">
								<span class="error errorMessage"><xsl:value-of select="leg:TranslateText('Year_before_current',concat('year=',string(year-from-date(current-date()))))"/></span>									
							</xsl:if>	
							
						</div>
						<div class="number">
							<label for="affected-number"><xsl:value-of select="leg:TranslateText('Number')"/>:</label>
							<input id="affected-number" name="affected-number" type="text"
								value="{$paramsDoc/parameters/affected-number}"/>
						</div>
					</div>
				</div>
				<div class="yearChoice">
				
					<xsl:variable name="invalidAffectedYearStart" as="xs:boolean"
						select="exists($paramsDoc/parameters/affected-year[
										contains(., '-') and substring-before(., '-') castable as xs:integer  
										and 
										(
										xs:integer(substring-before(., '-')) &gt; year-from-date(current-date())
											 or 
											 (
												 substring-after(., '-') castable as xs:integer  
												 and 	xs:integer(substring-before(., '-')) &gt; xs:integer(substring-after(., '-'))
											 )
										 )
										 ])"/>
	
					<xsl:variable name="invalidAffectedYearEnd" as="xs:boolean"
						select="exists($paramsDoc/parameters/affected-year[
										contains(., '-') and substring-after(., '-') castable as xs:integer  
										and 
										(
										xs:integer(substring-after(., '-')) &gt; year-from-date(current-date())
											 or 
											 (
												 substring-before(., '-') castable as xs:integer  
												 and 	xs:integer(substring-before(., '-')) &gt; xs:integer(substring-after(., '-'))
											 )
										 )
										 ])"/>									
										
					<input type="radio" name="affected-year-choice" id="affected-year-choice-range"
						value="range" class="yearChoice radio">
						<xsl:if test="$paramsDoc/parameters/affected-year-choice = 'range'
							or $paramsDoc/parameters/affected-year[contains(., '-')]
						 ">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="affected-year-choice-range"><xsl:value-of select="leg:TranslateText('Range of years')"/></label>
					<div class="yearChoiceFields" id="affectedRangeYears">
						<div class="from">
							<label for="affected-start-year">
								<xsl:if test="$invalidAffectedYearStart">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('From')"/>
								<xsl:text>:</xsl:text>
							</label>
							<input id="affected-start-year" name="affected-start-year" type="text"
								value="{
								if ($paramsDoc/parameters/affected-start-year[. != '']) then  $paramsDoc/parameters/affected-start-year
								else if ($paramsDoc/parameters/affected-year[contains(.,'-')]) then substring-before($paramsDoc/parameters/affected-year, '-')
								else ''}">
								<xsl:if test="$invalidAffectedYearStart">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>										
							</input>
						</div>
						<div class="to">
							<label for="affected-end-year">
								<xsl:if test="$invalidAffectedYearEnd">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('To')"/>
								<xsl:text>:</xsl:text>							
							</label>
							<input id="affected-end-year" name="affected-end-year" type="text"
								value="{
								if ($paramsDoc/parameters/affected-end-year[. != '']) then  $paramsDoc/parameters/affected-end-year
								else if ($paramsDoc/parameters/affected-year[contains(.,'-')]) then substring-after($paramsDoc/parameters/affected-year, '-')
								else ''}">
									<xsl:if test="$invalidAffectedYearEnd">
										<xsl:attribute name="class">error</xsl:attribute>
									</xsl:if>									
							</input>
						</div>

						<xsl:if test="$invalidAffectedYearStart or $invalidAffectedYearEnd">
							<span class="error errorMessage"><xsl:value-of select="leg:TranslateText('Year_before_range',concat('year=',string(year-from-date(current-date()))))"/></span>									
						</xsl:if>	
					</div>
				</div>
			</fieldset>
			<fieldset id="affecting" class="s_5 p_two">
				<div>
					<a class="helpItem helpItemToTop" href="#madeByHelp">
						<img alt="Made by help" src="/images/chrome/helpIcon.gif" />
					</a>	
					<legend><xsl:value-of select="leg:TranslateText('made by')"/>:</legend>										
				</div>
				<div class="title">
					<label for="affecting-title">Title:</label>
					<input id="affecting-title" name="affecting-title" type="text" value="{$paramsDoc/parameters/affecting-title}"/>
				</div>
				<div class="typeChoice">
					<xsl:variable name="invalidAffectingType" as="xs:boolean"
						select="exists($paramsDoc/parameters/affecting-type[not(. = ('', 'all',tso:GetEffectingTypes()/@abbrev) )])"/>
										
					<label for="affecting-type">
						<xsl:if test="$invalidAffectingType">
							<xsl:attribute name="class">error</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="leg:TranslateText('Legislation type')"/>
						<xsl:text>:</xsl:text>
					</label>
					<select id="affecting-type" name="affecting-type">
						<xsl:if test="$invalidAffectingType">
							<xsl:attribute name="class">error</xsl:attribute>
						</xsl:if>
						<option value=""><xsl:value-of select="leg:TranslateText('Any')"/></option>
						<xsl:for-each select="tso:GetEffectingTypes()">
							<option value="{@abbrev}">
								<xsl:if test="$paramsDoc/parameters/affecting-type = @abbrev">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="@plural"/>
							</option>
						</xsl:for-each>
					</select>
					<xsl:if test="$invalidAffectingType">
						<span class="error errorMessage"><xsl:value-of select="leg:TranslateText('Not a valid legislation type')"/></span>									
					</xsl:if>					
				</div>
				<div class="yearChoice">
					<xsl:variable name="invalidAffectingYear" as="xs:boolean"
						select="exists($paramsDoc/parameters/affecting-year[. castable as xs:integer
									and (xs:integer(.) &gt; year-from-date(current-date()) or xs:integer(.) &lt; 2002)])"/>
				
					<input type="radio" name="affecting-year-choice"
						id="affecting-year-choice-specific" value="specific"
						class="yearChoice radio" checked="checked">
						<xsl:if test="$paramsDoc/parameters/affecting-year-choice = 'specific'
							or $paramsDoc/parameters/affecting-year[not(contains(., '-'))]">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="affecting-year-choice-specific"><xsl:value-of select="leg:TranslateText('Specific year and number')"/></label>
					<div class="yearChoiceFields" id="affectingSingleYear">
						<div class="from">
							<label for="affecting-year">
								<xsl:if test="$invalidAffectingYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>	
								<xsl:value-of select="leg:TranslateText('Year')"/>
								<xsl:text>:</xsl:text>
							</label>
							<select name="affecting-year" id="affecting-year">
								<xsl:if test="$invalidAffectingYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>										
								<option value="" selected="selected"><xsl:value-of select="leg:TranslateText('Any')"/></option>
								<xsl:for-each select="2002 to year-from-date(current-date())">
									<option value="{.}">
										<xsl:if
											test="$paramsDoc/parameters/affecting-year castable as xs:integer and . = xs:integer($paramsDoc/parameters/affecting-year)">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="."/>
									</option>
								</xsl:for-each>
							</select>
							
							<xsl:if test="$invalidAffectingYear">
								<span class="error errorMessage">
									<xsl:value-of select="year-from-date(current-date())"/>
								</span>									
							</xsl:if>	
														
						</div>
						<div class="number">
							<label for="affecting-number"><xsl:value-of select="leg:TranslateText('Number')"/>:</label>
							<input id="affecting-number" name="affecting-number" type="text"
								value="{$paramsDoc/parameters/affecting-number}"/>
						</div>
					</div>
				</div>
				<div class="yearChoice">
				
					<xsl:variable name="invalidAffectingYearStart" as="xs:boolean"
						select="exists($paramsDoc/parameters/affecting-year[
										contains(., '-') and substring-before(., '-') castable as xs:integer  
										and 
										(
										 (xs:integer(substring-before(., '-')) &gt; year-from-date(current-date()) or xs:integer(substring-before(., '-')) &lt; 2002)
											 or 
											 (
												 substring-after(., '-') castable as xs:integer  
												 and 	xs:integer(substring-before(., '-')) &gt; xs:integer(substring-after(., '-'))
											 )
										 )
										 ])"/>
	
					<xsl:variable name="invalidAffectingYearEnd" as="xs:boolean"
						select="exists($paramsDoc/parameters/affecting-year[
										contains(., '-') and substring-after(., '-') castable as xs:integer  
										and 
										(
										  (xs:integer(substring-after(., '-')) &gt; year-from-date(current-date()) or xs:integer(substring-after(., '-')) &lt; 2002)
											 or 
											 (
												 substring-before(., '-') castable as xs:integer  
												 and 	xs:integer(substring-before(., '-')) &gt; xs:integer(substring-after(., '-'))
											 )
										 )
										 ])"/>
										 									
										 
					<input type="radio" name="affecting-year-choice"
						id="affecting-year-choice-range" value="range" class="yearChoice radio">
						<xsl:if test="$paramsDoc/parameters/affecting-year-choice = 'range' 
											or $paramsDoc/parameters/affecting-year[contains(., '-')]">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="affecting-year-choice-range"><xsl:value-of select="leg:TranslateText('Range of years')"/></label>
					<div class="yearChoiceFields" id="affectingRangeYears">
						<div class="from">
							<label for="affecting-start-year">
								<xsl:if test="$invalidAffectingYearStart">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('From')"/>
								<xsl:text>:</xsl:text>
							</label>
							<select name="affecting-start-year" id="affecting-start-year">
								<xsl:if test="$invalidAffectingYearStart">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<option value="" selected="selected"><xsl:value-of select="leg:TranslateText('YYYY')"/></option>
								<xsl:for-each select="2002 to year-from-date(current-date())">
									<option value="{.}">
										<xsl:if
											test="($paramsDoc/parameters/affecting-start-year castable as xs:integer and . = xs:integer($paramsDoc/parameters/affecting-start-year))
													or ($paramsDoc/parameters/affecting-year[contains(., '-') and substring-before(.,'-') castable as xs:integer] and . = xs:integer(substring-before($paramsDoc/parameters/affecting-year,'-')))
											">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="."/>
									</option>
								</xsl:for-each>
							</select>
						</div>
						<div class="to">
							<label for="affecting-end-year">
								<xsl:if test="$invalidAffectingYearEnd">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('To')"/>
								<xsl:text>:</xsl:text>
							</label>
							<select name="affecting-end-year" id="affecting-end-year">
								<xsl:if test="$invalidAffectingYearEnd">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
							
								<option value="" selected="selected"><xsl:value-of select="leg:TranslateText('YYYY')"/></option>
								<xsl:for-each select="2002 to year-from-date(current-date())">
									<option value="{.}">
										<xsl:if
											test="($paramsDoc/parameters/affecting-end-year castable as xs:integer and . = xs:integer($paramsDoc/parameters/affecting-end-year))
													or ($paramsDoc/parameters/affecting-year[contains(., '-') and substring-after(.,'-') castable as xs:integer] and . = xs:integer(substring-after($paramsDoc/parameters/affecting-year,'-')))
											">									
												<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="."/>
									</option>
								</xsl:for-each>
							</select>
						</div>
						
						<xsl:if test="$invalidAffectingYearStart or $invalidAffectingYearEnd">
							<span class="error errorMessage">
								<xsl:value-of select="leg:TranslateText('Year_after_2002',concat('year=',string(year-from-date(current-date()))))"/>	
							</span>									
						</xsl:if>						
					</div>
				</div>
			</fieldset>
			<div id="searchInfo">
				<p/>
				<!-- hook availabale for the JavaScript -->
				<fieldset id="effectsOptions" class="s_6">
					<div>
						<a class="helpItem helpItemToMidRight" href="#resultsShowingHelp">
							<img alt="Results showing help" src="/images/chrome/helpIcon.gif" />
						</a>						
						<legend><xsl:value-of select="leg:TranslateText('Results showing')"/></legend>
					</div>
					<div>
						<input type="radio" id="appliedAll" value="all" name="applied" class="radio"
							checked="checked">
							<xsl:if test="$paramsDoc/parameters/applied = 'all' ">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</input>
						<label for="appliedAll"><xsl:value-of select="leg:TranslateText('All changes')"/></label>
						
						<input type="radio" id="applied" value="applied" name="applied" class="radio">
							<xsl:if test="$paramsDoc/parameters/applied = 'applied' ">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</input>
						<label for="applied"><xsl:value-of select="leg:TranslateText('Applied changes')"/></label>
						
						<input type="radio" id="unapplied" value="unapplied" name="applied"
							class="radio">
							<xsl:if test="$paramsDoc/parameters/applied = 'unapplied' ">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</input>
						<label for="unapplied"><xsl:value-of select="leg:TranslateText('Unapplied changes')"/></label>
						<button type="submit" id="legChangesSearchSubmit" class="userFunctionalElement">
							<span class="btl"/>
							<span class="btr"/><xsl:value-of select="leg:TranslateText('Get Results')"/><span class="bbl"/>
							<span class="bbr"/>
						</button>
					</div>
				</fieldset>
			</div>
		</form>
	</xsl:template>

	<!-- ========== Standard code for search results========= -->
	<xsl:template match="atom:feed" mode="results">

		<!-- Show the table only if there's results. -->
			<xsl:variable name="link" as="xs:string?" select="//atom:link[@rel = 'first']/@href"/>
			<div class="results s_12 p_one">
				<div id="topPager" class="interface">

					<xsl:apply-templates select="/" mode="pagesummary"/>				
					
					<!-- adding the paging details -->
					<xsl:apply-templates select="/" mode="links">
						<xsl:with-param name="maxPageSetSize" select="10"/>
					</xsl:apply-templates>
					
					<xsl:apply-templates select="if (//atom:link[@rel = 'first']) then //atom:link[@rel = 'first']
							else //atom:link[@rel = 'self']" mode="subscribe"/>	
				</div>
				<xsl:choose>
					<xsl:when test="exists(atom:entry)">
						<table>
							<thead>
								<tr class="headerRow1">
									<th colspan="4"><xsl:value-of select="leg:TranslateText('Changes that affect')"/></th>
									<th colspan="3" class="centralCol"><xsl:value-of select="leg:TranslateText('Made by')"/></th>
									<td colspan="2" />							
								</tr>
								<tr class="headerRow2">
									<th>
										<xsl:call-template name="TSOOutputColumnHeader">
											<xsl:with-param name="link" select="$link"/>
											<xsl:with-param name="fieldName" select="'affected-title'"/>
											<xsl:with-param name="fieldTitle" select="leg:TranslateText('Changed Legislation')" />
										</xsl:call-template>
									</th>
									<th>
										<xsl:call-template name="TSOOutputColumnHeader">
											<xsl:with-param name="link" select="$link"/>
											<xsl:with-param name="fieldName" select="'affected-year-number'"/>
											<xsl:with-param name="fieldTitle" select="leg:TranslateText('Year and Number')" />
										</xsl:call-template>
									</th>
									<th>
										<xsl:value-of select="leg:TranslateText('Changed Provision')"/>	
									</th>
									<th>
										<xsl:value-of select="leg:TranslateText('Type of effect')"/>
										<a class="helpItem helpItemToMidRight" href="#typeofEffectHelp">
											<img alt="Type of effect help" src="/images/chrome/helpIcon.gif" />
										</a>	
									
									</th>							
									<th class="centralCol">
										<xsl:call-template name="TSOOutputColumnHeader">
											<xsl:with-param name="link" select="$link"/>
											<xsl:with-param name="fieldName" select="'affecting-title'"/>
											<xsl:with-param name="fieldTitle"
												select="leg:TranslateText('Affecting Legislation Title')"/>
										</xsl:call-template>
									</th>
									<th class="centralCol">
										<xsl:call-template name="TSOOutputColumnHeader">
											<xsl:with-param name="link" select="$link"/>
											<xsl:with-param name="fieldName"
												select="'affecting-year-number'"/>
											<xsl:with-param name="fieldTitle" select="leg:TranslateText('Year and Number')"/>
										</xsl:call-template>
									</th>
									<th class="centralCol">
										<xsl:value-of select="leg:TranslateText('Affecting Provision')"/>
									</th>
									<th class="applied">
									
										<xsl:call-template name="TSOOutputColumnHeader">
											<xsl:with-param name="link" select="$link"/>
											<xsl:with-param name="fieldName" select="'applied'"/>
											<xsl:with-param name="fieldTitle" select="leg:TranslateText('Applied')"/>
										</xsl:call-template>
											
										<a class="helpItem helpItemToMidLeft" href="#appliedHelp">
											<img alt="Amendment applied help" src="/images/chrome/helpIcon.gif" />
										</a>
									</th>
									<th>Note</th>
								</tr>
							</thead>
							<tbody>
								<xsl:apply-templates select="atom:entry/ukm:Effect" />
							</tbody>
						</table>
						<div class="contentFooter">
							<div class="interface">					
								<!-- adding the paging details -->
								<xsl:apply-templates select="/" mode="links"/>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div>
							<br/>
							<p><xsl:value-of select="leg:TranslateText('This may be because either')"/>:</p>
							<ul>
								<li><xsl:value-of select="leg:TranslateText('No_changes')"/></li>
								<li><xsl:value-of select="leg:TranslateText('No_changes_recorded')"/></li>
							</ul>
							<p><xsl:value-of select="leg:TranslateText('Next steps')"/>:</p>
							<ul>
								<xsl:if test="exists($requestInfoDoc/request/headers/header[name='referer' and contains(value, '/resources')])">
									<li>
										<a href="{$requestInfoDoc/request/headers/header[name='referer']/value}"><xsl:value-of select="leg:TranslateText('Back to legislation')"/></a>
									 </li>
								</xsl:if>
								<li><a href="{$TranslateLangPrefix}/changes"><xsl:value-of select="leg:TranslateText('New Search')"/></a></li>
								<li>
									<a href="{atom:link[@rel = 'self']/@href}">
										<xsl:value-of select="leg:TranslateText('Subscribe_feed')"/>
									</a>
								</li>
								<li>
									<a href="{$TranslateLangPrefix}/changes">
										<xsl:value-of select="leg:TranslateText('Learn_more')"/>
									</a>
								</li>
							</ul>
							
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<p class="backToTop">
					<a href="#top"><xsl:value-of select="leg:TranslateText('Back to top')"/></a>
				</p>
			</div>
	</xsl:template>

	<xsl:template match="ukm:Effect">
		<xsl:variable name="odd" as="xs:boolean" select="position() mod 2 = 1" />
		<tr>
			<xsl:if test="$odd">
				<xsl:attribute name="class">oddRow</xsl:attribute>
			</xsl:if>

			<xsl:apply-templates select="." mode="resultsAffectedTitle" />
			<xsl:apply-templates select="." mode="resultsAffectedYearNumber" />
			<xsl:apply-templates select="." mode="resultsChangedProvision" />
			<xsl:apply-templates select="." mode="resultsEffect"/>			
			<xsl:apply-templates select="." mode="resultsAffectingTitle"/>
			<xsl:apply-templates select="." mode="resultsAffectingYearNumber"/>
			<xsl:apply-templates select="." mode="resultsAffectingProvision"/>
			<xsl:apply-templates select="." mode="resultsApplied"/>
			<xsl:apply-templates select="." mode="resultsNote"/>
		</tr>
	</xsl:template>

	<!-- Affected -->
	<!-- Title -->
	<xsl:template match="ukm:Effect" mode="resultsAffectedTitle">
		<td>
			<xsl:choose>
				<xsl:when test="not(ukm:AffectedTitle)">
					<span><xsl:value-of select="leg:TranslateText('not available')"/></span>
				</xsl:when>
				<xsl:when test="ukm:AffectedTitle[1]">
					<strong>
						<xsl:value-of select="ukm:AffectedTitle[1]"/>
					</strong>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsAffectedYearNumber">
		<!-- Year and Number-->
		<td>
			<xsl:variable name="effectedYearNumber">
				<xsl:value-of select="@AffectedYear"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of
					select="tso:GetNumberForLegislation(@AffectedClass, @AffectedYear, @AffectedNumber)"
				/>
			</xsl:variable>
			<a href="/id/{tso:GetUriPrefixFromType(@AffectedClass, @AffectedYear)}/{@AffectedYear}/{@AffectedNumber}">
				<xsl:value-of select="$effectedYearNumber"/>
			</a>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsChangedProvision">
		<!-- Changed Provision-->
		<td>
			<xsl:choose>
				<xsl:when test="ukm:AffectedProvisions//ukm:Section">
					<xsl:apply-templates select="ukm:AffectedProvisions" />
				</xsl:when>
				<xsl:otherwise>
					<a href="/{substring-after(@AffectedURI, 'www.legislation.gov.uk/')}">
						<xsl:value-of select="@AffectedProvisions"/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<!-- Affecting -->

	<!-- Affecting Legislation Title -->
	<xsl:template match="ukm:Effect" mode="resultsAffectingTitle">
		<td class="centralCol">
			<xsl:choose>
				<xsl:when test="not(ukm:AffectingTitle)">
					<span><xsl:value-of select="leg:TranslateText('not available')"/></span>
				</xsl:when>
				<xsl:otherwise>
					<strong>
						<xsl:value-of select="ukm:AffectingTitle[1]"/>
					</strong>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<!-- Affecting Year and Number-->
	<xsl:template match="ukm:Effect" mode="resultsAffectingYearNumber">
		<td class="centralCol">
			<a href="/id/{tso:GetUriPrefixFromType(@AffectingClass, @AffectingYear)}/{@AffectingYear}/{@AffectingNumber}">
				<xsl:value-of select="@AffectingYear"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="tso:GetNumberForLegislation(@AffectingClass, @AffectingYear, @AffectingNumber)" />
			</a>
		</td>
	</xsl:template>

	<!-- Affecting Provision-->
	<xsl:template match="ukm:Effect" mode="resultsAffectingProvision">
		<td class="centralCol">
			<xsl:choose>
				<xsl:when test="ukm:AffectingProvisions//ukm:Section">
					<xsl:apply-templates select="ukm:AffectingProvisions" />
				</xsl:when>
				<xsl:otherwise>
					<a href="/{substring-after(@AffectingURI, 'www.legislation.gov.uk/')}">
						<xsl:value-of select="@AffectingProvisions" />
					</a>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsEffect">
		<!-- Type of Effect-->
		<td>
			<xsl:value-of select="@Type"/>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsApplied">
		<!-- Applied Yes-->
		<td>
			<xsl:if test="@Applied eq 'true'">
				<img src="/images/chrome/tickIcon.gif" alt="Yes"/>
			</xsl:if>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsNote">
		<!-- Note-->
		<td>
			<xsl:if test="not(empty(@Notes))">
				<a class="helpItem hover" href="#note{generate-id(.)}">
					<img alt="Note" src="/images/chrome/noteIcon.gif"/>
				</a>
				<div id="note{generate-id(.)}" class="help">
					<span class="icon"/>
					<div class="content">
						<a href="#" class="close">
							<img alt="Close" src="/images/chrome/closeIcon.gif"/>
						</a>
						<xsl:choose>
							<xsl:when test="exists(ukm:Commenced)">
								<xsl:apply-templates select="ukm:Commenced" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@Notes"/>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Section">
		<xsl:choose>
			<xsl:when test="@Missing = 'true'">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<a href="/{substring-after(@URI, 'www.legislation.gov.uk/')}">
					<xsl:apply-templates />
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ukm:Citation">
		<xsl:choose>
			<xsl:when test="exists(@URI)">
				<a href="/{substring-after(@URI, 'www.legislation.gov.uk/')}">
					<xsl:apply-templates />
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ukm:AffectedProvisions//text() | ukm:AffectingProvisions//text() | ukm:Commenced//text()">
		<xsl:value-of select="." />
	</xsl:template>

	<!-- ========== Standard code for search results========= -->

	<xsl:template match="atom:feed" mode="pagesummary">
		<div class="resultsInfo">
			<xsl:choose>
				<xsl:when test="exists(atom:entry)">
					<xsl:value-of select="openSearch:startIndex"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="leg:TranslateText('to')"/>
					<xsl:text> </xsl:text>
					<xsl:value-of
						select="openSearch:startIndex + min((openSearch:itemsPerPage, count(atom:entry))) - 1"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="leg:TranslateText('of')"/>
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="openSearch:totalResults">
							<xsl:value-of select="openSearch:totalResults"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="leg:TranslateText('over')"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="openSearch:itemsPerPage * leg:morePages"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text> </xsl:text>		
					<xsl:value-of select="leg:TranslateText('results')"/>
				</xsl:when>
				<xsl:otherwise>					
					<xsl:value-of select="leg:TranslateText('Changes_noResultFound_message')"/>
					<xsl:text> </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</div>			
	</xsl:template>

	<xsl:function name="sls:year-from-uri" as="xs:string">
		<xsl:param name="uri" as="xs:string?"/>
		<xsl:value-of
			select="tokenize(substring-after($uri, 'http://www.legislation.gov.uk/id/'), '/')[2]"/>
	</xsl:function>

	<xsl:function name="sls:number-from-uri" as="xs:string">
		<xsl:param name="uri" as="xs:string?"/>
		<xsl:value-of
			select="tokenize(substring-after($uri, 'http://www.legislation.gov.uk/id/'), '/')[3]"/>
	</xsl:function>

	<xsl:function name="ukm:PreviousAffected" as="element(ukm:Effect)?">
		<xsl:param name="effect" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$effect/../preceding-sibling::atom:entry[1]/ukm:Effect[ukm:SameAffectedLegislation(., $effect)]"
		/>
	</xsl:function>

	<xsl:function name="ukm:NextAffected" as="element(ukm:Effect)?">
		<xsl:param name="effect" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$effect/../following-sibling::atom:entry[1]/ukm:Effect[ukm:SameAffectedLegislation(., $effect)]"
		/>
	</xsl:function>

	<!-- Returns true() when two ukm:Effect afe for the same affected
	     legislation. -->
	<xsl:function name="ukm:SameAffectedLegislation" as="xs:boolean">
		<xsl:param name="a" as="element(ukm:Effect)"/>
		<xsl:param name="b" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$a/@AffectedNumber = $b/@AffectedNumber and
								$a/@AffectedYear = $b/@AffectedYear and
								$a/@AffectedClass = $b/@AffectedClass"
		/>
	</xsl:function>

	<xsl:function name="ukm:PreviousAffecting" as="element(ukm:Effect)?">
		<xsl:param name="effect" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$effect/../preceding-sibling::atom:entry[1]/ukm:Effect[ukm:SameAffectingLegislation(., $effect)]"
		/>
	</xsl:function>

	<xsl:function name="ukm:NextAffecting" as="element(ukm:Effect)?">
		<xsl:param name="effect" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$effect/../following-sibling::atom:entry[1]/ukm:Effect[ukm:SameAffectingLegislation(., $effect)]"
		/>
	</xsl:function>

	<!-- Returns true() when two ukm:Effect afe for the same affecting
	     legislation. -->
	<xsl:function name="ukm:SameAffectingLegislation" as="xs:boolean">
		<xsl:param name="a" as="element(ukm:Effect)"/>
		<xsl:param name="b" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="if (exists($a/@CommencingClass)) then
									($a/@CommencingNumber = $b/@CommencingNumber and
									 $a/@AffectingYear = $b/@AffectingYear and
									 $a/@CommencingClass = $b/@CommencingClass)
								else
									($a/@AffectingNumber = $b/@AffectingNumber and
									 $a/@AffectingYear = $b/@AffectingYear and
									 $a/@AffectingClass = $b/@AffectingClass)"
		/>
	</xsl:function>

	<!-- For the first ukm:Effect among possibly multiple ukm:Effect for
	     the same affecting legislation, returns the number of
	     ukm:Effect with the same value for $attribute as $effect.  For
	     following ukm:Effect with the same value for $attribute,
	     returns 0.  Non-zero indicates the number of rows to span, and
	     zero indicates to omit the table cell. -->
	<xsl:function name="ukm:ResultsAffectingSpan" as="xs:integer">
		<xsl:param name="effect" as="element(ukm:Effect)"/>
		<xsl:param name="attribute" as="xs:string"/>

		<xsl:variable name="previousEffect" select="ukm:PreviousAffecting($effect)"
			as="element(ukm:Effect)?"/>
		<xsl:variable name="nextEffect" select="ukm:NextAffecting($effect)"
			as="element(ukm:Effect)?"/>
		<xsl:choose>
			<xsl:when
				test="exists($previousEffect) and
								$previousEffect/@*[local-name() = $attribute] = $effect/@*[local-name() = $attribute]">
				<xsl:sequence select="0"/>
			</xsl:when>
			<xsl:when
				test="exists($nextEffect) and
								$nextEffect/@*[local-name() = $attribute] = $effect/@*[local-name() = $attribute]">
				<xsl:sequence select="ukm:ResultsAffectingSpanWorker($nextEffect, $attribute, 1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Not meant to be called except by ukm:ResultsAffectingSpan(). -->
	<xsl:function name="ukm:ResultsAffectingSpanWorker" as="xs:integer">
		<xsl:param name="effect" as="element(ukm:Effect)"/>
		<xsl:param name="attribute" as="xs:string"/>
		<xsl:param name="subtotal" as="xs:integer"/>

		<xsl:variable name="nextEffect" select="ukm:NextAffecting($effect)"
			as="element(ukm:Effect)?"/>
		<xsl:choose>
			<xsl:when
				test="exists($nextEffect) and
					$nextEffect/@*[local-name() = $attribute] = $effect/@*[local-name() = $attribute]">
				<xsl:sequence
					select="ukm:ResultsAffectingSpanWorker($nextEffect, $attribute, $subtotal + 1)"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$subtotal + 1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="TSOOutputColumnHeader">
		<xsl:param name="link" as="xs:string"/>
		<xsl:param name="fieldName" as="xs:string"/>
		<xsl:param name="fieldTitle" as="xs:string"/>
		
		<!--<xsl:variable name="link" select="if (string-length($requestInfoDoc/request/query-string) >0) then concat($link,'?', $requestInfoDoc/request/query-string) else $link"/>-->
		<!--[<xsl:value-of select="$link"/>][<xsl:value-of select="$order"/>][<xsl:value-of select="$fieldName"/>][<xsl:value-of select="$sort"/>]-->
		
		<a title="Sort {$order} by {$fieldTitle}">
			<xsl:variable name="fieldLink"
				select="if (contains($link, 'sort=')) then replace($link, 'sort=[-a-z]+', concat('sort=', $fieldName) ) 
							else concat($link, if (contains($link, '?')) then '&amp;' else '?', 'sort=', $fieldName)"/>
			<xsl:choose>
				<xsl:when test="$sort = $fieldName">
					<xsl:choose>
						<xsl:when test="$order = ('ascending', '') "> 
							<xsl:attribute name="class">sortAsc active</xsl:attribute>
							<xsl:variable name="fieldLinkOrder"
								select="if (contains($fieldLink, 'order=')) then replace($fieldLink, 'order=[-a-z]+', 'order=descending') else concat($fieldLink,  '&amp;order=descending')"/>
							<xsl:attribute name="href" select="leg:GetLink($fieldLinkOrder)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">sortDesc active</xsl:attribute>
							<xsl:attribute name="href"
								select="leg:GetLink(replace($fieldLink, 'order=[-a-z]+', 'order=ascending'))"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">sortAsc</xsl:attribute>
					<xsl:attribute name="href"
						select="leg:GetLink(replace($fieldLink, 'order=[-a-z]+', 'order=ascending'))"/>
				</xsl:otherwise>
			</xsl:choose>
			<span class="accessibleText">Sort
				<xsl:text> </xsl:text>
				<xsl:value-of select="$order"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="leg:TranslateText('by')"/>
				<xsl:text> </xsl:text>
			</span>
			<xsl:value-of select="$fieldTitle"/>
		</a>
	</xsl:template>
	
	<!-- adding the subscription link -->
	<xsl:template match="atom:link" mode="subscribe">
		<div class="subscribe">
			<a href="{@href}" class="userFunctionalElement">
				<span class="background">
					<span class="btl"/>
					<span class="btr"/> <xsl:value-of select="leg:TranslateText('Subscribe to this list')"/> <span class="bbl"/>
					<span class="bbr"/>
				</span>
			</a>
			<!--<a href="#" class="helpItem helpToLeftMid">
				<img src="../../images/chrome/helpIcon.gif" alt="List subscription help"/>
			</a>-->
		</div>
	</xsl:template>


	<xsl:template name="TSOOutputTooltips">
		<div class="help" id="changesThatAffectHelp">
			<span class="icon" />
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif" />
				</a>
				<h3><xsl:value-of select="leg:TranslateText('Changes that affect')"/></h3>
				<p><xsl:value-of select="leg:TranslateText('Changes_affect_tooltip_p')"/></p>
				<ul>
					<li><xsl:value-of select="leg:TranslateText('Changes_affect_tooltip_li_1')"/></li>
					<li><xsl:value-of select="leg:TranslateText('Changes_affect_tooltip_li_2')"/></li>
					<li><xsl:value-of select="leg:TranslateText('Changes_affect_tooltip_li_3')"/></li>
				</ul>
			</div>
		</div>		

		<div class="help" id="madeByHelp">
			<span class="icon" />
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif" />
				</a>
				<h3><xsl:value-of select="leg:TranslateText('Made by')"/></h3>
				<p><xsl:value-of select="leg:TranslateText('Changes_madeby_tooltip_p')"/></p>
				<ul>
					<li><xsl:value-of select="leg:TranslateText('Changes_madeby_tooltip_li_1')"/></li>
					<li><xsl:value-of select="leg:TranslateText('Changes_madeby_tooltip_li_2')"/></li>
					<li><xsl:value-of select="leg:TranslateText('Changes_madeby_tooltip_li_3')"/></li>
				</ul>
			</div>
		</div>	
		
		<div class="help" id="resultsShowingHelp">
			<span class="icon" />
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif" />
				</a>
				<h3><xsl:value-of select="leg:TranslateText('Changes_resultsShowing_tooltip_h3')"/></h3>
				<ul>
					<li><xsl:value-of select="leg:TranslateText('Changes_resultsShowing_tooltip_li_1')"/></li>
					<li><xsl:value-of select="leg:TranslateText('Changes_resultsShowing_tooltip_li_2')"/></li>
					<li><xsl:value-of select="leg:TranslateText('Changes_resultsShowing_tooltip_li_3')"/></li>
				</ul>
			</div>
		</div>		
		
		<xsl:if test="exists(/atom:feed/atom:entry)">
			<div class="help" id="appliedHelp">
				<span class="icon" />
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif" />
					</a>
					<h3><xsl:value-of select="leg:TranslateText('Applied')"/></h3>
					<p><xsl:value-of select="leg:TranslateText('Changes_applied_tooltip_p_1')"/></p>
					<p><xsl:value-of select="leg:TranslateText('Changes_applied_tooltip_p_2')"/></p>
				</div>
			</div>		
			
			<div class="help" id="typeofEffectHelp">
				<span class="icon" />
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif" />
					</a>
					<h3><xsl:value-of select="leg:TranslateText('Type of effect')"/></h3>
					<p>
						<xsl:value-of select="leg:TranslateText('Changes_typeofEffect_tooltip_p')"/>
					</p>
				</div>
			</div>	
		</xsl:if>		
			
	</xsl:template>

</xsl:stylesheet>
