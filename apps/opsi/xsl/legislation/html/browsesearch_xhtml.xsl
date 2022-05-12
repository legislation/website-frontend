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

	<xsl:import href="searchcommon_xhtml.xsl" />

	<xsl:variable name="link" as="xs:string" select="leg:GetLink(//atom:link[@rel = 'first']/@href)"/>


	<xsl:variable name="typeSub" as="xs:string" select="atom:feed/openSearch:Query/@leg:type"></xsl:variable>

	<xsl:variable name="sub" as="xs:string*" select="atom:feed/openSearch:Query/@leg:subject"></xsl:variable>

	<xsl:variable name="isEUretained" as="xs:boolean" select="some $item in /atom:feed/leg:facets/leg:facetTypes/leg:facetType/@type satisfies $item = $leg:euretained" />

	<xsl:template match="atom:feed" mode="searchfacets">
		<xsl:choose>
			<xsl:when test="matches(atom:id, 'http://www.legislation.gov.uk/research/proximity/search')">
				<div id="tools">
					<!--<h2 class="accessibleText">Narrow results by:</h2>-->
					<div class="section">
						<div class="title">
							<h2><a href="/research/proximity/search">Proximity Search</a></h2>
						</div>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="leg:facets" mode="searchfacets"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="leg:facets[empty(leg:facetTypes/*) and empty(leg:facetYears/*) and empty(leg:facetHundreds/*)]" mode="searchfacets">
		<div id="tools">
			<h2 class="accessibleText">Narrow results by:</h2>
			<div class="section" id="refineSearch">
				<div class="title">
					<h3><xsl:value-of select="leg:TranslateText('Refine your search:')"/></h3>
				</div>
				<div class="content">
					<form id="advancedSearch" name="advancedSearch" action="/search" method="get">
						<xsl:if test="$paramsDoc/parameters/title[. != '']">
							<div class="group">
								<label for="searchText"><xsl:value-of select="leg:TranslateText('Title')"/>: </label>
								<input type="title" id="searchTitle" name="title" value="{/atom:feed/openSearch:Query[@role = 'request']/@leg:title}" />
							</div>
						</xsl:if>
						<div class="group">
							<label for="searchText"><xsl:value-of select="leg:TranslateText('Keywords in content:')"/></label>
							<input type="text" id="searchText" name="text" value="{/atom:feed/openSearch:Query[@role = 'request']/@searchTerms}" />
						</div>
						<xsl:if test="$paramsDoc/parameters/lang[. = 'cy']">
							<p><xsl:value-of select="leg:TranslateText('Language:')"/></p>
							<div class="searchLang group">
								<div class="englishLang formGroup">
									<input type="radio" name="lang" id="englishRadio" value="en" class="radio" />
									<label for="englishRadio"><xsl:value-of select="leg:TranslateText('English')"/></label>
								</div>
								<div class="welshLang formGroup">
									<input type="radio" name="lang" id="welshRadio" value="cy" class="radio" checked="checked" />
									<label for="welshRadio"><xsl:value-of select="leg:TranslateText('Welsh')"/></label>
								</div>
							</div>
						</xsl:if>
						<xsl:variable name="year" as="xs:string?" select="$paramsDoc/parameters/year[. != '']" />
						<xsl:variable name="start-year" as="xs:string?"
							select="if (contains($year, '-')) then substring-before($year, '-') else $paramsDoc/parameters/start-year[. != '']" />
						<xsl:variable name="end-year" as="xs:string?"
							select="if (contains($year, '-')) then substring-after($year, '-') else $paramsDoc/parameters/end-year[. != '']" />
						<xsl:variable name="start-year" as="xs:string?" select="if ($start-year = '*') then () else $start-year" />
						<xsl:variable name="end-year" as="xs:string?" select="if ($end-year = '*') then () else $end-year" />
						<xsl:variable name="year" as="xs:string?" select="if ($start-year = $end-year) then $start-year else if ($start-year or $end-year) then () else $year" />
						<p><xsl:value-of select="leg:TranslateText('Year')"/>:</p>
						<div class="searchYear searchFieldCategory group">
							<div class="specificYear formGroup">
								<input type="radio" name="yearRadio" id="specificRadio" value="specific" class="yearChoice radio">
									<xsl:if test="not($start-year or $end-year)">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>

								<label for="specificRadio"><xsl:value-of select="leg:TranslateText('Specific year')"/></label>
								<div class="yearChoiceFields" id="singleYear">
									<div class="from">
										<label for="specificYear"><xsl:value-of select="leg:TranslateText('Year')"/>:</label>
										<input type="text" id="specificYear" name="year" value="{$year}" />
									</div>
								</div>
							</div>
							<div class="rangeOfYears formGroup">
								<input type="radio" name="yearRadio" id="rangeRadio" value="range" class="yearChoice radio">
									<xsl:if test="$start-year or $end-year">
										<xsl:attribute name="checked">checked</xsl:attribute>
									</xsl:if>
								</input>
								<label for="rangeRadio"><xsl:value-of select="leg:TranslateText('Range of years')"/></label>
								<div class="yearChoiceFields" id="rangeYears">
									<div class="from">
										<label for="yearStart"><xsl:value-of select="leg:TranslateText('From')"/>:</label>
										<input type="text" id="yearStart" name="start-year" value="{$start-year}"/>
									</div>
									<div class="to">
										<label for="yearEnd"><xsl:value-of select="leg:TranslateText('To')"/>:</label>
										<input type="text" id="yearEnd" name="end-year" value="{$end-year}"/>
									</div>
								</div>
							</div>
						</div>
						<xsl:if test="$paramsDoc/parameters/extent-match[. != '']">
							<xsl:variable name="extents" as="xs:string*" select="tokenize($paramsDoc/parameters/extent, '\+')" />
							<p>Geographical extent:</p>
							<div class="searchExtendsTo">
								<div class="searchExtendsToInput">
									<div class="opt1 group">
										<label>
											<input type="radio" name="extent-match" id="extent-match-1" value="applicable" class="radio yearChoice">
												<xsl:if test="$paramsDoc/parameters/extent-match[. = 'applicable']">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('Applicable to')"/>
											<xsl:text>:</xsl:text>
										</label>
										<label>
											<input type="radio" name="extent-match" id="extent-match-2" value="exact" class="radio yearChoice">
												<xsl:if test="$paramsDoc/parameters/extent-match[. = 'exact']">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('Exclusively extends to')"/>
											<xsl:text>:</xsl:text>
										</label>
									</div>
									<div class="opt2">
										<label>
											<input type="checkbox" name="extent" value="uk" class="radio">
												<xsl:if test="$extents = 'uk'">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('United Kingdom')"/>
										</label>
										<label>
											<input type="checkbox" name="extent" value="gb" class="radio">
												<xsl:if test="$extents = 'gb'">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('Great Britain')"/>
										</label>
										<label>
											<input type="checkbox" name="extent" value="ew" class="radio">
												<xsl:if test="$extents = 'ew'">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('England &amp; Wales')"/>
										</label>
										<label>
											<input type="checkbox" name="extent" value="england" class="radio">
												<xsl:if test="$extents = 'england'">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('England')"/>
										</label>
										<label>
											<input type="checkbox" name="extent" value="wales" class="radio">
												<xsl:if test="$extents = 'wales'">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('Wales')"/>
										</label>
										<label>
											<input type="checkbox" name="extent" value="scotland" class="radio">
												<xsl:if test="$extents = 'scotland'">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('Scotland')"/>
										</label>
										<label>
											<input type="checkbox" name="extent" value="ni" class="radio">
												<xsl:if test="$extents = 'ni'">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('Northern Ireland')"/>
										</label>
										<label>
											<input type="checkbox" name="extent" value="eu" class="radio">
												<xsl:if test="$extents = 'eu'">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
											</input>
											<xsl:value-of select="leg:TranslateText('European Union')"/>
										</label>
									</div>
								</div>
							</div>
						</xsl:if>
						<div class="group">
							<label for="type"><xsl:value-of select="leg:TranslateText('Type')"/>:</label>

							<xsl:variable name="isDraftSearched" select="tokenize($paramsDoc/parameters/type, '\+') = ('draft', 'ukdsi', 'sdsi', 'nidsr')" />
							<xsl:call-template name="tso:TypeSelect">
								<xsl:with-param name="selected" select="$paramsDoc/parameters/type"/>
								<xsl:with-param name="showPrimary" select="not($isDraftSearched)" />
								<xsl:with-param name="showSecondary" select="not($isDraftSearched)" />
								<xsl:with-param name="showDraft" as="xs:boolean" select="$isDraftSearched" />
								<xsl:with-param name="allowMultipleLines" select="true()" />
								<xsl:with-param name="maxLineLength" select="25" />
							</xsl:call-template>
						</div>
						<div class="group submit">
							<button type="submit" id="contentSearchSubmit" class="userFunctionalElement"><span class="btl"></span><span class="btr"></span><xsl:value-of select="leg:TranslateText('Search')"/><span class="bbl"></span><span class="bbr"></span></button>
						</div>
					</form>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="leg:facets" mode="searchfacets">
		<div id="tools">
			<h2 class="accessibleText">Narrow results by:</h2>
			<xsl:apply-templates select="*">
				<xsl:with-param name="maxYear" select="xs:string(max((leg:facetYears/leg:facetYear/xs:integer(@year), year-from-date(current-date()))))" tunnel="yes" />
			</xsl:apply-templates>
		</div>
	</xsl:template>

	<xsl:template match="leg:facetSubjectsInitials">
		<xsl:if test="(@remove or *)">
			<!-- the facet is selected, such that no further selections can be made, if there's a remove attribute and only one choice -->
			<xsl:variable name="selected" as="xs:boolean" select="exists(@remove)" />
			<div id="heading" class="section">
				<div class="title">
					<h3><xsl:value-of select="leg:TranslateText('Legislation by Subject Heading')"/></h3>

				</div>
				<xsl:if test="not(exists(//openSearch:Query/leg:subject))">
					<div class="title">
						<h4>1. <xsl:value-of select="leg:TranslateText('Select First Letter of Heading')"/></h4>
						</div>
				</xsl:if>
				<div class="content">
					<xsl:if test="$selected">
						<ul>
							<li class="returnLink">
								<a href="{leg:GetLink(@remove)}">
									<span class="accessibleText">
										<xsl:value-of select="leg:TranslateText('Browse by')"/>
										<xsl:text> </xsl:text>
									</span>
									<xsl:value-of select="leg:TranslateText('all headings')"/>
								</a>
							</li>
						</ul>
					</xsl:if>
					<ul>
						<xsl:variable name="availableFacets" select="*" />
						<xsl:variable name="alphabetSequence" as="xs:string" select="'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z'"/>
						<xsl:variable name="alphabetActive" as="xs:string?" select="/atom:feed/openSearch:Query/@leg:subject"/>
						<xsl:for-each select="tokenize($alphabetSequence,',')">
							<xsl:variable name="alphabet" select="."/>
							<xsl:variable name="facet" as="element()?" select="$availableFacets[@initial = lower-case($alphabet)]" />
							<li>
								<xsl:choose>
									<xsl:when test="exists($facet/@value)">
										<xsl:attribute name="class">legHeading active</xsl:attribute>
										<xsl:value-of select="."/>
									</xsl:when>
									<xsl:when test="exists($facet)">
										<xsl:attribute name="class">legHeading</xsl:attribute>
										<a href="{leg:GetSortedLink($facet/@href, 'subject', 'subject')}"><xsl:value-of select="."/></a>

									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class">legHeading empty</xsl:attribute>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>

							</li>

						</xsl:for-each>
					</ul>
				</div>
			</div>
			<div id="subheading" class="section">
			<div class="title">
				<h4>2. <xsl:value-of select="leg:TranslateText('Refine Results')"/></h4>
			</div>
			<div class="content">
				<ul>
						<xsl:apply-templates select="leg:headings"/>
				</ul>
			</div>
			</div>

		</xsl:if>
	</xsl:template>


	<xsl:template match="leg:headings">
		<xsl:variable name="apo">’</xsl:variable>
	    <xsl:variable name="stright">'</xsl:variable>
		<xsl:if test="string-length($sub) != 0">
	    <xsl:variable name="list" as="element()*">
	    	<xsl:sequence select="leg:heading[starts-with(@Value,upper-case($sub))]"/>

	    </xsl:variable>

	<xsl:for-each-group select="$list" group-by="translate(./@Value,$apo,$stright)">
		<xsl:sort select="current-grouping-key()"/>
		<li>
			<a href="{concat('http://www.legislation.gov.uk/',$typeSub,'/', encode-for-uri(lower-case(
				current-grouping-key())))}">
		<xsl:value-of select="current-grouping-key()"/>
			</a>
		</li>
		</xsl:for-each-group>
	                </xsl:if>
	</xsl:template>


	<xsl:template match="leg:facetTypes | leg:facetYears | leg:facetHundreds | leg:facetStages | leg:facetDepartments">
		<xsl:variable name="type" as="xs:string?" select="/atom:feed/openSearch:Query/@leg:type"/>
		<xsl:variable name="legType" as="xs:string" select="if (matches($type,'(impacts|ukia|sia|wia|niia)')) then 'Impact Assessments by ' else 'Legislation by '"/>
		<xsl:variable name="facetType" as="xs:string">
			<xsl:choose>
				<xsl:when test="self::leg:facetTypes">Type</xsl:when>
				<xsl:when test="self::leg:facetYears">Year</xsl:when>
				<xsl:when test="self::leg:facetHundreds">Number</xsl:when>
				<xsl:when test="self::leg:facetStages">Stage</xsl:when>
				<xsl:when test="self::leg:facetDepartments">Department</xsl:when>
				<xsl:otherwise>XXX</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="@remove or *">
			<!-- the facet is selected, such that no further selections can be made, if there's a remove attribute and only one choice -->
			<xsl:variable name="selected" as="xs:boolean" select="exists(@remove) and count(*[@value]) = 1" />
			<div class="section" id="{lower-case($facetType)}">
				<div class="title">
					<h3>
						<xsl:variable name="legTitle">
							<xsl:value-of select="$legType" />
							<xsl:value-of select="$facetType" />
						</xsl:variable>
						<xsl:value-of select="leg:TranslateText($legTitle)"/></h3>
				</div>
				<div class="content">

					<xsl:variable name="availableFacets" select="(if (empty(*[@value])) then * else *[@value])" />
					<xsl:variable name="availableFacetsPages" select="ceiling(count($availableFacets) div 24)" />

					<xsl:if test="$facetType = ('Year', 'Number') and $availableFacetsPages > 1">
						<xsl:attribute name="id">yearPagination</xsl:attribute>
					</xsl:if>

					<!--
						If facetYears and there is no selection (no @value attributes exists) then no need to display 'Browse by Year' and selected years list
						If facetHundreds and there is no selection (multiple @value exists) then no need to display 'Browse by Number' and selected numbers list
						Otherwise display the Browse by Type/Year/Number
					 -->
					<xsl:if test="not( (self::leg:facetYears and empty(*[@value])) or (self::leg:facetHundreds and count(*[@value]) > 1))">
						<ul>

							<!-- only add the 'all types' link if there is an year or title present, otherwise the search is too large -->
							<!-- only add the 'all years' link if there is no number provided, otherwise the search is non-sensical -->
							<xsl:if test="exists(@remove) and
								(if (self::leg:facetTypes) then (exists($paramsDoc/parameters/year[. != '']) or exists($paramsDoc/parameters/title[. != '']))
							else if (self::leg:facetYears) then not(exists($paramsDoc/parameters/number[. != '']))
							else true())">

							<li class="returnLink">
								<a href="{leg:GetLink(@remove)}">
									<span class="accessibleText">Browse by </span><xsl:value-of select="leg:TranslateText(concat('Any ',lower-case($facetType)))"/>
								</a>
							</li>
						</xsl:if>

						<!-- for years, show all the possible values only if none have been selected (have a @value attribute) -->
						<xsl:apply-templates select="
							if (self::leg:facetYears or self::leg:facetHundreds) then (
								if (empty(*[@value]) or count(*[@value]) > 1) then ()
								else *[@value]
							) else *">
							<xsl:with-param name="selected" select="$selected" />
						</xsl:apply-templates>
					</ul>
					</xsl:if>

					<!-- for years, show all the possible values only if none have been selected (have a @value attribute) -->
					<xsl:if test="(self::leg:facetYears or self::leg:facetHundreds) and not($selected) and (empty(*[@value]) or count(*[@value]) > 1)">
						<xsl:for-each select="1 to xs:integer($availableFacetsPages)">
							<xsl:variable name="currentIndex" select="."/>
							<ul class="page years">
								<xsl:apply-templates select="$availableFacets[position() &gt;= ( ($currentIndex - 1)* 24 + 1) and position() &lt;= ($currentIndex*24)]">
									<xsl:with-param name="selected" select="false()" />
								</xsl:apply-templates>
							</ul>
						</xsl:for-each>
					</xsl:if>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:facetType">
		<xsl:param name="selected" as="xs:boolean" required="yes" />
		<xsl:param name="maxYear" as="xs:string" required="yes" tunnel="yes" />
		<xsl:choose>
			<xsl:when test="$selected">
				<li class="legType">
					<span class="userFunctionalElement disabled">
						<xsl:value-of select="tso:GetTitleFromType(@type, $maxYear)" />
						<xsl:if test="exists(@value)"> (<xsl:value-of select="@value"/>)</xsl:if>
					</span>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li class="legType">
					<a href="{leg:GetLink(@href)}">
						<xsl:value-of select="tso:GetTitleFromType(@type, $maxYear)"/>
						<xsl:if test="exists(@value)"> (<xsl:value-of select="@value"/>)</xsl:if>
					</a>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:facetStage">
		<xsl:param name="selected" as="xs:boolean" required="yes" />
		<xsl:param name="maxYear" as="xs:string" required="yes" tunnel="yes" />
		<xsl:choose>
			<xsl:when test="$selected">
				<li class="legType">
					<span class="userFunctionalElement disabled">
						<xsl:value-of select="leg:TranslateText(tso:GetTitleFromType(@type, $maxYear))" />
						<xsl:if test="exists(@value)"> (<xsl:value-of select="@value"/>)</xsl:if>
					</span>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li class="legType">
					<a href="{leg:GetLink(@href)}">
						<xsl:variable name="title" select="tso:GetTitleFromType(@type, $maxYear)"/>
						<xsl:value-of select="leg:TranslateText($title)"/>
						<xsl:if test="exists(@value)"> (<xsl:value-of select="@value"/>)</xsl:if>
					</a>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:facetDepartment">
		<xsl:param name="selected" as="xs:boolean" required="yes" />
		<xsl:param name="maxYear" as="xs:string" required="yes" tunnel="yes" />
		<xsl:choose>
			<xsl:when test="$selected">
				<li class="legType">
					<span class="userFunctionalElement disabled">
						<xsl:value-of select="leg:TranslateText(tso:GetTitleFromType(@type, $maxYear))" />
						<xsl:if test="exists(@value)"> (<xsl:value-of select="@value"/>)</xsl:if>
					</span>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li class="legType">
					<a href="{leg:GetLink(@href)}">
						<xsl:variable name="title" select="tso:GetTitleFromType(@type, $maxYear)"/>
						<xsl:value-of select="leg:TranslateText($title)"/>
						<xsl:if test="exists(@value)"> (<xsl:value-of select="@value"/>)</xsl:if>
					</a>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:facetYear">
		<xsl:param name="selected" as="xs:boolean" required="yes" />
		<xsl:choose>
			<xsl:when test="$selected">
				<li class="legYear">
					<span class="userFunctionalElement disabled">
						<xsl:value-of select="@year"/>
						<xsl:if test="exists(@value)"> (<xsl:value-of select="@value"/>)</xsl:if>
					</span>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li class="legYear">
					<a href="{leg:GetLink(concat(@href, if ($paramsDoc/parameters/type = 'ukia' and $paramsDoc/parameters/start != '' and $paramsDoc/parameters/end != '') then concat(if (contains(@href,'?')) then '&amp;' else '?', 'start=', $paramsDoc/parameters/start, '&amp;end=', $paramsDoc/parameters/end) else if ($paramsDoc/parameters/type = 'ukia' and $paramsDoc/parameters/start != '') then concat(if (contains(@href,'?')) then '&amp;' else '?','start=', $paramsDoc/parameters/start) else if ($paramsDoc/parameters/type = 'ukia' and $paramsDoc/parameters/end != '') then concat(if (contains(@href,'?')) then '&amp;' else '?','end=', $paramsDoc/parameters/end) else''))}">
						<xsl:value-of select="@year"/>
						<xsl:if test="exists(@total)"> (<xsl:value-of select="@total"/>)</xsl:if>
					</a>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:facetHundred">
		<xsl:param name="selected" as="xs:boolean" required="yes" />
		<xsl:choose>
			<xsl:when test="$selected">
				<li class="legHundred">
					<span class="userFunctionalElement disabled">
						<xsl:value-of select="@hundred"/>-<xsl:value-of select="replace(@hundred, '00$', '99')" />
						<xsl:if test="exists(@value)"> (<xsl:value-of select="@value"/>)</xsl:if>
					</span>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li class="legHundred">
					<a href="{leg:GetLink(@href)}">
						<xsl:value-of select="@hundred"/>-<xsl:value-of select="replace(@hundred, '00$', '99')" />
						<xsl:if test="exists(@value)"> (<xsl:value-of select="@value"/>)</xsl:if>
					</a>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="atom:feed" mode="timeline">
		<xsl:variable name="facets" select="leg:facets" />

		<xsl:variable name="legTypes" as="element(tso:legType)*" select="$tso:legTypeMap[@abbrev = tokenize($paramsDoc/parameters/type,'[^a-z]')]" />
		<xsl:variable name="timeline" as="xs:string" select="if ($legTypes/@timeline = 'century') then 'century' else if ($legTypes/@timeline) then $legTypes/@timeline else 'decade'" />
		<xsl:variable name="complete" as="xs:integer?" select="min($legTypes/@complete)" />

		<xsl:if test="count($legTypes) = 1 and not($paramsDoc/parameters/type = ('eut', 'ukmd')) and ($timeline ne 'none' and $facets/leg:facetYears/leg:facetYear/@total)">
			<xsl:variable name="years" as="xs:integer+" select="$facets/leg:facetYears/leg:facetYear/xs:integer(@year)" />
			<xsl:variable name="minYear" as="xs:integer" select="min($years)"/>
			<xsl:variable name="maxYear" as="xs:integer" select="max($years)"/>
			<xsl:variable name="scale" as="xs:integer" select="if ($timeline = 'century') then 100 else 10" />
			<!-- changing the $scale to 100, $timeline to century if there are two many to fit in fishbar and browse timeline  -->
			<!--<xsl:variable name="scale" as="xs:integer" select="if ($scale = 10 and (($maxYear idiv $scale) - ($minYear idiv $scale)) &gt; 25) then 100 else $scale" />
			<xsl:variable name="timeline" as="xs:string" select="if ($scale = 100) then 'century' else $timeline"/>-->
			<xsl:variable name="minGroup" as="xs:integer" select="($minYear idiv $scale) * $scale" />
			<xsl:variable name="maxGroup" as="xs:integer" select="($maxYear idiv $scale) * $scale" />
			<!-- adjust the maxGroup to make sure there are at least three groups -->
			<xsl:variable name="maxGroup" as="xs:integer"
				select="if ($maxGroup - $minGroup &lt;= $scale) then $minGroup + ($scale) else $maxGroup" />
			<xsl:variable name="maxCount" as="xs:integer">
				<xsl:choose>
					<xsl:when test="$timeline = 'decade'">
						<xsl:sequence select="max($facets/leg:facetYears/leg:facetYear/xs:integer(@total))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="counts" as="xs:integer+">
							<xsl:for-each-group select="$facets/leg:facetYears/leg:facetYear" group-by="@year idiv 10">
								<xsl:sequence select="sum(current-group()/xs:integer(@total))" />
							</xsl:for-each-group>
						</xsl:variable>
						<xsl:sequence select="max($counts)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<div id="resultsTimeline" class="fisheye">
				<h2 class="accessibleText">Results by year</h2>
				<xsl:if test="not($isEUretained)">
					<h3 class="accessibleText">Key</h3>
					<dl class="key">
						<dt>
							<img src="/images/chrome/timelinePartialKey.gif" alt="Partial"/>
						</dt>
						<dd>
							<em>
								<xsl:value-of select="leg:TranslateText('Partial dataset')"/>
								<xsl:text> </xsl:text>
								<xsl:if test="empty($legTypes/@complete) or min($legTypes/@start) &lt; min($legTypes/@complete)">
									<xsl:value-of select="min($legTypes/@start)" /> - <xsl:value-of select="if (exists($legTypes/@complete)) then (min($legTypes/@complete)-1) else if (exists($legTypes/@end)) then max($legTypes/@end) else leg:TranslateText('Present')" />
								</xsl:if>
							</em>
							<!--
							<a href="#partialDataHelp" class="helpItemToMidRight">
								<img src="/images/chrome/helpIcon.gif" alt=" Explanation of partial data"/>
							</a>
							-->
						</dd>
						<dt>
							<img src="/images/chrome/timelineCompleteKey.gif" alt="Complete"/>
						</dt>
						<dd>
							<em>
								<xsl:value-of select="leg:TranslateText('Complete dataset')"/>
								<xsl:text> </xsl:text>
								<xsl:if test="exists($legTypes/@complete)">
									<xsl:value-of select="min($legTypes/@complete)" /> - <xsl:value-of select="if (exists($legTypes/@end)) then max($legTypes/@end) else leg:TranslateText('Present')" />
								</xsl:if>
							</em>
							<!--
							<a href="#presentDataHelp" class="helpItemToMidRight">
								<img src="/images/chrome/helpIcon.gif" alt=" Explanation of complete data"/>
							</a>
							-->
						</dd>
					</dl>
				</xsl:if>
				<h3 class="groupInfo">
					<xsl:variable name="result">
						<xsl:value-of select="if ($timeline = 'century') then '100' else '10'" />
						<xsl:text> </xsl:text>
						<xsl:value-of select="if($paramsDoc/parameters/lang[. = 'cy']) then 'o flynyddoedd' else leg:TranslateText('year')"/>
					</xsl:variable>
					<xsl:variable name="param" select="concat('result=',$result)"/>
					<xsl:variable name="translated" select="leg:TranslateText('results_grouped_by',$param)" />
					<xsl:value-of select="substring-before($translated,$result)"/>
					<strong><xsl:value-of select="$result"/></strong>
					<xsl:value-of select="substring-after($translated,$result)"/>
				</h3>

				<h3 class="accessibleText">Data is ordered by:</h3>
				<ul class="dataDescription">
					<li class="year"><xsl:value-of select="leg:TranslateText('Time')"/><span class="accessibleText"><xsl:text> </xsl:text><xsl:value-of select="leg:TranslateText('of results')"/></span></li>
					<li class="number"><xsl:value-of select="leg:TranslateText('Count')"/><span class="accessibleText"><xsl:text> </xsl:text><xsl:value-of select="leg:TranslateText('of results')"/></span></li>
				</ul>

				<p class="explanation">
					<xsl:choose>
						<xsl:when test="$isEUretained">
							<xsl:value-of select="leg:TranslateText('browse_explanation_eu')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="leg:TranslateText('browse_explanation_uk')"/>
						</xsl:otherwise>
					</xsl:choose>
				</p>

				<div id="timeline">
					<xsl:if test="$isEUretained">
						<xsl:attribute name="class">eu</xsl:attribute>
					</xsl:if>
					<div id="timelineData">
						<!-- have to get all the values between minYear and maxYear because there might be gaps otherwise -->
						<xsl:for-each select="($minGroup idiv $scale) to ($maxGroup idiv $scale)">
							<xsl:variable name="startGroup" as="xs:integer" select=". * $scale" />
							<xsl:variable name="endGroup" as="xs:integer" select="((. + 1) * $scale) - 1" />
							<xsl:variable name="facetGroup" as="element(leg:facetYear)*"
								select="$facets/leg:facetYears/leg:facetYear[@year >= $startGroup and @year &lt;= $endGroup]" />
							<div class="decade {if (position() mod 2 = 1) then 'odd' else 'even'}">
								<h3>
									<xsl:variable name="rangeGroup">
										<xsl:choose>
											<xsl:when test="position() = last() ">
												<xsl:choose>
													<xsl:when test="max($facetGroup/@year) = min($facetGroup/@year) and $startGroup = max($facetGroup/@year)">
														<xsl:value-of select="$startGroup" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="concat($startGroup, '-', max($facetGroup/@year))"/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat($startGroup, '-', $endGroup)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="exists($facetGroup)">
									<a href="{leg:GetLink(replace($facetGroup[1]/@href, concat('/', $facetGroup[1]/@year), concat('/', $startGroup, '-', $endGroup)))}"
												title="{$rangeGroup}"><xsl:value-of select="$rangeGroup" /></a>
										</xsl:when>
										<xsl:otherwise><xsl:value-of select="$rangeGroup" /></xsl:otherwise>
									</xsl:choose>
								</h3>
								<xsl:choose>
									<xsl:when test="exists($facetGroup)">
										<ul>
											<xsl:for-each select="($startGroup idiv ($scale idiv 10)) to ($endGroup idiv ($scale idiv 10))">
												<xsl:variable name="startYear" as="xs:integer" select=". * ($scale idiv 10)" />
												<xsl:variable name="endYear" as="xs:integer" select="((. + 1) * ($scale idiv 10)) - 1" />

												<!-- no need to set the endYear <= currentyear	 as ukdsi can contain next year facets as well
												<xsl:variable name="endYear" as="xs:integer" select="
													if ((((. + 1) * ($scale idiv 10)) - 1) &gt; year-from-date(current-date())) then year-from-date(current-date())
													else (((. + 1) * ($scale idiv 10)) - 1)" />
												<xsl:variable name="endYear" as="xs:integer"
													select="min(($endYear, year-from-date(current-date())))" />
												 -->
												<xsl:variable name="facetYears" as="element(leg:facetYear)*"
													select="$facetGroup[@year >= $startYear and @year &lt;= $endYear]" />
												<xsl:if test="exists($facetYears)">
													<xsl:variable name="count" as="xs:integer" select="sum($facetYears/xs:integer(@total))" />
													<xsl:variable name="perYear" as="xs:double" select="($count div $maxCount) * 100" />
													<xsl:variable name="perFormatted" as="xs:string" select="format-number($perYear, '00')" />
													<xsl:variable name="previousYears" as="xs:integer*" select="$facetGroup[@year &lt; $startYear]/@year" />
													<xsl:variable name="lastYear" as="xs:integer"
														select="if (exists($previousYears)) then max($previousYears) else ($startGroup - 1)" />
													<xsl:variable name="gap" as="xs:integer"
														select="(($startYear idiv ($scale idiv 10)) - ($lastYear idiv ($scale idiv 10))) - 1" />
													<xsl:variable name="classes" as="xs:string+">
														<xsl:sequence select="concat('per', $perFormatted)" />
														<xsl:sequence select="if (empty($legTypes/@complete) or $startYear &lt; min($legTypes/@complete)) then 'partial' else 'complete'" />
														<xsl:if test="position() = last()">
															<xsl:sequence select="'last'" />
														</xsl:if>
														<xsl:if test="$gap > 0">
															<xsl:sequence select="concat('noDataforPrev', $gap, 'yrs')" />
														</xsl:if>
														<xsl:if test="exists($facetYears/@value)">
															<xsl:sequence select="'currentYear'" />
														</xsl:if>
													</xsl:variable>
													<li class="{string-join($classes, ' ')}">
														<a href="{leg:GetLink(concat((if ($scale idiv 10 = 1) then $facetYears[1]/@href else replace($facetYears[1]/@href, concat('/', $facetYears[1]/@year), concat('/', $startYear, if ($startYear != $endYear) then concat('-', $endYear) else () ))),if (contains($facetYears[1]/@href,'ukia') and $paramsDoc/parameters/start != '' and $paramsDoc/parameters/end != '') then concat(if (contains($facetYears[1]/@href,'?')) then '&amp;' else '?','start=', $paramsDoc/parameters/start, '&amp;end=', $paramsDoc/parameters/end) else if (contains($facetYears[1]/$facetYears[1]/@href,'ukia') and $paramsDoc/parameters/start != '') then concat(if (contains($facetYears[1]/@href,'?')) then '&amp;' else '?','start=', $paramsDoc/parameters/start) else if (contains($facetYears[1]/@href,'ukia') and $paramsDoc/parameters/end != '') then concat(if (contains($facetYears[1]/@href,'?')) then '&amp;' else '?','end=', $paramsDoc/parameters/end) else ''))}"
															title="{$count} result{if ($count > 1) then 's' else ()} {$startYear}{if ($scale idiv 10 > 1 and $startYear != $endYear) then concat('-', $endYear) else ()}">
															<em>
																<span>
																	<xsl:value-of select="$count"/>
																</span>
															</em>
															<span class="accessibleText">
																<xsl:text> Result</xsl:text>
																<xsl:if test="$count > 1">s</xsl:if>
															</span>
															<strong>
																<xsl:choose>
																	<xsl:when test="$classes = 'complete' ">
																		<img src="/images/chrome/timelineCompleteKey.gif" alt=" (Complete)" />
																	</xsl:when>
																	<xsl:otherwise>
																		<img src="/images/chrome/timelinePartialKey.gif" alt=" (Partial)" />
																	</xsl:otherwise>
																</xsl:choose>
																<xsl:text> </xsl:text>
																<xsl:value-of select="$startYear" />
																<xsl:if test="$scale idiv 10 > 1 and $startYear != $endYear">
																	<xsl:text>s</xsl:text>
																</xsl:if>
															</strong>
														</a>
													</li>
												</xsl:if>
											</xsl:for-each>
										</ul>
									</xsl:when>
									<xsl:otherwise>
										<ul>
											<li class="per00 noDataforPrev9yrs"/>
										</ul>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:for-each>
					</div>
				</div>
				<h3 class="accessibleText"/>
				<table class="decades">
					<!-- if there are two many to fit in the fish bar then change the scale to 100 -->
					<xsl:variable name="scale" select="if ((($maxGroup idiv $scale) - ($minGroup idiv $scale)) &gt; 25) then 100 else $scale"/>
					<tr>
						<xsl:for-each select="($minGroup idiv $scale) to ($maxGroup idiv $scale)">
							<xsl:variable name="startGroup" as="xs:integer" select=". * $scale" />
							<td><xsl:value-of select="$startGroup" /></td>
						</xsl:for-each>
					</tr>
					<tr id="fisheye" />
				</table>
			</div>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
