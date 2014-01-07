<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xhtml xs"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	>
	
<xsl:import href="legislation/html/quicksearch.xsl"/>
<xsl:variable name="fileListDoc" select="if (doc-available('input:link-directory-scan')) then doc('input:link-directory-scan') else ()"/>


<xsl:template match="node()|@*">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" />
	</xsl:copy>
</xsl:template>

<xsl:template match="xhtml:body">
	<body xml:lang="en" lang="en" dir="ltr" id="doc">
		<xsl:sequence select="@*" />
		<div id="layout2">
			<xsl:if test="exists($fileListDoc)">
				<xsl:attribute name="class">subNavPage</xsl:attribute>
			</xsl:if>

			<xsl:if test="tokenize($paramsDoc/conditions/parameters/page,'/')[1] !='tools' ">
				<xsl:call-template name="TSOOutputQuickSearch" />		
				
				<div id="title">
					<xsl:apply-templates select="xhtml:h1[1]" />			
				</div>
				
				<xsl:apply-templates select="$fileListDoc/directory" mode="sectionNav"/>
			</xsl:if>
			
			<div id="content">
				<xsl:if test="exists($fileListDoc)">
					<xsl:attribute name="class">s_9 p_two</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="* except xhtml:h1[1]" />
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
								<xsl:with-param  name="fileId" select="$fileId"/>
							</xsl:call-template>
						</li>	
										
					</ul>
				</div>
			</div>			
		</div>
		<p class="backToTop"><a href="#top"><xsl:value-of select="leg:TranslateText('Back to top')"/></a></p>
		
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
							Next
						</xsl:when>
						<xsl:when test="$linkType='prev' ">
							Previous
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
		<xsl:apply-templates select="node()" />
	</h1>
</xsl:template>

<xsl:template match="xhtml:body/xhtml:p[1]">
	<p class="first">
		<xsl:apply-templates select="@*|node()" />
	</p>
</xsl:template>

<xsl:template match="directory" mode="pageTitle">
	<xsl:variable name="filePath" select="concat('../www/', @name, '.xhtml')"/>
	<xsl:variable name="fileDoc" select="if (doc-available($filePath)) then doc($filePath) else ()"/>
	<xsl:value-of  select="$fileDoc//xhtml:h1[1]" />
</xsl:template>

<xsl:template match="directory" mode="sectionNav">
	<xsl:variable name="items" as="element(xhtml:li)*">
		<xsl:choose>
			<xsl:when test="$TranslateLang='cy'">
				<xsl:apply-templates mode="sectionNavcy"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="sectionNav" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:variable>
	<xsl:variable name="resources" as="element(xhtml:div)?">
		<xsl:choose>
			<xsl:when test="$TranslateLang='cy'">
				<xsl:apply-templates mode="usefulResourcescy"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="usefulResources" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="exists($items) or exists($resources)">
		<div id="subNav" class="s_3 p_one">
			<div class="section">
				<h2 class="accessibleText">Section Navigation</h2>
				<ul class="sectionNav">
					<xsl:sequence select="$items" />
				</ul>
			</div>
			<xsl:sequence select="$resources" />
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="file[@name != 'usefulresources.xhtml' and not (ends-with(@name ,'.cy.xhtml'))]" mode="sectionNav">
	<xsl:variable name="filePath" select="concat('../www/', parent::directory/@name, '/', @name)"/>
	<xsl:variable name="fileUri" select="concat('/', parent::directory/@name, '/', substring-before(@name,'.xhtml') )"/>	
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
	
<xsl:template match="file[(@name != 'usefulresources.xhtml' and @name != 'usefulresources.cy.xhtml' and  ends-with(@name ,'.cy.xhtml') )]" mode="sectionNavcy">
		<xsl:variable name="filePath" select="concat('../www/', parent::directory/@name, '/', @name)"/>
		<xsl:variable name="fileUri" select="concat('/', parent::directory/@name, '/', substring-before(@name,'.cy.xhtml') )"/>
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
	<xsl:variable name="fileUri" select="concat('/', parent::directory/@name, '/', substring-before(@name,'.xhtml') )"/>	
	<xsl:variable name="fileDoc" select="if (doc-available($filePath)) then doc($filePath) else ()"/>
	<xsl:if test="exists($fileDoc)">
		<div class="section resources">
			<xsl:copy-of select="$fileDoc/xhtml:html/xhtml:body/*" copy-namespaces="no"/>
		</div>				
	</xsl:if>
</xsl:template>
	
<xsl:template match="file[@name = 'usefulresources.cy.xhtml']" mode="usefulResourcescy">
		<xsl:variable name="filePath" select="concat('../www/', parent::directory/@name, '/', @name)"/>
		<xsl:variable name="fileUri" select="concat('/', parent::directory/@name, '/', substring-before(@name,'.cy.xhtml') )"/>	
		<xsl:variable name="fileDoc" select="if (doc-available($filePath)) then doc($filePath) else ()"/>
		<xsl:if test="exists($fileDoc)">
			<div class="section resources">
				<xsl:copy-of select="$fileDoc/xhtml:html/xhtml:body/*" copy-namespaces="no"/>
			</div>				
		</xsl:if>
</xsl:template>

	

<xsl:template match="file" mode="usefulResources"/>
<xsl:template match="file" mode="usefulResourcescy"/>
	
</xsl:stylesheet>
