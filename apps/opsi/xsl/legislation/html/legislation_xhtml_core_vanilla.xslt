<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Legislation schema XHTML output for legislation -->

<!-- Version 1.00 -->
<!-- Created by Paul Appleby -->
<!-- Last changed 18/03/2009 by Paul Appleby -->
<!-- Change history

-->
<!--
Settings for this XSLT: Preserve white space should be set to true
-->

<!-- This file is used to produce the XHTML from the TSO legislation schema -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
xmlns:xhtml="http://www.w3.org/1999/xhtml" 
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" 
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" 
xmlns:math="http://www.w3.org/1998/Math/MathML" 
xmlns:msxsl="urn:schemas-microsoft-com:xslt"
xmlns:err="http://www.tso.co.uk/assets/namespace/error"
xmlns:dc="http://purl.org/dc/elements/1.1/" 
xmlns:dct="http://purl.org/dc/terms/"
xmlns:fo="http://www.w3.org/1999/XSL/Format" 
xmlns:svg="http://www.w3.org/2000/svg" 
xmlns:atom="http://www.w3.org/2005/Atom" 
exclude-result-prefixes="leg ukm math msxsl dc dct ukm fo xsl svg xhtml tso xs err">


<!-- ========== Global variables ========== -->

<!-- Self-reference to document being processed -->
<xsl:variable name="g_ndsMainDoc" select="."/>

<!-- Store metadata -->
<xsl:variable name="g_ndsMetadata" select="/leg:Legislation/ukm:Metadata"/>

<!-- Document main type -->
<xsl:variable name="g_strDocumentMainType" select="$g_ndsMetadata/*/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>

<!-- Document minor type -->
<xsl:variable name="g_strDocumentMinorType" select="$g_ndsMetadata/*/ukm:DocumentClassification/ukm:DocumentMinorType/@Value"/>

<!-- Document type. For NI acts they are treated as secondary for the body of the document -->
<xsl:variable name="g_strDocumentType">
	<xsl:choose>
		<xsl:when test="$g_strDocumentMainType = 'NorthernIrelandAct'">secondary</xsl:when>
		<xsl:when test="$g_strDocumentMainType = 'UnitedKingdomDraftPublicBill'">primary</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$g_ndsMetadata/*/ukm:DocumentClassification/ukm:DocumentCategory/@Value"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<!-- Store footnotes -->
<xsl:variable name="g_ndsFootnotes" select="//leg:Footnote"/>

<!-- Store resources -->
<xsl:variable name="g_ndsResources" select="//leg:Resource | //leg:ResourceGroup"/>

<!-- Store margin notes -->
<xsl:variable name="g_ndsMarginNotes" select="/leg:Legislation/leg:MarginNotes/leg:MarginNote"/>

<!-- Store versions -->
<xsl:variable name="g_ndsVersions" select="/leg:Legislation/leg:Versions/leg:Version"/>

<!-- Index all elements by any id -->
<xsl:key name="g_keyNodeIDs" match="*[@id != '']" use="@id"/>


<!-- ========== Global constants ========== -->

<xsl:variable name="g_strPrimary" select="'primary'"/>

<xsl:variable name="g_strSecondary" select="'secondary'"/>

<xsl:variable name="g_strEUretained" select="'euretained'"/>

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
		<xsl:value-of select="$g_ndsMainDoc/leg:Legislation/ukm:Metadata/dc:title/node()"/>
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
			<xsl:otherwise> (c. </xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$g_ndsMetadata/*/ukm:Number/@Value"/>
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
	</title>
	<xsl:if test="$g_ndsMetadata/dc:modified">
		<meta name="DC.Date.Modified" scheme="W3CDTF" content="{$g_ndsMetadata/dc:modified}" />
	</xsl:if>
	<xsl:if test="$g_ndsMetadata/dct:valid">
		<meta name="DC.Date.Valid" scheme="W3CDTF" content="{$g_ndsMetadata/dct:valid}" />
	</xsl:if>
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
	
<!-- Add in appropriate CSS file depending on whether processing primary or secondary legislation -->
<xsl:template match="xhtml:style">
	<style type="text/css" media="screen, print">
		<xsl:copy-of select="node()"/>
		<xsl:text>@import "</xsl:text>
		<xsl:value-of select="$g_strStylesPath"/>
		<xsl:text>legislation.css";</xsl:text>
		<xsl:choose>
			<xsl:when test="$g_strDocumentType = $g_strEUretained">
				<xsl:text>@import "</xsl:text>
				<xsl:value-of select="$g_strStylesPath"/>
				<xsl:text>eulegislation.css";</xsl:text>
			</xsl:when>
			<xsl:when test="$g_ndsMainDoc//leg:Primary and not($g_strDocumentType = $g_strSecondary)">
				<xsl:text>@import "</xsl:text>
				<xsl:value-of select="$g_strStylesPath"/>
				<xsl:text>primarylegislation.css";</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>@import "</xsl:text>
				<xsl:value-of select="$g_strStylesPath"/>
				<xsl:text>secondarylegislation.css";&#13;</xsl:text>
				<!-- For NI Acts we need to add a prelim CSS file to override secondary formatting -->
				<xsl:if test="$g_strDocumentMainType = 'NorthernIrelandAct'">
					<xsl:text>@import "</xsl:text>
					<xsl:value-of select="$g_strStylesPath"/>
					<xsl:text>NIlegislation.css";</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</style>
</xsl:template>

<xsl:template match="leg:Primary">
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>

<xsl:template match="leg:Secondary">
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>

<xsl:template match="leg:EURetained">
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>

<xsl:template match="ukm:*"/>

<xsl:template match="leg:Legislation">
	<xsl:apply-templates select="*[not(self::leg:Contents)] | processing-instruction()"/>
</xsl:template>


<!-- ========== Preliminary matter (Primary Legislation) ========== -->

<xsl:template match="leg:PrimaryPrelims">
	<div class="LegClearFix LegPrelims">
		<xsl:call-template name="FuncOutputPrimaryPrelimsPreContents"/>
		<xsl:apply-templates select="//leg:Legislation/leg:Contents"/>		
		<xsl:call-template name="FuncOutputPrimaryPrelimsPostContents"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template name="FuncOutputPrimaryPrelimsPreContents">
	<xsl:apply-templates select="leg:Title"/>
	<h1 class="LegNo">
		<!-- PG 2008-07-18 Welsh Measures, and indeed most new legislation, has all the info we need in the Number element, so we can just output that -->
		<xsl:choose>
			<xsl:when test="$g_strDocumentMainType = 'WelshAssemblyMeasure' ">
				<xsl:apply-templates select="leg:Number" mode="welshnumber"/>
			</xsl:when>
			<xsl:when test="$g_strDocumentMainType = 'WelshNationalAssemblyAct' ">
				<xsl:apply-templates select="leg:Number" mode="welshnumber"/>
			</xsl:when>
			<!-- Convoluted approach to outputting the correct act number, but probably required for legacy data -->
			<xsl:otherwise>
				<xsl:variable name="year" select="$g_ndsMetadata//ukm:Year/@Value"/>
				<xsl:if test="leg:Number/leg:CommentaryRef">
					<xsl:apply-templates select="leg:Number/leg:CommentaryRef"/>
				</xsl:if>
				<xsl:value-of select="$year"/>
				<xsl:choose>
					<xsl:when test="$g_strDocumentMainType = 'UnitedKingdomChurchMeasure'">
						<xsl:text> No. </xsl:text>
					</xsl:when>
					<xsl:when test="$g_strDocumentMainType = 'ScottishAct'">
						<xsl:choose>
							<xsl:when test="if ($year castable as xs:integer) then xs:integer($year) &lt; 1800 else false()">
								<span class="LegNoASP"> c. </span>
							</xsl:when>
							<xsl:otherwise>
								<span class="LegNoASP"> asp </span>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!--issue 161 we need to format old scottish acts to c. -->
					<xsl:when test="$g_strDocumentMainType = 'ScottishOldAct'">
						<span class="LegNoASP"> c. </span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> CHAPTER </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$g_strDocumentMainType = 'UnitedKingdomLocalAct'">
						<xsl:number format="i" value="$g_ndsMetadata//ukm:Number/@Value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$g_ndsMetadata//ukm:Number/@Value"/>
					</xsl:otherwise>
				</xsl:choose>
				<!-- Output Regnal year too if there is one -->
				<xsl:for-each select="$g_ndsMetadata//ukm:AlternativeNumber">
					<xsl:if test="@Category = 'Regnal'">
						<xsl:text> </xsl:text>
						<xsl:value-of select="translate(@Value,'_',' ')"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>	
	</h1>
</xsl:template>

<xsl:template name="FuncOutputPrimaryPrelimsPostContents">
	<!-- Scottish Acts are slightly differently formatted to the others, in that the LongTitle appears after the DateOfEnactment element. Also pass in a 'Scottish' suffix so that this can be formatted differently to the general format. -->
	<xsl:choose>
		<xsl:when test="contains($g_strDocumentMainType, 'ScottishAct')">
			<xsl:variable name="strScottishSuffix" select="'Scottish'"/>
			<xsl:apply-templates select="leg:DateOfEnactment">
				<xsl:with-param name="strSuffix" select="$strScottishSuffix"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="leg:LongTitle">
				<xsl:with-param name="strSuffix" select="$strScottishSuffix"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="leg:LongTitle"/>
			<xsl:apply-templates select="leg:DateOfEnactment"/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="not(ancestor::leg:BlockAmendment)">
		<xsl:call-template name="FuncCheckForIDnoElement">
			<xsl:with-param name="strID" select="'Legislation-Preamble'"/>
		</xsl:call-template>	
	</xsl:if>
	<xsl:apply-templates select="leg:PrimaryPreamble/leg:IntroductoryText"/>
	<xsl:apply-templates select="leg:PrimaryPreamble/leg:EnactingText"/>
</xsl:template>

<xsl:template match="leg:PrimaryPrelims/leg:Title">
	<h1 class="LegTitle">
		<xsl:apply-templates/>
	</h1>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:PrimaryPrelims/leg:Number"  mode="welshnumber">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:PrimaryPrelims/leg:LongTitle">
	<xsl:param name="strSuffix"/>
	<p class="LegLongTitle{$strSuffix}">
		<xsl:apply-templates/>
	</p>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:PrimaryPrelims/leg:DateOfEnactment">
	<xsl:param name="strSuffix"/>
	<p class="LegDateOfEnactment{$strSuffix}">
		<xsl:apply-templates select="leg:DateText/node()"/>
	</p>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<!-- ========== Preliminary matter (Secondary Legislation) ========== -->

<xsl:template match="leg:SecondaryPrelims">
	<div class="LegClearFix LegPrelims">
		<xsl:call-template name="FuncOutputSecondaryPrelims"/>
		<xsl:apply-templates select="//leg:Legislation/leg:Contents"/>
		<xsl:apply-templates select="leg:SecondaryPreamble"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template name="FuncOutputSecondaryPrelims">
	<xsl:apply-templates select="leg:Correction"/>
	<xsl:apply-templates select="leg:Draft"/>
	<p class="LegBanner">
		<xsl:if test="$g_ndsMetadata//ukm:DocumentStatus/@Value = 'draft'">
			<xsl:text>Draft </xsl:text>
		</xsl:if>
		<xsl:for-each select="$g_ndsMetadata//ukm:DocumentClassification/ukm:DocumentMainType">
			<xsl:choose>
				<xsl:when test="@Value = 'NorthernIrelandStatutoryRule' or @Value = 'NorthernIrelandStatutoryRuleOrOrder' or @Value = 'NorthernIrelandStatutoryRuleLocal' or @Value = 'NorthernIrelandDraftStatutoryRule'">Statutory Rules of Northern Ireland</xsl:when>
				<xsl:when test="@Value = 'ScottishStatutoryInstrument' or @Value = 'ScottishStatutoryInstrumentLocal'or @Value = 'ScottishDraftStatutoryInstrument'">Scottish Statutory Instruments</xsl:when>
       			<xsl:when test="@Value = 'UnitedKingdomChurchInstrument' or @Value = 'UnitedKingdomChurchInstrumentLocal'">Church Instruments</xsl:when>
       			<xsl:when test="@Value = 'UnitedKingdomMinisterialDirection'">Ministerial Directions</xsl:when>
      			<xsl:when test="@Value = 'UnitedKingdomMinisterialOrder' or @Value = 'UnitedKingdomMinisterialOrderLocal'">Ministerial Order</xsl:when>
				<!-- Yashasri: Added to make welsh banner text correct HA049222-->
				<xsl:when test="(@Value = 'WelshStatutoryInstrument' or @Value='WelshStatutoryInstrumentLocal') and not($g_ndsMetadata/dc:language = 'cy')">Welsh Statutory Instruments</xsl:when>				
				<!-- Can have Welsh-language UKSIs, so don't test for type here -->
				<xsl:when test="$g_ndsMetadata/dc:language = 'cy'">Offerynnau Statudol Cymru</xsl:when>
				<xsl:otherwise>Statutory Instruments</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</p>
	<!--Chunyu Added changed for Approved text in the correct place for  NI secondary legislation HA048652  -->
	<xsl:choose>
		<xsl:when test="($g_strDocumentMainType = 'NorthernIrelandStatutoryRule' or $g_strDocumentMainType = 'NorthernIrelandStatutoryRuleOrOrder') and leg:Approved">
			<xsl:apply-templates select="leg:Number | leg:SubjectInformation | leg:Title | leg:Approved | leg:LaidDraft | leg:LaidDate  | processing-instruction()"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="leg:Number | leg:SubjectInformation | leg:Title | leg:Approved | leg:LaidDraft | leg:SiftedDate | leg:MadeDate | leg:LaidDate | leg:ComingIntoForce | processing-instruction()"/>
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:Correction">
	<xsl:apply-templates/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:Draft">
	<xsl:apply-templates/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:Number">
	<h1 class="LegNo">
		<xsl:apply-templates/>
	</h1>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:Title">
	<h1 class="LegTitle">
		<xsl:apply-templates/>
	</h1>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:SubjectInformation">
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Subject">
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Subject/leg:Title">
	<p class="LegSubject">
		<xsl:apply-templates/>
	</p>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Subject/leg:Subtitle">
	<p class="LegSubsubject">
		<xsl:apply-templates/>
	</p>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<!--Chunyu Added changed for Approved text in the correct place for NI secondary legislation  HA048652 -->
<xsl:template match="leg:SecondaryPrelims/leg:Approved">
	<xsl:choose>
		<xsl:when test="$g_strDocumentMainType = 'NorthernIrelandStatutoryRule' or $g_strDocumentMainType = 'NorthernIrelandStatutoryRuleOrOrder'">
			<xsl:apply-templates select="following-sibling::leg:MadeDate"/>
			<xsl:apply-templates select="following-sibling::leg:ComingIntoForce"/>
			<div class="LegDate">
				<p class="LegDateText">
					<xsl:value-of select="concat(substring-before(.,' on '),' on')"/>
				</p>
				<p class="LegDateDate">
					<xsl:value-of select="normalize-space(substring-after(.,' on '))"/>
				</p>
			</div>
				</xsl:when>
				<xsl:otherwise>
					<p class="LegApproved">
					<xsl:apply-templates/>
				</p>
				</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

	<xsl:template match="leg:SecondaryPrelims/leg:SiftedDate">
		
		<div class="LegDate">
			<p class="LegDateText">
				<xsl:apply-templates select="leg:Text/node() | processing-instruction()[following-sibling::leg:DateText]"/>
			</p>
			<p class="LegDateDate">
				<xsl:apply-templates select="leg:DateText/node() | processing-instruction()[preceding-sibling::leg:DateText]"/>
			</p>
		</div>
		<xsl:call-template name="FuncApplyVersions"/>
		
	</xsl:template>


<xsl:template match="leg:SecondaryPrelims/leg:MadeDate">
	
			<div class="LegDate">
				<p class="LegDateText">
					<xsl:apply-templates select="leg:Text/node() | processing-instruction()[following-sibling::leg:DateText]"/>
				</p>
				<p class="LegDateDate">
					<xsl:apply-templates select="leg:DateText/node() | processing-instruction()[preceding-sibling::leg:DateText]"/>
				</p>
			</div>
			<xsl:call-template name="FuncApplyVersions"/>
	
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:LaidDraft">
	<div class="LegDate">
		<p class="LegDateText">
			<xsl:apply-templates select="leg:Text/node() | processing-instruction()[following-sibling::leg:DateText]"/>
		</p>
		<p class="LegDateDate">
			<xsl:apply-templates select="leg:DateText/node() | processing-instruction()[preceding-sibling::leg:DateText]"/>
		</p>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:LaidDate">
	<div class="LegDate">
		<p class="LegDateText">
			<xsl:apply-templates select="leg:Text/node() | processing-instruction()[following-sibling::leg:DateText]"/>
		</p>
		<p class="LegDateDate">
			<xsl:apply-templates select="leg:DateText/node() | processing-instruction()[preceding-sibling::leg:DateText]"/>
		</p>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:ComingIntoForce">

	<div class="LegDate">
		<xsl:choose>
			<!-- No date so use the full available width -->
			<xsl:when test="not(leg:DateText)">
				<p class="LegDateTextWide">
					<xsl:apply-templates select="leg:Text/node() | processing-instruction()"/>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<p class="LegDateText">
					<xsl:apply-templates select="leg:Text/node() | processing-instruction()[following-sibling::leg:DateText]"/>
				</p>
				<p class="LegDateDate">
					<xsl:apply-templates select="leg:DateText/node() | processing-instruction()[preceding-sibling::leg:DateText]"/>
				</p>		
			</xsl:otherwise>
		</xsl:choose>
	</div>
	<xsl:apply-templates select="leg:ComingIntoForceClauses"/>
	<xsl:call-template name="FuncApplyVersions"/>
	
</xsl:template>

<xsl:template match="leg:SecondaryPrelims//leg:ComingIntoForceClauses">
	<div class="LegDate">
		<xsl:choose>
			<!-- No date so use the full available width -->
			<xsl:when test="not(leg:DateText)">
				<p class="LegDateTextWideClauses">
					<xsl:for-each select="leg:Text">
						<xsl:apply-templates/>
					</xsl:for-each>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<p class="LegDateTextClauses">
					<xsl:for-each select="leg:Text">
						<xsl:apply-templates/>
					</xsl:for-each>
				</p>
				<p class="LegDateDate">
					<xsl:for-each select="leg:DateText">
						<xsl:apply-templates/>
					</xsl:for-each>
				</p>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="leg:ComingIntoForceClauses"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:SecondaryPreamble">
	<xsl:if test="not(ancestor::leg:BlockAmendment)">
		<xsl:call-template name="FuncCheckForIDnoElement">
			<xsl:with-param name="strID" select="'Legislation-Preamble'"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Resolution">
	<div class="LegResolution">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:RoyalPresence">
	<div class="LegRoyalPresence">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<!-- ========== Other preliminary matter ========= -->

<xsl:template match="leg:IntroductoryText">
	<div class="LegIntroductoryText">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:EnactingText">
	<div class="LegEnactingText">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<!-- ========== TOCs ========== -->

<xsl:template match="leg:Contents">
	<div class="LegContents LegClearFix">
		<xsl:call-template name="FuncTocListContents"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<!-- Amended 14-02-08 -->
<xsl:template match="leg:BlockAmendment/*[self::leg:ContentsSchedules or self::leg:ContentsSchedule or self::leg:ContentsPart or self::leg:ContentsChapter or self::leg:ContentsPblock or self::leg:ContentsPsubBlock or self::leg:ContentsAppendix or self::leg:ContentsGroup]">
	<div class="LegContents LegClearFix">
		<ol>
			<xsl:choose>
				<xsl:when test="self::leg:ContentsSchedules">
					<xsl:call-template name="FuncContentsSchedules"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsSchedule">
					<xsl:call-template name="FuncContentsSchedule"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsPart">
					<xsl:call-template name="FuncContentsPart"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsEUTitle">
					<xsl:call-template name="FuncContentsEUTitle"/>
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
				<xsl:when test="self::leg:ContentsAppendix">
					<xsl:call-template name="FuncContentsAppendix"/>
				</xsl:when>
				<xsl:when test="self::leg:ContentsGroup">
					<xsl:call-template name="FuncContentsGroup"/>
				</xsl:when>
			</xsl:choose>
		</ol>
	</div>
</xsl:template>

<xsl:template match="leg:ContentsSchedules" name="FuncContentsSchedules">
	<li class="LegClearFix LegContentsSchedules{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
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
						<xsl:apply-templates select="."/>
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

<xsl:template match="leg:ContentsSchedule" name="FuncContentsSchedule">
	<li class="LegClearFix LegContentsSchedule{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsAppendix" name="FuncContentsAppendix">
	<li class="LegClearFix LegContentsAppendix{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsGroup" name="FuncContentsGroup">
	<li class="LegClearFix LegContentsGroup{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsPart" name="FuncContentsPart">
	<li class="LegClearFix LegContentsPart{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsEUTitle" name="FuncContentsEUTitle">
	<li class="LegClearFix LegContentsEUTitle{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsChapter" name="FuncContentsChapter">
	<li class="LegClearFix LegContentsChapter{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsPblock" name="FuncContentsPblock">
	<li class="LegClearFix LegContentsPblock{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsPsubBlock" name="FuncContentsPsubBlock">
	<li class="LegClearFix LegContentsPsubBlock{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsItem">
	<li class="LegContentsEntry{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<p class="LegContentsItem LegClearFix">
			<xsl:apply-templates select="* | processing-instruction()"/>
		</p>
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
				<xsl:otherwise>LegContentsHeading</xsl:otherwise>
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
	<p class="{concat('LegContentsHeading', $strAmendmentSuffix)}">
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:ContentsItem/leg:ContentsTitle">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />		
	<span class="LegDS {concat('LegContentsTitle', $strAmendmentSuffix)}{if (exists($matchIndex)) then ' LegSearchResult' else ()}">
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
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />		
	<p class="{concat('LegContentsTitle', $strAmendmentSuffix)}{if (exists($matchIndex)) then ' LegSearchResult' else ()}">
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


<!-- ========== Main structures ========== -->

<xsl:template match="leg:Body | leg:EUBody">
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>


<!-- ========== Major headings ========== -->

<xsl:template match="leg:Form">
	<div class="LegClearForm"/>
	<div class="LegFormSection">
		<xsl:call-template name="FuncProcessMajorHeading"/>
	</div>
</xsl:template>

<xsl:template match="leg:Form/leg:TitleBlock">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>

<xsl:template match="leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:Schedule" name="FuncProcessMajorHeading">
	<xsl:if test="self::leg:Group | self::leg:Part | self::leg:Chapter | self::leg:Schedule">
		<xsl:call-template name="FuncCheckForIDelement"/>
	</xsl:if>
	<xsl:if test="not(preceding-sibling::*[1][self::leg:Title or self::leg:Number]) and not(self::leg:Form)">
		<xsl:choose>
			<xsl:when test="not(preceding-sibling::*) and (parent::leg:ScheduleBody or parent::leg:AppendixBody)">
				<div class="LegClear{name()}First"/>
			</xsl:when>
			<xsl:otherwise>
				<div class="LegClear{name()}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	<xsl:if test="leg:Reference and not(contains($g_strDocumentMainType, 'ScottishAct'))">
		<p class="LegArticleRef">
			<xsl:for-each select="leg:Reference">
				<xsl:call-template name="FuncCheckForID"/>
				<xsl:apply-templates/>
			</xsl:for-each>
		</p>
	</xsl:if>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:attribute name="class">
			<xsl:text>Leg</xsl:text>
			<!-- For Scottish PGAs all schedule headings are the same in schedules as in the body but are not necessariliy the same for other types -->
			<xsl:if test="ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule']] and $g_strDocumentType = ($g_strPrimary, $g_strEUretained) and not(name() = 'Schedule') and not(contains($g_strDocumentMainType, 'ScottishAct'))">
				<xsl:text>Schedule</xsl:text>
			</xsl:if>
			<xsl:value-of select="name()"/>
			<xsl:if test="preceding-sibling::*[1][self::leg:Title or self::leg:Number] or not(preceding-sibling::*)">
				<xsl:text>First</xsl:text>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates select="leg:Number | leg:Title | leg:TitleBlock | processing-instruction()[following-sibling::leg:Number or following-sibling::leg:Title or following-sibling::leg:TitleBlock or following-sibling::leg:Reference]"/>
	</xsl:element>
	<xsl:if test="leg:Reference and contains($g_strDocumentMainType, 'ScottishAct')">
		<!-- Generate suffix to be added for CSS classes for amendments -->
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<p>
			<xsl:attribute name="class">
				<xsl:text>LegArticleRefScottish</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> Leg</xsl:text>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:for-each select="leg:Reference">
				<xsl:call-template name="FuncCheckForID"/>
				<xsl:apply-templates/>
			</xsl:for-each>
		</p>
	</xsl:if>
	<xsl:apply-templates select="." mode="showEN" />
	<xsl:apply-templates select="." mode="Structure"/>
	<xsl:call-template name="FuncApplyVersions"/>	
</xsl:template>

<xsl:template match="leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:Schedule | leg:Form" mode="Structure">
	<xsl:call-template name="FuncProcessStructureContents"/>
</xsl:template>

<xsl:template name="FuncProcessStructureContents">
	<xsl:apply-templates select="*[not(self::leg:Reference or self::leg:Number or self::leg:Title or self::leg:TitleBlock)] | processing-instruction()[not(following-sibling::leg:Number or following-sibling::leg:Title or following-sibling::leg:TitleBlock or following-sibling::leg:Reference)]"/>
</xsl:template>

<xsl:template match="leg:Group/leg:Number | leg:Part/leg:Number | leg:Chapter/leg:Number | leg:Pblock/leg:Number | leg:PsubBlock/leg:Number | leg:Schedule/leg:Number | leg:Form/leg:Number">
	<xsl:apply-templates select="." mode="StructureNumber"/>
</xsl:template>

<xsl:template match="leg:Group/leg:Number | leg:Part/leg:Number | leg:Chapter/leg:Number | leg:Pblock/leg:Number | leg:PsubBlock/leg:Number | leg:Schedule/leg:Number | leg:Form/leg:Number" mode="StructureNumber">
	<xsl:call-template name="FuncGenerateMajorHeadingNumber">
		<xsl:with-param name="strHeading" select="name(parent::*)"/>
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:Group/leg:Title | leg:Part/leg:Title | leg:Chapter/leg:Title | leg:Pblock/leg:Title | leg:PsubBlock/leg:Title | leg:Schedule/leg:TitleBlock/leg:Title | leg:Schedule/leg:TitleBlock/leg:Subtitle | leg:Form/leg:TitleBlock/leg:Title | leg:Form/leg:TitleBlock/leg:Subtitle">
	<xsl:apply-templates select="." mode="StructureTitle"/>
</xsl:template>
	
	<xsl:template match="leg:Part/leg:Title[.=''][not(node() | attribute())]" priority="+10"/>

<xsl:template match="leg:Group/leg:Title | leg:Part/leg:Title | leg:Chapter/leg:Title | leg:Pblock/leg:Title | leg:PsubBlock/leg:Title | leg:Schedule/leg:TitleBlock/leg:Title | leg:Schedule/leg:TitleBlock/leg:Subtitle | leg:Form/leg:TitleBlock/leg:Title | leg:Form/leg:TitleBlock/leg:Subtitle" mode="StructureTitle">
	<xsl:call-template name="FuncGenerateMajorHeadingTitle">
		<xsl:with-param name="strHeading" select="name(parent::*)"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="FuncGenerateMajorHeadingNumber">
	<xsl:param name="strHeading"/>
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<!--<xsl:call-template name="FuncCheckForIDelement"/>-->
	<xsl:element name="span">
		<xsl:attribute name="class">
			<xsl:text>Leg</xsl:text>
			<xsl:value-of select="$strHeading"/>
			<xsl:text>No</xsl:text>
			<!-- Allow for any section reference apart from Scottish where it it output underneath -->
			<xsl:if test="following-sibling::leg:Reference and not(contains($g_strDocumentMainType, 'ScottishAct'))"> LegHeadingRef</xsl:if>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:if test="not(following-sibling::leg:Reference)">
					<xsl:text> Leg</xsl:text>
				</xsl:if>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template name="FuncGenerateMajorHeadingTitle">
	<xsl:param name="strHeading"/>
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<!--<xsl:call-template name="FuncCheckForIDelement"/>-->
	<xsl:element name="span">
		<xsl:attribute name="class">
			<xsl:text>Leg</xsl:text>
			<xsl:value-of select="$strHeading"/>
			<xsl:text>Title</xsl:text>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:text> Leg</xsl:text>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>


<!-- ========== Paragraphs ========== -->

<xsl:template match="leg:Para">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Text">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<!-- For primary legislation the indent of content is dependent upon its parent for amendments therefore we need more information if the parent is lower level than the content being amended -->
	<xsl:choose>
		<!-- For some amendments text runs on from the previous paragraph so we need to suppress that text here. Also allow it for very rare instances of secondary legislation where PartialRefs forces it -->
		<xsl:when test="($g_strDocumentType = ($g_strPrimary) or (string(@id) != '' and contains(ancestor::leg:BlockAmendment[1]/@PartialRefs, @id))) and generate-id(ancestor::leg:BlockAmendment[1]/descendant::*[1]) = generate-id()"/>
		<!-- Combined N2-N3 or N2-N4 or N2-N3-N4 paragraph -->
		<xsl:when test="parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P2para/preceding-sibling::*[1][self::leg:Pnumber]
		 or parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P2para/preceding-sibling::*[1][self::leg:Pnumber]
		 or parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P2para/preceding-sibling::*[1][self::leg:Pnumber]">
			<xsl:choose>
				<!-- see local act 2009 c. i s. 4 -->
				<xsl:when test="$g_strDocumentType = ($g_strPrimary)">
					<!-- Calculate if in a primary schedule -->
					<xsl:variable name="strScheduleContext">
						<xsl:call-template name="FuncGetScheduleContext"/>
					</xsl:variable>
					<p class="LegClearFix {concat('Leg', $strScheduleContext, name(parent::*/parent::*), 'Container')}">
						<xsl:call-template name="FuncCheckForID"/>
						<!-- add the numbers if it's a piece of primary legislation or it's not the first P2 within the surrounding P1 -->
						<span class="LegDS LegLHS {concat('LegP2No', $strAmendmentSuffix)}">
							<xsl:for-each select="ancestor::leg:P2[1]">
								<xsl:call-template name="FuncCheckForID"/>
								<xsl:apply-templates select="leg:Pnumber"/>
							</xsl:for-each>
						</span>
						<xsl:choose>
							<xsl:when test="ancestor::leg:P3">
								<span class="LegDS LegLHS LegP2P3No">
									<xsl:for-each select="ancestor::leg:P3[1]">
										<xsl:call-template name="FuncCheckForID"/>
										<xsl:apply-templates select="leg:Pnumber"/>
									</xsl:for-each>
								</span>
								<xsl:if test="ancestor::leg:P4">
									<span class="LegDS LegLHS LegP2P3P4No">
										<xsl:for-each select="ancestor::leg:P4[1]">
											<xsl:call-template name="FuncCheckForID"/>
											<xsl:apply-templates select="leg:Pnumber"/>
										</xsl:for-each>
									</span>
								</xsl:if>
							</xsl:when>
							<xsl:when test="ancestor::leg:P4">
								<span class="LegDS LegLHS LegP2P4No">
									<xsl:for-each select="ancestor::leg:P4[1]">
										<xsl:call-template name="FuncCheckForID"/>
										<xsl:apply-templates select="leg:Pnumber"/>
									</xsl:for-each>
								</span>
							</xsl:when>
						</xsl:choose>
						<span class="Text">
							<xsl:call-template name="FuncGetLocalTextStyle"/>
							<xsl:call-template name="FuncGetTextClass" />
							<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
						</span>
					</p>
				</xsl:when>
				<xsl:otherwise>
					<p class="{concat('LegP2ParaText', $strAmendmentSuffix)}">
						<xsl:call-template name="FuncCheckForID"/>
						<xsl:call-template name="FuncGetLocalTextStyle"/>
						<xsl:call-template name="FuncGetTextClass">
							<xsl:with-param name="flMode" select="'Block'"/>
						</xsl:call-template>
						<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
					</p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- N1 without a P1group -->
		<xsl:when test="not(preceding-sibling::*) and parent::leg:P1para and parent::leg:P1para/preceding-sibling::leg:*[1][self::leg:Pnumber] and not(parent::leg:P1para/parent::leg:P1[not(preceding-sibling::leg:P1)]/parent::leg:P1group) and $g_strDocumentType = ($g_strPrimary)">
			<!-- Calculate if in a primary schedule -->
			<xsl:variable name="strScheduleContext">
				<xsl:call-template name="FuncGetScheduleContext"/>
			</xsl:variable>
			<p class="LegClearFix {concat('Leg', $strScheduleContext, 'P1Container')}">
				<xsl:call-template name="FuncCheckForID"/>				
				<!-- For primary legislation ... -->
				<span class="LegDS {concat('LegP1No', $strAmendmentSuffix)}">
					<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
						<xsl:for-each select="..">
							<xsl:call-template name="FuncCheckForID"/>
						</xsl:for-each>
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</span>		
				<span class="Text">
					<xsl:call-template name="FuncGetLocalTextStyle"/>
					<xsl:call-template name="FuncGetTextClass"/>
					<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
				</span>
			</p>
		</xsl:when>
		
		<!-- Numbered paragraphs using hanging indent so we need to process them in a special manner -->
		<!-- For secondary legislation we need to make sure that we dont pick up N1-N3 or N1-N3-N4 (both very rare) -->
		<xsl:when test="not(preceding-sibling::*)
			 and parent::*[(self::leg:P2para and $g_strDocumentType = ($g_strPrimary, $g_strEUretained)) 
			 or (self::leg:P1para and ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or (@Context = 'unknown' and not(descendant::leg:P1group))]] and $g_strDocumentType = ($g_strPrimary))
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
			<p class="LegClearFix {concat('Leg', $strScheduleContext, name(parent::*/parent::*), 'Container')}">
				<xsl:call-template name="FuncCheckForID"/>				
				<xsl:choose>
					<!-- Combined N1-N2 paragraph
					<xsl:when test="parent::leg:P2para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P2[not(preceding-sibling::*)]/parent::leg:P1para/preceding-sibling::*[1][self::leg:Pnumber][not(parent::leg:P1/parent::leg:P1group)]">
						<span class="LegDS LegLHS {concat('LegN1No', $strAmendmentSuffix)}">
							<xsl:for-each select="parent::*/parent::*/parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
						<span class="LegDS LegLHS LegN2No">
							<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
					</xsl:when> -->
					<!-- Combined N3-N4 paragraph -->
					<xsl:when test="parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]">
						<span class="LegDS LegLHS {concat('LegN3No', $strAmendmentSuffix)}">
							<xsl:for-each select="parent::*/parent::*/parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
						<span class="LegDS LegLHS LegN4No">
							<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
					</xsl:when>
					<!-- Combined N4-N5 paragraph -->
					<xsl:when test="parent::leg:P5para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P5[not(preceding-sibling::*)]/parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]">
						<span class="LegDS LegLHS {concat('LegN4N5No', $strAmendmentSuffix)}">
							<xsl:for-each select="parent::*/parent::*/parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
						<span class="LegDS LegLHS LegN5No">
							<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<!-- For primary legislation ... -->
						<!-- If in a schedule and a combined N1-N2 then output N1 number. -->
						<!-- If context is unknown and BlockAmendment does not contain P1group then assume it is a schedule amendment as an amendment to a P1 in the body does not make any sense or if TargetClass is secondary apply similar logic (as secondary gets formatted like primary) -->
						<!-- Also if the below functionality has been invoked then handle that too -->
						<xsl:choose>					
							<xsl:when test="$g_strDocumentType = ($g_strPrimary) and 
								parent::leg:P2para and 
								(ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1]
								  [self::leg:Schedule or 
								   self::leg:BlockAmendment
								     [@Context = 'schedule' or 
								      ((@Context = 'unknown' or @TargetClass = 'secondary') and 
								       not(descendant::leg:P1group))]
								  ] or 
								 (ancestor::leg:P1group/@Layout = 'below' and
								  generate-id(ancestor::leg:P1group[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber or ancestor::leg:Title)][1]) = generate-id(node()[not(self::processing-instruction() or self::text()[normalize-space() = ''])][1])) or
								 empty(ancestor::leg:P1[1]/parent::leg:P1group)
								) and
								generate-id(ancestor::leg:P1[1]/descendant::text()[not(normalize-space(.) = '' or ancestor::leg:Pnumber or ancestor::leg:Title)][1]) = generate-id(descendant::text()[not(normalize-space(.) = '')][1]) and
								generate-id(ancestor::leg:P2[1]/descendant::text()[not(normalize-space(.) = '' or ancestor::leg:Pnumber)][1]) = generate-id(descendant::text()[not(normalize-space(.) = '')][1])">
									<!-- JDC - HA055227. Don't need the "LegDS LegSN1No..." span if -->
									<!-- we are 2 levels down from a P2 which has a P2 sibling -->
									<!--  		i. without a BlockAmendment  -->
									<!-- 		ii. with a P2para/Text containing the word "schedule" -->
									<!--e.g. ukpga/2013/26/section/7 subsection 4, first paragraph.-->
									<!-- If we include it under these conditions, the para number will be displayed too far to the left.-->
							      <!-- JDC - HA072391. Added P1group test to stop incorrect formatting of http://www.legislation.gov.uk/ukpga/2011/20/schedule/13/paragraph/71, sub-section 32B. -->
									<xsl:choose>
										<xsl:when test="ancestor::leg:P2[2]/preceding-sibling::leg:P2[not(descendant::leg:BlockAmendment)][contains(lower-case(descendant::leg:P2para[1]/leg:Text[1]),'schedule')]
										   and ancestor::leg:P1group"> 
											<xsl:for-each select="ancestor::leg:P1[1]">
												<xsl:call-template name="FuncCheckForID"/>
												<xsl:apply-templates select="leg:Pnumber"/>
											</xsl:for-each>									
										</xsl:when>
										<xsl:otherwise>
											<span class="LegDS {concat('LegSN1No', $strAmendmentSuffix)}">
												<xsl:for-each select="ancestor::leg:P1[1]">
													<xsl:call-template name="FuncCheckForID"/>
													<xsl:apply-templates select="leg:Pnumber"/>
												</xsl:for-each>									
											</span>
										</xsl:otherwise>
									</xsl:choose>

								<span class="LegDS {concat('LegSN2No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>
							</xsl:when>
							<!-- P1-P3 -->
							<xsl:when test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained) and parent::leg:P3para[not(ancestor::*[self::leg:P2para or self::leg:BlockAmendment][1][self::leg:P2para])] and (ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or ((@Context = 'unknown' or @TargetClass = 'secondary') and not(descendant::leg:P1group))]] or (ancestor::leg:P1group/@Layout = 'below' and generate-id(ancestor::leg:P1group[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Title)]  or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Substitution or self::leg:Repeal or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = generate-id(node()[not(self::processing-instruction())][1]))) and
							generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Title/parent::leg:P3group)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = generate-id(node()[not(self::processing-instruction())][1]) and
							generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = generate-id(node()[not(self::processing-instruction())][1])">
								<span class="LegDS {concat('LegP1No', $strAmendmentSuffix)}">
									<xsl:for-each select="ancestor::leg:P1[1]">
										<xsl:call-template name="FuncCheckForID"/>
										<xsl:apply-templates select="leg:Pnumber"/>
									</xsl:for-each>									
								</span>
								<span class="LegDS {concat('LegSN1N3No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>
							</xsl:when>
							<!-- Special handling for P1 numbers in schedules in primary legislation -->
							<xsl:when test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained) and parent::leg:P1para and not(normalize-space(.) = '') ">
								<span class="LegDS {concat('LegP1No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>		
							</xsl:when>
							<xsl:otherwise>
								<!-- Chunyu added condition for p1para/p3group/title see uksi19922792 schedule  HA048533-->
<!--								<xsl:if test="not(parent::leg:P3para/ancestor::leg:P3group[1]/parent::leg:P1para) and not (normalize-space(.) = '')">-->
								<!-- Mark R removed (normalize-space(.) = '') as it prevented item number displaying if there was an empty part before a <Repeal> element. See NISI 2007/916 section 39 2(b) annotated version half way down  -->
								<!--<xsl:if test="parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber] and
												ancestor::leg:P3[preceding-sibling::*[1][self::leg:Text][normalize-space(.) = '']]/parent::leg:P1para[preceding-sibling::*[1][self::leg:Pnumber]]">
									
										<xsl:for-each select="ancestor::leg:P1/leg:Pnumber">
											<xsl:call-template name="FuncCheckForID"/>
											<xsl:apply-templates select="."/>
										</xsl:for-each>
									
								</xsl:if>-->
								<xsl:if test="not(parent::leg:P3para/ancestor::leg:P3group[1]/parent::leg:P1para)">
									<span class="LegDS LegLHS {concat('Leg', name(parent::*/parent::*), 'No', $strAmendmentSuffix)}">
										<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
											<xsl:for-each select="..">
												<xsl:call-template name="FuncCheckForID"/>
											</xsl:for-each>
											<xsl:apply-templates select="."/>
										</xsl:for-each>
									</span>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- 07/10/2011 HA046618 The following appears to be a catch-all for textual content. If there is no textual content this must be a structural change, do not output anything -\-> -->				
				<xsl:if test=". !=''">
				<span class="Text">
						<xsl:call-template name="FuncGetLocalTextStyle"/>
						<xsl:call-template name="FuncGetTextClass"/>
						<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
					</span>
					<xsl:text>&#13;</xsl:text>
				</xsl:if>
			</p>
		</xsl:when>

		<!-- JDC - HA055227- Compensate for errors in the SLD XML translation, which set BlockAmendment's Context to unknown when it should be schedule. --> 
		<!-- Needed to e.g. show the 2nd paragraph number ("(10)") in ukpga/2013/26/section/7 subsection (4). --> 
		<!-- Unlike the "when" above, we don't want to include the "LegDS LegSN1No..." span, or  the para number will be displayed too far to the left.-->
		<xsl:when test="not(preceding-sibling::*)
			 and parent::*[(self::leg:P1para and ancestor::*[self::leg:BlockAmendment][1][self::leg:BlockAmendment[@Context = 'unknown' and descendant::leg:P1group]] and $g_strDocumentType = ($g_strPrimary, $g_strEUretained))]/preceding-sibling::*[1][self::leg:Pnumber] and ancestor::leg:P2[1]/preceding-sibling::leg:P2[not(descendant::leg:BlockAmendment)][contains(lower-case(descendant::leg:P2para/leg:Text[1]),'schedule')]">
			<p class="LegClearFix LegP2Container">
				<xsl:call-template name="FuncCheckForID"/>				
				<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
					<xsl:for-each select="..">
						<xsl:call-template name="FuncCheckForID"/>
					</xsl:for-each>
					<xsl:apply-templates select="."/>
				</xsl:for-each>
				<span class="Text">
						<xsl:call-template name="FuncGetLocalTextStyle"/>
						<xsl:call-template name="FuncGetTextClass"/>
						<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
					</span>
					<xsl:text>&#13;</xsl:text>
			</p>
		</xsl:when>

		<xsl:otherwise>
			<xsl:if test="not(ancestor::leg:MarginNote)">
				<!-- Chunyu Added if condition for empty text -->
				<!-- Mark Jones HA064261: Allowed output of images when they appear as children of leg:Text element -->
				<xsl:if test=". !='' or leg:Image">
					<!--Chunyu HA051074 Added a condition for the instance of ukci/2010/5/note/sld/created-->
					<!--2013-04-30 Update to HA051074 GC -->
					<!--This fix needs to be a very specific otherwise it has knock on effects to other legislation -->
					<!--Only apply to ENs in ukci's where there is either an Emphasis or Strong element and no textual content-->
				<xsl:choose>
					<xsl:when test="$g_strDocumentMainType = 'UnitedKingdomChurchInstrument' and
									parent::leg:P and 
									ancestor::leg:ExplanatoryNotes and
									(leg:Emphasis or leg:Strong) and
									(every $node in node() satisfies ($node instance of element(leg:Emphasis) or $node instance of element(leg:Strong) or ($node instance of text() and normalize-space($node) = '')))  
									">
						<xsl:for-each select="* ">
							<xsl:choose>
								<xsl:when test="local-name(.) = 'Strong'">
									<p class="LegExpNoteTitle">
										<xsl:apply-templates select="."/>
										<xsl:text>&#13;</xsl:text>
									</p>
								</xsl:when>
								<xsl:when test="local-name(.) = 'Emphasis'">
									<p class="LegPblockTitle">
										<xsl:apply-templates select="."/>
										<xsl:text>&#13;</xsl:text>
									</p>
								</xsl:when>
								<xsl:otherwise>
									<p class="LegExpNoteText">
										<xsl:apply-templates select="."/>
										<xsl:text>&#13;</xsl:text>
									</p>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<p class="{concat('LegText', $strAmendmentSuffix)}">
							<xsl:call-template name="FuncCheckForID"/>
							<xsl:call-template name="FuncGetLocalTextStyle"/>
							<xsl:call-template name="FuncGetTextClass">
								<xsl:with-param name="flMode" select="'Block'"/>
							</xsl:call-template>
							<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
							<xsl:text>&#13;</xsl:text>
						</p>
					</xsl:otherwise>
				</xsl:choose>
					
					
				</xsl:if>	
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	
<!-- Chunyu Added the following two specific templates to mach P1para/Text[empty]/P3/P3para/text. It is very rare.  see call HA048607 SI 20111824 schedule 1-->
	<!-- CRM changed the match from 
		match="leg:P1para/leg:Text[$g_strDocumentType = $g_strSecondary and self::leg:Text[normalize-space() = '']
	and parent::leg:P1para[preceding-sibling::*[1][self::leg:Pnumber]]]"
		to as it is now so that it does not causes duplicate number error see Sunrise HA052087 
		
		GC 2016-03-11
		This needs to work for the following cases so that numbers output to the provisions in agreement with the enacted pdf 
		This addresses issues raised by HA48607, HA052087 and HA069944
		/uksi/2011/1824/schedule/1/made
		/wsi/2016/58/schedule/1/made
		/nisi/2002/3150/article/21
		/nisi/1990/1504/article/62
		-->
	<xsl:template match="leg:P1para[leg:P3/leg:P3para/leg:Text]/leg:Text[$g_strDocumentType = $g_strSecondary and self::leg:Text[normalize-space() = ''] and parent::leg:P1para[preceding-sibling::*[1][self::leg:Pnumber]]]" priority="1000">
	<p class="LegP1ParaText">
		<xsl:apply-templates select="parent::leg:P1para/preceding-sibling::leg:Pnumber"/>
	</p>
</xsl:template>

<xsl:template match="leg:P1para[child::leg:Text[normalize-space() = '']]/leg:P3[preceding-sibling::*[1][self::leg:Text]]/leg:P3para/leg:Text[$g_strDocumentType = $g_strSecondary]" priority="1000"  >
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<p class="LegClearFix LegP3Container">
		 <span class="LegDS LegLHS {concat('Leg', name(parent::*/parent::*), 'No', $strAmendmentSuffix)}">
			<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
				<xsl:for-each select="..">
					<xsl:call-template name="FuncCheckForID"/>
				</xsl:for-each>
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</span>
		<span class="LegDS LegRHS LegP3Text">
			<xsl:apply-templates/>
		</span>
	</p>
</xsl:template>

<!-- For primary legislation we need to check if amending a schedule as output is different from body text -->
<xsl:template name="FuncGetScheduleContext">
	<!-- In the unusual example that we have a BlockAmendment containing a P1 in primary legislation with no context then assume it is amending a schedule as main does not make sense -->
	<xsl:variable name="strIsInP1">
		<xsl:if test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained) and ancestor::*[self::leg:P1 or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:P1]">
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
	<xsl:if test="$strIsInP1 = 'Schedule' or ($g_strDocumentType = ($g_strPrimary) and ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule']])">
		<xsl:text>S</xsl:text>
	</xsl:if>
</xsl:template>

<!-- Some structures in primary legislation are dependent upon their parentage we need to do some checks and alter the CSS class if necessary -->
<xsl:template name="FuncGetPrimaryContext">
	<xsl:if test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained)">
		<xsl:choose>
			<xsl:when test="parent::leg:P3para">P3</xsl:when>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<!-- As amendments in primary legislation are dependent upon their parentage we need to do some checks and alter the CSS class if necessary -->
<xsl:template name="FuncGetPrimaryAmendmentContext">
	<xsl:if test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained)">
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

<!-- Generate suffix to be added for CSS classes for amendments and output paragraph number if inline with text -->
<xsl:template name="FuncGetTextClass">
	<!-- If flMode = 'Block' then this is being calculated for a p element -->
	<xsl:param name="flMode" select="''"/>
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="strContext">
		<xsl:call-template name="FuncGetContext"/>
	</xsl:variable>
	<xsl:variable name="intInlineNodeID" select="generate-id(descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1])"/>
	<xsl:choose>
		<!-- Check if  first node in a P1-P2 in which case output P1 and P2 numbers (for secondary legislation) -->
		<xsl:when test="$g_strDocumentType = $g_strSecondary and not(ancestor::leg:P1group[1]/@Layout = 'side' or (ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])) and ancestor::leg:P1 and ancestor::leg:P2 and
				 generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber or ancestor::leg:Title/parent::leg:P2group)][1]) = $intInlineNodeID and 
				generate-id(ancestor::leg:P2[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = $intInlineNodeID">
			<xsl:attribute name="class">
				<xsl:text>LegP1ParaText</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> Leg</xsl:text>
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
				 generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = $intInlineNodeID and
				  generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = $intInlineNodeID">
			<xsl:attribute name="class">
				<xsl:text>LegP1ParaText</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> Leg</xsl:text>
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
		<xsl:when test="$g_strDocumentType = $g_strSecondary and not(ancestor::leg:P1group[1]/@Layout = 'side' or (ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])) and generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = $intInlineNodeID">
			<xsl:attribute name="class">
				<xsl:text>LegP1ParaText</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> Leg</xsl:text>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:apply-templates select="ancestor::leg:P1[1]/leg:Pnumber"/>
			<xsl:text>&#160;&#160;</xsl:text>
		</xsl:when>
		<!-- Check if first node in a P2 in which case output P2 number -->
		<xsl:when test="$g_strDocumentType  = $g_strSecondary and generate-id(ancestor::leg:P2[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = $intInlineNodeID">
			<xsl:attribute name="class">
				<xsl:text>LegP2ParaText</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> Leg</xsl:text>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			
			<xsl:apply-templates select="ancestor::leg:P2[1]/leg:Pnumber"/>
			<xsl:text>&#160;</xsl:text>
			<!-- Check if  first node in a P3 also which would indicate a combined N2-N3 -->
			<xsl:if test="generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = $intInlineNodeID">
				<xsl:apply-templates select="ancestor::leg:P3[1]/leg:Pnumber"/>
				<xsl:text>&#160;</xsl:text>
			</xsl:if>
			<!-- Check if  first node in a P4 also which would indicate a combined N2-N4 or N2-N3-N4 (very rare) -->
			<xsl:if test="generate-id(ancestor::leg:P4[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '')] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][not(ancestor::leg:Pnumber)][1]) = $intInlineNodeID">
				<xsl:apply-templates select="ancestor::leg:P4[1]/leg:Pnumber"/>
				<xsl:text>&#160;</xsl:text>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="strClass">
				<xsl:choose>
					<xsl:when test="parent::leg:P1para and $g_strDocumentType = ($g_strPrimary, $g_strEUretained)">
						<xsl:value-of select="concat('LegRHS LegP1Text', $strAmendmentSuffix)"/>
					</xsl:when>
					<!-- P2 in primary is on a hanging indent -->
					<xsl:when test="parent::leg:P2para and $g_strDocumentType = ($g_strPrimary, $g_strEUretained)">
						<xsl:value-of select="concat('LegRHS LegP2Text', $strAmendmentSuffix)"/>
					</xsl:when>
					<xsl:when test="parent::leg:P2para and not($g_strDocumentType = ($g_strPrimary, $g_strEUretained))">
						<xsl:value-of select="concat('LegP2Text', $strAmendmentSuffix)"/>
					</xsl:when>
					<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P3para[not(ancestor::leg:P2para)] and (ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or ((@Context = 'unknown' or @TargetClass = 'secondary') and not(descendant::leg:P1group))]] or (ancestor::leg:P1group/@Layout = 'below' and 
							
							generate-id(leg:get-test-node(ancestor::leg:P1group[1])) = generate-id(node()[not(self::processing-instruction())][not(normalize-space() = '')][1]))) and
							
							generate-id(leg:get-test-node(ancestor::leg:P1[1])) = generate-id(node()[not(self::processing-instruction())][not(normalize-space() = '')][1]) and
							
							generate-id(leg:get-test-node(ancestor::leg:P3[1])) = generate-id(node()[not(self::processing-instruction())][not(normalize-space() = '')][1])">
						<xsl:value-of select="concat('LegRHS LegP1P3Text', $strAmendmentSuffix)"/>
					</xsl:when>
					<xsl:when test="parent::leg:P3para">
						<xsl:value-of select="concat('LegRHS LegP3Text', $strAmendmentSuffix)"/>
					</xsl:when>
					<xsl:when test="parent::leg:P4para">
						<xsl:value-of select="concat('LegRHS LegP4Text', $strAmendmentSuffix)"/>
					</xsl:when>
					<xsl:when test="parent::leg:P5para">
						<xsl:value-of select="concat('LegRHS LegP5Text', $strAmendmentSuffix)"/>
					</xsl:when>
					<xsl:when test="parent::leg:P6para">
						<xsl:value-of select="concat('LegRHS LegP6Text', $strAmendmentSuffix)"/>
					</xsl:when>
					<xsl:when test="parent::leg:P7para">
						<xsl:value-of select="concat('LegRHS LegP7Text', $strAmendmentSuffix)"/>
					</xsl:when>
					<xsl:when test="ancestor::leg:Comment">LegCommentText</xsl:when>
					<xsl:when test="ancestor::leg:Draft">LegDraftText</xsl:when>
					<xsl:when test="ancestor::leg:Correction">LegCorrectionText</xsl:when>
					<xsl:when test="ancestor::leg:Resolution">LegResolutionText</xsl:when>
					<xsl:when test="parent::*/parent::leg:BlockText">
						<xsl:for-each select="parent::*/parent::*">
							<xsl:call-template name="FuncCalcListClass"/>
						</xsl:for-each>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:when>
					<xsl:when test="parent::*/parent::leg:ListItem">
						<xsl:text>LegListTextStandard </xsl:text>
						<xsl:for-each select="parent::*/parent::*">
							<xsl:call-template name="FuncCalcListClass"/>
						</xsl:for-each>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:when>
					<xsl:when test="parent::leg:P/parent::leg:ExplanatoryNotes or parent::leg:P/parent::leg:EarlierOrders">LegExpNoteText</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="string($strClass) != ''">
				<xsl:attribute name="class">
					<xsl:if test="$flMode != 'Block'">
						<xsl:text>LegDS </xsl:text>
					</xsl:if>
					<xsl:value-of select="$strClass"/>
				</xsl:attribute>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:function name="leg:get-test-node">
	<xsl:param name="node"/>
	<xsl:sequence select="$node/descendant::node()[not(self::processing-instruction())]
		[not(ancestor::leg:Pnumber)]
		[not(ancestor::leg:Title)]
		[self::text()[not(normalize-space() = '')]  or 
		  self::leg:Emphasis or 
		  self::leg:Strong or 
		  self::leg:Superior or 
		  self::leg:Inferior or 
		  self::leg:Addition or 
		  self::leg:Repeal or 
		  self::leg:Substitution or 
		  self::leg:CommentaryRef or 
		  self::leg:Citation or 
		  self::leg:Addition or 
		  self::leg:Repeal or 
		  self::leg:Substitution or 
		  self::leg:CommentaryRef or 
		  self::leg:CitationSubRef or 
		  self::math:math or 
		  self::leg:Character or 
		  self::leg:FootnoteRef or 
		  self::leg:Span or 
		  self::leg:Term or 
		  self::leg:Definition or 
		  self::leg:Proviso or 
		  self::leg:MarginNoteRef or 
		  self::leg:Underline or self::leg:SmallCaps][1]"/>
</xsl:function>

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
		<xsl:when test="parent::leg:P1">3</xsl:when>
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


<!-- ========== Provisions ========== -->

<xsl:template match="leg:P">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:P1group" name="TSOprocessP1group">
	<xsl:choose>
		<!-- For Primary legislation main content  (or amendments to it) we need to use a floats mechanism for the output -->
		<xsl:when test="(ancestor::*[self::leg:Body or self::leg:EUBody or self::leg:Schedule or self::leg:BlockAmendment][1][(self::leg:Schedule and $g_strDocumentType = ($g_strEUretained)) or self::leg:Body or self::leg:EUBody or self::leg:BlockAmendment[(@Context = 'main') or (@Context = 'unknown')]]) and $g_strDocumentType = ($g_strPrimary, $g_strEUretained) and (not(@Layout or @Layout != 'below'))">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
			<xsl:variable name="intHeadingLevel">
				<xsl:call-template name="FuncCalcHeadingLevel"/>
			</xsl:variable>
			<xsl:for-each select="leg:P1[1]/leg:Pnumber">
				<xsl:call-template name="FuncCheckForIDelement"/>
			</xsl:for-each>
			<xsl:element name="h{$intHeadingLevel}">
				<xsl:variable name="strContext">
					<xsl:call-template name="FuncGetContext"/>
				</xsl:variable>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="parent::leg:BlockAmendment and not(preceding-sibling::*) or ($g_strDocumentType = ($g_strPrimary, $g_strEUretained) and preceding-sibling::*[1][self::leg:Title])">
							<xsl:text>LegClearFix LegP1ContainerFirst</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>LegClearFix LegP1Container</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="FuncGetScheduleContext"/>
					<xsl:if test="$strAmendmentSuffix != '' and $g_strDocumentType = $g_strSecondary">
						<!-- We want a single class for primary due to the handling indent and multiple classes for secondary -->
						<xsl:if test="$strContext = $g_strSecondary">
							<xsl:text> Leg</xsl:text>
						</xsl:if>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:if>
				</xsl:attribute>
				<!-- Output an anchor for contents linking. Do here to avoid problem of anchor not clearing floats -->
				<!--<xsl:call-template name="FuncCheckForIDelement"/>-->
				<span>
					<xsl:attribute name="class">
						<xsl:text>LegDS LegP1No</xsl:text>
						<xsl:if test="$strAmendmentSuffix != ''">
							<xsl:if test="$strContext = $g_strSecondary and $g_strDocumentType = $g_strSecondary">
								<xsl:text> Leg</xsl:text>
							</xsl:if>
							<xsl:value-of select="$strAmendmentSuffix"/>
						</xsl:if>
					</xsl:attribute>
					<xsl:apply-templates select="leg:P1[1]/leg:Pnumber/node() | processing-instruction()"/>
				</span>
				<xsl:apply-templates select="leg:Title"/>
			</xsl:element>
			<xsl:apply-templates select="*[not(self::leg:Title)]"/>
		</xsl:when>
		<xsl:otherwise>
			<!--<xsl:call-template name="FuncCheckForIDelement"/>-->
			<xsl:apply-templates select="* | processing-instruction()"/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:P1group/leg:Title | leg:FragmentTitle[@Context = 'P1group']/leg:Title">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="strElementName">
		<xsl:choose>
			<xsl:when test="$g_strDocumentType = $g_strSecondary">
				<xsl:text>h</xsl:text>
				<xsl:call-template name="FuncCalcHeadingLevel"/>
			</xsl:when>
			<!-- For Primary legislation main content  (or amendments to it) we need to use a floats mechanism for the output which requires span -->
			<xsl:when test="(ancestor::*[self::leg:Body or self::leg:EUBody or self::leg:Schedule or self::leg:BlockAmendment][1][(self::leg:Schedule and $g_strDocumentType = ($g_strEUretained)) or self::leg:Body or self::leg:EUBody or self::leg:BlockAmendment[(@Context = 'main') or (@Context = 'unknown')]]) and $g_strDocumentType = ($g_strPrimary, $g_strEUretained) and (not(parent::*/@Layout or parent::*/@Layout != 'below'))">span</xsl:when>
			<!-- Therefore for all other BlockAmendment permutations we assume a primary schedule layout -->
			<xsl:when test="(ancestor::*[self::leg:Body or self::leg:EUBody or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment][@TargetClass = 'primary' and @Context = 'schedule'] or parent::*/@Layout = 'below') and $g_strDocumentType = ($g_strPrimary, $g_strEUretained)">
				<xsl:text>h</xsl:text>
				<xsl:call-template name="FuncCalcHeadingLevel"/>
			</xsl:when>
			<!-- For P1group titles in primary schedules they form a heading on their own -->
			<xsl:when test="ancestor::leg:Schedule and $g_strDocumentType = ($g_strPrimary, $g_strEUretained)">
				<xsl:text>h</xsl:text>
				<xsl:call-template name="FuncCalcHeadingLevel"/>
			</xsl:when>
			<xsl:otherwise>span</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:element name="{$strElementName}">
		<xsl:attribute name="class">
			<xsl:if test="$strElementName = 'span'">LegDS </xsl:if>
			<xsl:text>LegP1GroupTitle</xsl:text>
			<xsl:if test="parent::*/preceding-sibling::*[1][self::leg:Title or self::leg:Number]">First</xsl:if>
		</xsl:attribute>
		<xsl:choose>
			<xsl:when test="ancestor::leg:BlockAmendment">
				<xsl:attribute name="class">
					<xsl:if test="$strElementName = 'span'">LegDS </xsl:if>
					<xsl:text>Leg</xsl:text>
					<xsl:call-template name="FuncGetScheduleContext"/>
					<xsl:text>P1GroupTitle</xsl:text>
					<!-- If this heading has a below to force the number below the title then simulate the schedule layout -->
					<xsl:if test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained) and parent::*/@Layout = 'below'">Below</xsl:if>
					<xsl:if test="$strAmendmentSuffix != ''">
						<!-- When first heading in an amendment we need to close up the space -->
						<xsl:if test="parent::*[parent::leg:BlockAmendment and not(preceding-sibling::*)] or not(parent::*/preceding-sibling::*) or parent::*/preceding-sibling::*[1][self::leg:Title or self::leg:Number]">
							<xsl:text>First</xsl:text>
						</xsl:if>
						<!-- We want a single class for primary due to the handling indent and multiple classes for secondary -->
						<xsl:if test="$g_strDocumentType = $g_strSecondary">
							<xsl:text> Leg</xsl:text>
						</xsl:if>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:if>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="ancestor::leg:Schedule and $g_strDocumentType = ($g_strPrimary)">
				<xsl:attribute name="class">
					<xsl:text>LegClearFix LegSP1GroupTitle</xsl:text>
					<xsl:if test="parent::*/preceding-sibling::*[1][self::leg:Title or self::leg:Number]">First</xsl:if>
				</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:for-each select="..">
			<xsl:call-template name="FuncCheckForID"/>		
		</xsl:for-each>
		<xsl:if test="$g_strDocumentType = $g_strSecondary and ((ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']]) or parent::leg:P1group/@Layout = 'side')">
			<xsl:apply-templates select="parent::*/leg:P1[1]/leg:Pnumber/node()"/>
			<xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
		</xsl:if>
		<xsl:call-template name="FuncCheckForIDnoElement" />
		<xsl:apply-templates/>
	</xsl:element>
	<!--HA053653: process annotations appearing in a P1group/Title element so that the annotation doesn't end up outside the P1group after other annotations which appear further down in the P1group structure-->
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>

</xsl:template>

<xsl:template match="leg:P1">
<!--	<xsl:if test="not(parent::leg:P1group) or preceding-sibling::leg:P1">
		<xsl:call-template name="FuncCheckForIDelement"/>
		</xsl:if>-->
<xsl:apply-templates select="." mode="showEN" /> 
		<xsl:apply-templates select="*[not(self::leg:Pnumber)] | processing-instruction()"/>
		<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>



<xsl:template match="*" mode="showEN" />

<xsl:template match="leg:P1/leg:Pnumber">
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="strContext">
		<xsl:call-template name="FuncGetContext"/>
	</xsl:variable>
	<!--<span class="LegP1No">
		<xsl:call-template name="FuncGetPnumberID"/>
		<xsl:apply-templates/> 
		</span>-->
	<!-- Chunyu HA049771 asp/2005/6 Added the condition for P1 is not the first in P1group -->
	<!-- Julian    HA056190 - ssi/2005/190/article/2/made. Refined condition as it caused problems with the SSI specified. I think the fix which removed styling from P1s other than the first in
	the P1Group is only required when the 1st P1 becomes a header (<hn>) not a para (<p>) - this is done in the code following from line 1756, which is only applied for primary legislation. --> 
	<xsl:choose>
		<xsl:when test="(parent::leg:P1[not(preceding-sibling::leg:P1) and (parent::leg:P1group)]) or not($g_strDocumentType = ($g_strPrimary, $g_strEUretained))">
			<span>
				<xsl:attribute name="class">
					<xsl:text>LegP1No</xsl:text>
					<xsl:if test="$strAmendmentSuffix != ''">
						<xsl:if test="$strContext = $g_strSecondary and $g_strDocumentType = $g_strSecondary">
							<xsl:text> Leg</xsl:text>
						</xsl:if>
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:if>
				</xsl:attribute>
				<xsl:call-template name="FuncGetPnumberID"/>
				<xsl:apply-templates/> 
			</span>
		</xsl:when>
		<xsl:otherwise>
			<span>
			<xsl:apply-templates/>
			</span> 
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>

<xsl:template match="leg:Pnumber">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:P1para">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:P2group">
	<xsl:call-template name="FuncCheckForIDelement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:P2group/leg:Title">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<!--HA065320: hack to fix issue with dodgy sld structure. List should have been set up as a table but for some reason is 
	a unordered list in a P2 paragraph with the Pnumber replaced by the table heading "PART II". TNA refused to amend the source 
	data as it had passed validation so had to be resolved by this workaround-->
	<xsl:if test="(following-sibling::leg:P2/leg:Pnumber) and (starts-with(following-sibling::leg:P2[1]/leg:Pnumber[1],'PART'))">
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:attribute name="class">
				<xsl:text>LegP2GroupTitle</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> LegP2GroupTitle</xsl:text>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			<strong><xsl:value-of select="following-sibling::leg:P2/leg:Pnumber"/></strong>
		</xsl:element>
	</xsl:if>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:attribute name="class">
			<xsl:text>LegP2GroupTitle</xsl:text>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:text> LegP2GroupTitle</xsl:text>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
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

<xsl:template match="leg:P3group">
	<xsl:call-template name="FuncCheckForIDelement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:P3group/leg:Title">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:variable name="p3no" select="following-sibling::*[1][self::leg:P3]/leg:Pnumber"/>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:attribute name="class">
			<xsl:text>LegP3GroupTitle</xsl:text>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:text> LegP3GroupTitle</xsl:text>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
		<xsl:call-template name="FuncCheckForID"/>
<!-- Chunyu added condition for p1para/p3group/title see uksi19922792 schedule  HA048533-->
		<xsl:if test="ancestor::leg:P1para[1]">
			<span class="LegP3No">
			<xsl:call-template name="FuncGetPnumberID"/>
		<xsl:apply-templates select="$p3no"/>
		<xsl:text>    </xsl:text>
		</span>
	
	</xsl:if>
		<xsl:apply-templates/>
	</xsl:element>
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
		<xsl:when test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained) or ($g_strDocumentType = $g_strSecondary and string(@Class) != 'Definition')">
			<!-- Generate suffix to be added for CSS classes for amendments -->
			<xsl:variable name="strAmendmentSuffix">
				<xsl:call-template name="FuncCalcAmendmentNo"/>
			</xsl:variable>
			<xsl:variable name="strPrimaryContext">
				<xsl:call-template name="FuncGetPrimaryContext"/>
			</xsl:variable>
			<ul>
				<xsl:call-template name="FuncCheckForID"/>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="@Decoration = 'none'">LegTabbed</xsl:when>
						<xsl:when test="@Decoration = 'dash'">LegDashed</xsl:when>
						<xsl:when test="@Decoration = 'bullet'">LegBulleted</xsl:when>
					</xsl:choose>
					<xsl:if test="@Class = 'Definition'">
						<xsl:text>Def</xsl:text>
					</xsl:if>
					<xsl:value-of select="$strAmendmentSuffix"/>
					<xsl:text> LegUnorderedList</xsl:text>
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
		<xsl:when test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained) or ($g_strDocumentType = $g_strSecondary and string(parent::*/@Class) != 'Definition')">
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
	<div class="LegClearFix LegKeyListItem">
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
			<xsl:text>LegListItemNo LegKey</xsl:text>
			<!-- this is a rule to get around the lack of markup in EU legislation  -->
			<xsl:if test="$g_strDocumentType = $g_strEUretained and (ancestor::leg:KeyList[1]/@Separator = '' or empty(ancestor::leg:KeyList[1]/@Separator) or matches(., '^[0-9]+\.|^\([ivx]+\)'))">EU</xsl:if>
			<xsl:call-template name="FuncCalcListClass"/>
			<xsl:value-of select="$strAmendmentSuffix"/>
		</xsl:attribute>
		<xsl:apply-templates/>
	</div>
	<xsl:if test="ancestor::leg:KeyList[1]/@Separator != ''">
		<p class="LegKeySeparator">
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
		<xsl:if test="$g_strDocumentType = $g_strEUretained">
			<xsl:attribute name="class">
				<xsl:text>LegClearFix</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="FuncGetListAncestry"/>
		<div>
			<xsl:call-template name="FuncCheckForID"/>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="@Type = 'alpha' or @Type = 'alphaUpper'">LegAlphaList</xsl:when>
					<xsl:when test="@Type = 'roman' or @Type = 'romanUpper'">LegRomanList</xsl:when>
					<xsl:when test="@Type = 'arabic'">LegArabicList</xsl:when>					
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="* | processing-instruction()"/>
		</div>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template name="FuncGetListAncestry">
	<!-- Calculate the initial context of the list -->
	<xsl:for-each select="ancestor::*[self::leg:P3para or self::leg:P4para or self::leg:P5para or self::leg:P6para or self::leg:P7para or self::leg:BlockAmendment][1]">
		<xsl:if test="not(self::leg:BlockAmendment)">
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="self::leg:P3para">LegP3list</xsl:when>
					<xsl:when test="self::leg:P4para">LegP4list</xsl:when>
					<xsl:when test="self::leg:P5para">LegP5list</xsl:when>
					<xsl:when test="self::leg:P6para">LegP6list</xsl:when>
					<xsl:when test="self::leg:P7para">LegP7list</xsl:when>
				</xsl:choose>
				<xsl:call-template name="FuncCalcAmendmentNo"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="leg:OrderedList/leg:ListItem | leg:BlockAmendment/leg:ListItem">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<div class="LegListItem">
		<xsl:call-template name="FuncCheckForID"/>
		
		<!-- If a direct nested list item output number from parent list item also -->
		<xsl:if test="not(child::*[1][self::leg:OrderedList])">
			<xsl:variable name="strListClass">
				<xsl:call-template name="FuncCalcListClass"/>
			</xsl:variable>
<!-- Mark R 11/04/2014: Call HA054841 - Action HH518119: Additional check that the current ListItem does not have a NumberOverride attribute.
		If it does then the parent number is not output. -->
			<!-- Mark J 12/11/2015: Call HA066563: Removed as output of parent ListItem enumerator duplicates this content so seems to serve little purpose -->
			<!--<xsl:if test="not(preceding-sibling::leg:ListItem) and parent::leg:OrderedList/parent::leg:ListItem/parent::leg:OrderedList and not(@NumberOverride)">
				<div class="{concat('LegLeftNo', $strListClass, 'No', $strAmendmentSuffix, ' LegListItemNo')}">
					<xsl:for-each select="ancestor::leg:ListItem[1]">
						<xsl:call-template name="FuncOutputListItemNumber"/>
					</xsl:for-each>
				</div>
			</xsl:if>-->
			<div>
				<xsl:attribute name="class">
					<!--<xsl:if test="not(preceding-sibling::leg:ListItem) and parent::leg:OrderedList/parent::leg:ListItem/parent::leg:OrderedList and not(@NumberOverride)">
						<xsl:text>LegRightNo</xsl:text>
					</xsl:if>-->
					<xsl:value-of select="$strListClass"/>
					<xsl:text>No</xsl:text>
					<xsl:if test="preceding-sibling::leg:ListItem or not(parent::leg:OrderedList/parent::leg:ListItem/parent::leg:OrderedList)">
						<xsl:value-of select="$strAmendmentSuffix"/>
					</xsl:if>
					<xsl:text> LegListItemNo</xsl:text>
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
		<!--			<xsl:value-of select="$strPreText"/>
			<xsl:value-of select="@NumberOverride"/>
			<xsl:value-of select="$strPostText"/>-->
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
	<xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:variable name="strTextNode" as="xs:string" select="generate-id(descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()])"/>
	<xsl:apply-templates select="* | processing-instruction()">
		<xsl:with-param name="seqLastTextNodes" tunnel="yes" select="$seqLastTextNodes, $strTextNode" as="xs:string*"/>
	</xsl:apply-templates>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:AppendText"/>


<!-- ========== Block text ========== -->

<xsl:template match="leg:BlockText">
	<div class="LegBlockText">
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates select="* | processing-instruction()"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<!-- ========== Extracts ========== -->

<xsl:template match="leg:BlockExtract">
	<xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
 	<xsl:variable name="strTextNode" as="xs:string" select="generate-id(descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()])"/>
	<xsl:apply-templates select="* | processing-instruction()">
		<xsl:with-param name="seqLastTextNodes" tunnel="yes" select="$seqLastTextNodes, $strTextNode" as="xs:string*"/>
	</xsl:apply-templates>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<!-- ========== Signatures ========== -->

<xsl:template match="leg:SignedSection">
	<div class="LegClearFix LegSignedSection">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Signatory">
	<div class="LegClearFix LegSignatory">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</div>
</xsl:template>

<xsl:template match="leg:Signee">
	<div class="LegClearFix LegSignee">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</div>
</xsl:template>

<xsl:template match="leg:PersonName">
	<p class="LegPersonName">
		<xsl:if test="preceding-sibling::*[1][self::leg:Department or self::leg:JobTitle]">
			<xsl:attribute name="class">LegPersonName SignatureSpace</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:JobTitle">
	<p class="LegJobTitle">
		<xsl:if test="preceding-sibling::*[1][self::leg:Department]">
			<xsl:attribute name="class">LegJobTitle SignatureSpace</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:Department">
	<p class="LegDepartment">
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:DateSigned">
	<p class="LegDateSigned">
		<xsl:apply-templates select="* | processing-instruction()"/>
	</p>
</xsl:template>

<xsl:template match="leg:DateSigned/leg:DateText">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:Address">
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>

<xsl:template match="leg:AddressLine">
	<p class="LegAddressLine">
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:LSseal">
	<!-- If there is an image link use that else if there is not text then just output L.S. -->
	<xsl:choose>
		<xsl:when test="@ResourceRef">
			<xsl:apply-templates select="$g_ndsResources[@id = current()/@ResourceRef]">
				<xsl:with-param name="strContext" select="'Seal'"/>
				<xsl:with-param name="strDisplayFormat" select="'Display'"/>
				<xsl:with-param name="strAltAttributeDesc" select="'Legal seal'"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:when test="node()[not(normalize-space() = '')]">
			<p class="LegSealText">
				<xsl:apply-templates/>
			</p>
		</xsl:when>
		<xsl:otherwise>
			<p class="LegSealText">L.S.</p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- ========== Schedule ========== -->

<xsl:template match="leg:Schedules">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Schedules/leg:Title">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:attribute name="class">
			<xsl:value-of select="concat('LegSchedulesTitle', $strAmendmentSuffix)"/>
		</xsl:attribute>
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:Schedule/leg:TitleBlock">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>

<xsl:template match="leg:ScheduleBody">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<!-- ========== Abstract ========== -->

<xsl:template match="leg:Abstract">
	<xsl:call-template name="FuncCheckForID"/>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:attribute name="class">LegAbstract</xsl:attribute>
		<xsl:apply-templates select="leg:Number | leg:Title | leg:TitleBlock | processing-instruction()[following-sibling::leg:Number or following-sibling::leg:Title]"/>
	</xsl:element>
	<xsl:apply-templates select="*[not(self::leg:Number or self::leg:Title or self::leg:TitleBlock)] | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Abstract/leg:Number">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:element name="span">
		<xsl:attribute name="class">
			<xsl:value-of select="concat('LegAbstractNo', $strAmendmentSuffix)"/>
		</xsl:attribute>
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:Abstract/leg:TitleBlock">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Abstract/leg:TitleBlock/leg:Title">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:element name="span">
		<xsl:attribute name="class">
			<xsl:value-of select="concat('LegAbstractTitle', $strAmendmentSuffix)"/>
		</xsl:attribute>
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:Abstract/leg:TitleBlock/leg:Subtitle">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:element name="span">
		<xsl:attribute name="class">
			<xsl:value-of select="concat('LegAbstractSubtitle', $strAmendmentSuffix)"/>
		</xsl:attribute>
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:AbstractBody">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>


<!-- ========== Appendix ========== -->

<xsl:template match="leg:Appendix">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:attribute name="class">LegAppendix</xsl:attribute>
		<xsl:apply-templates select="leg:Number | leg:Title | leg:TitleBlock | processing-instruction()[following-sibling::leg:Number or following-sibling::leg:Title]"/>
	</xsl:element>
	<xsl:apply-templates select="*[not(self::leg:Number or self::leg:Title or self::leg:TitleBlock)] | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Appendix/leg:Number">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:element name="span">
		<xsl:attribute name="class">
			<xsl:value-of select="concat('LegAppendixNo', $strAmendmentSuffix)"/>
		</xsl:attribute>
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:Appendix/leg:TitleBlock">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Appendix/leg:TitleBlock/leg:Title">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:element name="span">
		<xsl:attribute name="class">
			<xsl:value-of select="concat('LegAppendixTitle', $strAmendmentSuffix)"/>
		</xsl:attribute>
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:Appendix/leg:TitleBlock/leg:Subtitle">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:element name="span">
		<xsl:attribute name="class">
			<xsl:value-of select="concat('LegAppendixSubtitle', $strAmendmentSuffix)"/>
		</xsl:attribute>
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:AppendixBody">
	<xsl:call-template name="FuncCheckForIDnoElement"/>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<!-- ========== Explanatory notes/Earlier orders ========== -->

<xsl:template match="leg:ExplanatoryNotes">
	<!-- The title is not obligatory as is always there - therefore if missing we will autogenerate -->
	<!-- We will generate a standard anchor name for the explanatory note -->
	<xsl:if test="not(ancestor::leg:Versions)">
		<xsl:call-template name="FuncCheckForIDnoElement">
			<xsl:with-param name="strID" select="'Legislation-ExNote'"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:call-template name="FuncCheckForIDnoElement"/>	
	<xsl:if test="not(leg:Title)">
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">LegExpNoteTitle</xsl:attribute>
			<xsl:if test="not(leg:Comment)">
				<xsl:attribute name="class">LegExpNoteTitleNoComment</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$g_ndsMetadata/dc:language = 'cy'">Nodyn Esboniadol</xsl:when>
				<xsl:otherwise>Explanatory Note</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:if>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:EarlierOrders">
	<!-- The title is not obligatory as is always there - therefore if missing we will autogenerate -->
	<xsl:call-template name="FuncCheckForIDnoElement"/>		
	<!-- We will generate a standard anchor name for the earlier orders -->
	<xsl:if test="not(ancestor::leg:Versions)">
		<xsl:call-template name="FuncCheckForIDnoElement">
			<xsl:with-param name="strID" select="'Legislation-EaNote'"/>
		</xsl:call-template>	
	</xsl:if>
	<xsl:if test="not(leg:Title)">
		<xsl:variable name="intHeadingLevel">
			<xsl:call-template name="FuncCalcHeadingLevel"/>
		</xsl:variable>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">LegExpNoteTitle</xsl:attribute>
			<xsl:if test="not(leg:Comment)">
				<xsl:attribute name="class">LegExpNoteTitleNoComment</xsl:attribute>
			</xsl:if>		
			<xsl:choose>
				<xsl:when test="$g_ndsMetadata/dc:language = 'cy'">Nodyn Orchymyn Cychwyn Blaenorol</xsl:when>
				<xsl:otherwise>Note as to Earlier Commencement Orders</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:if>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ExplanatoryNotes/leg:Title | leg:EarlierOrders/leg:Title">
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:attribute name="class">LegExpNoteTitle</xsl:attribute>
		<!-- If not comment we need a bit of space after the title -->
		<xsl:if test="not(following-sibling::leg:Comment)">
			<xsl:attribute name="class">LegExpNoteTitleNoComment</xsl:attribute>
		</xsl:if>		
		<xsl:call-template name="FuncCheckForID"/>		
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:Comment">
	<xsl:call-template name="FuncCheckForIDnoElement"/>	
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>


<!-- ========== Fragments ========= -->

<xsl:template match="leg:FragmentNumber">
	<xsl:variable name="strElementName">
		<xsl:text>h</xsl:text>
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="not(preceding-sibling::*) and (parent::leg:ScheduleBody or parent::leg:AppendixBody)">
			<div class="LegClear{name()}First"/>
		</xsl:when>
		<xsl:otherwise>
			<div class="LegClear{name()}"/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="FuncCheckForIDelement"/>
	<xsl:element name="{$strElementName}">
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="@Context = 'Group'">LegGroupNo</xsl:when>
				<xsl:when test="@Context = 'Part'">LegPartNo</xsl:when>
				<xsl:when test="@Context = 'Chapter'">LegChapterNo</xsl:when>
				<xsl:when test="@Context = 'Pblock'">LegPblockNo</xsl:when>
				<xsl:when test="@Context = 'PsubBlock'">LegPsubBlockNo</xsl:when>
				<xsl:when test="@Context = 'Schedule'">LegScheduleNo</xsl:when>
			</xsl:choose>
			<xsl:variable name="strAmendmentSuffix">
				<xsl:call-template name="FuncCalcAmendmentNo"/>
			</xsl:variable>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:text> Leg</xsl:text>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates select="leg:Number/node() | processing-instruction()"/>
	</xsl:element>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:FragmentTitle[@Context = 'P1group']">
	<xsl:call-template name="TSOprocessP1group"/>
</xsl:template>

<xsl:template match="leg:FragmentTitle[@Context != 'P1group']">
	<xsl:variable name="strElementName">
		<xsl:choose>
			<xsl:when test="@Context = 'Footnote'">p</xsl:when>
			<xsl:otherwise>
				<xsl:text>h</xsl:text>
				<xsl:call-template name="FuncCalcHeadingLevel"/>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="not(preceding-sibling::leg:FragmentNumber)">
		<xsl:choose>
			<xsl:when test="not(preceding-sibling::*) and (parent::leg:ScheduleBody or parent::leg:AppendixBody)">
				<div class="LegClear{@Context}First"/>
			</xsl:when>
			<xsl:otherwise>
				<div class="LegClear{@Context}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>	
	<xsl:call-template name="FuncCheckForIDelement"/>
	<xsl:element name="{$strElementName}">
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="@Context = 'Group'">LegGroupTitle</xsl:when>
				<xsl:when test="@Context = 'Part'">LegPartTitle</xsl:when>
				<xsl:when test="@Context = 'Chapter'">LegChapterTitle</xsl:when>
				<xsl:when test="@Context = 'Pblock'">LegPblockTitle</xsl:when>
				<xsl:when test="@Context = 'PsubBlock'">LegPsubBlockTitle</xsl:when>
				<xsl:when test="@Context = 'Schedule'">LegScheduleTitle</xsl:when>
				<xsl:when test="@Context = 'Figure'">LegFigureTitle</xsl:when>
				<xsl:when test="@Context = 'P2group'">LegP2GroupTitle</xsl:when>
				<xsl:when test="@Context = 'P3group'">LegP3GroupTitle</xsl:when>
			</xsl:choose>
			<xsl:variable name="strAmendmentSuffix">
				<xsl:call-template name="FuncCalcAmendmentNo"/>
			</xsl:variable>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:text> Leg</xsl:text>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates select="leg:Title/node() | processing-instruction()"/>
	</xsl:element>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<!-- ========== Tables ========== -->

<xsl:template match="leg:Tabular">
	<div class="LegTabular">
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
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:attribute name="class">
			<xsl:text>LegTableNo</xsl:text>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:text> Leg</xsl:text>
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
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:attribute name="class">
			<xsl:text>LegTableTitle</xsl:text>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:text> Leg</xsl:text>
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
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:element name="h{$intHeadingLevel + 1}">
		<xsl:attribute name="class">
			<xsl:text>LegTableSubtitle</xsl:text>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:text> Leg</xsl:text>
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
			<xsl:text>LegClearFix LegTableContainer</xsl:text>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:text> Leg</xsl:text>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
		
		<table class="LegTable" cellpadding="5">
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
	<th class="LegTHplain">
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
			<xsl:with-param name="strCellType" select="'LegTH'"/>
		</xsl:call-template>
	</th>
</xsl:template>

<xsl:template match="xhtml:td">
	<td class="LegTDplain">
		<xsl:attribute name="id">
			<xsl:call-template name="FuncGenerateAnchorID"/>
		</xsl:attribute>
		<xsl:call-template name="FuncProcessCellContent">
			<xsl:with-param name="strCellType" select="'LegTD'"/>
		</xsl:call-template>
	</td>
</xsl:template>

<xsl:template name="FuncProcessCellContent">
	<xsl:param name="strCellType"/>
	<!-- By default assume plain text in cell unless there is structural markup -->
	<xsl:if test="child::*[(self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps)]">
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
			<xsl:when test="self::text() and parent::*[child::*[not(
														self::leg:Emphasis or 
														self::leg:Strong or 
														self::leg:Superior or 
														self::leg:Inferior or 
														self::leg:Addition or 
														self::leg:Repeal or 
														self::leg:Substitution or 
														self::leg:CommentaryRef or 
														self::leg:Citation or 														 
														self::leg:CitationSubRef or 
														self::math:math or 
														self::leg:Character or 
														self::leg:FootnoteRef or 
														self::leg:Span or 
														self::leg:Term or 
														self::leg:Definition or 
														self::leg:Proviso or 
														self::leg:MarginNoteRef or 
														self::leg:Underline or 
														self::leg:SmallCaps or 
														self::leg:Acronym or
														self::leg:Abbreviation or
														self::leg:InlineAmendment or
														self::leg:CitationListRef or
														self::leg:InlineExtract or
														self::leg:InternalLink or
														self::leg:ExternalLink or
														self::leg:Image or
														self::err:Error or
														self::err:Warning)]]">
				<span class="LegTDmixedText">
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
<!-- #HA057536 - MJ: output resources if file contains no main content -->
<xsl:template match="leg:Resources">
	<xsl:if test="not(preceding-sibling::leg:Primary or preceding-sibling::leg:Secondary or preceding-sibling::leg:EURetained)">
		<xsl:apply-templates/>
	</xsl:if>
</xsl:template>

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
				<!-- MSXML -->
				<xsl:with-param name="ndsResourceToUse" select="$rtfContent"/>
				<xsl:with-param name="intIDofItemToReplace" select="$intIDofItemToReplace"/>
				<xsl:with-param name="strResource" select="$strResource"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- Now process the version that has been pulled into the correct context -->
	<!-- MSXML -->
	<xsl:for-each select="$rtfNormalisedDoc">
		<xsl:apply-templates select="//*[@ResourceReplacement = 'True']"/>
	</xsl:for-each>
	
	<!-- #HA057536 - MJ: output XML content within resource if file contains no main content -->
	<xsl:if test="not(ancestor::leg:Resources/(preceding-sibling::leg:Primary, preceding-sibling::leg:Secondary))">
		<xsl:apply-templates select="leg:InternalVersion/leg:XMLcontent/node()"/>
	</xsl:if>
	
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
					<xsl:attribute name="ResourceReference"><xsl:value-of select="$strResource"/></xsl:attribute>
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
	<div class="LegSVGcontainer">
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
	<!-- MSXML -->
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
					<xsl:attribute name="VersionReference"><xsl:value-of select="$strVersion"/></xsl:attribute>
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


<!-- ========== Footnotes ========== -->

<xsl:template match="leg:Footnotes">
	<div class="LegFootnotes">		
		<div class="LegClearFix LegFootnotesContainer">
			<xsl:apply-templates select="* | processing-instruction()"/>
		</div>
		<xsl:if test="$g_strDocumentType = $g_strEUretained">
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		</xsl:if>
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
								<xsl:apply-templates select="leg:Number"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>(</xsl:text>
							<span class="LegFootnoteNo">
								<xsl:value-of select="count(preceding-sibling::leg:Footnote) + 1"/>
							</span>
							<xsl:text>)</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- Table footnote -->
				<xsl:otherwise>
					<xsl:variable name="strTfootID" select="generate-id((ancestor::xhtml:tfoot)[1])"/>
					<xsl:variable name="intFootnoteNo" select="count(preceding::leg:Footnote[generate-id((ancestor::xhtml:tfoot)[1]) = $strTfootID]) + 1"/>
					<sup class="LegTableFootnoteNo">
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
	<xsl:call-template name="FuncCheckForStartOfQuote"/>
	<xsl:choose>
		<!-- Standard footnote -->
		<xsl:when test="$g_ndsFootnotes[@id = current()/@Ref]/ancestor::leg:Footnotes">
			<xsl:text>(</xsl:text>
			<xsl:call-template name="FuncGenerateFootnoteLink"/>
			<xsl:text>)</xsl:text>
		</xsl:when>
		<!-- Table footnote -->
		<xsl:otherwise>
			<sup class="LegTableFootnoteRef">
				<xsl:call-template name="FuncGenerateFootnoteLink"/>
			</sup>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="FuncCheckForEndOfQuote"/>
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
				<xsl:variable name="strTfootID" select="generate-id($g_ndsFootnotes[@id = current()/@Ref]/ancestor::xhtml:tfoot[1])"/>
				<xsl:variable name="intFootnoteNo" select="count($g_ndsFootnotes[@id = current()/@Ref]/preceding::leg:Footnote[generate-id(ancestor::xhtml:tfoot[1]) = $strTfootID]) + 1"/>
				<xsl:call-template name="FuncGenerateTableFootnoteNo">
					<xsl:with-param name="intFootnoteNo" select="$intFootnoteNo"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<a class="LegFootnoteRef" href="#{@Ref}" title="Go to footnote {$strFootnoteNo}">
		<!-- In case there are multiple cross-references to the same footnote only provide a single point for the back function -->
		<xsl:if test="not(preceding-sibling::leg:FootnoteRef[@Ref = current()/@Ref] or preceding::leg:FootnoteRef[@Ref = current()/@Ref])">
			<xsl:attribute name="id"><xsl:text>Back</xsl:text><xsl:value-of select="@Ref"/></xsl:attribute>
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



<!-- ========== MarginNotes ========== -->

<xsl:template match="leg:MarginNotes">
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>

<xsl:template match="leg:MarginNote">
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>

<xsl:template match="leg:MarginNoteRef">
	<xsl:if test="$g_ndsMarginNotes[@id = current()/@Ref]/ancestor::leg:MarginNotes">
		<span class="LegMarginNoteRef" id="{@Ref}">
			<xsl:text>[</xsl:text>
			<xsl:value-of select="normalize-space($g_ndsMarginNotes[@id = current()/@Ref])"/>
			<xsl:text>] </xsl:text>
		</span>
	</xsl:if>
</xsl:template>


<!-- ========== Abbreviations ========== -->

<xsl:template match="leg:Abbreviation">
	
		<xsl:apply-templates/>
	<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
	<xsl:call-template name="FuncIsLastElementInFootnote"/>
</xsl:template>

<xsl:template match="leg:Acronym">
		<xsl:apply-templates/>
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
	<xsl:apply-templates/>
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
	<p class="LegFigureNumber">
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:Figure/leg:Title">
	<p class="LegFigureTitle">
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

	<xsl:call-template name="FuncCheckForStartOfQuote"/>
	
	<xsl:call-template name="FuncCheckForIDelement"/>
	
	<xsl:apply-templates select="$g_ndsResources[@id = current()/@ResourceRef]">
		<xsl:with-param name="strContext" select="'Image'"/>
		<xsl:with-param name="strDisplayFormat" select="$strDisplayFormat"/>
		<xsl:with-param name="strAltAttributeDesc" select="$strAltAttributeDesc"/>
		<xsl:with-param name="dblWidth" select="@Width"/>
		<xsl:with-param name="dblHeight" select="@Height"/>
	</xsl:apply-templates>
	<xsl:call-template name="FuncCheckForEndOfQuote"/>
		
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
				<xsl:attribute name="class">LegDisplayImage</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="class">LegInlineImage</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="number($dblWidth) != 0 and $dblWidth != '' and $dblWidth != 'auto'">
			<xsl:choose>
				<xsl:when test="matches(normalize-space($dblWidth),'^[0-9]+(\.)?[0-9]*(\s)*pt') and substring-before($dblWidth,'pt') castable as xs:double">
					<xsl:attribute name="width">
						<xsl:value-of select="format-number(
(number(substring-before($dblWidth,'pt'))*96) div 72,'###0.')"/>
						<xsl:text>px</xsl:text>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="matches(normalize-space($dblWidth),'^[0-9]+(\.)?[0-9]*(\s)*mm') and substring-before($dblWidth,'mm') castable as xs:double">
					<xsl:attribute name="width">
						<xsl:value-of select="format-number(
(number(substring-before($dblWidth,'mm'))*96) div 25.4,'###0.')"/>
						<xsl:text>px</xsl:text>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="width" select="$dblWidth"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="number($dblHeight) != 0 and $dblHeight != '' and $dblHeight != 'auto'">
			<xsl:choose>
				<xsl:when test="matches(normalize-space($dblHeight),'^[0-9]+(\.)?[0-9]*(\s)*pt') and substring-before($dblHeight,'pt') castable as xs:double">
					<xsl:attribute name="height">
						<xsl:value-of select="format-number(
(number(substring-before($dblHeight,'pt'))*96) div 72,'###0.')"/>
						<xsl:text>px</xsl:text>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="matches(normalize-space($dblHeight),'^[0-9]+(\.)?[0-9]*(\s)*mm') and substring-before($dblHeight,'mm') castable as xs:double">
					<xsl:attribute name="height">
						<xsl:value-of select="format-number(
(number(substring-before($dblHeight,'mm'))*96) div 25.4,'###0.')"/>
						<xsl:text>px</xsl:text>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="height" select="$dblHeight"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</img>
</xsl:template>


<!-- ========== Included documents ========== -->

<xsl:template match="leg:IncludedDocument">
	<xsl:call-template name="FuncCheckForStartOfQuote"/>
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
	<xsl:call-template name="FuncCheckForEndOfQuote"/>
</xsl:template>


<!-- ========== Decorated groups ========== -->

<xsl:template match="leg:DecoratedGroup">
	<div class="LegDecoratedGroupLeft">
		<xsl:apply-templates select="child::*[1] | processing-instruction()"/>
	</div>
	<xsl:if test="child::*[1][self::leg:GroupItem]">
		<div class="LegDecoratedGroupRight">
			<xsl:apply-templates select="child::*[2]"/>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:GroupItem">
	<xsl:apply-templates select="* | processing-instruction()"/>
</xsl:template>

<xsl:template match="leg:GroupItemRef"/>


<!-- ========== Inline formatting ========== -->

<xsl:template match="leg:Strong">
	<strong>
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>
	</strong>
</xsl:template>
	
	<!-- Yashashri : changed to make Headings Italic - Support call- 	HA047941-->
	<!-- Chunyu HA050076 Added em back to the template with the condition -->
	<!--2013-04-30 Update to HA051074 GC -->
	<!--Only remove the emphasis if it is a UKCI -->
	<!--Only apply to ENs in ukci's where there is either an Emphasis or Strong element and no textual content-->
<xsl:template match="leg:Emphasis">	
	<xsl:choose>
		<xsl:when test="parent::leg:Title/parent::leg:Pblock or 
		($g_strDocumentMainType = 'UnitedKingdomChurchInstrument' and parent::leg:Text/parent::leg:P/parent::leg:ExplanatoryNotes)">
			<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>	
		</xsl:when>
		<xsl:otherwise>
			<em>
				<xsl:call-template name="FuncCheckForID"/>
				<xsl:apply-templates/>	
			</em>
		   <!-- JDC HA069475 - Do post ops separately so they don't also come out in italics. -->  
		   <xsl:apply-templates mode="PostOpsOnly"/>	
		</xsl:otherwise>
	</xsl:choose>
	
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

<xsl:template match="leg:Inferior">
	<sub>
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:apply-templates/>
	</sub>
	<!-- Check if last node in a footnote in which case output back link if a standard footnote -->
	<xsl:call-template name="FuncIsLastElementInFootnote"/>
</xsl:template>

<xsl:template match="leg:SmallCaps">
	<span class="LegSmallcaps">
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
	<xsl:variable name="ndsTargetElement" select="(//*[@id = $strLinkRef])[1]"/>
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
					<xsl:if test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained)">
						<xsl:text> </xsl:text>
						<xsl:value-of select="$ndsTargetElement/parent::leg:P1group/leg:Title"/>
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$ndsTargetElement/ancestor::*[self::leg:P1 or self::leg:BlockAmendment or self::leg:ListItem][last()][self::leg:P1]">
					<xsl:call-template name="FuncFormatParagraphNumberForInternalLink">
						<xsl:with-param name="ndsNumberNode" select="$ndsTargetElement/ancestor::leg:P1[last()]/leg:Pnumber"/>
					</xsl:call-template>
					<xsl:if test="$g_strDocumentType = ($g_strPrimary, $g_strEUretained)">
						<xsl:text> </xsl:text>
						<xsl:value-of select="$ndsTargetElement/ancestor::leg:P1group/leg:Title"/>
						<xsl:text> </xsl:text>
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
			<xsl:attribute name="title"><xsl:value-of select="$strTitleText"/></xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</a>
</xsl:template>


<!-- ========== External Link - non legislation items ========== -->

<xsl:template match="leg:ExternalLink">
	<a href="{@URI}">
		<xsl:if test="@Title">
			<xsl:attribute name="title"><xsl:value-of select="@Title"/></xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</a>
</xsl:template>


<!-- ========== Characters ========== -->

<xsl:template match="leg:Character">
	<xsl:choose>
		<xsl:when test="@Name = 'DotPadding'">
			<xsl:text> ... ... ... ...</xsl:text>
		</xsl:when>
		<xsl:when test="@Name = 'BoxPadding'">
			<div class="boxpadding">&#160;</div>
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
	<xsl:call-template name="FuncCheckForEndOfQuote"/>	
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

<xsl:template match="text()" mode="PostOpsOnly">
   <xsl:call-template name="FuncTextPostOperations"/>
</xsl:template>
   
<xsl:template match="comment()">
	<xsl:copy-of select="."/>
</xsl:template>

<xsl:template name="FuncTextPreOperations">

	<xsl:call-template name="FuncCheckForStartOfQuote"/>
	
	<!-- Output generated text around paragraph numbers -->
	<xsl:if test="ancestor::leg:Pnumber and normalize-space(.) != ''">
		<xsl:choose>
			<xsl:when test="not(ancestor::leg:Pnumber/@PuncBefore) and ancestor::leg:Pnumber/parent::leg:P1"/>
			<xsl:when test="not(ancestor::leg:Pnumber/@PuncBefore) and $g_strDocumentType = $g_strEUretained and ancestor::leg:Pnumber/parent::*[self::leg:P2 or self::leg:P2group]"/>
			<xsl:when test="not(ancestor::leg:Pnumber/@PuncBefore)">(</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="ancestor::leg:Pnumber/@PuncBefore"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	
</xsl:template>

<xsl:template name="FuncTextPostOperations">
	<!-- Output generated text around paragraph numbers -->
	<xsl:if test="ancestor::leg:Pnumber and normalize-space(.) != ''">
		<xsl:choose>
			<xsl:when test="not(ancestor::leg:Pnumber/@PuncAfter) and ancestor::leg:Pnumber/parent::leg:P1 and $g_strDocumentType = $g_strPrimary"/>
			<xsl:when test="not(ancestor::leg:Pnumber/@PuncAfter) and $g_strDocumentType = $g_strEUretained"/>
			<xsl:when test="not(ancestor::leg:Pnumber/@PuncAfter) and ancestor::leg:Pnumber/parent::leg:P1">.</xsl:when>
			<xsl:when test="not(ancestor::leg:Pnumber/@PuncAfter)">)</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="ancestor::leg:Pnumber/@PuncAfter"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>

	<xsl:call-template name="FuncCheckForEndOfQuote"/>

	<!-- Check if  last node in a footnote in which case output back link if a standard footnote -->
	<xsl:if test="not(ancestor::leg:Citation or ancestor::leg:CitationSubRef or ancestor::leg:InternalLink or ancestor::leg:ExternalLink or ancestor::leg:Acronym or ancestor::leg:Abbreviation or ancestor::leg:Definition or ancestor::leg:Proviso or ancestor::leg:Superior or ancestor::leg:Inferior or ancestor::leg:SmallCaps or ancestor::leg:Underline) and ancestor::leg:Footnote[not(ancestor::xhtml:table)] and generate-id(ancestor::leg:Footnote[1]/descendant::text()[not(normalize-space() = '')][last()]) = generate-id()">
		<xsl:call-template name="FuncCheckForBackReference"/>
	</xsl:if>


	<!-- For primary legislation some amendments run on from the prevoius paragraph. Also allow it for very rare instances of secondary legislation where PartialRefs forces it -->
	<xsl:if test="($g_strDocumentType = ($g_strPrimary, $g_strEUretained) or ancestor::leg:Text[1]/following-sibling::*[1][self::leg:BlockAmendment[string(@PartialRefs) != '']]/child::*[1][self::leg:Text]) and generate-id(ancestor::leg:Text[1]/descendant::text()[not(normalize-space() = '')][last()]) = generate-id()">
		<xsl:if test="ancestor::leg:Text[1]/following-sibling::*[1][self::leg:BlockAmendment]/child::*[1][self::leg:Text]">
			<xsl:text> </xsl:text>
			<span class="LegRunOnAmendment">
				<xsl:apply-templates select="ancestor::leg:Text[1]/following-sibling::*[1][self::leg:BlockAmendment]/child::*[1]/node() | processing-instruction()"/>
			</span>
		</xsl:if>
	</xsl:if>

</xsl:template>


<!-- ========== Functions ========== -->

<xsl:template name="FuncIsLastElementInFootnote">
	<xsl:if test="ancestor::leg:Footnote[not(ancestor::xhtml:table)] and generate-id(ancestor::leg:Footnote/descendant::text()[not(normalize-space() = '')][last()]/parent::*) = generate-id()">
		<xsl:call-template name="FuncCheckForBackReference"/>
	</xsl:if>	
</xsl:template>

<!-- Check to see if we need to output a back reference for a footnote -->
<xsl:template name="FuncCheckForBackReference">
	<xsl:text> </xsl:text>
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
			<xsl:when test="not($ndsNumberNode/@PuncBefore) and $ndsNumberNode/parent::leg:P2 and $g_strDocumentType = $g_strEUretained"/>
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
			<xsl:when test="not($ndsNumberNode/@PuncAfter) and $ndsNumberNode/parent::leg:P2 and $g_strDocumentType = $g_strEUretained"/>
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
	<xsl:variable name="strFirstAmendmentID" select="generate-id(ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument or ancestor::xhtml:tfoot)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Image][1])"/>
	<xsl:choose>
		<xsl:when test="$strFirstAmendmentID = generate-id() and not(ancestor::*[self::leg:BlockAmendment or self::leg:OrderedList][1][self::leg:OrderedList]) and not(parent::leg:Title[following-sibling::*[1][self::leg:P1]]/parent::leg:P1group/@Layout = 'side') and not(parent::leg:Title[following-sibling::*[1][self::leg:P1]] and $g_strDocumentType = ($g_strPrimary, $g_strEUretained) and parent::leg:Title/parent::leg:P1group/parent::leg:BlockAmendment[1][@Context != 'schedule']) and not(parent::leg:Title[following-sibling::*[1][self::leg:P1]] and $g_strDocumentType = $g_strSecondary and ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])">
			<xsl:choose>
				<xsl:when test="self::leg:IncludedDocument or self::leg:Image">
					<p class="LegAmendQuoteOpen">
						<xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
					</p>
					
				</xsl:when>
				<xsl:otherwise>
					<span class="LegAmendQuote">
						<xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
					</span>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- Otherwise test if this is a P1group where the number of a P1 needs to be output at the side. This is tricky as the number is not the first node in the amendment - we need to check if the Title element is the first -->
		<xsl:when test="((parent::leg:Pnumber/parent::leg:P1/parent::leg:P1group[not(@Layout = 'below')]/ancestor::leg:BlockAmendment[1][@Context != 'schedule'] and $g_strDocumentType = ($g_strPrimary, $g_strEUretained)) or (parent::leg:Pnumber/parent::leg:P1/parent::leg:P1group[not(@Layout = 'below')] and $g_strDocumentType = $g_strSecondary and ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])) and generate-id(ancestor::leg:P1[1]/preceding-sibling::leg:Title/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character][1]) = $strFirstAmendmentID">
			<span class="LegAmendQuote">
				<xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
			</span>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<!-- Check if last node in an amendment in which case output quotes -->
<xsl:template name="FuncCheckForEndOfQuote">
		<xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
		<xsl:variable name="strIsTableFootnoteAtEnd">
			<!-- Is this node in table footnotes? -->
			<xsl:if test="ancestor::xhtml:tfoot">
				<!-- Is this the last node in the footnotes? -->
				<xsl:if test="generate-id(ancestor::xhtml:tfoot[1]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()]) = generate-id()">
					<!-- Is the last node in the amendment in the same table as this footnote node in which case this is the node we want to output the quote on -->
					<!--chunyu: call for Call HA047974 of http://www.legislation.gov.uk/uksi/2000/3184/schedule/4/made. added '[1]' for generate-id(ancestor::xhtml:table) -->
					<xsl:if test="generate-id(ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()]/ancestor::xhtml:table) = generate-id(ancestor::xhtml:table[1])">
						<xsl:text>true</xsl:text>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="processAppendText" as="xs:boolean" select="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1][self::leg:AppendText] and not(parent::*[self::leg:Substitution or self::leg:Addition or self::leg:Repeal])"/>
	<xsl:if test="$strIsTableFootnoteAtEnd = 'true' or $seqLastTextNodes = generate-id()">
		<xsl:choose>
			<!-- JDC HA056626 http://www.legislation.gov.uk/uksi/2013/2005/regulation/2/made - paragraphs 8 and 9 -->			
			<!-- If we are in a leg:BlockAmendment//leg:OrderedList and there is an empty List Item/Paragraph/Text following this text node, the quote needs to go after that, not here. -->
			<xsl:when test="ancestor::leg:BlockAmendment//leg:OrderedList and ../../../following-sibling::*[self::leg:ListItem]/leg:Para/leg:Text = '' "/>
			<!-- If last node of amendment is in a table body and that table has footnote do not output at this point as will need to go after footnotes -->
			<xsl:when test="not(ancestor::xhtml:tfoot) and ancestor::*[self::xhtml:table or self::leg:BlockAmendment][1][self::xhtml:table][xhtml:tfoot]"/>
			<xsl:when test="self::leg:IncludedDocument or self::leg:Image">
				<p class="LegAmendQuoteClose">
					<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
					<xsl:if test="$processAppendText">
						<xsl:for-each select="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1]">
							<xsl:call-template name="FuncCheckForIDnoElement"/>
							<xsl:apply-templates/>
						</xsl:for-each>
					</xsl:if>
					<xsl:call-template name="FuncCheckForEndOfNestedQuote"/>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<span class="LegAmendQuote">
					<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
				</span>
				<xsl:if test="$processAppendText">
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
     	<xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
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
	<xsl:if test="$strIsTableFootnoteAtEnd = 'true' or (count($seqLastTextNodes[. = generate-id(current())]) &gt;= 2)">
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
				<span class="LegAmendQuote">
					<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
				</span>
				<xsl:if test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][2]/following-sibling::*[1][self::leg:AppendText]">
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
	  <xsl:when test="ancestor::leg:BlockAmendment[1]/@Format = 'double'">
	    <xsl:text>&#8220;</xsl:text>
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
	  <xsl:when test="ancestor::leg:BlockAmendment[1]/@Format = 'double'">
	    <xsl:text>&#8221;</xsl:text>
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
				<xsl:when test="//leg:BlockExtract[leg:IncludedDocument[@ResourceRef = current()/ancestor::leg:Resource/@id]]/@SourceClass = $g_strEUretained">
					<xsl:value-of select="$g_strEUretained"/>
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
		<xsl:when test="ancestor::leg:BlockAmendment[1]/@TargetClass = $g_strEUretained">
			<xsl:value-of select="$g_strEUretained"/>
		</xsl:when>
		<xsl:when test="ancestor::leg:BlockAmendment[1]/@TargetClass = $g_strSecondary">
			<xsl:value-of select="$g_strSecondary"/>
		</xsl:when>
		<!-- Instance level granularity -->
		<xsl:when test="$g_strDocumentType = $g_strPrimary">
			<xsl:value-of select="$g_strPrimary"/>
		</xsl:when>
		<xsl:when test="$g_strDocumentType = $g_strEUretained">
			<xsl:value-of select="$g_strEUretained"/>
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
		<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
	</xsl:if>
</xsl:template>

<!-- Apply id attribute if used and if so output an anchor point - this is for elements in the XML that will not have an HTML element -->
<xsl:template name="FuncCheckForIDnoElement">
	<xsl:param name="strID"/>
	<xsl:if test="@id or $strID != ''">
		<!-- Do it this way because IE doesn't like empty anchors -->
		<!-- Included a class id so that this can be identified for internal links. -->
		<a class="LegAnchorID">
			<xsl:attribute name="id">
				<xsl:choose>
					<xsl:when test="$strID != ''">
						<xsl:value-of select="$strID"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="FuncGenerateAnchorID"/>
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
	<xsl:variable name="anchorID">
		<xsl:choose>
			<xsl:when test="not(ancestor::*[self::leg:BlockAmendment or self::leg:Tabular or self::leg:EarlierOrders or self::leg:ExplanatoryNotes or self::leg:Form or self::leg:Resource])">
				<xsl:value-of select="tso:getSubsectionID(., $g_strDocumentMainType, $g_strDocumentMinorType)" />
			</xsl:when>
			<xsl:when test="@id">
				<xsl:value-of select="@id" />
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$anchorID">
		<!-- Do it this way because IE doesn't like empty anchors -->
		<a class="LegAnchorID" id="{$anchorID}">
			<!-- Copy an empty node set to force MSXML to output start and end tags -->
			<xsl:copy-of select="/.."/>
		</a>		
	</xsl:if>
</xsl:template>

<xsl:template name="FuncGetPnumberID" as="attribute(id)?">
	<xsl:variable name="strId">
		<xsl:choose>
			<xsl:when  test="not(ancestor::*[self::leg:BlockAmendment or self::leg:Tabular or self::leg:EarlierOrders or self::leg:ExplanatoryNotes or self::leg:Form or self::leg:Resource])">
				<xsl:value-of select="tso:getSubsectionID(parent::*, $g_strDocumentMainType, $g_strDocumentMinorType)"/>
			</xsl:when>
		<xsl:otherwise>
				<xsl:value-of select="@id" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$strId != ''">
		<xsl:attribute name="id" select="$strId" />
	</xsl:if>
</xsl:template>

<xsl:template name="FuncGenerateAnchorID">
	<xsl:choose>
		<!-- We won't do this in amendments or certain other structures as that would upset the numbering potentially -->
		<xsl:when test="not(ancestor::*[self::leg:BlockAmendment or self::leg:Tabular or self::leg:EarlierOrders or self::leg:ExplanatoryNotes or self::leg:Form or self::leg:Resource]) and (self::leg:P6 or self::leg:P5 or self::leg:P4 or self::leg:P3 or self::leg:P2 or self::leg:P1 or self::leg:P3group or self::leg:P2group or self::leg:P1group or self::leg:Group or self::leg:Part or self::leg:Chapter or self::leg:Pblock or self::leg:PsubBlock or self::leg:Schedule)">
			<xsl:call-template name="TSOcheckVersionAnchor"/>
			<xsl:value-of select="tso:getSubsectionID(., $g_strDocumentMainType, $g_strDocumentMinorType)"/>
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
					<xsl:value-of select="count(preceding::leg:Image[not(ancestor::leg:Figure)]) + 1"/>
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
			<xsl:call-template name="getStructureID"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Calculate an ID based on the position of a node in a tree -->
<xsl:template name="getStructureID">
	<xsl:param name="ndsNode" select="."/>
	<xsl:value-of select="count($ndsNode/preceding-sibling::node())"/>
	<xsl:if test="$ndsNode/parent::*">
		<xsl:text>-</xsl:text>
		<xsl:call-template name="getStructureID">
			<xsl:with-param name="ndsNode" select="$ndsNode/parent::*"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>
	
<xsl:function name="tso:getSubsectionID"> 
	<xsl:param name="contextNode" as="element()"/>
	<xsl:param name="documentType" as="xs:string"/>
	<xsl:param name="documentSubType" as="xs:string?"/>
	<xsl:for-each select="$contextNode">
		<xsl:variable name="isInSchedule" select="ancestor-or-self::leg:Schedule[1]"/>
		<xsl:choose>
			<!-- If id already exists use that -->
			<xsl:when test="@id and not(matches(@id, '[a-z][0-9]{5}'))">
				<xsl:value-of select="@id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$isInSchedule">
					<xsl:text>schedule</xsl:text>
					<xsl:if test="$isInSchedule/leg:Number">
						<xsl:variable name="schNumber" select="normalize-space(substring-after(lower-case($isInSchedule/leg:Number), 'schedule'))"/>
						<xsl:if test="$schNumber">
							<xsl:text>-</xsl:text>
							<xsl:value-of select="translate($schNumber,' ','-')"/>
							<xsl:if test="ancestor::leg:Schedule">
								<xsl:text>-</xsl:text>
							</xsl:if>
						</xsl:if>
					</xsl:if>
				</xsl:if>
				<xsl:if test="not(self::leg:Schedule)">
					<xsl:choose>
						<xsl:when test="self::leg:Group or self::leg:Part or self::leg:Chapter">
							<xsl:value-of select="tso:getStructureNumberID($contextNode)" separator="-"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="ancestor::leg:Schedule">paragraph</xsl:when>
								<xsl:when test="$documentType = 'NorthernIrelandOrderInCouncil' or $documentSubType = 'rule'">article</xsl:when>
								<xsl:when test="$documentSubType = 'regulation'">regulation</xsl:when>
								<xsl:when test="$documentSubType = 'order'">article</xsl:when>
								<xsl:otherwise>section</xsl:otherwise>
							</xsl:choose>
							<xsl:text>-</xsl:text>
							<xsl:value-of select="ancestor-or-self::leg:P1/leg:Pnumber, ancestor-or-self::leg:P2/leg:Pnumber, ancestor-or-self::leg:P3/leg:Pnumber, ancestor-or-self::leg:P4/leg:Pnumber, ancestor-or-self::leg:P5/leg:Pnumber" separator="-"/>
						</xsl:otherwise>
					</xsl:choose>				
				</xsl:if>
			</xsl:otherwise>
					
			<!--<xsl:when test="not(self::leg:Schedule)">
				<xsl:choose>
					<xsl:when test="self::leg:Group or self::leg:Part or self::leg:Chapter">
						<xsl:value-of select="tso:getStructureNumberID($contextNode)" separator="-"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="ancestor::leg:Schedule">paragraph</xsl:when>
							<xsl:when test="$documentType = 'NorthernIrelandOrderInCouncil' or $documentSubType = 'rule'">article</xsl:when>
							<xsl:when test="$documentSubType = 'regulation'">regulation</xsl:when>
							<xsl:when test="$documentSubType = 'order'">article</xsl:when>
							<xsl:otherwise>section</xsl:otherwise>
						</xsl:choose>
						<xsl:text>-</xsl:text>
						<xsl:value-of select="ancestor-or-self::leg:P1/leg:Pnumber, ancestor-or-self::leg:P2/leg:Pnumber, ancestor-or-self::leg:P3/leg:Pnumber, ancestor-or-self::leg:P4/leg:Pnumber, ancestor-or-self::leg:P5/leg:Pnumber" separator="-"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:when>-->
		</xsl:choose>
		
		<xsl:if test="ancestor-or-self::*[@VersionReplacement = 'True']">
			<!-- Here we will use the VersionReplacement attribute. This give the id of the version and optionally, first, the RestrictExtent of the version (followed by a space) -->
			<!-- If there is a RestrictExtent then we don't need the versin number as we can use the extent information to differentiate the ids -->
			<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReplacement = 'True']/@VersionReference" as="xs:string"/>
			<xsl:choose>
				<xsl:when test="contains($versionRef, ' ')">
					<xsl:text>_</xsl:text>
					<xsl:value-of select="translate(substring-before($versionRef, ' '), '+', '_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="$versionRef"/>
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:if>
	</xsl:for-each>
</xsl:function>
	
<xsl:function name="tso:getStructureNumberID" as="xs:string+">
	<xsl:param name="contextNode" as="element()"/>
	<xsl:for-each select="$contextNode">
		<xsl:choose>
			<xsl:when test="self::leg:Group">
				<xsl:sequence select="concat('group-', normalize-space(substring-before(leg:Number, 'Group')))"/>
			</xsl:when>
			<xsl:when test="self::leg:Part">
				<xsl:if test="ancestor::leg:Group">
					<xsl:value-of select="tso:getStructureNumberID($contextNode/ancestor::leg:Group)"/>
				</xsl:if>	
				<xsl:sequence select="concat('part-', normalize-space(substring-after(leg:Number, 'Part')))"/>
			</xsl:when>
			<xsl:when test="self::leg:Chapter">
				<xsl:if test="ancestor::*[self::leg:Part or leg:Group]">
					<xsl:value-of select="tso:getStructureNumberID($contextNode/ancestor::*[self::leg:Part or leg:Group][1])"/>
				</xsl:if>
				<xsl:sequence select="concat('chapter-', normalize-space(substring-after(leg:Number, 'Chapter')))"/>
			</xsl:when>
		</xsl:choose>				
	</xsl:for-each>
</xsl:function>

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

<xsl:template name="FuncCalcHeadingLevel">
	<xsl:variable name="intHeadingCount" select="count(ancestor-or-self::*[self::leg:Group or self::leg:Part or self::leg:Chapter or self::leg:Pblock or self::leg:PsubBlock or self::leg:Schedule or self::leg:P1group or self::leg:P2group or self::leg:P3group or self::leg:Abstract or self::leg:Appendix or self::leg:ExplanatoryNotes or self::leg:EarlierOrders or self::leg:Tabular or self::leg:Figure or self::leg:Form or self::leg:EUTitle or self::leg:EUChapter or self::leg:EUSection or self::leg:EUSubsection or self::leg:Division])"/>
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
