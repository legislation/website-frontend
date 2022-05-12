<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Browse output  -->
<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 07/05/2010 by Faiz Muhammad -->
<!-- Change history

03-06-13 : Colin Mackenzie (previously chnaged by Yash)
Added in welsh language support for UI.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="2.0" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:db="http://docbook.org/ns/docbook" 
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" 
	xmlns:xforms="http://www.w3.org/2002/xforms" 
	xmlns:ev="http://www.w3.org/2001/xml-events">
	
	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="../../common/utils.xsl" />


	<!-- ========== Standard code for outputing UI wireframes========= -->
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>
	<xsl:variable name="publishedParam" select="if ($paramsDoc/parameters/published != '') then concat('/', $paramsDoc/parameters/published) else ''"/>							

	<xsl:template match="atom:feed">
			<html>
			<head>
				<xsl:variable name="lastModified" as="xs:dateTime" select="current-dateTime()" />
 				<meta name="DC.Date.Modified" content="{adjust-date-to-timezone(xs:date($lastModified), ())}" />
				<meta http-equiv="Last-Modified" content="{tso:httpDateTime($lastModified)}" />
				<link type="text/css" href="/styles/per/newLeg.css" rel="stylesheet" />		
			</head>		
			<body lang="{$TranslateLang}" xml:lang="{$TranslateLang}" dir="ltr" id="per"  class="newLeg"> 
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle"><xsl:value-of select="leg:TranslateText('New Legislation')"/></h1>
					</div>
					<div id="content">
						<!-- intro paras -->
						<div class="s_12 p_one introWrapper">
							<h2 class="s_12 p_one"><xsl:value-of select="leg:TranslateText('Official_place_of_publication')"/></h2>
							
							<!-- intro paras -->
							<div class="s_6 p_one">
								<p class=""><xsl:value-of select="leg:TranslateText('New_intro_1_1')"/></p>
								<p><xsl:value-of select="leg:TranslateText('New_intro_1_2')"/></p>
							</div>
							<div class="s_6 p_two">
								<p><xsl:value-of select="leg:TranslateText('New_intro_2_1')"/></p>
								<p><xsl:value-of select="leg:TranslateText('New_intro_2_2_1')"/><strong><xsl:value-of select="leg:TranslateText('New_intro_2_2_2')"/></strong><xsl:value-of select="leg:TranslateText('New_intro_2_2_3')"/></p>
							</div>
						</div>
						
						<!-- if requested date is available 
							a redirections has happened on the requested date
						-->
						<xsl:if test="$paramsDoc/parameters/requested castable as xs:date and xs:date($paramsDoc/parameters/requested) ne current-date()">
							<p class="warning failedSearch">
								<xsl:value-of select="leg:TranslateText('Nothing has been published to this website on your requested date')"/><xsl:text>. </xsl:text>
								<a href="{$TranslateLangPrefix}/new"><xsl:value-of select="leg:TranslateText('View the newest legislation published')"/></a>
							</p>						
						</xsl:if>
						<!-- last 10 days -->
						<div class="s_12 p_one tabWrapper">				
							<h2 class="accessibleText">Dyddiad cyhoeddi:  
								<xsl:if test="$paramsDoc/parameters/published castable as xs:date" >
									<xsl:value-of select="tso:format-date-abbrev(xs:date($paramsDoc/parameters/published))"/>
								</xsl:if>
							</h2>				
							<xsl:choose>
									<xsl:when test="
										$paramsDoc/parameters/published castable as xs:date and 
										not(exists(leg:facets/leg:facetPublishDates/leg:facetPublishDate[ xs:date(@date) = xs:date($paramsDoc/parameters/published)]))">
										<ul class="days">
											<xsl:variable name="publishDate" select="xs:date($paramsDoc/parameters/published)"/>
											<xsl:apply-templates select="leg:facets/leg:facetPublishDates/leg:facetPublishDate[1]"/>										

											<li class="current">
												<a href="{$TranslateLangPrefix}/new{format-date($publishDate, '/[Y0001]-[M01]-[D01]')}">
														<xsl:value-of select="tso:format-date-abbrev($publishDate)"/>
													</a>
											</li>
										</ul>
							
										<xsl:if test="exists(atom:entry)">
											<p class="warning"><xsl:value-of select="leg:TranslateText('Date older than 10 publication days ago')"/>. <a href="/new"><xsl:value-of select="leg:TranslateText('View the newest legislation published')"/></a>.</p>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<ul class="days">
											<xsl:apply-templates select="leg:facets/leg:facetPublishDates/leg:facetPublishDate[position() &lt;=10]"/>
										</ul>
									</xsl:otherwise>
								</xsl:choose>
							<div class="s_12 p_one">
								<xsl:if test="$paramsDoc/parameters/type = 'all' ">
									<xsl:attribute name="class" select="'s_12 p_one active'"/>
								</xsl:if>	
											
								<h3 id="allNew">
									<a href="{$TranslateLangPrefix}/new/all{$publishedParam}"><xsl:value-of select="leg:TranslateText('All New Legislation')"/></a>
								</h3>
								<div class="feedHelp">
									<a href="{$TranslateLangPrefix}/new/data.feed"><img src="/images/chrome/atomFeedIcon.gif" alt="Atom feed help" /></a>
									<a href="#feedHelp" class="helpItemToBot"><img src="/images/chrome/atomHelpIcon.gif" alt="Atom feed help" /></a>
								</div>
								
								<div class="newLegFeeds">	
															
									<ul class="countryNav">
										<li>
											<xsl:if test="$paramsDoc/parameters/type = 'uk' or $paramsDoc/parameters/type = 'all' ">
												<xsl:attribute name="class" select="'active'"/>
											</xsl:if>
											<a href="{$TranslateLangPrefix}/new/uk{$publishedParam}"><xsl:value-of select="leg:TranslateText('United Kingdom')"/></a>
										</li>
										<li>
											<xsl:if test="$paramsDoc/parameters/type = 'scotland' or $paramsDoc/parameters/type = 'all' ">
												<xsl:attribute name="class" select="'active'"/>
											</xsl:if>
											<a href="{$TranslateLangPrefix}/new/scotland{$publishedParam}"><xsl:value-of select="leg:TranslateText('Scotland')"/></a>
										</li>
										<li>
											<xsl:if test="$paramsDoc/parameters/type = 'wales' or $paramsDoc/parameters/type = 'all' ">
												<xsl:attribute name="class" select="'active'"/>
											</xsl:if>
											<a href="{$TranslateLangPrefix}/new/wales{$publishedParam}"><xsl:value-of select="leg:TranslateText('Wales')"/></a>
										</li>
										<li class="last">
											<xsl:if test="$paramsDoc/parameters/type = 'ni' or $paramsDoc/parameters/type = 'all' ">
												<xsl:attribute name="class" select="'active last'"/>
											</xsl:if>
											<a href="{$TranslateLangPrefix}/new/ni{$publishedParam}"><xsl:value-of select="leg:TranslateText('Northern Ireland')"/></a>
										</li>
									</ul>								
								
								
									<div class="p_one feeds">
										<h4 id="uk" class="accessibleText"><xsl:value-of select="leg:TranslateText('United Kingdom')"/></h4>
										
										<xsl:if test="$paramsDoc/parameters/type = '' ">
											<xsl:apply-templates select="leg:facets/leg:facetTypes" mode="feedSummaryFacets">
												<xsl:with-param name="countryType" select="'United Kingdom'"/>
											</xsl:apply-templates>												
										</xsl:if>
									</div>
									
									<div class="p_two feeds">
										<h4 id="scotland"  class="accessibleText"><xsl:value-of select="leg:TranslateText('Scotland')"/></h4>
										
										<xsl:if test="$paramsDoc/parameters/type = '' ">
											<xsl:apply-templates select="leg:facets/leg:facetTypes" mode="feedSummaryFacets">
												<xsl:with-param name="countryType" select="'Scotland'"  />
											</xsl:apply-templates>												
										</xsl:if>										
																				
									</div>
									
									<div class="p_two feeds">
										<h4 id="wales" class="accessibleText"><xsl:value-of select="leg:TranslateText('Wales')"/></h4>
										
										<xsl:if test="$paramsDoc/parameters/type = '' ">
											<xsl:apply-templates select="leg:facets/leg:facetTypes" mode="feedSummaryFacets">
												<xsl:with-param name="countryType" select="'Wales'"/>
											</xsl:apply-templates>												
										</xsl:if>										
									</div>									
									
									<div class="p_two feeds last">
										<h4 id="ni" class="accessibleText"><xsl:value-of select="leg:TranslateText('Northern Ireland')"/></h4>
										
										<xsl:if test="$paramsDoc/parameters/type = '' ">
											<xsl:apply-templates select="leg:facets/leg:facetTypes" mode="feedSummaryFacets">
												<xsl:with-param name="countryType" select="'Northern Ireland'" />
											</xsl:apply-templates>												
										</xsl:if>												
									</div>
									
									<!-- displaying the all the legislation content-->
									<xsl:if test="$paramsDoc/parameters/type != ''">
										<div class="p_content">
											<div class="p_one furtherInfo">
												<xsl:choose>
													<xsl:when test="not(exists(leg:facets/leg:facetTypes/leg:facetType))">
														<h5><xsl:value-of select="leg:TranslateText('Nothing published on this date')"/></h5>
													</xsl:when>
													<xsl:otherwise>
														<xsl:apply-templates select="leg:facets/leg:facetTypes" mode="feedTypeFacets"/>
													</xsl:otherwise>
												</xsl:choose>
											</div>
										</div>
									</xsl:if>
							</div>
							</div>
							
							<div class="s_6 p_one sub">
								<div class="content">
									<h3 class="feedTitle" id="subsFeeds"><xsl:value-of select="leg:TranslateText('Free_of_charge')"/></h3>
									<ul>
										<li><a href="{$TranslateLangPrefix}/new/data.feed"><xsl:value-of select="leg:TranslateText('All Legislation (excluding drafts)')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/ukpga/data.feed"><xsl:value-of select="leg:TranslateText('UK Public General Acts')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/uksi/data.feed"><xsl:value-of select="leg:TranslateText('UK Statutory Instruments')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/ukmd/data.feed"><xsl:value-of select="leg:TranslateText('UK Ministerial Directions')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/nia/data.feed"><xsl:value-of select="leg:TranslateText('Acts of the Northern Ireland Assembly')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/nisi/data.feed"><xsl:value-of select="leg:TranslateText('Northern Ireland Orders in Council')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/nisr/data.feed"><xsl:value-of select="leg:TranslateText('Northern Ireland Statutory Rules')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/asp/data.feed"><xsl:value-of select="leg:TranslateText('Acts of the Scottish Parliament')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/ssi/data.feed"><xsl:value-of select="leg:TranslateText('Scottish Statutory Instruments')"/></a></li>
										<!-- <li><a href="{$TranslateLangPrefix}/new/anaw/data.feed"><xsl:value-of select="leg:TranslateText('Acts of the National Assembly for Wales')"/></a></li>-->
										<li><a href="{$TranslateLangPrefix}/new/asc/data.feed"><xsl:value-of select="leg:TranslateText('Acts of Senedd Cymru')"/></a></li>
										<!--<li><a href="/new/mwa/data.feed">Measures of the National Assembly for Wales</a></li>-->
										<li><a href="{$TranslateLangPrefix}/new/wsi/data.feed"><xsl:value-of select="leg:TranslateText('Wales Statutory Instruments')"/></a></li>
									</ul>
									<h3 class="feedTitle p_one" id="subsFeeds"><xsl:value-of select="leg:TranslateText('Free of charge draft legislation feeds')"/></h3>
									<ul class="p_one">
										<li><a href="{$TranslateLangPrefix}/new/draft/data.feed"><xsl:value-of select="leg:TranslateText('All Draft Legislation')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/ukdsi/data.feed"><xsl:value-of select="leg:TranslateText('UK Draft Statutory Instrument')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/sdsi/data.feed"><xsl:value-of select="leg:TranslateText('Scottish Draft Statutory Instruments')"/></a></li>
										<li><a href="{$TranslateLangPrefix}/new/nidsr/data.feed"><xsl:value-of select="leg:TranslateText('Northern Ireland Draft Statutory Rules')"/></a></li>
									</ul>
								</div>
							</div>	
								
							<div class="s_6 p_two sub tracking">
								<div class="content">
									<h3 class="feedTitle" id="trackingLeg"><xsl:value-of select="leg:TranslateText('Tracking UK Legislation')"/></h3>
									<ul>
										<li><xsl:copy-of select="leg:TranslateNode('New_tracking_1')"/></li>
										<li><xsl:copy-of select="leg:TranslateNode('New_tracking_2')"/></li>
										<li><xsl:copy-of select="leg:TranslateNode('New_tracking_3')"/></li>
										<li><xsl:value-of select="leg:TranslateText('New_tracking_4_1')"/></li>
									</ul>
								</div>
							</div>									

						</div>
						<h2 class="interfaceOptionsHeader"><xsl:value-of select="leg:TranslateText('Options')"/>/<xsl:value-of select="leg:TranslateText('Help')"/></h2>
						<div class="help" id="feedHelp">
							<span class="icon"></span>
							<div class="content"><a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif"/></a>
								<p><xsl:value-of select="leg:TranslateText('Feed1')"/></p>
			
								<p><xsl:value-of select="leg:TranslateText('Feed2')"/></p>
								
								<p><xsl:value-of select="leg:TranslateText('Feed3')"/></p>					

								<p> 
									<xsl:value-of select="leg:TranslateText('Feed4')"/>
									<a>
										<xsl:attribute name="href">
											<xsl:value-of select="leg:TranslateText('FeedLink1')"/>
										</xsl:attribute>
										<xsl:attribute name="target">
											<xsl:text>_blank</xsl:text>
										</xsl:attribute>
										<xsl:value-of select="leg:TranslateText('Feed5')"/>
									</a>
									<a>
										<xsl:attribute name="href">
											<xsl:value-of select="leg:TranslateText('FeedLink2')"/>
										</xsl:attribute>
										<xsl:attribute name="target">
											<xsl:text>_blank</xsl:text>
										</xsl:attribute>
										<xsl:value-of select="leg:TranslateText('Feed6')"/>
									</a>
									<xsl:value-of select="leg:TranslateText('Feed7')"/>
									<a>
										<xsl:attribute name="href">
											<xsl:value-of select="leg:TranslateText('FeedLink3')"/>
										</xsl:attribute>
										<xsl:attribute name="target">
											<xsl:text>_blank</xsl:text>
										</xsl:attribute>
										<xsl:value-of select="leg:TranslateText('Feed8')"/>
									</a>								
								</p>
							</div>
						</div>			
					</div>					
					<p class="backToTop"><a href="#top"><xsl:value-of select="leg:TranslateText('Back to top')"/></a></p>
				</div>
				
			</body>
		</html>

	</xsl:template>


	<xsl:template match="leg:facetPublishDate">
				<xsl:variable name="publishDate" select="xs:date(@date)" />
				
				<xsl:variable name="isCurrent" select="
						($paramsDoc/parameters/published castable as xs:date 
							and xs:date($paramsDoc/parameters/published) = $publishDate )
								or 
							($paramsDoc/parameters/published = '' and position() = 1)" as="xs:boolean"/>
							
				<xsl:variable name="formattedDate" as="xs:string">
					<xsl:choose>
						<xsl:when test="$publishDate = current-date()">
							<xsl:value-of select="leg:TranslateText('Today')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="tso:format-date-abbrev($publishDate)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>							
				<li>
					<xsl:if test="$isCurrent"><xsl:attribute name="class">current</xsl:attribute></xsl:if>			
					<a href="{$TranslateLangPrefix}/new{if ($publishDate = current-date()) then '' else format-date($publishDate, '/[Y0001]-[M01]-[D01]')}"><xsl:value-of select="$formattedDate"/></a>
				</li>
	</xsl:template>

	<xsl:template match="leg:facetTypes" mode="feedSummaryFacets">
		<xsl:param name="countryType" as="xs:string" required="yes"/>
		
		<xsl:choose>
			<xsl:when test="exists(leg:facetType[tso:countryType(@type) = $countryType])">
			<table summary="{leg:TranslateText(concat($countryType, ' Legislation'))}">
			<thead>								
				<tr class="accessibleText">
					<th class="accessibleText"><xsl:value-of select="leg:TranslateText('Publication Amount')"/></th>
					<th class="accessibleText"><xsl:value-of select="leg:TranslateText('Publication Type')"/></th>
					<th class="accessibleText"><xsl:value-of select="leg:TranslateText('Publication Feed')"/></th>
				</tr>
			</thead>
					<tbody>
						<xsl:for-each select="leg:facetType">
							<xsl:variable name="type" select="@type" />
							<xsl:variable name="typeConfig" select="$tso:legTypeMap[@schemaType = $type and @class != 'draft']" />
							<xsl:if test="exists($typeConfig) and tso:countryType($type) = $countryType">
								<tr>
									<td class="publishedNum"><xsl:value-of select="@value" /></td>
									<td>
										<a href="{$TranslateLangPrefix}/new/{$typeConfig/@abbrev}{$publishedParam}">
											<!-- need to create a list of the singular and plural types of legisaltion in stage 2 of welsh wrapper work and make sure it
												is translated if needed. For now this will return the english unless the tyoe is alreeady translated -->
											<xsl:value-of select="leg:TranslateText(if (@value = 1) then $typeConfig//@singular else $typeConfig//@plural)"/>
										</a>
									</td>
									<td>
										<a href="{$TranslateLangPrefix}/new/{$typeConfig/@abbrev}/data.feed" class="feed">
											<img src="/images/chrome/icon_feed_small.png" alt="" />
										</a>
									</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<p class="noPublish"><xsl:value-of select="leg:TranslateText('Nothing published')"/></p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

		
	<xsl:template match="leg:facetTypes" mode="feedTypeFacets">
		<xsl:for-each-group select="leg:facetType" group-by="tso:countryType(@type)">
			<xsl:sort select="tso:countrySort(tso:countryType(current-group()[1]/@type))" />
			<xsl:if test="$paramsDoc/parameters/type = 'all' ">
				<h4 id="{tso:getType(@type)}" class="accessibleText">
					<xsl:value-of select="leg:TranslateText(tso:countryType(@type))"/>
				</h4>
			</xsl:if>
			<xsl:apply-templates select="current-group()" mode="feedTypeFacets"/>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="leg:facetType" mode="feedTypeFacets">
		<xsl:variable name="type" select="@type"/>
		<xsl:if test="exists(/atom:feed/atom:entry[ukm:DocumentMainType/@Value = $type])">
			<h5>
				<a href="{$TranslateLangPrefix}/new/{$tso:legTypeMap[@schemaType = $type]/@abbrev}{$publishedParam}">
					<xsl:value-of select="leg:TranslateText($tso:legTypeMap[@schemaType = $type]/@plural)" /></a>
				<a class="feed" href="{$TranslateLangPrefix}/new/{$tso:legTypeMap[@schemaType = $type]/@abbrev}/data.feed">
					<img alt="{$tso:legTypeMap[@schemaType = $type]/@plural} Feed" src="/images/chrome/icon_feed_small.png"/>
				</a>				
			</h5>
				<xsl:for-each select="/atom:feed/atom:entry[ukm:DocumentMainType/@Value = $type]">
				<h6>
					<xsl:variable name="title">
						<xsl:sequence select="tso:GetShortOPSIPrefix(ukm:DocumentMainType/@Value, ukm:Year/@Value, if (exists(ukm:Number)) then ukm:Number/@Value else '')"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="atom:title[@type = 'xhtml']">
							<xsl:variable name="ToCs" select="atom:link[@rel='http://purl.org/dc/terms/tableOfContents']" />
							<xsl:choose>
								<xsl:when test="exists($ToCs)">
									<a href="{$ToCs[not(@hreflang = 'cy')]/@href}">
										<xsl:value-of select="$title" />
										<xsl:text> - </xsl:text>
										<xsl:value-of select="atom:title/xhtml:div/xhtml:span[1]"/>
									</a>
									<xsl:text> / </xsl:text>
									<a href="{$ToCs[@hreflang = 'cy']/@href}">
										<xsl:value-of select="atom:title/xhtml:div/xhtml:span[2]"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a href="{atom:link[@rel = 'self']/@href}">
										<xsl:value-of select="concat($title, if (string-length(atom:title) ne 0) then concat(' - ' , atom:title) else '')"/>
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="title" select="concat($title, if (string-length(atom:title) ne 0) then concat(' - ' , atom:title) else '')"/>
							<xsl:choose>
								<xsl:when test="exists(atom:link[@rel='http://purl.org/dc/terms/tableOfContents'])">
									<a href="{atom:link[@rel='http://purl.org/dc/terms/tableOfContents']/@href}">
										<xsl:value-of select="$title"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a href="{atom:link[@rel = 'self']/@href}">
										<xsl:value-of select="$title"/>
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</h6>
				<p>
					<xsl:value-of select="if (string-length(atom:summary) &gt; 200) then concat(substring(atom:summary,1,200), '...') else atom:summary"/>
					</p>
				</xsl:for-each>
		</xsl:if>	
	
	</xsl:template>
	
	<xsl:function name="tso:getType" as="xs:string">
		<xsl:param name="type" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="$type = 'Northern Ireland' ">ni</xsl:when>
			<xsl:when test="$type = 'UK' ">uk</xsl:when>
			<xsl:when test="$type = 'Scotland' ">scotland</xsl:when>
			<xsl:when test="$type = 'Wales' ">wales</xsl:when>
			<xsl:otherwise>()</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="tso:countrySort" as="xs:integer">
		<xsl:param name="countryType" as="xs:string" />
		<xsl:choose>
			<xsl:when test="$countryType = 'United Kingdom'">1</xsl:when>
			<xsl:when test="$countryType = 'Scotland'">2</xsl:when>
			<xsl:when test="$countryType = 'Wales'">3</xsl:when>
			<xsl:when test="$countryType = 'Northern Ireland'">4</xsl:when>
			<xsl:otherwise>5</xsl:otherwise>
		</xsl:choose>
	</xsl:function>	
	
	<!-- awaiting final description of how WELSH months are handled but added this for now (Saxon does not support lang cy on format-date function) -->
	<xsl:variable name="welshMonthAbbreviations" select="('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Oct','Nov','Dec')" as="xs:string+"/>
	<xsl:function name="tso:format-date-abbrev">
		<xsl:param name="date" as="xs:date"/>
		
		<!-- the Welsh translator says we cannot put 'st' and 'th' after day number so we will leave them out for now for welsh -->
		<xsl:value-of select="format-date($date, if ($TranslateLang='cy') then '[D1]' else '[D1o]')"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="leg:TranslateText(concat(format-date($date,'[MNn]'),'_short'))"/>
		<!--
		<xsl:choose>
			<xsl:when test="$TranslateLang='cy'">
				<xsl:variable name="month" as="xs:double" select="number(format-date($date,'[M1]'))"/>
				<xsl:value-of select="format-date($date,'[D1o]')"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$welshMonthAbbreviations[$month]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="month" as="xs:string" select="format-date($date,'[MNn]')"/>
				<xsl:choose>
					<xsl:when test="string-length($month) &lt;=4">
						<xsl:value-of select="format-date($date,'[D1o] [MNn, 3-4]')"/>
					</xsl:when>
					<xsl:when test="$month = 'September' ">
						<xsl:value-of select="format-date($date,'[D1o] Sept')"/>			
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-date($date,'[D1o] [MNn, 3-3]')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose> -->
	</xsl:function>
		
</xsl:stylesheet>
