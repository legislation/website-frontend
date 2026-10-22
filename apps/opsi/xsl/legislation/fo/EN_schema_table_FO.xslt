<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:template match="leg:Tabular">
	<fo:block space-before="12pt" space-after="12pt">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Tabular/leg:Number">
	<fo:block text-align="center" space-after="12pt" keep-with-next="always">
		<xsl:if test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Tabular/leg:Title">
	<fo:block space-after="12pt" keep-with-next="always">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:attribute name="text-align">center</xsl:attribute>
				<xsl:attribute name="font-weight">bold</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="text-align">center</xsl:attribute>
				<xsl:attribute name="text-transform">uppercase</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="xhtml:table">
	<xsl:apply-templates select="xhtml:caption"/>
	<fo:table font-size="11pt" table-layout="fixed">
		<xsl:attribute name="width" select="if (@width) then @width else '100%'"/>
		<xsl:call-template name="TSOprocessTableBorders"/>	
		<xsl:apply-templates select="xhtml:col | xhtml:colgroup"/>
		<xsl:apply-templates select="xhtml:thead"/>
		<xsl:apply-templates select="xhtml:tfoot"/>			
		<xsl:apply-templates select="xhtml:tbody"/>
	</fo:table>
	<xsl:for-each select="descendant::leg:FootnoteRef">
		<xsl:variable name="strFootnoteRef" select="@Ref" as="xs:string"/>
		<xsl:variable name="intFootnoteNumber" select="count($g_ndsFootnotes[@id = $strFootnoteRef]/preceding-sibling::*) + 1" as="xs:integer"/>
		<fo:block>
			<fo:footnote>
				 <fo:inline font-size="8pt" vertical-align="super"></fo:inline>
				<fo:footnote-body>
					<fo:list-block provisional-label-separation="6pt" provisional-distance-between-starts="18pt">
						<fo:list-item>
							<fo:list-item-label start-indent="0pt" end-indent="label-end()">
								<fo:block font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt" font-weight="bold">
									<xsl:number value="$intFootnoteNumber" format="1"/>
								</fo:block>
							</fo:list-item-label>
							<fo:list-item-body start-indent="body-start()">
								<fo:block font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt">
									<xsl:apply-templates select="$g_ndsFootnotes[@id = $strFootnoteRef]/leg:FootnoteText"/>
								</fo:block>
							</fo:list-item-body>
						</fo:list-item>
					</fo:list-block>		
				</fo:footnote-body>	
			</fo:footnote>
		</fo:block>
	</xsl:for-each>
</xsl:template>

<xsl:template match="xhtml:caption">
	<fo:block text-align="left" font-weight="bold" space-before="6pt" keep-with-next="always">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="xhtml:col">
	<fo:table-column>
		<xsl:if test="@width">
			<xsl:attribute name="column-width"><xsl:value-of select="@width"/></xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@align = 'char'">
				<xsl:attribute name="text-align">'<xsl:value-of select="@char"/>'</xsl:attribute>
			</xsl:when>
			<xsl:when test="@align">
				<xsl:attribute name="text-align"><xsl:value-of select="@align"/></xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="@span">
			<xsl:attribute name="number-columns-repeated"><xsl:value-of select="@span"/></xsl:attribute>
		</xsl:if>
	</fo:table-column>
</xsl:template>

<xsl:template match="xhtml:tr">
	<fo:table-row>
		<xsl:if test="@height">
			<xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>		
	</fo:table-row>
</xsl:template>

<xsl:template name="TSOprocessTableBorders">
	<!--<xsl:if test="@fo:border-top-style">
		<xsl:variable name="strTopText">
			<xsl:if test="not(@fo:border-top-style = 'inherit' and @fo:border-top-width = 'inherit' and @fo:border-top-color = 'inherit')">
				<xsl:choose>
					<xsl:when test="(@fo:border-top-style = 'inherit' and ancestor::*[@fo:border-top-style[not(. = 'inherit')]]) or @fo:border-top-style[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-top-style"/>
					</xsl:when>
					<xsl:otherwise>solid</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="(@fo:border-top-width = 'inherit' and ancestor::*[@fo:border-top-width[not(. = 'inherit')]]) or @fo:border-top-width[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-top-width"/>
					</xsl:when>
					<xsl:otherwise>0.5pt</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="(@fo:border-top-color = 'inherit' and ancestor::*[@fo:border-top-color[not(. = 'inherit')]]) or @fo:border-top-color[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-top-color"/>
					</xsl:when>					
					<xsl:otherwise>black</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$strTopText != ''">
			<xsl:attribute name="border-top" select="$strTopText"/>
		</xsl:if>
	</xsl:if>
	<xsl:if test="@fo:border-bottom-style">
		<xsl:variable name="strBottomText">
			<xsl:if test="not(@fo:border-bottom-style = 'inherit' and @fo:border-bottom-width = 'inherit' and @fo:border-bottom-color = 'inherit')">
				<xsl:choose>
					<xsl:when test="(@fo:border-bottom-style = 'inherit' and ancestor::*[@fo:border-bottom-style[not(. = 'inherit')]]) or @fo:border-bottom-style[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-bottom-style"/>
					</xsl:when>
					<xsl:otherwise>solid</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="(@fo:border-bottom-width = 'inherit' and ancestor::*[@fo:border-bottom-width[not(. = 'inherit')]]) or @fo:border-bottom-width[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-bottom-width"/>
					</xsl:when>
					<xsl:otherwise>0.5pt</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="(@fo:border-bottom-color = 'inherit' and ancestor::*[@fo:border-bottom-color[not(. = 'inherit')]]) or @fo:border-bottom-color[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-bottom-color"/>
					</xsl:when>					
					<xsl:otherwise>black</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$strBottomText != ''">		
			<xsl:attribute name="border-bottom"><xsl:value-of select="$strBottomText"/></xsl:attribute>
		</xsl:if>
	</xsl:if>
	<xsl:if test="@fo:border-left-style">
		<xsl:variable name="strLeftText">
			<xsl:if test="not(@fo:border-left-style = 'inherit' and @fo:border-left-width = 'inherit' and @fo:border-left-color = 'inherit')">
				<xsl:choose>
					<xsl:when test="(@fo:border-left-style = 'inherit' and ancestor::*[@fo:border-left-style[not(. = 'inherit')]]) or @fo:border-left-style[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-left-style"/>
					</xsl:when>
					<xsl:otherwise>solid</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="(@fo:border-left-width = 'inherit' and ancestor::*[@fo:border-left-width[not(. = 'inherit')]]) or @fo:border-left-width[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-left-width"/>
					</xsl:when>
					<xsl:otherwise>0.5pt</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="(@fo:border-left-color = 'inherit' and ancestor::*[@fo:border-left-color[not(. = 'inherit')]]) or @fo:border-left-color[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-left-color"/>
					</xsl:when>					
					<xsl:otherwise>black</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$strLeftText != ''">		
			<xsl:attribute name="border-left" select="$strLeftText"/>
		</xsl:if>
	</xsl:if>
	<xsl:if test="@fo:border-right-style">
		<xsl:variable name="strRightText">
			<xsl:if test="not(@fo:border-right-style = 'inherit' and @fo:border-right-width = 'inherit' and @fo:border-right-color = 'inherit')">
				<xsl:choose>
					<xsl:when test="(@fo:border-right-style = 'inherit' and ancestor::*[@fo:border-right-style[not(. = 'inherit')]]) or @fo:border-right-style[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-right-style"/>
					</xsl:when>
					<xsl:otherwise>solid</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="(@fo:border-right-width = 'inherit' and ancestor::*[@fo:border-right-width[not(. = 'inherit')]]) or @fo:border-right-width[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-right-width"/>
					</xsl:when>
					<xsl:otherwise>0.5pt</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="(@fo:border-right-color = 'inherit' and ancestor::*[@fo:border-right-color[not(. = 'inherit')]]) or @fo:border-right-color[not(. = 'inherit')]">
						<xsl:value-of select="@fo:border-right-color"/>
					</xsl:when>					
					<xsl:otherwise>black</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$strRightText != ''">
			<xsl:attribute name="border-right"><xsl:value-of select="$strRightText"/></xsl:attribute>
		</xsl:if>
	</xsl:if>-->
	<xsl:attribute name="border-right">solid 0.5pt black</xsl:attribute>
	<xsl:attribute name="border-left">solid 0.5pt black</xsl:attribute>
	<xsl:attribute name="border-top">solid 0.5pt black</xsl:attribute>
	<xsl:attribute name="border-bottom">solid 0.5pt black</xsl:attribute>
</xsl:template>

<xsl:template match="xhtml:thead">
	<fo:table-header>
		<xsl:call-template name="TSOprocessTableBorders"/>
		<xsl:apply-templates/>		
	</fo:table-header>
</xsl:template>

<xsl:template match="xhtml:tbody">
	<fo:table-body>
		<xsl:call-template name="TSOprocessTableBorders"/>
		<xsl:apply-templates/>		
	</fo:table-body>
</xsl:template>

<xsl:template match="xhtml:tfoot">
	<fo:table-footer>
		<xsl:call-template name="TSOprocessTableBorders"/>
		<xsl:apply-templates/>		
	</fo:table-footer>
</xsl:template>

<xsl:template match="xhtml:td">
	<fo:table-cell padding-left="3pt" padding-right="3pt" padding-top="1pt" text-indent="0pt">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary or $g_flSuppressTableLineSpace">
				<xsl:attribute name="padding-top">3pt</xsl:attribute>
				<xsl:attribute name="padding-bottom">3pt</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="@colspan">
			<xsl:attribute name="number-columns-spanned" select="@colspan"/>
		</xsl:if>		
		<xsl:if test="@rowspan">
			<xsl:attribute name="number-rows-spanned" select="@rowspan"/>
		</xsl:if>		
		<xsl:call-template name="TSOprocessTableBorders"/>
		<xsl:if test="@height">
			<xsl:attribute name="height" select="@height"/>
		</xsl:if>
		<xsl:if test="@fo:background-color">
			<xsl:attribute name="background-color" select="@fo:background-color"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@valign = 'middle'">
				<xsl:attribute name="display-align">center</xsl:attribute>
			</xsl:when>
			<xsl:when test="@valign = 'bottom'">
				<xsl:attribute name="display-align">after</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@align = 'left'">
				<xsl:attribute name="text-align">left</xsl:attribute>
			</xsl:when>
			<xsl:when test="@align = 'right'">
				<xsl:attribute name="text-align">right</xsl:attribute>
			</xsl:when>
			<xsl:when test="@align = 'center'">
				<xsl:attribute name="text-align">center</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="text-align">from-table-column(text-align)</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@fo:reference-orientation">
				<fo:block-container>
					<xsl:attribute name="reference-orientation"><xsl:value-of select="@fo:reference-orientation"/></xsl:attribute>
					<xsl:attribute name="inline-progression-dimension" select="if (@height) then @height else '50pt'"/>
					<fo:block>
						<xsl:choose>
							<xsl:when test="leg:Character[@Name = 'DotPadding']">
								<xsl:attribute name="text-align-last">justify</xsl:attribute>
							</xsl:when>
						</xsl:choose>
						<xsl:apply-templates/>		
					</fo:block>
				</fo:block-container>
			</xsl:when>
			<xsl:otherwise>
				<fo:block start-indent="0pt" end-indent="0pt">
					<xsl:choose>
						<xsl:when test="leg:Character[@Name = 'DotPadding']">
							<xsl:attribute name="text-align-last">justify</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="not(node())">
							<xsl:text>&#160;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</fo:table-cell>
</xsl:template>

<xsl:template match="xhtml:th">
	<fo:table-cell padding-left="3pt" padding-right="3pt" padding-top="1pt" text-indent="0pt" start-indent="0pt" >
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:attribute name="padding-top">3pt</xsl:attribute>
				<xsl:attribute name="padding-bottom">3pt</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="@colspan">
			<xsl:attribute name="number-columns-spanned" select="@colspan"/>
		</xsl:if>		
		<xsl:if test="@rowspan">
			<xsl:attribute name="number-rows-spanned" select="@rowspan"/>
		</xsl:if>				
		<xsl:call-template name="TSOprocessTableBorders"/>
		<xsl:choose>
			<xsl:when test="@valign = 'middle'">
				<xsl:attribute name="display-align">center</xsl:attribute>
			</xsl:when>
			<xsl:when test="@valign = 'bottom'">
				<xsl:attribute name="display-align">after</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@align = 'left'">
				<xsl:attribute name="text-align">left</xsl:attribute>
			</xsl:when>		
			<xsl:when test="@align = 'right'">
				<xsl:attribute name="text-align">right</xsl:attribute>
			</xsl:when>
			<xsl:when test="@align = 'center'">
				<xsl:attribute name="text-align">center</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$g_strDocClass = $g_strConstantPrimary and ancestor::xhtml:thead">
						<xsl:attribute name="text-align">center</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="text-align">from-table-column(text-align)</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<fo:block text-indent="0pt">
			<xsl:if test="ancestor::xhtml:thead and not(leg:Para)">
				<xsl:attribute name="font-style">italic</xsl:attribute>
			</xsl:if>
			<xsl:if test="ancestor::xhtml:tbody and not(leg:Para)">
				<xsl:attribute name="font-weight">bold</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</fo:table-cell>
</xsl:template>

</xsl:stylesheet>