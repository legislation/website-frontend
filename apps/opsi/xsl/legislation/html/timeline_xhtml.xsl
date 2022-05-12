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


	<xsl:variable name="showTimeline" select="true()"/>
	
	<!-- use a variable for the current date so we can easily test and debug future views  -->
	<xsl:variable name="currentdate" as="xs:date" select="current-date()"/>
	<!--<xsl:variable name="currentdate" as="xs:date" select="xs:date('2021-10-31')"/>-->

	<xsl:template name="TSOOutputChangesOverTime">

		<!-- If $showTimeline is true then the Status area should be above the Changes to legislation area, and the timeline should be visible. -->

		<!-- The timeline is only shown if $showTimeline is true. -->
		<xsl:if test="not($hideTimeline) and leg:IsCurrentRevised(.) and not($g_isEUtreaty)">

			<!-- default link of the item-->
			<xsl:variable name="linkHRef" as="xs:string?"
						  select="(/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'current']/@href, /leg:Legislation/ukm:Metadata/dc:identifier)[1]"/>
						  
			<!-- this is for debugging purposes and adds in dummy atom links 
				add the variable into the for-each in $otherVersions -->			  
			<xsl:variable name="dummyEnd" as="element()*">
				<!--<atom:link rel="http://www.legislation.gov.uk/def/date/euexitTransitionEnd" href="http://www.legislation.gov.uk/eur/2015/2456/contents/2020-12-31" title="2020-12-31"/>-->
				<!--<atom:link rel="http://purl.org/dc/terms/hasVersion" href="http://www.legislation.gov.uk/eur/2013/1303/annex/vi/2019-12-31" title="2019-12-31"/>
				<atom:link rel="http://purl.org/dc/terms/hasVersion" href="http://www.legislation.gov.uk/eur/2013/1303/annex/vi/2020-12-31" title="2020-12-31"/>-->
				</xsl:variable>

			<!-- let $otherVersions be a list of versions that are available for the section -->
			<xsl:variable name="otherVersions" as="element()*">
				<xsl:variable name="links" as="element(atom:link)*">
					<xsl:for-each select="$dummyEnd, /leg:Legislation/ukm:Metadata/atom:link[@rel= ('http://purl.org/dc/terms/hasVersion', 'http://www.legislation.gov.uk/def/date/euexitday', 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd') and tokenize(@title, ' ')[. castable as xs:date or . = 'prospective']]">
						<xsl:sort select="@title[not(. castable as xs:date)]"/>
						<xsl:sort select="@title[. castable as xs:date]"/>
						<xsl:copy-of select="."/>
					</xsl:for-each>

				</xsl:variable>
				
				<xsl:variable name="links" as="element(atom:link)*">

					<xsl:variable name="euexitday" select="$links[@rel= 'http://www.legislation.gov.uk/def/date/euexitday']"/>
					<xsl:variable name="euendTransitionDay" select="$links[@rel= 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd']"/>
					
					<xsl:variable name="dates" as="xs:date*" select="(for $date in $links[not(@rel = ('http://www.legislation.gov.uk/def/date/euexitday', 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd'))][@title castable as xs:date]/@title return xs:date($date))"/>
					
					<xsl:for-each select="$links">

						<xsl:variable name="currentPos" select="position()" as="xs:integer"/>
						<xsl:variable name="isExitDay" select="@rel = 'http://www.legislation.gov.uk/def/date/euexitday'"/>
						<xsl:variable name="isEndTransitionDay" select="@rel = 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd'"/>
						<xsl:variable name="linkVersion"
									  select="tokenize(@title, ' ')[. castable as xs:date or . = 'prospective']"/>
						<xsl:variable name="repealedVersion" as="xs:boolean"
									  select="tokenize(@title, ' ') = 'repealed'"/>
						<xsl:variable name="previousLink" select="$links[$currentPos - 1]" as="element(atom:link)?"/>
						<xsl:variable name="hasPitExitDate" select="$euexitday/@title = ($links[not($euexitday)]/@title, $startDate)"/>
						<xsl:variable name="previousVersion"
									  select="tokenize($previousLink/@title, ' ')[. castable as xs:date or . = 'prospective']"/>
						<xsl:variable name="thisversion" as="xs:string"
									  select="if ($version = '') then xs:string($currentdate) else $version"/>

						<!-- add $startDate if the current title is valid and and greater than $startDate and preceding date is less than $startDate -->
						<xsl:if test="
						(($startDate castable as xs:date)
							and ($linkVersion castable as xs:date)
							and xs:date($linkVersion) > xs:date($startDate)
							and (
								not($previousVersion castable as xs:date) or
								xs:date($previousVersion) &lt; xs:date($startDate)
							))">
							<atom:link rel="http://purl.org/dc/terms/hasVersion"
									   href="{concat($linkHRef, '/', $startDate)}" title="{$startDate}"
									   iscurrent="true">
								<xsl:if test="$startDate = $euexitday/@title">
									<xsl:attribute name="euexitday" select="'true'"/>
								</xsl:if>
								<xsl:if test="$startDate = $euendTransitionDay/@title">
									<xsl:attribute name="euendTransitionDay" select="'true'"/>
								</xsl:if>
							</atom:link>
						</xsl:if>

						<!-- add $startDate if the current is prospective and preceding date is less than $startDate -->
						<xsl:if test="($startDate castable as xs:date)
							and $linkVersion = 'prospective'
							and (
								not($previousVersion castable as xs:date)
								or xs:date($previousVersion) &lt; xs:date($startDate)
							)">
							<atom:link rel="http://purl.org/dc/terms/hasVersion"
									   href="{concat( $linkHRef, '/', $startDate)}" title="{$startDate}"
									   iscurrent="true"/>
						</xsl:if>

						<xsl:choose>
							<!-- prosps do not occur in eu retained data so treat this as per the old methods -->
							<xsl:when test="$linkVersion = 'prospective' or $thisversion = 'prospective'">
								<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{@href}" title="{$linkVersion}">
									<xsl:if test="$repealedVersion">
										<xsl:attribute name="repealed" select="'true'"/>
									</xsl:if>
								</atom:link>
							</xsl:when>
							<xsl:when test="($isExitDay or $isEndTransitionDay)
								and ($startDate castable as xs:date)
								and ($linkVersion castable as xs:date)
								and ((xs:date($linkVersion) = xs:date($startDate)
									and not($linkVersion = ($links[@rel = 'http://purl.org/dc/terms/hasVersion']/@title)))
								)">
							<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{@href}" title="{$linkVersion}" iscurrent="true">
									<xsl:attribute name="{if ($isExitDay) then 'euexitday' else 'euendTransitionDay'}" select="'true'"/>
								</atom:link>
							</xsl:when>
							<xsl:when test="($isExitDay or $isEndTransitionDay) 
								and ($startDate castable as xs:date)
								and ($linkVersion castable as xs:date)
								and ((xs:date($linkVersion) = xs:date($startDate)
									and not($linkVersion = ($links[@rel = 'http://purl.org/dc/terms/hasVersion']/@title)))
								or @title = ($links[@rel = 'http://purl.org/dc/terms/hasVersion']/@title))">
							</xsl:when>
							<xsl:otherwise>
								<atom:link rel="{@rel}" href="{@href}" title="{$linkVersion}" min="{($links/@title)}"  max="{min($dates[. gt xs:date($thisversion)])}" endtrans="{$isEndTransitionDay}" >
									<xsl:if test="$repealedVersion">
										<xsl:attribute name="repealed" select="'true'"/>
									</xsl:if>
									<xsl:if test="(($isEndTransitionDay or $isExitDay) and max($dates) lt xs:date($euexitday/@title) and max($dates) lt xs:date($euendTransitionDay/@title) and xs:date($thisversion) ge max($dates)) or
										($thisversion = $links/@title and xs:date($thisversion) ge max($dates) and xs:date(@title) ge max($dates))
										">
										<xsl:attribute name="iscurrent" select="'true'"/>
									</xsl:if>
									<xsl:if test="@rel = 'http://purl.org/dc/terms/hasVersion' and 
										@title = $euexitday/@title">
										<xsl:attribute name="euexitday" select="'true'"/>
									</xsl:if>
									<xsl:if test="@rel = 'http://purl.org/dc/terms/hasVersion' and 
										@title = $euendTransitionDay/@title">
										<xsl:attribute name="euendTransitionDay" select="'true'"/>
									</xsl:if>
								</atom:link>
							</xsl:otherwise>
						</xsl:choose>
						
						

						<!-- add $startDate in the last if it is not added -->
						<xsl:if test="($startDate castable as xs:date)
							and ($linkVersion castable as xs:date)
							and (xs:date($linkVersion) &lt; xs:date($startDate)
							and position() = last()
						)">
							<atom:link rel="http://purl.org/dc/terms/hasVersion"
									   href="{concat( $linkHRef, '/', $startDate)}" title="{$startDate}"
									   iscurrent="true"/>
						</xsl:if>
					</xsl:for-each>

				</xsl:variable>

				<!-- if  there are no links available and startDate is valid  -->
				<xsl:if test="$startDate castable as xs:date and count($links) = 0">
					<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{concat( $linkHRef, '/', $startDate)}"
							   title="{$startDate}" iscurrent="true"/>
				</xsl:if>

				<!-- if $startdate is not provided and there is not 'Prospective' status and $baseDate is not in the $links then add the base date -->
				<xsl:if test="empty($startDate) and not($prospective) and not(exists($links[@title = $baseDate]) )">
					<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{concat($linkHRef, '/', $baseDate)}"
							   title="{$baseDate}"/>
				</xsl:if>

				<!-- if repealed then ignore all the @title castable as xs:date and greater than $enddate -->
				<xsl:choose>
					<xsl:when test="$repealed">
						<xsl:sequence
								select="$links[not(tokenize(@title, ' ')[. castable as xs:date]) or xs:date(tokenize(@title, ' ')[. castable as xs:date]) &lt;= xs:date($endDate)]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="$links"/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:variable>

			<!-- minimum width of each bar-->
			<xsl:variable name="minWidth" select="140"/>

			<!--
		  - pointers for each available version of the section ($versions), which will include
			- normal pointers for each date listed in $versions
			- a pointer for the prospective version, if there is one
			- if $repealed is true, a pointer for the $endDate
		-->
			<xsl:variable name="pointers">
				<xsl:for-each select="$otherVersions">
					<xsl:variable name="pos" select="position()"/>
					<!-- finding the number of the between the current and previous version-->
					<xsl:variable name="numberOfDays">
						<xsl:choose>
							<xsl:when
									test="@title castable as xs:date and $otherVersions[$pos+1]/@title castable as xs:date">
								<xsl:variable name="versionDate" as="xs:date" select="xs:date(@title)"/>
								<xsl:variable name="nextVersionDate" as="xs:date"
											  select="xs:date($otherVersions[$pos+1]/@title)"/>
								<xsl:variable name="numberOfDaysFormatted"
											  select="translate(xs:string($nextVersionDate - $versionDate ), 'PD', '')"/>
								<xsl:choose>
									<xsl:when test="$numberOfDaysFormatted castable as xs:integer">
										<xsl:value-of select="xs:integer($numberOfDaysFormatted)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="0"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="0"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<leg:pointer numberOfDays="{$numberOfDays}">
						<xsl:copy-of select="@*"/>
					</leg:pointer>

				</xsl:for-each>

				<!-- if $prospective and prospective is not in the versions -->
				<xsl:if test="$prospective and not($otherVersions[@title = 'prospective'])">
					<leg:pointer
							href="{concat($linkHRef, '/', if ($repealed) then (xs:date($endDate) - xs:dayTimeDuration('P1D')) else 'prospective' )}"
							title="prospective" numberOfDays="0"/>
				</xsl:if>

				<!-- if the current section is repealed and there is no repealed exists in the versions then add it  -->
				<xsl:if test="$repealed and not($otherVersions[@repealed])">
					<leg:pointer href="{concat($linkHRef, '/', $endDate)}" title="{$endDate}" repealed="true"
								 numberOfDays="0"/>
				</xsl:if>
			</xsl:variable>


			<xsl:if test="false()">
				Debug
				<ul>
					<li>showTimeline :
						<xsl:value-of select="$showTimeline"/>
					</li>
					<li>version :
						<xsl:value-of select="$version"/>
					</li>
					<li>pointInTimeView :
						<xsl:value-of select="$pointInTimeView"/>
					</li>

					<li>startDate :
						<xsl:value-of select="$startDate"/>
					</li>
					<li>conurrent startDate:
						<xsl:value-of
								select="key('g_keyNodeIDs', tokenize($selectedSection/@AltVersionRefs, ' '))/*/@RestrictStartDate/xs:date(.)"/>
					</li>
					<li>exists startDate :
						<xsl:value-of select="exists($startDate)"/>
					</li>

					<li>endDate :
						<xsl:value-of select="$endDate"/>
					</li>
					<li>exists endDate :
						<xsl:value-of select="exists($endDate)"/>
					</li>

					<li>prospective :
						<xsl:value-of select="$prospective"/>
					</li>
					<li>repealed :
						<xsl:value-of select="$repealed"/>
					</li>
					<li>notYetInForce :
						<xsl:value-of select="$notYetInForce"/>
					</li>
					<li>otherVersions :
						<ul>
							<xsl:for-each select="$otherVersions">
								<li>
									<xsl:value-of select="concat('        ', @title)"/>
									<xsl:value-of select="if (@iscurrent) then ' current' else ()"/>
								</li>
							</xsl:for-each>
						</ul>
					</li>
					<li>pointers:
						<ul>
							<xsl:for-each select="$pointers/*">
								<li>
									<a href="{@href}">
										<xsl:value-of select="concat('        ', @title)"/>
									</a>
								</li>
							</xsl:for-each>
						</ul>
						<ul>
							<li>
								-
								<xsl:copy-of select="$pointers"/>
							</li>
						</ul>
					</li>
					<ul>
						Processing:
						<xsl:variable name="links" as="element(atom:link)*">
							<xsl:copy-of
									select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and (@title castable as xs:date or @title='prospective')]"/>
						</xsl:variable>

						<xsl:for-each select="$links">

							<xsl:variable name="currentPos" select="position()" as="xs:integer"/>

							<!-- add the $start in the required location-->
							<xsl:if test="($startDate castable as xs:date)
							and (@title castable as xs:date)
							and xs:date(@title) > xs:date($startDate)
							and (
								not($links[$currentPos - 1]/@title castable as xs:date) or
								xs:date($links[$currentPos - 1]/@title) &lt; xs:date($startDate)
							)">
								<!--<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{concat( /leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'current']/@href, '/', $startDate)}" title="{$startDate}" iscurrent="true" />-->
								<li>add -1 -
									<xsl:value-of select="$startDate"/>
								</li>
							</xsl:if>

							<!-- add the $start in the required location-->
							<xsl:if test="($startDate castable as xs:date)
							and @title = 'prospective'
							and (
								not($links[$currentPos - 1]/@title castable as xs:date) or
								xs:date($links[$currentPos - 1]/@title) &lt; xs:date($startDate)
							)">
								<!--
						<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{concat( /leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'current']/@href, '/', $startDate)}" title="{$startDate}" iscurrent="true" />-->
								<li>add -1 -
									<xsl:value-of select="$startDate"/>
								</li>
							</xsl:if>

							<li>
								Current:<xsl:value-of select="@title"/>, Previous:<xsl:value-of
									select="$links[$currentPos - 1]/@title"/>
							</li>
							<xsl:copy-of select="."/>

							<!-- add $startDate in the last if it is not added -->
							<xsl:if test="($startDate castable as xs:date)
							and (@title castable as xs:date)
							and (xs:date(@title) &lt; xs:date($startDate)
							and position() = last()
						)">
								<!--<atom:link rel="http://purl.org/dc/terms/hasVersion"
										   href="{concat( /leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'current']/@href, '/', $startDate)}"
										   title="{$startDate}" iscurrent="true"/>-->
								<li>add in end
									<xsl:value-of select="$startDate"/>
								</li>
							</xsl:if>
						</xsl:for-each>
					</ul>
				</ul>
			</xsl:if>

			<div id="changesOverTime">
				<!-- The title of the timeline should be "Changes over time for: {section name}". -->
				<h2>
					<xsl:value-of select="leg:TranslateText('Changes over time for')"/><xsl:text>:  </xsl:text>
					<xsl:choose>
						<xsl:when test="$nstSelectedSection">
							<xsl:apply-templates select="$nstSelectedSection" mode="CurrentSectionName"/>
						</xsl:when>
						<xsl:when test="$g_strsignatureURI = $dcIdentifier">
							<xsl:text> </xsl:text>
							<xsl:value-of select="leg:TranslateText('Signature')"/>
						</xsl:when>
						<xsl:when test="$g_strENURI = $dcIdentifier">
							<xsl:text> </xsl:text>
							<xsl:value-of select="leg:TranslateText('Explanatory Notes')"/>
						</xsl:when>
						<xsl:when test="$g_strIntroductionUri = $dcIdentifier">
							<xsl:value-of select="$introductoryText"/>
						</xsl:when>
						<xsl:when test="$g_strwholeActURI = $dcIdentifier">
							<xsl:value-of select="$g_bestShortTitle"/>
						</xsl:when>
						<xsl:when test="$g_wholeActWithoutSchedulesURI = $dcIdentifier">
							<xsl:value-of select="$g_bestShortTitle"/>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="leg:TranslateText(concat('without ', $schedulesText))"/>
							<xsl:text>)</xsl:text>
						</xsl:when>
						<xsl:when test="$g_schedulesOnlyURI = $dcIdentifier">
							<xsl:value-of select="$g_bestShortTitle"/>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="leg:TranslateText(concat($schedulesText, ' only'))"/>
							<xsl:text>)</xsl:text>
						</xsl:when>
					</xsl:choose>
				</h2>
				<div class="timelineHelp">
					<a href="#timelineHelp" class="helpItem helpItemToMidLeft">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about opening options"/>
					</a>
				</div>


				<!-- If $pointInTimeView is true, under the title will be some text saying:

				  - if $repealed is true, "No longer has effect: {$endDate}"
				  - if $notYetInForce is true, "No versions valid at: {$version}"
				  - if there is no $endDate, nothing
				  - otherwise, "Version Superseded: {$endDate}"
				-->
				<xsl:if test="$pointInTimeView">
					<xsl:choose>
						<xsl:when test="$repealed">
							<p class="warning">
								<xsl:value-of select="leg:TranslateText('No longer has effect')"/>
								<xsl:text>: </xsl:text>
								<xsl:value-of select="leg:FormatDate($endDate)"/>
							</p>
						</xsl:when>
						<xsl:when test="$notYetInForce">
							<p class="warning">
								<xsl:value-of select="leg:TranslateText('No versions valid at')"/>
								<xsl:text>: </xsl:text>
								<xsl:value-of select="leg:FormatDate($version)"/>
							</p>
						</xsl:when>
						<xsl:when test="string-length($endDate)= 0"/>
						<xsl:otherwise>
							<p class="warning">
								<xsl:value-of select="leg:TranslateText('Version Superseded')"/>
								<xsl:text>: </xsl:text>
								<xsl:value-of select="leg:FormatDate($endDate)"/>
							</p>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				
				
				<xsl:variable name="futurepointers" as="xs:string*">
					<xsl:for-each select="$pointers/*[@title castable as xs:date and xs:date(@title) &gt; $currentdate]">
						<xsl:value-of select="@title"/>
					</xsl:for-each>
				</xsl:variable>

				<!-- total width of the timeline -->
				<xsl:variable name="totalWidth" as="xs:integer+">
					<xsl:if test="$notYetInForce">
						<xsl:sequence select="$minWidth"/>
					</xsl:if>

					<xsl:for-each select="$pointers/*">
						<xsl:if test="@title castable as xs:date and xs:date(@title) &gt; $currentdate and @title = $futurepointers[1]">
							<xsl:sequence select="$minWidth"/>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="count($pointers/*) &lt;= 4">
								<xsl:sequence select="xs:integer( ($minWidth * 4) div count($pointers/*) )"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="leg:GetWidthInPixels(@numberOfDays, $minWidth)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>

					<!-- default width for the <ul>-->
					<xsl:sequence select="50"/>
				</xsl:variable>
				

				<!-- total content width of the timeline -->
				<xsl:variable name="contentWidth" as="xs:integer+">
					<!-- default width for the timeline-->
					<xsl:sequence select="if (sum($totalWidth) &lt; 677) then 677 else sum($totalWidth)"/>

					<xsl:if test="$notYetInForce">
						<xsl:sequence select="- $minWidth"/>
					</xsl:if>

					<xsl:for-each select="$pointers/*">
						<xsl:if test="@title castable as xs:date and xs:date(@title) &gt; $currentdate">
							<xsl:sequence select="- $minWidth"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				
				<!-- this prevents the arrow from getting cut off by the end of the display box 
				increasae the integer value if this happens 
				wwe need to use $g_euExitDay as the $pointers will not have this ref if there is 
				a coinciding change pit -->
				<xsl:variable name="arrowAllowance" select="if ($pointers/*/@rel = ('http://www.legislation.gov.uk/def/date/euexitday') or exists($g_euExitDay))  then 90 else 40"/>

				<div id="timeline">
					<div id="timelineData"
						 style="width:{(if (sum($totalWidth) &lt; 677) then 677 else sum($totalWidth)) + $arrowAllowance}px">

						<h3 class="accessibleText">Alternative versions:</h3>

						<!-- The timeline needs to include the following: -->
						<ul>
							
							<!-- the bar along which the pointers are positioned, which will include -->

							<!-- - if $notYetInForce is true, a leading solid bar -->
							<xsl:if test="$notYetInForce">
								<li style="width: {$minWidth}px"/>
							</xsl:if>

												
							<xsl:for-each select="$pointers/*">

								<!-- if any $versions are after the current date, a dashed bar before the pointers for those versions -->
								<xsl:if test="(@title castable as xs:date and xs:date(@title) &gt; $currentdate and @title = $futurepointers[1])">
									<li style="width: {$minWidth}px" class="dash"/>
								</xsl:if>

								<!-- width of the bar -->
								<xsl:variable name="liWidth"
											  select="xs:integer( sum($contentWidth) div count($pointers/*))"
											  as="xs:integer"/>
											  
								<xsl:variable name="exitDayText">
									<xsl:choose>
										<xsl:when test="$brexitType =('nodeal', 'extension')">
											<xsl:value-of select="leg:TranslateText('EU exit day')"/>
										</xsl:when>
										<xsl:when test="$brexitType =('deal') and (@rel = 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd' or @euendTransitionDay = 'true')">
											<xsl:value-of select="leg:TranslateText('End of implementation period')"/>
										</xsl:when>
										<xsl:when test="$brexitType =('deal')">
											<xsl:value-of select="leg:TranslateText('Exit day: start of implementation period')"/>
										</xsl:when>
									</xsl:choose>
								</xsl:variable>

								<xsl:variable name="exitDayDate">
									<xsl:value-of select="leg:FormatDate(@title)"/>
									<xsl:if test="(@euexitday = 'true' or @rel = 'http://www.legislation.gov.uk/def/date/euexitday') and $brexitType =('deal')"> 11pm</xsl:if>
								</xsl:variable>

								<!--
								  one of these pointers (and the timeline bar to the right of it) will be highlighted as indicating the current version of the provision:
									- if $notYetInForce is true, this will be the first pointer
									- if $repealed is true, this will be the last pointer
									- if $prospective is true, this will be the prospective pointer
									- otherwise, it will be the pointer representing the date that is closest (most recently in the past) to the $version
									
									ignore eu exit day marker - we will deal with that later
								-->
								<xsl:variable name="isCurrentVersion" as="xs:boolean">
									<xsl:choose>
										<!--<xsl:when test="@rel = 'http://www.legislation.gov.uk/def/date/euexitday'">
											<xsl:sequence select="false()"/>
										</xsl:when>-->
										<xsl:when test="$notYetInForce and position() = 1">
											<xsl:sequence select="true()"/>
										</xsl:when>
										<xsl:when test="$repealed">
											<xsl:choose>
												<xsl:when test="position() = last() - 1">
													<xsl:sequence select="true()"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:sequence select="false()"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:when test="$prospective and @title = 'prospective'">
											<xsl:sequence select="true()"/>
										</xsl:when>
										<xsl:when test="@iscurrent">
											<xsl:sequence select="true()"/>
										</xsl:when>
										<xsl:when test="@title = $version">
											<xsl:sequence select="true()"/>
										</xsl:when>
										<xsl:otherwise>
											<!--
												finding the pointer closest(most recently in the path) to the $version
												i = current index
												if (i+1 is date )
												{
													if (i+1 > $version and (i is not date or i < $version)) then
													  currentVersion
												}
												else
												{
												   if (
													if ((i is date and  i < $version) )
														  currentVersion
												}
											-->
											<xsl:choose>
												<!--<xsl:when test="((@rel = 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd') or (@rel = 'http://www.legislation.gov.uk/def/date/euexitday')) and xs:date(@title) &gt; leg:GetVersionDate($version) ">
													<xsl:sequence select="true()"/>
												</xsl:when>-->
												
												<xsl:when
														test="(@title castable as xs:date) and (@rel = 'http://www.legislation.gov.uk/def/date/euexitday') and xs:date(following-sibling::*[1][not(@rel = 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd')]/@title) &gt; leg:GetVersionDate($version)
														and xs:date(preceding-sibling::*[1]/@title) &lt;= leg:GetVersionDate($version)">
													<xsl:sequence select="true()"/>
												</xsl:when>
												<xsl:when test="following-sibling::*[not(@rel = 'http://www.legislation.gov.uk/def/date/euexitday')][1]/@title castable as xs:date">
													<xsl:choose>
														<xsl:when
																test="xs:date(following-sibling::*[not(@rel = 'http://www.legislation.gov.uk/def/date/euexitday')][1]/@title) &gt; leg:GetVersionDate($version) and ( not(@title castable as xs:date) or xs:date(@title) &lt; leg:GetVersionDate($version)) ">
															<xsl:sequence select="true()"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:sequence select="false()"/>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:when
														test="following-sibling::*[1]/@title = 'prospective' and $prospective">
													<xsl:sequence select="false()"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:choose>
														<xsl:when
																test="(@title castable as xs:date) and xs:date(@title) &lt; leg:GetVersionDate($version)">
															<xsl:sequence select="true()"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:sequence select="false()"/>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>

								<!--
								- if $repealed is true, a trailing solid bar with no arrow at the end
								- if $version is 'prospective' and $prospective is false, a trailing dashed bar with no arrow at the end
									otherwise it is last then add an error
							-->
								<xsl:variable name="noDealNotRetained" select="($brexitType = 'nodeal' and $g_isEuNotRetained and empty($pointers/*[@title castable as xs:date][xs:date(@title) gt xs:date($g_euExitDay)]))"/>
								
								<xsl:variable name="addArrow" as="xs:boolean">
									<xsl:choose>
										<xsl:when test="$noDealNotRetained">
											<xsl:sequence select="false()"/>
										</xsl:when>
										<xsl:when test="$repealed and position() = last()">
											<xsl:sequence select="false()"/>
										</xsl:when>
										<xsl:when
												test="$version = 'prospective' and not($prospective) and position() = last()">
											<xsl:sequence select="false()"/>
										</xsl:when>
										<xsl:when test="position() = last()">
											<xsl:sequence select="true()"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:sequence select="false()"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>

								<!-- this prevents the end arrow dropping down for EU items
									increase the integer value if it does 
									the boxes for the  EU exit day implementations need to be accommodated-->
								<xsl:variable name="liWidth"
											  select="
											  if (@title castable as xs:date and xs:date(@title) &gt; $currentdate
											  and ./following-sibling::*[1]/@rel = ('http://www.legislation.gov.uk/def/date/euexitday', 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd') or ./following-sibling::*[1]/@euexitday = 'true'  or ./following-sibling::*[1]/@euendTransitionDay = 'true')  then
											  ($minWidth)
											  else 
											  if (@rel = ('http://www.legislation.gov.uk/def/date/euexitday', 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd') or @euexitday = 'true' or @euendTransitionDay = 'true')  then
											  ($minWidth)
											  else if (@rel = ('http://www.legislation.gov.uk/def/date/euexitday', 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd') and $addArrow)  then
											  ($liWidth - 10)
											  else if ($addArrow) then ($liWidth - 20) else $liWidth"/>

								<li style="width: {$liWidth}px;">
									
									<xsl:variable name="currentClass">
										<xsl:choose>
											<xsl:when test="$noDealNotRetained and position() = last()">
												<xsl:text>notretained</xsl:text>
											</xsl:when>
											<xsl:when test="$isCurrentVersion and @title = 'prospective'">currentVersion
												currentProspective
											</xsl:when>
											<xsl:when test="$isCurrentVersion">currentVersion</xsl:when>
											<xsl:when test="@title ='prospective'">prospective</xsl:when>
										</xsl:choose>
									</xsl:variable>
									
									<xsl:variable name="dashClass">
										<xsl:choose>
											<xsl:when test="@repealed = true() or ($repealed and position() = last())">
												<xsl:text>stopDate</xsl:text>
												<xsl:if test="@repealed = 'true' and position() != last()"> dash</xsl:if>
											</xsl:when>
											<xsl:when test="$brexitType = ('deal') and @rel = ('http://www.legislation.gov.uk/def/date/euexitday', 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd') and xs:date(@title) gt $currentdate">
												<xsl:text>dash</xsl:text>
											</xsl:when>
										</xsl:choose>
									</xsl:variable>
									
									<xsl:variable name="class" select="string-join(($currentClass, $dashClass), ' ')"/>
									
									<xsl:variable name="exitdayclass">
										<xsl:choose>
											<xsl:when test="$brexitType = ('nodeal', 'extension')">
												<xsl:value-of select="concat('euexitday', if (@euexitday = 'true') then 'overlay' else ())"/>
											</xsl:when>
											<xsl:when test="$brexitType = ('deal') and @rel = ('http://www.legislation.gov.uk/def/date/euexitday', 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd')">
												<xsl:value-of select="'euexitday-deal'"/>
											</xsl:when>
											<xsl:when test="$brexitType = ('deal') and @euexitday = 'true'">
												<xsl:value-of select="'euexitdayoverlay-deal'"/>
											</xsl:when>
											<xsl:when test="$brexitType = ('deal') and @euendTransitionDay = 'true'">
												<xsl:value-of select="'euexitdayoverlay-deal'"/>
											</xsl:when>
										</xsl:choose>
									</xsl:variable>

									<xsl:if test="string-length(normalize-space($class)) ne 0">
										<xsl:attribute name="class">
											<xsl:value-of select="$class"/>
										</xsl:attribute>
									</xsl:if>
									
									<xsl:variable name="pointer" 
										select="
											if (@rel = 'http://www.legislation.gov.uk/def/date/euexitday') then 
												'pointer' 
											else if ($g_isEUretained and $brexitType =('nodeal') and 
													exists($g_euExitDay) and 
													@title castable as xs:date and 
													xs:date(@title) ge xs:date($g_euExitDay)) then
												'pointer-uk'	
											else if ($g_isEUretained and exists($g_euExitDay) and 
													@title castable as xs:date and 
													xs:date(@title) lt max((xs:date($g_euExitDay), xs:date($g_euExitTransitonEndDay)))) then 
												'pointer-eu' 
											else 'pointer'"/>

									<xsl:choose>
										<xsl:when test="@repealed = true() or ($repealed and position() = last())">
											<span class="stop">
												<span class="{$pointer}"/>
												<span class="label">
													<xsl:value-of select="leg:TranslateText('Stop date')"/>
													<xsl:text> </xsl:text>
													<xsl:value-of select="leg:FormatDate(@title)"/>
													<em class="accessibleText">- Amendment</em>
												</span>
											</span>
										</xsl:when>
										<!--  Prevent a link to a prosp doc if none exists but retain the timeline icons  -->
										<xsl:when test="lower-case(@title) = 'prospective' and empty($prospDoc)">
											<a href="#">
												<span class="{$pointer}"/>
												<span>
													<xsl:value-of select="leg:FormatDate(@title)"/>
													<em class="accessibleText">- Amendment</em>
												</span>
											</a>
										</xsl:when>
										<xsl:when test="@rel = 'http://www.legislation.gov.uk/def/date/euexitday'">
											<a href="{leg:FormatURL(@href)}" class="{$exitdayclass}">
												<span class="{$pointer}"/>
												<div class="content">
													<span class="title">
														<xsl:value-of select="$exitDayText"/>
													</span>
													<span class="description">
														<xsl:value-of select="$exitDayDate"/>
														<em class="accessibleText">- Amendment</em>
													</span>
												</div>
											</a>
										</xsl:when>
										<xsl:when test="@rel = 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd'">
											<a href="{leg:FormatURL(@href)}" class="{$exitdayclass}">
												<span class="{$pointer}"/>
												<div class="content">
													<span class="title">
														<xsl:value-of select="$exitDayText"/>
													</span>
													<span class="description">
														<xsl:value-of select="$exitDayDate"/>
														<em class="accessibleText">- Amendment</em>
													</span>
												</div>
											</a>
										</xsl:when>
										<xsl:when test="@euexitday = 'true'">
											<a href="{leg:FormatURL(@href)}" class="{$exitdayclass}">
												<span class="{$pointer}"/>
												<div class="content">
													<span class="title">
														<xsl:value-of select="$exitDayText"/>
													</span>
													<span class="description">
														<xsl:value-of select="$exitDayDate"/>
														<em class="accessibleText">- Amendment</em>
													</span>
												</div>
											</a>
										</xsl:when>
										<xsl:when test="@euendTransitionDay = 'true'">
											<a href="{leg:FormatURL(@href)}" class="{$exitdayclass}">
												<span class="{$pointer}"/>
												<div class="content">
													<span class="title">
														<xsl:value-of select="$exitDayText"/>
													</span>
													<span class="description">
														<xsl:value-of select="$exitDayDate"/>
														<em class="accessibleText">- Amendment</em>
													</span>
												</div>
											</a>
										</xsl:when>
										<xsl:otherwise>
											<a href="{leg:FormatURL(@href)}">
												<xsl:if test="@euexitday = 'true'">
													<xsl:attribute name="class" select="'exitdayoverlay'"/>
												</xsl:if>
												<span class="{$pointer}"/>
												<xsl:if test="@euexitday = 'true'">
													<span class="title">
														<xsl:value-of select="$exitDayText"/>
													</span>
												</xsl:if>
												<span>
													<xsl:value-of select="$exitDayDate"/>
													<em class="accessibleText">- Amendment</em>
												</span>
											</a>
										</xsl:otherwise>
									</xsl:choose>

									<a href="{leg:FormatURL(@href)}"/>

									<!--<xsl:if test="$g_euExitDay">
										<a href="#" class="eu-exit-day">
											<span class="text">BREXIT!</span>
											<span class="date">DD MMM YYYY</span>
										</a>
									</xsl:if>-->

									<xsl:if test="$addArrow">
										<span class="end"/>
									</xsl:if>
								</li>

								<!--
								  - if $pointInTimeView is true, an indicator showing the current point in time:
								- if $notYetInForce is true then this will be before any of the pointers
									- if $repealed is true, this will be after the pointer for the $endDate
									- if $version is 'prospective' but $prospective is false, this will be on the trailing dashed bar
									- if $version exactly matches one of the $versions, it will be directly above that version pointer
									- otherwise, it will be between the pointers for the versions either side, positioned roughly
								-->
								<xsl:if test="$pointInTimeView">
									<xsl:variable name="displayStyle">
										<xsl:choose>
											<xsl:when test="xs:date(following-sibling::*[1][@rel = 'http://www.legislation.gov.uk/def/date/euexitday']/@title) le leg:GetVersionDate($version)"></xsl:when>
											<xsl:when test="xs:date(following-sibling::*[1][@rel = 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd']/@title) le leg:GetVersionDate($version)"></xsl:when>
											<xsl:when test="@rel = 'http://www.legislation.gov.uk/def/date/euexitday' and xs:date(@title) &gt; leg:GetVersionDate($version)"></xsl:when>
											<xsl:when test="@rel = 'http://www.legislation.gov.uk/def/date/euexitTransitionEnd' and xs:date(@title) &gt; leg:GetVersionDate($version)"></xsl:when>
											<xsl:when test="$notYetInForce and position()=1">margin-left: <xsl:value-of
													select="-53*2 - $liWidth"/>px;
											</xsl:when>
											<xsl:when test="$repealed and $endDate = @title">margin-left: <xsl:value-of
													select="-53 - $liWidth"/>px;
											</xsl:when>
											<xsl:when test="$version = @title">margin-left: <xsl:value-of
													select="-53 - $liWidth"/>px;
											</xsl:when>
											<xsl:when test="$isCurrentVersion and $repealed"/>
											<xsl:when
													test="($isCurrentVersion) or ($version ='prospective' and $prospective = false() and position() = last())">
												<xsl:text>margin-left: </xsl:text>
												<xsl:value-of select="-53 - xs:integer($liWidth div 2)"/>
												<xsl:text>px;</xsl:text>
											</xsl:when>
										</xsl:choose>
									</xsl:variable>

									<xsl:if test="string-length($displayStyle) ne 0 or $version = @title">
										<li class="pointInTime{if ($version castable as xs:date) then '' else ' prospectivePIT'}"
											style="{$displayStyle}">
											<span>
												<strong>
													<xsl:choose>
														<xsl:when test="$version castable as xs:date">
															<xsl:value-of select="leg:FormatDate($version)"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of
																	select="leg:TranslateText('Latest with prospective')"/>
														</xsl:otherwise>
													</xsl:choose>
												</strong>
												<br/>
												<em>
													<xsl:value-of select="leg:TranslateText('Point in time')"/>
												</em>
											</span>
										</li>
									</xsl:if>
								</xsl:if>
							</xsl:for-each>
						</ul>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>