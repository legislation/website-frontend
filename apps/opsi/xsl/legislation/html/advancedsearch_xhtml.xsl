<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

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
		select="exists($paramsDoc/parameters/type[. = ('', 'all', 'primary', 'ukpga', 'ukla', 'apgb', 'aep', 'aosp', 'asp', 'aip', 'apni', 'mnia', 'nia', 'ukcm', 'mwa', 'nisi')])"/>

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
                <script type="text/javascript" src="/scripts/advancedsearch/search.js"></script>
				<link type="text/css" href="/styles/legBrowse.css" rel="stylesheet"/>
				
				<xsl:if test="$pointInTimeSearch or $impactAssessmentSearch">
					<link rel="stylesheet" href="/styles/advancedsearch/jquery.ui.datepicker.css" type="text/css" />
					<link rel="stylesheet" href="/styles/advancedsearch/jquery-ui.css" type="text/css" />
					<script type="text/javascript" src="/scripts/jquery-ui-1.8.1.custom.min.js"></script>
					<script type="text/javascript" src="/scripts/advancedsearch/jquery.ui.datepicker.min.js"></script>
				</xsl:if>
				
			</head>		
		
			<body lang="en" xml:lang="en" dir="ltr" id="search" class="intro">
				<div id="layout2">
				
					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>
					
					<div class="titles">
						<h1 id="pageTitle">Advanced Search</h1>
					</div>					
					
					<div id="tools">
						<div>
							<h2>Find legislation</h2>
						</div>
						<div id="links">
							<a href="/search">
								<xsl:if test="$generalSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:text>General</xsl:text>
							</a>
							<a href="/search/extent">
								<xsl:if test="$extentSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:text>Geographical Extent</xsl:text>
							</a>
							<a href="/search/point-in-time">
								<xsl:if test="$pointInTimeSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:text>Point in Time</xsl:text>
							</a>
							<a href="/search/draft-legislation">
								<xsl:if test="$draftLegislationSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:text>Draft Legislation</xsl:text>
							</a>							
							<a href="/search/impacts">
								<xsl:if test="$impactAssessmentSearch">
									<xsl:attribute name="class">current</xsl:attribute>
								</xsl:if>
								<xsl:text>Impact Assessments</xsl:text>
							</a>
						</div>
					</div>					
					
					<div id="content">
					
						<xsl:if test="exists($errorSearchingDoc)">
							<div id="errorBar" class="error errorMessage">
								<xsl:value-of select="concat('Please check the form fields which are highlighted in red. ', $errorSearchingDoc/errorsearching/message)"/>
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
		<form id="advancedSearch" class="advancedSearch" method="get" action="/search" style="display: block;">
			<h2>
				<xsl:choose>
					<xsl:when test="$pointInTimeSearch">
						<xsl:text>Legislation as it stood at a specific point in time (for revised legislation only)</xsl:text>
					</xsl:when>
                    <xsl:when test="$extentSearch">
                        <xsl:text>Geographical extent search (for revised legislation only)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$draftLegislationSearch">
                        <xsl:text>Draft Legislation search</xsl:text>
                    </xsl:when>    
					<xsl:when test="$impactAssessmentSearch">
                        <xsl:text>Impact Assessment search</xsl:text>
                    </xsl:when> 
					<xsl:otherwise>
						<xsl:text>General search</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</h2>

			<!-- extends search -->
			<xsl:if test="$extentSearch">
				<p>These advanced features are only available on searches for revised legislation e.g. Acts. Secondary legislation will not be included in search results.</p>
				<div class="searchExtendsTo searchFieldCategory">
					<div class="searchFieldGroup">
						<h3>Extends to</h3>
						<!--
						<a class="helpIcon advancedSearchHelp" href="#extendsHelp">
							<img alt=" Help about Extends searching" src="/images/chrome/helpIcon.gif"/>
						</a>
						-->
					</div>

					<div class="searchFieldGroup">
						<div class="searchCol1">
							<xsl:text>Geographical extent</xsl:text>
						</div>

						<div class="searchCol2 searchExtendsToInput">
							<div class="opt1 group">
								<label>
									<input type="radio" name="extent-match" value="applicable" checked="checked" class="radio yearChoice" />
										<xsl:text>Applicable to:</xsl:text>
									</label>
								<label>
									<input type="radio" name="extent-match" value="exact" class="radio yearChoice" />
										<xsl:text>Exclusively extends to:</xsl:text>
								</label>
							</div>
							<div class="opt2">
								<label>
									<input type="checkbox" name="extent" value="uk" class="checkbox" />
									<xsl:text>United Kingdom</xsl:text>
								</label>
								<label>
									<input type="checkbox" name="extent" value="gb" class="checkbox" />
									<xsl:text>Great Britain</xsl:text>
								</label>
								<label>
									<input type="checkbox" name="extent" value="ew" class="checkbox" />
									<xsl:text>England &amp; Wales</xsl:text>
								</label>
							</div>
							<div class="opt2">
								<label>
									<input type="checkbox" name="extent" checked="checked" value="england" class="checkbox" />
									<xsl:text>England</xsl:text>
								</label>
								<label>
									<input type="checkbox" name="extent" checked="checked" value="wales" class="checkbox" />
									<xsl:text>Wales</xsl:text>
								</label>
								<label>
									<input type="checkbox" name="extent" checked="checked" value="scotland" class="checkbox" />
									<xsl:text>Scotland</xsl:text>
								</label>
								<label>
									<input type="checkbox" name="extent" checked="checked" value="ni" class="checkbox" />
									<xsl:text>Northern Ireland</xsl:text>
								</label>
							</div>
						</div>
					</div>
				</div>
			</xsl:if>
		
			<!-- title -->
			<div class="searchTitle searchFieldCategory">
				<div class="searchCol1">
				<label for="searchTitle">
					<xsl:text>Title:</xsl:text>
				</label>
				</div>
				<div class="searchCol2">
					<div class="searchFieldGroup">
						<input type="text" id="searchTitle" name="title" value="{$paramsDoc/parameters/title}"/>
						<span>(or keywords in the title)</span>
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
						<label for="text">Keywords in content: </label>
					</div>
					<div class="searchCol2">
						<div class="searchFieldGroup">
							<input type="text" id="searchText" name="text" value="{$paramsDoc/parameters/text}" />
							<span>(using double quotes around a phrase will give faster results)</span>
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
						<label for="text">Stage: </label>
					</div>
					<div class="searchCol2">
						<div class="searchFieldGroup">
							<input type="text" id="stageText" name="stage" value="{$paramsDoc/parameters/stage}" />
							<span>(whole name of the stage required)</span>
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
						<label for="text">Department: </label>
					</div>
					<div class="searchCol2">
						<div class="searchFieldGroup">
							<input type="text" id="departmentText" name="department" value="{$paramsDoc/parameters/department}" />
							<span>(whole name of the department required)</span>
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
							
							    
					<div class="searchYear searchFieldCategory">
						<div class="searchCol1">
							<label for="specificYear">
								<xsl:if test="$invalidYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:text>Year:</xsl:text>
							</label>
						</div>
						
						<div class="searchCol2">
							<div class="specificYear formGroup">
								<input type="radio" id="specificRadio" name="yearRadio" value="specific"
									checked="true"/>
								<label for="specificRadio">Specific Year</label>
								<div>
									<input type="text" id="specificYear" name="year" maxlength="4"
										value="{$paramsDoc/parameters/year}">
										<xsl:if test="$invalidYear">
											<xsl:attribute name="class">error</xsl:attribute>
										</xsl:if>
									</input>
								</div>
							</div>
							<div class="rangeOfDates formGroup">
								<input type="radio" id="rangeRadio" name="yearRadio" value="range"/>
								<label for="rangeRadio">Range</label>
								<div class="yearRange">
									<div>
										<label for="yearStart">From</label>
										<input id="start" type="text" name="start" 
							value="{if ($paramsDoc/parameters/start[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}')]) then $paramsDoc/parameters/start	
										else if ($paramsDoc/parameters/start[. castable as xs:date]) then format-date($paramsDoc/parameters/start, '[D01]/[M01]/[Y0001]')
										else ''}">
											<xsl:if test="$invalidStartDate">
												<xsl:attribute name="class">error</xsl:attribute>
											</xsl:if>										
										</input>
									</div>
									<div>
										<label for="yearEnd">To</label>
										<input id="end" type="text" name="end" 
							value="{if ($paramsDoc/parameters/start[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}')]) then $paramsDoc/parameters/start	
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
								<span class="error errorMessage">Not a valid year (YYYY)</span>
							</xsl:if>
						</div>
						
						<div class="searchCol3">
							<a class="helpIcon helpItem helpItemToMidRight" href="#yearHelp">
								<img alt=" Help about Year Range searching" src="/images/chrome/helpIcon.gif"/>
							</a>
						</div>
					</div>
				
				</xsl:if>
			
			<!-- language -->
			<xsl:if test="$generalSearch">
				<div class="searchLang searchFieldCategory">
					<div class="searchCol1">
						<label for="lang">Language: </label>
					</div>
					<div class="searchCol2">
						<div class="englishLang formGroup">
							<input type="radio" id="englishRadio" name="lang" value="en" checked="true"/>
							<label for="englishRadio">English</label>
						</div>
						<div class="welshLang formGroup">
							<input type="radio" id="welshRadio" name="lang" value="cy"/>
							<label for="welshRadio">Welsh</label>
						</div>
					</div>
					<div class="searchCol3">
						<!--
						<a class="helpIcon advancedSearchHelp" href="#langHelp">
							<img alt=" Help about language searching" src="/images/chrome/helpIcon.gif"/>
						</a>
						-->
					</div>					
				</div>	
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
							<label for="specificYear">
								<xsl:if test="$invalidYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:text>Year: </xsl:text>
							</label>
						</div>
						<div class="searchCol2">
							<div class="specificYear PIT">
								<input type="text" id="specificYear" name="year" maxlength="4" value="{$paramsDoc/parameters/year}">
									<xsl:if test="$invalidYear">
										<xsl:attribute name="class">error</xsl:attribute>
									</xsl:if>								
								</input>
							</div>
							<xsl:if test="$invalidYear">
								<span class="error errorMessage">The year must be valid and before the point in time search</span>
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
								<xsl:text>Year:</xsl:text>
							</label>
						</div>
						
						<div class="searchCol2">
							<div class="specificYear formGroup">
								<input type="radio" id="specificRadio" name="yearRadio" value="specific"
									checked="true"/>
								<label for="specificRadio">Specific Year</label>
								<div>
									<input type="text" id="specificYear" name="year" maxlength="4"
										value="{$paramsDoc/parameters/year}">
										<xsl:if test="$invalidYear">
											<xsl:attribute name="class">error</xsl:attribute>
										</xsl:if>
									</input>
								</div>
							</div>
							<div class="rangeOfYears formGroup">
								<input type="radio" id="rangeRadio" name="yearRadio" value="range"/>
								<label for="rangeRadio">Range</label>
								<div class="yearRange">
									<div>
										<label for="yearStart">From</label>
										<input type="text" id="yearStart" name="start-year" maxlength="4"
											value="{$paramsDoc/parameters/start-year}">
											<xsl:if test="$invalidYearRange">
												<xsl:attribute name="class">error</xsl:attribute>
											</xsl:if>
										</input>
									</div>
									<div>
										<label for="yearEnd">To</label>
										<input type="text" id="yearEnd" name="end-year" maxlength="4"
											value="{$paramsDoc/parameters/end-year}">
											<xsl:if test="$invalidYearRange">
												<xsl:attribute name="class">error</xsl:attribute>
											</xsl:if>
										</input>
									</div>
								</div>
							</div>
							<xsl:if test="$invalidYear or $invalidYearRange">
								<span class="error errorMessage">Not a valid year (YYYY)</span>
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
			<div class="searchType searchFieldCategory">
				<div class="searchCol1">
					<label for="type">
						<xsl:if test="($pointInTimeSearch or $extentSearch or $draftLegislationSearch) and not($isRevisedLegislation)"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
						<xsl:text>Type:</xsl:text>
					</label>
				</div>
				
				
				<div class="searchCol2 searchType">
					<xsl:choose>
						<xsl:when test="$pointInTimeSearch or $extentSearch">
								<xsl:call-template name="tso:TypeSelect">
									<xsl:with-param name="showPrimary" select="true()" /> 
									<xsl:with-param name="showSecondary" select="true()" />
                  					<xsl:with-param name="showDraft" select="false()" />
					                <xsl:with-param name="showUnrevised" select="false()" />
									<xsl:with-param name="selected" select="$paramsDoc/parameters/type" />
									<xsl:with-param name="error" select="not($isRevisedLegislation)" />
								</xsl:call-template>
								<xsl:if test="not($isRevisedLegislation)">
									<span class="error">Please select revised legislations only</span>
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
			</div>
			
			<!-- point in time -->	
			<xsl:if test="$pointInTimeSearch">
			
				<xsl:variable name="invalidPointInTime" as="xs:boolean" 
					select="$paramsDoc/parameters/version[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}') 
							and xs:date(concat(substring(., 7), '-' , substring(., 4,2), '-' , substring(., 1,2))) &lt; xs:date (
								if ($paramsDoc/parameters/type = ('nia', 'nisi', 'mnia','apni')) then '2006-01-01' 								
								else '1991-02-01'
								)
							]
							 or 
						$paramsDoc/parameters/version[. castable as xs:date and 
							xs:date(.) &lt; xs:date(
										if ($paramsDoc/parameters/type = ('nia', 'nisi', 'mnia','apni')) then '2006-01-01' 								
										else '1991-02-01'
										)
							]"/>
							
				<div class="searchPIT searchFieldCategory">
					<div class="searchCol1">
						<label for="PIT">	
							<xsl:if test="$invalidPointInTime">
								<xsl:attribute name="class">error</xsl:attribute>
							</xsl:if>
							Point in time:
						</label>
					 </div>
					 <div class="searchCol2 pointInTime">
						<!--<input id="pitDay" type="text" name="pitDay" value=""/>
						<input id="pitMonth" type="text" name="pitMonth" value=""/>-->
						<input id="PIT" type="text" name="version" 
							value="{if ($paramsDoc/parameters/version[matches(., '[0-9]{2}/[0-9]{2}/[0-9]{4}')]) then $paramsDoc/parameters/version	
										else if ($paramsDoc/parameters/version[. castable as xs:date]) then format-date($paramsDoc/parameters/version, '[D01]/[M01]/[Y0001]')
										else ''}">
								<xsl:if test="$invalidPointInTime">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>										
							</input>
						
						<xsl:if test="$invalidPointInTime">
							<span class="error errorMessage">Point in Time must be after 01/01/2006 if you have selected Northern Ireland legislation, and after 01/02/1991 for other primary legislation types</span>
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
				<button class="userFunctionalElement" id="contentSearchSubmit" type="submit">
					Advanced Search
				</button>
			</div>			
		</form>
		
		<!-- help tips--> 
		<div class="help" id="titleHelp">
			<span class="icon"></span>
			<div class="content">
				<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
			<h3>Title</h3>
			<p>
				Enter a full title or part of a title to find results based on title.  The search will show results that match on any part of the title. For example ‘Data’ will match ‘Data Protection Act’ and ‘The Data Retention Regulations’. To exclude a term, use the minus operator before the term you wish to exclude. For example searching ‘Data -protection’ would return ‘The Data Retention Regulations’ but not the ‘Data Protection Act’.  Use double quotes for an exact match on a phrase e.g “Data Protection” would return ‘The Data Protection Act’ but not ‘The Protection of Vulnerable Groups (Data Handling) Regulations’. Alternatively, leave blank if you do not wish to specify a title match.  
			</p>
			</div>
		</div>
		<div class="help" id="yearHelp">
			<span class="icon"></span>
			<div class="content">
				<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
				<h3>Year</h3>				
				<xsl:choose>
					<xsl:when test="$pointInTimeSearch">
						<p>Enter the year of the legislation you would like to view. This is the year it was enacted/made.</p>
					</xsl:when>
					<xsl:otherwise>
						<p>Select whether you would like to search across legislation for a particular year or range of years. This is not a required field and can be left empty if you do not wish to narrow your search by year. </p>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
		
		<div class="help" id="numberHelp">
			<span class="icon"></span>
			<div class="content">
				<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
				<h3>Number</h3>								
				<xsl:choose>
					<xsl:when test="$pointInTimeSearch or $extentSearch">
						<p>Use this field to specify the number of the legislation if you know it. This field is not mandatory. Please note that a point in time or geographic extent search is only possible on the legislation that we revise (primary legislation). For example, an SI number will not be a valid search.</p>
					</xsl:when>
					<xsl:otherwise>
						<p>If you know the number of the legislation item you are looking for enter it here. There are several ways to search by number as some items of legislation are assigned multiple numbers each from different numbering systems.  Where multiple numbering systems have been used, you can select which one you wish to search by from the drop down box. If you are unsure, we recommend you keep ‘main series’ selected. </p>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
		
		<div class="help" id="typeHelp">
			<span class="icon"></span>
			<div class="content">
				<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
				<h3>Type</h3>												
				<xsl:choose>
					<xsl:when test="$pointInTimeSearch or $extentSearch">
						<p>Use the drop down to specify the type of legislation for the search. Please note that point in time and geographic extent search is only possible on legislation that we revise so only primary legislation types are listed. </p>
					</xsl:when>
					<xsl:when test="$draftLegislationSearch">
						<p>It is possible to narrow your search across a particular legislation type or set of legislation types by using the checkboxes. Select ‘All Draft' if you do not wish to restrict your search to particular types of draft legislation.  See the Help section for advice about understanding different legislation types.</p>					
					</xsl:when>
					<xsl:otherwise>
						<p>It is possible to narrow your search across a particular legislation type or set of legislation types by using the checkboxes. The first column shows all the possible primary legislation types, and the second column all the secondary legislation types.  Select ‘All Legislation’ if you do not wish to restrict your search to particular types of legislation.  See the Help section for advice about understanding different legislation types.</p>
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
					<h3>Point in time</h3>												
					<p>Use this field to select a date and see how your specified legislation stood at a particular point in time. Only dates after the basedate (01/02/1991) are valid we do not have versions that precede this date in the data. For Northern Ireland legislation the basedate is 01/01/ 2006.</p>
			</div>
			</div>			
		</xsl:if>		
		
		<xsl:if test="$extentSearch">
			<div class="help" id="extendsHelp">
				<span class="icon"></span>
				<div class="content">
					<a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
					<h2>Extends</h2>
					<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque at tortor lorem. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce non sem felis</p>
				</div>
			</div>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template name="TSOOutputNumber">
		<xsl:param name="includeSeries" as="xs:boolean" select="false()"/>
		<xsl:variable name="invalidNumber" as="xs:boolean" select="exists($paramsDoc/parameters/number[. != '' and not(matches(., '(\*|[0-9]+)(-(\*|[0-9]+))?' ))])"/>
		<xsl:variable name="invalidSeries" as="xs:boolean" select="exists($paramsDoc/parameters/series[. != '' and not(. = ('w', 's', 'ni', 'l', 'c'))])"/>
		
		<div class="searchNumber searchFieldCategory">
			<div class="searchCol1">
				<label for="searchNumber">
					<xsl:if test="$invalidNumber or $invalidSeries">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>
					Number:
				</label>
				</div>
			<div class="searchCol2 numberSearch">
				<input type="text" id="searchNumber" name="number" value="{$paramsDoc/parameters/number}">
					<xsl:if test="$invalidNumber">
						<xsl:attribute name="class">error</xsl:attribute>
					</xsl:if>										
				</input>
	
				<xsl:if test="$includeSeries">
					<select type="text" id="numberDropdown" name="series">
						<xsl:if test="$invalidSeries">
							<xsl:attribute name="class">error</xsl:attribute>
						</xsl:if>					
						<option value="">Main</option>
						<option value="w">Welsh</option>
						<option value="s">Scottish</option>
						<option value="ni">N.I.</option>
						<option value="c">Commencement</option>
						<option value="l">Legal</option>
					</select>
					<xsl:text>Series Number</xsl:text>
					<xsl:if test="$invalidSeries">
						<span class="error errorMessage">Not a valid series</span>
					</xsl:if>						
				</xsl:if>
			
				<xsl:if test="$invalidNumber">
					<span class="error errorMessage">Not a valid number</span>
				</xsl:if>				
			</div>			
			<div class="searchCol3">
				<a class="helpIcon helpItem helpItemToMidRight" href="#numberHelp">
					<img alt=" Help about Number and Series searching" src="/images/chrome/helpIcon.gif"/>
				</a>
			</div>						
		</div>	
	</xsl:template>
			
</xsl:stylesheet>
