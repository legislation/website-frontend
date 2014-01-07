<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

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

	<xsl:import href="../html/statuswarning.xsl"/>

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
	
	<!-- check if there is a signatire block-->
	<xsl:variable name="signatureURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/signature' and @title='signature']/@href"/>
	
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
		<xsl:output-character character="&#x2FFF;" string="&#x201C;"/><!--left double quote-->
		<xsl:output-character character="&#x2FDD;" string="&#x201D;"/><!--right double quote-->
		<xsl:output-character character="&#x2015;" string="&#x2014;"/><!--emdash-->
		<xsl:output-character character="―" string="&#8212;"/><!--right double quote-->
	</xsl:character-map>

	<!-- these will not work for the PDF generation so not used -->
	<xsl:variable name="requestInfoDoc" select="if (doc-available('input:request-info')) then doc('input:request-info') else ()"/>

	<xsl:variable name="FOparamsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

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
	<xsl:variable name="g_strConstantDocumentStatusDraft" select="'draft'" as="xs:string"/>
	<xsl:variable name="g_strConstantOutputTypePrimary" select="'PrimaryStyle'" as="xs:string"/>
	<xsl:variable name="g_strConstantOutputTypeSecondary" select="'SecondaryStyle'" as="xs:string"/>
	<xsl:variable name="g_strConstantImagesPath" select="'http://www.legislation.gov.uk/images/crests/'" as="xs:string"/>
	
	
	<xsl:variable name="dcIdentifier" select="/leg:Legislation/ukm:Metadata/dc:identifier"/>
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
			if ($wholeActURI = $dcIdentifier) then /leg:Legislation
			else if ($dcIdentifier = ($introURI, $wholeActWithoutSchedulesURI)) then  /leg:Legislation/(leg:Primary | leg:Secondary)//*[@DocumentURI = $strCurrentURIs]
			else if ($dcIdentifier = $schedulesOnlyURI)  then /leg:Legislation/(leg:Primary | leg:Secondary)/leg:Schedules
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

	<xsl:variable name="g_ndsLegMetadata" select="/(leg:Legislation | leg:EN)/ukm:Metadata/(ukm:SecondaryMetadata | ukm:PrimaryMetadata | ukm:ENmetadata)"/>

	<xsl:variable name="g_ndsValidDate" select="/leg:Legislation/ukm:Metadata/dct:valid"/>
	<xsl:variable name="g_ndsLegPrelims" select="/leg:Legislation/(leg:Primary/leg:PrimaryPrelims | leg:Secondary/leg:SecondaryPrelims)"/>
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
					<dc:creator></dc:creator>
					<dc:description>
						<xsl:for-each select="leg:Legislation/ukm:Metadata/dc:subject">
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
			

			
			
			<xsl:if test="(/leg:Legislation/*/leg:Body | /leg:Legislation/*/leg:PrimaryPrelims  | /leg:Legislation/*/leg:SecondaryPrelims) and $g_view != 'contents' and not(/leg:Legislation/leg:Contents)">
				
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
								<fo:table-column column-width="20%"/>									
								<fo:table-column column-width="60%"/>
								<fo:table-column column-width="20%"/>
								<fo:table-body margin-left="0pt" margin-right="0pt">
									<fo:table-row border-bottom="solid 0.5pt black" border-top="solid 0.5pt black" >
										<fo:table-cell number-columns-spanned="3" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center"  text-align-last="center">
											<fo:block>
												<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
									<!-- #D456 we do not need monarch info on generated PDFs as this would be incorrect for pre-1953-->
									<!--<fo:table-row margin-left="0pt" margin-right="0pt">
										<fo:table-cell text-align="left" margin-left="0pt" margin-right="0pt">
											<fo:block font-family="{$g_strMainFont}">&#160;</fo:block>
										</fo:table-cell>
										<fo:table-cell text-align="center" margin-left="0pt" margin-right="0pt">
											<fo:block font-size="{$g_strHeaderSize}" font-family="Times" font-weight="bold">
												<xsl:text>ELIZABETH II</xsl:text>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
											<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}">
												<xsl:text>c. </xsl:text>
												<xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>-->
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
								<fo:table-column column-width="20%"/>
								<fo:table-column column-width="80%"/>									
								<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
									<fo:table-row margin-left="0pt" margin-right="0pt" border-bottom="solid 0.5pt black" >
										<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt">
											<fo:block font-family="{$g_strMainFont}">
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
									<fo:table-row>
										<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center" text-align-last="center">
											<fo:block>
												<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:static-content>			

						
							<fo:static-content flow-name="footer-only-before">
								<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
									<fo:table-column column-width="20%"/>
									<fo:table-column column-width="80%"/>									
									<fo:table-body border-bottom="solid 0.5pt black" border-top="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
										<fo:table-row>
											<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center"  text-align-last="center">
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
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<fo:table-column column-width="80%"/>									
								<fo:table-column column-width="20%"/>
								<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
									<fo:table-row margin-left="0pt" margin-right="0pt" border-bottom="solid 0.5pt black" >
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
									<fo:table-row>
										<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center"  text-align-last="center">
											<fo:block>
												<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:static-content>		
					</xsl:if>

					<xsl:if test="$g_strDocClass = $g_strConstantSecondary and $g_strDocType != 'NorthernIrelandAct'">
						<!-- Header for even pages -->
						
						<fo:static-content flow-name="even-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<fo:table-column column-width="20%"/>
								<fo:table-column column-width="80%"/>									
								<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
									<fo:table-row margin-left="0pt" margin-right="0pt" border-bottom="solid 0.5pt black" >
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
									<fo:table-row>
										<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center" >
											<fo:block>
												<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:static-content>			

						
							<fo:static-content flow-name="footer-only-before">
								<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
									<fo:table-column column-width="20%"/>
									<fo:table-column column-width="80%"/>									
									<fo:table-body border-bottom="solid 0.5pt black" border-top="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
										<fo:table-row>
											<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center" >
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
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<fo:table-column column-width="80%"/>									
								<fo:table-column column-width="20%"/>
								<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
									<fo:table-row margin-left="0pt" margin-right="0pt" border-bottom="solid 0.5pt black" >
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
									<fo:table-row>
										<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center" >
											<fo:block>
												<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
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
			<xsl:if test="/leg:Legislation/*/leg:Schedules or /leg:Legislation/leg:Secondary/leg:ExplanatoryNotes or /leg:Legislation/leg:Secondary/leg:EarlierOrders">
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
									<fo:table-column column-width="20%"/>
									<fo:table-column column-width="80%"/>
									<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
										<fo:table-row border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
											<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt">
												<fo:block font-family="{$g_strMainFont}">
													<fo:inline>
														<fo:page-number/>
													</fo:inline>
												</fo:block>
											</fo:table-cell>
											<fo:table-cell text-align="right" margin-left="0pt" margin-right="0pt">
												<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runninghead2"/>
												</fo:block>
												<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runningheadschedule"/>
												</fo:block>
												<!--<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runningheadpart"/>
												</fo:block>-->
												<xsl:call-template name="TSOdocDateTime"/>
											</fo:table-cell>
										</fo:table-row>
										<fo:table-row>
											<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center" >
												<fo:block>
													<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
							</fo:static-content>			
							<fo:static-content flow-name="odd-before">
								<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed" width="{$g_PageBodyWidth}pt">
									<fo:table-column column-width="80%"/>									
									<fo:table-column column-width="20%"/>
									<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
										<fo:table-row border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
											<fo:table-cell margin-left="0pt" margin-right="0pt">
												<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runninghead2"/>
												</fo:block>
												<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runningheadschedule"/>
												</fo:block>
												<!--<fo:block font-size="{$g_strHeaderSize}" font-family="{$g_strMainFont}" font-style="italic">
													<fo:retrieve-marker retrieve-class-name="runningheadpart"/>
												</fo:block>-->
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
										<fo:table-row>
											<fo:table-cell number-columns-spanned="2" margin-left="0pt" margin-right="0pt" margin-top="0pt" text-align="center" >
												<fo:block>
													<xsl:apply-templates select="$statusWarningHeader" mode="statuswarningHeader"/>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
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
									<fo:table-column column-width="20%"/>									
									<fo:table-column column-width="60%"/>
									<fo:table-column column-width="20%"/>
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell number-columns-spanned="3" text-align="right" margin-left="0pt" margin-right="0pt">
												<xsl:call-template name="TSOdocDateTime"/>
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
							<fo:static-content flow-name="even-before-first">
								<fo:table  margin-left="90pt" margin-right="90pt" margin-top="36pt" table-layout="fixed"  width="{$g_PageBodyWidth}pt">
									<fo:table-column column-width="20%"/>									
									<fo:table-column column-width="60%"/>
									<fo:table-column column-width="20%"/>
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell number-columns-spanned="3" text-align="right" margin-left="0pt" margin-right="0pt">
												<xsl:call-template name="TSOdocDateTime"/>
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
						<fo:table-cell number-columns-spanned="3" text-align="left" margin-left="0pt" margin-right="0pt">
							<xsl:call-template name="TSOdocDateTime"/>
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
						<fo:table-cell number-columns-spanned="3" text-align="left" margin-left="0pt" margin-right="0pt">
							<xsl:call-template name="TSOdocDateTime"/>
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


			<xsl:if test="$statusWarningHTML//xhtml:div[@id='statusWarning']">
				<fo:page-sequence master-reference="unapplied-effects-sequence"  xml:lang="{$g_documentLanguage}">
					<xsl:if test="$g_strDocClass != $g_strConstantSecondary">
						<!-- Header for even pages -->
						<fo:static-content flow-name="even-before">
							<fo:table margin-left="90pt" margin-right="90pt" margin-top="36pt"  table-layout="fixed" width="{$g_PageBodyWidth}pt">
								<fo:table-column column-width="20%"/>
								<fo:table-column column-width="80%"/>									
								<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
									<fo:table-row margin-left="0pt" margin-right="0pt" border-bottom="solid 0.5pt black" >
										<fo:table-cell font-size="10pt" margin-left="0pt" margin-right="0pt">
											<fo:block font-family="{$g_strMainFont}">
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
								<fo:table-column column-width="80%"/>									
								<fo:table-column column-width="20%"/>
								<fo:table-body border-bottom="solid 0.5pt black" margin-left="0pt" margin-right="0pt">
									<fo:table-row margin-left="0pt" margin-right="0pt" border-bottom="solid 0.5pt black" >
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

	<xsl:include href="legislation_schema_contents_FO.xslt"/>



	<xsl:template match="leg:Body  ">
		<fo:block id="StartOfContent"/>
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

	<!-- Adding Annotations for parent levels if the current section is dead/repeal -->
<xsl:template match="*" mode="showSectionWithAnnotation">
	<xsl:apply-templates select="."/>
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
	
	<xsl:template match="leg:Body" mode="TSOBreadcrumbItem" priority="20"/>	
	
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
	
	<xsl:template match="leg:PrimaryPrelims | leg:SecondaryPrelims" mode="TSOBreadcrumbItem" priority="5"/>

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
	<xsl:template match="leg:Schedule//leg:P1 | leg:PrimaryPrelims | leg:SecondaryPrelims | leg:P1group | leg:Schedule/leg:ScheduleBody//leg:Tabular" priority="400">
		<xsl:next-match/>
		<!-- If there are alternate versions outputting ot annotations will happen there -->
		<xsl:if test="not(@AltVersionRefs)">
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
	<xsl:template match="leg:P1group[not(ancestor::leg:BlockAmendment) and @Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and not(ancestor::leg:Contents)]/leg:Title" priority="60">
		<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
	</xsl:template>
	<!-- display Part, ScheduleBody/Tabular as dotted line if the section is repealed.  -->
	<xsl:template match="leg:ScheduleBody/leg:Tabular[exists(ancestor::*[@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective')])]" priority="60">
		<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
	</xsl:template>
	<xsl:template match="leg:ScheduleBody/leg:Part[exists(ancestor::*[@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective')])]" priority="60">
		<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
	</xsl:template>

		

	<!--#154 do not process wholly repealed legislation/parts or schedules -->
	<!--we also need to allow for any act that is to come into force sometime in the future - query the RestrictStartDate  -->
	<xsl:template match="leg:Part | leg:Body | leg:Schedules | leg:Pblock | leg:PsubBlock" priority="60">
		<xsl:choose>
			<xsl:when test="every $child in (leg:* except (leg:Number, leg:Title))
				satisfies (($child/@Match = 'false' and $child/@RestrictEndDate and not($child/@Status = 'Prospective')
				) or  ($child/@Match = 'false' and $child/@Status = 'Repealed'))">
				<xsl:apply-templates select="leg:Number | leg:Title" />
				<fo:block>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</fo:block>
				<xsl:apply-templates select="." mode="ProcessAnnotations"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match />
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
		<xsl:call-template name="FuncApplyVersions"/>
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
			<xsl:if test="ancestor-or-self::*/@RestrictExtent and  ($g_matchExtent = 'true' or parent::*/@Concurrent = 'true' or ancestor-or-self::*/@VersionReplacement) and not(ancestor::leg:BlockAmendment)">
				<xsl:copy-of select="tso:generateExtentInfo(.)"/>
			</xsl:if>
		</fo:block>
	</xsl:template>

	<xsl:template match="leg:Schedule[not($g_strDocClass = $g_strConstantSecondary)]//leg:P1group[not(ancestor::leg:BlockAmendment)]/leg:Title | leg:P1group[parent::leg:BlockAmendment[@TargetClass = 'primary' and @Context = 'schedule']]/leg:Title" priority="2">
		<fo:block font-size="{$g_strBodySize}" font-style="italic" text-align="left" keep-with-next="always">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>



	<xsl:template match="leg:P1[not(ancestor::leg:BlockAmendment)]" priority="3">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
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
							<xsl:if test="not(parent::leg:P1group/@Match = 'false' and parent::leg:P1group/@RestrictEndDate and not(parent::leg:P1group/@Status = 'Prospective') and not(ancestor::leg:Contents))">
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
	<xsl:template match="leg:Schedule//leg:P1[not(ancestor::leg:BlockAmendment[1][@Context = 'main' or @Context='unknown' or @Context = 'schedule'])]" priority="110">
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
			<xsl:otherwise>
				<fo:list-block provisional-label-separation="3pt" space-before="{$g_strLargeStandardParaGap}" provisional-distance-between-starts="42pt" start-indent="0pt">	
					<xsl:call-template name="TSO_p2"/>
				</fo:list-block>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:Schedule//leg:P2">
		<xsl:choose>
			<xsl:when test="$g_strDocClass = $g_strConstantSecondary">
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
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
				<xsl:text> – </xsl:text>
				<xsl:value-of select="leg:TitleBlock/leg:Title"/>
			</fo:marker>
			<xsl:if test="not(leg:ScheduleBody/leg:Part)">
				<fo:marker marker-class-name="runningheadpart">&#8203;</fo:marker>
			</xsl:if>
			<!--<fo:marker marker-class-name="SideBar">
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
			</fo:marker>	-->	
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
						   ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))) or (every $child in (leg:ScheduleBody/*)
				  satisfies (($child/@Match = 'false' and $child/@RestrictEndDate and not($child/@Status = 'Prospective')) and
						   ((($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= current-date() )))  or ($child/@Match = 'false' and $child/@Status = 'Repealed'))">
							  
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
				<xsl:text> – </xsl:text>
				<xsl:value-of select="following-sibling::leg:TitleBlock/leg:Title"/>
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
				<xsl:text> – </xsl:text>
				<xsl:value-of select="following-sibling::leg:TitleBlock/leg:Title"/>
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
								<xsl:apply-templates select="parent::leg:P3para/preceding-sibling::leg:Pnumber"/>
								<!-- FOP doesn't handle 2003 well - look for alternative -->
								<xsl:text>&#160;&#160;</xsl:text>
							</xsl:if>
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
			<xsl:otherwise>
				<fo:inline>[<xsl:value-of select="@Name"/>]</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:Emphasis">
		<xsl:choose>
			<!--  HA048129 Pblock titles should be left aligned and italic  -->
			<xsl:when test="self::*[not(ancestor::leg:Para)]/ancestor::xhtml:th[1][ancestor::xhtml:thead] (: or parent::leg:Title/parent::leg:Pblock :) or parent::leg:PersonName/parent::leg:Signee">
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
	</xsl:template>

	<xsl:template match="leg:Strong">
		<xsl:choose>
			<xsl:when test="parent::leg:Title/parent::leg:Tabular or parent::xhtml:th/parent::xhtml:tr/parent::xhtml:tbody or (parent::leg:Title/parent::leg:P1group and $g_strDocClass = $g_strConstantSecondary)">
				<fo:inline font-weight="normal">
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
				<fo:block font-weight="bold"  >
					<xsl:apply-templates/>
				</fo:block>
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

	<xsl:template match="leg:CitationSubRef">
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

	<xsl:template match="leg:Citation">
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

	<xsl:template match="leg:SignedSection">
		<fo:block font-size="{$g_strBodySize}" space-before="24pt">
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
								<xsl:attribute name="space-after">48pt</xsl:attribute>
							</xsl:if>
							<xsl:apply-templates/>
						</fo:block>
					</xsl:for-each>
				</xsl:if>
				<xsl:for-each select="leg:Signee">
					<xsl:variable name="lssealuri" select="leg:LSseal/@ResourceRef"/>
					<fo:table font-size="{$g_strBodySize}" table-layout="fixed" width="100%">
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
											<fo:external-graphic src='url("{//leg:Resource[@id = $lssealuri]/leg:ExternalVersion/@URI}")' fox:alt-text="Legal seal"/>
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
		<xsl:variable name="booTableRef" select="ancestor::xhtml:table and $strFootnoteRef = ancestor::xhtml:table/xhtml:tfoot//leg:Footnote/@id" as="xs:boolean"/>
		<xsl:choose>
			<xsl:when test="ancestor::*[self::leg:Footnote]">
				<xsl:number value="$intFootnoteNumber" format="1"/> 
			</xsl:when>
			<xsl:otherwise>
				<fo:footnote>
					<xsl:choose>
						<xsl:when test="$booTableRef = true()">
							<xsl:variable name="nstTableFootnoteRefs" select="ancestor::xhtml:table/xhtml:tfoot//leg:Footnote" as="element(leg:Footnote)*"/>
							<fo:inline font-weight="bold" baseline-shift="super" font-size="6pt">
								<xsl:value-of select="$nstTableFootnoteRefs[@id = $strFootnoteRef]/leg:Number"/>
							</fo:inline>
						</xsl:when>
						<xsl:otherwise>
							<fo:inline font-weight="bold">
								<fo:inline font-weight="normal">			
									<xsl:text>(</xsl:text>
								</fo:inline>
								<xsl:number value="$intFootnoteNumber" format="1"/>
								<fo:inline font-weight="normal">
									<xsl:text>)</xsl:text>
								</fo:inline>
							</fo:inline>
						</xsl:otherwise>
					</xsl:choose>	
					
					
					
					<fo:footnote-body>
						<fo:list-block start-indent="0pt" provisional-label-separation="6pt" provisional-distance-between-starts="18pt">
							<fo:list-item>
								<fo:list-item-label start-indent="0pt" end-indent="label-end()">
									<fo:block font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt" font-weight="bold">
										<fo:inline font-weight="normal"><xsl:text>(</xsl:text></fo:inline>
										<xsl:number value="$intFootnoteNumber" format="1"/>
										<fo:inline font-weight="normal"><xsl:text>)</xsl:text></fo:inline>
									</fo:block>
								</fo:list-item-label>
								<fo:list-item-body start-indent="body-start()">
									<fo:block font-size="8pt" line-height="9pt" text-indent="0pt" margin-left="0pt">
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
					<fo:block>
						<xsl:apply-templates/>
					</fo:block>
				</fo:block-container>
			</xsl:when>
	<!-- Chunyu 09/05/12: Added a condition for portrait dislay images see nisr/1996/447 -->
		<xsl:when test="@Orientation = 'portrait'">
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
				<!--<xsl:when test="contains(@Width, 'auto') or not(@Width)">
					<xsl:attribute name="max-width"><xsl:value-of select="$maxWidth"/>pt</xsl:attribute>
					<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
					<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
				</xsl:when>-->
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
				<fo:block space-before="6pt" space-after="6pt" text-align="left">
					<!-- old comment said "We'll assume here that there is only one version"
						This SHOULD be the case but bugs in augment.xsl caused duplciation if the version with 
						same ID if the same image was referrenced twice as is the case with HA052048 -->
					<xsl:apply-templates select="(//leg:Version[@id = current()/parent::*/@AltVersionRefs])[1]/*"/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:block space-before="6pt" space-after="6pt">
					<xsl:if test="contains(@style, 'font-weight: bold')">
						<xsl:attribute name="font-weight">bold</xsl:attribute>
					</xsl:if>
					<xsl:if test="contains(@style, 'text-align: center')">
						<xsl:attribute name="text-align">center</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates/>
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
		<fo:block>
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
		<!-- D455 we need to make sure the bracket is before the section number -->
		<xsl:variable name="showCommentary" as="xs:boolean" select="tso:showCommentary(.)" />
		<xsl:variable name="changeId" as="xs:string" select="@ChangeId" />
		<!-- showSection variable - this obviously working differently to html as it is not using the correct nodeset so we shall choose from where we are in the nodeset
		
		<xsl:variable name="showSection" as="node()"
		select="if (ancestor::*[@VersionReplacement]) then ancestor::*[@VersionReplacement] else 
		if (ancestor::leg:P1group[not(ancestor::leg:BlockAmendment)]) then ancestor::leg:P1group[not(ancestor::leg:BlockAmendment)][1]/.. else if (ancestor::leg:Body) then  ancestor::leg:Body else
		if (empty($showSection)) then root() else $showSection" />-->
		
		<xsl:variable name="showSection" as="node()"
		select="if (ancestor::*[@VersionReplacement]) then ancestor::*[@VersionReplacement] else if (exists($showSection) and ancestor-or-self::*[. is $showSection]) then $showSection else root()" />
		<xsl:variable name="sameChanges" as="element()*" select="key('additionRepealChanges', $changeId, $showSection)" />
		<xsl:variable name="firstChange" as="element()?" select="$sameChanges[1]" />
		<xsl:variable name="secondChange" as="element()?" select="$sameChanges[2]" />
		<xsl:variable name="lastChange" as="element()?" select="$sameChanges[last()]" />
		<xsl:variable name="isFirstChange" as="xs:boolean?">
			<xsl:choose>
				<xsl:when test="$g_strDocClass = $g_strConstantPrimary and ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group">
					<xsl:sequence select="$firstChange is (ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group//(leg:Addition|leg:Repeal|leg:Substitution))[1]" />
				</xsl:when>
				<xsl:when test="$g_strDocClass = $g_strConstantPrimary and ancestor::leg:Title/parent::leg:P1group">
					<xsl:sequence select="$firstChange is . and
						empty(ancestor::leg:Title/parent::leg:P1group/leg:P1[1]/leg:Pnumber//(leg:Addition|leg:Repeal|leg:Substitution)[@ChangeId = $changeId])" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$firstChange is ." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="ancestor::leg:Pnumber">
		
		</xsl:if>
		<xsl:if test="$showCommentary">
			<xsl:if test="$isFirstChange = true()">
				<fo:inline font-weight="bold">[</fo:inline>
			</xsl:if>
		</xsl:if>
		<!--<xsl:choose>
			<xsl:when test="($firstChange is parent::leg:Pnumber/parent::leg:P1/parent::leg:P1group/leg:Title/leg:Addition[1]) and $secondChange is .)">
				<fo:inline font-weight="bold">[</fo:inline>
			</xsl:when>
			
			<xsl:when test="parent::leg:Title/following-sibling::*[1]/leg:Pnumber/leg:Addition">
				
			</xsl:when>
			<xsl:when test="key('additionRepealChanges', @ChangeId)[1] is .">
				<fo:inline font-weight="bold">[</fo:inline>
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>-->
		
		<!--<xsl:if test="key('additionRepealChanges', @ChangeId)[1] is .">
			<fo:inline font-weight="bold">[</fo:inline>
		</xsl:if>-->
		<xsl:apply-templates select="." mode="AdditionRepealRefs"/>
		<xsl:variable name="changeType" as="xs:string">
			<xsl:choose>
				<xsl:when test="key('substituted', $changeId)">Substitution</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:inline>
			<xsl:choose>
				<xsl:when test="@Status = 'Proposed' and $changeType = 'Substitution'">
					<!--<xsl:attribute name="color">#FF4500</xsl:attribute>-->
					<xsl:attribute name="text-decoration">underline</xsl:attribute>										
				</xsl:when>
				<xsl:when test="@Status = 'Proposed' and $changeType = 'Repeal'">
					<!--<xsl:attribute name="color">#FF0000</xsl:attribute>-->
					<xsl:attribute name="text-decoration">line-through</xsl:attribute>
				</xsl:when>
				<xsl:when test="@Status = 'Proposed' and $changeType = 'Addition'">
					<!--<xsl:attribute name="color">#008000</xsl:attribute>-->
					<xsl:attribute name="text-decoration">underline</xsl:attribute>					
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates/>
		</fo:inline>
		<!--<xsl:if test="key('additionRepealChanges', @ChangeId)[last()] is .">
			<fo:inline font-weight="bold">]</fo:inline>
			</xsl:if>-->
		<xsl:if test="key('additionRepealChanges', @ChangeId, $showSection)[last()] is .">
			<fo:inline font-weight="bold">]</fo:inline>
		</xsl:if>
	</xsl:template>

	<!--<xsl:template match="leg:Repeal">
		<xsl:apply-templates select="." mode="AdditionRepealRefs"/>
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>-->

	<xsl:template match="leg:Addition | leg:Repeal | leg:Substitution" mode="AdditionRepealRefs">
		<xsl:param name="showSection" select="root()" tunnel="yes" />
		<xsl:if test="@CommentaryRef">
			<xsl:variable name="commentaryItem" select="key('commentary', @CommentaryRef)[1]" as="element(leg:Commentary)*"/>
	
			<xsl:if test="$commentaryItem/@Type = ('F', 'M', 'X')">
				<!-- The <Title> comes before the <Pnumber> in the XML, but appears after the <Pnumber> in the HTML display
				so the first commentary reference for the change is the one in the <Title> rather than the one in the <Pnumber>-->
				<xsl:variable name="changeId" as="xs:string" select="@ChangeId" />			
				<xsl:variable name="showSection" as="node()"
						select="if (ancestor::*[@VersionReplacement]) then ancestor::*[@VersionReplacement] else if (exists($showSection) and ancestor-or-self::*[. is $showSection]) then $showSection else root()" />
				
				<!--<xsl:variable name="sameChanges" as="element()*" select="key('commentaryRefInChange', concat(@CommentaryRef, '+', @ChangeId))" />-->
					<xsl:variable name="sameChanges" as="element()*" select="key('commentaryRefInChange', concat(@CommentaryRef, '+', @ChangeId), $showSection)" />
					<xsl:variable name="firstChange" as="element()?" select="$sameChanges[1]" />
				<xsl:variable name="isFirstChange" as="xs:boolean?">
					<xsl:choose>
						<xsl:when test="$g_strDocClass = $g_strConstantPrimary and ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group">
							<xsl:sequence select="$firstChange is (ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group//(leg:Addition|leg:Substitution))[1]" />
						</xsl:when>
						<xsl:when test="$g_strDocClass = $g_strConstantPrimary and ancestor::leg:Title/parent::leg:P1group">
							<xsl:sequence select="$firstChange is . and
								empty(ancestor::leg:Title/parent::leg:P1group/leg:P1[1]/leg:Pnumber//(leg:Addition|leg:Substitution)[@ChangeId = $changeId])" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="$firstChange is ." />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:if test="$isFirstChange = true()">
					<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReference][1]/@VersionReference"/>
					<xsl:sequence select="tso:OutputCommentaryRef(key('commentaryRef', @CommentaryRef)[1] is ., $commentaryItem,  translate($versionRef,' ',''))"/>
				</xsl:if>		
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- Make assumption here that comments have been filtered to only contain those relevant for content being viewed -->

	<!-- when commentarys are in version there can be identical id's - therefore we concatanate the version ref to these to make them unique -->

	<xsl:template match="leg:CommentaryRef">
		<xsl:variable name="commentaryItem" select="key('commentary', @Ref)[1]" as="element(leg:Commentary)?"/>
		<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReference][1]/@VersionReference"/>
		<xsl:if test="empty($commentaryItem)">
			<fo:inline font-weight="bold" color="red">No commentary item could be found for this reference <xsl:value-of select="@Ref"/>
			</fo:inline>
		</xsl:if>
		<xsl:if test="tso:showCommentary(.) and $commentaryItem/@Type = ('F', 'M', 'X') and key('commentaryRef', @Ref)[1] is .">
			<!-- in the rare event that the commentary item is not within the text we need to block it as in nisi/1993/1576/2006-01-01 -->
			<xsl:choose>
				<xsl:when test="not(ancestor::leg:Text or ancestor::leg:Pnumber or ancestor::leg:Title or ancestor::leg:Citation or ancestor::leg:CitationSubRef or ancestor::leg:CitationListRef or ancestor::leg:Addition or ancestor::leg:Repeal or ancestor::leg:Substitution)">
					<fo:block>
						<xsl:sequence select="tso:OutputCommentaryRef(key('commentaryRef', @Ref)[1] is ., $commentaryItem, translate($versionRef,' ',''))"/>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="tso:OutputCommentaryRef(key('commentaryRef', @Ref)[1] is ., $commentaryItem, translate($versionRef,' ',''))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

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
	
	<xsl:template match="leg:SignedSection">
		<xsl:apply-templates/>
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	</xsl:template>

	<xsl:template match="leg:ExplanatoryNotes">
		<xsl:apply-templates/>
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	</xsl:template>


	<!--<xsl:template match="leg:P1group | leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:P1 | leg:P| leg:PrimaryPrelims | leg:SecondaryPrelims | leg:Schedule | leg:Form | leg:Schedule/leg:ScheduleBody//leg:Tabular | leg:Body" mode="ProcessAnnotations"> -->
	<xsl:template match="leg:Primary | leg:Secondary | leg:Body | leg:Schedules | leg:SignedSection | leg:ExplanatoryNotes | leg:P1group | leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:P1 | leg:P |leg:PrimaryPrelims | leg:SecondaryPrelims | leg:Schedule | leg:Form | leg:Schedule/leg:ScheduleBody//leg:Tabular" mode="ProcessAnnotations">
		<xsl:param name="showSection" as="element()*" tunnel="yes" select="()" />
		<xsl:param name="showingHigherLevel" as="xs:boolean" tunnel="yes" select="false()"/>

		<xsl:variable name="showSection" as="node()"
		select="if (ancestor::*[@VersionReplacement]) then ancestor::*[@VersionReplacement] else if (exists($showSection) and ancestor-or-self::*[. is $showSection]) then $showSection else root()" />
		<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReference][1]/@VersionReference"/>
		<xsl:variable name="commentaryRefs" as="element(leg:CommentaryRef)*">
			<xsl:choose>
			<!--HA053652: annotations in tables are repeated if table is child of P1 (annotations also processed for all descendants of P1) so condition added to exclude these tables-->
				<xsl:when test="ancestor::leg:BlockAmendment  and (self::leg:P1group | self::leg:P1[not(parent::leg:P1group)] | self::leg:PrimaryPrelims | self::leg:SecondaryPrelims | self::leg:Tabular[not(parent::leg:P1)])">
					<xsl:sequence select="descendant::leg:CommentaryRef"/>
				</xsl:when>
			<!--HA053652: annotations in tables are repeated if table is child of P1 (annotations also processed for all descendants of P1) so condition added to exclude these tables-->
				<xsl:when test="self::leg:P1group | self::leg:P1[not(parent::leg:P1group)] | self::leg:PrimaryPrelims | self::leg:SecondaryPrelims | self::leg:Tabular[not(parent::leg:P1)]">
					<xsl:sequence select="descendant::leg:CommentaryRef[not(ancestor::leg:BlockAmendment//leg:P1group or ancestor::leg:BlockAmendment//leg:P1)]"/>
				</xsl:when>
				<xsl:when test="self::leg:P and (@id or parent::*[@id] or parent::leg:Body)">
					<xsl:sequence select="descendant::leg:CommentaryRef[not(ancestor::leg:P1group)]"/>
				</xsl:when>
			<!--HA053652: annotations in tables are repeated if table is child of P1 (annotations also processed for all descendants of P1) so condition added to exclude these tables-->
				<xsl:when test="self::leg:Tabular[not(parent::leg:P1)] and (parent::*[@id] or parent::leg:Body)">
					<xsl:sequence select="descendant::leg:CommentaryRef" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="leg:Text/leg:CommentaryRef | child::leg:CommentaryRef | (leg:Number | leg:Title | leg:Reference | leg:TitleBlock)/descendant::leg:CommentaryRef"/>
				</xsl:otherwise>	
			</xsl:choose>			
		</xsl:variable>

		<xsl:variable name="additionRepealRefs" as="element()*">
			<xsl:choose>
			<!--HA053652: annotations in tables are repeated if table is child of P1 (annotations also processed for all descendants of P1) so condition added to exclude these tables-->
				<xsl:when test="ancestor::leg:BlockAmendment  and (self::leg:P1group | self::leg:P1[not(parent::leg:P1group)] | self::leg:PrimaryPrelims | self::leg:SecondaryPrelims | self::leg:Tabular[not(parent::leg:P1)])">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>
				<xsl:when test="self::leg:P1group | self::leg:P1[not(parent::leg:P1group)] | self::leg:PrimaryPrelims | self::leg:SecondaryPrelims">
					<xsl:sequence select="descendant::leg:Addition[not(ancestor::leg:BlockAmendment//leg:P1group or ancestor::leg:BlockAmendment//leg:P1)] | descendant::leg:Repeal[not(ancestor::leg:BlockAmendment//leg:P1group or ancestor::leg:BlockAmendment//leg:P1)] | descendant::leg:Substitution[not(ancestor::leg:BlockAmendment//leg:P1group or ancestor::leg:BlockAmendment//leg:P1)]"/>
				</xsl:when>
				<!--<xsl:when test="self::leg:P and (parent::leg:Part | parent::leg:Body)">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>-->
				<xsl:when test="self::leg:P and (@id or parent::*[@id] or parent::leg:Body or parent::leg:Schedules)">
					<xsl:sequence select="descendant::leg:Addition[not(ancestor::leg:P1group)] | descendant::leg:Repeal[not(ancestor::leg:P1group)] | descendant::leg:Substitution[not(ancestor::leg:P1group)]"/>
				</xsl:when>
			<!--HA053652: annotations in tables are repeated if table is child of P1 (annotations also processed for all descendants of P1) so condition added to exclude these tables-->
				<xsl:when test="self::leg:Tabular[not(parent::leg:P1)] and (parent::*[@id] or parent::leg:Body or parent::leg:Schedules)">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="leg:Text/leg:Addition | leg:Text/leg:Repeal | leg:Text/leg:Substitution | (leg:Number | leg:Title | leg:Reference | leg:TitleBlock)/(descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution)"/>
				</xsl:otherwise>	
			</xsl:choose>			
		</xsl:variable>
		<xsl:variable name="commentaryItem" select="key('commentary', ($commentaryRefs/@Ref, $additionRepealRefs/@CommentaryRef))" as="element(leg:Commentary)*"/>
		<xsl:variable name="currentURI">
			<xsl:choose>
				<xsl:when test="@DocumentURI"><xsl:value-of select="@DocumentURI"/></xsl:when>
				<xsl:when test="self::leg:Body"><xsl:value-of select="/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/body']/@href" /></xsl:when>
				<xsl:when test="self::leg:Schedules"><xsl:value-of select="/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/schedules']/@href" /></xsl:when>
				<xsl:when test="parent::leg:SignedSection"><xsl:value-of select="/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/signature']/@href" /></xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="descendant::*[@DocumentURI][1]/@DocumentURI"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		
		
		<xsl:variable name="isDead" as="xs:boolean" select="@Status = 'Dead'" />
		<xsl:variable name="isValidFrom" as="xs:boolean" select="@Match = 'false' and @RestrictStartDate and ((($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; current-date() ))" />
		<xsl:variable name="isRepealed" as="xs:boolean" select="@Match = 'false' and (not(@Status) or @Status != 'Prospective') and not($isValidFrom)"/>
		<!-- We need to check if the first reference to the comment falls within this structure. Do this for each comment in the list -->
		<xsl:variable name="showComments" as="element(leg:Commentary)*">
			<xsl:for-each select="$commentaryItem">
				<xsl:if test="$showingHigherLevel or not($isRepealed) or ($isRepealed and contains(., 'temp.')) or $isDead">
					<xsl:if test="key('commentaryRef', @id, $showSection)[1] intersect ($commentaryRefs | $additionRepealRefs)">
						<xsl:sequence select="."/>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- FM:  Issue 195: Only the f-notes should be pulled into the child fragments from the parent-->
		<xsl:variable name="showComments" as="element(leg:Commentary)*"
			select="$showComments[not($showingHigherLevel) or ($showingHigherLevel and @Type ='F')]" />

		<xsl:variable name="higherLevelComments">
			<xsl:if test="$dcIdentifier = $currentURI and $isRepealed">
				<!-- if the current section is dead then get the commenteries of all the higher levels-->
				<xsl:apply-templates select="ancestor::*" mode="ProcessAnnotations">
					<xsl:with-param name="showingHigherLevel" select="true()" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:if>	
		</xsl:variable>
		
		
		<xsl:if test="$showComments or $higherLevelComments/*">
			<fo:block  margin-left="0pt" margin-right="0pt" font-size="10pt" border="0.75pt #c7c7c7 solid" padding="6pt" color="black" space-before="8pt"   >
				<xsl:choose>
					<xsl:when test="$showingHigherLevel">

					</xsl:when>
					<xsl:otherwise>
						<fo:block font-weight="bold" font-size="10pt" keep-with-next="always">Annotations:</fo:block>
						<xsl:copy-of select="$higherLevelComments"/>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:if test="not($higherLevelComments/*)">
				
					<xsl:variable name="documentType" select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>
					<xsl:variable name="documentYear" select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value"/>

					<xsl:for-each-group select="$showComments" group-by="@Type">
						<xsl:sort select="@Type = 'M'"/>			
						<xsl:sort select="@Type = 'I'"/>
						<xsl:sort select="@Type = 'C'"/>
						<xsl:sort select="@Type = 'F'"/>
						<xsl:variable name="groupType" select="current-grouping-key()"/>

						<!-- FM:  Issue 364: In NI legislation before 1.1.2006 - f-notes are used across the board i.e. not just for textual amendments. Removing the annotation heading for textual texts --> 
						<xsl:if test="not($documentType = ('NorthernIrelandAct' , 'NorthernIrelandOrderInCouncil' , 'NorthernIrelandStatutoryRule', 'NorthernIrelandAssemblyMeasure', 'NorthernIrelandParliamentAct') and $documentYear &lt; 2006 and $groupType = 'F' )">
							<fo:block font-weight="bold"  padding-top="6pt" border-top="0.75pt #c7c7c7 dotted"  space-before="6pt" keep-with-next="always">
								<xsl:if test="$showingHigherLevel">Associated </xsl:if>
								<xsl:choose>
									<xsl:when test="$groupType = 'I'">Commencement Information</xsl:when>
									<xsl:when test="$groupType = 'F'">Amendments (Textual)</xsl:when>
									<xsl:when test="$groupType = 'M'">Marginal Citations</xsl:when>		
									<xsl:when test="$groupType = 'C'">Modifications etc. (not altering text)</xsl:when>
									<xsl:when test="$groupType = 'P'">Subordinate Legislation Made</xsl:when>
									<xsl:when test="$groupType = 'E'">Extent Information</xsl:when>
									<xsl:when test="$groupType = 'X'">Editorial Information</xsl:when>
								</xsl:choose>				
							</fo:block>
						</xsl:if>
						<xsl:apply-templates select="current-group()" mode="DisplayAnnotations">
							<xsl:sort select="tso:commentaryNumber(@id)" />
							<xsl:with-param name="versionRef" select="$versionRef"/>
						</xsl:apply-templates>
					</xsl:for-each-group>
				</xsl:if>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:function name="tso:commentaryNumber" as="xs:integer">
		<xsl:param name="commentary" as="xs:string" />
		<xsl:sequence select="count($g_commentaryOrder/leg:commentary[@id = $commentary][1]/preceding-sibling::*)" />
	</xsl:function>
		
	<xsl:template match="*" mode="ProcessAnnotations"/>
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

	<xsl:template match="leg:PrimaryPrelims | leg:SecondaryPrelims" priority="100">
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

	<xsl:function name="tso:generateExtentInfo" as="element(fo:inline)">
		<xsl:param name="element" as="node()" />
		<fo:inline color="white" background-color="rgb(102,0,102)" padding-top="3pt" padding-bottom="1pt" padding-left="5pt" padding-right="5pt" >
			<!--<xsl:text> [</xsl:text>-->
			<xsl:value-of select="$element/ancestor-or-self::*[@RestrictExtent][1]/@RestrictExtent"/>
			<!--<xsl:text>]</xsl:text>-->
		</fo:inline>
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
		<xsl:variable name="isRepealed" as="xs:boolean" select="$fragment/@Match = 'false' and (not($fragment/@Status) or $fragment/@Status != 'Prospective') and not($isValidFrom)"/>
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
	
	
</xsl:stylesheet>