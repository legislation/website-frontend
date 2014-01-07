<?xml version="1.0" encoding="UTF-8"?>
<!--
©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/

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
	<xsl:variable name="requestInfoDoc" select="if (doc-available('input:request-info')) then doc('input:request-info') else ()"/>	

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
					<p>Would you like to continue?</p>
				</div>
			
				<div class="interface">
					<ul>
						<li class="continue"><a href="{$continueURL}" class="userFunctionalElement">
								<xsl:if test="$messageType = 'pdfWarning' or  $messageType = 'webWarning' ">
									<xsl:attribute name="target">_blank</xsl:attribute>
								</xsl:if>
						<span class="btl"></span><span class="btr"></span>Continue to open<span class="bbl"></span><span class="bbr"></span></a></li>
					</ul>
				</div>
			</div>
		</xsl:template>

	<!--  =========== Common Templates ================= -->
	<xsl:template match="ukm:AlternativeNumber" mode="series">
		<xsl:value-of select="concat(' (',  if (@Category eq 'NI') then 'N.I' else @Category, '. ', @Value, ')')"/>
	</xsl:template>

	<!-- ========== Standard code for html metadata ========= -->
	
	<xsl:template match="ukm:Metadata" mode="HTMLmetadata">
		<xsl:apply-templates mode="HTMLmetadata" />
		<meta name="Legislation.year" content="{*/ukm:Year/@Value}" />	
	</xsl:template>
	
	<xsl:template match="atom:link[@rel = ('self', 'alternate')]" mode="HTMLmetadata">
		<link rel="alternate"><xsl:apply-templates select="@type, @href, @title" mode="HTMLmetadata" /></link>
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
					<xsl:sequence select="replace(substring-after(., 'http://legislation.data.gov.uk'), '/data\.feed', '')" />
				</xsl:when>
				<xsl:when test="contains(., '/data.htm') and not(../@rel = ('self', 'alternate'))">
					<xsl:sequence select="replace(substring-after(., 'http://legislation.data.gov.uk'), '/data\.htm', '')" />
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
					<a href="{leg:FormatURL($tocURI, false())}">Table of Contents</a>
				</li>
				<li id="legContentLink">
					<span class="presentation"></span>
						<xsl:choose>
							<xsl:when test="exists($introURI)">
								<a href="{leg:FormatURL($introURI, false())}" class="disabled">Content</a>							
							</xsl:when>
							<xsl:otherwise>
								<span class="disabled">Content</span>
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
						<a href="{leg:FormatURL($impactURI, false())}">
						<xsl:if test="contains(lower-case($documentMainType),'draft')">
							<xsl:text>Draft </xsl:text>
						</xsl:if>
						<xsl:text>Impact Assessments</xsl:text></a>
						<a href="#moreIATabHelp" class="helpItem helpItemToBot">
							<img src="/images/chrome/helpIcon.gif" alt=" Help about ImpactAssessments" />
						</a>
					</li>
				</xsl:if>
				
				<xsl:if test="$IsMoreResourcesAvailable">
					<li id="legResourcesLink">
						<span class="presentation"></span>
						<a href="{leg:FormatURL($resourceURI, false())}">More Resources</a>
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
				<xsl:value-of select="$labelOfEn" />
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
			<xsl:when test="$enType = ('en','pn') ">
				<xsl:choose>
					<xsl:when test="$uriPrefix ='ukpga'">
						Text created by the government department responsible for the subject matter of the Act to explain what the Act sets out to achieve and to make the Act accessible to readers who are not legally qualified. Explanatory Notes were introduced in 1999 and accompany all Public Acts except Appropriation, Consolidated Fund, Finance and Consolidation Acts.
					</xsl:when>
					<xsl:when test="$uriPrefix ='nia'">
						Text created by the Northern Ireland Assembly department responsible for the subject matter of the Act to explain what the Act sets out to achieve and to make the Act accessible to readers who are not legally qualified. Explanatory Notes accompany all Acts of the Northern Ireland Assembly.
					</xsl:when>
					<xsl:when test="$uriPrefix ='asp'">
						Text created by the Scottish Executive department responsible for the subject matter of the Act to explain what the Act sets out to achieve and to make the Act accessible to readers who are not legally qualified. Explanatory Notes were introduced in 1999 and accompany all Acts of the Scottish Parliament except those which result from Budget Bills
					</xsl:when>
					<xsl:when test="$uriPrefix ='mwa'">
						Text created by the Welsh Assembly Government department responsible for the subject matter of the Measure to explain what the Measure sets out to achieve and to make the Measure accessible to readers who are not legally qualified. Explanatory Notes accompany all Measures of the National Assembly for Wales.
					</xsl:when>
					<xsl:when test="$uriPrefix ='anaw'">
						Text created by the Welsh Government department responsible for the subject matter of the Act to explain what the Act sets out to achieve and to make the Act accessible to readers who are not legally qualified. Explanatory Notes accompany all Acts of the National Assembly for Wales.
					</xsl:when>
					<xsl:when test="$uriPrefix =('ssi') and $enType = ('pn') ">
						Policy Note sets out a brief statement of the purpose of a Scottish Statutory Instrument and provides information about its policy objective and policy implications. They aim to make the Scottish Statutory Instrument accessible to readers who are not legally qualified and accompany any Scottish Statutory Instrument or Draft Scottish Statutory Instrument laid before the Scottish Parliament from July 2012 onwards. Prior to this date these type of notes existed as ‘Executive Notes’ and accompanied Scottish Statutory Instruments from July 2005 until July 2012.
					</xsl:when>
					<xsl:when test="$uriPrefix =('sdsi') and $enType = ('pn') ">
						Draft Policy Note sets out a brief statement of the purpose of a Draft Scottish Statutory Instrument and provides information about its policy objective and policy implications. They aim to make the Draft Scottish Statutory Instrument accessible to readers who are not legally qualified and accompany any Scottish Statutory Instrument or Draft Scottish Statutory Instrument laid before the Scottish Parliament from July 2012 onwards. Prior to this date these type of notes existed as 'Executive Notes' and accompanied Draft Scottish Statutory Instruments from July 2005 until July 2012.
					</xsl:when>
					<xsl:when test="$uriPrefix =('ssi', 'uksi') ">
						Executive Note sets out a brief statement of the purpose of a Scottish Statutory Instrument and provides information about its policy objective and policy implications. They aim to make the Scottish Statutory Instrument accessible to readers who are not legally qualified and accompany any Scottish Statutory Instrument or Draft Scottish Statutory Instrument laid before the Scottish Parliament from July 2005 onwards.
					</xsl:when>	
					<xsl:when test="$uriPrefix = ('sdsi', 'ukdsi')">
						Draft Executive Note sets out a brief statement of the purpose of a Draft Scottish Statutory Instrument and provides information about its policy objective and policy implications. They aim to make the Draft Scottish Statutory Instrument accessible to readers who are not legally qualified and accompany any Scottish Statutory Instrument or Draft Scottish Statutory Instrument laid before the Scottish Parliament from July 2005 onwards.
					</xsl:when>										
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$enType = 'em' ">
				<xsl:choose>
					<xsl:when test="$uriPrefix ='uksi'">
						Explanatory Memorandum sets out a brief statement of the purpose of a Statutory Instrument and provides information about its policy objective and policy implications. They aim to make the Statutory Instrument accessible to readers who are not legally qualified accompany any Statutory Instrument or Draft Statutory Instrument laid before Parliament from June 2004 onwards.
					</xsl:when>
					<xsl:when test="$uriPrefix ='nisi'">
						Explanatory Memorandum sets out a brief statement of the purpose of a Northern Ireland Order in Council and provides information about its policy objective and policy implications. They aim to make the Order accessible to readers who are not legally qualified and accompany any Northern Ireland Order in Council made since 2002.
					</xsl:when>					
					<xsl:when test="$uriPrefix ='nisr'">
						Explanatory Memorandum sets out a brief statement of the purpose of a Statutory Rule and provides information about its policy objective and policy implications. They aim to make the Statutory Rule accessible to readers who are not legally qualified and accompany any Northern Ireland Statutory Rule or Draft Northern Ireland Statutory Rule laid before the UK Parliament during the suspension of the Northern Ireland Assembly.
					</xsl:when>
					<xsl:when test="$uriPrefix = 'ukdsi'">
						Draft Explanatory Memorandum sets out a brief statement of the purpose of a Draft Statutory Instrument and provides information about its policy objective and policy implications. They aim to make the Draft Statutory Instrument accessible to readers who are not legally qualified accompany any Statutory Instrument or Draft Statutory Instrument laid before Parliament from June 2004 onwards.					
					</xsl:when>
					<xsl:when test="$uriPrefix = 'nidsr'">
						Draft Explanatory Memorandum sets out a brief statement of the purpose of a Draft Statutory Rule and provides information about its policy objective and policy implications. They aim to make the Draft Statutory Rule accessible to readers who are not legally qualified and accompany any Statutory Rule laid before the UK Parliament during the suspension of the Northern Ireland Assembly.
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
			<div class="help" id="moreResourcesTabHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>More Resources</h3>
					<p>Access essential accompanying documents and information for this legislation item from this tab. Dependent on the legislation item being viewed this may include:</p>
					<ul>
						<li>the original print PDF of the as enacted version that was used for the print copy</li>
						<li>lists of changes made by and/or affecting this legislation item</li>
						<li>confers power and blanket amendment details</li>
						<li>all formats of all associated documents</li>
						<li>correction slips</li>
						<li>links to related legislation and further information resources</li>																														
					</ul>
				</div>
			</div>		
		</xsl:if>		
		
		<xsl:if test="$IsImpactAssessmentsAvailable">
			<div class="help" id="moreIATabHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>Impact Assessments</h3>
					<p>Impact Assessments generally accompany all UK Government interventions of a regulatory nature that affect the private sector, civil society organisations and public services. They apply regardless of whether the regulation originates from a domestic or international source and can accompany primary (Acts etc) and secondary legislation (SIs). An Impact Assessment allows those with an interest in the policy area to understand:</p>
					<ul>
						<li>Why the government is proposing to intervene;</li>
						<li>The main options the government is considering, and which one is preferred;</li>
						<li>How and to what extent new policies may impact on them; and,</li>
						<li>The estimated costs and benefits of proposed measures.</li>
					</ul>
				</div>
			</div>		
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
			<div class="help" id="moreResourcesTabHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>More Resources</h3>
					<p>Access essential accompanying documents and information for this legislation item from this tab. Dependent on the legislation item being viewed this may include:</p>
					<ul>
						<li>the original print PDF of the as enacted version that was used for the print copy</li>
						<li>lists of changes made by and/or affecting this legislation item</li>
						<li>confers power and blanket amendment details</li>
						<li>all formats of all associated documents</li>
						<li>correction slips</li>
						<li>links to related legislation and further information resources</li>																														
					</ul>
				</div>
			</div>		
		</xsl:if>		
		
		<xsl:if test="$IsImpactAssessmentsAvailable">
			<div class="help" id="moreIATabHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>Impact Assessments</h3>
					<p>Impact Assessments generally accompany all UK Government interventions of a regulatory nature that affect the private sector, civil society organisations and public services. They apply regardless of whether the regulation originates from a domestic or international source and can accompany primary (Acts etc) and secondary legislation (SIs). An Impact Assessment allows those with an interest in the policy area to understand:</p>
					<ul>
						<li>Why the government is proposing to intervene;</li>
						<li>The main options the government is considering, and which one is preferred;</li>
						<li>How and to what extent new policies may impact on them; and,</li>
						<li>The estimated costs and benefits of proposed measures.</li>
					</ul>
				</div>
			</div>		
		</xsl:if>
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
					<h3><xsl:value-of select="$enLabel"/></h3>
					<p>
						<xsl:value-of select="$enhelpText" />
					 </p>
				</div>
			</div>	
		</xsl:if>	
	
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
