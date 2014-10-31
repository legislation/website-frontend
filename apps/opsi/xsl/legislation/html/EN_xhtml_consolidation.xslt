<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Legislation schema XHTML output for consolidated legislation -->

<!-- Version 1.00 -->
<!-- Created by Paul Appleby -->
<!-- Last changed 18/03/2009 by Paul Appleby -->
<!-- Change history

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
 xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
exclude-result-prefixes="leg ukm math msxsl dc fo xsl svg xhtml xs tso">

<!-- ========== Standard code for outputting legislation ========= -->

<xsl:import href="EN_xhtml_vanilla.xslt"/>

<xsl:import href="../../common/utils.xsl"/>

<xsl:output method="xml" version="1.0" omit-xml-declaration="yes"  indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>


<xsl:key name="citations" match="leg:Citation" use="@id" />
<xsl:key name="commentary" match="leg:Commentary" use="@id"/>
<xsl:key name="commentaryRef" match="leg:CommentaryRef" use="@Ref"/>
<xsl:key name="commentaryRef" match="leg:Addition | leg:Repeal | leg:Substitution" use="@CommentaryRef"/>
<xsl:key name="additionRepealChanges" match="leg:Addition | leg:Repeal | leg:Substitution" use="@ChangeId"/>
<xsl:key name="citationLists" match="leg:CitationList" use="@id"/>

<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

<xsl:variable name="legislationYear" select="/leg:Legislation/ukm:Metadata//ukm:Year/@Value"/>
<xsl:variable name="legislationNumber" select="/leg:Legislation/ukm:Metadata//ukm:Number/@Value"/>


<xsl:variable name="g_ndsTemplateDoc" 
	select="if ($paramsDoc/parameters/wrap = 'true') then doc('HTMLTemplate_Vanilla-v-1-0.xml') else doc('HTMLTemplate_snippet.xml')" />

<!-- ========= Code for consolidation ========== -->

<xsl:template match="leg:EN">
	<xsl:choose>
		<xsl:when test="$paramsDoc/parameters/view = 'body'">
			<xsl:apply-templates select="//leg:Body"/>
		</xsl:when>
		<xsl:when test="$paramsDoc/parameters/view = 'contents'">
			<xsl:apply-templates select="leg:Contents" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="*[not(self::leg:Contents)] | processing-instruction()"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- JDC: template copied from EN_xhtml_core_vanilla.xslt and "FuncCheckForStartOfQuote" commented back in -->
<xsl:template name="FuncTextPreOperations">
	<xsl:call-template name="FuncCheckForStartOfQuote"/>
	<!-- Output generated text around paragraph numbers in legislation extracts -->
	<xsl:if test="ancestor::leg:Pnumber[parent::leg:P2 or parent::leg:P3 or parent::leg:P4 or parent::leg:P5]">
		<xsl:text>(</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template name="FuncTextPostOperations">
	<xsl:param name="nstLastTextNode" as="text()?" tunnel="yes" select="(ancestor::leg:Text[1]//text())[last()]" />
	<xsl:param name="nstRunOnAmendmentText" as="element(leg:Text)?" tunnel="yes" select="()" />
	<!-- Output generated text around paragraph numbers -->
	<xsl:variable name="nstPnumber" as="element(leg:Pnumber)?"
		select="ancestor::leg:Pnumber" />
	<xsl:if test="exists($nstPnumber)">
		<xsl:choose>
			<xsl:when test="$nstPnumber/@PuncAfter">
				<xsl:value-of select="$nstPnumber/@PuncAfter" />
			</xsl:when>
		  <xsl:when test="$nstPnumber[parent::leg:P2 or parent::leg:P3 or parent::leg:P4 or parent::leg:P5]">
		    <xsl:text>)</xsl:text>
		  </xsl:when>
			<xsl:when test="$nstPnumber/parent::leg:P1 and $g_strDocumentType = $g_strPrimary"/>
			<xsl:when test="$nstPnumber/parent::leg:P1">.</xsl:when>
			<xsl:otherwise>.</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	
	<xsl:call-template name="FuncCheckForEndOfQuote"/>
	
	<!-- Check if  last node in a footnote in which case output back link if a standard footnote -->
	<!-- JT: In XML generated for SLS, there are no footnotes 
	<xsl:if test="not(ancestor::leg:Citation or ancestor::leg:CitationSubRef or ancestor::leg:InternalLink or ancestor::leg:ExternalLink or ancestor::leg:Acronym or ancestor::leg:Abbreviation or ancestor::leg:Definition or ancestor::leg:Proviso or ancestor::leg:Superior or ancestor::leg:Inferior or ancestor::leg:SmallCaps or ancestor::leg:Underline) and ancestor::leg:Footnote[not(ancestor::xhtml:table)] and generate-id(ancestor::leg:Footnote[1]/descendant::text()[not(normalize-space() = '')][last()]) = generate-id()">
		<xsl:call-template name="FuncCheckForBackReference"/>
	</xsl:if>
	-->
	
	<!-- For primary legislation some amendments run on from the prevoius paragraph. Also allow it for very rare instances of secondary legislation where PartialRefs forces it -->
	<xsl:if test="exists($nstRunOnAmendmentText) and $nstLastTextNode is .">
		<xsl:text> </xsl:text>
		<span class="LegRunOnAmendment">
			<xsl:apply-templates select="$nstRunOnAmendmentText/(node() | processing-instruction())" />
		</span>
	</xsl:if>
	
</xsl:template>






<xsl:template match="leg:ContentsItem/leg:ContentsNumber">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="nstContent">
		<xsl:apply-templates/>
		<xsl:if test="translate(., ' &#160;', '') != ''">
			<xsl:text>.</xsl:text>
		</xsl:if>
	</xsl:variable>
	<span class="LegDS {concat('LegContentsNo', $strAmendmentSuffix)}">
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<a href="{parent::*/@DocumentURI}">
					<xsl:copy-of select="$nstContent" />
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$nstContent" />
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
			<xsl:when test="parent::*/@DocumentURI">
				<a href="{parent::*/@DocumentURI}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>


<xsl:template match="leg:Contents/leg:ContentsTitle | leg:ContentsSchedules/leg:ContentsTitle">
	<xsl:apply-imports />
</xsl:template>

<xsl:template match="leg:ContentsItem/leg:ContentsTitle">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<span class="LegDS {concat('ENContentsTitle', $strAmendmentSuffix)}">
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<a href="{parent::*/@DocumentURI}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>

<xsl:template match="leg:ExplanatoryNotes">
	<xsl:param name="showSection" as="element()*" tunnel="yes" select="()" />
	<xsl:choose>
		<xsl:when test="exists($showSection)">
			<xsl:apply-templates select="$showSection" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:ContentsTitle">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<p class="{concat('ENContentsTitle', $strAmendmentSuffix)}">
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<a href="{parent::*/@DocumentURI}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>		
	</p>
</xsl:template>


<xsl:template match="*[@xml:lang != 'en']" priority="1000">
	<xsl:next-match>
		<xsl:with-param name="strLanguage" tunnel="yes" select="@xml:lang" />
	</xsl:next-match>
</xsl:template>

<xsl:template match="text()">
	<xsl:param name="strLanguage" tunnel="yes" select="'en'" />
	<xsl:call-template name="FuncTextPreOperations"/>
	<!-- Check if text node is in a language other than English -->
	<xsl:choose>
		<xsl:when test="$strLanguage != 'en'">
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

<xsl:variable name="g_strUnicodeCharsRegex" as="xs:string">
	<xsl:value-of>
		(
		<xsl:value-of select="$g_ndsUnicodeCharsToConvert/@unicode" separator="|" />
		)
	</xsl:value-of>
</xsl:variable>
<xsl:key name="entities" match="entity" use="@unicode" />

<xsl:template name="FuncProcessTextForUnicodeChars">
	<xsl:param name="strText"/>
	<xsl:param name="ndsUnicodeCharsToConvert" select="$g_ndsUnicodeCharsToConvert" />
	<xsl:param name="strPathToImages" select="''"/>
	<xsl:choose>
		<xsl:when test="matches($strText, $g_strUnicodeCharsRegex, 'x')">
			<xsl:analyze-string select="$strText" regex="{$g_strUnicodeCharsRegex}" flags="x">
				<xsl:matching-substring>
					<xsl:variable name="ndsEntity" as="element(entity)"
						select="key('entities', ., $g_ndsUnicodeCharsDoc)" />
					<img class="LegUnicodeCharacter" 
						src="{$strPathToImages}{$ndsEntity/@image}" 
						alt="{$ndsEntity/@explanation}" 
						title="{$ndsEntity/@explanation}" 
						style="height: 1em;" />
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:value-of select="." />
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$strText" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- JDC: template copied from EN_xhtml_core_vanilla.xslt and blockquote commented back in -->
<xsl:template match="leg:BlockExtract">
	<blockquote>
	<xsl:apply-templates select="* | processing-instruction()"/>
	<xsl:call-template name="FuncApplyVersions"/>
	</blockquote>
</xsl:template>

</xsl:stylesheet>
