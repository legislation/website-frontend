<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
    xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.tso.co.uk/assets/namespace/error"
    xmlns:tso="http://www.tso.co.uk/assets/namespace/function"
xmlns:math="http://www.w3.org/1998/Math/MathML" 
xmlns:dc="http://purl.org/dc/elements/1.1/"
version="2.0">

<xsl:output method="xhtml" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN/" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" omit-xml-declaration="yes" exclude-result-prefixes="leg xhtml"/>
    
<xsl:strip-space elements="*"/>

<!-- Store metadata -->
<xsl:variable name="g_ndsMetadata" select="/leg:Legislation/ukm:Metadata"/>

<!-- Document main type -->
<xsl:variable name="g_strDocumentMainType" select="$g_ndsMetadata//ukm:DocumentMainType[parent::ukm:DocumentClassification]/@Value"/>

<xsl:template match="/">
    <html>
        <head>
            <title>Legislation Test (Secondary legislation)</title>
            <meta http-equiv="content-Type" content="text/html; charset=UTF-8"  />
	        <link rel="stylesheet" href="/styles/legislation-secondary.css" type="text/css" media="screen"/>
        </head>
        <body>
            <div class="LegContent">
                <xsl:apply-templates/>
            </div>
        </body>
    </html>
</xsl:template>
    
<xsl:template match="ukm:Metadata"/>
    
<xsl:template match="leg:Contents"/>
 
 
<!-- ========= Preliminary Matter ========== -->
    
<xsl:template match="leg:SecondaryPrelims">
	
	<div class="LegPrelims">
		<xsl:call-template name="FuncOutputSecondaryPrelims"/>
		<xsl:apply-templates select="/leg:Legislation/leg:Contents"/>
		<xsl:apply-templates select="leg:SecondaryPreamble"/>
	</div>
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
				<xsl:when test="@Value = 'NorthernIrelandStatutoryRule' or @Value = 'NorthernIrelandStatutoryRuleLocal' or @Value = 'NorthernIrelandDraftStatutoryRule'">Statutory Rules of Northern Ireland</xsl:when>
				<xsl:when test="@Value = 'ScottishStatutoryInstrument' or @Value = 'ScottishStatutoryInstrumentLocal' or @Value = 'ScottishDraftStatutoryInstrument'">Scottish Statutory Instruments</xsl:when>
       			<xsl:when test="@Value = 'UnitedKingdomChurchInstrument' or @Value = 'UnitedKingdomChurchInstrumentLocal'">Church Instruments</xsl:when>
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
		<xsl:when test="$g_strDocumentMainType = 'NorthernIrelandStatutoryRule' and leg:Approved">
			<xsl:apply-templates select="leg:Number | leg:SubjectInformation | leg:Title | leg:Approved | leg:LaidDraft | leg:LaidDate  | processing-instruction()"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="leg:Number | leg:SubjectInformation | leg:Title | leg:Approved | leg:LaidDraft | leg:MadeDate | leg:LaidDate | leg:ComingIntoForce | processing-instruction()"/>
		</xsl:otherwise>
	</xsl:choose>

<xsl:template match="leg:SecondaryPrelims/leg:Correction">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:Draft">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:Number">
	<h1 class="LegNo">
		<xsl:apply-templates/>
	</h1>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:Title">
	<h1 class="LegTitle">
		<xsl:apply-templates/>
	</h1>
</xsl:template>

<xsl:template match="leg:SubjectInformation">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:Subject">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:Subject/leg:Title">
	<p class="LegSubject">
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:Subject/leg:Subtitle">
	<p class="LegSubsubject">
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:Approved">
	<p class="LegApproved">
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:MadeDate">
	<div class="LegDate">
		<p class="LegDateText">
			<xsl:apply-templates select="leg:Text/node()"/>
		</p>
		<p class="LegDateDate">
			<xsl:apply-templates select="leg:DateText/node()"/>
		</p>
	</div>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:LaidDraft">
	<div class="LegDate">
		<p class="LegDateText">
			<xsl:apply-templates select="leg:Text/node()"/>
		</p>
		<p class="LegDateDate">
			<xsl:apply-templates select="leg:DateText/node()"/>
		</p>
	</div>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:LaidDate">
	<div class="LegDate">
		<p class="LegDateText">
			<xsl:apply-templates select="leg:Text/node()"/>
		</p>
		<p class="LegDateDate">
			<xsl:apply-templates select="leg:DateText/node()"/>
		</p>
	</div>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims/leg:Approved">
<xsl:choose>
	<xsl:when test="$g_strDocumentMainType = 'NorthernIrelandStatutoryRule'">
		<xsl:apply-templates select="following-sibling::leg:MadeDate"/>
	<xsl:apply-templates select="following-sibling::leg:ComingIntoForce"/>
	<p class="LegApproved">
		<xsl:apply-templates/>
	</p>
	<xsl:call-template name="FuncApplyVersions"/>
	</xsl:when>
	<xsl:otherwise>
	<p class="LegApproved">
		<xsl:apply-templates/>
	</p>
	<xsl:call-template name="FuncApplyVersions"/>
	</xsl:otherwise>
</xsl:choose>
	
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
					<xsl:apply-templates select="leg:Text/node()"/>
				</p>
				<p class="LegDateDate">
					<xsl:apply-templates select="leg:DateText/node()"/>
				</p>
			</xsl:otherwise>
		</xsl:choose>
	</div>
	<xsl:apply-templates select="leg:ComingIntoForceClauses"/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims//leg:ComingIntoForceClauses">
	<div class="LegDate">
		<xsl:choose>
			<!-- No date so use the full available width -->
			<xsl:when test="not(leg:DateText)">
				<p class="LegDateTextWideClauses">
					<xsl:apply-templates select="leg:Text/node()"/>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<p class="LegDateTextClauses">
					<xsl:apply-templates select="leg:Text/node()"/>
				</p>
				<p class="LegDateDate">
					<xsl:apply-templates select="leg:DateText/node()"/>
				</p>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="leg:ComingIntoForceClauses"/>
	</div>
</xsl:template>

<xsl:template match="leg:SecondaryPreamble">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:Resolution">
	<div class="LegResolution">
		<xsl:apply-templates/>
	</div>
</xsl:template>

<xsl:template match="leg:RoyalPresence">
	<div class="LegRoyalPresence">
		<xsl:apply-templates/>
	</div>
</xsl:template>


<!-- ========== Other preliminary matter ========= -->

<xsl:template match="leg:IntroductoryText">
	<div class="LegIntroductoryText">
		<xsl:apply-templates/>
	</div>
</xsl:template>

<xsl:template match="leg:EnactingText">
	<div class="LegEnactingText">
		<xsl:apply-templates/>
	</div>
</xsl:template>

 
<!-- ========== Headings ========== -->

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

<xsl:template match="leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock">
	<div class="Leg{local-name()}">
		<xsl:element name="h{tso:CalcHeadingLevel(.)}">
			<xsl:attribute name="class">Leg<xsl:value-of select="local-name()"/>Heading</xsl:attribute>
			<xsl:apply-templates select="leg:Number | leg:Title"/>
		</xsl:element>
		<xsl:apply-templates select="*[not(self::leg:Number | self::leg:Title)]"/>
	</div>
</xsl:template>

<xsl:template match="leg:Part/leg:Number | leg:Chapter/leg:Number | leg:Pblock/leg:Number">
	<span class="Leg{local-name(parent::*)}Number">
		<xsl:apply-templates/>
	</span>
</xsl:template>

<xsl:template match="leg:Part/leg:Title | leg:Chapter/leg:Title | leg:Pblock/leg:Title | leg:PsubBlock/leg:Title">
    <span class="Leg{local-name(parent::*)}Title">
        <xsl:apply-templates/>
    </span>
</xsl:template>
    
<xsl:template match="leg:Schedules/leg:Title">
    <h1 class="LegSchedulesTitle">
        <xsl:apply-templates/>
    </h1>
</xsl:template>    

<xsl:template match="leg:Schedule">
	<div class="LegSchedule">
		<xsl:element name="h{tso:CalcHeadingLevel(.)}">
			<xsl:attribute name="class">LegScheduleHeading</xsl:attribute>
			<xsl:apply-templates select="leg:Number | leg:TitleBlock/*"/>
		</xsl:element>
		<xsl:apply-templates select="*[not(self::leg:Number | self::leg:TitleBlock)]"/>
	</div>
</xsl:template>

<xsl:template match="leg:Schedule/leg:Reference">
    <p class="LegScheduleReference">
        <xsl:apply-templates/>
    </p>
</xsl:template>    

<xsl:template match="leg:Schedule/leg:Number">
    <span class="LegScheduleNumber">
        <xsl:apply-templates/>
    </span>
</xsl:template>    

<xsl:template match="leg:Schedule/leg:TitleBlock/leg:Title">
    <span class="LegScheduleTitle">
        <xsl:apply-templates/>
    </span>
</xsl:template>    

<xsl:template match="leg:Schedule/leg:TitleBlock/leg:SubTitle">
    <span class="LegScheduleSubTitle">
        <xsl:apply-templates/>
    </span>
</xsl:template>    

<xsl:template match="leg:P1group/leg:Title">
	<xsl:element name="h{tso:CalcHeadingLevel(.)}">
		<xsl:attribute name="class">LegP1group</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:Schedule//leg:P1group/leg:Title" priority="1">
	<xsl:element name="h{tso:CalcHeadingLevel(.)}">
		<xsl:attribute name="class">LegP1group</xsl:attribute>
	        <xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:Pnumber">
    <span class="Leg{local-name(parent::*)}number">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<xsl:template match="leg:P1">
	<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
</xsl:template>

<xsl:template match="leg:P2">
	<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
</xsl:template>

<xsl:template match="leg:P3">
    <div class="LegP3">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="leg:P4">
    <div class="LegP4">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="leg:P5">
    <div class="LegP5">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="leg:P6">
    <div class="LegP6">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="leg:P1/leg:Pnumber">
	<span class="LegP1No">
		<xsl:apply-templates/>
	</span>
</xsl:template>

<xsl:template match="leg:P1para">
	<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="leg:P2para">
	<xsl:apply-templates select="*"/>
</xsl:template>
	
<xsl:template match="leg:P3para">
    <div class="LegP3para">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="leg:P4para">
    <div class="LegP4para">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="leg:P5para">
    <div class="LegP5para">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="leg:P6para">
    <div class="LegP6para">
        <xsl:apply-templates/>
    </div>
</xsl:template>	

<xsl:template match="leg:Text">
    <p class="Leg{local-name(parent::*)}Text">
	<xsl:variable name="intInlineNodeID" select="generate-id(descendant::node()[not(self::processing-instruction())][self::text() or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1])"/>
	<xsl:choose>
		<!-- Check if  first node in a P1-P2 in which case output P1 and P2 numbers (for secondary legislation) -->
		<xsl:when test="not(ancestor::leg:P1group[1]/@Layout = 'side' or (ancestor::*[self::leg:Body or self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:BlockAmendment[(@Context = 'main' or @Context = 'unknown') and @TargetClass = 'primary']])) and ancestor::leg:P1 and ancestor::leg:P2 and
				 generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1] or ancestor::leg:Title/parent::leg:P2group)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID and 
				generate-id(ancestor::leg:P2[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Citation or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = $intInlineNodeID">
			<xsl:apply-templates select="ancestor::leg:P1[1]/leg:Pnumber"/>
			<xsl:text>&#8212;</xsl:text>
			<xsl:apply-templates select="ancestor::leg:P2[1]/leg:Pnumber"/>
			<xsl:text>&#160;</xsl:text>
			<!-- Very rare instance of combined N1-N2-N3 -->
			<xsl:if test="ancestor::*[self::leg:P3 or self::leg:BlockAmendment][1][self::leg:P3]">
				<xsl:apply-templates select="ancestor::leg:P3[1]/leg:Pnumber"/>
				<xsl:text>&#160;</xsl:text>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:when test="parent::leg:P1para[not(preceding-sibling::*[not(self::leg:Pnumber)])]/parent::leg:P1">
    			<xsl:apply-templates select="parent::leg:P1para/preceding-sibling::leg:Pnumber"/>
    			<xsl:text>&#160;</xsl:text>
    			<xsl:apply-templates/>
    		</xsl:when>
		<xsl:when test="parent::leg:P2para[not(preceding-sibling::*[not(self::leg:Pnumber)])]/parent::leg:P2">
    			<xsl:apply-templates select="parent::leg:P2para/preceding-sibling::leg:Pnumber"/>
    			<xsl:text>&#160;</xsl:text>
    			<xsl:apply-templates/>
    		</xsl:when>
    		<xsl:otherwise>
    			<xsl:apply-templates/>
    		</xsl:otherwise>
    	</xsl:choose>
    </p>
</xsl:template>

<xsl:template match="leg:P3para/leg:Text | leg:P4para/leg:Text | leg:P5para/leg:Text | leg:P6para/leg:Text">
    <p class="Leg{local-name(parent::*)}Text">
        <xsl:apply-templates/>
    </p>
</xsl:template>

<xsl:template match="leg:BlockAmendment">
    <xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
        <div class="LegBlockAmendment">
            <xsl:variable name="strTextNode" as="xs:string" select="generate-id(descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character or self::leg:Image][last()])"/>
        <xsl:apply-templates>
            <xsl:with-param name="seqLastTextNodes" tunnel="yes" select="$seqLastTextNodes, $strTextNode" as="xs:string*"/>
        </xsl:apply-templates>
    </div>
</xsl:template>
 
 <xsl:template match="leg:AppendText"/>
    

<!-- ========== Tables ========== -->
    
<xsl:template match="xhtml:*">
    <xsl:copy>
        <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>


<!-- ========== Formatting ========== -->
    
<xsl:template match="leg:SmallCaps">
    <span class="LegSmallCaps">
        <xsl:apply-templates/>
    </span>
</xsl:template>


<!-- ========== Characters ========== -->

<xsl:include href="legislation-characters.xsl"/>

<!-- ========== Standard processing ========== -->

<xsl:template match="*">
    <xsl:apply-templates/>
</xsl:template>
    
<xsl:template match="text()">
    <xsl:call-template name="FuncCheckForStartOfQuote"/>

    <xsl:if test="ancestor::leg:Pnumber">
    	<xsl:choose>
    		<xsl:when test="not(ancestor::leg:Pnumber/@PuncBefore) and ancestor::leg:Pnumber/parent::leg:P1"/>
    		<xsl:when test="not(ancestor::leg:Pnumber/@PuncBefore)">(</xsl:when>
    		<xsl:otherwise>
    			<xsl:value-of select="ancestor::leg:Pnumber/@PuncBefore"/>
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:if>

    <xsl:value-of select="."/>

    <xsl:if test="ancestor::leg:Pnumber">
        <xsl:choose>
		<xsl:when test="not(ancestor::leg:Pnumber/@PuncAfter) and ancestor::leg:Pnumber/parent::leg:P1">.</xsl:when>
        	<xsl:when test="not(ancestor::leg:Pnumber/@PuncAfter)">)</xsl:when>
        	<xsl:otherwise>
                	<xsl:value-of select="ancestor::leg:Pnumber/@PuncAfter"/>
        	</xsl:otherwise>
        </xsl:choose>
    </xsl:if>

    <xsl:call-template name="FuncCheckForEndOfQuote"/>

    <!-- For primary legislation some amendments run on from the prevoius paragraph -->
    <xsl:if test="(ancestor::leg:Text[1]/following-sibling::*[1][self::leg:BlockAmendment[string(@PartialRefs) != '']]/child::*[1][self::leg:Text]) and generate-id(ancestor::leg:Text[1]/descendant::text()[not(normalize-space() = '')][last()]) = generate-id()">
                <xsl:if test="ancestor::leg:Text[1]/following-sibling::*[1][self::leg:BlockAmendment]/child::*[1][self::leg:Text]">
	<xsl:text> </xsl:text>
	<span class="LegRunOnAmendment">
	    <xsl:apply-templates select="ancestor::leg:Text[1]/following-sibling::*[1][self::leg:BlockAmendment]/child::*[1]/node()"/>
	</span>
        </xsl:if>
    </xsl:if>

</xsl:template>

<xsl:template name="FuncCheckForStartOfQuote">
	<!-- This gets the ID of the first text node or applicable element in an amendment -->
	<xsl:variable name="strFirstAmendmentID" select="generate-id(ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Image][1])"/>
	<xsl:choose>
		<xsl:when test="$strFirstAmendmentID = generate-id() and not(ancestor::*[self::leg:BlockAmendment or self::leg:OrderedList][1][self::leg:OrderedList]) and not(parent::leg:Title[following-sibling::*[1][self::leg:P1]]/parent::leg:P1group/@Layout = 'side') and not(parent::leg:Title[following-sibling::*[1][self::leg:P1]] and parent::leg:Title/parent::leg:P1group/parent::leg:BlockAmendment[1][@Context != 'schedule'])">
            		    <span class="LegAmendQuote">
            		    	<xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
            		    </span>
		</xsl:when>
		<!-- Otherwise test if this is a P1group where the number of a P1 needs to be output at the side. This is tricky as the number is not the first node in the amendment - we need to check if the Title element is the first -->
		<xsl:when test="((parent::leg:Pnumber/parent::leg:P1/parent::leg:P1group[not(@Layout = 'below')]/ancestor::leg:BlockAmendment[1][@Context != 'schedule'])) and generate-id(ancestor::leg:P1[1]/preceding-sibling::leg:Title/descendant::node()[self::text()[not(normalize-space() = '' or parent::leg:IncludedDocument)] or self::leg:IncludedDocument or self::leg:FootnoteRef or self::leg:Character][1]) = $strFirstAmendmentID">
            		    <span class="LegAmendQuote">
            		        <xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
            		    </span>
		</xsl:when>
	</xsl:choose>
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

<!-- Check if last node in an amendment in which case output quotes -->
<xsl:template name="FuncCheckForEndOfQuote">
     <xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
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
	<xsl:if test="$strIsTableFootnoteAtEnd = 'true' or $seqLastTextNodes = generate-id()">
	    <xsl:choose>
                <!-- If last node of amendment is in a table body and that table has footnote do not output at this point as will need to go after footnotes -->
                <xsl:when test="not(ancestor::xhtml:tfoot) and ancestor::*[self::xhtml:table or self::leg:BlockAmendment][1][self::xhtml:table][xhtml:tfoot]"/>
                <xsl:when test="self::leg:IncludedDocument or self::leg:Image">
                	<p class="LegAmendQuoteClose">
                		<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
                		<xsl:if test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1][self::leg:AppendText]">
                			<xsl:for-each select="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1]">
                				<xsl:apply-templates/>
                			</xsl:for-each>
                		</xsl:if>
                	        <!-- If two or more nodes then we're in a nested situation -->
             		    <xsl:call-template name="FuncCheckForEndOfNestedQuote"/>
                	</p>
                	<xsl:text>&#13;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                	<span class="LegAmendQuote">
                		<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
                	</span>
                	<xsl:if test="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1][self::leg:AppendText]">
                		<xsl:for-each select="ancestor::*[self::leg:BlockAmendment or self::leg:BlockExtract][1]/following-sibling::*[1]">
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
					<xsl:apply-templates/>
				</xsl:for-each>				
			</xsl:if>
		</xsl:otherwise>
       		</xsl:choose>
	</xsl:if>
</xsl:template>

<!-- ========== Temporary code to remove stuff ========== -->

<xsl:template match="leg:Versions | leg:Commentary"/>
	
<xsl:template match="err:*"/>
	
<xsl:template match="leg:Addition | leg:Substitution">
	<span style="color:red">
		<xsl:apply-templates/>
	</span>
</xsl:template>

</xsl:stylesheet>
