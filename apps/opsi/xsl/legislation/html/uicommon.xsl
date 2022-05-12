<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"  version="2.0" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:db="http://docbook.org/ns/docbook"	
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events"
	>
	
	<xsl:import href="../../common/utils.xsl" />
	
	<xsl:variable name="requestInfoDoc" select="if (doc-available('input:request-info')) then doc('input:request-info') else ()"/>	
	
	<xsl:variable name="IsEURetained" as="xs:boolean" select="$g_strDocumentType = 'euretained'" />
	
	<xsl:template name="TSOOutputWarningMessage">
			<xsl:param name="messageId" as="xs:string" />	
			<xsl:param name="messageType" as="xs:string" />
			<xsl:param name="messageHeading" as="xs:string" />
			<xsl:param name="message" as="xs:string" />		
			<xsl:param name="continueURL" as="xs:string" />				
		
			<!-- print models-->
			<div id="{$messageId}" class="modWin">
				<div class="title {if ($messageType = 'pdfWarning') then 'pdfWarning' else 'webWarning'}Title">
				<!-- pdfWarning
					webWarning
					openingWholeWarning
					openingWholeWithoutSchedulesWarning
					openingSchedulesOnlyWarning
				-->
					<h3><xsl:value-of select="$messageHeading"/></h3>
				</div>
				<div class="content">
					<p><xsl:value-of select="$message"/></p>
					<p><xsl:value-of select="leg:TranslateText('Would you like to continue?')"/></p>
				</div>
			
				<div class="interface">
					<ul>
						<li class="continue"><a href="{$continueURL}" class="userFunctionalElement">
								<xsl:if test="$messageType = 'pdfWarning' or  $messageType = 'webWarning' ">
									<xsl:attribute name="target">_blank</xsl:attribute>
								</xsl:if>
							<span class="btl"></span><span class="btr"></span><xsl:value-of select="leg:TranslateText('Continue to open')"/><span class="bbl"></span><span class="bbr"></span></a></li>
					</ul>
				</div>
			</div>
		</xsl:template>

	<!--  =========== Common Templates ================= -->
	<xsl:template match="ukm:AlternativeNumber" mode="series">
		<xsl:value-of select="concat(' (',  if (@Category eq 'NI') then 'N.I' else @Category, '. ', @Value, ')')"/>
	</xsl:template>
	
	<!--  =========== Common Breadcrumb ================= -->
	<xsl:template name="legtypeBreadcrumb">
		<li class="first">
			<a href="{concat($TranslateLangPrefix, '/', $g_strShortType)}">
				<xsl:value-of select="$g_strSchemaDefinitions/@plural"/>
			</a>
		</li>
	</xsl:template>

	<!-- ========== Standard code for html metadata ========= -->
	
	<xsl:template match="ukm:Metadata" mode="HTMLmetadata">
		<xsl:apply-templates mode="HTMLmetadata" />
		<meta name="Legislation.year" content="{*/ukm:Year/@Value}" />	
		<xsl:if test="$IsEURetained and $hideEUdata">
			<meta name="robots" content="noindex, nofollow" />
		</xsl:if>
	</xsl:template>
	
	<!--HA070053: condition added to exclude the PDF alternate link from documents which are print only ie. we don't hold any xml data for, as these create a broken link-->
	<xsl:template match="atom:link[@rel = ('self', 'alternate')]" mode="HTMLmetadata">
 		<xsl:if test="(@type!='application/pdf')or ((@type='application/pdf')and not(leg:IsPDFOnly(/)))">
            <link rel="alternate"><xsl:apply-templates select="@type, @href, @title" mode="HTMLmetadata" /></link>
        </xsl:if>
  	</xsl:template>
	
	<xsl:template match="atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents']" mode="HTMLmetadata">
		<link rel="index"><xsl:apply-templates select="@type, @href, @title" mode="HTMLmetadata" /></link>
	</xsl:template>

	<xsl:template match="atom:link[@rel = ('up', 'prev', 'next')]" mode="HTMLmetadata">
		<link><xsl:apply-templates select="@rel, @type, @href, @title" mode="HTMLmetadata" /></link>
	</xsl:template>
	
	<xsl:template match="@rel | @title | @type" mode="HTMLmetadata">
		<xsl:sequence select="." />
	</xsl:template>
	
	<xsl:template match="@href" mode="HTMLmetadata">
		<xsl:attribute name="href">
			<xsl:choose>
				<xsl:when test="starts-with(., 'http://www.legislation.gov.uk')">
					<xsl:sequence select="substring-after(., 'http://www.legislation.gov.uk')" />
				</xsl:when>
				<xsl:when test="contains(., '/data.feed') and not(../@rel = ('self', 'alternate'))">
					<xsl:sequence select="replace(substring-after(., 'http://www.legislation.gov.uk'), '/data\.feed', '')" />
				</xsl:when>
				<xsl:when test="contains(., '/data.htm') and not(../@rel = ('self', 'alternate'))">
					<xsl:sequence select="replace(substring-after(., 'http://www.legislation.gov.uk'), '/data\.htm', '')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<!-- not using the identifier as we are currently returning the URI...we need to display ISBN --> 
	<xsl:template match="dc:identifier" mode="HTMLmetadata" priority="10" />
	<xsl:template match="dc:modified" mode="HTMLmetadata" priority="10">
		<meta name="DC.Date.Modified" content="{.}" />
	</xsl:template>	
	
	<xsl:template match="dc:title" mode="HTMLmetadata" priority="10">
		<meta name="DC.title" content="{.}" lang="en" />
	</xsl:template>	
	
	<xsl:template match="dc:date" mode="HTMLmetadata" priority="10">
		<meta name="DC.date.created" scheme="W3CDTF" content="{.}" />
	</xsl:template>		
	
	<xsl:template match="dc:type" mode="HTMLmetadata" priority="10">
		<meta name="DC.type" scheme="DCTERMS.DCMIType" content="{concat(upper-case(substring(.,1,1)),substring(.,2))}" />
	</xsl:template>		

	<xsl:template match="dc:format" mode="HTMLmetadata" priority="10">
		<meta name="DC.format" scheme="IMT" content="{.}" />
	</xsl:template>
	
	<xsl:template match="dc:language" mode="HTMLmetadata" priority="10">
		<meta name="DC.language" scheme="ISO639-2" content="{if (. = 'en') then 'eng' else .}" />
	</xsl:template>		
	
	<xsl:template match="dc:description" mode="HTMLmetadata" priority="10">
		<meta name="DC.description" content="{.}" />
		<meta name="description" content="{.}" />		
	</xsl:template>			
	
	<xsl:template match="*[starts-with(name(), 'dc:')]" mode="HTMLmetadata">
		<meta name="DC.{substring-after(name(), 'dc:')}" content="{.}"/>
	</xsl:template>
	
	<!-- wrapping the image around model window html -->
	<xsl:template match="leg:ExternalVersion">
		<xsl:param name="strContext"/>
		<xsl:param name="strDisplayFormat"/>
		<xsl:param name="strAltAttributeDesc"/>
		<xsl:param name="dblWidth"/>
		<xsl:param name="dblHeight"/>	
		<xsl:variable name="html" as="element()">
			<xsl:next-match>
				<xsl:with-param name="strContext" select="$strContext"/>
				<xsl:with-param name="strDisplayFormat" select="$strDisplayFormat"/>
				<xsl:with-param name="strAltAttributeDesc" select="$strAltAttributeDesc"/>
				<xsl:with-param name="dblWidth" select="$dblWidth"/>
				<xsl:with-param name="dblHeight" select="$dblHeight"/>	
			</xsl:next-match>
		</xsl:variable>
		<a href="{$html/@src}" target="_blank" class="previewImg">
				<span class="zoomIcon"></span>		
				<xsl:sequence select="$html" />
		</a>
	</xsl:template>
		
	<xsl:template match="*" mode="HTMLmetadata" />

	<xsl:template name="TSOOutputSubNavTabs">
		<ul id="legSubNav">
				<li id="legTocLink">
					<span class="presentation"></span>
					<a href="{leg:FormatURL($tocURI, false())}"><xsl:value-of select="leg:TranslateText('Table of Contents')"/></a>					
				</li>
				<li id="legContentLink">
					<span class="presentation"></span>
						<xsl:choose>
							<xsl:when test="exists($g_strIntroductionUri)">
								<a href="{leg:FormatURL($g_strIntroductionUri, false())}" class="disabled"><xsl:value-of select="leg:TranslateText('Content')"/></a>							
							</xsl:when>
							<xsl:otherwise>
								<span class="disabled"><xsl:value-of select="leg:TranslateText('Content')"/></span>
							</xsl:otherwise>
						</xsl:choose>
				</li>
				<!-- loading the Explanatory Memorandum-->
				<xsl:if test="$IsEmAvailable">
					<xsl:call-template name="TSOOutputSubNavTabsENs">
						<xsl:with-param name="typeOfEn" select="'em'"/>
						<xsl:with-param name="hrefOfEn" select="$emURI" />
					</xsl:call-template>
				</xsl:if>
				
				<!-- loading the Explanatory Memorandum-->
				<xsl:if test="$IsEnAvailable">
					<xsl:call-template name="TSOOutputSubNavTabsENs">
						<xsl:with-param name="typeOfEn" select="'en'"/>
						<xsl:with-param name="hrefOfEn" select="$enURI" />
					</xsl:call-template>
				</xsl:if>				
			
				<!-- loading the Policy Note -->
				<xsl:if test="$IsPnAvailable">
					<xsl:call-template name="TSOOutputSubNavTabsENs">
						<xsl:with-param name="typeOfEn" select="'pn'"/>
						<xsl:with-param name="hrefOfEn" select="$pnURI" />
					</xsl:call-template>
				</xsl:if>
				
				<xsl:if test="$IsImpactAssessmentsAvailable">
					<li id="legIALink">
						<span class="presentation" />
						<a href="{leg:FormatURL($impactURI, false())}"><xsl:value-of select="leg:TranslateText(if (contains(lower-case($documentMainType),'draft')) then 'Draft Impact Assessments' else 'Impact Assessments')"/></a>
						<a href="#moreIATabHelp" class="helpItem helpItemToBot">
							<img src="/images/chrome/helpIcon.gif" alt=" Help about ImpactAssessments" />
						</a>
					</li>
				</xsl:if>
				
				<xsl:if test="$IsMoreResourcesAvailable">
					<li id="legResourcesLink">
						<span class="presentation"></span>
						<a href="{leg:FormatURL($resourceURI, false())}"><xsl:value-of select="leg:TranslateText('More Resources')"/></a>
						<a href="#moreResourcesTabHelp" class="helpItem helpItemToBot">
							<img src="/images/chrome/helpIcon.gif" alt=" Help about More Resources"/>
						</a>
					</li>
				</xsl:if>
		</ul>			
	</xsl:template>

	<xsl:template name="TSOOutputSubNavTabsENs">
		<xsl:param name="typeOfEn" as="xs:string"/>
		<xsl:param name="hrefOfEn" as="xs:string"/>

		<xsl:variable name="labelOfEn"  select="tso:GetENLabel($documentMainType, $typeOfEn)" />
	  
		<li id="leg{concat(upper-case(substring($typeOfEn,1,1)),substring($typeOfEn,2))}Link">
			<span class="presentation"></span>							
			<a href="{leg:FormatURL($hrefOfEn, false())}">
				<xsl:value-of select="leg:TranslateText($labelOfEn)"/>
			</a>
			<xsl:if test="string-length(leg:GetENHelpText($uriPrefix,$typeOfEn)) ne 0">
				<a href="#{$typeOfEn}TabHelp" class="helpItem helpItemToBot">
					<img src="/images/chrome/helpIcon.gif" alt=" Help about {$labelOfEn}"/>
				</a>
			</xsl:if>
		</li>		
	</xsl:template>
				  



	<!-- ========== Standard code for help tips ========= -->
	<xsl:function name="leg:GetENHelpText">
		<xsl:param name="uriPrefix" as="xs:string"/>
		<xsl:param name="enType" as="xs:string?"/>
		
		<xsl:choose>
			<xsl:when test="$enType = ('en','pn')">
				<xsl:choose>
					<xsl:when test="$uriPrefix ='ukpga'">
						<xsl:value-of select="leg:TranslateText('EN_Help_1')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix ='nia'">
						<xsl:value-of select="leg:TranslateText('EN_Help_2')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix ='asp'">
						<xsl:value-of select="leg:TranslateText('EN_Help_3')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix ='mwa'">
						<xsl:value-of select="leg:TranslateText('helpText_en_mwa')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix ='anaw'">
						<xsl:value-of select="leg:TranslateText('EN_Help_4')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix ='asc'">
						<xsl:value-of select="leg:TranslateText('EN_Help_4a')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix =('ssi') and $enType = ('pn')">
						<xsl:value-of select="leg:TranslateText('EN_Help_5')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix =('sdsi') and $enType = ('pn')">
						<xsl:value-of select="leg:TranslateText('EN_Help_6')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix =('ssi', 'uksi') ">
						<xsl:value-of select="leg:TranslateText('EN_Help_7')"/>
					</xsl:when>	
					<xsl:when test="$uriPrefix = ('sdsi', 'ukdsi')">
						<xsl:value-of select="leg:TranslateText('EN_Help_8')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$enType = 'em' ">
				<xsl:choose>
					<xsl:when test="$uriPrefix ='uksi'">
						<xsl:value-of select="leg:TranslateText('helpText_em_mwa')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix ='nisi'">
						<xsl:value-of select="leg:TranslateText('EN_Help_9')"/>
					</xsl:when>					
					<xsl:when test="$uriPrefix ='nisr'">
						<xsl:value-of select="leg:TranslateText('EN_Help_10')"/>
					</xsl:when>
					<xsl:when test="$uriPrefix = 'ukdsi'">
						<xsl:value-of select="leg:TranslateText('EN_Help_11')"/>					
					</xsl:when>
					<xsl:when test="$uriPrefix = 'nidsr'">
						<xsl:value-of select="leg:TranslateText('EN_Help_12')"/>
					</xsl:when>					
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="TSOOutputIAsHelpTips">

		 <!-- loading the Explanatory Memorandum help-->
		<xsl:if test="$IsEmAvailable">
			<xsl:call-template name="TSOOutputENHelpTip">
				<xsl:with-param name="uriPrefix" select="$uriPrefix"/>
				<xsl:with-param name="documentMainType" select="$documentMainType"/>
				<xsl:with-param name="enType" select="'em'"/>				
			</xsl:call-template>
		</xsl:if>
		
		 <!-- loading the Explanatory Notes/Executive Notes help-->
		<xsl:if test="$IsEnAvailable">
			<xsl:call-template name="TSOOutputENHelpTip">
				<xsl:with-param name="uriPrefix" select="$uriPrefix"/>
				<xsl:with-param name="documentMainType" select="$documentMainType"/>
				<xsl:with-param name="enType" select="'en'"/>				
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="$IsMoreResourcesAvailable">
			<xsl:call-template name="TSOOutputMoreResourcesHelpTip">
				<xsl:with-param name="uriPrefix" select="$uriPrefix"/>
				<xsl:with-param name="documentMainType" select="$documentMainType"/>
			</xsl:call-template>		
		</xsl:if>		
		
		<xsl:if test="$IsImpactAssessmentsAvailable">
			<xsl:call-template name="TSOOutputIAHelpTip"/>		
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="TSOOutputENsHelpTips">

		 <!-- loading the Explanatory Memorandum help-->
		<xsl:if test="$IsEmAvailable">
			<xsl:call-template name="TSOOutputENHelpTip">
				<xsl:with-param name="uriPrefix" select="$uriPrefix"/>
				<xsl:with-param name="documentMainType" select="$documentMainType"/>
				<xsl:with-param name="enType" select="'em'"/>				
			</xsl:call-template>
		</xsl:if>
		
		 <!-- loading the Explanatory Notes/Executive Notes help-->
		<xsl:if test="$IsEnAvailable">
			<xsl:call-template name="TSOOutputENHelpTip">
				<xsl:with-param name="uriPrefix" select="$uriPrefix"/>
				<xsl:with-param name="documentMainType" select="$documentMainType"/>
				<xsl:with-param name="enType" select="'en'"/>				
			</xsl:call-template>
		</xsl:if>
		
		 <!-- loading the Policy Notes help-->
		<xsl:if test="$IsPnAvailable">
			<xsl:call-template name="TSOOutputENHelpTip">
				<xsl:with-param name="uriPrefix" select="$uriPrefix"/>
				<xsl:with-param name="documentMainType" select="$documentMainType"/>
				<xsl:with-param name="enType" select="'pn'"/>				
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="$IsMoreResourcesAvailable">
			<xsl:call-template name="TSOOutputMoreResourcesHelpTip">
				<xsl:with-param name="uriPrefix" select="$uriPrefix"/>
				<xsl:with-param name="documentMainType" select="$documentMainType"/>
			</xsl:call-template>		
		</xsl:if>		
		
		<xsl:if test="$IsImpactAssessmentsAvailable">
			<xsl:call-template name="TSOOutputIAHelpTip"/>	
		</xsl:if>
	</xsl:template>

	<xsl:template name="TSOOutputMoreResourcesHelpTip">
		<xsl:param name="uriPrefix" as="xs:string"/>
		<xsl:param name="documentMainType" as="xs:string" />
		
		<div class="help" id="moreResourcesTabHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					
					<h3><xsl:value-of select="leg:TranslateText('More Resources')"/></h3>
					<p><xsl:value-of select="leg:TranslateText('moreResourcesHelp_alt_para1')"/></p>
					<ul>
						<li>
							<xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul_li_1_part1')"/>
							<xsl:text> </xsl:text>
							<xsl:value-of 
								select="if ($g_strDocumentMainType = ('UnitedKingdomMinisterialDirection', 'UnitedKingdomMinisterialOrder')) then 
									leg:TranslateText('created')
								else if ($g_isEURetainedOrEUTreaty) then 
									leg:TranslateText('adopted')
								else leg:TranslateText('enacted')"/>
							<xsl:text> </xsl:text>							
							<xsl:value-of select="leg:TranslateText(if ($g_isEURetainedOrEUTreaty) then 'moreResourcesHelp_ul_li_1_part3eu' else 'moreResourcesHelp_ul_li_1_part3')"/>
						</li>
						<li><xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_1')"/></li>
						<xsl:if test="not($g_isEURetainedOrEUTreaty)">
							<li><xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_2')"/></li>
						</xsl:if>
						<li><xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_3')"/></li>
						<li><xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul_li_2')"/></li>
						<li><xsl:value-of select="leg:TranslateText('moreResourcesHelp_ul2_li_4')"/></li>
					</ul>
				</div>
			</div>	
	</xsl:template>
	
	<xsl:template name="TSOOutputENHelpTip">
		<xsl:param name="enType" as="xs:string"/>	
		<xsl:param name="uriPrefix" as="xs:string"/>
		<xsl:param name="documentMainType" as="xs:string" />
		
		<xsl:variable name="enLabel">
			<xsl:sequence select="tso:GetENLabel($documentMainType,$enType)" />
		</xsl:variable>		
		
		<xsl:variable name="enhelpText" select="leg:GetENHelpText($uriPrefix, $enType)"/>
		
		<xsl:if test="string-length($enhelpText) &gt; 0">
			<div class="help" id="{$enType}TabHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3><xsl:value-of select="leg:TranslateText($enLabel)"/></h3>
					<p>
						<xsl:value-of select="$enhelpText" />
					 </p>
				</div>
			</div>	
		</xsl:if>	
	
	</xsl:template>
	
	<xsl:template name="TSOOutputIAHelpTip">
		<div class="help" id="moreIATabHelp">
			<span class="icon"/>
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif"/>
				</a>
				<h3><xsl:value-of select="leg:TranslateText('Impact Assessments')"/></h3>
				<p><xsl:value-of select="leg:TranslateText('IA_tooltip_1')"/></p>
				<ul>
					<li><xsl:value-of select="leg:TranslateText('IA_tooltip_2')"/></li>
					<li><xsl:value-of select="leg:TranslateText('IA_tooltip_3')"/></li>
					<li><xsl:value-of select="leg:TranslateText('IA_tooltip_4')"/></li>
					<li><xsl:value-of select="leg:TranslateText('IA_tooltip_5')"/></li>
				</ul>
			</div>
		</div>	
	</xsl:template>

	<!-- ========== Standard code for query-string functions========= -->
	
	<xsl:function name="leg:get-query" as="xs:string">
		<xsl:param name="params" as="xs:string"/>
	
		<xsl:variable name="qs" select="$requestInfoDoc/request/query-string"/>
		
		<xsl:variable name="filtered-qs" as="xs:string*">
			<xsl:for-each select="tokenize($qs, '&amp;')">
				<xsl:analyze-string select="." regex="({string-join($params, '|')})=\w*">
				<xsl:matching-substring>
					<xsl:sequence select="regex-group(0)"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
			</xsl:for-each>
		</xsl:variable>
		<xsl:sequence select="string-join($filtered-qs, '&amp;')"/>
	</xsl:function>
	
	<xsl:function name="leg:set-query-params" as="xs:string">
		<xsl:param name="name" as="xs:string"/>	
		<xsl:param name="value" as="xs:string"/>		
		
		<xsl:variable name="qs" select="$requestInfoDoc/request/query-string"/>
	
		<xsl:choose>
			<xsl:when test="string-length(leg:get-query($name)) = 0">
				<xsl:variable name="namevalue" select="concat($name,'=', $value)"/>
				<xsl:choose>
					<xsl:when test="string-length($qs) = 0"><xsl:sequence select="$namevalue"/></xsl:when>
					<xsl:otherwise><xsl:sequence select="concat($qs, '&amp;', $namevalue)"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="filtered-qs" as="xs:string*">
					<xsl:for-each select="tokenize($qs, '&amp;')">
						<xsl:variable name="param" select="substring-before(., '=')"/>
						<xsl:analyze-string select="." regex="({string-join($param, '|')})=\w*">
							<xsl:matching-substring>
								<xsl:choose>
									<xsl:when test="$param = $name">
										<xsl:if test="$value != '' ">
											<xsl:sequence select="concat($param,'=', $value)"/>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise><xsl:sequence select="regex-group(0)"/></xsl:otherwise>
								</xsl:choose>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</xsl:for-each>
				</xsl:variable>
				<xsl:sequence select="string-join($filtered-qs, '&amp;')"/>		
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	

</xsl:stylesheet>
