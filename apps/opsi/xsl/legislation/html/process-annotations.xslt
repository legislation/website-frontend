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

	<xsl:template match="leg:Primary | leg:Secondary | leg:Body | leg:Schedules | leg:SignedSection | leg:ExplanatoryNotes | leg:P1group | leg:Title | leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:P1 | leg:P |leg:PrimaryPrelims | leg:SecondaryPrelims | leg:Schedule | leg:Form | leg:Schedule/leg:ScheduleBody//leg:Tabular " mode="ProcessAnnotations">
		<xsl:param name="showSection" as="element()*" tunnel="yes" select="()" />
		<xsl:param name="showingHigherLevel" as="xs:boolean" tunnel="yes" select="false()"/>
		<xsl:param name="includeTooltip" as="xs:boolean" tunnel="yes" select="false()"/>

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
				<xsl:when test="self::leg:Part[not(ancestor::leg:BlockAmendment)] | self::leg:Chapter[not(ancestor::leg:BlockAmendment)] | self::leg:Pblock[not(ancestor::leg:BlockAmendment)]">
					<xsl:sequence select="(leg:Number | leg:Title)/descendant::leg:CommentaryRef" />
				</xsl:when>
				<xsl:when test="self::leg:P1group[not(ancestor::leg:BlockAmendment)] | self::leg:P1[not(parent::leg:P1group)][not(ancestor::leg:BlockAmendment)][not(ancestor::leg:Tabular)] | self::leg:PrimaryPrelims | self::leg:SecondaryPrelims | self::leg:Tabular[not(parent::leg:P1)][not(parent::leg:P)]">
					<xsl:sequence select="descendant::leg:CommentaryRef"/>
				</xsl:when>
				<xsl:when test="self::leg:P and (@id or parent::*[@id] or parent::leg:Body or parent::leg:Schedules or parent::leg:ScheduleBody)">			
					<xsl:sequence select="descendant::leg:CommentaryRef"/>
				</xsl:when>
				<xsl:when test="self::leg:Tabular[not(parent::leg:P1)][not(parent::leg:P)] and (parent::*[@id] or parent::leg:Body )">
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
				<xsl:when test="self::leg:Part[not(ancestor::leg:BlockAmendment)] | self::leg:Chapter[not(ancestor::leg:BlockAmendment)] | self::leg:Pblock[not(ancestor::leg:BlockAmendment)]">
					<xsl:sequence select="(leg:Number | leg:Title)/(descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution)" />
				</xsl:when>
				<!-- for prelims we need to take all descendent amendments -->
				<xsl:when test="self::leg:PrimaryPrelims | self::leg:SecondaryPrelims">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>	
				<xsl:when test="self::leg:P1group[not(ancestor::leg:BlockAmendment)] | self::leg:P1[not(parent::leg:P1group)][not(ancestor::leg:BlockAmendment)][not(ancestor::leg:Tabular)]">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>
				<xsl:when test="self::leg:Title[parent::leg:Part or parent::leg:Chapter][not(ancestor::leg:BlockAmendment)]">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>
				<xsl:when test="self::leg:Title[parent::leg:P1group or parent::leg:P1]">
					<!-- all other title commentaries handled at end of the provision  -->
				</xsl:when>
				<xsl:when test="self::leg:P and (@id or parent::*[@id] or parent::leg:Body or parent::leg:Schedules or parent::leg:ScheduleBody)">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution"/>
				</xsl:when>
				<xsl:when test="self::leg:Tabular[not(parent::leg:P1)][not(parent::leg:P)] and (parent::*[@id] or parent::leg:Body or parent::leg:Schedules or parent::leg:ScheduleBody)">
					<xsl:sequence select="descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="leg:Addition | leg:Repeal | leg:Substitution | (leg:Number | leg:Title[ancestor:: leg:Secondary/leg:Schedules/leg:Schedule/leg:ScheduleBody/leg:Pblock] | leg:Reference | leg:TitleBlock)/(descendant::leg:Addition | descendant::leg:Repeal | descendant::leg:Substitution)"/>
				</xsl:otherwise>	
			</xsl:choose>			
		</xsl:variable>

		<xsl:variable name="commentaryItem" select="key('commentary', ($commentaryRefs/@Ref, $additionRepealRefs/@CommentaryRef))" as="element(leg:Commentary)*"/>
		<xsl:variable name="currentURI">
			<xsl:choose>
				<xsl:when test="@DocumentURI">
					<xsl:value-of select="@DocumentURI"/>
				</xsl:when>
				<xsl:when test="self::leg:Body">
					<xsl:value-of select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/body']/@href" />
				</xsl:when>
				<xsl:when test="self::leg:Schedules">
					<xsl:value-of select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/schedules']/@href" />
				</xsl:when>
				<xsl:when test="parent::leg:SignedSection">
					<xsl:value-of select="/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/signature']/@href" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="descendant::*[@DocumentURI][1]/@DocumentURI"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="isDead" as="xs:boolean" select="@Status = 'Dead'" />
		<xsl:variable name="isValidFrom" as="xs:boolean" select="@Match = 'false' and @RestrictStartDate and ((($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; current-date() ))" />
		<xsl:variable name="isRepealed" as="xs:boolean" select="@Match = 'false' and (not(@Status) or @Status != 'Prospective') and not($isValidFrom)"/>

		<!-- when we have change annotations for insertion/addition/sub that spans multiple provisions but is not part of a whole part/schedule/chapter change then each provision will need to be annotated when viewed from a higher level
	- see ukpga/2003/42/schedule/3 for example-->
		<xsl:variable name="multiple-provision-annotations" as="xs:boolean" 
		select="if (
			((local-name() = 'P1' and not(parent::leg:P1group) and not(ancestor::leg:BlockAmendment) and
				(some $c in preceding-sibling::*[1][self::leg:P1]//(descendant::leg:CommentaryRef/@Ref | descendant::leg:Repeal/@CommentaryRef | descendant::leg:Substitution/@CommentaryRef | descendant::leg:Addition/@CommentaryRef) satisfies $c = ($additionRepealRefs/@CommentaryRef,$commentaryRefs/@Ref))
			) or 
			(:  allowance for EPP blanket amendments - use peceding for allowance across high level boundaries :)
			(local-name() = 'P1group' and not(ancestor::leg:BlockAmendment) and 
				(some $c in preceding::*[self::leg:P1group]//(descendant::leg:CommentaryRef[starts-with(@Ref, 'key-')]/@Ref | descendant::leg:Repeal[starts-with(@ChangeId, 'key-')]/@CommentaryRef | descendant::leg:Substitution[starts-with(@ChangeId, 'key-')]/@CommentaryRef | descendant::leg:Addition[starts-with(@ChangeId, 'key-')]/@CommentaryRef) satisfies $c = ($additionRepealRefs/@CommentaryRef,$commentaryRefs/@Ref))
			) or 
			(local-name() = 'P1group' and not(ancestor::leg:BlockAmendment) and 
				(some $c in preceding-sibling::*[1][self::leg:P1group]//(descendant::leg:CommentaryRef/@Ref | descendant::leg:Repeal/@CommentaryRef | descendant::leg:Substitution/@CommentaryRef | descendant::leg:Addition/@CommentaryRef) satisfies $c  = ($additionRepealRefs/@CommentaryRef,$commentaryRefs/@Ref))
			)) and 
			not(ancestor::*[self::leg:Schedule or self::leg:Part or self::leg:Chapter or self::leg:Pblock or self::leg:Group]/(leg:TitleBlock | leg:Title | leg:Number)/(descendant::leg:CommentaryRef | descendant::leg:Repeal/@CommentaryRef | descendant::leg:Substitution/@CommentaryRef | descendant::leg:Addition/@CommentaryRef) = $additionRepealRefs/@CommentaryRef)
		) then true() else false()"/>


<xsl:message><xsl:value-of select="(self::*/@id, descendant::*[@id]/@id)[1]"/>:<xsl:value-of select="$multiple-provision-annotations"/>:<xsl:value-of select="local-name() = 'P1group' and not(ancestor::leg:BlockAmendment) and 
				(some $c in preceding-sibling::*[self::leg:P1group]//descendant::leg:CommentaryRef/@Ref satisfies $c= ($commentaryRefs/@Ref))"/></xsl:message>


		<xsl:variable name="showComments" as="element(leg:Commentary)*">
			<xsl:variable name="localname" select="local-name()"/>
			<xsl:for-each select="$commentaryItem">
				<xsl:if test="$showingHigherLevel or not($isRepealed) or ($isRepealed and contains(., 'temp.')) or $isDead">
					<xsl:choose>
						<!-- For higher level views we need to annotate all provisions that have a common change -->
						<xsl:when test="$multiple-provision-annotations">
							<xsl:if test="key('commentaryRef', @id, $showSection) intersect ($commentaryRefs | $additionRepealRefs)">
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

		<xsl:variable name="higherLevelComments">
			<xsl:if test="$dcIdentifier = $currentURI and $isRepealed">
				<!-- if the current section is repealed then get the commenteries of all the higher levels-->
				<xsl:apply-templates select="ancestor::*" mode="ProcessAnnotations">
					<xsl:with-param name="showingHigherLevel" select="true()" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:if>	
		</xsl:variable>
		<!-- debugging
	<xsl:message>||<xsl:value-of select="local-name()"/>||<xsl:value-of select="count($higherLevelComments)"/>|||<xsl:value-of select="@id"/>||<xsl:sequence select="$multiple-provision-annotations"/></xsl:message>-->
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
										<p>
											<xsl:value-of select="leg:TranslateText('Annotation_text')"/>
										</p>
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
									<xsl:when test="$groupType = 'I'">
										<xsl:value-of select="leg:TranslateText('Commencement Information')"/>
									</xsl:when>
									<xsl:when test="$groupType = 'F'">
										<xsl:value-of select="leg:TranslateText('Amendments (Textual)')"/>
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
	
	<xsl:function name="tso:commentaryNumber" as="xs:integer">
		<xsl:param name="commentary" as="xs:string" />
		<xsl:sequence select="count($g_commentaryOrder/leg:commentary[@id = $commentary][1]/preceding-sibling::*)" />
	</xsl:function>

</xsl:stylesheet>
