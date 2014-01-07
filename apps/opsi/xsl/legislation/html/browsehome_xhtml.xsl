<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

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

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$paramsDoc/parameters/page ='uk'">
				<xsl:call-template name="TSOBrowseUK"/>
			</xsl:when>
			<xsl:when test="$paramsDoc/parameters/page ='wales'">
				<xsl:call-template name="TSOBrowseWales"/>
			</xsl:when>
			<xsl:when test="$paramsDoc/parameters/page ='scotland'">
				<xsl:call-template name="TSOBrowseScotland"/>
			</xsl:when>
			<xsl:when test="$paramsDoc/parameters/page ='ni'">
				<xsl:call-template name="TSOBrowseNI"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="TSOBrowseHome"/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	
	<!-- Home -->
	<xsl:template name="TSOBrowseHome">
		<html>
			<head>
				<link type="text/css" href="/styles/legBrowse.css" rel="stylesheet" />
				<xsl:comment><![CDATA[[if lte IE 6]><link rel="stylesheet" href="/styles/IE/ie6browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<xsl:comment><![CDATA[[if IE 7]><link rel="stylesheet" href="/styles/IE/ie7browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<!-- TSOBrowseHome has this extra map script -->
				<script type="text/javascript" src="/scripts/browse/map.js"></script>  
			</head>
			<!-- TSOBrowseHome has a different body@class -->
			<body lang="{$TranslateLang}" xml:lang="{$TranslateLang}" dir="ltr" id="browse" class="intro"> 
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle"><xsl:value-of select="leg:TranslateText('Browse')"/></h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">
							<div class="s_8 p_one">
								<p><xsl:value-of select="leg:TranslateText('Browse_Intro_p')"/></p>
							</div>							
							<div class="s_4 p_absTopRight">
								<p><strong><xsl:value-of select="leg:TranslateText('Browse_Hover')"/></strong><xsl:value-of select="leg:TranslateText('Browse_Hover2')"/></p>
								<div class="helpIcon">
									<a href="#browseMapHelp" class="helpItemToMidLeft"><img src="/images/chrome/helpIcon.gif" alt="Map help" /></a>
								</div>
								<div id="map">					
									<img id="blank" src="/images/maps/blank.png" usemap="#imgmap" alt="" /> 
									<img class="mapImage" id="uk" src="/images/maps/uk.png" usemap="#imgmap" alt="" /> 
									<img class="mapImage" id="england" src="/images/maps/england.png" usemap="#imgmap" alt="" /> 
									<img class="mapImage" id="scotland" src="/images/maps/scotland.png" usemap="#imgmap" alt="" /> 
									<img class="mapImage" id="wales" src="/images/maps/wales.png" usemap="#imgmap" alt="" /> 
									<img class="mapImage" id="northernireland" src="/images/maps/northernireland.png" usemap="#imgmap" alt="" />
									<map name="imgmap" id="imgmap">
										<area title="{upper-case(leg:TranslateText('Northern Ireland'))}" id="niarea" shape="poly" coords="87,133,79,142,79,171,102,171,103,177,124,178,112,133" href="{$TranslateLangPrefix}/browse/ni"/>
										<area title="{upper-case(leg:TranslateText('Scotland'))}" id="scotlandarea" shape="poly" coords="127,155,114,133,80,107,80,1,210,0,210,140,193,155" href="{$TranslateLangPrefix}/browse/scotland"/>
										<area title="{upper-case(leg:TranslateText('Wales'))}" id="walesarea" shape="poly" coords="167,209,187,227,187,279,151,288,120,271,121,194" href="{$TranslateLangPrefix}/browse/wales"/>
										<area title="{upper-case(leg:TranslateText('UK'))}" id="englandarea" shape="poly" coords="127,156,131,181,187,226,188,278,152,289,112,294,101,339,283,316,283,226,212,141,192,156" href="{$TranslateLangPrefix}/browse/uk"/>
									</map>
								</div>
							</div>
						</div>
						<xsl:variable name="nonDraftTypes" select="$tso:legTypeMap[not(@class = ('draft','IA'))]" />
						<xsl:variable name="draftTypes" select="$tso:legTypeMap[@class = 'draft']" />
						<xsl:variable name="iaTypes" select="$tso:legTypeMap[@class = 'IA']" />
						<div class="s_8 p_one infoArea">
							<dl class="key">
								<dt class="first"><img src="/images/chrome/mapExclusiveKeyIcon.gif" alt="A blue background" /></dt>
								<dd><xsl:value-of select="leg:TranslateText('Browse_UKApplies1')"/></dd>
								
								<dt><img src="/images/chrome/mapAppliesKeyIcon.gif" alt="A light grey background" /></dt>
								<dd><xsl:value-of select="leg:TranslateText('Browse_UKApplies4')"/></dd>
								
								<dt><img src="/images/chrome/mapNAKeyIcon.gif" alt="No background" /></dt>
								<dd><xsl:value-of select="leg:TranslateText('Not applicable')"/></dd>
							</dl>
							<div class="s_4 p_one legCol">
								<ul class="legTypes">
									<xsl:for-each select="$nonDraftTypes[position() &lt;= ceiling(count($nonDraftTypes) div 2)]">
										<li><a id="{@abbrev}" href="{$TranslateLangPrefix}/{@abbrev}"><xsl:value-of select="@plural" />
											<xsl:choose>
												<xsl:when test="exists(@start) and exists(@end) and @start != @end">
													<xsl:text> </xsl:text>
													<xsl:value-of select="@start" />-<xsl:value-of select="@end" />
												</xsl:when>
												<xsl:when test="exists(@start) and exists(@end) and @start = @end">
													<xsl:text> </xsl:text>
													<xsl:value-of select="@start" />
												</xsl:when>
											</xsl:choose>
										</a></li>
									</xsl:for-each>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<ul class="legTypes">
									<xsl:for-each select="$nonDraftTypes[not(@class ='draft')][position() > ceiling(count($nonDraftTypes) div 2)]">
										<li><a id="{@abbrev}" href="{$TranslateLangPrefix}/{@abbrev}"><xsl:value-of select="@plural" />
											<xsl:choose>
												<xsl:when test="exists(@start) and exists(@end) and @start != @end">
													<xsl:text> </xsl:text>
													<xsl:value-of select="@start" />-<xsl:value-of select="@end" />
												</xsl:when>
												<xsl:when test="exists(@start) and exists(@end) and @start = @end">
													<xsl:text> </xsl:text>
													<xsl:value-of select="@start" />
												</xsl:when>
											</xsl:choose>
										</a></li>
									</xsl:for-each>
								</ul>
							</div>
						</div>
						
						<div class="s_8 p_one infoArea">
							<h2 class="s_7 p_one"><xsl:value-of select="leg:TranslateText('Draft legislation')"/></h2>
							<a href="#browseDraftHelp" class="helpItemToMidLeft helpIcon p_two draftHelpIcon"><img src="/images/chrome/helpIcon.gif" alt="Draft Legislation Help" /></a>							
							<div class="s_4 p_one legCol">
								<ul class="legTypes">
									<xsl:for-each select="$draftTypes[position() &lt;= ceiling(count($draftTypes) div 2)]">
										<li><a id="{@abbrev}" href="{$TranslateLangPrefix}/{@abbrev}"><xsl:value-of select="@plural" /></a></li>
									</xsl:for-each>
								</ul>							
							</div>
							<div class="s_4 p_two legCol">
								<ul class="legTypes">
									<xsl:for-each select="$draftTypes[position() > ceiling(count($draftTypes) div 2)]">
										<li><a id="{@abbrev}" href="{$TranslateLangPrefix}/{@abbrev}"><xsl:value-of select="@plural" /></a></li>
									</xsl:for-each>
								</ul>							
							</div>
						</div>						
						<div class="s_8 p_one infoArea">
							<h2 class="s_7 p_one"><xsl:value-of select="leg:TranslateText('Impact Assessments')"/></h2>
							<a href="#browseIaHelp" class="helpItemToMidLeft helpIcon p_two draftHelpIcon"><img src="/images/chrome/helpIcon.gif" alt="Draft Legislation Help" /></a>							
							<div class="s_4 p_one legCol">
								<ul class="legTypes">
									<xsl:for-each select="$iaTypes[position() &lt;= ceiling(count($iaTypes) div 2)]">
										<li><a id="{@abbrev}" href="{$TranslateLangPrefix}/{@abbrev}"><xsl:value-of select="@plural" /></a></li>
									</xsl:for-each>
								</ul>							
							</div>
							<div class="s_4 p_two legCol">
								<ul class="legTypes">
									<xsl:for-each select="$iaTypes[position() > ceiling(count($iaTypes) div 2)]">
										<li><a id="{@abbrev}" href="{$TranslateLangPrefix}/{@abbrev}"><xsl:value-of select="@plural" /></a></li>
									</xsl:for-each>
								</ul>							
							</div>
						</div>							
					</div>
					<div class="help" id="browseMapHelp">
						<span class="icon"></span>
						<div class="content">
							<a href="#" class="close"> <img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
							<h3><xsl:value-of select="leg:TranslateText('Browse_MapHelp_Title')"/></h3>
							<p><xsl:value-of select="leg:TranslateText('Browse_MapHelp_Text')"/></p>
						</div>
					</div>
					
					<div class="help" id="browseDraftHelp">
						<span class="icon"></span>
						<div class="content">
							<a href="#" class="close"> <img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
							<h3><xsl:value-of select="leg:TranslateText('Browse_DraftLegislationHelp_Title')"/></h3>
							<p><xsl:value-of select="leg:TranslateText('Browse_DraftLegislationHelp_Text')"/></p>
						</div>
					</div>	
					
					<div class="help" id="browseIaHelp">
						<span class="icon"></span>
						<div class="content">
							<a href="#" class="close"> <img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
							<h3><xsl:value-of select="leg:TranslateText('Browse_IAHelp_Title')"/></h3>
							<p><xsl:value-of select="leg:TranslateText('Browse_IAHelp_Text')"/></p>
						</div>
					</div>	 
				</div>
			</body>
		</html>
	</xsl:template>
	
	<!-- UK -->
	<xsl:template name="TSOBrowseUK">
		<html>
			<head>
				<link type="text/css" href="/styles/legBrowse.css" rel="stylesheet" />
				<xsl:comment><![CDATA[[if lte IE 6]><link rel="stylesheet" href="/styles/IE/ie6browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<xsl:comment><![CDATA[[if IE 7]><link rel="stylesheet" href="/styles/IE/ie7browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
			</head>
			<body lang="{$TranslateLang}" xml:lang="{$TranslateLang}" dir="ltr" id="browse" class="intro region"> 
				<div id="layout2">
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle"><xsl:value-of select="leg:TranslateText('Browse Legislation')"/>: <abbr title="United Kingdom">UK</abbr></h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">				
							<p class=""><xsl:value-of select="leg:TranslateText('Browse_UKIntro')"/></p>
								<!--<div class="helpPara">
									<h2>Need more help?</h2>
									<p>
										Sed adipiscing sapien non dolor ornare eu hendrerit arcu varius. Phasellus aliquet bibendum nibh in ornare.
										<a href="">Understanding legislation types</a>
									</p>					
								</div>-->
							<div class="s_4 p_absTopRight">
								<div id="map">					
									<img id="blank" src="/images/maps/activeUk.gif" alt="{leg:TranslateText('United Kingdom')} ({leg:TranslateText('UK')})" /> 
									<div class="returnLink ukRegion">
										<a href="{$TranslateLangPrefix}/browse"><xsl:value-of select="leg:TranslateText('Browse_Back')"/></a>
									</div>
								</div>
							</div>
						</div>
						<div class="s_8 p_one">					
							<div class="s_4 p_one legCol">
								<h2><xsl:value-of select="leg:TranslateText('Browse_UKApplies2')"/></h2>
								<ul class="legTypes">
									<li> <a id="ukpga" href="{$TranslateLangPrefix}/ukpga"><xsl:value-of select="leg:TranslateText('UK Public General Acts')"/><span></span></a> </li>
									<li> <a id="ukla" href="{$TranslateLangPrefix}/ukla"><xsl:value-of select="leg:TranslateText('UK Local Acts')"/><span></span></a> </li>
									<li> <a id="uksi" href="{$TranslateLangPrefix}/uksi"><xsl:value-of select="leg:TranslateText('UK Statutory Instruments')"/><span></span></a> </li>
									<li> <a id="ukmo" href="{$TranslateLangPrefix}/ukmo"><xsl:value-of select="leg:TranslateText('UK Ministerial Orders')"/><span></span></a> </li>
									<li> <a id="uksro" href="{$TranslateLangPrefix}/uksro"><xsl:value-of select="leg:TranslateText('UK Statutory Rules and Orders')"/> 1900-1948<span></span></a> </li>
									<li> <a id="ukdsi" href="{$TranslateLangPrefix}/ukdsi"><xsl:value-of select="leg:TranslateText('UK Draft Statutory Instruments')"/><span></span></a> </li>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<h2><xsl:value-of select="leg:TranslateText('Browse_UKApplies3')"/></h2>
								<ul class="legTypes">
									<li> <a id="asp" href="{$TranslateLangPrefix}/asp"><xsl:value-of select="leg:TranslateText('Acts of the Scottish Parliament')"/><span></span></a> </li>
									<li> <a id="nia" href="{$TranslateLangPrefix}/nia"><xsl:value-of select="leg:TranslateText('Acts of the Northern Ireland Assembly')"/><span></span></a> </li>
									<li> <a id="aosp" href="{$TranslateLangPrefix}/aosp"><xsl:value-of select="leg:TranslateText('Acts of the Old Scottish Parliament')"/> 1424-1707<span></span></a> </li>
									<li> <a id="aep" href="{$TranslateLangPrefix}/aep"><xsl:value-of select="leg:TranslateText('Acts of the English Parliament')"/> 1267-1706<span></span></a> </li>
									<li> <a id="aip" href="{$TranslateLangPrefix}/aip"><xsl:value-of select="leg:TranslateText('Acts of the Old Irish Parliament')"/> 1495-1800<span></span></a> </li>
									<li> <a id="apgb" href="{$TranslateLangPrefix}/apgb"><xsl:value-of select="leg:TranslateText('Acts of the Parliament of Great Britain')"/> 1707-1800<span></span></a> </li>
									<li> <a id="nisr" href="{$TranslateLangPrefix}/nisr"><xsl:value-of select="leg:TranslateText('Northern Ireland Statutory Rules')"/> <span></span></a> </li>
									<li> <a id="anaw" href="{$TranslateLangPrefix}/anaw"><xsl:value-of select="leg:TranslateText('Acts of the National Assembly for Wales')"/><span></span></a> </li>
									<li> <a id="mwa" href="{$TranslateLangPrefix}/mwa"><xsl:value-of select="leg:TranslateText('Measures of the National Assembly for Wales')"/><span></span></a> </li>
									<li> <a id="ukcm" href="{$TranslateLangPrefix}/ukcm"><xsl:value-of select="leg:TranslateText('UK Church Measures')"/><span></span></a> </li>
									<li> <a id="wsi" href="{$TranslateLangPrefix}/wsi"><xsl:value-of select="leg:TranslateText('Wales Statutory Instruments')"/><span></span></a> </li>
									<li> <a id="ssi" href="{$TranslateLangPrefix}/ssi"><xsl:value-of select="leg:TranslateText('Scottish Statutory Instruments')"/><span></span></a> </li>
									<li> <a id="nisi" href="{$TranslateLangPrefix}/nisi"><xsl:value-of select="leg:TranslateText('Northern Ireland Orders in Council')"/><span></span></a> </li>
									<li> <a id="ukci" href="{$TranslateLangPrefix}/ukci"><xsl:value-of select="leg:TranslateText('Church Instruments')"/><span></span></a> </li>						
									<li> <a id="mnia" href="{$TranslateLangPrefix}/mnia"><xsl:value-of select="leg:TranslateText('Northern Ireland Assembly Measures')"/> 1974<span></span></a> </li>
									<li> <a id="apni" href="{$TranslateLangPrefix}/apni"><xsl:value-of select="leg:TranslateText('Acts of the Northern Ireland Parliament')"/> 1921-1972<span></span></a> </li>
									<li> <a id="nidsr" href="{$TranslateLangPrefix}/nidsr"><xsl:value-of select="leg:TranslateText('Northern Ireland Draft Statutory Rules')"/><span></span></a> </li>
									<li> <a id="wdsi" href="{$TranslateLangPrefix}/wdsi"><xsl:value-of select="leg:TranslateText('Wales Draft Statutory Instruments')"/><span></span></a> </li>
									<li> <a id="sdsi" href="{$TranslateLangPrefix}/sdsi"><xsl:value-of select="leg:TranslateText('Scottish Draft Statutory Instruments')"/><span></span></a> </li>
									<li> <a id="nidsi" href="{$TranslateLangPrefix}/nidsi"><xsl:value-of select="leg:TranslateText('Northern Ireland Draft Orders in Council')"/><span></span></a> </li>
								</ul>
							</div>
							<div class="s_8 p_one quickLinks">					
								<h2><xsl:value-of select="leg:TranslateText('Browse_QuickLinks')"/></h2>
								<ul>
									<li><a href="{$TranslateLangPrefix}/browse/scotland"><xsl:value-of select="leg:TranslateText('Browse_ScotlandLegislation')"/></a></li>
									<li><a href="{$TranslateLangPrefix}/browse/wales"><xsl:value-of select="leg:TranslateText('Browse_WalesLegislation')"/></a></li>
									<li><a href="{$TranslateLangPrefix}/browse/ni"><xsl:value-of select="leg:TranslateText('Browse_NILegislation')"/></a></li>
								</ul>
							</div>					
						</div>		
					</div>	
				</div>				
			</body>
		</html>
	</xsl:template>
	

	<!-- Wales -->
	<xsl:template name="TSOBrowseWales">
		<html>
			<head>
				<link type="text/css" href="/styles/legBrowse.css" rel="stylesheet" />
				<xsl:comment><![CDATA[[if lte IE 6]><link rel="stylesheet" href="/styles/IE/ie6browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<xsl:comment><![CDATA[[if IE 7]><link rel="stylesheet" href="/styles/IE/ie7browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
			</head>
			<body lang="{$TranslateLang}" xml:lang="{$TranslateLang}" dir="ltr" id="browse" class="intro region"> 		
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle"><xsl:value-of select="leg:TranslateText('Browse Legislation')"/>: <xsl:value-of select="leg:TranslateText('Wales')"/></h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">			
							<p><xsl:value-of select="leg:TranslateText('Browse_WalesIntro')"/></p>
							<!--<div class="helpPara">
								<h2 class="">Need more help?</h2>
								<p>
									Sed adipiscing sapien non dolor ornare eu hendrerit arcu varius. Phasellus aliquet bibendum nibh in ornare.
									<a href="">Understanding legislation types</a>
								</p>					
							</div>-->
							<div class="s_4 p_absTopRight">
								<div id="map">					
									<img id="blank" src="/images/maps/activeWales.gif" />
									<div class="returnLink walesRegion">
										<a href="{$TranslateLangPrefix}/browse"><xsl:value-of select="leg:TranslateText('Browse_Back')"/></a>
									</div>
								</div>
							</div>	
						</div>
						<div class="s_8 p_one">
							<div class="s_4 p_one legCol">
								<h2><xsl:value-of select="leg:TranslateText('Browse_WalesApplies1')"/></h2>
								<ul class="legTypes">
									<li> <a id="anaw" href="{$TranslateLangPrefix}/anaw"><xsl:value-of select="leg:TranslateText('Acts of the National Assembly for Wales')"/><span></span></a> </li>
									<li> <a id="mwa" href="{$TranslateLangPrefix}/mwa"><xsl:value-of select="leg:TranslateText('Measures of the National Assembly for Wales')"/><span></span></a> </li>
									<li> <a id="wsi" href="{$TranslateLangPrefix}/wsi"><xsl:value-of select="leg:TranslateText('Wales Statutory Instruments')"/><span></span></a> </li>						
									<li> <a id="wdsi" href="{$TranslateLangPrefix}/wdsi"><xsl:value-of select="leg:TranslateText('Wales Draft Statutory Instruments')"/><span></span></a> </li>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<h2><xsl:value-of select="leg:TranslateText('Browse_WalesApplies2')"/></h2>
								<ul class="legTypes">
									<li> <a id="ukpga" href="{$TranslateLangPrefix}/ukpga"><xsl:value-of select="leg:TranslateText('UK Public General Acts')"/><span></span></a> </li>
									<li> <a id="ukla" href="{$TranslateLangPrefix}/ukla"><xsl:value-of select="leg:TranslateText('UK Local Acts')"/><span></span></a> </li>
									<li> <a id="aep" href="{$TranslateLangPrefix}/aep"><xsl:value-of select="leg:TranslateText('Acts of the English Parliament')"/> 1267-1706<span></span></a> </li>
									<li> <a id="apgb" href="{$TranslateLangPrefix}/apgb"><xsl:value-of select="leg:TranslateText('Acts of the Parliament of Great Britain')"/> 1707-1800<span></span></a> </li>
									<li> <a id="uksi" href="{$TranslateLangPrefix}/uksi"><xsl:value-of select="leg:TranslateText('UK Statutory Instruments')"/><span></span></a> </li>
									<li> <a id="uksro" href="{$TranslateLangPrefix}/uksro"><xsl:value-of select="leg:TranslateText('UK Statutory Rules and Orders')"/> 1900-1948<span></span></a> </li>
									<li> <a id="ukdsi" href="{$TranslateLangPrefix}/ukdsi"><xsl:value-of select="leg:TranslateText('UK Draft Statutory Instruments')"/><span></span></a> </li>
								</ul>
							</div>
							<div class="s_8 p_one quickLinks">					
								<h2><xsl:value-of select="leg:TranslateText('Browse_QuickLinks')"/></h2>
								<ul>
									<li><a href="{$TranslateLangPrefix}/browse/uk"><xsl:value-of select="leg:TranslateText('Browse_UKLegislation')"/></a></li>
									<li><a href="{$TranslateLangPrefix}/browse/scotland"><xsl:value-of select="leg:TranslateText('Browse_ScotlandLegislation')"/></a></li>
									<li><a href="{$TranslateLangPrefix}/browse/ni"><xsl:value-of select="leg:TranslateText('Browse_NILegislation')"/></a></li>
								</ul>
							</div>
						</div>
					</div>	
				</div>
			</body>
		</html>	
	</xsl:template>

	<!-- Scotland -->
	<xsl:template name="TSOBrowseScotland">
		<html>
			<head>
				<link type="text/css" href="/styles/legBrowse.css" rel="stylesheet" />
				<xsl:comment><![CDATA[[if lte IE 6]><link rel="stylesheet" href="/styles/IE/ie6browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<xsl:comment><![CDATA[[if IE 7]><link rel="stylesheet" href="/styles/IE/ie7browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
			</head>
			<body lang="{$TranslateLang}" xml:lang="{$TranslateLang}" dir="ltr" id="browse" class="intro region"> 		
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle"><xsl:value-of select="leg:TranslateText('Browse Legislation')"/>: <xsl:value-of select="leg:TranslateText('Scotland')"/></h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">				
							<p><xsl:value-of select="leg:TranslateText('Browse_ScotlandIntro')"/></p>
							<!--<div class="helpPara">
								<h2 class="">Need more help?</h2>
								<p>
									Sed adipiscing sapien non dolor ornare eu hendrerit arcu varius. Phasellus aliquet bibendum nibh in ornare.
									<a href="">Understanding legislation types</a>
								</p>					
							</div>-->
							<div class="s_4 p_absTopRight">
								<div id="map">					
									<img id="blank" src="/images/maps/activeScotland.gif" alt="{leg:TranslateText('Scotland')}" />
									<div class="returnLink scotlandRegion">
										<a href="{$TranslateLangPrefix}/browse"><xsl:value-of select="leg:TranslateText('Browse_Back')"/></a>
									</div>
								</div>
							</div>	
						</div>	
						<div class="s_8 p_one">		
							<div class="s_4 p_one legCol">
								<h2><xsl:value-of select="leg:TranslateText('Browse_ScotlandApplies1')"/></h2>
								<ul class="legTypes">
									<li> <a id="asp" href="{$TranslateLangPrefix}/asp"><xsl:value-of select="leg:TranslateText('Acts of the Scottish Parliament')"/></a> </li>
									<li> <a id="aosp" href="{$TranslateLangPrefix}/aosp"><xsl:value-of select="leg:TranslateText('Acts of the Old Scottish Parliament')"/> 1424-1707</a> </li>
									<li> <a id="ssi" href="{$TranslateLangPrefix}/ssi"><xsl:value-of select="leg:TranslateText('Scottish Statutory Instruments')"/></a> </li>
									<li> <a id="sdsi" href="{$TranslateLangPrefix}/sdsi"><xsl:value-of select="leg:TranslateText('Scottish Draft Statutory Instruments')"/><span></span></a> </li>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<h2><xsl:value-of select="leg:TranslateText('Browse_ScotlandApplies2')"/></h2>
								<ul class="legTypes">
									<li> <a id="ukpga" href="{$TranslateLangPrefix}/ukpga"><xsl:value-of select="leg:TranslateText('UK Public General Acts')"/></a> </li>
									<li> <a id="ukla" href="{$TranslateLangPrefix}/ukla"><xsl:value-of select="leg:TranslateText('UK Local Acts')"/></a> </li>
									<li> <a id="apgb" href="{$TranslateLangPrefix}/apgb"><xsl:value-of select="leg:TranslateText('Acts of the Parliament of Great Britain')"/> 1707-1800</a> </li>
									<li> <a id="uksi" href="{$TranslateLangPrefix}/uksi"><xsl:value-of select="leg:TranslateText('UK Statutory Instruments')"/></a> </li>						
									<li> <a id="uksro" href="{$TranslateLangPrefix}/uksro"><xsl:value-of select="leg:TranslateText('UK Statutory Rules and Orders')"/> 1900-1948<span></span></a> </li>
									<li> <a id="ukdsi" href="{$TranslateLangPrefix}/ukdsi"><xsl:value-of select="leg:TranslateText('UK Draft Statutory Instruments')"/><span></span></a> </li>
								</ul>
							</div>
							<div class="s_8 p_one quickLinks">					
								<h2><xsl:value-of select="leg:TranslateText('Browse_QuickLinks')"/></h2>
								<ul>
									<li><a href="{$TranslateLangPrefix}/browse/uk"><xsl:value-of select="leg:TranslateText('Browse_UKLegislation')"/></a></li>
									<li><a href="{$TranslateLangPrefix}/browse/wales"><xsl:value-of select="leg:TranslateText('Browse_WalesLegislation')"/></a></li>
									<li><a href="{$TranslateLangPrefix}/browse/ni"><xsl:value-of select="leg:TranslateText('Browse_NILegislation')"/></a></li>
								</ul>
							</div>							
						</div>
					</div>			
				</div>
			</body>
		</html>	
	</xsl:template>

	<!-- NI -->
	<xsl:template name="TSOBrowseNI">
		<html>
			<head>
				<link type="text/css" href="/styles/legBrowse.css" rel="stylesheet" />
				<xsl:comment><![CDATA[[if lte IE 6]><link rel="stylesheet" href="/styles/IE/ie6browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<xsl:comment><![CDATA[[if IE 7]><link rel="stylesheet" href="/styles/IE/ie7browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
			</head>
			<body lang="{$TranslateLang}" xml:lang="{$TranslateLang}" dir="ltr" id="browse" class="intro region"> 		
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle"><xsl:value-of select="leg:TranslateText('Browse Legislation')"/>: <xsl:value-of select="leg:TranslateText('Northern Ireland')"/></h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">				
							<p><xsl:value-of select="leg:TranslateText('Browse_NIIntro')"/></p>
							<!--<div class="helpPara">
								<h2 class="">Need more help?</h2>
								<p>
									Sed adipiscing sapien non dolor ornare eu hendrerit arcu varius. Phasellus aliquet bibendum nibh in ornare.
									<a href="">Understanding legislation types</a>
								</p>					
							</div>-->
							<div class="s_4 p_absTopRight">
								<div id="map">					
									<img id="blank" src="/images/maps/activeNi.gif" alt="Northern Ireland" />
									<div class="returnLink niRegion">
										<a href="{$TranslateLangPrefix}/browse"><xsl:value-of select="leg:TranslateText('Browse_Back')"/></a>
									</div>
								</div>
							</div>	
						</div>
						<div class="s_8 p_one">
							<div class="s_4 p_one legCol">
								<h2><xsl:value-of select="leg:TranslateText('Browse_NIApplies1')"/></h2>
								<ul class="legTypes">
									<li> <a id="nia" href="{$TranslateLangPrefix}/nia"><xsl:value-of select="leg:TranslateText('Acts of the Northern Ireland Assembly')"/><span></span></a> </li>
									<li> <a id="aip" href="{$TranslateLangPrefix}/aip"><xsl:value-of select="leg:TranslateText('Acts of the Old Irish Parliament')"/> 1495-1800<span></span></a> </li>
									<li> <a id="nisr" href="{$TranslateLangPrefix}/nisr"><xsl:value-of select="leg:TranslateText('Northern Ireland Statutory Rules')"/><span></span></a> </li>
									<li> <a id="nisi" href="{$TranslateLangPrefix}/nisi"><xsl:value-of select="leg:TranslateText('Northern Ireland Orders in Council')"/><span></span></a> </li>
									<li> <a id="mnia" href="{$TranslateLangPrefix}/mnia"><xsl:value-of select="leg:TranslateText('Northern Ireland Assembly Measures')"/> 1974<span></span></a> </li>
									<li> <a id="apni" href="{$TranslateLangPrefix}/apni"><xsl:value-of select="leg:TranslateText('Acts of the Northern Ireland Parliament')"/> 1921-1972<span></span></a> </li>
									<li> <a id="nidsr" href="{$TranslateLangPrefix}/nidsr"><xsl:value-of select="leg:TranslateText('Northern Ireland Draft Statutory Rules')"/><span></span></a> </li>
									<li> <a id="nidsi" href="{$TranslateLangPrefix}/nidsi"><xsl:value-of select="leg:TranslateText('Northern Ireland Draft Orders in Council')"/><span></span></a> </li>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<h2><xsl:value-of select="leg:TranslateText('Browse_NIApplies2')"/></h2>
								<ul class="legTypes">
									<li> <a id="ukpga" href="{$TranslateLangPrefix}/ukpga"><xsl:value-of select="leg:TranslateText('UK Public General Acts')"/><span></span></a> </li>
									<li> <a id="ukla" href="{$TranslateLangPrefix}/ukla"><xsl:value-of select="leg:TranslateText('UK Local Acts')"/><span></span></a> </li>
									<li> <a id="uksi" href="{$TranslateLangPrefix}/uksi"><xsl:value-of select="leg:TranslateText('UK Statutory Instruments')"/><span></span></a> </li>
									<li> <a id="uksro" href="{$TranslateLangPrefix}/uksro"><xsl:value-of select="leg:TranslateText('UK Statutory Rules and Orders')"/> 1900-1948<span></span></a> </li>
									<li> <a id="ukdsi" href="{$TranslateLangPrefix}/ukdsi"><xsl:value-of select="leg:TranslateText('UK Draft Statutory Instruments')"/><span></span></a> </li>
								</ul>
							</div>
							<div class="s_8 p_one quickLinks">					
								<h2><xsl:value-of select="leg:TranslateText('Browse_QuickLinks')"/></h2>
								<ul>
									<li><a href="{$TranslateLangPrefix}/browse/uk"><xsl:value-of select="leg:TranslateText('Browse_UKLegislation')"/></a></li>
									<li><a href="{$TranslateLangPrefix}/browse/scotland"><xsl:value-of select="leg:TranslateText('Browse_ScotlandLegislation')"/></a></li>
									<li><a href="{$TranslateLangPrefix}/browse/wales"><xsl:value-of select="leg:TranslateText('Browse_WalesLegislation')"/></a></li>
								</ul>
							</div>							
						</div>
					</div>
				</div>
			</body>
		</html>	
	</xsl:template>
	
</xsl:stylesheet>
