<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<!-- Output frontmatter. This is basically metadata and is used more for development than the final finished product -->
<xsl:template name="TSOoutputFrontmatter">
	<fo:page-sequence master-reference="front-sequence" letter-value="traditional" xml:lang="{$g_documentLanguage}">
		<fo:flow flow-name="xsl-region-body" font-family="{$g_strMainFont}" white-space-collapse="false" line-height-shift-adjustment="disregard-shifts">
			<fo:block text-align="center">
				<fo:inline font-size="36pt" color="navy">UK Legislation</fo:inline>
			</fo:block>
			<fo:block font-size="18pt" text-align="center">
				<fo:basic-link external-destination="url('http://www.tso.co.uk')">www.tso.co.uk</fo:basic-link>
			</fo:block>
			<fo:block border="solid 0.5pt black" padding="12pt" space-before="24pt">
					<fo:table font-size="10pt" table-layout="fixed" width="100%">
						<fo:table-column column-width="30%"/>									
						<fo:table-column column-width="70%"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell number-columns-spanned="2" text-align="center">
									<fo:block space-after="14pt" color="navy" font-size="12pt" font-weight="bold">Document Metadata</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row>
								<fo:table-cell><fo:block color="navy">Title</fo:block></fo:table-cell>
								<fo:table-cell text-align="left">
									<fo:block>
									<xsl:call-template name="TSOprocessText">
											<xsl:with-param name="strText" select="/leg:Legislation/ukm:Metadata/dc:title"/>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row>
								<fo:table-cell><fo:block color="navy">ISBN</fo:block></fo:table-cell>
								<fo:table-cell><fo:block><xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:identifier"/></fo:block></fo:table-cell>
							</fo:table-row>
							<fo:table-row>
								<fo:table-cell><fo:block color="navy">Document Category</fo:block></fo:table-cell>
								<fo:table-cell><fo:block><xsl:value-of select="$g_ndsLegMetadata/ukm:DocumentClassification/ukm:DocumentCategory/@Value"/></fo:block></fo:table-cell>
							</fo:table-row>
							<fo:table-row>
								<fo:table-cell><fo:block color="navy">Document Type</fo:block></fo:table-cell>
								<fo:table-cell><fo:block><xsl:value-of select="$g_strDocType"/></fo:block></fo:table-cell>
							</fo:table-row>
							<fo:table-row>
								<fo:table-cell><fo:block color="navy">Year</fo:block></fo:table-cell>
								<fo:table-cell><fo:block><xsl:value-of select="$g_ndsLegMetadata/ukm:Year/@Value"/></fo:block></fo:table-cell>
							</fo:table-row>
							<fo:table-row>
								<fo:table-cell><fo:block color="navy">Number</fo:block></fo:table-cell>
								<fo:table-cell><fo:block><xsl:value-of select="$g_ndsLegMetadata/ukm:Number/@Value"/></fo:block></fo:table-cell>
							</fo:table-row>
							<xsl:if test="$g_strDocClass = $g_strConstantPrimary">
								<fo:table-row>
									<fo:table-cell><fo:block color="navy">Enactment Date</fo:block></fo:table-cell>
									<fo:table-cell><fo:block><xsl:value-of select="//ukm:EnactmentDate/@Date"/></fo:block></fo:table-cell>
								</fo:table-row>
							</xsl:if>
							<xsl:if test="$g_strDocClass = $g_strConstantSecondary and //ukm:DepartmentCode">
								<fo:table-row>
									<fo:table-cell><fo:block color="navy">Department Code</fo:block></fo:table-cell>
									<fo:table-cell><fo:block><xsl:value-of select="//ukm:DepartmentCode/@Value"/></fo:block></fo:table-cell>
								</fo:table-row>
							</xsl:if>
						</fo:table-body>
					</fo:table>
			</fo:block>
		</fo:flow>
	</fo:page-sequence>
</xsl:template>

</xsl:stylesheet>