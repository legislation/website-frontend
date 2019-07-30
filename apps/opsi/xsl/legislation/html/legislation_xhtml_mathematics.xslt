<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Legislation schema XHTML output for legislation - mathematics module -->

<!-- Version 1.03 -->
<!-- Created by Manjit Jootle -->
<!-- Last changed 23/05/2007 by Paul Appleby -->

<!-- Change history

 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
xmlns:math="http://www.w3.org/1998/Math/MathML"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:fo="http://www.w3.org/1999/XSL/Format"
exclude-result-prefixes="leg ukm math xhtml dc ukm fo xsl">


<!-- ========== Global variables for Mathematics ========== -->

<!-- Path to the renderable characters file -->
<xsl:variable name="g_ndsRenderableCharsDoc" select="document('renderablecharacters.xml')"/>

<!-- All Renderable Characters as defined in renderablecharacters.xml XML file. -->
<!-- Allowable characters are HTML entities and ASCII characters. -->

<xsl:variable name="g_strRenderableCharacters">
	<xsl:for-each select="$g_ndsRenderableCharsDoc//unicode">
		<xsl:value-of select="."/>
	</xsl:for-each>
</xsl:variable>


<!-- ========== Global constants ========== -->

<!-- These are used to determine whether to display an image or render the maths elements. -->
<xsl:variable name="g_strDisplayImage" select="'displayimage'"/>
<xsl:variable name="g_strRenderMaths" select="'rendermaths'"/>


<!-- ========== Main code for Mathematics ========== -->

<xsl:template match="leg:Formula">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
  
	<div>
	 	<xsl:attribute name="class">
			<xsl:text>LegFormula</xsl:text>
			<xsl:value-of select="$strAmendmentSuffix"/>
		</xsl:attribute>
		<xsl:variable name="strCheckMathsForRendering">
			<xsl:call-template name="FuncCheckDisplayImageOrRenderMaths">
				<xsl:with-param name="currentnode" select="descendant::math:math"/>
			</xsl:call-template>
		</xsl:variable>
	  <xsl:if test="ancestor::leg:BlockAmendment and generate-id(ancestor::leg:BlockAmendment[1]/descendant::text()[not(normalize-space() = '')][1]) = generate-id(descendant::text()[not(normalize-space() = '')][1])">
	    <xsl:call-template name="FuncOutputAmendmentOpenQuote"/>
	  </xsl:if>
		<xsl:choose>
			<!-- For very simple one line maths with no odd characters output as text -->
			<xsl:when test="$strCheckMathsForRendering = $g_strRenderMaths">
				<p class="LegMaths">
					<xsl:apply-templates select="math:math"/>
					<xsl:call-template name="FuncCheckForMathAmendmentText"/>
				</p>				
				<xsl:text>&#13;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="@AltVersionRefs != ''">
						<!-- old comment said "We'll assume here that there is only one version"
						This SHOULD be the case but bugs in augment.xsl caused duplciation if the version with 
						same ID if the same image was referrenced twice as is the case with HA052048 -->
						<xsl:apply-templates select="(//leg:Version[@id = current()/@AltVersionRefs])[1]/*"/>
						<xsl:apply-templates select=".//(leg:Substitution|leg:Addition|leg:Repeal)[ancestor::math:math]" mode="mathrevisions"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="FuncOutputError"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>  
	  <xsl:if test="ancestor::leg:BlockAmendment and generate-id(ancestor::leg:BlockAmendment[1]/descendant::text()[not(normalize-space() = '')][last()]) = generate-id(descendant::text()[not(normalize-space() = '')][last()])">
    <xsl:call-template name="FuncOutputAmendmentEndQuote"/>
  </xsl:if>
	</div>

	<xsl:apply-templates select="leg:Where"/>
</xsl:template>

<!-- Check if  last node in an amendment in which case output quotes -->
<xsl:template name="FuncCheckForMathAmendmentText">
	<xsl:if test="ancestor::leg:BlockAmendment[1]/descendant::text()[not(normalize-space() = '')][last()]/ancestor::math:math and generate-id(ancestor::leg:BlockAmendment[1]/descendant::text()[not(normalize-space() = '')][last()]/ancestor::math:math) = generate-id(math:math)">
		<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
		<xsl:if test="ancestor::leg:BlockAmendment[1]/following-sibling::*[1][self::leg:AppendText]">
			<xsl:apply-templates select="ancestor::leg:BlockAmendment[1]/following-sibling::*[1]/node()"/>
		</xsl:if>
	</xsl:if>		
</xsl:template>

<xsl:template match="math:math">		
	<span class="LegInlineFormula">
		<xsl:variable name="strCheckMathsForRendering">
			<xsl:call-template name="FuncCheckDisplayImageOrRenderMaths">
				<xsl:with-param name="currentnode" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<!-- For very simple one line maths with no odd characters output as text -->
			<xsl:when test="$strCheckMathsForRendering = $g_strRenderMaths">
				<xsl:apply-templates select="*"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="parent::leg:Span/@AltVersionRefs != ''">
						<!-- We'll assume here that there is only one version -->
						<xsl:apply-templates select="//leg:Version[@id = current()/parent::*/@AltVersionRefs]/*"/>
						<xsl:apply-templates select=".//(leg:Substitution|leg:Addition|leg:Repeal)" mode="mathrevisions"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="FuncOutputError"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>

<xsl:template name="FuncOutputError">
	<div class="LegClearFix LegErrorMaths">
		<p class="NoMathImageToDisplay">No math image to display</p>
	</div>
</xsl:template>

<!-- Perform the various checks to determine whether and image should be displayed or the maths elements rendered for output.
	  The following conditions trigger the display of an image:
			*	Mulitple level of rows;
			*	The use of elements that do not appear in the list:  mi, mo, mtext, mrow, msup, msub;
			*	The use of fractions or square root, which are automatically be addressed by the list in the second point.

		The order of the checks that need to be performed will save time by elminating the immediate ones to be discounted first.

		First check if there are any multiple use of rows.  
			If there are multiple rows, then this automatically triggers the display of an image.
			Otherwise, then the second list - of allowable elements should be checked.
				If there are elements used other than any of these, then this triggers the display of an image.
				Otherwise, check the list of renderable characters.
					If any characters in the text (not elements) which are deemed not renderable, then this triggers the display of an image.
					Otherwise, If all characters in the text are okay, then proceed to render the <maths> elements for output.

	The current node is used as a parameter to this function as we want to make sure that the current node is always "math" and
	is taken explicitly from the calling template.  In the case of the OPSI project, the leg:Formula and math:math templates call this
	template.  The leg:Formula passes in the descendant math node (as there could a "semantic" node).
-->

<xsl:template name="FuncCheckDisplayImageOrRenderMaths">
	<xsl:param name="currentnode"/>
			
	<!-- Grab all the descendant element names for the current node.  This is to check whether there are any elements used other than the safe list:  mi, mo, mtext, mn, mrow, msup, msub. -->
	<xsl:variable name="strMathsElements">
		<xsl:for-each select="$currentnode/descendant::*">
			<!-- Ignore the following elements as these are valid:  mi, mo, mtext, mn, mrow, msup, msub. -->
			<xsl:if test="not(name() = 'mi' or name() = 'mo' or name() = 'mtext' or name() = 'mn' or name() = 'mrow' or name() = 'msup' or name() = 'msub')">
				<xsl:value-of select="name()"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="strMathsText">
		<xsl:for-each select="$currentnode/descendant::text()">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:choose>
		<!-- Check if multiple rows, ie, only to display simple single line maths as rendered maths. -->
		<xsl:when test="$currentnode/math:mrow//math:mrow">
			<xsl:value-of select="$g_strDisplayImage"/>
		</xsl:when>
		<!-- Check the descendant elements for allowable elements: mi, mo, mtext, mrow, msup, msub, mn. -->
		<!-- If the list of descendant elements is NOT EMPTY, this means that there are other elements being used outside the safe list.-->
		<xsl:when test="normalize-space($strMathsElements)">
			<xsl:value-of select="$g_strDisplayImage"/>
		</xsl:when>
		<!-- Check the for renderable characters. -->
		<xsl:when test="translate($strMathsText, $g_strRenderableCharacters, '') != ''">
			<xsl:value-of select="$g_strDisplayImage"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$g_strRenderMaths"/>
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>

<xsl:template match="math:semantics">
	<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="math:mrow">
	<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="math:mi">
	<xsl:variable name="strStyle">
		<xsl:choose>
			<xsl:when test="@mathvariant = 'normal'"/>
			<xsl:otherwise>
				<xsl:text>font-style: italic</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="$strStyle != ''">
			<span style="{$strStyle}">
				<xsl:apply-templates/>
			</span>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="math:mn | math:mtext">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="math:annotation"/>

<xsl:template match="math:mo">
	<!-- If not a fence output some white space -->
	<xsl:if test=". != '(' and . != ')'">
		<xsl:text>&#160;</xsl:text>
	</xsl:if>
	<xsl:apply-templates/>
	<xsl:if test=". != '(' and . != ')'">
		<xsl:text>&#160;</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="math:msup | math:msub">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="math:msub/*[2]">
	<sub>
		<xsl:apply-templates/>
	</sub>
</xsl:template>

<xsl:template match="math:msup/*[2]">
	<sub>
		<xsl:apply-templates/>
	</sub>
</xsl:template>

<xsl:template match="leg:Where">
	<div class="LegWhere">
		<xsl:apply-templates select="*"/>
	</div>
</xsl:template>

</xsl:stylesheet>
 
