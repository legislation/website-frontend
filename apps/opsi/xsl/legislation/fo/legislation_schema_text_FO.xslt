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
xmlns:math="http://www.w3.org/1998/Math/MathML"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:rx="http://www.renderx.com/XSL/Extensions"
xmlns:tso="http://www.tso.co.uk/xslt"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
exclude-result-prefixes="tso">

<!-- ========== Text processing ========== -->

<xsl:template match="text()">
	<xsl:param name="flSmallCaps" select="false()" tunnel="yes"/>
	<xsl:param name="seqLastTextNodes" tunnel="yes" as="xs:string*"/>
	

	<xsl:call-template name="TSOcheckStartOfAmendment"/>

	<!-- Need to allow for PuncBefore and PuncAfter here -->
	<!-- the not(normalize-space(.)='' is a quick-fix for the proposed revision where commentary/additions are putting whitespace before the  aommentary/addition elements -->
	<xsl:if test="ancestor::leg:Pnumber[not(parent::leg:P1)] and (not(preceding-sibling::node()[not(self::processing-instruction())]) or (preceding-sibling::node()[self::leg:CommentaryRef]))
	and not(normalize-space(.)='')">
		<xsl:text>(</xsl:text>
	</xsl:if>
	
	<!-- Is this the start of the enacting text? We need a drop cap for primary -->
	<!-- FOP does not support float-->
	<!--<xsl:if test="($g_strDocClass = $g_strConstantPrimary or $g_strDocType = 'NorthernIrelandAct') and generate-id(ancestor::leg:EnactingText/descendant::text()[normalize-space(.) != ''][1]) = generate-id()">
		<fo:float float="start">
			<fo:block-container width="{$g_intLineHeight * 1.6}pt" height="{$g_intLineHeight * 1.6}pt" padding-top="3pt" text-align="right">
				<fo:block font-size="{$g_intLineHeight * 2.3}pt" line-height="{$g_intLineHeight * 1.9}pt" space-end="2pt" margin-top="-2pt">
					--><!-- We seem to need to put a negative margin on for Book Antiqua --><!--
					<xsl:if test="$g_strDocType != 'NorthernIrelandAct'">
						<xsl:attribute name="margin-top">-15pt</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="substring(., 1, 1)"/>
				</fo:block>
			</fo:block-container>
		</fo:float>
	</xsl:if>-->

<!-- Change substring(.,2) into 1-->
	<xsl:variable name="ndsText">
		<xsl:variable name="strTextToProcess" select="if (($g_strDocClass = $g_strConstantPrimary or $g_strDocType = 'NorthernIrelandAct') and generate-id(ancestor::leg:EnactingText/descendant::text()[normalize-space(.) != ''][1]) = generate-id()) then substring(.,1) else ."/>
		<xsl:choose>
			<!-- This is to get around white space issues within repeal/addition/substitutions where the xml is pretty-printed - this could be dangerous in taking out legitimate white space but we will go with it at the moment  -->
			<xsl:when test="self::text() and normalize-space(.) = ''">
						
			</xsl:when>
			<!-- If node ends with a space and following element is InternalLink replace space with non-breaking space -->
			<xsl:when test="following-sibling::node()[1][self::leg:InternalLink] and substring($strTextToProcess, string-length($strTextToProcess), 1) = ' ' or (ends-with(translate($strTextToProcess, '&#13;&#10;', ''),' ') and parent::*/following-sibling::*[1][self::leg:InternalLink])">
				<xsl:call-template name="TSOprocessText">
					<xsl:with-param name="strText">
						<xsl:call-template name="FuncNormalizeSpace">
							<xsl:with-param name="strString" select="concat(translate(substring($strTextToProcess, 1, string-length($strTextToProcess) - 1), '&#13;&#10;', ''), '&#160;')" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>		
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:call-template name="TSOprocessText">
					<xsl:with-param name="strText">
						<xsl:call-template name="FuncNormalizeSpace">
							<xsl:with-param name="strString" select="translate($strTextToProcess, '&#13;&#10;', '')" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>	
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:variable>
	
	<xsl:choose>
		<xsl:when test="$flSmallCaps = true()">
			<xsl:analyze-string select="$ndsText" regex="\p{{Ll}}+">
				<xsl:matching-substring>
					<fo:inline font-size="{$g_strSmallCapsSize}" text-transform="uppercase">				
						<xsl:value-of select="."/>
					</fo:inline>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:value-of select="."/>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$g_flAddTargets">
					<xsl:call-template name="tso:AddTargets">
						<xsl:with-param name="strText" select="$ndsText"/>
						<xsl:with-param name="strNodeId" select="generate-id()"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ndsText"/>
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:otherwise>
	</xsl:choose>

	<!-- Need to allow for PuncBefore and PuncAfter here -->
	<!-- the not(normalize-space(.)='' is a quick-fix for the proposed revision where commentary/additions are putting whitespace before the  aommentary/addition elements -->
	<xsl:if test="ancestor::leg:Pnumber[not(parent::leg:P1)] and not(following-sibling::node()[not(self::processing-instruction())]) and  not(normalize-space(.)='')">
		<xsl:text>)</xsl:text>
	</xsl:if>
			
	<!-- If part of a long quote and last text node output quote and any run-on text -->
	<xsl:if test="$seqLastTextNodes = generate-id()">
		<xsl:for-each select="ancestor::leg:BlockAmendment[generate-id(current()) = generate-id(descendant::text()[normalize-space(.) != ''][last()])]">
			<xsl:text>&#x201d;</xsl:text>
			<xsl:apply-templates select="following-sibling::*[1][self::leg:AppendText]/node()"/>
		</xsl:for-each>		
	</xsl:if>

	<!-- Check if next text node should run on from this one - happens where an amendment starts with some text - but not if previous line ends in mdash happens in asp/2001/3/section/22) -->
	<xsl:if test="not(following-sibling::node()) and parent::leg:Text/following-sibling::*[1][self::leg:BlockAmendment]/*[1][self::leg:Text] and not(substring(., string-length(.)) = '&#8212;')">
		<xsl:text>&#32;</xsl:text>
		<xsl:for-each select="parent::*/following-sibling::*[1]/*[1][self::leg:Text]">
			<xsl:apply-templates/>
		</xsl:for-each>								
	</xsl:if>
	

	
</xsl:template>

<xsl:template name="TSOcheckStartOfAmendment">
	<!-- If part of a long quote and first text node output quote -->
	<xsl:if test="ancestor::leg:BlockAmendment">
	
		<xsl:variable name="firsttextnode" select="generate-id(ancestor::leg:BlockAmendment[1]/descendant::text()[normalize-space(.) != ''][1])"/>
		<xsl:if test="generate-id(.) = $firsttextnode and ($g_strDocClass = $g_strConstantSecondary or not(parent::leg:Title/parent::leg:P1group) or parent::leg:Title/parent::leg:P1group/parent::leg:BlockAmendment[@TargetClass = 'primary' and @Context = 'schedule'])">
			<fo:inline font-weight="normal">&#x201c;</fo:inline>
		</xsl:if>
		
		<xsl:if test="not($g_strDocClass = $g_strConstantSecondary) and not(parent::leg:Pnumber/parent::leg:P1/parent::leg:P1group/parent::leg:BlockAmendment[@TargetClass = 'primary' and @Context = 'schedule']) and parent::leg:Pnumber/parent::leg:P1/parent::leg:P1group and generate-id(parent::leg:Pnumber/parent::leg:P1/parent::leg:P1group/leg:Title/text()[1]) = $firsttextnode">
			<fo:inline font-weight="normal">&#x201c;</fo:inline>
		</xsl:if>
		
		<!-- Check that there aren't two amdts starting on same text node - very unlikely! -->
		<xsl:if test="ancestor::leg:BlockAmendment/ancestor::leg:BlockAmendment">
			<xsl:variable name="ndsFirstTextNode2" select="generate-id(ancestor::leg:BlockAmendment[2]/descendant::text()[normalize-space() != ''][1])"/>
			<xsl:if test="generate-id() = $ndsFirstTextNode2">
				<fo:inline font-weight="normal">&#x201c;</fo:inline>
			</xsl:if>
		</xsl:if>
	</xsl:if>
	
</xsl:template>

<!-- This list maps strings to new strings - basically inserting non-breaking spaces where desirable -->
<xsl:variable name="g_ndsEntityData">
	<entities xmlns="">
		<entity unicode="Chapter 3">Chapter&#x00a0;3</entity>			
		<entity unicode="c. ">c.&#x00a0;</entity>			
		<entity unicode="No. ">No.&#x00a0;</entity>
		<entity unicode="NI ">NI&#x00a0;</entity>
		<entity unicode="paragraph (">paragraph&#x00a0;(</entity>			
		<entity unicode="Note 1">Note&#x00a0;1</entity>
		<entity unicode="Note 2">Note&#x00a0;2</entity>
		<entity unicode="Note 3">Note&#x00a0;3</entity>
		<entity unicode="Note 4">Note&#x00a0;4</entity>
		<entity unicode="Note 5">Note&#x00a0;5</entity>								
		<entity unicode="Schedule 1">Schedule&#x00a0;1</entity>
		<entity unicode="Schedule 2">Schedule&#x00a0;2</entity>
		<entity unicode="Schedule 3">Schedule&#x00a0;3</entity>				
		<entity unicode="Schedule 4">Schedule&#x00a0;4</entity>
		<entity unicode="Schedule 5">Schedule&#x00a0;5</entity>
		<entity unicode="Schedule 6">Schedule&#x00a0;6</entity>
		<entity unicode="Schedule 7">Schedule&#x00a0;7</entity>
		<entity unicode="Schedule 8">Schedule&#x00a0;8</entity>								
		<entity unicode="section 1">section&#x00a0;1</entity>
		<entity unicode="section 2">section&#x00a0;2</entity>
		<entity unicode="section 3">section&#x00a0;3</entity>
		<entity unicode="section 4">section&#x00a0;4</entity>
		<entity unicode="section 5">section&#x00a0;5</entity>
		<entity unicode="section 6">section&#x00a0;6</entity>
		<entity unicode="section 7">section&#x00a0;7</entity>
		<entity unicode="section 8">section&#x00a0;8</entity>
		<entity unicode="section 9">section&#x00a0;9</entity>														
		<entity unicode="regulation 1">regulation&#x00a0;1</entity>
		<entity unicode="regulation 2">regulation&#x00a0;2</entity>
		<entity unicode="regulation 3">regulation&#x00a0;3</entity>
		<entity unicode="regulation 4">regulation&#x00a0;4</entity>
		<entity unicode="regulation 5">regulation&#x00a0;5</entity>
		<entity unicode="regulation 6">regulation&#x00a0;6</entity>
		<entity unicode="regulation 7">regulation&#x00a0;7</entity>
		<entity unicode="regulation 8">regulation&#x00a0;8</entity>
		<entity unicode="regulation 9">regulation&#x00a0;9</entity>
		<entity unicode="regulations 1">regulations&#x00a0;1</entity>
		<entity unicode="regulations 2">regulations&#x00a0;2</entity>
		<entity unicode="regulations 3">regulations&#x00a0;3</entity>
		<entity unicode="regulations 4">regulations&#x00a0;4</entity>
		<entity unicode="regulations 5">regulations&#x00a0;5</entity>
		<entity unicode="regulations 6">regulations&#x00a0;6</entity>
		<entity unicode="regulations 7">regulations&#x00a0;7</entity>
		<entity unicode="regulations 8">regulations&#x00a0;8</entity>
		<entity unicode="regulations 9">regulations&#x00a0;9</entity>
		<entity unicode="subsection (">subsection&#x00a0;(</entity>	
		<entity unicode=" or (f)"> or&#x00a0;(f)</entity>
		<entity unicode=" &#8212;">&#x00a0;&#8212;</entity>
		<entity unicode="&#x2605;">*</entity>
		<!-- 8203 is a zero-width space -->
<!--		<entity unicode="/">/&#8203;</entity>
		<entity unicode="&#8212;">&#8212;&#8203;</entity>		-->
	</entities>
</xsl:variable>

<xsl:template name="TSOprocessText">
	<xsl:param name="strText" as="xs:string"/>
	<xsl:param name="flSmallCaps" select="false()" as="xs:boolean" tunnel="yes"/>
	
	<xsl:variable name="ndsGetEntity" select="$g_ndsEntityData/entities/entity[contains($strText, @unicode)][1]"/>

	<xsl:choose>
		<xsl:when test="$ndsGetEntity != ''">
			<xsl:call-template name="TSOprocessText">
				<xsl:with-param name="strText" select="substring-before($strText, $ndsGetEntity/@unicode)"/>
			</xsl:call-template>
			<xsl:value-of select="$ndsGetEntity"/>
			<xsl:call-template name="TSOprocessText">
				<xsl:with-param name="strText" select="substring-after($strText, $ndsGetEntity/@unicode)"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$strText"/>
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>

<xsl:template name="tso:AddTargets">
	<xsl:param name="strText" as="xs:string"/>
	<xsl:param name="strNodeId" as="xs:string"/>

	<xsl:for-each select="1 to string-length($strText)">
		<fo:wrapper id="{$strNodeId}-LineNumberID-{position()}">
			<xsl:value-of select="substring($strText, position(), 1)"/>
		</fo:wrapper>
	</xsl:for-each>	
	
	
<!--	<xsl:if test="$strText != ''">
		<xsl:variable name="strID" select="$intPosition"/>
		<fo:wrapper id="{$strNodeId}-LineNumberID-{$strID}"/>
		<xsl:value-of select="substring($strText, 1, 1)"/>
		<xsl:call-template name="tso:AddTargets">
			<xsl:with-param name="strText" select="substring($strText, 2)"/>
			<xsl:with-param name="strNodeId" select="$strNodeId"/>
			<xsl:with-param name="intPosition" select="$intPosition + 1"/>
		</xsl:call-template>
	</xsl:if>-->
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