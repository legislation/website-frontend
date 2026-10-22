<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="2.0">



<!-- routine for removing duplicate ids -->
	
<xsl:key name="ids" match="*" use="@id" />


<xsl:template match="node() | @*">
	<xsl:copy>
		<xsl:apply-templates select="node() | @*"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="*[@id]">
	<xsl:variable name="uniqueID" select="key('ids', @id)[1] is ."/>
	<xsl:copy>
		<xsl:for-each select="@*">
			<xsl:choose>
				<xsl:when test="name(.) = 'id' and not($uniqueID)">
					<xsl:message>DUUPLICATE ID <xsl:value-of select="."/></xsl:message>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:apply-templates/>	
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>