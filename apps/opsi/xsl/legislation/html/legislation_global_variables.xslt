<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Legislation schema XHTML output for consolidated legislation -->

<!-- Version 1.00 -->
<!-- Created by Griff Chamberlain -->
<!-- Global variables that are shared across all xslt workflows-->
<!-- Change history

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
xmlns:xhtml="http://www.w3.org/1999/xhtml" 
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" 
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" 
xmlns:math="http://www.w3.org/1998/Math/MathML" 
xmlns:msxsl="urn:schemas-microsoft-com:xslt"
xmlns:err="http://www.tso.co.uk/assets/namespace/error"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:dct="http://purl.org/dc/terms/"
xmlns:fo="http://www.w3.org/1999/XSL/Format" 
xmlns:svg="http://www.w3.org/2000/svg" 
xmlns:atom="http://www.w3.org/2005/Atom" 
exclude-result-prefixes="leg ukm math msxsl dc dct ukm fo xsl svg xhtml tso xs err">

	<!-- document metadata -->
	<xsl:variable 	name="g_ndsMetadata" select="/(leg:Legislation|leg:EN)/ukm:Metadata"/>

	<xsl:variable 	name="g_strDocumentStatus" select="$g_ndsMetadata/*/ukm:DocumentClassification/ukm:DocumentStatus/@Value"/>
	<xsl:variable 	name="g_strDocumentMainType" select="$g_ndsMetadata/*/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>
	<xsl:variable 	name="g_strDocumentYear" select="$g_ndsMetadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:BillMetadata | ukm:ENmetadata)/ukm:Year/@Value"/>
	<xsl:variable 	name="g_strDocumentNumber" select="$g_ndsMetadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:BillMetadata | ukm:ENmetadata)/ukm:Number/@Value"/>
	<xsl:variable 	name="g_strDocumentAltNumber" select="$g_ndsMetadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:BillMetadata | ukm:ENmetadata)/ukm:AlternativeNumber"/>
	<!-- This is specifically for EU treaties which use a name convention rather than a number convention-->
	<xsl:variable 	name="g_strDocumentName" select="$g_ndsMetadata/ukm:EUMetadata/ukm:Name/@Value"/>
	
	
	<xsl:variable 	name="g_strSchemaDefinitions" select="$tso:legTypeMap[@schemaType = $g_strDocumentMainType]"/>
	<xsl:variable 	name="g_strShortType" select="$g_strSchemaDefinitions/@abbrev"/>
	
	
	<xsl:variable 	name="g_euTypes" select="('EuropeanUnionRegulation', 'EuropeanUnionDecision', 'EuropeanUnionDirective')"/>
	<xsl:variable 	name="g_isEUretained" select="$g_strDocumentMainType = $g_euTypes"/>
	<xsl:variable 	name="g_isEUtreaty" select="$g_strDocumentMainType = ('EuropeanUnionTreaty')"/>
	<xsl:variable 	name="g_isEURetainedOrEUTreaty" select="$g_isEUretained or $g_isEUtreaty"/>
	<xsl:variable 	name="g_EUcelex" select="$g_ndsMetadata/ukm:EUMetadata/ukm:EURLexIdentifiers/ukm:CELEX/@Value"/>
	
	
	<xsl:variable 	name="g_pdfVersions" as="element()*" select="$g_ndsMetadata/ukm:Alternatives/ukm:Alternative"/>
	<xsl:variable 	name="g_correctionSlips" as="element()*" select="$g_ndsMetadata/ukm:CorrectionSlips/ukm:CorrectionSlip"/>
	
	<xsl:variable 	name="g_euExitDay"  as="xs:string?"
					select="$g_ndsMetadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/date/euexitday']/@title"/>
	<xsl:variable 	name="g_euExitRefs"  as="xs:string*"
					select="$g_ndsMetadata/atom:link[@rel = 'http://purl.org/dc/terms/references']/@href"/>

	<xsl:variable name="dcIdentifier" select="$g_ndsMetadata/dc:identifier"/>
	<xsl:variable name="dctitle" select="$g_ndsMetadata/dc:title"/>
	<xsl:variable name="dcalternative" select="$g_ndsMetadata/dct:alternative"/>
	<xsl:variable name="g_bestShortTitle" as="xs:string?" select="if (exists($dcalternative)) then $dcalternative[1] else  $dctitle[1]"/>
	
	<!-- document navigation uris -->
	<xsl:variable 	name="g_self" as="xs:string?" select="$g_ndsMetadata/atom:link[@rel='self']/@href"/>
	<xsl:variable 	name="g_strIntroductionUri"  as="xs:string?"
					select="$g_ndsMetadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/introduction']/@href"/>
	<xsl:variable 	name="g_strwholeActURI"  as="xs:string?"
					select="$g_ndsMetadata/atom:link[@rel = 'http://www.legislation.gov.uk/def/navigation/act']/@href"/>
	<xsl:variable 	name="g_strToC"  as="xs:string?"
					select="$g_ndsMetadata/atom:link[@rel = 'http://purl.org/dc/terms/tableOfContents']/@href"/>				
	<xsl:variable 	name="g_strsignatureURI" as="xs:string?" 
					select="$g_ndsMetadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/signature' and @title='signature']/@href"/>
	<xsl:variable 	name="g_strENURI" as="xs:string?" 
					select="$g_ndsMetadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/note' and @title='note']/@href"/>				
	<xsl:variable 	name="g_attachmentsOnlyURI" as="xs:string?"
					select="$g_ndsMetadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/attachments' and @title='attachments']/@href"/>
	<xsl:variable 	name="g_schedulesOnlyURI" as="xs:string?"
					select="($g_ndsMetadata/atom:link[@rel = ('http://www.legislation.gov.uk/def/navigation/schedules', 'http://www.legislation.gov.uk/def/navigation/annexes')]/@href)"/>
	<xsl:variable 	name="g_bodyURI" as="xs:string?"
					select="$g_ndsMetadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/body' and @title='body']/@href"/>
	<xsl:variable 	name="g_wholeActWithoutSchedulesURI" as="xs:string?"
					select="$g_bodyURI"/>				
					

	<!-- annotations and commentaries -->	
	<xsl:variable 	name="g_wholeActAmendments" as="element()*"
					select="$g_ndsMetadata/atom:link[@rel='http://purl.org/dc/terms/provenance']"/>	
					
	<xsl:variable 	name="g_wholeActCommentaries" as="element(leg:Commentary)*"
					select="for $ref in $g_wholeActAmendments/@href	
								return key('commentary', substring-after($ref, '#commentary-'))"/>

							
	<!-- EURLEX CELEX numbering functions -->
	<xsl:function name="leg:eurlex-uri" as="xs:string">
		<xsl:value-of select="'http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri='"/>
	</xsl:function>

	<xsl:function name="leg:webarchive-uri" as="xs:string">
		<xsl:value-of select="'https://webarchive.nationalarchives.gov.uk/eu-exit/https://eur-lex.europa.eu/legal-content/EN/TXT/?uri='"/>
	</xsl:function>

	<xsl:function name="leg:get-celex-number" as="xs:string">
		<xsl:param name="shortype" as="xs:string"/>
		<xsl:param name="year" as="xs:string?"/>
		<xsl:param name="number" as="xs:string?"/>
		<xsl:variable name="prefix" select="'CELEX:'"/>
		<xsl:variable name="CELEXtype" select="leg:celex-type($shortype)"/>
		<xsl:variable name="CELEXsector" select="'3'"/>
		<xsl:value-of select="if ($g_EUcelex) then concat($prefix, $g_EUcelex)
								else 
							concat($prefix, $CELEXsector, $year, $CELEXtype, format-number(xs:integer($number), '0000'))"/>
	</xsl:function>

	<xsl:function name="leg:celex-type" as="xs:string">
		<xsl:param name="shortype" as="xs:string"/>
		<xsl:value-of select="if ($shortype ='eur') then 'R'
								else if ($shortype ='eudn') then 'D'
								else if ($shortype ='eudr') then 'L'
								else ''"/>
	</xsl:function>				
							
</xsl:stylesheet>
