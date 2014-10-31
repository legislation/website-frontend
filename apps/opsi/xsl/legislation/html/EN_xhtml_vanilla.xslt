<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Legislation schema XHTML output for legislation -->



<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.tso.co.uk/assets/namespace/legislation"
xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata"
xmlns:math="http://www.w3.org/1998/Math/MathML"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:fo="http://www.w3.org/1999/XSL/Format"
xmlns:svg="http://www.w3.org/2000/svg"
exclude-result-prefixes="leg ukm math xhtml dc ukm fo xsl svg">


<xsl:param name="g_strLegislationXMLDocFilename"/>

<!-- ========== Global variables ========== -->

<!-- Path to the Vanilla HTML template -->
<xsl:variable name="g_ndsTemplateDoc" select="document('HTMLTemplate_Vanilla-v-1-0.xml')"/>

<!-- The prefix used for the legislation document images relative to the content. By default we will leave it blank so that images will need to be in the same folder as the content -->
<xsl:variable name="g_strDocumentImagesPath" select="''"/>


<!-- ========== Include core code ========== -->

<!-- Legislation Configuration module - gets the configuration information from the related XML file. -->
<xsl:include href="EN_xhtml_configuration.xslt"/>

<xsl:include href="EN_xhtml_core_vanilla.xslt"/>

</xsl:stylesheet>
 
