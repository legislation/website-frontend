<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!--
	
	0.1			Griff Chamberlain	
	
	
-->



<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
xmlns="http://www.w3.org/1999/xhtml" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:xhtml="http://www.w3.org/1999/xhtml" 
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" 
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"  
xmlns:math="http://www.w3.org/1998/Math/MathML" 
xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
xmlns:dc="http://purl.org/dc/elements/1.1/" 
xmlns:fo="http://www.w3.org/1999/XSL/Format" 
xmlns:svg="http://www.w3.org/2000/svg" 
xmlns:lnk="http://www.tso.co.uk/assets/namespace/leglink"
exclude-result-prefixes="leg ukm math msxsl dc ukm fo xsl svg xhtml lnk">


	<!-- ========== Global variables ========== -->

	<!-- Self-reference to document being processed -->
	<xsl:variable name="g_ndsMainDoc" select="."/>

	<!-- Store metadata -->
	<xsl:variable name="g_ndsMetadata" select="/leg:EN/ukm:Metadata"/>


	<xsl:key name="g_keyENRefs" match="lnk:Link" use="lnk:ENref/@Ref"/>
	<xsl:key name="g_keyENCiteRefs" match="lnk:Link" use="lnk:ENref/@citeRef"/>

	<!-- Document main type -->
	<xsl:variable name="g_strDocumentMainType" select="$g_ndsMetadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentMainType[parent::ukm:DocumentClassification]/@Value"/>

	<!-- Document type. For NI acts they are treated as secondary for the body of the document -->
	<xsl:variable name="g_strDocumentType">
		<xsl:choose>
			<xsl:when test="$g_strDocumentMainType = 'NorthernIrelandAct'">secondary</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$g_ndsMetadata/ukm:ENmetadata/ukm:DocumentClassification/ukm:DocumentCategory/@Value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- Store footnotes -->
	<xsl:variable name="g_ndsFootnotes" select="//leg:Footnote"/>

	<!-- Store resources -->
	<xsl:variable name="g_ndsResources" select="//leg:Resource | //leg:ResourceGroup"/>

	<!-- Store margin notes -->

	<!-- Store versions -->
	<xsl:variable name="g_ndsVersions" select="/leg:EN/leg:Versions/leg:Version"/>

	<!-- Index all elements by any id -->
	<xsl:key name="g_keyNodeIDs" match="*[@id != '']" use="@id"/>


	<!-- ========== Global constants ========== -->

	<xsl:variable name="g_strPrimary" select="'primary'"/>

	<xsl:variable name="g_strSecondary" select="'secondary'"/>


	<!-- ========== Global parameters ========== -->

	<!-- By setting this to true, image filename extensions will be converted to standard web values -->
	<xsl:param name="g_flConvertImageExtensions" select="true()"/>


	<!-- ========== Include any code from other modules ========== -->

	<!-- Mathematics module -->
	<xsl:include href="legislation_xhtml_mathematics.xslt"/>

	<!-- Unicode module - converts unicode characters which are known NOT to render correctly get replaced with its corresponding image. -->
	<xsl:include href="legislation_xhtml_convertunicodetoimage.xslt"/>

	<!-- Include the utilities - date functions stylesheet. -->
	<xsl:include href="legislation_xhtml_utilities_dates.xslt"/>


	<!-- ========== Main code ========== -->

	<xsl:template match="/">

		<xsl:if test="not($g_ndsLegisConfigDoc//path[@type='images'])">
			<xsl:message terminate="yes">Configuration file is missing images path</xsl:message>
		</xsl:if>
		<xsl:if test="not($g_ndsLegisConfigDoc//path[@type='CSS'])">
			<xsl:message terminate="yes">Configuration file is missing CSS path</xsl:message>
		</xsl:if>
		<xsl:for-each select="$g_ndsTemplateDoc">
			<xsl:apply-templates/>
		</xsl:for-each>
	</xsl:template>

	<!-- Replace template title with document title -->
	<xsl:template match="xhtml:head/xhtml:title">
		<title>
			<!-- Set language to Welsh if necessary -->
			<xsl:if test="$g_ndsMetadata/dc:language = 'cy'">
				<xsl:attribute name="lang">cy</xsl:attribute>
				<xsl:attribute name="xml:lang">cy</xsl:attribute>
			</xsl:if>	
			<xsl:value-of select="$g_ndsMainDoc/leg:EN/leg:ExplanatoryNotes/leg:ENprelims/leg:Title"/>
			<xsl:choose>
				<xsl:when test="$g_strDocumentType = $g_strSecondary or $g_strDocumentMainType = 'UnitedKingdomChurchMeasure'"> No. </xsl:when>
				<xsl:when test="$g_strDocumentMainType = 'ScottishAct'"> (asp </xsl:when>
				<xsl:when test="$g_strDocumentMainType = 'WelshAssemblyMeasure'">
					<xsl:text> (</xsl:text>
					<xsl:choose>
						<xsl:when test="$g_ndsMetadata/dc:language = 'cy'">mccc</xsl:when>
						<xsl:otherwise>nawm</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$g_strDocumentMainType = 'WelshNationalAssemblyAct'">
					<xsl:text> (</xsl:text>
					<xsl:choose>
						<xsl:when test="$g_ndsMetadata/dc:language = 'cy'">dccc</xsl:when>
						<xsl:otherwise>anaw</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>(c. </xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$g_ndsMetadata/ukm:ENmetadata/ukm:Number/@Value"/>
			<xsl:choose>
				<xsl:when test="$g_strDocumentType = $g_strSecondary or $g_strDocumentMainType = 'UnitedKingdomChurchMeasure'"/>
				<xsl:otherwise>)</xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="$g_ndsMetadata/ukm:SecondaryMetadata/ukm:AlternativeNumber">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="@Category"/>
				<xsl:text>. </xsl:text>
				<xsl:value-of select="@Value"/>
				<xsl:text>)</xsl:text>
			</xsl:for-each>
			<xsl:text> - </xsl:text>
			<xsl:choose>
				<xsl:when test="$g_ndsMetadata/dc:language = 'cy'">Nodyn Esboniadol</xsl:when>
				<xsl:when test="$g_strDocumentType = $g_strSecondary">Explanatory Memorandum</xsl:when>
				<xsl:otherwise>Explanatory Notes</xsl:otherwise>
			</xsl:choose>
		</title>

	</xsl:template>

	<xsl:template match="xhtml:include">
		<div class="DocContainer">
			<!-- Set language to Welsh if necessary -->
			<xsl:if test="$g_ndsMetadata/dc:language = 'cy'">
				<xsl:attribute name="lang">cy</xsl:attribute>
				<xsl:attribute name="xml:lang">cy</xsl:attribute>
			</xsl:if>	
			<xsl:for-each select="$g_ndsMainDoc">
				<xsl:apply-templates/>
			</xsl:for-each>
		</div>

	</xsl:template>

	<!-- Add in appropriate CSS file  -->
	<xsl:template match="xhtml:style">
		<style type="text/css" media="screen, print">
			<xsl:copy-of select="node()"/>

			<xsl:text>@import "</xsl:text>
			<xsl:value-of select="$g_strStylesPath"/>
			<xsl:text>explanatoryNotes.css";</xsl:text>
		</style>
	</xsl:template>

	<xsl:template match="ukm:*"/>


	<!-- ========== Preliminary matter ========== -->

	<xsl:template match="leg:ENprelims">

		<div class="ENClearFix ENPrelims">

			<xsl:call-template name="FuncOutputENPrelimsPreContents"/>
			<!--<xsl:call-template name="FuncOutputContents"/>	-->
			<xsl:apply-templates select="//leg:EN/leg:Contents"/>		
			<xsl:call-template name="FuncOutputENPrelimsPostContents"/>
		</div>

		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:ENprelims/leg:Title">
		<xsl:variable name="strFilenameExtension">
			<xsl:if test="$g_ndsLegisConfigDoc//usecontentnegotiation/@value != 'yes'">.gif</xsl:if>
		</xsl:variable>
		<!--<xsl:choose>
		<xsl:when test="$g_strDocumentMainType = 'ScottishAct'">
			<img src="{$g_strImagesPath}scottishroyalarm{$strFilenameExtension}" alt="Royal arms" title="Royal arms" width="150" height="133"/>
		</xsl:when>
		<xsl:when test="$g_strDocumentMainType = 'WelshAssemblyMeasure'">
			<img src="{$g_strImagesPath}welshroyalarm{$strFilenameExtension}" alt="Welsh Royal arms" title="Welsh Royal arms" width="147" height="188"/>
		</xsl:when>
		<xsl:otherwise>
			<img src="{$g_strImagesPath}royalarm{$strFilenameExtension}" alt="Royal arms" title="Royal arms" width="156" height="128"/>
		</xsl:otherwise>
	</xsl:choose>-->


		<xsl:element name="h1">
			<xsl:attribute name="class">ENTitle</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$g_ndsMetadata/dc:language = 'cy'">Nodyn Esboniadol</xsl:when>
				<xsl:when test="$g_strDocumentType = $g_strSecondary">Explanatory Memorandum</xsl:when>
				<xsl:otherwise>Explanatory Notes</xsl:otherwise>
			</xsl:choose>
		</xsl:element>


		<h2 class="ENTitle">
			<xsl:apply-templates/>
		</h2>

		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>



	<xsl:template match="leg:ENprelims/leg:DateOfEnactment">
		<xsl:param name="strSuffix"/>
		<p class="ENDateOfEnactment{$strSuffix}">
			<xsl:apply-templates select="leg:DateText/node()"/>
		</p>

		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template name="FuncOutputENPrelimsPreContents">
		<xsl:apply-templates select="leg:Title"/>
		<h2 class="ENNo">
			<!-- PG 2008-07-18 Welsh Measures, and indeed most new legislation, has all the info we need in the Number element, 
			so we can just output that
		-->
			<xsl:choose>
				<xsl:when test="$g_strDocumentMainType = 'WelshAssemblyMeasure' ">
					<xsl:value-of select="leg:Number"/>
				</xsl:when>
				<xsl:when test="$g_strDocumentMainType = 'WelshNationalAssemblyAct' ">
					<xsl:value-of select="leg:Number"/>
				</xsl:when>
				<!-- Convoluted approach to outputting the correct act number, but probably required for legacy data -->
				<xsl:otherwise>
					<xsl:variable name="year" select="$g_ndsMetadata/ukm:ENmetadata/ukm:Year/@Value"/>
					<xsl:value-of select="$year"/>
					<xsl:choose>
						<xsl:when test="$g_strDocumentMainType = 'UnitedKingdomChurchMeasure' or $g_strDocumentMainType = 'NorthernIrelandOrderInCouncil' ">
							<xsl:text> No. </xsl:text>
						</xsl:when>
						<xsl:when test="$g_strDocumentMainType = 'ScottishAct'">
							<xsl:choose>
								<xsl:when test="if ($year castable as xs:integer) then xs:integer($year) &lt; 1800 else false()">
									<span class="ENNoASP"> c. </span>
								</xsl:when>
								<xsl:otherwise>
									<span class="ENNoASP"> asp </span>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!--issue 161 we need to format old scottish acts to c. -->
						<xsl:when test="$g_strDocumentMainType = 'ScottishOldAct'">
							<span class="ENNoASP"> c. </span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> CHAPTER </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$g_strDocumentMainType = 'UnitedKingdomLocalAct'">
							<xsl:number format="i" value="$g_ndsMetadata/ukm:ENmetadata/ukm:Number/@Value"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$g_ndsMetadata/ukm:ENmetadata/ukm:Number/@Value"/>
						</xsl:otherwise>
					</xsl:choose>
					<!-- Output Regnal year too if there is one -->
					<xsl:for-each select="$g_ndsMetadata/ukm:ENmetadata/ukm:AlternativeNumber">
						<xsl:if test="@Category = 'Regnal'">
							<xsl:text/>
							<xsl:value-of select="@Value"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>	
		</h2>

	</xsl:template>


	<xsl:template name="FuncOutputENPrelimsPostContents">
		<xsl:apply-templates select="leg:DateOfEnactment"/>
	</xsl:template>








	<!-- ========== TOCs ========== -->


<!-- ========== TOCs ========== -->

<xsl:template match="leg:Contents">
	<div class="ENContents LegClearFix">
		<xsl:call-template name="FuncTocListContents"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<!--
<xsl:template match="leg:BlockAmendment/*[self::leg:ContentsSchedules or self::leg:ContentsSchedule or self::leg:ContentsPart or self::leg:ContentsChapter or self::leg:ContentsPblock or self::leg:ContentsPsubBlock or self::leg:ContentsAppendix or self::leg:ContentsGroup]">
	<div class="ENContents LegClearFix">
		<ol>
			<xsl:choose>
				<xsl:when test="self::leg:ContentsAnnexes">
					<xsl:call-template name="FuncContentsAnnexes"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsSchedule">
					<xsl:call-template name="FuncContentsAnnex"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsPart">
					<xsl:call-template name="FuncContentsPart"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsChapter">
					<xsl:call-template name="FuncContentsChapter"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsPblock">
					<xsl:call-template name="FuncContentsPblock"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsPsubBlock">
					<xsl:call-template name="FuncContentsPsubBlock"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsGroup">
					<xsl:call-template name="FuncContentsDivision"/>
				</xsl:when>
			</xsl:choose>
		</ol>
	</div>
</xsl:template>
-->


<xsl:template match="leg:ContentsAnnexes" name="FuncContentsAnnexes">
	<li class="LegClearFix ENContentsAnnexes">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template name="FuncTocListContents">
	<xsl:apply-templates select="leg:ContentsNumber | leg:ContentsTitle | processing-instruction()[following-sibling::leg:ContentsNumber or following-sibling::leg:ContentsTitle]"/>
	<xsl:if test="node()[(self::* or self::processing-instruction()) and not(self::leg:ContentsNumber | self::leg:ContentsTitle) and not(self::processing-instruction()[following-sibling::leg:ContentsNumber or following-sibling::leg:ContentsTitle])]">
		<ol>
			<xsl:for-each select="node()[not(self::leg:ContentsNumber | self::leg:ContentsTitle) and not(self::processing-instruction()[following-sibling::leg:ContentsNumber or following-sibling::leg:ContentsTitle])]">
				<xsl:choose>
					<xsl:when test="self::leg:ContentsItem">
						<li class="ENContentsEntry">
							<xsl:apply-templates select="."/>
						</li>			
					</xsl:when>
					<xsl:when test="self::text()[normalize-space() = '']"/>
					<xsl:otherwise>
						<xsl:apply-templates select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</ol>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:ContentsAnnex" name="FuncContentsAnnex">
	<li class="LegClearFix ENContentsAnnex">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<xsl:template match="leg:ContentsDivision" name="FuncContentsDivision">
	<li class="LegClearFix ENContentsDivision">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsSubDivision" name="FuncContentsSubDivision">
	<li class="LegClearFix ENContentsSubDivision">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsSubSubDivision" name="FuncContentsSubSubDivision">
	<li class="LegClearFix ENContentsSubSubDivision">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsSubSubSubDivision" name="FuncContentsSubSubSubDivision">
	<li class="LegClearFix ENContentsSubSubSubDivision">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>









<xsl:template match="leg:ContentsCommentaryGroup" name="FuncContentsCommentaryGroup">
	<li class="LegClearFix ENContentsCommentaryGroup">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsCommentaryPart" name="FuncContentsCommentaryPart">
	<li class="LegClearFix ENContentsCommentaryPart">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsCommentaryChapter" name="FuncContentsCommentaryChapter">
	<li class="LegClearFix ENContentsCommentaryChapter">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsCommentaryP1" name="FuncContentsCommentaryP1">
	<li class="LegClearFix ENContentsCommentaryP1">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsCommentarySchedule" name="FuncContentsCommentarySchedule">
	<li class="LegClearFix ENContentsCommentarySchedule">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsCommentaryDivision" name="FuncContentsCommentaryDivision">
	<li class="LegClearFix ENContentsCommentaryDivision">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsCommentarySubDivision" name="FuncContentsCommentarySubDivision">
	<li class="LegClearFix ContentsCommentarySubDivision">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>





<xsl:template match="leg:ContentsItem/leg:ContentsNumber">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<span class="LegDS {concat('LegContentsNo', $strAmendmentSuffix)}">
		<xsl:choose>
			<xsl:when test="parent::*/@ContentRef">
				<xsl:variable name="strIDref" select="parent::*/@ContentRef"/>
				<xsl:variable name="strID">
					<xsl:for-each select="key('g_keyNodeIDs', $strIDref)">
						<xsl:call-template name="FuncGenerateAnchorID"/>
					</xsl:for-each>
				</xsl:variable>
				<a href="#{$strID}">
					<xsl:apply-templates/>
					<xsl:if test="parent::leg:ContentsItem and translate(., ' &#160;', '') != ''">
						<xsl:text>.</xsl:text>
					</xsl:if>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
				<xsl:if test="parent::leg:ContentsItem and translate(., '&#160; ', '') != ''">
					<xsl:text>.</xsl:text>
				</xsl:if>				
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>

<xsl:template match="leg:ContentsNumber">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<p class="{concat('LegContentsNo', $strAmendmentSuffix)}">
		<xsl:choose>
			<xsl:when test="parent::*/@ContentRef">
				<xsl:variable name="strIDref" select="parent::*/@ContentRef"/>
				<xsl:variable name="strID">
					<xsl:for-each select="key('g_keyNodeIDs', $strIDref)">
						<xsl:call-template name="FuncGenerateAnchorID"/>
					</xsl:for-each>
				</xsl:variable>
				<a href="#{$strID}">
					<xsl:apply-templates/>
					<xsl:if test="parent::leg:ContentsItem and translate(., ' &#160;', '') != ''">
						<xsl:text>.</xsl:text>
					</xsl:if>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
				<xsl:if test="parent::leg:ContentsItem and translate(., ' &#160;', '') != ''">
					<xsl:text>.</xsl:text>
				</xsl:if>				
			</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

<xsl:template match="leg:Contents/leg:ContentsTitle">
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<h2>
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="ancestor::leg:Schedule">LegScheduleContentsHeading</xsl:when>
				<xsl:otherwise>ENContentsHeading</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$strAmendmentSuffix"/>
		</xsl:attribute>
		<xsl:apply-templates/>
	</h2>
</xsl:template>

<xsl:template match="leg:ContentsSchedules/leg:ContentsTitle">
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<p class="{concat('ENContentsHeading', $strAmendmentSuffix)}">
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:ContentsItem/leg:ContentsTitle">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<span class="LegDS {concat('ENContentsTitle', $strAmendmentSuffix)}">
		<xsl:choose>
			<xsl:when test="parent::*/@ContentRef">
				<xsl:variable name="strIDref" select="parent::*/@ContentRef"/>
				<xsl:variable name="strID">
					<xsl:for-each select="key('g_keyNodeIDs', $strIDref)">
						<xsl:call-template name="FuncGenerateAnchorID"/>
					</xsl:for-each>
				</xsl:variable>
				<a href="#{$strID}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>

<xsl:template match="leg:ContentsTitle">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<p class="{concat('ENContentsTitle', $strAmendmentSuffix)}">
		<xsl:choose>
			<xsl:when test="parent::*/@ContentRef">
				<xsl:variable name="strIDref" select="parent::*/@ContentRef"/>
				<xsl:variable name="strID">
					<xsl:for-each select="key('g_keyNodeIDs', $strIDref)">
						<xsl:call-template name="FuncGenerateAnchorID"/>
					</xsl:for-each>
				</xsl:variable>
				<a href="#{$strID}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>		
	</p>
</xsl:template>
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	<!-- ========== MAIN STRUCTURE ========== -->	
	
	<!-- This will override the breadcrumb trail XSLT for the unchunked views -->
	<xsl:template match="leg:CommentaryGroup | leg:CommentaryDivision  | leg:CommentarySubDivision | leg:CommentarySubSubDivision |
	leg:CommentaryPart | leg:CommentaryChapter | leg:CommentaryP1 | leg:CommentarySchedule | 
	leg:Division | leg:SubDivision | leg:SubSubDivision | leg:SubSubSubDivision" mode="Structure">
		<xsl:call-template name="FuncProcessStructureContents"/>
	</xsl:template>

	<!-- presently needed for the breadcrumb trail -->
	<xsl:template name="FuncProcessStructureContents">
		<xsl:apply-templates select="*[not(self::leg:Reference or self::leg:Number or self::leg:Title or self::leg:TitleBlock)] | processing-instruction()[not(following-sibling::leg:Number or following-sibling::leg:Title or following-sibling::leg:TitleBlock or following-sibling::leg:Reference)]"/>
	</xsl:template>

	<xsl:template name="FuncOutputContents">

		<!-- Calculate if we should auto-generate contents - set the value of the number of divisions 
			to determine size of doc that will have a TOC-->
		<xsl:variable name="strGenerateContents">
			<xsl:choose>
				<xsl:when test="count(/leg:EN/leg:ExplanatoryNotes/leg:Body//leg:Division) &gt; 5">true</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<!-- Ignore contents - autogenerate only if size of document warrants this -->
			<!--<xsl:when test="/leg:EN/leg:Contents">
			<xsl:apply-templates select="/leg:EN/leg:Contents"/>
		</xsl:when>-->
			<xsl:when test="$strGenerateContents = 'true'">
				<xsl:call-template name="FuncGenerateContents"/>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<!-- We will extract headings from the file and generate the necessary contents for those items -->
	<xsl:template name="FuncGenerateContents">

		<div class="ENContents ENClearFix">
			<h2 class="ENContentsHeading">Contents</h2>
			<ol>
				<xsl:for-each select="/leg:EN/*[self::leg:ExplanatoryNotes]/*[self::leg:Body or self::leg:Annexes]">
					<xsl:call-template name="FuncGenerateTOCstructure"/>
				</xsl:for-each>
			</ol>
		</div>			

	</xsl:template>


	<!-- Process high-level headings -->
	<xsl:template name="FuncGenerateTOCstructure">
		<xsl:for-each select="leg:Division | leg:SubDivision | leg:SubSubDivision  | leg:CommentaryP1[leg:Title] | leg:CommentaryPart[leg:Title] | leg:CommentaryDivision | leg:CommentaryChapter[leg:Title] | leg:CommentarySchedule[leg:Title] | leg:Annex">
			<xsl:choose>
				<xsl:when test="self::leg:Division or self::leg:SubDivision or self::leg:SubSubDivision or self::leg:CommentaryDivision or self::leg:CommentaryPart">
					<li class="ENClearFix ENContents{name()}">
						<xsl:call-template name="FuncGenerateTOCtitle"/>
						<xsl:if test="leg:SubDivision or leg:SubSubDivision or leg:CommentaryP1[leg:Title] or leg:CommentaryPart[leg:Title] or leg:CommentaryDivision or leg:CommentaryChapter[leg:Title] or leg:CommentarySchedule[leg:Title] or leg:Annex">
							<ol>
								<xsl:call-template name="FuncGenerateTOCstructure"/>
							</ol>
						</xsl:if>
					</li>			
				</xsl:when>
				<xsl:when test="self::leg:CommentaryP1[leg:Title] or self::leg:CommentaryPart[leg:Title] or self::leg:CommentaryChapter[leg:Title] or self::leg:CommentarySchedule[leg:Title]">
					<li class="ENContentsEntry">
						<p class="ENContentsCommentary ENClearFix">

							<xsl:call-template name="FuncGenerateTOCitemTitle"/>
						</p>
					</li>
				</xsl:when>
				<xsl:when test="self::leg:Annex">
					<li class="ENContentsEntry">
						<p class="ENContentsAnnex ENClearFix">
							<xsl:call-template name="FuncGenerateTOCitemTitle">
								<xsl:with-param name="strPrefix">
									<xsl:value-of select="leg:Number"/>
									<xsl:text>: </xsl:text>
								</xsl:with-param>
							</xsl:call-template>
						</p>
					</li>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="leg:Contents//*[leg:* except (leg:ContentsTitle, leg:ContentsNumber)]" priority="2">
		<li class="ENClearFix EN{local-name()}">
			<xsl:apply-templates select="leg:ContentsTitle" />
			<!-- addedby Yash - Call HA051277 - ContentsNumber was missing from TOC for notes -http://www.legislation.gov.uk/ukpga/2011/16/notes/contents-->
			<xsl:apply-templates select="leg:ContentsNumber" />
			<ol>
				<xsl:apply-templates select="* except (leg:ContentsTitle, leg:ContentsNumber)" />
			</ol>
		</li>
	</xsl:template>
	


	<xsl:template name="FuncGenerateTOCtitle">
		<xsl:param name="strPrefix" />
		<xsl:variable name="strID">
			<xsl:choose>
				<xsl:when test="self::leg:Division or self::leg:SubDivision or self::leg:SubSubDivision">
					<xsl:call-template name="FuncCalcDivID"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="TSO_FuncGenerateENCommentaryLinkID"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select="leg:Title | leg:TitleBlock/leg:Title">
			<p class="ENContentsTitle">
				<a href="#{$strID}">
					<xsl:value-of select="$strPrefix"/>
					<xsl:apply-templates select="preceding-sibling::*[1][self::leg:Number]" >
						<xsl:with-param name="blnProcessContents" select="false()" />
					</xsl:apply-templates>
					<xsl:value-of select="."/>
				</a>
			</p>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="FuncGenerateTOCitemTitle">
		<xsl:param name="strPrefix" />
		<xsl:variable name="strID">
			<xsl:call-template name="TSO_FuncGenerateENCommentaryLinkID"/>
		</xsl:variable>
		<xsl:for-each select="leg:Title | leg:TitleBlock/leg:Title">
			<span class="ENDS ENContentsTitle">
				<a href="#{$strID}">
					<xsl:value-of select="$strPrefix"/>
					<xsl:apply-templates select="preceding-sibling::*[1][self::leg:Number]" >
						<xsl:with-param name="blnProcessContents" select="false()" />
					</xsl:apply-templates>
					<xsl:value-of select="."/>
				</a>
			</span>
		</xsl:for-each>
	</xsl:template>


	<!-- ========== Main structures ========== -->

	<xsl:template match="leg:EN">
		<xsl:apply-templates select="*[not(self::leg:Contents)] | processing-instruction()"/>
	</xsl:template>

	<xsl:template match="leg:ExplanatoryNotes">
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:Body">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</xsl:template>


	<!-- ========== Major headings ========== -->

	<xsl:template match="leg:Form">
		<div class="ENClearForm"/>
		<div class="ENFormSection">
			<xsl:call-template name="FuncProcessMajorHeading"/>
		</div>
	</xsl:template>

	<xsl:template match="leg:Form/leg:TitleBlock">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
	</xsl:template>

	<xsl:template name="FuncProcessMajorHeading">

	</xsl:template>


	<!-- ========== Paragraphs ========== -->



	<!-- Not really needed for EN but List elements presently using this -->


	<!-- This template reliant on other named templates -->
	<xsl:template name="FuncGetPrimaryAmendmentContext">

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
					<xsl:text>ENLevel</xsl:text>
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
			<xsl:when test="parent::leg:NumberedPara">3</xsl:when>
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


	<!-- ========== Provisions ========== -->


	<xsl:template match="leg:Division">
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcENHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="not(preceding-sibling::*)">ENClearDivFirst ENDivTitle</xsl:when>
					<xsl:otherwise>ENClearDiv ENDivTitle</xsl:otherwise>
				</xsl:choose>		
			</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:call-template name="FuncCalcDivID"/>
			</xsl:attribute>
			<xsl:apply-templates select="leg:Number | leg:Title"/>
		</xsl:element>

		<xsl:apply-templates select="." mode="Structure"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:SubDivision">
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcENHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">ENClearSub ENSubTitle</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:call-template name="FuncCalcDivID"/>
			</xsl:attribute>
			<xsl:apply-templates select="leg:Number | leg:Title"/>
		</xsl:element>
		<xsl:apply-templates select="." mode="Structure"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:SubSubDivision">
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcENHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">ENClearSubSub ENSubSubTitle</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:call-template name="FuncCalcDivID"/>
			</xsl:attribute>
			<xsl:apply-templates select="leg:Number | leg:Title"/>
		</xsl:element>
		<xsl:apply-templates select="." mode="Structure"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>


	<xsl:template match="leg:SubSubSubDivision">
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcENHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">ENClearSubSubSub ENSubSubSubTitle</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:call-template name="FuncCalcDivID"/>
			</xsl:attribute>
			<xsl:apply-templates select="leg:Number | leg:Title"/>
		</xsl:element>
		<xsl:apply-templates select="." mode="Structure"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:Division/leg:Title | leg:SubDivision/leg:Title | leg:SubSubDivision/leg:Title | leg:SubSubSubDivision/leg:Title">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- Catch any error divs in the output for debugging -->
	<xsl:template match="leg:ErrorDivision">
		<div class="ENError">
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template name="FuncCalcDivID">
		<xsl:if test="ancestor-or-self::leg:Division">
			<xsl:text>div</xsl:text>
			<xsl:value-of select="count(ancestor-or-self::leg:Division/preceding-sibling::leg:Division) + 1"/>
		</xsl:if>
		<xsl:if test="ancestor-or-self::leg:SubDivision">
			<xsl:text>-sub</xsl:text>
			<xsl:value-of select="count(ancestor-or-self::leg:SubDivision/preceding-sibling::leg:SubDivision) + 1"/>
		</xsl:if>
		<xsl:if test="ancestor-or-self::leg:SubSubDivision">
			<xsl:text>-subsub</xsl:text>
			<xsl:value-of select="count(ancestor-or-self::leg:SubSubDivision/preceding-sibling::leg:SubSubDivision) + 1"/>
		</xsl:if>
		<xsl:if test="ancestor-or-self::leg:SubSubSubDivision">
			<xsl:text>-subsubsub</xsl:text>
			<xsl:value-of select="count(ancestor-or-self::leg:SubSubSubDivision/preceding-sibling::leg:SubSubSubDivision) + 1"/>
		</xsl:if>
	</xsl:template>


	<xsl:template match="leg:CommentaryGroup | leg:CommentaryDivision  | leg:CommentarySubDivision | leg:CommentarySubSubDivision |
	leg:CommentaryPart | leg:CommentaryChapter | leg:CommentaryP1 | leg:CommentarySchedule">
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcENHeadingLevel"/>
		</xsl:variable>
		<xsl:if test="self::legCommentaryP1">
			<div class="ENClearPblock"/>
		</xsl:if>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">ENClearFix EN<xsl:value-of select="local-name()"/>
			</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:call-template name="TSO_FuncGenerateENCommentaryLinkID"/>
			</xsl:attribute>
			<xsl:apply-templates select="leg:Number | leg:Title"/>
		</xsl:element>
		<xsl:apply-templates select="." mode="Structure"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>


	<xsl:template match="leg:Division/leg:Number | leg:SubDivision/leg:Number | leg:SubSubDivision/leg:Number | leg:SubSubSubDivision/leg:Number | 
	leg:CommentaryP1/leg:Number | leg:CommentaryChapter/leg:Number | 
	leg:CommentaryPart/leg:Number | leg:CommentarySchedule/leg:Number  | 
	leg:CommentaryDivision/leg:Number | leg:CommentarySubDivision/leg:Number | leg:CommentarySubSubDivision/leg:Number ">
		<xsl:param name="blnProcessContents" select="true()" />
		<xsl:choose>
			<xsl:when test="$blnProcessContents">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
		<!-- only output a period after the number if it does not already end with a period -->
		<xsl:if test="not(contains(., '.') and substring-after(., '.') = '') " >
			<xsl:text>.</xsl:text>
		</xsl:if>
		<xsl:text/>
	</xsl:template>


	<!-- 
	Name:     TSO_FuncGenerateENCommentaryLinkID
	Parameters:
	ndContextNode:	Node from which id attribute should be matched against link document. Defaults to current node.
	Description:    Generates an id for an EN commentary section by matching the id of the commentary section
	with the id of the legislation section via the link file generated in the preceding pipeline stage
-->
	<xsl:template name="TSO_FuncGenerateENCommentaryLinkID">
		<xsl:param name="ndContextNode" select="self::*" />
		<xsl:variable name="strId" select="$ndContextNode/@id" />
		<!-- No corresponding section found in legislation file, so generate an id  -->
		<xsl:call-template name="FuncCalcCommentaryID" />
	</xsl:template>


	<xsl:template name="TSO_FuncGenerateLegislationLinkID">
		<xsl:param name="strId" />
		<!-- 
		Any EN commentary section can reference multiple sections of the legislation document, so unique ids are not guaranteed
		However, we can minimize this by looking for links to sections that have not previously been referenced
	-->
	</xsl:template>


	<!--
TODO: need to add semantic id based on EN structure	
-->
	<xsl:template name="FuncCalcCommentaryID">
		<xsl:text>c</xsl:text>
		<xsl:value-of select="generate-id()"/>
	</xsl:template>


	<xsl:template match="leg:CommentaryP1/leg:Title | leg:CommentaryPart/leg:Title | 
	leg:CommentaryChapter/leg:Title | leg:CommentarySchedule/leg:Title | 
	leg:CommentaryDivision/leg:Title | leg:CommentarySubDivision/leg:Title | leg:CommentarySubSubDivision/leg:Title |
	leg:CommentaryGroup/leg:Title">
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template match="leg:NumberedPara">
		<!--<xsl:call-template name="FuncCheckForIDelement"/>-->
		<xsl:apply-templates select="*[not(self::leg:Pnumber)] | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:NumberedPara/leg:Pnumber">
		<xsl:apply-templates/> 
	</xsl:template>

	<xsl:template match="leg:Pnumber">
		<xsl:value-of select="@PuncBefore"/>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="leg:Pnumber/@PuncBefore" priority="10">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="leg:Pnumber/@*" />


	<xsl:template match="leg:Para">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<!-- This is for extracted legislation -->
	<xsl:template match="leg:P1 | leg:Pblock | leg:P1group | leg:Schedules |  leg:Schedule | leg:ScheduleBody | leg:Part | leg:Chapter">
		<xsl:call-template name="FuncCheckForIDelement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:Schedule/leg:TitleBlock">
		<p class="ENLegTitleBlockTitle">
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<xsl:template match="leg:Schedule/leg:Number">
		<p class="ENClearFix ENLegScheduleNo">
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<xsl:template match="leg:Pblock/leg:Title">
		<p class="ENLegPblockTitle">
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<xsl:template match="leg:Part/leg:Number">
		<p class="ENClearFix ENLegPartNo">
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<xsl:template match="leg:Part/leg:Title">
		<p class="ENLegPartTitle">
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<xsl:template match="leg:Chapter/leg:Number">
		<p class="ENClearFix ENLegChapterNo">
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<xsl:template match="leg:Chapter/leg:Title">
		<p class="ENLegChapterTitle">
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<xsl:template match="leg:P1group/leg:Title">
		<p class="ENClearFix ENLegP1GroupTitle">
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<xsl:template match="leg:P1/leg:Pnumber">
		<xsl:choose>
			<!-- Pnumbers in schedules have already been picked up by the leg:P1para/leg:Text template -->
			<xsl:when test="ancestor::leg:ScheduleBody" />
			<xsl:otherwise>
				<span class="ENDS ENLHS ENLegP1No">
					<xsl:call-template name="FuncCheckForID"/>
					<xsl:apply-templates/> 
					<xsl:if test="following-sibling::leg:P1para[child::*[1][self::leg:P2]] and not(parent::leg:P1/preceding-sibling::*[1][self::leg:Title])">
						<xsl:text>&#8211;</xsl:text>
					</xsl:if>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:P1para">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P2">
		<xsl:call-template name="FuncCheckForIDelement"/>
		<xsl:apply-templates select="*[not(self::leg:Pnumber)] | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P2para">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P3">
		<xsl:call-template name="FuncCheckForIDelement"/>
		<xsl:apply-templates select="*[not(self::leg:Pnumber)] | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P3para">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P4">
		<xsl:call-template name="FuncCheckForIDelement"/>
		<xsl:apply-templates select="*[not(self::leg:Pnumber)] | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P4para">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P5">
		<xsl:call-template name="FuncCheckForIDelement"/>
		<xsl:apply-templates select="*[not(self::leg:Pnumber)] | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P5para">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P6">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="*[not(self::leg:Pnumber)] | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P6para">
		<xsl:call-template name="FuncCheckForIDelement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P7">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="*[not(self::leg:Pnumber)] | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:P7para">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>


	<!-- ========== Lists ========== -->

	<xsl:template match="leg:UnorderedList">
		<xsl:choose>
			<xsl:when test="$g_strDocumentType = $g_strPrimary or ($g_strDocumentType = $g_strSecondary and string(@Class) != 'Definition')">
				<!-- Generate suffix to be added for CSS classes for amendments -->
				<xsl:variable name="strAmendmentSuffix">
					<xsl:call-template name="FuncCalcAmendmentNo"/>
				</xsl:variable>
				<xsl:variable name="strPrimaryContext">
					<xsl:text>P3</xsl:text>
				</xsl:variable>
				<ul>
					<xsl:call-template name="FuncCheckForID"/>
					<xsl:attribute name="class">
						<xsl:choose>
							<xsl:when test="@Decoration = 'none'">ENTabbed</xsl:when>
							<xsl:when test="@Decoration = 'dash'">ENDashed</xsl:when>
							<xsl:when test="@Decoration = 'bullet'">ENBulleted</xsl:when>
						</xsl:choose>
						<xsl:if test="@Class = 'Definition'">
							<xsl:text>Def</xsl:text>
						</xsl:if>
						<xsl:value-of select="$strAmendmentSuffix"/>
						<xsl:text> ENUnorderedList</xsl:text>
						<xsl:value-of select="$strPrimaryContext"/>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:attribute>
					<xsl:apply-templates select="* | processing-instruction()"/>
				</ul>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="FuncCheckForIDnoElement"/>
				<xsl:apply-templates select="* | processing-instruction()"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:UnorderedList/leg:ListItem">
		<xsl:choose>
			<xsl:when test="$g_strDocumentType = $g_strPrimary or ($g_strDocumentType = $g_strSecondary and string(parent::*/@Class) != 'Definition')">
				<li>
					<xsl:call-template name="FuncCheckForID"/>

					<xsl:apply-templates select="* | processing-instruction()"/>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="FuncCheckForIDnoElement"/>
				<xsl:apply-templates select="* | processing-instruction()"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:KeyList">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:KeyListItem">
		<div class="ENClearFix ENKeyListItem">
			<xsl:call-template name="FuncCheckForID"/>

			<xsl:apply-templates select="* | processing-instruction()"/>
		</div>

		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:Key">
		<!-- Generate suffix to be added for CSS classes for amendments -->
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<div>
			<xsl:attribute name="class">
				<xsl:text>ENListItemNo ENKey</xsl:text>
				<xsl:call-template name="FuncCalcListClass"/>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</div>
		<xsl:if test="ancestor::leg:KeyList[1]/@Separator != ''">
			<p class="ENKeySeparator">
				<xsl:value-of select="ancestor::leg:KeyList[1]/@Separator"/>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:KeyListItem/leg:ListItem">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:OrderedList">
		<!-- Lists cannot be used because not enough numbering flexibility or compatibility with regard to CSS formatting -->
		<div>
			<xsl:call-template name="FuncGetListAncestry"/>
			<div>
				<xsl:call-template name="FuncCheckForID"/>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="@Type = 'alpha' or @Type = 'alphaUpper'">ENAlphaList</xsl:when>
						<xsl:when test="@Type = 'roman' or @Type = 'romanUpper'">ENRomanList</xsl:when>
						<xsl:when test="@Type = 'arabic'">ENArabicList</xsl:when>					
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="* | processing-instruction()"/>
			</div>
		</div>

		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<!-- This is for ordered lists within legislation extracts -->
	<xsl:template name="FuncGetListAncestry">
		<!-- Calculate the initial context of the list -->
		<xsl:for-each select="ancestor::*[self::leg:P2para or self::leg:P3para or self::leg:P4para or self::leg:P5para or self::leg:P6para or self::leg:P7para or self::leg:BlockAmendment][1]">
			<xsl:if test="not(self::leg:BlockAmendment)">
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="self::leg:P2para">ENLegP2list</xsl:when>
						<xsl:when test="self::leg:P3para">ENLegP3list</xsl:when>
						<xsl:when test="self::leg:P4para">ENLegP4list</xsl:when>
						<xsl:when test="self::leg:P5para">ENLegP5list</xsl:when>
						<xsl:when test="self::leg:P6para">ENLegP6list</xsl:when>
						<xsl:when test="self::leg:P7para">ENLegP7list</xsl:when>
					</xsl:choose>
					<xsl:call-template name="FuncCalcAmendmentNo"/>
				</xsl:attribute>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="leg:OrderedList/leg:ListItem">
		<!-- Generate suffix to be added for CSS classes for amendments -->
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<div class="ENListItem">
			<xsl:call-template name="FuncCheckForID"/>
			<!-- If a direct nested list item output number from parent list item also -->
			<xsl:if test="not(child::*[1][self::leg:OrderedList])">
				<xsl:variable name="strListClass">
					<xsl:call-template name="FuncCalcListClass"/>
				</xsl:variable>
				<xsl:if test="not(preceding-sibling::leg:ListItem) and parent::leg:OrderedList/parent::leg:ListItem/parent::leg:OrderedList">
					<div class="{concat('ENLeftNo', $strListClass, 'No', $strAmendmentSuffix, ' ENListItemNo')}">
						<xsl:for-each select="ancestor::leg:ListItem[1]">
							<xsl:call-template name="FuncOutputListItemNumber"/>
						</xsl:for-each>
					</div>
				</xsl:if>
				<div>
					<xsl:attribute name="class">
						<xsl:if test="not(preceding-sibling::leg:ListItem) and parent::leg:OrderedList/parent::leg:ListItem/parent::leg:OrderedList">
							<xsl:text>ENRightNo</xsl:text>
						</xsl:if>
						<xsl:value-of select="$strListClass"/>
						<xsl:text>No</xsl:text>
						<xsl:if test="preceding-sibling::leg:ListItem or not(parent::leg:OrderedList/parent::leg:ListItem/parent::leg:OrderedList)">
							<xsl:value-of select="$strAmendmentSuffix"/>
						</xsl:if>
						<xsl:text> ENListItemNo</xsl:text>
						<xsl:if test="descendant::leg:Note">
							<xsl:text> ENNote</xsl:text>
						</xsl:if>
					</xsl:attribute>
					<!-- Check if the list item number is the first text in an amendment, in which case output the quote -->
					<xsl:if test="ancestor::leg:BlockAmendment and generate-id(ancestor::leg:BlockAmendment[1]/descendant::text()[not(normalize-space() = '')][1]) = generate-id(descendant::text()[not(normalize-space() = '')][1])">
						<xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
					</xsl:if>
					<xsl:call-template name="FuncOutputListItemNumber"/>
				</div>
			</xsl:if>
			<xsl:apply-templates select="* | processing-instruction()"/>
		</div>

		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template name="FuncOutputListItemNumber">
		<xsl:variable name="intStartValue">
			<xsl:choose>
				<xsl:when test="parent::*/@Start">
					<xsl:value-of select="number(parent::*/@Start)"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="intListItemCount" select="count(preceding-sibling::leg:ListItem) + $intStartValue"/>
		<xsl:variable name="strDecoration" select="parent::*/@Decoration"/>
		<xsl:variable name="strPreText">
			<xsl:choose>
				<xsl:when test="$strDecoration = 'parens'">(</xsl:when>
				<xsl:when test="$strDecoration = 'brackets'">[</xsl:when>
			</xsl:choose>		
		</xsl:variable>
		<xsl:variable name="strPostText">
			<xsl:choose>
				<xsl:when test="$strDecoration = 'parens' or $strDecoration = 'parenRight'">)</xsl:when>
				<xsl:when test="$strDecoration = 'brackets' or $strDecoration = 'bracketRight'">]</xsl:when>
				<xsl:when test="$strDecoration = 'period'">.</xsl:when>
				<xsl:when test="$strDecoration = 'colon'">:</xsl:when>
			</xsl:choose>		
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@NumberOverride">
				<!-- NumberOverride might start with the pre-text and/or end with post-text characters, so may not want to output them -->
				<xsl:if test="not(contains(@NumberOverride, $strPreText))">
					<xsl:value-of select="$strPreText"/>
				</xsl:if>
				<xsl:value-of select="@NumberOverride"/>
				<xsl:if test="not(contains(@NumberOverride, $strPostText) and substring-after(@NumberOverride, $strPostText)='')">
					<xsl:value-of select="$strPostText"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="strFormat">
					<xsl:choose>
						<xsl:when test="parent::*/@Type = 'roman'">i</xsl:when>
						<xsl:when test="parent::*/@Type = 'romanUpper'">I</xsl:when>
						<xsl:when test="parent::*/@Type = 'arabic'">1</xsl:when>
						<xsl:when test="parent::*/@Type = 'alphaUpper'">A</xsl:when>
						<xsl:otherwise>a</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:number value="$intListItemCount" format="{concat($strPreText, $strFormat, $strPostText)}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- ========== Amendments ========== -->

	<xsl:template match="leg:BlockAmendment">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:AppendText"/>


	<!-- ========== Block text ========== -->

	<xsl:template match="leg:BlockText">
		<div class="ENBlockText">
			<xsl:call-template name="FuncCheckForID"/>

			<xsl:apply-templates select="* | processing-instruction()"/>
		</div>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>


	<!-- ========== Extracts ========== -->

	<xsl:template match="leg:BlockExtract">
		<!--<blockquote>-->
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
		<!--</blockquote>-->
	</xsl:template>

	<xsl:template match="leg:P">
		<xsl:apply-templates select="* | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<!-- ========== Tables ========== -->

	<xsl:template match="leg:Tabular">
		<div class="ENTabular">
			<xsl:attribute name="id">
				<xsl:call-template name="FuncGenerateAnchorID"/>
			</xsl:attribute>
			<xsl:apply-templates select="* | processing-instruction()"/>
		</div>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:Tabular/leg:Number">
		<!-- Generate suffix to be added for CSS classes for amendments -->
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcENHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">
				<xsl:text>ENTableNo</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> EN</xsl:text>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:call-template name="FuncGetLocalTextStyle"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="leg:Tabular/leg:Title">
		<!-- Generate suffix to be added for CSS classes for amendments -->
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcENHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">
				<xsl:text>ENTableTitle</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> EN</xsl:text>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:call-template name="FuncGetLocalTextStyle"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="leg:Tabular/leg:Subtitle">
		<!-- Generate suffix to be added for CSS classes for amendments -->
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcENHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel + 1}">
			<xsl:attribute name="class">
				<xsl:text>ENTableSubtitle</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> EN</xsl:text>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:call-template name="FuncGetLocalTextStyle"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="leg:TableText">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
	</xsl:template>

	<xsl:template match="xhtml:table">
		<!-- Generate suffix to be added for CSS classes for amendments -->
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<div>
			<xsl:attribute name="class">
				<xsl:text>ENClearFix ENTableContainer</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> EN</xsl:text>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			<table class="ENTable" cellpadding="5">
				<xsl:attribute name="id">
					<xsl:call-template name="FuncGenerateAnchorID"/>
				</xsl:attribute>
				<xsl:copy-of select="@summary"/>
				<xsl:variable name="dblTablePercentageWidth">
					<xsl:call-template name="FuncCalcTableColWidths"/>
				</xsl:variable>
				<!-- For tables with no defined borders use default -->
				<xsl:choose>
					<xsl:when test="not(descendant::*/@*[not(. = 'inherit') and contains(name(), 'border')])">
						<xsl:attribute name="style">border-top: solid 1px black; border-bottom: solid 1px black</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="FuncProcessTableBordersStyle">
							<xsl:with-param name="strOtherCSS" select="$dblTablePercentageWidth"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates select="* | processing-instruction()"/>
			</table>
		</div>
	</xsl:template>

	<xsl:template match="xhtml:caption">
		<caption>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:apply-templates/>
		</caption>
	</xsl:template>

	<xsl:template match="xhtml:colgroup">
		<colgroup>

			<xsl:apply-templates select="* | processing-instruction()">
				<xsl:with-param name="dblTableTotalWidth">
					<xsl:for-each select="xhtml:col[@width][1]">
						<xsl:call-template name="FuncAddNextColWidth"/>
					</xsl:for-each>
				</xsl:with-param>
			</xsl:apply-templates>
		</colgroup>
	</xsl:template>

	<xsl:template match="xhtml:col">
		<xsl:param name="dblTableTotalWidth" select="100"/>
		<col>
			<!-- For tables using percentage column widths we will copy those through. For points we will convert to percent. Note that a combination will cause problems -->
			<xsl:if test="@width and (contains(@width, '%') or contains(@width, 'pt'))">
				<xsl:attribute name="width">
					<xsl:choose>
						<xsl:when test="contains(@width, '%')">
							<xsl:value-of select="@width"/>
						</xsl:when>
						<xsl:when test="contains(@width, 'pt')">
							<xsl:value-of select="round(number(translate(@width, 'pt', '')) div $dblTableTotalWidth * 100)"/>
							<xsl:text>%</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
		</col>
	</xsl:template>

	<!-- Get total width of table as a percentage of measure (SI measure) -->
	<xsl:template name="FuncCalcTableColWidths">
		<xsl:variable name="dblTableTotalWidth">
			<xsl:for-each select="xhtml:colgroup/xhtml:col[@width][1]">
				<xsl:call-template name="FuncAddNextColWidth"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space($dblTableTotalWidth) = ''"/>
			<xsl:otherwise>
				<xsl:text>width: </xsl:text>
				<xsl:value-of select="round(number($dblTableTotalWidth) div 426.5 * 100)"/>
				<xsl:text>%; </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="FuncAddNextColWidth">
		<xsl:param name="dblTotalWidth" select="0"/>
		<xsl:variable name="dblCurrentColWidth" select="translate(@width, 'pt', '')"/>
		<xsl:choose>
			<xsl:when test="following-sibling::xhtml:col">
				<xsl:for-each select="following-sibling::xhtml:col[@width][1]">
					<xsl:call-template name="FuncAddNextColWidth">
						<xsl:with-param name="dblTotalWidth" select="number($dblTotalWidth) + number($dblCurrentColWidth)"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number($dblTotalWidth) + number($dblCurrentColWidth)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xhtml:tfoot">
		<tfoot>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:call-template name="FuncProcessTableBordersStyle"/>

			<xsl:apply-templates select="* | processing-instruction()"/>
		</tfoot>
	</xsl:template>

	<xsl:template match="xhtml:thead">
		<thead>
			<xsl:call-template name="FuncCheckForID"/>
			<!-- For tables with no defined borders use default -->
			<xsl:choose>
				<xsl:when test="not(ancestor::xhtml:table[1]/descendant::*/@*[not(. = 'inherit') and contains(name(), 'border')])">
					<xsl:attribute name="style">border-top: solid 1px black; border-bottom: solid 1px black</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="FuncProcessTableBordersStyle"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="* | processing-instruction()"/>
		</thead>
	</xsl:template>

	<xsl:template match="xhtml:tbody">
		<tbody>
			<xsl:attribute name="id">
				<xsl:call-template name="FuncGenerateAnchorID"/>
			</xsl:attribute>
			<!-- For tables with no defined borders use default -->
			<xsl:choose>
				<xsl:when test="not(ancestor::xhtml:table[1]/descendant::*/@*[not(. = 'inherit') and contains(name(), 'border')])">
					<xsl:attribute name="style">border-bottom: solid 1px black</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="FuncProcessTableBordersStyle"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select="* | processing-instruction()"/>
		</tbody>
	</xsl:template>

	<xsl:template match="xhtml:tr">
		<tr>
			<xsl:attribute name="id">
				<xsl:call-template name="FuncGenerateAnchorID"/>
			</xsl:attribute>

			<xsl:apply-templates select="* | processing-instruction()"/>
		</tr>
	</xsl:template>

	<xsl:template match="xhtml:th">
		<th class="ENTHplain">
			<xsl:attribute name="id">
				<xsl:call-template name="FuncGenerateAnchorID"/>
			</xsl:attribute>
			<!-- If there are no column spans in the table then output a scope attribute -->
			<xsl:if test="not(ancestor::xhtml:table[1]/xhtml:tbody/xhtml:tr/xhtml:td[number(@colspan) &gt; 1])">
				<xsl:choose>
					<xsl:when test="number(@colspan) &gt; 1">
						<xsl:attribute name="scope">colgroup</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="scope">col</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:call-template name="FuncProcessCellContent">
				<xsl:with-param name="strCellType" select="'ENTH'"/>
			</xsl:call-template>
		</th>
	</xsl:template>

	<xsl:template match="xhtml:td">
		<td class="ENTDplain">
			<xsl:attribute name="id">
				<xsl:call-template name="FuncGenerateAnchorID"/>
			</xsl:attribute>
			<xsl:call-template name="FuncProcessCellContent">
				<xsl:with-param name="strCellType" select="'ENTD'"/>
			</xsl:call-template>
		</td>
	</xsl:template>

	<xsl:template name="FuncProcessCellContent">
		<xsl:param name="strCellType"/>
		<!-- By default assume plain text in cell unless there is structural markup -->
		<xsl:if test="child::*[not(self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps)]">
			<xsl:attribute name="class">
				<xsl:value-of select="$strCellType"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="@scope"/>
		<xsl:if test="@colspan != '1'">
			<xsl:copy-of select="@colspan"/>
		</xsl:if>
		<xsl:if test="@rowspan != '1'">
			<xsl:copy-of select="@rowspan"/>
		</xsl:if>
		<xsl:variable name="strTableBorders">
			<xsl:call-template name="FuncProcessTableBordersStyle">
				<xsl:with-param name="flCreateAttribute" select="false()"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="@valign[not(. = 'inherit')] or @align[not(. = 'inherit')] or string($strTableBorders) != ''">
			<xsl:attribute name="style">
				<xsl:if test="@valign[not(. = 'inherit')]">
					<xsl:text>vertical-align: </xsl:text>
					<xsl:value-of select="@valign"/>
					<xsl:text>; </xsl:text>
				</xsl:if>
				<xsl:if test="@align[not(. = 'inherit')]">
					<xsl:text>text-align: </xsl:text>
					<xsl:value-of select="@align"/>
					<xsl:text>; </xsl:text>
				</xsl:if>
				<xsl:value-of select="$strTableBorders"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:for-each select="node()[not((position() = last() or preceding-sibling::node()[1][self::leg:Para]) and self::text() and normalize-space() = '')] | processing-instruction()">
			<!-- Mixed content in a table cell (i.e. paragraph level and text level content) should not occur - but just in case it does ... -->
			<xsl:choose>
				<xsl:when test="self::text() and parent::*[child::*[not(self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps)]]">
					<span class="ENTDmixedText">
						<xsl:apply-templates select="."/>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- Calculate if need to output style attribute -->
	<xsl:template name="FuncProcessTableBordersStyle">
		<xsl:param name="flCreateAttribute" select="true()"/>
		<xsl:param name="strOtherCSS"/>
		<xsl:variable name="strCSS">
			<xsl:value-of select="$strOtherCSS"/>
			<xsl:call-template name="FuncProcessTableBorders"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$flCreateAttribute = true()">
				<xsl:attribute name="style">
					<xsl:value-of select="$strCSS"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$strCSS"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Generate table borders -->
	<xsl:template name="FuncProcessTableBorders">
		<xsl:if test="@fo:border-top-style = 'solid'">border-top: solid 1px black; </xsl:if>
		<xsl:if test="@fo:border-bottom-style = 'solid'">border-bottom: solid 1px black; </xsl:if>
		<xsl:if test="@fo:border-right-style = 'solid'">border-right: solid 1px black; </xsl:if>
		<xsl:if test="@fo:border-left-style = 'solid'">border-left: solid 1px black; </xsl:if>
	</xsl:template>


	<!-- ========== Resources ========== -->

	<xsl:template match="leg:Resources"/>

	<xsl:template match="leg:ResourceGroup">
		<xsl:param name="strContext"/>
		<xsl:param name="strDisplayFormat"/>
		<xsl:param name="strAltAttributeDesc"/>
		<xsl:param name="dblWidth"/>
		<xsl:param name="dblHeight"/>
		<xsl:apply-templates select="* | processing-instruction()">
			<xsl:with-param name="strContext" select="$strContext"/>
			<xsl:with-param name="strDisplayFormat" select="$strDisplayFormat"/>
			<xsl:with-param name="strAltAttributeDesc" select="$strAltAttributeDesc"/>
			<xsl:with-param name="dblWidth" select="$dblWidth"/>
			<xsl:with-param name="dblHeight" select="$dblHeight"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="leg:Resource[leg:ExternalVersion]">
		<xsl:param name="strContext"/>
		<xsl:param name="strDisplayFormat"/>
		<xsl:param name="strAltAttributeDesc"/>
		<xsl:param name="dblWidth"/>
		<xsl:param name="dblHeight"/>
		<xsl:apply-templates select="* | processing-instruction()">
			<xsl:with-param name="strContext" select="$strContext"/>
			<xsl:with-param name="strDisplayFormat" select="$strDisplayFormat"/>
			<xsl:with-param name="strAltAttributeDesc" select="$strAltAttributeDesc"/>
			<xsl:with-param name="dblWidth" select="$dblWidth"/>
			<xsl:with-param name="dblHeight" select="$dblHeight"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="leg:ExternalVersion">
		<xsl:param name="strContext"/>
		<xsl:param name="strDisplayFormat"/>
		<xsl:param name="strAltAttributeDesc"/>
		<xsl:param name="dblWidth"/>
		<xsl:param name="dblHeight"/>
		<!-- We'll make an assumption that an external version is an image -->
		<xsl:call-template name="FuncProcessImage">
			<xsl:with-param name="strContext" select="$strContext"/>
			<xsl:with-param name="strDisplayFormat" select="$strDisplayFormat"/>
			<xsl:with-param name="strAltAttributeDesc" select="$strAltAttributeDesc"/>
			<xsl:with-param name="dblWidth">
				<!-- Any value for width passed in will override the value at this level -->
				<xsl:choose>
					<xsl:when test="$dblWidth != ''">
						<xsl:value-of select="$dblWidth"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@Width"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="dblHeight">
				<xsl:choose>
					<xsl:when test="$dblHeight != ''">
						<xsl:value-of select="$dblHeight"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@Height"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- In a similar way to versions we need to put any internal XML content resources in context ready for processing -->
	<xsl:template match="leg:Resource[leg:InternalVersion]">
		<!-- Get an aggregated copy of all internal XML -->
		<xsl:variable name="rtfContent">
			<!-- There is an assumption here of no PIs at this level -->
			<xsl:copy-of select="leg:InternalVersion/leg:XMLcontent/node()"/>
		</xsl:variable>
		<xsl:variable name="strResource" select="@id"/>
		<!-- We need to do it this way because we may be looking for an include in a version copy of the content -->
		<xsl:variable name="ndsIncludeDocument" select="//leg:IncludedDocument[@ResourceRef = $strResource]"/>
		<xsl:variable name="intIDofItemToReplace" select="generate-id($ndsIncludeDocument)"/>
		<!-- Generate a document that is the correct context -->
		<xsl:variable name="rtfNormalisedDoc">
			<!-- We use root because we may be in a RTF generated for version processing -->
			<xsl:for-each select="/">
				<xsl:apply-templates mode="ResourceNormalisation">
					<xsl:with-param name="ndsResourceToUse" select="$rtfContent"/>
					<xsl:with-param name="intIDofItemToReplace" select="$intIDofItemToReplace"/>
					<xsl:with-param name="strResource" select="$strResource"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:variable>
		<!-- Now process the version that has been pulled into the correct context -->
		<xsl:for-each select="$rtfNormalisedDoc">
			<xsl:apply-templates select="//*[@ResourceReplacement = 'True']"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="ResourceNormalisation">
		<xsl:param name="ndsResourceToUse"/>
		<xsl:param name="intIDofItemToReplace"/>
		<xsl:param name="strResource"/>
		<xsl:choose>
			<xsl:when test="generate-id() = $intIDofItemToReplace">
				<xsl:for-each select="$ndsResourceToUse/*">
					<xsl:copy>
						<xsl:copy-of select="@*"/>
						<!--We will use a ResourceReplacement attribute to identify the substituted content -->
						<xsl:attribute name="ResourceReplacement">True</xsl:attribute>
						<xsl:attribute name="ResourceReference">
							<xsl:value-of select="$strResource"/>
						</xsl:attribute>
						<xsl:apply-templates mode="ResourceNormalisation">
							<xsl:with-param name="ndsResourceToUse" select="$ndsResourceToUse"/>
							<xsl:with-param name="intIDofItemToReplace" select="$intIDofItemToReplace"/>
							<xsl:with-param name="strResource" select="$strResource"/>
						</xsl:apply-templates>
					</xsl:copy>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates mode="ResourceNormalisation">
						<xsl:with-param name="ndsResourceToUse" select="$ndsResourceToUse"/>
						<xsl:with-param name="intIDofItemToReplace" select="$intIDofItemToReplace"/>
						<xsl:with-param name="strResource" select="$strResource"/>
					</xsl:apply-templates>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:InternalVersion">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</xsl:template>

	<xsl:template match="leg:XMLcontent">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</xsl:template>

	<xsl:template match="svg:svg">
		<div class="ENSVGcontainer">
			<xsl:text>SVG IMAGE CONTAINED HERE</xsl:text>
		</div>
	</xsl:template>


	<!-- ========== Versions ========== -->

	<xsl:template match="leg:Versions"/>

	<!-- Process alternate versions -->
	<xsl:template name="FuncApplyVersions">
		<xsl:if test="@AltVersionRefs">
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
			<xsl:with-param name="intIDofItemToReplace" select="generate-id()"/>
			<xsl:with-param name="strVersion" select="$strVersion"/>
		</xsl:apply-templates>
		<xsl:variable name="strRemainingVersions" select="normalize-space(substring-after($strVersions, $strVersion))"/>
		<xsl:if test="$strRemainingVersions != ''">
			<xsl:call-template name="FuncApplyVersion">
				<xsl:with-param name="strVersions" select="$strRemainingVersions"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:Version" mode="VersionNormalisationContext">
		<xsl:param name="intIDofItemToReplace"/>
		<xsl:param name="strVersion"/>
		<xsl:variable name="ndsVersionToUse" select="."/>	
		<!-- Generate a document that is the correct context -->
		<xsl:variable name="rtfNormalisedDoc">
			<xsl:for-each select="$g_ndsMainDoc">
				<xsl:apply-templates mode="VersionNormalisation">
					<xsl:with-param name="ndsVersionToUse" select="$ndsVersionToUse"/>
					<xsl:with-param name="intIDofItemToReplace" select="$intIDofItemToReplace"/>
					<xsl:with-param name="strVersion" select="$strVersion"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:variable>

		<!-- Now process the version that has been pulled into the correct context -->
		<xsl:for-each select="$rtfNormalisedDoc">
			<xsl:apply-templates select="//*[@VersionReplacement = 'True']"/>
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="*" mode="VersionNormalisation">
		<xsl:param name="ndsVersionToUse"/>
		<xsl:param name="intIDofItemToReplace"/>
		<xsl:param name="strVersion"/>
		<xsl:choose>
			<xsl:when test="generate-id() = $intIDofItemToReplace">
				<xsl:for-each select="$ndsVersionToUse/*">
					<xsl:copy>
						<xsl:copy-of select="@*"/>
						<!--We will use a VersionReplacement attribute to identify the substituted content -->
						<xsl:attribute name="VersionReplacement">True</xsl:attribute>
						<xsl:attribute name="VersionReference">
							<xsl:value-of select="$strVersion"/>
						</xsl:attribute>
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
						<xsl:apply-templates mode="VersionNormalisation">
							<xsl:with-param name="ndsVersionToUse" select="$ndsVersionToUse"/>
							<xsl:with-param name="intIDofItemToReplace" select="$intIDofItemToReplace"/>
							<xsl:with-param name="strVersion" select="$strVersion"/>
						</xsl:apply-templates>
					</xsl:copy>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates mode="VersionNormalisation">
						<xsl:with-param name="ndsVersionToUse" select="$ndsVersionToUse"/>
						<xsl:with-param name="intIDofItemToReplace" select="$intIDofItemToReplace"/>
						<xsl:with-param name="strVersion" select="$strVersion"/>
					</xsl:apply-templates>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ========== Annexes ========== -->

	<xsl:template match="leg:Annexes">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="leg:Annex">
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcENHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="not(preceding-sibling::*)">ENClearPblockFirst ENTitleBlockTitle</xsl:when>
					<xsl:otherwise>ENClearPblock ENTitleBlockTitle</xsl:otherwise>
				</xsl:choose>		
			</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:call-template name="FuncCalcCommentaryID" />
			</xsl:attribute>
			<xsl:if test="not(contains(lower-case(.),'annex'))">
				<xsl:text>Annex </xsl:text>
			</xsl:if>
			<xsl:value-of select="leg:Number"/>
			<xsl:text>: </xsl:text>
			<xsl:apply-templates select="leg:TitleBlock/leg:Title"/>
		</xsl:element>
		<xsl:apply-templates select="leg:TitleBlock/leg:SubTitle"/>
		<xsl:apply-templates select="*[not(self::leg:TitleBlock)]"/>
		<xsl:call-template name="FuncApplyVersions"/>
	</xsl:template>

	<xsl:template match="leg:TitleBlock/leg:Title">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="leg:TitleBlock/leg:SubTitle">
		<p class="legSubtitle">
			<xsl:apply-templates/>
		</p>

	</xsl:template>

	<xsl:template match="leg:Annex/leg:Number">

	</xsl:template>

	<xsl:template match="leg:Annex/leg:Number">
		
	</xsl:template>	
	
	
	<xsl:template match="leg:Reference">
		<p class="ENLegArticleRef">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!-- ========== Footnotes ========== -->

	<xsl:template match="leg:Footnotes">
		<div class="LegFootnotes">
			<div class="LegClearFix LegFootnotesContainer">
				<xsl:apply-templates select="* | processing-instruction()"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="leg:Footnote">
		<div class="LegClearFix LegFootnote" id="{@id}">

			<div class="LegFootnoteNoContainer">
				<xsl:attribute name="class">
					<xsl:choose>
						<!-- Standard footnote -->
						<xsl:when test="ancestor::leg:Footnotes">LegFootnoteNoContainer</xsl:when>
						<!-- Table footnote -->
						<xsl:otherwise>LegTableFootnoteNoContainer</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:choose>
					<!-- Standard footnote -->
					<xsl:when test="ancestor::leg:Footnotes">
						<xsl:choose>
							<xsl:when test="leg:Number">
								<span class="LegFootnoteNo">
									<xsl:apply-templates select="leg:Number/node()"/>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<!--<xsl:text>(</xsl:text>-->
								<span class="LegFootnoteNo">
									<xsl:value-of select="count(preceding-sibling::leg:Footnote) + 1"/>
								</span>
								<!--<xsl:text>)</xsl:text>-->
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!-- Table footnote -->
					<xsl:otherwise>
						<xsl:variable name="strTfootID" select="generate-id(ancestor::xhtml:tfoot)"/>
						<xsl:variable name="intFootnoteNo" select="count(preceding::leg:Footnote[generate-id(ancestor::xhtml:tfoot) = $strTfootID]) + 1"/>
						<sup class="ENTableFootnoteNo">
							<xsl:choose>
								<xsl:when test="leg:Number">
									<xsl:apply-templates select="leg:Number/node() | processing-instruction()"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="FuncGenerateTableFootnoteNo">
										<xsl:with-param name="intFootnoteNo" select="$intFootnoteNo"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</sup>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<xsl:apply-templates select="*[not(self::leg:Number)] | processing-instruction()"/>
		</div>
	</xsl:template>

	<xsl:template match="leg:FootnoteText">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</xsl:template>

	<xsl:template match="leg:FootnoteRef">
		<!-- Due to the fact that footnote numbers in legislation restart numbering on each page we have to change the way this is down for HTML output for normal footnotes-->
		<!-- Therefore we will output as a numbered seqeunce -->
		<!--<xsl:call-template name="FuncCheckForStartOfQuote"/>-->
		<xsl:choose>
			<!-- Standard footnote -->
			<xsl:when test="$g_ndsFootnotes[@id = current()/@Ref]/ancestor::leg:Footnotes">
				<xsl:if test="not( starts-with(following-sibling::text()[1], ')' ))">
					<xsl:text>(</xsl:text>
				</xsl:if>
				<xsl:call-template name="FuncGenerateFootnoteLink"/>
				<xsl:if test="not( starts-with(following-sibling::text()[1], ')' ))">
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:when>
			<!-- Table footnote -->
			<xsl:otherwise>
				<sup class="ENTableFootnoteRef">
					<xsl:call-template name="FuncGenerateFootnoteLink"/>
				</sup>
			</xsl:otherwise>
		</xsl:choose>
		<!--<xsl:call-template name="FuncCheckForEndOfQuote"/>-->
	</xsl:template>

	<xsl:template name="FuncGenerateFootnoteLink">
		<xsl:variable name="strFootnoteNo">
			<xsl:choose>
				<!-- Automatic footnote numbering overridden -->
				<xsl:when test="$g_ndsFootnotes[@id = current()/@Ref]/leg:Number">
					<xsl:value-of select="$g_ndsFootnotes[@id = current()/@Ref]/leg:Number"/>
				</xsl:when>
				<!-- Standard footnote -->
				<xsl:when test="$g_ndsFootnotes[@id = current()/@Ref]/ancestor::leg:Footnotes">
					<xsl:value-of select="count($g_ndsFootnotes[@id = current()/@Ref]/preceding-sibling::leg:Footnote) + 1"/>
				</xsl:when>
				<!-- Table footnote -->
				<xsl:otherwise>
					<xsl:variable name="strTfootID" select="generate-id($g_ndsFootnotes[@id = current()/@Ref]/ancestor::xhtml:tfoot)"/>
					<xsl:variable name="intFootnoteNo" select="count($g_ndsFootnotes[@id = current()/@Ref]/preceding::leg:Footnote[generate-id(ancestor::xhtml:tfoot) = $strTfootID]) + 1"/>
					<xsl:call-template name="FuncGenerateTableFootnoteNo">
						<xsl:with-param name="intFootnoteNo" select="$intFootnoteNo"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<a class="LegFootnoteRef" href="#{@Ref}" title="Go to footnote {$strFootnoteNo}">
			<!-- In case there are multiple cross-references to the same footnote only provide a single point for the back function -->
			<xsl:if test="not(preceding-sibling::leg:FootnoteRef[@Ref = current()/@Ref] or preceding::leg:FootnoteRef[@Ref = current()/@Ref])">
				<xsl:attribute name="id">
					<xsl:text>Back</xsl:text>
					<xsl:value-of select="@Ref"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$strFootnoteNo"/>
		</a>
	</xsl:template>

	<!-- Generate table footnote number -->
	<xsl:template name="FuncGenerateTableFootnoteNo">
		<xsl:param name="intFootnoteNo" select="1"/>
		<xsl:variable name="strFootnoteCharacter" select="substring('abcdefghijlkmnopqrstuvwxyz', $intFootnoteNo, 1)"/>
		<xsl:value-of select="$strFootnoteCharacter"/>
	</xsl:template>





	<!-- ========== Abbreviations ========== -->

	<xsl:template match="leg:Abbreviation">
		<abbr title="{@Expansion}">
			<xsl:apply-templates/>
		</abbr>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>
	</xsl:template>

	<xsl:template match="leg:Acronym">
		<acronym title="{@Expansion}">
			<xsl:apply-templates/>
		</acronym>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>
	</xsl:template>


	<!-- ========== Citations =========== -->

	<xsl:template match="leg:Citation">
		<xsl:apply-templates/>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>
	</xsl:template>

	<xsl:template match="leg:CitationSubRef">
		<xsl:choose>
			<xsl:when test="ancestor::leg:Title and starts-with(@URI, 'http://www.legislation.gov.uk/id')">
				<a href="{$TranslateLangPrefix}{substring-after(@URI, 'http://www.legislation.gov.uk/id')}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>
	</xsl:template>


	<!-- ========== Images ========== -->

	<xsl:template match="leg:Figure">
		<div>
			<xsl:attribute name="id">
				<xsl:call-template name="FuncGenerateAnchorID"/>
			</xsl:attribute>
			<xsl:apply-templates select="* | processing-instruction()"/>
		</div>
	</xsl:template>

	<xsl:template match="leg:Figure/leg:Number">
		<p class="ENFigureNumber">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="leg:Figure/leg:Title">
		<p class="ENFigureTitle">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="leg:Image">

		<xsl:variable name="strDisplayFormat">
			<xsl:choose>
				<xsl:when test="parent::leg:Figure">Display</xsl:when>
				<xsl:otherwise>Inline</xsl:otherwise>
			</xsl:choose>
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

		<!--<xsl:call-template name="FuncCheckForStartOfQuote"/>-->

		<xsl:call-template name="FuncCheckForIDelement"/>

		<xsl:apply-templates select="$g_ndsResources[@id = current()/@ResourceRef]">
			<xsl:with-param name="strContext" select="'Image'"/>
			<xsl:with-param name="strDisplayFormat" select="$strDisplayFormat"/>
			<xsl:with-param name="strAltAttributeDesc" select="$strAltAttributeDesc"/>
			<xsl:with-param name="dblWidth" select="@Width"/>
			<xsl:with-param name="dblHeight" select="@Height"/>
		</xsl:apply-templates>
		<!--<xsl:call-template name="FuncCheckForEndOfQuote"/>-->

	</xsl:template>

	<xsl:template name="FuncProcessImage">
		<!-- Indicates if the containing markup is attempting to display the image 'Display' or 'Inline' -->
		<xsl:param name="strDisplayFormat" select="'Inline'"/>
		<!-- Passes in the text to be used for the alt attribute for the image element -->
		<xsl:param name="strAltAttributeDesc"/>
		<!-- Passed in the width of the image -->
		<xsl:param name="dblWidth"/>
		<!-- Passed in the height of the image -->
		<xsl:param name="dblHeight"/>
		<xsl:param name="strContext"/>

		<!-- Check if the image format is in the configuration output file.  If it is then get the output format, otherwise just pass thorugh the input format.  N.B.  Use the file extension and not the Format attribute -->
		<xsl:variable name="strImageFormat" select="substring-after(@URI, '.')"/>
		<xsl:variable name="strOutputFormat" select="$g_ndsLegisConfigDoc//format[@input = $strImageFormat]/@output"/>
		<xsl:variable name="strFilename">
			<xsl:choose>
				<xsl:when test="$g_flConvertImageExtensions">
					<xsl:choose>
						<xsl:when test="normalize-space($strOutputFormat)">
							<xsl:value-of select="concat(substring-before(@URI, '.'), '.gif')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@URI"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@URI"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<img src="{$g_strDocumentImagesPath}{$strFilename}" alt="{$strAltAttributeDesc}" title="{$strAltAttributeDesc}">
			<xsl:choose>
				<xsl:when test="$strDisplayFormat = 'Display'">
					<xsl:attribute name="class">ENDisplayImage</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">ENInlineImage</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<!-- We will make no attemp to convert the units - they will simply be passed through -->
			<xsl:if test="number($dblWidth) != 0 and $dblWidth != '' and $dblWidth != 'auto'">
				<xsl:attribute name="width">
					<xsl:value-of select="$dblWidth"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="number($dblHeight) != 0 and $dblHeight != '' and $dblHeight != 'auto'">
				<xsl:attribute name="height">
					<xsl:value-of select="$dblHeight"/>
				</xsl:attribute>
			</xsl:if>
		</img>
	</xsl:template>


	<!-- ========== Included documents ========== -->

	<xsl:template match="leg:IncludedDocument">
		<!--<xsl:call-template name="FuncCheckForStartOfQuote"/>-->
		<!-- Do it this way because we may be in a version -->
		<xsl:apply-templates select="//leg:Resource[@id = current()/@ResourceRef]">
			<xsl:with-param name="strContext">
				<xsl:choose>
					<xsl:when test="ancestor::leg:Form">Form</xsl:when>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="strDisplayFormat" select="'Display'"/>
			<xsl:with-param name="strAltAttributeDesc" select="."/>
		</xsl:apply-templates>
		<!--<xsl:call-template name="FuncCheckForEndOfQuote"/>-->
	</xsl:template>


	<!-- ========== Decorated groups ========== -->

	<xsl:template match="leg:DecoratedGroup">
		<div class="ENDecoratedGroupLeft">
			<xsl:apply-templates select="child::*[1] | processing-instruction()"/>
		</div>
		<xsl:if test="child::*[1][self::leg:GroupItem]">
			<div class="ENDecoratedGroupRight">
				<xsl:apply-templates select="child::*[2]"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:GroupItem">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</xsl:template>

	<xsl:template match="leg:GroupItemRef"/>


	<!-- ========== Inline formatting ========== -->

	<xsl:template match="leg:Strike">
		<del>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:apply-templates/>
		</del>
	</xsl:template>

	<xsl:template match="leg:Strong">
		<strong>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:apply-templates/>
		</strong>
	</xsl:template>

	<xsl:template match="leg:Emphasis">
		<em>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:apply-templates/>
		</em>
	</xsl:template>

	<xsl:template match="leg:Underline">
		<u>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:apply-templates/>
		</u>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>
	</xsl:template>

	<xsl:template match="leg:Superior">
		<sup>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:apply-templates/>
		</sup>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>	
	</xsl:template>

	<!-- If Superior appears as the first child of it's parent, is within FootnoteText, and is a number, we want to suppress it as it is the footnote number that has crept in -->
	<xsl:template match="leg:Superior[ancestor::leg:FootnoteText]" priority="1">
		<xsl:choose>
			<xsl:when test="ancestor::leg:Text[not(preceding-sibling::*)] and parent::*[child::*[1] = current()] and number(.)" />
			<xsl:otherwise>
				<sup>
					<xsl:call-template name="FuncCheckForID"/>
					<xsl:apply-templates/>
				</sup>
				<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
				<xsl:call-template name="FuncIsLastElementInFootnote"/>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Footnote references in Superior should be output in normal font. Also, extraneous text should not be output -->
	<xsl:template match="leg:Superior[leg:FootnoteRef]" priority="1">
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates select="leg:FootnoteRef"/>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>	
	</xsl:template>

	<xsl:template match="leg:Inferior">
		<sub>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:apply-templates/>
		</sub>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>
	</xsl:template>

	<xsl:template match="leg:SmallCaps">
		<span class="ENSmallcaps">
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:apply-templates/>
		</span>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>
	</xsl:template>

	<xsl:template match="leg:Note">
		<span class="ENNote">
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:apply-templates/>
		</span>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>
	</xsl:template>

	<xsl:template match="leg:Span">
		<xsl:call-template name="FuncCheckForIDnoElement"/>
		<xsl:apply-templates/>
	</xsl:template>


	<!-- ========== Internal Link ========== -->

	<xsl:template match="leg:InternalLink">
		<!-- First calculate the title that is to be displayed in the tool tip of this link. -->
		<xsl:variable name="strLinkRef" select="@Ref"/>
		<xsl:variable name="ndsTargetElement" select="//*[@id = $strLinkRef]"/>
		<xsl:variable name="strTargetElementName" select="name($ndsTargetElement)"/>
		<xsl:variable name="strTitlePrefix">
			<xsl:text>Go to </xsl:text>
		</xsl:variable>
		<!-- If the target link is a heading element itself, then get the text nodes for the Number (the heading itself) - not any formatting which may exist in that element. -->
		<xsl:variable name="strHeadingSectionFormat">
			<xsl:choose>
				<xsl:when test="$strTargetElementName = 'Schedule' or $strTargetElementName = 'Group' or $strTargetElementName = 'Part' or $strTargetElementName = 'Chapter'">
					<xsl:value-of select="$ndsTargetElement/leg:Number/descendant::text()"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- The target link is NOT a heading element, so this needs formatting. -->
					<xsl:if test="name($ndsTargetElement) = 'P1'">
						<xsl:call-template name="FuncFormatParagraphNumberForInternalLink">
							<xsl:with-param name="ndsNumberNode" select="$ndsTargetElement/leg:Pnumber"/>
						</xsl:call-template>
						<xsl:if test="$g_strDocumentType = $g_strPrimary">
							<xsl:text/>
							<xsl:value-of select="$ndsTargetElement/parent::leg:P1group/leg:Title"/>
							<xsl:text/>
						</xsl:if>
					</xsl:if>
					<xsl:if test="$ndsTargetElement/ancestor::*[self::leg:P1 or self::leg:BlockAmendment or self::leg:ListItem][last()][self::leg:P1]">
						<xsl:call-template name="FuncFormatParagraphNumberForInternalLink">
							<xsl:with-param name="ndsNumberNode" select="$ndsTargetElement/ancestor::leg:P1[last()]/leg:Pnumber"/>
						</xsl:call-template>
						<xsl:if test="$g_strDocumentType = $g_strPrimary">
							<xsl:text/>
							<xsl:value-of select="$ndsTargetElement/ancestor::leg:P1group/leg:Title"/>
							<xsl:text/>
						</xsl:if>
					</xsl:if>
					<xsl:if test="$ndsTargetElement/ancestor::*[self::leg:P2 or self::leg:BlockAmendment or self::leg:ListItem][last()][self::leg:P2]">
						<xsl:call-template name="FuncFormatParagraphNumberForInternalLink">
							<xsl:with-param name="ndsNumberNode" select="$ndsTargetElement/ancestor::leg:P2[last()]/leg:Pnumber"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$ndsTargetElement[self::leg:P4 or self::leg:P5 or self::leg:P6] and $ndsTargetElement/ancestor::*[self::leg:P3 or self::leg:BlockAmendment or self::leg:ListItem][last()][self::leg:P3]">
						<xsl:call-template name="FuncFormatParagraphNumberForInternalLink">
							<xsl:with-param name="ndsNumberNode" select="$ndsTargetElement/ancestor::leg:P3[last()]/leg:Pnumber"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$ndsTargetElement[self::leg:P5 or self::leg:P6] and $ndsTargetElement/ancestor::*[self::leg:P4 or self::leg:BlockAmendment or self::leg:ListItem][last()][self::leg:P4]">
						<xsl:call-template name="FuncFormatParagraphNumberForInternalLink">
							<xsl:with-param name="ndsNumberNode" select="$ndsTargetElement/ancestor::leg:P4[last()]/leg:Pnumber"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$ndsTargetElement[self::leg:P6] and $ndsTargetElement/ancestor::*[self::leg:P5 or self::leg:BlockAmendment or self::leg:ListItem][last()][self::leg:P5]">
						<xsl:call-template name="FuncFormatParagraphNumberForInternalLink">
							<xsl:with-param name="ndsNumberNode" select="$ndsTargetElement/ancestor::leg:P5[last()]/leg:Pnumber"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$ndsTargetElement[not(self::leg:P1)]">
						<xsl:call-template name="FuncFormatParagraphNumberForInternalLink">
							<xsl:with-param name="ndsNumberNode" select="$ndsTargetElement/leg:Pnumber"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Check if the target link sits in a major structure, i.e. there is a Schedule, Chapter or Part. If there is a BlockAmendment in the XPath, then only take the path before it.
			In the case that there is a BlockAmendment, concatenate a string to indicate this to the end of the title. -->
		<!-- 	If the target link is in major structure, then the ancestor trail needs to be determined. -->
		<xsl:variable name="strMajorStructureSuffix">
			<xsl:if test="$ndsTargetElement/ancestor::*[self::leg:Schedule or self::leg:Chapter or self::leg:Part or self::leg:Group]">
				<xsl:text> in </xsl:text>
				<xsl:call-template name="GenerateAncestorTrail">
					<xsl:with-param name="ndsCurrentNode" select="$ndsTargetElement"/>
					<xsl:with-param name="strSeparator" select="', '"/>
					<xsl:with-param name="strMode" select="'NOID'"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="strBlockAmendmentSuffix">
			<xsl:if test="$ndsTargetElement/ancestor::BlockAmendment">
				<xsl:text> (as part of an amendment)</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="strTitleText">
			<!-- If the target link is a heading, then it won't be in a P1, P2, etc.. element, so that does not need to be processed. -->
			<xsl:value-of select="concat($strTitlePrefix, $strHeadingSectionFormat, $strMajorStructureSuffix, $strBlockAmendmentSuffix)"/>
		</xsl:variable>
		<a>
			<xsl:attribute name="href">
				<xsl:text>#</xsl:text>
				<xsl:variable name="strIDref" select="@Ref"/>
				<xsl:for-each select="key('g_keyNodeIDs', $strIDref)">
					<xsl:call-template name="FuncGenerateAnchorID"/>
				</xsl:for-each>
			</xsl:attribute>
			<xsl:if test="normalize-space($strTitleText)">
				<xsl:attribute name="title">
					<xsl:value-of select="$strTitleText"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</a>
	</xsl:template>


	<!-- ========== External Link - non legislation items ========== -->

	<xsl:template match="leg:ExternalLink">
		<a href="{@URI}">
			<xsl:if test="@Title">
				<xsl:attribute name="title">
					<xsl:value-of select="@Title"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</a>
		<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
		<xsl:call-template name="FuncIsLastElementInFootnote"/>
	</xsl:template>


	<!-- ========== Characters ========== -->

	<xsl:template match="leg:Character">
		<xsl:choose>
			<xsl:when test="@Name = 'DotPadding'">
				<xsl:text> ... ... ... ...</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'ThinSpace'">
				<xsl:text>&#160;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'LinePadding'">
				<!--<span style="color: red">LINE PADDING TO SORT OUT</span>-->
			</xsl:when>
			<xsl:when test="@Name = 'NonBreakingSpace'">
				<xsl:text>&#160;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'EnSpace'">
				<xsl:text>&#160;&#160;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'EmSpace'">
				<xsl:text>&#160;&#160;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<span style="color: red">CHARACTER TO SORT OUT</span>
			</xsl:otherwise>
		</xsl:choose>
		<!--<xsl:call-template name="FuncCheckForEndOfQuote"/>-->	
	</xsl:template>


	<!-- ========== Text ========== -->

	<xsl:template match="*">
		<xsl:choose>
			<xsl:when test="self::xhtml:meta or self::xhtml:img">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:call-template name="FuncTextPreOperations"/>

		<!-- Check if text node is in a language other than English -->
		<xsl:variable name="strLanguage">
			<xsl:if test="ancestor::*[@xml:lang][@xml:lang != 'en' or ancestor::*[@xml:lang][1][@xml:lang != 'en']]">
				<xsl:value-of select="ancestor::*[@xml:lang][1]/@xml:lang"/>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$strLanguage != ''">
				<span lang="{$strLanguage}" xml:lang="{$strLanguage}">
					<!-- Check that if there are any characters that can not be rendered correctly.  If this is the case then these need to be replaced with corresponding images. -->
					<xsl:call-template name="FuncProcessTextForUnicodeChars">
						<xsl:with-param name="strText">
							<xsl:call-template name="FuncNormalizeSpace">
								<xsl:with-param name="strString" select="." />
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<!-- Check that if there are any characters that can not be rendered correctly.  If this is the case then these need to be replaced with corresponding images. -->
				<xsl:call-template name="FuncProcessTextForUnicodeChars">
					<xsl:with-param name="strText">
						<xsl:call-template name="FuncNormalizeSpace">
							<xsl:with-param name="strString" select="." />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>		
			</xsl:otherwise>
		</xsl:choose>

		<xsl:call-template name="FuncTextPostOperations"/>

	</xsl:template>

	<xsl:template match="comment()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template name="FuncTextPreOperations">
		<!--<xsl:call-template name="FuncCheckForStartOfQuote"/>-->

		<!-- Output generated text around paragraph numbers in legislation extracts -->
		<xsl:if test="ancestor::leg:Pnumber[parent::leg:P2 or parent::leg:P3 or parent::leg:P4 or parent::leg:P5]">
			<xsl:text>(</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="FuncTextPostOperations">

		<!-- Output generated text around paragraph numbers -->
		<xsl:choose>
			<!-- Legislation extracts -->
			<xsl:when test="ancestor::leg:Pnumber[parent::leg:P2 or parent::leg:P3 or parent::leg:P4 or parent::leg:P5]">
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="ancestor::leg:Pnumber">
					<xsl:text>.</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>



		<!--<xsl:call-template name="FuncCheckForEndOfQuote"/>-->

		<!-- Check if  last node in a footnote in which case output back link if a standard footnote -->
		<xsl:if test="not(ancestor::leg:Citation or ancestor::leg:CitationSubRef or ancestor::leg:InternalLink or ancestor::leg:ExternalLink or ancestor::leg:Acronym or ancestor::leg:Abbreviation or ancestor::leg:Definition or ancestor::leg:Proviso or ancestor::leg:Superior or ancestor::leg:Inferior or ancestor::leg:SmallCaps or ancestor::leg:Underline) and ancestor::leg:Footnote[not(ancestor::xhtml:table)] and generate-id(ancestor::leg:Footnote[1]/descendant::text()[not(normalize-space() = '')][last()]) = generate-id()">
			<xsl:call-template name="FuncCheckForBackReference"/>
		</xsl:if>

		<!-- For primary legislation some amendments run on from the prevoius paragraph. Also allow it for very rare instances of secondary legislation where PartialRefs forces it -->
		<xsl:if test="($g_strDocumentType = $g_strPrimary or ancestor::leg:Text[1]/following-sibling::*[1][self::leg:BlockAmendment[string(@PartialRefs) != '']]/child::*[1][self::leg:Text]) and generate-id(ancestor::leg:Text[1]/descendant::text()[not(normalize-space() = '')][last()]) = generate-id()">
			<xsl:if test="ancestor::leg:Text[1]/following-sibling::*[1][self::leg:BlockAmendment]/child::*[1][self::leg:Text]">
				<xsl:text/>
				<span class="ENRunOnAmendment">
					<xsl:apply-templates select="ancestor::leg:Text[1]/following-sibling::*[1][self::leg:BlockAmendment]/child::*[1]/node() | processing-instruction()"/>
				</span>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<!-- For primary legislation we need to check if amending a schedule as output is different from body text -->
	<xsl:template name="FuncGetScheduleContext">
		<!-- In the unusual example that we have a BlockAmendment containing a P1 in primary legislation with no context then assume it is amending a schedule as main does not make sense -->
		<xsl:variable name="strIsInP1">
			<xsl:if test="$g_strDocumentType = $g_strPrimary and ancestor::*[self::leg:P1 or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:P1]">
				<xsl:choose>
					<xsl:when test="ancestor::leg:P1[1]/parent::leg:BlockAmendment[@Context = 'unknown' and @TargetClass != 'secondary']">Schedule</xsl:when>
					<xsl:when test="ancestor::leg:P1[1]/parent::*[self::leg:Pblock or self::leg:Chapter or self::leg:Part or self::leg:Group]/parent::leg:BlockAmendment[@Context = 'unknown' and @TargetClass != 'secondary']">Schedule</xsl:when>
					<xsl:when test="ancestor::leg:P1[1]/parent::*[self::leg:PsubBlock or self::leg:Pblock or self::leg:Chapter]/parent::*[self::leg:Pblock or self::leg:Chapter or self::leg:Part or self::leg:Group]/parent::leg:BlockAmendment[@Context = 'unknown' and @TargetClass != 'secondary']">Schedule</xsl:when>
					<xsl:when test="ancestor::leg:P1[1]/parent::*[self::leg:PsubBlock or self::leg:Pblock]/parent::*[self::leg:PsubBlock or self::leg:Pblock or self::leg:Chapter]/parent::*[self::leg:Pblock or self::leg:Chapter or self::leg:Part or self::leg:Group]/parent::leg:BlockAmendment[@Context = 'unknown' and @TargetClass != 'secondary']">Schedule</xsl:when>
					<xsl:when test="ancestor::leg:P1[1]/parent::leg:PsubBlock/parent::leg:Pblock/parent::leg:Chapter/parent::*[self::leg:Part or self::leg:Group]/parent::leg:BlockAmendment[@Context = 'unknown' and @TargetClass != 'secondary']">Schedule</xsl:when>		
					<xsl:when test="ancestor::leg:P1[1]/parent::leg:PsubBlock/parent::leg:Pblock/parent::leg:Chapter/parent::leg:Part/parent::leg:Group/parent::leg:BlockAmendment[@Context = 'unknown' and @TargetClass != 'secondary']">Schedule</xsl:when>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$strIsInP1 = 'Schedule' or ($g_strDocumentType = $g_strPrimary and ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule']])">
			<xsl:text>S</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- From legislation_xhtml_core_vanilla.xslt - reproduction of legislation extracts -->
	<xsl:template match="leg:P1para/leg:Text | leg:P2para/leg:Text | leg:P3para/leg:Text | leg:P4para/leg:Text | leg:P5para/leg:Text">
		<!-- Generate suffix to be added for CSS classes for amendments -->
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<!-- For primary legislation the indent of content is dependent upon its parent for amendments therefore we need more information if the parent is lower level than the content being amended -->
		<xsl:choose>
			<!-- For some amendments text runs on from the previous paragraph so we need to suppress that text here. Also allow it for very rare instances of secondary legislation where PartialRefs forces it -->
			<xsl:when test="($g_strDocumentType = $g_strPrimary or (string(@id) != '' and contains(ancestor::leg:BlockAmendment[1]/@PartialRefs, @id))) and generate-id(ancestor::leg:BlockAmendment[1]/descendant::*[1]) = generate-id()"/>
			<!-- Combined N2-N3 or N2-N4 or N2-N3-N4 paragraph -->
			<xsl:when test="parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P2para/preceding-sibling::*[1][self::leg:Pnumber]
			or parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P2para/preceding-sibling::*[1][self::leg:Pnumber]
			or parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P2para/preceding-sibling::*[1][self::leg:Pnumber]">
				<p class="{concat('ENLegP2ParaText', $strAmendmentSuffix)}">
					<xsl:call-template name="FuncCheckForID"/>
					<xsl:call-template name="FuncGetLocalTextStyle"/>
					<xsl:call-template name="FuncGetTextClass">
						<xsl:with-param name="flMode" select="'Block'"/>
					</xsl:call-template>
					<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
				</p>

			</xsl:when>
			<!-- Numbered paragraphs using hanging indent so we need to process them in a special manner -->
			<!-- For secondary legislation we need to make sure that we dont pick up N1-N3 or N1-N3-N4 (both very rare) -->
			<xsl:when test="not(preceding-sibling::*)
			and parent::*[(self::leg:P2para and $g_strDocumentType = $g_strPrimary) 
			or (self::leg:P1para and ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or (@Context = 'unknown' and not(descendant::leg:P1group))]] and $g_strDocumentType = $g_strPrimary)
			or self::leg:P3para[not($g_strDocumentType = $g_strSecondary and preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P1para/preceding-sibling::*[1][self::leg:Pnumber])]
			or self::leg:P4para[not($g_strDocumentType = $g_strSecondary and preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P1para/preceding-sibling::*[1][self::leg:Pnumber])]
			or self::leg:P5para or self::leg:P6para or self::leg:P7para]/preceding-sibling::*[1][self::leg:Pnumber]">
				<!-- Calculate if in a primary schedule -->
				<xsl:variable name="strScheduleContext">
					<xsl:call-template name="FuncGetScheduleContext"/>
				</xsl:variable>
				<!--<xsl:variable name="strScheduleNestedContext">
				<xsl:call-template name="FuncGetScheduleNestedAmendmentContext"/>
				</xsl:variable>-->
				<p class="ENClearFix {concat('ENLeg', $strScheduleContext, name(parent::*/parent::*), 'Container')}">
					<xsl:call-template name="FuncCheckForID"/>

					<xsl:choose>
						<!-- Combined N3-N4 paragraph -->
						<xsl:when test="parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]">
							<span class="ENDS ENLHS {concat('ENLegN3No', $strAmendmentSuffix)}">
								<xsl:for-each select="parent::*/parent::*/parent::*/preceding-sibling::leg:Pnumber">
									<xsl:call-template name="FuncCheckForID"/>
									<xsl:apply-templates select="@* | node()"/>
								</xsl:for-each>
							</span>
							<span class="ENDS ENLHS ENLegN4No">
								<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
									<xsl:call-template name="FuncCheckForID"/>
									<xsl:apply-templates select="@* | node()"/>
								</xsl:for-each>
							</span>
						</xsl:when>
						<!-- Combined N4-N5 paragraph -->
						<xsl:when test="parent::leg:P5para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P5[not(preceding-sibling::*)]/parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]">
							<span class="ENDS ENLHS {concat('ENLegN4N5No', $strAmendmentSuffix)}">
								<xsl:for-each select="parent::*/parent::*/parent::*/preceding-sibling::leg:Pnumber">
									<xsl:call-template name="FuncCheckForID"/>
									<xsl:apply-templates select="@* | node()"/>
								</xsl:for-each>
							</span>
							<span class="ENDS ENLHS ENLegN5No">
								<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
									<xsl:call-template name="FuncCheckForID"/>
									<xsl:apply-templates select="@* | node()"/>
								</xsl:for-each>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<!-- For primary legislation ... -->
							<!-- If in a schedule and a combined N1-N2 then output N1 number. -->
							<!-- If context is unknown and BlockAmendment does not contain P1group then assume it is a schedule amendment as an amendment to a P1 in the body does not make any sense or if TargetClass is secondary apply similar logic (as secondary gets formatted like primary) -->
							<!-- Also if the below functionality has been invoked then handle that too -->
							<xsl:choose>					
								<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P2para and (ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or ((@Context = 'unknown' or @TargetClass = 'secondary') and not(descendant::leg:P1group))]] or (ancestor::leg:P1group/@Layout = 'below' and
								generate-id(ancestor::leg:P1group[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber or ancestor::leg:Title)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps]) = generate-id(node()[not(self::processing-instruction())][1]))) and
								generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1] or ancestor::leg:Title/parent::leg:P2group)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]) and
								generate-id(ancestor::leg:P2[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1])">
									<span class="ENDS {concat('ENLegSN1No', $strAmendmentSuffix)}">
										<xsl:for-each select="ancestor::leg:P1[1]/leg:Pnumber">
											<xsl:call-template name="FuncCheckForID"/>
											<xsl:apply-templates select="@* | node()"/>
										</xsl:for-each>									
									</span>
									<span class="ENDS {concat('ENLegSN2No', $strAmendmentSuffix)}">
										<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
											<xsl:call-template name="FuncCheckForID"/>
											<xsl:apply-templates select="@* | node()"/>
										</xsl:for-each>
									</span>
								</xsl:when>
								<!-- P1-P3 -->
								<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P3para[not(ancestor::*[self::leg:P2para or self::leg:BlockAmendment][1][self::leg:P2para])] and (ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or ((@Context = 'unknown' or @TargetClass = 'secondary') and not(descendant::leg:P1group))]] or (ancestor::leg:P1group/@Layout = 'below' and generate-id(ancestor::leg:P1group[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber or ancestor::leg:Title)]  or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps]) = generate-id(node()[not(self::processing-instruction())][1]))) and
								generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1] or ancestor::leg:Title/parent::leg:P3group)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]) and
								generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1])">
									<span class="ENDS ENLHS {concat('ENLegP1No', $strAmendmentSuffix)}">
										<xsl:for-each select="ancestor::leg:P1[1]/leg:Pnumber">
											<xsl:call-template name="FuncCheckForID"/>
											<xsl:apply-templates select="@* | node()"/>
										</xsl:for-each>									
									</span>
									<span class="ENDS {concat('ENLegSN1N3No', $strAmendmentSuffix)}">
										<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
											<xsl:call-template name="FuncCheckForID"/>
											<xsl:apply-templates select="@* | node()"/>
										</xsl:for-each>
									</span>
								</xsl:when>
								<!-- Special handling for P1 numbers in schedules in primary legislation -->
								<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P1para">
									<span class="ENDS ENLHS {concat('ENLegP1No', $strAmendmentSuffix)}">
										<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
											<xsl:call-template name="FuncCheckForID"/>
											<xsl:apply-templates select="@* | node()"/>
										</xsl:for-each>
									</span>
								</xsl:when>
								<xsl:otherwise>
									<span class="ENDS ENLHS {concat('ENLeg', name(parent::*/parent::*), 'No', $strAmendmentSuffix)}">
										<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
											<xsl:call-template name="FuncCheckForID"/>
											<xsl:apply-templates select="@* | node()"/>
										</xsl:for-each>
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<span class="Text">
						<xsl:call-template name="FuncGetLocalTextStyle"/>
						<xsl:call-template name="FuncGetTextClass"/>
						<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
					</span>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not(ancestor::leg:MarginNote)">
					<p class="{concat('LegText', $strAmendmentSuffix)}">
						<xsl:call-template name="FuncCheckForID"/>
						<xsl:call-template name="FuncGetLocalTextStyle"/>
						<xsl:call-template name="FuncGetTextClass">
							<xsl:with-param name="flMode" select="'Block'"/>
						</xsl:call-template>
						<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
					</p>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:Text">
		<xsl:choose>


			<!-- There is only one paragraph level in the Explanatory Notes -->
			<xsl:when test="parent::leg:Para/parent::leg:NumberedPara/leg:Pnumber and not(preceding-sibling::leg:Text)">
				<p class="ENNumParaContainer">
					<xsl:if test="parent::*[preceding-sibling::*[1][self::leg:Pnumber]]">
						<xsl:attribute name="id">
							<!-- Add semantic id from the Legislation XML -->
							<xsl:call-template name="TSO_FuncGenerateENCommentaryLinkID" >
								<xsl:with-param name="ndContextNode" select="parent::leg:Para/parent::leg:NumberedPara" />
							</xsl:call-template>
							<!--<xsl:text>p</xsl:text>
						<xsl:value-of select="parent::*/parent::leg:NumberedPara/leg:Pnumber"/>-->
						</xsl:attribute>
						<span class="ENDS ENLHS ENNumParaNo">
							<xsl:call-template name="FuncCheckForID"/>
							<xsl:apply-templates select="parent::*/preceding-sibling::*[1]/self::leg:Pnumber"/>
						</span>
					</xsl:if>
					<span class="ENDS ENRHS ENNumParaText">
						<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
					</span>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not(ancestor::leg:MarginNote)">
					<p class="ENDS ENRHS ENNumParaText">
						<xsl:call-template name="FuncCheckForID"/>
						<xsl:call-template name="FuncGetLocalTextStyle"/>
						<xsl:call-template name="FuncGetTextClass">
							<xsl:with-param name="flMode" select="'Block'"/>
						</xsl:call-template>
						<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
					</p>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- ========== Functions ========== -->

	<!-- Generate suffix to be added for CSS classes for amendments and output paragraph number if inline with text -->
	<!-- This predominantly handles legislation extracts within ENs, and we use the CSS class ENLeg... for these -->
	<xsl:template name="FuncGetTextClass">
		<!-- If flMode = 'Block' then this is being calculated for a p element -->
		<xsl:param name="flMode" select="''"/>
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<xsl:variable name="strContext">
			<xsl:call-template name="FuncGetContext"/>
		</xsl:variable>
		<xsl:variable name="intInlineNodeID" select="generate-id(descendant::node()[not(self::processing-instruction())][self::text() or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1])"/>
		<xsl:choose>
			<!-- Check if  first node in a P1-P2 in which case output P1 and P2 numbers (for secondary legislation) -->
			<xsl:when test="$g_strDocumentType = $g_strSecondary and not(ancestor::leg:P1group[1]/@Layout = 'side' or (ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])) and ancestor::leg:P1 and ancestor::leg:P2 and
				 generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1] or ancestor::leg:Title/parent::leg:P2group)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID and 
				generate-id(ancestor::leg:P2[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID">
				<xsl:attribute name="class">
					<xsl:text>ENLegP1ParaText</xsl:text>
					<xsl:if test="$strAmendmentSuffix != ''">
						<xsl:text> ENLeg</xsl:text>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:if>
				</xsl:attribute>
				<xsl:for-each select="ancestor::leg:P2[1]/leg:Pnumber">
					<xsl:call-template name="FuncCheckForIDnoElement"/>
				</xsl:for-each>
				<xsl:apply-templates select="ancestor::leg:P1[1]/leg:Pnumber"/>
				<xsl:text>&#8212;</xsl:text>
				<xsl:apply-templates select="ancestor::leg:P2[1]/leg:Pnumber"/>
				<xsl:text>&#160;</xsl:text>
				<!-- Very rare instance of combined N1-N2-N3 -->
				<xsl:if test="ancestor::*[self::leg:P3 or self::leg:BlockAmendment][1][self::leg:P3]">
					<xsl:apply-templates select="ancestor::leg:P3[1]/leg:Pnumber"/>
					<xsl:text>&#160;</xsl:text>
				</xsl:if>
			</xsl:when>
			<!-- Check if  first node in a P1-P3 in which case output P1 and P3 numbers (for secondary legislation) (very rare)-->
			<xsl:when test="$g_strDocumentType = $g_strSecondary and not(ancestor::leg:P1group[1]/@Layout = 'side' or (ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])) and ancestor::leg:P1 and
				 generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID and
				  generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID">
				<xsl:attribute name="class">
					<xsl:text>ENLegP1ParaText</xsl:text>
					<xsl:if test="$strAmendmentSuffix != ''">
						<xsl:text> ENLeg</xsl:text>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:if>
				</xsl:attribute>
				<xsl:for-each select="ancestor::leg:P3[1]/leg:Pnumber">
					<xsl:call-template name="FuncCheckForIDnoElement"/>
				</xsl:for-each>
				<xsl:apply-templates select="ancestor::leg:P1[1]/leg:Pnumber"/>
				<xsl:text>&#8212;</xsl:text>
				<xsl:apply-templates select="ancestor::leg:P3[1]/leg:Pnumber"/>
				<xsl:text>&#160;</xsl:text>
				<!-- Very rare instance of combined N1-N3-N4 (very rare) -->
				<xsl:if test="ancestor::*[self::leg:P4 or self::leg:BlockAmendment][1][self::leg:P4]">
					<xsl:apply-templates select="ancestor::leg:P4[1]/leg:Pnumber"/>
					<xsl:text>&#160;</xsl:text>
				</xsl:if>
			</xsl:when>
			<!-- Check if first node in a P1 in which case output P1 number -->
			<xsl:when test="$g_strDocumentType = $g_strSecondary and not(ancestor::leg:P1group[1]/@Layout = 'side' or (ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])) and generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID">
				<xsl:attribute name="class">
					<xsl:text>ENLegP1ParaText</xsl:text>
					<xsl:if test="$strAmendmentSuffix != ''">
						<xsl:text> ENLeg</xsl:text>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:if>
				</xsl:attribute>
				<xsl:apply-templates select="ancestor::leg:P1[1]/leg:Pnumber"/>
				<xsl:text>&#160;&#160;</xsl:text>
			</xsl:when>
			<!-- Check if first node in a P2 in which case output P2 number -->
			<xsl:when test="$g_strDocumentType  = $g_strSecondary and generate-id(ancestor::leg:P2[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID">
				<xsl:attribute name="class">
					<xsl:text>ENLegP2ParaText</xsl:text>
					<xsl:if test="$strAmendmentSuffix != ''">
						<xsl:text> ENLeg</xsl:text>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:if>
				</xsl:attribute>
				<xsl:apply-templates select="ancestor::leg:P2[1]/leg:Pnumber"/>
				<xsl:text>&#160;</xsl:text>
				<!-- Check if  first node in a P3 also which would indicate a combined N2-N3 -->
				<xsl:if test="generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID">
					<xsl:apply-templates select="ancestor::leg:P3[1]/leg:Pnumber"/>
					<xsl:text>&#160;</xsl:text>
				</xsl:if>
				<!-- Check if  first node in a P4 also which would indicate a combined N2-N4 or N2-N3-N4 (very rare) -->
				<xsl:if test="generate-id(ancestor::leg:P4[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID">
					<xsl:apply-templates select="ancestor::leg:P4[1]/leg:Pnumber"/>
					<xsl:text>&#160;</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="strClass">
					<xsl:choose>
						<xsl:when test="parent::leg:P1para and $g_strDocumentType = $g_strPrimary">
							<xsl:value-of select="concat('ENRHS ENLegP1Text', $strAmendmentSuffix)"/>
						</xsl:when>
						<!-- P2 in primary is on a hanging indent -->
						<xsl:when test="parent::leg:P2para and $g_strDocumentType = $g_strPrimary">
							<xsl:value-of select="concat('ENRHS ENLegP2Text', $strAmendmentSuffix)"/>
						</xsl:when>
						<xsl:when test="parent::leg:P2para and $g_strDocumentType != $g_strPrimary">
							<xsl:value-of select="concat('ENLegP2Text', $strAmendmentSuffix)"/>
						</xsl:when>
						<xsl:when test="parent::leg:P3para">
							<xsl:value-of select="concat('ENRHS ENLegP3Text', $strAmendmentSuffix)"/>
						</xsl:when>
						<xsl:when test="parent::leg:P4para">
							<xsl:value-of select="concat('ENRHS ENLegP4Text', $strAmendmentSuffix)"/>
						</xsl:when>
						<xsl:when test="parent::leg:P5para">
							<xsl:value-of select="concat('ENRHS ENLegP5Text', $strAmendmentSuffix)"/>
						</xsl:when>
						<xsl:when test="parent::leg:P6para">
							<xsl:value-of select="concat('ENRHS ENLegP6Text', $strAmendmentSuffix)"/>
						</xsl:when>
						<xsl:when test="parent::leg:P7para">
							<xsl:value-of select="concat('ENRHS ENLegP7Text', $strAmendmentSuffix)"/>
						</xsl:when>
						<xsl:when test="ancestor::leg:Comment">ENCommentText</xsl:when>
						<xsl:when test="ancestor::leg:Draft">ENDraftText</xsl:when>
						<xsl:when test="ancestor::leg:Correction">ENCorrectionText</xsl:when>
						<xsl:when test="ancestor::leg:Resolution">ENResolutionText</xsl:when>
						<xsl:when test="parent::*/parent::leg:BlockText">
							<xsl:for-each select="parent::*/parent::*">
								<xsl:call-template name="FuncCalcListClass"/>
							</xsl:for-each>
							<xsl:value-of select="$strAmendmentSuffix"/>
						</xsl:when>
						<xsl:when test="parent::*/parent::leg:ListItem">
							<xsl:text>ENListTextStandard </xsl:text>
							<xsl:for-each select="parent::*/parent::*">
								<xsl:call-template name="FuncCalcListClass"/>
							</xsl:for-each>
							<xsl:value-of select="$strAmendmentSuffix"/>
						</xsl:when>
						<xsl:when test="parent::leg:P/parent::leg:ExplanatoryNotes or parent::leg:P/parent::leg:EarlierOrders">ENExpNoteText</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:if test="string($strClass) != ''">
					<xsl:attribute name="class">
						<xsl:if test="$flMode != 'Block'">
							<xsl:text>ENDS </xsl:text>
						</xsl:if>
						<xsl:value-of select="$strClass"/>
					</xsl:attribute>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="FuncIsLastElementInFootnote">
		<xsl:if test="ancestor::leg:Footnote[not(ancestor::xhtml:table)] and generate-id(ancestor::leg:Footnote/descendant::text()[not(normalize-space() = '')][last()]/parent::*) = generate-id()">
			<xsl:call-template name="FuncCheckForBackReference"/>
		</xsl:if>	
	</xsl:template>

	<!-- Check to see if we need to output a back reference for a footnote -->
	<xsl:template name="FuncCheckForBackReference">
		<xsl:text/>
		<a href="#Back{ancestor::leg:Footnote/@id}" title="Back to footnote {count(ancestor::leg:Footnote/preceding-sibling::leg:Footnote) + 1}" xml:lang="en" lang="en">
			<xsl:text>Back [</xsl:text>
			<xsl:value-of select="count(ancestor::leg:Footnote/preceding-sibling::leg:Footnote) + 1"/>
			<xsl:text>]</xsl:text>
		</a>
	</xsl:template>

	<!-- Generate a internal link ancestor trail of the major headings to help user locate their position within the document -->
	<xsl:template name="GenerateAncestorTrail">
		<xsl:param name="ndsCurrentNode" select="."/>
		<xsl:param name="strSeparator" select="' ... '"/>
		<xsl:param name="strMode"/>
		<xsl:variable name="strAncestorTrail">
			<xsl:if test="$ndsCurrentNode/ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][last()][self::leg:Schedule]">
				<xsl:value-of select="$ndsCurrentNode/ancestor::leg:Schedule[last()]/leg:Number"/>
				<xsl:value-of select="$strSeparator"/>
			</xsl:if>
			<xsl:if test="$ndsCurrentNode/ancestor::*[self::leg:Group or self::leg:BlockAmendment][last()][self::leg:Group]">
				<xsl:value-of select="$ndsCurrentNode/ancestor::leg:Group[last()]/leg:Number"/>
				<xsl:value-of select="$strSeparator"/>
			</xsl:if>
			<xsl:if test="$ndsCurrentNode/ancestor::*[self::leg:Part or self::leg:BlockAmendment][last()][self::leg:Part]">
				<xsl:value-of select="$ndsCurrentNode/ancestor::leg:Part[last()]/leg:Number"/>
				<xsl:value-of select="$strSeparator"/>
			</xsl:if>
			<xsl:if test="$ndsCurrentNode/ancestor::*[self::leg:Chapter or self::leg:BlockAmendment][last()][self::leg:Chapter]">
				<xsl:value-of select="$ndsCurrentNode/ancestor::leg:Chapter[last()]/leg:Number"/>
				<xsl:value-of select="$strSeparator"/>
			</xsl:if>
		</xsl:variable>
		<!--Remove the last separator as this is at the end of the ancestor trail which is not required. -->
		<xsl:variable name="strLengthOfSeparator" select="string-length($strSeparator)"/>
		<xsl:value-of select="substring($strAncestorTrail, 1, string-length($strAncestorTrail) - $strLengthOfSeparator)"/>
	</xsl:template>

	<!-- Output the paragraph formatting in accordance to the normal paragraph numbering rules for SIs and Acts. -->
	<xsl:template name="FuncFormatParagraphNumberForInternalLink">
		<xsl:param name="ndsNumberNode"/>

		<xsl:variable name="ndsNumberTextNode" select="$ndsNumberNode/text()"/>

		<!-- Output generated text around paragraph numbers -->
		<xsl:if test="$ndsNumberNode">
			<!-- We know that the &#8212; is for a P2 in secondary legislation (if it's the first child with a P1 parent), so this can be added at the beginning -->
			<xsl:if test="not($ndsNumberNode/@PuncBefore) and $ndsNumberNode/parent::leg:P2[ancestor::leg:P1] and $g_strDocumentType = $g_strSecondary">
				<!-- This is required in this manner as this will be placed in the title attribute of an anchor and will not render with a code -->
				<xsl:text>&#8212;</xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="not($ndsNumberNode/@PuncBefore) and $ndsNumberNode/parent::leg:P1"/>
				<xsl:when test="not($ndsNumberNode/@PuncBefore)">(</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ndsNumberNode/@PuncBefore"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:value-of select="$ndsNumberNode/text()"/>
		<!-- Output generated text around paragraph numbers -->
		<xsl:if test="$ndsNumberNode">
			<xsl:choose>
				<xsl:when test="not($ndsNumberNode/@PuncAfter) and $ndsNumberNode/parent::leg:P1 and $g_strDocumentType = $g_strPrimary"/>
				<xsl:when test="not($ndsNumberNode/@PuncAfter) and $ndsNumberNode/parent::leg:P1">.</xsl:when>
				<xsl:when test="not($ndsNumberNode/@PuncAfter)">)</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ndsNumberNode/@PuncAfter"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Check if  first node in an amendment in which case output quotes -->
	<xsl:template name="FuncCheckForStartOfQuote">
		<xsl:variable name="strContext">
			<xsl:call-template name="FuncGetContext"/>
		</xsl:variable>
		<!-- This gets the ID of the first text node or applicable element in an amendment -->
		<xsl:variable name="strFirstAmendmentID" select="generate-id(ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Image][1])"/>
		<xsl:choose>
			<xsl:when test="$strFirstAmendmentID = generate-id() and not(ancestor::*[self::leg:BlockAmendment or self::leg:OrderedList][1][self::leg:OrderedList]) and not(parent::leg:Title[following-sibling::*[1][self::leg:P1]]/parent::leg:P1group/@Layout = 'side') and not(parent::leg:Title[following-sibling::*[1][self::leg:P1]] and $g_strDocumentType = $g_strPrimary and parent::leg:Title/parent::leg:P1group/parent::leg:BlockAmendment[1][@Context != 'schedule']) and not(parent::leg:Title[following-sibling::*[1][self::leg:P1]] and $g_strDocumentType = $g_strSecondary and ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])">
				<xsl:choose>
					<xsl:when test="self::leg:IncludedDocument or self::leg:Image">
						<p class="ENAmendQuoteOpen">
							<xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
						</p>
					</xsl:when>
					<xsl:otherwise>
						<span class="ENAmendQuote">
							<xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
						</span>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- Otherwise test if this is a P1group where the number of a P1 needs to be output at the side. This is tricky as the number is not the first node in the amendment - we need to check if the Title element is the first -->
			<xsl:when test="((parent::leg:Pnumber/parent::leg:P1/parent::leg:P1group[not(@Layout = 'below')]/ancestor::leg:BlockAmendment[1][@Context != 'schedule'] and $g_strDocumentType = $g_strPrimary) or (parent::leg:Pnumber/parent::leg:P1/parent::leg:P1group[not(@Layout = 'below')] and $g_strDocumentType = $g_strSecondary and ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])) and generate-id(ancestor::leg:P1[1]/preceding-sibling::leg:Title/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character][1]) = $strFirstAmendmentID">
				<span class="ENAmendQuote">
					<xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
				</span>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Check if last node in an amendment in which case output quotes -->
	<xsl:template name="FuncCheckForEndOfQuote">
		<xsl:variable name="strIsTableFootnoteAtEnd">
			<!-- Is this node in table footnotes? -->
			<xsl:if test="ancestor::xhtml:tfoot">
				<!-- Is this the last node in the footnotes? -->
				<xsl:if test="generate-id(ancestor::xhtml:tfoot[1]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()]) = generate-id()">
					<!-- Is the last node in the amendment in the same table as this footnote node in which case this is the node we want to output the quote on -->
					<xsl:if test="generate-id(ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()]/ancestor::xhtml:table) = generate-id(ancestor::xhtml:table)">
						<xsl:text>true</xsl:text>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$strIsTableFootnoteAtEnd = 'true' or generate-id(ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()]) = generate-id()">
			<xsl:choose>
				<!-- If last node of amendment is in a table body and that table has footnote do not output at this point as will need to go after footnotes -->
				<xsl:when test="not(ancestor::xhtml:tfoot) and ancestor::*[self::xhtml:table or self::leg:BlockAmendment][1][self::xhtml:table][xhtml:tfoot]"/>
				<xsl:when test="self::leg:IncludedDocument or self::leg:Image">
					<p class="ENAmendQuoteClose">
						<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
						<xsl:if test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1][self::leg:AppendText]">
							<xsl:for-each select="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1]">
								<xsl:call-template name="FuncCheckForIDnoElement"/>
								<xsl:apply-templates/>
							</xsl:for-each>
						</xsl:if>
						<xsl:call-template name="FuncCheckForEndOfNestedQuote"/>
					</p>
				</xsl:when>
				<xsl:otherwise>
					<span class="ENAmendQuote">
						<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
					</span>
					<xsl:if test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1][self::leg:AppendText]">
						<xsl:for-each select="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1]">
							<xsl:call-template name="FuncCheckForIDnoElement"/>
							<xsl:apply-templates/>
						</xsl:for-each>
					</xsl:if>
					<xsl:call-template name="FuncCheckForEndOfNestedQuote"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Check if last node in a nested amendment in which case output quotes -->
	<xsl:template name="FuncCheckForEndOfNestedQuote">
		<xsl:variable name="strIsTableFootnoteAtEnd">
			<!-- Is this node in table footnotes? -->
			<xsl:if test="ancestor::xhtml:tfoot">
				<!-- Is this the last node in the footnotes? -->
				<xsl:if test="generate-id(ancestor::xhtml:tfoot[1]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()]) = generate-id()">
					<!-- Is the last node in the amendment in the same table as this footnote node in which case this is the node we want to output the quote on -->
					<xsl:if test="generate-id(ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][2]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()]/ancestor::xhtml:table) = generate-id(ancestor::xhtml:table)">
						<xsl:text>true</xsl:text>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$strIsTableFootnoteAtEnd = 'true' or generate-id(ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][2]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()]) = generate-id()">
			<xsl:choose>
				<!-- If last node of amendment is in a table body and that table has footnote do not output at this point as will need to go after footnotes -->
				<xsl:when test="not(ancestor::xhtml:tfoot) and ancestor::*[self::xhtml:table or self::leg:BlockAmendment][2][self::xhtml:table][xhtml:tfoot]"/>
				<xsl:when test="self::leg:IncludedDocument or self::leg:Image">
					<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
					<xsl:if test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][2]/following-sibling::*[1][self::leg:AppendText]">
						<xsl:for-each select="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][2]/following-sibling::*[1]">
							<xsl:call-template name="FuncCheckForIDnoElement"/>
							<xsl:apply-templates/>
						</xsl:for-each>				
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<span class="ENAmendQuote">
						<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
					</span>
					<xsl:if test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][2]/following-sibling::*[2][self::leg:AppendText]">
						<xsl:for-each select="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][2]/following-sibling::*[1]">
							<xsl:call-template name="FuncCheckForIDnoElement"/>
							<xsl:apply-templates/>
						</xsl:for-each>				
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Work out what character to output at the start of an amendment -->
	<xsl:template name="FuncOutputAmendmentOpenQuote">
		<xsl:choose>
			<xsl:when test="ancestor::leg:BlockAmendment[1]/@Format = 'single'">
				<xsl:text>&#8216;</xsl:text>
			</xsl:when>
			<xsl:when test="ancestor::leg:BlockAmendment[1]/@Format = 'none'"/>
			<xsl:otherwise>
				<xsl:text>&#8220;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Work out what character to output at the end of an amendment -->
	<xsl:template name="FuncOutputAmendmentEndQuote">
		<xsl:choose>
			<xsl:when test="ancestor::leg:BlockAmendment[1]/@Format = 'single'">
				<xsl:text>&#8217;</xsl:text>
			</xsl:when>
			<xsl:when test="ancestor::leg:BlockAmendment[1]/@Format = 'none'"/>
			<xsl:otherwise>
				<xsl:text>&#8221;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

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

	<!-- Define the context using increasing granularity for the tests -->
	<xsl:template name="FuncGetContext">
		<xsl:choose>
			<xsl:when test="ancestor::leg:Resource">
				<xsl:choose>
					<!-- This code works on the assumption that an included document in an extract will only be included once within the document -->
					<xsl:when test="//leg:BlockExtract[leg:IncludedDocument[@ResourceRef = current()/ancestor::leg:Resource/@id]]/@SourceClass = $g_strPrimary">
						<xsl:value-of select="$g_strPrimary"/>
					</xsl:when>
					<xsl:when test="//leg:BlockExtract[leg:IncludedDocument[@ResourceRef = current()/ancestor::leg:Resource/@id]]/@SourceClass = $g_strSecondary">
						<xsl:value-of select="$g_strSecondary"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<!-- Amendment level granularity -->
			<xsl:when test="ancestor::leg:BlockAmendment[1]/@TargetClass = $g_strPrimary">
				<xsl:value-of select="$g_strPrimary"/>
			</xsl:when>
			<xsl:when test="ancestor::leg:BlockAmendment[1]/@TargetClass = $g_strSecondary">
				<xsl:value-of select="$g_strSecondary"/>
			</xsl:when>
			<!-- Instance level granularity -->
			<xsl:when test="$g_strDocumentType = $g_strPrimary">
				<xsl:value-of select="$g_strPrimary"/>
			</xsl:when>
			<xsl:when test="$g_strDocumentType = $g_strSecondary">
				<xsl:value-of select="$g_strSecondary"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Calculate local CSS overrides -->
	<xsl:template name="FuncGetLocalTextStyle">
		<xsl:if test="@Hanging = 'indented' or @Align = 'centre' or @Align = 'right'">
			<xsl:attribute name="style">
				<xsl:if test="@Hanging = 'indented'">
					<xsl:text>text-indent: 1em; </xsl:text>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="@Align = 'centre'">text-align: center; </xsl:when>
					<xsl:when test="@Align = 'right'">text-align: right; </xsl:when>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<!-- Apply id attribute if used -->
	<xsl:template name="FuncCheckForID">
		<xsl:if test="@id">
			<xsl:attribute name="id">
				<xsl:value-of select="@id"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<!-- Apply id attribute if used and if so output an anchor point - this is for elements in the XML that will not have an HTML element -->
	<xsl:template name="FuncCheckForIDnoElement">
		<xsl:param name="strID"/>
		<xsl:if test="@id or $strID != ''">
			<!-- Do it this way because IE doesn't like empty anchors -->
			<!-- Included a class id so that this can be identified for internal links. -->
			<a class="ENAnchorID">
				<xsl:attribute name="id">
					<xsl:choose>
						<xsl:when test="$strID != ''">
							<xsl:value-of select="$strID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="FuncGenerateAnchorID"/>
							<!--<xsl:value-of select="@id"/>-->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<!-- Copy an empty node set to force MSXML to output start and end tags -->
				<xsl:copy-of select="/.."/>
			</a>
		</xsl:if>
	</xsl:template>

	<!-- Apply id attribute if used and if so output an anchor point - this is for major elements in the structure that might form anchor points -->
	<xsl:template name="FuncCheckForIDelement">
		<!-- Do it this way because IE doesn't like empty anchors -->
		<!-- Included a class id so that this can be identified for internal links. -->
		<a class="ENAnchorID">
			<xsl:attribute name="id">
				<xsl:call-template name="FuncGenerateAnchorID"/>
			</xsl:attribute>
			<!-- Copy an empty node set to force MSXML to output start and end tags -->
			<xsl:copy-of select="/.."/>
		</a>
	</xsl:template>

	<xsl:template name="FuncGenerateAnchorID">
		<xsl:choose>
			<!-- We won't do this in amendments or certain other structures as that would upset the numbering potentially -->
			<xsl:when test="not(ancestor::*[self::leg:BlockAmendment or self::leg:Tabular or self::leg:EarlierOrders or self::leg:ExplanatoryNotes or self::leg:Form or self::leg:Resource]) and (self::leg:P6 or self::leg:P5 or self::leg:P4 or self::leg:P3 or self::leg:P2 or self::leg:P1 or self::leg:P3group or self::leg:P2group or self::leg:P1group or self::leg:Group or self::leg:Part or self::leg:Chapter or self::leg:Pblock or self::leg:PsubBlock or self::leg:Schedule)">
				<xsl:call-template name="TSOcheckVersionAnchor"/>
				<xsl:call-template name="FuncGenerateSemanticAnchor"/>
			</xsl:when>
			<xsl:when test="not(ancestor::*[self::leg:BlockAmendment or self::leg:EarlierOrders or self::leg:ExplanatoryNotes or self::leg:Form or self::leg:Resource]) and (self::leg:Figure or self::leg:Image)">
				<xsl:call-template name="TSOcheckVersionAnchor"/>
				<xsl:if test="ancestor-or-self::leg:Figure">
					<xsl:text>fig</xsl:text>
					<xsl:value-of select="count(ancestor-or-self::leg:Figure/preceding::leg:Figure) + 1"/>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="ancestor::leg:Figure and self::leg:Image">
						<xsl:text>-img</xsl:text>
						<xsl:value-of select="count(preceding-sibling::leg:Image) + 1"/>
					</xsl:when>
					<xsl:when test="self::leg:Image">
						<xsl:text>img</xsl:text>
						<xsl:value-of select="count(preceding::leg:Image[not(ancestor::leg:Figre)]) + 1"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<!-- We won't do this in amendments or certain other structures as that would upset the numbering potentially -->
			<xsl:when test="not(ancestor::*[self::leg:BlockAmendment or self::leg:EarlierOrders or self::leg:ExplanatoryNotes or self::leg:Form or self::leg:Resource]) and (self::leg:Tabular or self::xhtml:table or self::xhtml:tfoot or self::xhtml:tbody or self::xhtml:tr or self::xhtml:th or self::xhtml:td)">
				<xsl:call-template name="TSOcheckVersionAnchor"/>
				<xsl:call-template name="FuncGenerateSemanticTableAnchor"/>
			</xsl:when>
			<xsl:when test="@id">
				<xsl:value-of select="@id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Legislation-</xsl:text>
				<!-- To avoid ID clashes for content generated from a version expand the id -->
				<xsl:if test="ancestor-or-self::*[@VersionReplacement = 'True']">
					<xsl:value-of select="ancestor-or-self::*[@VersionReplacement = 'True']/@VersionReference"/>
					<xsl:text>-</xsl:text>
				</xsl:if>
				<xsl:value-of select="generate-id()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="TSOcheckVersionAnchor">
		<!-- To avoid ID clashes for content generated from a version expand the id -->
		<xsl:if test="ancestor-or-self::*[@VersionReplacement = 'True']">
			<xsl:value-of select="ancestor-or-self::*[@VersionReplacement = 'True']/@VersionReference"/>
			<xsl:text>-</xsl:text>
		</xsl:if>
		<xsl:if test="ancestor-or-self::*[@ResourceReplacement = 'True']">
			<xsl:value-of select="ancestor-or-self::*[@ResourceReplacement = 'True']/@ResourceReference"/>
			<xsl:text>-</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- Where possible we will generate anchors that are calculable manuall rather than using generated ids -->
	<xsl:template name="FuncGenerateSemanticTableAnchor">
		<xsl:for-each select="ancestor::*[self::leg:Tabular or self::xhtml:table or self::xhtml:thead or self::xhtml:tbody or self::xhtml:tr or self::xhtml:th or self::xhtml:td][1]">
			<xsl:call-template name="FuncGenerateSemanticTableAnchor"/>
		</xsl:for-each>
		<xsl:if test="ancestor::*[self::leg:Tabular or self::xhtml:table or self::xhtml:thead or self::xhtml:tbody or self::xhtml:tr or self::xhtml:th or self::xhtml:td]">
			<xsl:text>-</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="self::leg:Tabular">tgp</xsl:when>
			<xsl:when test="self::xhtml:table">tbl</xsl:when>
			<xsl:when test="self::xhtml:thead">thd</xsl:when>
			<xsl:when test="self::xhtml:tbody">tbd</xsl:when>
			<xsl:when test="self::xhtml:tr">tr</xsl:when>
			<xsl:when test="self::xhtml:th">th</xsl:when>
			<xsl:when test="self::xhtml:td">tc</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="self::leg:Tabular">
				<xsl:value-of select="count(ancestor-or-self::leg:Tabular) + count(preceding::leg:Tabular)"/>
			</xsl:when>
			<xsl:when test="self::xhtml:table">
				<xsl:variable name="strTableID" select="generate-id(ancestor::xhtml:table[1])"/>
				<xsl:value-of select="count(preceding::xhtml:table[generate-id(ancestor::xhtml:table[1]) = $strTableID]) + 1"/>									
			</xsl:when>
			<xsl:when test="self::xhtml:tbody">
				<xsl:value-of select="count(preceding-sibling::xhtml:tbody) + 1"/>
			</xsl:when>
			<xsl:when test="self::xhtml:thead or self::xhtml:tr">
				<xsl:value-of select="count(preceding-sibling::xhtml:*) + 1"/>
			</xsl:when>
			<xsl:when test="self::xhtml:th or self::xhtml:td">
				<xsl:value-of select="count(preceding-sibling::xhtml:th) + count(preceding-sibling::xhtml:td) + 1"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Where possible we will generate anchors that are calculable manually rather than using generated ids -->
	<xsl:template name="FuncGenerateSemanticAnchor">
		<xsl:for-each select="ancestor::*[self::leg:P6 or self::leg:P5 or self::leg:P4 or self::leg:P3 or self::leg:P2 or self::leg:P1 or self::leg:P or self::leg:P3group or self::leg:P2group or self::leg:P1group or self::leg:Group or self::leg:Part or self::leg:Chapter or self::leg:Pblock or self::leg:PsubBlock or self::leg:Schedule][1]">
			<xsl:call-template name="FuncGenerateSemanticAnchor"/>
		</xsl:for-each>
		<xsl:if test="ancestor::*[self::leg:P6 or self::leg:P5 or self::leg:P4 or self::leg:P3 or self::leg:P2 or self::leg:P1 or self::leg:P or self::leg:P3group or self::leg:P2group or self::leg:P1group or self::leg:Group or self::leg:Part or self::leg:Chapter or self::leg:Pblock or self::leg:PsubBlock or self::leg:Schedule]">
			<xsl:text>-</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="self::leg:P">lp</xsl:when>
			<xsl:when test="self::leg:P1">l1p</xsl:when>
			<xsl:when test="self::leg:P2">l2p</xsl:when>
			<xsl:when test="self::leg:P3">l3p</xsl:when>
			<xsl:when test="self::leg:P4">l4p</xsl:when>
			<xsl:when test="self::leg:P5">l5p</xsl:when>
			<xsl:when test="self::leg:P6">l6p</xsl:when>
			<xsl:when test="self::leg:P1group">l1g</xsl:when>
			<xsl:when test="self::leg:P2group">l2g</xsl:when>
			<xsl:when test="self::leg:P3group">l3g</xsl:when>
			<xsl:when test="self::leg:PsubBlock">psb</xsl:when>
			<xsl:when test="self::leg:Pblock">pb</xsl:when>
			<xsl:when test="self::leg:Chapter">ch</xsl:when>
			<xsl:when test="self::leg:Part">pt</xsl:when>
			<xsl:when test="self::leg:Group">gp</xsl:when>		
			<xsl:when test="self::leg:Schedule">sch</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="self::leg:P1group">
				<xsl:value-of select="count(preceding::leg:P1group[not(ancestor::*[self::leg:BlockAmendment or self::leg:Tabular or self::leg:EarlierOrders or self::leg:ExplanatoryNotes or self::leg:Form])]) + 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="strElement" select="name()"/>
				<!-- We need to be careful because our elements may be contained in para style elements, of which there may be more than one in the containing structure -->
				<xsl:variable name="intPrecedingCount">
					<xsl:choose>
						<xsl:when test="(self::leg:P2group or self::leg:P3group or self::leg:P2 or self::leg:P3 or self::leg:P4 or self::leg:P5 or self::leg:P6) and parent::*[self::leg:P1para or self::leg:P2para or self::leg:P3para or self::leg:P4para or self::leg:P5para]">
							<xsl:for-each select="parent::*[self::leg:P1para or self::leg:P2para or self::leg:P3para or self::leg:P4para or self::leg:P5para]">
								<xsl:call-template name="FuncCalcPrecedingParaCount">
									<xsl:with-param name="strElement" select="$strElement"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="count(preceding-sibling::*[name() = name(current())]) + 1 + $intPrecedingCount"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="FuncCalcPrecedingParaCount">
		<xsl:param name="intCount" select="0"/>
		<xsl:param name="strElement"/>
		<xsl:choose>
			<xsl:when test="preceding-sibling::*[name() = name(current())]">
				<xsl:for-each select="preceding-sibling::*[name() = name(current())][1]">
					<xsl:call-template name="FuncCalcPrecedingParaCount">
						<xsl:with-param name="intCount" select="$intCount + count(child::*[name() = $strElement])"/>
						<xsl:with-param name="strElement" select="$strElement"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$intCount"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="FuncCalcENHeadingLevel">
		<xsl:variable name="intHeadingCount" select="count(ancestor-or-self::*[self::leg:ExplanatoryNotes or self::leg:Division or self::leg:SubDivision or self::leg:SubSubDivision or self::leg:CommentaryP1 or self::leg:CommentaryPart or self::leg:CommentaryChapter or self::leg:Annex or self::leg:Tabular or self::leg:Figure or self::leg:Form])"/>
		<xsl:choose>
			<!-- Document level headings are going to start at 1 -->
			<xsl:when test="$intHeadingCount &lt; 6">
				<xsl:value-of select="$intHeadingCount + 1"/>
			</xsl:when>
			<xsl:otherwise>6</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="FuncNormalizeSpace">
		<xsl:param name="strString" />
		<xsl:choose>
			<xsl:when test="ancestor::xhtml:html">
				<xsl:value-of select="translate($strString, '&#13;&#10;', '')"/>
			</xsl:when>
			<xsl:when test="$strString = ''" />
			<xsl:when test="normalize-space($strString) = ''">
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="normalize-space(substring($strString, 1, 1)) = ''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="normalize-space($strString)" />
				<xsl:if test="normalize-space(substring($strString, string-length($strString))) = ''">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
