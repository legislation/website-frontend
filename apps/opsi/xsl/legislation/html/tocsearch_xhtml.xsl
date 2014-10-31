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
	<xsl:import href="searchcommon_xhtml.xsl" />
	
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>
	<xsl:variable name="link" as="xs:string" select="leg:GetLink(//atom:link[@rel = 'first']/@href)"/>
	
	
	<xsl:template match="atom:feed" mode="searchfacets">
		<xsl:apply-templates select="leg:facets" mode="searchfacets"/>
	</xsl:template>
	
	<xsl:template match="leg:facets" mode="searchfacets">
		<xsl:variable name="type" as="xs:string?" select="/atom:feed/openSearch:Query/@leg:type"/>
		<xsl:variable name="legType" as="xs:string" select="leg:TranslateText(if (matches($type,'(impacts|ukia|sia|wia|niia)')) then 'Impact Assessments' else 'Legislation')"/>
		<div id="tools">
			<h2 class="accessibleText">Narrow results by:</h2>
			<xsl:if test="count(leg:facetTypes/leg:facetType)>0">
				<div class="section">
					<div class="title">
						<h3><xsl:value-of select="$legType"/> <xsl:value-of select="leg:TranslateText('By Type')"/></h3>
					</div>
					<div class="content">
						<ul>
							<xsl:choose>
								<xsl:when test="contains($link, 'type=*')">
									<xsl:for-each select="leg:facetTypes/leg:facetType">
										<li class="legType">
											<a href="{replace($link, 'type=\*', concat('type=', tso:GetUriPrefixFromType(@type,())))}"><xsl:value-of select="tso:GetTitleFromType(@type,())"/> (<xsl:value-of select="@value"/>)</a>
										</li>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<li class="returnLink">
										<a href="{replace($link, concat('type=',  tso:GetUriPrefixFromType(leg:facetTypes/leg:facetType[1]/@type,()) ),  'type=*')}">
											<span class="accessibleText"><xsl:value-of select="leg:TranslateText('Browse by')"/> </span><xsl:value-of select="leg:TranslateText('Any type')"/>
										</a>
									</li>
									<li class="legType">
										<span class="userFunctionalElement disabled">
											<xsl:value-of select="tso:GetTitleFromType(leg:facetTypes/leg:facetType[1]/@type,())"/> (<xsl:value-of select="leg:facetTypes/leg:facetType[1]/@value"/>)
										</span>
									</li>
								</xsl:otherwise>
							</xsl:choose>
						</ul>								
					</div>
				</div>
			</xsl:if>
			<xsl:if test="count(leg:facetYears/leg:facetYear)>0">
				<div id="year" class="section">
					<div class="title">
						<h3><xsl:value-of select="leg:TranslateText($legType)"/><xsl:value-of select="leg:TranslateText('By Year')"/>|</h3>
					</div>
					<div class="content">
						<xsl:choose>
							<xsl:when test="contains($link, 'year=')">
								<ul>
									<li class="returnLink">
										<a href="{replace($link, '&amp;year=\d+','' )}">
											<span class="accessibleText"><xsl:value-of select="leg:TranslateText('Browse by')"/> </span>
											<xsl:value-of select="leg:TranslateText('Any year')"/> 
										</a>
									</li>
									<li>
										<span class="userFunctionalElement disabled">
											<xsl:value-of select="leg:facetYears/leg:facetYear[1]/@year"/> (<xsl:value-of select="leg:facetYears/leg:facetYear[1]/@value"/>)
										</span>
									</li>
								</ul>										
							</xsl:when>
							<xsl:otherwise>
									<xsl:variable name="facetYears" select="leg:facetYears"/>
									<xsl:variable name="total" select="count(leg:facetYears/leg:facetYear)"/>
									<xsl:variable name="mid" select="xs:integer(ceiling(count(leg:facetYears/leg:facetYear) div 2))"/>									
									<ul>
										<xsl:for-each select="1 to $mid">							
											<xsl:variable name="current" select="."/>
											<!--<xsl:for-each select="leg:facetYears/leg:facetYear">-->
											<li>
												<a href="{if (contains($link, 'year=')) then $link else concat($link,'&amp;year=', $facetYears/leg:facetYear[$current]/@year) }"><xsl:value-of select="$facetYears/leg:facetYear[$current]/@year"/> (<xsl:value-of select="$facetYears/leg:facetYear[$current]/@value"/>)</a>
											</li>
										</xsl:for-each>
									</ul>
									<ul>
										<xsl:for-each select="($mid+1) to $total">							
											<xsl:variable name="current" select="."/>
											<!--<xsl:for-each select="leg:facetYears/leg:facetYear">-->
											<li>
												<a href="{if (contains($link, 'year=')) then $link else concat($link,'&amp;year=',$facetYears/leg:facetYear[$current]/@year) }"><xsl:value-of select="$facetYears/leg:facetYear[$current]/@year"/> (<xsl:value-of select="$facetYears/leg:facetYear[$current]/@value"/>)</a>
											</li>
										</xsl:for-each>
									</ul>
									
							</xsl:otherwise> 
						</xsl:choose>
						
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>	

	<xsl:template name="heading">
		<h1 id="pageTitle"><xsl:value-of select="leg:TranslateText('Search Results')"/></h1>		
	</xsl:template>	

</xsl:stylesheet>
