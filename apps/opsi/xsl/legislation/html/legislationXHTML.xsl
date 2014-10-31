<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:msxsl="urn:schemas-microsoft-com:xslt"
      xmlns:xhtml="http://www.w3.org/1999/xhtml"
      xmlns:leg="http://www.tso.co.uk/assets/namespace/legislation"
      xmlns:local="#local-functions"
      exclude-result-prefixes="xs msxsl xhtml leg"
      xmlns="http://www.w3.org/1999/xhtml"
      version="2.0">

<!-- Import the plain and standard processing XSLT, as this is the same for both Plain and Standard views. -->
<xsl:import href="TSO_SPO_legislation_xhtml_versions.xslt"/>

<xsl:output method="xhtml" omit-xml-declaration="yes" indent="no" 
	doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
	doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

<!-- ========== Global parameters ========== -->

<!-- The XML filename (including extension) of the legislation document being processed, set by the processor. -->
<xsl:param name="g_strLegislationXMLDocFilename" select="replace(base-uri(/), '^.+/([^/]+)$', '$1')" />

<!-- The date on which this file is processed -->
<xsl:param name="g_strDate" select="string(current-date())" />

<!-- ========== Global variables ========== -->

<!-- Commentary Document -->
<xsl:variable name="g_nstCommentaryDoc" select="/" />

<xsl:variable name="g_intMaxRecursions" select="100" />

<!-- Path to the Plain template. -->
<xsl:variable name="g_ndsTemplateDoc" select="document('SPOHTMLTemplate_Plain-v-1-0.xml')"/>

<!-- This indicates whether it is chunked or unchunked (plainunchunked). Values are:  chunked/plainunchunked. -->
<xsl:variable name="g_strViewType" select="'plainunchunked'"/>

<!-- This indicates whether it is plain or standard view style.  This is used in determining the correction locations in the folder structure. -->
<xsl:variable name="g_strViewStyle" select="'plain'"/>

<!-- The prefix used for the legislation document images, for the plain view styles, as the actual documents are in subfolder "plain" where as the images sit in the preceding parent folder. -->
<xsl:variable name="g_strDocumentImagesPath" select="'../images/'"/>

<!-- Only if output is unchunked, then output file without the "_1" as the chunker will add this automatically. -->
<xsl:variable name="g_strAddFirstChunkSuffix" select="'no'"/>
	
<xsl:template match="/" priority="1">
	<xsl:if test="not($g_ndsLegisConfigDoc//path[@type='images'])">
		<xsl:message terminate="yes">Configuration file is missing images path</xsl:message>
	</xsl:if>
	<xsl:if test="not($g_ndsLegisConfigDoc//path[@type='CSS'])">
		<xsl:message terminate="yes">Configuration file is missing CSS path</xsl:message>
	</xsl:if>
	<xsl:if test="not($g_ndsLegisConfigDoc//path[@type='transformlog'])">
		<xsl:message terminate="yes">Configuration file is missing Transform Log path</xsl:message>
	</xsl:if>
	<xsl:if test="not($g_ndsLegisConfigDoc//path[@type='localroot'])">
		<xsl:message terminate="yes">Configuration file is missing Local Root path</xsl:message>
	</xsl:if>
	<xsl:if test="not($g_ndsLegisConfigDoc//path[@type='statutes'])">
		<xsl:message terminate="yes">Configuration file is missing Statutes path</xsl:message>
	</xsl:if>
	<xsl:if test="not($g_ndsLegisConfigDoc//path[@type='ssi'])">
		<xsl:message terminate="yes">Configuration file is missing SSI path</xsl:message>
	</xsl:if>
	<html lang="en" xml:lang="en">
		<xsl:for-each select="$g_ndsTemplateDoc//xhtml:html">
			<xsl:apply-templates />
		</xsl:for-each>
	</html>
</xsl:template>

<xsl:template match="xhtml:title">
	<title>
		<xsl:value-of select="$g_rtfShortTitle" />
	</title>
</xsl:template>

<xsl:template match="xhtml:include[@name]" />

<xsl:variable name="nstContent">
	<xsl:call-template name="FuncProcessFileContents"/>
</xsl:variable>

<xsl:variable name="nstAAsRemoved">
	<xsl:apply-templates select="$nstContent" mode="TSORemoveAllButFirstAA" />
</xsl:variable>

<xsl:template match="xhtml:include[not(@name)]">
	<xsl:sequence select="$nstAAsRemoved" />
</xsl:template>

<xsl:template name="FuncProcessFileContents">
	<div class="DocContainer">
		<xsl:for-each select="$g_ndsMainDoc">
			<xsl:apply-templates/>
		</xsl:for-each>		
		<xsl:variable name="nstChanges" 
			select="$g_ndsMainDoc//processing-instruction('change')
			[contains(., 'start')]" />
		<xsl:if test="$nstChanges">
			<div class="LegPIContainer">
				<xsl:apply-templates select="$nstChanges" mode="plainunchunked"/>
			</div>
			<xsl:text>&#13;</xsl:text>
		</xsl:if>
	</div>
	<xsl:text>&#13;</xsl:text>		
</xsl:template>

<!-- *** TSORemoveAllButFirstAA *** -->

<xsl:key name="AAs" match="xhtml:acronym | xhtml:abbr" use="." />

<xsl:template match="node()" mode="TSORemoveAllButFirstAA">
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates mode="TSORemoveAllButFirstAA" />
	</xsl:copy>
</xsl:template>

<xsl:template match="xhtml:acronym | xhtml:abbr" mode="TSORemoveAllButFirstAA">
	<xsl:variable name="nstSameAA" select="key('AAs', .)" />
	<xsl:variable name="nstFirstAA" select="$nstSameAA[1]" />
	<xsl:choose>
		<xsl:when test="$nstFirstAA != .">
			<xsl:comment>ERR: Problem with MSXML's keys</xsl:comment>
			<xsl:variable name="strValue" select="." />
			<xsl:choose>
				<xsl:when test="(self::xhtml:acronym and
					not(preceding::xhtml:acronym[. = $strValue])) or
					(self::xhtml:abbr and
					not(preceding::xhtml:abbr[. = $strValue]))">
					<xsl:copy-of select="." />
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="node()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="strFirstAAid" select="generate-id($nstFirstAA)" />
			<xsl:choose>
				<xsl:when test="generate-id(.) = $strFirstAAid">
					<xsl:copy-of select="." />
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="node()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- *** Overrides *** -->

<xsl:template match="leg:Legislation">
	<xsl:apply-templates select="*|processing-instruction()" />
</xsl:template>

<xsl:template match="leg:Commentary" />

<xsl:key name="CommentariesById" match="leg:Commentary[@id]" use="substring-after(@id, 'c')" />

<xsl:template name="FuncGetCommentariesFromPIs">
	<xsl:param name="nstPIs" />
	<xsl:param name="nstCommentaries" select="/.." />
	<xsl:choose>
		<xsl:when test="$nstPIs">
			<xsl:variable name="nstPI" select="$nstPIs[1]" />
			<xsl:variable name="strPIid" select="generate-id($nstPI)" />
			<xsl:variable name="strCommentaryId" 
				select="substring-before(
				        substring-after($nstPI, 'id=&quot;'), '&quot;')" />
			<xsl:variable name="nstNewCommentary" 
				select="key('CommentariesById', $strCommentaryId)" />
			<xsl:call-template name="FuncGetCommentariesFromPIs">
				<xsl:with-param name="nstPIs" select="$nstPIs[position() > 1]" />
				<xsl:with-param name="nstCommentaries"
					select="$nstCommentaries | $nstNewCommentary" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="$nstCommentaries">
				<commentary id="{substring-after(@id, 'c')}" xmlns="">
					<type><xsl:value-of select="@Type" /></type>
					<commentarycontent>
						<xsl:sequence select="node()" />
					</commentarycontent>
				</commentary>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	

<!-- *** Functions *** -->

<xsl:function name="msxsl:node-set" as="node()*">
	<xsl:param name="nodes" as="node()*" />
	<xsl:sequence select="$nodes" />
</xsl:function>

<xsl:function name="local:AddLinks" as="xs:string">
	<xsl:param name="text" as="xs:string" />
	<xsl:sequence select="''" />
</xsl:function>

</xsl:stylesheet>
