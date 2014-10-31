<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Legislation schema XHTML output for legislation -->

<!-- Version 1.01 -->
<!-- Created by Paul Appleby -->
<!-- Last changed 27/02/2007 by Paul Appleby -->

<!-- Change history

	27/02/2007		Paul Appleby	Added reference for metadata
	21/10/2005		Created

 -->

<!-- This file is used to produce the XHTML from the legislation schema -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
xmlns:math="http://www.w3.org/1998/Math/MathML"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:fo="http://www.w3.org/1999/XSL/Format"
xmlns:svg="http://www.w3.org/2000/svg"
exclude-result-prefixes="leg ukm math xhtml dc ukm fo xsl svg">

<xsl:output method="xml" version="1.0" omit-xml-declaration="yes"  indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>


<!-- ========== Global variables ========== -->

<!-- Path to the Vanilla HTML template -->
<xsl:variable name="g_ndsTemplateDoc" select="document('HTMLTemplate_Vanilla-v-1-0.xml')"/>

<!-- The prefix used for the legislation document images relative to the content. By default we will leave it blank so that images will need to be in the same folder as the content -->
<xsl:variable name="g_strDocumentImagesPath" select="''"/>

<!-- ========== Include core code ========== -->

<!-- Legislation Configuration module - gets the configuration information from the related XML file. -->
<xsl:include href="legislation_xhtml_configuration.xslt"/>

<xsl:include href="legislation_xhtml_core_vanilla.xslt"/>

</xsl:stylesheet>
 
