<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="2.0"
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:math="http://www.w3.org/1998/Math/MathML"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:rx="http://www.renderx.com/XSL/Extensions"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:tso="http://www.tso.co.uk/xslt"
xmlns:atom="http://www.w3.org/2005/Atom"
xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
exclude-result-prefixes="tso atom">

<xsl:output method="xml" version="1.0" omit-xml-declaration="no"  indent="no" standalone="no" use-character-maps="FOcharacters"/>

<!-- Map characters for serialization -->
<xsl:character-map name="FOcharacters">
	<!-- Do this just so we can see NBSP -->
	<xsl:output-character character="&#160;" string="&amp;#160;"/>
	<xsl:output-character character="⿿" string="-"/>
</xsl:character-map>


<!-- ========== Parameters ========== -->

<xsl:param name="g_flShowFrontmatter" select="false()" as="xs:boolean"/>

	<!-- use a value of FOP0.95 if FOP 0.95 is used to generate the footnote hacks -->
	<xsl:param name="g_FOprocessor" select="'FOP1.0'" as="xs:string"/>
<!-- ========== Global Constants ========== -->

<xsl:variable name="g_strConstantPrimary" select="'primary'" as="xs:string"/>
<xsl:variable name="g_strConstantSecondary" select="'secondary'" as="xs:string"/>
<xsl:variable name="g_strConstantDocumentStatusDraft" select="'draft'" as="xs:string"/>
<xsl:variable name="g_strConstantOutputTypePrimary" select="'PrimaryStyle'" as="xs:string"/>
<xsl:variable name="g_strConstantOutputTypeSecondary" select="'SecondaryStyle'" as="xs:string"/>
<xsl:variable name="g_strConstantImagesPath" select="'http://localhost:80/images/crests/'" as="xs:string"/>

<xsl:variable name="g_documentLanguage" select="if (/leg:EN/@xml:lang) then /leg:EN/@xml:lang else 'en'"  as="xs:string"/>

<!--<xsl:variable name="g_strMainFont" select="if ($g_strDocClass = $g_strConstantSecondary) then 'Times' else 'BookAntiqua'" as="xs:string"/> -->
<xsl:variable name="g_strMainFont" select="if ($g_strDocClass = $g_strConstantSecondary) then 'Times' else 'Times'" as="xs:string"/> 
<xsl:variable name="g_strOutputType" as="xs:string">PrimaryStyle</xsl:variable>
<xsl:variable name="g_dblBodySize" as="xs:double">
	<xsl:choose>
		<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">11.5</xsl:when>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">10.5</xsl:when>
		<xsl:otherwise>11</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:variable name="g_intSmallCapsSize" as="xs:integer">
	<xsl:choose>
		<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">9</xsl:when>
		<xsl:otherwise>9</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:variable name="g_intLineHeight" as="xs:integer">
	<xsl:choose>
		<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">14</xsl:when>
		<xsl:otherwise>12</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:variable name="g_strBodySize" select="concat($g_dblBodySize, 'pt')" as="xs:string"/>
<xsl:variable name="g_strHeaderSize" select="if ($g_strDocType = 'NorthernIrelandAct') then '11pt' else '11pt'" as="xs:string"/>
<xsl:variable name="g_strFooterSize" select="if ($g_strDocType = 'NorthernIrelandAct') then '11pt' else '11pt'" as="xs:string"/>
<xsl:variable name="g_strSmallCapsSize" select="concat($g_intSmallCapsSize, 'pt')" as="xs:string"/>
<xsl:variable name="g_strLineHeight" select="concat($g_intLineHeight, 'pt')" as="xs:string"/>
<xsl:variable name="g_dblPageHeight" select="841.89" as="xs:double"/>
<xsl:variable name="g_dblPageWidth" select="595.276" as="xs:double"/>
<xsl:variable name="g_PageBodyWidth" select="415.276" as="xs:double"/>
<xsl:variable name="g_strStandardParaGap" select="if ($g_strDocClass = $g_strConstantSecondary) then '4pt' else '2pt'"/>
<xsl:variable name="g_strLargeStandardParaGap" select="if ($g_strDocClass = $g_strConstantSecondary) then '4pt' else '8pt'"/>
<xsl:variable name="g_strLinkColor" select="'rgb(0,102,153)'" as="xs:string"/>
<!-- Define the units of measurements for the above -->
<xsl:variable name="g_strUnits" select="'pt'" as="xs:string"/>
<xsl:variable name="g_flAddTargets" select="false()" as="xs:boolean"/>
<!-- Indicates whether line space between paragraphs should be suppressed in tables - needed for line numbering -->
<xsl:variable name="g_flSuppressTableLineSpace" select="true()" as="xs:boolean"/>


<!-- ========== Global Variables ========== -->

<xsl:variable name="g_ndsLegMetadata" select="/leg:EN/ukm:Metadata/ukm:ENmetadata"/>
<xsl:variable name="g_ndsLegPrelims" select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims"/>
<xsl:variable name="g_strDocType" select="$g_ndsLegMetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value" as="xs:string"/>
<xsl:variable name="g_dctitle" select="/leg:EN/ukm:Metadata/dc:title"/>
<xsl:variable name="g_strDocClass" as="xs:string">
	<!-- For NI Acts the look and feel is as for secondary legislation so set doc class accordingly 
	<xsl:choose>
		<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
			<xsl:value-of select="$g_strConstantSecondary"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$g_ndsLegMetadata/ukm:DocumentClassification/ukm:DocumentCategory/@Value"/>
		</xsl:otherwise>
	</xsl:choose>-->
	<xsl:value-of select="$g_ndsLegMetadata/ukm:DocumentClassification/ukm:DocumentCategory/@Value"/>
</xsl:variable>
<xsl:variable name="g_strDocStatus" select="$g_ndsLegMetadata/ukm:DocumentClassification/ukm:DocumentStatus/@Value" as="xs:string"/>
<xsl:variable name="g_ndsFootnotes" select="/leg:EN/leg:Footnotes/leg:Footnote"/>

<!-- ========== Key used to check for duplicate id's========== -->
<xsl:key name="ids" match="*" use="@id"/>


<!-- ========== Main code ========== -->

<xsl:template match="/">

	<!-- Create FO output -->
		<fo:root id="{replace(/leg:EN/ukm:Metadata/atom:link[@rel = 'self']/@href,'.xml','.pdf')}">
			
			<!-- Set PDF options -->
			<xsl:processing-instruction name="xep-pdf-initial-zoom">fit</xsl:processing-instruction>
			
			<xsl:call-template name="TSOoutputMasterSet"/>
			
			<fo:declarations>
			  <x:xmpmeta xmlns:x="adobe:ns:meta/">
				<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				  <rdf:Description rdf:about=""
					  xmlns:dc="http://purl.org/dc/elements/1.1/">
					<!-- Dublin Core properties go here -->
					<dc:title>
						<xsl:value-of select="$g_dctitle"/>
					</dc:title>
					<dc:creator></dc:creator>
					<dc:description>
						<xsl:for-each select="leg:EN/ukm:Metadata/dc:subject">
							<xsl:value-of select="."/>
							<xsl:if test="following-sibling::dc:subject">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</dc:description>
				  </rdf:Description>
				  <rdf:Description rdf:about=""
					  xmlns:xmp="http://ns.adobe.com/xap/1.0/">
					<!-- XMP properties go here -->
					<xmp:CreatorTool>
						<xsl:choose>
							<xsl:when test="$g_FOprocessor eq 'FOP0.95'">
								<xsl:text>FOP 0.95</xsl:text>
							</xsl:when>
							<xsl:when test="$g_FOprocessor eq 'FOP1.0'">
								<xsl:text>FOP 1.0</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$g_FOprocessor"/>
							</xsl:otherwise>
						</xsl:choose>
					</xmp:CreatorTool>
				</rdf:Description>
				</rdf:RDF>
			  </x:xmpmeta>
			</fo:declarations>
			
			<!--<xsl:if test="$g_flShowFrontmatter">
				<xsl:call-template name="TSOoutputFrontmatter"/>
			</xsl:if>-->
	
			<!-- Only primary style outputs TOC before any actual content
			<xsl:if test="$g_strDocClass = $g_strConstantPrimary or $g_strDocType = 'NorthernIrelandAct'">
				<xsl:apply-templates select="/leg:EN/leg:Contents" mode="MainContents"/>
			</xsl:if> -->
	
			<fo:page-sequence master-reference="main-sequence" initial-page-number="1" letter-value="auto" xml:lang="{$g_documentLanguage}">
	
				<fo:static-content flow-name="xsl-footnote-separator">
					<fo:block id="footnoteBlock" space-after="12pt">
						<fo:leader leader-pattern="rule" leader-length="100%" rule-style="solid" rule-thickness="0.5pt"/>
					</fo:block>
				</fo:static-content>
	
				<!-- Footer for first page -->
				<xsl:if test="$g_strDocClass = $g_strConstantSecondary and //ukm:DepartmentCode">
					<fo:static-content flow-name="footer-only-after">
						<fo:block font-size="{$g_strFooterSize}" font-weight="bold" text-align="right" font-family="{$g_strMainFont}">
							<xsl:text>[</xsl:text>
							<xsl:value-of select="//ukm:DepartmentCode/@Value"/>
							<xsl:text>]</xsl:text>
						</fo:block>
					</fo:static-content>			
				</xsl:if>
				
				<xsl:if test="$g_strDocClass != $g_strConstantSecondary">
					<!-- Header for even pages -->
					<fo:static-content flow-name="even-before">
						
						
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">

							<fo:table-body margin-left="0pt" margin-right="0pt">
								<fo:table-row margin-left="0pt" margin-right="0pt">
									<!--<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt">
										<fo:block font-family="{$g_strMainFont}">
											<fo:inline><fo:page-number/></fo:inline>
										</fo:block>
									</fo:table-cell>-->
									<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead1"/>
										</fo:block>
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead2"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:static-content>	

					<fo:static-content flow-name="even-after">
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
							<fo:table-body margin-left="0pt" margin-right="0pt">
								<fo:table-row margin-left="0pt" margin-right="0pt">
									<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt" text-align="center">
										<fo:block font-family="{$g_strMainFont}">
											<fo:inline><fo:page-number/></fo:inline>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:static-content>
					
	
	
					<!-- Header for odd pages -->
					<fo:static-content flow-name="odd-before">
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
<!--							<fo:table-column column-width="80%"/>									
							<fo:table-column column-width="20%"/>-->
							<fo:table-body margin-left="0pt" margin-right="0pt">
								<fo:table-row margin-left="0pt" margin-right="0pt">
									<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead1"/>
										</fo:block>
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead2"/>
										</fo:block>
									</fo:table-cell>
									<!--<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
										<fo:block font-family="{$g_strMainFont}" font-size="10pt">
											<fo:inline><fo:page-number/></fo:inline>
										</fo:block>
									</fo:table-cell>-->
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:static-content>	

					<fo:static-content flow-name="odd-after">
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
							<fo:table-body margin-left="0pt" margin-right="0pt">
								<fo:table-row margin-left="0pt" margin-right="0pt">
									<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt" text-align="center">
										<fo:block font-family="{$g_strMainFont}">
											<fo:inline><fo:page-number/></fo:inline>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:static-content>

					<fo:static-content flow-name="footer-only-after">
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
							<fo:table-body margin-left="0pt" margin-right="0pt">
								<fo:table-row margin-left="0pt" margin-right="0pt">
									<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt" text-align="center">
										<fo:block font-family="{$g_strMainFont}">
											<fo:inline><fo:page-number/></fo:inline>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:static-content>
				</xsl:if>
				
				
				
				
				<!-- Footers on pages -->	
				<xsl:if test="$g_strDocClass = $g_strConstantSecondary">
					
				<!-- Header for even pages -->
					<fo:static-content flow-name="even-before">
						
						
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">

							<fo:table-body margin-left="0pt" margin-right="0pt">
								<fo:table-row margin-left="0pt" margin-right="0pt">
									<!--<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt">
										<fo:block font-family="{$g_strMainFont}">
											<fo:inline><fo:page-number/></fo:inline>
										</fo:block>
									</fo:table-cell>-->
									<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead1"/>
										</fo:block>
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead2"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:static-content>	

					
					
	
	
					<!-- Header for odd pages -->
					<fo:static-content flow-name="odd-before">
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
<!--							<fo:table-column column-width="80%"/>									
							<fo:table-column column-width="20%"/>-->
							<fo:table-body margin-left="0pt" margin-right="0pt">
								<fo:table-row margin-left="0pt" margin-right="0pt">
									<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead1"/>
										</fo:block>
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead2"/>
										</fo:block>
									</fo:table-cell>
									<!--<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
										<fo:block font-family="{$g_strMainFont}" font-size="10pt">
											<fo:inline><fo:page-number/></fo:inline>
										</fo:block>
									</fo:table-cell>-->
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:static-content>		
					
					
					<fo:static-content flow-name="footer-only-after">
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
							<fo:table-body margin-left="0pt" margin-right="0pt">
								<fo:table-row margin-left="0pt" margin-right="0pt">
									<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt" text-align="center">
										<fo:block font-family="{$g_strMainFont}">
											<fo:inline><fo:page-number/></fo:inline>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:static-content>
					
					
					
					
					<xsl:call-template name="TSOsecondaryMainFooter"/>
				</xsl:if>	
	
				
				
				
				<xsl:choose>
					<xsl:when test="$g_strDocClass = $g_strConstantPrimary or $g_strDocType = 'NorthernIrelandAct'">
						<xsl:call-template name="TSO_PrimaryPrelims"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="TSO_SecondaryPrelims"/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:page-sequence>
	
			<!-- SCHEDULE SEQUENCE OF PAGES -->
			<xsl:if test="/leg:EN/*/leg:Annexes">
				<fo:page-sequence master-reference="annex-sequence" xml:lang="{$g_documentLanguage}">
					<fo:static-content flow-name="xsl-footnote-separator">
						<fo:block>
							<fo:leader leader-pattern="rule" leader-length="96pt" rule-style="solid" rule-thickness="0.5pt"/>
						</fo:block>
					</fo:static-content>
		
					<xsl:choose>
						<xsl:when test="$g_strDocClass != $g_strConstantSecondary">
							<fo:static-content flow-name="even-before">
						
						
								<fo:table margin-left="0pt" margin-right="0pt" margin-top="36pt" table-layout="fixed" width="100%">

									<fo:table-body margin-left="0pt" margin-right="0pt">
										<fo:table-row margin-left="0pt" margin-right="0pt">
											<!--<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt">
												<fo:block font-family="{$g_strMainFont}">
													<fo:inline><fo:page-number/></fo:inline>
												</fo:block>
											</fo:table-cell>-->
											<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
												<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runninghead1"/>
												</fo:block>
												<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runninghead2"/>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
							</fo:static-content>	

							<fo:static-content flow-name="even-after">
								<fo:table margin-left="0pt" margin-right="0pt" margin-top="36pt" table-layout="fixed" width="100%">
									<fo:table-body margin-left="0pt" margin-right="0pt">
										<fo:table-row margin-left="0pt" margin-right="0pt">
											<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt" text-align="center">
												<fo:block font-family="{$g_strMainFont}">
													<fo:inline><fo:page-number/></fo:inline>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
							</fo:static-content>
							
			
			
							<!-- Header for odd pages -->
							<fo:static-content flow-name="odd-before">
								<fo:table margin-left="0pt" margin-right="0pt" margin-top="36pt" table-layout="fixed" width="100%">
		<!--							<fo:table-column column-width="80%"/>									
									<fo:table-column column-width="20%"/>-->
									<fo:table-body margin-left="0pt" margin-right="0pt">
										<fo:table-row margin-left="0pt" margin-right="0pt">
											<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
												<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runninghead1"/>
												</fo:block>
												<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runninghead2"/>
												</fo:block>
											</fo:table-cell>
											<!--<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
												<fo:block font-family="{$g_strMainFont}" font-size="10pt">
													<fo:inline><fo:page-number/></fo:inline>
												</fo:block>
											</fo:table-cell>-->
										</fo:table-row>
									</fo:table-body>
								</fo:table>
							</fo:static-content>	

							<fo:static-content flow-name="odd-after">
								<fo:table margin-left="0pt" margin-right="0pt" margin-top="36pt" table-layout="fixed" width="100%">
									<fo:table-body margin-left="0pt" margin-right="0pt">
										<fo:table-row margin-left="0pt" margin-right="0pt">
											<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt" text-align="center">
												<fo:block font-family="{$g_strMainFont}">
													<fo:inline><fo:page-number/></fo:inline>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
							</fo:static-content>	
						</xsl:when>
						<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
							<xsl:call-template name="TSOgetNIheaderFooter"/>
							<xsl:call-template name="TSOsecondaryMainFooter"/>
						</xsl:when>
					</xsl:choose>
					
					<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" font-size="{$g_strBodySize}" line-height="{$g_strLineHeight}">
						<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
							<!--<fo:block font-size="10pt" text-align="center" font-weight="normal" font-style="italic">
								<xsl:text>These notes refer to the </xsl:text>
								<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
								<xsl:text> 2009 (c. </xsl:text>
								<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
								<xsl:text>), which received Royal Assent on 12 February 2009</xsl:text>
							</fo:block>	-->
						</xsl:if>
						<xsl:apply-templates select="/leg:EN/leg:ExplanatoryNotes/leg:Annexes"/>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
		</fo:root>	
</xsl:template>

<xsl:template name="TSOsecondaryMainFooter">
	<fo:static-content flow-name="even-after">
		<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" id="pageFooterEven" text-align="center">
			<fo:inline><fo:page-number/></fo:inline>						
		</fo:block>
	</fo:static-content>
	<fo:static-content flow-name="odd-after">
		<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" id="pageFooterOdd" text-align="center">
			<fo:inline><fo:page-number/></fo:inline>								
		</fo:block>
	</fo:static-content>
</xsl:template>

<xsl:template name="TSOgetNIheaderFooter">
	<!-- Header for even pages -->
	<fo:static-content flow-name="even-before">
		<fo:table>
<!--			<fo:table-column column-width="20%"/>									
			<fo:table-column column-width="60%"/>
			<fo:table-column column-width="20%"/>-->
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell text-align="left">
						<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}">
							<xsl:text>c. </xsl:text>
							<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="center">
						<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
							<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
		<fo:block font-size="{$g_strSmallCapsSize}" font-family="{$g_strMainFont}" margin-top="24pt" margin-left="-72pt">
			<fo:retrieve-marker retrieve-class-name="SideBar"/>
		</fo:block>
	</fo:static-content>					
	<fo:static-content flow-name="even-before-first">
		<fo:table>
<!--			<fo:table-column column-width="20%"/>									
			<fo:table-column column-width="60%"/>
			<fo:table-column column-width="20%"/>-->
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell text-align="left">
						<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}">
							<xsl:text>c. </xsl:text>
							<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="center">
						<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
							<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</fo:static-content>
	<!-- Header for odd pages -->
	<fo:static-content flow-name="odd-before">
		<fo:table>
	<!--		<fo:table-column column-width="20%"/>	
			<fo:table-column column-width="60%"/>									
			<fo:table-column column-width="20%"/>-->
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell text-align="left">
						<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="center">
						<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
							<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}">
							<xsl:text>c. </xsl:text>
							<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
		<fo:block font-size="{$g_strSmallCapsSize}" font-family="{$g_strMainFont}" margin-top="24pt" margin-right="-72pt" text-align="right">
			<fo:retrieve-marker retrieve-class-name="SideBar"/>
		</fo:block>
	</fo:static-content>		
	<fo:static-content flow-name="odd-before-first">
		<fo:table>
<!--			<fo:table-column column-width="20%"/>	
			<fo:table-column column-width="60%"/>									
			<fo:table-column column-width="20%"/>-->
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell text-align="left">
						<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="center">
						<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
							<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell text-align="right">
						<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}">
							<xsl:text>c. </xsl:text>
							<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</fo:static-content>
</xsl:template>


<xsl:include href="EN_schema_masterpages_FO.xslt"/>

<!--<xsl:include href="legislation_schema_frontmatter_FO.xslt"/>-->

<xsl:include href="EN_schema_primaryprelims_FO.xslt"/>

<xsl:include href="EN_schema_secondaryprelims_FO.xslt"/>

<xsl:include href="EN_schema_contents_FO.xslt"/>

<xsl:include href="EN_schema_headings_FO.xslt"/>

<xsl:template match="leg:Body">
	
	<fo:block id="StartOfContent"/>
	

	<xsl:apply-templates/>
</xsl:template>


<xsl:template match="leg:Annexes">
	<xsl:call-template name="TSOheader"/>
	<xsl:apply-templates/>
</xsl:template>


<xsl:template match="leg:NumberedPara">
	<fo:list-block  space-before="8pt" provisional-label-separation="6pt" provisional-distance-between-starts="36pt" margin-left="0pt" text-indent="0pt">
		<xsl:call-template name="TSOgetID"/>
		<fo:list-item>
			<fo:list-item-label end-indent="label-end()">
				<fo:block font-size="11pt" text-align="left">
					<xsl:value-of select="leg:Pnumber"/>
					<xsl:text>.</xsl:text>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block font-size="11pt" text-align="justify">
					<xsl:apply-templates select="*/self::*[not(leg:Pnumber)]"/>
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</fo:list-block>
	<!-- Hack to get around footnote issue in FOP  0.95 - footnotes in lists/tables disappear!-->
	<xsl:if test="g_FOprocessor = 'FOP0.95'">
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
									<fo:block  vertical-align="super" font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt" font-weight="bold">
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
	</xsl:if>
</xsl:template>


<xsl:template match="leg:NumberedPara/leg:Pnumber">
	
</xsl:template>





<xsl:template match="leg:IntroductoryText">
	<fo:block font-size="{$g_strBodySize}" space-before="24pt" text-align="justify">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:EnactingText">
	<fo:block font-size="{$g_strBodySize}" text-align="justify" space-after="30pt">
		<xsl:if test="/leg:EN/leg:Contents">
			<xsl:attribute name="space-before">24pt</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:P1group">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates select="leg:Title"/>
			<xsl:if test="child::*[2][self::leg:P1]/child::*[2][self::leg:P1para]/child::*[1][self::leg:P2group]">
				<fo:block font-style="italic" space-before="12pt">
					<xsl:apply-templates select="child::*[2][self::leg:P1]/child::*[2][self::leg:P1para]/child::*[1]/leg:Title"/>
				</fo:block>
			</xsl:if>
			<xsl:apply-templates select="leg:P1 | leg:P"/>
		</xsl:when>
		<xsl:when test="parent::leg:BlockAmendment[@TargetClass = 'primary' and @Context = 'schedule'] or parent::leg:ScheduleBody or parent::leg:Part/parent::leg:ScheduleBody">
			<fo:block space-before="18pt">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:when>
		<xsl:otherwise>
			<fo:block space-before="18pt">
				<xsl:apply-templates select="leg:P1 | leg:P"/>
			</fo:block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:P1group/leg:Title" priority="1">
	<fo:block font-size="{$g_strBodySize}" font-weight="bold" text-align="left" keep-with-next="always">
		<xsl:if test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:attribute name="space-before">16pt</xsl:attribute>
			<xsl:attribute name="space-after">6pt</xsl:attribute>
			<xsl:if test="ancestor::leg:BlockAmendment">
				<xsl:attribute name="margin-left">24pt</xsl:attribute>
			</xsl:if>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$g_strDocType = 'ScottishAct'">
				<xsl:attribute name="margin-left">6pt</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Schedule[not($g_strDocClass = $g_strConstantSecondary)]//leg:P1group[not(ancestor::leg:BlockAmendment)]/leg:Title | leg:P1group[parent::leg:BlockAmendment[@TargetClass = 'primary' and @Context = 'schedule']]/leg:Title" priority="2">
	<fo:block font-size="{$g_strBodySize}" font-style="italic" text-align="left" keep-with-next="always">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:P1">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
		</xsl:when>
		<xsl:otherwise>
			<fo:list-block provisional-label-separation="6pt" provisional-distance-between-starts="30pt" space-before="6pt">		
				<xsl:call-template name="TSOgetID"/>
				<xsl:choose>
					<xsl:when test="$g_strDocClass = $g_strConstantPrimary"/>
					<xsl:otherwise>
						<xsl:attribute name="space-before">8pt</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>				
				<fo:list-item>
					<fo:list-item-label end-indent="label-end()">
						<fo:block font-size="{$g_strBodySize}" text-align="left" font-weight="bold">
							<xsl:if test="leg:Pnumber/@PuncBefore != ''"><xsl:value-of select="leg:Pnumber/@PuncBefore"/></xsl:if>
							<xsl:apply-templates select="leg:Pnumber"/>
							<xsl:if test="leg:Pnumber/@PuncAfter != ''"><xsl:value-of select="leg:Pnumber/@PuncAfter"/></xsl:if>
						</fo:block>						
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<xsl:if test="parent::leg:P1group and not(preceding-sibling::leg:P1)">
							<xsl:apply-templates select="parent::*/leg:Title"/>
						</xsl:if>
						<fo:block font-size="{$g_strBodySize}" text-align="justify">
							<xsl:apply-templates select="leg:P1para"/>
						</fo:block>						
					</fo:list-item-body>
				</fo:list-item>						
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:P | leg:Para">
	<fo:block>
		<xsl:apply-templates select="*"/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Schedule//leg:P1" priority="1">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
		</xsl:when>
		<xsl:otherwise>
			<fo:list-block provisional-label-separation="12pt" provisional-distance-between-starts="48pt" space-before="6pt">		
				<xsl:call-template name="TSOgetID"/>
				<xsl:choose>
					<xsl:when test="$g_strDocClass = $g_strConstantPrimary"/>
					<xsl:otherwise>
						<xsl:attribute name="space-before">8pt</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>	
				<fo:list-item>
					<fo:list-item-label end-indent="label-end()">
						<fo:block font-size="{$g_strBodySize}" text-align="left" start-indent="3pt">
							<xsl:if test="leg:Pnumber/@PuncBefore != ''"><xsl:value-of select="leg:Pnumber/@PuncBefore"/></xsl:if>
							<xsl:apply-templates select="leg:Pnumber"/>
							<xsl:if test="leg:Pnumber/@PuncAfter != ''"><xsl:value-of select="leg:Pnumber/@PuncAfter"/></xsl:if>
						</fo:block>						
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block font-size="{$g_strBodySize}" text-align="justify">
							<xsl:apply-templates select="leg:P1para"/>
						</fo:block>						
					</fo:list-item-body>
				</fo:list-item>						
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- P1 as part of an amendment in a schedule context or an unknown context but in a schedule (so the context is implied) -->
<xsl:template match="leg:P1[ancestor::leg:BlockAmendment[1][@Context = 'schedule']] | leg:P1[ancestor::leg:BlockAmendment[1][@Context = 'unknown' and ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule]]]" priority="3">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
		</xsl:when>
		<xsl:otherwise>
			<fo:list-block provisional-label-separation="12pt" provisional-distance-between-starts="48pt" space-before="6pt">		
				<xsl:call-template name="TSOgetID"/>
				<xsl:choose>
					<xsl:when test="$g_strDocClass = $g_strConstantPrimary"/>
					<xsl:otherwise>
						<xsl:attribute name="space-before">8pt</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>	
				<fo:list-item>
					<fo:list-item-label end-indent="label-end()">
						<fo:block font-size="{$g_strBodySize}" text-align="left" margin-left="6pt">
							<xsl:if test="leg:Pnumber/@PuncBefore != ''"><xsl:value-of select="leg:Pnumber/@PuncBefore"/></xsl:if>
							<xsl:apply-templates select="leg:Pnumber"/>
							<xsl:if test="leg:Pnumber/@PuncAfter != ''"><xsl:value-of select="leg:Pnumber/@PuncAfter"/></xsl:if>							
						</fo:block>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block font-size="{$g_strBodySize}" text-align="justify">
							<xsl:apply-templates select="leg:P1para"/>
						</fo:block>						
					</fo:list-item-body>
				</fo:list-item>						
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- P1 as part of body -->
<xsl:template match="leg:P1[ancestor::leg:BlockAmendment[1][@Context = 'main' or @Context='unknown']]" priority="2">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<fo:block font-size="{$g_strBodySize}">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="parent::leg:BlockAmendment/parent::*[self::leg:P2para]">36pt</xsl:when>
						<xsl:when test="parent::leg:BlockAmendment/parent::*[self::leg:P3para]">0pt</xsl:when>
						<xsl:otherwise>24pt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</fo:block>
		</xsl:when>
		<xsl:otherwise>
			<fo:list-block provisional-label-separation="6pt" provisional-distance-between-starts="30pt" space-before="6pt">		
				<xsl:call-template name="TSOgetID"/>
				<xsl:choose>
					<xsl:when test="$g_strDocClass = $g_strConstantPrimary"/>
					<xsl:otherwise>
						<xsl:attribute name="space-before">8pt</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>					
				<fo:list-item>
					<fo:list-item-label end-indent="label-end()">
						<fo:block font-size="{$g_strBodySize}" text-align="left">
							<!-- Allow a bit more space -->
							<xsl:if test="string-length(leg:Pnumber) &gt; 3">
								<xsl:attribute name="margin-left">-24pt</xsl:attribute>
								<xsl:attribute name="text-align">right</xsl:attribute>
							</xsl:if>
							<xsl:if test="not(parent::leg:ScheduleBody/ancestor::leg:BlockAmendment[1][@TargetClass = 'primary'])">
								<xsl:attribute name="font-weight">bold</xsl:attribute>
							</xsl:if>
							<xsl:if test="leg:Pnumber/@PuncBefore != ''"><xsl:value-of select="leg:Pnumber/@PuncBefore"/></xsl:if>
							<xsl:apply-templates select="leg:Pnumber"/>
							<xsl:if test="leg:Pnumber/@PuncAfter != ''"><xsl:value-of select="leg:Pnumber/@PuncAfter"/></xsl:if>							
						</fo:block>						
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<xsl:if test="parent::leg:P1group and not(preceding-sibling::leg:P1)">
							<xsl:apply-templates select="parent::*/leg:Title"/>
						</xsl:if>
						<fo:block font-size="{$g_strBodySize}" text-align="justify">
							<xsl:apply-templates select="leg:P1para"/>
						</fo:block>						
					</fo:list-item-body>
				</fo:list-item>						
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:P2">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
		</xsl:when>
		<xsl:otherwise>
			<fo:list-block provisional-label-separation="12pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" start-indent="0pt">	
				<xsl:call-template name="TSO_p2"/>
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:Schedule//leg:P2">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
		</xsl:when>
		<xsl:otherwise>
			<fo:list-block provisional-label-separation="12pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" start-indent="12pt">	
				<xsl:call-template name="TSO_p2"/>
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:BlockAmendment//leg:P2" priority="1">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<fo:block font-size="{$g_strBodySize}">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="parent::leg:BlockAmendment/parent::*[self::leg:P1para]">24pt</xsl:when>
						<xsl:when test="parent::leg:BlockAmendment/parent::*[self::leg:P2para]">36pt</xsl:when>
						<xsl:otherwise>0pt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</fo:block>
		</xsl:when>
		<xsl:otherwise>
			<fo:list-block provisional-label-separation="12pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt">
				<xsl:if test="parent::leg:BlockAmendment[@Context = 'schedule']">
					<xsl:attribute name="margin-left">24pt</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="TSO_p2"/>
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:BlockAmendment[@Context = 'schedule']//leg:P2" priority="2">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
		</xsl:when>
		<xsl:otherwise>
			<fo:list-block provisional-label-separation="12pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="12pt">
				<xsl:call-template name="TSO_p2"/>
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:BlockAmendment[@Context = 'schedule']//leg:P1//leg:P2" priority="3">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
		</xsl:when>
		<xsl:otherwise>
			<fo:list-block provisional-label-separation="12pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="-30pt">
				<xsl:call-template name="TSO_p2"/>
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:BlockAmendment[@Context = 'main' or @Context='unknown']//leg:P1//leg:P2" priority="4">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="parent::leg:P2group and not(preceding-sibling::leg:P2)">
				<fo:block font-style="italic" space-before="12pt">
					<xsl:apply-templates select="parent::*/leg:Title"/>
				</fo:block>
			</xsl:if>
			<fo:list-block provisional-label-separation="12pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="-30pt">
				<xsl:call-template name="TSO_p2"/>
			</fo:list-block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:P2group">
	<xsl:if test="preceding-sibling::* or not(parent::leg:P1para)">
		<fo:block font-style="italic" space-before="12pt">
			<xsl:apply-templates select="leg:Title"/>
		</fo:block>
	</xsl:if>
	<xsl:apply-templates select="*[not(self::leg:Title)]"/>
</xsl:template>

<xsl:template name="TSO_p2">
	<fo:list-item>
		<xsl:call-template name="TSOgetID"/>
		<fo:list-item-label end-indent="label-end()">
			<fo:block font-size="{$g_strBodySize}" text-align="right" margin-left="-12pt">
				<xsl:apply-templates select="leg:Pnumber"/>
			</fo:block>						
		</fo:list-item-label>
		<fo:list-item-body start-indent="body-start()">
			<fo:block font-size="{$g_strBodySize}" text-align="justify">
				<xsl:apply-templates select="leg:P2para"/>
			</fo:block>						
		</fo:list-item-body>
	</fo:list-item>						
</xsl:template>

<xsl:template match="leg:P2para">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:otherwise>
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:BlockAmendment/leg:P2para">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<fo:block space-before="{$g_strStandardParaGap}">
				<xsl:choose>
					<xsl:when test="parent::*/parent::leg:P1para">
						<xsl:attribute name="margin-left">24pt</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:apply-templates/>
			</fo:block>
		</xsl:when>
		<xsl:otherwise>
			<fo:block margin-left="36pt">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:P3">
	<xsl:call-template name="TSO_p3">
		<xsl:with-param name="margin_left">
			<xsl:choose>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">6pt</xsl:when>
				<xsl:when test="parent::leg:P1para and not($g_strDocType = 'ScottishAct')">6pt</xsl:when>
				<xsl:otherwise>0pt</xsl:otherwise>		
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="label_separation">
			<xsl:choose>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">6pt</xsl:when>
				<xsl:otherwise>12pt</xsl:otherwise>				
			</xsl:choose>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:BlockAmendment/leg:P3">
	<xsl:call-template name="TSO_p3">
		<xsl:with-param name="margin_left">
			<xsl:choose>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary and parent::*/parent::*[self::leg:P3para or self::leg:P5para]">0pt</xsl:when>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">12pt</xsl:when>
				<xsl:when test="parent::leg:P1para">6pt</xsl:when>
				<xsl:otherwise>36pt</xsl:otherwise>		
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="label_separation">
			<xsl:choose>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">6pt</xsl:when>
				<xsl:otherwise>12pt</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:P3group">
	<fo:block font-style="italic" space-before="12pt" start-indent="24pt">
		<xsl:apply-templates select="leg:Title"/>
	</fo:block>
	<xsl:apply-templates select="*[not(self::leg:Title)]"/>
</xsl:template>

<xsl:template name="TSO_p3">
	<xsl:param name="margin_left">0pt</xsl:param>
	<xsl:param name="label_separation">12pt</xsl:param>	
	<fo:list-block provisional-label-separation="{$label_separation}" space-before="{$g_strStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="{$margin_left}" text-indent="0pt">	
		<xsl:call-template name="TSOgetID"/>
		<fo:list-item>
			<fo:list-item-label end-indent="label-end()">
				<fo:block font-size="{$g_strBodySize}" text-align="right">
					<xsl:apply-templates select="leg:Pnumber"/>
				</fo:block>						
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block font-size="{$g_strBodySize}" text-align="justify">
					<xsl:apply-templates select="leg:P3para"/>
				</fo:block>						
			</fo:list-item-body>
		</fo:list-item>						
	</fo:list-block>		
</xsl:template>

<xsl:template match="leg:P3para">
	<fo:block>
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:choose>
					<xsl:when test="parent::leg:BlockAmendment/parent::leg:P1para">
						<xsl:attribute name="margin-left">36pt</xsl:attribute>
					</xsl:when>
					<xsl:when test="parent::leg:BlockAmendment/parent::leg:P2para">
						<xsl:attribute name="margin-left">48pt</xsl:attribute>
					</xsl:when>
					<xsl:when test="parent::leg:BlockAmendment/parent::leg:P3para">
						<xsl:attribute name="margin-left">36pt</xsl:attribute>
					</xsl:when>
				</xsl:choose>		
			</xsl:when>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:choose>
					<xsl:when test="parent::leg:BlockAmendment/parent::leg:P3para">
						<xsl:attribute name="margin-left">36pt</xsl:attribute>
					</xsl:when>
				</xsl:choose>		
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:P4">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:call-template name="TSO_p4">
				<xsl:with-param name="margin_left">
					<xsl:choose>
						<xsl:when test="parent::leg:P2para/ancestor::leg:BlockAmendment">36pt</xsl:when>
						<xsl:when test="parent::leg:P1para">36pt</xsl:when>
						<xsl:otherwise>-12pt</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="TSO_p4"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:BlockAmendment/leg:P4">
	<xsl:call-template name="TSO_p4">
		<xsl:with-param name="margin_left">
			<xsl:choose>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">0pt</xsl:when>
				<xsl:otherwise>72pt</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="TSO_p4">
	<xsl:param name="margin_left">0pt</xsl:param>
	<fo:list-block provisional-label-separation="12pt" space-before="{$g_strStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="{$margin_left}" text-indent="0pt">	
		<xsl:call-template name="TSOgetID"/>
		<fo:list-item>
			<fo:list-item-label end-indent="label-end()">
				<fo:block font-size="{$g_strBodySize}" text-align="right">
					<xsl:apply-templates select="leg:Pnumber"/>
				</fo:block>						
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block font-size="{$g_strBodySize}" text-align="justify">
					<xsl:apply-templates select="leg:P4para"/>
				</fo:block>						
			</fo:list-item-body>
		</fo:list-item>						
	</fo:list-block>		
</xsl:template>

<xsl:template match="leg:P5" priority="1">
	<xsl:call-template name="TSO_p5"/>
</xsl:template>

<xsl:template match="leg:Schedule//leg:P5" priority="1">
	<xsl:call-template name="TSO_p5"/>
</xsl:template>

<xsl:template match="leg:BlockAmendment/leg:P5" priority="2">
	<xsl:call-template name="TSO_p5">
		<xsl:with-param name="margin_left" select="'72pt'"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="TSO_p5">
	<xsl:param name="margin_left">0pt</xsl:param>
	<fo:list-block provisional-label-separation="12pt" space-before="{$g_strStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="{$margin_left}" text-indent="0pt">	
		<xsl:call-template name="TSOgetID"/>
		<fo:list-item>
			<fo:list-item-label end-indent="label-end()">
				<fo:block font-size="{$g_strBodySize}" text-align="right">
					<xsl:apply-templates select="leg:Pnumber"/>
				</fo:block>						
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block font-size="{$g_strBodySize}" text-align="justify">
					<xsl:apply-templates select="leg:P5para"/>
				</fo:block>						
			</fo:list-item-body>
		</fo:list-item>						
	</fo:list-block>		
</xsl:template>

<xsl:template match="leg:Schedules">
	<fo:block text-align="justify" font-size="{$g_strBodySize}" break-before="page">
		<xsl:apply-templates select="leg:Title"/>
		<xsl:apply-templates select="leg:Schedule"/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Schedules/leg:Title">	
	<fo:block font-size="14pt" margin-top="36pt" text-align="center" keep-with-next="always" letter-spacing="3pt" space-after="12pt">
		<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
			<xsl:attribute name="text-transform">uppercase</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Schedule">
	<fo:block text-align="justify" font-size="{$g_strBodySize}">
		<xsl:call-template name="TSOgetID"/>	
		<fo:marker marker-class-name="runningheadschedule">
			<xsl:value-of select="leg:Number"/>
			<xsl:text> – </xsl:text>
			<xsl:value-of select="leg:TitleBlock/leg:Title"/>
		</fo:marker>
		<xsl:if test="not(leg:ScheduleBody/leg:Part)">
			<fo:marker marker-class-name="runningheadpart"/>
		</xsl:if>
		<fo:marker marker-class-name="SideBar">
			<xsl:choose>
				<xsl:when test="starts-with(leg:Number, 'Schedule ')">
					<xsl:text>SCH. </xsl:text>
					<xsl:value-of select="substring-after(leg:Number, 'Schedule ')"/>
				</xsl:when>
				<xsl:when test="starts-with(leg:Number, 'SCHEDULE ')">
					<xsl:text>SCH. </xsl:text>
					<xsl:value-of select="substring-after(leg:Number, 'SCHEDULE ')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="leg:Number"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:marker>		
		<xsl:choose>
			<xsl:when test="$g_strDocType = 'ScottishAct'">
				<fo:block font-size="{$g_strBodySize}" space-before="36pt">
					<xsl:apply-templates select="leg:Number"/>
					<xsl:apply-templates select="leg:Reference"/>					
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:table font-size="{$g_strBodySize}" space-after="12pt">
					<xsl:choose>
						<xsl:when test="parent::leg:BlockAmendment and not(preceding-sibling::*)">
							<xsl:attribute name="space-before">12pt</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="space-before">36pt</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
<!--					<fo:table-column column-width="20%"/>
					<fo:table-column column-width="60%"/>	
					<fo:table-column column-width="20%"/>-->
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell>
								<fo:block font-size="{$g_strBodySize}">&#160;</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<xsl:apply-templates select="leg:Number"/>
							</fo:table-cell>
							<fo:table-cell>
								<xsl:choose>
									<xsl:when test="leg:Reference/node()">
										<xsl:apply-templates select="leg:Reference"/>		
									</xsl:when>
									<xsl:otherwise>
										<fo:block font-size="{$g_strBodySize}">&#160;</fo:block>
									</xsl:otherwise>
								</xsl:choose>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>			
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="leg:TitleBlock"/>	
		<xsl:apply-templates select="leg:ScheduleBody"/>
		<!-- CRM Appendix not being output in schedules -->
		<xsl:apply-templates select="leg:Appendix"/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Schedule/leg:Number">
	<fo:block font-size="{$g_strBodySize}" space-before="24pt" text-align="center" keep-with-next="always">
		<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
			<xsl:attribute name="text-transform">uppercase</xsl:attribute>
		</xsl:if>	
		<fo:marker marker-class-name="runningheadschedule">
			<xsl:value-of select="."/>
			<xsl:text> – </xsl:text>
			<xsl:value-of select="following-sibling::leg:TitleBlock/leg:Title"/>
		</fo:marker>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Schedule/leg:TitleBlock/leg:Title">	
	<fo:block font-size="{$g_strBodySize}" text-align="center" keep-with-next="always">
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

<xsl:template match="leg:Reference">
	<fo:block font-size="8pt" keep-with-next="always">
		<xsl:choose>
			<xsl:when test="$g_strDocType = 'ScottishAct'">
				<xsl:attribute name="text-align">center</xsl:attribute>
				<xsl:attribute name="space-after">6pt</xsl:attribute>
				<xsl:attribute name="font-style">italic</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="text-align">right</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Annex/leg:Reference">
	<fo:block  space-before="8pt">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Appendix/leg:Number">
	<fo:block font-size="{$g_strBodySize}" space-before="24pt" text-align="center" keep-with-next="always" page-break-before="always">
		<fo:marker marker-class-name="runningheadschedule">
			<xsl:value-of select="."/>
			<xsl:text> – </xsl:text>
			<xsl:value-of select="following-sibling::leg:TitleBlock/leg:Title"/>
		</fo:marker>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Appendix/leg:TitleBlock/leg:Title">	
	<fo:block font-size="{$g_strBodySize}" margin-top="18pt" text-align="center" keep-with-next="always" space-after="12pt">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:BlockAmendment/leg:Text">
	<xsl:if test="not(preceding-sibling::*) and not(parent::*/preceding-sibling::*[1][self::leg:Text][substring(., string-length(.)) != '&#8212;'])">
		<xsl:if test="not(preceding-sibling::*[1][self::leg:BlockAmendment])">
			<fo:block text-align="justify" font-size="{$g_strBodySize}">
				<xsl:choose>
					<xsl:when test="parent::*/parent::*/parent::leg:UnorderedList/parent::leg:P1para">
						<xsl:attribute name="text-indent">-12pt</xsl:attribute>
						<xsl:attribute name="margin-left">36pt</xsl:attribute>
					</xsl:when>
					<xsl:when test="parent::*/parent::*/parent::leg:UnorderedList and not($g_strDocType = 'ScottishAct')">
						<xsl:attribute name="text-indent">-12pt</xsl:attribute>
						<xsl:attribute name="margin-left">12pt</xsl:attribute>			
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="space-before">12pt</xsl:attribute>
						<xsl:attribute name="margin-left">12pt</xsl:attribute>			
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="preceding-sibling::*[1][self::P1]">
					<xsl:attribute name="space-before">12pt</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:Text">

	<xsl:variable name="strAlignment" as="xs:string">
		<xsl:choose>
			<xsl:when test="@Align = 'centre'">cente</xsl:when>
			<xsl:when test="@Align = 'right'">right</xsl:when>
			<xsl:when test="@Align = 'left'">left</xsl:when>
			<xsl:otherwise>justify</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<fo:block font-size="{$g_strBodySize}" text-align="{$strAlignment}">
		<xsl:if test="leg:Character[@Name = 'DotPadding']">
			<xsl:attribute name="text-align-last">justify</xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="parent::*/parent::*/parent::leg:UnorderedList/parent::leg:P1para and $g_strDocClass = $g_strConstantPrimary">
				<xsl:attribute name="text-indent">-12pt</xsl:attribute>
				<xsl:attribute name="margin-left">36pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="parent::*/parent::*/parent::leg:UnorderedList and not($g_strDocType = 'ScottishAct')">
				<xsl:attribute name="text-indent">-12pt</xsl:attribute>
				<xsl:attribute name="margin-left">12pt</xsl:attribute>			
			</xsl:when>
			<xsl:when test="parent::*/parent::leg:ExplanatoryNotes and parent::*/preceding-sibling::leg:P[not(leg:Text[@Align = 'centre'])]">
				<xsl:attribute name="space-before">3pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="parent::*/parent::leg:EarlierOrders and parent::*/preceding-sibling::leg:P[not(leg:Text[@Align = 'centre'])]">
				<xsl:attribute name="space-before">3pt</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="preceding-sibling::*[1][self::P1]">
			<xsl:attribute name="space-before">12pt</xsl:attribute>
		</xsl:if>
		<xsl:if test="ancestor::xhtml:table and $g_flSuppressTableLineSpace">
			<xsl:attribute name="space-before">0pt</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:P2para/leg:Text | leg:P3para/leg:Text | leg:P4para/leg:Text | leg:P5para/leg:Text | leg:Para/leg:Text | leg:P/leg:Text">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:choose>
				<!-- Capture first para in P2 and output number -->
				<xsl:when test="not(preceding-sibling::*) and (parent::leg:P2para[preceding-sibling::*[1][self::leg:Pnumber] or (not(parent::*/preceding-sibling::*) and parent::leg:BlockAmendment)])">	
					<fo:block text-align="justify" text-indent="12pt" space-before="{$g_strLargeStandardParaGap}">
						<xsl:for-each select="parent::leg:P2para/parent::leg:P2">
							<xsl:if test="(not(preceding-sibling::*) and parent::leg:P1para) or (preceding-sibling::*[1][self::leg:Title] and parent::leg:P2group[not(preceding-sibling::*)])">
								<xsl:if test="parent::*/parent::leg:P1[not(parent::leg:P1group) or preceding-sibling::leg:P1]">
									<xsl:attribute name="space-before">12pt</xsl:attribute>
								</xsl:if>
								<fo:inline>
									<xsl:if test="not(ancestor::leg:Schedule and $g_strDocType = 'NorthernIrelandStatutoryRule')">
										<xsl:attribute name="font-weight">bold</xsl:attribute>
									</xsl:if>
									<xsl:apply-templates select="ancestor::leg:P1[1]/leg:Pnumber"/>
									<xsl:text>.</xsl:text>
								</fo:inline>
								<xsl:text>&#8212;</xsl:text>
							</xsl:if>
							<xsl:apply-templates select="leg:Pnumber"/>
							<!-- FOP doesn't handle 2003 well - look for alternative -->
							<xsl:text>&#160;&#160;</xsl:text>
							<!--<xsl:text>&#2003;</xsl:text>-->						
						</xsl:for-each>
						<xsl:apply-templates/>
					</fo:block>
				</xsl:when>
				<xsl:when test="preceding-sibling::*[1][self::leg:BlockAmendment]"/>
				<xsl:when test="parent::leg:P or parent::leg:P3para or parent::leg:P4para or parent::leg:P5para or preceding-sibling::* or parent::*/parent::*[self::xhtml:td or self::xhtml:th or self::leg:ListItem or self::leg:GroupItem or self::leg:Where or self::leg:EnactingText or self::leg:ExplanatoryNotes or self::leg:RoyalPresence or self::leg:TableText] or parent::*/preceding-sibling::*[self::leg:P2para]">

					<xsl:variable name="strAlignment" as="xs:string">
						<xsl:choose>
							<xsl:when test="@Align = 'centre'">center</xsl:when>
							<xsl:when test="@Align = 'right'">right</xsl:when>
							<xsl:when test="@Align = 'left'">left</xsl:when>					
							<xsl:when test="@Align = 'justify'">justify</xsl:when>					
							<xsl:when test="leg:Character[@Name = 'DotPadding']">justify</xsl:when>
							<xsl:when test="ancestor::xhtml:td[1][@align = 'center']">center</xsl:when>
							<xsl:when test="ancestor::xhtml:td[1][@align = 'right']">right</xsl:when>
							<xsl:when test="ancestor::xhtml:td or ancestor::xhtml:th">left</xsl:when>
							<xsl:when test="ancestor::leg:Comment or ancestor::leg:RoyalPresence">center</xsl:when>
							<xsl:otherwise>justify</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<fo:block text-align="{$strAlignment}" space-before="4pt">
						<xsl:if test="ancestor::xhtml:table and $g_flSuppressTableLineSpace">
							<xsl:choose>
								<xsl:when test="not(preceding-sibling::*)">
									<xsl:attribute name="space-before">
										<xsl:value-of select="$g_strLineHeight"/>
									</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="space-before">0pt</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="@Hanging = 'indented'">
								<xsl:attribute name="text-indent">12pt</xsl:attribute>
							</xsl:when>
							<xsl:when test="@Hanging = 'hanging'">
								<xsl:attribute name="text-indent">-12pt</xsl:attribute>
								<xsl:attribute name="margin-left">12pt</xsl:attribute>
							</xsl:when>
							<xsl:when test="parent::*[preceding-sibling::leg:Para]/parent::*[self::leg:EnactingText]">
								<xsl:attribute name="text-indent">12pt</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="text-indent">0pt</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates/>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>		
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="not(preceding-sibling::*[1][self::leg:BlockAmendment])">
			<fo:block>
				<xsl:if test="not(ancestor::leg:Footnote)">
					<xsl:choose>
						<xsl:when test="preceding-sibling::leg:Text">
							<xsl:attribute name="space-before">3pt</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="space-before">
								<xsl:value-of select="$g_strLargeStandardParaGap"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="ancestor::xhtml:table and $g_flSuppressTableLineSpace">
						<xsl:attribute name="space-before">0pt</xsl:attribute>
					</xsl:if>				
				</xsl:if>
				<xsl:choose>
					<xsl:when test="@Align = 'centre'">
						<xsl:attribute name="text-align">center</xsl:attribute>
					</xsl:when>
					<xsl:when test="@Align = 'right'">
						<xsl:attribute name="text-align">right</xsl:attribute>
					</xsl:when>
					<xsl:when test="@Align = 'left'">
						<xsl:attribute name="text-align">left</xsl:attribute>
					</xsl:when>					
					<xsl:when test="@Align = 'justify'">
						<xsl:attribute name="text-align">justify</xsl:attribute>
					</xsl:when>					
					<xsl:when test="ancestor::xhtml:td">
						<xsl:attribute name="text-align">left</xsl:attribute>
					</xsl:when>
					<xsl:when test="ancestor::leg:Comment">
						<xsl:attribute name="text-align">center</xsl:attribute>
					</xsl:when>
					<xsl:when test="ancestor::leg:RoyalPresence">
						<xsl:attribute name="text-align">center</xsl:attribute>
						<xsl:attribute name="space-after">6pt</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="text-align">justify</xsl:attribute>				
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="leg:Character[@Name = 'DotPadding']">
						<xsl:attribute name="text-align-last">justify</xsl:attribute>
					</xsl:when>
				</xsl:choose>			
	 			<xsl:choose>
					<xsl:when test="not(preceding-sibling::*) and parent::*/parent::*/parent::leg:UnorderedList[@Class = 'Definition'] and not($g_strDocType = 'ScottishAct')">
						<xsl:attribute name="text-indent">-12pt</xsl:attribute>
						<xsl:attribute name="margin-left">12pt</xsl:attribute>
					</xsl:when>
					<xsl:when test="preceding-sibling::* and parent::*/parent::*/parent::leg:UnorderedList[@Class = 'Definition'] and not($g_strDocType = 'ScottishAct')">
						<xsl:attribute name="margin-left">12pt</xsl:attribute>
						<!-- Try and simulate left hanging punctuation -->
						<xsl:if test="substring(descendant::text()[1], 1, 1) = '('">
							<xsl:attribute name="text-indent">-4pt</xsl:attribute>
						</xsl:if>
					</xsl:when>
					<xsl:when test="parent::leg:Para/parent::leg:BlockAmendment">
						<xsl:attribute name="margin-left">12pt</xsl:attribute>
					</xsl:when>
					<xsl:when test="@Hanging = 'hanging'">
						<xsl:attribute name="text-indent">-12pt</xsl:attribute>
						<xsl:attribute name="margin-left">12pt</xsl:attribute>			
					</xsl:when>
					<xsl:when test="parent::*[preceding-sibling::*]/parent::leg:EnactingText or @Hanging = 'indented'">
						<xsl:attribute name="text-indent">12pt</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:apply-templates/>
			</fo:block>
			</xsl:if>		
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:P1para/leg:Text">
	<xsl:choose>
		<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
			<xsl:if test="not(preceding-sibling::*[1][self::leg:BlockAmendment])">
				<xsl:choose>
					<xsl:when test="not(parent::*/preceding-sibling::*[not(self::leg:Pnumber)]) and not(preceding-sibling::*) and not(parent::*/parent::leg:BlockAmendment)">
						<fo:block text-align="justify" space-before="6pt">
							<xsl:attribute name="text-indent">12pt</xsl:attribute>
							<fo:inline>
								<xsl:if test="not(ancestor::leg:Schedule and $g_strDocType = 'NorthernIrelandStatutoryRule')">
									<xsl:attribute name="font-weight">bold</xsl:attribute>
								</xsl:if>
								<xsl:apply-templates select="ancestor::leg:P1[1]/leg:Pnumber"/>
								<xsl:text>.</xsl:text>
							</fo:inline>
							<fo:leader leader-pattern="space" leader-length="0.5em"/>
							<xsl:apply-templates/>
						</fo:block>										
					</xsl:when>
					<xsl:otherwise>
						<fo:block text-indent="0pt" space-before="6pt">
							<xsl:apply-templates/>
						</fo:block>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="not(preceding-sibling::*[1][self::leg:BlockAmendment])">
				<fo:block text-align="justify">
					<xsl:choose>
						<xsl:when test="preceding-sibling::leg:Text">
							<xsl:attribute name="space-before">3pt</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="space-before">
								<xsl:value-of select="$g_strLargeStandardParaGap"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>				
					<xsl:choose>
						<xsl:when test="parent::*/parent::*/parent::leg:UnorderedList">
							<xsl:attribute name="text-indent">-12pt</xsl:attribute>
							<xsl:attribute name="margin-left">36pt</xsl:attribute>
						</xsl:when>
						<xsl:when test="parent::leg:P1para/parent::leg:P1/parent::leg:P1group/parent::leg:Part/parent::leg:ScheduleBody">
						</xsl:when>			
						<xsl:when test="parent::leg:P1para/parent::leg:P1/parent::leg:P1group/parent::leg:ScheduleBody">
						</xsl:when>			
						<xsl:otherwise>
							<xsl:attribute name="margin-left">6pt</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates/>
				</fo:block>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:BlockAmendment">
    <xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
       <xsl:variable name="strTextNode" as="xs:string" select="generate-id(descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()])"/>
	<fo:block text-align="justify" font-size="{$g_strBodySize}">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:choose>
					<xsl:when test="parent::leg:P3para">
						<xsl:attribute name="margin-left">12pt</xsl:attribute>
					</xsl:when>
					<xsl:when test="parent::leg:P1para">
						<xsl:attribute name="margin-left">12pt</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="margin-left">0pt</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	        <xsl:apply-templates>
	            <xsl:with-param name="seqLastTextNodes" tunnel="yes" select="$seqLastTextNodes, $strTextNode" as="xs:string*"/>
	        </xsl:apply-templates>	
	</fo:block>
</xsl:template>

<xsl:template match="leg:AppendText"/>

<xsl:include href="EN_schema_lists_FO.xslt"/>

<xsl:template match="leg:GroupItem[not(preceding-sibling::GroupItem)]">
	<fo:block border-right="solid 0.5pt black" padding-right="6pt">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Character">
	<xsl:choose>
		<xsl:when test="@Name = 'ThinSpace'">
			<xsl:text>&#x202f;</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'NonBreakingSpace'">
			<xsl:text>&#x00a0;</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'EmSpace'">
			<xsl:text>&#x2003;</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'EnSpace'">
			<xsl:text>&#x2002;</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'Minus'">
			<xsl:text>&#x2212;</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'LinePadding'">
			<xsl:text>&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;</xsl:text>			
		</xsl:when>
		<xsl:when test="@Name = 'DotPadding'">
			<xsl:text> </xsl:text>
			<fo:leader leader-alignment="reference-area" leader-pattern="use-content" leader-length.maximum="100%">     ...     ...</fo:leader>
		</xsl:when>
		<xsl:otherwise>
			<fo:inline>[<xsl:value-of select="@Name"/>]</fo:inline>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:Emphasis">
	<xsl:choose>
		<xsl:when test="self::*[not(ancestor::leg:Para)]/ancestor::xhtml:th[1][ancestor::xhtml:thead] or parent::leg:Title/parent::leg:Pblock or parent::leg:PersonName/parent::leg:Signee">
			<fo:inline font-style="normal"><xsl:apply-templates/></fo:inline>
		</xsl:when>
		<xsl:otherwise>
			<fo:inline font-style="italic"><xsl:apply-templates/></fo:inline>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:Division/leg:Number/leg:Strong">
	<fo:block space-before="12pt">
		<xsl:choose>
			<xsl:when test="parent::leg:Title/parent::leg:Tabular or parent::xhtml:th/parent::xhtml:tr/parent::xhtml:tbody or (parent::leg:Title/parent::leg:P1group and $g_strDocClass = $g_strConstantSecondary)">
				<fo:inline font-weight="normal">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-weight="bold">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Strong">
	<xsl:choose>
		<xsl:when test="parent::leg:Title/parent::leg:Tabular or parent::xhtml:th/parent::xhtml:tr/parent::xhtml:tbody or (parent::leg:Title/parent::leg:P1group and $g_strDocClass = $g_strConstantSecondary)">
			<fo:inline font-weight="normal">
				<xsl:apply-templates/>
			</fo:inline>
		</xsl:when>
		<xsl:otherwise>
			<fo:inline font-weight="bold">
				<xsl:apply-templates/>
			</fo:inline>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:SmallCaps">
	<xsl:apply-templates>
		<xsl:with-param name="flSmallCaps" select="true()" tunnel="yes"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:include href="EN_schema_table_FO.xslt"/>

<xsl:template match="leg:InternalLink">
	<xsl:choose>
		<xsl:when test="@Ref and @Ref != ''">
			<fo:basic-link internal-destination="{@Ref}" color="{$g_strLinkColor}">
				<xsl:apply-templates/>
			</fo:basic-link>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:ExternalLink">
	<xsl:choose>
		<xsl:when test="@URI and @URI != ''">
			<fo:basic-link external-destination="url('{@URI}')" color="purple">
				<xsl:apply-templates/>
			</fo:basic-link>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:CitationSubRef">
	 <xsl:choose>
		<xsl:when test="normalize-space(@URI) != ''">
			<fo:basic-link color="{$g_strLinkColor}">
				<xsl:attribute name="external-destination">
					<xsl:text>url('</xsl:text>
					<xsl:value-of select="@URI"/>
					<xsl:text>')</xsl:text>
				</xsl:attribute>
				<xsl:call-template name="TSOgetID"/>
				<xsl:apply-templates/>
			</fo:basic-link>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	 </xsl:choose>
	
	<!--<xsl:apply-templates/>-->
</xsl:template>

<xsl:template match="leg:Citation">
	<xsl:choose>
		<xsl:when test="parent::leg:Title/parent::leg:ENprelims">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:otherwise>
			<fo:basic-link color="{$g_strLinkColor}">
				<xsl:call-template name="TSOgetID"/>
				<xsl:attribute name="external-destination">
					<xsl:text>url('</xsl:text>
					<xsl:value-of select="@URI"/>
					<xsl:text>')</xsl:text>
				</xsl:attribute>
				<xsl:apply-templates/>
			</fo:basic-link>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:SignedSection">
	<fo:block font-size="{$g_strBodySize}" space-before="24pt">
		<xsl:for-each select="leg:Signatory">
			<xsl:if test="preceding-sibling::leg:Signatory">
				<fo:block space-before="24pt"></fo:block>
			</xsl:if>
			<xsl:if test="leg:Para">
				<xsl:for-each select="leg:Para">
					<fo:block keep-with-next="always">
						<xsl:if test="not(preceding-sibling::*)">
							<xsl:attribute name="margin-top">18pt</xsl:attribute>
						</xsl:if>
						<xsl:if test="not(following-sibling::leg:Para)">
							<xsl:attribute name="space-after">48pt</xsl:attribute>
						</xsl:if>
						<xsl:apply-templates/>
					</fo:block>
				</xsl:for-each>
			</xsl:if>
			<xsl:for-each select="leg:Signee">
				<fo:table font-size="{$g_strBodySize}">
<!--					<fo:table-column column-width="30%"/>
					<fo:table-column column-width="70%"/>	-->
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell display-align="after">
								<xsl:if test="not(leg:Address or leg:DateSigned/leg:DateText or leg:LSseal)">
									<fo:block/>
								</xsl:if>
								<xsl:if test="leg:Address">
									<fo:block keep-with-next="always">
										<xsl:apply-templates select="leg:Address"/>
									</fo:block>
								</xsl:if>
								<xsl:if test="leg:DateSigned/leg:DateText">
									<fo:block keep-with-next="always">
										<xsl:apply-templates select="leg:DateSigned/leg:DateText"/>
									</fo:block>
								</xsl:if>
								<xsl:if test="leg:LSseal">
									<fo:block keep-with-next="always">
										<fo:external-graphic src="url('lsseal.tif')" fox:alt-text="Legal seal"/>
									</fo:block>
								</xsl:if>
							</fo:table-cell>
							<fo:table-cell display-align="after">
								<xsl:for-each select="leg:PersonName">
									<fo:block text-align="right" font-style="italic" keep-with-next="always">
										<xsl:apply-templates select="."/>
									</fo:block>
								</xsl:for-each>
								<fo:block text-align="right" keep-with-next="always">
									<xsl:apply-templates select="leg:JobTitle"/>	
								</fo:block>
								<xsl:if test="leg:Department">
									<fo:block text-align="right">
										<xsl:apply-templates select="leg:Department"/>		
									</fo:block>
								</xsl:if>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>							
			</xsl:for-each>
		</xsl:for-each>
	</fo:block>						
</xsl:template>

<xsl:template match="leg:FootnoteRef">
	<xsl:variable name="strFootnoteRef" select="@Ref" as="xs:string"/>
	<xsl:variable name="intFootnoteNumber" select="count($g_ndsFootnotes[@id = $strFootnoteRef]/preceding-sibling::*) + 1" as="xs:integer"/>
	<xsl:choose>
		<xsl:when test="ancestor::*[self::leg:Footnote]">
			<xsl:number value="$intFootnoteNumber" format="1"/> 
		</xsl:when>
		<xsl:when test="ancestor::*[not(self::leg:NumberedPara)]">
			<fo:footnote>
				<fo:inline font-size="8pt" vertical-align="super"><xsl:number value="$intFootnoteNumber" format="1"/></fo:inline>
				<fo:footnote-body>
					<fo:list-block start-indent="0pt"  provisional-label-separation="6pt" provisional-distance-between-starts="18pt">
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
		</xsl:when>
	</xsl:choose>
	
</xsl:template>

<xsl:template match="leg:ExplanatoryNotes">
	<fo:block space-before="36pt" space-after="36pt" keep-with-next="always">
		<fo:leader leader-pattern="rule" leader-length="100%" rule-style="solid" rule-thickness="0.5pt"/>
	</fo:block>
	<xsl:choose>
		<xsl:when test="leg:Title">
			<fo:block font-weight="bold" text-align="center" text-transform="uppercase" space-after="12pt" keep-with-next="always">
				<xsl:apply-templates select="leg:Title/node()"/>
			</fo:block>
		</xsl:when>
		<xsl:otherwise>
			<fo:block font-weight="bold" text-align="center" text-transform="uppercase" space-after="12pt" keep-with-next="always">
				<xsl:text>Explanatory Note</xsl:text>
			</fo:block>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="leg:Comment">
		<fo:block font-style="italic" text-align="center" space-after="12pt" keep-with-next="always">
			<xsl:apply-templates select="leg:Comment/node()"/>
		</fo:block>
	</xsl:if>
	<xsl:apply-templates select="*[not(self::leg:Title or self::leg:Comment)]"/>
	<xsl:if test="@AltVersionRefs">
		<xsl:variable name="strVersion" select="@AltVersionRefs" as="xs:string"/>
		<xsl:for-each select="//leg:Version[@id = $strVersion]">
			<xsl:apply-templates/>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:EarlierOrders">
	<xsl:choose>
		<xsl:when test="leg:Title">
			<fo:block font-weight="bold" text-align="center" text-transform="uppercase" space-before="12pt" space-after="12pt" keep-with-next="always">
				<xsl:choose>
					<xsl:when test="preceding-sibling::leg:ExplanatoryNotes">
						<xsl:attribute name="space-before">12pt</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="space-before">36pt</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="leg:Title/node()"/>
			</fo:block>
		</xsl:when>
		<xsl:otherwise>
			<fo:block font-weight="bold" text-align="center" text-transform="uppercase" space-after="12pt" keep-with-next="always">
				<xsl:choose>
					<xsl:when test="preceding-sibling::leg:ExplanatoryNotes">
						<xsl:attribute name="space-before">12pt</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="space-before">36pt</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>Note as to Earlier Commencement Orders</xsl:text>
			</fo:block>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="leg:Comment">
		<fo:block font-style="italic" text-align="center" space-after="12pt" keep-with-next="always">
			<xsl:apply-templates select="leg:Comment/node()"/>
		</fo:block>
	</xsl:if>
	<xsl:apply-templates select="*[not(self::leg:Title or self::leg:Comment)]"/>
</xsl:template>

<xsl:template match="leg:Figure">
	<xsl:choose>
		<xsl:when test="@Orientation = 'landscape'">
			<fo:block-container reference-orientation="90">
				<xsl:choose>
					<xsl:when test="contains(leg:Image/@Width,'pt')">
						<xsl:attribute name="inline-progression-dimension" select="leg:Image/@Width"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="inline-progression-dimension">645pt</xsl:attribute>
						<xsl:attribute name="break-before">page</xsl:attribute>
						<xsl:attribute name="break-after">page</xsl:attribute>						
					</xsl:otherwise>
				</xsl:choose>
				<fo:block>
					<xsl:apply-templates/>
				</fo:block>
			</fo:block-container>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:Image">
	<xsl:variable name="strURL" as="xs:string">
		<xsl:variable name="strRef" select="@ResourceRef" as="xs:string"/> 
		<xsl:value-of select="//leg:Resource[@id = $strRef]/leg:ExternalVersion/@URI"/>
	</xsl:variable>
	<xsl:variable name="strAltAttributeDesc">
		<xsl:variable name="ndsFormulaNode" select="//leg:Formula[@AltVersionRefs = current()/ancestor::leg:Version/@id]"/>
		<xsl:choose>
			<xsl:when test="$ndsFormulaNode">
				<xsl:value-of select="$ndsFormulaNode/descendant::math:math/@alttext"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@Description"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<fo:external-graphic src="url('{$strURL}')" fox:alt-text="{$strAltAttributeDesc}">
		<xsl:choose>
			<xsl:when test="@Width = 'scale-to-fit'">
				<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
				<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>				
				<xsl:attribute name="width">100%</xsl:attribute>
			</xsl:when>
			<xsl:when test="contains(@Width, 'pt')">
				<xsl:attribute name="content-width" select="@Width"/>
			</xsl:when>
		</xsl:choose>
	</fo:external-graphic>
</xsl:template>

<xsl:template match="leg:Formula">
	<fo:block>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:Where">
	<fo:block>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="math:math">
	<fo:block space-before="6pt" space-after="6pt">
		<xsl:if test="contains(@style, 'font-weight: bold')">
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		</xsl:if>
		<xsl:if test="contains(@style, 'text-align: center')">
			<xsl:attribute name="text-align">center</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="math:mo">
	<xsl:if test="not(@fence = 'true')">
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:apply-templates/>
	<xsl:if test="not(@fence = 'true')">
		<xsl:text> </xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:Inferior">
	<fo:inline baseline-shift="sub" font-size="70%">
		<xsl:apply-templates/>
	</fo:inline>
</xsl:template>

<xsl:template match="leg:Superior">
	<fo:inline baseline-shift="super" font-size="70%">
		<xsl:apply-templates/>
	</fo:inline>
</xsl:template>

<xsl:template match="leg:Form">
	<fo:block>
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="leg:IncludedDocument">
	<xsl:apply-templates select="//leg:Resource[@id = current()/@ResourceRef]"/>
</xsl:template>

<xsl:template match="leg:InternalVersion">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:XMLcontent">
	<fo:instream-foreign-object width="100%" content-width="scale-to-fit">
		<xsl:copy-of select="node()"/>
	</fo:instream-foreign-object>
</xsl:template>

<xsl:template name="TSOgetID">
	<xsl:if test="@id and not(key('ids', @id)[2])">
		<xsl:attribute name="id" select="@id"/>
	</xsl:if>
</xsl:template>

<xsl:template name="TSOheader">
	<xsl:if test="(/leg:EN/leg:ExplanatoryNotes/leg:ENprelims or /leg:EN/leg:Contents/leg:ContentsTitle) and $g_ndsLegMetadata/ukm:Number/@Value != ''">
				<fo:marker marker-class-name="runninghead1">
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
							<xsl:text>)</xsl:text>
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
						</xsl:otherwise>
					</xsl:choose>
				</fo:marker>
			</xsl:if>
			<xsl:if test="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText">
				<fo:marker marker-class-name="runninghead2">
					<xsl:choose>
						<xsl:when test="$g_strDocType = 'ScottishAct'">
							<xsl:text>which received Royal Assent on </xsl:text>
							<xsl:value-of select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>which received Royal Assent on </xsl:text>
							<xsl:value-of select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:marker>	
			</xsl:if>
</xsl:template>


<xsl:template name="TSOEMheader">
	<xsl:if test="(/leg:EN/leg:ExplanatoryNotes/leg:ENprelims or /leg:EN/leg:Contents/leg:ContentsTitle) and $g_ndsLegMetadata/ukm:Number/@Value != ''">
				<fo:marker marker-class-name="runninghead1">
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
							<xsl:text>)</xsl:text>
						</xsl:when>
						<xsl:when test="$g_strDocType = 'NorthernIrelandOrderInCouncil'">
							<xsl:text>This Explanatory Memorandum refers to the </xsl:text>
							<xsl:choose>
								<xsl:when test="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:Title">
									<xsl:apply-templates select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:Title" mode="header"/>
								</xsl:when>
								<xsl:when test="/leg:EN/leg:Contents/leg:ContentsTitle">
									<xsl:apply-templates select="/leg:EN/leg:Contents/leg:ContentsTitle" mode="header"/>
								</xsl:when>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="$g_ndsLegPrelims/leg:Number">
									<xsl:apply-templates select="$g_ndsLegPrelims/leg:Number"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> No. </xsl:text>
									<xsl:apply-templates select="$g_ndsLegMetadata/ukm:Number/@Value"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>This Explanatory Memorandum refers to </xsl:text>
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
						</xsl:otherwise>
					</xsl:choose>
				</fo:marker>
			</xsl:if>
			<xsl:if test="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText">
				<fo:marker marker-class-name="runninghead2">
					<xsl:choose>
						<xsl:when test="$g_strDocType = 'ScottishAct'">
							<xsl:text>which received Royal Assent on </xsl:text>
							<xsl:value-of select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>which received Royal Assent on </xsl:text>
							<xsl:value-of select="/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:DateOfEnactment/leg:DateText"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:marker>	
			</xsl:if>
</xsl:template>

<xsl:template match="leg:ENprelims/leg:Title | leg:Contents/leg:ContentsTitle" mode="header">
	<xsl:apply-templates mode="header"/>
</xsl:template>

<xsl:template match="leg:Citation" mode="header">
	<xsl:apply-templates mode="header"/>
</xsl:template>


<!-- ========== Text processing ========== -->

<xsl:include href="legislation_schema_text_FO.xslt"/>


<!-- ========== Create an annotated version of XML for pulling line numbers in ========== -->

<xsl:template match="/" mode="Annotate">
	<xsl:copy>
		<xsl:apply-templates mode="Annotate"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="*" mode="Annotate">
	<xsl:choose>
		<xsl:when test="node()">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates mode="Annotate"/>
			</xsl:copy>			
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
			</xsl:copy>			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="text()" mode="Annotate">
	<xsl:processing-instruction name="LineNumberID" select="generate-id()"/>
	<xsl:copy-of select="."/>
</xsl:template>

</xsl:stylesheet>