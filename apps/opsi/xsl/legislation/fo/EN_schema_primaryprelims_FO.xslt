<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:template name="TSO_PrimaryPrelims">
	<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" line-height="{$g_strLineHeight}" white-space-collapse="false" line-height-shift-adjustment="disregard-shifts">
		
			<xsl:call-template name="TSOheader"/>
		<fo:block text-align="center" font-style="italic" font-size="11pt">
			<xsl:if test="(/leg:EN/leg:ExplanatoryNotes/leg:ENprelims or /leg:EN/leg:Contents/leg:ContentsTitle) and $g_ndsLegMetadata/ukm:Number/@Value != ''">
				<xsl:choose>
					<xsl:when test="$g_strDocType = 'ScottishAct'">
						<xsl:text>These notes relate to the </xsl:text>
						<xsl:choose>
							<xsl:when test="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:Title">
								<xsl:apply-templates select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:Title" mode="header"/>
							</xsl:when>
							<xsl:when test="/leg:EN/leg:Contents/leg:ContentsTitle">
								<xsl:apply-templates select="/leg:EN/leg:Contents/leg:ContentsTitle" mode="header"/>
							</xsl:when>
						</xsl:choose>
						<xsl:text> (asp </xsl:text>
						<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
						<xsl:text>) </xsl:text>
						<xsl:if test="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText">
							<xsl:text>which received Royal Assent on </xsl:text>
							<xsl:value-of select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>These notes refer to the </xsl:text>
						<xsl:choose>
							<xsl:when test="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:Title">
								<xsl:apply-templates select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:Title" mode="header"/>
							</xsl:when>
							<xsl:when test="/leg:EN/leg:Contents/leg:ContentsTitle">
								<xsl:apply-templates select="/leg:EN/leg:Contents/leg:ContentsTitle" mode="header"/>
							</xsl:when>
						</xsl:choose>
						<xsl:text> (c.</xsl:text>
						<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
						<xsl:text>) </xsl:text>
						<xsl:if test="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText">
							<xsl:text>which received Royal Assent on </xsl:text>
							<xsl:value-of select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</fo:block>
		<xsl:choose>
			<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
				<fo:block font-size="20pt" line-height="24pt" margin-top="12pt" text-align="center">
					<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:block font-size="18pt" font-weight="bold" line-height="30pt" margin-top="12pt" text-align="center" text-transform="uppercase">
					<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
		<fo:block border-bottom="0.5pt solid black" margin-left="144pt" margin-right="144pt" text-align="center" space-after="12pt" space-before="12pt"/>
		<fo:block font-size="14pt" font-weight="bold" text-align="center" space-after="24pt" space-before="24pt">
			<xsl:text>EXPLANATORY NOTES</xsl:text>
		</fo:block>
		<!--<xsl:if test="$g_ndsLegMetadata/ukm:Year/@Value != ''">
			<fo:block font-size="12pt" font-weight="bold" text-align="center" space-after="24pt">
				<xsl:choose>
					<xsl:when test="$g_strDocType = 'ScottishAct'"/>
					<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
						<xsl:attribute name="margin-top">36pt</xsl:attribute>
						<xsl:attribute name="font-weight">normal</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="margin-top">18pt</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$g_ndsLegMetadata/ukm:Year/@Value"/>
				<xsl:choose>
					<xsl:when test="$g_strDocType = 'ScottishAct'">
						<xsl:text> asp </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> CHAPTER </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$g_ndsLegMetadata//ukm:Number/@Value"/>
			</fo:block>
		</xsl:if>-->
		
		
		<xsl:apply-templates select="/leg:EN/leg:Contents"/>
		<xsl:apply-templates select="/leg:EN/leg:ExplanatoryNotes/leg:Body"/>
	</fo:flow>
</xsl:template>

<xsl:template match="leg:LongTitle">
	<xsl:choose>
		<xsl:when test="$g_strDocType = 'ScottishAct'">
			<fo:block text-align="justify" space-before="12pt" space-after="12pt" font-weight="bold">
				<xsl:apply-templates select="following-sibling::leg:DateOfEnactment/leg:DateText"/>
			</fo:block>
			<fo:block text-align="justify">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:when>
		<xsl:otherwise>
			<fo:block text-align="justify" text-align-last="justify" font-size="{$g_dblBodySize + 1}{$g_strUnits}" line-height="{$g_intLineHeight + 2}{$g_strUnits}">
				<xsl:apply-templates/>
				<xsl:text> </xsl:text>
				<fo:leader leader-pattern="space" leader-length.minimum="1em" leader-length.maximum="100%"/>
				<xsl:text> </xsl:text>
				<fo:leader leader-pattern="space" leader-length.minimum="0em" leader-length.maximum="100%"/>
				<fo:inline>
					<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
					<xsl:value-of select="following-sibling::leg:DateOfEnactment/leg:DateText"/>
				</fo:inline>
			</fo:block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>