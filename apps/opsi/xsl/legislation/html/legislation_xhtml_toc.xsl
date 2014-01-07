<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

-->
<!-- Change history
Colin 06/06/13 NOT added code to output Welsh as this template is only used by  old code (new code uses format-date XSLT2)
-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
    xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.tso.co.uk/assets/namespace/error"
    xmlns:tso="http://www.tso.co.uk/assets/namespace/function"
xmlns:dc="http://purl.org/dc/elements/1.1/"
version="2.0">
	
<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>
	
<xsl:key name="versions" match="leg:Version" use="@id"/>

<xsl:template match="/">
	<html>
		<head>
			<style type="text/css" media="screen, print">@import "/styles/legislation.css";</style>
		</head>
		<body>
			<div id="ContentMain">
				<xsl:variable name="docPath" select="concat('/', substring-before($paramsDoc/parameters/path, '/contents'))"/>
				<p class="LegContentsWhole">
					<a href="{$docPath}">
						<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title"/>
					</a>
				</p>
				<p class="LegContentsIntroduction">
					<a href="{$docPath}/introduction">Introductory Text</a>
				</p>
				<p class="LegContentsBody">
					<a href="{$docPath}/body">Main Body</a>
				</p>
				<ul class="LegContents">
					<xsl:apply-templates select="/leg:Legislation/(leg:Primary | leg:Secondary)/*" mode="GenerateTOC"/>
				</ul>
			</div>
		</body>
	</html>
</xsl:template>
	
<xsl:template  match="leg:Body" mode="GenerateTOC">
	<xsl:apply-templates select="*" mode="#current"/>
</xsl:template>
	
<xsl:template match="leg:Group | leg:Part | leg:Chapter | leg:Pblock" mode="GenerateTOC">
	<li class="LegContents{local-name()}">
		<p>
			<xsl:apply-templates select="leg:Number, leg:Title" mode="#current"/>
		</p>
		<ul>
			<xsl:apply-templates select="*[not(self::leg:Number or self::leg:Title)]" mode="#current"/>
		</ul>
	</li>
</xsl:template>
	
<xsl:template match="leg:Group/leg:Number | leg:Part/leg:Number | leg:Chapter/leg:Number" mode="GenerateTOC">
	<span class="LegContentsNumber">
		<a href="{tso:GenTocLink(parent::*/@id)}">
			<xsl:apply-templates/>
		</a>
	</span>
</xsl:template>

<xsl:template match="leg:Pblock/leg:Number" mode="GenerateTOC">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:Group/leg:Title | leg:Part/leg:Title | leg:Chapter/leg:Title" mode="GenerateTOC">
	<span class="LegContentsTitle">
		<a href="{tso:GenTocLink(parent::*/@id)}">
			<xsl:apply-templates/>
		</a>
	</span>
</xsl:template>

<xsl:template match="leg:Pblock/leg:Title" mode="GenerateTOC">
	<span class="LegContentsTitle">
		<a href="{tso:GenBlockTocLink(parent::*/@id)}">
			<xsl:apply-templates/>
		</a>
	</span>
</xsl:template>

<xsl:template match="leg:Schedule/leg:Number" mode="GenerateTOC">
	<span class="LegContentsNumber">
		<a href="{tso:GenTocLink(parent::*/@id)}">
			<xsl:apply-templates/>
		</a>
	</span>
</xsl:template>

<xsl:template match="leg:Schedule/leg:TitleBlock/leg:Title" mode="GenerateTOC">
	<span class="LegContentsTitle">
		<a href="{tso:GenTocLink(parent::*/parent::*/@id)}">
			<xsl:apply-templates/>
		</a>
	</span>
</xsl:template>

<xsl:template match="leg:P1group" mode="GenerateTOC">
	<li class="LegProvision">
		<a href="{tso:GenTocLink(leg:P1[1]/@id)}">
			<xsl:value-of select="leg:P1[1]/leg:Pnumber"/>
			<xsl:text>. </xsl:text>
			<xsl:apply-templates select="leg:Title"/>
			<xsl:if test="@RestrictExtent">
				<span class="LegExtentRestriction">
					<xsl:text> [</xsl:text>
					<xsl:value-of select="@RestrictExtent"/>
					<xsl:text>]</xsl:text>
				</span>
			</xsl:if>
		</a>
	</li>
	<xsl:if test="not(ancestor::leg:Version)">
		<xsl:apply-templates select="key('versions', tokenize(@AltVersionRefs, ' '))/*" mode="GenerateTOC"/>
	</xsl:if>
</xsl:template>
	
<xsl:template match="leg:Schedules" mode="GenerateTOC">
	<li class="LegContentsSchedules">
		<p>
			<xsl:apply-templates select="leg:Title" mode="#current"/>
		</p>
		<ul>
			<xsl:apply-templates select="*[not(self::leg:Title)]" mode="#current"/>
		</ul>
	</li>
</xsl:template>

<xsl:template match="leg:Schedule" mode="GenerateTOC">
	<li class="LegContentsSchedule">
		<p>
			<xsl:apply-templates select="leg:Number, leg:TitleBlock" mode="#current"/>
		</p>
	</li>
</xsl:template>

<xsl:template match="leg:Schedule/leg:TitleBlock" mode="GenerateTOC">
	<xsl:apply-templates select="leg:Title" mode="#current"/>
</xsl:template>

<xsl:template match="*" mode="GenerateTOC"/>

<xsl:function name="tso:GenTocLink" as="xs:string">
	<xsl:param name="id"/>
	<xsl:sequence select="translate($id, '-', '/')"/>
</xsl:function>
	
<xsl:function name="tso:GenBlockTocLink" as="xs:string">
	<xsl:param name="id"/>
	<xsl:value-of>
		<xsl:sequence select="translate(substring-before($id, 'crossheading-'), '-', '/')"/>
		<xsl:text>crossheading/</xsl:text>
		<xsl:sequence select="substring-after($id, 'crossheading-')" />
	</xsl:value-of>
</xsl:function>

</xsl:stylesheet>
