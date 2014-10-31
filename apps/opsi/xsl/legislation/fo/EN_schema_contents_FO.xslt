<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions">



	<xsl:template match="leg:Contents">
		<fo:block font-size="14pt" space-before="30pt" text-align="center" space-after="0pt" text-transform="uppercase">
			<xsl:attribute name="space-after">36pt</xsl:attribute>
			<xsl:apply-templates select="leg:ContentsTitle"/>
		</fo:block>
		<xsl:apply-templates select="*[not(self::leg:ContentsTitle)]"/>
	</xsl:template>













	<xsl:template match="leg:ContentsDivision">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>

	<xsl:template match="leg:ContentsSubDivision">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>

	<xsl:template match="leg:ContentsSubSubDivision">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>

	<xsl:template match="leg:ContentsSubSubSubDivision">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>



	<xsl:template match="leg:ContentsAnnexes">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>


	<xsl:template match="leg:ContentsAnnex">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>


	<xsl:template match="leg:ContentsCommentaryPart">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>

	<xsl:template match="leg:ContentsCommentaryDivision">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>	

	<xsl:template match="leg:ContentsCommentarySubDivision">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>	

	<xsl:template match="leg:ContentsCommentaryGroup">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>	

	<xsl:template match="leg:ContentsCommentaryChapter">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>

	<xsl:template match="leg:ContentsCommentarySchedule">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>

	<xsl:template match="leg:ContentsCommentaryP1">
		<xsl:apply-templates select="leg:ContentsTitle"/>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</xsl:template>





	<xsl:template match="leg:ContentsDivision/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" space-before="12pt" text-align="left" text-transform="uppercase" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:ContentsSubDivision/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" space-before="12pt" text-align="left" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:ContentsSubSubDivision/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" space-before="12pt" text-align="left" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:ContentsSubSubSubDivision/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" space-before="12pt" text-align="left" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>



	<xsl:template match="leg:ContentsAnnexes/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" space-before="12pt" text-align="left" text-transform="uppercase"  start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>


	<xsl:template match="leg:ContentsAnnex/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" space-before="12pt" text-align="left" text-transform="uppercase"  start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>


	<xsl:template match="leg:ContentsCommentaryPart/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" space-before="12pt" text-align="left" text-transform="uppercase"  start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:ContentsCommentaryDivision/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" text-align="left" keep-with-next="always" space-before="12pt" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>	


	<xsl:template match="leg:ContentsCommentarySubDivision/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" text-align="left" keep-with-next="always" space-before="12pt" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>	

	<xsl:template match="leg:ContentsCommentaryGroup/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" text-align="left" keep-with-next="always" space-before="12pt" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>	

	<xsl:template match="leg:ContentsCommentaryChapter/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" text-align="left" keep-with-next="always" space-before="12pt" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:ContentsCommentarySchedule/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" space-before="12pt" space-after="6pt" text-align="left" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:ContentsCommentaryP1/leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" space-before="12pt" space-after="6pt" text-align="left" start-indent="{tso:indent(count(ancestor::*))}">
			<xsl:call-template name="TSOContentsTitle"/>
		</fo:block>
	</xsl:template>

	<xsl:template name="TSOContentsTitle">
		<xsl:if test="count(parent::*/preceding-sibling::*) = 1">
			<xsl:attribute name="keep-with-previous">
				<xsl:text>always</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<fo:basic-link color="{$g_strLinkColor}">
					<xsl:attribute name="external-destination">
						<xsl:value-of select="parent::*/@DocumentURI"/>
					</xsl:attribute>
					<xsl:if test="preceding-sibling::*/self::leg:ContentsNumber">
						<xsl:apply-templates select="preceding-sibling::*/self::leg:ContentsNumber"/>
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:apply-templates/>
				</fo:basic-link>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="preceding-sibling::*/self::leg:ContentsNumber">
					<xsl:apply-templates select="preceding-sibling::*/self::leg:ContentsNumber"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:function name="tso:indent" as="xs:string">
		<xsl:param name="depth" as="xs:integer"/>
		<xsl:value-of select="concat((($depth - 3) * 24),'pt')"/>
	</xsl:function>	
	
	
</xsl:stylesheet>