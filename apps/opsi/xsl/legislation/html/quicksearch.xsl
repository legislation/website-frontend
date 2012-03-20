<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

-->
<!-- UI EN Table of Content/Content page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 01/03/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"  version="2.0" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	exclude-result-prefixes="xs tso">
	
	<xsl:import href="../../common/utils.xsl" />
	
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

	<xsl:template name="TSOOutputQuickSearch">
		<form id="contentSearch" method="get" action="/search" class="contentSearch">
			<h2>Search Legislation</h2>
			<div class="title">
				<label for="title">Title: <em>(or keywords in the title)</em></label>
				<input type="text" id="title" name="title"/>
			</div>
			<div class="year">
				<label for="year">Year:</label>
				<input type="text" id="year" name="year" />
			</div>
			<div class="number">
				<label for="number">Number:</label>
				<input type="text" id="number" name="number" />
			</div>
			<div class="type">
				<label for="type">Type:</label>
				<xsl:call-template name="tso:TypeSelect" />
			</div>
			
			<div class="submit">
				<button type="submit" id="contentSearchSubmit" class="userFunctionalElement"><span class="btl"></span><span class="btr"></span>Search<span class="bbl"></span><span class="bbr"></span></button>
			</div>
			
			<div class="advSearch">
				<a href="/search">Advanced Search</a>
			</div>
		</form>	
	</xsl:template>
	
	<xsl:template name="addselected">
		<xsl:param name="type"/>
		<xsl:if test="$type = $paramsDoc/parameters/type">
			<xsl:attribute name="selected"/>
		</xsl:if>
	</xsl:template>	

</xsl:stylesheet>
