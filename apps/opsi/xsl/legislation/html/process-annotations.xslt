<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Legislation schema XHTML output for consolidated legislation -->
<!-- This serves to process the annotations and is a common module for both html and fo output -->


<!-- Version 1.00 -->
<!-- Created by Griff Chamberlain -->
<!-- Last changed 11-05-2015 by Griff Chamberlain -->
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

	<xsl:template match="leg:Appendix | leg:Attachment | leg:Primary | leg:Secondary | leg:EURetained | leg:Body | leg:EUBody | leg:Schedules | leg:SignedSection | leg:ExplanatoryNotes | leg:P1group | leg:Title | leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:P1 | leg:P |leg:PrimaryPrelims | leg:SecondaryPrelims | leg:EUPrelims | leg:Schedule | leg:Form | leg:Schedule/leg:ScheduleBody//leg:Tabular | leg:EUTitle | leg:EUPart | leg:EUChapter | leg:EUSection | leg:Division | leg:Footnotes | leg:ScheduleBody/leg:BlockAmendment" mode="ProcessAnnotations">
		<xsl:param name="showSection" as="element()*" tunnel="yes" select="()" />
		<xsl:param name="showingHigherLevel" as="xs:boolean" tunnel="yes" select="false()"/>
		<xsl:param name="includeTooltip" as="xs:boolean" tunnel="yes" select="false()"/>

		<xsl:variable name="currentURI">
			<xsl:choose>
				<xsl:when test="@DocumentURI">
					<xsl:value-of select="@DocumentURI"/>
				</xsl:when>
				<xsl:when test="self::leg:Body or self::leg:EUBody">
					<xsl:value-of select="$g_bodyURI" />
				</xsl:when>
				<xsl:when test="self::leg:Schedules">
					<xsl:value-of select="$g_schedulesOnlyURI" />
				</xsl:when>
				<xsl:when test="parent::leg:SignedSection">
					<xsl:value-of select="$g_strsignatureURI" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="descendant::*[@DocumentURI][1]/@DocumentURI"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="isRequestedProvision" select="$dcIdentifier = $currentURI"/>
		
		
		<xsl:variable name="showSection" as="node()"
		select="if (ancestor::*[@VersionReplacement]) then ancestor::*[@VersionReplacement] else if (exists($showSection) and ancestor-or-self::*[. is $showSection]) then $showSection else root()" />
		<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReference][1]/@VersionReference"/>
		<xsl:variable name="commentaryRefs" as="element(leg:CommentaryRef)*">
			<xsl:choose>
				<!--HA053652 HA053652 HA051079-->
				<!--  retained some conditions for fringe cases  -->
				<xsl:when test="ancestor::leg:BlockAmendment">
					<!--Block amendment annotations handled at end of provision-->
				</xsl:when>
				<xsl:when test="self::leg:Part[not(ancestor::leg:BlockAmendment)] | self::leg:Chapter[not(ancestor::leg:BlockAmendment)] | self::leg:Pblock[not(ancestor::leg:BlockAmendment)] | self::leg:PsubBlock[not(ancestor::leg:BlockAmendment)] | self::leg:EUTitle[not(ancestor::leg:BlockAmendment)] | self::leg:EUPart[not(ancestor::leg:BlockAmendment)] | self::leg:EUChapter[not(ancestor::leg:BlockAmendment)] | self::leg:EUSection[not(ancestor::leg:BlockAmendment)] |
				self::leg:EUSubsection[not(ancestor::leg:BlockAmendment)] |
				self::leg:Division[not(ancestor::leg:BlockAmendment)]">
					<xsl:sequence select="(leg:Number | leg:Title)/descendant::leg:CommentaryRef" />
				</xsl:when>
				<xsl:when test="self::leg:Attachment[not(ancestor::leg:BlockAmendment)] | self::leg:P1group[not(ancestor::leg:BlockAmendment)] | self::leg:P1[not(parent::leg:P1group)][not(ancestor::leg:BlockAmendment)][not(ancestor::leg:Tabular)] | self::leg:PrimaryPrelims | self::leg:SecondaryPrelims | self::leg:EUPrelims |self::leg:Tabular[not(parent::leg:P1)][not(parent::leg:P)] | self::leg:SignedSection[not(ancestor::leg:BlockAmendment)] ">
					<xsl:sequence select="descendant::leg:CommentaryRef"/>
				</xsl:when>
				<xsl:when test="self::leg:P and (@id or parent::*[@id] or parent::leg:Body or parent::leg:EUBody or parent::leg:Schedules or parent::leg:ScheduleBody)">			
					<xsl:sequence select="descendant::leg:CommentaryRef"/>
				</xsl:when>
				<xsl:when test="self::leg:BlockAmendment and parent::leg:ScheduleBody">			
					<xsl:sequence select="descendant::leg:CommentaryRef"/>
				</xsl:when>
				<xsl:when test="self::leg:Tabular[not(parent::leg:P1)][not(parent::leg:P)] and (parent::*[@id] or parent::leg:Body or parent::leg:EUBody )">
					<xsl:sequence select="descendant::leg:CommentaryRef" />
				</xsl:when>
				<xsl:when test="self::leg:Title[parent::leg:Part or parent::leg:Chapter]">
					<xsl:sequence select="descendant::leg:CommentaryRef" />
				</xsl:when>
				<xsl:when test="self::leg:Title[parent::leg:P1group or parent::leg:P1]">
					<!-- all other title commentaries handled at end of the provision  -->
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="child::leg:CommentaryRef | (leg:Number | leg:Title | leg:Reference | leg:TitleBlock)/descendant::leg:CommentaryRef"/>
				</xsl:otherwise>	
			</xsl:choose>			
		</xsl:variable>

		<xsl:variable name="additionRepealRefs" as="element()*">
			<xsl:choose>
				<!--HA053652 HA057074 HA050371 HA058757-->
				<!--  retained some conditions for fringe cases  -->
				<xsl:when test="ancestor::leg:BlockAmendment">
					<!--Block amendment annotations handled at end of provision-->
				</xsl:when>
				<xsl:when test="self::leg:Part[not(ancestor::leg:BlockAmendment)] | self::leg:Chapter[not(ancestor::leg:BlockAmendment)] | self::leg:Pblock[not(ancestor::leg:BlockAmendment)] | self::leg:PsubBlock[not(ancestor::leg:BlockAmendment)] | self::leg:EUTitle[not(ancestor::leg:BlockAmendment)] | self::leg:EUPart[not(ancestor::leg:BlockAmendment)] | self::leg:EUChapter[not(ancestor::leg:BlockAmendment)] | self::leg:EUSection[not(ancestor::leg:BlockAmendment)] | 
				self::leg:EUSubsection[not(ancestor::leg:BlockAmendment)] | 
				self::leg:Division[not(ancestor::leg:BlockAmendment)]">
					<xsl:sequence select="(leg:Number | leg:Title)/(descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution)" />
				</xsl:when>
				<!-- for prelims we need to take all descendent amendments -->
				<xsl:when test="self::leg:Footnotes | self::leg:PrimaryPrelims | self::leg:SecondaryPrelims | self::leg:EUPrelims">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>	
				<xsl:when test="self::leg:Attachment[not(ancestor::leg:BlockAmendment)] | self::leg:P1group[not(ancestor::leg:BlockAmendment)] | self::leg:P1[not(parent::leg:P1group)][not(ancestor::leg:BlockAmendment)][not(ancestor::leg:Tabular)] | self::leg:SignedSection[not(ancestor::leg:BlockAmendment)]">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>
				<xsl:when test="self::leg:Title[parent::leg:Part or parent::leg:Chapter][not(ancestor::leg:BlockAmendment)]">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>
				<xsl:when test="self::leg:Title[parent::leg:P1group or parent::leg:P1]">
					<!-- all other title commentaries handled at end of the provision  -->
				</xsl:when>
				<xsl:when test="self::leg:P and (@id or parent::*[@id] or parent::leg:Body or parent::leg:EUBody or parent::leg:Schedules or parent::leg:ScheduleBody)">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>
				<xsl:when test="self::leg:BlockAmendment and parent::leg:ScheduleBody">			
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>
				<xsl:when test="self::leg:Tabular[not(parent::leg:P1)][not(parent::leg:P)] and (parent::*[@id] or parent::leg:Body or parent::leg:EUBody or parent::leg:Schedules or parent::leg:ScheduleBody)">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="leg:Addition | leg:Repeal | leg:Substitution | (leg:Number | leg:Title[ancestor:: leg:Secondary/leg:Schedules/leg:Schedule/leg:ScheduleBody/leg:Pblock] | leg:Reference | leg:TitleBlock)/(descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution)"/>
				</xsl:otherwise>	
			</xsl:choose>			
		</xsl:variable>

		<xsl:variable name="commentaryItem" select="key('commentary', ($commentaryRefs/@Ref, $additionRepealRefs/@CommentaryRef))" as="element(leg:Commentary)*"/>
		
		<xsl:variable name="isDead" as="xs:boolean" select="@Status = 'Dead'" />
		<xsl:variable name="isValidFrom" as="xs:boolean" select="@Match = 'false' and @RestrictStartDate and ((($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; current-date() ))" />
		<xsl:variable name="isRepealed" as="xs:boolean" select="(@Match = 'false' and (not(@Status) or @Status != 'Prospective') and not($isValidFrom)) or ($isRepealedAct and matches($currentURI, '/body|/schedules|/note'))"/>

		
		<xsl:variable name="showComments" as="element(leg:Commentary)*">
			<xsl:variable name="localname" select="local-name()"/>
			<xsl:variable name="thisSection" select="."/>
			<xsl:variable name="ancestorRefs" select="ancestor::*[self::leg:Appendix or self::leg:Schedule or self::leg:Part or self::leg:Chapter or self::leg:Pblock or self::leg:Group or self::leg:EUPart or self::leg:EUChapter or self::leg:EUTitle or self::leg:EUSection or self::leg:EUSubsection or leg:Division[@Type = ('EUPart','EUTitle','EUChapter','EUSection','EUSubsection')]]/(leg:TitleBlock | leg:Title | leg:Number)/(descendant::leg:CommentaryRef/@Ref | descendant::leg:Repeal/@CommentaryRef | descendant::leg:Substitution/@CommentaryRef | descendant::leg:Addition/@CommentaryRef)"/>
			
			<xsl:for-each select="$commentaryItem">
				
				<xsl:if test="self::leg:Footnotes or $showingHigherLevel or not($isRepealed) or ($isRepealed and contains(., 'temp.')) or $isDead">
					<xsl:choose>
						<!-- For higher level views we need to annotate all provisions that have a common change -->
						<xsl:when test="$localname = 'Footnotes' or ($localname = ('P1', 'P1group') and not(@id = $ancestorRefs))">
							<xsl:if test="key('commentaryRef', @id, $thisSection)[1] intersect ($commentaryRefs | $additionRepealRefs)">
								<xsl:sequence select="."/>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<!-- We need to check if the first reference to the comment falls within this structure. Do this for each comment in the list -->
							<xsl:if test="key('commentaryRef', @id, $showSection)[1] intersect ($commentaryRefs | $additionRepealRefs)">
								<xsl:sequence select="."/>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>	

		<!-- FM:  Issue 195: Only the f-notes should be pulled into the child fragments from the parent-->
		<xsl:variable name="showComments" as="element(leg:Commentary)*"
		select="$showComments[not($showingHigherLevel) or ($showingHigherLevel and @Type ='F')]" />
		
		<xsl:variable name="showComments" as="element(leg:Commentary)*"
		select="if ($currentURI = ($g_strIntroductionUri, $g_strwholeActURI)) then 
					$showComments
				else $showComments[not(@id = $g_wholeActCommentaries/@id)]" />
		
		
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
				<xsl:if test="not($isRepealed)">
					<xsl:attribute name="class" select="'LegAnnotations'"/>
					<xsl:call-template name="make-annotation">
						<xsl:with-param name="commentary" select="$showComments"/>
						<xsl:with-param name="versionRef" select="$versionRef"/>
						<xsl:with-param name="isHighLevel" select="false()"/>
					</xsl:call-template>
				</xsl:if>
			</div>
			<!-- these mnay be part/chapter repeals -->
			<xsl:copy-of select="$higherLevelComments"/>
		</xsl:if>
		<!-- whole act commentary  -->
		<!-- only output if we are on the requested provision and nto at act/intro level  -->
		<xsl:if test="$g_wholeActCommentaries[@Type = 'F'] and $isRequestedProvision and not($currentURI = ($g_strIntroductionUri, $g_strwholeActURI)) and not($showingHigherLevel)">	
			<div>
				<xsl:attribute name="class" select="'LegAnnotations'"/>
				<xsl:call-template name="make-annotation">
					<xsl:with-param name="commentary" select="$g_wholeActCommentaries[@Type = 'F']"/>
					<xsl:with-param name="versionRef" select="$versionRef"/>
					<xsl:with-param name="isHighLevel" select="true()"/>
				</xsl:call-template>			
			<xsl:if test="$g_wholeActCommentaries[not(@Type = 'F')]">
				<p class="LegAnnotationsGroupHeading">
					<xsl:value-of select="leg:TranslateText('Non-textual amendments applied to the whole Legislation')"/>
					<xsl:text> </xsl:text>
					<span class="normal">
						<xsl:value-of select="leg:TranslateText('can be found in the')"/>
						<xsl:text> </xsl:text>
						<a href="{$g_strIntroductionUri}">
							<xsl:value-of select="leg:TranslateText('Introduction')"/>
						</a>
					</span>
				</p>
			</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="ProcessAnnotations"/>
	
	<!-- prevent snnotations from rendering within a table -->
	<xsl:template match="xhtml:table//*" mode="ProcessAnnotations" priority="100"/>
	
	<xsl:template name="make-annotation">
		<xsl:param name="commentary" as="element()*"/>
		<xsl:param name="versionRef"/>
		<xsl:param name="isHighLevel" as="xs:boolean"/>
		
		<!-- Issue FM#235
				At section level only the section number with the dots should be displayed along with an annotation box that only shows the repeal annottaion, pulled in from the parent. 
				When viewed at higher levels (e.g Part, cross heading, chapter, act levels) the sections within that level should be brought back as abover with just number and dotted lines. 
				No annotations needed under each section as the repel annotation will be in the part annotation. 
			if any higher level comments have been added due to dead/repealed then don't display any commenteries
			-->
		<!-- FM:  Issue 364: In NI legislation before 1.1.2006 - f-notes are used across the board i.e. not just for textual amendments. Removing the annotation heading for textual texts --> 
					
		<!-- TNA requirement based on above :
			The issue is that the SLD ‘as enacted’ S.I.s deployed to legislation.gov.uk from SLD (ActiveText editorial system) which we will be using for update contain existing annotations.
			All the existing annotations in these S.I.s are classed as f-notes regardless of the fact that virtually all of the them should be m-notes.
			For example, where the annotation is just an Act reference (e.g. 1985 c. 6) this would be an m-note in a revised Act but it is listed as an f-note in the S.I.s.
			This means that on legislation.gov.uk such annotations will be listed under ‘textual amendments’ which is misleading.
			We have a similar issue with older Orders in Council and what we have done there is to show all the annotations in one list (without the textual/ non-textual etc categorisation (e.g. http://www.legislation.gov.uk/nisi/1973/1896)).
			What we would like to do is apply this same code to all the revised S.I.s  on legislation.gov.uk.” 
			-->
	
		<xsl:variable name="oldNI" select="$g_strDocumentMainType = 
					('NorthernIrelandAct' , 'NorthernIrelandOrderInCouncil' , 'NorthernIrelandStatutoryRule', 'NorthernIrelandStatutoryRuleOrOrder', 
					'NorthernIrelandAssemblyMeasure', 'NorthernIrelandParliamentAct') and ($g_strDocumentYear &lt; 2006)"/>
		<xsl:variable name="revisedSI" select="$g_strDocumentMainType = 
					('UnitedKingdomStatutoryInstrument' , 'ScottishStatutoryInstrument' , 'WelshStatutoryInstrument', 'NorthernIrelandStatutoryRule', 'NorthernIrelandStatutoryRuleOrOrder') and ($g_strDocumentStatus = 'revised')"/>
		
		
		<xsl:for-each-group select="$commentary" group-by="@Type">
			<xsl:sort select="@Type = 'M'"/>			
			<xsl:sort select="@Type = 'I'"/>
			<xsl:sort select="@Type = 'C'"/>
			<xsl:sort select="@Type = 'F'"/>
			<xsl:variable name="groupType" select="current-grouping-key()"/>

			<xsl:if test="not(($oldNI or $revisedSI) and $groupType = 'F' )">
				<p class="LegAnnotationsGroupHeading">
					<xsl:choose>
						<xsl:when test="$groupType = 'I'">
							<xsl:value-of select="leg:TranslateText('Commencement Information')"/>
						</xsl:when>
						<xsl:when test="$groupType = 'F'">
							<xsl:value-of select="leg:TranslateText('Textual Amendments')"/>
						</xsl:when>
						<xsl:when test="$groupType = 'M'">
							<xsl:value-of select="leg:TranslateText('Marginal Citations')"/>
						</xsl:when>		
						<xsl:when test="$groupType = 'C'">
							<xsl:value-of select="leg:TranslateText('Modifications etc. (not altering text)')"/>
						</xsl:when>
						<xsl:when test="$groupType = 'P'">
							<xsl:value-of select="leg:TranslateText('Subordinate Legislation Made')"/>
						</xsl:when>
						<xsl:when test="$groupType = 'E'">
							<xsl:value-of select="leg:TranslateText('Extent Information')"/>
						</xsl:when>
						<xsl:when test="$groupType = 'X'">
							<xsl:value-of select="leg:TranslateText('Editorial Information')"/>
						</xsl:when>
					</xsl:choose>
					<xsl:if test="$isHighLevel">
						<xsl:text> </xsl:text>
						<xsl:value-of select="leg:TranslateText('applied to the whole legislation')"/>
					</xsl:if>								
				</p>
			</xsl:if>  
			<xsl:apply-templates select="current-group()" mode="DisplayAnnotations">
				<xsl:sort select="tso:commentaryNumber(@id)" />
				<xsl:with-param name="versionRef" select="$versionRef"/>
			</xsl:apply-templates>
		</xsl:for-each-group>
		
	</xsl:template>
	
	<xsl:function name="tso:commentaryNumber" as="xs:integer">
		<xsl:param name="commentary" as="xs:string" />
		<xsl:sequence select="count($g_commentaryOrder/leg:commentary[@id = $commentary][1]/preceding-sibling::*)" />
	</xsl:function>

</xsl:stylesheet>
