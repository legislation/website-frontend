<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:template name="TSO_SecondaryPrelims">
	<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" line-height="{$g_strLineHeight}" font-size="{$g_strBodySize}" >

		<!--<xsl:apply-templates select="$statusWarningHTML" mode="statuswarning"/>-->
		
        <xsl:apply-templates select="$g_ndsLegPrelims/leg:Correction"/>
		<xsl:apply-templates select="$g_ndsLegPrelims/leg:Draft"/>

		<fo:block font-size="12pt" line-height="12pt" text-align="center" padding-top="9pt" padding-bottom="6pt" border-top="solid 1pt black" border-bottom="solid 1pt black" letter-spacing="3pt" space-after="24pt">
			<xsl:if test="$g_strDocStatus = $g_strConstantDocumentStatusDraft">
				<xsl:text>DRAFT  </xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$g_strDocType= 'NorthernIrelandStatutoryRule' or $g_strDocType='NorthernIrelandStatutoryRuleLocal' or $g_strDocType='NorthernIrelandDraftStatutoryRule' or $g_strDocType = 'NorthernIrelandStatutoryRuleOrOrder'">
					<xsl:text>STATUTORY  RULES OF NORTHERN IRELAND</xsl:text>
				</xsl:when>
				<xsl:when test="$g_strDocType= 'UnitedKingdomChurchInstrument'">
					<xsl:text>CHURCH  INSTRUMENTS</xsl:text>
				</xsl:when>
				<xsl:when test="$g_strDocType = 'ScottishStatutoryInstrument' or $g_strDocType='ScottishStatutoryInstrumentLocal' or $g_strDocType='ScottishDraftStatutoryInstrument'">
					<xsl:text>SCOTTISH STATUTORY  INSTRUMENTS</xsl:text>
				</xsl:when>
				<xsl:when test="$g_strDocType = 'UnitedKingdomMinisterialDirection'">
					<xsl:text>MINISTERIAL  DIRECTIONS</xsl:text>
				</xsl:when>

				<!-- Yashasri: Added to make welsh banner text correct HA049222-->
				<xsl:when test="($g_strDocType = 'WelshStatutoryInstrument' or $g_strDocType ='WelshStatutoryInstrumentLocal') and not(/(leg:Legislation | leg:EN)/ukm:Metadata/dc:language = 'cy')">WELSH STATUTORY INSTRUMENTS</xsl:when>
				<xsl:when test="($g_strDocType = 'WelshStatutoryInstrument' or $g_strDocType = 'WelshStatutoryInstrumentLocal') and /(leg:Legislation | leg:EN)/ukm:Metadata/dc:language = 'cy'">OFFERYNNAU STATUDOL CYMRU</xsl:when>
				<xsl:otherwise>
					<xsl:text>STATUTORY  INSTRUMENTS</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
		
		<fo:block font-size="18pt" line-height="24pt" text-align="center" font-weight="bold" space-after="12pt">
			<xsl:choose>
				<xsl:when test="$g_ndsLegPrelims/leg:Number">
					<xsl:apply-templates select="$g_ndsLegPrelims/leg:Number"/>
				</xsl:when>
				<xsl:when test="$g_ndsLegMetadata/ukm:Year">
					<xsl:apply-templates select="$g_ndsLegMetadata/ukm:Year/@Value"/>
					<xsl:text> No. </xsl:text>
					<xsl:apply-templates select="$g_ndsLegMetadata/ukm:Number/@Value"/>
				</xsl:when>
			</xsl:choose>
		</fo:block>
		
		<xsl:for-each select="$g_ndsLegPrelims/leg:SubjectInformation/leg:Subject">
			<fo:block font-size="18pt" line-height="24pt" text-align="center" font-weight="bold" text-transform="uppercase">
				<xsl:apply-templates select="leg:Title/node()"/>
			</fo:block>
			<xsl:if test="leg:Subtitle">
				<xsl:for-each select="leg:Subtitle">
					<fo:block font-size="14pt" line-height="24pt" text-align="center" font-weight="normal" text-transform="uppercase">
						<xsl:apply-templates select="node()"/>
					</fo:block>
				</xsl:for-each>
			</xsl:if>
		</xsl:for-each>
		
		<fo:block font-size="16pt" line-height="20pt" margin-top="18pt" text-align="center">
			<xsl:choose>
				<xsl:when test="$g_ndsLegPrelims/leg:Title">
					<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
				</xsl:when>
				<xsl:when test="/leg:Legislation/ukm:Metadata/dc:title">
					<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"/>
				</xsl:when>
			</xsl:choose>
		</fo:block>
		
		<xsl:if test="not($g_strDocType = 'NorthernIrelandStatutoryRule' or $g_strDocType = 'NorthernIrelandStatutoryRuleOrOrder')">
			<fo:block space-before="24pt" text-align="center" font-style="italic">
				<xsl:apply-templates select="$g_ndsLegPrelims/leg:Approved"/>
			</fo:block>
		</xsl:if>
		
        <!-- HA102182 - display LaidDraft Text centered when no date-->
		<xsl:if test="$g_ndsLegPrelims/leg:LaidDraft[not(leg:DateText)]">
			<fo:block text-align="center" font-style="italic">
				<xsl:attribute name="space-before" select="if ($g_ndsLegPrelims/leg:Approved) then '12pt' else '24pt'"/>
				<xsl:apply-templates select="$g_ndsLegPrelims/leg:LaidDraft/leg:Text/node()"/>
			</fo:block>
		</xsl:if>
		
		<xsl:if test="$g_ndsLegPrelims[leg:SiftedDate or leg:MadeDate or leg:LaidDate or leg:ComingIntoForce or leg:LaidDraft[leg:DateText]]">
			<fo:block text-align="center" margin-left="90pt" margin-right="90pt">
				<xsl:attribute name="space-before" select="if($g_ndsLegPrelims/leg:LaidDraft) then '0pt' else if($g_ndsLegPrelims[leg:Approved]) then '12pt' else '24pt'"/>
				<xsl:attribute name="space-after" select="if ($g_ndsLegPrelims[leg:Approved] and ($g_strDocType = 'NorthernIrelandStatutoryRule' or $g_strDocType = 'NorthernIrelandStatutoryRuleOrOrder')) then '0pt' else '24pt'"/>
				<fo:table font-size="{$g_strBodySize}" font-style="italic" margin-left="0pt" margin-right="0pt" table-layout="fixed" width="100%">
					<fo:table-column column-width="57%"/>
					<fo:table-column column-width="5%"/>
					<fo:table-column column-width="38%"/>	
					<fo:table-body margin-left="0pt" margin-right="0pt">
						<xsl:apply-templates select="$g_ndsLegPrelims/leg:LaidDraft[leg:DateText],
							 $g_ndsLegPrelims/leg:SiftedDate,							 
							 $g_ndsLegPrelims/leg:MadeDate,
							 $g_ndsLegPrelims/leg:LaidDate,
							 $g_ndsLegPrelims/leg:ComingIntoForce"/>
					</fo:table-body>
				</fo:table>		
			</fo:block>
		</xsl:if>

		<xsl:if test="$g_strDocType = 'NorthernIrelandStatutoryRule' or $g_strDocType = 'NorthernIrelandStatutoryRuleOrOrder'">
			<fo:block space-before="6pt" space-after="24pt" text-align="center" font-style="italic">
				<xsl:apply-templates select="$g_ndsLegPrelims/leg:Approved"/>
			</fo:block>
		</xsl:if>
		
		<xsl:apply-templates select="/leg:Legislation/leg:Contents"/>

		<xsl:apply-templates select="$g_ndsLegPrelims/leg:RoyalPresence,
            $g_ndsLegPrelims/leg:SecondaryPreamble/leg:RoyalPresence,
			$g_ndsLegPrelims/leg:Resolution,
			$g_ndsLegPrelims/leg:SecondaryPreamble/leg:IntroductoryText,
			$g_ndsLegPrelims/leg:SecondaryPreamble/leg:EnactingText"/>
		
		<!-- make sure we process any prelim annotations  -->
		<xsl:if test="not(/leg:Legislation/leg:Secondary/leg:SecondaryPrelims/@AltVersionRefs)">
			<xsl:apply-templates select="/leg:Legislation/leg:Secondary/leg:SecondaryPrelims" mode="ProcessAnnotations"/>
		</xsl:if>
		
		<xsl:apply-templates select="/leg:Legislation/leg:Secondary/leg:Body"/>
		
		<!-- #HA057536 - MJ: output resources if file contains no main content -->
		<xsl:apply-templates select="/leg:Legislation/leg:Resources[not(preceding-sibling::leg:Secondary)]"/>
		
		<!--<xsl:if test="not(/leg:Legislation/*/leg:Schedules)">
			<xsl:apply-templates select="$statusWarningHTML" mode="statuswarning"/>
		</xsl:if>-->
		<!-- this is a bodge fix to get around a FOP issue when there is not enough space on the end page for all the footnotes but if it takes a footnote over to the next page then there is enough space for the content to fit in on the first page where it tries to render the footnote back on the first page thus resulting in a loop --> 
		<xsl:if test="/leg:Legislation/leg:Footnotes">
			<fo:block font-size="{$g_strBodySize}" space-before="36pt" text-align="left" keep-with-next="always">
				<xsl:text>&#8203;</xsl:text>
			</fo:block>
		</xsl:if>
	</fo:flow>
</xsl:template>

<xsl:template match="leg:LaidDraft">
	<xsl:call-template name="TSOprocessDateItem"/>
</xsl:template>

<xsl:template match="leg:SiftedDate">
	<xsl:call-template name="TSOprocessDateItem"/>
</xsl:template>

<xsl:template match="leg:MadeDate">
	<xsl:call-template name="TSOprocessDateItem"/>
</xsl:template>

<xsl:template match="leg:LaidDate">
	<xsl:call-template name="TSOprocessDateItem"/>
</xsl:template>

<xsl:template match="leg:ComingIntoForce">
	<xsl:call-template name="TSOprocessDateItem"/>
	<xsl:apply-templates select="leg:ComingIntoForceClauses"/>
</xsl:template>

<xsl:template name="TSOprocessDateItem">
	<fo:table-row margin-left="0pt" margin-right="0pt" >
		<fo:table-cell text-align="left" display-align="after" height="18pt" margin-left="0pt" margin-right="0pt"> 
			<xsl:if test="not(leg:DateText)">
				<xsl:attribute name="number-columns-spanned">3</xsl:attribute>
			</xsl:if>
			<fo:block letter-spacing.maximum="0pt">
				<xsl:attribute name="text-align-last">
					<xsl:choose>
						<xsl:when test="leg:DateText">justify</xsl:when>
						<xsl:otherwise>left</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<fo:inline word-spacing.maximum="3pt">
					<xsl:apply-templates select="leg:Text/node()"/>
				</fo:inline>
				<xsl:if test="leg:DateText">
					<fo:inline>
						<xsl:text> </xsl:text>
						<xsl:text> </xsl:text>
					</fo:inline>
					<fo:leader leader-alignment="reference-area" leader-pattern="use-content" leader-length.maximum="100%">&#160;&#160;&#160;&#160;&#160;&#160;-&#160;&#160;&#160;&#160;&#160;&#160;-</fo:leader>					
				</xsl:if>
			</fo:block>
		</fo:table-cell>
		<xsl:if test="leg:DateText">
			<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
				<fo:block/>
			</fo:table-cell>
			<fo:table-cell text-align="right" display-align="after" margin-left="0pt" margin-right="0pt">
				<fo:block>
					<xsl:apply-templates select="leg:DateText"/>
				</fo:block>
			</fo:table-cell>
		</xsl:if>
	</fo:table-row>
</xsl:template>

<xsl:template match="leg:ComingIntoForceClauses">
	<fo:table-row margin-left="0pt" margin-right="0pt">
		<fo:table-cell text-align="left" display-align="after" height="18pt" margin-left="12pt" margin-right="0pt" padding-top="3pt"> 
			<xsl:if test="not(leg:DateText)">
				<xsl:attribute name="number-columns-spanned">3</xsl:attribute>
			</xsl:if>
			<fo:block letter-spacing.maximum="0pt">
				<xsl:attribute name="text-align-last">left</xsl:attribute>
				<xsl:apply-templates select="leg:Text/node()"/>
			</fo:block>
		</fo:table-cell>
		<xsl:if test="leg:DateText">
			<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
				<fo:block/>
			</fo:table-cell>
			<fo:table-cell text-align="right" display-align="after" margin-left="0pt" margin-right="0pt">
				<fo:block>
					<xsl:apply-templates select="leg:DateText"/>
				</fo:block>
			</fo:table-cell>
		</xsl:if>
	</fo:table-row>
	
	
</xsl:template>

<xsl:template match="leg:RoyalPresence">
	<fo:block text-align="center" space-before="24pt" space-after="12pt">
		<xsl:if test="/leg:Legislation/leg:Contents">
			<xsl:attribute name="space-before">24pt</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Resolution">
	<fo:block text-align="left" space-after="12pt" font-weight="bold">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>
	
<xsl:template match="leg:SecondaryPrelims/leg:Correction">
	<fo:block font-style="italic" text-align="justify" space-after="10pt">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>
	
<xsl:template match="leg:SecondaryPrelims/leg:Draft">
	<fo:block font-style="italic" text-align="justify" space-after="6pt">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Approved">
	<xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>