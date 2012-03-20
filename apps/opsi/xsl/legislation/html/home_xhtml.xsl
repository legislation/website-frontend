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
	<xsl:variable name="g_nstMostRequested" select="if (doc-available('../../../www/mostrequested.xhtml')) then doc('../../../www/mostrequested.xhtml') else ()" />

	
	<xsl:template match="/">
		<html>
			<head>
				<xsl:variable name="lastModified" as="xs:dateTime" select="max((/atom:feed/atom:updated, /atom:feed/atom:entry/atom:updated)/xs:dateTime(.))" />
				<meta name="DC.Date.Modified" content="{adjust-date-to-timezone(xs:date($lastModified), ())}" />
				<meta http-equiv="Last-Modified" content="{tso:httpDateTime($lastModified)}" />
				
				<!-- adding description to the home page -->
				<xsl:variable name="description">The official home of UK legislation, revised and as enacted 1267-present. This website is managed by The National Archives on behalf of HM Government. Publishing all UK legislation is a core part of the remit of Her Majesty’s Stationery Office (HMSO), part of The National Archives, and the Office of the Queen's Printer for Scotland.</xsl:variable>
				<meta name="DC.description" content="{$description}" />
				<meta name="description" content="{$description}" />						
			</head>
			<body xml:lang="en" lang="en" dir="ltr" id="per" class="home">
				<div id="layout2">
			
				<div id="intro" class="welcome">
					<!-- quick Search-->
					<xsl:call-template name="quickSearch"/>
					
					<div id="animContent">
						<div class="welcome">
							<h2>
								<span class="accessibleText">Welcome</span>
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
						<div class="uk">
							<h2>
								<span class="accessibleText">United Kingdom</span>
							</h2>
							<ul>
								<li>
									<a href="/browse/uk">Browse UK Legislation<span class="pageLinkIcon"></span></a>
								</li>
								<li>
									<a href="http://www.parliament.uk">UK Parliament website<span class="pageLinkIcon"></span></a>
								</li>								
							</ul>
						</div>
						<div class="scotland">
							<h2>
								<span class="accessibleText">Scotland</span>
							</h2>
							<ul>
								<li>
									<a href="/browse/scotland">Browse Scotland Legislation<span class="pageLinkIcon"></span></a>
								</li>
								<li>
									<a href="http://www.scottish.parliament.uk">Scottish Parliament website<span class="pageLinkIcon"></span></a>
								</li>
							</ul>
						</div>
						<div class="wales">
							<h2>
								<span class="accessibleText">Wales</span>
							</h2>
							<ul>
								<li>
									<a href="/browse/wales">Browse Wales Legislation<span class="pageLinkIcon"></span></a>
								</li>
								<li>
									<a href="http://www.assemblywales.org">National Assembly for Wales<span class="pageLinkIcon"></span></a>
								</li>								
							</ul>
						</div>
						<div class="ni">
							<h2>
								<span class="accessibleText">Northern Ireland</span>
							</h2>
							<ul>
								<li>
									<a href="/browse/ni">Browse Northern Ireland Legislation<span class="pageLinkIcon"></span></a>
								</li>
								<li>
									<a href="http://www.niassembly.gov.uk">Northern Ireland Assembly<span class="pageLinkIcon"></span></a>
								</li>
							</ul>
						</div>
					</div>
					<ul id="countryLeg">
						<li>
							<a href="" id="welcome">Welcome</a>
						</li>
						<li>
							<a href="" id="uk">United Kingdom</a>
						</li>
						<li>
							<a href="" id="scotland">Scotland</a>
						</li>
						<li>
							<a href="" id="wales">Wales</a>
						</li>
						<li>
							<a href="" id="ni">Northern Ireland</a>
						</li>
					</ul>
				</div>
				<!--/ #intro -->
				<div id="siteLinks">
						<div class="s_6 section p_one">
							<div class="title">
								<h2>New Legislation</h2>
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
																<xsl:sequence select="leg:FormatURL(atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][not(@hreflang='cy')][1]/@href)"/>
															</xsl:when>
															<xsl:otherwise>
																<xsl:sequence select="atom:link[@rel = 'self']/@href"/>															
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
							<h2>Frequently Asked Questions</h2>
						</div>
						<div class="content">
							<ul class="linkList">

								<li>
									<a href="/help#aboutOpsiSld">What has happened to the OPSI and Statute Law Database (SLD) websites?<span class="pageLinkIcon"></span></a>
								</li>
								<li>
									<a href="/help#aboutLeg">What legislation is held on legislation.gov.uk?<span class="pageLinkIcon"></span></a>
								</li>
								<li>
									<a href="/help#aboutNewLeg">Will I find new legislation on legislation.gov.uk?<span class="pageLinkIcon"></span></a>
								</li>
								<li>
									<a href="/help#aboutRevised">What legislation is available as revised?<span class="pageLinkIcon"></span></a>
								</li>
								<li>
									<a href="/help#aboutRevDate">How up to date is the revised content on this website?<span class="pageLinkIcon"></span></a>
								</li>																
							</ul>
							<p class="viewMoreLink">
								<a href="/help#faqs">View more
									<span class="pageLinkIcon"/>
								</a>
								
							</p>
						</div>
					</div>
					<div class="s_3 section p_two">
						<div class="title">
							<h2>Most requested Acts</h2>
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
		<form id="contentSearch" method="get" action="search" class="contentSearch">
			<h2>Search All Legislation</h2>
			<div class="title">
				<label for="title">Title: <em>(or keywords in the title)</em>
				</label>
				<input type="text" id="title" name="title" />
			</div>
			<div class="year">
				<label for="year">Year:</label>
				<input type="text" id="year" name="year" />
			</div>
			<div class="number">
				<label for="number">Number:</label>
				<input type="text" id="number" name="number" />
			</div>
			<div class="type">
				<label for="type">Type:</label>
				<xsl:call-template name="tso:TypeSelect" />
			</div>
			<div class="submit">
				<button type="submit" id="contentSearchSubmit" class="userFunctionalElement">
					<span class="btl"/>
					<span class="btr"/>Search<span class="bbl"/>
					<span class="bbr"/>
				</button>
			</div>
			<div class="advSearch">
				<a href="/search">Advanced Search</a>
			</div>			
		</form>
	</xsl:template>
</xsl:stylesheet>
