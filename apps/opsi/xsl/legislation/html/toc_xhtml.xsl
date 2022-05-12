<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Table of Contents/Content page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 17/02/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="2.0"
				xmlns:xhtml="http://www.w3.org/1999/xhtml"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
				xmlns:dc="http://purl.org/dc/elements/1.1/"
				xmlns:db="http://docbook.org/ns/docbook"
				xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
				xmlns:dct="http://purl.org/dc/terms/"
				xmlns:atom="http://www.w3.org/2005/Atom"
				xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
				xmlns:xforms="http://www.w3.org/2002/xforms"
				xmlns:ev="http://www.w3.org/2001/xml-events"
>

	<!-- ========== Standard code for outputing UI wireframes========= -->

	<xsl:import href="statuswarning.xsl"/>
	<xsl:import href="legislation_xhtml_consolidation.xslt"/>
	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="uicommon.xsl"/>
	<xsl:import href="timeline_xhtml.xsl"/>
	<xsl:output indent="yes" method="xhtml"/>
	<!-- @TEMP Always show alternative title for #162755738 -->
	<!-- <xsl:variable name="dcalternative" select="'Alternative Title'"/> -->
	<!-- end TEMP -->
	<xsl:variable name="isEULeg" as="xs:boolean" select="$g_isEUretained" />

	<xsl:variable name="nstSection" as="element()?"
				  select="if ($nstSelectedSection/parent::leg:P1group) then $nstSelectedSection/.. else $nstSelectedSection"/>


	<xsl:variable name="language" select="if (/leg:Legislation/@xml:lang) then
			/leg:Legislation/@xml:lang
		else 'en'"/>

	<xsl:variable name="prospDoc" as="xs:string?"
				  select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'prospective']/@href"/>

		
	<xsl:variable name="tocURI" as="xs:string?" select="
		if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='cy'] and $language = 'cy') then
			/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='cy']/@href
		else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='en']) then
			/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='en']/@href
		else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents']) then
			/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][1]/@href
		else /leg:Legislation/@DocumentURI
	"/>
	<xsl:variable name="resourceURI" as="xs:string"
				  select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/resources']/@href"/>

	<xsl:variable name="impactURI" as="xs:string?"
				  select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/impacts']/@href"/>

	<xsl:variable name="legislationIdURI" select="/leg:Legislation/@IdURI"/>

	<xsl:variable name="enURI" as="xs:string?"
				  select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/notes/toc' and not(@hreflang = 'cy')]/@href |
		        /leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/executive-note/toc']/@href"/>
	<xsl:variable name="emURI" as="xs:string?"
				  select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/memorandum/toc' and not(@hreflang = 'cy')]/@href"/>


	<xsl:variable name="pnURI" as="xs:string?"
				  select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/policy-note/toc']/@href"/>

	<xsl:variable name="IsEnAvailable" as="xs:boolean" select="exists($enURI)"/>
	<xsl:variable name="IsEmAvailable" as="xs:boolean" select="exists($emURI)"/>
	<xsl:variable name="IsPnAvailable" as="xs:boolean" select="exists($pnURI)"/>

	<xsl:variable name="IsMoreResourcesAvailable" as="xs:boolean" select="tso:ShowMoreResources(/)"/>
	<xsl:variable name="IsImpactAssessmentsAvailable" as="xs:boolean" select="exists($impactURI)"/>


	<xsl:variable name="IsPDFOnly" as="xs:boolean">
		<xsl:sequence select="leg:IsPDFOnly(.)"/>
	</xsl:variable>

	<xsl:variable name="IsRevisedPDFOnly" as="xs:boolean">
		<xsl:sequence select="leg:IsRevisedPDFOnly(.)"/>
	</xsl:variable>

	<xsl:variable name="paragraphThreshold" select="200"/>

	<!--  let $showTimeline be true if the timeline parameter is 'true', otherwise false  -->
	<xsl:param name="paramTimeline" as="xs:string" select="'true'"/>
	<xsl:variable name="showTimeline" as="xs:boolean"
				  select="contains(leg:get-query('timeline'), 'true') or $paramTimeline = 'true'"/>
	<xsl:variable name="hideTimeline" as="xs:boolean"
				  select="contains(leg:get-query('timeline'), 'false') or $paramTimeline = 'false'"/>

	<xsl:param name="paramShowRepeals" as="xs:string" select="'false'"/>
	<xsl:variable name="showRepeals" as="xs:boolean"
				  select="contains(leg:get-query('repeals'), 'true') or $paramShowRepeals = 'true'"/>

	<xsl:variable name="whatVersionScenario" as="xs:string">
		<xsl:call-template name="TSOGetScenarios">
			<xsl:with-param name="type" select="'whatversion'"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="showInterweaveOption" as="xs:boolean"
				  select="
				tso:ENInterweavedAllowed(leg:GetDocumentMainType(.))  and
				($IsEnAvailable or $IsEmAvailable) and
				(if ($whatVersionScenario = ('B','D') or ($whatVersionScenario = 'A' and leg:IsCurrentOriginal(.) )) then true() else false())"/>

	<xsl:variable name="showInterweave" as="xs:boolean"
				  select="$showInterweaveOption and contains(leg:get-query('view'), 'interweave')"/>

	<xsl:variable name="forceShowExtent" as="xs:boolean"
				  select="(exists($nstSection[@AltVersionRefs]) and $nstSection/(self::leg:P1group or self::leg:P1)) or $searchingByExtent"/>
	<xsl:variable name="showExtent" as="xs:boolean"
				  select="$forceShowExtent or contains(leg:get-query('view'), 'extent')"/>

	<xsl:variable name="correctionSlipTitle" as="xs:string"
				  select="if ($g_strDocumentType = $g_strEUretained) then 'Corrigendum' else 'Correction Slip'"/>

	<xsl:variable name="isLarge" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$g_strwholeActURI = $dcIdentifier and /leg:Legislation/@NumberOfProvisions &gt; 800">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="$nstSection/@NumberOfProvisions &gt; 800">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:function name="tso:IncludeInlineTooltip" as="xs:boolean">
		<xsl:sequence select="not($isLarge)"/>
	</xsl:function>

	<!--  let $selectedSection be the (XML element of the) section that's being looked at, which you already get hold of  -->
	<xsl:variable name="selectedSection" as="element()?"
				  select="
			if ($g_strwholeActURI = $dcIdentifier) then /leg:Legislation
			else if ($dcIdentifier = ($g_strIntroductionUri, $g_strsignatureURI,  $g_strEarlierOrdersURI, $g_strENURI, $g_wholeActWithoutSchedulesURI)) then  /leg:Legislation/(leg:Primary | leg:Secondary | leg:EURetained)//*[@DocumentURI = $strCurrentURIs]
			else if ($dcIdentifier = $g_schedulesOnlyURI)  then /leg:Legislation/(leg:Primary | leg:Secondary | leg:EURetained)/leg:Schedules
			else $nstSection"/>

	<!--  let $startDate be the latest value of RestrictStartDate on $selectedSection or any of its descendants -->
	<xsl:variable name="restrictStartDate"
				  select="max(($selectedSection/descendant-or-self::*[not(@Match = 'false')]/@RestrictStartDate/xs:date(.), key('g_keyNodeIDs', tokenize($selectedSection/@AltVersionRefs, ' '))/*/descendant-or-self::*[not(@Match = 'false')]/@RestrictStartDate/xs:date(.)) )"/>
	<!-- if there's no valid start date (on a section without @Match = 'false') then look at the RestrictStartDate attribute of the section that's actually been requested	 -->
	<xsl:variable name="startDate"
				  select="if (empty($restrictStartDate)) then $selectedSection/@RestrictStartDate/xs:date(.) else $restrictStartDate"/>

	<!--  let $dead be true if the $selectedSection is Dead -->
	<xsl:variable name="dead" as="xs:boolean" select="$selectedSection/@Status = 'Dead'"/>
	<!--  let $endDate be the earliest value of the RestrictEndDate on $selectedSection or any of its descendants -->
	<xsl:variable name="endDate"
				  select="if ($dead) then
							$selectedSection/@RestrictEndDate
		        else
		          string(min(($selectedSection/descendant-or-self::*[not(@Match = 'false')]/@RestrictEndDate/xs:date(.),  key('g_keyNodeIDs', tokenize($selectedSection/@AltVersionRefs, ' '))/*/descendant-or-self::*[not(@Match = 'false')]/@RestrictEndDate/xs:date(.))))"/>
	<!--  let $prospective be true if the Status attribute on $selectedSection is 'Prospective' or 'Dead' and $selectedSection has not RestrictStartDate-->
	<xsl:variable name="prospective" as="xs:boolean"
				  select="$dead or (not($selectedSection/@RestrictStartDate) and $selectedSection/@Status = 'Prospective') or ($selectedSection//*[not(@Match = 'false') and not(@RestrictStartDate) and @Status = 'Prospective'])"/>
	<!--  let $repealed be true if the Match attribute on $selectedSection is false and either the $version is 'prospective' and there is an $endDate or the $endDate is before or equal to $version -->
	<xsl:variable name="repealed" as="xs:boolean"
				  select="$dead or (($endDate castable as xs:date) and $selectedSection/@Match = 'false' and ( $version = 'prospective' or  xs:date($endDate) &lt;= leg:GetVersionDate($version)))"/>
	<!--  let $notYetInForce be true if the Match attribute on $selectedSection is false and the $startDate is after $version  -->
	<xsl:variable name="notYetInForce" as="xs:boolean"
				  select="($startDate castable as xs:date) and $selectedSection/@Match = 'false' and xs:date($startDate) &gt; leg:GetVersionDate($version) "/>

	<!--  flag for arranging the pointers equally -->
	<xsl:variable name="arrangePointersEqually" as="xs:boolean" select="true()"/>

	<!-- getting the document type -->
	<xsl:function name="leg:GetDocumentMainType" as="xs:string">
		<xsl:param name="legislation" as="document-node()"/>
		<xsl:sequence select="$g_strDocumentMainType"/>
	</xsl:function>

	<!-- uri Prefix-->
	<xsl:variable name="uriPrefix" as="xs:string">
		<xsl:value-of
				select="tso:GetUriPrefixFromType(leg:GetDocumentMainType(.), /leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:BillMetadata)/ukm:Year/@Value)"/>
	</xsl:variable>
	<xsl:variable name="documentMainType" as="xs:string" select="leg:GetDocumentMainType(.)"/>

	<!-- Construct a list of the ContentRefs of the items that have MatchText="true" up front -->
	<xsl:variable name="searchingByText" as="xs:string?" select="$paramsDoc/parameters/text[. != '']"/>
	<xsl:variable name="searchingByExtent" as="xs:string?"
				  select="($paramsDoc/parameters/extent[. != ''], $paramsDoc/parameters/extent-query[. != ''])[1]"/>
	<xsl:variable name="matchTextEntries" as="xs:string*"
				  select="tokenize(/leg:Legislation/leg:Contents/@MatchTextEntries, ' ')"/>
	<xsl:variable name="matchExtentEntries" as="xs:string*"
				  select="tokenize(/leg:Legislation/leg:Contents/@MatchExtentEntries, ' ')"/>
	<xsl:variable name="matchEntries" as="xs:string*"
				  select="distinct-values(($matchTextEntries, $matchExtentEntries))"/>
	<xsl:variable name="matchRefs"
				  select="if ($searchingByText and $searchingByExtent) then (
							if ($matchTextEntries = 'introduction' and $matchExtentEntries = 'introduction') then 'introduction' else (),
							//leg:ContentsItem[@MatchText = 'true' and @MatchExtent = 'true']/@ContentRef,
							for $entry in ('signature', 'note', 'earlier-orders')[$matchTextEntries = . and $matchExtentEntries = .]
							return
								$entry
						) else if ($searchingByText or $searchingByExtent) then
							($matchEntries[. = 'introduction'], //leg:Contents//*[@MatchText = 'true' or @MatchExtent = 'true']/@ContentRef, $matchEntries[. != 'introduction'])
						else
							()"/>
	<xsl:variable name="linkFragment" as="xs:string?"
				  select="if ($searchingByExtent or $searchingByText) then
		          concat('#', encode-for-uri(string-join((
		            if ($searchingByText) then concat('text=', $searchingByText) else (),
		            if ($searchingByExtent) then concat('extent=', $searchingByExtent) else ()
		          ), '&amp;')))
		        else
		          ()"/>


	<xsl:variable name="isDraft" as="xs:boolean" select="leg:IsDraft(.)"/>

	<xsl:variable name="isBill" as="xs:boolean" select="leg:IsBill(.)"/>

	<xsl:variable name="scheduleText">
		<xsl:value-of select="if ($g_strDocumentType = $g_strEUretained) then 'Annex' else 'Schedule'"/>
	</xsl:variable>

	<xsl:variable name="schedulesText">
		<xsl:value-of select="if ($g_strDocumentType = $g_strEUretained) then 'Annexes' else 'Schedules'"/>
	</xsl:variable>

	<xsl:variable name="attachmentsText">
		<xsl:value-of select="'Attachments'"/>
	</xsl:variable>

	<xsl:variable name="title">
		<xsl:choose>
			<xsl:when test="$language = 'cy' and count($dctitle) &gt; 1">
				<xsl:value-of select="$dctitle[@xml:lang='cy']"/>
			</xsl:when>
			<xsl:when test="$language = 'cy' and count($dctitle) = 1 ">
				<xsl:value-of select="$dctitle"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$dctitle[not(@xml:lang='cy')]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:choose>
						<xsl:when test="$language = 'cy'">
							<xsl:value-of select="$dctitle[@xml:lang='cy']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$dctitle[not(@xml:lang='cy')]"/>
						</xsl:otherwise>
					</xsl:choose>
				</title>
				<!--<meta name="DC.Date.Modified" content="{/leg:Legislation/ukm:Metadata/dc:modified}" />-->
				<xsl:apply-templates select="/leg:Legislation/ukm:Metadata" mode="HTMLmetadata"/>

				<xsl:call-template name="TSOOutputAddLegislationStyles"/>

				<xsl:if test="$showTimeline">
					<link rel="stylesheet" href="/styles/view/changesOverTime.css" type="text/css"/>
					<script type="text/javascript" src="/scripts/jquery-ui-1.8.24.custom.min.js"></script>
					<script type="text/javascript" src="/scripts/view/jquery.ui.slider.min.js"></script>
					<script type="text/javascript" src="/scripts/view/scrollbar.js"></script>
				</xsl:if>

				<xsl:if test="$showInterweave and
						exists(/leg:Legislation/ukm:Metadata/atom:link[@rel=
								('http://www.legislation.gov.uk/def/navigation/notes', 'http://www.legislation.gov.uk/def/navigation/memorandum')])
						">
					<script type="text/javascript" src="/scripts/eniw/eniw_leg.gov.uk.js"></script>
					<link rel="stylesheet" href="/styles/explanatoryNotesInterweave.css" type="text/css"/>
				</xsl:if>

				<!-- commenting out the highlighting
				<xsl:if test="leg:IsContentTabDisplaying()">

					<xsl:comment><![CDATA[[if IE]><script type="text/javascript" src="/scripts/json2.js"></script><![endif]]]></xsl:comment>
					<script type="text/javascript">

						var varType;
						var varUrl;
						var varData;
						var varContentType;
						var varDataType;
						var varProcessData;
						//Generic function to call AXMX/WCF  Service
						function CallService()
						{
								$.ajax({
									type        : varType, //GET or POST or PUT or DELETE verb
									url         : varUrl, // Location of the service
									data        : varData, //Data sent to server
									contentType : varContentType, // content type sent to server
									dataType    : varDataType, //Expected data format from server
									processdata : varProcessData, //True or False
									success     : function(msg) {//On Successfull service call
									ServiceSucceeded(msg);
									},
									error: ServiceFailed// When Service call fails
								});
						}

						function ServiceSucceeded(result) {//When service call is sucessful
							$('#viewLegSnippet').html($(result).find("string").text());
							varType=null;varUrl = null;varData = null;varContentType = null;varDataType = null;varProcessData = null;
						}
						function ServiceFailed(result) {
							//alert('Service call failed: ' + result.status + '' + result.statusText);
							varType = null; varUrl = null; varData = null; varContentType = null; varDataType = null; varProcessData = null;
						}

						function RunHighlight()
						{
							var hash = unescape(window.location.hash);

							if (hash.substring(0,6) == "#text=")
							{
								<xsl:variable name="view" as="xs:string*" select="tokenize(replace(leg:get-query('view'),'view=',''),'\+')"/>
								<xsl:variable name="href"  as="xs:string"
									select="leg:set-query-params('view',
													string-join( ($view, 'hits'), '+') )"/>
								<xsl:variable name="highlightURI" as="xs:string">
									<xsl:value-of select="concat('/highlightdatasnippet.htm', '?', $href)"/>
								</xsl:variable>

								varType = 'POST';
								varUrl = '<xsl:value-of select="$highlightURI"/>' ;
								varData = JSON.stringify({sourceText: $('#viewLegSnippet').html(), searchText: hash.substring(hash.indexOf("text=")+5)});
								varContentType = "application/json; charset=utf-8";
								varDataType = "xml";
								varProcessData = true;
								CallService();
							}
						}
					</script>
				</xsl:if>-->
			</head>
			<body xml:lang="en" lang="en" dir="ltr" id="leg" about="{$dcIdentifier}"
				  class="{concat('browse', if ($showExtent) then ' geoExtShowing' else '', if ($pointInTimeView and $version != 'prospective') then ' pointInTimeView' else '', if ($repealed) then ' hideChangestoLegislation' else '', if ($isLarge) then ' removeScripting' else '')}">
				<!-- commenting out the highlighting
					<xsl:if test="leg:IsContentTabDisplaying()">
						<xsl:attribute name="onload">RunHighlight();</xsl:attribute>
					</xsl:if>
				 -->

				<div id="layout2">
					<xsl:choose>
						<xsl:when test="leg:IsTOC()">
							<xsl:attribute name="class">legToc</xsl:attribute>
						</xsl:when>
						<xsl:when test="$IsPDFOnly">
							<xsl:attribute name="class">legToc</xsl:attribute>
						</xsl:when>

						<xsl:when test="$dcIdentifier = ($g_strsignatureURI, $g_strENURI, $g_strEarlierOrdersURI)">
							<xsl:attribute name="class">legContent</xsl:attribute>
						</xsl:when>
						<xsl:when test="leg:IsContent()">
							<xsl:attribute name="class">legContent</xsl:attribute>
						</xsl:when>
						<xsl:when
								test="$dcIdentifier = ($g_strwholeActURI, $g_wholeActWithoutSchedulesURI, $g_schedulesOnlyURI, $g_attachmentsOnlyURI) or matches($dcIdentifier, '[0-9]+/(ni|england|scotland|wales|eu)')">
							<xsl:attribute name="class">legComplete</xsl:attribute>
						</xsl:when>
						<xsl:otherwise/>
					</xsl:choose>

					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>

					<!-- adding the title of the legislation-->
					<xsl:call-template name="TSOOutputLegislationTitle"/>

					<!-- breadcrumb -->
					<xsl:call-template name="TSOOutputBreadcrumbItems"/>

					<!-- Sub Navigation tabs-->
					<xsl:call-template name="TSOOutputSubNavTabs"/>

					<div class="interface">

						<!-- adding the links for previous and next links-->
						<xsl:call-template name="TSOOutputPreviousNextLinks"/>

						<!-- adding the links for view print links-->
						<xsl:call-template name="TSOOutputViewPrintLinks"/>

					</div>
					<!--./interface -->
					<div id="tools">
						<!-- what version functionality-->
						<xsl:call-template name="TSOOutputWhatVersionScenario"/>

						<!-- advanced search-->
						<xsl:call-template name="TSOOutputAdvancedSearch"/>

						<!-- opening options functionality-->
						<xsl:call-template name="TSOOutputOpeningOptions"/>

						<!-- what version functionality
						<xsl:call-template name="TSOOutputMoreResources"/>-->

						<!-- PDF Versions -->
						<xsl:call-template name="TSOOutputPDFVersions"/>

						<!-- UK Regulation originating from the EU-->
						<xsl:call-template name="TSOOutputEUR"/>
					</div>
					<!--/tools-->

					<div id="content">

						<!-- outputing the legislation status and timeline-->
						<xsl:call-template name="TSOOutputLegislationStatusTimeline"/>

						<!-- outputing the legislation content-->
						<xsl:call-template name="TSOOutputLegislationContent"/>

						<div class="contentFooter">

							<div class="interface">

								<!-- adding the links for previous and next links-->
								<xsl:call-template name="TSOOutputPreviousNextLinks"/>

							</div>

						</div>

						<p class="backToTop">
							<a href="#top">
								<xsl:value-of select="leg:TranslateText('Back to top')"/>
							</a>
						</p>

					</div>
					<!--/content-->

				</div>
				<!--layout2 -->

				<!-- Where all of the Help divs and modal windows are loaded -->
				<h2 class="interfaceOptionsHeader"><xsl:value-of select="leg:TranslateText('Options')"/>/<xsl:value-of
						select="leg:TranslateText('Help')"/>
				</h2>

				<!-- adding the view/print options-->
				<xsl:if test="not($IsPDFOnly)">
					<xsl:call-template name="TSOOutputPrintOptions"/>
				</xsl:if>

				<!-- opening options model -->
				<xsl:call-template name="TSOOutputOpeningOptionsWarning"/>

				<!-- help tips -->
				<xsl:call-template name="TSOOutputHelpTips"/>

			</body>
		</html>

	</xsl:template>


	<!-- ========== CSS Styles for Legislation =============-->
	<xsl:template name="TSOOutputAddLegislationStyles">
		<style type="text/css">
			<xsl:text>/* Legislation stylesheets - load depending on content type */&#xA;</xsl:text>
			<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when
						test="$uriPrefix ='ukdpb' or $uriPrefix ='ukpga' or  $uriPrefix ='ukla'  or  $uriPrefix ='cukla'  or  $uriPrefix ='ukcm'  ">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/primarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when
						test="$uriPrefix ='apgb' or  $uriPrefix ='aosp'  or  $uriPrefix ='aip'  or  $uriPrefix ='mnia'  or  $uriPrefix ='apni'  or  $uriPrefix ='mwa'  or  $uriPrefix ='anaw'">
					<xsl:text>@import "/styles/SPOprimarylegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/SPOlegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/primarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix ='aep' or  $uriPrefix ='asp' ">
					<xsl:text>@import "/styles/SPOlegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/primarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix ='nia' ">
					<xsl:text>@import "/styles/NIlegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/secondarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when
						test="$uriPrefix = ('uksi', 'ukmd', 'ssi', 'wsi', 'nisr', 'ukci', 'nisi', 'ukmo', 'uksro', 'nisro')">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/secondarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when
						test="$uriPrefix ='ukdsi' or  $uriPrefix ='sdsi'  or  $uriPrefix ='wdsi'  or  $uriPrefix ='nidsr'">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/secondarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix = ('eut', 'eur', 'eudr', 'eudn')  ">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/eulegislation.css";&#xA;</xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:text>@import "/styles/legislationOverwrites.css";&#xA;</xsl:text>
			<xsl:text>/* End of Legislation stylesheets */&#xA;</xsl:text>
		</style>

		<xsl:comment><![CDATA[[if IE 6]>
	<style type="text/css">
		@import "/styles/IE/ie6LegAdditions.css";
	</style>
<![endif]]]></xsl:comment>
		<xsl:comment><![CDATA[[if IE 7]>
	<style type="text/css">
		@import "/styles/IE/ie7LegAdditions.css";
	</style>
<![endif]]]></xsl:comment>
	</xsl:template>


	<!-- ========== Standard code for what version ========= -->
	<!-- outputting the what version box based on the scenarios-->
	<xsl:template name="TSOOutputWhatVersionScenario">
		<!--<xsl:message>
			$whatVersionScenario: <xsl:value-of select="$whatVersionScenario" />
		</xsl:message>-->
		<xsl:choose>
			<xsl:when test="$whatVersionScenario='A' ">
				<xsl:call-template name="TSOOutputWhatVersion">
					<xsl:with-param name="enableRevisedVersion" select="true()"/>
					<xsl:with-param name="selectRevisedVersion" select="leg:IsCurrentRevised(.)"/>
					<xsl:with-param name="enableOriginalVersion" select="true()"/>
					<xsl:with-param name="selectOriginalVersion" select="leg:IsCurrentOriginal(.)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$whatVersionScenario='B' ">
				<xsl:call-template name="TSOOutputWhatVersion">
					<xsl:with-param name="enableRevisedVersion" select="false()"/>
					<xsl:with-param name="selectRevisedVersion" select="false()"/>
					<xsl:with-param name="enableOriginalVersion" select="true()"/>
					<xsl:with-param name="selectOriginalVersion" select="true()"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$whatVersionScenario='C' ">
				<xsl:call-template name="TSOOutputWhatVersion">
					<xsl:with-param name="enableRevisedVersion" select="true()"/>
					<xsl:with-param name="selectRevisedVersion" select="leg:IsCurrentRevised(.)"/>
					<xsl:with-param name="enableOriginalVersion" select="false()"/>
					<xsl:with-param name="selectOriginalVersion" select="false()"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$whatVersionScenario='D' ">
				<xsl:call-template name="TSOOutputWhatVersion">
					<xsl:with-param name="enableRevisedVersion" select="false()"/>
					<xsl:with-param name="selectRevisedVersion" select="false()"/>
					<xsl:with-param name="enableOriginalVersion" select="true()"/>
					<xsl:with-param name="selectOriginalVersion" select="true()"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- outputting the whatversion box with the selected properties-->
	<xsl:template name="TSOOutputWhatVersion">
		<xsl:param name="enableRevisedVersion" as="xs:boolean"/>
		<xsl:param name="selectRevisedVersion" as="xs:boolean"/>
		<xsl:param name="enableOriginalVersion" as="xs:boolean"/>
		<xsl:param name="selectOriginalVersion" as="xs:boolean"/>
		<div class="section" id="whatVersion">
			<div class="title">
				<a href="#whatversionHelp" class="helpItem helpItemToMidRight">
					<img src="/images/chrome/helpIcon.gif" alt=" Help about what version"/>
				</a>
				<h2>
					<xsl:value-of select="leg:TranslateText('What Version')"/>
				</h2>
			</div>
			<div class="content">
				<ul class="toolList">
					<xsl:choose>
						<xsl:when test="leg:IsDraft(.) and leg:IsBill(.)">
							<li>
								<span class="userFunctionalElement active">
									<span class="background">
										<span class="btl"/>
										<span class="btr"/>
										<xsl:value-of select="leg:TranslateText('Draft bill')"/>
										<span class="bbl"/>
										<span class="bbr"/>

									</span>
								</span>
							</li>
						</xsl:when>
						<xsl:when test="leg:IsDraft(.)">
							<li>
								<span class="userFunctionalElement active">
									<span class="background">
										<span class="btl"/>
										<span class="btr"/>
										<xsl:value-of select="leg:TranslateText('Draft legislation')"/>
										<span class="bbl"/>
										<span class="bbr"/>
									</span>
								</span>
							</li>
						</xsl:when>
						<xsl:otherwise>
							<li>
								<xsl:variable name="ndsLatestAvailable">
									<span class="background">
										<span class="btl"/>
										<span class="btr"/>
										<xsl:value-of select="leg:TranslateText('Latest available (Revised)')"/>
										<span class="bbl"/>
										<span class="bbr"/>
									</span>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="$enableRevisedVersion">
										<xsl:choose>
											<xsl:when test="$selectRevisedVersion and not($pointInTimeView)">
												<span class="userFunctionalElement active">
													<xsl:copy-of select="$ndsLatestAvailable"/>
												</span>
											</xsl:when>
											<xsl:otherwise>
												<a href="{leg:FormatURL(//atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title='current']/@href)}"
												   class="userFunctionalElement">
													<xsl:copy-of select="$ndsLatestAvailable"/>
												</a>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<span class="userFunctionalElement disabled">
											<xsl:copy-of select="$ndsLatestAvailable"/>
										</span>
									</xsl:otherwise>
								</xsl:choose>
							</li>
							<xsl:choose>
								<xsl:when test="$pointInTimeView">
									<li>
										<span class="userFunctionalElement active">
											<span class="background">
												<span class="btl"/>
												<span class="btr"/>
												<xsl:choose>
													<xsl:when test="$version castable as xs:date">
														<xsl:value-of select="leg:TranslateText('Point in Time')"/>
														(<xsl:value-of select="leg:FormatDate($version)"/>)
													</xsl:when>
													<xsl:when test="$version ='prospective' ">
														<xsl:value-of
																select="leg:TranslateText('Latest with prospective')"/>
													</xsl:when>
												</xsl:choose>
												<span class="bbl"/>
												<span class="bbr"/>
											</span>
										</span>
									</li>
								</xsl:when>
							</xsl:choose>
							<li>
								<xsl:variable name="ndsOriginal">
									<span class="background">
										<span class="btl"/>
										<span class="btr"/>
										<xsl:variable name="textoiginal">
											<xsl:text>Original (As </xsl:text>
											<xsl:value-of select="leg:GetCodeSchemaStatus(.)"/>
											<xsl:text>)</xsl:text>
											<xsl:if test="leg:IsWelshExists(.)">
												<xsl:text> - English</xsl:text>
											</xsl:if>
										</xsl:variable>
										<xsl:value-of select="leg:TranslateText($textoiginal)"/>
										<span class="bbl"/>
										<span class="bbr"/>
									</span>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="$enableOriginalVersion = true()">
										<xsl:choose>
											<xsl:when test="$selectOriginalVersion = true() and not($pointInTimeView)">
												<xsl:choose>
													<xsl:when test="not(leg:IsCurrentWelsh(.))">
														<span class="userFunctionalElement active">
															<xsl:copy-of select="$ndsOriginal"/>
														</span>
													</xsl:when>
													<xsl:when
															test="empty(//atom:link[@rel='alternate' and @hreflang='en'])">
														<!-- there is no corrosponding english version of the provision  -->
													</xsl:when>
													<xsl:otherwise>
														<a href="{leg:FormatURL(//atom:link[@rel='alternate' and @hreflang='en']/@href)}"
														   class="userFunctionalElement">
															<xsl:copy-of select="$ndsOriginal"/>
														</a>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:variable name="enactedLink" as="element(atom:link)?"
															  select="//atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = ('enacted', 'made', 'created', 'adopted') and (not(@hreflang) or @hreflang='en')]"/>
												<!-- this changes the link if we're looking a PDF-only revised version to go to the as-enacted ToC -->
												<xsl:variable name="enactedLink" as="xs:string?"
															  select="if ($IsPDFOnly and not(contains($enactedLink/@href,'/contents/'))) then
													          replace($enactedLink/@href, concat('/', $enactedLink/@title), concat('/contents/', $enactedLink/@title))
													        else
													        	$enactedLink/@href"/>
												<a href="{leg:FormatURL($enactedLink)}" class="userFunctionalElement">
													<xsl:copy-of select="$ndsOriginal"/>
												</a>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<span class="userFunctionalElement disabled">
											<xsl:copy-of select="$ndsOriginal"/>
										</span>
									</xsl:otherwise>
								</xsl:choose>
							</li>

							<xsl:if test="leg:IsWelshExists(.)">
								<li>
									<xsl:variable name="ndsOriginal">
										<span class="background">
											<span class="btl"/>
											<span class="btr"/>
											<xsl:variable name="textoriginal">
												<xsl:text>Original (As </xsl:text>
												<xsl:value-of select="leg:GetCodeSchemaStatus(.)"/>
												<xsl:text>) - Welsh</xsl:text>
											</xsl:variable>
											<xsl:value-of select="leg:TranslateText($textoriginal)"/>
											<span class="bbl"/>
											<span class="bbr"/>
										</span>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="$enableOriginalVersion = true()">
											<xsl:choose>
												<xsl:when
														test="$selectOriginalVersion = true() and not($pointInTimeView)">
													<xsl:choose>
														<xsl:when test="leg:IsCurrentWelsh(.)">
															<span class="userFunctionalElement active">
																<xsl:copy-of select="$ndsOriginal"/>
															</span>
														</xsl:when>
														<xsl:when
																test="empty(//atom:link[@rel='alternate' and @hreflang='cy'])">
															<!-- there is no corrosponding english version of the provision  -->
														</xsl:when>
														<xsl:otherwise>
															<a href="{leg:FormatURL(//atom:link[@rel='alternate' and @hreflang='cy']/@href)}"
															   class="userFunctionalElement">
																<xsl:copy-of select="$ndsOriginal"/>
															</a>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													<a href="{leg:FormatURL(//atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = ('enacted', 'made', 'created', 'adopted') and @hreflang='cy']/@href)}"
													   class="userFunctionalElement">
														<xsl:copy-of select="$ndsOriginal"/>
													</a>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<span class="userFunctionalElement disabled">
												<xsl:copy-of select="$ndsOriginal"/>
											</span>
										</xsl:otherwise>
									</xsl:choose>
								</li>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="leg:IsProposedVersion(.)">
									<li>
										<span class="userFunctionalElement active">
											<span class="background">
												<span class="btl"/>
												<span class="btr"/>
												<xsl:value-of select="leg:TranslateText('Proposed legislation')"/>
												<span class="bbl"/>
												<span class="bbr"/>
											</span>
										</span>
									</li>
								</xsl:when>
								<!--
									If $pointInTimeView is true then add a button that says "Point in Time (DD/MM/YYYY)" if the $version is castable to xs:date or "Point in Time Prospective" if the $version is 'prospective'.
								-->

							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
		</div>
	</xsl:template>

	<!-- outputting the whatversion box with the selected properties-->
	<xsl:template name="TSOOutputMoreResources">
		<xsl:if test="exists(/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative) or exists(/leg:Legislation/ukm:Metadata/ukm:CorrectionSlips/ukm:CorrectionSlip)">
			<div class="section" id="moreResources">
				<div class="title">
					<a href="#moreResourcesHelp" class="helpItem helpItemToMidRight">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about more resources"/>
					</a>
					<h2>
						<xsl:value-of select="leg:TranslateText('More Resources')"/>
					</h2>
				</div>
				<div class="content">
					<ul class="toolList">
						<xsl:variable name="status" select="leg:GetCodeSchemaStatus(/)"/>

						<xsl:for-each select="/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative">
							<xsl:sort select="@Title = 'Print Version' and not(@Revised)" order="descending"/>
							<xsl:sort select="xs:date(@Revised)" order="descending"/>
							<xsl:sort select="@Title"/>
							<!-- put English first -->
							<xsl:sort select="exists(@Language)"/>
							<xsl:sort select="@Language = 'English'" order="descending"/>
							<!-- put Mixed language last -->
							<xsl:sort select="@Language = 'Mixed'"/>
							<xsl:variable name="strLanguageSuffix">
								<xsl:if test="(not(@Title) and count(../ukm:Alternative[not(@Title)]) > 1) or
									(if (@Title = ('', 'Print Version', 'Mixed Language Measure')) then
										count(../ukm:Alternative[@Title = ('', 'Print Version', 'Mixed Language Measure')]) > 1
									else
										count(../ukm:Alternative[@Title = current()/@Title]) > 1)">
									<xsl:choose>
										<xsl:when test="@Language = 'Mixed'"> - Mixed Language</xsl:when>
										<xsl:when test="exists(@Language)">
											<xsl:text> - </xsl:text>
											<xsl:value-of select="concat(@Language, ' Language') "/>
										</xsl:when>
										<xsl:when test="matches(@URI, '_en(_[0-9]{3})?.pdf$')"> - English Language
										</xsl:when>
										<xsl:when test="matches(@URI, '_we(_[0-9]{3})?.pdf$')"> - Welsh Language
										</xsl:when>
										<xsl:when test="matches(@URI, '_mi(_[0-9]{3})?.pdf$')"> - Mixed Language
										</xsl:when>
									</xsl:choose>
								</xsl:if>
							</xsl:variable>
							<xsl:variable name="title" as="xs:string">
								<xsl:choose>
									<!-- if there is no title then display the download label-->
									<xsl:when test="@Title = '' or not(@Title)">
										<xsl:value-of select="leg:TranslateText(if (@Language = 'Mixed' and string-length($strLanguageSuffix) eq 0)
																				then 'Mixed Language'
																				else $strLanguageSuffix)"/>
									</xsl:when>
									<!-- if the title is print then display the Download label-->
									<xsl:when test="@Title = 'Print Version' or @Title = 'Mixed Language Measure'">
										<xsl:value-of select="leg:TranslateText($strLanguageSuffix)"/>
									</xsl:when>
									<!-- for anything else display the title -->
									<xsl:otherwise>
										<xsl:value-of
												select="concat(leg:TranslateText(@Title), leg:TranslateText($strLanguageSuffix))"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<li>
								<a class="pdfLink" href="{@URI}">
									<xsl:choose>
										<!--added revised version-->
										<xsl:when test="exists(@Revised)">
											<xsl:value-of select="leg:TranslateText('Revised Version')"/>
											<xsl:text> </xsl:text>
											<xsl:value-of
													select="if (@Revised castable as xs:date) then format-date(@Revised,'[D]/[M]/[Y]') else @Revised"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="leg:TranslateText('Original Print PDF')"/>
										</xsl:otherwise>
									</xsl:choose>

									<xsl:if test="string-length($title) ne 0 and not(@Revised)">
										<xsl:choose>
											<xsl:when test="string-length($strLanguageSuffix) ne 0">
												<xsl:value-of select="$title"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat(' - ', $title)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
								</a>
							</li>
						</xsl:for-each>


						<xsl:for-each select="/leg:Legislation/ukm:Metadata/ukm:CorrectionSlips/ukm:CorrectionSlip">
							<li>
								<a class="pdfLink" href="{@URI}">
									<xsl:value-of select="$correctionSlipTitle"/>
									<xsl:text> - </xsl:text>
									<xsl:value-of select="leg:FormatDate(@Date)"/>
								</a>
							</li>
						</xsl:for-each>
					</ul>

					<p class="viewMoreLink">
						<a href="{leg:FormatURL($resourceURI, false())}">
							<xsl:value-of select="leg:TranslateText('View more')"/>
							<span class="pageLinkIcon"></span>
						</a>
					</p>
				</div>
			</div>


		</xsl:if>
	</xsl:template>

	<!-- outputting the pdfversions box -->
	<!-- we restrict the reformatted content to EU instances -->
	<!-- UK items will remain the old format for MVP-1 -->
	<xsl:template name="TSOOutputPDFVersions">
		<div class="section" id="pdfVersions">
			<div class="title">
				<h2>
					<xsl:value-of select="leg:TranslateText('More Resources')"/>
				</h2>
			</div>
			<xsl:choose>
				<xsl:when test="$g_isEURetainedOrEUTreaty">
					<div class="content" id="pdfVersionsContent">
						<ul class="toolList">
							<xsl:for-each select="$g_pdfVersions[not(@Revised)]">
								<xsl:sort select="@Title = 'Print Version'" order="descending" />
								<xsl:sort select="@Title"/>
								<!-- put English first -->
								<xsl:sort select="exists(@Language)" />
								<xsl:sort select="@Language = 'English'" order="descending" />
								<!-- put Mixed language last -->
								<xsl:sort select="@Language = 'Mixed'" />
								<xsl:variable name="strLanguageSuffix" select="leg:pdf-language(.)"/>
								<xsl:variable name="title" as="xs:string">
									<xsl:choose>
										<!-- if there is no title then display the download label-->
										<xsl:when test="@Title = '' or not(@Title)"><xsl:value-of select="$strLanguageSuffix" /></xsl:when>
										<!-- if the title is print then display the Download label-->
										<xsl:when test="@Title = 'Print Version' or @Title = 'Mixed Language Measure'"><xsl:value-of select="$strLanguageSuffix" /></xsl:when>
										<!-- for anything else display the title -->
										<xsl:otherwise><xsl:value-of select="concat(leg:TranslateText(@Title), $strLanguageSuffix)"/></xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<li>
									<a href="{@URI}" class="pdfLink">
										<xsl:value-of select="leg:TranslateText('PDF_Versions_EU_final')"/>
										<xsl:if test="string-length($title) ne 0">
											<span><xsl:value-of select="concat(' ', $title)"/></span>
										</xsl:if>
									</a>
								</li>
							</xsl:for-each>

							<xsl:for-each select="$g_correctionSlips">
								<xsl:sort select="xs:date(@Date)" order="descending" />
								<li>
									<a href="{@URI}" class="pdfLink">
										<xsl:value-of select="leg:TranslateText('PDF_Versions_EU_correction')"/>
										<xsl:text> </xsl:text>
										<xsl:value-of select="format-date(@Date, '[D01]/[M01]/[Y0001]')"/>
									</a>
									<!--<span>
										<xsl:value-of select="format-number((@Size div (1024 * 1024)), '#0.00')"/>
										<xsl:value-of select="' MB'"/>
									</span>-->
								</li>
							</xsl:for-each>
						</ul>
						<xsl:if test="$g_pdfVersions/@Revised">
							<div class="subsection" id="pdfVersionsSub">
								<div class="title">
									<h3>
										<xsl:value-of select="leg:TranslateText('PDF_Versions_EU')"/>
									</h3>
								</div>

								<div class="content" id="pdfVersionsSubContent">
									<ul class="toolList">

										<xsl:for-each select="$g_pdfVersions[@Revised]">
											<xsl:sort select="xs:date(@Revised)" order="descending" />
											<li>
												<a href="{@URI}" class="pdfLink">
													<xsl:value-of select="leg:TranslateText('Revised')"/>
													<xsl:text> </xsl:text>
													<xsl:value-of select="format-date(@Revised, '[D01]/[M01]/[Y0001]')"/>
												</a>
												<span>
													<xsl:value-of select="format-number((@Size div (1024 * 1024)), '#0.00')"/>
													<xsl:value-of select="' MB'"/>
												</span>
											</li>
										</xsl:for-each>
									</ul>
								</div>
							</div>
						</xsl:if>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="content" id="pdfVersionsContent">
					<xsl:if test="exists($g_pdfVersions) or exists(/leg:Legislation/ukm:Metadata/ukm:CorrectionSlips/ukm:CorrectionSlip)">
						<div class="content">
							<ul class="toolList">
								<xsl:variable name="status" select="leg:GetCodeSchemaStatus(/)" />
								<xsl:for-each select="$g_pdfVersions">
									<xsl:sort select="not(@Revised)" order="descending" />
									<xsl:sort select="@Title = 'Print Version' and not(@Revised)" order="descending" />
									<xsl:sort select="xs:date(@Revised)" order="descending" />
									<xsl:sort select="@Title"/>
									<!-- put English first -->
									<xsl:sort select="exists(@Language)" />
									<xsl:sort select="@Language = 'English'" order="descending" />
									<!-- put Mixed language last -->
									<xsl:sort select="@Language = 'Mixed'" />
									<xsl:variable name="strLanguageSuffix" select="leg:pdf-language(.)"/>
									<xsl:variable name="title" as="xs:string">
										<xsl:choose>
											<!-- if there is no title then display the download label-->
											<xsl:when test="@Title = '' or not(@Title)"><xsl:value-of select="$strLanguageSuffix" /></xsl:when>
											<!-- if the title is print then display the Download label-->
											<xsl:when test="@Title = 'Print Version' or @Title = 'Mixed Language Measure'"><xsl:value-of select="$strLanguageSuffix" /></xsl:when>
											<!-- for anything else display the title -->
											<xsl:otherwise><xsl:value-of select="concat(leg:TranslateText(@Title), strLanguageSuffix)"/></xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<li>
										<a class="pdfLink" href="{@URI}">
											<xsl:choose>
												<!--added revised version-->
												<xsl:when test="exists(@Revised)">
													<xsl:value-of select="leg:TranslateText('PDF_Revised_Version')"/>
													<xsl:text> </xsl:text>
													<xsl:value-of select="if (@Revised castable as xs:date) then format-date(@Revised,'[D]/[M]/[Y]') else @Revised"/>
												</xsl:when>
												<xsl:when test="$documentMainType = $createdTypes">
													<xsl:value-of select="leg:TranslateText('Original Print PDF')"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="leg:TranslateText('PDF_Versions_final')"/>
												</xsl:otherwise>
											</xsl:choose>

											<xsl:if test="string-length($title) ne 0 and not(@Revised)">
												<xsl:value-of select="concat(' ', $title)"/>
											</xsl:if>
										</a>
									</li>
								</xsl:for-each>
								<xsl:for-each select="/leg:Legislation/ukm:Metadata/ukm:CorrectionSlips/ukm:CorrectionSlip">
									<li>
										<a class="pdfLink" href="{@URI}">
											<xsl:value-of select="leg:TranslateText('PDF_Versions_correction')"/>
											<xsl:text> - </xsl:text>
											<xsl:value-of select="leg:FormatDate(@Date)"/>
										</a>
									</li>
								</xsl:for-each>
							</ul>
						</div>
						<p class="viewMoreLink">
							<a href="{leg:FormatURL($resourceURI, false())}"><xsl:value-of select="leg:TranslateText('View more')"/>
								<span class="pageLinkIcon"></span>
							</a>
						</p>
					</xsl:if>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<!-- outputting the ukoriginatesfromeu box -->
	<xsl:template name="TSOOutputEUR">
		<xsl:if test="$g_isEURetainedOrEUTreaty">
			<xsl:variable name="titleText" select="concat('eu_uk_', $g_strShortType)"/>
			<xsl:variable name="celexNumber" select="leg:get-celex-number($g_strShortType, $g_strDocumentYear, $g_strDocumentNumber)"/>
			<xsl:variable name="eulex-uri" select="concat(leg:eurlex-uri(), $celexNumber, ':en:NOT')"/>
			<xsl:variable name="webarchive-uri" select="concat(leg:webarchive-uri(), $celexNumber)"/>

			<div class="section" id="ukregfromeu">
				<div class="title">
					<a href="#ukregfromeuHelp" class="helpItem helpItemToMidRight">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about UK-EU Regulation"/>
					</a>
					<h2>
						<xsl:value-of select="leg:TranslateText($titleText)"/>
					</h2>
				</div>
				<div class="content">
					<ul class="toolList">
						<li>
							<a href="{$eulex-uri}" target="_blank">
								<xsl:value-of select="leg:TranslateText('eu_uk_reg_equiv_eu')"/>
								<img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)"/>
							</a>
						</li>
						<xsl:if test="not($g_strDocumentYear = $g_EUwebArchiveIgnoreYears)">
							<li>
								<a href="{$webarchive-uri}" target="_blank">
								<xsl:value-of select="leg:TranslateText('eu_uk_reg_archive_brexitday')"/>
								<img src="/images/chrome/newWindowIcon.gif" alt=" (opens in new window)"/>
								</a>
							</li>
						</xsl:if>
					</ul>
				</div>
			</div>

			<div class="help" id="ukregfromeuHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>
						<xsl:value-of select="leg:TranslateText('legislation_originated_from_EU_1')"/>
					</h3>
					<p>
						<xsl:value-of select="leg:TranslateText('legislation_originated_from_EU_p1')"/>
					</p>
					<p>
						<xsl:value-of select="leg:TranslateText('legislation_originated_from_EU_p2')"/>
					</p>
				</div>

			</div>
		</xsl:if>
	</xsl:template>
	<!-- ========== Standard code for outputing legislation content ========= -->

	<xsl:template name="TSOOutputLegislationContent">
		<div id="viewLegContents" xml:lang="{if(contains((/leg:Legislation/ukm:Metadata/dc:identifier)[1],'/cy/')) then 'cy' else 'en'}">
			<div class="LegSnippet" id="viewLegSnippet">

				<!-- adding the tocControlsAddress to the table of contents when it is not PDFOnly-->
				<xsl:if test="count(//leg:ContentsPart[* except (leg:ContentsNumber, leg:ContentsTitle)]) > 0 or count(//leg:ContentsSchedule[* except (leg:ContentsNumber, leg:ContentsTitle)]) >0">
					<xsl:attribute name="id">tocControlsAdded</xsl:attribute>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="$IsPDFOnly ">
						<!-- If legislation is only available in PDFOnly then display PDF link -->
						<xsl:variable name="alternatives" as="element(ukm:Alternative)+"
									  select="/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative"/>
						<xsl:variable name="versiondate" as="xs:date?"
									  select="if ($version castable as xs:date) then xs:date($version) else ()"/>
						<xsl:variable name="alternative" as="element(ukm:Alternative)?"
									  select="if (exists($versiondate)) then
												 $alternatives[@Revised = max($alternatives/@Revised/xs:date(.)[. le $versiondate])]
											else if (leg:IsCurrentRevised(.)) then
									          $alternatives[@Revised = max($alternatives/@Revised/xs:date(.))]
									        else if ($language = 'cy') then
									        	($alternatives[@Language = 'Welsh'])[1]
									        else
									        	$alternatives[not(@Language = 'Welsh')][not(@Revised)][1]"/>
						<!-- make sure we get one -->
						<xsl:variable name="alternative" as="element(ukm:Alternative)"
									  select="if ($alternative) then $alternative else $alternatives[1]"/>
						<p class="downloadPdfVersion">
							<a class="pdfLink" href="{$alternative/@URI}">
								<img class="imgIcon" alt="" src="/images/chrome/pdfIconMed.gif"/>
								<xsl:value-of select="leg:TranslateText('View PDF')"/>
								<img class="pdfThumb"
									 src="{replace(replace(substring-after($alternative/@URI, 'http://www.legislation.gov.uk'), '/pdfs/', '/images/'), '.pdf', '.jpg')}"
									 title="{$title}"
									 alt="{$title}"/>
							</a>
						</p>
					</xsl:when>

					<xsl:otherwise>
						<!-- adding the crest logo if introduction or whole act-->
						<xsl:if test=" $g_strIntroductionUri = $dcIdentifier or $g_strwholeActURI = $dcIdentifier">
							<xsl:variable name="uriPrefix" as="xs:string"
										  select="tso:GetUriPrefixFromType(leg:GetDocumentMainType(.), /leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:BillMetadata)/ukm:Year/@Value)"/>
							<xsl:if test="$uriPrefix = ('aep', 'aip', 'apgb' , 'apni' , 'asp' , 'mnia' , 'ukcm' , 'ukla' , 'ukpga' , 'mwa', 'aosp','anaw', 'nia') ">
								<p class="crest">
									<a href="{leg:FormatURL($g_strIntroductionUri)}">
										<img alt="" src="/images/crests/{$uriPrefix}.gif"/>
									</a>
								</p>
							</xsl:if>
						</xsl:if>


						<!-- output the legislation content-->
						<xsl:call-template name="TSOOutputContent"/>

					</xsl:otherwise>
				</xsl:choose>

				<!-- add a break -->
				<span class="LegClearFix"/>
			</div>
		</div>

	</xsl:template>

	<!-- title heading of the legislation-->
	<xsl:template name="TSOOutputLegislationTitle">
		<h1 class="pageTitle{if ($isDraft) then ' draft' else if (leg:IsProposedVersion(.)) then ' proposed' else ''}">
			<xsl:choose>
				<xsl:when test="$dcalternative">
					<span>
						<xsl:value-of select="$dcalternative"/>
					</span>
					<a href="#" class="pageTitleToggleLink"><xsl:value-of select="leg:TranslateText('Show full title')"/></a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$title"/>
				</xsl:otherwise>
			</xsl:choose>
		</h1>
		<xsl:if test="$dcalternative">
			<p class="fullTitle">
					<xsl:value-of select="$title"/>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template name="TSOOutputLegislationNumber">
		<xsl:choose>
			<xsl:when test="$g_ndsMetadata/ukm:SecondaryMetadata">
				<h1 class="LegNo">
					<xsl:value-of select="$g_strDocumentYear"/>
					<xsl:text> </xsl:text>
					<xsl:value-of
							select="tso:GetNumberForLegislation($g_strDocumentMainType, $g_strDocumentYear, $g_strDocumentNumber)"/>
					<xsl:for-each select="$g_strDocumentAltNumber">
						<xsl:text> (</xsl:text>
						<xsl:value-of select="./@Category"/>
						<xsl:text>. </xsl:text>
						<xsl:value-of select="./@Value"/>
						<xsl:text>)</xsl:text>
					</xsl:for-each>
				</h1>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="FuncOutputPrimaryPrelimsPreContents"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- outputing the content -->
	<xsl:template name="TSOOutputContent">
		<xsl:apply-templates select="leg:Legislation">
			<xsl:with-param name="showSection" select="$nstSection" tunnel="yes"/>
			<xsl:with-param name="matchRefs" select="$matchRefs" tunnel="yes"/>
			<xsl:with-param name="includeTooltip" select="tso:IncludeInlineTooltip()" tunnel="yes"/>
			<xsl:with-param name="linkFragment" select="$linkFragment" tunnel="yes"/>
			<xsl:with-param name="showRepeals" select="$showRepeals" tunnel="yes"/>
			<xsl:with-param name="searchingByText" select="$searchingByText" tunnel="yes"/>
			<xsl:with-param name="searchingByExtent" select="$searchingByExtent" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="leg:Contents/leg:ContentsTitle" priority="1000">
		<!-- legislation titles will not be displayed on the table of content page -->
		<!--<xsl:choose>
			<xsl:when test="/leg:Legislation/ukm:Metadata/ukm:PrimaryMetadata">
		<xsl:next-match />
		<xsl:call-template name="TSOOutputLegislationNumber" />
			</xsl:when>
			<xsl:when test="/leg:Legislation/ukm:Metadata/ukm:SecondaryMetadata">
				<xsl:call-template name="FuncOutputSecondaryPrelims" />
				<xsl:call-template name="TSOOutputLegislationNumber" />
				<p class="LegSubject"><xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:subject[last()]" /></p>
				<xsl:next-match />
			</xsl:when>
		</xsl:choose>-->
	</xsl:template>

	
	

	<!-- ========== Standard code for breadcrumb ========= -->
	<xsl:template name="TSOOutputBreadcrumbItems">
		<!--/#breadcrumbControl -->
		<xsl:variable name="maintype" select="leg:GetDocumentMainType(.)"/>
		<div id="breadCrumb">
			<h3 class="accessibleText">You are here:</h3>
			<ul>
				<xsl:call-template name="legtypeBreadcrumb"/>
				<xsl:choose>
					<xsl:when test="$g_strwholeActURI = $strCurrentURIs">
						<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
						<li class="activetext">Whole
							<xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/>
						</li>
					</xsl:when>
					<xsl:when test="$g_wholeActWithoutSchedulesURI = $strCurrentURIs">
						<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
						<li class="activetext">Whole
							<xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/> without
							<xsl:value-of select="$schedulesText"/>
						</li>
					</xsl:when>
					<xsl:when test="$strCurrentURIs = $g_schedulesOnlyURI">
						<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
						<li class="activetext">
							<xsl:value-of select="$schedulesText"/> only
						</li>
					</xsl:when>
					<xsl:when test="leg:IsTOC()">
						<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
						<li class="activetext"><xsl:value-of select="leg:TranslateText('Table of contents')"/></li>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="nstSection" as="element()?"
									  select="(//*[@DocumentURI = $strCurrentURIs])[1]"/>
						<xsl:choose>
							<xsl:when test="exists($nstSection)">
								<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]"
													 mode="TSOBreadcrumbItem"/>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</ul>
		</div>
	</xsl:template>



	<!-- creating link for the whole act  -->
	<xsl:template match="leg:Legislation" mode="TSOBreadcrumbItem" priority="20">
		<xsl:variable name="nstMetadata" as="element()"
					  select="$g_ndsMetadata/(ukm:SecondaryMetadata|ukm:PrimaryMetadata|ukm:EUMetadata|ukm:BillMetadata)"/>
		<li>
			<a href="{substring-after($tocURI,'http://www.legislation.gov.uk')}">
				<xsl:choose>
					<xsl:when test="$g_strDocumentNumber">
						<xsl:value-of select="$g_strDocumentYear"/>&#160;<xsl:value-of
							select="tso:GetNumberForLegislation($g_strDocumentMainType, $g_strDocumentYear, $g_strDocumentNumber)"/>
						<xsl:apply-templates select="$nstMetadata/ukm:AlternativeNumber" mode="series"/>
					</xsl:when>
					<xsl:when test="$nstMetadata/ukm:AlternativeNumber[@Category='Bill']">
						<xsl:value-of select="$g_strDocumentYear"/>&#160;<xsl:value-of
							select="$nstMetadata/ukm:AlternativeNumber[@Category='Bill']/@Value"/>
					</xsl:when>
					<xsl:when test="$nstMetadata/ukm:Name">
						<xsl:value-of select="upper-case($nstMetadata/ukm:Name/@Value)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>ISBN </xsl:text>
						<xsl:value-of select="tso:formatISBN($nstMetadata/ukm:ISBN/@Value)"/>
					</xsl:otherwise>
				</xsl:choose>
			</a>
		</li>
	</xsl:template>

	<!-- hiding the text for the body-->
	<xsl:template match="leg:Body | leg:EUBody" mode="TSOBreadcrumbItem" priority="20"/>

	<xsl:template match="*[@DocumentURI]" mode="TSOBreadcrumbItem" priority="10">
		<li>
			<xsl:choose>
				<xsl:when test="$strCurrentURIs = @DocumentURI">
					<xsl:attribute name="class" select="'active'"/>
					<xsl:next-match/>
				</xsl:when>
				<xsl:otherwise>
					<a href="{leg:FormatURL(@DocumentURI)}">
						<xsl:next-match/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
		</li>
	</xsl:template>

	<xsl:template match="leg:PrimaryPrelims | leg:SecondaryPrelims | leg:EUPrelims" mode="TSOBreadcrumbItem"
				  priority="5">
		<xsl:choose>
			<xsl:when test="leg:IsCurrentWelsh(/)">
				<xsl:text>Cyflwyniad</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Introduction</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:SignedSection" mode="TSOBreadcrumbItem" priority="5">
		<xsl:value-of select="$signatureText"/>
	</xsl:template>

	<xsl:template match="leg:ExplanatoryNotes" mode="TSOBreadcrumbItem" priority="5">
		<xsl:value-of select="$noteText"/>
	</xsl:template>

	<xsl:template match="leg:EarlierOrders" mode="TSOBreadcrumbItem" priority="5">
		<xsl:value-of select="$earlierOrdersText"/>
	</xsl:template>

	<xsl:template match="leg:AttachmentGroup[@DocumentURI] | leg:Attachment[@DocumentURI]" mode="TSOBreadcrumbItem"
				  priority="5">
		<xsl:value-of select="translate(@id, '-', ' ')"/>
	</xsl:template>

	<xsl:template match="leg:Attachment//*[@DocumentURI]" mode="TSOBreadcrumbItem" priority="15"/>

	<xsl:template match="*[leg:Pnumber]" mode="TSOBreadcrumbItem" priority="5">
		<xsl:param name="nstDocumentClassification"
				   select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:BillMetadata)/ukm:DocumentClassification"/>
		<xsl:choose>
			<xsl:when test="self::leg:P1">
				<xsl:variable name="strCategory"
							  select="$nstDocumentClassification/ukm:DocumentCategory/@Value"/>
				<xsl:variable name="strMainType"
							  select="$nstDocumentClassification/ukm:DocumentMainType/@Value"/>
				<xsl:variable name="strMinorType"
							  select="$nstDocumentClassification/ukm:DocumentMinorType/@Value"/>
				<xsl:choose>
					<xsl:when test="$g_strDocumentType = $g_strEUretained"></xsl:when>
					<xsl:when test="ancestor::leg:Schedule[not(ancestor::leg:BlockAmendment)]">Paragraph</xsl:when>
					<xsl:when test="$strMainType = 'NorthernIrelandOrderInCouncil'">Article</xsl:when>
					<xsl:when test="$strMinorType = 'rule'">Rule</xsl:when>
					<xsl:when test="$strMinorType = 'regulation'">Regulation</xsl:when>
					<xsl:when test="$strCategory = 'secondary'">Article</xsl:when>
					<xsl:otherwise>Section</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Create the relevant 'Section' or 'Subsection' or 'Subsubsection' -->
				<xsl:text>S</xsl:text>
				<xsl:for-each select="ancestor-or-self::*[leg:Pnumber]">
					<xsl:choose>
						<xsl:when test="position() = last()">ection</xsl:when>
						<xsl:otherwise>ubs</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
		<xsl:value-of select="leg:Pnumber"/>
	</xsl:template>

	<!-- FM: Fixing the breadcrumb to display the 'leg:Title' if leg:Number is empty -->
	<xsl:template match="*[leg:Number != '' ]" mode="TSOBreadcrumbItem" priority="3">
		<xsl:choose>
			<xsl:when test="self::leg:Division">
				<xsl:variable name="prefix"
							  select="
									if (@Type = 'EUTitle' and not(matches(leg:Number, 'title', 'i'))) then 'Title'
									else if (@Type = 'EUPart' and not(matches(leg:Number, 'part', 'i'))) then 'Part'
									else if (@Type = 'EUChapter' and not(matches(leg:Number, 'chapter', 'i'))) then 'Chapter'
									else if (@Type = 'EUSection' and not(matches(leg:Number, 'section', 'i'))) then 'Section'
									else if (@Type = 'EUSubsection' and not(matches(leg:Number, 'section', 'i'))) then 'Sub-Section'
									else if (@Type = 'Annotations' and not(matches(leg:Number, 'annotation', 'i'))) then 'Annotations'
									else if (@Type = 'Annotation' and not(matches(leg:Number, 'annotation', 'i'))) then 'Annotation'
									else if (@Type = ('EUTitle', 'EUPart', 'EUChapter', 'EUSection', 'EUSubsection', 'Annotations', 'Annotation')) then ()
									else 'Division'
									"/>
				<xsl:value-of select="concat($prefix, ' ', leg:Number)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="leg:Number"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[leg:Title='' and not(leg:Number) and not (leg:Pnumber) and matches(@id,'[^/]*n[0-9]+')]"
				  mode="TSOBreadcrumbItem" priority="4">
		<xsl:choose>
			<xsl:when test="exists(descendant::*[local-name() = 'Emphasis'])">
				<xsl:variable name="title" select="(//leg:Emphasis)[1]"/>
				<xsl:value-of select="
					concat(
					replace($title,'([A-Za-z])([A-Za-z]+)\s([^\s]+).*','$1'),
					replace($title,'([A-Za-z])([A-Za-z]+)\s([^\s]+).*','$2'),
					replace($title,'([A-Za-z])([A-Za-z]+)\s([^\s]+).*',' $3')
					)
					"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="local-name(.)"/>
				<xsl:value-of select="replace(@id, replace(@id,'n[0-9]+',''), ' ')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[leg:Title]" mode="TSOBreadcrumbItem" priority="2">
		<xsl:choose>
			<xsl:when test="leg:Title = ''">
				<xsl:value-of select="local-name(if (. instance of element(leg:TitleBlock)) then .. else .)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="leg:abridgeContent(leg:Title[1], 4)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[leg:TitleBlock]" mode="TSOBreadcrumbItem" priority="2">
		<!-- This will pick up the Title from the TitleBlock -->
		<xsl:variable name="title">
			<xsl:apply-templates select="leg:TitleBlock" mode="TSOBreadcrumbItem"/>
		</xsl:variable>
		<xsl:variable name="path-seq">
			<xsl:if test="exists(@IdURI)">
				<xsl:variable name="seq" as="xs:string*"
							  select="tokenize(replace(@IdURI,'(https?://)(www)?(.[^/]+)/id/(.*)','$4'),'/')"/>
				<xsl:value-of select="string-join(subsequence($seq,4),' ')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="lower-case($title) != $path-seq and string-length($title) lt string-length($path-seq)">
				<xsl:choose>
					<xsl:when test="upper-case($title) = $title">
						<xsl:value-of select="upper-case($path-seq)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$path-seq"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="upper-case($title) != $title"/>
				<xsl:value-of select="$path-seq"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[leg:TitleBlock]" mode="TSOBreadcrumbItem" priority="1">
		<!-- This will pick up the Title from the TitleBlock -->
		<xsl:apply-templates select="leg:TitleBlock" mode="TSOBreadcrumbItem"/>
	</xsl:template>

	<xsl:template match="leg:P1group[leg:Title = '']" mode="TSOBreadcrumbItem" priority="3">Paragraphs</xsl:template>

	<!-- Container Divisions without any specific content -->
	<xsl:template match="leg:Division[not(leg:Number)][not(leg:Title)]" mode="TSOBreadcrumbItem" priority="2">
		<xsl:variable name="idtokens" as="xs:string*" select="tokenize(@id, '-')"/>
		<xsl:variable name="tokencount" as="xs:integer?" select="count($idtokens)"/>
		<xsl:value-of select="if (matches($idtokens[last()], '[0-9]+')) then
					concat($idtokens[$tokencount - 1], ' ', $idtokens[$tokencount])
					else $idtokens[$tokencount]"/>
	</xsl:template>

	<!-- prevent other matches extending the breadcrumb trail-->
	<xsl:template match="*" mode="TSOBreadcrumbItem" priority="1"></xsl:template>


	<!-- ========== Standard code for previous and next ========= -->
	<xsl:template name="TSOOutputPreviousNextLinks">
		<xsl:choose>
			<xsl:when test="not(leg:IsTOC())">
				<xsl:variable name="prev" as="element(atom:link)?"
							  select="leg:Legislation/ukm:Metadata/atom:link[@rel='prev']"/>
				<xsl:variable name="next" as="element(atom:link)?"
							  select="leg:Legislation/ukm:Metadata/atom:link[@rel='next']"/>
				<div class="prevNextNav">
					<ul>
						<li class="prev">
							<xsl:element name="{if (exists($prev)) then 'a' else 'span'}">
								<xsl:choose>
									<xsl:when test="exists($prev)">
										<xsl:attribute name="href" select="leg:FormatURL($prev/@href)"/>
										<xsl:attribute name="class"
													   select="concat('userFunctionalElement', if (contains(leg:get-query('view'), 'plain')) then '' else ' nav')"/>
										<xsl:attribute name="title">
											<xsl:choose>
												<xsl:when test="exists($prev/@title)">
													<xsl:value-of
															select="substring-after(lower-case($prev/@title), ';')"/>
												</xsl:when>
											</xsl:choose>
										</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class" select="'userFunctionalElement disabled'"/>
									</xsl:otherwise>
								</xsl:choose>
								<span class="background">
									<span class="btl"/>
									<span class="btr"/>
									<xsl:value-of select="leg:TranslateText('Previous')"/>
									<xsl:if test="exists($prev)">:
										<xsl:value-of select="leg:TranslateText(substring-before($prev/@title, ';'))"/>
									</xsl:if>
									<span class="bbl"/>
									<span class="bbr"/>
								</span>
							</xsl:element>
						</li>
						<li class="next">
							<xsl:element name="{if (exists($next)) then 'a' else 'span'}">
								<xsl:choose>
									<xsl:when test="exists($next)">
										<xsl:attribute name="href" select="leg:FormatURL($next/@href)"/>
										<xsl:attribute name="class"
													   select="concat('userFunctionalElement', if (contains(leg:get-query('view'), 'plain')) then '' else ' nav')"/>
										<xsl:attribute name="title">
											<xsl:choose>
												<xsl:when test="exists($next/@title)">
													<xsl:value-of
															select="substring-after(lower-case($next/@title),';')"/>
												</xsl:when>
											</xsl:choose>
										</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class" select="'userFunctionalElement disabled'"/>
									</xsl:otherwise>
								</xsl:choose>
								<span class="background">
									<span class="btl"/>
									<span class="btr"/>
									<xsl:value-of select="leg:TranslateText('Next')"/>
									<xsl:if test="exists($next)">:
										<xsl:value-of select="leg:TranslateText(substring-before($next/@title, ';'))"/>
									</xsl:if>
									<span class="bbl"/>
									<span class="bbr"/>
								</span>
							</xsl:element>
						</li>
					</ul>
				</div>
				<!--/.prevNextNav-->
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

	<!-- trimming previous and next sections titles-->
	<xsl:function name="tso:OutputNextPreviousSection">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="string-length($text)>50">
				<xsl:value-of select="substring($text, 1,50)"/>...
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- ========== Standard code for view/print ========= -->
	<xsl:template name="TSOOutputViewPrintLinks">
		<ul id="viewPrintControl">
			<li class="view">
				<xsl:element name="{if ($IsPDFOnly) then 'span' else 'a'}">
					<xsl:choose>
						<xsl:when test="$IsPDFOnly">
							<xsl:attribute name="class">userFunctionalElement disabled</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
							<xsl:attribute name="href">
								<xsl:text>?</xsl:text>
								<xsl:choose>
									<xsl:when test="contains(leg:get-query('view'), 'extent') ">
										<xsl:value-of select="leg:set-query-params('view', 'plain+extent')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="leg:set-query-params('view', 'plain')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<span class="btl"/>
					<span class="btr"/>
					<xsl:value-of select="leg:TranslateText('Plain View')"/>
					<span class="bbl"/>
					<span class="bbr"/>
				</xsl:element>
			</li>
			<li class="print">
				<xsl:element name="{if ($IsPDFOnly) then 'span' else 'a'}">
					<xsl:choose>
						<xsl:when test="$IsPDFOnly">
							<xsl:attribute name="class">userFunctionalElement disabled</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
							<xsl:attribute name="href">#printOptions</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<span class="btl"/>
					<span class="btr"/>
					<xsl:value-of select="leg:TranslateText('Print Options')"/>
					<span class="bbl"/>
					<span class="bbr"/>
				</xsl:element>
			</li>
		</ul>
		<!--/#viewPrintControl-->
	</xsl:template>

	<!-- for print options -->
	<xsl:template match="leg:Legislation" mode="TSOPrintOptions" priority="1000">
		<xsl:if test="leg:IsTOC()">
			<li class="printToc">
				<h4>
					<span class="accessibleText">Print</span>
					<xsl:value-of select="leg:TranslateText('Table of Contents')"/>
				</h4>
				<ul>
					<li>
						<a href="{leg:FormatPDFDataURL($dcIdentifier)}" target="_blank" class="pdfLink">PDF
							<span class="accessibleText">table of contents</span>
						</a>
					</li>
					<li>
						<a href="{leg:FormatHTMLDataURL($dcIdentifier)}" target="_blank" class="htmLink">
							<xsl:value-of select="leg:TranslateText('Web page')"/>
							<span class="accessibleText">table of contents</span>
						</a>
					</li>
				</ul>
			</li>
		</xsl:if>
		<xsl:next-match/>
	</xsl:template>

	<xsl:template
			match="leg:Legislation | leg:Body | leg:EUBody | leg:Part | leg:Chapter | leg:Schedules | leg:Schedule | leg:Pblock | leg:P1 | leg:SecondaryPrelims | leg:PrimaryPrelims | leg:EUPrelims | leg:SignedSection | leg:Secondary/leg:ExplanatoryNotes | leg:EarlierOrders | leg:EUPart | leg:EUTitle  | leg:EUChapter  | leg:EUSection  | leg:EUSubsection  | leg:Division  | leg:Attachments | leg:Attachment"
			mode="TSOPrintOptions">
		<li class="printWhole">
			<xsl:variable name="displayText">
				<xsl:choose>
					<xsl:when test="self::leg:Body or self::leg:EUBody">The
						<xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/>
					</xsl:when>
					<xsl:when test="self::leg:Schedules">The
						<xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/>
						only
					</xsl:when>
					<xsl:when test="self::leg:P1 and parent::leg:P1group/@AltVersionRefs">This
						<xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/>
						only
					</xsl:when>
					<xsl:when test="@DocumentURI = $dcIdentifier and not(self::leg:Legislation)">This
						<xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/>
						only
					</xsl:when>
					<xsl:otherwise>The Whole
						<xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="provisions" as="xs:integer">
				<xsl:choose>
					<xsl:when test="@NumberOfProvisions">
						<xsl:value-of select="xs:integer(@NumberOfProvisions)"/>
					</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- If the current node is Schedules then get $g_schedulesOnlyURI-->
			<xsl:variable name="documentURI">
				<xsl:choose>
					<xsl:when test="self::leg:Schedules">
						<xsl:value-of select="$g_schedulesOnlyURI"/>
					</xsl:when>
					<xsl:when test="self::leg:Attachments">
						<xsl:value-of select="$g_attachmentsOnlyURI"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@DocumentURI"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<h4>
				<span class="accessibleText">Print</span>
				<xsl:value-of select="leg:TranslateText($displayText)"/>
			</h4>
			<ul>
				<li>
					<a class="pdfLink">
						<xsl:choose>
							<xsl:when test="$provisions > $paragraphThreshold">
								<xsl:attribute name="href" select="concat ('#print',  name(), 'ModPdf')"/>
								<xsl:attribute name="class" select="'pdfLink warning'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="href" select="leg:FormatPDFDataURL($documentURI)"/>
								<xsl:attribute name="target">_blank</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>PDF</xsl:text>
						<span class="accessibleText">
							<xsl:text> </xsl:text>
							<xsl:value-of select="leg:TranslateText($displayText)"/>
						</span>
					</a>
				</li>
				<li>
					<a class="htmLink">
						<xsl:choose>
							<xsl:when test="$provisions > $paragraphThreshold">
								<xsl:attribute name="href" select="concat ('#print',  name(), 'ModHtm')"/>
								<xsl:attribute name="class" select="'htmLink warning'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="href" select="leg:FormatHTMLDataURL($documentURI)"/>
								<xsl:attribute name="target">_blank</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="leg:TranslateText('Web page')"/>
						<span class="accessibleText">
							<xsl:text> </xsl:text>
							<xsl:value-of select="leg:TranslateText($displayText)"/>
						</span>
					</a>
				</li>
			</ul>
		</li>
	</xsl:template>
	<xsl:template match="*" mode="TSOPrintOptions"/>

	<xsl:template
			match="leg:Legislation | leg:Body | leg:EUBody | leg:Schedules | leg:Attachments | leg:Attachment | leg:Part | leg:Chapter | leg:Schedule | leg:Pblock | leg:P1"
			mode="TSOPrintOptionsWarnings">
		<xsl:if test="@NumberOfProvisions > $paragraphThreshold">

			<xsl:variable name="displayText">
				<xsl:choose>
					<xsl:when test="@DocumentURI = $dcIdentifier and not(self::leg:Legislation)">This
						<xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/>
						only
					</xsl:when>
					<xsl:otherwise>The Whole
						<xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:call-template name="TSOOutputWarningMessage">
				<xsl:with-param name="messageId" select="concat('print',  name(), 'ModHtm')"/>
				<xsl:with-param name="messageType" select=" 'webWarning' "/>
				<xsl:with-param name="messageHeading">You have chosen to open
					<xsl:value-of select="$displayText"/>
				</xsl:with-param>
				<xsl:with-param name="message">
					<xsl:value-of select="$displayText"/> you have selected contains over
					<xsl:value-of select="$paragraphThreshold"/> provisions and might take some time to download. You
					may also experience some issues with your browser, such as an alert box that a script is taking a
					long time to run.
				</xsl:with-param>
				<xsl:with-param name="continueURL" select="leg:FormatHTMLDataURL(@DocumentURI)"/>
			</xsl:call-template>

			<xsl:call-template name="TSOOutputWarningMessage">
				<xsl:with-param name="messageId" select="concat('print',  name(), 'ModPdf')"/>
				<xsl:with-param name="messageType" select=" 'pdfWarning' "/>
				<xsl:with-param name="messageHeading">You have chosen to open
					<xsl:value-of select="$displayText"/> as a PDF
				</xsl:with-param>
				<xsl:with-param name="message">
					<xsl:value-of select="$displayText"/> you have selected contains over
					<xsl:value-of select="$paragraphThreshold"/> provisions and might take some time to download.
				</xsl:with-param>
				<xsl:with-param name="continueURL" select="leg:FormatPDFDataURL(@DocumentURI)"/>
			</xsl:call-template>

		</xsl:if>
	</xsl:template>
	<xsl:template match="*" mode="TSOPrintOptionsWarnings"/>

	<xsl:template match="leg:Legislation" mode="TSOPrintOptionsXXX">
		<xsl:value-of
				select="tso:GetCategory($ndsLegislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:BillMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value)"/>
	</xsl:template>
	<xsl:template match="leg:Body | leg:EUBody" mode="TSOPrintOptionsXXX">
		<xsl:value-of
				select="tso:GetCategory($ndsLegislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:BillMetadata | ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value)"/>
		without
		<xsl:value-of select="$schedulesText"/>
	</xsl:template>

	<xsl:template match="leg:Part | leg:EUPart | leg:Division[@Type='EUPart']" mode="TSOPrintOptionsXXX">Part
	</xsl:template>
	<xsl:template match="leg:EUTitle | leg:Division[@Type='EUTitle']" mode="TSOPrintOptionsXXX">Title</xsl:template>
	<xsl:template match="leg:EUSection | leg:Division[@Type='EUSection']" mode="TSOPrintOptionsXXX">Section
	</xsl:template>
	<xsl:template match="leg:EUSubsection | leg:Division[@Type='EUSubsection']" mode="TSOPrintOptionsXXX">Sub-section
	</xsl:template>
	<xsl:template match="leg:Attachment" mode="TSOPrintOptionsXXX">Attachment</xsl:template>
	<xsl:template match="leg:Attachments" mode="TSOPrintOptionsXXX">Attachments</xsl:template>
	<xsl:template match="leg:Schedule" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$scheduleText"/>
	</xsl:template>
	<xsl:template match="leg:Schedules" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$schedulesText"/>
	</xsl:template>
	<xsl:template match="leg:Pblock" mode="TSOPrintOptionsXXX">Cross Heading</xsl:template>
	<xsl:template match="leg:Chapter | leg:EUChapter | leg:Division[@Type='EUChapter']" mode="TSOPrintOptionsXXX">
		Chapter
	</xsl:template>
	<xsl:template match="leg:Division[not(@Type=('EUPart','EUTitle','EUChapter','EUSection','EUSubsection'))]"
				  mode="TSOPrintOptionsXXX">Division
	</xsl:template>
	<xsl:template match="leg:P1[$g_strDocumentType = $g_strEUretained]" mode="TSOPrintOptionsXXX">Article</xsl:template>
	<xsl:template match="leg:P1[not($g_strDocumentType = $g_strEUretained)]" mode="TSOPrintOptionsXXX">Section
	</xsl:template>
	<xsl:template match="leg:SecondaryPrelims | leg:PrimaryPrelims | leg:EUPrelims" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$introductoryText"/>
	</xsl:template>
	<xsl:template match="leg:SignedSection" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$signatureText"/>
	</xsl:template>
	<xsl:template match="leg:ExplanatoryNotes" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$noteText"/>
	</xsl:template>
	<xsl:template match="leg:EarlierOrders" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$earlierOrdersText"/>
	</xsl:template>
	<xsl:template match="*" mode="TSOPrintOptionsXXX"/>


	<xsl:template name="TSOOutputPrintOptions">
		<div id="printOptions" class="interfaceOptions ">
			<h3 class="accessibleText">Print Options</h3>
			<ul class="optionList">
				<xsl:choose>
					<xsl:when test="leg:IsTOC()">
						<xsl:apply-templates select="leg:Legislation"
											 mode="TSOPrintOptions"/> <!-- displaying print options as 'Whole Act', 'Table of Content' -->
					</xsl:when>
					<xsl:when
							test="$dcIdentifier = $g_schedulesOnlyURI"> <!-- displaying print options as 'Whole Act', 'The Schedules only' for Schedules only -->
						<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptions"/>
						<xsl:apply-templates
								select="leg:Legislation/(leg:Primary|leg:Secondary|leg:EURetained)/leg:Schedules"
								mode="TSOPrintOptions"/>
					</xsl:when>
					<xsl:when
							test="$dcIdentifier = $g_attachmentsOnlyURI"> <!-- displaying print options as 'Whole Act', 'The Schedules only' for Schedules only -->
						<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptions"/>
						<xsl:apply-templates select="leg:Legislation/leg:EURetained/leg:Attachments"
											 mode="TSOPrintOptions"/>
					</xsl:when>
					<xsl:when
							test="$g_wholeActWithoutSchedulesURI = $dcIdentifier"><!-- displaying print options as 'Whole Act', 'Act without Schedules' for Schedules without Act only -->
						<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptions"/>
						<xsl:apply-templates
								select="leg:Legislation/(leg:Primary|leg:Secondary)/leg:Body | leg:Legislation/leg:EURetained/leg:EUBody"
								mode="TSOPrintOptions"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="nstSection" as="element()?"
									  select="(//*[@DocumentURI = $strCurrentURIs])[1]"/>
						<xsl:choose>
							<xsl:when test="exists($nstSection)">
								<!--							<xsl:for-each select="$nstSection/ancestor-or-self::*[@DocumentURI]">
																<br/>
																[<xsl:value-of select="position()"/> : <xsl:value-of select="name()" />]
															</xsl:for-each>
															<br/>			-->
								<xsl:apply-templates
										select="$nstSection/ancestor-or-self::*[@DocumentURI and not(self::leg:Body or self::leg:EUBody)] "
										mode="TSOPrintOptions"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptions"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</ul>
		</div>

		<xsl:choose>
			<xsl:when test="leg:IsTOC()">
				<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptionsWarnings"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]"/>
				<xsl:if test="exists($nstSection)">
					<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]"
										 mode="TSOPrintOptionsWarnings"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<!-- ========== Standard code for advanced search ========= -->
	<xsl:template name="TSOOutputAdvancedSearch">
		<!-- advance -->
		<xsl:if test="not(leg:IsTOC()) and (leg:IsCurrentRevised(.) or $showInterweaveOption or leg:IsProposedVersion(.)) and not($IsPDFOnly) and not($g_isEUtreaty)">
			<div id="advFeatures" class="section">
				<div class="title">
					<a href="#advFeaturesHelp" class="helpItem helpItemToMidRight">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about advanced features"/>
					</a>
					<h2>
						<xsl:value-of select="leg:TranslateText('Advanced Features')"/>
					</h2>
				</div>
				<div id="advFeaturesContent" class="content">
					<ul class="toolList">
						<xsl:if test="leg:IsCurrentRevised(.)">
							<li class="concVers geoExtent first">
								<xsl:choose>
									<xsl:when test="$forceShowExtent">
										<span class="userFunctionalElement close">
											<xsl:value-of select="leg:TranslateText('Show Geographical Extent')"/>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="view" as="xs:string*"
													  select="tokenize(replace(leg:get-query('view'),'view=',''),'\+')"/>
										<xsl:variable name="href"
													  select="leg:set-query-params('view', string-join(
																	if ($view[. = 'extent']) then $view[. != 'extent']
																	else ($view, 'extent')
																	, '+') )"/>

										<a>
											<xsl:choose>
												<xsl:when test="$showExtent">
													<xsl:attribute name="class">userFunctionalElement close
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>

											<xsl:attribute name="href">
												<xsl:choose>
													<xsl:when test="$href != ''">?<xsl:value-of select="$href"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="$requestInfoDoc/request/request-path"/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:attribute>
											<xsl:value-of select="leg:TranslateText('Show Geographical Extent')"/>
										</a>
									</xsl:otherwise>
								</xsl:choose>
								<!-- translate  -->
								<span>
									<xsl:variable name="constituents" 
										select="for $item in ('England','Wales','Scotland','Northern Ireland') return leg:TranslateText($item)" />
									<xsl:text>(</xsl:text>
									<xsl:value-of select="leg:TranslateText('e.g.')"/>
									<xsl:text> </xsl:text>
									<xsl:for-each select="$constituents">
										<xsl:variable name="pPos" select="position()"/>
										<xsl:for-each select="tokenize(.,' ')">
											<xsl:variable name="head" select="substring(.,1,1)"/>
											<xsl:variable name="tail" select="substring(.,2)" />
											<xsl:value-of select="if(position()>1) then ' ' else ''" /><b><xsl:value-of select="$head"/></b><xsl:value-of select="$tail" />
										</xsl:for-each>
										<xsl:value-of select="
											if(position()!=count($constituents)) then
												if(position()!=count($constituents)-1) then
													', '
												else
													concat(' ',leg:TranslateText('and'),' ')
											else
												''
											"
										/>
									</xsl:for-each>
									<xsl:text>)</xsl:text>
								</span>
							</li>

							<!--
							The checkbox for "Show Timeline of Changes" should be checked if $showTimeline is true and unchecked if $showTimeline is false.
							 The link, when you click on that, should take you to the same URI as the page you are on but with ?timeline=true (if $showTimeline is false) or without the timeline parameter in the URI (if $showTimeline is true).
							-->
							<li>
								<xsl:choose>
									<xsl:when test="$hideTimeline">
										<a class="userFunctionalElement">
											<xsl:attribute name="href">
												<xsl:variable name="href"
															  select="leg:set-query-params('timeline', '' )"/>
												<xsl:choose>
													<xsl:when test="$href != ''">?<xsl:value-of select="$href"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="$requestInfoDoc/request/request-path"/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:attribute>
											<xsl:value-of select="leg:TranslateText('Show Timeline of Changes')"/>
											<xsl:text> </xsl:text>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a class="userFunctionalElement close"
										   href="?{leg:set-query-params('timeline', 'false' )}">
											<xsl:value-of select="leg:TranslateText('Show Timeline of Changes')"/>
										</a>
									</xsl:otherwise>
								</xsl:choose>
							</li>
						</xsl:if>
						<xsl:if test="$showInterweaveOption">
							<li>
								<xsl:variable name="view" as="xs:string*"
											  select="tokenize(replace(leg:get-query('view'),'view=',''),'\+')"/>
								<xsl:variable name="href"
											  select="leg:set-query-params('view', string-join(
															if ($view[. = 'interweave']) then $view[. != 'interweave']
															else ($view, 'interweave')
															, '+') )"/>
								<a>
									<xsl:choose>
										<xsl:when test="$showInterweave">
											<xsl:attribute name="class">userFunctionalElement close</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="href">
										<xsl:choose>
											<xsl:when test="$href != ''">?<xsl:value-of select="$href"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$requestInfoDoc/request/request-path"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<xsl:value-of select="leg:TranslateText('Show Explanatory Notes for Sections')"/>
									<xsl:text> </xsl:text>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="leg:IsProposedVersion(.)">
							<li>
								<xsl:choose>
									<xsl:when test="$showRepeals">
										<a class="userFunctionalElement close">
											<xsl:attribute name="href">
												<xsl:variable name="href"
															  select="leg:set-query-params('repeals', '' )"/>
												<xsl:choose>
													<xsl:when test="$href != ''">?<xsl:value-of select="$href"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="$requestInfoDoc/request/request-path"/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:attribute>
											<xsl:value-of select="leg:TranslateText('Show Repeals')"/>
											<xsl:text> </xsl:text>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a class="userFunctionalElement"
										   href="?{leg:set-query-params('repeals', 'true' )}">
											<xsl:value-of select="leg:TranslateText('Show Repeals')"/>
										</a>
									</xsl:otherwise>
								</xsl:choose>
							</li>
						</xsl:if>

					</ul>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- ========== Standard code for opening options ========= -->
	<xsl:template name="TSOOutputOpeningOptions">
		<xsl:if test="(leg:IsTOC() or leg:IsContentTabDisplaying()) and not($IsPDFOnly)">
			<div class="section" id="openingOptions">
				<div class="title">
					<a href="#openingOptionsHelp" class="helpItem helpItemToMidRight">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about opening options"/>
					</a>
					<h2>
						<xsl:value-of select="leg:TranslateText('Opening Options')"/>
					</h2>
				</div>
				<div id="openingOptionsContent" class="content">
					<ul class="toolList">
						<xsl:if test="$g_strwholeActURI != ''">
							<li class="whole">
								<a>
									<xsl:choose>
										<xsl:when
												test="xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:TotalParagraphs/@Value) > $paragraphThreshold">
											<xsl:attribute name="href" select="'#openingWholeMod'"/>
											<xsl:attribute name="class" select="'warning'"/>
										</xsl:when>
										<xsl:when test="leg:IsTOC()">
											<xsl:attribute name="href"
														   select="concat(leg:FormatURL($g_strwholeActURI, false()), $contentsLinkParams, $linkFragment)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href" select="leg:FormatURL($g_strwholeActURI)"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:variable name="wholeActText">
										<xsl:text>Open whole </xsl:text>
										<xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/>
									</xsl:variable>
									<xsl:value-of select="leg:TranslateText($wholeActText)"/>
								</a>
							</li>
						</xsl:if>

						<xsl:if test="$g_wholeActWithoutSchedulesURI != '' and ($g_schedulesOnlyURI != '' or $g_attachmentsOnlyURI != '')">
							<li class="minusSched">
								<a>
									<xsl:choose>
										<xsl:when
												test="xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:BodyParagraphs/@Value) > $paragraphThreshold">
											<xsl:attribute name="href" select="'#openingWholeWithoutSchedulesMod'"/>
											<xsl:attribute name="class" select="'warning'"/>
										</xsl:when>
										<xsl:when test="leg:IsTOC()">
											<xsl:attribute name="href"
														   select="concat(leg:FormatURL($g_wholeActWithoutSchedulesURI, false()), $contentsLinkParams, $linkFragment)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href"
														   select="leg:FormatURL($g_wholeActWithoutSchedulesURI)"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:variable name="wholeActText">
										<xsl:text>Open </xsl:text>
										<xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/>
										<xsl:text> without </xsl:text>
										<xsl:if test="$g_schedulesOnlyURI != ''">
											<xsl:value-of select="$schedulesText"/>
										</xsl:if>
										<xsl:if test="$g_schedulesOnlyURI != '' and $g_attachmentsOnlyURI != ''">
											<xsl:text> or </xsl:text>
										</xsl:if>
										<xsl:if test="$g_attachmentsOnlyURI != ''">
											<xsl:text> Attachments</xsl:text>
										</xsl:if>
									</xsl:variable>
									<xsl:value-of select="leg:TranslateText(normalize-space($wholeActText))"/>
								</a>
							</li>
						</xsl:if>

						<xsl:if test="$g_schedulesOnlyURI != ''">
							<li class="onlySched">
								<a>
									<xsl:choose>
										<xsl:when
												test="xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:ScheduleParagraphs/@Value) > $paragraphThreshold">
											<xsl:attribute name="href" select="'#openingSchedulesOnlyMod'"/>
											<xsl:attribute name="class" select="'warning'"/>
										</xsl:when>
										<xsl:when test="leg:IsTOC()">
											<xsl:attribute name="href"
														   select="concat(leg:FormatURL($g_schedulesOnlyURI, false()), $contentsLinkParams, $linkFragment)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href" select="leg:FormatURL($g_schedulesOnlyURI)"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:value-of select="leg:TranslateText(concat('Open ', $schedulesText, ' only'))"/>
								</a>
							</li>
						</xsl:if>

						<xsl:if test="$g_attachmentsOnlyURI != ''">
							<li class="onlySched">
								<a>
									<xsl:choose>
										<xsl:when
												test="xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:AttachmentParagraphs/@Value) > $paragraphThreshold">
											<xsl:attribute name="href" select="'#openingAttachmentsOnlyMod'"/>
											<xsl:attribute name="class" select="'warning'"/>
										</xsl:when>
										<xsl:when test="leg:IsTOC()">
											<xsl:attribute name="href"
														   select="concat(leg:FormatURL($g_attachmentsOnlyURI, false()), $contentsLinkParams, $linkFragment)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href" select="leg:FormatURL($g_attachmentsOnlyURI)"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:value-of
											select="leg:TranslateText(concat('Open ', $attachmentsText, ' only'))"/>
								</a>
							</li>
						</xsl:if>

					</ul>
				</div>
			</div>
		</xsl:if>


	</xsl:template>


	<xsl:template name="TSOOutputOpeningOptionsWarning">
		<xsl:if test="((leg:IsTOC() or leg:IsContent()) and not($IsPDFOnly)) or ($g_strwholeActURI = $dcIdentifier or $g_wholeActWithoutSchedulesURI = $dcIdentifier or $g_schedulesOnlyURI = $dcIdentifier or $g_attachmentsOnlyURI = $dcIdentifier)">
			<xsl:if test="$g_strwholeActURI != '' and xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:TotalParagraphs/@Value) > $paragraphThreshold ">
				<xsl:call-template name="TSOOutputWarningMessage">
					<xsl:with-param name="messageId" select="'openingWholeMod' "/>
					<xsl:with-param name="messageType" select=" 'openingWholeWarning' "/>
					<xsl:with-param name="messageHeading"
									select="concat(leg:TranslateText('You have chosen to open'),' ', leg:TranslateText(concat('the Whole ', tso:GetCategory(leg:GetDocumentMainType(.)))))"/>
					<xsl:with-param name="message" select="
						concat(
						leg:TranslateText(concat('The Whole ',tso:GetCategory(leg:GetDocumentMainType(.)))),
							' ',
							leg:TranslateText('EN_selected_count', concat('count=',$paragraphThreshold)),
							leg:TranslateText('Browser_warning')
						)"/>
					<xsl:with-param name="continueURL"
									select="if (leg:IsTOC()) then concat(leg:FormatURL($g_strwholeActURI, false()), $contentsLinkParams, $linkFragment) else leg:FormatURL($g_strwholeActURI)"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$g_wholeActWithoutSchedulesURI != '' and $g_schedulesOnlyURI != '' and xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:BodyParagraphs/@Value) > $paragraphThreshold">

				<xsl:call-template name="TSOOutputWarningMessage">
					<xsl:with-param name="messageId" select="'openingWholeWithoutSchedulesMod' "/>
					<xsl:with-param name="messageType" select=" 'openingWholeWithoutSchedulesWarning' "/>
					<xsl:with-param name="messageHeading"
									select="concat(leg:TranslateText('You have chosen to open'),' ', leg:TranslateText(concat('the Whole ', tso:GetCategory(leg:GetDocumentMainType(.)))),' ',leg:TranslateText(concat('without ',$schedulesText)))"/>
					<xsl:with-param name="message" select="
						concat(
						leg:TranslateText(concat('The Whole ',tso:GetCategory(leg:GetDocumentMainType(.)))),
						' ',
						leg:TranslateText(concat('without ', $schedulesText)),
						' ',
						leg:TranslateText('EN_selected_count', concat('count=',$paragraphThreshold)),
						leg:TranslateText('Browser_warning')
						)"/>
					<xsl:with-param name="continueURL"
									select="if (leg:IsTOC()) then concat(leg:FormatURL($g_wholeActWithoutSchedulesURI, false()), $contentsLinkParams, $linkFragment) else leg:FormatURL($g_wholeActWithoutSchedulesURI)"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$g_schedulesOnlyURI != '' and xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:ScheduleParagraphs/@Value) > $paragraphThreshold">
				<xsl:call-template name="TSOOutputWarningMessage">
					<xsl:with-param name="messageId" select="'openingSchedulesOnlyMod' "/>
					<xsl:with-param name="messageType" select=" 'openingSchedulesOnlyWarning' "/>
					<xsl:with-param name="messageHeading" select="leg:TranslateText('Schedules_only')"/>
					<xsl:with-param name="message" select="
						concat(
						leg:TranslateText('The Schedules'),
						' ',
						leg:TranslateText('EN_selected_count', concat('count=',$paragraphThreshold)),
						leg:TranslateText('Browser_warning')
						)"/>
					<xsl:with-param name="continueURL"
									select="if (leg:IsTOC()) then concat(leg:FormatURL($g_schedulesOnlyURI, false()), $contentsLinkParams, $linkFragment) else leg:FormatURL($g_schedulesOnlyURI)"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$g_attachmentsOnlyURI != '' and xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:AttachmentParagraphs/@Value) > $paragraphThreshold">
				<xsl:call-template name="TSOOutputWarningMessage">
					<xsl:with-param name="messageId" select="'openingAttachmentsOnlyMod' "/>
					<xsl:with-param name="messageType" select=" 'openingAttachmentsOnlyWarning' "/>
					<xsl:with-param name="messageHeading" select="leg:TranslateText('Attachments_only')"/>
					<xsl:with-param name="message" select="
						concat(
						leg:TranslateText('The Attachments'),
						' ',
						leg:TranslateText('EN_selected_count', concat('count=',$paragraphThreshold)),
						leg:TranslateText('Browser_warning')
						)"/>
					<xsl:with-param name="continueURL"
									select="if (leg:IsTOC()) then concat(leg:FormatURL($g_attachmentsOnlyURI, false()), $contentsLinkParams, $linkFragment) else leg:FormatURL($g_attachmentsOnlyURI)"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- Text of tooltip has been put in resource.xml for english and welsh version -->
	<xsl:template name="TSOOutputHelpTips">
		<div class="help" id="whatversionHelp">
			<span class="icon"/>
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif"/>
				</a>
				<h3>
					<xsl:value-of select="leg:TranslateText('whatversionHelp_head')"/>
				</h3>

				<p>
					<b>
						<xsl:value-of select="leg:TranslateText('whatversionHelp_para1_bold')"/>
					</b>
					<xsl:value-of select="leg:TranslateText('whatversionHelp_para1_text')"/>
					<xsl:if test="leg:IsWelshExists(.)">
						<xsl:text> </xsl:text>
						<xsl:value-of select="leg:TranslateText('whatversionHelp_para1_text_welsh')"/>
					</xsl:if>
				</p>
				<xsl:choose>
					<xsl:when test="$g_strDocumentMainType = ('UnitedKingdomMinisterialDirection', 'UnitedKingdomMinisterialOrder')">
						<p>
							<b>
								<xsl:value-of select="leg:TranslateText('whatversionHelp_para_created_bold')"/>
								<xsl:text>: </xsl:text>
							</b>
							<xsl:value-of select="leg:TranslateText('The original')"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="leg:TranslateText('whatversionHelp_para_created_text')"/>
						</p>
					</xsl:when>
					<xsl:when test="$g_isEURetainedOrEUTreaty">
						<p>
							<b>
								<xsl:value-of select="leg:TranslateText('Original (As adopted)')"/>
								<xsl:text>: </xsl:text>
							</b>
							<xsl:value-of select="leg:TranslateText('The original')"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="leg:TranslateText('whatversionHelp_para_eu_text')"/>
						</p>
					</xsl:when>
					<xsl:otherwise>
						<p>
							<b>
								<xsl:value-of select="leg:TranslateText('whatversionHelp_para2_bold')"/>
								<xsl:if test="leg:IsWelshExists(.)">
									<xsl:text> - </xsl:text>
									<xsl:value-of select="leg:TranslateText('whatversionHelp_para2_bold_1')"/>
								</xsl:if>
								<xsl:text>: </xsl:text>
							</b>
							<xsl:value-of select="leg:TranslateText('The original')"/>
							<xsl:text> </xsl:text>
							<xsl:if test="leg:IsWelshExists(.)">
								<xsl:value-of select="leg:TranslateText('English language')"/>
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:value-of select="leg:TranslateText('whatversionHelp_para2_text')"/>
						</p>
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:if test="leg:IsWelshExists(.)">
					<p>
						<b>
							<xsl:value-of select="leg:TranslateText('whatversionHelp_para3_bold')"/>
						</b>
						<xsl:value-of select="leg:TranslateText('whatversionHelp_para3_text')"/>
					</p>
				</xsl:if>
				<xsl:if test="$pointInTimeView">
					<xsl:choose>
						<xsl:when test="$version castable as xs:date">
							<p>
								<b><xsl:value-of select="leg:TranslateText('Point in Time')"/>:
								</b>
								<xsl:value-of select="leg:TranslateText('PIT_toc_1')"/>
								<xsl:if test="leg:IsWelshExists(.)">
									<xsl:text> </xsl:text>
									<xsl:value-of select="leg:TranslateText('PIT_toc_2')"/>
								</xsl:if>
							</p>
						</xsl:when>
						<xsl:when test="$version ='prospective' ">
							<p>
								<b><xsl:value-of select="leg:TranslateText('Latest with prospective')"/>:
								</b>
								<xsl:value-of select="leg:TranslateText('Latest_toc_1')"/>
							</p>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</div>
		</div>

		<xsl:if test="not(leg:IsTOC()) and (leg:IsCurrentRevised(.) or $showInterweaveOption or leg:IsProposedVersion(.))">
			<div class="help" id="advFeaturesHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>
						<xsl:value-of select="leg:TranslateText('Interweave_toc_1')"/>
					</h3>
					<xsl:choose>
						<xsl:when test="$showInterweaveOption">
							<p>
								<b><xsl:value-of select="leg:TranslateText('Show Explanatory Notes for Sections')"/>:
								</b>
								<xsl:value-of select="leg:TranslateText('Interweave_toc_2')"/>
							</p>
						</xsl:when>
						<xsl:when test="leg:IsProposedVersion(.)">
							<p>
								<b><xsl:value-of select="leg:TranslateText('Show Repeals')"/>:
								</b>
								<xsl:value-of select="leg:TranslateText('Displays the repeals')"/>
							</p>
						</xsl:when>
						<xsl:otherwise>
							<p>
								<b><xsl:value-of select="leg:TranslateText('Geographical Extent')"/>:
								</b>
								<xsl:value-of select="leg:TranslateText('Interweave_toc_3')"/>
							</p>
							<p>
								<b><xsl:value-of select="leg:TranslateText('Show Timeline of Changes')"/>:
								</b>
								<xsl:value-of select="leg:TranslateText('Interweave_toc_4')"/>
							</p>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:if>

		<!-- Help text is moved to resource.xml to have different test for welsh and english -->
		<xsl:if test="(leg:IsTOC() or leg:IsContentTabDisplaying()) and not($IsPDFOnly)">
			<div class="help" id="openingOptionsHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>
						<xsl:value-of select="leg:TranslateText('openingOptionsHelp_head')"/>
					</h3>
					<p>
						<xsl:value-of select="leg:TranslateText('openingOptionsHelp_para')"/>
					</p>
				</div>
			</div>
		</xsl:if>

		<!-- displaying the output help tips for EN/EM tabs -->
		<xsl:call-template name="TSOOutputENsHelpTips"/>

		<xsl:if test="$showTimeline and leg:IsCurrentRevised(.)">
			<div class="help" id="timelineHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>
						<xsl:value-of select="leg:TranslateText('Timeline of Changes')"/>
					</h3>
					<xsl:choose>
						<xsl:when test="$isEULeg">
							<p><xsl:value-of select="leg:TranslateText('Revised_toc_eu_1')"/></p>
							<p><xsl:value-of select="leg:TranslateText('Revised_toc_eu_2')"/></p>
							<p><xsl:value-of select="leg:TranslateText('Revised_toc_eu_3')"/></p>
						</xsl:when>
						<xsl:otherwise>
							<p><xsl:value-of select="leg:TranslateText('Revised_toc_1')"/></p>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="exists(/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative) or exists(/leg:Legislation/ukm:Metadata/ukm:CorrectionSlips/ukm:CorrectionSlip)">
			<div class="help" id="moreResourcesHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>
						<xsl:value-of select="leg:TranslateText('moreResourcesHelp_head')"/>
					</h3>
					<p>
						<xsl:value-of select="leg:TranslateText('moreResourcesHelp_para1')"/>
					</p>
					<ul>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul_li_1_part1')"/><xsl:text> </xsl:text><xsl:value-of
								select="leg:TranslateText(leg:GetCodeSchemaStatus(.))"/><xsl:text> </xsl:text><xsl:value-of
								select="leg:TranslateText('moreResourcesHelp_ul_li_1_part3')"/>
						</li>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul_li_2')"/>
						</li>
					</ul>
					<p></p>
					<p>
						<xsl:value-of select="leg:TranslateText('moreResourcesHelp_para2')"/>
					</p>
					<ul>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_1')"/>
						</li>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_2')"/>
						</li>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_3')"/>
						</li>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_4')"/>
						</li>
					</ul>
				</div>
			</div>
		</xsl:if>

	</xsl:template>

	<!-- ========== Standard code for outputing legislation status/timeline ========= -->
	<xsl:template name="TSOOutputLegislationStatusTimeline">

		<xsl:if test="leg:IsContent() or $g_strwholeActURI = $dcIdentifier or $g_wholeActWithoutSchedulesURI = $dcIdentifier or $g_schedulesOnlyURI = $dcIdentifier">
			<!-- adding the changes over time -->
			<xsl:call-template name="TSOOutputChangesOverTime"/>
		</xsl:if>

		<!-- adding the update status warning-->
		<xsl:call-template name="TSOOutputUpdateStatusMessage">
			<xsl:with-param name="AddAppliedEffects" select="leg:IsContent()"/>
			<xsl:with-param name="includeTooltip" select="tso:IncludeInlineTooltip()"/>
		</xsl:call-template>

		<!-- adding search information box -->
		<xsl:if test="$searchingByExtent or $searchingByText">
			<xsl:call-template name="TSOOutputSearchInformationMessage"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="TSOOutputSearchInformationMessage">
		<xsl:variable name="messages" as="document-node()*">
			<xsl:if test="$searchingByText">
				<xsl:document>contain the text '
					<strong>
						<xsl:value-of select="$searchingByText"/>
					</strong>
					'
				</xsl:document>
			</xsl:if>
			<xsl:if test="$searchingByExtent">
				<xsl:document>
					<xsl:choose>
						<xsl:when test="starts-with($searchingByExtent, '=')">
							<xsl:text>exclusively extend to </xsl:text>
							<xsl:sequence
									select="tso:extentDescription(tokenize(substring($searchingByExtent, 2), '\+'), ' and ', true())"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>are applicable to </xsl:text>
							<xsl:sequence
									select="tso:extentDescription(tokenize($searchingByExtent, '\+'), ' or ', true())"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:document>
			</xsl:if>
		</xsl:variable>
		<div id="infoSection">
			<h2>Information:</h2>
			<p class="intro">
				<xsl:text>You searched for provisions that </xsl:text>
				<xsl:for-each select="$messages">
					<xsl:sequence select="node()"/>
					<xsl:if test="position() != last()">and</xsl:if>
				</xsl:for-each>
				<xsl:text>. The matching provisions are highlighted below.  Where no highlighting is shown the matching result may be contained within a footnote.</xsl:text>
			</p>
		</div>
	</xsl:template>


	<xsl:function name="leg:GetWidthInPixels">
		<xsl:param name="numberOfDays" as="xs:decimal"/>
		<xsl:param name="minWidth" as="xs:integer"/>


		<xsl:variable name="minRangeWidth" select="20"/>
		<xsl:variable name="minRange" select="1"/>

		<xsl:variable name="numberOfYears" as="xs:decimal" select="$numberOfDays div 365"/>
		<xsl:choose>
			<xsl:when test="$arrangePointersEqually">
				<xsl:value-of select="$minWidth"/>
			</xsl:when>
			<xsl:when test="$numberOfYears &lt;= 0.5 ">
				<xsl:value-of select="xs:integer($minWidth div 1.5)"/>
			</xsl:when>
			<xsl:when test="$numberOfYears &lt;= $minRange">
				<xsl:value-of select="xs:integer($numberOfYears * $minWidth)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of
						select="xs:integer(($minRange * $minWidth) + ($numberOfYears - $minRange) * $minRangeWidth)"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>

	<xsl:function name="leg:FormatHTMLDataURL" as="xs:string">
		<xsl:param name="url"/>

		<xsl:sequence
				select="concat($TranslateLangPrefix,tso:remove-extent(substring-after($url,concat('http://www.legislation.gov.uk',$TranslateLangPrefix))), '/data.xht','?view=snippet&amp;wrap=true') "/>
	</xsl:function>

	<xsl:function name="leg:FormatPDFDataURL" as="xs:string">
		<xsl:param name="url"/>
		<!-- #395 we need to carry the extent query through so that the PDF generation knows about it -->
		<xsl:variable name="strQuery" as="xs:string?">
			<xsl:choose>
				<xsl:when
						test="contains(leg:get-query('view'), 'extent') and contains(leg:get-query('repeals'), 'true')">
					<xsl:text>?view=extent&amp;repeals=true</xsl:text>
				</xsl:when>
				<xsl:when test="contains(leg:get-query('view'), 'extent')">
					<xsl:text>?view=extent</xsl:text>
				</xsl:when>
				<xsl:when test="contains(leg:get-query('repeals'), 'true')">
					<xsl:text>?repeals=true</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence
				select="concat( tso:remove-extent(substring-after($url,'http://www.legislation.gov.uk')), '/data.pdf',$strQuery)"/>
	</xsl:function>

	<xsl:function name="leg:FormatURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:sequence select="leg:FormatURL($url, true())"/>
	</xsl:function>
	<xsl:function name="leg:FormatURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:param name="addQueryString" as="xs:boolean"/>
		<xsl:choose>
			<xsl:when test="string-length($url) ne 0">
				<!-- todo: post launch <xsl:value-of select="string-join((substring-after($url,'http://www.legislation.gov.uk'), $requestInfoDoc/request/request-querystring), '?')"/>-->
				<xsl:value-of
						select="concat(substring-after($url,'http://www.legislation.gov.uk'), if ($requestInfoDoc/request/query-string != '' and $addQueryString) then concat('?',$requestInfoDoc/request/query-string) else '') "/>
			</xsl:when>
			<xsl:otherwise>
				<!-- if the $url is not available then link to the same page -->
				<xsl:value-of
						select="string-join((leg:RemoveDomainFromURI($requestInfoDoc/request/request-url), if ($addQueryString) then $requestInfoDoc/request/request-querystring else ()), '?')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="leg:RemoveDomainFromURI" as="xs:string">
		<xsl:param name="uri"/>
		<xsl:sequence
				select="if (matches($uri, '^http[s]?://')) then
						concat('/', string-join((tokenize(replace($uri, '^http[s]?://', ''), '/'))[not(position() = 1)], '/'))
					else $uri"/>
	</xsl:function>

	<!-- removing the extent information from the  PDF/HTM URL-->
	<xsl:function name="tso:remove-extent">
		<xsl:param name="url" as="xs:string"/>
		<xsl:variable name="removeExtent" as="xs:string+">
			<xsl:variable name="tokens" as="xs:string+" select="tokenize($url, '/')"/>
			<xsl:for-each select="$tokens">
				<xsl:choose>
					<!-- Chunyu HA049961 Added the condition for crossheading which need to keep the extent see http://www.legislation.gov.uk/ukpga/1997/40/crossheading/england-and-wales -->
					<xsl:when
							test="position() = last() and matches(., '^(england|wales|scotland|ni)(\+(england|wales|scotland|ni))*$') and not($tokens[position() - 1] = 'crossheading')"/>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="string-join($removeExtent, '/')"/>
	</xsl:function>


	<xsl:function name="leg:GetVersionDate" as="xs:date">
		<xsl:param name="versionDate" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="$versionDate castable as xs:date">
				<xsl:sequence select="xs:date($versionDate)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="current-date()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="leg:IsContentTabDisplaying" as="xs:boolean">
		<xsl:choose>
			<xsl:when
					test="leg:IsContent() or $g_strwholeActURI = $dcIdentifier or $g_wholeActWithoutSchedulesURI = $dcIdentifier or $g_schedulesOnlyURI = $dcIdentifier">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="leg:pdf-language" as="xs:string?">
		<xsl:param name="pdf-item" as="element()"/>
		<xsl:if test="(not($pdf-item/@Title) and count($g_pdfVersions[not(@Revised)][not(@Title)]) > 1) or
			(if ($pdf-item/@Title = ('', 'Print Version', 'Mixed Language Measure')) then
				count($g_pdfVersions[not(@Revised)][@Title = ('', 'Print Version', 'Mixed Language Measure')]) > 1
			else
				count($g_pdfVersions[not(@Revised)][@Title = $pdf-item/@Title]) > 1)">
			<xsl:value-of>
				<xsl:choose>
					<xsl:when test="$pdf-item/@Language = 'Mixed'">
						<xsl:text> - </xsl:text>
						<xsl:value-of select="leg:TranslateText('PDF_Mixed_Language')"/>
					</xsl:when>
					<xsl:when test="exists($pdf-item/@Language)">
						<xsl:text> - </xsl:text>
						<xsl:value-of select="$pdf-item/@Language" />
					</xsl:when>
					<xsl:when test="matches($pdf-item/@URI, '_en(_[0-9]{3})?.pdf$')">
						<xsl:text> - </xsl:text>
						<xsl:value-of select="leg:TranslateText('PDF_English')"/>
					</xsl:when>
					<xsl:when test="matches($pdf-item/@URI, '_we(_[0-9]{3})?.pdf$')">
						<xsl:text> - </xsl:text>
						<xsl:value-of select="leg:TranslateText('PDF_Welsh')"/>
					</xsl:when>
					<xsl:when test="matches($pdf-item/@URI, '_mi(_[0-9]{3})?.pdf$')">
						<xsl:text> - </xsl:text>
						<xsl:value-of select="leg:TranslateText('PDF_Mixed_Language')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:value-of>
		</xsl:if>
	</xsl:function>

	<!-- Hiding the legislation notifications as requested by TNA Issue 234 -->
	<xsl:template name="FuncLegNotification"/>

</xsl:stylesheet>
