<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Legislation schema XHTML output for legislation - utilities module -->

<!-- Version 1.00 -->
<!-- Created by Manjit Jootle -->
<!-- Last changed 14/09/2006 by Manjit Jootle -->

<!-- Change history
Colin 06/06/13 NOT added code to output Welsh as this template is only used by  old code (new code uses format-date XSLT2)
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xsl">


<!-- ========== Functions ========== -->

<!-- Assuming that the input date is in CCYY-MM-DD format - converts format to long format, i.e. 01 January 2006 -->
<xsl:template name="FormatLongDate">
	<xsl:param name="strInputDate"/>
	<xsl:variable name="strSpace" select="' '"/>
	<!-- Day -->
	<xsl:variable name="strDay" select="substring($strInputDate, 9, 2)"/>
	<!-- Month -->
	<xsl:variable name="strMonth" select="substring($strInputDate, 6, 2)"/>
	<xsl:variable name="strMonthText">
		<xsl:choose>
			<xsl:when test="$strMonth = '01'"><xsl:text>January</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '02'"><xsl:text>February</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '03'"><xsl:text>March</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '04'"><xsl:text>April</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '05'"><xsl:text>May</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '06'"><xsl:text>June</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '07'"><xsl:text>July</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '08'"><xsl:text>August</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '09'"><xsl:text>September</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '10'"><xsl:text>October</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '11'"><xsl:text>November</xsl:text></xsl:when>
			<xsl:when test="$strMonth = '12'"><xsl:text>December</xsl:text></xsl:when>
			<xsl:otherwise>Invalid Month</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- Century and Year -->
	<xsl:variable name="strYear" select="substring($strInputDate, 1, 4)"/>
	<!-- New format of D Month CCYY. -->
	<xsl:value-of select="concat($strDay, $strSpace, $strMonthText, $strSpace, $strYear)"/>
</xsl:template>

</xsl:stylesheet>