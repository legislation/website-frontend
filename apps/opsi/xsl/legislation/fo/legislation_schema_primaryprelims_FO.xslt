<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dct="http://purl.org/dc/terms/" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions">

	<xsl:template name="TSO_PrimaryPrelims">
		<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" line-height="{$g_strLineHeight}" white-space-collapse="false" line-height-shift-adjustment="disregard-shifts">

			<!--<xsl:apply-templates select="$statusWarningHTML" mode="statuswarning"/>-->
			<!-- #D456 we do not need monarch info on generated PDFs as this would be incorrect for pre-1953-->
			<!--<xsl:if test="not($g_strDocType = 'ScottishAct'or $g_strDocType = 'NorthernIrelandAct') and $g_ndsLegMetadata/ukm:Number/@Value != ''">
				<fo:table font-size="10pt" space-after="6pt" table-layout="fixed" width="100%">
									<fo:table-column column-width="10%"/>
				<fo:table-column column-width="80%"/>
				<fo:table-column column-width="10%"/>
					<fo:table-body>
						
						<fo:table-row>
							<fo:table-cell>
								<fo:block font-size="10pt">
								</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block font-size="10pt" text-align="center" font-weight="bold">
									<xsl:text>ELIZABETH II</xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block font-size="10pt" text-align="right">
									<xsl:text>c. </xsl:text>
									<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</xsl:if>-->
			<fo:block text-align="center">
				<!--<xsl:if test="$g_ndsLegMetadata/ukm:Number/@Value != ''">
				<fo:marker marker-class-name="runninghead2">
					<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
					<xsl:text> (c. </xsl:text>
					<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
					<xsl:text>)</xsl:text>
				</fo:marker>	
			</xsl:if>-->
				<xsl:choose>
					<xsl:when test="$g_ndsLegMetadata/ukm:Number/@Value != '' and  $g_strDocType = 'ScottishAct'">
						<fo:marker marker-class-name="runninghead2">
							<xsl:choose>
								<xsl:when test="$g_ndsLegPrelims/leg:Title">
									<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"  mode="header"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"  mode="header"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text> asp </xsl:text>
							<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
						</fo:marker>
					</xsl:when>
					<!-- addedy by Yash call	HA051710 - corrected number for wlaes measures and act-->
					<xsl:when test="$g_ndsLegMetadata/ukm:Number/@Value != '' and  $g_strDocType = 'WelshAssemblyMeasure'">
						<fo:marker marker-class-name="runninghead2">
							<xsl:choose>
								<xsl:when test="$g_ndsLegPrelims/leg:Title">
									<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"  mode="header"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"  mode="header"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="$g_documentLanguage = 'cy'">
									<xsl:text> mccc </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> nawm </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
						</fo:marker>
					</xsl:when>	
					
					<xsl:when test="$g_ndsLegMetadata/ukm:Number/@Value != '' and  $g_strDocType = 'WelshNationalAssemblyAct'">
						<fo:marker marker-class-name="runninghead2">
							<xsl:choose>
								<xsl:when test="$g_ndsLegPrelims/leg:Title">
									<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"  mode="header"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"  mode="header"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="$g_documentLanguage = 'cy'">
									<xsl:text> dccc </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> anaw </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
						</fo:marker>
					</xsl:when>
					
					
					<xsl:when test="$g_ndsLegMetadata/ukm:Number/@Value != ''">
						<fo:marker marker-class-name="runninghead2">
							<xsl:choose>
								<xsl:when test="$g_ndsLegPrelims/leg:Title">
									<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"  mode="header"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"  mode="header"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text> (c. </xsl:text>
							<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
							<xsl:text>)</xsl:text>
						</fo:marker>
					</xsl:when>
					<xsl:otherwise>
						<fo:marker marker-class-name="runninghead2">
							<xsl:text>&#8203;</xsl:text>
						</fo:marker>
					</xsl:otherwise>
				</xsl:choose>
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
						<fo:external-graphic src="url({concat($g_strConstantImagesPath, 'ukpga.tif')})" content-height="112pt" fox:alt-text="Royal arms"/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:block>
			<xsl:choose>
				<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
					<fo:block font-size="20pt" line-height="24pt" margin-top="12pt" text-align="center">
						<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:block font-size="24pt" line-height="30pt" margin-top="12pt" text-align="center">
						<xsl:choose>
							<xsl:when test="$g_ndsLegPrelims/leg:Title">
								<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:block>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$g_ndsLegMetadata/ukm:Year/@Value != ''">
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
					<!-- if the leg:Number has a commentry ref then we need to include this  (see apni1964/36/introduction #HA05037 -->
					<xsl:if test="$g_ndsLegPrelims/leg:Number/leg:CommentaryRef">
						<xsl:apply-templates select="$g_ndsLegPrelims/leg:Number/leg:CommentaryRef"/>
					</xsl:if>
					<xsl:value-of select="$g_ndsLegMetadata/ukm:Year/@Value"/>
					<xsl:choose>
						<xsl:when test="$g_strDocType = 'ScottishAct'">
							<xsl:text> asp </xsl:text>
						</xsl:when>
						<!-- addedy by Yash call	HA051710 - corrected number for wlaes measures and act-->
						<xsl:when test="$g_strDocType = 'WelshAssemblyMeasure'">						
							<xsl:choose>
								<xsl:when test="$g_documentLanguage = 'cy'">
									<xsl:text> mccc </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> nawm </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$g_strDocType = 'WelshNationalAssemblyAct'">						
							<xsl:choose>
								<xsl:when test="$g_documentLanguage = 'cy'">
									<xsl:text> dccc </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> anaw </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
					<xsl:when test="$g_strDocType = 'UnitedKingdomChurchMeasure'">
						<xsl:text> No. </xsl:text>
					</xsl:when>
						<xsl:otherwise>
							<xsl:text> CHAPTER </xsl:text>
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
					 <xsl:for-each select="$g_ndsLegMetadata//ukm:AlternativeNumber">
                    	<xsl:if test="@Category = 'Regnal'">
	                      <xsl:text> </xsl:text>
	                      <xsl:value-of select="translate(@Value,'_',' ')"/>
                    	</xsl:if>
                    </xsl:for-each>
				</fo:block>
			</xsl:if>
			
			
			<!-- we need to apply-templates for PrimaryPrelims in case these contain 'Valid From' or 'Prospective' data so that they are highlighted as such -->
			<xsl:apply-templates select="/leg:Legislation/leg:Primary/leg:PrimaryPrelims"/>
			
			
			<!--<xsl:apply-templates select="$g_ndsLegPrelims/leg:LongTitle"/>
			<xsl:apply-templates select="$g_ndsLegPrelims/leg:IntroductoryText"/>
			<xsl:apply-templates select="$g_ndsLegPrelims/leg:PrimaryPreamble/leg:EnactingText"/>		
			<xsl:apply-templates select="/leg:Legislation/leg:Primary/leg:PrimaryPrelims" mode="ProcessAnnotations"/>-->
			<xsl:apply-templates select="/leg:Legislation/leg:Primary/leg:Body"/>
			
			<!-- this is a bodge fix to get around a FOP issue when there is not enough space on the end page for all the footnotes but if it takes a footnote over to the next page then there is enough space for the content to fit in on the first page where it tries to render the footnote back on the first page thus resulting in a loop --> 
			<xsl:if test="/leg:Legislation/leg:Footnotes">
				<fo:block font-size="{$g_strBodySize}" space-before="36pt" text-align="left" keep-with-next="always">
					<xsl:text>&#8203;</xsl:text>
				</fo:block>
			</xsl:if>
			
		</fo:flow>
	</xsl:template>


	
	<xsl:template match="leg:Primary/leg:PrimaryPrelims">
		<xsl:apply-templates select="leg:LongTitle"/>
		<xsl:apply-templates select="leg:PrimaryPreamble/*"/>
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
				<fo:block text-align="justify" space-before="12pt" space-after="12pt" text-align-last="justify" font-size="{$g_dblBodySize + 1}{$g_strUnits}" line-height="{$g_intLineHeight + 2}{$g_strUnits}">
					<xsl:apply-templates/>
					<xsl:text/>
					<fo:leader leader-pattern="space" leader-length.minimum="1em" leader-length.maximum="100%"/>
					<xsl:text/>
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