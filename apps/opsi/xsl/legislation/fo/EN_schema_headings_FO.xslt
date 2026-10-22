<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:template match="leg:Part">
	<fo:block font-size="{$g_strBodySize}">
		<xsl:call-template name="TSOgetID"/>
		<xsl:if test="not(leg:Chapter)">
			<fo:marker marker-class-name="runningheadchapter"/>
		</xsl:if>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Part/leg:Number" priority="1">
	<fo:block font-size="{$g_strBodySize}" space-before="24pt" text-align="center" keep-with-next="always">
		<xsl:call-template name="TSOgetID"/>	
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:attribute name="font-weight">bold</xsl:attribute>
				<xsl:attribute name="font-variant">small-caps</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="font-size">14pt</xsl:attribute>
				<xsl:attribute name="line-height">16.8pt</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<fo:marker marker-class-name="runningheadpart">
			<xsl:value-of select="."/>
			<xsl:text> – </xsl:text>
			<xsl:value-of select="following-sibling::leg:Title"/>
		</fo:marker>
		<fo:marker marker-class-name="SideBar">
			<xsl:value-of select="."/>
		</fo:marker>
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:apply-templates>
					<xsl:with-param name="flSmallCaps" select="true()" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Schedule//leg:Part[not(ancestor::leg:BlockAmendment)]/leg:Number" priority="2">
	<fo:block font-size="{$g_strBodySize}" space-before="12pt" text-align="center" keep-with-next="always">
		<xsl:call-template name="TSOgetID"/>	
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:attribute name="font-variant">small-caps</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="space-before">24pt</xsl:attribute>
				<xsl:attribute name="font-size">14pt</xsl:attribute>
				<xsl:attribute name="line-height">16.8pt</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<fo:marker marker-class-name="runningheadpart">
			<xsl:value-of select="."/>
			<xsl:text> – </xsl:text>
			<xsl:value-of select="following-sibling::leg:Title"/>
		</fo:marker>
		<xsl:for-each select="node()">
			<xsl:choose>
				<xsl:when test="self::leg:Emphasis">
					<fo:inline font-style="italic">
						<xsl:choose>
							<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
								<xsl:call-template name="TSOcheckStartOfAmendment"/>
								<xsl:apply-templates>
									<xsl:with-param name="flSmallCaps" select="true()" tunnel="yes"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:inline>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
							<xsl:call-template name="TSOcheckStartOfAmendment"/>
							<xsl:apply-templates>
								<xsl:with-param name="flSmallCaps" select="true()" tunnel="yes"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Part/leg:Title">	
	<fo:block font-size="{$g_strBodySize}" space-before="12pt" text-align="center" keep-with-next="always">
		<xsl:call-template name="TSOgetID"/>
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary"/>
			<xsl:otherwise>
				<xsl:attribute name="font-size">12pt</xsl:attribute>
				<xsl:attribute name="line-height">14.4pt</xsl:attribute>
				<xsl:attribute name="space-before">6pt</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>	
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:apply-templates>
					<xsl:with-param name="flSmallCaps" select="true()" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Schedule/leg:Part/leg:Title">	
	<fo:block font-size="{$g_strBodySize}" space-before="12pt" text-align="center" keep-with-next="always" font-variant="small-caps">
		<xsl:call-template name="TSOgetID"/>	
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary"/>
			<xsl:otherwise>
				<xsl:attribute name="font-size">12pt</xsl:attribute>
				<xsl:attribute name="line-height">14.4pt</xsl:attribute>
				<xsl:attribute name="space-before">6pt</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>	
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Chapter">
	<fo:block font-size="{$g_strBodySize}">
		<xsl:call-template name="TSOgetID"/>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Chapter/leg:Number">
	<fo:block font-size="{$g_strBodySize}" space-before="12pt" text-align="center" keep-with-next="always">
		<xsl:call-template name="TSOgetID"/>
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:attribute name="space-before">24pt</xsl:attribute>
				<xsl:attribute name="font-weight">bold</xsl:attribute>
				<xsl:attribute name="font-variant">small-caps</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="font-size">11pt</xsl:attribute>
				<xsl:attribute name="line-height">13.2pt</xsl:attribute>
				<xsl:attribute name="space-before">6pt</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>	
		<xsl:if test="not(ancestor::Schedule)">
			<fo:marker marker-class-name="runningheadchapter">
				<xsl:value-of select="."/>
				<xsl:text> – </xsl:text>
				<xsl:value-of select="following-sibling::leg:Title"/>
			</fo:marker>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:apply-templates>
					<xsl:with-param name="flSmallCaps" select="true()" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Chapter/leg:Title">	
	<fo:block font-size="{$g_strBodySize}" space-before="12pt" text-align="center" keep-with-next="always">
		<xsl:call-template name="TSOgetID"/>
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:attribute name="font-variant">small-caps</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="font-size">10.5pt</xsl:attribute>
				<xsl:attribute name="line-height">12.6pt</xsl:attribute>
				<xsl:attribute name="space-before">6pt</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>			
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:apply-templates>
					<xsl:with-param name="flSmallCaps" select="true()" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Pblock">
	<fo:block font-size="{$g_strBodySize}">
		<xsl:call-template name="TSOgetID"/>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Pblock/leg:Title">
	<fo:block font-size="{$g_strBodySize}" space-before="18pt" text-align="center" keep-with-next="always" font-style="italic">
		<xsl:call-template name="TSOgetID"/>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>




<xsl:template match="leg:Title">
	<fo:block>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>



<xsl:template match="leg:Annex">
	<fo:block>
		<fo:block font-weight="bold" space-before="8pt" text-align="left" keep-with-next="always" text-transform="uppercase" break-before="page">
			<xsl:apply-templates select="leg:Number | leg:TitleBlock/leg:Title"/>
		</fo:block>
		<xsl:apply-templates select="leg:TitleBlock/leg:Subtitle"/>
		<xsl:apply-templates select="*[not(self::leg:Number | self::leg:TitleBlock)]"/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Annex/leg:Number">
	<xsl:if test="not(contains(lower-case(.),'annex'))">
		<xsl:text>Annex </xsl:text>
	</xsl:if>
	<xsl:apply-templates/>
	<xsl:text>: </xsl:text>
</xsl:template>

<xsl:template match="leg:Annex/leg:TitleBlock/leg:Title">
	<xsl:call-template name="TSOgetID"/>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:Annex/leg:TitleBlock/leg:Subtitle">
	<fo:block>
		<xsl:call-template name="TSOgetID"/>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:CommentaryGroup/leg:Title | leg:CommentaryChapter/leg:Title | leg:CommentaryP1/leg:Title | leg:CommentarySchedule/leg:Title | leg:SubDivision/leg:Title | leg:SubSubDivision/leg:Title | leg:SubSubSubDivision/leg:Title">
	<fo:block font-weight="bold" font-style="italic" space-before="12pt" text-align="left" keep-with-next="always">
		<xsl:call-template name="TSOgetID"/>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:CommentaryPart/leg:Number | leg:CommentaryPart/leg:Title | leg:CommentaryDivision/leg:Title">
	<fo:block font-weight="bold" space-before="12pt" text-align="left" keep-with-next="always">
		<xsl:call-template name="TSOgetID"/>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Division/leg:Title">
	<fo:block font-weight="bold" text-transform="uppercase" space-before="12pt" text-align="left" keep-with-next="always">
		<xsl:call-template name="TSOgetID"/>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:CommentaryPart | leg:CommentaryGroup | leg:CommentaryChapter | leg:CommentaryP1 | leg:CommentarySchedule">
	<fo:block>
		<xsl:call-template name="TSOgetID"/>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>









</xsl:stylesheet>