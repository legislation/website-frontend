<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	exclude-result-prefixes="#all">

<xsl:import href="../apps/opsi/xsl/legislation/html/quicksearch.xsl" />

<xsl:output method="xhtml" indent="no" encoding="UTF-8" exclude-result-prefixes="xhtml" omit-xml-declaration="yes"/>

<xsl:variable name="g_strBaseURL" select="'/'"/>

<xsl:variable name="g_strUri">
	<xsl:value-of select="doc('input:request')//request-path"/>
	<xsl:if test="doc('input:request')//query-string != ''">
		<xsl:text>?</xsl:text>
		<xsl:value-of select="doc('input:request')//query-string"/>
	</xsl:if>
</xsl:variable>

<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

<xsl:function name="leg:IsHome" as="xs:boolean">
	<xsl:sequence select="$paramsDoc/request/request-path ='/' "/>
</xsl:function>

<xsl:function name="leg:IsTOC" as="xs:boolean">
	<xsl:sequence select="$paramsDoc/parameters/view ='contents' " />
</xsl:function>		

<xsl:function name="leg:IsContent" as="xs:boolean">
	<xsl:sequence select="$paramsDoc/parameters/section !='' or $paramsDoc/parameters/view = 'introduction'" />
</xsl:function>	

<xsl:template match="/*">
	<html xmlns="http://www.w3.org/1999/xhtml" xmlns:dct="http://purl.org/dc/terms/" lang="en" xml:lang="en">
		<xsl:apply-templates select="@*"/>
		<xsl:text>&#10;</xsl:text>
		<head>
			<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=iso-8859-1" />
			<xsl:if test="not(xhtml:head/xhtml:title)">
				<title>Legislation.gov.uk</title>
			</xsl:if>
			<link rel="icon" href="/favicon.ico" />
			<link rel="stylesheet" href="/styles/screen.css" type="text/css" />
      		<link rel="stylesheet" href="/styles/survey/survey.css" type="text/css" />
			<xsl:comment><![CDATA[[if lte IE 6]><link rel="stylesheet" href="/styles/IE/ie6chromeAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
			<xsl:comment><![CDATA[[if lte IE 7]><link rel="stylesheet" href="/styles/IE/ie7chromeAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
			<xsl:if test="not(contains(xhtml:body/@class, 'removeScripting'))">
			<script type="text/javascript" src="/scripts/jquery-1.6.2.js"></script>
			<!-- <script type="text/javascript" src="/scripts/sitestat.js"></script> -->
      <script type="text/javascript" src="/scripts/survey/survey.js"></script>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="leg:IsHome()">
						<script type="text/javascript" src="/scripts/homepageChrome.js"/>

				</xsl:when>
				<xsl:otherwise>
						<script type="text/javascript" src="/scripts/chrome.js"></script>				
						<script type="text/javascript" src="/scripts/jquery.cookie.js"></script>		
				</xsl:otherwise>
			</xsl:choose>
			<xsl:copy-of select="xhtml:head/node() except xhtml:head/xhtml:meta[@http-equiv]" copy-namespaces="no" />
			<xsl:copy-of select="xhtml:head/xhtml:meta[lower-case(@http-equiv) = 'refresh']" copy-namespaces="no" />
			<link rel="stylesheet" href="/styles/print.css" type="text/css" media="print" />
		</head>
		<body>
			<xsl:copy-of select="xhtml:body/@*"/>
			<xsl:if test="/error">
				<xsl:attribute name="id" select="'error'" />
			</xsl:if>
			
			<div id="preloadBg">
				<script type="text/javascript">		
					$("body").addClass("js");
				</script>
			</div>
			
            <!-- accessible skip links -->
            <ul id="top" class="accessibleLinks">
            	<xsl:choose>         	
                   <!-- issue highlighted by HA050430 where there can be multiple parameter/value elements  -->
				   <xsl:when test="some $value in $paramsDoc/request/parameters/parameter/value satisfies contains($value,'plain')">                        
                        <li><a href="#content">Skip to main content</a></li>
                        <li><a href="#plainViewNav">Skip to navigation</a></li>                      
                    </xsl:when>                
                    <xsl:otherwise>                        
                        <li><a href="#pageTitle">Skip to main content</a></li>
                        <li><a href="#primaryNav">Skip to navigation</a></li>                        
                    </xsl:otherwise> 
                </xsl:choose>
			</ul>
            
			<div id="layout1">

				<!-- header -->
				<xsl:call-template name="header"/>

				<!-- adding background -->
				<xsl:call-template name="background"/>
				
				<xsl:choose>
					<xsl:when test="/error">
						<xsl:next-match />
					</xsl:when>
					<xsl:otherwise>
						<!-- content -->
						<xsl:apply-templates select="xhtml:body/node()" />
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- adding the netstats -->
				<!-- <xsl:call-template name="NetStats"/> -->
				
				<!-- footer -->				
				<xsl:call-template name="footer"/>
			</div>
			<!--/#layout1-->
				
				<div id="modalBg" style="width: 1264px; height: 1731px; opacity: 0.8; display: none;"/>
				
			<script>
				$("#statusWarningSubSections").css("display", "none");
				$(".help").css("display", "none");			
				$("#searchChanges", "#existingSearch").css({"display": "none"});
			</script>
		</body>
	</html>
</xsl:template>

<xsl:template name="background">
	<div id="background"><!-- this creates the 22em high grey bar background--></div>				
</xsl:template>

<xsl:template match="error">
	<div id="layout2">
		<!-- adding quick search  -->
		<xsl:call-template name="TSOOutputQuickSearch"/>
		<div id="title">
			<h1 id="pageTitle">
				<xsl:choose>
					<xsl:when test="status-code = 503">Temporarily Unavailable</xsl:when>
					<xsl:when test="status-code = 404">Page Not Found</xsl:when>
					<xsl:when test="status-code = 300">Multiple Choices</xsl:when>
					<xsl:when test="status-code = 200">Found References</xsl:when>
					<xsl:when test="status-code = 201">Created</xsl:when>
					<xsl:when test="status-code = 202">Accepted</xsl:when>
					<xsl:otherwise>Internal Error</xsl:otherwise> 
				</xsl:choose>
			</h1>
		</div>
		<div id="content">
			<xsl:choose>
				<xsl:when test="status-code = 404">
					<p class="first">The page you requested could not be found.</p>
				
					<p>Please check for any of the following if you see this page after a search:
					  <ul>
						<li>Spelling mistakes in the search phrase</li>
						<li>Invalid parameter entered e.g 19988 instead of 1998 for a year</li>
					  </ul>
					</p>
					
					<p>Alternatively, the referrer may have passed an invalid URI to this site. Check that the URI has 'www' and does not start with 'https:'</p>					
				</xsl:when>
				<xsl:otherwise>
					<p class="first">
						<xsl:value-of select="message"/>
					</p>							
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="link">
				<xsl:choose>
					<xsl:when test="status-code = 300">
						<p>The link that you've followed could mean <xsl:value-of select="if (count(link) > 2) then 'any' else 'either'" /> of the following:</p>
					</xsl:when>
					<xsl:when test="status-code = 200">
						<p>Try the following items of legislation:</p>
					</xsl:when>
					<xsl:otherwise>
						<p>The following are possible links that you could try as alternatives:</p>
					</xsl:otherwise>
				</xsl:choose>
				<ul>
					<xsl:for-each select="link">
						<xsl:sort order="descending" select="." />
						<li>
							<a href="/{substring-after(substring-after(@href, 'http://'), '/')}">
								<xsl:value-of select="." />
							</a>
						</li>
					</xsl:for-each>
				</ul>
			</xsl:if>
		</div>
	</div>
</xsl:template>


<xsl:template match="@href[starts-with(., 'http://www.legislation.gov.uk/') and not(ends-with(.,'htm')) and not(ends-with(.,'feed')) ]">
	<xsl:attribute name="href">
		<xsl:value-of select="substring-after(., 'http://www.legislation.gov.uk')"/>
		<xsl:if test="string-length($paramsDoc/request/query-string) > 0 and not(contains(., '?'))">?<xsl:value-of select="$paramsDoc/request/query-string"/></xsl:if>
	</xsl:attribute>
</xsl:template>

<xsl:template match="@src[starts-with(., 'http://www.legislation.gov.uk/')]">
	<xsl:attribute name="src" select="substring-after(., 'http://www.legislation.gov.uk')" />
</xsl:template>

<!-- Simply copy everything that's not matched -->
<xsl:template match="@*|node()">
	<xsl:copy copy-namespaces="no">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template name="header">
	<div id="header">
		<xsl:element name="{if (leg:IsHome()) then 'h1' else 'h2'}">
			<a href="/">legislation.gov.uk<span/></a>
		</xsl:element>	
		<span class="natArch">
			<a href="http://www.nationalarchives.gov.uk">The National Archives<span/></a>
		</span>	
	<ul id="secondaryNav">
			<li><a href="/help">Help</a></li>
			<li><a href="/sitemap">Site Map</a></li>
			<li><a href="/accessibility">Accessibility</a></li>
			<li><a href="/contactus">Contact Us</a></li>
		</ul>
	</div>
	<div id="primaryNav">
		<div class="navLayout">
			<ul>
				<li class="link1"><a href="/"><span>Home</span></a></li>
				<li class="link2"><a href="/aboutus"><span>About Us</span></a></li>
				<li class="link3"><a href="/browse"><span>Browse Legislation</span></a></li>
				<li class="link4"><a href="/new"><span>New Legislation</span></a></li>
				<li class="link5"><a href="/changes"><span>Changes to Legislation</span></a></li>
				<li id="quickSearch"><a class="expandCollapseLink" href="#contentSearch"><span>Search Legislation</span></a></li>				
			</ul>
		</div>
	</div>

</xsl:template>

<xsl:template name="footer">
	<div id="footer">
		<div>
			<p>&#xa9; <span rel="dct:rights" resource="http://reference.data.gov.uk/def/copyright/crown-copyright">Crown copyright</span></p>
			<p>You may use and re-use the information featured on this website (not including logos) free of charge in any format or medium, under the terms of the <a href="http://reference.data.gov.uk/id/open-government-licence" rel="license"> Open Government Licence</a></p>
		</div>
	</div>
</xsl:template>

<!-- ============= Nets Stats ========================-->
<!-- <xsl:template name="NetStats">

	<xsl:variable name="counterName" select="leg:GetNetStatsCounterName()"/>
	<xsl:comment>Begin Sitestat4 code</xsl:comment>
	<script language='JavaScript1.1' type='text/javascript'>
		<xsl:text>//</xsl:text>
		<xsl:comment>
		<![CDATA[
			function sitestat(ns_l){ns_l+='&amp;ns__t='+(new Date()).getTime();ns_pixelUrl=ns_l;
			ns_0=document.referrer;
			ns_0=(ns_0.lastIndexOf('/')==ns_0.length-1)?ns_0.substring(ns_0.lastIndexOf('/'),0):ns_0;
			if(ns_0.length>0)ns_l+='&amp;ns_referrer='+escape(ns_0);
			if(document.images){ns_1=new Image();ns_1.src=ns_l;}else
			document.write('<img src="'+ns_l+'" width="1" height="1" alt="">');}
			sitestat("http://uk.sitestat.com/opsi/legislation/s?]]><xsl:value-of select="$counterName"/><![CDATA[");
		]]>//</xsl:comment>
	</script>
	<noscript>
		<img src="http://uk.sitestat.com/opsi/legislation/s?{$counterName}" width="1" height="1" alt=""/>
	</noscript>
	<xsl:comment>End Sitestat4 code</xsl:comment 
</xsl:template>

<xsl:function  name="leg:GetNetStatsCounterName">
	<xsl:variable name="url" as="xs:string*" >
		<xsl:choose>
			<xsl:when test="$paramsDoc/request/request-path = '/' ">
				<xsl:text>home</xsl:text>
			</xsl:when>
			<xsl:otherwise>
		<xsl:for-each select="tokenize(substring-after($paramsDoc/request/request-path, '/'), '/')">
			<xsl:choose>
				<xsl:when test="position() = last() and . castable as xs:date and not(starts-with($paramsDoc/request/request-path, '/new')) "/>			
				<xsl:when test="position() = last() and matches(., '(england|wales|scotland|ni)(\+(england|wales|scotland|ni))*$')"/>
				<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="queryParams" as="xs:string+">
			<xsl:if test="$paramsDoc/request/parameters/parameter[name = 'timeline'] ">
					<xsl:text>timeline=true</xsl:text>
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="$paramsDoc/request/parameters/parameter[name = 'view' and contains(value, 'plain')]">
					<xsl:text>view=plain</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>view=full</xsl:text>				
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:for-each select="tokenize($paramsDoc/request/request-path, '/') ">
				<xsl:choose>
					<xsl:when test="position() = last() and matches(., '(england|wales|scotland|ni)(\+(england|wales|scotland|ni))*$')">
						<xsl:value-of select="concat('extent=', .)"/>
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
			</xsl:for-each>			
	</xsl:variable>
	
	<xsl:value-of select="concat(encode-for-uri(string-join($url, '.')), '&amp;', string-join($queryParams, '&amp;'))"/>
</xsl:function>
 -->

</xsl:stylesheet>
