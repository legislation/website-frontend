<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg">

<xsl:template match="leg:UnorderedList">
	<fo:block>
		<xsl:if test="parent::leg:P1para">
			<xsl:attribute name="margin-left">6pt</xsl:attribute>
		</xsl:if>
		<xsl:variable name="intProvDistance" as="xs:integer">
			<xsl:choose>
				<xsl:when test="ancestor::leg:ListItem">18</xsl:when>
				<xsl:when test="@Decoration = 'dash'">30</xsl:when>
				<xsl:otherwise>18</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:list-block provisional-label-separation="6pt" space-before="{$g_strStandardParaGap}" provisional-distance-between-starts="{$intProvDistance}pt">
			<xsl:if test="ancestor::xhtml:table and $g_flSuppressTableLineSpace">
				<xsl:attribute name="space-before">0pt</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="leg:ListItem">
				<fo:list-item space-before="{$g_strLargeStandardParaGap}">
					<xsl:if test="ancestor::xhtml:table and $g_flSuppressTableLineSpace">
						<xsl:attribute name="space-before">0pt</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="TSOgetID"/>
					<fo:list-item-label end-indent="label-end()">
						<fo:block font-size="{$g_strBodySize}" text-align="left" font-weight="bold" font-family="Times New Roman">
							<xsl:choose>
								<xsl:when test="parent::*/@Decoration = 'dash'">&#8212;</xsl:when>
								<xsl:when test="parent::*/@Decoration = 'bullet' and count(ancestor-or-self::*[@Decoration = 'bullet']) = 2">
									<fo:instream-foreign-object content-height="6pt">
										<svg:svg height="100" width="100">
											<svg:circle cx="50" cy="50" r="40" stroke="black" stroke-width="8" fill="white" />
										</svg:svg>
									</fo:instream-foreign-object>
								</xsl:when>
								<xsl:when test="parent::*/@Decoration = 'bullet' and count(ancestor-or-self::*[@Decoration = 'bullet']) = 3">
									<fo:instream-foreign-object content-height="6pt">
										<svg:svg height="100" width="100">
											<svg:rect width="50" height="50" x="25" y="25" stroke="black" stroke-width="3" fill="black" />
										</svg:svg>
									</fo:instream-foreign-object>
								</xsl:when>
								<!-- Chunyu: Changed '-' into 'endash' for fop1.0 which can not handle a single '-' -->
								<xsl:when test="parent::*/@Decoration = 'bullet' and parent::*/ancestor::*/@Decoration = 'bullet'">&#8211;</xsl:when><!--ndash-->
								<xsl:when test="parent::*/@Decoration = 'bullet'">&#8226;</xsl:when><!--filled circle-->
								<!-- Put other values here -->
							</xsl:choose>
						</fo:block>						
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block font-size="{$g_strBodySize}" text-indent="0pt" text-align="justify">
							<xsl:if test="ancestor::xhtml:td">
								<xsl:attribute name="text-align">left</xsl:attribute>
							</xsl:if>
							<xsl:apply-templates/>
						</fo:block>						
					</fo:list-item-body>
				</fo:list-item>						
			</xsl:for-each>
		</fo:list-block>
	</fo:block>
</xsl:template>

<xsl:template match="leg:OrderedList">
	<fo:block>
	
		<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
			<xsl:choose>
				<xsl:when test="ancestor::leg:ListItem[not(ancestor::leg:UnorderedList[@Class = 'Definition'] and $g_strDocType = 'ScottishAct')] or parent::xhtml:td">
					<xsl:attribute name="space-start">12pt</xsl:attribute>
				</xsl:when>
				<xsl:when test="parent::leg:P2para/ancestor::leg:BlockAmendment">
					<xsl:attribute name="space-start">36pt</xsl:attribute>
				</xsl:when>
			</xsl:choose>
		</xsl:if>

		<xsl:variable name="intProvDistance" as="xs:integer">
			<xsl:choose>
				<xsl:when test="$g_strDocClass = $g_strConstantPrimary and ancestor::leg:ListItem">36</xsl:when>
				<xsl:otherwise>24</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="strDecoration" select="@Decoration" as="xs:string"/>
		<xsl:variable name="strListType" select="@Type" as="xs:string"/>

		<xsl:variable name="strFormat" as="xs:string">
			<xsl:choose>
				<xsl:when test="$strListType = 'alpha'">a</xsl:when>
				<xsl:when test="$strListType = 'alphaupper'">A</xsl:when>
				<xsl:when test="$strListType = 'roman'">i</xsl:when>
				<xsl:when test="$strListType = 'romanupper'">I</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		

		<fo:list-block provisional-label-separation="6pt" provisional-distance-between-starts="{$intProvDistance}pt">
			<xsl:for-each select="leg:ListItem">
				
				<fo:list-item space-before="{$g_strLargeStandardParaGap}">
					<xsl:if test="ancestor::xhtml:table and $g_flSuppressTableLineSpace">
						<xsl:attribute name="space-before">0pt</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="TSOgetID"/>
					<fo:list-item-label end-indent="label-end()">
						<fo:block font-size="{$g_strBodySize}" text-align="right">
							<xsl:if test="$g_strDocClass = $g_strConstantSecondary">
								<xsl:attribute name="text-align">left</xsl:attribute>
							</xsl:if>
					
							<xsl:variable name="intItemCount" as="xs:integer">
								<xsl:choose>
									<xsl:when test="parent::leg:OrderedList/@Start">
										<xsl:sequence select="count(preceding-sibling::*) + xs:integer(parent::leg:OrderedList/@Start)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="count(preceding-sibling::*) + 1"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:choose>
								<xsl:when test="$strDecoration = 'parens'">(</xsl:when>
								<xsl:when test="$strDecoration = 'brackets'">[</xsl:when>
							</xsl:choose>
							
							<xsl:choose>
								<xsl:when test="@NumberOverride"><xsl:value-of select="@NumberOverride"/></xsl:when>
								<xsl:otherwise>
									<xsl:number value="$intItemCount" format="{$strFormat}"/>
								</xsl:otherwise>
							</xsl:choose>
							

							<xsl:choose>
								<xsl:when test="@NumberOverride"></xsl:when>
								<xsl:when test="$strDecoration = ('parens', 'parenRight')">)</xsl:when>
								<xsl:when test="$strDecoration = ('brackets', 'bracketRight')">]</xsl:when>
								<xsl:when test="$strDecoration = 'period'">.</xsl:when>
								<xsl:when test="$strDecoration = 'colon'">:</xsl:when>
							</xsl:choose>

						</fo:block>						
					</fo:list-item-label>
					
					<fo:list-item-body start-indent="body-start()">
						<fo:block font-size="{$g_strBodySize}" text-align="justify">
							<xsl:apply-templates/>
						</fo:block>						
					</fo:list-item-body>
					
				</fo:list-item>						
			</xsl:for-each>
		</fo:list-block>
	</fo:block>
</xsl:template>

<xsl:template match="leg:KeyList">
	<fo:table font-size="{$g_strBodySize}" space-before="6pt" >
		<fo:table-column column-width="5%"/>
		<fo:table-column column-width="5%"/>	
		<fo:table-column column-width="90%"/>
		<fo:table-body>
			<xsl:for-each select="leg:KeyListItem">
				<fo:table-row>
					<fo:table-cell>
						<xsl:if test="@Align">
							<xsl:attribute name="text-align"><xsl:value-of select="@Align"/></xsl:attribute>
						</xsl:if>
						<fo:block font-size="{$g_strBodySize}">
							<xsl:apply-templates select="leg:Key"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="center">
						<fo:block font-size="{$g_strBodySize}">
							<xsl:value-of select="parent::*/@Separator"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block font-size="{$g_strBodySize}" text-align="left" space-after="3pt">
							<xsl:apply-templates select="leg:ListItem/node()"/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</xsl:for-each>
		</fo:table-body>
	</fo:table>	
</xsl:template>

</xsl:stylesheet>