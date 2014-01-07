<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<!-- Legislation configuration XSLT  -->
<!-- Crown Copyright 2006 -->



<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.tso.co.uk/assets/namespace/legislation"
exclude-result-prefixes="leg xhtml xsl">


<!-- ========== Global variables ========== -->

<!-- Path to the Legislation Configuration XML file used for output. -->
<xsl:variable name="g_ndsLegisConfigDoc" select="document('legislationconfiguration.xml')"/>

<!-- Path to where images are. -->
<xsl:variable name="g_strImagesPath" select="concat($g_ndsLegisConfigDoc//path[@type = 'images']/@href, '/')"/>

<!-- Path to where styles are. -->
<xsl:variable name="g_strStylesPath" select="concat($g_ndsLegisConfigDoc//path[@type = 'CSS']/@href, '/')"/>

</xsl:stylesheet>