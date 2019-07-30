<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions">

<xsl:template match="leg:Contents" mode="MainContents">
	<fo:page-sequence master-reference="contents-sequence" initial-page-number="1" letter-value="auto" format="i" xml:lang="{$g_documentLanguage}">

		<xsl:call-template name="TSOcreateContentsHeadersFooters"/>
	
		<!-- Contents -->
		<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" line-height="{$g_strLineHeight}">
			
			<xsl:if test="not($g_strDocClass = ($g_strConstantSecondary, $g_strConstantEuretained)) or $g_strDocType = 'NorthernIrelandAct'">
				<fo:block text-align="center">
					<xsl:choose>
						<xsl:when test="$g_strDocType = 'ScottishAct'">
							<fo:external-graphic src="url({concat($g_strConstantImagesPath, 'asp.tif')})" content-height="98pt" fox:alt-text="Royal arms"/>
						</xsl:when>
						<xsl:when test="$g_strDocType = 'WelshAssemblyMeasure'">
							<fo:external-graphic src="url({concat($g_strConstantImagesPath, 'mwa.tif')})" content-height="110pt" fox:alt-text="Royal arms"/>
						</xsl:when>
						<xsl:when test="$g_strDocType = 'WelshNationalAssemblyAct'">
							<fo:external-graphic src="url({concat($g_strConstantImagesPath, 'mwa.tif')})" content-height="110pt" fox:alt-text="Royal arms"/>
						</xsl:when>
						<xsl:otherwise>
							<fo:external-graphic src="url({concat($g_strConstantImagesPath, 'ukpga.tif')})" content-height="128pt" fox:alt-text="Royal arms"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>

				<xsl:choose>
					<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
						<fo:block font-size="20pt" line-height="24pt" margin-top="30pt" text-align="center" font-weight="bold">
							<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
						</fo:block>
					</xsl:when>
					<xsl:otherwise>
						<fo:block font-size="24pt" line-height="30pt" margin-top="30pt" text-align="center">
							<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
						</fo:block>
					</xsl:otherwise>
				</xsl:choose>			

				<fo:block font-size="12pt" font-weight="bold"  text-align="center">
					<xsl:if test="$g_strDocType = 'NorthernIrelandAct'">
						<xsl:attribute name="font-weight">normal</xsl:attribute>
					</xsl:if>
					<xsl:variable name="year" select="$g_ndsLegMetadata//ukm:Year/@Value"/>
					<xsl:choose>
						<xsl:when test="$g_strDocType = 'ScottishAct'">
							<xsl:value-of select="$year"/>
							<xsl:choose>
								<xsl:when test="if ($year castable as xs:integer) then xs:integer($year) &lt; 1800 else false()">
									<xsl:text> c. </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> asp </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!--issue 161 we need to format old scottish acts to c. -->
						<xsl:when test="$g_strDocType = 'ScottishOldAct'">
							<xsl:value-of select="$year"/>
							<xsl:text> c. </xsl:text>
						</xsl:when>
						<!-- addedy by Yash call	HA051710 - corrected number for wlaes measures and act-->
						<xsl:when test="$g_strDocType = 'WelshAssemblyMeasure'">
							<xsl:value-of select="$year"/>
							<xsl:choose >
								<xsl:when test="$g_documentLanguage = 'cy'">
									<xsl:text> mccc </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> nawm </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$g_strDocType = 'WelshNationalAssemblyAct'">
							<xsl:value-of select="$year"/>
							<xsl:choose >
								<xsl:when test="$g_documentLanguage = 'cy'">
									<xsl:text> dccc </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> anaw </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>	
						<xsl:when test="$g_strDocType = $g_strConstantEuretained">
							
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="margin-top">18pt</xsl:attribute>
							<xsl:text>CHAPTER </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
                    	<xsl:when test="$g_strDocType = 'UnitedKingdomLocalAct'">
                    		<xsl:number format="i" value="$g_ndsLegMetadata//ukm:Number/@Value"/>
                    	</xsl:when>
                    	<xsl:otherwise>
                    		<xsl:value-of select="$g_ndsLegMetadata//ukm:Number/@Value"/>
                    	</xsl:otherwise>
                    </xsl:choose>
				</fo:block>	
			</xsl:if>
			
			<xsl:if test="$g_strDocClass = $g_strConstantEuretained">
				<fo:block font-size="24pt" line-height="30pt" margin-top="12pt" text-align="center">
					<xsl:choose>
						<xsl:when test="$g_strDocType = 'EuropeanUnionRegulation'">
							<xsl:text>REGULATIONS</xsl:text>
						</xsl:when>
						<xsl:when test="$g_strDocType = 'EuropeanUnionDecision'">
							<xsl:text>DECISIONS</xsl:text>
						</xsl:when>
						<xsl:when test="$g_strDocType = 'EuropeanUnionDirective'">
							<xsl:text>DIRECTIVES</xsl:text>
						</xsl:when>
					</xsl:choose>
				</fo:block>
				<fo:block font-size="12pt" line-height="14pt" margin-top="12pt" text-align="center">
					<xsl:choose>
						<xsl:when test="$g_ndsLegPrelims/leg:Title">
							<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</xsl:if>
			
			<xsl:if test="$g_strDocClass = $g_strConstantSecondary and $g_strDocType != 'NorthernIrelandAct'">
				<fo:block font-size="12pt" line-height="12pt" text-align="center" padding-top="9pt" padding-bottom="6pt" border-top="solid 1pt black" border-bottom="solid 1pt black" letter-spacing="3pt" space-after="24pt">
			<xsl:if test="$g_strDocStatus = $g_strConstantDocumentStatusDraft">
				<xsl:text>DRAFT  </xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$g_strDocType= 'NorthernIrelandStatutoryRule' or $g_strDocType='NorthernIrelandStatutoryRuleLocal' or $g_strDocType='NorthernIrelandDraftStatutoryRule' or $g_strDocType= 'NorthernIrelandStatutoryRuleOrOrder'">
					<xsl:text>STATUTORY  RULES OF NORTHERN IRELAND</xsl:text>
				</xsl:when>
				<xsl:when test="$g_strDocType = 'ScottishStatutoryInstrument' or $g_strDocType='ScottishStatutoryInstrumentLocal' or $g_strDocType='ScottishDraftStatutoryInstrument'">
					<xsl:text>SCOTTISH STATUTORY  INSTRUMENTS</xsl:text>
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
		
		<xsl:if test="not($g_strDocType = 'NorthernIrelandStatutoryRule') and not($g_strDocType = 'NorthernIrelandStatutoryRuleOrOrder')">
			<fo:block space-before="24pt" text-align="center" font-style="italic">
				<xsl:apply-templates select="$g_ndsLegPrelims/leg:Approved"/>
			</fo:block>
		</xsl:if>

		<xsl:if test="$g_ndsLegPrelims/leg:LaidDraft">
			<fo:block text-align="center" font-style="italic">
				<xsl:attribute name="space-before" select="if ($g_ndsLegPrelims/leg:Approved) then '12pt' else '24pt'"/>
				<xsl:apply-templates select="$g_ndsLegPrelims/leg:LaidDraft/leg:Text/node()"/>
			</fo:block>
		</xsl:if>
		
				<xsl:if test="$g_ndsLegPrelims[leg:SiftedDate or leg:MadeDate or leg:LaidDate or leg:ComingIntoForce]">
			<fo:block text-align="center" margin-left="96pt" margin-right="96pt" >
				<xsl:attribute name="space-before" select="if ($g_ndsLegPrelims[leg:Approved or leg:LaidDraft]) then '12pt' else '24pt'"/>
				<xsl:attribute name="space-after" select="if ($g_ndsLegPrelims[leg:Approved] and ($g_strDocType = 'NorthernIrelandStatutoryRule' or $g_strDocType = 'NorthernIrelandStatutoryRuleOrOrder')) then '0pt' else '24pt'"/>
				<fo:table font-size="{$g_strBodySize}" font-style="italic" margin-left="0pt" margin-right="0pt" table-layout="fixed" width="100%">
					<fo:table-column column-width="50%"/>
					<fo:table-column column-width="10%"/>
					<fo:table-column column-width="40%"/>	
					<fo:table-body margin-left="0pt" margin-right="0pt">
						<xsl:apply-templates select="$g_ndsLegPrelims/leg:SiftedDate,
							 $g_ndsLegPrelims/leg:MadeDate,
							 $g_ndsLegPrelims/leg:LaidDate,
							 $g_ndsLegPrelims/leg:ComingIntoForce"/>
					</fo:table-body>
				</fo:table>		
			</fo:block>
		</xsl:if>
		
		<xsl:if test="$g_strDocType = 'NorthernIrelandStatutoryRule' or $g_strDocType = 'NorthernIrelandStatutoryRuleOrOrder'">
			<fo:block space-before="6pt" space-after="24pt" text-align="center" font-style="italic" font-size="11pt">
				<xsl:apply-templates select="$g_ndsLegPrelims/leg:Approved"/>
			</fo:block>
		</xsl:if>
		
			</xsl:if>
			
			
			
			<xsl:apply-templates select="."/>
			
			
		
			
			
			
		</fo:flow>
	</fo:page-sequence>
</xsl:template>



<!-- fix for  issue D498 - missing sig  block in ToC  -->
<xsl:template match="leg:Contents/*[not(self::leg:ContentsTitle) and not(ancestor::leg:BlockAmendment) and not(self::leg:ContentsSchedules)][position()=last()]" priority="1000">
	<xsl:next-match />
	<xsl:if test="$signatureURI">
		<fo:table font-size="{$g_strBodySize}">
			<xsl:call-template name="column-widths"/>
			<fo:table-body>
				<xsl:for-each select=". | following-sibling::leg:ContentsItem">
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="right">&#160;</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}">&#160;</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="left" space-after="3pt">
								<xsl:value-of select="$signatureText"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}">&#160;</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>	
	</xsl:if>
</xsl:template>

<!-- fix for  issue D498 - missing EN in ToC  -->
<xsl:template match="leg:Contents/*[not(self::leg:ContentsTitle) and not(ancestor::leg:BlockAmendment)][position()=last()]" priority="2000">
	<xsl:param name="matchRefs" tunnel="yes" select="''" />
	<xsl:next-match />
	
	<xsl:if test="$noteURI">
		<fo:table font-size="{$g_strBodySize}">
			<xsl:call-template name="column-widths"/>
			<fo:table-body>
				<xsl:for-each select=". | following-sibling::leg:ContentsItem">
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="right">&#160;</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}">&#160;</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="left" space-after="3pt">
								<xsl:value-of select="$noteText"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}">&#160;</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>	
	</xsl:if>
</xsl:template>


<xsl:template match="leg:Contents/leg:ContentsTitle[$g_strDocClass = $g_strConstantEuretained]"  priority="2000"/>



<xsl:template name="TSOcreateContentsHeadersFooters">
	<!-- Header for even pages -->
	<xsl:if test="$g_strDocClass != $g_strConstantSecondary">
		<fo:static-content flow-name="even-before">
			<xsl:choose>
				<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="20%"/>									
						<fo:table-column column-width="60%"/>
						<fo:table-column column-width="20%"/>
						<fo:table-body margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}">
										<xsl:text>c. </xsl:text>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row border-bottom="solid 0.5pt black" border-top="solid 0.5pt black" >
						<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center" >
							<fo:block>
								<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
						</fo:table-body>
					</fo:table>
				</xsl:when>	
				
				<xsl:when test="$g_strDocType = 'ScottishAct'">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="20%"/>									
						<fo:table-column column-width="80%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" font-size="10pt" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
										<xsl:text> asp </xsl:text>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:when>
				<!-- addedy by Yash call	HA051710 - corrected number for wlaes measures and act-->
				<xsl:when test="$g_strDocType = 'WelshAssemblyMeasure'">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="20%"/>									
						<fo:table-column column-width="80%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" font-size="10pt" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
										<xsl:choose>
											<xsl:when test="$g_documentLanguage = 'cy'">
												<xsl:text> mccc </xsl:text>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text> nawm </xsl:text>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row border-bottom="solid 0.5pt black" border-top="solid 0.5pt black" >
								<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center" >
									<fo:block>
										<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</xsl:when>				
				<xsl:when test="$g_strDocType = 'WelshNationalAssemblyAct'">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="20%"/>									
						<fo:table-column column-width="80%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" font-size="10pt" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
										<xsl:choose>
											<xsl:when test="$g_documentLanguage = 'cy'">
												<xsl:text> dccc </xsl:text>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text> anaw </xsl:text>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:when>	
				<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="20%"/>									
						<fo:table-column column-width="80%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" font-size="10pt" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:abridgeContent(/leg:Legislation/ukm:Metadata/dc:title, 15)"  mode="header"/>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:when>
				<xsl:otherwise>
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="20%"/>									
						<fo:table-column column-width="80%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" font-size="10pt" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
										<xsl:text> (c. </xsl:text>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
										<xsl:text>)</xsl:text>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:otherwise>
			</xsl:choose>
		</fo:static-content>	
		

	<fo:static-content flow-name="footer-only-before">
			<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
				<fo:table-column column-width="20%"/>
				<fo:table-column column-width="80%"/>									
				<fo:table-body border-bottom="solid 0.5pt black" border-top="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
					<xsl:call-template name="statusWarningHeader"/>
				</fo:table-body>
			</fo:table>
		</fo:static-content>	
		
		<!-- Header for odd pages -->
		<fo:static-content flow-name="odd-before">
			<xsl:choose>
				<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="20%"/>	
						<fo:table-column column-width="60%"/>									
						<fo:table-column column-width="20%"/>
						<fo:table-body margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
										<xsl:call-template name="TSOdocDateTime"/>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}">
										<xsl:text>c. </xsl:text>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:when>
				<xsl:when test="$g_strDocType = 'ScottishAct'">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="80%"/>									
						<fo:table-column column-width="20%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
										<xsl:text> asp </xsl:text>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}" font-size="10pt">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:when>
				<!-- addedy by Yash call	HA051710 - corrected number for wlaes measures and act-->
				<xsl:when test="$g_strDocType = 'WelshAssemblyMeasure'">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="80%"/>									
						<fo:table-column column-width="20%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
										<xsl:choose>
											<xsl:when test="$g_documentLanguage = 'cy'">
												<xsl:text> mccc </xsl:text>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text> nawm </xsl:text>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}" font-size="10pt">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:when>
				
				
				
				<xsl:when test="$g_strDocType = 'WelshNationalAssemblyAct'">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="80%"/>									
						<fo:table-column column-width="20%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
										<xsl:choose>
											<xsl:when test="$g_documentLanguage = 'cy'">
												<xsl:text> dccc </xsl:text>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text> anaw </xsl:text>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}" font-size="10pt">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:when>
				
				<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="80%"/>									
						<fo:table-column column-width="20%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:abridgeContent(/leg:Legislation/ukm:Metadata/dc:title, 15)"  mode="header"/>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}" font-size="10pt">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:when>
				<xsl:otherwise>
					<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt">
						<fo:table-column column-width="80%"/>									
						<fo:table-column column-width="20%"/>
						<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
							<fo:table-row margin-left="0pt" margin-right="0pt">
								<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
									<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
										<xsl:apply-templates select="leg:ContentsTitle"/>
										<xsl:text> (c. </xsl:text>
										<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
										<xsl:text>)</xsl:text>
									</fo:block>
									<xsl:call-template name="TSOdocDateTime"/>
								</fo:table-cell>
								<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
									<fo:block font-family="{$g_strMainFont}" font-size="10pt">
										<fo:inline><fo:page-number/></fo:inline>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<xsl:call-template name="statusWarningHeader"/>
						</fo:table-body>
					</fo:table>
				</xsl:otherwise>
			</xsl:choose>
		</fo:static-content>		
	</xsl:if>
	
	<xsl:if test="$g_strDocClass = $g_strConstantSecondary">
		<!-- Header for even pages -->
		<fo:static-content flow-name="even-before">
			<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
				<fo:table-column column-width="20%"/>
				<fo:table-column column-width="80%"/>									
				<fo:table-body margin-left="0pt" margin-right="0pt">
					<fo:table-row margin-left="0pt" margin-right="0pt" >
						<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt">
							<fo:block font-family="{$g_strMainFont}">
								<fo:inline>
									
								</fo:inline>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
							<xsl:call-template name="TSOdocDateTime"/>
						</fo:table-cell>
					</fo:table-row>
					<xsl:call-template name="statusWarningHeader"/>
				</fo:table-body>
			</fo:table>
		</fo:static-content>			

		<fo:static-content flow-name="footer-only-before">
			<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
				<fo:table-column column-width="20%"/>
				<fo:table-column column-width="80%"/>									
				<fo:table-body border-bottom="solid 0.5pt black" border-top="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
					<xsl:call-template name="statusWarningHeader"/>
				</fo:table-body>
			</fo:table>
		</fo:static-content>	
		<!-- Header for odd pages -->
		<fo:static-content flow-name="odd-before">
			<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
				<fo:table-column column-width="80%"/>									
				<fo:table-column column-width="20%"/>
				<fo:table-body margin-left="0pt" margin-right="0pt">
					<fo:table-row margin-left="0pt" margin-right="0pt" >
						<fo:table-cell margin-left="0pt" margin-right="0pt">
							<xsl:call-template name="TSOdocDateTime"/>									
						</fo:table-cell>
						<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
							<fo:block font-family="{$g_strMainFont}" font-size="10pt">
								<fo:inline>
									
								</fo:inline>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<xsl:call-template name="statusWarningHeader"/>
				</fo:table-body>
			</fo:table>
		</fo:static-content>		
	</xsl:if>
	
	<!-- Footers for pages - only for NI Acts -->
	<xsl:if test="$g_strDocType = 'NorthernIrelandAct'">
		<fo:static-content flow-name="even-after">
			<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" text-align="center">
				<fo:inline><fo:page-number/></fo:inline>
			</fo:block>
		</fo:static-content>
		<fo:static-content flow-name="odd-after">
			<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" text-align="center">
				<fo:inline><fo:page-number/></fo:inline>
			</fo:block>
		</fo:static-content>
	</xsl:if>
	
	
</xsl:template>

<xsl:template match="leg:Contents">
	<fo:block font-size="14pt" space-before="30pt" text-align="center" space-after="0pt" text-transform="uppercase">
		<xsl:if test="$g_strDocType = 'NorthernIrelandAct'">
			<xsl:attribute name="space-before">48pt</xsl:attribute>
		</xsl:if>
		<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
			<xsl:attribute name="space-after">36pt</xsl:attribute>
		</xsl:if>
		<xsl:if test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:attribute name="space-after">36pt</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="leg:ContentsTitle"/>
	</fo:block>
	<xsl:apply-templates select="*[not(self::leg:ContentsTitle)]"/>
</xsl:template>

<xsl:template match="leg:ContentsSchedules">
	<fo:block text-align="center" space-before="12pt" space-after="12pt" keep-with-next="always">
		<fo:leader leader-length="96pt" leader-pattern="rule" alignment-adjust="after-edge" rule-thickness="0.5pt"/><!--   alignment-baseline="top"   -->
	</fo:block>		
	<xsl:if test="leg:ContentsNumber">
		<fo:block font-size="{$g_strBodySize}" font-variant="small-caps" font-weight="bold" text-align="center" keep-with-next="always">
			<xsl:attribute name="space-before" select="if (preceding-sibling::leg:ContentsPart) then '24pt' else '12pt'"/>
			<xsl:apply-templates select="leg:ContentsNumber"/>
		</fo:block>
	</xsl:if>
	<xsl:if test="leg:ContentsTitle">
		<fo:block font-size="{$g_strBodySize}" font-variant="small-caps" space-before="12pt" text-align="center" keep-with-next="always">
			<xsl:apply-templates select="leg:ContentsTitle"/>
		</fo:block>
	</xsl:if>
	<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
</xsl:template>

<xsl:template match="leg:ContentsSchedule|leg:ContentsAppendix">
	<xsl:choose>
		<xsl:when test="$g_strDocType = ('NorthernIrelandStatutoryRule', 'WelshStatutoryInstrument', 'NorthernIrelandStatutoryRuleOrOrder')">
			<fo:table font-size="{$g_strBodySize}">
				<xsl:call-template name="column-widths"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="right">
								<xsl:apply-templates select="leg:ContentsNumber"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}"/>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="left">
								<xsl:apply-templates select="leg:ContentsTitle"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>	
			<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>			
		</xsl:when>
		<xsl:when test="$g_strDocType = 'ScottishStatutoryInstrument'">
			<fo:table font-size="{$g_strBodySize}">
				<fo:table-column column-width="35%"/>
				<fo:table-column column-width="5%"/>		
				<fo:table-column column-width="60%"/>	
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="right">
								<xsl:apply-templates select="leg:ContentsNumber"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}"></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="left">
								<xsl:apply-templates select="leg:ContentsTitle"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>	
			<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
		</xsl:when>
		<xsl:when test="$g_strDocType = ('EuropeanUnionRegulation','EuropeanUnionDecision','EuropeanUnionDirective')">
			<fo:block font-size="{$g_strBodySize}" text-align="center" keep-with-next="always" space-before="24pt">
				<xsl:apply-templates select="leg:ContentsNumber"/>
			</fo:block>
			<fo:block font-size="{$g_strBodySize}" space-before="6pt" text-align="center" keep-with-next="always" space-after="12pt">
				<xsl:if test="not(leg:ContentsNumber)">
					<xsl:attribute name="space-before">12pt</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="leg:ContentsTitle"/>
			</fo:block>
			<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
		</xsl:when>
		<xsl:otherwise>			
			<fo:block space-after="12pt">
				<!--<xsl:if test="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]">
					<xsl:attribute name="keep-together.within-page">always</xsl:attribute>
				</xsl:if>-->
				<fo:table font-size="{$g_strBodySize}" space-before="0pt" space-after="0pt">
					<fo:table-column column-width="25%"/>
					<fo:table-column column-width="5%"/>
					<fo:table-column column-width="70%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell>
								<fo:block font-size="{$g_strBodySize}" text-align="right">
									<xsl:apply-templates select="leg:ContentsNumber"/>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block font-size="{$g_strBodySize}" text-align="center">
									<xsl:text>&#8212;</xsl:text>
								</fo:block>
							</fo:table-cell>						
							<fo:table-cell>
								<fo:block font-size="{$g_strBodySize}" text-align="left">
									<xsl:apply-templates select="leg:ContentsTitle"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
				<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
			</fo:block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:ContentsPart[ancestor::leg:ContentsSchedule or ancestor::leg:ContentsAppendix or ancestor::leg:ContentsGroup]">
	<xsl:choose>
		<xsl:when test="$g_strDocType = 'ScottishStatutoryInstrument'">
			<fo:table font-size="{$g_strBodySize}" space-before="0pt" space-after="0pt">
				<fo:table-column column-width="40%"/>
				<fo:table-column column-width="10%"/>
				<fo:table-column column-width="3%"/>		
				<fo:table-column column-width="47%"/>	
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}"></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="left">
								<xsl:apply-templates select="leg:ContentsNumber"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}"></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="left" space-after="3pt">
								<xsl:apply-templates select="leg:ContentsTitle"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>	
		</xsl:when>
		<xsl:otherwise>
			<fo:table font-size="{$g_strBodySize}" space-before="0pt" space-after="0pt">
				<fo:table-column column-width="25%"/>
				<fo:table-column column-width="5%"/>				
				<fo:table-column column-width="70%"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="right">
								<xsl:apply-templates select="leg:ContentsNumber"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="center">
								<xsl:if test="leg:ContentsTitle[node()]">
									<xsl:if test="not(self::leg:ContentsGroup)"><xsl:text>&#8212;</xsl:text></xsl:if>
								</xsl:if>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="{$g_strBodySize}" text-align="left">
								<xsl:apply-templates select="leg:ContentsTitle"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>		
		</xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
</xsl:template>

<xsl:template match="leg:ContentsPart | leg:ContentsEUPart | leg:ContentsEUTitle">
	<fo:block font-size="{$g_strBodySize}" text-align="center" keep-with-next="always">
		<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
			<xsl:attribute name="font-variant">small-caps</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="space-before">
			<xsl:choose>
				<xsl:when test="preceding-sibling::leg:ContentsTitle">6pt</xsl:when>
				<xsl:when test="preceding-sibling::leg:ContentsPart">12pt</xsl:when>
				<xsl:otherwise>24pt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates select="leg:ContentsNumber"/>
	</fo:block>
	<fo:block font-size="{$g_strBodySize}" space-before="6pt" text-align="center" keep-with-next="{leg:keep-with-next(.)}">
		<xsl:if test="not(leg:ContentsNumber)">
			<xsl:attribute name="space-before">12pt</xsl:attribute>
		</xsl:if>
		<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
			<xsl:attribute name="font-variant">small-caps</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="space-after">
			<xsl:choose>
				<xsl:when test="ContentsPblock">0pt</xsl:when>
				<xsl:otherwise>12pt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates select="leg:ContentsTitle"/>
	</fo:block>
	<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
</xsl:template>

<xsl:template match="leg:ContentsChapter | leg:ContentsEUChapter | leg:ContentsEUSection | leg:ContentsEUSubsection">
	<fo:block font-size="{$g_strBodySize}" text-align="center" keep-with-next="always" space-before="12pt">
		<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
			<xsl:attribute name="font-variant">small-caps</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="leg:ContentsNumber"/>
	</fo:block>
	<fo:block font-size="{$g_strBodySize}" space-before="12pt" text-align="center" 
			keep-with-next="{leg:keep-with-next(.)}">
		<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
			<xsl:attribute name="font-variant">small-caps</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="space-after">
			<xsl:choose>
				<xsl:when test="contentsPblock">0pt</xsl:when>
				<xsl:otherwise>12pt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates select="leg:ContentsTitle"/>
	</fo:block>
	<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
</xsl:template>


<xsl:template match="leg:ContentsDivision">
	<xsl:variable name="indent" select="(count(ancestor::leg:ContentsDivision) + 1) * 36"/>
	<xsl:variable name="start-indent" select="count(ancestor::leg:ContentsDivision) * 36"/>
	<fo:block>
		<fo:list-block provisional-label-separation="3pt" provisional-distance-between-starts="36pt">	
			<xsl:if test="not(ancestor::leg:ContentsDivision)">
			<xsl:attribute name="space-before">12pt</xsl:attribute>
		</xsl:if>
			<fo:list-item>
				<xsl:call-template name="TSOgetID"/>
				<fo:list-item-label start-indent="{$start-indent}pt">
					<fo:block font-size="{$g_strBodySize}" text-align="left" margin-left="0pt">
						<xsl:apply-templates select="leg:ContentsNumber"/>
					</fo:block>						
				</fo:list-item-label>
				<fo:list-item-body start-indent="{$indent}pt" end-indent="0pt">
					<fo:block font-size="{$g_strBodySize}" text-align="justify">
						<xsl:apply-templates select="leg:ContentsTitle"/>
					</fo:block>	
				</fo:list-item-body>
			</fo:list-item>	
		</fo:list-block>
		<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:ContentsPblock">
	<xsl:if test="leg:contentsNumber">
		<fo:block font-size="{$g_strBodySize}" space-before="12pt" text-align="center" keep-with-next="always">
			<xsl:apply-templates select="leg:ContentsNumber"/>
		</fo:block>
	</xsl:if>
	<fo:block font-size="{$g_strBodySize}" font-style="italic" space-before="12pt" space-after="6pt" text-align="center" keep-with-next="always">
		<xsl:apply-templates select="leg:ContentsTitle"/>
	</fo:block>
	<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
</xsl:template>

<xsl:template match="leg:ContentsGroup">
	<xsl:if test="leg:contentsNumber">
		<fo:block font-size="{$g_strBodySize}" space-before="12pt" font-weight="bold" text-align="center" keep-with-next="always">
			<xsl:apply-templates select="leg:ContentsNumber"/>
		</fo:block>
	</xsl:if>
	<fo:block font-size="{$g_strBodySize}" font-style="italic" font-weight="bold" space-before="12pt" space-after="6pt" text-align="center" keep-with-next="always">
		<xsl:apply-templates select="leg:ContentsTitle"/>
	</fo:block>
	<xsl:apply-templates select="*[not(self::leg:ContentsNumber or self::leg:ContentsTitle)]"/>
</xsl:template>

<xsl:template match="leg:ContentsItem[not(preceding-sibling::leg:ContentsItem)]">
	<fo:table font-size="{$g_strBodySize}">
		<xsl:call-template name="column-widths"/>
		<fo:table-body>
			<xsl:for-each select=". | following-sibling::leg:ContentsItem">
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-size="{$g_strBodySize}" text-align="right">
							<xsl:for-each select="leg:ContentsNumber">
								<xsl:apply-templates select="."/>
								<xsl:if test="$g_strDocClass = $g_strConstantSecondary and . castable as xs:integer">
									<xsl:text>.</xsl:text>
								</xsl:if>
								<xsl:if test="following-sibling::leg:ContentsNumber">
									<xsl:text>&#160;</xsl:text>
								</xsl:if>
							</xsl:for-each>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block font-size="{$g_strBodySize}">&#160;</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block font-size="{$g_strBodySize}" text-align="left" space-after="3pt">
							<xsl:apply-templates select="leg:ContentsTitle"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block font-size="{$g_strBodySize}">&#160;</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</xsl:for-each>
		</fo:table-body>
	</fo:table>		
</xsl:template>

<xsl:template match="leg:ContentsItem[preceding-sibling::leg:ContentsItem]"/>

<xsl:template match="leg:ContentsPart[not(ancestor::leg:ContentsSchedule) or not(ancestor::leg:ContentsAppendix)]/leg:ContentsTitle | leg:ContentsChapter/leg:ContentsTitle | leg:ContentsPart[not(ancestor::leg:ContentsSchedule)]/leg:ContentsNumber | leg:ContentsChapter/leg:ContentsNumber">
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
</xsl:template>

<xsl:template name="column-widths">
	<xsl:choose>
		<xsl:when test="$g_strDocType = ('NorthernIrelandStatutoryRule', 'WelshStatutoryInstrument', 'NorthernIrelandStatutoryRuleOrOrder') or $g_strDocClass = $g_strConstantEuretained">
			<fo:table-column column-width="15%"/>
			<fo:table-column column-width="5%"/>		
			<fo:table-column column-width="70%"/>	
			<fo:table-column column-width="10%"/>
		</xsl:when>
		<xsl:otherwise>
			<fo:table-column column-width="10%"/>
			<fo:table-column column-width="3%"/>		
			<fo:table-column column-width="77%"/>	
			<fo:table-column column-width="10%"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:function name="leg:keep-with-next" as="xs:string">
	<xsl:param name="node" as="element()"/>
	<xsl:value-of select="if ($node/*[self::leg:ContentsPart or	
										self::leg:ContentsEUPart or
										self::leg:ContentsEUTitle or
										self::leg:ContentsChapter or
										self::leg:ContentsEUChapter or
										self::leg:ContentsEUSection or
										self::leg:ContentsEUSubsection or
										self::leg:ContentsDivision or
										self::leg:ContentsItem]) then 'always' else 'auto'"/>
	
</xsl:function>

</xsl:stylesheet>