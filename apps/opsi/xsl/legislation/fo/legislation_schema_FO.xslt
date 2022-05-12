<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="2.0"
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:xmp="http://ns.adobe.com/xap/1.0/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:math="http://www.w3.org/1998/Math/MathML"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:rx="http://www.renderx.com/XSL/Extensions"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:tso="http://www.tso.co.uk/xslt"
xmlns:atom="http://www.w3.org/2005/Atom"
xmlns:err="http://www.tso.co.uk/assets/namespace/error" 
xmlns:dct="http://purl.org/dc/terms/"
xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
exclude-result-prefixes="tso atom">
	<xsl:import href="legislation_schema_headings_FO.xslt"/>
	<xsl:import href="../html/legislation_global_variables.xslt"/>
	<xsl:import href="../html/statuswarning.xsl"/>
	<xsl:import href="../html/process-annotations.xslt"/>

		
	<xsl:output method="xml" version="1.0" omit-xml-declaration="no"  indent="no" standalone="no" use-character-maps="FOcharacters"/>

	
	<!-- params to take value from uri query -->
	<xsl:param name="query_view"/>

	<xsl:param name="query_repeals" as="xs:string" select="'false'" />
	
	<!-- this is a work-around for the fact that the standard windows times new roman font does not have a complete utf-8 character set available which gives us issues on defined spaces for leg.gov -->
	<!-- NOTE FOP does not support the font-selection-strategy property  -->
	<xsl:param name="fullUTF8CSavailable" select="'false'"/>
	
	<xsl:variable name="showRepeals" as="xs:boolean" 
		select="$query_repeals = 'true'"  />		
	

	<!-- status warning messages -->


	<xsl:variable name="statusWarningHTML">
		<xsl:call-template name="TSOOutputUpdateStatus">
			<!--<xsl:with-param name="AddAppliedEffects" select="leg:IsContent()"/>-->
			<xsl:with-param name="AddAppliedEffects" select="true()"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="statusWarningHeader">
		<xsl:call-template name="TSOOutputUpdateStatus">
			<xsl:with-param name="AddAppliedEffects" select="false()"/>
		</xsl:call-template>
	</xsl:variable>	

	<!-- document uri -->
	<xsl:variable name="strDocURI" select="/leg:Legislation/@DocumentURI"/>	

	<xsl:variable name="isRepealedAct" select="matches((/leg:Legislation/ukm:Metadata/dc:title)[1], '\((repealed|revoked)(\s*[\d]{1,2}\.[\d]{1,2}\.[\d]{4}\s*)?\)\s*$', 'i')"/>
	
	<!-- this is a global variable which has to match the name of the version variable in the imported stylesheet statuswarning.xsl otherwise we will not have the correct status warnings when run from the PDF service -->
	<!-- as we do not have the pramsdoc available to the PDF service we will have to determine the version from the document URI -->
	<xsl:variable name="version">
		<xsl:choose>
			<xsl:when test="contains($strDocURI,'prospective')">prospective</xsl:when>
			<xsl:when test="matches($strDocURI,'[0-9]{4}-[0-9]{2}-[0-9]{2}')">
				<xsl:analyze-string select="$strDocURI" regex="[0-9]{{4}}-[0-9]{{2}}-[0-9]{{2}}">
					<xsl:matching-substring><xsl:value-of select="."/></xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>		
	
	
	
	<xsl:variable name="signatureText">
		<xsl:choose>
			<xsl:when test="leg:IsCurrentWelsh(/)">
					<xsl:text>Llofnod</xsl:text>
			</xsl:when>
			<xsl:otherwise>
					<xsl:text>Signature</xsl:text>			
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:variable>

	<!-- check if there is an EN -->
	<xsl:variable name="noteURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/note']/@href"/>
	
	<xsl:variable name="noteText">
		<xsl:choose>
			<xsl:when test="leg:IsCurrentWelsh(/)">
				<xsl:text>Nodyn Esboniadol</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Explanatory Note</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	
	<!-- Map characters for serialization -->
	<xsl:character-map name="FOcharacters">
		<!-- Do this just so we can see NBSP -->
		<xsl:output-character character="&#160;" string="&amp;#160;"/>
		<xsl:output-character character="⿿" string="-"/>
		<xsl:output-character character="&#8209;" string="-"/>
		<xsl:output-character character="&#x2011;" string="-"/>
		<xsl:output-character character="&#x2012;" string="-"/>	
		<xsl:output-character character="&#x2FFF;" string="&#x201C;"/><!--left double quote-->
		<xsl:output-character character="&#x2FDD;" string="&#x201D;"/><!--right double quote-->
		<xsl:output-character character="&#x2015;" string="&#x2014;"/><!--emdash-->
		<xsl:output-character character="―" string="&#8212;"/><!--right double quote-->
		<xsl:output-character character="&#x30a;" string="&#x00B0;"/><!--combining ring above to degree-->		
	</xsl:character-map>

	<!-- these will not work for the PDF generation so not used -->
	<xsl:variable name="requestInfoDoc" select="if (doc-available('input:request-info')) then doc('input:request-info') else ()"/>

	<xsl:variable name="FOparamsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

	<!-- cssup: set extent to true to generate this particular pdf 
	<xsl:variable name="g_matchExtent">true</xsl:variable>
	-->
	<xsl:variable name="g_matchExtent" 
	select="if ($FOparamsDoc/parameters/extent != '' or $query_view='extent') then 'true' else 'false'"/>
	

	<xsl:variable name="g_view" as="xs:string" select="($FOparamsDoc/parameters/view, '')[1]"/>
	
	<!-- ========== Parameters ========== -->

	<xsl:param name="g_flShowFrontmatter" select="false()" as="xs:boolean"/>

	<!-- use a value of FOP0.95 if FOP 0.95 is used to generate the footnote hacks -->
	<xsl:param name="g_FOprocessor" select="'FOP1.0'" as="xs:string"/>
	
	
	<!-- ========== Global Constants ========== -->

	<xsl:variable name="g_strConstantPrimary" select="'primary'" as="xs:string"/>
	<xsl:variable name="g_strConstantSecondary" select="'secondary'" as="xs:string"/>
	<xsl:variable name="g_strConstantEuretained" select="'euretained'" as="xs:string"/>
	<xsl:variable name="g_strConstantDocumentStatusDraft" select="'draft'" as="xs:string"/>
	<xsl:variable name="g_strConstantOutputTypePrimary" select="'PrimaryStyle'" as="xs:string"/>
	<xsl:variable name="g_strConstantOutputTypeSecondary" select="'SecondaryStyle'" as="xs:string"/>
	<xsl:variable name="g_strConstantOutputTypeEURetained" select="'euretainedStyle'" as="xs:string"/>
	<xsl:variable name="g_strConstantImagesPath" select="'http://www.legislation.gov.uk/images/crests/'" as="xs:string"/>
	
	
	<xsl:variable name="g_documentLanguage" select="if (/leg:Legislation/@xml:lang) then /leg:Legislation/@xml:lang else 'en'"  as="xs:string"/>
	<xsl:variable name="g_dctitle" select="/leg:Legislation/ukm:Metadata/dc:title"/>

	<xsl:variable name="wholeActURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/act' and @title='whole act']/@href" />
	<xsl:variable name="wholeActWithoutSchedulesURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/body' and @title='body']/@href" />
	<xsl:variable name="schedulesOnlyURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/schedules' and @title='schedules']/@href" />
	<xsl:variable name="introURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/introduction' and @title='introduction']/@href" />	
	
	<xsl:variable name="nstSection" as="element()?"
		select="if ($nstSelectedSection/parent::leg:P1group) then $nstSelectedSection/.. else $nstSelectedSection" />
	
	
	<!--  let $selectedSection be the (XML element of the) section that's being looked at, which you already get hold of  -->
	<!-- put a bodge in to at least select /leg:Legislation  so we get something returned id this fails as in the case of ukpga/2000/36/schedules/ni   -->
	<xsl:variable name="selectedSection" as="element()?"
		select="
			if ($g_strwholeActURI = $dcIdentifier) then /leg:Legislation
			else if ($dcIdentifier = ($introURI, $wholeActWithoutSchedulesURI)) then  /leg:Legislation/(leg:Primary | leg:Secondary | leg:EURetained)//*[@DocumentURI = $strCurrentURIs]
			else if ($dcIdentifier = $schedulesOnlyURI)  then /leg:Legislation/(leg:Primary | leg:Secondary | leg:EURetained)/leg:Schedules
			else if ($nstSection)  then $nstSection
			else /leg:Legislation" />
	<xsl:variable name="selectedSectionSubstituted" as="xs:boolean" select="tso:isSubstituted($selectedSection)" />

	<!-- Book antiqua not available so we will use just Times
	<xsl:variable name="g_strMainFont" select="if ($g_strDocClass = $g_strConstantSecondary) then 'Times' else 'BookAntiqua'" as="xs:string"/> -->
	<xsl:variable name="g_strMainFont" select="if ($g_strDocClass = $g_strConstantSecondary) then 'Times New Roman' else 'Times New Roman'" as="xs:string"/> 
	<xsl:variable name="g_strOutputType" as="xs:string">PrimaryStyle</xsl:variable>
	<xsl:variable name="g_dblBodySize" as="xs:double">
		<xsl:choose>
			<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">11.5</xsl:when>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">10.5</xsl:when>
			<xsl:otherwise>11</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="g_endNoteSize" as="xs:double">10</xsl:variable>
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
	<xsl:variable name="g_strHeaderSize" select="if ($g_strDocType = 'NorthernIrelandAct') then '11pt' else '8pt'" as="xs:string"/>
	<xsl:variable name="g_strFooterSize" select="if ($g_strDocType = 'NorthernIrelandAct') then '11pt' else '8pt'" as="xs:string"/>
	<xsl:variable name="g_strStatusSize" select="'8pt'" as="xs:string"/>
	<xsl:variable name="g_strLinkColor" select="'rgb(0,102,153)'" as="xs:string"/>
	
	<xsl:variable name="g_strSmallCapsSize" select="concat($g_intSmallCapsSize, 'pt')" as="xs:string"/>
	<xsl:variable name="g_strLineHeight" select="concat($g_intLineHeight, 'pt')" as="xs:string"/>
	<xsl:variable name="g_dblPageHeight" select="841.89" as="xs:double"/>
	<xsl:variable name="g_dblPageWidth" select="595.276" as="xs:double"/>
	<xsl:variable name="g_PageBodyWidth" select="415.276" as="xs:double"/>
	<xsl:variable name="g_strStandardParaGap" select="if ($g_strDocClass = $g_strConstantSecondary) then '4pt' else '2pt'"/>
	<xsl:variable name="g_strLargeStandardParaGap" select="if ($g_strDocClass = $g_strConstantSecondary) then '4pt' else '8pt'"/>
	<xsl:variable name="g_intMaxTfootCharCount"  as="xs:integer" select="1001"/>
	<!-- Define the units of measurements for the above -->
	<xsl:variable name="g_strUnits" select="'pt'" as="xs:string"/>
	<xsl:variable name="g_flAddTargets" select="false()" as="xs:boolean"/>
	<!-- Indicates whether line space between paragraphs should be suppressed in tables - needed for line numbering -->
	<xsl:variable name="g_flSuppressTableLineSpace" select="true()" as="xs:boolean"/>

	<!-- Store versions -->
	<xsl:variable name="g_ndsVersions" select="/leg:Legislation/leg:Versions/leg:Version"/>

	<!-- Self-reference to document being processed -->
	<xsl:variable name="g_ndsMainDoc" select="."/>

	<!-- ========== Global Variables ========== -->

	<xsl:variable name="g_ndsLegMetadata" select="/(leg:Legislation | leg:EN)/ukm:Metadata/(ukm:SecondaryMetadata | ukm:PrimaryMetadata | ukm:ENmetadata | ukm:EUMetadata)"/>

	<xsl:variable name="g_ndsValidDate" select="/leg:Legislation/ukm:Metadata/dct:valid"/>
	<xsl:variable name="g_ndsLegPrelims" select="/leg:Legislation/(leg:Primary/leg:PrimaryPrelims | leg:Secondary/leg:SecondaryPrelims | leg:EURetained/leg:EUPrelims)"/>
	<xsl:variable name="g_strDocType" select="$g_ndsLegMetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value" as="xs:string"/>
	<xsl:variable name="g_strDocClass" as="xs:string">
		<!-- For NI Acts the look and feel is as for secondary legislation so set doc class accordingly -->
		<xsl:choose>
			<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
				<xsl:value-of select="$g_strConstantSecondary"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$g_ndsLegMetadata/ukm:DocumentClassification/ukm:DocumentCategory/@Value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="g_strDocStatus" select="$g_ndsLegMetadata/ukm:DocumentClassification/ukm:DocumentStatus/@Value" as="xs:string"/>
	<xsl:variable name="g_ndsFootnotes" select="/leg:Legislation/leg:Footnotes/leg:Footnote"/>

	
	<!-- Chunyu:Added two variables to deal with the xmlcontent within the resorce -->
	<xsl:variable name="includDocRef" select="//leg:IncludedDocument//@ResourceRef"/>
	<xsl:variable name="includDoc" select="//leg:Resource[@id = $includDocRef]"/>
	
	
	
	<!-- ========== Key used to check for duplicate id's========== -->
	<xsl:key name="ids" match="*" use="@id"/>


	<xsl:key name="citations" match="leg:Citation" use="@id" />
	<xsl:key name="commentary" match="leg:Commentary" use="@id"/>
	<xsl:key name="commentaryRef" match="leg:CommentaryRef" use="@Ref"/>
	<xsl:key name="commentaryRef" match="leg:Addition | leg:Repeal | leg:Substitution" use="@CommentaryRef"/>
	<xsl:key name="additionRepealChanges" match="leg:Addition | leg:Repeal | leg:Substitution" use="@ChangeId"/>
	<xsl:key name="commentaryRefInChange" match="leg:Addition | leg:Repeal | leg:Substitution" use="concat(@CommentaryRef, '+', @ChangeId)" />
	<xsl:key name="citationLists" match="leg:CitationList" use="@id"/>
	<xsl:key name="substituted" match="leg:Repeal[@SubstitutionRef]" use="@SubstitutionRef" />
	
<!-- we need to reference the document order of the commentaries rather than the commenatry order in order to gain the correct numbering sequence. Therefore we will build a nodeset of all CommentartRef/Addition/Repeal elements and their types which can be queried when determining the sequence number -->
<!-- Chunyu:Added a condition for versions. We should go from the root call Call HA048969 -->
	<xsl:variable name="g_commentaryOrder">
		<xsl:variable name="commentaryRoot" as="node()+"
			select="if (empty($selectedSection)) then root()
					(: include all commentaries if the section has been repealed :)
					else if ($selectedSection/@Match = 'false' and (not($selectedSection/@Status) or $selectedSection/@Status != 'Prospective') and not($selectedSection/@RestrictStartDate and ((($version castable as xs:date) and xs:date($selectedSection/@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date($selectedSection/@RestrictStartDate) &gt; current-date())))) then root()
					 else if (root()//leg:Versions) then root()
					else $selectedSection" />
		<xsl:for-each-group select="$commentaryRoot//(leg:CommentaryRef | leg:Addition | leg:Repeal | leg:Substitution)" group-by="(@Ref, @CommentaryRef)[1]">
			<leg:commentary id="{current-grouping-key()}" Type="{key('commentary', current-grouping-key())/@Type}" />
		</xsl:for-each-group>
	</xsl:variable>
	
	<!-- ========== Main code ========== -->
	
	<xsl:template match="/">
		<!-- Create FO output -->
		<fo:root id="{replace(/(leg:Legislation | leg:EN)/ukm:Metadata/atom:link[@rel = 'self']/@href,'.xml','.pdf')}">

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
					<dc:creator>www.legislation.gov.uk</dc:creator>
					<dc:description>
						<xsl:for-each select="(leg:Legislation/ukm:Metadata/dc:subject)">
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
			
			<xsl:if test="$g_flShowFrontmatter">
				<xsl:call-template name="TSOoutputFrontmatter"/>
			</xsl:if>

			<!-- Only primary style outputs TOC before any actual content -->
			<xsl:apply-templates select="/leg:Legislation/leg:Contents" mode="MainContents"/>
			

			
			<!-- #HA057536 - MJ: output resources if file contains no main content -->
			<xsl:if test="(/leg:Legislation/*/leg:Body | /leg:Legislation/*/leg:EUBody | /leg:Legislation/*/leg:PrimaryPrelims  | /leg:Legislation/*/leg:SecondaryPrelims  | /leg:Legislation/*/leg:EUPrelims | /leg:Legislation/leg:Resources[not(preceding-sibling::leg:Primary or preceding-sibling::leg:Secondary)]) and $g_view != 'contents' and not(/leg:Legislation/leg:Contents)">
				
				<fo:page-sequence master-reference="main-sequence" initial-page-number="1" letter-value="auto" xml:lang="{$g_documentLanguage}">

					<fo:static-content flow-name="xsl-footnote-separator">
						<fo:block id="footnoteBlock" space-after="12pt">
							<fo:leader leader-pattern="rule" leader-length="100%" rule-style="solid" rule-thickness="0.5pt"/>
						</fo:block>
					</fo:static-content>

					<!-- Footer for first page -->
					<xsl:if test="$g_strDocClass = $g_strConstantSecondary and //ukm:DepartmentCode">
						<fo:static-content flow-name="footer-only-after">
							<fo:block margin-left="90pt" margin-right="90pt" font-size="{$g_strFooterSize}" font-weight="bold" text-align="right" font-family="{$g_strMainFont}">
								<xsl:text>[</xsl:text>
								<xsl:value-of select="//ukm:DepartmentCode/@Value"/>
								<xsl:text>]</xsl:text>
							</fo:block>
						</fo:static-content>			
					</xsl:if>

					<!-- Only NI Acts have a page number on the first main page -->
					<xsl:if test="$g_strDocType = 'NorthernIrelandAct'">
						<fo:static-content flow-name="footer-only-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<xsl:call-template name="columns-3"/>
								<fo:table-body>
									<xsl:call-template name="statusWarningHeader">
										<xsl:with-param name="number-columns-spanned">3</xsl:with-param>
									</xsl:call-template>
								</fo:table-body>
							</fo:table>
						</fo:static-content>	
						<fo:static-content flow-name="footer-only-after">
							<fo:block font-size="{$g_strFooterSize}" text-align="center" font-family="{$g_strMainFont}">
								<fo:inline>
									<fo:page-number/>
								</fo:inline>
							</fo:block>
						</fo:static-content>	
					</xsl:if>




					<xsl:if test="$g_strDocClass != $g_strConstantSecondary">
						<!-- Header for even pages -->
						<fo:static-content flow-name="even-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<xsl:call-template name="columns-2-even"/>									
								<fo:table-body border-bottom="solid 0.5pt black">
									<fo:table-row border-bottom="solid 0.5pt black" >
										<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt">
											<fo:block font-family="{$g_strMainFont}">
												<fo:inline>
													<fo:page-number/>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
											<xsl:call-template name="runningheaders-body"/>
											<xsl:call-template name="TSOdocDateTime"/>
										</fo:table-cell>
									</fo:table-row>
									<xsl:call-template name="statusWarningHeader"/>
								</fo:table-body>
							</fo:table>
						</fo:static-content>			

						<fo:static-content flow-name="footer-only-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<xsl:call-template name="columns-2-even"/>										
								<fo:table-body border-bottom="solid 0.5pt black" border-top="solid 0.5pt black">
									<xsl:call-template name="statusWarningHeader"/>
								</fo:table-body>
							</fo:table>
						</fo:static-content>	
						
						<!-- Header for odd pages -->
						<fo:static-content flow-name="odd-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<xsl:call-template name="columns-2-odd"/>
								<fo:table-body border-bottom="solid 0.5pt black">
									<fo:table-row border-bottom="solid 0.5pt black" >
										<fo:table-cell margin-left="0pt" margin-right="0pt">
											<xsl:call-template name="runningheaders-body"/>
											<xsl:call-template name="TSOdocDateTime"/>									
										</fo:table-cell>
										<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
											<fo:block font-family="{$g_strMainFont}" font-size="10pt">
												<fo:inline>
													<fo:page-number/>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
									<xsl:call-template name="statusWarningHeader"/>
								</fo:table-body>
							</fo:table>
						</fo:static-content>		
					</xsl:if>

					<xsl:if test="$g_strDocClass = $g_strConstantSecondary and $g_strDocType != 'NorthernIrelandAct'">
						<!-- Header for even pages -->
						
						<fo:static-content flow-name="even-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<xsl:call-template name="columns-2-even"/>										
								<fo:table-body border-bottom="solid 0.5pt black">
									<fo:table-row border-bottom="solid 0.5pt black" >
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
									<xsl:call-template name="columns-2-even"/>										
									<fo:table-body border-bottom="solid 0.5pt black" border-top="solid 0.5pt black">
										<xsl:call-template name="statusWarningHeader"/>
									</fo:table-body>
								</fo:table>
							</fo:static-content>	
						
						<!-- Header for odd pages -->
						<fo:static-content flow-name="odd-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<xsl:call-template name="columns-2-odd"/>
								<fo:table-body border-bottom="solid 0.5pt black">
									<fo:table-row border-bottom="solid 0.5pt black" >
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
					
					
					<xsl:if test="$g_strDocType = 'NorthernIrelandAct'">
						<xsl:call-template name="TSOgetNIheaderFooter"/>
					</xsl:if>

					<!-- Footers on pages -->	
					<xsl:if test="$g_strDocClass = $g_strConstantSecondary">
						<xsl:call-template name="TSOsecondaryMainFooter"/>
					</xsl:if>	

					<xsl:choose>
						<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
							<xsl:call-template name="TSO_EUPrelims"/>
						</xsl:when>
						<xsl:when test="$g_strDocClass = $g_strConstantPrimary or $g_strDocType = 'NorthernIrelandAct'">
							<xsl:call-template name="TSO_PrimaryPrelims"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="TSO_SecondaryPrelims"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:page-sequence>
			</xsl:if>
			
			
			<!-- SCHEDULE SEQUENCE OF PAGES -->
			<xsl:if test="/leg:Legislation/*/leg:Schedules or /leg:Legislation/leg:Secondary/leg:ExplanatoryNotes or /leg:Legislation/leg:Secondary/leg:EarlierOrders or /leg:Legislation/*/leg:Attachments">
				<fo:page-sequence master-reference="schedule-sequence"  xml:lang="{$g_documentLanguage}">
					<fo:static-content flow-name="xsl-footnote-separator">
						<fo:block>
							<fo:leader leader-pattern="rule" leader-length="96pt" rule-style="solid" rule-thickness="0.5pt"/>
						</fo:block>
					</fo:static-content>

					<xsl:choose>
						<xsl:when test="$g_strDocClass != $g_strConstantSecondary">
							<fo:static-content flow-name="even-before">
								<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
									<xsl:call-template name="columns-2-even"/>	
									<fo:table-body border-bottom="solid 0.5pt black">
										<fo:table-row border-bottom="solid 0.5pt black">
											<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt">
												<fo:block font-family="{$g_strMainFont}">
													<fo:inline>
														<fo:page-number/>
													</fo:inline>
												</fo:block>
											</fo:table-cell>
											<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
												<xsl:call-template name="runningheaders-schedule"/>
												<xsl:call-template name="TSOdocDateTime"/>
											</fo:table-cell>
										</fo:table-row>
										<xsl:call-template name="statusWarningHeader"/>
									</fo:table-body>
								</fo:table>
							</fo:static-content>			
							<fo:static-content flow-name="odd-before">
								<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
									<xsl:call-template name="columns-2-odd"/>
									<fo:table-body border-bottom="solid 0.5pt black">
										<fo:table-row border-bottom="solid 0.5pt black">
											<fo:table-cell margin-left="0pt" margin-right="0pt">
												<xsl:call-template name="runningheaders-schedule"/>
												<xsl:call-template name="TSOdocDateTime"/>
											</fo:table-cell>
											<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
												<fo:block font-family="{$g_strMainFont}" font-size="10pt">
													<fo:inline>
														<fo:page-number/>
													</fo:inline>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
										<xsl:call-template name="statusWarningHeader"/>
									</fo:table-body>
								</fo:table>
							</fo:static-content>		
						</xsl:when>
						<xsl:when test="$g_strDocType = 'NorthernIrelandAct'">
							<xsl:call-template name="TSOgetNIheaderFooter"/>
							<xsl:call-template name="TSOsecondaryScheduleFooter"/>
						</xsl:when>
						<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
							
							<fo:static-content flow-name="even-before">
								<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed"  width="{$g_PageBodyWidth}pt">
									<xsl:call-template name="columns-3"/>
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell number-columns-spanned="3" text-align="right" margin-left="0pt" margin-right="0pt">
												<xsl:call-template name="TSOdocDateTime"/>
											</fo:table-cell>
										</fo:table-row>
										<xsl:call-template name="statusWarningHeader">
											<xsl:with-param name="number-columns-spanned">3</xsl:with-param>
										</xsl:call-template>
									</fo:table-body>
								</fo:table>
							</fo:static-content>					
							<fo:static-content flow-name="even-before-first">
								<fo:table  margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed"  width="{$g_PageBodyWidth}pt">
									<xsl:call-template name="columns-3"/>
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell number-columns-spanned="3" text-align="right" margin-left="0pt" margin-right="0pt">
												<xsl:call-template name="TSOdocDateTime"/>
											</fo:table-cell>
										</fo:table-row>
										<xsl:call-template name="statusWarningHeader">
											<xsl:with-param name="number-columns-spanned">3</xsl:with-param>
										</xsl:call-template>
									</fo:table-body>
								</fo:table>
							</fo:static-content>
							<!-- Header for odd pages -->
							<fo:static-content flow-name="odd-before">
								<fo:table  margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed"  width="{$g_PageBodyWidth}pt">
									<xsl:call-template name="columns-3"/>
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell number-columns-spanned="3" text-align="left" margin-left="0pt" margin-right="0pt">
												<xsl:call-template name="TSOdocDateTime"/>
											</fo:table-cell>
										</fo:table-row>
										<xsl:call-template name="statusWarningHeader">
											<xsl:with-param name="number-columns-spanned">3</xsl:with-param>
										</xsl:call-template>
									</fo:table-body>
								</fo:table>
								<!--<fo:block font-size="{$g_strSmallCapsSize}" font-family="{$g_strMainFont}" margin-top="24pt" margin-right="-72pt" text-align="right">
									<fo:retrieve-marker retrieve-class-name="SideBar"/>
								</fo:block>-->
							</fo:static-content>		
							<fo:static-content flow-name="odd-before-first">
								<fo:table  margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed"  width="{$g_PageBodyWidth}pt">
									<xsl:call-template name="columns-3"/>
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell number-columns-spanned="3" text-align="left" margin-left="0pt" margin-right="0pt">
												<xsl:call-template name="TSOdocDateTime"/>
											</fo:table-cell>
										</fo:table-row>
										<xsl:call-template name="statusWarningHeader">
											<xsl:with-param name="number-columns-spanned">3</xsl:with-param>
										</xsl:call-template>
									</fo:table-body>
								</fo:table>
							</fo:static-content>
							
							<xsl:call-template name="TSOsecondaryScheduleFooter"/>
						</xsl:when>
					</xsl:choose>

					<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" font-size="{$g_strBodySize}" line-height="{$g_strLineHeight}">
						<!--<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
							<fo:marker marker-class-name="runninghead2">
								<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
								<xsl:text> (c. </xsl:text>
								<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
								<xsl:text>)</xsl:text>
							</fo:marker>	
						</xsl:if>-->
						<xsl:choose>
							<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
								<fo:marker marker-class-name="runninghead2">
									<xsl:apply-templates select="leg:abridgeContent(/leg:Legislation/ukm:Metadata/dc:title, 13)"  mode="header"/>
								</fo:marker>
							</xsl:when>
							<xsl:when test="$g_strDocClass = $g_strConstantPrimary">
								<fo:marker marker-class-name="runninghead2">
									<xsl:choose>
										<xsl:when test="$g_ndsLegPrelims/leg:Title">
											<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"  mode="header"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"  mode="header"/>
										</xsl:otherwise>
									</xsl:choose>
									<!-- addedy by Yash call	HA051710 - corrected number for wlaes measures and act-->
									<xsl:choose>
										<xsl:when test="$g_strDocType = 'ScottishAct'">
											<xsl:text> asp </xsl:text>
											<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>											
										</xsl:when>
										<xsl:when test="$g_strDocType = 'WelshAssemblyMeasure'">
											<xsl:choose>
												<xsl:when test="$g_documentLanguage = 'cy'">
													<xsl:text> mccc </xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:text> nawm </xsl:text>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>	
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
											<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text> (c. </xsl:text>
											<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
											<xsl:text>)</xsl:text>
										</xsl:otherwise>
									</xsl:choose>									
								</fo:marker>
							</xsl:when>
							<xsl:otherwise>
								<fo:marker marker-class-name="runninghead2">
									<xsl:text>&#8203;</xsl:text>
								</fo:marker>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="/leg:Legislation/*/leg:Schedules"/>
						<xsl:apply-templates select="/leg:Legislation/*/leg:Attachments"/>
						<!-- Chunyu:Added a condition for xmlcontent -->
						<xsl:if test="$includDoc//leg:XMLcontent[not(descendant::leg:Figure)] | $includDoc//leg:XMLcontent[not(descendant::leg:Image)]">
							<fo:block>
								<xsl:apply-templates select="$includDoc//leg:XMLcontent"/>
							</fo:block>
						</xsl:if>-
						<xsl:apply-templates select="/leg:Legislation/leg:Secondary/leg:ExplanatoryNotes"/>	
						<xsl:apply-templates select="/leg:Legislation/leg:Secondary/leg:EarlierOrders"/>
					
					<!-- this is a bodge fix to get around a FOP issue when there is not enough space on the end page for all the footnotes but if it takes a footnote over to the next page then there is enough space for the content to fit in on the first page where it tries to render the footnote back on the first page thus resulting in a loop --> 
						<xsl:if test="/leg:Legislation/leg:Footnotes">
							<fo:block font-size="{$g_strBodySize}" space-before="36pt" text-align="left" keep-with-next="always">
								<xsl:text>&#8203;</xsl:text>
							</fo:block>
						</xsl:if>
					
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
			
			<!-- we will treat EU footnotes as end notes -->
			<xsl:if test="$g_strDocClass = $g_strConstantEuretained and exists(/leg:Legislation/leg:Footnotes)">
				<fo:page-sequence master-reference="endnote-sequence"  xml:lang="{$g_documentLanguage}">
					<!-- Header for even pages -->
					<fo:static-content flow-name="even-before">
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
							<xsl:call-template name="columns-2-even"/>										
							<fo:table-body border-bottom="solid 0.5pt black">
								<fo:table-row margin-left="0pt" margin-right="0pt" border-bottom="solid 0.5pt black" >
									<fo:table-cell font-size="10pt" margin-left="0pt" padding-left="0pt">
										<fo:block font-family="{$g_strMainFont}" text-align="left">
											<fo:inline>
												<fo:page-number/>
											</fo:inline>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead2"/>
										</fo:block>
										<xsl:call-template name="TSOdocDateTime"/>
									</fo:table-cell>
								</fo:table-row>
								<xsl:call-template name="statusWarningHeader"/>
							</fo:table-body>
						</fo:table>
					</fo:static-content>			

					<fo:static-content flow-name="odd-before">
						<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
							<xsl:call-template name="columns-2-odd"/>
							<fo:table-body border-bottom="solid 0.5pt black">
								<fo:table-row border-bottom="solid 0.5pt black" >
									<fo:table-cell margin-left="0pt" margin-right="0pt">
										<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
											<fo:retrieve-marker retrieve-class-name="runninghead2"/>
										</fo:block>
										<xsl:call-template name="TSOdocDateTime"/>									
									</fo:table-cell>
									<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
										<fo:block font-family="{$g_strMainFont}" font-size="10pt">
											<fo:inline>
												<fo:page-number/>
											</fo:inline>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<xsl:call-template name="statusWarningHeader"/>
							</fo:table-body>
						</fo:table>
					</fo:static-content>		
					
					<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" font-size="{$g_strBodySize}" line-height="{$g_strLineHeight}">
						<fo:marker marker-class-name="runninghead2">
							<xsl:apply-templates select="leg:abridgeContent(/leg:Legislation/ukm:Metadata/dc:title, 13)"  mode="header"/>
						</fo:marker>
						<xsl:apply-templates select="/leg:Legislation/leg:Footnotes" mode="EU-EndNotes"/>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>


			<xsl:if test="$statusWarningHTML//xhtml:div[@id='statusWarning']">
				<fo:page-sequence master-reference="unapplied-effects-sequence"  xml:lang="{$g_documentLanguage}">
					<xsl:if test="$g_strDocClass != $g_strConstantSecondary">
						<!-- Header for even pages -->
						<fo:static-content flow-name="even-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<xsl:call-template name="columns-2-even"/>										
								<fo:table-body border-bottom="solid 0.5pt black">
									<fo:table-row margin-left="0pt" margin-right="0pt" border-bottom="solid 0.5pt black" >
										<fo:table-cell font-size="10pt" margin-left="0pt" padding-left="0pt">
											<fo:block font-family="{$g_strMainFont}" text-align="left">
												<fo:inline>
													<fo:page-number/>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
											<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
												<fo:retrieve-marker retrieve-class-name="runninghead2"/>
											</fo:block>
											<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
												<fo:retrieve-marker retrieve-class-name="runningheadpart"/>
											</fo:block>
											<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
												<fo:retrieve-marker retrieve-class-name="runningheadchapter"/>
											</fo:block>
											<xsl:call-template name="TSOdocDateTime"/>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:static-content>			

						<fo:static-content flow-name="odd-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<xsl:call-template name="columns-2-odd"/>	
								<fo:table-body border-bottom="solid 0.5pt black">
									<fo:table-row border-bottom="solid 0.5pt black" >
										<fo:table-cell margin-left="0pt" margin-right="0pt">
											<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
												<fo:retrieve-marker retrieve-class-name="runninghead2"/>
											</fo:block>
											<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
												<fo:retrieve-marker retrieve-class-name="runningheadpart"/>
											</fo:block>
											<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
												<fo:retrieve-marker retrieve-class-name="runningheadchapter"/>
											</fo:block>
											<xsl:call-template name="TSOdocDateTime"/>									
										</fo:table-cell>
										<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
											<fo:block font-family="{$g_strMainFont}" font-size="10pt">
												<fo:inline>
													<fo:page-number/>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:static-content>		
					</xsl:if>
					<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" font-size="{$g_strBodySize}" line-height="{$g_strLineHeight}">
						<fo:marker marker-class-name="runninghead2">
							<xsl:choose>
								<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
									<xsl:apply-templates select="leg:abridgeContent(/leg:Legislation/ukm:Metadata/dc:title, 13)"  mode="header"/>
								</xsl:when>
								<xsl:when test="$g_ndsLegPrelims/leg:Title">
									<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"  mode="header"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="/leg:Legislation/ukm:Metadata/dc:title"  mode="header"/>
								</xsl:otherwise>
							</xsl:choose>
							<!-- addedy by Yash call	HA051710 - corrected number for wlaes measures and act-->
							<xsl:choose>
								<xsl:when test="$g_strDocClass = $g_strConstantEuretained"/>
								<xsl:when test="$g_strDocType = 'ScottishAct'">
									<xsl:text> asp </xsl:text>
									<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>											
								</xsl:when>
								<xsl:when test="$g_strDocType = 'WelshAssemblyMeasure'">
									<xsl:choose>
										<xsl:when test="$g_documentLanguage = 'cy'">
											<xsl:text> mccc </xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text> nawm </xsl:text>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>	
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
									<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> (c. </xsl:text>
									<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
									<xsl:text>)</xsl:text>
								</xsl:otherwise>
							</xsl:choose>	
						</fo:marker>
						<xsl:apply-templates select="$statusWarningHTML" mode="statuswarning"/>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
		</fo:root>	
	</xsl:template>

	<xsl:template name="TSOdocDateTime">
		<fo:block font-size="{$g_strStatusSize}" font-family="{$g_strMainFont}" font-style="italic">
			<!--<xsl:if test="$g_ndsValidDate != ''">
				<xsl:text>Legislation Valid: </xsl:text>
				<xsl:value-of select="$g_ndsValidDate"/>
			</xsl:if>-->
			<xsl:text>Document Generated: </xsl:text>
			<xsl:value-of select="format-date(current-date(),'[Y]-[M,2]-[D,2]')"/>
		</fo:block>
	</xsl:template>

	<xsl:template name="statusWarningHeader">
		<xsl:param name="number-columns-spanned" select="'2'"/>
		<fo:table-row>
			<fo:table-cell number-columns-spanned="{$number-columns-spanned}" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center" text-align-last="center">
				<fo:block>
					<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>
	
	<xsl:template name="runningheaders-body">
		<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
			<fo:retrieve-marker retrieve-class-name="runninghead2"/>
		</fo:block>
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
					<fo:retrieve-marker retrieve-class-name="runningheadEU"  retrieve-position="last-starting-within-page"/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
					<fo:retrieve-marker retrieve-class-name="runningheadpart"/>
				</fo:block>
				<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
					<fo:retrieve-marker retrieve-class-name="runningheadchapter"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="runningheaders-schedule">
		<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}" font-style="italic">
			<fo:retrieve-marker retrieve-class-name="runninghead2"/>
		</fo:block>
		<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}" font-style="italic">
			<xsl:choose>
				<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
					<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" font-style="italic">
						<fo:retrieve-marker retrieve-class-name="runningheadEU" retrieve-position="last-starting-within-page"/>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:retrieve-marker retrieve-class-name="runningheadschedule"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>	
	
	<xsl:template name="columns-3">
		<fo:table-column column-width="20%"/>									
		<fo:table-column column-width="60%"/>
		<fo:table-column column-width="20%"/>
	</xsl:template>	

	<xsl:template name="columns-2-odd">
		<fo:table-column column-width="80%"/>									
		<fo:table-column column-width="20%"/>
	</xsl:template>	
	
	<xsl:template name="columns-2-even">
		<fo:table-column column-width="20%"/>
		<fo:table-column column-width="80%"/>									
	</xsl:template>		

	<xsl:template name="TSOsecondaryMainFooter">
		<fo:static-content flow-name="even-after">
			<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" id="pageFooterEven" text-align="center">
				<fo:inline>
					<fo:page-number/>
				</fo:inline>						
			</fo:block>
		</fo:static-content>
		<fo:static-content flow-name="odd-after">
			<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" id="pageFooterOdd" text-align="center">
				<fo:inline>
					<fo:page-number/>
				</fo:inline>								
			</fo:block>
		</fo:static-content>
	</xsl:template>

	
	<xsl:template name="TSOsecondaryScheduleFooter">
		<fo:static-content flow-name="even-after">
			<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" id="pageScheduleFooterEven" text-align="center">
				<fo:inline>
					<fo:page-number/>
				</fo:inline>						
			</fo:block>
		</fo:static-content>
		<fo:static-content flow-name="odd-after">
			<fo:block font-size="{$g_strFooterSize}" font-family="{$g_strMainFont}" id="pageScheduleFooterOdd" text-align="center">
				<fo:inline>
					<fo:page-number/>
				</fo:inline>								
			</fo:block>
		</fo:static-content>
	</xsl:template>	
	
	<xsl:template name="TSOgetNIheaderFooter">
		<!-- Header for even pages -->
		<fo:static-content flow-name="even-before">
			<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed"  width="{$g_PageBodyWidth}pt">
				<fo:table-column column-width="20%"/>									
				<fo:table-column column-width="60%"/>
				<fo:table-column column-width="20%"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
							<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}">
								<xsl:text>c. </xsl:text>
								<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
							<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
								<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
								<xsl:call-template name="TSOdocDateTime"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
							<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row border-bottom="solid 0.5pt black" border-top="solid 0.5pt black">
						<fo:table-cell number-columns-spanned="3" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center"  text-align-last="center">
							<fo:block>
								<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			<!--<fo:block font-size="{$g_strSmallCapsSize}" font-family="{$g_strMainFont}" margin-top="24pt" margin-left="-72pt">
				<fo:retrieve-marker retrieve-class-name="SideBar"/>
			</fo:block>-->
		</fo:static-content>					
		<fo:static-content flow-name="even-before-first">
			<fo:table  margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed"  width="{$g_PageBodyWidth}pt">
				<fo:table-column column-width="20%"/>									
				<fo:table-column column-width="60%"/>
				<fo:table-column column-width="20%"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
							<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}">
								<xsl:text>c. </xsl:text>
								<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
							<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
								<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
								<xsl:call-template name="TSOdocDateTime"/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
							<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row border-bottom="solid 0.5pt black" border-top="solid 0.5pt black">
						<fo:table-cell number-columns-spanned="3" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center"  text-align-last="center">
							<fo:block>
								<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:static-content>
		<!-- Header for odd pages -->
		<fo:static-content flow-name="odd-before">
			<fo:table  margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed"  width="{$g_PageBodyWidth}pt">
				<fo:table-column column-width="20%"/>	
				<fo:table-column column-width="60%"/>									
				<fo:table-column column-width="20%"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
							<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
						</fo:table-cell>
						<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
							<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
								<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
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
					<fo:table-row border-bottom="solid 0.5pt black" border-top="solid 0.5pt black">
						<fo:table-cell number-columns-spanned="3" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center"  text-align-last="center">
							<fo:block>
								<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			<!--<fo:block font-size="{$g_strSmallCapsSize}" font-family="{$g_strMainFont}" margin-top="24pt" margin-right="-72pt" text-align="right">
				<fo:retrieve-marker retrieve-class-name="SideBar"/>
			</fo:block>-->
		</fo:static-content>		
		<fo:static-content flow-name="odd-before-first">
			<fo:table  margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed"  width="{$g_PageBodyWidth}pt">
				<fo:table-column column-width="20%"/>	
				<fo:table-column column-width="60%"/>									
				<fo:table-column column-width="20%"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
							<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
						</fo:table-cell>
						<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
							<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-style="italic">
								<xsl:apply-templates select="$g_ndsLegPrelims/leg:Title"/>
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
					<fo:table-row border-bottom="solid 0.5pt black" border-top="solid 0.5pt black">
						<fo:table-cell number-columns-spanned="3" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center"  text-align-last="center">
							<fo:block>
								<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:static-content>
	</xsl:template>


	<xsl:include href="legislation_schema_masterpages_FO.xslt"/>

	<xsl:include href="legislation_schema_frontmatter_FO.xslt"/>

	<xsl:include href="legislation_schema_primaryprelims_FO.xslt"/>

	<xsl:include href="legislation_schema_secondaryprelims_FO.xslt"/>
	
	<xsl:include href="legislation_schema_euretainedprelims_FO.xslt"/>

	<xsl:include href="legislation_schema_contents_FO.xslt"/>


	<xsl:template match="leg:Footnotes" mode="EU-EndNotes">
		<fo:block>
			<xsl:apply-templates mode="EU-EndNotes"/>
			<xsl:apply-templates select="." mode="ProcessAnnotations" />
		</fo:block>
	</xsl:template>
	
	<xsl:template match="leg:Footnote" mode="EU-EndNotes">
		<fo:block space-before="6pt" id="{@id}">
			<xsl:variable name="strFootnoteRef" select="@id" as="xs:string"/>
		<!--<xsl:variable name="intFootnoteNumber" select="count($g_ndsFootnotes[@id = $strFootnoteRef]/preceding-sibling::*) + 1" as="xs:integer"/>-->
		<xsl:variable name="intFootnoteNumber" select="index-of($g_ndsFootnotes/@id, $strFootnoteRef)" as="xs:integer?"/>
		<xsl:variable name="booTableRef" select="ancestor::xhtml:table and $strFootnoteRef = ancestor::xhtml:table/xhtml:tfoot//leg:Footnote/@id" as="xs:boolean"/>
		
			
				<fo:list-block start-indent="0pt" provisional-label-separation="6pt" provisional-distance-between-starts="24pt">
					<fo:list-item>
						<fo:list-item-label start-indent="0pt" end-indent="label-end()">
							<fo:block font-size="{$g_endNoteSize}pt" line-height="{$g_endNoteSize}pt" text-indent="0pt" margin-left="0pt" font-weight="bold" font-style="normal">
								<fo:inline font-weight="normal"><xsl:text>(</xsl:text></fo:inline>
								<xsl:number format="1"/>
								<fo:inline font-weight="normal"><xsl:text>)</xsl:text></fo:inline>
							</fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:block font-size="{$g_endNoteSize}pt" line-height="{$g_endNoteSize}pt" text-indent="0pt" margin-left="0pt"  font-style="normal">
								<xsl:apply-templates select="."/>
							</fo:block>
						</fo:list-item-body>
					</fo:list-item>
				</fo:list-block>		
			
		</fo:block>
	</xsl:template>	
	
	<xsl:template match="leg:Body | leg:EUBody" priority="10">
		<xsl:if test="not(ancestor::leg:Attachments)">
			<fo:block id="StartOfContent"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="ancestor::leg:BlockAmendment">
				<xsl:next-match />
			</xsl:when>
			<xsl:when test="exists($nstSection[not(//leg:IncludedDocument)])">
				<xsl:call-template name="TSOOutputBreadcrumbItems"	/>
				<fo:block space-before="8pt">
					<xsl:apply-templates select="$nstSection" mode="showSectionWithAnnotation">
						<xsl:with-param name="showSection" select="$nstSection" tunnel="yes" />
						<xsl:with-param name="showRepeals" select="$showRepeals" tunnel="yes" />
					</xsl:apply-templates>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="ProcessAnnotations" />
				<xsl:next-match>
					<xsl:with-param name="showRepeals" select="$showRepeals" tunnel="yes" />
				</xsl:next-match>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	

	
	<!-- #HA057536 - MJ: output XML content within resource if file contains no main content -->
	<xsl:template match="leg:Resources[not(preceding-sibling::leg:Primary or preceding-sibling::leg:Secondary or  preceding-sibling::leg:EURetained)]">
		<fo:block id="StartOfContent"/>
		<xsl:apply-templates select="leg:Resource/leg:InternalVersion/leg:XMLcontent/node()"/>
	</xsl:template>

	<!-- Adding Annotations for parent levels if the current section is dead/repeal -->
<xsl:template match="*" mode="showSectionWithAnnotation">
	<xsl:apply-templates select="."/>
</xsl:template>

	<xsl:template name="OutputHeaderBreadscrumb">
		 <xsl:apply-templates select="./ancestor::*[self::leg:Schedule or self::leg:EUTitle or self::leg:EUPart or self::leg:EUChapter or self::leg:EUSection  or self::leg:EUSubsection  or self::leg:Division[@Type =  ('EUPart','EUTitle','EUChapter','EUSection','EUSubsection')]]" mode="OutputHeaderBreadscrumb"/>
	</xsl:template>
	
	<xsl:template match="*" mode="OutputHeaderBreadscrumb" priority="3">
		<xsl:if test="ancestor::*[self::leg:Schedule or self::leg:EUTitle or self::leg:EUPart or self::leg:EUChapter or self::leg:EUSection  or self::leg:EUSubsection  or self::leg:Division[@Type =  ('EUPart','EUTitle','EUChapter','EUSection','EUSubsection')]]">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="leg:Number != ''">
				<xsl:value-of select="leg:Number"/>
			</xsl:when>
			<xsl:when test="leg:Title != ''">
				<xsl:value-of select="leg:Title"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

<!-- ##############################################  -->
<!-- Add in titles that precede the section that has been requested  -->
	<!-- ========== Standard code for breadcrumb ========= -->
	<xsl:template name="TSOOutputBreadcrumbItems">
		 <fo:block>
			<xsl:if test="exists($nstSection)">
				<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]" mode="TSOBreadcrumbItem"/>
			</xsl:if>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="leg:Legislation" mode="TSOBreadcrumbItem" priority="20"/>
	
	<xsl:template match="leg:Body|leg:EUBody" mode="TSOBreadcrumbItem" priority="20"/>	
	
	<xsl:template match="*[@DocumentURI]" mode="TSOBreadcrumbItem" priority="10">
		<xsl:choose>
				<xsl:when test="$strCurrentURIs = @DocumentURI">
				</xsl:when>
				<xsl:otherwise>
					<fo:block>
						<xsl:next-match />
					</fo:block>
				</xsl:otherwise>
			</xsl:choose>		
	</xsl:template>
	
	<xsl:template match="leg:PrimaryPrelims | leg:SecondaryPrelims | leg:EUPrelims" mode="TSOBreadcrumbItem" priority="5"/>

	<xsl:template match="leg:SignedSection" mode="TSOBreadcrumbItem" priority="5"/>	

	<xsl:template match="leg:ExplanatoryNotes" mode="TSOBreadcrumbItem" priority="5"/>	

	<xsl:template match="leg:EarlierOrders" mode="TSOBreadcrumbItem" priority="5"/>	
	
	<xsl:template match="*[leg:Pnumber]" mode="TSOBreadcrumbItem" priority="5"/>
	
	<xsl:template match="*[leg:Number != '' ][leg:Title]" mode="TSOBreadcrumbItem" priority="4">
		<xsl:apply-templates select="leg:Number | leg:Title"/>
	</xsl:template>
	
	<xsl:template match="*[leg:Number != '' ]" mode="TSOBreadcrumbItem" priority="3">
		<xsl:apply-templates select="leg:Number"/>
	</xsl:template>
	
	<xsl:template match="*[leg:Title]" mode="TSOBreadcrumbItem" priority="2">
		<xsl:apply-templates select="leg:Title"/>
	</xsl:template>
	
	<xsl:template match="*[leg:TitleBlock]" mode="TSOBreadcrumbItem" priority="1">
		<xsl:apply-templates select="leg:TitleBlock"  />
	</xsl:template>

	<xsl:template match="leg:P1group[leg:Title = '']" mode="TSOBreadcrumbItem" priority="3"></xsl:template>





<!-- ##############################################  -->





	<xsl:template match="leg:IntroductoryText">
		<fo:block font-size="{$g_strBodySize}" space-before="24pt" text-align="justify">
			<xsl:apply-templates/>
		</fo:block>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>



	<xsl:template match="leg:EnactingText">
		<fo:block font-size="{$g_strBodySize}" text-align="justify" space-after="30pt">
			<xsl:if test="/leg:Legislation/leg:Contents">
				<xsl:attribute name="space-before">24pt</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<!-- this needs the highest priority so that the annotations get processed  -->
	<xsl:template match="leg:Schedule//leg:P1 | leg:PrimaryPrelims | leg:SecondaryPrelims | leg:EUPrelims | leg:P1group | leg:Schedule/leg:ScheduleBody/leg:Tabular | leg:P1[not(parent::leg:P1group)]" priority="400">
		<xsl:next-match>
			<xsl:with-param name="showRepeals" select="$showRepeals" tunnel="yes"/>
		</xsl:next-match>
		<!-- If there are alternate versions outputting ot annotations will happen there -->
		<xsl:if test="not(@AltVersionRefs) and not(parent::leg:BlockAmendment)">
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		</xsl:if>
	</xsl:template>

	<!-- when a section is in a dated version and has been included at a later date we will highlight this with coloured backgrounds -->
	<xsl:template match="*[(@RestrictStartDate castable as xs:date) and @Match = 'false'  and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; current-date() ))]" priority="150">
		<xsl:param name="showingValidFromDate" tunnel="yes" as="xs:date?" select="()" />
		<xsl:choose>
			<xsl:when test="empty($showingValidFromDate) or xs:date(@RestrictStartDate) != $showingValidFromDate">
				<fo:block background-color="#eff5f5" border="1pt solid #7a8093" space-before="12pt" padding-bottom="6pt" padding-top="0pt" padding-left="0pt" padding-right="0pt" margin-left="0pt">
						<xsl:if test="ancestor::*[(@RestrictStartDate castable as xs:date) and @Match = 'false'  and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; current-date() ))]">
						<xsl:attribute name="margin-left">0pt</xsl:attribute>
						<xsl:attribute name="margin-right">0pt</xsl:attribute>
						</xsl:if>
					<fo:block background-color="#7a8093" text-align="right" padding="6pt" keep-with-next="always" margin="0pt">
						<!--<xsl:if test="ancestor::*[(@RestrictStartDate castable as xs:date) and @Match = 'false'  and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; current-date() ))]">
							<xsl:attribute name="margin-right">0pt</xsl:attribute>
						</xsl:if>-->
						<fo:inline color="#ffffff" text-transform="uppercase" font-size="10pt">Valid from <xsl:value-of select="format-date(xs:date(@RestrictStartDate), '[D01]/[M01]/[Y0001]')"/></fo:inline>
					</fo:block>
					<fo:block  margin-left="6pt" margin-right="6pt" >
					<xsl:next-match>
						<xsl:with-param name="showingValidFromDate" tunnel="yes" select="xs:date(@RestrictStartDate)" />
					</xsl:next-match>
				</fo:block>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- when a section is in a prospective version and has been included at an earlier date we will highlight this with coloured backgrounds -->
	<xsl:template match="*[@Match = 'false' and not(ancestor::leg:Contents) and @Status = 'Prospective']" priority="150">
		<xsl:param name="showingProspective" tunnel="yes" as="xs:boolean" select="false()" />
		<xsl:choose>
			<xsl:when test="not($showingProspective)">
				<fo:block background-color="#eff5f5" space-before="12pt" padding-bottom="6pt" padding-top="0pt" padding-left="6pt" padding-right="6pt" margin-left="0pt">
					<fo:block background-color="#7a8093" text-align="right" padding="6pt" keep-with-next="always">
						<xsl:if test="ancestor::*[(@RestrictStartDate castable as xs:date) and @Match = 'false'  and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; current-date() ))]">
							<xsl:attribute name="margin-right">3pt</xsl:attribute>
						</xsl:if>
						<fo:inline color="#ffffff" text-transform="uppercase" font-size="10pt">Prospective</fo:inline>
					</fo:block>
					<xsl:next-match>
						<xsl:with-param name="showingProspective" tunnel="yes" select="true()" />
					</xsl:next-match>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- displaying P1group/title as dotted line if the section is repealed.  -->
	<xsl:template match="leg:P1group[not(ancestor::leg:BlockAmendment) and @Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))]/leg:Title" priority="60">
		<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
	</xsl:template>
	<!-- display Part, ScheduleBody/Tabular as dotted line if the section is repealed.  -->
	<xsl:template match="leg:ScheduleBody/leg:Tabular[exists(ancestor::*[@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective')])]" priority="60">
		<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
	</xsl:template>
	<xsl:template match="leg:ScheduleBody/leg:Part[exists(ancestor::*[@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective')])]" priority="60">
		<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
	</xsl:template>

	<!-- hiding P1, P if any of the ancestors are repealed -->
<xsl:template match="leg:P[exists(ancestor::*[@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))])]" priority="60"/>
<xsl:template match="leg:P1[parent::leg:P1group and exists(ancestor::*[@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))])]" priority="50"/>

<!-- process only the first descendant line of elements from P1s that are repealed -->
<xsl:template match="leg:P1[not(ancestor::leg:BlockAmendment) and @Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))]//*" priority="70">
	<xsl:if test="not(preceding-sibling::leg:*) or preceding-sibling::*[1][self::leg:Pnumber]">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<!-- process text within P1s that are repealed -->
<xsl:template match="leg:P1[not(ancestor::leg:BlockAmendment) and @Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))]//text()" priority="70">
	<xsl:choose>
		<xsl:when test="ancestor::leg:Pnumber/parent::leg:P1[not(ancestor::leg:BlockAmendment)]">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="provision" as="element(leg:P1)" select="ancestor::leg:P1[not(ancestor::leg:BlockAmendment)][1]" />
			<xsl:variable name="firstText" as="text()?" select="(($provision//leg:Text)[1]//text())[1]" />
			<xsl:if test=". is $firstText">
				<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	
	<xsl:template match="leg:Division | leg:Part | leg:Body | leg:EUBody | leg:Schedules | leg:Pblock | leg:PsubBlock | leg:ExplanatoryNotes | leg:SignedSection | leg:EUChapter | leg:EUPart | leg:EUTitle | leg:EUSection | leg:EUSubsection" priority="61">
		<xsl:variable name="isWholeActView" select="./root()/leg:Legislation/@DocumentURI = $dcIdentifier"/>
		<xsl:variable name="isBodyView" select="matches($dcIdentifier, '/body')"/>
		<xsl:variable name="isSchedulesView" select="matches($dcIdentifier, '/schedules|/annexes')"/>
		<xsl:variable name="isSignatureView" select="matches($dcIdentifier, '/signature')"/>
		<xsl:variable name="documentURI" select="@DocumentURI"/>
		<xsl:variable name="repealedText" select="if ($isWholeActView) then 'act\s+(repeal|revoked|omitted)' else 'repeal'"/>
		<!--<xsl:variable name="isRepealedAct" select="matches((ancestor::leg:Legislation/ukm:Metadata/dc:title)[1], '\(repealed\)\s*$')"/>-->
		<xsl:variable name="commentary" as="xs:string*" 
				select="$g_wholeActCommentaries/@id"/>				
		<xsl:variable name="isRepealedStatus" select="@Status = 'Repealed'"/>
		<xsl:variable name="isRepealed" select="(every $child in (leg:* except (leg:Number, leg:Title)) satisfies 
						(
							(
								($child/@Match = 'false' and $child/@RestrictEndDate) and 
								not($child/@Status = 'Prospective') and
								(
									(
										($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= xs:date($version) 
									) or (not($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= current-date() )
								)
							) 
						 or ($child/@Match = 'false' and $child/@Status = 'Repealed')
						 or (self::leg:Division and (($child/self::leg:P[not(@id)] and $isRepealedStatus) or ($child/@Match = 'false' and $child/@Status = 'Repealed')))
					   or (
					  (:  allowance for prosp repeals made by EPP  :)
							$child/@Match = 'false' and matches($child/@Status, 'prospective|repealed', 'i') and 
							(some $text in $commentary satisfies matches(string(/leg:Legislation/leg:Commentaries/leg:Commentary[@id = $text][1]), $repealedText, 'i')
							)  and 
							(exists($child//leg:Text) or exists($child//xhtml:td)) and 
							(every $text in ($child//leg:Text | $child//xhtml:td) satisfies normalize-space(replace($text, '[\.\s]' , '')) = '')
							)
						)
					) or 
					(	(:  the explanatory notes do not appear to always have an enddate or status attribute so we must infer the repeal  :)
						self::leg:ExplanatoryNotes and (
						every $child in (leg:* except (leg:Number, leg:Title)) satisfies
						(exists($child//leg:Text) or exists($child//xhtml:td)) and 
						(every $text in ($child//leg:Text | $child//xhtml:td) satisfies normalize-space(replace($text, '[\.\s]' , '')) = ''))
					) or
					(
							(
								(@Match = 'false' and @RestrictEndDate) and 
								not(@Status = 'Prospective') and
								(
								(
								($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) 
								) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() )
								)
							)
							and
							(				
								leg:Title[.=''][not(preceding-sibling::element())]/following-sibling::element()[1]
																			[self::leg:P][normalize-space(.) != '']
																			[not(following-sibling::element())]
							)
					
					)
					
					"/>
		
						
		<xsl:choose>
			<xsl:when test="$isWholeActView and $isRepealedAct and $isRepealed">
				<fo:block>	</fo:block>
			</xsl:when>
			<xsl:when test="$isSignatureView and (self::leg:Body or self::leg:EUBody)">
				<fo:block><xsl:apply-templates/></fo:block>
			</xsl:when>
			<xsl:when test="($documentURI = ($dcIdentifier) or $isSchedulesView or $isBodyView) and $isRepealed">
				<xsl:apply-templates select="leg:Number | leg:Title" />
				<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
				<xsl:apply-templates select="." mode="ProcessAnnotations"/>
			</xsl:when>
			
			<xsl:otherwise>
				<fo:block><xsl:next-match /></fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:ScheduleBody" priority="60">
		<xsl:choose>
			<xsl:when test="parent::*/@Match = 'false' and parent::*/@RestrictEndDate and not(parent::*/@Status = 'Prospective')">
				<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
				<xsl:apply-templates select="." mode="ProcessAnnotations"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- annotations are processed by a higher priority template which will run them when there are no alt versions  -->
	<xsl:template match="leg:P1group" priority="99">
		<xsl:choose>
			<!--<xsl:when test="not(ancestor::leg:BlockAmendment) and @Match = 'false' and not(@Status = 'Prospective') and not(ancestor::leg:Contents) and leg:Title">
				<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
			</xsl:when>-->
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:apply-templates select="leg:Title"/>
				<xsl:if test="child::*[2][self::leg:P1]/child::*[2][self::leg:P1para]/child::*[1][self::leg:P2group]">
					<fo:block font-style="italic" space-before="12pt">
						<xsl:apply-templates select="child::*[2][self::leg:P1]/child::*[2][self::leg:P1para]/child::*[1]/leg:Title"/>
					</fo:block>
				</xsl:if>
				<xsl:apply-templates select="leg:P1 | leg:P"/>
			</xsl:when>
			<xsl:when test="not(leg:P1)">
				<xsl:apply-templates select="leg:Title"/>
				<xsl:apply-templates select="leg:P"/>
			</xsl:when>
			<!--<xsl:when test="child::*[2][self::leg:P1]/child::*[2][self::leg:P1para]/child::*[1][self::leg:Text]">
				<fo:block space-before="18pt">
					<xsl:apply-templates select="leg:Title"/>
				</fo:block>
				<fo:block space-before="3pt">
					<xsl:apply-templates select="*[not(self::leg:Title)]"/>
				</fo:block>
			</xsl:when>-->
			<xsl:when test="not($g_strDocClass = $g_strConstantEuretained) and (parent::leg:BlockAmendment[@TargetClass = 'primary' and @Context = 'schedule'] or  ancestor::leg:ScheduleBody)">
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
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P1group/leg:Title" priority="1">
		<fo:block font-size="{$g_strBodySize}" font-weight="bold" 
				text-align="{if ($g_strDocClass = $g_strConstantEuretained) then 'center' else 'left'}" keep-with-next="always">
			<xsl:if test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:attribute name="space-before">16pt</xsl:attribute>
				<xsl:attribute name="space-after">6pt</xsl:attribute>
				<xsl:if test="ancestor::leg:BlockAmendment">
					<xsl:attribute name="margin-left">24pt</xsl:attribute>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$g_strDocClass = $g_strConstantEuretained">
				<xsl:attribute name="space-before">8pt</xsl:attribute>
				<xsl:attribute name="space-after">16pt</xsl:attribute>
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
			<xsl:if test="not($g_strDocClass = $g_strConstantEuretained) and ancestor-or-self::*/@RestrictExtent and  ($g_matchExtent = 'true' or parent::*/@Concurrent = 'true' or ancestor-or-self::*/@VersionReplacement) and not(ancestor::leg:BlockAmendment)">
				<xsl:copy-of select="tso:generateExtentInfo(.)"/>
			</xsl:if>
		</fo:block>
					<xsl:apply-templates select="." mode="ProcessAnnotations"/>

	</xsl:template>
		

	<xsl:template match="leg:Schedule[not($g_strDocClass = ($g_strConstantSecondary, $g_strConstantEuretained))]//leg:P1group[not(ancestor::leg:BlockAmendment)]/leg:Title | leg:P1group[parent::leg:BlockAmendment[@TargetClass = 'primary' and @Context = 'schedule']]/leg:Title" priority="2">
		<fo:block font-size="{$g_strBodySize}" font-style="italic" text-align="left" keep-with-next="always">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>



	<xsl:template match="leg:P1[not(ancestor::leg:BlockAmendment)]" priority="3">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:when>
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<fo:block>
					<fo:block font-size="{$g_strBodySize}" text-align="center" font-weight="normal" font-style="italic" keep-with-next="always">
						<xsl:apply-templates select="leg:Pnumber"/>
						<xsl:if test="ancestor-or-self::*/@RestrictExtent and  ($g_matchExtent = 'true' or parent::*/@Concurrent = 'true' or ancestor-or-self::*/@VersionReplacement) and not(ancestor::leg:BlockAmendment)">
							<xsl:copy-of select="tso:generateExtentInfo(.)"/>
						</xsl:if>
					</fo:block>
					<xsl:if test="parent::leg:P1group and not(preceding-sibling::leg:P1)">
						<fo:block font-size="{$g_strBodySize}" text-align="center" font-weight="bold">
							<xsl:apply-templates select="parent::*/leg:Title"/>
						</fo:block>
					</xsl:if>
					<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block provisional-label-separation="3pt" provisional-distance-between-starts="36pt" space-before="6pt">		
					<xsl:call-template name="TSOgetID"/>
					<xsl:choose>
						<xsl:when test="$g_strDocClass = $g_strConstantPrimary"/>
						<xsl:otherwise>
							<xsl:attribute name="space-before">8pt</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>				
					<fo:list-item>
						<fo:list-item-label end-indent="label-end()">
							<fo:block font-size="{$g_strBodySize}" font-weight="bold">
								<!--<xsl:attribute name="text-align">
									<xsl:choose>
										<xsl:when test="leg:Pnumber/leg:Addition or leg:Pnumber/leg:Substitution">left</xsl:when>
										<xsl:when test="leg:Pnumber/leg:Addition or leg:Pnumber/leg:Substitution or leg:Pnumber/leg:CommentaryRef">
											<xsl:variable name="commentaryItem" select="key('commentary', leg:Pnumber/leg:CommentaryRef/@Ref)[1]" as="element(leg:Commentary)?"/>
											<xsl:value-of select="if ($commentaryItem/@Type = ('F', 'M', 'X')) then 'left' else 'left'"/>
										</xsl:when>
										<xsl:otherwise>left</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>-->
								<xsl:attribute name="text-align">left</xsl:attribute>
								<xsl:attribute name="margin-left">
									<xsl:choose>
										<xsl:when test="leg:Pnumber/leg:Addition">-3pt</xsl:when>
										<xsl:otherwise>0pt</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:if test="leg:Pnumber/@PuncBefore!= ''">
									<xsl:value-of select="leg:Pnumber/@PuncBefore"/>
								</xsl:if>
								<xsl:apply-templates select="leg:Pnumber/node() | processing-instruction()"/>
								<xsl:if test="leg:Pnumber/@PuncAfter != ''">
									<xsl:value-of select="leg:Pnumber/@PuncAfter"/>
								</xsl:if>
							</fo:block>						
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<xsl:if test="parent::leg:P1group and not(preceding-sibling::leg:P1)">
								<xsl:apply-templates select="parent::*/leg:Title"/>
							</xsl:if>
							<!-- HA050986  -->
							<xsl:if test="not(parent::leg:P1group/@Match = 'false' and parent::leg:P1group/@RestrictEndDate and not(parent::leg:P1group/@Status = 'Prospective') and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(parent::leg:P1group/@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(parent::leg:P1group/@RestrictEndDate) &lt;= current-date() )))">
								<fo:block font-size="{$g_strBodySize}" text-align="justify">
									<xsl:apply-templates select="*[not(self::leg:Pnumber)] | processing-instruction()"/>
								</fo:block>
							</xsl:if>						
						</fo:list-item-body>
					</fo:list-item>						
				</fo:list-block>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>


	<!-- change conflicting priority as other templates are using a priority of 100  -->
	<xsl:template match="leg:Schedule//leg:P1[not(ancestor::leg:BlockAmendment[1][@Context = 'main' or @Context='unknown' or @Context = 'schedule'])][not($g_strDocClass = $g_strConstantEuretained)]" priority="110">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block provisional-label-separation="3pt" provisional-distance-between-starts="48pt" space-before="6pt">		
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
								<xsl:if test="leg:Pnumber/@PuncBefore!= ''">
									<xsl:value-of select="leg:Pnumber/@PuncBefore"/>
								</xsl:if>
								<xsl:apply-templates select="leg:Pnumber"/>
								<xsl:if test="leg:Pnumber/@PuncAfter != ''">
									<xsl:value-of select="leg:Pnumber/@PuncAfter"/>
								</xsl:if>
							</fo:block>						
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:block font-size="{$g_strBodySize}" text-align="justify">
								<xsl:apply-templates select="leg:P1para"/>
								<!-- HA056627 JDC - next line required for revised PDFs, e.g. http://www.legislation.gov.uk/ukpga/2013/22/schedule/24/paragraph/9/data.pdf, which can have the Tabular element at the same level as the P1Para. --> 
								<xsl:apply-templates select="leg:Tabular"/>
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
				<fo:list-block provisional-label-separation="3pt" provisional-distance-between-starts="48pt" space-before="6pt">		
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
								<xsl:if test="leg:Pnumber/@PuncBefore!= ''">
									<xsl:value-of select="leg:Pnumber/@PuncBefore"/>
								</xsl:if>
								<xsl:apply-templates select="leg:Pnumber"/>
								<xsl:if test="leg:Pnumber/@PuncAfter != ''">
									<xsl:value-of select="leg:Pnumber/@PuncAfter"/>
								</xsl:if>							
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
	<xsl:template match="leg:P1[ancestor::leg:BlockAmendment[1][@Context = 'main' or @Context='unknown']]" priority="110">
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
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<fo:block>
					<fo:block font-size="{$g_strBodySize}" text-align="center" font-weight="normal" font-style="italic" keep-with-next="always">
						<xsl:apply-templates select="leg:Pnumber"/>
					</fo:block>
					<xsl:if test="parent::leg:P1group and not(preceding-sibling::leg:P1)">
						<fo:block  font-size="{$g_strBodySize}" text-align="center" font-weight="bold">
							<xsl:apply-templates select="parent::*/leg:Title"/>
						</fo:block>
					</xsl:if>
					<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block provisional-label-separation="3pt" provisional-distance-between-starts="30pt" space-before="6pt">		
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
								<xsl:if test="ancestor::leg:BlockAmendment[1][@TargetClass = 'primary']">
									<xsl:attribute name="font-weight">bold</xsl:attribute>
								</xsl:if>
								<xsl:if test="leg:Pnumber/@PuncBefore!= ''">
									<xsl:value-of select="leg:Pnumber/@PuncBefore"/>
								</xsl:if>
								<xsl:apply-templates select="leg:Pnumber"/>
								<xsl:if test="leg:Pnumber/@PuncAfter != ''">
									<xsl:value-of select="leg:Pnumber/@PuncAfter"/>
								</xsl:if>							
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
				<!-- not needed for FOP 1.0 -->
				<xsl:if test="g_FOprocessor = 'FOP0.95'">
					<xsl:call-template name="FOPfootnoteHack"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:P2">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:when>
			<!--
				THE EU has a hanging indent at this level which screws up lower level lists so we will only use the first node after the number
				This is a hack to get around the lack of float support on FOP
			-->
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="42pt" text-indent="0pt">	
					<xsl:call-template name="TSO_EU_p2"/>
				</fo:list-block>
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="42pt" start-indent="0pt">	
					<xsl:call-template name="TSO_p2"/>
				</fo:list-block>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P2para/leg:Text[1]" mode="EUprocessing">
		<fo:block space-before="8pt" text-align="justify">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!--<xsl:template match="leg:P2para[preceding-sibling::*[1][self::leg:Pnumber]]/leg:Text[1][$g_strDocClass = $g_strConstantEuretained]" priority="100">
	</xsl:template>-->
	
	<xsl:template match="leg:Schedule//leg:P2">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:when>
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<!--<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" text-indent="12pt">-->	
				<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="42pt" text-indent="0pt">	
					<xsl:call-template name="TSO_EU_p2"/>
				</fo:list-block>
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" start-indent="12pt">	
					<xsl:call-template name="TSO_p2"/>
				</fo:list-block>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="FuncApplyVersions"/>
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
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<fo:list-block margin-left="0pt" provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="42pt" text-indent="0pt">	
					<xsl:call-template name="TSO_EU_p2_amend"/>
				</fo:list-block>
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt">
					<xsl:if test="parent::leg:BlockAmendment[@Context = 'schedule']">
						<xsl:attribute name="margin-left">24pt</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="TSO_p2"/>
				</fo:list-block>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:BlockAmendment[@Context = 'schedule']//leg:P2" priority="2">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="12pt">
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
				<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="-30pt">
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
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<fo:list-block margin-left="0pt" provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="42pt" text-indent="0pt">	
					<xsl:call-template name="TSO_EU_p2_amend"/>
				</fo:list-block>
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="parent::leg:P2group and not(preceding-sibling::leg:P2)">
					<fo:block font-style="italic" space-before="12pt">
						<xsl:apply-templates select="parent::*/leg:Title"/>
					</fo:block>
				</xsl:if>
				<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="-30pt">
					<xsl:call-template name="TSO_p2"/>
				</fo:list-block>
				<!-- not needed for FOP 1.0 -->
				<xsl:if test="g_FOprocessor = 'FOP0.95'">
					<xsl:call-template name="FOPfootnoteHack"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:P2group">
		<xsl:if test="preceding-sibling::* or not(parent::leg:P1para)">
			<fo:block font-style="italic" space-before="12pt">
				<xsl:apply-templates select="leg:Title"/>
			</fo:block>
		</xsl:if>
		<!-- HA048775 nisi1991/2628 failing to generate because no block element around P2para  -->
		<fo:block><xsl:apply-templates select="*[not(self::leg:Title)]"/></fo:block>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template name="TSO_EU_p2">
		<fo:list-item text-indent="0pt">
			<xsl:call-template name="TSOgetID"/>
			<fo:list-item-label start-indent="0pt">
				<fo:block font-size="{$g_strBodySize}" text-align="left" margin-left="0pt">
					<xsl:apply-templates select="leg:Pnumber"/>
				</fo:block>						
			</fo:list-item-label>
			<fo:list-item-body text-indent="42pt" end-indent="0pt">
				<fo:block font-size="{$g_strBodySize}" text-align="justify">
					<!--<xsl:apply-templates select="leg:P2para"/>-->
					<xsl:apply-templates select="leg:P2para[1]/leg:Text[1]" mode="EUprocessing"/>
				</fo:block>	
			</fo:list-item-body>
		</fo:list-item>						
	</xsl:template>	
	
	<xsl:template name="TSO_EU_p2_amend">
		<fo:list-item text-indent="0pt">
			<xsl:call-template name="TSOgetID"/>
			<fo:list-item-label start-indent="0pt">
			<xsl:if test="ancestor::leg:ListItem/ancestor::leg:ListItem">
				<xsl:attribute name="start-indent">
					<xsl:value-of select="'84pt'"/>
				</xsl:attribute>
			</xsl:if>
				<fo:block font-size="{$g_strBodySize}" text-align="left">
					<xsl:apply-templates select="leg:Pnumber"/>
				</fo:block>						
			</fo:list-item-label>
			<fo:list-item-body text-indent="42pt" end-indent="0pt">
				<fo:block font-size="{$g_strBodySize}" text-align="justify">
					<!--<xsl:apply-templates select="leg:P2para"/>-->
					<xsl:apply-templates select="leg:P2para[1]/leg:Text[1]" mode="EUprocessing"/>
				</fo:block>	
			</fo:list-item-body>
		</fo:list-item>						
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
					<!--<xsl:apply-templates select="leg:P2para"/>-->
					<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>

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
		<xsl:call-template name="FuncApplyVersions"/>
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
		<xsl:call-template name="FuncApplyVersions"/>
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
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>
	
	<!--HA055410: added to capture N1-N2-N3 paragraphs ie. P3 is the first thing in a P2para block-->
	<xsl:template match="leg:P3[parent::leg:P2para and not(preceding-sibling::*)]">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:block>
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="FuncApplyVersions"/>
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
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P3group">
		<fo:block font-style="italic" space-before="12pt" start-indent="24pt">
			<xsl:apply-templates select="leg:Title"/>
		</fo:block>
		<xsl:apply-templates select="*[not(self::leg:Title)]"/>
		<xsl:call-template name="FuncApplyVersions"/>
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
						<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
					</fo:block>						
				</fo:list-item-body>
			</fo:list-item>						
		</fo:list-block>
	
		<!-- not needed for FOP 1.0 -->
		<xsl:if test="g_FOprocessor = 'FOP0.95'">
			<xsl:call-template name="FOPfootnoteHack"/>
		</xsl:if>
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
		<xsl:call-template name="FuncApplyVersions"/>
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
		<xsl:call-template name="FuncApplyVersions"/>
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
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template name="TSO_p4">
		<xsl:param name="margin_left">0pt</xsl:param>
		<fo:list-block provisional-label-separation="3pt" space-before="{$g_strStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="{$margin_left}" text-indent="0pt">	
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
		<!-- not needed for FOP 1.0 -->
		<xsl:if test="g_FOprocessor = 'FOP0.95'">
			<xsl:call-template name="FOPfootnoteHack"/>
		</xsl:if>			
	</xsl:template>

	<xsl:template match="leg:P5" priority="1">
		<xsl:call-template name="TSO_p5"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>



	<xsl:template match="leg:BlockAmendment/leg:P5" priority="2">
		<xsl:call-template name="TSO_p5">
			<xsl:with-param name="margin_left" select="'72pt'"/>
		</xsl:call-template>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template name="TSO_p5">
		<xsl:param name="margin_left">0pt</xsl:param>
		<fo:list-block provisional-label-separation="3pt" space-before="{$g_strStandardParaGap}" provisional-distance-between-starts="36pt" margin-left="{$margin_left}" text-indent="0pt">	
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
		<!-- not needed for FOP 1.0 -->
		<xsl:if test="g_FOprocessor = 'FOP0.95'">
			<xsl:call-template name="FOPfootnoteHack"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:Schedules">
		<fo:block text-align="justify" font-size="{$g_strBodySize}">
			<xsl:apply-templates select="leg:Title"/>
			<xsl:apply-templates select="leg:Schedule"/>
			<xsl:apply-templates select="leg:SignedSection"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:Schedules/leg:Title">	
		<fo:block font-size="14pt" margin-top="36pt" text-align="center" keep-with-next="always" letter-spacing="3pt" space-after="12pt">
			<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:attribute name="text-transform">uppercase</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	

	
	<xsl:template match="leg:Schedule" priority="100">
		<fo:block text-align="justify" font-size="{$g_strBodySize}">
			<xsl:call-template name="TSOgetID"/>	
			<fo:marker marker-class-name="runningheadschedule">
				<xsl:value-of select="leg:Number"/>
				<xsl:if test="leg:TitleBlock/leg:Title and not($g_strDocClass = $g_strConstantEuretained)">
					<xsl:text> – </xsl:text>
					<xsl:value-of select="leg:TitleBlock/leg:Title"/>
				</xsl:if>
			</fo:marker>
			<xsl:if test="not(leg:ScheduleBody/leg:Part)">
				<fo:marker marker-class-name="runningheadpart">&#8203;</fo:marker>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$g_strDocType = 'ScottishAct'">
					<fo:block font-size="{$g_strBodySize}" space-before="36pt">
						<xsl:apply-templates select="leg:Number"/>
						<xsl:apply-templates select="leg:Reference"/>					
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:table font-size="{$g_strBodySize}" space-after="12pt" table-layout="fixed" width="100%">
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
			<!-- this should make the dots appear as per the html pages -->
			<xsl:choose>
				<xsl:when test="(@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and
						   ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))) or (exists(leg:ScheduleBody/*) and (every $child in (leg:ScheduleBody/*)
				  satisfies (($child/@Match = 'false' and $child/@RestrictEndDate and not($child/@Status = 'Prospective')) and
						   ((($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= current-date() )))  or ($child/@Match = 'false' and $child/@Status = 'Repealed')))">
							  
					<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
					<xsl:apply-templates select="." mode="ProcessAnnotations"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="leg:TitleBlock"/>	
					<xsl:apply-templates select="." mode="ProcessAnnotations"/>
					<xsl:apply-templates select="leg:Contents"/>
					<xsl:apply-templates select="leg:ScheduleBody"/>
					<!-- CRM Appendix not being output in schedules -->
					<xsl:apply-templates select="leg:Appendix"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
		<!--<xsl:call-template name="FuncApplyVersions"/>-->
	</xsl:template>

	<xsl:template match="leg:Schedule/leg:Number">
		<fo:block font-size="{$g_strBodySize}" space-before="24pt" text-align="center" keep-with-next="always">
			<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
				<xsl:attribute name="text-transform">uppercase</xsl:attribute>
			</xsl:if>	
			<fo:marker marker-class-name="runningheadschedule">
				<xsl:value-of select="."/>
				<xsl:if test="following-sibling::leg:TitleBlock/leg:Title">
					<xsl:text> – </xsl:text>
					<xsl:value-of select="following-sibling::leg:TitleBlock/leg:Title"/>
				</xsl:if>
			</fo:marker>
			<xsl:apply-templates/>
			<xsl:call-template name="FuncGenerateMajorHeadingNumber">
				<xsl:with-param name="strHeading" select="name(parent::*)"/>
			</xsl:call-template>
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

	<xsl:template match="leg:Appendix/leg:Number">
		<fo:block font-size="{$g_strBodySize}" space-before="24pt" text-align="center" keep-with-next="always" page-break-before="always">
			<fo:marker marker-class-name="runningheadschedule">
				<xsl:value-of select="."/>
				<xsl:if test="following-sibling::leg:TitleBlock/leg:Title">
					<xsl:text> – </xsl:text>
					<xsl:value-of select="following-sibling::leg:TitleBlock/leg:Title"/>
				</xsl:if>
			</fo:marker>
			<xsl:apply-templates/>
			<xsl:call-template name="FuncGenerateMajorHeadingNumber">
				<xsl:with-param name="strHeading" select="name(parent::*)"/>
			</xsl:call-template>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:Appendix/leg:TitleBlock/leg:Title">	
		<fo:block font-size="{$g_strBodySize}" margin-top="18pt" text-align="center" keep-with-next="always" space-after="12pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:BlockAmendment/leg:Text">
		<!-- Check if preceding text node should run on to this one - happens where an amendment starts with some text - but not if previous line ends in mdash (happens in asp/2001/3/section/22)-->
		<xsl:if test="preceding-sibling::* or not(parent::*/preceding-sibling::*[1][self::leg:Text][substring(., string-length(.)) != '&#8212;'])">
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
					<!-- HA055410: Amended to also pick out rare N1-N2-N3 paragraphs-->
					<xsl:when test="not(preceding-sibling::*) and 
						(
							(parent::leg:P2para[preceding-sibling::*[1][self::leg:Pnumber] or 
								(not(parent::*/preceding-sibling::*) and 
							parent::leg:BlockAmendment)])
							 or 
							 (parent::leg:P3para[preceding-sibling::*[1][self::leg:Pnumber]] and not(parent::leg:P3para/parent::leg:P3/preceding-sibling::*)))">	

						<fo:block text-align="justify" text-indent="12pt" space-before="{$g_strLargeStandardParaGap}">
							<xsl:for-each select="parent::leg:P2para/parent::leg:P2">
								<xsl:if test="(not(preceding-sibling::*) and parent::leg:P1para[not(parent::leg:BlockAmendment)]) or (preceding-sibling::*[1][self::leg:Title] and parent::leg:P2group[not(preceding-sibling::*)] and parent::leg:P2group[not(parent::leg:BlockAmendment)])">
									<xsl:if test="parent::*/parent::leg:P1[not(parent::leg:P1group) or preceding-sibling::leg:P1]">
										<xsl:attribute name="space-before">12pt</xsl:attribute>
									</xsl:if>
							  		<!-- HA098003- only if Title is a child of BlockAmendment and not inside Schedule-->
							  		<xsl:if test="not(ancestor::*[self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])">	
								  		<fo:inline>
											<xsl:if test="not(ancestor::leg:Schedule and $g_strDocType = 'NorthernIrelandStatutoryRule')">
												<xsl:attribute name="font-weight">bold</xsl:attribute>
											</xsl:if>
											<xsl:apply-templates select="ancestor::leg:P1[1]/leg:Pnumber"/>
										 	<xsl:text>.</xsl:text>
										</fo:inline>
										<xsl:text>&#8212;</xsl:text>
							  		</xsl:if>
								</xsl:if>
								<xsl:apply-templates select="leg:Pnumber"/>
								<!-- FOP doesn't handle 2003 well - look for alternative -->
								<xsl:text>&#160;&#160;</xsl:text>
								<!--<xsl:text>&#2003;</xsl:text>-->						
							</xsl:for-each>
							<!--HA055410: added for N1-N2-N3 paragraphs-->
							<xsl:if test="parent::leg:P3para and not(parent::leg:P3para/parent::leg:P3/preceding-sibling::leg:P3)">
							<xsl:for-each select="parent::leg:P3para/parent::leg:P3/parent::leg:P2para/parent::leg:P2">
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
									<!-- Call No: HA051095 -->
									<!--<xsl:text>&#8212;</xsl:text>-->
									<xsl:text>&#160;&#160;</xsl:text>
								</xsl:if>
								<xsl:apply-templates select="leg:Pnumber"/>
								<!-- FOP doesn't handle 2003 well - look for alternative -->
								<xsl:text>&#160;&#160;</xsl:text>
								<!--<xsl:text>&#2003;</xsl:text>-->						
							</xsl:for-each>
								<!-- HA064898 - don't include para number if within a BlockAmendment, as it will have already been output from "leg:BlockAmendment/leg:P3" template match -->
								<xsl:apply-templates select="parent::leg:P3para[not(ancestor::leg:BlockAmendment)]/preceding-sibling::leg:Pnumber"/>
								<!-- FOP doesn't handle 2003 well - look for alternative -->
								<xsl:text>&#160;&#160;</xsl:text>
							</xsl:if>
							<xsl:apply-templates/>
						</fo:block>
					</xsl:when>
					<xsl:when test="preceding-sibling::*[1][self::leg:BlockAmendment] and not(following-sibling::*[1][self::leg:BlockAmendment])"/>
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
								<!--2013-04-30 Update to HA051074 GC -->
								<!--This fix needs to be a very specific otherwise it has knock on effects to other legislation -->
								<!--Only apply to ENs in ukci's where there is either an Emphasis or Strong element and no textual content-->
								<xsl:when test="$g_strDocType = 'UnitedKingdomChurchInstrument' and 
												parent::leg:P and 
												ancestor::leg:ExplanatoryNotes and
												(leg:Emphasis or leg:Strong) and
												(every $node in node() satisfies ($node instance of element(leg:Emphasis) or $node instance of element(leg:Strong) or ($node instance of text() and normalize-space($node) = '')))  ">center</xsl:when>
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
				<xsl:choose>
				<xsl:when test=" parent::leg:P2para[preceding-sibling::*[1][self::leg:Pnumber]] and not(preceding-sibling::leg:Text) and $g_strDocClass = $g_strConstantEuretained "/>
				<xsl:when test="not(preceding-sibling::*[1][self::leg:BlockAmendment])">
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
							<xsl:when test="ancestor::leg:P3 and ancestor::leg:UnorderedList[@Decoration='none']">
								<xsl:attribute name="start-indent">0pt</xsl:attribute>
								<xsl:attribute name="margin-left">0pt</xsl:attribute>
								<xsl:attribute name="space-after">2pt</xsl:attribute>
							</xsl:when>
							<xsl:when test="not(preceding-sibling::*) and parent::*/parent::*/parent::leg:UnorderedList[@Class = 'Definition'] and not($g_strDocType = 'ScottishAct')">
								<xsl:attribute name="text-indent">12pt</xsl:attribute>
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
						<!-- fix for FOP issue where it ignores listitems where an empty text element is encountered - therefore use a zero width space to force the empty tag to have a clsoe tag-->
						<xsl:if test="not(node())">
							<xsl:text>&#8203;</xsl:text>
						</xsl:if>
						<xsl:apply-templates/>
					</fo:block>
				</xsl:when>		
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:P1para/leg:Text" name="leg:P1para-legText">
		<xsl:param name="context" as="element(leg:Tabular)?"/>
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
								<xsl:if test="not($context/self::leg:Tabular)">
									<xsl:apply-templates/>
								</xsl:if>
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
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
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
								<xsl:attribute name="margin-left">0pt</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates/>
					</fo:block>
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

	<xsl:template match="leg:BlockAmendment | leg:BlockExtract">
		<xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
		<xsl:variable name="strTextNode" as="xs:string" select="generate-id(descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()])"/>
		<fo:block text-align="justify" font-size="{$g_strBodySize}">
			<xsl:choose>
				<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
					<xsl:choose>
						<xsl:when test="count(*)=1 and leg:Form">
							<xsl:attribute name="margin-left">-12pt</xsl:attribute>
						</xsl:when>
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
		<xsl:apply-templates select="*" mode="ProcessAnnotations"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>


	
	
	<xsl:template match="leg:AppendText"/>

	<xsl:include href="legislation_schema_lists_FO.xslt"/>

	<xsl:template match="leg:GroupItem[not(preceding-sibling::GroupItem)]">
		<fo:block border-right="solid 0.5pt black" padding-right="6pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:Character">
		<xsl:choose>
			<!-- this is a work around for when we do not have a font with the full utf-8 character compliment available as happens on leg.gov -->
			<!-- NOTE FOP does not support the font-selection-strategy property  -->
			<xsl:when test="$fullUTF8CSavailable = 'false' and @Name=('ThinSpace','EmSpace','EnSpace')">
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'ThinSpace'">
				<xsl:text>&#x202f;</xsl:text>
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
			<xsl:when test="@Name = 'NonBreakingSpace'">
				<xsl:text>&#x00a0;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'LinePadding'">
				<xsl:text>&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;&#x00a0;</xsl:text>			
			</xsl:when>
			<xsl:when test="@Name = 'DotPadding'">
				<xsl:text/>
				<fo:leader leader-alignment="reference-area" leader-pattern="use-content" leader-length.maximum="100%">     ...     ...</fo:leader>
			</xsl:when>
			<xsl:when test="@Name = 'BoxPadding'">
				<fo:block>
					<fo:table>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell border="solid 1px black" border-collapse="collapse" height="2em">
									<fo:block>&#160;</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline>[<xsl:value-of select="@Name"/>]</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:Emphasis">
		<xsl:choose>
			<!--  HA048129 Pblock titles should be left aligned and italic  -->
		  <xsl:when test="self::*[not(ancestor::leg:Para)]/ancestor::xhtml:th[1][ancestor::xhtml:thead] 
		    or ancestor::leg:Title[parent::*[contains(local-name(),'group')][parent::leg:BlockAmendment]]
		    (: or parent::leg:Title/parent::leg:Pblock :) 
		    or parent::leg:PersonName/parent::leg:Signee">
				<fo:inline font-style="normal">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<!--Chunyu	HA051074 if parent only has emphasis and strong children and not other nodes,each of them should be individual block. See ukci/2010/5/note/sld/created-->
			<!--2013-04-30 Update to HA051074 GC -->
			<!--This fix needs to be a very specific otherwise it has knock on effects to other legislation -->
			<!--Only apply to ENs in ukci's where there is either an Emphasis or Strong element and no textual content-->
			<xsl:when test="$g_strDocType = 'UnitedKingdomChurchInstrument' and
							ancestor::leg:P and 
							ancestor::leg:ExplanatoryNotes and
							(parent::leg:Text/leg:Emphasis or parent::leg:Text/leg:Strong) and
							(every $node in parent::leg:Text/node() satisfies ($node instance of element(leg:Emphasis) or $node instance of element(leg:Strong) or ($node instance of text() and normalize-space($node) = '')))  
							">
				<fo:block font-style="italic" space-after="6pt">
					<xsl:apply-templates/>
					</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-style="italic">
					<xsl:apply-templates/>
					</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="following-sibling::node()[1]/self::text()[normalize-space()='']/following-sibling::node()[1]/self::leg:Emphasis or following-sibling::node()[1]/self::leg:Emphasis">
			<xsl:text>&#x00a0;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:Strong">
		<xsl:choose>
			<xsl:when test="parent::leg:Title/parent::leg:Tabular or parent::xhtml:th/parent::xhtml:tr/parent::xhtml:tbody or (parent::leg:Title/parent::leg:P1group and $g_strDocClass = $g_strConstantSecondary)">
				<fo:inline font-weight="normal">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-weight="bold" >
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

	<xsl:include href="legislation_schema_table_FO.xslt"/>

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

	<xsl:template match="leg:CitationSubRef[@URI]">
		<fo:basic-link color="{$g_strLinkColor}">
			<xsl:attribute name="external-destination">
				<!-- The relationship may be one-to-may so if is just link to first no -->
				<xsl:choose>
					<xsl:when test="@URI">
						<xsl:text>url('</xsl:text>
						<xsl:value-of select="@URI"/>
						<xsl:text>')</xsl:text>
					</xsl:when>
					<xsl:when test="contains(@CitationRef, ' ')">
						<xsl:value-of select="substring-before(@CitationRef, ' ')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@CitationRef"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="@Operative = 'true'">
				<xsl:attribute name="font-weight">
					<xsl:text>bold</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<!--<xsl:call-template name="TSOgetID"/>-->
			<xsl:apply-templates/>
		</fo:basic-link>
	</xsl:template>
<xsl:template match="leg:CitationSubRef[not(@URI)]">
    <xsl:apply-templates/>
</xsl:template>
	<xsl:template match="leg:Citation[@URI]">
		<fo:basic-link color="{$g_strLinkColor}">
			<!--<xsl:call-template name="TSOgetID"/>-->
			<xsl:attribute name="external-destination">
				<xsl:text>url('</xsl:text>
				<xsl:value-of select="@URI"/>
				<xsl:text>')</xsl:text>
			</xsl:attribute>
			<xsl:apply-templates/>
		</fo:basic-link>
	</xsl:template>
<xsl:template match="leg:Citation[not(@URI)]">
    <xsl:apply-templates/>
</xsl:template>

	<xsl:template match="leg:SignedSection">
		<fo:block font-size="{$g_strBodySize}" space-before="24pt">
			<xsl:apply-templates select="leg:Para"/>
			<xsl:for-each select="leg:Signatory">
				<xsl:if test="preceding-sibling::leg:Signatory">
					<fo:block space-before="24pt"/>
				</xsl:if>
				<xsl:if test="leg:Para">
					<xsl:for-each select="leg:Para">
						<fo:block keep-with-next="always">
							<xsl:if test="not(preceding-sibling::*)">
								<xsl:attribute name="margin-top">18pt</xsl:attribute>
							</xsl:if>
							<xsl:if test="not(following-sibling::leg:Para)">
								<xsl:attribute name="space-after">24pt</xsl:attribute>
							</xsl:if>
							<xsl:apply-templates/>
						</fo:block>
					</xsl:for-each>
				</xsl:if>
				<xsl:for-each select="leg:Signee">
					<xsl:choose>
						<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
							<fo:block text-align="center">
								<xsl:apply-templates/>
							</fo:block>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="lssealuri" select="leg:LSseal/@ResourceRef"/>
							<fo:table font-size="{$g_strBodySize}" table-layout="fixed" width="100%">
								<!--					<fo:table-column column-width="30%"/>
							<fo:table-column column-width="70%"/>	-->
								<fo:table-body>
							<xsl:if test="leg:LSseal">
								<fo:table-row>
									<fo:table-cell display-align="before"  number-columns-spanned="2">
										<xsl:choose>
											<xsl:when test="$lssealuri">
												<fo:block keep-with-next="always">
													<fo:external-graphic src='url("{//leg:Resource[@id = $lssealuri]/leg:ExternalVersion/@URI}")' fox:alt-text="Legal seal"/>
												</fo:block>
											</xsl:when>
											<xsl:when test="not(normalize-space(leg:LSseal) = '')">
												<fo:block keep-with-next="always">
													<xsl:apply-templates select="leg:LSseal"/>
												</fo:block>
											</xsl:when>
											<xsl:otherwise>
												<fo:block keep-with-next="always">L.S.</fo:block>
											</xsl:otherwise>
										</xsl:choose>
									</fo:table-cell>
								</fo:table-row>
							</xsl:if>
									<fo:table-row>
										<fo:table-cell display-align="after">
											<xsl:if test="not(leg:Address or leg:DateSigned/leg:DateText)">
												<fo:block/>
											</xsl:if>
											<xsl:if test="leg:Address">
												<xsl:apply-templates select="leg:Address"/>
											</xsl:if>
											
											<xsl:if test="leg:DateSigned/leg:DateText">
												<fo:block keep-with-next="always">
													<xsl:apply-templates select="leg:DateSigned/leg:DateText"/>
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
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:for-each>
		</fo:block>						
	</xsl:template>
	
	<xsl:template match="leg:Address">		
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="leg:AddressLine">
		<fo:block keep-with-next="always">
			<xsl:apply-templates />
		</fo:block>		
	</xsl:template>
	
	<xsl:template match="leg:SignedSection/leg:Signatory/leg:Signee/leg:Para/leg:Text[$g_strDocClass = $g_strConstantEuretained]" priority="50">
		<fo:block text-align="center" space-before="8pt" keep-with-previous="always">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="leg:FootnoteRef">
		<xsl:variable name="strFootnoteRef" select="@Ref" as="xs:string"/>
		<!--<xsl:variable name="intFootnoteNumber" select="count($g_ndsFootnotes[@id = $strFootnoteRef]/preceding-sibling::*) + 1" as="xs:integer"/>-->
		<xsl:variable name="intFootnoteNumber" select="index-of($g_ndsFootnotes/@id, $strFootnoteRef)" as="xs:integer?"/>
		<xsl:variable name="booTableRef" select="ancestor::xhtml:table and $strFootnoteRef = ancestor::xhtml:table/xhtml:tfoot//leg:Footnote/@id" as="xs:boolean"/>
		
		<xsl:choose>
			<xsl:when test="ancestor::*[self::leg:Footnote]">
				<xsl:number value="$intFootnoteNumber" format="1"/> 
			</xsl:when>
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained and $booTableRef = true()">
				<xsl:variable name="nstTableFootnoteRefs" select="ancestor::xhtml:table/xhtml:tfoot//leg:Footnote" as="element(leg:Footnote)*"/>
				<fo:inline font-weight="bold" baseline-shift="super" font-size="6pt">
					<xsl:value-of select="if ($nstTableFootnoteRefs[@id = $strFootnoteRef]/leg:Number) then
										$nstTableFootnoteRefs[@id = $strFootnoteRef]/leg:Number
									else if ($g_strDocClass = $g_strConstantEuretained) then
										leg:format-number-as-alpha(index-of($nstTableFootnoteRefs/@id,$strFootnoteRef))
									else ()"/>
				</fo:inline>
			</xsl:when>
			<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
				<xsl:call-template name="processFootnoteRef">
					<xsl:with-param name="booTableRef" select="$booTableRef"/>
					<xsl:with-param name="strFootnoteRef" select="$strFootnoteRef"/>
					<xsl:with-param name="intFootnoteNumber" select="$intFootnoteNumber"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$booTableRef">
				<xsl:call-template name="processFootnoteRef">
					<xsl:with-param name="booTableRef" select="$booTableRef"/>
					<xsl:with-param name="strFootnoteRef" select="$strFootnoteRef"/>
					<xsl:with-param name="intFootnoteNumber" select="$intFootnoteNumber"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<fo:footnote>
					<xsl:call-template name="processFootnoteRef">
						<xsl:with-param name="booTableRef" select="$booTableRef"/>
						<xsl:with-param name="strFootnoteRef" select="$strFootnoteRef"/>
						<xsl:with-param name="intFootnoteNumber" select="$intFootnoteNumber"/>
					</xsl:call-template>	
					<fo:footnote-body>
						<fo:list-block start-indent="0pt" provisional-label-separation="6pt" provisional-distance-between-starts="18pt">
							<fo:list-item>
								<fo:list-item-label start-indent="0pt" end-indent="label-end()">
									<fo:block font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt" font-weight="bold" font-style="normal">
										<fo:inline font-weight="normal"><xsl:text>(</xsl:text></fo:inline>
										<xsl:number value="$intFootnoteNumber" format="1"/>
										<fo:inline font-weight="normal"><xsl:text>)</xsl:text></fo:inline>
									</fo:block>
								</fo:list-item-label>
								<fo:list-item-body start-indent="body-start()">
									<fo:block font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt"  font-style="normal">
										<xsl:apply-templates select="$g_ndsFootnotes[@id = $strFootnoteRef][1]"/>
									</fo:block>
								</fo:list-item-body>
							</fo:list-item>
						</fo:list-block>		
					</fo:footnote-body>	
				</fo:footnote>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="processFootnoteRef">
		<xsl:param name="booTableRef" as="xs:boolean"/>
		<xsl:param name="strFootnoteRef" as="xs:string"/>
		<xsl:param name="intFootnoteNumber" as="xs:integer?"/>
		<xsl:choose>
			<xsl:when test="$booTableRef = true()">
				<xsl:variable name="nstTableFootnoteRefs" select="ancestor::xhtml:table/xhtml:tfoot//leg:Footnote" as="element(leg:Footnote)*"/>
				<fo:inline font-weight="bold" baseline-shift="super" font-size="6pt">
					<xsl:value-of select="$nstTableFootnoteRefs[@id = $strFootnoteRef]/leg:Number"/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-weight="bold">
					<xsl:choose>
						<xsl:when test="$g_strDocClass = $g_strConstantEuretained">
							<fo:inline baseline-shift="super" font-size="60%" font-weight="bold">			
								<xsl:text>(</xsl:text>
							</fo:inline>
							<fo:basic-link internal-destination="{@Ref}" baseline-shift="super" color="black" font-size="60%" font-weight="bold" >
								<xsl:number value="$intFootnoteNumber" format="1"/>
							</fo:basic-link>
							<fo:inline baseline-shift="super" font-size="60%" font-weight="bold">			
								<xsl:text>)</xsl:text>
							</fo:inline>
						</xsl:when>
						<xsl:otherwise>
							<fo:inline font-weight="normal">			
								<xsl:text>(</xsl:text>
							</fo:inline>
							<xsl:number value="$intFootnoteNumber" format="1"/>
							<fo:inline font-weight="normal">
								<xsl:text>)</xsl:text>
							</fo:inline>
						</xsl:otherwise>
					</xsl:choose>
				</fo:inline>
			</xsl:otherwise>
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
			  <fo:block-container>
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
			    <xsl:apply-templates select="leg:Title"/>
					<fo:block>
						<xsl:apply-templates select="leg:Image"/>
					</fo:block>
				</fo:block-container>
			</xsl:when>
	<!-- Chunyu 09/05/12: Added a condition for portrait dislay images see nisr/1996/447 -->
		<xsl:when test="@Orientation = 'portrait'">
		  <xsl:apply-templates select="leg:Title"/>
					<xsl:for-each select="leg:Image">
					<fo:block-container clear="both">
						<fo:block linefeed-treatment="preserve">
						<xsl:apply-templates select="."/>
						<xsl:text>&#xA;</xsl:text>
					</fo:block></fo:block-container>
				</xsl:for-each>
			
			</xsl:when>
			<!-- need to test for inline on mathml display attribute -->
			<xsl:when test="parent::leg:Version and //leg:Formula[@AltVersionRefs = current()/parent::leg:Version/@id]">
			  <xsl:apply-templates select="leg:Title"/>
				<fo:inline>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block-container>
					<fo:block>
						<xsl:apply-templates/>
					</fo:block>
				</fo:block-container>
			</xsl:otherwise>
		</xsl:choose>
	  </xsl:template>

	<xsl:template match="leg:Image">
		<xsl:variable name="maxHeight" select="640" as="xs:double"/>
		<xsl:variable name="maxWidth" select="414" as="xs:double"/>
		<xsl:variable name="imageHeight" select="number(translate(@Height, 'pt', ''))" as="xs:double"/>
		<xsl:variable name="imageWidth" select="number(translate(@Width, 'pt', ''))" as="xs:double"/>
		<xsl:variable name="strURL" as="xs:string">
			<xsl:variable name="strRef" select="@ResourceRef" as="xs:string"/> 
			<xsl:value-of select="//leg:Resource[@id = $strRef]/leg:ExternalVersion/@URI"/>
		</xsl:variable>
		<!-- Check whether this image is for maths, if so then the alttext attribute needs to be used for the image alt attribute, otherwise use the image Description attribute -->
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
		<!-- we cant use single quotes as part of the uri the single quote is a valid character in the URL syntax -->
		<fo:external-graphic src='url("{$strURL}")' fox:alt-text="{$strAltAttributeDesc}">
			<xsl:choose>
				<xsl:when test="@Width = 'scale-to-fit'">
					<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
					<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>				
					<xsl:attribute name="width">100%</xsl:attribute>
				</xsl:when>
				<!--if it fits use it -->
				<xsl:when test="contains(@Width, 'pt')  and ($imageWidth &lt; $maxWidth) and contains(@Height, 'pt')  and ($imageHeight &lt; $maxHeight)">
					<xsl:attribute name="content-width"><xsl:value-of select="$imageWidth"/>pt</xsl:attribute>
					<xsl:attribute name="content-height"><xsl:value-of select="$imageHeight"/>pt</xsl:attribute>
				</xsl:when>
				
				<!--if the height does not fit the page depth reduce it down and check the width fits-->
				<xsl:when test="contains(@Width, 'pt') and ($imageHeight &gt; $maxHeight) and (($maxHeight * $imageWidth) div $imageHeight &lt; $maxWidth)">
					<xsl:attribute name="content-height"><xsl:value-of select="$maxHeight"/>pt</xsl:attribute>
					<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
				</xsl:when>
				<!-- make it the max width if it is greater than max width-->
				<xsl:when test="contains(@Width, 'pt') and ($imageWidth &gt; $maxWidth)">
					<xsl:attribute name="content-width"><xsl:value-of select="$maxWidth"/>pt</xsl:attribute>
					<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
				</xsl:when>
				<xsl:when test="contains(@Width, 'pt')">
					<xsl:attribute name="content-width"><xsl:value-of select="@Width"/></xsl:attribute>
					<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
				</xsl:when>
				<!-- THIS WILL ONLY WORK IN FOP 1.0 -->
				<xsl:when test="contains(@Width, 'auto') or not(@Width) and $g_strDocClass = $g_strConstantEuretained">
					<xsl:attribute name="max-width"><xsl:value-of select="$maxWidth"/>pt</xsl:attribute>
					<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
					<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
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
		<xsl:choose>
			<xsl:when test="parent::*/@AltVersionRefs">
				<fo:inline><xsl:for-each select="1 to count(ancestor::*[matches(name(), '^(P\d+|ListItem$)')]) * 2">&#160;</xsl:for-each></fo:inline>
				<xsl:call-template name="TSOcheckStartOfAmendment"/>
				<!-- old comment said "We'll assume here that there is only one version"
					This SHOULD be the case but bugs in augment.xsl caused duplciation if the version with 
					same ID if the same image was referrenced twice as is the case with HA052048 -->
				<xsl:apply-templates select="(//leg:Version[@id = current()/parent::*/@AltVersionRefs])[1]/*"/>
				<xsl:call-template name="TSOcheckEndOfAmendment"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:block space-before="6pt" space-after="6pt">
					<xsl:if test="contains(@style, 'font-weight: bold')">
						<xsl:attribute name="font-weight">bold</xsl:attribute>
					</xsl:if>
					<xsl:if test="contains(@style, 'text-align: center')">
						<xsl:attribute name="text-align">center</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="TSOcheckStartOfAmendment"/>
					<xsl:apply-templates/>
					<xsl:call-template name="TSOcheckEndOfAmendment"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="math:mo">
		<xsl:if test="not(@fence = 'true')">
			<xsl:text/>
		</xsl:if>
		<xsl:apply-templates/>
		<xsl:if test="not(@fence = 'true')">
			<xsl:text/>
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
		<fo:block keep-with-previous="always">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!-- Chunyu:HA049511 Added a condtion for the xmlcontent in the resource see uksi/1999/1892 -->
	<xsl:template match="leg:IncludedDocument">
		<xsl:choose>
			<xsl:when test="$includDoc//leg:XMLcontent[not(descendant::leg:Figure)] | $includDoc//leg:XMLcontent[not(descendant::leg:Image)]">
				<fo:block>
					<xsl:apply-templates />
				</fo:block>
			</xsl:when>
			<xsl:when test="parent::leg:Form[count(*)=1]/parent::leg:BlockAmendment[count(*)=1]">
				<fo:table margin-left="-17.5pt" margin-right="17.5pt">
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell display-align="before" width="5pt">
								<fo:block>“</fo:block>
							</fo:table-cell>
							<fo:table-cell width="375pt">
								<fo:block>
									<fo:external-graphic 
										src='url("{//leg:Resource[@id = current()/@ResourceRef]/leg:ExternalVersion/@URI}")' 
										fox:alt-text="{.}"
										content-width="scale-to-fit"
										content-height="100%"
										width="100%"
										scaling="uniform"
									/>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell display-align="after" width="5pt">
								<fo:block>”</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</xsl:when>
			<xsl:otherwise>
				<fo:block><!--GC 2011-03-23 remove keep-with-next=always - issue D501  -->
					<fo:external-graphic src='url("{//leg:Resource[@id = current()/@ResourceRef]/leg:ExternalVersion/@URI}")' fox:alt-text="{.}"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	

	<xsl:template match="leg:InternalVersion">
		<xsl:apply-templates/>
	</xsl:template>
	
	
	
	<xsl:template match="leg:XMLcontent">
	
		<xsl:choose>
			<xsl:when test="not(//leg:Figure | leg:Image)">
					<fo:block>
									
					<xsl:apply-templates/>
				
					</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:instream-foreign-object width="100%" content-width="scale-to-fit">
			<xsl:copy-of select="node()"/>
		</fo:instream-foreign-object>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	

	<xsl:template name="TSOgetID">
		<xsl:if test="@id and not(key('ids', @id)[2])">
			<xsl:attribute name="id" select="@id"/>
		</xsl:if>
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







	<xsl:template match="leg:InlineAmendment">
		<fo:inline>
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>
	
	
	<xsl:template match="leg:Addition | leg:Repeal | leg:Substitution">
		<xsl:param name="showSection" select="root()" tunnel="yes" />
		<xsl:param name="showRepeals" select="false()" tunnel="yes" />	
		<xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
		<xsl:variable name="showCommentary" as="xs:boolean" select="tso:showCommentary(.)" />
		<xsl:variable name="changeId" as="xs:string" select="@ChangeId" />
		<xsl:variable name="showSection" as="node()" select="leg:showSection(., $showSection)" />
		<xsl:variable name="allChanges" as="element()*" select="key('additionRepealChanges', $changeId, root()/leg:Legislation/(leg:EURetained|leg:Primary|leg:Secondary))" />
		<xsl:variable name="sameChanges" as="element()*" select="key('additionRepealChanges', $changeId, $showSection)" />
		<xsl:variable name="firstChange" as="element()?" select="$sameChanges[1]" />
		<xsl:variable name="lastChange" as="element()?" select="$sameChanges[last()]" />
		<xsl:variable name="isFirstChange" as="xs:boolean?" select="leg:isFirstChange(., $allChanges, $firstChange, $changeId)"/>
		<xsl:variable name="changeType" as="xs:string">
			<xsl:choose>
				<xsl:when test="key('substituted', $changeId)">Substitution</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$showCommentary">
			<xsl:if test="$isFirstChange = true()">
				<fo:inline font-weight="bold">[</fo:inline>
				<xsl:if test="self::leg:Addition and parent::leg:Addition and ancestor::leg:Pnumber">
					<fo:block/>
				</xsl:if>
			</xsl:if>
			<xsl:apply-templates select="." mode="AdditionRepealRefs"/>
		</xsl:if>
		<fo:inline>
			<xsl:choose>
				<xsl:when test="@Status = 'Proposed' and $changeType = 'Substitution'">
					<xsl:attribute name="color">#FF4500</xsl:attribute>
					<xsl:attribute name="text-decoration">underline</xsl:attribute>										
				</xsl:when>
				<xsl:when test="@Status = 'Proposed' and $changeType = 'Repeal'">
					<xsl:attribute name="color">#FF0000</xsl:attribute>
					<xsl:attribute name="text-decoration">line-through</xsl:attribute>
				</xsl:when>
				<xsl:when test="@Status = 'Proposed' and $changeType = 'Addition'">
					<xsl:attribute name="color">#008000</xsl:attribute>
					<xsl:attribute name="text-decoration">underline</xsl:attribute>					
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates/>
		</fo:inline>
		<xsl:choose>
			<xsl:when test="$showCommentary and ancestor::xhtml:tbody and (($allChanges[ancestor::xhtml:tfoot][last()]/ancestor::xhtml:table[1] is current()/ancestor::xhtml:table[1]) or  not($allChanges[last()] is .))"></xsl:when>
			<xsl:when test="$showCommentary and ancestor::xhtml:tfoot and ($allChanges[last()][not(ancestor::xhtml:table[1])] or not($allChanges[last()]/ancestor::xhtml:table[1] is current()/ancestor::xhtml:table[1]))"></xsl:when>
			<xsl:when test="$showCommentary and key('additionRepealChanges', @ChangeId, $showSection)[last()] is .">
				<fo:inline font-weight="bold">]</fo:inline>
			</xsl:when>
		</xsl:choose>
		<!-- this condition will allow for any AppendText that is usually treated in the named template FuncCheckForEndOfQuote 
		to prevent the end bracket from incorrectly encapsulating the append text -->
		<xsl:if test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1][self::leg:AppendText] and $seqLastTextNodes = generate-id(text()[not(normalize-space(.) = '')][last()])">
			<xsl:for-each select="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1]">
				<xsl:apply-templates/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:function name="leg:isFirstChange" as="xs:boolean">
		<xsl:param name="node"  as="node()"/>
		<xsl:param name="allChanges" />
		<xsl:param name="firstChange" />
		<xsl:param name="changeId" />
		<xsl:choose>
			<xsl:when test="$node/ancestor::xhtml:tbody and $allChanges[not(ancestor::xhtml:tfoot)][1] is $node">
				<xsl:sequence select="true()" />
			</xsl:when>
			<xsl:when test="$node/ancestor::xhtml:tfoot and $allChanges[ancestor::xhtml:tbody]">
				<xsl:sequence select="false()" />
			</xsl:when>
			<xsl:when test="$node/ancestor::xhtml:table and not($allChanges[1] is $firstChange)">
				<xsl:sequence select="false()" />
			</xsl:when>
			<xsl:when test="$g_strDocClass = ($g_strConstantPrimary, $g_strConstantEuretained) and $node/ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group">
				<xsl:sequence select="$firstChange is ($node/ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group//(leg:Addition|leg:Repeal|leg:Substitution))[@ChangeId = $changeId][1]" />
			</xsl:when>
			<xsl:when test="$g_strDocClass = ($g_strConstantPrimary, $g_strConstantEuretained) and $node/ancestor::leg:Title/parent::leg:P1group">
				<xsl:sequence select="$firstChange is $node and
					empty($node/ancestor::leg:Title/parent::leg:P1group/leg:P1[1]/leg:Pnumber//(leg:Addition|leg:Repeal|leg:Substitution)[@ChangeId = $changeId])" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$firstChange is $node" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="leg:showSection" as="node()">
		<xsl:param name="node" as="node()"/>
		<xsl:param name="showSection" />
		<xsl:sequence 
			select="if ($node/ancestor::*[@VersionReplacement]) then $node/ancestor::*[@VersionReplacement] 
					else if ($node/ancestor::xhtml:tfoot) then $node/ancestor::xhtml:tfoot[1] 
					else if ($node/ancestor::xhtml:tbody) then $node/ancestor::xhtml:tbody[1] 
					else if (exists($showSection) and $node/ancestor-or-self::*[. is $showSection]) then $showSection 
					else if ($g_strDocClass = $g_strConstantEuretained and $node/ancestor::leg:Footnotes) then $node/ancestor::leg:Footnotes 
					else $node/root()/leg:Legislation/(leg:EURetained|leg:Primary|leg:Secondary)" />
	</xsl:function>

	
	<xsl:template match="leg:Addition | leg:Repeal | leg:Substitution" mode="AdditionRepealRefs">
		<xsl:param name="showSection" select="root()" tunnel="yes" />
		<xsl:if test="@CommentaryRef">
			<xsl:variable name="commentaryItem" select="key('commentary', @CommentaryRef)[1]" as="element(leg:Commentary)*"/>
			<xsl:if test="$commentaryItem/@Type = ('F', 'M', 'X')">
				<!-- The <Title> comes before the <Pnumber> in the XML, but appears after the <Pnumber> in the HTML display
				so the first commentary reference for the change is the one in the <Title> rather than the one in the <Pnumber>-->
				<xsl:variable name="changeId" as="xs:string" select="@ChangeId" />			
				<xsl:variable name="showSection" as="node()" select="leg:showSection(., $showSection)" />
				<xsl:variable name="sameChanges" as="element()*" select="key('commentaryRefInChange', concat(@CommentaryRef, '+', @ChangeId), $showSection)" />
				<xsl:variable name="allChanges" as="element()*" select="key('commentaryRefInChange', concat(@CommentaryRef, '+', @ChangeId), root()/leg:Legislation/(leg:EURetained|leg:Primary|leg:Secondary))" />
				<xsl:variable name="firstChange" as="element()?" select="$sameChanges[1]" />
				
				<xsl:variable name="isFirstChange" as="xs:boolean?" select="leg:isFirstChange(., $allChanges, $firstChange, $changeId)"/>
				
				<xsl:if test="$isFirstChange">
					<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReference][1]/@VersionReference"/>
					<xsl:sequence select="tso:OutputCommentaryRef(key('commentaryRef', @CommentaryRef)[1] is ., $commentaryItem,  translate($versionRef,' ',''))"/>
				</xsl:if>		
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="leg:CommentaryRef" priority="50">
		<xsl:choose>
			<xsl:when test="not(ancestor::leg:Text or ancestor::leg:Pnumber or ancestor::leg:Title or ancestor::leg:Number or ancestor::leg:Citation or ancestor::leg:CitationSubRef or ancestor::leg:CitationListRef or ancestor::leg:Addition or ancestor::leg:Repeal or ancestor::leg:Substitution)">
				<fo:block>
					<xsl:next-match/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="leg:CommentaryRef">
		<xsl:variable name="commentaryItem" select="key('commentary', @Ref)[1]" as="element(leg:Commentary)?"/>
		<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReference][1]/@VersionReference"/>
		<xsl:if test="empty($commentaryItem)">
			<fo:inline font-weight="bold" color="red">No commentary item could be found for this reference <xsl:value-of select="@Ref"/>
			</fo:inline>
		</xsl:if>
		<xsl:choose>		
			<xsl:when test="../(self::leg:Addition | self::leg:Repeal | self::leg:Substitution)">
				<!--#HA050337 - updated to fix missing footnote referance. earlier code was only allowing to display first footnote referance . so if the same referance occurs twice
					the code was avoiding it from display 
				http://www.legislation.gov.uk/nisi/1996/275/article/8
				http://www.legislation.gov.uk/nisi/1996/274/article/8A
				-->
				<xsl:if test="$commentaryItem/@Type = ('F', 'M', 'X') and key('commentaryRef', @Ref) = .">
					<xsl:sequence select="tso:OutputCommentaryRef(key('commentaryRef', @Ref) = ., $commentaryItem,  translate($versionRef,' ',''))"/>				
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="tso:showCommentary(.) and $commentaryItem/@Type = ('F', 'M', 'X') ">
					<xsl:sequence select="tso:OutputCommentaryRef(key('commentaryRef', @Ref)[1] is ., $commentaryItem,  translate($versionRef,' ',''))"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	


	<!-- for markers - we do not watn commentary referemces included -->
	<xsl:template match="leg:CommentaryRef" mode="header">
		<xsl:apply-templates/>
	</xsl:template>	



	<xsl:function name="tso:OutputCommentaryRef" as="element(fo:basic-link)">
		<xsl:param name="isFirstReference" as="xs:boolean"/>
		<xsl:param name="commentaryItem" as="element(leg:Commentary)"/>
		<xsl:param name="versionRef" as="xs:string"/>
		<fo:basic-link baseline-shift="super"  color="black" font-size="60%" font-weight="bold" 
    internal-destination="commentary-{$commentaryItem/@id}{$versionRef}">
			<!-- There may be multiple references to the commentary. Only output back id on first one -->
			<xsl:if test="$isFirstReference">
				<xsl:attribute name="id" select="concat('reference-', $commentaryItem/@id, translate($versionRef,' ',''))"/>
			</xsl:if>
			<xsl:variable name="thisId" select="$commentaryItem/@id"/>
			<xsl:value-of select="$commentaryItem/@Type"/>
			<!--<xsl:value-of select="count($commentaryItem/preceding-sibling::*[@Type = $commentaryItem/@Type]) + 1"/>-->
			<!-- we need to reference the document order of the commentaries rather than the commentary order in order to gain the correct numbering sequence -->
			<xsl:value-of select="count($g_commentaryOrder/leg:commentary[@id = $thisId][1]/preceding-sibling::*[@Type = $commentaryItem/@Type]) + 1"/>
		</fo:basic-link>
	</xsl:function>

	<xsl:template match="leg:Commentaries | err:Warning | leg:CitationLists"/>



	<xsl:template match="leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:Schedule" name="FuncProcessMajorHeading">
		<xsl:if test="self::leg:Group | self::leg:Part | self::leg:Chapter | self::leg:Schedule">
			<!--<xsl:call-template name="FuncCheckForIDelement"/>-->
		</xsl:if>
		<xsl:if test="leg:Reference and not(contains($g_strDocType, 'ScottishAct'))">
			<fo:block>
				<xsl:for-each select="leg:Reference">
					<!--<xsl:call-template name="FuncCheckForID"/>-->
					<xsl:apply-templates/>
				</xsl:for-each>
			</fo:block>
		</xsl:if>
		<!--<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>-->
		<fo:block>
			<!-- enable this if we want to customise the PDF tags -->
			<!--<xsl:attribute name="role">
				<xsl:value-of select="concat('H',tso:CalcHeadingLevel(.))"/>
			</xsl:attribute>-->
			<xsl:apply-templates select="leg:Number | leg:Title | leg:TitleBlock | processing-instruction()[following-sibling::leg:Number or following-sibling::leg:Title or following-sibling::leg:TitleBlock or following-sibling::leg:Reference]"/>
		</fo:block>
		<xsl:if test="leg:Reference and contains($g_strDocType, 'ScottishAct')">
			<fo:block>
				<xsl:for-each select="leg:Reference">
					<!--<xsl:call-template name="FuncCheckForID"/>-->
					<xsl:apply-templates/>
				</xsl:for-each>
			</fo:block>
		</xsl:if>
		<xsl:apply-templates select="." mode="Structure"/>
	</xsl:template>



	<!-- when we have repealed parts then a child para is usually added which has the annotation in it  -->
	<xsl:template match="leg:P">
		<xsl:apply-templates/>
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	</xsl:template>

	<xsl:template match="leg:Para">
		<fo:block>
			<xsl:apply-templates select="*"/>
		</fo:block>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>
	
	<xsl:template match="leg:SignedSection" priority="20">
		<xsl:next-match/>
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	</xsl:template>

	<xsl:template match="leg:ExplanatoryNotes" priority="10">
		<xsl:next-match/>
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	</xsl:template>


	<!-- ANNOTATION PROCESSING -->
	<!-- call the annotation processing from a common module that serves both html and fo generation  --> 
	<xsl:template match="*" mode="ProcessAnnotations" priority="100">
		<xsl:variable name="annotations-html">
			<xsl:next-match/>
		</xsl:variable>
		<xsl:apply-templates select="$annotations-html" mode="annotation-html"/>
	</xsl:template>
	
	<xsl:template match="fo:*|@*|text()" mode="annotation-html">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" mode="annotation-html"/>
		</xsl:copy>
	</xsl:template>	

	<xsl:template match="xhtml:div[@class='LegAnnotationsHeading']" mode="annotation-html">
		<fo:block font-weight="bold" font-size="10pt" keep-with-next="always">
			<xsl:apply-templates mode="annotation-html"/>
		</fo:block>
	</xsl:template>	
	
	<xsl:template match="xhtml:div[@class='LegAnnotations']" mode="annotation-html">
		<fo:block  margin-left="0pt" margin-right="0pt" font-size="10pt" border="0.75pt #c7c7c7 solid" padding="6pt" color="black" space-before="8pt" >
			<xsl:apply-templates mode="annotation-html"/>
		</fo:block>
	</xsl:template>	
	
	<xsl:template match="xhtml:p[@class='LegAnnotationsGroupHeading']" mode="annotation-html">
		<fo:block font-weight="bold"  padding-top="6pt" border-top="0.75pt #c7c7c7 dotted"  space-before="6pt" keep-with-next="always">
			<xsl:apply-templates mode="annotation-html"/>
		</fo:block>
	</xsl:template>		

	<xsl:template match="xhtml:*" mode="annotation-html">
		<fo:block>
			<xsl:apply-templates mode="annotation-html"/>
		</fo:block>
	</xsl:template>	

	<!-- END OF ANNOTATION PROCESSING -->

		

	<!-- Override Vanilla handling -->
	<xsl:template match="leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:Schedule | leg:Form" mode="Structure">
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		<xsl:call-template name="FuncProcessStructureContents"/>
	</xsl:template>

	<xsl:template name="FuncProcessStructureContents">
		<xsl:apply-templates select="*[not(self::leg:Reference or self::leg:Number or self::leg:Title or self::leg:TitleBlock)] | processing-instruction()[not(following-sibling::leg:Number or following-sibling::leg:Title or following-sibling::leg:TitleBlock or following-sibling::leg:Reference)]"/>
	</xsl:template>






	<xsl:template match="leg:Commentary" mode="DisplayAnnotations">
		<xsl:param name="versionRef"/>
		<!-- MS: if this has no children then output nothing -->
		<xsl:choose>
			<xsl:when test="leg:*">
				<fo:block id="commentary-{@id}{translate($versionRef,' ','')}" space-after="0pt">
					<fo:list-block provisional-label-separation="3pt" space-before="0pt" provisional-distance-between-starts="24pt" margin-left="6pt">
						<xsl:apply-templates select="leg:Para" mode="DisplayAnnotations" >
							<xsl:with-param name="versionRef" select="$versionRef"/>
						</xsl:apply-templates>
					</fo:list-block>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>Commentary has no children!</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:Commentary/leg:Para" mode="DisplayAnnotations">
		<xsl:param name="versionRef"/>
		<xsl:if test="position() = 1">
			<fo:list-item font-size="9pt" space-before="0pt" space-after="0pt">
				<fo:list-item-label end-indent="label-end()" font-weight="bold">
					<!--<xsl:variable name="strType" as="xs:string"
					select="concat(../@Type, count(../preceding-sibling::leg:Commentary[@Type = current()/../@Type]) + 1)" />-->
					<!-- we need to reference the document order of the commentaries rather than the commentary order in order to gain the correct numbering sequence -->
					<xsl:variable name="thisId" select="parent::leg:Commentary/@id"/>
					<xsl:variable name="thisType" select="parent::leg:Commentary/@Type"/>
					<xsl:variable name="strType" as="xs:string"
					select="concat(../@Type, count($g_commentaryOrder/leg:commentary[@id = $thisId][1]/preceding-sibling::*[@Type = $thisType]) + 1)" />
					
					
					<fo:block>
						<xsl:choose>
							<xsl:when test="../@Type = ('F', 'M', 'X')">
								<fo:basic-link internal-destination="reference-{../@id}{translate($versionRef,' ','')}">
									<xsl:value-of select="$strType" />
								</fo:basic-link>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$strType" />
							</xsl:otherwise>
						</xsl:choose>
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<xsl:apply-templates mode="DisplayAnnotations" />
					<xsl:apply-templates select="parent::leg:Commentary/leg:Para[position() != 1]/*" mode="DisplayAnnotations" />
				</fo:list-item-body>
			</fo:list-item>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:Commentary/leg:Para/leg:Text" mode="DisplayAnnotations">
		<fo:block>
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>




	<!-- ========== Handle extent information ========== -->
	<!-- May need to extend this to cover a standalone P1 as well as P1group for secondary formatted legislation -->

	<xsl:template match="leg:PrimaryPrelims | leg:SecondaryPrelims | leg:EUPrelims" priority="100">
		<xsl:if test="ancestor-or-self::*/@RestrictExtent and  ($g_matchExtent = 'true' or parent::*/@Concurrent = 'true' or ancestor-or-self::*/@VersionReplacement)">
			<fo:block>
				<xsl:copy-of select="tso:generateExtentInfo(.)"/>
			</fo:block>
		</xsl:if>	
		<xsl:next-match/>
	</xsl:template>

	<xsl:template name="FuncGenerateMajorHeadingNumber">
		<xsl:param name="strHeading"/>
		
			<xsl:if test="ancestor-or-self::*/@RestrictExtent and  ($g_matchExtent = 'true' or parent::*/@Concurrent = 'true' or ancestor-or-self::*/@VersionReplacement)">
				<fo:inline><xsl:copy-of select="tso:generateExtentInfo(.)"/></fo:inline>
			</xsl:if>	
	</xsl:template>

	<xsl:template match="leg:P1group[not(ancestor::leg:BlockAmendment)]/leg:Title/node()[last()]" priority="100">
		<xsl:next-match/>
	</xsl:template>

	<xsl:function name="tso:generateExtentInfo" as="element(fo:inline)*">
		<xsl:param name="element" as="node()" />
		<xsl:variable name="extents" select="$element/ancestor-or-self::*[@RestrictExtent][1]/@RestrictExtent"/>
		<xsl:variable name="resolvedExtents" select="if ($extents) then replace($extents, 'E\+W\+S\+N\.?I\.?', 'U.K.') else ()"/>
		<xsl:if test="not($element/ancestor::xhtml:table)">
			<fo:inline>&#160;</fo:inline>
			<fo:inline color="white" background-color="rgb(102,0,102)" padding-top="3pt" padding-bottom="1pt" padding-left="5pt" padding-right="5pt">
				<!--<xsl:text> [</xsl:text>-->
				<xsl:value-of select="$resolvedExtents"/>
				<!--<xsl:text>]</xsl:text>-->
			</fo:inline>
		</xsl:if>
	</xsl:function>	

	<!-- VERSION HANDLING -->


	<xsl:template name="FuncApplyVersions">
		<xsl:if test="@AltVersionRefs">
			<!-- Output annotations for default version -->
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
			<xsl:call-template name="FuncApplyVersion">
				<xsl:with-param name="strVersions" select="concat(normalize-space(@AltVersionRefs), ' ')"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="FuncApplyVersion">
		<xsl:param name="strVersions"/>

		<xsl:variable name="strVersion" select="normalize-space(substring-before(concat($strVersions, ' '), ' '))"/>
		<!-- We are going to create a copy of the XML but put the versioned XML into the same place as the original version -->
		<xsl:apply-templates select="$g_ndsVersions[@id = $strVersion]" mode="VersionNormalisationContext">
			<xsl:with-param name="itemToReplace" select="."/>
			<xsl:with-param name="strVersion" select="@RestrictExtent, $strVersion"/>
		</xsl:apply-templates>

		<xsl:variable name="strRemainingVersions" select="normalize-space(substring-after($strVersions, $strVersion))"/>
		<xsl:if test="$strRemainingVersions != ''">
			<xsl:call-template name="FuncApplyVersion">
				<xsl:with-param name="strVersions" select="$strRemainingVersions"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:Version" mode="VersionNormalisationContext">
		<xsl:param name="itemToReplace" as="element()"/>
		<xsl:param name="strVersion"/>

		<xsl:variable name="ndsVersionToUse" select="."/>	
		<!-- Generate a document that is the correct context -->
		<xsl:variable name="rtfNormalisedDoc">
			<xsl:for-each select="$g_ndsMainDoc">
				<xsl:apply-templates mode="VersionNormalisation">
					<xsl:with-param name="ndsVersionToUse" select="$ndsVersionToUse"/>
					<xsl:with-param name="itemToReplace" select="$itemToReplace"/>
					<xsl:with-param name="strVersion" select="$strVersion"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:variable>
		<!--<xsl:if test="descendant-or-self::*[@Ref='c1088016']"><xsl:message>FOUND</xsl:message><xsl:result-document href="{generate-id(.)}.{count(preceding-sibling::leg:Version)}.xml"><total><xsl:sequence select="$rtfNormalisedDoc"/><KEYS><xsl:for-each select="//*[@Ref='c1088016']"><ID><xsl:value-of select="generate-id(.)"/></ID></xsl:for-each></KEYS></total></xsl:result-document></xsl:if>-->
		<xsl:for-each select="$rtfNormalisedDoc">
			<xsl:apply-templates select="//*[@VersionReplacement = 'True']"/>
		</xsl:for-each>

	</xsl:template>	

	<xsl:template match="*" mode="VersionNormalisation">
		<xsl:param name="ndsVersionToUse"/>
		<xsl:param name="itemToReplace" as="element()"/>
		<xsl:param name="strVersion"/>
		<xsl:choose>
			<xsl:when test=". >> $itemToReplace">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:when test="not(some $i in descendant-or-self::* satisfies $i is $itemToReplace)">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:when test=". is $itemToReplace">
				<xsl:for-each select="$ndsVersionToUse/*">
					<xsl:copy>
						<xsl:copy-of select="@*"/>
						<!--We will use a VersionReplacement attribute to identify the substituted content -->
						<xsl:attribute name="VersionReplacement">True</xsl:attribute>
						<xsl:attribute name="VersionReference" select="$strVersion"/>
						<xsl:if test="not(@xml:lang) and $ndsVersionToUse/@Language">
							<xsl:attribute name="xml:lang">
								<xsl:for-each select="$ndsVersionToUse">
									<xsl:choose>
										<xsl:when test="@Language = 'French'">fr</xsl:when>
										<!-- Need to add more languages here -->
									</xsl:choose>						
								</xsl:for-each>
							</xsl:attribute>
						</xsl:if>
						<xsl:copy-of select="node()"/>
					</xsl:copy>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:attribute name="genID">
						<xsl:value-of select="generate-id()"/>
					</xsl:attribute>
					<xsl:apply-templates mode="VersionNormalisation">
						<xsl:with-param name="ndsVersionToUse" select="$ndsVersionToUse"/>
						<xsl:with-param name="itemToReplace" select="$itemToReplace"/>
						<xsl:with-param name="strVersion" select="$strVersion"/>
					</xsl:apply-templates>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:FragmentTitle">
		<fo:block margin-top="18pt" text-align="center" font-style="italic">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>


	<!-- html status warning message transforms  -->

	<xsl:template match="xhtml:div[@id='statusWarning']" mode="statuswarning">
		<fo:block   margin="6pt" font-size="10pt" border="0.5pt black solid" padding="6pt" color="black" space-before="8pt" background-color="#F9F7F8" space-after="12pt">
			<xsl:apply-templates mode="statuswarning"/>
		</fo:block>
	</xsl:template>	

	<xsl:template match="xhtml:div[@id=('statusEffectsAppliedSection','changesAppliedSection','commencementAppliedSection','infoSection','infoDraft')]" mode="statuswarning">
		<fo:block   margin="6pt" font-size="10pt" border="0.5pt black solid" padding="6pt" color="black" space-before="8pt" background-color="#F9F7F8" space-after="12pt">
			<xsl:apply-templates mode="statuswarning"/>
		</fo:block>
	</xsl:template>		

	<xsl:template match="xhtml:div" mode="statuswarning">
		<fo:block>
			<xsl:apply-templates mode="statuswarning"/>
		</fo:block>
	</xsl:template>		


	<xsl:template match="xhtml:p" mode="statuswarning">
		<fo:block color="#990101">
			<xsl:apply-templates mode="statuswarning"/>
		</fo:block>
	</xsl:template>	

	<xsl:template match="xhtml:strong" mode="statuswarning">
		<fo:block font-weight="bold">
			<xsl:apply-templates mode="statuswarning"/>
		</fo:block>
	</xsl:template>		

	<xsl:template match="xhtml:a" mode="statuswarning">
		<xsl:choose>
			<xsl:when test="starts-with(@href,'http')">
				<fo:basic-link external-destination="url('{@href}')" color="{$g_strLinkColor}">
					<xsl:apply-templates mode="statuswarning"/>
				</fo:basic-link>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="statuswarning"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>		

	<xsl:template match="xhtml:*" mode="statuswarning">
		<xsl:apply-templates mode="statuswarning"/>
	</xsl:template>	

	<xsl:template match="xhtml:span[@id='viewChanges']" mode="statuswarning">
		<fo:inline> 
			<xsl:text> (Document generated on </xsl:text> 
			<xsl:value-of select="format-date(current-date(),'[Y]-[M,2]-[D,2]')"/>
			<xsl:text>)</xsl:text> 
		</fo:inline>
	</xsl:template>		

	<!--<xsl:template match="text()" mode="statuswarning">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>	-->	
	<xsl:template match="xhtml:h2" mode="statuswarning">
		<fo:block color="#990101" font-weight="bold">
			<xsl:apply-templates mode="statuswarning"/>
			<xsl:text>&#160;</xsl:text>
		</fo:block>
	</xsl:template>	

	<xsl:template match="xhtml:h3" mode="statuswarning">
		<fo:block color="#990101" font-weight="bold">
			<xsl:apply-templates mode="statuswarning"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="xhtml:ul" mode="statuswarning">
		<!-- this conditional is a failsafe to make sure that the list does have some list-items otherwise FOP will fall over  -->
		<xsl:if test="*">
			<fo:list-block space-before="3pt" space-after="3pt" provisional-label-separation="6pt" provisional-distance-between-starts="24pt">
				<xsl:apply-templates mode="statuswarning"/>
			</fo:list-block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="xhtml:li" mode="statuswarning">
		<fo:list-item>
			<fo:list-item-label  end-indent="label-end()">
				<fo:block>&#8211;</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block space-after="3pt">
					<xsl:apply-templates mode="statuswarning"/>
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>



	<xsl:template match="xhtml:div[@id='statusWarning'] | xhtml:div[@id='infoSection'] | xhtml:div[@id='infoDraft'] | xhtml:div[starts-with(@id,'infoProposed')]" mode="statuswarningHeader">
		<fo:block   font-size="{$g_strStatusSize}" font-family="{$g_strMainFont}" font-style="italic">
			<xsl:apply-templates mode="statuswarningHeader"/>
		</fo:block>
	</xsl:template>		


	<xsl:template match="xhtml:h2" mode="statuswarningHeader">
		<fo:inline font-weight="bold">
			<xsl:apply-templates mode="statuswarningHeader"/>
			<xsl:text>&#160;</xsl:text>
		</fo:inline>
	</xsl:template>	

	<xsl:template match="xhtml:p" mode="statuswarningHeader">
		<fo:inline>
			<xsl:apply-templates mode="statuswarningHeader"/>
			<xsl:if test="ancestor::xhtml:div[@id='statusWarning']">
				<xsl:text> (See end of Document for details)</xsl:text> 
			</xsl:if>
		</fo:inline>
	</xsl:template>		



	<xsl:template match="xhtml:strong" mode="statuswarningHeader">
		<fo:inline font-weight="bold">
			<xsl:apply-templates mode="statuswarningHeader"/>
		</fo:inline>
	</xsl:template>	

	<xsl:template match="xhtml:div[@id='statusWarningSubSections'] | xhtml:div[@id='statusEffectsAppliedSection'] | xhtml:div[@id='changesAppliedSection'] " mode="statuswarningHeader">

	</xsl:template>	

	<xsl:template name="FOPfootnoteHack">
	
	<!-- Hack to get around footnote issue in FOP - footnotes in lists/tables disappear!-->
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
										<fo:inline font-weight="normal"><xsl:text>(</xsl:text></fo:inline>
										<xsl:number value="$intFootnoteNumber" format="1"/>
										<fo:inline font-weight="normal"><xsl:text>)</xsl:text></fo:inline>
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

<!-- Suppress repealed content -->
	<!-- D315: For substitutions we would like to show only the 'new' text again enclosed in brackets, at the moment on the system both the new and old text are appearing -->
	<xsl:template match="leg:Group[.//leg:Repeal[@SubstitutionRef]] | leg:Part[.//leg:Repeal[@SubstitutionRef]] | leg:Chapter[.//leg:Repeal[@SubstitutionRef]] | 
			leg:Schedule[.//leg:Repeal[@SubstitutionRef]] | leg:ScheduleBody[.//leg:Repeal[@SubstitutionRef]] |
			leg:Pblock[.//leg:Repeal[@SubstitutionRef]] | leg:PsubBlock[.//leg:Repeal[@SubstitutionRef]] | leg:P1group[.//leg:Repeal[@SubstitutionRef]] | 
			leg:P1[.//leg:Repeal[@SubstitutionRef]] | leg:P2[.//leg:Repeal[@SubstitutionRef]] | leg:P3[.//leg:Repeal[@SubstitutionRef]] | 
			leg:P4[.//leg:Repeal[@SubstitutionRef]] | leg:P5[.//leg:Repeal[@SubstitutionRef]] | leg:P6[.//leg:Repeal[@SubstitutionRef]] | leg:P7[.//leg:Repeal[@SubstitutionRef]] |
			leg:P1para[.//leg:Repeal[@SubstitutionRef]] | leg:P2para[.//leg:Repeal[@SubstitutionRef]] | leg:P3para[.//leg:Repeal[@SubstitutionRef]] | 
			leg:P4para[.//leg:Repeal[@SubstitutionRef]] | leg:P5para[.//leg:Repeal[@SubstitutionRef]] | leg:P6para[.//leg:Repeal[@SubstitutionRef]] | leg:P7para[.//leg:Repeal[@SubstitutionRef]]"
			priority="499">
		<xsl:param name="showRepeals" select="false()" tunnel="yes" />	
		<xsl:if test="$selectedSectionSubstituted or not(tso:isSubstituted(.)) or $showRepeals">
			<xsl:next-match />
		</xsl:if>
	</xsl:template>

	<!-- DXXX: For repeals we would like to show only the text again enclosed in brackets if showRepeals is turned on   -->
	<xsl:template match="leg:Group[.//leg:Repeal] | leg:Part[.//leg:Repeal] | leg:Chapter[.//leg:Repeal] | 
			leg:Schedule[.//leg:Repeal] | leg:ScheduleBody[.//leg:Repeal] |
			leg:Pblock[.//leg:Repeal] | leg:PsubBlock[.//leg:Repeal] | leg:P1group[.//leg:Repeal] | 
			leg:P1[.//leg:Repeal] | leg:P2[.//leg:Repeal] | leg:P3[.//leg:Repeal] | 
			leg:P4[.//leg:Repeal] | leg:P5[.//leg:Repeal] | leg:P6[.//leg:Repeal] | leg:P7[.//leg:Repeal] |
			leg:P1para[.//leg:Repeal] | leg:P2para[.//leg:Repeal] | leg:P3para[.//leg:Repeal] | 
			leg:P4para[.//leg:Repeal] | leg:P5para[.//leg:Repeal] | leg:P6para[.//leg:Repeal] | leg:P7para[.//leg:Repeal]"
			priority="500">
		<xsl:param name="showRepeals" select="false()" tunnel="yes" />	
				
		<xsl:choose>
			<xsl:when test="$showRepeals or not(tso:isProposedRepeal(.))">
				<xsl:next-match />		
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>		
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="leg:Repeal[@SubstitutionRef]">
		<xsl:param name="showRepeals" select="false()" tunnel="yes" />	
		<xsl:if test="$selectedSectionSubstituted or $showRepeals">
			<xsl:next-match />
		</xsl:if>
	</xsl:template>
	
	
	
	<!-- EU TEMPLATES  -->
	
	<xsl:template match="leg:Expanded">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	
	<xsl:template match="leg:Uppercase">
		<fo:inline text-transform="uppercase">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="leg:P1group | leg:Division[not(@Type)]"  priority="100">
		<!-- we need to have a marker on every page to replicate the breadcrumb in a consistent fashion -->
		<!-- if this is marked at the high level a page which has no marker will refer to the highest level  -->
		<!-- this should resolve such issues  -->
		<xsl:if test="$g_strDocClass = $g_strConstantEuretained">
			<fo:block keep-with-next="always">
				<fo:marker marker-class-name="runningheadEU">
					<xsl:call-template name="OutputHeaderBreadscrumb"/>
				</fo:marker>
			</fo:block>
		</xsl:if>
		<xsl:next-match/>
	</xsl:template>


	<xsl:template match="leg:EUTitle | leg:EUPart | leg:EUChapter | leg:EUSection | leg:EUSubsection | leg:Division[leg:Title][@Type = ('EUPart','EUTitle','EUChapter','EUSection','EUSubsection', 'ANNEX')]"  priority="20">
		<xsl:variable name="element" select="if (@Type) then @Type else local-name()"/>
		<xsl:variable name="name" 
			select="
					if (local-name() = 'Division') then
						lower-case(substring-after(@Type, 'EU'))
					else lower-case(substring-after(local-name(), 'EU'))"/>
		<fo:block>
			<!--<fo:marker marker-class-name="runningheadEU">
				<xsl:call-template name="OutputHeaderBreadscrumb"/>
				<xsl:apply-templates select="." mode="runningheader"/>
			</fo:marker>-->
			<xsl:apply-templates/>
		</fo:block>
		<xsl:if test="not(@AltVersionRefs) and not(parent::leg:BlockAmendment)">
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*[leg:Number != '' ]" mode="runningheader" priority="3">
		<xsl:choose>
			<xsl:when test="self::leg:Division">
				<xsl:variable name="prefix" 
								select="
									if (@Type = 'EUTitle' and not(matches(leg:Number, 'title', 'i'))) then 'Title'
									else if (@Type = 'EUPart' and not(matches(leg:Number, 'part', 'i'))) then 'Part'
									else if (@Type = 'EUChapter' and not(matches(leg:Number, 'chapter', 'i'))) then 'Chapter'
									else if (@Type = 'EUSection' and not(matches(leg:Number, 'section', 'i'))) then 'Section'
									else if (@Type = 'EUSubsection' and not(matches(leg:Number, 'section', 'i'))) then 'Sub-Section'
									else if (@Type = 'Annotations' and not(matches(leg:Number, 'annotation', 'i'))) then 'Annotations'
									else if (@Type = 'Annotation' and not(matches(leg:Number, 'annotation', 'i'))) then 'Annotation'
									else if (@Type = ('EUTitle', 'EUPart', 'EUChapter', 'EUSection', 'EUSubsection', 'Annotations', 'Annotation')) then ()
									else 'Division'
									"/>
				<xsl:value-of select="concat($prefix, ' ', leg:Number)" />				
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="leg:Number" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:Division[leg:Number][leg:Title]" priority="15">
		<fo:block>
			<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="42pt" text-indent="0pt">	
				<fo:list-item text-indent="0pt">
					<xsl:call-template name="TSOgetID"/>
					<fo:list-item-label start-indent="0pt">
						<fo:block font-size="{$g_strBodySize}" text-align="left" margin-left="0pt">
							<xsl:apply-templates select="leg:Number"/>
						</fo:block>						
					</fo:list-item-label>
					<fo:list-item-body text-indent="42pt" end-indent="0pt">
						<fo:block font-size="{$g_strBodySize}" text-align="justify">
							<!--<xsl:apply-templates select="leg:P2para"/>-->
							<xsl:apply-templates select="leg:Title"/>
							<xsl:if test="ancestor-or-self::*/@RestrictExtent and  ($g_matchExtent = 'true' or parent::*/@Concurrent = 'true' or ancestor-or-self::*/@VersionReplacement) and not(ancestor::leg:BlockAmendment)">
								<xsl:copy-of select="tso:generateExtentInfo(.)"/>
							</xsl:if>
						</fo:block>	
					</fo:list-item-body>
				</fo:list-item>	
			</fo:list-block>
			<xsl:apply-templates select="*[not(self::leg:Title or self::leg:Number)]"/>
		</fo:block>
		<xsl:if test="not(@AltVersionRefs) and not(parent::leg:BlockAmendment)">
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="leg:Division[leg:Number][not(leg:Title)]" priority="20">
		<fo:block>
			<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="42pt" text-indent="0pt">	
				<fo:list-item text-indent="0pt">
					<xsl:call-template name="TSOgetID"/>
					<fo:list-item-label start-indent="0pt">
						<fo:block font-size="{$g_strBodySize}" text-align="left" margin-left="0pt">
							<xsl:apply-templates select="leg:Number"/>
						</fo:block>						
					</fo:list-item-label>
					<fo:list-item-body text-indent="42pt" end-indent="0pt">
						<fo:block font-size="{$g_strBodySize}" text-align="justify">
							<xsl:apply-templates select="leg:Number/following-sibling::*[1]" mode="numberedpara"/>
						</fo:block>	
					</fo:list-item-body>
				</fo:list-item>	
			</fo:list-block>
			<xsl:apply-templates select="*[not(self::leg:Number)][self::*[not(preceding-sibling::*[1][self::leg:Number])]]"/>
		</fo:block>
		<xsl:if test="not(@AltVersionRefs) and not(parent::leg:BlockAmendment)">
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		</xsl:if>
	</xsl:template>

	<!-- very sepcific annex title that appears as the first division in a schedule body  -->
	<xsl:template match="leg:Division[not(preceding-sibling::*)][parent::leg:ScheduleBody][not(translate(leg:Number, '.()', '') castable as xs:integer)]" priority="50">
		<xsl:variable name="element" select="if (@Type) then @Type else local-name()"/>
		<fo:block>
			<xsl:apply-templates select="leg:Title | leg:Number"/>
			<xsl:apply-templates select="*[not(self::leg:Title or self::leg:Number)]"/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="leg:Division/leg:Number | leg:Division/leg:Title">
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template match="leg:EUTitle/leg:Number | leg:EUPart/leg:Number | leg:EUChapter/leg:Number | leg:EUSection/leg:Number | leg:EUSubsection/leg:Number |  leg:Division[leg:Title][@Type = ('EUPart','EUTitle','EUChapter','EUSection','EUSubsection', 'ANNEX')]/leg:Number" priority="40">
		<xsl:variable name="font-weight" select="if (parent::leg:EUTitle or parent::leg:Divion/@Type = 'EUTitle') then 'bold' else 'normal'"/>
		<fo:block font-size="{$g_strBodySize}" space-before="24pt" text-align="center" keep-with-next="always" font-weight="{font-weight}">
			<xsl:apply-templates/>
			<xsl:if test="ancestor-or-self::*/@RestrictExtent and  ($g_matchExtent = 'true' or parent::*/@Concurrent = 'true' or ancestor-or-self::*/@VersionReplacement) and not(ancestor::leg:BlockAmendment)">
				<xsl:copy-of select="tso:generateExtentInfo(.)"/>
			</xsl:if>
		</fo:block>
	</xsl:template>
	

	<xsl:template match="leg:EUTitle/leg:Title | leg:EUPart/leg:Title | leg:EUChapter/leg:Title | leg:EUSection/leg:Title | leg:EUSubsection/leg:Title | leg:Division[leg:Title][@Type = ('EUPart','EUTitle','EUChapter','EUSection','EUSubsection', 'ANNEX')]/leg:Title" priority="10">
		<xsl:variable name="contentcount" select="string-length(parent::*/leg:Number)"/>
		<xsl:variable name="element" select="if (parent::*/@Type) then parent::*/ @Type 
			else if (parent::leg:Division[not(@type)] and ancestor::leg:Schedule and $contentcount gt 8) then 'ScheduleSection'
			else parent::*/local-name()"/>
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<xsl:variable name="class" select="concat('Leg',$element, 'Title', $strAmendmentSuffix)"/>
		
		<fo:block  font-size="{$g_strBodySize}" text-align="center" keep-with-next="always" font-weight="bold" space-before="12pt">
			<xsl:choose>
				<xsl:when test="$class = 'LegDivisionTitle'">
					<xsl:attribute name="text-align">left</xsl:attribute>
					<xsl:attribute name="font-weight">normal</xsl:attribute>		
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="leg:Attachment//leg:EUPrelims" priority="10">
		<fo:block>
			<xsl:apply-templates/>		
		</fo:block>
	</xsl:template>
	
	<xsl:template match="leg:Attachment//leg:EUBody" priority="400">
		<fo:block>
			<xsl:apply-templates/>		
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:Attachments" priority="10">
		<fo:block>
			<xsl:apply-templates/>		
		</fo:block>
	</xsl:template>
	
	<xsl:template match="leg:Attachment//leg:EURetained" priority="10">
		<xsl:apply-templates/>		
	</xsl:template>

		
	<xsl:template match="leg:Attachment" priority="10">
		<fo:block text-align="justify" font-size="{$g_strBodySize}">
			<xsl:call-template name="TSOgetID"/>	
			<fo:marker marker-class-name="runningheadschedule">
				<xsl:value-of select="(.//leg:Title)[1]"/>
			</fo:marker>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:P" mode="numberedpara">
		<xsl:variable name="element" select="if (parent::*/@Type) then parent::*/ @Type else parent::*/local-name()"/>
		<fo:block>
			<xsl:apply-templates select="leg:Text/node()"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:P1[not(parent::leg:P1group)][$g_strDocClass = $g_strConstantEuretained]" priority="70">
		<fo:block>
			<fo:block font-size="{$g_strBodySize}" text-align="center" font-weight="normal" font-style="italic" keep-with-next="always" space-before="8pt" space-after="8pt">
				<xsl:apply-templates select="leg:Pnumber"/>
				<xsl:if test="ancestor-or-self::*/@RestrictExtent and  ($g_matchExtent = 'true' or parent::*/@Concurrent = 'true' or ancestor-or-self::*/@VersionReplacement) and not(ancestor::leg:BlockAmendment)">
					<xsl:copy-of select="tso:generateExtentInfo(.)"/>
				</xsl:if>
			</fo:block>
			<xsl:if test="parent::leg:P1group and not(preceding-sibling::leg:P1)">
				<fo:block font-size="{$g_strBodySize}" text-align="center" font-weight="bold">
					<xsl:apply-templates select="leg:Title"/>
				</fo:block>
			</xsl:if>
			<xsl:apply-templates select="*[not(self::leg:Title or self::leg:Pnumber)]"/>
		</fo:block>
	</xsl:template>

	<!-- EU special case numbered P2group elements -->
	<xsl:template match="leg:P2group[leg:Pnumber][leg:Title]" priority="50">
		<fo:block>
			<xsl:apply-templates select="leg:Title | leg:Pnumber"/>
		</fo:block>
		<xsl:apply-templates select="*[not(self::leg:Title or self::leg:Pnumber)]"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>


	<xsl:template match="leg:P2group[leg:Pnumber]/leg:Title" priority="50">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:P2group[leg:Pnumber]/leg:Pnumber" priority="50">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>



	<xsl:template match="leg:EUPreamble">
		<fo:block font-size="{$g_strBodySize}" line-height="14pt" margin-top="12pt" text-align="justify">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:EUPreamble/leg:Division" priority="50">
		<fo:list-block provisional-label-separation="3pt" provisional-distance-between-starts="36pt" space-before="6pt">		
			<xsl:call-template name="TSOgetID"/>
			<fo:list-item>
				<fo:list-item-label end-indent="label-end()">
					<fo:block font-size="{$g_strBodySize}" font-weight="normal">
						<xsl:attribute name="text-align">left</xsl:attribute>
						<xsl:attribute name="margin-left">
							<xsl:choose>
								<xsl:when test="leg:Pnumber/leg:Addition">-3pt</xsl:when>
								<xsl:otherwise>0pt</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:if test="leg:Number/@PuncBefore!= ''">
							<xsl:value-of select="leg:Pnumber/@PuncBefore"/>
						</xsl:if>
						<xsl:apply-templates select="leg:Number/node() | processing-instruction()"/>
						<xsl:if test="leg:Number/@PuncAfter != ''">
							<xsl:value-of select="leg:Number/@PuncAfter"/>
						</xsl:if>
					</fo:block>						
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<xsl:apply-templates select="*[not(self::leg:Number)]"/>
				</fo:list-item-body>
			</fo:list-item>						
		</fo:list-block>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:EUPreamble/leg:Division/leg:Number" priority="50">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="leg:EUPreamble/leg:Division/leg:P" priority="10">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="leg:EUPreamble/leg:Division/leg:P/leg:Text" priority="50">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- the title elemnent in the preamble appears to just be a first paragraph so treat as such-->
	<xsl:template match="leg:EUPreamble/leg:Division/leg:Title" priority="20">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

















	<xsl:function name="tso:isProposedRepeal" as="xs:boolean">
		<xsl:param name="element" as="element()" />
		<xsl:variable name="firstTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][1]/ancestor::leg:Repeal[@Status = 'Proposed' and not(@SubstitutionRef)]" />
		<xsl:variable name="lastTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][last()]/ancestor::leg:Repeal[@Status = 'Proposed' and not(@SubstitutionRef)]" />
		<xsl:sequence select="exists($firstTextRepeal) and exists($lastTextRepeal) and $firstTextRepeal/@ChangeId = $lastTextRepeal/@ChangeId" />
	</xsl:function>
	
	<xsl:function name="tso:isSubstituted" as="xs:boolean">
		<xsl:param name="element" as="element()" />
		<xsl:variable name="firstTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][1]/ancestor::leg:Repeal[@SubstitutionRef]" />
		<xsl:variable name="lastTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][last()]/ancestor::leg:Repeal[@SubstitutionRef]" />
		<xsl:sequence select="exists($firstTextRepeal) and exists($lastTextRepeal) and $firstTextRepeal/@ChangeId = $lastTextRepeal/@ChangeId" />
	</xsl:function>
	
	
	<xsl:function name="tso:showCommentary" as="xs:boolean">
		<xsl:param name="commentaryRef" as="element()" />
		<xsl:variable name="fragment" select="$commentaryRef/ancestor::*[@RestrictStartDate or @RestrictEndDate or @Match or @Status][1]" />
		<xsl:variable name="isDead" as="xs:boolean" select="$fragment/@Status = 'Dead'" />
		<xsl:variable name="isValidFrom" as="xs:boolean" select="$fragment/@Match = 'false' and $fragment/@RestrictStartDate and ((($version castable as xs:date) and xs:date($fragment/@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date($fragment/@RestrictStartDate) &gt; current-date() ))" />
		<xsl:variable name="isRepealed" as="xs:boolean" select="$fragment/@Match = 'false' and (not($fragment/@Status) or $fragment/@Status != 'Prospective') and not($isValidFrom) and not($commentaryRef/ancestor::leg:EUPreamble)"/>
		<xsl:variable name="commentary" as="element(leg:Commentary)?" select="key('commentary', $commentaryRef/(@Ref | @CommentaryRef), $commentaryRef/root())" />
		<xsl:sequence select="tso:showCommentary($commentary, $isRepealed, $isDead)" />
	</xsl:function>

	<xsl:function name="tso:showCommentary" as="xs:boolean">
		<xsl:param name="commentary" as="element(leg:Commentary)?" />
		<xsl:param name="isRepealed" as="xs:boolean" />
		<xsl:param name="isDead" as="xs:boolean" />
		<xsl:sequence select="not($isRepealed) or ($isRepealed and contains($commentary, 'temp.')) or $isDead" />
	</xsl:function>
	
	<xsl:function name="tso:CalcHeadingLevel">
		<xsl:param name="ndsContext"/>
		<xsl:variable name="intHeadingCount" select="count($ndsContext/ancestor-or-self::*[self::leg:Group or self::leg:Part or self::leg:Chapter or self::leg:Pblock or self::leg:PsubBlock or self::leg:Schedule or self::leg:P1group or self::leg:P2group or self::leg:P3group or self::leg:Abstract or self::leg:Appendix or self::leg:ExplanatoryNotes or self::leg:EarlierOrders or self::leg:Tabular or self::leg:Figure or self::leg:Form])"/>
		<xsl:choose>
			<!-- Document level headings are going to start at 1 -->
			<xsl:when test="$intHeadingCount &lt; 6">
				<xsl:value-of select="$intHeadingCount + 1"/>
			</xsl:when>
			<xsl:otherwise>6</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="leg:abridgeContent">
		<xsl:param name="text" as="xs:string" />
		<xsl:param name="nWords" as="xs:integer" />
		<xsl:variable name="words" as="xs:string+" select="tokenize(normalize-space($text), '\s+')[position() &lt;= $nWords]" />
		<xsl:value-of select="string-join($words, ' ')" />
		<xsl:if test="count(tokenize(normalize-space($text), '\s+')) &gt; $nWords">
			<xsl:text>...</xsl:text>
		</xsl:if>	
	</xsl:function>
	
	<!-- Calculate the level of depth of indented text and output return value as Amendmentx where x is the depth (if greater than 1) -->
	<xsl:template name="FuncCalcAmendmentNo">
		<!-- If table is first ancestor before an amendment do not add amendment suffix -->
		<xsl:if test="not(ancestor::*[self::xhtml:table or self::leg:BlockAmendment or self::leg:BlockExtract][1][self::xhtml:table])">
			<xsl:call-template name="FuncGetPrimaryAmendmentContext"/>
			<xsl:choose>
				<!-- If we have amendments in a table that is itself in an amendment we need to drop the amendment level to 1 -->
				<xsl:when test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/ancestor::*[self::xhtml:table or self::leg:BlockAmendment or self::leg:BlockExtract][1][self::xhtml:table]">
					<xsl:text>Amend</xsl:text>
				</xsl:when>
				<!-- If we have nested amendments in a table that is itself in an amendment we need to drop the amendment level to 2 -->
				<xsl:when test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][2]/ancestor::*[self::xhtml:table or self::leg:BlockAmendment or self::leg:BlockExtract][1][self::xhtml:table]">
					<xsl:text>Amend2</xsl:text>
				</xsl:when>
				<xsl:when test="count(ancestor::leg:BlockAmendment) + count(ancestor::leg:BlockExtract) = 1">
					<xsl:text>Amend</xsl:text>
				</xsl:when>
				<xsl:when test="ancestor::leg:BlockAmendment or ancestor::leg:BlockExtract">
					<xsl:text>Amend</xsl:text>
					<xsl:value-of select="count(ancestor::leg:BlockAmendment) + count(ancestor::leg:BlockExtract)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- As amendments in primary legislation are dependent upon their parentage we need to do some checks and alter the CSS class if necessary -->
	<xsl:template name="FuncGetPrimaryAmendmentContext">
		<xsl:if test="$g_strDocClass = $g_strConstantEuretained">
				<xsl:for-each select="ancestor::leg:BlockAmendment">
					<xsl:choose>
						<xsl:when test="parent::leg:P3para or parent::leg:BlockText/parent::leg:P3para">C3</xsl:when>
						<xsl:when test="parent::leg:P4para or parent::leg:BlockText/parent::leg:P4para">C4</xsl:when>
						<xsl:when test="parent::leg:P5para or parent::leg:BlockText/parent::leg:P5para">C5</xsl:when>
						<xsl:when test="parent::leg:P6para or parent::leg:BlockText/parent::leg:P6para">C6</xsl:when>
						<xsl:when test="parent::leg:P7para or parent::leg:BlockText/parent::leg:P7para">C7</xsl:when>
						<!-- This shouldn't really happen but just in case! -->
						<xsl:when test="parent::leg:Para/parent::leg:ListItem">
							<xsl:text>C</xsl:text>
							<xsl:for-each select="parent::*/parent::*">
								<xsl:call-template name="FuncCalcListClass">
									<xsl:with-param name="flOutputPrefix" select="false()"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<!-- Level 1 and 2 are treated the same -->
						<xsl:when test="parent::leg:BlockAmendment or parent::leg:BlockText or parent::leg:P or parent::leg:Para or parent::leg:P1para or parent::leg:P2para or parent::leg:ScheduleBody or parent::leg:AppendixBody or parent::leg:Group or parent::leg:Part or parent::leg:Chapter or parent::leg:Pblock or parent::leg:PsubBlock">C1</xsl:when>
						<!-- Otherwise we haven't handled the situation so error -->
						<xsl:otherwise>
							<xsl:message terminate="yes">This document has an unhandled amendment context: <xsl:value-of select="name(parent::*)" /></xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>	
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="FuncCalcListClass">
	<xsl:param name="flOutputPrefix" select="true()"/>
	<xsl:variable name="intStartLevel">
		<xsl:call-template name="TSOcalculateListLevel"/>
	</xsl:variable>
	<xsl:variable name="intListAncestors">
		<xsl:call-template name="TSOgetListAncestors"/>
	</xsl:variable>
	<xsl:variable name="intCurrentLevel">
		<xsl:choose>
			<xsl:when test="number($intStartLevel) &lt; 0">
				<xsl:value-of select="number($intListAncestors) - number($intStartLevel)"/>
			</xsl:when>		
			<xsl:otherwise>
				<xsl:value-of select="number($intStartLevel) + number($intListAncestors)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="parent::leg:UnorderedList[@Decoration != 'none']">UL</xsl:if>
	<xsl:choose>
		<xsl:when test="number($intCurrentLevel) &gt; 0">
			<xsl:if test="$flOutputPrefix = true()">
				<xsl:text>LegLevel</xsl:text>
			</xsl:if>
			<xsl:value-of select="floor($intCurrentLevel)"/>
		</xsl:when>
		<xsl:otherwise>Unknown</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Calculate the level to convert list items to by working out the level of the top level list containing this list -->
<xsl:template name="TSOcalculateListLevel">
	<!-- Get ID of first blockamendment ancestor if there is one as we dont want list items outside the current amendment -->
	<xsl:variable name="intAmendmentAncestor" select="generate-id(ancestor::leg:BlockAmendment[1])"/>
	<xsl:variable name="ndsAncestors" select="ancestor::*[self::leg:OrderedList or self::leg:KeyList or self::leg:UnorderedList or self::leg:Formula or self::leg:BlockText][generate-id(ancestor::leg:BlockAmendment[1]) = $intAmendmentAncestor or $intAmendmentAncestor = ''][last()]"/>
	<!-- Get back to last ancestor that qualifies in the range of elements we are 'blocking' -->
	<xsl:choose>
		<xsl:when test="$ndsAncestors">
			<xsl:for-each select="$ndsAncestors">
				<xsl:call-template name="TSOgetListLevel"/>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="TSOgetListLevel"/>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="TSOgetListLevel">
	<xsl:choose>
		<xsl:when test="parent::xhtml:td or parent::xhtml:th">3</xsl:when>
		<xsl:when test="parent::leg:Para">3</xsl:when>
		<!--Chunyu:HA051074 Added an extra conditiion for EN see http://www.legislation.gov.uk/ukci/2010/5/note/sld/created		-->
		<xsl:when test="parent::leg:P and not(parent::leg:P/parent::leg:ExplanatoryNotes)">3</xsl:when>
		<xsl:when test="parent::leg:P1para">3</xsl:when>
		<xsl:when test="parent::leg:P2">3</xsl:when>
		<xsl:when test="parent::leg:P2para">3</xsl:when>
		<xsl:when test="parent::leg:P3">3</xsl:when>			
		<xsl:when test="parent::leg:P3para">4</xsl:when>
		<xsl:when test="parent::leg:P4">4</xsl:when>			
		<xsl:when test="parent::leg:P4para">5</xsl:when>
		<xsl:when test="parent::leg:P5">5</xsl:when>			
		<xsl:when test="parent::leg:P5para">6</xsl:when>
		<xsl:when test="parent::leg:P6">6</xsl:when>
		<xsl:when test="parent::leg:P6para">7</xsl:when>
		<xsl:when test="parent::leg:P7">7</xsl:when>
		<xsl:when test="parent::leg:P7para">8</xsl:when>
		<xsl:when test="parent::leg:BlockAmendment">3</xsl:when>
	</xsl:choose>
</xsl:template>

<!-- Work up the hierarchy to calculate the number of list ancestors but stop if we hit an amendment element. We'll treat BlockText the same as a list-->
<xsl:template name="TSOgetListAncestors">
	<xsl:param name="intCount" select="0"/>
	<xsl:choose>
		<xsl:when test="self::leg:BlockAmendment or not(parent::*)">
			<xsl:value-of select="$intCount"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="parent::*">
				<xsl:choose>
					<xsl:when test="self::leg:ListItem or self::leg:BlockText">
						<xsl:call-template name="TSOgetListAncestors">
							<xsl:with-param name="intCount" select="$intCount + 1"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="TSOgetListAncestors">
							<xsl:with-param name="intCount" select="$intCount"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


	<xsl:function name="leg:format-number-as-alpha">
		<xsl:param name="number" as="xs:decimal"/>	
		<xsl:value-of select="leg:format-number-as-alpha($number, ())"/>
	</xsl:function>
	
	<xsl:function name="leg:format-number-as-alpha">
		<xsl:param name="number" as="xs:decimal"/>
		<xsl:param name="case" as="xs:string?"/>
		<xsl:variable name="int" select="xs:integer(round($number))"/>
		<xsl:variable name="mod" select="$int mod 26"/>
		<xsl:variable name="times" select="xs:integer(floor($int div 26) +1)"/>
		<xsl:variable name="alpha" select="('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')"/>
		<xsl:variable name="numberstring" select="string-join((for $n in 1 to $times return $alpha[$mod]), '')"/>
		<xsl:value-of select="if ($case = ('upper', 'uppercase')) then upper-case($numberstring) else $numberstring"/>
	</xsl:function>
	
</xsl:stylesheet>