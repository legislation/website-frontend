<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
xmlns:dc="http://purl.org/dc/elements/1.1/" 
xmlns:atom="http://www.w3.org/2005/Atom"
xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/"
exclude-result-prefixes="xs leg ukm tso dc atom xhtml"
version="2.0">

<xsl:import href="common/utils.xsl" />

<xsl:template match="atom:feed">
	<xsl:variable name="self" as="xs:string"
		select="substring-after(atom:link[@rel = 'self']/@href, 'http://www.legislation.gov.uk')" />
	<html>
		<head>
			<link href="{$self}" rel="alternate" type="application/atom+xml" title="Legislation Search Results" />
		</head>
		<body>
			<h1>Search Results</h1>
			<xsl:apply-templates select="." mode="totals" />
			<xsl:apply-templates select="." mode="links" />
			<xsl:apply-templates select="* except atom:link" />
		</body>
	</html>
</xsl:template>

<xsl:template match="atom:feed" mode="totals">
	<xsl:variable name="start" as="xs:integer"
		select="xs:integer((leg:page * leg:resultsCount) - (leg:resultsCount - 1))" />
	<xsl:variable name="end" as="xs:integer"
		select="xs:integer($start + min((count(atom:entry), leg:resultsCount)) - 1)" />
	<p>
		<xsl:text>Showing results </xsl:text>
		<xsl:value-of select="$start" />
		<xsl:text> - </xsl:text>
		<xsl:value-of select="$end" />
		<xsl:if test="leg:totalResults or leg:morePages &lt; 10">
			<xsl:text> of </xsl:text>
			<xsl:choose>
				<xsl:when test="leg:totalResults">
					<xsl:value-of select="leg:totalResults" />
				</xsl:when>
				<xsl:when test="leg:morePages = 0">
					<xsl:value-of select="((leg:page - 1) * leg:resultsCount) + count(atom:entry)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>about </xsl:text>
					<xsl:value-of select="round-half-to-even((leg:page + leg:morePages) * leg:resultsCount, -1)" />
					<xsl:value-of select="openSearch:totalResults"></xsl:value-of>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</p>
</xsl:template>

<xsl:template match="atom:feed" mode="links">
	<xsl:variable name="thisPage" as="xs:integer" select="leg:page" />
	<xsl:variable name="lastKnownPage" as="xs:integer"
		select="xs:integer($thisPage + leg:morePages)" />
	<xsl:variable name="firstPage" as="xs:integer"
		select="xs:integer(max((min(($lastKnownPage - 9, $thisPage - 5)), 1)))" />
	<xsl:variable name="lastPage" as="xs:integer"
		select="min(($lastKnownPage, $firstPage + 9))" />
	<xsl:variable name="link" as="xs:string"
		select="replace(atom:link[@rel = 'first']/@href, '/atom.feed', '')" />
	<p class="pageLinks">
		<xsl:if test="$thisPage > 1 or leg:morePages > 0">
			<xsl:apply-templates select="atom:link[@rel = 'first']" />
			<xsl:if test="$firstPage > 1">
				<a class="pageLink" href="{replace($link, 'page=1', concat('page=', max(($thisPage - 10, 1))))}">PREVIOUS TEN PAGES</a>
			</xsl:if>
			<xsl:apply-templates select="atom:link[@rel = 'prev']" />
			<xsl:for-each select="$firstPage to $lastPage">
				<xsl:choose>
					<xsl:when test=". = $thisPage">
						<span class="selected"><xsl:value-of select="." /></span>
					</xsl:when>
					<xsl:otherwise>
						<a href="{replace($link, 'page=1', concat('page=', .))}">
							<xsl:choose>
								<xsl:when test=". = $thisPage - 1">
									<xsl:attribute name="rel">prev</xsl:attribute>
								</xsl:when>
								<xsl:when test=". = $thisPage + 1">
									<xsl:attribute name="rel">next</xsl:attribute>
								</xsl:when>
							</xsl:choose>
							<xsl:value-of select="." />
						</a>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="position() != last()"> | </xsl:if>
			</xsl:for-each>
			<xsl:apply-templates select="atom:link[@rel = 'next']" />
			<xsl:if test="leg:morePages > 5">
				<a class="pageLink" href="{replace($link, 'page=1', concat('page=', min(($lastPage + 6, $lastKnownPage))))}">NEXT TEN PAGES</a>
			</xsl:if>
		</xsl:if>
	</p>
</xsl:template>

<xsl:template match="atom:id | atom:updated | atom:link | atom:content | leg:morePages | leg:totalResults | leg:resultsCount | leg:page" />

<xsl:template match="atom:entry">
	<xsl:variable name="uri" as="xs:string" select="atom:link/@href" />
	<div class="searchEntry">
		<xsl:apply-templates select="atom:title, atom:summary">
			<xsl:with-param name="uri" select="$uri" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:for-each-group select="leg:*" group-by="@fragment">
			<xsl:variable name="current" as="element()*"
				select="current-group()[@end-date = '' and @status != 'Prospective']" />
			<xsl:choose>
				<xsl:when test="exists($current)">
					<xsl:call-template name="group-items">
						<xsl:with-param name="items" select="$current" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="repealed" as="element()*"
						select="current-group()[@end-date != '' and @status != 'Prospective']" />
					<xsl:choose>
						<xsl:when test="exists($repealed)">
							<xsl:variable name="latest" as="xs:date"
								select="max($repealed/@end-date/xs:date(.))" />
							<xsl:call-template name="group-items">
								<xsl:with-param name="items" select="$repealed[@end-date = $latest]" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="prospective" as="element()*"
								select="current-group()[@status = 'Prospective' and @end-date = '']" />
							<xsl:choose>
								<xsl:when test="exists($prospective)">
									<xsl:call-template name="group-items">
										<xsl:with-param name="items" select="$prospective" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="latest" as="xs:date"
										select="max(current-group()/@end-date/xs:date(.))" />
									<xsl:call-template name="group-items">
										<xsl:with-param name="items" select="current-group()[@end-date = $latest]" />
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</div>
</xsl:template>

<xsl:template match="atom:feed/atom:title" />

<xsl:template match="atom:title">
	<xsl:param name="uri" as="xs:string" tunnel="yes" required="yes" />
	<h3 class="searchTitle">
		<a href="{$uri}">
			<xsl:apply-templates/>
			<xsl:text> (</xsl:text>
			<xsl:value-of select="tso:GetNumberForLegislation(../ukm:DocumentMainType/@Value, ../ukm:Year/@Value, ../ukm:Number/@Value)" />
			<xsl:text>)</xsl:text>
		</a>		
	</h3>
</xsl:template>

<xsl:template match="atom:summary">
	<p class="searchSummary">
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template name="group-items">
	<xsl:param name="items" as="element()+" required="yes" />
	<xsl:for-each-group select="$items" group-by="@href">
		<xsl:sort select="@href" />
		<h4 class="searchSection">
			<a href="{@href}">
				<xsl:value-of select="@title" />
			</a>
			<xsl:if test="@extent != 'E+W+S+N.I.'">
				<span class="LegExtentRestriction"> [<xsl:value-of select="@extent" />]</span>
			</xsl:if>
			<xsl:if test="@status = 'Prospective'">
				<span class="LegProspective"> [Prosp.]</span>
			</xsl:if>
			<xsl:if test="@end-date != ''">
				<span class="LegVersionRestriction"> [<xsl:value-of select="if (@start-date != '') then @start-date else 'as enacted'" />]</span>
			</xsl:if>
		</h4>
		<xsl:if test="current-group()[self::leg:term]">
			<dl class="searchTerms">
				<xsl:apply-templates select="current-group()[self::leg:term]" />
			</dl>
		</xsl:if>
		<xsl:if test="current-group()[self::leg:citation]">
			<xsl:for-each-group select="current-group()[self::leg:citation]" group-by="string(@id)">
				<xsl:apply-templates select="." />
			</xsl:for-each-group>
		</xsl:if>
	</xsl:for-each-group>
</xsl:template>

<xsl:template match="leg:term">
	<dt>
		<a href="{@href}#term-{translate(@term, ' ', '-')}">
			<xsl:text>Term found: </xsl:text>
			<xsl:value-of select="@term" />
		</a>
	</dt>
	<dd>
		<xsl:apply-templates />
	</dd>
</xsl:template>

<xsl:template match="leg:citation">
	<p class="searchSummary">
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="leg:text" />

<xsl:template match="atom:link[@rel = ('first', 'prev', 'next', 'last')]">
	<a class="pageLink" href="{replace(@href, '/atom\.feed', '')}"><xsl:value-of select="upper-case(@rel)"/> PAGE</a>
</xsl:template>

</xsl:stylesheet>
