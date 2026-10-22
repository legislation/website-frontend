<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<!--HA054109: added as FOP doesn't like empty list-block elements-->
<xsl:template match="leg:UnorderedList[not(leg:ListItem/leg:Para/leg:Text/node())]">
<xsl:apply-templates/>
</xsl:template>

<!--HA054109: match altered as FOP doesn't like empty list-block elements-->
<xsl:template match="leg:UnorderedList[leg:ListItem/leg:Para/leg:Text/node()]">
	<xsl:for-each select="leg:ListItem">
		<!-- HA074029: further check to prevent empty list-block elements causing FOP errors in, e.g. http://www.legislation.gov.uk/uksi/2006/1003/data.pdf-->
		<xsl:if test="not(ancestor::leg:Schedule) or not(leg:Para/leg:Text/leg:Repeal) or (every $text in leg:Para/leg:Text/leg:Repeal satisfies normalize-space($text) != normalize-space(.)) or $selectedSectionSubstituted or $showRepeals">
			<fo:block>
				<xsl:if test="parent::leg:P1para">
					<xsl:attribute name="margin-left">6pt</xsl:attribute>
				</xsl:if>
				<xsl:variable name="intProvDistance" as="xs:integer">
					<xsl:choose>
						<xsl:when test="$g_strDocClass = $g_strConstantEuretained and ancestor::leg:Footnote">18</xsl:when>
						<xsl:when test="$g_strDocClass = $g_strConstantEuretained">42</xsl:when>
						<xsl:when test="ancestor::leg:ListItem">24</xsl:when>
						<xsl:when test="@Decoration = 'dash'">36</xsl:when>
						<xsl:otherwise>24</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<fo:list-block provisional-label-separation="6pt" space-before="{$g_strStandardParaGap}" provisional-distance-between-starts="{$intProvDistance}pt">
					<xsl:if test="ancestor::xhtml:table and $g_flSuppressTableLineSpace">
						<xsl:attribute name="space-before">0pt</xsl:attribute>
					</xsl:if>
					
						<fo:list-item space-before="{$g_strStandardParaGap}">
							<xsl:if test="ancestor::xhtml:table and $g_flSuppressTableLineSpace">
								<xsl:attribute name="space-before">0pt</xsl:attribute>
							</xsl:if>
							<xsl:call-template name="TSOgetID"/>
							<fo:list-item-label end-indent="label-end()">
								<fo:block font-size="{if (ancestor::leg:Footnote) then $g_strFooterSize else $g_strBodySize}" text-align="right" font-weight="bold">
									<xsl:if test="$g_strDocClass = ($g_strConstantEuretained)">
										<xsl:attribute name="text-align">left</xsl:attribute>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="parent::*/@Decoration = 'dash'">&#8212;</xsl:when>
										<xsl:when test="parent::*/@Decoration = 'bullet'">&#8226;</xsl:when>
										<!-- Put other values here -->
									</xsl:choose>
								</fo:block>						
							</fo:list-item-label>
							<fo:list-item-body start-indent="body-start()">
								<fo:block font-size="{if (ancestor::leg:Footnote) then $g_strFooterSize else $g_strBodySize}" text-indent="0pt" text-align="justify">
									<xsl:if test="ancestor::leg:Footnot">
										<xsl:attribute name="line-height">9pt</xsl:attribute>
									</xsl:if>
									<xsl:if test="ancestor::xhtml:td">
										<xsl:attribute name="text-align">left</xsl:attribute>
									</xsl:if>
									<xsl:apply-templates/>
								</fo:block>						
							</fo:list-item-body>
						</fo:list-item>						
					
				</fo:list-block>
			</fo:block>
		</xsl:if>
	<!-- Hack to get around footnote issue in FOP - footnotes in lists/tables disappear!-->
	<!-- not needed for FOP 1.0 -->
		<xsl:if test="g_FOprocessor = 'FOP0.95'">
			<xsl:call-template name="FOPfootnoteHack"/>
		</xsl:if>
	</xsl:for-each>
	
</xsl:template>

<xsl:template match="leg:OrderedList">
	<xsl:variable name="strDecoration" select="@Decoration" as="xs:string?"/>
	<xsl:variable name="strListType" select="@Type" as="xs:string?"/>
	
	<xsl:for-each select="leg:ListItem">
		<!--Added by Yash - call HA051278 - to correct numbering-->
		<xsl:variable name="strListNumberOverride" select="@NumberOverride" as="xs:string?"/>
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
				<xsl:when test="$g_strDocClass = $g_strConstantEuretained and ancestor::leg:Footnote">18</xsl:when>
				<xsl:when test="$g_strDocClass = $g_strConstantEuretained">42</xsl:when>
				<xsl:when test="$g_strDocClass = $g_strConstantPrimary and ancestor::leg:ListItem">36</xsl:when>
				<xsl:otherwise>24</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		

		<xsl:variable name="strFormat" as="xs:string">
			<xsl:choose>	
				<xsl:when test="lower-case($strListType) = 'alpha'">a</xsl:when>
				<xsl:when test="lower-case($strListType) = 'alphaupper'">A</xsl:when>
				<xsl:when test="lower-case($strListType) = 'roman'">i</xsl:when>
				<xsl:when test="lower-case($strListType) = 'romanupper'">I</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		
		<fo:list-block provisional-label-separation="6pt" provisional-distance-between-starts="{$intProvDistance}pt">
			
				<fo:list-item space-before="{$g_strStandardParaGap}">
					<xsl:choose>
						<xsl:when test="ancestor::xhtml:table and $g_flSuppressTableLineSpace">
							<xsl:attribute name="space-before">0pt</xsl:attribute>
						</xsl:when>
						<xsl:when test="$g_strDocClass =  $g_strConstantEuretained and ancestor::leg:Footnote">
							<xsl:attribute name="space-before">0pt</xsl:attribute>
						</xsl:when>
						<xsl:when test="$g_strDocClass =  $g_strConstantEuretained">
							<xsl:attribute name="space-before">8pt</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:call-template name="TSOgetID"/>
					<fo:list-item-label end-indent="label-end()">
						<fo:block font-size="{if (ancestor::leg:Footnote) then $g_strFooterSize else $g_strBodySize}" text-align="right">
							<xsl:if test="$g_strDocClass = ($g_strConstantSecondary, $g_strConstantEuretained)">
								<xsl:attribute name="text-align">left</xsl:attribute>
							</xsl:if>
							
							<xsl:if test="parent::leg:OrderedList/parent::leg:BlockAmendment">
								<xsl:call-template name="TSOcheckStartOfAmendment">
									<xsl:with-param name="provenance" tunnel="yes" select="descendant::text()[normalize-space(.) != ''][1]"/>
								</xsl:call-template>
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
								<xsl:when test="$g_strDocClass = $g_strConstantEuretained"></xsl:when>
								<xsl:when test="$strDecoration = 'parens'">(</xsl:when>
								<xsl:when test="$strDecoration = 'brackets'">[</xsl:when>
							</xsl:choose>
							
							<!--Added by Yash - call HA051278 - to correct numbering-->
							<xsl:choose>
								<xsl:when test="$strListNumberOverride">
									<xsl:value-of select="$strListNumberOverride"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:number value="$intItemCount" format="{$strFormat}"/>
								</xsl:otherwise>
							</xsl:choose>
							

							<xsl:choose>
								<xsl:when test="$g_strDocClass = $g_strConstantEuretained"></xsl:when>
								<xsl:when test="$strDecoration = ('parens', 'parenRight')">)</xsl:when>
								<xsl:when test="$strDecoration = ('brackets', 'bracketRight')">]</xsl:when>
								<xsl:when test="$strDecoration = 'period'">.</xsl:when>
								<xsl:when test="$strDecoration = 'colon'">:</xsl:when>
							</xsl:choose>

						</fo:block>						
					</fo:list-item-label>
					
					<fo:list-item-body start-indent="body-start()">
						<fo:block font-size="{if (ancestor::leg:Footnote) then $g_strFooterSize else $g_strBodySize}" text-align="justify">
							<xsl:apply-templates/>
						</fo:block>						
					</fo:list-item-body>
					
				</fo:list-item>						
			
		</fo:list-block>
	</fo:block>
	<!-- Hack to get around footnote issue in FOP - footnotes in lists/tables disappear!-->
	<!-- not needed for FOP 1.0 -->
		<xsl:if test="g_FOprocessor = 'FOP0.95'">
			<xsl:call-template name="FOPfootnoteHack"/>
		</xsl:if>
	
	</xsl:for-each>
</xsl:template>

<xsl:template match="leg:KeyList">
	<fo:table font-size="{$g_strBodySize}" space-before="6pt"  table-layout="fixed" width="100%">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<fo:table-column column-width="20%"/>
				<fo:table-column column-width="5%"/>	
				<fo:table-column column-width="75%"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:table-column column-width="5%"/>
				<fo:table-column column-width="5%"/>	
				<fo:table-column column-width="90%"/>
			</xsl:otherwise>
		</xsl:choose>
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
	<xsl:if test="g_FOprocessor = 'FOP0.95'">
		<xsl:call-template name="FOPfootnoteHack"/>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>