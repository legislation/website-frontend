<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:template match="leg:Tabular">
	<!-- count the ancestor depth as we do not want the table to stick out of the page margins -->
	<xsl:if test="parent::leg:P1para/preceding-sibling::*[1]/self::leg:Pnumber and not(preceding-sibling::*)">
		<xsl:call-template name="leg:P1para-legText">
			<xsl:with-param name="context" select="."/>
		</xsl:call-template>
	</xsl:if>
	<!-- count the ancestor depth as we do not want the table to stick out of the page margins -->
	<xsl:variable name="intAncestorDepth" select="count(ancestor::*)"/>
	<fo:block space-before="12pt" space-after="12pt" margin-left="-36pt">
		<!-- give the table more horiozontal space when in higher list levels-->
		<xsl:attribute name="margin-left">
			<xsl:choose>
				<xsl:when test="ancestor::leg:P3 and $intAncestorDepth &gt; 10">
					<xsl:text>-36pt</xsl:text>
				</xsl:when>
				<xsl:when test="ancestor::leg:P2 and $intAncestorDepth &gt; 10">
					<xsl:text>-48pt</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0pt</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
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
	<xsl:variable name="charCount" as="xs:integer" select="string-length(xhtml:tfoot)"/>
	<fo:table table-layout="fixed">
		<xsl:attribute name="width" select="if (@width) then @width else '100%'"/>
	
		<xsl:choose>
				<xsl:when test="not(descendant::*/@*[not(. = 'inherit') and contains(name(), 'border')])">
					<xsl:attribute name="border-top">solid 0.5pt black</xsl:attribute>
					<xsl:attribute name="border-bottom">solid 0.5pt black</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="TSOprocessTableBorders"/>	
				</xsl:otherwise>
			</xsl:choose>	
	
		
		<xsl:apply-templates select="xhtml:col | xhtml:colgroup"/>
		<xsl:apply-templates select="xhtml:thead"/>
		
		
		
		
		<!-- bug D494 sometimes we have schedules that have Notes included within the tablefooter - these can format over several pages 
			therefore we will run a character count and if greater than a specified value will format after the current table -->
		<xsl:if test="$charCount &lt; $g_intMaxTfootCharCount">
			<xsl:apply-templates select="xhtml:tfoot"/>	
		</xsl:if>
		
		<xsl:apply-templates select="xhtml:tbody"/>
		
		
		
	</fo:table>
	
	<xsl:if test="$charCount &gt;= $g_intMaxTfootCharCount">
		<xsl:apply-templates select="xhtml:tfoot" mode="format-tfoot-after-table"/>	
	</xsl:if>
	
	<!-- Hack to get around footnote issue in FOP - footnotes in lists/tables disappear!-->
	<!-- Chunyu :Added the condition for fop0.95 -->
	<xsl:if test="g_FOprocessor = 'FOP0.95'">
		<xsl:for-each select="descendant::leg:FootnoteRef">
		<xsl:variable name="strFootnoteRef" select="@Ref" as="xs:string"/>
		<xsl:variable name="intFootnoteNumber" select="count($g_ndsFootnotes[@id = $strFootnoteRef]/preceding-sibling::*) + 1" as="xs:integer"/>
		<xsl:if test="$g_ndsFootnotes[@id = $strFootnoteRef]">
			<fo:block>
				<fo:footnote>
					 <fo:inline font-size="8pt" vertical-align="super"></fo:inline>
					<fo:footnote-body>
						<fo:list-block provisional-label-separation="6pt" provisional-distance-between-starts="18pt">
							<fo:list-item>
								<fo:list-item-label start-indent="0pt" end-indent="label-end()">
									<fo:block  vertical-align="super" font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt" font-weight="bold">
										<fo:inline font-weight="normal">			
											<xsl:text>(</xsl:text>
										</fo:inline>
										<xsl:number value="$intFootnoteNumber" format="1"/>
										<fo:inline font-weight="normal">
											<xsl:text>)</xsl:text>
										</fo:inline>
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
		</xsl:if>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template match="xhtml:caption">
	<fo:block text-align="left" font-weight="bold" space-before="6pt" keep-with-next="always">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="xhtml:col">
	<fo:table-column>
		<xsl:if test="@width">
			<!-- Translate specified width into a proportional column width
			     since formatted width won't always match designed width.
			     This works provided every column definition uses the same
			     units (which is likely when is XML generated from an
			     authoring application). -->
			<xsl:attribute
					name="column-width"
					select="concat('proportional-column-width(', replace(@width, '[A-Z]', '', 'i'), ')')"/>
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

<!-- Maybe add some border properties to the fo:table. -->
<xsl:template name="TSOprocessTableBorders">
	<xsl:if test="@fo:border-top-style">
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
	</xsl:if>
</xsl:template>

<xsl:template match="xhtml:thead">
	<fo:table-header>
		<xsl:choose>
			<xsl:when test="not(ancestor::xhtml:table[1]/descendant::*/@*[not(. = 'inherit') and contains(name(), 'border')])">
				<xsl:attribute name="border-bottom">solid 0.5pt black</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="TSOprocessTableBorders"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:apply-templates/>		
	</fo:table-header>
</xsl:template>

<xsl:template match="xhtml:tbody">
	<fo:table-body>
		<xsl:choose>
			<xsl:when test="not(ancestor::xhtml:table[1]/descendant::*/@*[not(. = 'inherit') and contains(name(), 'border')])">
				<xsl:attribute name="border-bottom">solid 0.5pt black</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="TSOprocessTableBorders"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:apply-templates/>		
	</fo:table-body>
</xsl:template>

<xsl:template match="xhtml:tfoot">
	<fo:table-footer>
		<xsl:call-template name="TSOprocessTableBorders"/>
		<xsl:apply-templates/>		
	</fo:table-footer>
</xsl:template>

<xsl:template match="xhtml:tfoot" mode="format-tfoot-after-table">
	<fo:table table-layout="fixed">
		<xsl:attribute name="width" select="if (parent::xhtml:table/@width) then parent::xhtml:table/@width else '100%'"/>
		<xsl:apply-templates select="parent::xhtml:table/xhtml:col | parent::xhtml:table/xhtml:colgroup"/>
		<fo:table-body>
			<xsl:call-template name="TSOprocessTableBorders"/>
			<xsl:apply-templates/>	
		</fo:table-body>
	</fo:table>
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
			<!-- Fix to get around FOPs validation on bad data -->
			<xsl:if test="count(parent::xhtml:tr/following-sibling::*) ge number(@rowspan) - 1"><xsl:attribute name="number-rows-spanned" select="@rowspan"/></xsl:if>
		</xsl:if>		
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<xsl:call-template name="EU-table-borders"/>					
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="TSOprocessTableBorders"/>
			</xsl:otherwise>		
		</xsl:choose>
		
		<xsl:if test="@height">
			<xsl:attribute name="height" select="@height"/>
		</xsl:if>
		<xsl:if test="@fo:background-color">
			<xsl:attribute name="background-color" select="@fo:background-color"/>
		</xsl:if>
		<!-- make table footnote text  8pt by default to cover any text entered directly into a tfoot cell  (issue identified with uksi/2007/3297/made) -->
		<xsl:if test="ancestor::xhtml:tfoot">
			<xsl:attribute name="font-size">8pt</xsl:attribute>
			<xsl:attribute name="line-height">9pt</xsl:attribute>
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
	<fo:table-cell padding-left="3pt" padding-right="3pt" padding-top="1pt" text-indent="0pt" margin="0pt">
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
			<!-- Fix to get around FOPs validation on bad data -->
			<xsl:if test="count(parent::xhtml:tr/following-sibling::*) ge number(@rowspan) - 1"><xsl:attribute name="number-rows-spanned" select="@rowspan"/></xsl:if>
		</xsl:if>				
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<xsl:call-template name="EU-table-borders"/>					
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="TSOprocessTableBorders"/>
			</xsl:otherwise>		
		</xsl:choose>
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

<xsl:template name="EU-table-borders">
	<xsl:if test="preceding-sibling::*">
		<xsl:attribute name="border-left">solid 0.5pt black</xsl:attribute>
	</xsl:if>
	<xsl:if test="following-sibling::*">
		<xsl:attribute name="border-right">solid 0.5pt black</xsl:attribute>
	</xsl:if>
	<xsl:attribute name="border-top">solid 0.5pt black</xsl:attribute>
	<xsl:attribute name="border-bottom">solid 0.5pt black</xsl:attribute>					
</xsl:template>

<xsl:template match="xhtml:tfoot//leg:Footnote">
	<xsl:variable name="nstTableFootnoteRefs" select="ancestor::xhtml:table/xhtml:tfoot//leg:Footnote" as="element(leg:Footnote)*"/>
	<xsl:variable name="strFootnoteRef" select="./@id"/>
	<fo:list-block provisional-label-separation="6pt" provisional-distance-between-starts="18pt">
		<fo:list-item>
			<fo:list-item-label start-indent="0pt" end-indent="label-end()">
				<fo:block  vertical-align="super" font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt" font-weight="bold">
					<xsl:choose>
						<xsl:when test="leg:Number">
							<xsl:apply-templates  select="leg:Number"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="leg:format-number-as-alpha(index-of($nstTableFootnoteRefs/@id,$strFootnoteRef))"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt">
					<xsl:apply-templates select="leg:FootnoteText"/>
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</fo:list-block>
	
</xsl:template>


</xsl:stylesheet>