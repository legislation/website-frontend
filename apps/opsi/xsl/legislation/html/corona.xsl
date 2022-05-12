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

	<xsl:variable name="staleResearch" as="xs:yearMonthDuration" select="xs:yearMonthDuration('P1M')"/>

	<xsl:template match="/">
		<html>
			<head>
				
				<!--<xsl:variable name="lastModified" as="xs:dateTime?">
					<xsl:choose>
						<xsl:when test="/atom:feed/atom:updated !='' or /atom:feed/atom:entry/atom:updated !=''">
							<xsl:value-of select="max((/atom:feed/atom:updated, /atom:feed/atom:entry/atom:updated)/xs:dateTime(.))"/>
						</xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
						
				</xsl:variable> 
				<xsl:variable name="lastModified" as="xs:dateTime" select="if (exists($lastModified)) then $lastModified else current-dateTime()" />
 				<meta name="DC.Date.Modified" content="{adjust-date-to-timezone(xs:date($lastModified), ())}" />
				<meta http-equiv="Last-Modified" content="{tso:httpDateTime($lastModified)}" />-->
				<!--<xsl:apply-templates select="/atom:feed/atom:link" mode="HTMLmetadata" />-->
			</head>		
		
			
		
			<body id="doc" class="results" dir="ltr" xml:lang="en">
				
					<div id="layout2" class="subNavPage">
					
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
						<div class="pageContent">							
							<div class="s_12 p_two">							
								<xsl:call-template name="heading"/>									
								<div id="content">
									<xsl:if test="exists(atom:feed/atom:entry)">
									
										<h2>Legislation referenced in newly published Coronavirus Legislation </h2>
								
										<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit, erat id sollicitudin sollicitudin, dolor urna gravida risus, et gravida tellus eros in risus. Proin a elit eleifend, aliquet massa non, elementum metus. Etiam ultrices dui sed tincidunt facilisis. </p>
								
										<xsl:apply-templates select="atom:feed" mode="searchresults"/>
								
									</xsl:if>
							
									<xsl:if test="exists(atom:feed/atom:entry)">

										<h2>Documents Affected by Coronavirus Legislation</h2>
										
										<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit, erat id sollicitudin sollicitudin, dolor urna gravida risus, et gravida tellus eros in risus. Proin a elit eleifend, aliquet massa non, elementum metus. Etiam ultrices dui sed tincidunt facilisis. </p>
										
										<xsl:apply-templates select="atom:feed" mode="researchedResults"/>
										
										<!-- footer paging details-->
										<div class="contentFooter">
											<div class="interface">
											<!--<xsl:apply-templates select="atom:feed" mode="links" />-->
										</div>
								</div>

								<p class="backToTop">
									<a href="#top"><xsl:value-of select="leg:TranslateText('Back to top')"/></a>
								</p>						
							
								
							</xsl:if>
							
							</div>
							</div>	
						</div>
						<!--/#content-->
						
					</div>
				
				<!--/#layout1-->
			</body>
		</html>
	</xsl:template>

	<xsl:template match="atom:feed" mode="searchresults">
		
		<div id="content" class="results">
			<!-- displaying the search results -->
			<table>
					<thead>
					<tr>
						<xsl:variable name="link" as="xs:string" select="//atom:link[@rel = 'first']/@href"/>
						<th>
							
							<xsl:element name="{'span'}" >
								<xsl:value-of select="leg:TranslateText('Title')" />
							</xsl:element>
						</th>
						<th>
							
							<xsl:variable name="title">
								<xsl:text>Year</xsl:text>
								<xsl:if test="exists(atom:entry/ukm:Number)">
									<xsl:text>s and Numbers</xsl:text>
								</xsl:if>
							</xsl:variable>
							<xsl:element name="{'span'}">
								<xsl:value-of select="leg:TranslateText($title)" />
							</xsl:element>
						</th>
						<th>
							<xsl:variable name="type" as="xs:string?" select="/atom:feed/openSearch:Query/@leg:type"/>
							<xsl:variable name="legType" as="xs:string" select="if (matches($type,'(impacts|ukia|sia|wia|niia)')) then 'Impact Assessment Stage' else 'Legislation type'"/>
							
							<xsl:element name="{'span'}">
								<xsl:value-of select="leg:TranslateText('Legislation type')"/>
							</xsl:element>
						</th>
					</tr>
					</thead>
					<tbody>
						<xsl:variable name="unresearchedEntries">
							<xsl:for-each select="atom:entry">
								<xsl:choose>
									<xsl:when test="empty(atom:updated) or  not(atom:updated castable as xs:dateTime) and ukm:Effects/@researched = 'false'">
										<!--<xsl:sequence select="."/>-->
										<!-- these are items not published on leg.gov -->
									</xsl:when>
									<xsl:when test="atom:updated castable as xs:dateTime and 
													ukm:Effects/@researched = 'false' and
													(
													xs:dateTime(atom:updated) gt (current-dateTime() -  $staleResearch)													
													)">
										<xsl:sequence select="."/>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</xsl:variable>
						<xsl:apply-templates select="$unresearchedEntries" mode="searchresults" />
				</tbody>
			</table>
		</div>
	</xsl:template>	
	
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
			else if (ends-with(atom:link/@href,'adopted')) then
				replace(substring-after(atom:link/@href,'http://www.legislation.gov.uk/'), '/adopted', '/contents/adopted')
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
					 xml:lang="cy">
						<xsl:value-of select="atom:title/xhtml:div/xhtml:span[2]" />
					</a>
				</td>
			</tr>
		</xsl:if>	
	</xsl:template>
	
	<xsl:template match="atom:feed" mode="researchedResults">
		
		<div id="content" class="results">
			<!-- displaying the search results -->
			<table>
					<thead>
					<tr>
						<xsl:variable name="link" as="xs:string" select="//atom:link[@rel = 'first']/@href"/>
						<th>
							
							<xsl:element name="{'span'}" >
								<xsl:value-of select="leg:TranslateText('Title')" />
							</xsl:element>
						</th>
						<th>
							
							<xsl:variable name="title">
								<xsl:text>Year</xsl:text>
								<xsl:if test="exists(atom:entry/ukm:Number)">
									<xsl:text>s and Numbers</xsl:text>
								</xsl:if>
							</xsl:variable>
							<xsl:element name="{'span'}">
								<xsl:value-of select="leg:TranslateText($title)" />
							</xsl:element>
						</th>
						<th>
							<xsl:variable name="type" as="xs:string?" select="/atom:feed/openSearch:Query/@leg:type"/>
							<xsl:variable name="legType" as="xs:string" select="if (matches($type,'(impacts|ukia|sia|wia|niia)')) then 'Impact Assessment Stage' else 'Legislation type'"/>
							
							<xsl:element name="{'span'}">
								<xsl:value-of select="leg:TranslateText('Legislation type')"/>
							</xsl:element>
						</th>
					</tr>
					</thead>
					<tbody>
						
						<xsl:variable name="researchedEntries">
							<xsl:for-each select="atom:entry">
								<xsl:choose>
									<xsl:when test="empty(atom:updated) or  not(atom:updated castable as xs:dateTime)">
										
									</xsl:when>
									<xsl:when test="ukm:Effects/@researched = 'true'">
										<xsl:sequence select="."/>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</xsl:variable>
						<xsl:apply-templates select="$researchedEntries" mode="researchedResults" />
						
						
					
				</tbody>
			</table>
		</div>
	</xsl:template>	
	
	<xsl:template match="atom:entry" mode="researchedResults">
		
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
			else if (ends-with(atom:link/@href,'adopted')) then
				replace(substring-after(atom:link/@href,'http://www.legislation.gov.uk/'), '/adopted', '/contents/adopted')
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
					 xml:lang="cy">
						<xsl:value-of select="atom:title/xhtml:div/xhtml:span[2]" />
					</a>
				</td>
			</tr>
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
	
	<xsl:template name="heading">
		<h1 id="pageTitle">Coronavirus Legislation - Changes </h1>
	</xsl:template>
	
	

</xsl:stylesheet>
