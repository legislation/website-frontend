<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

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

<!-- ========== Standard code for outputting legislation ========= -->

<xsl:import href="legislation_xhtml_vanilla.xslt"/>

<xsl:import href="../../common/utils.xsl"/>

<xsl:output method="xml" version="1.0" omit-xml-declaration="yes"  indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

<xsl:key name="citations" match="leg:Citation" use="@id" />
<xsl:key name="commentary" match="leg:Commentary" use="@id"/>
<xsl:key name="commentaryRef" match="leg:CommentaryRef" use="@Ref"/>
<xsl:key name="commentaryRef" match="leg:Addition | leg:Repeal | leg:Substitution" use="@CommentaryRef"/>
<xsl:key name="commentaryRefInChange" match="leg:Addition | leg:Repeal | leg:Substitution" use="concat(@CommentaryRef, '+', @ChangeId)" />
<xsl:key name="additionRepealChanges" match="leg:Addition | leg:Repeal | leg:Substitution" use="@ChangeId"/>
<xsl:key name="substituted" match="leg:Repeal[@SubstitutionRef]" use="@SubstitutionRef" />
<xsl:key name="citationLists" match="leg:CitationList" use="@id"/>
<xsl:key name="versions" match="leg:Version" use="@id" />
<xsl:key name="versionOf" match="*[@AltVersionRefs]" use="tokenize(@AltVersionRefs, ' ')" />

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

<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

<xsl:variable name="legislationYear" select="/leg:Legislation/ukm:Metadata//ukm:Year/@Value"/>
<xsl:variable name="legislationNumber" select="/leg:Legislation/ukm:Metadata//ukm:Number/@Value"/>
<xsl:variable name="uriPrefix" select="tso:GetUriPrefixFromType(/leg:Legislation/ukm:Metadata//ukm:DocumentMainType/@Value, $legislationYear)"/>
<xsl:variable name="dcIdentifier" select="/leg:Legislation/ukm:Metadata/dc:identifier"/>
<xsl:variable name="isWrap" as="xs:boolean" select="$paramsDoc/parameters/wrap='true'"/>

<xsl:param name="version" as="xs:string" select="($paramsDoc/parameters/version, '')[1]"/>
<xsl:variable name="contentsLinkParams" as="xs:string" select="if ($paramsDoc/parameters/extent[. != '']) then '?view=extent' else ''" />

<xsl:variable name="g_ndsTemplateDoc" 
	select="if ($paramsDoc/parameters/wrap = 'true') then doc('HTMLTemplate_Vanilla-v-1-0.xml') else doc('HTMLTemplate_snippet.xml')" />

<xsl:param name="selectedSection" as="element()?" select="()" />

<xsl:variable name="selectedSectionSubstituted" as="xs:boolean" select="false()" />

<!-- ========= Code for consolidation ========== -->

<xsl:template match="leg:Legislation">
	
	<!--<p>Parameters for this page: </p>
	<xsl:for-each select="doc('input:request')/parameters/*">
		<p><xsl:value-of select="name()"/>: <xsl:value-of select="."/></p>
	</xsl:for-each>-->
	<xsl:call-template name="FuncLegNotification"/>
	<xsl:choose>
		<xsl:when test="$paramsDoc/parameters/view = 'introduction'">
			<xsl:apply-templates select="leg:Primary/leg:PrimaryPrelims | leg:Secondary/leg:SecondaryPrelims" />
			<xsl:apply-templates select="*[not(self::leg:Primary | self::leg:Secondary | self::leg:Contents)] | processing-instruction()"/>
		</xsl:when>
		<xsl:when test="$paramsDoc/parameters/view = 'body'">
			<xsl:apply-templates select="(leg:Primary | leg:Secondary)/leg:Body"/>
		</xsl:when>
		<xsl:when test="$paramsDoc/parameters/view = 'contents'">
			<xsl:apply-templates select="leg:Contents" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="*[not(self::leg:Contents)] | processing-instruction()"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:PrimaryPrelims" mode="Introduction">
	<div class="LegClearFix LegPrelims">
		<xsl:call-template name="FuncOutputPrimaryPrelimsPreContents"/>
		<xsl:apply-templates select="/leg:Legislation/leg:Contents"/>		
		<xsl:call-template name="FuncOutputPrimaryPrelimsPostContents"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims" mode="Introduction">
	<div class="LegClearFix LegPrelims">
		<xsl:apply-templates select="leg:Number | leg:SubjectInformation | leg:Title"/>
		<xsl:apply-templates select="leg:SecondaryPreamble"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
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
		priority="100">
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
		priority="100">
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

<xsl:function name="tso:isSubstituted" as="xs:boolean">
	<xsl:param name="element" as="element()" />
	<xsl:variable name="firstTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][1]/ancestor::leg:Repeal[@SubstitutionRef]" />
	<xsl:variable name="lastTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][last()]/ancestor::leg:Repeal[@SubstitutionRef]" />
	<xsl:sequence select="exists($firstTextRepeal) and exists($lastTextRepeal) and $firstTextRepeal/@ChangeId = $lastTextRepeal/@ChangeId" />
</xsl:function>

<xsl:function name="tso:isProposedRepeal" as="xs:boolean">
	<xsl:param name="element" as="element()" />
	<xsl:variable name="firstTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][1]/ancestor::leg:Repeal[@Status = 'Proposed' and not(@SubstitutionRef)]" />
	<xsl:variable name="lastTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][last()]/ancestor::leg:Repeal[@Status = 'Proposed' and not(@SubstitutionRef)]" />
	<xsl:sequence select="exists($firstTextRepeal) and exists($lastTextRepeal) and $firstTextRepeal/@ChangeId = $lastTextRepeal/@ChangeId" />
</xsl:function>

<xsl:template match="leg:ContentsItem/leg:ContentsNumber">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />
	<xsl:variable name="nstContent">
		<xsl:apply-templates/>
		<xsl:if test="translate(., ' &#160;', '') != ''">
			<xsl:text>.</xsl:text>
		</xsl:if>
	</xsl:variable>
	<!-- <span class="LegDS {concat('LegContentsNo', $strAmendmentSuffix)}{if (exists($matchIndex)) then ' LegSearchResult' else ()}"> -->
	<span class="LegDS {concat('LegContentsNo', $strAmendmentSuffix)}{if (../@MatchText) then ' LegSearchResult' else ()}">
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:copy-of select="$nstContent" />
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$nstContent" />
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>
	
<xsl:template match="leg:ContentsPart/leg:ContentsNumber | leg:ContentsChapter/leg:ContentsNumber">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />
	<p class="{concat('LegContentsNo', $strAmendmentSuffix)}">
		<xsl:if test="exists($matchIndex) and ../@ContentRef">
			<xsl:attribute name="id" select="concat('match-', $matchIndex)"/>
		</xsl:if>	
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:if test="exists($matchIndex)">
						<xsl:attribute name="class" select="'LegSearchResult'" />
					</xsl:if>
					<xsl:apply-templates/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="following-sibling::leg:ContentsTitle" mode="inlineTitle"/>
				</a>
			<xsl:call-template name="matchLinks">
					<xsl:with-param name="matchIndex" select="$matchIndex" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="following-sibling::leg:ContentsTitle" mode="inlineTitle"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</p>
</xsl:template>	
	
<xsl:template match="leg:ContentsNumber">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />
	<p class="{concat('LegContentsNo', $strAmendmentSuffix)}">
		<xsl:if test="exists($matchIndex) and ../@ContentRef">
			<xsl:attribute name="id" select="concat('match-', $matchIndex)"/>
		</xsl:if>	
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:if test="exists($matchIndex)">
						<xsl:attribute name="class" select="'LegSearchResult'" />
					</xsl:if>
					<xsl:choose>
						<xsl:when test=". = '' and ../leg:ContentsTitle = ''">
							<xsl:value-of select="substring-after(local-name(..), 'Contents')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates />
						</xsl:otherwise>
					</xsl:choose>
				</a>
			<xsl:call-template name="matchLinks">
					<xsl:with-param name="matchIndex" select="$matchIndex" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

<xsl:template match="leg:ContentsPart/leg:ContentsTitle | leg:ContentsChapter/leg:ContentsTitle" mode="inlineTitle">
	<xsl:apply-templates/>
</xsl:template>

<!-- Chunyu  HA050364 deleted leg:ContentsPart/leg:ContentsTitle in this template. It has casused the titles were missing see nisi/2007/1351,NISI 2007/287 (NI 1) and etc.-->
	<!-- Yashashri HA051273 - Reverted code changed by chunyu to existing one  as it was creating other issue(HA051273)with one extra condition so that it can fix both issue in call HA051273 and HA049670(the issue chunuy fixed)-->
	<xsl:template match="leg:ContentsPart[leg:ContentsNumber]/leg:ContentsTitle | leg:ContentsChapter[leg:ContentsNumber]/leg:ContentsTitle">
<!--  FM U437: Chapter Headings should appear even if there is no chapter number-->   
</xsl:template>

<xsl:template match="leg:Contents/leg:ContentsTitle">
	<h2 class="LegContentsHeading">
		<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title" />			
	</h2>
</xsl:template>

<xsl:template match="leg:ContentsSchedules/leg:ContentsTitle">
	<xsl:apply-imports />
</xsl:template>

<xsl:template match="leg:ContentsItem/leg:ContentsTitle">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />		
	<!-- Chunyu HA051073 changed the condition of LegSearchResult into @MatchText. It will be safer to get search result. There are instances that replicated section ids. See aosp/1690/7
	<span class="LegDS {concat('LegContentsTitle', $strAmendmentSuffix)}{if (exists($matchIndex)) then ' LegSearchResult' else ()}"> -->
	<!-- pass that through as a tunnelling parameter called $matchRefs. Then on a given item get the index-of() this item's ContentRef wtihin -->	
		<span class="LegDS {concat('LegContentsTitle', $strAmendmentSuffix)}{if (../@MatchText) then ' LegSearchResult' else ()}">
		<xsl:if test="exists($matchIndex)">
			<xsl:attribute name="id" select="concat('match-', $matchIndex)"/>
		</xsl:if>	
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<!--	HA050978 - added condition to have links for titles in ContentsSchedule - http://www.legislation.gov.uk/apni/1970/10/contents-->
			<xsl:when test="parent::*/parent::leg:ContentsSchedule/@DocumentURI and not(parent::*/@DocumentURI)">
				<a href="{substring-after(parent::*/parent::leg:ContentsSchedule/@DocumentURI, 'http://www.legislation.gov.uk')}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>		
			<xsl:otherwise>
				<xsl:apply-templates/>				
			</xsl:otherwise>
		</xsl:choose>
	</span>
	<xsl:call-template name="matchLinks">
		<xsl:with-param name="matchIndex" select="$matchIndex" />
	</xsl:call-template>		
</xsl:template>

<xsl:template match="leg:ContentsTitle">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />		
	<p class="{concat('LegContentsTitle', $strAmendmentSuffix)}">
		<!-- pass that through as a tunnelling parameter called $matchRefs. Then on a given item get the index-of() this item's ContentRef wtihin -->
		<xsl:if test="exists($matchIndex) and ../@ContentRef">
			<xsl:attribute name="id" select="concat('match-', $matchIndex)"/>
		</xsl:if>	
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:if test="exists($matchIndex)">
						<xsl:attribute name="class" select="'LegSearchResult'" />
					</xsl:if>
					<xsl:apply-templates/>
				</a>
			<xsl:call-template name="matchLinks">
					<xsl:with-param name="matchIndex" select="$matchIndex" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>		
	</p>
</xsl:template>
	
	<!-- added by Yashashri - call No : HA050979 - Links to EU legislation should not appear in TOC -->	
	<xsl:template match="leg:ContentsSchedule/leg:ContentsTitle/leg:Citation">
		<xsl:apply-templates/>
	</xsl:template>

<xsl:template name="matchLinks">
	<xsl:param name="matchRefs" as="xs:string*" tunnel="yes" select="()" />
	<xsl:param name="matchIndex" as="xs:integer?" required="yes" />
	<xsl:if test="exists($matchIndex)">
		<!-- adding previous link-->			
		<xsl:if test="$matchIndex &gt; 1">
			<span class="skipLink prev">
				<a href="{concat('#match-', $matchIndex -1 )}"><xsl:value-of select="leg:TranslateText('Previous Match')"/></a>
			</span>
		</xsl:if>
		<!-- adding next link-->
		<xsl:if test="$matchIndex &lt; count($matchRefs)">
			<span class="skipLink next">
				<a href="{concat('#match-', $matchIndex + 1)}"><xsl:value-of select="leg:TranslateText('Next Match')"/></a>
			</span>
		</xsl:if>
	</xsl:if>		
</xsl:template>

<!--Chunyu:Call HA049511 Added includedDocument in $showSection to resovle the xml file to display properly on the page see /uksi/1999/1892/ -->
<xsl:template match="leg:Body | leg:Schedules">
	<xsl:param name="showSection" as="element()*" tunnel="yes" select="()" />
	<xsl:choose>
		<xsl:when test="ancestor::leg:BlockAmendment">
			<xsl:next-match />
		</xsl:when>
		<xsl:when test="exists($showSection[not(//leg:IncludedDocument)])">
			<xsl:apply-templates select="$showSection" mode="showSectionWithAnnotation"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="." mode="ProcessAnnotations" />
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Adding Annotations for parent levels if the current section is dead/repeal -->
<xsl:template match="*" mode="showSectionWithAnnotation">
	<xsl:apply-templates select="."/>
</xsl:template>


<xsl:template match="leg:InlineAmendment">
	<span class="LegAmendingText">
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="leg:Addition | leg:Repeal | leg:Substitution">
	<xsl:param name="showSection" select="root()" tunnel="yes" />
	<xsl:param name="showRepeals" select="false()" tunnel="yes" />	
	<xsl:variable name="showCommentary" as="xs:boolean" select="tso:showCommentary(.)" />
	<xsl:variable name="changeId" as="xs:string" select="@ChangeId" />
	<xsl:variable name="showSection" as="node()"
		select="if (ancestor::*[@VersionReplacement]) then ancestor::*[@VersionReplacement] else if (exists($showSection) and ancestor-or-self::*[. is $showSection]) then $showSection else root()" />
	<xsl:variable name="sameChanges" as="element()*" select="key('additionRepealChanges', $changeId, $showSection)" />
	<xsl:variable name="firstChange" as="element()?" select="$sameChanges[1]" />
	<xsl:variable name="lastChange" as="element()?" select="$sameChanges[last()]" />
	<xsl:variable name="isFirstChange" as="xs:boolean?">
		<xsl:choose>
			<xsl:when test="$g_strDocumentType = $g_strPrimary and ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group">
				<xsl:sequence select="$firstChange is (ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group//(leg:Addition|leg:Repeal|leg:Substitution))[1]" />
			</xsl:when>
			<xsl:when test="$g_strDocumentType = $g_strPrimary and ancestor::leg:Title/parent::leg:P1group">
				<xsl:sequence select="$firstChange is . and
					empty(ancestor::leg:Title/parent::leg:P1group/leg:P1[1]/leg:Pnumber//(leg:Addition|leg:Repeal|leg:Substitution)[@ChangeId = $changeId])" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$firstChange is ." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
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
			<span class="LegChangeDelimiter">[</span>
		</xsl:if>
		<xsl:apply-templates select="." mode="AdditionRepealRefs"/>
	</xsl:if>
	<span class="Leg{if (@Status = 'Proposed') then 'Proposed' else ''}{$changeType}">
		<xsl:apply-templates/>
	</span>
	<xsl:if test="$showCommentary and key('additionRepealChanges', @ChangeId, $showSection)[last()] is .">
		<span class="LegChangeDelimiter">]</span>
	</xsl:if>
</xsl:template>

<!--<xsl:template match="leg:Repeal">
	<xsl:apply-templates select="." mode="AdditionRepealRefs"/>
	<span class="LegRepeal">
		<xsl:apply-templates/>
	</span>
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
	
			<xsl:variable name="sameChanges" as="element()*" select="key('commentaryRefInChange', concat(@CommentaryRef, '+', @ChangeId), $showSection)" />
			
			<xsl:variable name="firstChange" as="element()?" select="$sameChanges[1]" />
			<xsl:variable name="isFirstChange" as="xs:boolean?">
				<xsl:choose>
					<xsl:when test="$g_strDocumentType = $g_strPrimary and ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group">
						<xsl:sequence select="$firstChange is (ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group//(leg:Addition|leg:Substitution))[1]" />
					</xsl:when>
					<xsl:when test="$g_strDocumentType = $g_strPrimary and ancestor::leg:Title/parent::leg:P1group">
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
<!--Chunyu HA051080 added the logic for CommentaryRef. We need to display each individual commentaryref if it is not the child of additon and etc. We only output the first one if  the commentaryrefs with same ref are the chidren of addtion and etc.-->
<xsl:template match="leg:Primary/leg:CommentaryRef | leg:Secondary/leg:CommentaryRef" />

<xsl:template match="leg:CommentaryRef">
	<xsl:variable name="commentaryItem" select="key('commentary', @Ref)[1]" as="element(leg:Commentary)?"/>
	<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReference][1]/@VersionReference"/>
	<xsl:if test="empty($commentaryItem)">
		<span class="LegError">No commentary item could be found for this reference <xsl:value-of select="@Ref"/></span>
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
	
<xsl:function name="tso:OutputCommentaryRef" as="element(xhtml:a)">
	<xsl:param name="isFirstReference" as="xs:boolean"/>
	<xsl:param name="commentaryItem" as="element(leg:Commentary)"/>
	<xsl:param name="versionRef" as="xs:string"/>
	<a class="LegCommentaryLink" href="#commentary-{$commentaryItem/@id}{$versionRef}" title="View the commentary text for this item">
		<!-- There may be multiple references to the commentary. Only output back id on first one -->
		<xsl:if test="$isFirstReference">
			<xsl:attribute name="id" select="concat('reference-', $commentaryItem/@id, $versionRef)"/>
		</xsl:if>
		<xsl:variable name="thisId" select="$commentaryItem/@id"/>
		<xsl:value-of select="$commentaryItem/@Type"/>
		<!--<xsl:value-of select="count($commentaryItem/preceding-sibling::*[@Type = $commentaryItem/@Type]) + 1"/>-->
		<!-- we need to reference the document order of the commentaries rather than the commentary order in order to gain the correct numbering sequence -->
		<xsl:value-of select="count($g_commentaryOrder/leg:commentary[@id = $thisId][1]/preceding-sibling::*[@Type = $commentaryItem/@Type]) + 1"/>
		
	</a>
</xsl:function>

<!-- when we have repealed parts then a child para is usually added which has the annotation in it  -->
<xsl:template match="leg:P[not(parent::leg:P1group)]">
	<xsl:apply-templates/>
	<xsl:apply-templates select="." mode="ProcessAnnotations"/>
</xsl:template>

<xsl:template match="leg:Commentaries | err:Warning | leg:CitationLists"/>

	<xsl:template match="leg:Primary | leg:Secondary | leg:Body | leg:Schedules | leg:P1group | leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:P1 | leg:P |leg:PrimaryPrelims | leg:SecondaryPrelims | leg:Schedule | leg:Form | leg:Schedule/leg:ScheduleBody//leg:Tabular " mode="ProcessAnnotations">
	<xsl:param name="showSection" as="element()*" tunnel="yes" select="()" />
	<xsl:param name="showingHigherLevel" as="xs:boolean" tunnel="yes" select="false()"/>
	<xsl:param name="includeTooltip" as="xs:boolean" tunnel="yes" select="false()"/>
	
	
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
			<!-- updated by yashashri 	HA051079 - added parent::leg:Schedules or parent::leg:ScheduleBody to fix missing footnotes on http://www.legislation.gov.uk/ukpga/Geo5/23-24/12/schedule/FIRST -->
			<xsl:when test="self::leg:P and (@id or parent::*[@id] or parent::leg:Body or parent::leg:Schedules or parent::leg:ScheduleBody)">			
				<xsl:sequence select="descendant::leg:CommentaryRef"/>
			</xsl:when>
			<!--HA053652: annotations in tables are repeated if table is child of P1 (annotations also processed for all descendants of P1) so condition added to exclude these tables-->
			<xsl:when test="self::leg:Tabular[not(parent::leg:P1)] and (parent::*[@id] or parent::leg:Body )">
				<xsl:sequence select="descendant::leg:CommentaryRef" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="child::leg:CommentaryRef | (leg:Number | leg:Title | leg:Reference | leg:TitleBlock)/descendant::leg:CommentaryRef"/>
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
			<!-- Chunyu HA050371 added parent::leg:ScheduleBody to fix http://www.legislation.gov.uk/ukpga/1981/61/schedule/3 -->
			<xsl:when test="self::leg:P and (@id or parent::*[@id] or parent::leg:Body or parent::leg:Schedules or parent::leg:ScheduleBody)">
				<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
			</xsl:when>
			<!--HA053652: annotations in tables are repeated if table is child of P1 (annotations also processed for all descendants of P1) so condition added to exclude these tables-->
			<xsl:when test="self::leg:Tabular[not(parent::leg:P1)] and (parent::*[@id] or parent::leg:Body or parent::leg:Schedules or parent::leg:ScheduleBody)">
				<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="leg:Addition | leg:Repeal | leg:Substitution | (leg:Number | leg:Title | leg:Reference | leg:TitleBlock)/(descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution)"/>
			</xsl:otherwise>	
		</xsl:choose>			
	</xsl:variable>
		
	<xsl:variable name="commentaryItem" select="key('commentary', ($commentaryRefs/@Ref, $additionRepealRefs/@CommentaryRef))" as="element(leg:Commentary)*"/>
	<xsl:variable name="currentURI">
		<xsl:choose>
			<xsl:when test="@DocumentURI"><xsl:value-of select="@DocumentURI"/></xsl:when>
			<xsl:when test="self::leg:Body"><xsl:value-of select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/body']/@href" /></xsl:when>
			<xsl:when test="self::leg:Schedules"><xsl:value-of select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/schedules']/@href" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="descendant::*[@DocumentURI][1]/@DocumentURI"/></xsl:otherwise>
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
			<!-- if the current section is repealed then get the commenteries of all the higher levels-->
			<xsl:apply-templates select="ancestor::*" mode="ProcessAnnotations">
				<xsl:with-param name="showingHigherLevel" select="true()" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:if>	
	</xsl:variable>

	<xsl:if test="$showComments or $higherLevelComments/*">
		<div>
			<xsl:choose>
				<xsl:when test="$showingHigherLevel">
					<xsl:attribute name="class" select="'LegAssociatedAnnotations'"/>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class" select="'LegAnnotations'"/>
					<div class="LegAnnotationsHeading">
						<xsl:text>Annotations:</xsl:text>
						<xsl:if test="$includeTooltip">
							<a href="#Annotation{generate-id(.)}Help" class="helpItem helpItemToBot">
								<img src="/images/chrome/helpIcon.gif" alt=" Help about Annotation"/>
							</a>
							<div class="help" id="Annotation{generate-id(.)}Help">
								<span class="icon"/>
								<div class="content">
									<a href="#" class="close">
										<img alt="Close" src="/images/chrome/closeIcon.gif"/>
									</a>
									<!--<h3><xsl:value-of select="Annotations"/></h3>-->
									<p><xsl:value-of select="leg:TranslateText('Annotation_text')"/></p>
								</div>
							</div>
						</xsl:if>
					</div>
					<xsl:copy-of select="$higherLevelComments"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Issue FM#235
				At section level only the section number with the dots should be displayed along with an annotation box that only shows the repeal annottaion, pulled in from the parent. 
				When viewed at higher levels (e.g Part, cross heading, chapter, act levels) the sections within that level should be brought back as abover with just number and dotted lines. 
				No annotations needed under each section as the repel annotation will be in the part annotation. 
			if any higher level comments have been added due to dead/repealed then don't display any commenteries
			-->
			<xsl:if test="not($higherLevelComments/*)">
				
				<xsl:variable name="documentType" select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>
				<xsl:variable name="documentYear" select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value"/>
				<xsl:variable name="documentRevised" select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:DocumentClassification/ukm:DocumentStatus/@Value"/>
				
				<!-- FM:  Issue 364: In NI legislation before 1.1.2006 - f-notes are used across the board i.e. not just for textual amendments. Removing the annotation heading for textual texts --> 
				<xsl:variable name="oldNI" select="$documentType = 
					('NorthernIrelandAct' , 'NorthernIrelandOrderInCouncil' , 'NorthernIrelandStatutoryRule', 
					'NorthernIrelandAssemblyMeasure', 'NorthernIrelandParliamentAct') and ($documentYear &lt; 2006)"/>
				
				<!-- TNA requirement based on above :
						The issue is that the SLD ‘as enacted’ S.I.s deployed to legislation.gov.uk from SLD (ActiveText editorial system) which we will be using for update contain existing annotations.
						All the existing annotations in these S.I.s are classed as f-notes regardless of the fact that virtually all of the them should be m-notes.
						For example, where the annotation is just an Act reference (e.g. 1985 c. 6) this would be an m-note in a revised Act but it is listed as an f-note in the S.I.s.
						This means that on legislation.gov.uk such annotations will be listed under ‘textual amendments’ which is misleading.
						We have a similar issue with older Orders in Council and what we have done there is to show all the annotations in one list (without the textual/ non-textual etc categorisation (e.g. http://www.legislation.gov.uk/nisi/1973/1896)).
						What we would like to do is apply this same code to all the revised S.I.s  on legislation.gov.uk.” 
						-->
				<xsl:variable name="revisedSI" select="$documentType = 
					('UnitedKingdomStatutoryInstrument' , 'ScottishStatutoryInstrument' , 'WelshStatutoryInstrument', 'NorthernIrelandStatutoryRule') and ($documentRevised = 'revised')"/>
				
				<xsl:for-each-group select="$showComments" group-by="@Type">
					<xsl:sort select="@Type = 'M'"/>			
					<xsl:sort select="@Type = 'I'"/>
					<xsl:sort select="@Type = 'C'"/>
					<xsl:sort select="@Type = 'F'"/>
					<xsl:variable name="groupType" select="current-grouping-key()"/>
					
					<xsl:if test="not(($oldNI or $revisedSI) and $groupType = 'F' )">
						<p class="LegAnnotationsGroupHeading">
							<xsl:if test="$showingHigherLevel">
								<xsl:value-of select="leg:TranslateText('Associated')"/>
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="$groupType = 'I'"><xsl:value-of select="leg:TranslateText('Commencement Information')"/></xsl:when>
								<xsl:when test="$groupType = 'F'"><xsl:value-of select="leg:TranslateText('Amendments (Textual)')"/></xsl:when>
								<xsl:when test="$groupType = 'M'"><xsl:value-of select="leg:TranslateText('Marginal Citations')"/></xsl:when>		
								<xsl:when test="$groupType = 'C'"><xsl:value-of select="leg:TranslateText('Modifications etc. (not altering text)')"/></xsl:when>
								<xsl:when test="$groupType = 'P'"><xsl:value-of select="leg:TranslateText('Subordinate Legislation Made')"/></xsl:when>
								<xsl:when test="$groupType = 'E'"><xsl:value-of select="leg:TranslateText('Extent Information')"/></xsl:when>
								<xsl:when test="$groupType = 'X'"><xsl:value-of select="leg:TranslateText('Editorial Information')"/></xsl:when>
							</xsl:choose>				
						</p>
					</xsl:if>  
					<xsl:apply-templates select="current-group()" mode="DisplayAnnotations">
						<xsl:sort select="tso:commentaryNumber(@id)" />
						<xsl:with-param name="versionRef" select="$versionRef"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
			</xsl:if>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="*" mode="ProcessAnnotations"/>
<!-- Override Vanilla handling -->
<xsl:template match="leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:Schedule | leg:Form" mode="Structure">
	<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	<xsl:call-template name="FuncProcessStructureContents"/>
</xsl:template>
	
<!-- ========== Handle extent information ========== -->
<!-- May need to extend this to cover a standalone P1 as well as P1group for secondary formatted legislation -->

<xsl:template match="leg:PrimaryPrelims | leg:SecondaryPrelims" priority="100">
	<xsl:if test="ancestor-or-self::*/@RestrictExtent">
		<xsl:variable name="blnConcurrent" as="xs:boolean" select="@Concurrent = 'true'" />
		<p class="LegExtentParagraph{if ($blnConcurrent) then ' LegConcurrent' else ''}">
			<xsl:copy-of select="tso:generateExtentInfo(.)"/>
		</p>
	</xsl:if>	
	<xsl:next-match/>
</xsl:template>

<xsl:template name="FuncGenerateMajorHeadingNumber">
	<xsl:param name="strHeading"/>
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="blnConcurrent" as="xs:boolean" 
		select="parent::*/@Concurrent = 'true'" />
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
			<xsl:if test="$blnConcurrent"> LegConcurrent</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates/>
		<xsl:if test="ancestor-or-self::*/@RestrictExtent">
			<xsl:sequence select="tso:generateExtentInfo(..)"/>
		</xsl:if>	
	</xsl:element>
</xsl:template>

	<xsl:template name="FuncGenerateMajorHeadingTitle">
	<xsl:param name="strHeading"/>
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<!--<xsl:call-template name="FuncCheckForIDelement"/>-->
	<xsl:variable name="blnConcurrent" as="xs:boolean" 
		select="parent::*/@Concurrent = 'true'" />
	<xsl:variable name="blnHasNumber" as="xs:boolean" select="exists(../leg:Number) or exists(parent::leg:TitleBlock/../leg:Number)" />
	<xsl:element name="span">		
		<xsl:attribute name="class">
			<!-- Yashashri: Changed To make Headings Left alligned - Support call - HA047941-->
			<!-- Chunyu: Added the condition for Yash's change to limit for pblock see HA050365 http://www.legislation.gov.uk/nia/2012/3/part/3 -->
				<xsl:choose>
					<xsl:when test="leg:Emphasis and not(parent::leg:Pblock)">LegClearFix LegSP1GroupTitle</xsl:when>
					<xsl:otherwise>	
						<xsl:text>Leg</xsl:text>
						<xsl:value-of select="$strHeading"/>
						<xsl:text>Title</xsl:text>
						<xsl:if test="$strAmendmentSuffix != ''">
							<xsl:text> Leg</xsl:text>
							<xsl:value-of select="$strAmendmentSuffix"/>
						</xsl:if>
						<xsl:if test="not($blnHasNumber) and $blnConcurrent"> LegConcurrent</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
		</xsl:attribute>	
		<xsl:apply-templates/>
		<xsl:if test="not($blnHasNumber) and ancestor-or-self::*/@RestrictExtent">
			<xsl:sequence select="tso:generateExtentInfo(if (parent::leg:TitleBlock) then parent::leg:TitleBlock/.. else ..)" />
		</xsl:if>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:P1group[not(ancestor::leg:BlockAmendment)]/leg:Title/node()[last()]" priority="100">
	<xsl:next-match/>
	<xsl:if test="ancestor-or-self::*/@RestrictExtent">
		<xsl:variable name="blnConcurrent" as="xs:boolean" 
			select="ancestor::leg:P1group/@Concurrent = 'true'" />
		<xsl:variable name="nstContent" as="node()*">
			<xsl:copy-of select="tso:generateExtentInfo(ancestor::leg:P1group)"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$blnConcurrent">
				<span class="{concat('LegConcurrent', if (ancestor::leg:P1group/@Status='Prospective') then ' LegProspective' else '' )}">
					<xsl:sequence select="$nstContent" />
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$nstContent" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:function name="tso:generateExtentInfo" as="element()?">
	<xsl:param name="element" as="node()" />
	<xsl:variable name="extent" as="xs:string" select="($element/ancestor-or-self::*[@RestrictExtent][1]/@RestrictExtent, 'E+W+S+N.I.')[1]" />
	<span class="LegExtentRestriction">
		<!--<xsl:if test="$nstSelectedSection is $element">-->
			<xsl:attribute name="id" select="concat('extent-', translate($extent, '+', '-'))" />
		<!--</xsl:if>-->
		<xsl:attribute name="title">
			<xsl:variable name="extentsToken" select="tokenize($extent, '\+')" />
			<xsl:value-of select="leg:TranslateText('Applies to')"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="tso:extentDescription($extentsToken)" />
		</xsl:attribute>
		<span class="btr"></span>
		<xsl:value-of select="$extent" />
		<span class="bbl"></span><span class="bbr"></span>
	</span>
</xsl:function>

<!-- FM 
	Issue  235: Block repeal: Where there has been a block repeal (e.g a whole Part repeal as in 1975 c.30 Part II) instead of the 'no longer effect' styling can the 
	sectoins be presented as (e.g 21. ............................................) . 
	At section level only the section number with the dots should be displayed along with an annotation box that only shows the repeal annottaion, pulled in from the parent. 
	When viewed at higher levels (e.g Part, cross heading, chapter, act levels) the sections within that level should be brought back as abover with just number and dotted lines. 
	No annotations needed under each section as the repel annotation will be in the part annotation.
-->
<!-- displaying P1group/title as dotted line if the section is repealed.  -->
<xsl:template match="leg:P1group[not(ancestor::leg:BlockAmendment) and @Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))]/leg:Title" priority="60">
	<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>
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

<!--Every child that's repealed has @Match = 'false' and @RestrictEndDate not @Status = 'Prospective': -->
<!--Chunyu HA049670 Changed priority from 50 to 51 since it conflicts with the template of line 955 see nisi/2007/1351 part -->
<xsl:template match="leg:Part | leg:Body | leg:Schedules | leg:Pblock | leg:PsubBlock" priority="51">
	<xsl:choose>
		<xsl:when test="every $child in (leg:* except (leg:Number, leg:Title))
				satisfies ((($child/@Match = 'false' and $child/@RestrictEndDate) and not($child/@Status = 'Prospective') and
				   ((($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= current-date() ))) or ($child/@Match = 'false' and $child/@Status = 'Repealed'))">
			<xsl:apply-templates select="leg:Number | leg:Title" />
			<p>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</p>
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--For schedules you have to look inside the ScheduleBody: -->
<xsl:template match="leg:Schedule" priority="50">
	<xsl:choose>
		<xsl:when test="(@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and
				   ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))) or (every $child in (leg:ScheduleBody/*)
		  satisfies (($child/@Match = 'false' and $child/@RestrictEndDate and not($child/@Status = 'Prospective')) and
				   ((($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= current-date() ))) or ($child/@Match = 'false' and $child/@Status = 'Repealed'))">
			<p class="LegArticleRef">
				<xsl:for-each select="leg:Reference">
					<xsl:call-template name="FuncCheckForID"/>
					<xsl:apply-templates/>
				</xsl:for-each>
			</p>		  
			 <h2 class="LegScheduleFirst">
				<xsl:apply-templates select="leg:Number | leg:TitleBlock" />
			</h2>
			<p>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</p>
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--<xsl:template match="*[@Match = 'false' and not(@Status = 'Prospective') and not(ancestor::leg:Contents)]" priority="50">
	<div class="LegBlockRepeal">
		<p class="LegClearFix LegBlockRepealHeading"><span>No longer has effect</span></p>
		<xsl:next-match />
	</div>
</xsl:template>-->

<xsl:template match="*[(@RestrictStartDate castable as xs:date) and @Match = 'false' and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; current-date() ))]" priority="50">
	<xsl:param name="showingValidFromDate" tunnel="yes" as="xs:date?" select="()" />
	<xsl:choose>
		<xsl:when test="empty($showingValidFromDate) or xs:date(@RestrictStartDate) != $showingValidFromDate">
			<div class="LegBlockNotYetInForce">
				<p class="LegClearFix LegBlockNotYetInForceHeading">
					<span>
						<xsl:value-of select="leg:TranslateText('over')"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="format-date(xs:date(@RestrictStartDate), '[D01]/[M01]/[Y0001]')"/>
					</span>
				</p>
				<xsl:next-match>
					<xsl:with-param name="showingValidFromDate" tunnel="yes" select="xs:date(@RestrictStartDate)" />
				</xsl:next-match>
			</div>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[not(ancestor::leg:Contents) and ((@Match = 'false' and @Status = 'Prospective') or (@Status = 'Dead' and $version castable as xs:date and xs:date(@RestrictEndDate) &gt; xs:date($version)))]" priority="60">
	<xsl:param name="showingProspective" tunnel="yes" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="not($showingProspective)">
			<div class="LegBlockNotYetInForce">
				<p class="LegClearFix LegBlockNotYetInForceHeading">
					<span>
						<xsl:value-of select="leg:TranslateText('Prospective')"/>
					</span>
				</p>
				<xsl:next-match>
					<xsl:with-param name="showingProspective" tunnel="yes" select="true()" />
				</xsl:next-match>
			</div>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:P1[@NotesURI] | leg:Schedule[@NotesURI]" mode="showEN">
	<xsl:variable name="enType" 
		select="if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/notes/toc' and not(@hreflang = 'cy')]/@href) then 'notes'
					else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/executive-note/toc']/@href) then 'executive-notes'
					else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/policy-note/toc' and not(@hreflang = 'cy')]/@href) then 'policy-notes'
					else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/memorandum/toc' and not(@hreflang = 'cy')]/@href) then 'memorandum'
					else '' "/>
		
	<xsl:if test="$enType != ''">
		<div class="eniw">
			<span class="enNote">
				<xsl:value-of select="leg:TranslateText(if ($enType = 'executive-notes') then 'Executive Note' 
											   else if ($enType = 'policy-notes') then 'Policy Notes'
											   else if ($enType = 'memorandum') then 'Explanatory Memorandum' 
											   else 'Explanatory Notes')"/>
			</span>
			<a class="LegDS noteLink" href="{substring-after(@NotesURI, 'http://www.legislation.gov.uk')}">
				<xsl:value-of select="leg:TranslateText('Show')"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="if ($enType = 'executive-notes') then 'EN' 
											   else if ($enType = 'policy-notes') then 'PN'
											   else if ($enType = 'memorandum') then 'EM' 
											   else 'EN'"/>
			</a>
		</div>		
	</xsl:if>
</xsl:template>

<xsl:template match="leg:P1 | leg:Schedule" mode="showEN">
	<xsl:if test=". is $selectedSection or parent::leg:P1group is $selectedSection">
		<xsl:variable name="enType" 
			select="if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/notes/toc' and not(@hreflang = 'cy')]/@href) then 'notes'
						else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/executive-note/toc']/@href) then 'executive-notes'
						else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/policy-note/toc' and not(@hreflang = 'cy')]/@href) then 'policy-notes'
						else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/memorandum/toc' and not(@hreflang = 'cy')]/@href) then 'memorandum'
						else '' "/>
			
		<xsl:if test="$enType != ''">
			<div class="eniw">
				<span class="enNote">
					<xsl:value-of select="leg:TranslateText('No_associated_note',
											concat('type=',
												leg:TranslateText(if (self::leg:P1) then 'section' else 'schedule'),
												'noteType=',
												leg:TranslateText(if ($enType = 'executive-notes') then 'Executive Note' 
												else if ($enType = 'policy-notes') then 'Policy Notes'
												else if ($enType = 'memorandum') then 'Explanatory Memorandum' 
												else 'Explanatory Notes')
											)
										)"/>
				</span>
			</div>		
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:Schedule//leg:P1 | leg:PrimaryPrelims | leg:SecondaryPrelims | leg:P1group | leg:Schedule/leg:ScheduleBody//leg:Tabular">
	<xsl:next-match/>
	<!-- If there are alternate versions outputting ot annotations will happen there -->
	<xsl:if test="not(@AltVersionRefs) and not(parent::leg:BlockAmendment)">
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	</xsl:if>
</xsl:template>
	
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
				<xsl:apply-templates mode="VersionNormalisation">
					<xsl:with-param name="ndsVersionToUse" select="$ndsVersionToUse"/>
					<xsl:with-param name="itemToReplace" select="$itemToReplace"/>
					<xsl:with-param name="strVersion" select="$strVersion"/>
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="text()" priority="0.25">
	<xsl:choose>
		<xsl:when test="ancestor::leg:BlockAmendment">
			<span class="LegAmendingText">
				<xsl:next-match/>
			</span>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates select="following::*[1][self::leg:BlockAmendment[@CitationListRef]]" mode="CitationListRef"/>
</xsl:template>

<xsl:template match="leg:Commentary" mode="DisplayAnnotations">
	<xsl:param name="versionRef"/>
	<div class="LegCommentaryItem" id="commentary-{@id}{translate($versionRef,' ','')}">
		<xsl:apply-templates select="leg:Para" mode="DisplayAnnotations" >
				<xsl:with-param name="versionRef" select="$versionRef"/>
			</xsl:apply-templates>
	</div>
</xsl:template>

<xsl:template match="leg:Commentary/leg:Para" mode="DisplayAnnotations">
	<xsl:param name="versionRef"/>
	<p class="LegCommentaryPara">
		<xsl:if test="position() = 1">
			<span class="LegCommentaryType">
				<!-- we need to reference the document order of the commentaries rather than the commentary order in order to gain the correct numbering sequence -->
				<xsl:variable name="thisId" select="parent::leg:Commentary/@id"/>
				<xsl:variable name="thisType" select="parent::leg:Commentary/@Type"/>
				<xsl:variable name="strType" as="xs:string"
					select="concat(../@Type, count($g_commentaryOrder/leg:commentary[@id = $thisId][1]/preceding-sibling::*[@Type = $thisType]) + 1)" />
				
				
				<!--<xsl:variable name="strType" as="xs:string"
					select="concat(../@Type, count(../preceding-sibling::leg:Commentary[@Type = current()/../@Type]) + 1)" />-->
				<xsl:choose>
					<xsl:when test="../@Type = ('F', 'M', 'X')">
						<a href="#reference-{../@id}{translate($versionRef,' ','')}" title="Go back to reference for this commentary item">
							<xsl:value-of select="$strType" />
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$strType" />
					</xsl:otherwise>
				</xsl:choose>
			</span>
		</xsl:if>
		<xsl:apply-templates mode="DisplayAnnotations" />
	</p>
</xsl:template>

<xsl:template match="leg:Commentary/leg:Para/leg:Text" mode="DisplayAnnotations">
	<span class="LegCommentaryText">
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="leg:Citation">
	<xsl:variable name="uri">
		<xsl:value-of select="replace(./@URI,'&amp;','and')"/>
	</xsl:variable>	
	<a class="LegCitation" title="{if (@Title) then @Title else 'Go to item of legislation'}" rel="cite">
		<xsl:choose>
			<xsl:when test="@URI">
				<xsl:attribute name="href" select="$uri" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="href" select="concat('/', tso:GetUriPrefixFromType(@Class, @Year), '/', @Year, '/', @Number, if (@SectionRef) then concat('/', translate(@SectionRef, '-', '/')) else())" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
	</a>
</xsl:template>

<xsl:template match="leg:CitationSubRef[@URI]">
	<xsl:variable name="legislation" as="element(leg:Citation)?"
		select="key('citations', @CitationRef)[1]" />
	<xsl:variable name="title" as="xs:string"
		select="string-join(('Go to', if ($legislation/@Title) then $legislation/@Title else if ($legislation) then $legislation else (), .), ' ')" />
	<xsl:variable name="uri">
		<xsl:value-of select="replace(./@URI,'&amp;','and')"/>
		</xsl:variable>
	<a class="LegCitation" href="{if ($isWrap and $TranslateLangPrefix) then concat('http://legislation.gov.uk',$TranslateLangPrefix, substring-after($uri,'http://www.legislation.gov.uk')) else $uri}" title="{$title}" rel="cite">
		<xsl:choose>
			<xsl:when test="@Operative = 'true'">
				<strong><xsl:apply-templates /></strong>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</a>
</xsl:template>

<xsl:template match="leg:BlockAmendment" mode="CitationListRef">
	<xsl:variable name="citationList" select="key('citationLists', @CitationListRef)" as="element(leg:CitationList)"/>
	<xsl:choose>
		<!-- If only one item go direct -->
		<xsl:when test="count($citationList/leg:Citation) = 1">
			<xsl:apply-templates select="$citationList/leg:Citation" mode="AffectedLegislation"/>
		</xsl:when>
		<xsl:otherwise>
			<a class="LegCitation" href="/{$uriPrefix}/{$legislationYear}/{$legislationNumber}{tso:IsStartDate(@StartDate)}/affected/{$citationList/@id}" title="Go to list of affected legislation" rel="cite">
				<img class="LegAffectedLink" src="/images/icon_linkto_affected_leg.gif" alt=""/>
			</a>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<xsl:template match="leg:CitationListRef">
	<xsl:variable name="citationList" select="key('citationLists', @Ref)" as="element(leg:CitationList)"/>
	<xsl:choose>
		<!-- If only one item go direct -->
		<xsl:when test="count($citationList/leg:Citation) = 1">
			<xsl:apply-templates select="$citationList/leg:Citation" mode="AffectedLegislation"/>
		</xsl:when>
		<xsl:otherwise>
			<a class="LegCitation" href="/{$uriPrefix}/{$legislationYear}/{$legislationNumber}{tso:IsStartDate(@StartDate)}/affected/{$citationList/@id}" title="Go to list of affected legislation" rel="cite">
				<img class="LegAffectedLink" src="/images/icon_linkto_affected_leg.gif" alt=""/>
			</a>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<xsl:template match="leg:Citation" mode="AffectedLegislation">
	<a class="LegCitation" href="/{tso:GetUriPrefixFromType(@Class, @Year)}/{@Year}/{@Number}{tso:IsStartDate(@StartDate)}#reference-{@CommentaryRef}" title="Go to affected legislation" rel="cite">
		<img class="LegAffectedLink" src="/images/icon_linkto_affected_leg.gif" alt=""/>
	</a>
</xsl:template>

<xsl:template match="leg:Term">
	<span class="LegTerm" id="{@id}">
		<xsl:apply-templates/>
	</span>
</xsl:template>
	
<xsl:function name="tso:IsStartDate" as="xs:string?">
	<xsl:param name="startDate"/>
	<xsl:if test="$startDate">
		<xsl:sequence select="concat('/', $startDate)"/>
	</xsl:if>
</xsl:function>

<!-- *** Text Processing Overrides *** -->

<xsl:template match="leg:Text" priority="1000">
	<xsl:next-match>
		<xsl:with-param name="nstLastTextNode" tunnel="yes" select="(.//text())[last()]" />
	</xsl:next-match>
</xsl:template>

<xsl:template match="leg:Text[following-sibling::*[1][self::leg:BlockAmendment][child::*[1][self::leg:Text]]]" priority="999">
	<xsl:next-match>
		<xsl:with-param name="nstRunOnAmendmentText" tunnel="yes" 
			select="if ($g_strDocumentType = $g_strPrimary or following-sibling::leg:BlockAmendment[1]/string(@PartialRefs) != '')
			        then following-sibling::leg:BlockAmendment[1]/leg:Text[1]
			        else ()" />
	</xsl:next-match>
</xsl:template>

<!-- This catches the first leg:Text within a P1 that hasn't got a P1group parent and that has some extent restriction applied -->
<!--Chunyu HA049670 Added [last()] for P1 which has a scenario with two P1 see nisi/2007/1351 schedule 5 -->
<xsl:template match="*[not(self::leg:P1group)]/leg:P1[ancestor-or-self::*/@RestrictExtent]//leg:*[preceding-sibling::leg:*[1][self::leg:Pnumber]]/leg:Text[not(preceding-sibling::*) and not(ancestor::leg:BlockAmendment)]">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="nstExtentMarker" select="tso:generateExtentInfo(ancestor::leg:P1[not(ancestor-or-self::leg:BlockAmendment)][last()])" />
	<!-- For primary legislation the indent of content is dependent upon its parent for amendments therefore we need more information if the parent is lower level than the content being amended -->
	<xsl:choose>
		<!-- N1 without a P1group -->
		<xsl:when test="parent::leg:P1para and $g_strDocumentType = $g_strPrimary">
			<!-- Calculate if in a primary schedule -->
			<xsl:variable name="strScheduleContext">
				<xsl:call-template name="FuncGetScheduleContext"/>
			</xsl:variable>
			<p class="LegClearFix {concat('Leg', $strScheduleContext, 'P1Container')} LegExtentContainer">
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
				<xsl:sequence select="$nstExtentMarker" />
			</p>
		</xsl:when>
		<!-- Numbered paragraphs using hanging indent so we need to process them in a special manner -->
		<!-- For secondary legislation we need to make sure that we dont pick up N1-N3 or N1-N3-N4 (both very rare) -->
		<xsl:when test="parent::*[(self::leg:P2para and $g_strDocumentType = $g_strPrimary) 
			 or (self::leg:P1para and ancestor::leg:Schedule and $g_strDocumentType = $g_strPrimary)
			 or self::leg:P3para[not($g_strDocumentType = $g_strSecondary and parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P1para/preceding-sibling::*[1][self::leg:Pnumber])]
			 or self::leg:P4para[not($g_strDocumentType = $g_strSecondary and parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P1para/preceding-sibling::*[1][self::leg:Pnumber])]
			 or self::leg:P5para or self::leg:P6para or self::leg:P7para]">
			<!-- Calculate if in a primary schedule -->
			<xsl:variable name="strScheduleContext">
				<xsl:call-template name="FuncGetScheduleContext"/>
			</xsl:variable>
			<xsl:variable name="nstText">
				<span class="Text">
					<xsl:call-template name="FuncGetLocalTextStyle"/>
					<xsl:call-template name="FuncGetTextClass"/>
					<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
				</span>
			</xsl:variable>
			<xsl:variable name="strClass" select="concat('LegClearFix Leg', $strScheduleContext, name(parent::*/parent::*), 'Container')" />
			<!--<xsl:variable name="strScheduleNestedContext">
				<xsl:call-template name="FuncGetScheduleNestedAmendmentContext"/>
			</xsl:variable>-->
			<p>
				<xsl:call-template name="FuncCheckForID"/>				
				<xsl:choose>
					<!-- Combined N3-N4 paragraph -->
					<xsl:when test="parent::leg:P4para/parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]">
						<xsl:attribute name="class" select="$strClass" />
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
						<xsl:sequence select="$nstText" />
					</xsl:when>
					<!-- Combined N4-N5 paragraph -->
					<xsl:when test="parent::leg:P5para/parent::leg:P5[not(preceding-sibling::*)]/parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]">
						<xsl:attribute name="class" select="$strClass" />
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
						<xsl:sequence select="$nstText" />
					</xsl:when>
					<xsl:otherwise>
						<!-- For primary legislation ... -->
						<!-- If in a schedule and a combined N1-N2 then output N1 number. -->
						<!-- If context is unknown and BlockAmendment does not contain P1group then assume it is a schedule amendment as an amendment to a P1 in the body does not make any sense or if TargetClass is secondary apply similar logic (as secondary gets formatted like primary) -->
						<!-- Also if the below functionality has been invoked then handle that too -->
						<xsl:choose>					
							<xsl:when test="$g_strDocumentType = $g_strPrimary and 
								parent::leg:P2para and 
								generate-id(ancestor::leg:P1[1]/descendant::text()[not(normalize-space(.) = '' or ancestor::leg:Pnumber or ancestor::leg:Title)][1]) = generate-id(descendant::text()[not(normalize-space(.) = '')][1]) and
								generate-id(ancestor::leg:P2[1]/descendant::text()[not(normalize-space(.) = '' or ancestor::leg:Pnumber)][1]) = generate-id(descendant::text()[not(normalize-space(.) = '')][1])">
								<xsl:attribute name="class" select="concat($strClass, ' LegExtentContainer')" />
								<span class="LegDS {concat('LegSN1No', $strAmendmentSuffix)}">
									<xsl:for-each select="ancestor::leg:P1[1]">
										<xsl:call-template name="FuncCheckForID"/>
										<xsl:apply-templates select="leg:Pnumber"/>
									</xsl:for-each>									
								</span>
								<span class="LegDS {concat('LegSN2No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>
								<xsl:sequence select="$nstText" />
								<xsl:sequence select="$nstExtentMarker" />
							</xsl:when>
							<!-- P2-P3 -->
							<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P3para[ancestor::leg:P2para] and (ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or ((@Context = 'unknown' or @TargetClass = 'secondary') and not(descendant::leg:P1group))]] or (ancestor::leg:P1group/@Layout = 'below' and generate-id(ancestor::leg:P1group[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber or ancestor::leg:Title)]  or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]))) and
							generate-id(ancestor::leg:P2[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1] or ancestor::leg:Title/parent::leg:P3group)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]) and
							generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1])">
								<xsl:attribute name="class" select="concat($strClass, ' LegExtentContainer')" />
								<span class="LegDS {concat('LegP2No', $strAmendmentSuffix)}">
									<xsl:for-each select="ancestor::leg:P2[1]">
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
								<xsl:sequence select="$nstText" />
								<xsl:sequence select="$nstExtentMarker" />
							</xsl:when>
							<!-- P1-P3 -->
							<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P3para[not(ancestor::leg:P2para)] and (ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or ((@Context = 'unknown' or @TargetClass = 'secondary') and not(descendant::leg:P1group))]] or (ancestor::leg:P1group/@Layout = 'below' and generate-id(ancestor::leg:P1group[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber or ancestor::leg:Title)]  or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]))) and
							generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1] or ancestor::leg:Title/parent::leg:P3group)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]) and
							generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1])">
								<xsl:attribute name="class" select="concat($strClass, ' LegExtentContainer')" />
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
								<xsl:sequence select="$nstText" />
								<xsl:sequence select="$nstExtentMarker" />
							</xsl:when>
							<!-- Special handling for P1 numbers in schedules in primary legislation -->
							<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P1para">
								<xsl:attribute name="class" select="concat($strClass, ' LegExtentContainer')" />
								<span class="LegDS {concat('LegP1No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>		
								<xsl:sequence select="$nstText" />
								<xsl:sequence select="$nstExtentMarker" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class" select="$strClass" />
								<span class="LegDS LegLHS {concat('Leg', name(parent::*/parent::*), 'No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>
								<xsl:sequence select="$nstText" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="not(ancestor::leg:MarginNote)">
				<xsl:variable name="blnShowExtent"
					select="generate-id(ancestor::leg:P1[1]/descendant::text()[not(normalize-space(.) = '' or ancestor::leg:Pnumber or ancestor::leg:Title)][1]) = generate-id(descendant::text()[1][not(normalize-space(.) = '')][1])" />
				<xsl:variable name="textClass" as="node()*">
					<xsl:call-template name="FuncGetTextClass">
						<xsl:with-param name="flMode" select="'Block'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="classAttribute" as="attribute(class)?" select="$textClass[. instance of attribute(class)]" />
				<!-- JT: Do not use $textClass except $classAttribute as this reorders the content! -->
				<xsl:variable name="content" select="$textClass[not(. is $classAttribute)]" />
				<p class="{if (exists($classAttribute)) then $classAttribute else concat('LegText', $strAmendmentSuffix)}{if ($blnShowExtent) then ' LegExtentContainer' else ''}">
					<xsl:for-each select="ancestor::leg:P1">
						<xsl:call-template name="FuncCheckForID"/>
					</xsl:for-each>
					<xsl:call-template name="FuncGetLocalTextStyle"/>
					<xsl:sequence select="$content" />
					<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
					<xsl:if test="$blnShowExtent">
						<xsl:sequence select="$nstExtentMarker" />
					</xsl:if>
				</p>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="FuncTextPostOperations">
	<xsl:param name="nstLastTextNode" as="text()?" tunnel="yes" select="(ancestor::leg:Text[1]//text())[last()]" />
	<xsl:param name="nstRunOnAmendmentText" as="element(leg:Text)?" tunnel="yes" select="()" />
	<!-- Output generated text around paragraph numbers -->
	<xsl:variable name="nstPnumber" as="element(leg:Pnumber)?"
		select="ancestor::leg:Pnumber" />
	<xsl:if test="exists($nstPnumber) and normalize-space(.) != ''">
		<xsl:choose>
			<xsl:when test="$nstPnumber/@PuncAfter">
				<xsl:value-of select="$nstPnumber/@PuncAfter" />
			</xsl:when>
			<xsl:when test="$nstPnumber/parent::leg:P1 and $g_strDocumentType = $g_strPrimary"/>
			<xsl:when test="$nstPnumber/parent::leg:P1">.</xsl:when>
			<xsl:otherwise>)</xsl:otherwise>
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


<xsl:template name="FuncLegNotification">
	<xsl:if test="$paramsDoc/parameters/version != '' and $paramsDoc/parameters/version != $g_ndsMetadata/dct:valid">
		<p class="LegNotification">Please note that the date you requested in the address for this web page is not an actual date upon which a change occurred to this item of legislation. You are being shown the legislation from <xsl:value-of select="format-date($g_ndsMetadata/dc:valid, '[D10] [MNn] [Y]')"/>, which is the first date before then upon which a change was made.</p>
	</xsl:if>
</xsl:template>

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

<xsl:function name="tso:commentaryNumber" as="xs:integer">
	<xsl:param name="commentary" as="xs:string" />
	<xsl:sequence select="count($g_commentaryOrder/leg:commentary[@id = $commentary][1]/preceding-sibling::*)" />
</xsl:function>

</xsl:stylesheet>
