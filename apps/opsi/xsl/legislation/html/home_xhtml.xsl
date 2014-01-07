<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<!-- UI Legislation Table of Content/Content page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 17/02/2010 by Faiz Muhammad -->
<!-- Change history
	
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"  version="2.0" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:db="http://docbook.org/ns/docbook"	
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:ev="http://www.w3.org/2001/xml-events"
	>
	<xsl:import href="statuswarning.xsl"/>
	<xsl:import href="../../common/utils.xsl" />
	<!-- ========== Standard code for outputing UI wireframes========= -->
	
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>
	<xsl:variable name="g_nstMostRequested" select="if (doc-available('../../../www/mostrequested.xhtml') and $TranslateLang = 'cy') then doc('../../../www/mostrequested.cy.xhtml') else if (doc-available('../../../www/mostrequested.xhtml')) then doc('../../../www/mostrequested.xhtml') else ()" />
	
	<xsl:template match="/">		
		<html>
			<head>
				<xsl:variable name="lastModified" as="xs:dateTime" select="max((/atom:feed/atom:updated, /atom:feed/atom:entry/atom:updated)/xs:dateTime(.))" />
				<meta name="DC.Date.Modified" content="{adjust-date-to-timezone(xs:date($lastModified), ())}" />
				<meta http-equiv="Last-Modified" content="{tso:httpDateTime($lastModified)}" />
				
				<!-- adding description to the home page -->
				<xsl:variable name="description" select="leg:TranslateText('Home_description')"/>
				<meta name="DC.description" content="{$description}" />
				<meta name="description" content="{$description}" />						
			</head>
			<body xml:lang="{$TranslateLang}" lang="{$TranslateLang}" dir="ltr" id="per" class="home">
				<div id="layout2">
					
					<div id="intro" class="welcome">
						<!-- quick Search-->
						<xsl:call-template name="quickSearch"/>
						
						<div id="animContent">
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'welcomecy' else 'welcome'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText"><xsl:value-of select="leg:TranslateText('Welcome')"/></span>
								</h2>
								<!--<ul>
								<li>
									<a href="">Link to welcome option a</a>
								</li>
								<li>
									<a href="">Link to welcome option b</a>
								</li>
								<li>
									<a href="">Link to welcome option c</a>
								</li>
							</ul>-->
							</div>
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'ukcy' else 'uk'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText"><xsl:value-of select="leg:TranslateText('United Kingdom')"/></span>
								</h2>
								<ul>
									<li>
										<a href="{$TranslateLangPrefix}/browse/uk"><xsl:value-of select="leg:TranslateText('Browse UK Legislation')"/><span class="pageLinkIcon"></span></a>
									</li>
									<li>
										<a href="http://www.parliament.uk"><xsl:value-of select="leg:TranslateText('UK Parliament website')"/><span class="pageLinkIcon"></span></a>
									</li>								
								</ul>
							</div>
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'scotlandcy' else 'scotland'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText"><xsl:value-of select="leg:TranslateText('Scotland')"/></span>
								</h2>
								<ul>
									<li>
										<a href="{$TranslateLangPrefix}/browse/scotland"><xsl:value-of select="leg:TranslateText('Browse Scotland Legislation')"/><span class="pageLinkIcon"></span></a>
									</li>
									<li>
										<a href="http://www.scottish.parliament.uk"><xsl:value-of select="leg:TranslateText('Scottish Parliament website')"/><span class="pageLinkIcon"></span></a>
									</li>
								</ul>
							</div>
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'walescy' else 'wales'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText"><xsl:value-of select="leg:TranslateText('Wales')"/></span>
								</h2>
								<ul>
									<li>
										<a href="{$TranslateLangPrefix}/browse/wales"><xsl:value-of select="leg:TranslateText('Browse Wales Legislation')"/><span class="pageLinkIcon"></span></a>
									</li>
									<li>
										<a href="http://www.assemblywales.org"><xsl:value-of select="leg:TranslateText('National Assembly for Wales')"/><span class="pageLinkIcon"></span></a>
									</li>								
								</ul>
							</div>
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'nicy' else 'ni'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText"><xsl:value-of select="leg:TranslateText('Northern Ireland')"/></span>
								</h2>
								<ul>
									<li>
										<a href="{$TranslateLangPrefix}/browse/ni"><xsl:value-of select="leg:TranslateText('Browse Northern Ireland Legislation')"/><span class="pageLinkIcon"></span></a>
									</li>
									<li>
										<a href="http://www.niassembly.gov.uk"><xsl:value-of select="leg:TranslateText('Northern Ireland Assembly')"/><span class="pageLinkIcon"></span></a>
									</li>
								</ul>
							</div>
						</div>
						<ul id="countryLeg">
							<li>
								<a href="">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'welcomecy' else 'welcome'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Welcome')"/>
								</a>
							</li>
							<li>
								<a href="">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'ukcy' else 'uk'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('United Kingdom')"/>
								</a>
							</li>
							<li>
								<a href="">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'scotlandcy' else 'scotland'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Scotland')"/>
								</a>
							</li>
							<li>
								<a href="">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'walescy' else 'wales'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Wales')"/>
								</a>
							</li>
							<li>
								<a href="">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'nicy' else 'ni'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Northern Ireland')"/>
								</a>
							</li>
						</ul>
					</div>
					<!--/ #intro -->
					<div id="siteLinks">
						<div class="s_6 section p_one">
							<div class="title">
								<h2><xsl:value-of select="leg:TranslateText('New Legislation')"/></h2>
							</div>
							<div class="content">
								<ul class="linkList docLinks">
									<xsl:for-each select="//atom:entry">
										<xsl:if test="position()&lt;=5">
											<li>	
												<a href="{atom:link[@rel = 'self']/@href}">
													<xsl:attribute name="href">
														<xsl:choose>
															<xsl:when test="exists(atom:link[@rel='http://purl.org/dc/terms/tableOfContents'])">
																<xsl:sequence select="concat($TranslateLangPrefix,leg:FormatURL(atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][not(@hreflang='cy')][1]/@href))"/>
															</xsl:when>
															<xsl:otherwise>
																<xsl:sequence select="concat($TranslateLangPrefix,atom:link[@rel = 'self']/@href)"/>															
															</xsl:otherwise>
														</xsl:choose>													
													</xsl:attribute>
													<xsl:value-of select="atom:title"/><span class="pageLinkIcon"></span>
												</a>																				
											</li>
										</xsl:if>
									</xsl:for-each>
								</ul>
							</div>
						</div>					
						<div class="s_3 section p_two">
							<div class="title">
								<h2><xsl:value-of select="leg:TranslateText('Frequently Asked Questions')"/></h2>
							</div>
							<div class="content">
								<ul class="linkList">
									<li>
										<a href="{$TranslateLangPrefix}/help#aboutLeg"><xsl:value-of select="leg:TranslateText('whatlegislation')"/><span class="pageLinkIcon"></span></a>
									</li>
									<li>
										<a href="{$TranslateLangPrefix}/help#aboutNewLeg"><xsl:value-of select="leg:TranslateText('willIfind')"/><span class="pageLinkIcon"></span></a>
									</li>
									<li>
										<a href="{$TranslateLangPrefix}/help#aboutRevised"><xsl:value-of select="leg:TranslateText('availableRevised')"/><span class="pageLinkIcon"></span></a>
									</li>
									<li>
										<a href="{$TranslateLangPrefix}/help#aboutRevDate"><xsl:value-of select="leg:TranslateText('revisedContent_website')"/><span class="pageLinkIcon"></span></a>
									</li>																
								</ul>
								<p class="viewMoreLink">
									<a href="{$TranslateLangPrefix}/help#faqs"><xsl:value-of select="leg:TranslateText('View more')"/>
										<span class="pageLinkIcon"/>
									</a>
									
								</p>
							</div>
						</div>
						<div class="s_3 section p_two">
							<div class="title">
								<h2><xsl:value-of select="leg:TranslateText('Most requested Acts')"/></h2>
							</div>
							<xsl:if test="exists($g_nstMostRequested)">
								<xsl:copy-of select="$g_nstMostRequested/xhtml:html/xhtml:body/node()" />
							</xsl:if>
							<!--<p>Listings of repeals, amendments and other effects of legislation enacted from 2002 to the current year on the revised legislation held on this website.</p>-->
							<!--<p class="viewMoreLink"><a href="">View full list here</a></p>-->
						</div>
					</div>
				</div>
			</body>
		</html>		
	</xsl:template>
	
	<xsl:template name="quickSearch">
		<form id="contentSearch" method="get" action="{$TranslateLangPrefix}/search" class="contentSearch">
			<h2><xsl:value-of select="leg:TranslateText('Search All Legislation')"/></h2>
			<div class="title">
				<label for="title"><xsl:value-of select="leg:TranslateText('Title')"/>: <em><xsl:value-of select="leg:TranslateText('Key_title_text')"/></em>
				</label>
				<input type="text" id="title" name="title" />
			</div>
			<div class="year">
				<label for="year"><xsl:value-of select="leg:TranslateText('Year')"/>:</label>
				<input type="text" id="year" name="year" />
			</div>
			<div class="number">
				<label for="number"><xsl:value-of select="leg:TranslateText('Number')"/>:</label>
				<input type="text" id="number" name="number" />
			</div>
			<div class="type">
				<label for="type"><xsl:value-of select="leg:TranslateText('Type')"/>:</label>
				<xsl:call-template name="tso:TypeSelect" />
			</div>
			<div class="submit">
				<button type="submit" id="contentSearchSubmit" class="userFunctionalElement">
					<span class="btl"/>
					<span class="btr"/><xsl:value-of select="leg:TranslateText('Search')"/><span class="bbl"/>
					<span class="bbr"/>
				</button>
			</div>
			<div class="advSearch">
				<a href="{$TranslateLangPrefix}/search"><xsl:value-of select="leg:TranslateText('Advanced Search')"/></a>
			</div>			
		</form>
	</xsl:template>
</xsl:stylesheet>
