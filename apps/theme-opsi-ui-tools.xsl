<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	exclude-result-prefixes="#all">
<xsl:import href="theme-opsi-demo.xsl"/>
<xsl:output method="xhtml" indent="no" encoding="UTF-8" exclude-result-prefixes="xhtml" omit-xml-declaration="yes"/>

<xsl:preserve-space elements="*"/>


<xsl:template name="header"/>
<xsl:template name="footer"/>
<xsl:template name="background"/>
</xsl:stylesheet>
