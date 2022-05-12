<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Table of Content/Content page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 17/02/2010 by Faiz Muhammad -->
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
				xmlns:ev="http://www.w3.org/2001/xml-events"
>
	<xsl:import href="statuswarning.xsl"/>
	<xsl:import href="../../common/utils.xsl"/>
	<xsl:import href="quicksearch.xsl"/>
	<!-- ========== Standard code for outputing UI wireframes========= -->

	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

	<xsl:variable name="g_nstMostRequested" select="if (doc-available('../../../www/mostrequested.xhtml') and $TranslateLang = 'cy') then doc('../../../www/mostrequested.cy.xhtml') else if (doc-available('../../../www/mostrequested.xhtml')) then doc('../../../www/mostrequested.xhtml') else ()"/>
	<xsl:template match="/">
		<html>
			<head>
				<xsl:variable name="lastModified" as="xs:dateTime" select="max((/atom:feed/atom:updated, /atom:feed/atom:entry/atom:updated)/xs:dateTime(.))"/>
				<meta name="DC.Date.Modified" content="{adjust-date-to-timezone(xs:date($lastModified), ())}"/>
				<meta http-equiv="Last-Modified" content="{tso:httpDateTime($lastModified)}"/>
				<!-- adding description to the home page -->
				<xsl:variable name="description" select="leg:TranslateText('Home_description')"/>
				<meta name="DC.description" content="{$description}"/>
				<meta name="description" content="{$description}"/>
			</head>
			<body xml:lang="{$TranslateLang}" dir="ltr" id="per" class="home">
				<div id="layout2">
					<!-- quick Search-->
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div id="intro" class="welcome">
						<div id="animContent">
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'welcomecy' else 'welcome'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText">
										<xsl:value-of select="leg:TranslateText('Welcome')"/>
									</span>
								</h2>
							</div>
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'ukcy' else 'uk'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText">
										<xsl:value-of select="leg:TranslateText('United Kingdom')"/>
									</span>
								</h2>
								<ul>
									<li>
										<a href="{$TranslateLangPrefix}/browse/uk">
											<xsl:value-of select="leg:TranslateText('Browse UK Legislation')"/>
											<span class="pageLinkIcon"></span>
										</a>
									</li>
									<li>
										<a href="http://www.parliament.uk">
											<xsl:value-of select="leg:TranslateText('UK Parliament website')"/>
											<span class="pageLinkIcon"></span>
										</a>
									</li>
								</ul>
							</div>
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'scotlandcy' else 'scotland'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText">
										<xsl:value-of select="leg:TranslateText('Scotland')"/>
									</span>
								</h2>
								<ul>
									<li>
										<a href="{$TranslateLangPrefix}/browse/scotland">
											<xsl:value-of select="leg:TranslateText('Browse Scotland Legislation')"/>
											<span class="pageLinkIcon"></span>
										</a>
									</li>
									<li>
										<a href="http://www.scottish.parliament.uk"  target="_blank">
											<xsl:value-of select="leg:TranslateText('Scottish Parliament website')"/>
											<span class="pageLinkIcon"></span>
										</a>
									</li>
								</ul>
							</div>
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'walescy' else 'wales'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText">
										<xsl:value-of select="leg:TranslateText('Wales')"/>
									</span>
								</h2>
								<ul>
									<li>
										<a href="{$TranslateLangPrefix}/browse/wales">
											<xsl:value-of select="leg:TranslateText('Browse Wales Legislation')"/>
											<span class="pageLinkIcon"></span>
										</a>
									</li>
									<li>
										<a href="{leg:TranslateText('http://www.senedd.wales')}" target="_blank">
											<xsl:value-of select="leg:TranslateText('Welsh Parliament')"/>
											<span class="pageLinkIcon"></span>
										</a>
									</li>
								</ul>
							</div>
							<div>
								<xsl:attribute name="class">
									<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'nicy' else 'ni'"/>
								</xsl:attribute>
								<h2>
									<span class="accessibleText">
										<xsl:value-of select="leg:TranslateText('Northern Ireland')"/>
									</span>
								</h2>
								<ul>
									<li>
										<a href="{$TranslateLangPrefix}/browse/ni">
											<xsl:value-of select="leg:TranslateText('Browse Northern Ireland Legislation')"/>
											<span class="pageLinkIcon"></span>
										</a>
									</li>
									<li>
										<a href="http://www.niassembly.gov.uk" target="_blank">
											<xsl:value-of select="leg:TranslateText('Northern Ireland Assembly')"/>
											<span class="pageLinkIcon"></span>
										</a>
									</li>
								</ul>
							</div>
							<xsl:if test="not($hideEUdata)">
								<div>
									<xsl:attribute name="class">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'eucy' else 'eu'"/>
									</xsl:attribute>
									<h2>
										<span class="accessibleText">
											<xsl:value-of select="leg:TranslateText('Legislation originating from the EU')"/>
										</span>
									</h2>
									<ul>
										<li>
											<a href="{$TranslateLangPrefix}/browse/eu">
												<xsl:value-of select="leg:TranslateText('Browse legislation originating from the EU')"/>
												<span class="pageLinkIcon"></span>
											</a>
										</li>
										<li>
											<a href="https://eur-lex.europa.eu/homepage.html?locale=en" target="_blank">
												<xsl:value-of select="leg:TranslateText('EUR-Lex website')"/>
												<span class="pageLinkIcon"></span>
											</a>
										</li>
									</ul>
								</div>
							</xsl:if>
						</div>
						<ul id="countryLeg">
							<li>
								<a href="javascript:void(0)">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'welcomecy' else 'welcome'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Welcome')"/>
								</a>
							</li>
							<li>
								<a href="javascript:void(0)">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'ukcy' else 'uk'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('United Kingdom')"/>
								</a>
							</li>
							<li>
								<a href="javascript:void(0)">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'scotlandcy' else 'scotland'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Scotland')"/>
								</a>
							</li>
							<li>
								<a href="javascript:void(0)">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'walescy' else 'wales'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Wales')"/>
								</a>
							</li>
							<li>
								<a href="javascript:void(0)">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'nicy' else 'ni'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Northern Ireland')"/>
								</a>
							</li>
							<xsl:if test="not($hideEUdata)">
							<li>
								<a href="javascript:void(0)">
									<xsl:attribute name="id">
										<xsl:value-of select="if ($TranslateLangPrefix='/cy') then 'eucy' else 'eu'"/>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Legislation originating from the EU')"/>
								</a>
							</li>
							</xsl:if>
						</ul>

						<div id="homeCTA">
							<div class="content">
								<img src="{concat('/images/chrome/',leg:TranslateText('site_logo_legislation'),'.gif')}" alt="legislation.gov.uk homepage call-to-action widget"/>
						<p>
                  <xsl:value-of select="leg:TranslateText('homeCTA_content')"/>
                </p>
				  <xsl:variable name="uri"
				  		select="concat(if ($TranslateLangPrefix='/cy') then '/cy' else (),'/understanding-legislation#Whatlegislationisheldonlegislationgovuk')"/>
				  <a href="{$uri}" class="btn">
                  <xsl:value-of select="leg:TranslateText('homeCTA_button')"/>
                </a>
							</div>
						</div>
					</div>
					<!--/ #intro -->
					<div id="siteLinks">
						<div class="box">
							<div class="box_main">
								<div class="title">
									<h2>
										<xsl:value-of select="leg:TranslateText('New_and_amended_title')"/>
									</h2>
								</div>
								<div class="content">
									<p><xsl:copy-of select="leg:TranslateNode('New_and_amended_para_1')"/></p>
									<p class="viewMoreLink">
										<a href="{concat($TranslateLangPrefix,'/','new')}">
											<xsl:value-of select="leg:TranslateText('New_and_amended_link')"/>
											<span class="pageLinkIcon"/>
										</a>
									</p>
								</div>
							</div>
							<div class="box_aside">
								<div class="title">
									<h2>
										<xsl:value-of select="leg:TranslateText('Legislation_published')"/>
									</h2>
								</div>
								<div class="content">
									<xsl:variable name="latestdate" as="xs:date" select="max(for $date in //atom:entry/atom:published return xs:date(substring-before($date, 'T')))"/>
									<xsl:variable name="isNotCurrentDate" as="xs:boolean" select="not($latestdate = current-date())"/>
									<xsl:if test="//atom:entry">
										<xsl:if test="$isNotCurrentDate">
											<p class="noresults"><xsl:value-of select="leg:TranslateText('Legislation_published_no_new')"/></p>
											<h3 class="lastpublishing" xml:lang="{$TranslateLang}">
												<xsl:variable name="date">
													<xsl:value-of select="leg:TranslateOrdinal(format-date($latestdate, ' [D1o] '))"/>
													<xsl:value-of select="leg:TranslateText(format-date($latestdate, '[MNn]'))"/>
													<xsl:value-of select="format-date($latestdate, ' [Y0001]')"/>
												</xsl:variable>
												<xsl:value-of select="leg:TranslateText('Legislation_published_on_date',concat('date=',$date))"/>

											</h3>
										</xsl:if>
										<ul class="linkList">
											<xsl:for-each-group select="//atom:entry[xs:date(substring-before(atom:published, 'T')) = $latestdate]" group-by="ukm:DocumentMainType/@Value">
												<xsl:sort select="$tso:legTypeMap[@schemaType = current-grouping-key()]/@plural"/>
												<xsl:variable name="schematype" select="$tso:legTypeMap[@schemaType = current-grouping-key()]"/>
												<xsl:variable name="count" select="count(current-group())"/>
												<xsl:variable name="linkText" select="if ($count gt 1) then $schematype/@plural else $schematype/@singular" />
												<li>
													<a href="new/{$schematype/@abbrev}{if ($isNotCurrentDate) then concat('/',$latestdate) else ()}">
														<xsl:value-of
															select="leg:TranslateText($linkText)"/>
														<xsl:text> (</xsl:text>
														<xsl:value-of select="$count"/>
														<xsl:text>)</xsl:text>
													</a>
												</li>
											</xsl:for-each-group>
										</ul>
									</xsl:if>
								</div>
							</div>
						</div>
						<div class="no_box">
							<div class="title">
								<h2>
									<xsl:value-of select="leg:TranslateText('Finding_your_way_title')"/>
								</h2>
							</div>
							<div class="content">
								<p>
									<xsl:copy-of select="leg:TranslateNode('Finding_your_way_para_1')"/>
								</p>
							</div>
						</div>
						<div class="box">
							<div class="box_main">
								<div class="title">
									<h2>
										<xsl:value-of select="leg:TranslateText('Understanding Legislation')"/>
									</h2>
								</div>
								<div class="content">
									<ul class="linkList col_2">
										<li>
											<a href="{$TranslateLangPrefix}/understanding-legislation#Howlegislationworks">
												<xsl:value-of select="leg:TranslateText('Howlegislationworks')"/>
											</a>
										</li>
										<li>
											<a href="{$TranslateLangPrefix}/understanding-legislation#parliamentsandlegislationtypes">
												<xsl:value-of select="leg:TranslateText('parliamentsandlegislationtypes')"/>
											</a>
										</li>
										<li>
											<a href="{$TranslateLangPrefix}/understanding-legislation#citationandnumbering">
												<xsl:value-of select="leg:TranslateText('citationandnumbering')"/>
											</a>
										</li>
										<li>
											<a href="{$TranslateLangPrefix}/understanding-legislation#howlegislationextends">
												<xsl:value-of select="leg:TranslateText('howlegislationextends')"/>
											</a>
										</li>
										<li>
											<a href="{$TranslateLangPrefix}/understanding-legislation#Howlegislationcomesintoforceandisamended">
												<xsl:value-of select="leg:TranslateText('Howlegislationcomesintoforceandisamended')"/>
											</a>
										</li>
										<li>
											<a href="{$TranslateLangPrefix}/understanding-legislation#editorialpractice">
												<xsl:value-of select="leg:TranslateText('editorialpractice')"/>
											</a>
										</li>
										<li>
											<a href="{$TranslateLangPrefix}/understanding-legislation#LegislationoriginatingfromtheEU">
												<xsl:value-of select="leg:TranslateText('LegislationoriginatingfromtheEU')"/>
											</a>
										</li>
									</ul>
								</div>
							</div>
							<div class="box_aside">
								<div class="title">
									<h2>
										<xsl:value-of select="leg:TranslateText('morehelp')"/>
									</h2>
								</div>
								<div class="content">
									<ul class="linkList">
										<li>
											<a href="{$TranslateLangPrefix}/help#faqs">
												<xsl:value-of select="leg:TranslateText('faqs')"/>
											</a>
										</li>
										<li>
											<a href="{$TranslateLangPrefix}/help#aboutNewLeg">
												<xsl:value-of select="leg:TranslateText('aboutNewLeg')"/>
											</a>
										</li>
										<li>
											<a href="{$TranslateLangPrefix}/help#editorialPracticeGuide">
												<xsl:value-of select="leg:TranslateText('editorialPracticeGuide')"/>
											</a>
										</li>
										<li>
											<a href="{$TranslateLangPrefix}/help#sip">
												<xsl:value-of select="leg:TranslateText('sip')"/>
											</a>
										</li>
									</ul>
								</div>
							</div>
						</div>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
