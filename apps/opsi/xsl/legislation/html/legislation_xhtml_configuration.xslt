<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v2.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

-->
<!-- Legislation configuration XSLT  -->
<!-- Crown Copyright 2006 -->

<!-- Version 1.00 -->
<!-- Created by Manjit Jootle -->
<!-- Last changed 14/09/2006 by Manjit Jootle -->

<!-- Change history

-->

<!--

Settings for this XSLT:

MSXML4
Preserve white space = true
Validate = true

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
exclude-result-prefixes="leg xhtml xsl">


<!-- ========== Global variables ========== -->

<!-- Path to the Legislation Configuration XML file used for output. -->
<xsl:variable name="g_ndsLegisConfigDoc" select="document('legislationconfiguration.xml')"/>

<!-- Path to where images are. -->
<xsl:variable name="g_strImagesPath" select="concat($g_ndsLegisConfigDoc//path[@type = 'images']/@href, '/')"/>

<!-- Path to where styles are. -->
<xsl:variable name="g_strStylesPath" select="concat($g_ndsLegisConfigDoc//path[@type = 'CSS']/@href, '/')"/>

</xsl:stylesheet>