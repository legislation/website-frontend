<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:xhtml="http://www.w3.org/1999/xhtml"
				exclude-result-prefixes="xhtml xs"
				xmlns="http://www.w3.org/1999/xhtml"
				xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation">

	<xsl:import href="legislation/html/quicksearch.xsl"/>
	<xsl:variable name="fileListDoc" select="if (doc-available('input:link-directory-scan')) then doc('input:link-directory-scan') else ()"/>


	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:body">
		<body xml:lang="en" lang="en" dir="ltr" id="doc">
			<xsl:sequence select="@*"/>
			<div id="layout2" class="subNavPage">

				<xsl:call-template name="TSOOutputQuickSearch"/>

				<div class="pageContent">
					<div id="subNav" class="s_3 p_one">
						<xsl:choose>
							<!-- Used for Chron-Tables -->
							<xsl:when test="exists($fileListDoc)">
								<xsl:apply-templates select="$fileListDoc/directory" mode="sectionNav"/>
							</xsl:when>
							<!-- Other static pages -->
							<xsl:otherwise>

								<!-- Only show a ToC if there will be more than one item in it -->
								<xsl:if test="count(.//xhtml:h2) &gt; 1">
									<h2 class="accessibleText">Section Navigation</h2>
									<div class="section">
										<ul class="sectionNav">
											<xsl:apply-templates select="xhtml:h2" mode="tableOfContents"/>
										</ul>
									</div>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
						<p class="backToTop">
							<a href="#top">
								<xsl:value-of select="leg:TranslateText('Back to top')"/>
							</a>
						</p>
					</div>
					<div class="s_9 p_two">
						<div id="title">
							<xsl:apply-templates select="xhtml:h1[1]"/>
						</div>
						<div id="content">
							<xsl:apply-templates select="* except xhtml:h1[1]"/>
						</div>
					</div>
				</div>
				<xsl:call-template name="NextPreviousLinks"/>
			</div>
		</body>
	</xsl:template>

	<xsl:template name="NextPreviousLinks">
		<xsl:variable name="fileId" select="tokenize($paramsDoc/conditions/parameters/page,'/')[last()]"/>
		<xsl:if test="contains($paramsDoc/conditions/parameters/page, 'chron-tables/')">
			<div class="contentFooter">
				<div class="interface">
					<div class="prevPagesNextNav">
						<ul>
							<li>
								<xsl:call-template name="link">
									<xsl:with-param name="fileId" select="$fileId"/>
									<xsl:with-param name="linkType" select="'prev'"/>
								</xsl:call-template>
							</li>
							<li>
								<xsl:call-template name="link">
									<xsl:with-param name="fileId" select="$fileId"/>
								</xsl:call-template>
							</li>
						</ul>
					</div>
				</div>
			</div>

		</xsl:if>
	</xsl:template>

	<xsl:template name="link">
		<xsl:param name="fileId"/>
		<xsl:param name="linkType" select="'next'"/>

		<xsl:if test="$fileId castable as xs:integer">
			<xsl:variable name="file">
				<xsl:for-each select="tokenize($paramsDoc/conditions/parameters/page,'/')">
					<xsl:text>/</xsl:text>
					<xsl:choose>
						<xsl:when test="position() = last() and $linkType ='next' ">
							<xsl:value-of select="xs:integer($fileId) + 1"/>
						</xsl:when>
						<xsl:when test="position() = last() and $linkType ='prev'">
							<xsl:value-of select="xs:integer($fileId) - 1"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="filePath" select="concat('../www/', $file, '.xhtml')"/>
			<xsl:variable name="fileDoc" select="if (doc-available($filePath)) then doc($filePath) else ()"/>

			<xsl:if test="exists($fileDoc)">
				<a href="{$TranslateLangPrefix}/changes{$file}" class="userFunctionalElement">
					<span class="btl"></span>
					<span class="btr"></span>

					<xsl:choose>
						<xsl:when test="$linkType='next' ">
							<xsl:value-of select="leg:TranslateText('Next')"/>
						</xsl:when>
						<xsl:when test="$linkType='prev' ">
							<xsl:value-of select="leg:TranslateText('Previous')"/>
						</xsl:when>
						<xsl:otherwise>
							Unknown
						</xsl:otherwise>
					</xsl:choose>

					<span class="bbl"></span>
					<span class="bbr"></span>
				</a>
			</xsl:if>

		</xsl:if>

	</xsl:template>

	<xsl:template match="xhtml:h1[1]">
		<h1 id="pageTitle">
			<xsl:apply-templates select="@*"/>

			<!--<xsl:if test="exists($fileListDoc)">
				<xsl:apply-templates select="$fileListDoc/directory" mode="pageTitle"/><xsl:text>: </xsl:text>
			</xsl:if>-->
			<xsl:apply-templates select="node()"/>
		</h1>
	</xsl:template>

	<xsl:template match="xhtml:body/xhtml:p[1]">
		<p class="first">
			<xsl:apply-templates select="@*|node()"/>
		</p>
	</xsl:template>

	<xsl:template match="directory" mode="pageTitle">
		<xsl:variable name="filePath" select="concat('../www/', @name, '.xhtml')"/>
		<xsl:variable name="fileDoc" select="if (doc-available($filePath)) then doc($filePath) else ()"/>
		<xsl:value-of select="$fileDoc//xhtml:h1[1]"/>
	</xsl:template>

	<xsl:template match="directory" mode="sectionNav">
		<xsl:variable name="items" as="element(xhtml:li)*">
			<xsl:choose>
				<xsl:when test="$TranslateLang='cy'">
					<xsl:apply-templates mode="sectionNavcy"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="sectionNav"/>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:variable>
		<xsl:variable name="resources" as="element(xhtml:div)?">
			<xsl:choose>
				<xsl:when test="$TranslateLang='cy'">
					<xsl:apply-templates mode="usefulResourcescy"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="usefulResources"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="exists($items) or exists($resources)">
			<div class="section">
				<h2 class="accessibleText"><xsl:value-of select="leg:TranslateText('Section Navigation')"/></h2>
				<ul class="sectionNav">
					<xsl:sequence select="$items"/>
				</ul>
			</div>
			<xsl:sequence select="$resources"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="file[@name != 'usefulresources.xhtml' and not (ends-with(@name ,'.cy.xhtml'))]"
				  mode="sectionNav">
		<xsl:variable name="filePath" select="concat('../www/', parent::directory/@name, '/', @name)"/>
		<xsl:variable name="fileUri"
					  select="concat('/', parent::directory/@name, '/', substring-before(@name,'.xhtml') )"/>
		<xsl:variable name="fileDoc" select="if (doc-available($filePath)) then doc($filePath) else ()"/>
		<xsl:if test="exists($fileDoc)">
			<li>
				<xsl:if test="position() = last()">
					<xsl:attribute name="class">last</xsl:attribute>
				</xsl:if>
				<a href="{if (parent::directory/@name ='chron-tables') then '/changes' else ''}{$fileUri}">
					<xsl:value-of select="$fileDoc/xhtml:html/xhtml:head/xhtml:title"/>
				</a>
			</li>
		</xsl:if>
	</xsl:template>

	<xsl:template
			match="file[(@name != 'usefulresources.xhtml' and @name != 'usefulresources.cy.xhtml' and  ends-with(@name ,'.cy.xhtml') )]"
			mode="sectionNavcy">
		<xsl:variable name="filePath" select="concat('../www/', parent::directory/@name, '/', @name)"/>
		<xsl:variable name="fileUri"
					  select="concat('/', parent::directory/@name, '/', substring-before(@name,'.cy.xhtml') )"/>
		<xsl:variable name="fileDoc" select="if (doc-available($filePath)) then doc($filePath) else ()"/>
		<xsl:if test="exists($fileDoc)">
			<li>
				<xsl:if test="position() = last()">
					<xsl:attribute name="class">last</xsl:attribute>
				</xsl:if>
				<a href="{if (parent::directory/@name ='chron-tables') then '/cy/changes' else ''}{$fileUri}">
					<xsl:value-of select="$fileDoc/xhtml:html/xhtml:head/xhtml:title"/>
				</a>
			</li>
		</xsl:if>
	</xsl:template>

	<xsl:template match="file" mode="sectionNav"/>
	<xsl:template match="file" mode="sectionNavcy"/>

	<xsl:template match="file[@name = 'usefulresources.xhtml']" mode="usefulResources">
		<xsl:variable name="filePath" select="concat('../www/', parent::directory/@name, '/', @name)"/>
		<xsl:variable name="fileUri"
					  select="concat('/', parent::directory/@name, '/', substring-before(@name,'.xhtml') )"/>
		<xsl:variable name="fileDoc" select="if (doc-available($filePath)) then doc($filePath) else ()"/>
		<xsl:if test="exists($fileDoc)">
			<div class="section resources">
				<xsl:copy-of select="$fileDoc/xhtml:html/xhtml:body/*" copy-namespaces="no"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="file[@name = 'usefulresources.cy.xhtml']" mode="usefulResourcescy">
		<xsl:variable name="filePath" select="concat('../www/', parent::directory/@name, '/', @name)"/>
		<xsl:variable name="fileUri"
					  select="concat('/', parent::directory/@name, '/', substring-before(@name,'.cy.xhtml') )"/>
		<xsl:variable name="fileDoc" select="if (doc-available($filePath)) then doc($filePath) else ()"/>
		<xsl:if test="exists($fileDoc)">
			<div class="section resources">
				<xsl:copy-of select="$fileDoc/xhtml:html/xhtml:body/*" copy-namespaces="no"/>
			</div>
		</xsl:if>
	</xsl:template>


	<xsl:template match="file" mode="usefulResources"/>
	<xsl:template match="file" mode="usefulResourcescy"/>

	<xsl:template match="xhtml:h2">
		<h2>
			<xsl:attribute name="id">
				<xsl:choose>
					<xsl:when test="@id">
						<xsl:value-of select="@id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="leg:TextToId">
							<xsl:with-param name="text" select="text()"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</h2>
	</xsl:template>

	<xsl:template match="xhtml:h2" mode="tableOfContents" priority="15" >
		<li>
			<a>
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="@id">
							<xsl:value-of select="concat('#',@id)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="leg:TextToId">
								<xsl:with-param name="text" select="text()"/>
								<xsl:with-param name="prefix" select="'#'"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="node()" mode="tableOfContents"/>
			</a>
		</li>
	</xsl:template>
	<!-- Stop ToC links from containing a link -->
	<xsl:template match="xhtml:a" mode="tableOfContents">
		<xsl:apply-templates select="node()" mode="tableOfContents"/>
	</xsl:template>
	
	<xsl:template match="*[@rel and matches(@rel,'(deal|nodeal|extension|revoke|holding)')]" priority="10" mode="tableOfContents">
		<xsl:variable name="scenarios" as="xs:string*" select="if (contains(@rel, ' ')) then tokenize(@rel, ' ') else @rel"/>
		<xsl:if test="$brexitType = $scenarios">
			<xsl:copy>
				<xsl:apply-templates select="node()|@*" mode="tableOfContents"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="@rel[matches(.,'(deal|nodeal|extension|revoke|holding)')]" priority="10" mode="tableOfContents">
		
	</xsl:template>

	<xsl:template match="*" mode="tableOfContents" >
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tableOfContents"/>
		</xsl:copy>
	</xsl:template>

	<!-- Convert title into an id, remove space and . characters -->
	<xsl:template name="leg:TextToId">
		<xsl:param name="text"/>
		<xsl:param name="prefix" select="''"/>
		<xsl:variable name="selectedText">
			<xsl:choose>
				<xsl:when	test="empty($text) or matches(string-join(($text), ' '), '^[\s]+$')">
					<xsl:value-of select="generate-id()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="string-join(($text), ' ')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat($prefix,replace(normalize-space($selectedText),'[ \.\?/'']',''))"/>
	</xsl:template>

</xsl:stylesheet>
