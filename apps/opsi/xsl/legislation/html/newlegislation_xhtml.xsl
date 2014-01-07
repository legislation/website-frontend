<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<!-- UI Legislation Browse output  -->
<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 07/05/2010 by Faiz Muhammad -->
<!-- Change history

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
			<body lang="en" xml:lang="en" dir="ltr" id="per"  class="newLeg"> 
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle">New Legislation</h1>
					</div>
					<div id="content">
						<!-- intro paras -->
						<div class="s_12 p_one introWrapper">
							<h2 class="s_12 p_one">Official place of publication for newly enacted legislation</h2>
							
							<!-- intro paras -->
							<div class="s_6 p_one">
								<p class="">Stay up to date with newly enacted legislation for the UK, Scotland, Wales and Northern Ireland as it is published to this site, by selecting a date below or using the free of charge subscription feeds.</p>
								<p>The aim is to publish legislation on this site simultaneously, or at least within 24 hours, of its publication in printed form.</p>
							</div>
							<div class="s_6 p_two">
								<p>Any document which is especially complex in terms of its size or its typography may take longer to prepare.</p>
								<p>New legislation is therefore <strong>listed by publication date</strong> rather than the date on which it was enacted.</p>								
								<!--<p class="">New legislation is therefore <strong>listed by publication date</strong> rather than the date on which it was enacted. Interested in legislation listed by enacted date? See our <a href="link to the enacted date search">Advanced Search</a></p>-->
							</div>
						</div>
						
						<!-- if requested date is available 
							a redirections has happened on the requested date
						-->
						<xsl:if test="$paramsDoc/parameters/requested castable as xs:date and xs:date($paramsDoc/parameters/requested) ne current-date()">
							<p class="warning failedSearch">
								<xsl:text>Nothing has been published to this website on your requested date. </xsl:text>
								<a href="/new">View the newest legislation published</a>
							</p>						
						</xsl:if>
						<!-- last 10 days -->
						<div class="s_12 p_one tabWrapper">				
							<h2 class="accessibleText">Publish date: 
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
													<a href="/new{format-date($publishDate, '/[Y0001]-[M01]-[D01]')}">
														<xsl:value-of select="tso:format-date-abbrev($publishDate)"/>
													</a>
											</li>
										</ul>
							
										<xsl:if test="exists(atom:entry)">
											<p class="warning">Date older than 10 publication days ago. <a href="/new">View the newest legislation published</a>.</p>
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
									<a href="/new/all{$publishedParam}">All New Legislation</a>
								</h3>
								<div class="feedHelp">
									<a href="/new/data.feed"><img src="/images/chrome/atomFeedIcon.gif" alt="Atom feed help" /></a>
									<a href="#feedHelp" class="helpItemToBot"><img src="/images/chrome/atomHelpIcon.gif" alt="Atom feed help" /></a>
								</div>
								
								<div class="newLegFeeds">	
															
									<ul class="countryNav">
										<li>
											<xsl:if test="$paramsDoc/parameters/type = 'uk' or $paramsDoc/parameters/type = 'all' ">
												<xsl:attribute name="class" select="'active'"/>
											</xsl:if>
											<a href="/new/uk{$publishedParam}">United Kingdom</a>
										</li>
										<li>
											<xsl:if test="$paramsDoc/parameters/type = 'scotland' or $paramsDoc/parameters/type = 'all' ">
												<xsl:attribute name="class" select="'active'"/>
											</xsl:if>
											<a href="/new/scotland{$publishedParam}">Scotland</a>
										</li>
										<li>
											<xsl:if test="$paramsDoc/parameters/type = 'wales' or $paramsDoc/parameters/type = 'all' ">
												<xsl:attribute name="class" select="'active'"/>
											</xsl:if>
											<a href="/new/wales{$publishedParam}">Wales</a>
										</li>
										<li class="last">
											<xsl:if test="$paramsDoc/parameters/type = 'ni' or $paramsDoc/parameters/type = 'all' ">
												<xsl:attribute name="class" select="'active last'"/>
											</xsl:if>
											<a href="/new/ni{$publishedParam}">Northern Ireland</a>
										</li>
									</ul>								
								
								
									<div class="p_one feeds">
										<h4 id="uk" class="accessibleText">United Kingdom</h4>
										
										<xsl:if test="$paramsDoc/parameters/type = '' ">
											<xsl:apply-templates select="leg:facets/leg:facetTypes" mode="feedSummaryFacets">
												<xsl:with-param name="countryType" select="'United Kingdom'"/>
											</xsl:apply-templates>												
										</xsl:if>
									</div>
									
									<div class="p_two feeds">
										<h4 id="scotland"  class="accessibleText">Scotland</h4>
										
										<xsl:if test="$paramsDoc/parameters/type = '' ">
											<xsl:apply-templates select="leg:facets/leg:facetTypes" mode="feedSummaryFacets">
												<xsl:with-param name="countryType" select="'Scotland'"  />
											</xsl:apply-templates>												
										</xsl:if>										
																				
									</div>
									
									<div class="p_two feeds">
										<h4 id="wales" class="accessibleText">Wales</h4>
										
										<xsl:if test="$paramsDoc/parameters/type = '' ">
											<xsl:apply-templates select="leg:facets/leg:facetTypes" mode="feedSummaryFacets">
												<xsl:with-param name="countryType" select="'Wales'"/>
											</xsl:apply-templates>												
										</xsl:if>										
									</div>									
									
									<div class="p_two feeds last">
										<h4 id="ni" class="accessibleText">Northern Ireland</h4>
										
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
														<h5>Nothing published on this date</h5>
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
									<h3 class="feedTitle" id="subsFeeds">Free of charge legislation feeds</h3>
									<ul>
										<li><a href="/new/data.feed">All Legislation (excluding drafts)</a></li>
										<li><a href="/new/ukpga/data.feed">UK Public General Acts</a></li>
										<li><a href="/new/uksi/data.feed">UK Statutory Instruments</a></li>
										<li><a href="/new/nia/data.feed">Acts of the Northern Ireland Assembly</a></li>
										<li><a href="/new/nisi/data.feed">Northern Ireland Orders in Council</a></li>
										<li><a href="/new/nisr/data.feed">Northern Ireland Statutory Rules</a></li>
										<li><a href="/new/asp/data.feed">Acts of the Scottish Parliament</a></li>
										<li><a href="/new/ssi/data.feed">Scottish Statutory Instruments</a></li>
										<li><a href="/new/anaw/data.feed">Acts of the National Assembly for Wales</a></li>
										<!--<li><a href="/new/mwa/data.feed">Measures of the National Assembly for Wales</a></li>-->
										<li><a href="/new/wsi/data.feed">Wales Statutory Instruments</a></li>
									</ul>
									<h3 class="feedTitle p_one" id="subsFeeds">Free of charge draft legislation feeds</h3>
									<ul class="p_one">
										<li><a href="/new/draft/data.feed">All Draft Legislation</a></li>
										<li><a href="/new/ukdsi/data.feed">UK Draft Statutory Instrument</a></li>
										<li><a href="/new/sdsi/data.feed">Scottish Draft Statutory Instruments</a></li>
										<li><a href="/new/nidsr/data.feed">Northern Ireland Draft Statutory Rules</a></li>
									</ul>
								</div>
							</div>	
								
							<div class="s_6 p_two sub tracking">
								<div class="content">
									<h3 class="feedTitle" id="trackingLeg">Tracking UK Legislation</h3>
									<ul>
										<li>All Bills currently before the UK Parliament are listed on the <a href="http://www.publications.parliament.uk/pa/pabills.htm">UK Parliament website</a> </li>
										<li>The <a href="http://services.parliament.uk/bills/">Parliamentary Business, Bills &#38; Legislation website</a> shows which stage a Bill has reached on its passage through Parliament.</li>
										<li>See <a href="http://bills.ais.co.uk/AC.asp">The Bill index database</a> for links to the full text of a Bill, the Hansard debate and any proposed amendments.</li>
										<li>Bills become Acts once they have passed all stages within both Houses of Parliament and receive Royal Assent. Once they have received Royal Assent, Acts are published under the authority of the Queen's Printer to this website.</li>
									</ul>
								</div>
							</div>									

						</div>
						<h2 class="interfaceOptionsHeader">Options/Help</h2>
						<div class="help" id="feedHelp">
							<span class="icon"></span>
							<div class="content"><a href="#" class="close"><img alt="Close" src="/images/chrome/closeIcon.gif"/></a>
								<p>Feeds enable you to see when websites have added new content. By using the legislation feeds you can get details of the latest legislation as soon as it is published without having to check the new legislation page each day. </p>
			
								<p>There are many types of feed (such as RSS and Atom). This site provides Atom feeds which can be used in most news readers. To use the feeds you will need a newsreader or a browser enabled device. </p>
								
								<p>To receive the feed to your newsreader either drag the orange feed button or cut and paste the link of the feed into your news reader.</p>					
							</div>
						</div>			
					</div>
					
				<p class="backToTop"><a href="#top">Back to top</a></p>

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
							<xsl:text>Today</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="tso:format-date-abbrev($publishDate)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>							
				<li>
					<xsl:if test="$isCurrent"><xsl:attribute name="class">current</xsl:attribute></xsl:if>			
							<a href="/new{if ($publishDate = current-date()) then '' else format-date($publishDate, '/[Y0001]-[M01]-[D01]')}"><xsl:value-of select="$formattedDate"/></a>
				</li>
	</xsl:template>

	<xsl:template match="leg:facetTypes" mode="feedSummaryFacets">
		<xsl:param name="countryType" as="xs:string" required="yes"/>
		
		<xsl:choose>
			<xsl:when test="exists(leg:facetType[tso:countryType(@type) = $countryType])">
		<table summary="{$countryType} Legislation">
			<thead>								
				<tr class="accessibleText">
					<th class="accessibleText">Publication Amount</th>
					<th class="accessibleText">Publication Type</th>
					<th class="accessibleText">Publication Feed</th>
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
										<a href="/new/{$typeConfig/@abbrev}{$publishedParam}">
											<xsl:choose>
												<xsl:when test="@value = 1">
													<xsl:value-of select="$typeConfig//@singular" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$typeConfig//@plural" />
												</xsl:otherwise>
											</xsl:choose>
										</a>
									</td>
									<td>
										<a href="/new/{$typeConfig/@abbrev}/data.feed" class="feed">
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
				<p class="noPublish">Nothing published</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

		
	<xsl:template match="leg:facetTypes" mode="feedTypeFacets">
		<xsl:for-each-group select="leg:facetType" group-by="tso:countryType(@type)">
			<xsl:sort select="tso:countrySort(tso:countryType(current-group()[1]/@type))" />
			<xsl:if test="$paramsDoc/parameters/type = 'all' ">
				<h4 id="{tso:getType(@type)}" class="accessibleText"><xsl:value-of select="tso:countryType(@type)"/></h4>
			</xsl:if>
			<xsl:apply-templates select="current-group()" mode="feedTypeFacets"/>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="leg:facetType" mode="feedTypeFacets">
		<xsl:variable name="type" select="@type"/>
		<xsl:if test="exists(/atom:feed/atom:entry[ukm:DocumentMainType/@Value = $type])">
			<h5>
					<a href="/new/{$tso:legTypeMap[@schemaType = $type]/@abbrev}{$publishedParam}">
						<xsl:value-of select="$tso:legTypeMap[@schemaType = $type]/@plural" /></a>
				<a class="feed" href="/new/{$tso:legTypeMap[@schemaType = $type]/@abbrev}/data.feed">
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
		
	<xsl:function name="tso:format-date-abbrev">
		<xsl:param name="date" as="xs:date"/>
		
		<!-- cannot use as it returns Augu, Sept, Nove
		<xsl:value-of select="format-date(xs:date($paramsDoc/parameters/published),'[D1o] [MNn, 3-4]')"/>
		-->
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
	</xsl:function>
		
</xsl:stylesheet>
