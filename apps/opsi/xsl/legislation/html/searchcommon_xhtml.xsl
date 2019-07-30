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
	
			<!-- 
				MS: we need to decide if this is a "search" or a "browse" to set the ID field... the difference is:
				search might specify a title or a non-specific type
				browse must specify a specific type (and no title)
			-->
	<xsl:variable name="id" as="xs:string"
		select="if ($paramsDoc/parameters/title[. != ''] or 
			not($paramsDoc/parameters/type) or
			$paramsDoc/parameters/type = ('', '*', 'all', 'primary', 'secondary', 'draft', 'uk', 'scotland', 'wales', 'ni') or
			$paramsDoc/parameters/version[. != ''] or
			$paramsDoc/parameters/number[. != ''] or
			$paramsDoc/parameters/subject[. != ''] or
			$paramsDoc/parameters/theme[. != ''] or
			$paramsDoc/parameters/extent[. != ''] or
			$paramsDoc/parameters/text[. != ''] or
			/atom:feed/openSearch:Query/@leg:lang = 'cy') then 'search' else 'browse'" />
					
	<xsl:variable name="type" as="xs:string?" select="$paramsDoc/parameters/type" />
	<xsl:variable name="year" as="xs:string?" select="$paramsDoc/parameters/year" />
	<xsl:variable name="subject" as="xs:string?" select="$paramsDoc/parameters/subject" />
	
	<xsl:variable name="defaultSort" as="xs:string"
		select="if ($paramsDoc/parameters/text[. != '']) then '' 
		else if (/atom:feed/openSearch:Query/@leg:subject or (empty(/atom:feed/atom:entry/ukm:Number) and $year != '')) then 'subject' 
		else 'year' " />
	<xsl:variable name="sort" as="xs:string?" 
		select="($paramsDoc/parameters/sort[. != ''], $defaultSort)[1]" />
	
	<xsl:template match="/">
		<html>
			<head>
				<xsl:call-template name="AddBrowseStylesScripts"/>
				<xsl:variable name="lastModified" as="xs:dateTime?">
					<xsl:choose>
						<xsl:when test="/atom:feed/atom:updated !='' or /atom:feed/atom:entry/atom:updated !=''">
							<xsl:value-of select="max((/atom:feed/atom:updated, /atom:feed/atom:entry/atom:updated)/xs:dateTime(.))"/>
						</xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
						
				</xsl:variable> 
				<xsl:variable name="lastModified" as="xs:dateTime" select="if (exists($lastModified)) then $lastModified else current-dateTime()" />
 				<meta name="DC.Date.Modified" content="{adjust-date-to-timezone(xs:date($lastModified), ())}" />
				<meta http-equiv="Last-Modified" content="{tso:httpDateTime($lastModified)}" />
				<xsl:apply-templates select="/atom:feed/atom:link" mode="HTMLmetadata" />
			</head>		
		
			<xsl:variable name="class" as="xs:string"
				select="if ($id = 'browse') then concat($paramsDoc/parameters/type, ' timeline') else 'results'" />
		
			<body id="{$id}" class="{$class}" lang="en" dir="ltr" xml:lang="en">
			
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
							<xsl:call-template name="heading"/>	<!-- h1: Search results -->
							<xsl:apply-templates select="atom:feed" mode="summary" /> <!-- h2: Search result summary -->
						</div>

						<xsl:if test="$id = 'browse'">
							<xsl:apply-templates select="atom:feed" mode="timeline"/>
						</xsl:if>

						<xsl:if test="exists(atom:feed/atom:entry)">

							<div class="interface">
                                <!-- header paging details-->
                                <xsl:apply-templates select="atom:feed" mode="links" />
							</div>
							
							<!-- facet details-->
							<xsl:apply-templates select="atom:feed" mode="searchfacets" />
                            
		<!-- search result details-->	
							<xsl:apply-templates select="atom:feed" mode="searchresults" />
							
							<!-- footer paging details-->
							<div class="contentFooter">
								<div class="interface">
								<xsl:apply-templates select="atom:feed" mode="links" />
							</div>
							</div>

							<p class="backToTop">
								<a href="#top"><xsl:value-of select="leg:TranslateText('Back to top')"/></a>
							</p>						
						
							<!--
							<div class="help" id="partialDataHelp">
								<span class="icon"/>
								<div class="content">
									<a href="#" class="close">
										<img alt="Close" src="/images/chrome/closeIcon.gif"/>
									</a>
									<h3>Partial map help</h3>
									<p>An explanatory Note is Lorem ipsum est docum eros dracos lorem.</p>
								</div>
							</div>
							<div class="help" id="presentDataHelp">
								<span class="icon"/>
								<div class="content">
									<a href="#" class="close">
										<img alt="Close" src="/images/chrome/closeIcon.gif"/>
									</a>
									<h3>Present map help</h3>
									<p>An explanatory Note is Lorem ipsum est docum eros dracos lorem.</p>
								</div>
							</div>
							-->
						</xsl:if>
							
					</div>
					<!--/#content-->
					
				</div>
				<!--/#layout1-->
			</body>
		</html>
	</xsl:template>
		

	<!-- ========== Standard code for links========= -->
	
	<xsl:template match="atom:feed" mode="links">
		<xsl:param name="maxPageSetSize" as="xs:integer" select="20"/>
		
		
		<xsl:variable name="thisPage" as="xs:integer" select="leg:page" />
		<xsl:variable name="pageSize" as="xs:integer" select="openSearch:itemsPerPage"/>
		<xsl:variable name="lastKnownPage" as="xs:integer" select="if (exists(openSearch:totalResults)) then xs:integer(ceiling((openSearch:totalResults div $pageSize)))  else xs:integer(leg:morePages )" />
		<xsl:variable name="firstPage" as="xs:integer" select="xs:integer(max(($thisPage - ($maxPageSetSize div 2) + 1 , 1)))" />
		<xsl:variable name="lastPage" as="xs:integer" select="min(($lastKnownPage, (if ($thisPage &lt;=5 and $maxPageSetSize = 10) then $maxPageSetSize else $thisPage + ($maxPageSetSize div 2) - 1)))" />
		
				
		<xsl:variable name="link" as="xs:string" select="leg:GetLink(atom:link[@rel = 'first']/@href)"/>
			<div class="prevPagesNextNav">
				<ul>
					<xsl:if test="$thisPage > 1 or leg:morePages > 0">
						<xsl:variable name="nextLink" as="element(atom:link)?" select="atom:link[@rel = 'next']" />
						<!-- displaying previous, if exists --> 
						<xsl:apply-templates select="atom:link[@rel = 'prev']" />
						<xsl:for-each select="$firstPage to $lastPage">
							<xsl:variable name="isLastPage" as="xs:boolean" select=". = $lastPage and empty($nextLink)" />
							<xsl:choose>
								<xsl:when test=". = $thisPage">
									<li class="currentPage {if ($isLastPage) then 'lastPageLink' else 'pageLink'}">
										<strong><span class="accessibleText">This is results page </span><xsl:value-of select="." /></strong>
									</li>								
								</xsl:when>
								<xsl:otherwise>
									<li class="{if ($isLastPage) then 'lastPageLink' else 'pageLink'}">
										<a href="{concat(if (contains($link, 'page=')) then replace($link, 'page=[0-9]+', concat('page=', .)) else concat($link, if (contains($link, '?')) then '&amp;page=' else '?page=', .),if  ($paramsDoc/parameters/type = 'ukia') then concat(if ($paramsDoc/parameters/start != '') then concat('&amp;start=', $paramsDoc/parameters/start) else '',if ($paramsDoc/parameters/end != '') then concat('&amp;end=', $paramsDoc/parameters/end) else '') else '')}">
											<xsl:choose>
												<xsl:when test=". = $thisPage - 1">
													<xsl:attribute name="rel">prev</xsl:attribute>
												</xsl:when>
												<xsl:when test=". = $thisPage + 1">
													<xsl:attribute name="rel">next</xsl:attribute>
												</xsl:when>
											</xsl:choose>
											<span class="accessibleText">Results page </span> <xsl:value-of select="." />
										</a>
									</li>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<!-- displaying next if exists -->
						<xsl:apply-templates select="$nextLink" />
					</xsl:if>
					
				</ul>
			</div>
	</xsl:template>
	
	<xsl:function name="leg:GetLink" as="xs:string">
		<xsl:param name="href"/>
		<xsl:sequence select="leg:GetLink($href, if ($paramsDoc/parameters/text [. != '']) then '' else 'year')" />
	</xsl:function>

	<xsl:function name="leg:SetParam" as="xs:string">
		<xsl:param name="href" />
		<xsl:param name="param" />
		<xsl:param name="value" />
		<xsl:choose>
			<xsl:when test="contains($href, concat($param, '='))">
				<xsl:sequence select="replace($href, concat($param, '=[^&amp;]+'), concat($param, '=', encode-for-uri($value)))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="concat($href, if (contains($href, '?')) then '&amp;' else '?', $param, '=', encode-for-uri($value))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="leg:GetLink" as="xs:string">
		<xsl:param name="href"/>
		<xsl:param name="defaultSort" />
		<xsl:variable name="href" as="xs:string"
			select="replace($href, 'http://legislation.data.gov.uk', '')" />
		<xsl:variable name="href" as="xs:string"
			select="replace($href, '/data.feed', '')" />
		<xsl:variable name="href" as="xs:string"
			select="if ($defaultSort = '') then $href else replace($href, concat('sort=', $defaultSort), '')" />
		<xsl:variable name="href" as="xs:string"
			select="replace($href, '&amp;level=search', '')" />
		<xsl:variable name="href" as="xs:string"
			select="replace($href, '\?level=search', '')" />
		<xsl:variable name="href" as="xs:string"
			select="replace($href, '[\?&amp;]$', '')" />
		<xsl:sequence select="$href"/>
	</xsl:function>	
	
	<xsl:template match="atom:link[@rel = ('prev', 'next')]">
		<li class="pageLink {@rel}">
			<a href="{leg:GetLink(concat(@href, if ($paramsDoc/parameters/type = 'ukia') then concat(if ($paramsDoc/parameters/start != '') then concat('&amp;start=', $paramsDoc/parameters/start) else '',if ($paramsDoc/parameters/end != '') then concat('&amp;end=', $paramsDoc/parameters/end) else '') else ''))}" title="{if (@rel ='prev') then 'previous' else @rel} page">
				<span class="btl"/>
				<span class="btr"/>
				<xsl:choose>
					<xsl:when test="@rel = 'prev'"><xsl:value-of select="leg:TranslateText('Previous')"/></xsl:when>
					<xsl:when test="@rel=  'next'"><xsl:value-of select="leg:TranslateText('Next')"/></xsl:when>
				</xsl:choose>
				<span class="accessibleText"> results page</span>
				<span class="bbl"/>
				<span class="bbr"/>
			</a>
		</li>	
	</xsl:template>	


	<!-- ========== Standard code for summary========= -->
	
	<xsl:template match="atom:feed" mode="summary">
		<xsl:variable name="params" select="$paramsDoc/parameters/(type | title | year | start-year | end-year | number | start-number | end-number | series | subject | theme | text | extent | version | view)[not(. = ('', '*'))]" />
		<xsl:variable name="legislationParams" select="$params[not(self::text or self::title)]" />
		<xsl:if test="exists($params)">
			<xsl:variable name="searchParams">
				<xsl:apply-templates select="$params[self::text]" mode="summary">
					<xsl:with-param name="feed" select="." />
				</xsl:apply-templates>
				<xsl:apply-templates select="$params[self::title]" mode="summary">
					<xsl:with-param name="feed" select="." />
				</xsl:apply-templates>
				<xsl:apply-templates select="$params[self::view]" mode="summary" />
				<xsl:choose>
					<xsl:when test="$params[self::type]">
						<xsl:apply-templates select="$params[self::type]" mode="summary">
							<xsl:with-param name="addAll" select="exists($legislationParams)" />
							<xsl:with-param name="addIn" select="exists($params[self::text or self::title])" />
							<xsl:with-param name="feed" select="." />
							<xsl:with-param name="themed" select="exists($params[self::theme])" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="$legislationParams">
						<span>
							<xsl:choose>
								<xsl:when test="$params[self::text or self::title]">in </xsl:when>
								<xsl:when test="openSearch:Query/@leg:lang = 'cy'"><strong>Welsh-language</strong><xsl:text> </xsl:text></xsl:when>
							</xsl:choose>
							<xsl:text>legislation</xsl:text>
						</span>
					</xsl:when>
				</xsl:choose>
				<xsl:apply-templates select="$params[self::theme]" mode="summary">
					<xsl:with-param name="feed" select="." />
				</xsl:apply-templates>
							
				<xsl:choose>
					<xsl:when test="$params[self::year]">
						<xsl:apply-templates select="$params[self::year]" mode="summary"/>
					</xsl:when>
					<xsl:when test="$params[self::start-year] and $params[self::end-year]">
						<span>
							<xsl:text>between </xsl:text>
							<strong><xsl:value-of select="$params[self::start-year]" /></strong>
							<xsl:text> and </xsl:text>
							<strong><xsl:value-of select="$params[self::end-year]" /></strong>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$params[self::start-year]" mode="summary"/>
						<xsl:apply-templates select="$params[self::end-year]" mode="summary"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$params[self::number]">
						<xsl:apply-templates select="$params[self::number]" mode="summary"/>
					</xsl:when>
					<xsl:when test="$params[self::start-number] and $params[self::end-number]">
						<span>
							<xsl:text>numbered between </xsl:text>
							<strong>
								<xsl:apply-templates select="$params[self::series]" mode="summary" />
								<xsl:value-of select="$params[self::start-number]" />
							</strong>
							<xsl:text> and </xsl:text>
							<strong>
								<xsl:apply-templates select="$params[self::series]" mode="summary" />
								<xsl:value-of select="$params[self::end-number]" />
							</strong>
						</span>
					</xsl:when>
					<xsl:when test="$params[self::start-number] or $params[self::end-number]">
						<xsl:apply-templates select="$params[self::start-number]" mode="summary"/>
						<xsl:apply-templates select="$params[self::end-number]" mode="summary"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$params[self::series]" mode="summary">
							<xsl:with-param name="noNumber" select="true()" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			<!--	<xsl:apply-templates select="$params[self::subject]" mode="summary" />-->
				
				<xsl:apply-templates select="$params[self::subject]" mode="summary"/>
					
				
				<xsl:apply-templates select="$params[self::extent]" mode="summary" />
				<xsl:apply-templates select="$params[self::version]" mode="summary" />
			</xsl:variable>
	
			<xsl:variable name="pageSize" as="xs:integer?" select="openSearch:itemsPerPage"/>
			<h2>
				<xsl:variable name="searchResultMessage">
				<xsl:choose>
					<xsl:when test="$params[self::theme]">
						<xsl:for-each select="$searchParams/*">
							<xsl:copy-of select="." />
							<xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
				<xsl:text>Your</xsl:text>
				<xsl:choose>
					<xsl:when test="$params[self::text]">
						<xsl:if test="not($params[self::title])"> text</xsl:if>
					</xsl:when>
					<xsl:when test="$params[self::title]"> title</xsl:when>
				</xsl:choose>
				<xsl:text> search</xsl:text>
				<xsl:if test="$searchParams/*">
					<xsl:text> for </xsl:text>
					<xsl:for-each select="$searchParams/*">
						<xsl:copy-of select="." />
						<xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if>
					</xsl:for-each>
				</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> has returned </xsl:text>
				<xsl:choose>
					<xsl:when test="openSearch:totalResults = '0'">no results.</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$paramsDoc/parameters/count-only='true'">
								<xsl:value-of select="openSearch:totalResults" />
							</xsl:when>
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
						<xsl:text> result</xsl:text>
						<xsl:if test="not(openSearch:totalResults = 1)">s</xsl:if>
						<xsl:text>.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>				
				</xsl:variable>				
				
				<!-- added this code to display messages in welsh languages for welsh version of site-->
				<xsl:variable name="fr" select="('Your text search for','Your search for','Your title search for', 'in legislation from', 'legislation from', 'numbered','has returned no results','in legislation','has returned','results','in Secondary Legislation','result')"/>
				<xsl:variable name="to" select="('Mae eich chwiliad testun am ','Mae eich chwiliad am','Nid yw eich chwiliad teitl am', 'mewn deddfwriaeth o ', 'deddfwriaeth o ', 'wedi ei rifo ','wedi dod o hyd i unrhyw ganlyniadau','mewn deddfwriaeth','wedi dod o hyd i ','o ganlyniadau','mewn Deddfwriaeth Eilaidd','ganlyniad')"/>
				
				<xsl:choose>
					<xsl:when test="$TranslateLang='cy'">
						<xsl:choose>
							<xsl:when test="$searchResultMessage='Your search for legislation has returned more than 200 results.'">Mae eich chwiliad am ddeddfwriaeth wedi dychwelyd mwy na 200 o ganlyniadau.</xsl:when>
							<xsl:when test="$searchResultMessage='Your search for Primary Legislation has returned   more than 200  results.'">Mae eich chwiliad am ddeddfwriaeth sylfaenol wedi dychwelyd mwy na 200 o ganlyniadau.</xsl:when>
							<xsl:when test="$searchResultMessage='Your search for Secondary Legislation has returned   more than 200  results.'">Mae eich chwiliad am is-ddeddfwriaeth wedi dychwelyd mwy na 200 o ganlyniadau.</xsl:when>
							<xsl:when test="$searchResultMessage='Your search for Draft Legislation has returned   more than 200  results.'">Mae eich chwiliad am Deddfwriaeth ddrafft wedi dychwelyd mwy na 200 o ganlyniadau.</xsl:when>
							<xsl:when test="$searchResultMessage='Your search for Asesiadau Effaith y Deyrnas Unedig has returned   more than 200  results.'">Mae eich chwiliad am Asesiadau Effaith DU wedi dychwelyd mwy na 200 o ganlyniadau.</xsl:when>
							<xsl:when test="$searchResultMessage='Your search for UK Statutory Instruments has returned   more than 200  results.'">Mae eich chwiliad am UK Offerynnau Statudol wedi dychwelyd mwy na 200 o ganlyniadau.</xsl:when>
							<xsl:when test="contains($searchResultMessage,'more than 200  results')"><xsl:value-of select="$searchResultMessage"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="leg:replace-multi($searchResultMessage,$fr,$to)"/></xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$searchResultMessage"/>
					</xsl:otherwise>
				</xsl:choose>				
			</h2>
	
	
			
			
			<xsl:variable name="messages" as="xs:string*">
				<xsl:if test="$sort = ''">
					<xsl:value-of select="leg:TranslateText('Search results are ordered according to relevance.')"/>
				</xsl:if>
			<xsl:if test="leg:text//leg:term[@ignored = 'true'] or leg:title//leg:term[@ignored = 'true']">
				<xsl:value-of select="leg:TranslateText('Common_word_text_message')"/>
				<!--<xsl:text>Common words were ignored for this search. Use double quotes around common words to include them.</xsl:text>-->
			</xsl:if>
			</xsl:variable>
			<xsl:if test="exists($messages)">
				<p><xsl:value-of select="$messages" separator="  " /></p>
		</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="type" mode="summary">
		<xsl:param name="addAll" required="yes" as="xs:boolean" />
		<xsl:param name="addIn" required="yes" as="xs:boolean" />
		<xsl:param name="feed" required="yes" as="element(atom:feed)" />
		<xsl:param name="themed" required="yes" as="xs:boolean" />
		<xsl:variable name="types" select="tokenize(., '( |\+)')" />
		<span>
			<xsl:choose>
				<xsl:when test="exists($types) and not($types = ('all', '*'))">
					<xsl:choose>
						<xsl:when test="$addIn">in </xsl:when>
						<xsl:when test="$feed/openSearch:Query/@leg:lang = 'cy'"><strong>Welsh-language</strong><xsl:text> </xsl:text></xsl:when>
					</xsl:choose>
					<xsl:for-each select="$types">
						<strong>
							<xsl:choose>
								<xsl:when test=". = 'primary'">Primary<xsl:if test="position() = last()"> Legislation</xsl:if></xsl:when>
								<xsl:when test=". = 'secondary'">Secondary<xsl:if test="position() = last()"> Legislation</xsl:if></xsl:when>
								<xsl:when test=". = 'draft'">Draft<xsl:if test="position() = last()"> Legislation</xsl:if></xsl:when>
								<xsl:otherwise>
									<xsl:variable name="type" select="."/>
									<xsl:value-of select="$tso:legTypeMap[@abbrev=$type]/@plural"/>
								</xsl:otherwise>
							</xsl:choose>
						</strong>
						<xsl:choose>
							<xsl:when test="position() = last() - 1"> and </xsl:when>
							<xsl:when test="position() != last()">, </xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$themed">
					<xsl:text>Legislation</xsl:text>
				</xsl:when>
				<xsl:when test="$addAll">
					<xsl:choose>
						<xsl:when test="$addIn">in </xsl:when>
						<xsl:when test="$feed/openSearch:Query/@leg:lang = 'cy'"><strong>Welsh-language</strong><xsl:text> </xsl:text></xsl:when>
					</xsl:choose>
					<xsl:text>legislation</xsl:text>
				</xsl:when>
			</xsl:choose>
		</span>
	</xsl:template>
	
	<xsl:template match="year" mode="summary">
		<xsl:if test="string-length(.) > 0">
			<span>from <strong><xsl:value-of select="."/></strong></span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="start-year" mode="summary">
		<xsl:if test="string-length(.) > 0">
			<span>since <strong><xsl:value-of select="."/></strong></span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="end-year" mode="summary">
		<xsl:if test="string-length(.) > 0">
			<span>until <strong><xsl:value-of select="."/></strong></span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="number" mode="summary">
		<xsl:if test="string-length(.) > 0">
			<span>
				<xsl:text>numbered </xsl:text>
				<xsl:apply-templates select="../series" mode="summary" />
				<strong><xsl:value-of select="."/></strong>
			</span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="start-number" mode="summary">
		<xsl:if test="string-length(.) > 0">
			<span>
				<xsl:text>numbered from </xsl:text>
				<xsl:apply-templates select="../series" mode="summary" />
				<strong><xsl:value-of select="."/></strong>
			</span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="end-number" mode="summary">
		<xsl:if test="string-length(.) > 0">
			<span>
				<xsl:text>numbered up to </xsl:text>
				<xsl:apply-templates select="../series" mode="summary" />
				<strong><xsl:value-of select="."/></strong>
			</span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="series" mode="summary">
		<xsl:param name="noNumber" select="false()" />
		<xsl:if test=". != ''">
			<xsl:choose>
				<xsl:when test="$noNumber">
					<span>
						<xsl:text>in the </xsl:text>
						<strong>
							<xsl:choose>
								<xsl:when test=". = 's'">Scottish</xsl:when>
								<xsl:when test=". = 'w'">Welsh</xsl:when>
								<xsl:when test=". = 'ni'">N.I.</xsl:when>
								<xsl:when test=". = 'c'">Commencement</xsl:when>
								<xsl:when test=". = 'l'">Legal</xsl:when>
							</xsl:choose>
						</strong>
						<xsl:text> series</xsl:text>
					</span>
				</xsl:when>
				<xsl:when test=". = 'ni'">N.I. </xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="upper-case(.)" />
					<xsl:text>. </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="theme" mode="summary">
		<xsl:param name="feed" required="yes" />
		<xsl:if test=". != ''">
			<span>
				<xsl:text>for the theme </xsl:text>
				<strong><xsl:value-of select="$feed/leg:theme" /></strong>
			</span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="view" mode="summary">
		<xsl:if test=". = 'impacts'">
			<span>
				<strong>Impact Assessments </strong>
				<text>for </text>
			</span>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template match="subject" mode="summary">
		<xsl:if test=". != ''">
			<span>
				<xsl:text>with a subject starting with </xsl:text>
				<strong><xsl:value-of select="upper-case(.)" /></strong>
			</span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="title" mode="summary">
		<xsl:param name="feed" required="yes" />
		<xsl:if test=". != ''">
			<span>
				<xsl:if test="$feed/leg:text">and title </xsl:if>
				<strong>
					<xsl:if test="$feed/openSearch:Query/@leg:lang = 'cy'">
						<xsl:attribute name="lang">cy</xsl:attribute>
						<xsl:attribute name="xml:lang">cy</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="$feed/leg:title" />
				</strong>
			</span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="text" mode="summary">
		<xsl:param name="feed" required="yes" />
		<xsl:if test=". != ''">
			<strong>
				<xsl:if test="$feed/openSearch:Query/@leg:lang = 'cy'">
					<xsl:attribute name="lang">cy</xsl:attribute>
					<xsl:attribute name="xml:lang">cy</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="$feed/leg:text" />
			</strong>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="leg:text/leg:and | leg:title/leg:and">
		<xsl:for-each select="*">
			<xsl:apply-templates select="." />
			<xsl:if test="position() != last()">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="leg:and | leg:or">
		<xsl:if test="not(parent::leg:text or parent::leg:title)">(</xsl:if>
		<xsl:for-each select="*">
			<xsl:apply-templates select="." />
			<xsl:if test="position() != last()">
				<xsl:text> </xsl:text>
				<xsl:value-of select="upper-case(local-name(..))" />
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="not(parent::leg:text or parent::leg:title)">)</xsl:if>
	</xsl:template>
	
	<xsl:template match="leg:not[leg:term]">
		<xsl:text>-</xsl:text>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="leg:not">
		<xsl:text>NOT </xsl:text>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="leg:term[@ignored = 'true']">
		<strike>
			<xsl:next-match />
		</strike>
	</xsl:template>
	
	<xsl:template match="leg:term">
		<xsl:variable name="phrase" as="xs:boolean" select="matches(., '\s')" />
		<xsl:if test="$phrase">"</xsl:if>
		<xsl:value-of select="." />
		<xsl:if test="$phrase">"</xsl:if>
	</xsl:template>
	
	<xsl:template match="extent" mode="summary" name="extentSummary">
		<xsl:param name="exact" select="starts-with(., '=')" />
		<xsl:param name="extents" select="tokenize(if ($exact) then substring(., 2) else ., '\+')" />
		<xsl:if test=". != ''">
			<xsl:choose>
				<xsl:when test="$exact">
					<span>
						<xsl:text>exclusively extending to </xsl:text>
						<xsl:sequence select="tso:extentDescription($extents, ' and ', true())" />
					</span>
				</xsl:when>
				<xsl:otherwise>
					<span>
						<xsl:text>applicable to </xsl:text>
						<xsl:sequence select="tso:extentDescription($extents, ' or ', true())" />
					</span>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="version" mode="summary">
		<xsl:if test=". castable as xs:date">
			<span>as it stood on </span>
			<strong>
				<xsl:choose>
					<xsl:when test=". castable as xs:date">
						<xsl:value-of select="format-date(xs:date(.), '[D01]/[M01]/[Y0001]')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="." />
					</xsl:otherwise>
				</xsl:choose>
			</strong>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="summary"/>

	<!-- ========== Standard code for displaying search result========= -->

	<xsl:template match="atom:feed" mode="searchresults">
		<div id="content" class="results">
			<!-- displaying the search results -->
			<table>
					<thead>
					<tr>
						<xsl:variable name="link" as="xs:string" select="//atom:link[@rel = 'first']/@href"/>
						<th>
							<xsl:variable name="allowlegislationTitleSorting" as="xs:boolean" select="empty($subject) or $subject = ''" />
							<xsl:element name="{if ($allowlegislationTitleSorting and not($sort = 'title')) then 'a' else 'span'}" >
								<xsl:if test="$allowlegislationTitleSorting">
									<xsl:choose>
										<xsl:when test="$sort = 'title'">
											<xsl:attribute name="class">sortAsc active</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href" select="leg:GetSortedLink($link, 'title', $defaultSort)"/>
											<xsl:attribute name="class">sortAsc</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="title">Sort ascending by Title</xsl:attribute>
									<span class="accessibleText">Sort ascending by </span>
								</xsl:if>							
								<xsl:value-of select="leg:TranslateText('Title')" />
							</xsl:element>
						</th>
						<th>
							<xsl:variable name="allowlegislationYearSorting" as="xs:boolean" select="empty($year) or $year = ''" />
							<xsl:variable name="title">
								<xsl:text>Year</xsl:text>
								<xsl:if test="exists(atom:entry/ukm:Number)">
									<xsl:text>s and Numbers</xsl:text>
								</xsl:if>
							</xsl:variable>
							<xsl:element name="{if ($allowlegislationYearSorting and not($sort = 'year')) then 'a' else 'span'}">
								<xsl:if test="$allowlegislationYearSorting">
									<xsl:choose>
										<xsl:when test="$sort = 'year'">
											<xsl:attribute name="class">sortDesc active</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href" select="leg:GetSortedLink($link, 'year', $defaultSort)"/>
											<xsl:attribute name="class">sortDesc</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="title">Sort descending by <xsl:value-of select="$title" /></xsl:attribute>
									<span class="accessibleText">Sort descending by </span>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText($title)" />
							</xsl:element>
						</th>
						<th>
							<!-- don't bother allowing sorting by type if you only have one type! -->
							<xsl:variable name="allowlegislationTypeSorting" as="xs:boolean" select="empty($type) or $type = ('*', 'all', 'primary', 'secondary', 'draft') or contains($type, '+')" />
							
							<xsl:variable name="type" as="xs:string?" select="/atom:feed/openSearch:Query/@leg:type"/>
							<xsl:variable name="legType" as="xs:string" select="if (matches($type,'(impacts|ukia|sia|wia|niia)')) then 'Impact Assessment Stage' else 'Legislation type'"/>
							
							<xsl:element name="{if ($allowlegislationTypeSorting and not($sort = 'type')) then 'a' else 'span'}">
								<xsl:choose>
									<xsl:when test="$allowlegislationTypeSorting">
										<xsl:choose>
											<xsl:when test="$sort = 'type' ">
												<xsl:attribute name="class">sortAsc active</xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="href" select="leg:GetSortedLink($link, 'type', $defaultSort)"/>
												<xsl:attribute name="class">sortAsc</xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="$sort = 'type'">
										<xsl:attribute name="class">sortAsc active</xsl:attribute>
									</xsl:when>
								</xsl:choose>
								<xsl:if test="$allowlegislationTypeSorting">
									<xsl:attribute name="title">Sort ascending by <xsl:value-of select="$legType"/></xsl:attribute>
									<span class="accessibleText">Sort ascending by </span>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Legislation type')"/>
							</xsl:element>
						</th>
					</tr>
					</thead>
					<tbody>
					<xsl:choose>
						<xsl:when test="exists(leg:facets/leg:facetSubjectsInitials/leg:facetSubjectInitial) and string-length($subject) = 1">
							<!-- if the search by heading is performed then we only need to display the results whose @category starts-with the required heading letter. -->
							<xsl:variable name="subject"  select="openSearch:Query/@leg:subject" />
							<xsl:for-each-group select="atom:entry" group-by="ukm:Subject/lower-case(@Value)">
								<xsl:sort select="current-grouping-key()" />
								<xsl:if test="$subject = '' or starts-with(lower-case(current-grouping-key()), $subject)   ">
									<tr class="heading">
										<td colspan="3">
											<h2>
												<xsl:variable name="ignoreWords" select="('about', 'after', 'all', 'also', 'an', 'and','another', 'any', 'are', 'as', 'at', 'be','because', 'been', 'before', 'being', 'between','both', 'but', 'by', 'came', 'can', 'come','could', 'did', 'do', 'does', 'each', 'else','for', 'from', 'get', 'got', 'has', 'had','he', 'have', 'her', 'here', 'him', 'himself','his', 'how','if', 'in', 'into', 'is', 'it','its', 'just', 'like', 'make', 'many', 'me','might', 'more', 'most', 'much', 'must', 'my','never', 'now', 'of', 'on', 'only', 'or','other', 'our', 'out', 'over', 're', 'said','same', 'see', 'should', 'since', 'so', 'some','still', 'such', 'take', 'than', 'that', 'the','their', 'them', 'then', 'there', 'these','they', 'this', 'those', 'through', 'to', 'too','under', 'up', 'use', 'very', 'want', 'was','way', 'we', 'well', 'were', 'what', 'when','where', 'which', 'while', 'who', 'will','with', 'would', 'you', 'your','a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i','j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r','s', 't', 'u', 'v', 'w', 'x', 'y', 'z')"/>
												<xsl:analyze-string select="current-grouping-key()" regex="(^|\s)([^\s]+)">
													<xsl:matching-substring>
														<xsl:variable name="word" select="regex-group(2)" />
														<xsl:value-of select="regex-group(1)" />
														<xsl:choose>
															<xsl:when test="position() != 1 and $word = $ignoreWords">
																<xsl:value-of select="$word" />
															</xsl:when>
															<xsl:otherwise>
																<xsl:value-of select="concat(upper-case(substring(regex-group(2),1,1)), substring(regex-group(2),2))"/>
															</xsl:otherwise>
														</xsl:choose>
													</xsl:matching-substring>
													<xsl:non-matching-substring>
														<xsl:value-of select="." />
													</xsl:non-matching-substring>
												</xsl:analyze-string>
											</h2>
										</td>
									</tr>
									<xsl:apply-templates select="current-group()" mode="searchresults" >
										<xsl:sort select="atom:title" />
									</xsl:apply-templates>
								</xsl:if>
							</xsl:for-each-group>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="atom:entry" mode="searchresults" />
								
						</xsl:otherwise>
					</xsl:choose>
				</tbody>
			</table>
		</div>
	</xsl:template>	
	
	

	<xsl:function name="leg:GetSortedLink">
		<xsl:param name="link" />
		<xsl:param name="sort" />
		<xsl:sequence select="leg:GetSortedLink($link, $sort, if ($paramsDoc/parameters/text [. != '']) then '' else 'year')" />
	</xsl:function>
	
	<xsl:function name="leg:GetSortedLink">
		<xsl:param name="link" />
		<xsl:param name="sort" />
		<xsl:param name="defaultSort" />
		<xsl:variable name="link">
			<xsl:choose>
				<xsl:when test="contains($link, 'sort=')">
					<xsl:sequence select="replace($link, 'sort=[-a-z]+', concat('sort=', $sort))" />
				</xsl:when>
				<xsl:when test="contains($link, '?')">
					<xsl:sequence select="concat($link, '&amp;sort=', $sort)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="concat($link, '?sort=', $sort)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence select="leg:GetLink($link, $defaultSort)" />
	</xsl:function>
	
	<xsl:template match="atom:entry" mode="searchresults">
		<xsl:param name="position" as="xs:integer" select="position()"/>
		<xsl:variable name="tocLink" as="xs:string"
			select="if (atom:link[@rel='http://purl.org/dc/terms/tableOfContents' and not(@hreflang)]) 
			then 
				substring-after(atom:link[@rel='http://purl.org/dc/terms/tableOfContents' and not(@hreflang)]/@href, 'http://www.legislation.gov.uk/') 
			else if (ukm:DocumentMainType/@Value='UnitedKingdomImpactAssessment' and atom:link[@rel='alternate'][not(@type='application/pdf')]) 
			then
				substring-after(atom:link[@rel='alternate'][not(@type='application/pdf')][last()]/@href, 'http://www.legislation.gov.uk/')
			else if (atom:link[@rel='self']/@href) then 
				substring-after(atom:link[@rel='self']/@href, 'http://www.legislation.gov.uk/')
			else if (ends-with(atom:link/@href,'made')) then
				replace(substring-after(atom:link/@href,'http://www.legislation.gov.uk/'), '/made', '/contents/made')
			else if (ends-with(atom:link/@href,'enacted')) then
				replace(substring-after(atom:link/@href,'http://www.legislation.gov.uk/'), '/enacted', '/contents/enacted')
			else
				substring-after(atom:link/@href,'http://www.legislation.gov.uk/')"/>
		<xsl:variable name="hasWelshTitle" as="xs:boolean" select="atom:title/@type = 'xhtml'" />
		<xsl:variable name="rowspan" as="attribute(rowspan)?">
			<xsl:if test="$hasWelshTitle">
				<xsl:attribute name="rowspan" select="2" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="tocLink" select="concat($tocLink, if ($paramsDoc/parameters/text[. != '' ] or $paramsDoc/parameters/extent[. != '' ]) then '#match-1' else '')"/>
		<xsl:variable name="class" as="attribute(class)?">
			<xsl:if test="$position mod 2 = 1">
				<xsl:attribute name="class">oddRow</xsl:attribute>
			</xsl:if>
		</xsl:variable>
		<tr>
			<xsl:sequence select="$class" />
			<td>
				<xsl:if test="$hasWelshTitle">
					<xsl:attribute name="class" select="'bilingual en'" />
				</xsl:if>
				<xsl:choose>
					<xsl:when test=".//xhtml:article">
						<xsl:sequence select=".//xhtml:article"/>
					</xsl:when>
					<xsl:otherwise>
						<a href="/{$tocLink}">
							<xsl:choose>
								<xsl:when test="$hasWelshTitle">
									<xsl:value-of select="atom:title/xhtml:div/xhtml:span[1]" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="atom:title"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:otherwise>
				</xsl:choose>
				
				
				
				
				<xsl:if test="ukm:SupersededBy">
					<xsl:variable name="superseding" select="ukm:SupersededBy[1]" />
					<br />
					<span class="superseded">
						<xsl:choose>
							<xsl:when test="$superseding/ukm:Number">
								<xsl:text>Superseded by </xsl:text>
							</xsl:when>
							<xsl:otherwise>Replaced by new draft </xsl:otherwise>
						</xsl:choose>
						<a href="{replace($superseding/@URI, '/id/', '/')}/contents{if ($superseding/ukm:Number) then '/made' else ''}">
							<xsl:apply-templates select="$superseding" mode="LegislationReference" />
						</a>
					</span>
				</xsl:if>
			</td>
			<td>
				<xsl:sequence select="$rowspan" />
				<a href="/{$tocLink}">
					<xsl:apply-templates select="." mode="LegislationYearNumber" />
				</a>
			</td>
			<td>
				<xsl:sequence select="$rowspan" />
				<xsl:value-of select="tso:GetTitleFromType(ukm:DocumentMainType/@Value, ukm:Year/@Value)"/>
			</td>
		</tr>
		<xsl:if test="$hasWelshTitle">
			<xsl:variable name="welshToCLink" as="xs:string?"
				select="atom:link[@rel='http://purl.org/dc/terms/tableOfContents' and @hreflang = 'cy']/@href" />
			<tr>
				<xsl:sequence select="$class" />
				<td class="bilingual cy">
					<a href="/{if (exists($welshToCLink)) then substring-after($welshToCLink, 'http://www.legislation.gov.uk/') else $tocLink}"
						lang="cy" xml:lang="cy">
						<xsl:value-of select="atom:title/xhtml:div/xhtml:span[2]" />
					</a>
				</td>
			</tr>
		</xsl:if>	
	</xsl:template>
	
	<xsl:template match="*" mode="LegislationReference">
		<xsl:choose>
			<xsl:when test="exists(ukm:Number)">
				<xsl:value-of select="ukm:Year/@Value"/>&#160;<xsl:value-of select="tso:GetNumberForLegislation(ukm:DocumentMainType/@Value, ukm:Year/@Value, ukm:Number/@Value)" />
			</xsl:when>
			<xsl:when test="exists(ukm:ISBN)">
				<xsl:text>ISBN </xsl:text>
				<xsl:value-of select="tso:formatISBN(ukm:ISBN/@Value)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="ukm:Year/@Value" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$paramsDoc/parameters/series[. != '' ] and ukm:AlternativeNumber[@Category=upper-case($paramsDoc/parameters/series)]">
			<xsl:apply-templates select="ukm:AlternativeNumber[@Category=upper-case($paramsDoc/parameters/series)]" mode="series"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="LegislationYearNumber">
		<xsl:value-of select="ukm:Year/@Value"/>
		<xsl:if test="exists(ukm:Number)">
			<xsl:text>&#160;</xsl:text>
			<xsl:value-of select="tso:GetNumberForLegislation(ukm:DocumentMainType/@Value, ukm:Year/@Value, ukm:Number/@Value)" />
		</xsl:if>
		<xsl:if test="ukm:AlternativeNumber">
			<xsl:apply-templates select="ukm:AlternativeNumber" mode="series"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="AddBrowseStylesScripts">
		<xsl:variable name="legTypes" as="element(tso:legType)*" select="$tso:legTypeMap[@abbrev = tokenize($paramsDoc/parameters/type,'[^a-z]')]" />
		<xsl:variable name="timeline" as="xs:string" select="if ($legTypes/@timeline = 'century') then 'century' else if ($legTypes/@timeline) then $legTypes/@timeline else 'decade'" />
		<xsl:variable name="years" as="xs:integer*" select="/atom:feed/leg:facets/leg:facetYears/leg:facetYear/xs:integer(@year)" />
		<xsl:variable name="minYear" as="xs:integer" select="min(($years, year-from-date(current-date())))"/>
		<xsl:variable name="maxYear" as="xs:integer" select="max(($years, 0))"/>
		<xsl:variable name="scale" as="xs:integer" select="if ($timeline = 'century') then 100 else 10" />
		<!-- changing the $scale to 100, $timeline to century if there are two many to fit in fishbar and browse timeline  -->
		<!--<xsl:variable name="scale" as="xs:integer" select="if ($scale = 10 and (($maxYear idiv $scale) - ($minYear idiv $scale)) &gt; 25) then 100 else $scale" />
		<xsl:variable name="timeline" as="xs:string" select="if ($scale = 100) then 'century' else $timeline"/>-->
		<xsl:variable name="minGroup" as="xs:integer" select="($minYear idiv $scale) * $scale" />
		<xsl:variable name="maxGroup" as="xs:integer" select="($maxYear idiv $scale) * $scale" />
		<!-- adjust the maxGroup to make sure there are at least three groups -->
		<xsl:variable name="maxGroup" as="xs:integer" 
			select="if ($maxGroup - $minGroup &lt;= $scale) then $minGroup + ($scale) else $maxGroup" />
			<script type="text/javascript" src="/scripts/view/minpagination.js"></script> 
		<link rel="stylesheet" href="/styles/view/timeline.css" type="text/css"/>
		<style type="text/css">
            <xsl:text>#timeline #timelineData {width:</xsl:text>
			<xsl:value-of select="xs:integer(((($maxGroup - $minGroup) idiv $scale) * 35) + 35)" />
			<xsl:text>em}</xsl:text>
		</style>
        
        <!-- Required for the headingFacet autocomplete -->
        <link rel="stylesheet" href="/styles/advancedsearch/jquery-ui.css" type="text/css"/>
        
		<script type="text/javascript" src="/scripts/jquery-ui-1.8.24.custom.min.js"/>
		<script type="text/javascript" src="/scripts/view/jquery.ui.slider.min.js"/>
		<script type="text/javascript" src="/scripts/view/scrollbar.js"/>
        <script type="text/javascript" src="/scripts/formFunctions/common.js"></script>
		<script type="text/javascript" src="/scripts/advancedsearch/search.js"></script>
        <script type="text/javascript" src="/scripts/search/jquery.ui.autocomplete.min.js"></script>
        <script type="text/javascript" src="/scripts/search/jquery.ui.comboboxFromLinks.js"></script>
        <script type="text/javascript" src="/scripts/search/headingFacet.js"></script>
	</xsl:template>
	
	<xsl:template name="heading">
		<xsl:variable name="params" as="element(parameters)" select="$paramsDoc/parameters" />
		<xsl:choose>
			<xsl:when test="not($params/*[. != ''] except ($params/(level, type, year, number, theme, england, scotland, wales, ni, uk, gb, ew, extent, extent-match, results, results-count, page, sort, more-pages))) and
				($params/type != '' or $params/year != '') and
				($params/number = '' or $params/year != '')">
				<h1 id="pageTitle">
					<xsl:choose>
						<xsl:when test="$params/type = ('all', '*')">Legislation</xsl:when>
						<xsl:when test="$params/type = 'primary'">Primary Legislation</xsl:when>
						<xsl:when test="$params/type = 'secondary'">Secondary Legislation</xsl:when>
						<xsl:when test="$params/type = 'draft'">Draft Legislation</xsl:when>
						<xsl:when test="$params/type != ''">
							<xsl:value-of select="$tso:legTypeMap[@abbrev=$params/type]/@plural"/>
						</xsl:when>
						<xsl:otherwise>Legislation</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="$params/theme != ''">
						<xsl:text> by theme </xsl:text>
					</xsl:if>
					<xsl:if test="$params/year != ''">
						<xsl:text> from </xsl:text>
						<xsl:value-of select="$params/year" />
						<xsl:if test="$params/number != ''">
							<xsl:text> numbered </xsl:text>
							<xsl:value-of select="$params/number" />
						</xsl:if>
					</xsl:if>
					<xsl:if test="$params/extent != ''">
						<xsl:choose>
							<xsl:when test="$params/extent-match = 'exact' or starts-with($params/extent, '=')"> exclusively extending to </xsl:when>
							<xsl:otherwise> applicable to </xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="tokenize(if (starts-with($params/extent, '=')) then substring($params/extent, 2) else $params/extent, '\+')">
							<xsl:choose>
								<xsl:when test=". = 'england'">England</xsl:when>
								<xsl:when test=". = 'scotland'">Scotland</xsl:when>
								<xsl:when test=". = 'wales'">Wales</xsl:when>
								<xsl:when test=". = 'ni'">Northern Ireland</xsl:when>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="position() = last() - 1"> and </xsl:when>
								<xsl:when test="position() != last()">, </xsl:when>
							</xsl:choose>
						</xsl:for-each>
					</xsl:if>
				</h1>
			</xsl:when>
			<xsl:when test="matches(atom:feed/atom:id, 'http://www.legislation.gov.uk/research/proximity/search')">
				<h1 id="pageTitle"><xsl:value-of select="leg:TranslateText('Proximity Search Results')"/></h1>
			</xsl:when>
			<xsl:otherwise>
				<h1 id="pageTitle"><xsl:value-of select="leg:TranslateText('Search Results')"/></h1>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ukm:AlternativeNumber[@Category = 'Regnal']" mode="series" />
	<xsl:template match="ukm:AlternativeNumber[@Category = 'Cy' and ../ukm:AlternativeNumber[@Category = 'W']]" mode="series" />
	
	<xsl:template match="ukm:AlternativeNumber" mode="series">
		<xsl:value-of select="concat(' (', if (@Category eq 'NI') then 'N.I' else if (@Category = 'Cy') then 'W' else @Category, '.&#xA0;', @Value, ')')"/>	
	</xsl:template>

	<!-- Metadata -->
	
	<xsl:template match="atom:link[@rel = ('self', 'alternate')]" mode="HTMLmetadata">
		<link rel="alternate"><xsl:apply-templates select="@type, @href, @title" mode="HTMLmetadata" /></link>
	</xsl:template>

	<xsl:template match="atom:link[@rel = ('up', 'prev', 'next', 'first', 'last')]" mode="HTMLmetadata">
		<link><xsl:apply-templates select="@rel, @type, @href, @title" mode="HTMLmetadata" /></link>
	</xsl:template>
	
	<xsl:template match="atom:link[@rel = ('up', 'prev', 'next', 'first', 'last')]/@type" mode="HTMLmetadata" />
	
	<xsl:template match="@rel | @title | @type" mode="HTMLmetadata">
		<xsl:sequence select="." />
	</xsl:template>
	
	<xsl:template match="@href" mode="HTMLmetadata">
		<xsl:attribute name="href">
			<xsl:choose>
				<xsl:when test="starts-with(., 'http://www.legislation.gov.uk')">
					<xsl:sequence select="substring-after(., 'http://www.legislation.gov.uk')" />
				</xsl:when>
				<xsl:when test="contains(., '/data.feed') and not(../@rel = ('self', 'alternate'))">
					<xsl:sequence select="replace(substring-after(., 'http://legislation.data.gov.uk'), '/data\.feed', '')" />
				</xsl:when>
				<xsl:when test="contains(., '/data.htm') and not(../@rel = ('self', 'alternate'))">
					<xsl:sequence select="replace(substring-after(., 'http://legislation.data.gov.uk'), '/data\.htm', '')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:function name="leg:replace-multi" as="xs:string?" >
		<xsl:param name="arg" as="xs:string?"/> 
		<xsl:param name="changeFrom" as="xs:string*"/> 
		<xsl:param name="changeTo" as="xs:string*"/> 
		
		<xsl:sequence select=" 
			if (count($changeFrom) > 0)
			then leg:replace-multi(
			replace($arg, $changeFrom[1],
			leg:if-absent($changeTo[1],'')),
			$changeFrom[position() > 1],
			$changeTo[position() > 1])
			else $arg
			"/>
		
	</xsl:function>
	
	<xsl:function name="leg:if-absent" as="item()*" >
		<xsl:param name="arg" as="item()*"/> 
		<xsl:param name="value" as="item()*"/> 
		
		<xsl:sequence select=" 
			if (exists($arg))
			then $arg
			else $value
			"/>
		
	</xsl:function>
	
</xsl:stylesheet>
