<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

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
	
	<xsl:variable name="isWelshChronTable"  as="xs:boolean" select="matches($g_strUri,'/cy/changes/chron-tables')" />

	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

	<xsl:function name="leg:IsHome" as="xs:boolean">
		<xsl:sequence select="$paramsDoc/request/request-path = ('/cy','/cy/','/en','/en/','/')"/>
		<!--<xsl:choose>-->
		<!--<xsl:when test="$TranslateLangPrefix ='/cy'">-->
		<!---->
		<!--</xsl:when>-->
		<!--<xsl:when test="$TranslateLangPrefix='/en'">-->
		<!--<xsl:sequence select="$paramsDoc/request/request-path ='/en'"/>-->
		<!--</xsl:when>-->
		<!--<xsl:otherwise>-->
		<!--<xsl:sequence select="$paramsDoc/request/request-path ='/' "/>-->
		<!--</xsl:otherwise>-->
		<!--</xsl:choose>	-->
	</xsl:function>

	<xsl:function name="leg:IsTOC" as="xs:boolean">
		<xsl:sequence select="$paramsDoc/parameters/view ='contents' " />
	</xsl:function>

	<xsl:function name="leg:IsContent" as="xs:boolean">
		<xsl:sequence select="$paramsDoc/parameters/section !='' or $paramsDoc/parameters/view = 'introduction'" />
	</xsl:function>

	<xsl:variable name="serverName" as="xs:string?" select="'$SERVER'" />
	<xsl:variable name="serverPrefix" as="xs:string" select="if (exists($serverName)) then concat('https://', $serverName) else ''" />

	<xsl:template match="/*">
		<html xmlns="http://www.w3.org/1999/xhtml" xmlns:dct="http://purl.org/dc/terms/" lang="en" xml:lang="en">
			<xsl:apply-templates select="@*"/>
			<xsl:text>&#10;</xsl:text>
			<head>
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=iso-8859-1" />
				<xsl:choose>
					<xsl:when test="not(xhtml:head/xhtml:title)">
						<title>Legislation.gov.uk</title>
					</xsl:when>
					<xsl:otherwise>
						<title><xsl:value-of select="leg:TranslateText(normalize-space(string-join(xhtml:head/xhtml:title/text(),' ')))"/></title>
					</xsl:otherwise>
				</xsl:choose>

				<link rel="icon" href="/favicon.ico" />
				<!-- <link rel="stylesheet" href="/styles/cookiebar/cookiebar.min.css" type="text/css" /> -->
				<link rel="stylesheet" href="/styles/screen.css" type="text/css" />
				<link rel="stylesheet" href="/styles/survey/survey.css" type="text/css" />
				<xsl:comment><![CDATA[[if lte IE 6]><link rel="stylesheet" href="/styles/IE/ie6chromeAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<xsl:comment><![CDATA[[if lte IE 7]><link rel="stylesheet" href="/styles/IE/ie7chromeAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<xsl:if test="not(contains(xhtml:body/@class, 'removeScripting'))">
					<script type="text/javascript" src="/scripts/jquery-1.6.2.js"></script>
					<script type="text/javascript" src="/scripts/CentralConfig.js"></script>
					<!-- <script type="text/javascript" src="/scripts/sitestat.js"></script> -->
					<script type="text/javascript" src="/scripts/survey/survey.js"></script>
				</xsl:if>
				<script type="text/javascript" src="/scripts/chrome.js"></script>
				<xsl:choose>
					<xsl:when test="leg:IsHome()">
						<script type="text/javascript" src="/scripts/homepageChrome.js"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- <script type="text/javascript" src="/scripts/jquery.cookie.js"></script> -->
					</xsl:otherwise>
				</xsl:choose>
				<!-- Add to homepage icons add -->
				<link rel="apple-touch-icon" href="/images/chrome/apple-touch-icons/apple-touch-icon.png" />
				<link rel="apple-touch-icon" sizes="57x57" href="/images/chrome/apple-touch-icons/apple-touch-icon-57x57.png" />
				<link rel="apple-touch-icon" sizes="72x72" href="/images/chrome/apple-touch-icons/apple-touch-icon-72x72.png" />
				<link rel="apple-touch-icon" sizes="76x76" href="/images/chrome/apple-touch-icons/apple-touch-icon-76x76.png" />
				<link rel="apple-touch-icon" sizes="114x114" href="/images/chrome/apple-touch-icons/apple-touch-icon-114x114.png" />
				<link rel="apple-touch-icon" sizes="120x120" href="/images/chrome/apple-touch-icons/apple-touch-icon-120x120.png" />
				<link rel="apple-touch-icon" sizes="144x144" href="/images/chrome/apple-touch-icons/apple-touch-icon-144x144.png" />
				<link rel="apple-touch-icon" sizes="152x152" href="/images/chrome/apple-touch-icons/apple-touch-icon-152x152.png" />


				<xsl:copy-of select="xhtml:head/node() except (xhtml:head/xhtml:meta[@http-equiv], xhtml:head/xhtml)" copy-namespaces="no" />
				<xsl:copy-of select="xhtml:head/xhtml:meta[lower-case(@http-equiv) = 'refresh']" copy-namespaces="no" />
				<link rel="stylesheet" href="/styles/print.css" type="text/css" media="print" />
				<script type="text/javascript" src="/scripts/jquery-cookie-directive/jquery.cookie.js"></script>
				<script type="text/javascript" src="/scripts/jquery-cookie-directive/jquery-cookie-functions.js"></script>
				<script type="text/javascript" src="/scripts/cookie-directive.js"></script>
				<xsl:call-template name="GTMHead"/>
			</head>
			<body>
				<xsl:copy-of select="xhtml:body/@*"/>
				<xsl:if test="/error">
					<xsl:attribute name="id" select="'error'" />
				</xsl:if>
				<xsl:call-template name="GTMBody"/>
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
							<li><a href="#content"><xsl:value-of select="leg:TranslateText('Skip to main content')"/></a></li>
							<li><a href="#plainViewNav"><xsl:value-of select="leg:TranslateText('Skip to navigation')"/></a></li>
						</xsl:when>
						<xsl:otherwise>
							<li><a href="#pageTitle"><xsl:value-of select="leg:TranslateText('Skip to main content')"/></a></li>
							<li><a href="#primaryNav"><xsl:value-of select="leg:TranslateText('Skip to navigation')"/></a></li>
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
						<xsl:when test="$isWelshChronTable">
							<xsl:apply-templates select="xhtml:body/node()" mode="isWelshChronTable"/>							
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
				<xsl:if test="not(leg:IsHome())">
					<script type="text/javascript" src="/scripts/libs/gsap/TweenMax.min.js"></script>
					<script type="text/javascript" src="/scripts/libs/gsap/ScrollToPlugin.min.js"></script>
					<script type="text/javascript" src="/scripts/libs/scrollmagic/ScrollMagic.min.js"></script>
					<!-- <script type="text/javascript" src="/scripts/libs/scrollmagic/debug.addIndicators.min.js"></script> -->
					<script type="text/javascript" src="/scripts/SidebarScroll.js"></script>
					<script type="text/javascript" src="/scripts/CookieBarScroll.js"></script>
				</xsl:if>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="@href[starts-with(., 'http://www.legislation.gov.uk/') and not(ends-with(.,'htm')) and not(ends-with(.,'feed')) and not(ends-with(.,'pdf')) and not(contains(., '/images/'))]" priority="100">
		<xsl:choose>
			<xsl:when test="$TranslateLangPrefix !=''">
				<xsl:variable name="uriAfterDomain" as="xs:string" select="substring-after(.,'http://www.legislation.gov.uk')"/>
				<xsl:attribute name="href">
					<!-- do not add wrapper if
					the URI already has an english or welsh part of the URI
					- this is done carefully so that if we ever had a document type like 'ensi' it would not cause an issue
					-->
					<xsl:if test="not(contains(.,'/id'))">
						<xsl:if test="not(starts-with($uriAfterDomain,'/en/') or starts-with($uriAfterDomain,'/cy/') or $uriAfterDomain='/en' or $uriAfterDomain='/cy')">
							<xsl:value-of select="$TranslateLangPrefix"/>
						</xsl:if>
					</xsl:if>
					<xsl:value-of select="substring-after(., 'http://www.legislation.gov.uk')"/>
					<xsl:if test="string-length($paramsDoc/request/query-string) > 0 and not(contains(., '?'))">?<xsl:value-of select="$paramsDoc/request/query-string"/></xsl:if>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- HA083023 FIX /admin/log table uri's - resolving to the correct URL depending on server -->
	<xsl:template match="@href[starts-with(.,'http://www.legislation.gov.uk/') and $paramsDoc/request/request-path[.='/admin/log'] and ancestor::*[name()='tr' and contains(@class,'publish')]]" priority="50">
		<xsl:attribute name="href">
			<xsl:variable name="prefix">
				<!-- server prefix check the request server-name or the $servername capture only staging, test or localhost -->
				<xsl:choose>
					<xsl:when test="matches($paramsDoc/request/server-name,'.*(staging|test|localhost).*')">
						<xsl:value-of select="replace($paramsDoc/request/server-name,'.*(staging|test|localhost).*','$1')"/>
					</xsl:when>
					<xsl:when test="matches(lower-case($serverName),'.*(staging|test|localhost).*')">
						<xsl:value-of select="replace(lower-case($serverName),'.*(staging|test|localhost).*','$1')"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- no need to change the server prefix as $2 = 'www'  -->
						<xsl:value-of select="'$2'" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- set the replace regex picture $1$2$3$4 is no change-->
			<xsl:variable name="host-regex">
				<xsl:value-of select="concat('$1', $prefix ,if($prefix='localhost') then '$4' else '$3$4')"/>
			</xsl:variable>
			<xsl:attribute name="href">
				<xsl:value-of select="replace(., '(https?://)(www\.admin|www|admin)?(\.[^/]+)(.*)',$host-regex)"/>
			</xsl:attribute>
		</xsl:attribute>
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
						<xsl:when test="status-code = 503"><xsl:value-of select="leg:TranslateText('Temporarily Unavailable')"/></xsl:when>
						<xsl:when test="status-code = 404"><xsl:value-of select="leg:TranslateText('Page Not Found')"/></xsl:when>
						<xsl:when test="status-code = 300"><xsl:value-of select="leg:TranslateText('Multiple Choices')"/></xsl:when>
						<xsl:when test="status-code = 200"><xsl:value-of select="leg:TranslateText('Found References')"/></xsl:when>
						<xsl:when test="status-code = 201"><xsl:value-of select="leg:TranslateText('Created')"/></xsl:when>
						<xsl:when test="status-code = 202"><xsl:value-of select="leg:TranslateText('Accepted')"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="leg:TranslateText('Internal Error')"/></xsl:otherwise>
					</xsl:choose>
				</h1>
			</div>
			<div id="content">
				<xsl:choose>
					<xsl:when test="status-code = 404">
						<p class="first"><xsl:value-of select="leg:TranslateText('Error404_1')"/>.</p>

						<p><xsl:value-of select="leg:TranslateText('Error404_2')"/>:
							<ul>
								<li><xsl:value-of select="leg:TranslateText('Error404_3')"/></li>
								<li><xsl:value-of select="leg:TranslateText('Error404_4')"/></li>
							</ul>
						</p>

						<p><xsl:value-of select="leg:TranslateText('Error404_5')"/></p>
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
							<p><xsl:value-of select="leg:TranslateText(if (count(link) > 2) then 'Error300_1' else 'Error300_2')"/>:</p>
						</xsl:when>
						<xsl:when test="status-code = 200">
							<p><xsl:value-of select="leg:TranslateText('Error200')"/>:</p>
						</xsl:when>
						<xsl:otherwise>
							<p><xsl:value-of select="leg:TranslateText('Error_Alt')"/>:</p>
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

	<xsl:template match="@href[starts-with(.,'http://www.legislation.gov.uk/') and not(ends-with(.,'htm')) and not(ends-with(.,'feed')) ]">
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

	<xsl:template match="*:h1|*:h2" mode="isWelshChronTable">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:for-each select="node()">
				<xsl:choose>
					<xsl:when test="name()=''">
						<xsl:choose>
							<xsl:when test="matches(normalize-space(.),'^Part.*')">
								<xsl:value-of select="replace(normalize-space(.),'^Part(.+)','Rhan$1')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="leg:TranslateText(normalize-space(.))" />
							</xsl:otherwise>					
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="."  mode="isWelshChronTable"/>
					</xsl:otherwise>
				</xsl:choose>	
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:function name="leg:recurTranslate">
		<xsl:param name="text"/>
		<xsl:param name="tokens"/>
	
		<xsl:if test="count($tokens) != 0">
			<xsl:choose>
				<xsl:when test="contains($text, $tokens[1])">
					<xsl:value-of 
						select="leg:recurTranslate(
							replace($text,$tokens[1],leg:TranslateText($tokens[1])),
							remove($tokens,1)
						)"
					/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="leg:recurTranslate($text,remove($tokens,1))"/>
				</xsl:otherwise>			
			</xsl:choose>
		</xsl:if>
		<xsl:if test="count($tokens) = 0">
			<xsl:value-of select="$text"/>
		</xsl:if>
	</xsl:function>

	<xsl:template match="*:p|*:em|*:span" mode="isWelshChronTable">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:for-each select="node()">
				<xsl:choose>
					<xsl:when test="name()='' and parent::*[local-name()='em']">
						<xsl:value-of select="leg:TranslateText(normalize-space(.))" />
					</xsl:when>
					<xsl:when test="name()='' and parent::*[local-name()='span' and not(@class='actNumMedium')]">
						<xsl:variable name="part" select="tokenize(.,'-')[1]"/>
						<xsl:variable name="tpart">
							<xsl:choose>
							<xsl:when test="matches($part,'(.*)((r\.)([^-]*))$')">
								<xsl:value-of select="if(matches($part,'(.+)((r\.)([^-]*))$')) then replace($part,'(.+)((r\.)([^-]*))$','$1') else ()"/>
								<xsl:value-of select="leg:TranslateText(replace($part,'^(.*)((r\.)([^-]*))$','$3'))"/>
								<xsl:variable name="rest" select="replace($part,'^(.*)((r\.)([^-]*))$','$4')"/>
								<xsl:variable name="endPart" select="replace($rest,'(.+)(\.|\.\s)$','$2')"/>
								<xsl:variable name="startPart" select="replace(normalize-space($rest),'^(.+)(\.|\.\s)$','$1')" />
								<xsl:value-of select="concat(leg:TranslateText($startPart),if($endPart!=$rest) then $endPart else ())"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="endPart" select="replace($part,'^(.+)(\.|\.\s)$','$2')"/>
								<xsl:variable name="startPart" select="replace($part,'^(.+)(\.|\.\s)$','$1')" />
								<xsl:value-of select="concat(leg:TranslateText($startPart),if($endPart!=$part) then $endPart else ())"/>
							</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="leg:recurTranslate(concat($tpart, substring-after(.,$part)),('see:','and superseded',' r.',' subst.-','excl.','exp.in pt'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="."  mode="isWelshChronTable"/>
					</xsl:otherwise>
				</xsl:choose>	
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<!-- Simply copy everything that's not matched -->
	<xsl:template match="@*|node()" mode="isWelshChronTable">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@*|node()" mode="isWelshChronTable"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="header">
		<!-- Added to switch site between welsh and english version
		<div>
			<span>
				<p class="changeLang">
					<xsl:choose>
						<xsl:when test="starts-with($paramsDoc/request/request-path, '/en')">
							<a href="{leg:replace-first($paramsDoc/request/request-path,'en','cy')}"><xsl:value-of select="leg:TranslateTextToLang('Language_Switch_CY','cy')"/></a>
						</xsl:when>
						<xsl:when test="starts-with($paramsDoc/request/request-path, '/cy')">
							<xsl:choose>
								<xsl:when test="$paramsDoc/request/request-path ='/cy'">
									<a href="{leg:replace-first($paramsDoc/request/request-path,'/cy','/')}"><xsl:value-of select="leg:TranslateTextToLang('Language_Switch_EN','en')"/></a>
								</xsl:when>
								<xsl:otherwise>
									<a href="{leg:replace-first($paramsDoc/request/request-path,'/cy','')}"><xsl:value-of select="leg:TranslateTextToLang('Language_Switch_EN','en')"/></a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$paramsDoc/request/request-path ='/'">
									<a href="/cy"><xsl:value-of select="leg:TranslateTextToLang('Language_Switch_CY','cy')"/></a>
								</xsl:when>
								<xsl:otherwise>
									<a href="{concat('/cy',$paramsDoc/request/request-path)}"><xsl:value-of select="leg:TranslateTextToLang('Language_Switch_CY','cy')"/></a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</p>
			</span>
		</div> -->

		<div id="header">
			<xsl:element name="{if (leg:IsHome()) then 'h1' else 'h2'}">
				<xsl:choose>
					<xsl:when test="$TranslateLang ='cy'">
						<a href="/cy/">legislation.gov.uk<span class="welsh"/></a>
					</xsl:when>
					<xsl:otherwise>
						<a href="/">legislation.gov.uk<span class="english"/></a>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<span class="{if ($TranslateLang ='cy') then 'natArchWelsh' else 'natArch'}">
				<a href="http://www.nationalarchives.gov.uk"><span></span>
				</a>
			</span>

			<ul id="secondaryNav">
				<xsl:choose>
					<xsl:when test="starts-with($paramsDoc/request/request-path, '/cy')">
						<li>
							<a class="langaugeSwitch">
								<xsl:attribute name="href">
									<xsl:choose>
										<xsl:when test="$paramsDoc/request/request-path ='/cy'">
											<xsl:value-of select="leg:replace-first($paramsDoc/request/request-path,'/cy','/')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="leg:replace-first($paramsDoc/request/request-path,'/cy','')"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:value-of select="leg:TranslateTextToLang('English','en')"/>
							</a>
						</li>
					</xsl:when>
					<xsl:otherwise>
						<li>
							<a class="langaugeSwitch">
								<xsl:attribute name="href">
									<xsl:choose>
										<xsl:when test="$paramsDoc/request/request-path ='/en'">
											<xsl:value-of select="leg:replace-first($paramsDoc/request/request-path,'en','cy')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat('/cy',$paramsDoc/request/request-path)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:value-of select="leg:TranslateTextToLang('Welsh','cy')"/>
							</a>
						</li>
					</xsl:otherwise>
				</xsl:choose>

				<!--<li>-->
				<!--<xsl:choose>-->
				<!--<xsl:when test="starts-with($paramsDoc/request/request-path, '/en')">-->
				<!--<a href="{leg:replace-first($paramsDoc/request/request-path,'en','cy')}" class="langaugeSwitch"><xsl:value-of select="leg:TranslateTextToLang('Welsh','cy')"/></a>-->
				<!--</xsl:when>-->
				<!--<xsl:when test="starts-with($paramsDoc/request/request-path, '/cy')">-->
				<!--<xsl:choose>-->
				<!--<xsl:when test="$paramsDoc/request/request-path ='/cy'">-->
				<!--<a href="{leg:replace-first($paramsDoc/request/request-path,'/cy','/')}" class="langaugeSwitch"><xsl:value-of select="leg:TranslateTextToLang('English','en')"/></a>-->
				<!--</xsl:when>-->
				<!--<xsl:otherwise>-->
				<!--<a href="{leg:replace-first($paramsDoc/request/request-path,'/cy','')}" class="langaugeSwitch"><xsl:value-of select="leg:TranslateTextToLang('English','en')"/></a>-->
				<!--</xsl:otherwise>-->
				<!--</xsl:choose>-->
				<!--</xsl:when>-->
				<!--<xsl:otherwise>-->
				<!--<xsl:choose>-->
				<!--<xsl:when test="$paramsDoc/request/request-path ='/'">-->
				<!--<a href="/cy" class="langaugeSwitch"><xsl:value-of select="leg:TranslateTextToLang('Welsh','cy')"/></a>-->
				<!--</xsl:when>-->
				<!--<xsl:otherwise>-->
				<!--<a href="{concat('/cy',$paramsDoc/request/request-path)}" class="langaugeSwitch"><xsl:value-of select="leg:TranslateTextToLang('Welsh','cy')"/></a>-->
				<!--</xsl:otherwise>-->
				<!--</xsl:choose>-->
				<!--</xsl:otherwise>-->
				<!--</xsl:choose>-->
				<!--</li>-->
			</ul>
		</div>


		<div id="primaryNav">
			<div class="navLayout">
				<ul>
					<xsl:if test="$TranslateLang='cy' ">
						<xsl:attribute name="class">cy</xsl:attribute>
					</xsl:if>
					<li class="link1">
						<a href="{if ($TranslateLangPrefix ='/cy' or $TranslateLangPrefix='/en') then concat($TranslateLangPrefix,'/') else '/'}">
							<span>
								<xsl:if test="$TranslateLang='cy' ">
									<xsl:attribute name="class">cy</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Home')"/>
							</span>
						</a>
					</li>
					<li class="link2">
						<a href="{$TranslateLangPrefix}/understanding-legislation">
							<span>
								<xsl:if test="$TranslateLang='cy' ">
									<xsl:attribute name="class">cy</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Understanding Legislation')"/>
							</span>
						</a>
					</li>
					<!-- Hide for MVP1 -->
					<xsl:if test="not($hideEUdata)">
					<li class="link3">
						<a href="{$TranslateLangPrefix}/eu-legislation-and-uk-law">
							<span>
								<xsl:if test="$TranslateLang='cy' ">
									<xsl:attribute name="class">cy</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('EU Legislation and UK Law')"/>
							</span>
						</a>
					</li>
					</xsl:if>
					<li class="link4">
						<a href="{$TranslateLangPrefix}/browse">
							<span>
								<xsl:if test="$TranslateLang='cy' ">
									<xsl:attribute name="class">cy</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Browse Legislation')"/>
							</span>
						</a>
					</li>
					<!--<li class="link4">-->
					<!--<a href="{$TranslateLangPrefix}/new">-->
					<!--<span>-->
					<!--<xsl:if test="$TranslateLang='cy' ">-->
					<!--<xsl:attribute name="class">cy</xsl:attribute>-->
					<!--</xsl:if>-->
					<!--<xsl:value-of select="leg:TranslateText('New Legislation')"/>-->
					<!--</span>-->
					<!--</a>-->
					<!--</li>-->
					<li class="link5">
						<a href="{$TranslateLangPrefix}/changes">
							<span>
								<xsl:if test="$TranslateLang='cy' ">
									<xsl:attribute name="class">cy</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="leg:TranslateText('Changes To Legislation')"/>
							</span>
						</a>
					</li>
					<li id="quickSearch" class="{if ($TranslateLang = 'cy') then 'cy' else 'en'}"><a  href="#contentSearch"><span><xsl:value-of select="leg:TranslateText('Search Legislation')"/></span></a></li>
				</ul>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="footer">
		<div id="footerNav">
			<ul>
				<li><a href="{$TranslateLangPrefix}/help"><xsl:value-of select="leg:TranslateText('Help')"/></a></li>
				<li><a href="{$TranslateLangPrefix}/aboutus"><xsl:value-of select="leg:TranslateText('About Us')"/></a></li>
				<li><a href="{$TranslateLangPrefix}/sitemap"><xsl:value-of select="leg:TranslateText('Site Map')"/></a></li>
				<li><a href="{$TranslateLangPrefix}/accessibility"><xsl:value-of select="leg:TranslateText('Accessibility')"/></a></li>
				<li><a href="{$TranslateLangPrefix}/contactus">	<xsl:value-of select="leg:TranslateText('Contact Us')"/></a></li>
				<li><a href="{$TranslateLangPrefix}/privacynotice"><xsl:value-of select="leg:TranslateText('Privacy Notice')"/></a></li>
				<li><a href="{$TranslateLangPrefix}/cookiepolicy" id="cookies-content-link"><xsl:value-of select="leg:TranslateText('Cookies')"/></a></li>
			</ul>
		</div>
		<div id="footer">
			<div>
				<p class="copyrightstatement">
					<img src="/images/chrome/ogl-symbol.gif" alt="OGL logo"/>
					<span xml:lang="{substring-after($TranslateLangPrefix,'/')}"><xsl:copy-of select="leg:TranslateNode('Copyright_Statement')"/></span>
				</p>
				<span class="copyright">&#xa9; <span rel="dct:rights" resource="http://reference.data.gov.uk/def/copyright/crown-copyright"><xsl:value-of select="leg:TranslateText('Crown copyright')"/></span></span>
			</div>
		</div>



	</xsl:template>
	<xsl:function name="leg:replace-first" as="xs:string" >
		<xsl:param name="arg" as="xs:string?"/>
		<xsl:param name="pattern" as="xs:string"/>
		<xsl:param name="replacement" as="xs:string"/>
		<xsl:sequence select="
			replace($arg, concat('(^.*?)', $pattern),
			concat('$1',$replacement))
			"/>
	</xsl:function>
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
	<xsl:template name="GTMHead">
		<xsl:comment>Google Tag Manager</xsl:comment>
		<script type="text/javascript">
			(function (w, d, s, l, i) {
				w[l] = w[l] || [];
				w[l].push({'gtm.start': new Date().getTime(), event: 'gtm.js'});
				var and = '&amp;';
				and = and.charAt(0);
				var f = d.getElementsByTagName(s)[0], j = d.createElement(s),
						dl = l != 'dataLayer' ? (and + 'l=' + l) : '';
				j.async = true;
				j.src = 'https://www.googletagmanager.com/gtm.js?id=' + i + dl;
				f.parentNode.insertBefore(j, f);
			})(window, document, 'script', 'dataLayer', 'GTM-TWB7339');
		</script>
		<xsl:comment>End Google Tag Manager</xsl:comment>
	</xsl:template>
	<xsl:template name="GTMBody">
		<xsl:comment>Google Tag Manager (noscript)</xsl:comment>
		<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-TWB7339"
						  height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
		<xsl:comment>End Google Tag Manager (noscript)</xsl:comment>
	</xsl:template>

</xsl:stylesheet>
