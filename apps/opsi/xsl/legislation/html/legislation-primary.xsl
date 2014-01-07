<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

-->
<!-- NOT adapted for Welsh UI wrapper as this XSL is not used on legislation site -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
    xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.tso.co.uk/assets/namespace/error"
    xmlns:tso="http://www.tso.co.uk/assets/namespace/function"
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
            <title>Legislation Test (Primary legislation)</title>
            <meta http-equiv="content-Type" content="text/html; charset=UTF-8"  />
        <link rel="stylesheet" href="/styles/legislation-primary.css" type="text/css" media="screen"/>
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
    
<xsl:template match="leg:PrimaryPrelims">
    <div class="LegPrelims">
        <xsl:choose>
        	<xsl:when test="$g_strDocumentMainType = 'ScottishAct'">
                    <img src="/images/crests/scottishroyalarm.gif" alt="Royal arms" title="Royal arms" width="150" height="133"/>
        	</xsl:when>
        	<xsl:when test="$g_strDocumentMainType = 'WelshAssemblyMeasure'">
                    <img src="/images/crests/mwa.gif" alt="Welsh Royal arms" title="Welsh Royal arms" width="147" height="188"/>
        	</xsl:when>
			<xsl:when test="$g_strDocumentMainType = 'WelshNationalAssemblyAct'">
                    <img src="/images/crests/mwa.gif" alt="Welsh Royal arms" title="Welsh Royal arms" width="147" height="188"/>
        	</xsl:when>
        	<xsl:otherwise>
                    <img src="/images/crests/ukpga.gif" alt="Royal arms" title="Royal arms" width="156" height="128"/>
        	</xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
    </div>
</xsl:template>
    
<xsl:template match="leg:PrimaryPrelims/leg:Title">
    <h1 class="LegTitle">
        <xsl:apply-templates/>
    </h1>
</xsl:template>

<xsl:template match="leg:PrimaryPrelims/leg:Number">
    <h2 class="LegNo">
        <xsl:choose>
        	<xsl:when test="$g_strDocumentMainType = 'WelshAssemblyMeasure' ">
        		<xsl:value-of select="leg:Number"/>
        	</xsl:when>
			<xsl:when test="$g_strDocumentMainType = 'WelshNationalAssemblyAct' ">
        		<xsl:value-of select="leg:Number"/>
        	</xsl:when>
        	<!-- Convoluted approach to outputting the correct act number, but probably required for legacy data -->
        	<xsl:otherwise>
                    <xsl:variable name="year" select="$g_ndsMetadata//ukm:Year/@Value"/>
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
	                      <xsl:value-of select="@Value"/>
                    	</xsl:if>
                    </xsl:for-each>
        	</xsl:otherwise>
        </xsl:choose>	
        </h2>
</xsl:template>

<xsl:template match="leg:LongTitle">
    <p class="LegLongTitle">
        <xsl:apply-templates/>
    </p>
</xsl:template>

<xsl:template match="leg:DateOfEnactment">
    <p class="LegDateOfEnactment">
        <xsl:apply-templates/>
    </p>
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
	        <xsl:if test="following-sibling::*[1][self::leg:P1]">
	            <xsl:apply-templates select="following-sibling::*/leg:Pnumber"/>
	        </xsl:if>
	        <span class="LegP1groupTitle">
	            <xsl:apply-templates/>
	        </span>
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
    <div class="LegP1">
        <xsl:if test="not(preceding-sibling::*[1][self::leg:Title])">
            <xsl:apply-templates select="leg:Pnumber"/>
        </xsl:if>
        <xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
    </div>
</xsl:template>

<xsl:template match="leg:Schedule//leg:P1">
    <div class="LegP1">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="leg:P2">
    <div class="LegP2">
        <xsl:apply-templates/>
    </div>
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

<xsl:template match="leg:P1para">
    <div class="LegP1para">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="leg:P2para">
    <div class="LegP2para">
        <xsl:apply-templates/>
    </div>
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
        	<xsl:when test="not(ancestor::leg:Pnumber/@PuncAfter) and ancestor::leg:Pnumber/parent::leg:P1"/>
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
