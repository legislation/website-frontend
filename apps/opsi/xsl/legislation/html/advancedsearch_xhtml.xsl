<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"  version="2.0"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:db="http://docbook.org/ns/docbook"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/"
	>
	<xsl:import href="quicksearch.xsl" />
	<xsl:import href="../../common/utils.xsl" />

	<xsl:character-map name="specialchar">
		<xsl:output-character character="&apos;" string="&amp;apos;" />
		<xsl:output-character character="&quot;" string="&amp;quot;" />
		<xsl:output-character character="&gt;" string="tt" />
		<xsl:output-character character="&lt;" string="tt" />
	</xsl:character-map>

	<xsl:output use-character-maps="specialchar" />

	<xsl:variable name="paramsDoc" as="document-node()">
		<xsl:choose>
			<xsl:when test="doc-available('input:request')">
				<xsl:sequence select="doc('input:request')" />
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

	<xsl:variable name="errorSearchingDoc" as="document-node()?">
		<xsl:choose>
			<xsl:when test="doc-available('input:error-searching')">
				<xsl:sequence select="doc('input:error-searching')" />
			</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="isVersionSpecified" as="xs:boolean"
		select="exists($paramsDoc/parameters/version[. != ''])"/>

	<xsl:variable name="isRevisedLegislation" as="xs:boolean"
		select="exists($paramsDoc/parameters/type[. = leg:revisedLegislationTypes()])"/>

	<xsl:variable name="generalSearch" as="xs:boolean" select="not($paramsDoc/parameters/search-type = ('extent', 'point-in-time','draft-legislation','impacts') ) and not($isVersionSpecified)" />
	<xsl:variable name="extentSearch" as="xs:boolean" select="$paramsDoc/parameters/search-type = 'extent' " />
	<xsl:variable name="pointInTimeSearch" as="xs:boolean" select="$paramsDoc/parameters/search-type = 'point-in-time' or $isVersionSpecified" />
	<xsl:variable name="draftLegislationSearch" as="xs:boolean" select="$paramsDoc/parameters/search-type = 'draft-legislation' " />
	<xsl:variable name="impactAssessmentSearch" as="xs:boolean" select="$paramsDoc/parameters/search-type = 'impacts' " />

	<xsl:template match="/">
		<html>
			<head>
				<link rel="stylesheet" href="/styles/advancedsearch/search.css" type="text/css"/>
                <script type="text/javascript" src="/scripts/formFunctions/common.js"></script>
                <script type="text/javascript" src="/scripts/advancedsearch/{if ($hideEUdata) then 'search.js' else 'search-eu.js'}"></script>
				<link type="text/css" href="/styles/legBrowse.css" rel="stylesheet"/>

				<xsl:if test="$pointInTimeSearch or $impactAssessmentSearch">
					<link rel="stylesheet" href="/styles/advancedsearch/jquery.ui.datepicker.css" type="text/css" />
					<link rel="stylesheet" href="/styles/advancedsearch/jquery-ui.css" type="text/css" />
					<script type="text/javascript" src="/scripts/jquery-ui-1.8.24.custom.min.js"></script>
					<script type="text/javascript" src="/scripts/advancedsearch/jquery.ui.datepicker.min.js"></script>
				</xsl:if>

			</head>

			<body xml:lang="{$TranslateLang}" dir="ltr" id="search" class="intro">
				<div id="layout2">
					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>

					<div class="titles">
						<h1 id="pageTitle">
							<xsl:value-of select="leg:TranslateText('Advanced Search - ')"/>

							<xsl:choose>
								<xsl:when test="$pointInTimeSearch">
									<xsl:value-of select="leg:TranslateText('Legislation as it stood at a specific point in time (for revised legislation only)')"/>
								</xsl:when>
								<xsl:when test="$extentSearch">
									<xsl:value-of select="leg:TranslateText('Geographical extent search (for revised legislation only)')"/>
								</xsl:when>
								<xsl:when test="$draftLegislationSearch">
									<xsl:value-of select="leg:TranslateText('Draft Legislation search')"/>
								</xsl:when>
								<xsl:when test="$impactAssessmentSearch">
									<xsl:value-of select="leg:TranslateText('Impact Assessment search')"/>
									<small><xsl:text> </xsl:text>(<xsl:value-of select="leg:TranslateText('UK only')"/>)</small>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="leg:TranslateText('General search')"/>
								</xsl:otherwise>
							</xsl:choose>

						</h1>
					</div>

					<div id="tools">
						<div>
							<h2><xsl:value-of select="leg:TranslateText('Find legislation')"/></h2>
						</div>
						<div id="links">
							<a href="{$TranslateLangPrefix}/search">
								<xsl:if test="$generalSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('General')"/>
							</a>
							<a href="{$TranslateLangPrefix}/search/extent">
								<xsl:if test="$extentSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Geographical Extent')"/>
							</a>
							<a href="{$TranslateLangPrefix}/search/point-in-time">
								<xsl:if test="$pointInTimeSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Point in Time')"/>
							</a>
							<a href="{$TranslateLangPrefix}/search/draft-legislation">
								<xsl:if test="$draftLegislationSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Draft Legislation')"/>
							</a>
							<a href="{$TranslateLangPrefix}/search/impacts">
								<xsl:if test="$impactAssessmentSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Impact Assessments')"/>
							</a>
						</div>
					</div>

					<div id="content">

						<xsl:if test="exists($errorSearchingDoc)">
							<div id="errorBar" class="error errorMessage">
								<xsl:choose>
									<xsl:when test="$errorSearchingDoc/errorsearching/status-code = '400'">
										<xsl:value-of select="leg:TranslateText(string-join($errorSearchingDoc/errorsearching/message,''))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat(leg:TranslateText('Please check the form fields which are highlighted in red'),'. ', $errorSearchingDoc/errorsearching/message)"/>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:if>

						<xsl:call-template name="TSOSearch"/>
					</div>
					<!--/#content-->
				</div>
				<!--/#layout2-->
			</body>
		</html>
	</xsl:template>

	<xsl:template name="TSOSearch">
		<form id="advancedSearch" class="advancedSearch" method="get" action="{$TranslateLangPrefix}/search" style="display: block;">
			<h2 class="accessibleText">
				<xsl:value-of select="leg:TranslateText('Search Form')"/>
			</h2>

			<!-- extends search -->
			<xsl:if test="$extentSearch">
				<p><xsl:value-of select="leg:TranslateText('Extent_search_desc')"/></p>
				<div class="searchExtendsTo searchFieldCategory">
					<div class="searchFieldGroup">
						<h3><xsl:value-of select="leg:TranslateText('Extends to')"/></h3>
						<!--
						<a class="helpIcon advancedSearchHelp" href="#extendsHelp">
							<img alt=" Help about Extends searching" src="/images/chrome/helpIcon.gif"/>
						</a>
						-->
					</div>

					<div class="searchFieldGroup">
						<div class="searchCol1">
							<xsl:value-of select="leg:TranslateText('Geographical extent')"/>
						</div>

						<div class="searchCol2 searchExtendsToInput">
							<div class="opt1 group">
								<label for="applicable">
									<input type="radio" name="extent-match" value="applicable" id="applicable" checked="checked" class="radio yearChoice" />
									<xsl:value-of select="leg:TranslateText('Applicable to')"/>
										<xsl:text>:</xsl:text>
									</label>
								<label for="exact">
									<input type="radio" name="extent-match" value="exact" id="exact" class="radio yearChoice" />
									<xsl:value-of select="leg:TranslateText('Exclusively extends to')"/>
										<xsl:text>:</xsl:text>
								</label>
							</div>
							<div class="opt2">
								<label for="uk">
									<input type="checkbox" name="extent" value="uk" id="uk" class="checkbox" />
									<xsl:value-of select="leg:TranslateText('United Kingdom')"/>
								</label>
								<label for="gb">
									<input type="checkbox" name="extent" value="gb" id="gb" class="checkbox" />
									<xsl:value-of select="leg:TranslateText('Great Britain')"/>
								</label>
								<label for="ew">
									<input type="checkbox" name="extent" value="ew" id="ew" class="checkbox" />
									<xsl:value-of select="leg:TranslateText('England &amp; Wales')"/>
									<!--<xsl:text>England &amp; Wales</xsl:text>-->
								</label>
							</div>
							<div class="opt2">
								<label for="england">
									<input type="checkbox" name="extent" checked="checked" value="england" id="england" class="checkbox" />
									<xsl:value-of select="leg:TranslateText('England')"/>
								</label>
								<label for="wales">
									<input type="checkbox" name="extent" checked="checked" value="wales" id="wales" class="checkbox" />
									<xsl:value-of select="leg:TranslateText('Wales')"/>
								</label>
								<label for="scotland">
									<input type="checkbox" name="extent" checked="checked" value="scotland" id="scotland" class="checkbox" />
									<xsl:value-of select="leg:TranslateText('Scotland')"/>
								</label>
								<label for="ni">
									<input type="checkbox" name="extent" checked="checked" value="ni" id="ni" class="checkbox" />
									<xsl:value-of select="leg:TranslateText('Northern Ireland')"/>
								</label>
								<xsl:if test="not($hideEUdata)">
									<label for="eu">
										<input type="checkbox" name="extent" checked="checked" value="eu" id="eu" class="checkbox" />
										<xsl:value-of select="leg:TranslateText('European Union')"/>
									</label>
								</xsl:if>
							</div>
						</div>
					</div>
				</div>
			</xsl:if>

			<!-- title -->
			<div class="searchTitle searchFieldCategory">
				<div class="searchCol1">
				<label for="searchTitle">
					<xsl:value-of select="leg:TranslateText('Title')"/>:
				</label>
				</div>
				<div class="searchCol2">
					<div class="searchFieldGroup">
						<input type="text" id="searchTitle" name="title" value="{leg:resolve-request-data($paramsDoc/parameters/title)}"/>
						<span><xsl:value-of select="leg:TranslateText('Key_title_text')"/></span>
					</div>
				</div>
				<div class="searchCol3">
					<a class="helpIcon helpItem helpItemToRight" href="#titleHelp">
					<img alt=" Help about Title searching" src="/images/chrome/helpIcon.gif"/>
				</a>
				</div>
			</div>

			<!-- search keywords -->
			<xsl:if test="$generalSearch or $extentSearch or $draftLegislationSearch or $impactAssessmentSearch">
				<div class="searchKeywords searchFieldCategory">
					<div class="searchCol1">
						<label for="searchText"><xsl:value-of select="leg:TranslateText('Keywords in content:')"/></label>
					</div>
					<div class="searchCol2">
						<div class="searchFieldGroup">
							<input type="text" id="searchText" name="text" value="{leg:resolve-request-data($paramsDoc/parameters/text)}" />
							<span><xsl:value-of select="leg:TranslateText('Use_double_quote_text')"/></span>
						</div>
					</div>
					<div class="searchCol3">
						<!--
						<a class="helpIcon advancedSearchHelp" href="#keywordHelp">
							<img alt=" Help about Keywords searching" src="/images/chrome/helpIcon.gif"/>
						</a>
						-->
					</div>
				</div>
			</xsl:if>


			<!-- search keywords -->
			<xsl:if test="$impactAssessmentSearch">
				<div class="searchKeywords searchFieldCategory">
					<div class="searchCol1">
						<label for="stageText"><xsl:value-of select="leg:TranslateText('Stage')"/>: </label>
					</div>
					<div class="searchCol2">
						<div class="searchFieldGroup">
							<input type="text" id="stageText" name="stage" value="{leg:resolve-request-data($paramsDoc/parameters/stage)}" />
							<span>(<xsl:value-of select="leg:TranslateText('whole name of the stage required')"/>)</span>
						</div>
					</div>
					<div class="searchCol3">
						<!--
						<a class="helpIcon advancedSearchHelp" href="#keywordHelp">
							<img alt=" Help about Keywords searching" src="/images/chrome/helpIcon.gif"/>
						</a>
						-->
					</div>
				</div>

				<div class="searchKeywords searchFieldCategory">
					<div class="searchCol1">
						<label for="departmentText"><xsl:value-of select="leg:TranslateText('Department')"/>: </label>
					</div>
					<div class="searchCol2">
						<div class="searchFieldGroup">
							<input type="text" id="departmentText" name="department" value="{leg:resolve-request-data($paramsDoc/parameters/department)}" />
							<span>(<xsl:value-of select="leg:TranslateText('whole name of the department required')"/>)</span>
						</div>
					</div>
					<div class="searchCol3">
						<!--
						<a class="helpIcon advancedSearchHelp" href="#keywordHelp">
							<img alt=" Help about Keywords searching" src="/images/chrome/helpIcon.gif"/>
						</a>
						-->
					</div>
				</div>


				<xsl:variable name="invalidStartDate" as="xs:boolean"
					select="$paramsDoc/parameters/start[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}')
							and xs:date(concat(substring(., 7), '-' , substring(., 4,2), '-' , substring(., 1,2))) &lt; xs:date ('1990-01-01')
							]
							 or
						$paramsDoc/parameters/start[. castable as xs:date and
							xs:date(.) &lt; xs:date('1990-01-01')
							]"/>

				<xsl:variable name="invalidEndDate" as="xs:boolean"
					select="$paramsDoc/parameters/start[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}')
							and xs:date(concat(substring(., 7), '-' , substring(., 4,2), '-' , substring(., 1,2))) &lt; xs:date ('1990-01-01')
							]
							 or
						$paramsDoc/parameters/start[. castable as xs:date and
							xs:date(.) &lt; xs:date('1990-01-01')
							]"/>


				<xsl:variable name="invalidYear" as="xs:boolean"
						select="exists($paramsDoc/parameters/year[. !='' and not(matches(., '(\*|[0-9]{4})(-(\*|[0-9]{4}))?'))])"/>


					<fieldset class="searchYear searchFieldCategory">
						<legend class="searchCol1">
							<xsl:if test="$invalidYear">
								<xsl:attribute name="class">error</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="leg:TranslateText('Year')"/>:
						</legend>

						<div class="searchCol2">
							<div class="specificYear formGroup">
								<input type="radio" id="specificRadio" name="yearRadio" value="specific"
									checked="true"/>
								<label for="specificRadio"><xsl:value-of select="leg:TranslateText('Specific Year')"/></label>
								<div>
									<label for="specificYear" class="accessibleText">
										<xsl:value-of select="leg:TranslateText('Specific Year')"/>
									</label>
									<input type="text" id="specificYear" name="year" maxlength="4"
										value="{leg:resolve-request-data($paramsDoc/parameters/year)}">
										<xsl:if test="$invalidYear">
											<xsl:attribute name="class">error</xsl:attribute>
										</xsl:if>
									</input>
								</div>
							</div>
							<div class="rangeOfYears formGroup">
								<xsl:variable name="invalidYearRange" as="xs:boolean"
						select="exists($paramsDoc/parameters/start-year[. != '*' and . != '' and not(. castable as xs:integer)]) or
							    exists($paramsDoc/parameters/end-year[. != '*' and . != '' and not(. castable as xs:integer)])"/>
								<input type="radio" id="rangeRadio" name="yearRadio" value="range"/>
								<label for="rangeRadio"><xsl:value-of select="leg:TranslateText('Year Range')"/></label>
								<div class="yearRange">
									<div>
										<label for="yearStart"><xsl:value-of select="leg:TranslateText('From')"/></label>
										<input type="text" id="yearStart" name="start-year" maxlength="4"
											value="{leg:resolve-request-data($paramsDoc/parameters/start-year)}">
											<xsl:if test="$invalidYearRange">
												<xsl:attribute name="class">error</xsl:attribute>
											</xsl:if>
										</input>
									</div>
									<div>
										<label for="yearEnd"><xsl:value-of select="leg:TranslateText('To')"/></label>
										<input type="text" id="yearEnd" name="end-year" maxlength="4"
											value="{leg:resolve-request-data($paramsDoc/parameters/end-year)}">
											<xsl:if test="$invalidYearRange">
												<xsl:attribute name="class">error</xsl:attribute>
											</xsl:if>
										</input>
									</div>
								</div>
							</div>

							<div class="rangeOfDates formGroup searchDateRange">
								<input type="radio" id="dateRangeRadio" name="yearRadio" value="range"/>
								<label for="dateRangeRadio"><xsl:value-of select="leg:TranslateText('Date Range')"/></label>
								<div class="yearRange">
									<div>
										<label for="dateStart"><xsl:value-of select="leg:TranslateText('From')"/></label>
										<input id="dateStart" type="text" name="start"
							value="{if ($paramsDoc/parameters/start[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}')]) then leg:resolve-request-data($paramsDoc/parameters/start)
										else if ($paramsDoc/parameters/start[. castable as xs:date]) then format-date($paramsDoc/parameters/start, '[D01]/[M01]/[Y0001]')
										else ''}">
											<xsl:if test="$invalidStartDate">
												<xsl:attribute name="class">error</xsl:attribute>
											</xsl:if>
										</input>
									</div>
									<div>
										<label for="dateEnd"><xsl:value-of select="leg:TranslateText('To')"/></label>
										<input id="dateEnd" type="text" name="end"
										value="{if ($paramsDoc/parameters/start[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}')]) then leg:resolve-request-data($paramsDoc/parameters/start)
													else if ($paramsDoc/parameters/start[. castable as xs:date]) then format-date($paramsDoc/parameters/start, '[D01]/[M01]/[Y0001]')
													else ''}">
											<xsl:if test="$invalidEndDate">
												<xsl:attribute name="class">error</xsl:attribute>
											</xsl:if>
										</input>


									</div>
								</div>
							</div>

							<xsl:if test="$invalidYear">
								<span class="error errorMessage"><xsl:value-of select="concat(leg:TranslateText('Not a valid year'),' (', leg:TranslateText('YYYY'),')')"/></span>
							</xsl:if>
						</div>

						<div class="searchCol3">
							<a class="helpIcon helpItem helpItemToMidRight" href="#yearHelp">
								<img alt=" Help about Year Range searching" src="/images/chrome/helpIcon.gif"/>
							</a>
						</div>
					</fieldset>

				</xsl:if>

			<!-- language -->
			<xsl:if test="$generalSearch">
				<fieldset class="searchLang searchFieldCategory">
					<legend class="searchCol1">
						<xsl:value-of select="leg:TranslateText('Language')"/>:
					</legend>
					<div class="searchCol2">
						<div class="englishLang formGroup">
							<input type="radio" id="englishRadio" name="lang" value="en" checked="true"/>
							<label for="englishRadio"><xsl:value-of select="leg:TranslateText('English')"/></label>
						</div>
						<div class="welshLang formGroup">
							<input type="radio" id="welshRadio" name="lang" value="cy"/>
							<label for="welshRadio"><xsl:value-of select="leg:TranslateText('Welsh')"/></label>
						</div>
					</div>
					<div class="searchCol3">
						<!--
						<a class="helpIcon advancedSearchHelp" href="#langHelp">
							<img alt=" Help about language searching" src="/images/chrome/helpIcon.gif"/>
						</a>
						-->
					</div>
				</fieldset>
			</xsl:if>

			<!-- search year -->
			<xsl:choose>
				<xsl:when test="$pointInTimeSearch">
					<xsl:variable name="invalidYear" as="xs:boolean"
						select="
								$paramsDoc/parameters/year[. !='' and not(matches(., '(\*|[0-9]{4})(-(\*|[0-9]{4}))?'))] or
								$paramsDoc/parameters/version[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}') and
										$paramsDoc/parameters/year castable as xs:integer and
										xs:integer(substring(., 7)) &lt; xs:integer($paramsDoc/parameters/year)
									] or
									$paramsDoc/parameters/version[. castable as xs:date and
										$paramsDoc/parameters/year castable as xs:integer and
										year-from-date(xs:date(.)) &lt; xs:integer($paramsDoc/parameters/year)
									]"/>

					<div class="searchYear searchFieldCategory">
						<div class="searchCol1">
							<label for="specificPITYearText">
								<xsl:if test="$invalidYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Year')"/>:
							</label>
						</div>
						<div class="searchCol2">
							<div class="specificYear PIT">
								<input type="text" id="specificPITYearText" name="year" maxlength="4" value="{leg:resolve-request-data($paramsDoc/parameters/year)}">
									<xsl:if test="$invalidYear">
										<xsl:attribute name="class">error</xsl:attribute>
									</xsl:if>
								</input>
							</div>
							<xsl:if test="$invalidYear">
								<span class="error errorMessage"><xsl:value-of select="leg:TranslateText('The year must be valid and before the point in time search')"/></span>
							</xsl:if>
						</div>
						<div class="searchCol3">
							<a class="helpIcon helpItem helpItemToMidRight" href="#yearHelp">
							<img alt=" Help about Specific Year searching" src="/images/chrome/helpIcon.gif"/>
						</a>
						</div>
					</div>

					<xsl:call-template name="TSOOutputNumber"/>
				</xsl:when>
				<xsl:when test="$impactAssessmentSearch"></xsl:when>
				<xsl:otherwise>
					<xsl:variable name="invalidYear" as="xs:boolean"
						select="exists($paramsDoc/parameters/year[. !='' and not(matches(., '(\*|[0-9]{4})(-(\*|[0-9]{4}))?'))])"/>
					<xsl:variable name="invalidYearRange" as="xs:boolean"
						select="exists($paramsDoc/parameters/start-year[. != '*' and . != '' and not(. castable as xs:integer)]) or
							    exists($paramsDoc/parameters/end-year[. != '*' and . != '' and not(. castable as xs:integer)])"/>


					<div class="searchYear searchFieldCategory">
						<div class="searchCol1">
							<label for="specificYear">
								<xsl:if test="$invalidYear or $invalidYearRange">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Year')"/>:
							</label>
						</div>

						<div class="searchCol2">
							<div class="specificYear formGroup">
								<input type="radio" id="specificRadio" name="yearRadio" value="specific"
									checked="true"/>
								<label for="specificRadio"><xsl:value-of select="leg:TranslateText('Specific Year')"/></label>
								<div>
									<label for="specificYearText" class="accessibleText">
										<xsl:value-of select="leg:TranslateText('Specific Year')"/>
									</label>
									<input type="text" id="specificYearText" name="year" maxlength="4"
										value="{leg:resolve-request-data($paramsDoc/parameters/year)}">
										<xsl:if test="$invalidYear">
											<xsl:attribute name="class">error</xsl:attribute>
										</xsl:if>
									</input>
								</div>
							</div>
							<div class="rangeOfYears formGroup">
								<input type="radio" id="rangeRadio" name="yearRadio" value="range"/>
								<label for="rangeRadio"><xsl:value-of select="leg:TranslateText('Range')"/></label>
								<div class="yearRange">
									<div>
										<label for="yearStart"><xsl:value-of select="leg:TranslateText('From')"/></label>
										<input type="text" id="yearStart" name="start-year" maxlength="4"
											value="{leg:resolve-request-data($paramsDoc/parameters/start-year)}">
											<xsl:if test="$invalidYearRange">
												<xsl:attribute name="class">error</xsl:attribute>
											</xsl:if>
										</input>
									</div>
									<div>
										<label for="yearEnd"><xsl:value-of select="leg:TranslateText('To')"/></label>
										<input type="text" id="yearEnd" name="end-year" maxlength="4"
											value="{leg:resolve-request-data($paramsDoc/parameters/end-year)}">
											<xsl:if test="$invalidYearRange">
												<xsl:attribute name="class">error</xsl:attribute>
											</xsl:if>
										</input>
									</div>
								</div>
							</div>
							<xsl:if test="$invalidYear or $invalidYearRange">
								<span class="error errorMessage"><xsl:value-of select="concat(leg:TranslateText('Not a valid year'),' (', leg:TranslateText('YYYY'),')')"/></span>
							</xsl:if>
						</div>

						<div class="searchCol3">
							<a class="helpIcon helpItem helpItemToMidRight" href="#yearHelp">
								<img alt=" Help about Year Range searching" src="/images/chrome/helpIcon.gif"/>
							</a>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>

			<!-- search number -->
			<xsl:choose>
				<xsl:when test="$generalSearch">
					<xsl:call-template name="TSOOutputNumber">
						<xsl:with-param name="includeSeries" select="true()"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$extentSearch">
					<xsl:call-template name="TSOOutputNumber">
						<xsl:with-param name="includeSeries" select="false()"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise><!-- already add for Point-in-time --></xsl:otherwise>
			</xsl:choose>

			<!-- search type -->
			<xsl:choose>
				<xsl:when test="$impactAssessmentSearch">
					<input type="hidden" name="type" value="ukia"/>
				</xsl:when>
				<xsl:otherwise>
					<fieldset class="searchType searchFieldCategory">
						<legend class="searchCol1">
							<xsl:if test="($pointInTimeSearch or $extentSearch or $draftLegislationSearch) and not($isRevisedLegislation)"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
							<xsl:value-of select="leg:TranslateText('Type')"/><xsl:text>:</xsl:text>
						</legend>

						<div class="searchCol2 searchType">
							<xsl:choose>
								<xsl:when test="$pointInTimeSearch or $extentSearch">
										<xsl:call-template name="tso:TypeSelect">
											<xsl:with-param name="showPrimary" select="true()" />
											<xsl:with-param name="showSecondary" select="true()" />
											<xsl:with-param name="showEUretained" select="true()" />
											<xsl:with-param name="showDraft" select="false()" />
											<xsl:with-param name="showUnrevised" select="false()" />
											<xsl:with-param name="showImpacts" select="false()" />
											<xsl:with-param name="selected" select="$paramsDoc/parameters/type" />
											<xsl:with-param name="error" select="not($isRevisedLegislation)" />
										</xsl:call-template>
										<xsl:if test="not($isRevisedLegislation)">
											<span class="error"><xsl:value-of select="leg:TranslateText('Please select revised legislations only')"/></span>
										</xsl:if>
								</xsl:when>
								<!--
								<xsl:when test="$extentSearch">
									<xsl:call-template name="tso:TypeChoice">
										<xsl:with-param name="showPrimary" select="true()" />
										<xsl:with-param name="showSecondary" select="false()" />
										<xsl:with-param name="selected" select="$paramsDoc/parameters/type" />
									</xsl:call-template>
								</xsl:when>
								-->
								<xsl:when test="$draftLegislationSearch">
									<xsl:call-template name="tso:TypeChoice">
										<xsl:with-param name="showPrimary" select="false()" />
										<xsl:with-param name="showSecondary" select="false()" />
										<xsl:with-param name="showImpacts" select="false()" />
										<xsl:with-param name="showDraft" select="$draftLegislationSearch" />
										<xsl:with-param name="selected" select="$paramsDoc/parameters/type" />
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$impactAssessmentSearch">
									<xsl:call-template name="tso:TypeChoice">
										<xsl:with-param name="showPrimary" select="false()" />
										<xsl:with-param name="showSecondary" select="false()" />
										<xsl:with-param name="showImpacts" select="$impactAssessmentSearch" />
										<xsl:with-param name="selected" select="$paramsDoc/parameters/type" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="tso:TypeChoice">
										<xsl:with-param name="showPrimary" select="true()" />
										<xsl:with-param name="showSecondary" select="true()" />
										<xsl:with-param name="showEUretained" select="true()" />
										<xsl:with-param name="showImpacts" select="false()" />
										<xsl:with-param name="selected" select="$paramsDoc/parameters/type" />
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</div>

						<div class="searchCol3">
							<a class="helpIcon helpItem helpItemToMidRight" href="#typeHelp">
								<img alt=" Help about Legislation Type searching" src="/images/chrome/helpIcon.gif"/>
							</a>
						</div>
					</fieldset>
				</xsl:otherwise>
			</xsl:choose>

			<!-- point in time -->
			<xsl:if test="$pointInTimeSearch">
				<xsl:variable name="basedate" select="leg:base-date(tso:getLongType($paramsDoc/parameters/type))"/>
				<xsl:variable name="invalidPointInTime" as="xs:boolean"
					select="$paramsDoc/parameters/version[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}')
							and xs:date(concat(substring(., 7), '-' , substring(., 4,2), '-' , substring(., 1,2))) &lt; $basedate]
							 or
						$paramsDoc/parameters/version[. castable as xs:date and
							xs:date(.) &lt; $basedate]"/>

				<div class="searchPIT searchFieldCategory">
					<div class="searchCol1">
						<label for="PIT">
							<xsl:if test="$invalidPointInTime">
								<xsl:attribute name="class">error</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="leg:TranslateText('Point in time')"/><xsl:text>:</xsl:text>
						</label>
					 </div>
					 <div class="searchCol2 pointInTime">
						<!--<input id="pitDay" type="text" name="pitDay" />
						<input id="pitMonth" type="text" name="pitMonth" />-->
						<input id="PIT" type="text" name="version"
							value="{if ($paramsDoc/parameters/version[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}')]) then leg:resolve-request-data($paramsDoc/parameters/version)
										else if ($paramsDoc/parameters/version[. castable as xs:date]) then format-date($paramsDoc/parameters/version, '[D01]/[M01]/[Y0001]')
										else ''}">
								<xsl:if test="$invalidPointInTime">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
							</input>

						<xsl:if test="$invalidPointInTime">
							<span class="error errorMessage"><xsl:value-of select="leg:TranslateText('Point_in_time_error')"/></span>
						</xsl:if>
					 </div>


					<div class="searchCol3">
						<a class="helpIcon helpItem helpItemToMidRight" href="#PITHelp">
						<img alt=" Help about Point In Time searching" src="/images/chrome/helpIcon.gif"/>
					</a>
				</div>
				</div>


			</xsl:if>

			<!-- submit -->
			<div class="submit">
				<button class="userFunctionalElement" id="contentAdvancedSearchSubmit" type="submit">
					<xsl:value-of select="leg:TranslateText('Advanced Search')"/>
				</button>
			</div>
		</form>

		<!-- help tips-->
		<div class="help" id="titleHelp">
			<span class="icon"></span>
			<div class="content">
				<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
				<h3><xsl:value-of select="leg:TranslateText('Title')"/></h3>
				<p>
					<xsl:value-of select="leg:TranslateText('Search_tooltip_title')"/>
				</p>
			</div>
		</div>
		<div class="help" id="yearHelp">
			<span class="icon"></span>
			<div class="content">
				<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
				<h3><xsl:value-of select="leg:TranslateText('Year')"/></h3>
				<xsl:choose>
					<xsl:when test="$pointInTimeSearch">
						<p><xsl:value-of select="leg:TranslateText('Search_tooltip_year_pit')"/></p>
					</xsl:when>
					<xsl:otherwise>
						<p><xsl:value-of select="leg:TranslateText('Search_tooltip_year')"/></p>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>

		<div class="help" id="numberHelp">
			<span class="icon"></span>
			<div class="content">
				<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
				<h3><xsl:value-of select="leg:TranslateText('Number')"/></h3>
				<xsl:choose>
					<xsl:when test="$pointInTimeSearch or $extentSearch">
						<p><xsl:value-of select="leg:TranslateText('Search_tooltip_number_pit_extent')"/></p>
					</xsl:when>
					<xsl:otherwise>
						<p><xsl:value-of select="leg:TranslateText('Search_tooltip_number')"/></p>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>

		<div class="help" id="typeHelp">
			<span class="icon"></span>
			<div class="content">
				<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
				<h3><xsl:value-of select="leg:TranslateText('Type')"/></h3>
				<xsl:choose>
					<xsl:when test="$pointInTimeSearch or $extentSearch">
						<p><xsl:value-of select="leg:TranslateText('Search_tooltip_type_pit_extent')"/></p>
					</xsl:when>
					<xsl:when test="$draftLegislationSearch">
						<p><xsl:value-of select="leg:TranslateText('Search_tooltip_type_draft')"/></p>
					</xsl:when>
					<xsl:otherwise>
						<p><xsl:value-of select="leg:TranslateText('Search_tooltip_type')"/></p>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>

		<!-- Keyword search is not supported
		<xsl:if test="($extendSearch or $generalSearch)">
		<div class="searchHelp" id="keywordHelp">
			<h2>Keyword</h2>
			<p>
				Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque at tortor lorem. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce non sem felis
			</p>
			<span class="icon"/>
		</div>
		</xsl:if>-->


		<xsl:if test="$pointInTimeSearch">
			<div class="help" id="PITHelp">
				<span class="icon"></span>
				<div class="content">
					<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
					<h3><xsl:value-of select="leg:TranslateText('Point in time')"/></h3>
					<p><xsl:value-of select="leg:TranslateText('Search_tooltip_pit')"/></p>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="$extentSearch">
			<div class="help" id="extendsHelp">
				<span class="icon"></span>
				<div class="content">
					<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
					<h2><xsl:value-of select="leg:TranslateText('Extends')"/></h2>
					<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque at tortor lorem. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce non sem felis</p>
				</div>
			</div>
		</xsl:if>

	</xsl:template>

	<xsl:template name="TSOOutputNumber">
		<xsl:param name="includeSeries" as="xs:boolean" select="false()"/>
		<!--
			note the catch for the number matches(., '[0-9]+') and string-length(.) &gt; 10 is because
			these values need to be cast as xs:int for the marklogic indexes
			xs:intwhich is a restriction of xs:long and not available to saxon HE
			therefore we cannot test whether it is castable.
			xs:integer is a restriction of xs:decimal and is not a sufficient test
		-->
		<xsl:variable name="invalidNumber" as="xs:boolean" select="exists($paramsDoc/parameters/number[. != '' and (not(matches(., '^\d*$' )) or (matches(., '[0-9]+') and string-length(.) &gt; 10))])"/>
		<xsl:variable name="invalidSeries" as="xs:boolean" select="exists($paramsDoc/parameters/series[. != '' and not(. = ('w', 's', 'ni', 'l', 'c'))])"/>

		<div class="searchNumber searchFieldCategory">
			<div class="searchCol1">
				<label for="searchNumber">
					<xsl:if test="$invalidNumber or $invalidSeries">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="leg:TranslateText('Number')"/>:
				</label>
				</div>
			<div class="searchCol2 numberSearch">
				<input type="text" id="searchNumber" name="number" value="{leg:resolve-request-data($paramsDoc/parameters/number)}">
					<xsl:if test="$invalidNumber">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
				</input>

				<xsl:if test="$includeSeries">
					<select type="text" id="numberDropdown" name="series">
						<xsl:if test="$invalidSeries">
							<xsl:attribute name="class">error</xsl:attribute>
						</xsl:if>
						<option><xsl:value-of select="leg:TranslateText('Main')"/></option>
						<option value="w"><xsl:value-of select="leg:TranslateText('Welsh')"/></option>
						<option value="s"><xsl:value-of select="leg:TranslateText('Scottish')"/></option>
						<option value="ni"><xsl:value-of select="leg:TranslateText('N.I.')"/></option>
						<option value="c"><xsl:value-of select="leg:TranslateText('Commencement')"/></option>
						<option value="l"><xsl:value-of select="leg:TranslateText('Legal')"/></option>
					</select>
					<label for="numberDropdown">
						<xsl:value-of select="leg:TranslateText('Series Number')"/>

						<xsl:if test="$invalidSeries">
							<span class="error errorMessage"><xsl:value-of select="leg:TranslateText('Not a valid series')"/></span>
						</xsl:if>
					</label>
				</xsl:if>

				<xsl:if test="$invalidNumber">
					<span class="error errorMessage"><xsl:value-of select="leg:TranslateText('Not a valid number')"/></span>
				</xsl:if>
			</div>
			<div class="searchCol3">
				<a class="helpIcon helpItem helpItemToMidRight" href="#numberHelp">
					<img alt=" Help about Number and Series searching" src="/images/chrome/helpIcon.gif"/>
				</a>
			</div>
		</div>
	</xsl:template>

	<xsl:function name="leg:resolve-request-data" as="xs:string">
		<xsl:param name="string" as="xs:string"/>

		<xsl:variable name="removechars" select="replace($string, '&#8221;|&lt;|&gt;', '')"/>
		<xsl:variable name="removedoublequotes" select='translate($removechars, """", "")'/>
		<xsl:value-of select="$removedoublequotes"/>
	</xsl:function>

</xsl:stylesheet>
