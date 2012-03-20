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
			<body lang="en" xml:lang="en" dir="ltr" id="browse" class="intro"> 
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle">Browse</h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">
							<div class="s_8 p_one">
								<p>Legislation.gov.uk carries most types of UK Legislation.  The list below is a complete breakdown of the types of legislation held on this site.  From this page you can select any legislation type and continue browsing or you can hover over the map to see which legislation types are applicable to the geographical area you are interested in.</p>
							</div>							
							<div class="s_4 p_absTopRight">
								<p><strong>Hover over the map</strong> to highlight legislation types or click to view legislation for the area selected.</p>
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
										<area title="NORTHERN IRELAND" id="niarea" shape="poly" coords="87,133,79,142,79,171,102,171,103,177,124,178,112,133" href="/browse/ni"/>
										<area title="SCOTLAND" id="scotlandarea" shape="poly" coords="127,155,114,133,80,107,80,1,210,0,210,140,193,155" href="/browse/scotland"/>
										<area title="WALES" id="walesarea" shape="poly" coords="167,209,187,227,187,279,151,288,120,271,121,194" href="/browse/wales"/>
										<area title="UK" id="englandarea" shape="poly" coords="127,156,131,181,187,226,188,278,152,289,112,294,101,339,283,316,283,226,212,141,192,156" href="/browse/uk"/>
									</map>
								</div>
							</div>
						</div>
						<xsl:variable name="nonDraftTypes" select="$tso:legTypeMap[not(@class = 'draft')]" />
						<xsl:variable name="draftTypes" select="$tso:legTypeMap[@class = 'draft']" />
						<div class="s_8 p_one infoArea">
							<dl class="key">
								<dt class="first"><img src="/images/chrome/mapExclusiveKeyIcon.gif" alt="A blue background" /></dt>
								<dd>Exclusively or primarily applies to the area on the map</dd>
								
								<dt><img src="/images/chrome/mapAppliesKeyIcon.gif" alt="A light grey background" /></dt>
								<dd>Contains legislation that applies/may apply to the whole or part of the area on the map</dd>
								
								<dt><img src="/images/chrome/mapNAKeyIcon.gif" alt="No background" /></dt>
								<dd>Not applicable</dd>
							</dl>
							<div class="s_4 p_one legCol">
								<ul class="legTypes">
									<xsl:for-each select="$nonDraftTypes[position() &lt;= ceiling(count($nonDraftTypes) div 2)]">
										<li><a id="{@abbrev}" href="/{@abbrev}"><xsl:value-of select="@plural" /></a></li>
									</xsl:for-each>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<ul class="legTypes">
									<xsl:for-each select="$nonDraftTypes[not(@class ='draft')][position() > ceiling(count($nonDraftTypes) div 2)]">
										<li><a id="{@abbrev}" href="/{@abbrev}"><xsl:value-of select="@plural" /></a></li>
									</xsl:for-each>
								</ul>
							</div>
						</div>
						
						<div class="s_8 p_one infoArea">
							<h2 class="s_7 p_one">Draft legislation</h2>
							<a href="#browseDraftHelp" class="helpItemToMidLeft helpIcon p_two draftHelpIcon"><img src="/images/chrome/helpIcon.gif" alt="Draft Legislation Help" /></a>							
							<div class="s_4 p_one legCol">
								<ul class="legTypes">
									<xsl:for-each select="$draftTypes[position() &lt;= ceiling(count($draftTypes) div 2)]">
										<li><a id="{@abbrev}" href="/{@abbrev}"><xsl:value-of select="@plural" /></a></li>
									</xsl:for-each>
								</ul>							
							</div>
							<div class="s_4 p_two legCol">
								<ul class="legTypes">
									<xsl:for-each select="$draftTypes[position() > ceiling(count($draftTypes) div 2)]">
										<li><a id="{@abbrev}" href="/{@abbrev}"><xsl:value-of select="@plural" /></a></li>
									</xsl:for-each>
								</ul>							
							</div>
						</div>						
												
					</div>
					<div class="help" id="browseMapHelp">
						<span class="icon"></span>
						<div class="content">
							<a href="#" class="close"> <img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
						  <h3>Browse map help</h3>
						  <p>The UK parliament has power to make legislation for the whole of the UK. However, the parliaments and assemblies of Scotland, Wales and Northern Ireland all have powers to make certain types of legislation specific to their geographical areas. This interactive map and legislation list aims to show the different legislation types that may be applicable to different areas.</p>
						</div>
					 </div>
					 
					<div class="help" id="browseDraftHelp">
						<span class="icon"></span>
						<div class="content">
							<a href="#" class="close"> <img alt="Close" src="/images/chrome/closeIcon.gif" /></a>
						  <h3>Draft Legislation help</h3>
						  <p>Draft legislation is legislation that is awaiting approval. It generally either becomes law or in some cases is withdrawn. Also, sometimes draft legislation is replaced by another draft. For these reasons, these draft legislation types are not reflected by the interactive map above.</p>
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
			<body lang="en" xml:lang="en" dir="ltr" id="browse" class="intro region"> 
				<div id="layout2">
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle">Browse Legislation: <abbr title="United Kingdom">UK</abbr></h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">				
								<p class="">Legislation.gov.uk carries most types of UK Legislation.  The list below is a breakdown of the types of legislation held on this site that are applicable to the whole or some part of the UK. From this page you can select any legislation type to continue browsing.</p>
								<!--<div class="helpPara">
									<h2>Need more help?</h2>
									<p>
										Sed adipiscing sapien non dolor ornare eu hendrerit arcu varius. Phasellus aliquet bibendum nibh in ornare.
										<a href="">Understanding legislation types</a>
									</p>					
								</div>-->
							<div class="s_4 p_absTopRight">
								<div id="map">					
									<img id="blank" src="/images/maps/activeUk.gif" alt="United Kingdom (UK)" /> 
									<div class="returnLink ukRegion">
										<a href="/browse">Back to all legislation</a>
									</div>
								</div>
							</div>
						</div>
						<div class="s_8 p_one">					
							<div class="s_4 p_one legCol">
								<h2>Exclusively or primarily applies to the UK</h2>
								<ul class="legTypes">
									<li> <a id="ukpga" href="/ukpga">UK Public General Acts<span></span></a> </li>
									<li> <a id="ukla" href="/ukla">UK Local Acts<span></span></a> </li>
									<li> <a id="uksi" href="/uksi">UK Statutory Instruments<span></span></a> </li>
									<li> <a id="ukmo" href="/ukmo">UK Ministerial Order<span></span></a> </li>
									<li> <a id="uksro" href="/uksro">UK Statutory Rules and Orders 1900-1948<span></span></a> </li>
									<li> <a id="ukdsi" href="/ukdsi">UK Draft Statutory Instruments<span></span></a> </li>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<h2>May contain legislation that applies to the UK</h2>
								<ul class="legTypes">
									<li> <a id="asp" href="/asp">Acts of the Scottish Parliament<span></span></a> </li>
									<li> <a id="nia" href="/nia">Acts of the Northern Ireland Assembly<span></span></a> </li>
									<li> <a id="aosp" href="/aosp">Acts of the Old Scottish Parliament<span></span></a> </li>
									<li> <a id="aep" href="/aep">Acts of English Parliament 1267-1706<span></span></a> </li>
									<li> <a id="aip" href="/aip">Acts of the Old Irish Parliament 1495-1800<span></span></a> </li>
									<li> <a id="apgb" href="/apgb">Acts of Parliament of Great Britain 1707-1800<span></span></a> </li>
									<li> <a id="nisr" href="/nisr">Northern Ireland Statutory Rules<span></span></a> </li>
									<li> <a id="mwa" href="/mwa">Measures of the National Assembly for Wales<span></span></a> </li>
									<li> <a id="ukcm" href="/ukcm">UK Church Measures<span></span></a> </li>
									<li> <a id="wsi" href="/wsi">Wales Statutory Instruments<span></span></a> </li>
									<li> <a id="ssi" href="/ssi">Scottish Statutory Instruments<span></span></a> </li>
									<li> <a id="nisi" href="/nisi">Northern Ireland Orders in Council<span></span></a> </li>
									<li> <a id="ukci" href="/ukci">Church Instruments<span></span></a> </li>						
									<li> <a id="mnia" href="/mnia">Northern Ireland Assembly Measures 1974<span></span></a> </li>
									<li> <a id="apni" href="/apni">Acts of the Northern Ireland Parliament 1921-1972<span></span></a> </li>
									<li> <a id="nidsr" href="/nidsr">Northern Ireland Draft Statutory Rules<span></span></a> </li>
									<li> <a id="wdsi" href="/wdsi">Wales Draft Statutory Instruments<span></span></a> </li>
									<li> <a id="sdsi" href="/sdsi">Scottish Draft Statutory Instruments<span></span></a> </li>
									<li> <a id="nidsi" href="/nidsi">Northern Ireland Draft Orders in Council<span></span></a> </li>
								</ul>
							</div>
							<div class="s_8 p_one quickLinks">					
								<h2>Quick links</h2>
								<ul>
									<li><a href="/browse/scotland">Scotland Legislation</a></li>
									<li><a href="/browse/wales">Wales Legislation</a></li>
									<li><a href="/browse/ni">Northern Ireland Legislation</a></li>
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
			<body lang="en" xml:lang="en" dir="ltr" id="browse" class="intro region"> 		
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle">Browse Legislation: Wales</h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">			
							<p>Legislation.gov.uk carries most types of UK Legislation including Welsh Legislation.  The list below is a breakdown of the types of legislation held on this site that are either exclusively applicable to Wales or contain legislation that may pertain to Wales. From this page you can select any legislation type to continue browsing.</p>
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
										<a href="/browse">Back to all legislation</a>
									</div>
								</div>
							</div>	
						</div>
						<div class="s_8 p_one">
							<div class="s_4 p_one legCol">
								<h2>Exclusively or primarily applies to Wales</h2>
								<ul class="legTypes">
									<li> <a id="mwa" href="/mwa">Measures of the National Assembly for Wales<span></span></a> </li>
									<li> <a id="wsi" href="/wsi">Wales Statutory Instruments<span></span></a> </li>						
									<li> <a id="wdsi" href="/wdsi">Wales Draft Statutory Instruments<span></span></a> </li>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<h2>May contain legislation that applies to Wales</h2>
								<ul class="legTypes">
									<li> <a id="ukpga" href="/ukpga">UK Public General Acts<span></span></a> </li>
									<li> <a id="ukla" href="/ukla">UK Local Acts<span></span></a> </li>
									<li> <a id="aep" href="/aep">Acts of English Parliament 1267-1706<span></span></a> </li>
									<li> <a id="apgb" href="/apgb">Acts of Parliament of Great Britain 1707-1800<span></span></a> </li>
									<li> <a id="uksi" href="/uksi">UK Statutory Instruments<span></span></a> </li>
									<li> <a id="uksro" href="/uksro">UK Statutory Rules and Orders 1900-1948<span></span></a> </li>
									<li> <a id="ukdsi" href="/ukdsi">UK Draft Statutory Instruments<span></span></a> </li>
								</ul>
							</div>
							<div class="s_8 p_one quickLinks">					
								<h2>Quick links</h2>
								<ul>
									<li><a href="/browse/uk">UK Legislation</a></li>
									<li><a href="/browse/scotland">Scotland Legislation</a></li>
									<li><a href="/browse/ni">Northern Ireland Legislation</a></li>
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
			<body lang="en" xml:lang="en" dir="ltr" id="browse" class="intro region"> 		
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle">Browse Legislation: Scotland</h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">				
							<p>Legislation.gov.uk carries most types of UK Legislation including Scottish Legislation.  The list below is a breakdown of the types of legislation held on this site that are either exclusively applicable to Scotland or contain legislation that may pertain to Scotland. From this page you can select any legislation type to continue browsing.</p>
							<!--<div class="helpPara">
								<h2 class="">Need more help?</h2>
								<p>
									Sed adipiscing sapien non dolor ornare eu hendrerit arcu varius. Phasellus aliquet bibendum nibh in ornare.
									<a href="">Understanding legislation types</a>
								</p>					
							</div>-->
							<div class="s_4 p_absTopRight">
								<div id="map">					
									<img id="blank" src="/images/maps/activeScotland.gif" alt="Scotland" />
									<div class="returnLink scotlandRegion">
										<a href="/browse">Back to all legislation</a>
									</div>
								</div>
							</div>	
						</div>	
						<div class="s_8 p_one">		
							<div class="s_4 p_one legCol">
								<h2>Exclusively or primarily applies to Scotland</h2>
								<ul class="legTypes">
									<li> <a id="asp" href="/asp">Acts of the Scottish Parliament</a> </li>
									<li> <a id="aosp" href="/aosp">Acts of the Old Scottish Parliament</a> </li>
									<li> <a id="ssi" href="/ssi">Scottish Statutory Instruments</a> </li>
									<li> <a id="sdsi" href="/sdsi">Scottish Draft Statutory Instruments<span></span></a> </li>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<h2>May contain legislation that applies to Scotland</h2>
								<ul class="legTypes">
									<li> <a id="ukpga" href="/ukpga">UK Public General Acts</a> </li>
									<li> <a id="ukla" href="/ukla">UK Local Acts</a> </li>
									<li> <a id="apgb" href="/apgb">Acts of Parliament of Great Britain 1707-1800</a> </li>
									<li> <a id="uksi" href="/uksi">UK Statutory Instruments</a> </li>						
									<li> <a id="uksro" href="/uksro">UK Statutory Rules and Orders 1900-1948<span></span></a> </li>
									<li> <a id="ukdsi" href="/ukdsi">UK Draft Statutory Instruments<span></span></a> </li>
								</ul>
							</div>
							<div class="s_8 p_one quickLinks">					
								<h2>Quick links</h2>
								<ul>
									<li><a href="/browse/uk">UK Legislation</a></li>
									<li><a href="/browse/wales">Wales Legislation</a></li>
									<li><a href="/browse/ni">Northern Ireland Legislation</a></li>
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
			<body lang="en" xml:lang="en" dir="ltr" id="browse" class="intro region"> 		
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="title">
						<h1 id="pageTitle">Browse Legislation: Northern Ireland</h1>
					</div>
					<div id="content">
						<div class="s_8 p_one intro">				
							<p>Legislation.gov.uk carries most types of UK Legislation including Northern Irish Legislation.  The list below is a breakdown of the types of legislation held on this site that are either exclusively applicable to Northern Ireland or contain legislation that may pertain to Northern Ireland. From this page you can select any legislation type to continue browsing.</p>
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
										<a href="/browse">Back to all legislation</a>
									</div>
								</div>
							</div>	
						</div>
						<div class="s_8 p_one">
							<div class="s_4 p_one legCol">
								<h2>Exclusively or primarily applies to Northern Ireland</h2>
								<ul class="legTypes">
									<li> <a id="nia" href="/nia">Acts of the Northern Ireland Assembly<span></span></a> </li>
									<li> <a id="aip" href="/aip">Acts of the Old Irish Parliament 1495-1800<span></span></a> </li>
									<li> <a id="nisr" href="/nisr">Northern Ireland Statutory Rules<span></span></a> </li>
									<li> <a id="nisi" href="/nisi">Northern Ireland Orders in Council<span></span></a> </li>
									<li> <a id="mnia" href="/mnia">Northern Ireland Assembly Measures 1974<span></span></a> </li>
									<li> <a id="apni" href="/apni">Acts of the Northern Ireland Parliament 1921-1972<span></span></a> </li>
									<li> <a id="nidsr" href="/nidsr">Northern Ireland Draft Statutory Rules<span></span></a> </li>
									<li> <a id="nidsi" href="/nidsi">Northern Ireland Draft Orders in Council<span></span></a> </li>
								</ul>
							</div>
							<div class="s_4 p_two legCol">
								<h2>May contain legislation that applies to Northern Ireland</h2>
								<ul class="legTypes">
									<li> <a id="ukpga" href="/ukpga">UK Public General Acts<span></span></a> </li>
									<li> <a id="ukla" href="/ukla">UK Local Acts<span></span></a> </li>
									<li> <a id="uksi" href="/uksi">UK Statutory Instruments<span></span></a> </li>
									<li> <a id="uksro" href="/uksro">UK Statutory Rules and Orders 1900-1948<span></span></a> </li>
									<li> <a id="ukdsi" href="/ukdsi">UK Draft Statutory Instruments<span></span></a> </li>
								</ul>
							</div>
							<div class="s_8 p_one quickLinks">					
								<h2>Quick links</h2>
								<ul>
									<li><a href="/browse/uk">UK Legislation</a></li>
									<li><a href="/browse/scotland">Scotland Legislation</a></li>
									<li><a href="/browse/wales">Wales Legislation</a></li>
								</ul>
							</div>							
						</div>
					</div>
				</div>
			</body>
		</html>	
	</xsl:template>

	
</xsl:stylesheet>
