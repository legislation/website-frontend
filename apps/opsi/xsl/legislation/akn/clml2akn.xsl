<?xml version="1.0" encoding="utf-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

<!-- v1.2, written by Jim Mangiafico, updated 18 September 2015 -->

<xsl:stylesheet version="2.0"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0/WD16"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:clml2akn="http://clml2akn.mangiafico.com/"
	exclude-result-prefixes="xs ukl ukm html math dc dct atom fo clml2akn">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />
<xsl:strip-space elements="*" />

<!-- keys -->

<xsl:key name="id" match="*" use="@id" />
<xsl:key name="commentary" match="Commentary" use="@Type" />


<!-- global variables -->

<xsl:variable name="root" select="/" />

<xsl:variable name="ukm-doctype" select="/Legislation/ukm:Metadata/ukm:*/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />

<xsl:variable name="minor-type" select="/Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:DocumentClassification/ukm:DocumentMinorType/@Value" />

<xsl:variable name="is-fragment" select="count(/Legislation/ukm:Metadata/atom:link[@rel='up']) > 0" as="xs:boolean" />

<xsl:variable name="expr-this" as="xs:string">
	<xsl:value-of select="/Legislation/ukm:Metadata/dc:identifier" />
</xsl:variable>

<xsl:variable name="expr-uri" as="xs:string">
	<xsl:choose>
		<xsl:when test="$is-fragment">
			<xsl:value-of select="/Legislation/ukm:Metadata/atom:link[@rel='up']/@href" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$expr-this" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="doc-uri" as="xs:string">
	<xsl:variable name="base" as="xs:string">
		<xsl:value-of select="concat('http://www.legislation.gov.uk/id/', substring-after($expr-uri, 'http://www.legislation.gov.uk/'))" />
	</xsl:variable>
	<xsl:analyze-string select="$base" regex="(/enacted)? ( /\d{{4}}-\d{{2}}-\d{{2}} | /made | /welsh )$" flags="x">
		<xsl:non-matching-substring><xsl:value-of select="." /></xsl:non-matching-substring>
	</xsl:analyze-string>		
</xsl:variable>

<xsl:variable name="point-in-time" as="xs:date?">
	<xsl:analyze-string select="$expr-this" regex="\d{{4}}-\d{{2}}-\d{{2}}$">
		<xsl:matching-substring><xsl:value-of select="." /></xsl:matching-substring>
	</xsl:analyze-string>		
</xsl:variable>

<xsl:variable name="this-uri" as="xs:string">
	<xsl:variable name="base" as="xs:string">
		<xsl:value-of select="concat('http://www.legislation.gov.uk/id/', substring-after($expr-this, 'http://www.legislation.gov.uk/'))" />
	</xsl:variable>
	<xsl:analyze-string select="$base" regex="(/enacted)? ( /\d{{4}}-\d{{2}}-\d{{2}} | /made | /welsh )$" flags="x">
		<xsl:non-matching-substring><xsl:value-of select="." /></xsl:non-matching-substring>
	</xsl:analyze-string>
</xsl:variable>

<!-- global functions -->

<!-- returns the value of 'id' attribute, if present, else generates an id -->
<xsl:function name="clml2akn:id" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/@id"><xsl:value-of select="$e/@id" /></xsl:when>
		<xsl:otherwise><xsl:value-of select="generate-id($e)" /></xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- returns a unique id for each version of a provision -->
<xsl:function name="clml2akn:vid" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/ancestor::Version">
			<xsl:variable name="slashed-id" select="replace($e/@id, '-', '/')" as="xs:string" />
			<xsl:variable name="slashed-version" select="substring-after($e/@DocumentURI, $slashed-id)" as="xs:string" />
			<xsl:variable name="hyphenated-version" select="replace($slashed-version, '/', '-')" as="xs:string" />
			<xsl:value-of select="concat(clml2akn:id($e), $hyphenated-version)" />
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="clml2akn:id($e)" /></xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- returns an id for each term, to allow term elements to refer to metadata counterparts -->
<xsl:function name="clml2akn:term-id" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/@id"><xsl:value-of select="$e/@id" /></xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat('term-', lower-case(translate(replace($e, ' ', '-'), '&#34;“”%', '')))" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- a sequence of unique time periods, in chronological order -->
<xsl:variable name="periods" as="xs:string *">
	<xsl:for-each-group select="//*[@RestrictStartDate | @RestrictEndDate]" group-by="concat(@RestrictStartDate, '-', @RestrictEndDate)">
		<xsl:sort select="concat(@RestrictStartDate, '-', @RestrictEndDate)" />
		<xsl:value-of select="concat(@RestrictStartDate, '-', @RestrictEndDate)" />
	</xsl:for-each-group>
</xsl:variable>

<!-- returns a unique id for each unique pair of dates -->
<xsl:function name="clml2akn:period-id" as="xs:string?">
	<xsl:param name="start" as="xs:date?" />
	<xsl:param name="end" as="xs:date?" />
	<xsl:variable name="position" select="index-of($periods, concat($start, '-', $end))" />
	<xsl:value-of select="concat('period', string($position))" />
</xsl:function>

<!-- a sequence of unique dates, in chronological order -->
<xsl:variable name="event-dates" as="xs:date *">
	<xsl:for-each-group select="//@RestrictStartDate | //@RestrictEndDate" group-by=".">
		<xsl:sort />
		<xsl:value-of select="." />
	</xsl:for-each-group>
</xsl:variable>

<!-- returns a unique id for each unique dates -->
<xsl:function name="clml2akn:event-id" as="xs:string">
	<xsl:param name="date" as="xs:date" />
	<xsl:variable name="position" select="index-of($event-dates, $date)" />
	<xsl:value-of select="concat('effective-date-', string($position))" />
</xsl:function>

<!-- takes an id and returns the order that commentary appears -->
<xsl:function name="clml2akn:commentary-num" as="xs:integer">
	<xsl:param name="type" as="xs:string" />
	<xsl:param name="commentary-id" as="xs:string" />
	<xsl:variable name="commentary-ids" as="xs:string*">
		<xsl:for-each select="key('commentary', $type, $root)">
			<xsl:sequence select="@id" />
		</xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="index-of($commentary-ids, $commentary-id)[1]" />
</xsl:function>


<!-- helper templates -->

<!-- adds a period attribute to a given element -->
<xsl:template name="period">
	<xsl:param name="e" select="." as="element()?" />
	<xsl:param name="class" select="''" as="xs:string" />
	<xsl:if test="$e/@RestrictStartDate | $e/@RestrictEndDate">
		<xsl:attribute name="period">
			<xsl:text>#</xsl:text>
			<xsl:value-of select="clml2akn:period-id($e/@RestrictStartDate, $e/@RestrictEndDate)" />
		</xsl:attribute>
	</xsl:if>
	<xsl:if test="$e/@Status">
		<xsl:attribute name="class"><xsl:value-of select="string-join(($class, lower-case($e/@Status)), ' ')" /></xsl:attribute>
	</xsl:if>
</xsl:template>

<!-- adds alternative versions of a provision -->
<xsl:template name="alt-versions">
	<xsl:param name="e" select="." as="element()" />
	<xsl:if test="$e/@AltVersionRefs and not($e/ancestor::Version)">
		<xsl:for-each select="tokenize($e/@AltVersionRefs, ' ')">
			<xsl:variable name="alt-version" select="key('id', ., $root)" />
			<xsl:apply-templates select="$alt-version/*" />
		</xsl:for-each>
	</xsl:if>		
	
</xsl:template>


<!-- main templates -->

<xsl:template match="/">
	<akomaNtoso><xsl:apply-templates /></akomaNtoso>
</xsl:template>

<xsl:template match="/Legislation">

	<xsl:variable name="eName" as="xs:string">
		<xsl:choose>
			<xsl:when test="$is-fragment">portion</xsl:when>
			<xsl:otherwise>act</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:element name="{$eName}">
	
		<xsl:choose>
			<xsl:when test="$is-fragment">
				<xsl:attribute name="includedIn"><xsl:value-of select="$doc-uri" /></xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="name"><xsl:value-of select="$ukm-doctype" /></xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates select="ukm:Metadata" />

		<xsl:call-template name="cover" />

		<xsl:apply-templates select="Primary | Secondary" />

	</xsl:element>

</xsl:template>


<!-- metadata -->

<xsl:function name="clml2akn:alias" as="element()?">
	<xsl:param name="uri" as="xs:string" />
	<xsl:for-each select="('/wsi/', '/nisi/')">
		<xsl:if test="contains($uri, .)">
			<FRBRalias value="{replace($uri, ., '/uksi/')}" name="UnitedKingdomStatutoryInstrument" />
		</xsl:if>
	</xsl:for-each>
</xsl:function>

<xsl:template match="ukm:Metadata">

	<meta>
		<identification source="#source">

			<xsl:variable name="work-date" select="ukm:PrimaryMetadata/ukm:EnactmentDate/@Date | ukm:SecondaryMetadata/ukm:Made/@Date" />
			<FRBRWork>
				<FRBRthis value="{$this-uri}" />
				<FRBRuri value="{$doc-uri}" />
				<xsl:copy-of select="clml2akn:alias($this-uri)" />
				<FRBRdate date="{$work-date}">
					<xsl:attribute name="name">
						<xsl:choose>
							<xsl:when test="ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value = 'primary'">enacted</xsl:when>
							<xsl:otherwise>made</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</FRBRdate>
				<FRBRauthor>
					<xsl:attribute name="href">
						<xsl:text>http://www.legislation.gov.uk/id/</xsl:text>
						<xsl:choose>
							<xsl:when test="$ukm-doctype = 'EnglandAct'">legislature/EnglishParliament</xsl:when>
							<xsl:when test="$ukm-doctype = 'GreatBritainAct'">legislature/ParliamentOfGreatBritain</xsl:when>
							<xsl:when test="$ukm-doctype = 'IrelandAct'">legislature/OldIrishParliament</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAct'">legislature/NorthernIrelandAssembly</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAssemblyMeasure'">legislature/NorthernIrelandAssembly</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandParliamentAct'">legislature/NorthernIrelandParliament  </xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandOrderInCouncil'">government/uk</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandDraftOrderInCouncil'">government/uk</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandStatutoryRule'">government/northern-ireland</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandDraftStatutoryRule'">government/northern-ireland</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishAct'">legislature/ScottishParliament</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishOldAct'">legislature/OldScottishParliament</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishStatutoryInstrument'">government/scotland</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishDraftStatutoryInstrument'">government/scotland</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchInstrument'">legislature/GeneralSynod</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchMeasure'">legislature/GeneralSynod</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPrivateAct'">legislature/UnitedKingdomParliament</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPublicGeneralAct'">legislature/UnitedKingdomParliament</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomLocalAct'">legislature/UnitedKingdomParliament</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomMinisterialOrder'">government/uk</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomStatutoryInstrument'">government/uk</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomDraftStatutoryInstrument'">government/uk</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshAssemblyMeasure'">legislature/NationalAssemblyForWales</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshNationalAssemblyAct'">legislature/NationalAssemblyForWales</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshStatutoryInstrument'">government/wales</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshDraftStatutoryInstrument'">government/wales</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</FRBRauthor>
				<FRBRcountry>
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="$ukm-doctype = 'EnglandAct'">GB-ENG</xsl:when>
							<xsl:when test="$ukm-doctype = 'GreatBritainAct'">GB-GBN</xsl:when>
							<xsl:when test="$ukm-doctype = 'IrelandAct'">IE</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAct'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAssemblyMeasure'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandParliamentAct'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandOrderInCouncil'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandDraftOrderInCouncil'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandStatutoryRule'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandDraftStatutoryRule'">GB-NIR</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishAct'">GB-SCT</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishOldAct'">GB-SCT</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishStatutoryInstrument'">GB-SCT</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishDraftStatutoryInstrument'">GB-SCT</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchInstrument'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchMeasure'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPrivateAct'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPublicGeneralAct'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomLocalAct'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomMinisterialOrder'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomStatutoryInstrument'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomDraftStatutoryInstrument'">GB-UKM</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshAssemblyMeasure'">GB-WLS</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshNationalAssemblyAct'">GB-WLS</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshStatutoryInstrument'">GB-WLS</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshDraftStatutoryInstrument'">GB-WLS</xsl:when>
							<xsl:otherwise>GB-UKM</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</FRBRcountry>
				<xsl:if test="ukm:SecondaryMetadata/ukm:DocumentClassification/ukm:DocumentMinorType">
					<FRBRsubtype value="{ukm:SecondaryMetadata/ukm:DocumentClassification/ukm:DocumentMinorType/@Value}" />
				</xsl:if>
				<FRBRnumber value="{ukm:*/ukm:Number/@Value}" />
				<FRBRname>
					<xsl:attribute name="value">
						<xsl:variable name="year" select="ukm:PrimaryMetadata/ukm:Year/@Value | ukm:SecondaryMetadata/ukm:Year/@Value" />
						<xsl:variable name="num" select="ukm:PrimaryMetadata/ukm:Number/@Value | ukm:SecondaryMetadata/ukm:Number/@Value" />
						<xsl:choose>
							<xsl:when test="$ukm-doctype = 'EnglandAct'">
								<xsl:value-of select="concat($year, ' c. ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'GreatBritainAct'">
								<xsl:value-of select="concat($year, ' c. ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'IrelandAct'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' [I]')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAct'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' (N.I.)')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandAssemblyMeasure'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' (N.I.)')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandParliamentAct'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' (N.I.)')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandOrderInCouncil' or $ukm-doctype = 'NorthernIrelandDraftOrderInCouncil'">
								<xsl:variable name="alt-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='NI']/@Value" />
								<xsl:value-of select="concat('S.I. ', $year, '/', $num, ' (N.I. ', $alt-num, ')')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'NorthernIrelandStatutoryRule' or $ukm-doctype = 'NorthernIrelandDraftStatutoryRule'">
								<xsl:choose>
									<xsl:when test="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']">
										<xsl:variable name="c-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']/@Value" />
										<xsl:value-of select="concat('S.R. ', $year, '/', $num, ' (C. ', $c-num, ')')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('S.R. ', $year, '/', $num)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishAct'">
								<xsl:value-of select="concat($year, ' asp ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishOldAct'">
								<xsl:value-of select="concat($year, ' c. ', $num, ' [S]')" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'ScottishStatutoryInstrument' or $ukm-doctype = 'ScottishDraftStatutoryInstrument'">
								<xsl:choose>
									<xsl:when test="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']">
										<xsl:variable name="c-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']/@Value" />
										<xsl:value-of select="concat('S.S.I. ', $year, '/', $num, ' (C. ', $c-num, ')')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('S.S.I. ', $year, '/', $num)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchInstrument'">
								<xsl:value-of select="concat('Church Instrument ', $year, '/', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomChurchMeasure'">
								<xsl:value-of select="concat($year, ' No. ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPrivateAct'">
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomPublicGeneralAct'">
								<xsl:value-of select="concat($year, ' c. ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomLocalAct'">
								<xsl:value-of select="$year" />
								<xsl:text> c. </xsl:text>
								<xsl:number value="$num" format="i" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomMinisterialOrder'">
								<xsl:value-of select="concat('Ministerial Order ', $year, '/', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'UnitedKingdomStatutoryInstrument' or $ukm-doctype = 'UnitedKingdomDraftStatutoryInstrument'">
								<xsl:choose>
									<xsl:when test="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C' or @Category='L' or @Category='S']">
										<xsl:variable name="alt-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C' or @Category='L' or @Category='S']" />
										<xsl:value-of select="concat('S.I. ', $year, '/', $num, ' (', $alt-num/@Category,'. ', $alt-num/@Value, ')')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('S.I. ', $year, '/', $num)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshAssemblyMeasure'">
								<xsl:value-of select="concat($year, ' nawm ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshNationalAssemblyAct'">
								<xsl:value-of select="concat($year, ' anaw ', $num)" />
							</xsl:when>
							<xsl:when test="$ukm-doctype = 'WelshStatutoryInstrument' or $ukm-doctype = 'WelshDraftStatutoryInstrument'">
								<xsl:variable name="alt-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='W' or @Category='Cy']/@Value" />
								<xsl:choose>
									<xsl:when test="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']">
										<xsl:variable name="c-num" select="ukm:SecondaryMetadata/ukm:AlternativeNumber[@Category='C']/@Value" />
										<xsl:value-of select="concat('S.I. ', $year, '/', $num, ' (W. ', $alt-num, ') (C. ', $c-num,')')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('S.I. ', $year, '/', $num, ' (W. ', $alt-num, ')')" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($year, ' c. ', $num)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</FRBRname>
				<FRBRprescriptive value="true" />
			</FRBRWork>

			<FRBRExpression>
				<FRBRthis value="{$expr-this}" />
				<FRBRuri value="{$expr-uri}" />
				<xsl:copy-of select="clml2akn:alias($expr-this)" />
				<FRBRdate>
					<xsl:attribute name="date">
						<xsl:choose>
							<xsl:when test="dct:valid"><xsl:value-of select="dct:valid" /></xsl:when>
							<xsl:otherwise><xsl:value-of select="$work-date" /></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="name">
						<xsl:choose>
							<xsl:when test="dct:valid">validFrom</xsl:when>
							<xsl:when test="ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value = 'primary'">enacted</xsl:when>
							<xsl:otherwise>made</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</FRBRdate>
				<FRBRauthor href="#source" />
				<FRBRlanguage>
					<xsl:attribute name="language">
						<xsl:choose>
							<xsl:when test="dc:language = 'cy'">cym</xsl:when>
							<xsl:otherwise>eng</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</FRBRlanguage>
			</FRBRExpression>

			<FRBRManifestation>
				<xsl:variable name="mani-this" select="concat($expr-this, '/data.akn')" />
				<FRBRthis value="{$mani-this}" />
				<FRBRuri value="{$expr-uri}/data.akn" />
				<xsl:copy-of select="clml2akn:alias($mani-this)" />
				<FRBRdate date="{current-date()}" name="transform" />
				<FRBRauthor href="http://www.legislation.gov.uk" />
				<FRBRformat value="application/akn+xml" />
			</FRBRManifestation>
		</identification>
		
		<!-- classification -->
		<xsl:if test="dc:subject">
			<classification source="#source">
				<xsl:for-each select="dc:subject">
					<keyword value="{lower-case(.)}" showAs="{.}" dictionary="http://www.legislation.gov.uk" />
				</xsl:for-each>
			</classification>
		</xsl:if>
				
		<!-- lifecycle -->
		<lifecycle source="#source">
			<xsl:if test="ukm:PrimaryMetadata/ukm:EnactmentDate">
				<eventRef date="{ukm:PrimaryMetadata/ukm:EnactmentDate/@Date}" type="generation" eId="enacted-date" source="#source" />
			</xsl:if>
			<xsl:if test="ukm:SecondaryMetadata/ukm:Made">
				<eventRef date="{ukm:SecondaryMetadata/ukm:Made/@Date}" type="generation" eId="made-date" source="#source" />
			</xsl:if>
			<xsl:if test="ukm:SecondaryMetadata/ukm:Laid">
				<eventRef date="{ukm:SecondaryMetadata/ukm:Laid/@Date}" eId="laid-date" source="#source" />
			</xsl:if>
			<xsl:for-each select="ukm:SecondaryMetadata/ukm:ComingIntoForce/ukm:DateTime">
				<eventRef date="{@Date}" eId="coming-into-force-date-{position()}" source="#source" />
			</xsl:for-each>

			<!-- adds an eventRef element for each date in a dc:hasVersion atom link -->
			<xsl:for-each select="atom:link[@rel='http://purl.org/dc/terms/hasVersion']">
				<xsl:if test="@title castable as xs:date">
			        <eventRef date="{@title}" type="amendment" source="#source" />
				</xsl:if>
			</xsl:for-each>

			<!-- adds an eventRef element for each date in a RestrictStartDate or @RestrictEndDate attribute -->
			<xsl:for-each select="$event-dates">
		        <eventRef date="{.}" eId="effective-date-{position()}" source="#source" />
			</xsl:for-each>
		</lifecycle>
		
		<!-- analysis -->
		<!-- adds a passiveModification for each Addition, Repeal or Substitution (only one per unique ChangeId attribute) -->
		<!-- adds a restriction for each unique RestrictExtent attribute -->
		<xsl:variable name="modifications" select="//Addition | //Repeal | //Substitution" as="element()*" />
		<xsl:variable name="restrictions" select="//*[@RestrictExtent]" as="element()*" />
		<xsl:if test="$modifications or $restrictions">
			<analysis source="#source">
				<xsl:if test="$modifications">
					<passiveModifications>
						<xsl:for-each-group select="$modifications" group-by="@ChangeId">
							<textualMod>
								<xsl:attribute name="type">
									<xsl:choose>
										<xsl:when test="self::Addition">insertion</xsl:when>
										<xsl:when test="self::Repeal">repeal</xsl:when>
										<xsl:when test="self::Substitution">substitution</xsl:when>
									</xsl:choose>
								</xsl:attribute>
								<xsl:attribute name="eId"><xsl:value-of select="@ChangeId" /></xsl:attribute>
								<source href="#{@CommentaryRef}" />
								<destination href="#{./ancestor::*[@id][1]/@id}" /><!-- id of first ancestor -->
							</textualMod>
						</xsl:for-each-group>
					</passiveModifications>
				</xsl:if>
				<xsl:if test="$restrictions">
					<restrictions source="#source">
						<xsl:for-each select="$restrictions">
							<xsl:sort select="@id" />
							<restriction>
								<xsl:if test="not(self::Legislation)">
									<xsl:attribute name="href">
										<xsl:text>#</xsl:text>
										<xsl:choose>
											<xsl:when test="self::ContentsItem"><xsl:value-of select="@ContentRef" /></xsl:when>
											<xsl:when test="self::PrimaryPrelims">preface</xsl:when>
											<xsl:when test="self::Body">body</xsl:when>
											<xsl:when test="self::P1group[count(P1) = 1][not(P1/@RestrictExtent)]"><xsl:value-of select="clml2akn:vid(P1)" /></xsl:when>
											<xsl:when test="self::P2group[count(P2) = 1]"><xsl:value-of select="clml2akn:vid(P2)" /></xsl:when>
											<xsl:otherwise><xsl:value-of select="clml2akn:vid(.)" /></xsl:otherwise>
										</xsl:choose>
										<xsl:if test="count(key('id', @id)[@RestrictExtent][not(ancestor::Versions)]) > 1">
											<xsl:text>[</xsl:text>
											<xsl:value-of select="index-of(key('id', @id), .)" />
											<xsl:text>]</xsl:text>
										</xsl:if>
									</xsl:attribute>
								</xsl:if>
								<xsl:attribute name="refersTo">
									<xsl:text>#</xsl:text>
									<xsl:value-of select="lower-case(replace(@RestrictExtent,'\.',''))" />
								</xsl:attribute>
								<xsl:attribute name="type">jurisdiction</xsl:attribute>
							</restriction>
						</xsl:for-each>
					</restrictions>
				</xsl:if>
			</analysis>
		</xsl:if>
		
		<!-- temporal data -->
		<!-- add a timeInterval element for each unique pair of RestrictStartDate and RestrictEndDate attributes -->
		<xsl:if test="//*[@RestrictStartDate | @RestrictEndDate]">
			<temporalData source="#source">
				<xsl:for-each-group select="//*[@RestrictStartDate | @RestrictEndDate]" group-by="concat(@RestrictStartDate, '-', @RestrictEndDate)">
					<xsl:sort select="concat(@RestrictStartDate, '-', @RestrictEndDate)" />
					<temporalGroup eId="period{position()}">
						<timeInterval>
							<xsl:if test="@RestrictStartDate">
								<xsl:attribute name="start">
									<xsl:text>#</xsl:text>
									<xsl:value-of select="clml2akn:event-id(@RestrictStartDate)" />
								</xsl:attribute>
							</xsl:if>
							<xsl:if test="@RestrictEndDate">
								<xsl:attribute name="end">
									<xsl:text>#</xsl:text>
									<xsl:value-of select="clml2akn:event-id(@RestrictEndDate)" />
								</xsl:attribute>
							</xsl:if>
							<xsl:attribute name="refersTo">
								<xsl:text>#period-concept</xsl:text>
								<xsl:value-of select="position()" />
							</xsl:attribute>
						</timeInterval>
					</temporalGroup>
				</xsl:for-each-group>
			</temporalData>
		</xsl:if>

		<!-- references -->
		<!-- a passiveRef element for each UnappliedEffect -->
		<!-- a TLCOrganization for each Department -->
		<!-- a TLCLocation for each unique RestrictExtent and each AddressLine -->
		<!-- a TLCRole for each JobTitle -->
		<!-- a TLCPerson for each PersonName -->
		<!-- a TLCTerm for each unique Term -->
		<!-- a TLCConcept for each unique territorial extent and each unique Subject -->
		<references source="#source">
		
			<TLCOrganization eId="source">
				<xsl:variable name="dc-publishers" select="dc:publisher" as="xs:string*" />
				<xsl:attribute name="href">
					<xsl:text>http://www.legislation.gov.uk/id/</xsl:text>
					<xsl:choose>
						<xsl:when test="$dc-publishers = ('King''s Printer of Acts of Parliament', 'Queen''s Printer of Acts of Parliament')">
							<xsl:text>publisher/KingsOrQueensPrinterOfActsOfParliament</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('King''s Printer for Scotland', 'Queen''s Printer for Scotland')">
							<xsl:text>publisher/KingsOrQueensPrinterForScotland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Government Printer for Northern Ireland')">
							<xsl:text>publisher/GovernmentPrinterForNorthernIreland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('The National Archives')">
							<xsl:text>publisher/TheNationalArchives</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Statute Law Database')">
							<xsl:text>publisher/StatuteLawDatabase</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Westlaw')">
							<xsl:text>contributor/Westlaw</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="translate($dc-publishers[1], ' ', '')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="showAs">
					<xsl:choose>
						<xsl:when test="$dc-publishers = ('King''s Printer of Acts of Parliament')">
							<xsl:text>King's Printer of Acts of Parliament</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Queen''s Printer of Acts of Parliament')">
							<xsl:text>Queen's Printer of Acts of Parliament</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('King''s Printer for Scotland')">
							<xsl:text>King's Printer for Scotland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Queen''s Printer for Scotland')">
							<xsl:text>Queen's Printer for Scotland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Government Printer for Northern Ireland')">
							<xsl:text>Government Printer for Northern Ireland</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('The National Archives')">
							<xsl:text>The National Archives</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Statute Law Database')">
							<xsl:text>Statute Law Database</xsl:text>
						</xsl:when>
						<xsl:when test="$dc-publishers = ('Westlaw')">
							<xsl:text>Westlaw</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$dc-publishers[1]" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</TLCOrganization>
		
			<xsl:for-each-group select="ukm:*/ukm:UnappliedEffects/ukm:UnappliedEffect" group-by="@AffectingURI">
				<xsl:sort select="@AffectingURI" />
				<passiveRef href="{@AffectingURI}" showAs="{ukm:AffectingTitle[1]}" />
			</xsl:for-each-group>

			<xsl:for-each select="//Department">
				<TLCOrganization eId="ref-{clml2akn:id(.)}" href="/ontology/organization/uk.{replace(.,' ’','')}" showAs="{.}" />			
			</xsl:for-each>

			<xsl:for-each-group select="//@RestrictExtent" group-by=".">
				<TLCLocation eId="{lower-case(replace(.,'\.',''))}">
					<xsl:variable name="extent" select="replace(.,'E','England')" />
					<xsl:variable name="extent" select="replace($extent, 'W', 'Wales')" />
					<xsl:variable name="extent" select="replace($extent, 'S', 'Scotland')" />
					<xsl:variable name="extent" select="replace($extent, 'N.I.', 'Northern Ireland')" />
					<xsl:attribute name="href">
						<xsl:text>/ontology/jurisdictions/uk.</xsl:text>
						<xsl:value-of select="translate($extent, '\+ ', '')" />
					</xsl:attribute>
					<xsl:attribute name="showAs">
						<xsl:value-of select="string-join(tokenize($extent, '\+'), ', ')" />
					</xsl:attribute>
				</TLCLocation>
			</xsl:for-each-group>
			
			<xsl:for-each select="//AddressLine">
				<TLCLocation eId="{lower-case(translate(.,' ,',''))}" href="/ontology/location/uk.{translate(.,' ,','')}" showAs="{.}" />
			</xsl:for-each>

			<xsl:for-each select="//JobTitle">
				<TLCRole eId="ref-{clml2akn:id(.)}" href="/ontology/role/uk.{replace(.,' ’','')}" showAs="{.}" />			
			</xsl:for-each>

			<xsl:for-each select="//PersonName">
				<TLCPerson eId="ref-{clml2akn:id(.)}" href="/ontology/persons/uk.{replace(.,' ','')}" showAs="{.}" />			
			</xsl:for-each>

 			<xsl:for-each-group select="//Term" group-by="clml2akn:term-id(.)">
 				<xsl:variable name="id" select="clml2akn:term-id(.)" />
				<TLCTerm eId="{$id}" href="/ontology/term/uk.{replace($id, 'term-', '')}" showAs="{.}" />
			</xsl:for-each-group>

			<xsl:for-each-group select="//*[@RestrictStartDate | @RestrictEndDate]" group-by="concat(@RestrictStartDate,@RestrictEndDate)">
				<xsl:sort select="concat(@RestrictStartDate,@RestrictEndDate)" />
				<TLCConcept eId="period-concept{position()}">
					<xsl:attribute name="href">
						<xsl:text>/ontology/time/</xsl:text>
						<xsl:value-of select="replace(@RestrictStartDate,'-','.')" />
						<xsl:if test="@RestrictEndDate">
							<xsl:text>-</xsl:text>
							<xsl:value-of select="replace(@RestrictEndDate,'-','.')" />
						</xsl:if>
					</xsl:attribute>
					<xsl:variable name="period-string">
						<xsl:choose>
							<xsl:when test="@RestrictStartDate and @RestrictEndDate">
								<xsl:text>from </xsl:text>
								<xsl:value-of select="@RestrictStartDate" />
								<xsl:text> until </xsl:text>
								<xsl:value-of select="@RestrictEndDate" />
							</xsl:when>
							<xsl:when test="@RestrictStartDate and not(@RestrictEndDate)">
								<xsl:text>since </xsl:text>
								<xsl:value-of select="@RestrictStartDate" />
							</xsl:when>
							<xsl:when test="not(@RestrictStartDate) and @RestrictEndDate">
								<xsl:text> before </xsl:text>
								<xsl:value-of select="@RestrictEndDate" />
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:attribute name="showAs"><xsl:value-of select="$period-string" /></xsl:attribute>
				</TLCConcept>
			</xsl:for-each-group>
			<xsl:for-each select="/Legislation/Secondary/SecondaryPrelims/SubjectInformation/Subject/Title |
				/Legislation/Secondary/SecondaryPrelims/SubjectInformation/Subject/Subtitle">
				<TLCConcept href="/uk/subject/{lower-case(translate(., ' ,', '-'))}" showAs="{.}" eId="{clml2akn:id(.)}" />
			</xsl:for-each>
		</references>
		
		<!-- notes -->
		<!-- see templates for Commentaries, MarginNotes & Footnotes -->
		<xsl:if test="/Legislation/Commentaries | /Legislation/MarginNotes | /Legislation/Footnotes">
			<notes source="#source">
				<xsl:apply-templates select="/Legislation/Commentaries/Commentary | /Legislation/MarginNotes/MarginNote | /Legislation/Footnotes/Footnote" />
			</notes>
		</xsl:if>
		
		<!-- proprietary -->
		<!-- all ukm:Metadata with namespace -->
		<proprietary source="#source">
			<xsl:namespace name="ukl" select="'http://www.legislation.gov.uk/namespaces/legislation'"/>
			<xsl:namespace name="ukm" select="'http://www.legislation.gov.uk/namespaces/metadata'"/>
			<xsl:namespace name="dc" select="'http://purl.org/dc/elements/1.1/'"/>
			<xsl:namespace name="dct" select="'http://purl.org/dc/terms/'"/>
			<xsl:namespace name="atom" select="'http://www.w3.org/2005/Atom'"/>
			<xsl:if test="../@RestrictStartDate">
				<ukl:RestrictStartDate value="{../@RestrictStartDate}" />
			</xsl:if>
			<xsl:if test="../@RestrictEndDate">
				<ukl:RestrictEndDate value="{../@RestrictEndDate}" />
			</xsl:if>
			<xsl:if test="../@Status">
				<ukl:Status value="{../@Status}" />
			</xsl:if>
			<xsl:apply-templates />
		</proprietary>
	</meta>

</xsl:template>

<xsl:template match="/Legislation/ukm:Metadata//*">
	<xsl:element name="{name()}">
		<xsl:copy-of select="@*"/> 
		<xsl:apply-templates select="node()" />
	</xsl:element>
</xsl:template>


<!-- main top-level templates (primary & secondary) -->

<xsl:template match="Primary | Secondary">
	<xsl:choose>
		<xsl:when test="$is-fragment">
			<portionBody>
				<xsl:if test="Body/@RestrictExtent">
					<xsl:attribute name="eId">body</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="period"><xsl:with-param name="e" select="Body" /></xsl:call-template>
				<xsl:apply-templates select="PrimaryPrelims | SecondaryPrelims" />
				<xsl:apply-templates select="Body/*[not(self::CommentaryRef)]" />
				<xsl:apply-templates select="Schedules" />
				<xsl:apply-templates select="ExplanatoryNotes | EarlierOrders" />
			</portionBody>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="PrimaryPrelims | SecondaryPrelims" />
			<body>
				<xsl:if test="Body/@RestrictExtent">
					<xsl:attribute name="eId">body</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="period"><xsl:with-param name="e" select="Body" /></xsl:call-template>
				<xsl:apply-templates select="Body/*[not(self::CommentaryRef)]" />
				<xsl:apply-templates select="Schedules" />
			</body>
			<xsl:if test="ExplanatoryNotes | EarlierOrders">
				<conclusions><xsl:apply-templates select="ExplanatoryNotes | EarlierOrders" /></conclusions>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- cover page -->

<xsl:template name="cover">
	<xsl:if test="not($is-fragment) and Contents">
		<coverPage>
			<xsl:apply-templates select="Contents" />
		</coverPage>
	</xsl:if>
</xsl:template>

<xsl:template match="CoverTitle">
	<p class="title"><xsl:apply-templates /></p>
</xsl:template>


<!-- tables of contents -->

<xsl:template match="Contents">
	<toc class="body">
		<xsl:call-template name="period" />
		<xsl:apply-templates select="*[not(self::ContentsSchedules)]" />
	</toc>
	<xsl:apply-templates select="ContentsSchedules" />
</xsl:template>

<xsl:template match="ContentsSchedules">
	<toc class="schedules">
		<xsl:call-template name="period" />
		<xsl:apply-templates />
	</toc>
</xsl:template>

<xsl:template match="Contents/ContentsTitle | ContentsSchedules/ContentsTitle">
	<tocItem level="0" class="title" href=""><xsl:apply-templates /></tocItem>
</xsl:template>

<xsl:template match="ContentsPart | ContentsChapter | ContentsPblock | ContentsPsubBlock | ContentsItem | ContentsSubItem | ContentsSchedule | ContentsAppendix">
	<xsl:param name="level" select="1" />
	<xsl:variable name="class" as="xs:string?">
		<xsl:choose>
			<xsl:when test="self::ContentsPart">part</xsl:when>
			<xsl:when test="self::ContentsChapter">chapter</xsl:when>
			<xsl:when test="self::ContentsPblock">heading</xsl:when>
			<xsl:when test="self::ContentsPsubBlock">subheading</xsl:when>
			<xsl:when test="self::ContentsItem">item</xsl:when>
			<xsl:when test="self::ContentsSubItem">subitem</xsl:when>
			<xsl:when test="self::ContentsSchedule">schedule</xsl:when>
			<xsl:when test="self::ContentsAppendix">appendix</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<tocItem href="{@IdURI}" level="{$level}" class="{$class}">
		<xsl:call-template name="period">
			<xsl:with-param name="class" select="$class" />
		</xsl:call-template>
		<xsl:apply-templates select="ContentsNumber | ContentsTitle" />
	</tocItem>
	<xsl:apply-templates select="*[not(self::ContentsNumber)][not(self::ContentsTitle)]">
		<xsl:with-param name="level" select="$level + 1" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="ContentsNumber">
	<inline name="tocNum"><xsl:apply-templates /></inline>
</xsl:template>
<xsl:template match="ContentsTitle">
	<inline name="tocHeading"><xsl:apply-templates /></inline>
</xsl:template>


<!-- preface -->

<xsl:template match="PrimaryPrelims | SecondaryPrelims">
	<xsl:choose>
		<xsl:when test="$is-fragment">
			<preface>
				<xsl:if test="@RestrictExtent">
					<xsl:attribute name="eId">preface</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="period" />
				<xsl:apply-templates select="*[not(self::PrimaryPreamble)][not(self::SecondaryPreamble)]" />
				<xsl:apply-templates select="../Body/CommentaryRef" />
				<xsl:apply-templates select="PrimaryPreamble | SecondaryPreamble" />	
			</preface>
		</xsl:when>
		<xsl:otherwise>
			<preface>
				<xsl:if test="@RestrictExtent">
					<xsl:attribute name="eId">preface</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="period" />
				<xsl:apply-templates select="*[not(self::PrimaryPreamble)][not(self::SecondaryPreamble)]" />
				<xsl:if test="empty(PrimaryPreamble | SecondaryPreamble)">
					<xsl:apply-templates select="../Body/CommentaryRef" />
				</xsl:if>
			</preface>
			<xsl:apply-templates select="PrimaryPreamble | SecondaryPreamble" />	
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Draft">
	<blockContainer class="draft"><xsl:apply-templates /></blockContainer>
</xsl:template>

<xsl:template match="PrimaryPrelims/Title | SecondaryPrelims/Title">
	<p class="title"><shortTitle><xsl:apply-templates /></shortTitle></p>
</xsl:template>

<xsl:template match="PrimaryPrelims/Number | SecondaryPrelims/Number">
	<p class="number"><docNumber><xsl:apply-templates /></docNumber></p>
</xsl:template>

<xsl:template match="Subject">
	<block name="subject"><xsl:apply-templates /></block>
</xsl:template>
<xsl:template match="Subject/Title | Subject/Subtitle">
	<concept class="{lower-case(local-name())}" refersTo="#{clml2akn:id(.)}"><xsl:apply-templates /></concept>
</xsl:template>

<xsl:template match="LongTitle">
	<longTitle>
		<p><xsl:apply-templates /></p>
	</longTitle>
</xsl:template>

<xsl:template match="DateOfEnactment">
	<p class="{local-name()}"><xsl:apply-templates /></p>
</xsl:template>
<xsl:template match="DateOfEnactment/DateText">
	<docDate>
		<xsl:attribute name="date" select="/Legislation/ukm:Metadata/ukm:*/ukm:EnactmentDate/@Date" />
		<xsl:apply-templates />
	</docDate>
</xsl:template>

<xsl:template match="Approved">
	<p class="approved"><xsl:apply-templates /></p>
</xsl:template>

<xsl:template match="LaidDraft | MadeDate | LaidDate | ComingIntoForce[not(ComingIntoForceClauses)] | ComingIntoForceClauses">
	<p class="{local-name()}"><xsl:apply-templates /></p>
</xsl:template>
<xsl:template match="ComingIntoForce[ComingIntoForceClauses]">
	<container name="{local-name()}"><xsl:apply-templates /></container>
</xsl:template>

<xsl:template match="LaidDraft/Text | MadeDate/Text | LaidDate/Text | ComingIntoForce[not(ComingIntoForceClauses)]/Text | ComingIntoForceClauses/Text">
	<span><xsl:apply-templates /></span>
</xsl:template>
<xsl:template match="ComingIntoForce[ComingIntoForceClauses]/Text">
	<p><xsl:apply-templates /></p>
</xsl:template>

<xsl:template match="MadeDate/DateText | LaidDate/DateText | ComingIntoForce/DateText | ComingIntoForceClauses/DateText">
	<docDate>
		<xsl:attribute name="date">
			<xsl:choose>
				<xsl:when test="parent::MadeDate">
					<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:Made/@Date" />
				</xsl:when>
				<xsl:when test="parent::LaidDate">
					<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:Laid/@Date" />
				</xsl:when>
				<xsl:when test="parent::ComingIntoForce">
					<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:ComingIntoForce/ukm:DateTime/@Date" />
				</xsl:when>
				<xsl:when test="parent::ComingIntoForceClauses">
					<xsl:variable name="pos" select="count(../preceding-sibling::ComingIntoForceClauses) + 1" as="xs:integer" />
					<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:ComingIntoForce/ukm:DateTime[$pos]/@Date" />
				</xsl:when>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates />
	</docDate>
</xsl:template>


<!-- preamble -->

<xsl:template match="PrimaryPreamble | SecondaryPreamble">
	<xsl:choose>
		<xsl:when test="$is-fragment">
			<xsl:apply-templates />
			<xsl:apply-templates select="../../Body/CommentaryRef" />
		</xsl:when>
		<xsl:otherwise>
			<preamble>
				<xsl:call-template name="period" />
				<xsl:apply-templates />
				<xsl:apply-templates select="../../Body/CommentaryRef" />
			</preamble>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="RoyalPresence">
	<container name="RoyalPresence"><xsl:apply-templates /></container>
</xsl:template>

<xsl:template match="PrimaryPreamble/IntroductoryText | SecondaryPreamble/IntroductoryText">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="EnactingText">
	<formula name="EnactingText"><xsl:apply-templates /></formula>
</xsl:template>


<!-- main structure -->

<!--

key helper template for all hierarchical elements
takes up to 6 parameters:
  name - the name of the element, must be the name of an element in the Akoma Ntoso hierarchy, required
  hcontainter-name - the value of the @name attribute, used only if element name is 'hcontainer', defaults to empty string
  attrs - a sequence of atributes to be added, defaults to empty sequence
  number - an element to be used for the num, defaults to Number or Pnumber
  title - a sequence of elements to be used for the heading, defaults to the Title child
  subtitle - a sequence of elements to be used for the subheading, defaults to the Subtitle child
  para - a sequence of elements whose children should be treated as direct children of the element, defaults to P1para, etc 

if the element is an alternative version, wId is set to the id of the principal version

after setting the name, attributes, heading and subheading,
if the context element or any of the para elements contains a hierarchical element, then
  1. wrap all children before the first hierarchical child in an <intro> element
  2. apply templates corresponding to the hierarchical children
  3. wrap all children after the last hierarchical child in a <wrapUp> element
else
  wrap all children in a <content> element

follows the element immediately with any alternative version(s)
-->

<xsl:template name="hierarchy">

	<xsl:param name="name" as="xs:string" />
	<xsl:param name="hcontainer-name" as="xs:string" select="''" />
	<xsl:param name="attrs" as="attribute()*" select="()" />
	<xsl:param name="number" as="element()*" select="Number | Pnumber" />	<!-- Pnumber siblings in ukpga/1985/6 -->
	<xsl:param name="title" as="element()*" select="Title" />
	<xsl:param name="subtitle" as="element()*" select="Subtitle" />
	<xsl:param name="paras" as="element()*" select="P | P1para | P2para | P3para | P4para | P5para | P6para" />

	<xsl:element name="{$name}">
		<xsl:if test="$name = 'hcontainer'">
			<xsl:attribute name="name"><xsl:value-of select="$hcontainer-name" /></xsl:attribute>
		</xsl:if>

		<!-- id -->
		<xsl:attribute name="eId"><xsl:value-of select="clml2akn:vid(.)" /></xsl:attribute>
		<xsl:if test="ancestor::Version">
			<xsl:attribute name="alternativeTo"><xsl:value-of select="clml2akn:id(.)" /></xsl:attribute>
		</xsl:if>
		
		<xsl:call-template name="period" />
		
		<xsl:copy-of select="$attrs" />
		
		<!-- number -->
		<xsl:apply-templates select="$number" />

		<!-- heading -->
		<xsl:choose>
			<xsl:when test="count($title) > 1"><!-- see, e.g., ukpga/1983/2 & ukpga/1990/1 -->
				<heading>
					<xsl:for-each select="$title">
						<inline name="multi-heading">
							<xsl:apply-templates select="./node()" />
						</inline>
						<xsl:if test="position() != last()"><br/></xsl:if>
					</xsl:for-each>
				</heading>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$title" />
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:apply-templates select="$subtitle" />

		<xsl:variable name="paras-with-subs" select="$paras[Part | Chapter | Pblock |
			PsubBlock | P1 | P1group | P2 | P2group | P3 | P4 | P5 | P6]" />
		
		<xsl:variable name="subs" select="Part | Chapter | Pblock | PsubBlock |
			P1 | P1group | P2 | P2group | P3 | P4 | P5 | P6 |
			$paras/Part | $paras/Chapter | $paras/Pblock | $paras/PsubBlock |
			$paras/P1 | $paras/P1group | $paras/P2 | $paras/P2group |
			$paras/P3 | $paras/P4 | $paras/P5 | $paras/P6" />
			
		<xsl:variable name="headers" as="element()*" select="$number union $title union $subtitle" />
			
		<xsl:choose>
			<xsl:when test="$subs">
				<xsl:variable name="intro" select="($subs[1]/preceding-sibling::* union
					$paras-with-subs[1]/preceding-sibling::*) except $headers" />

				<xsl:variable name="wrap" select="$subs[last()]/following-sibling::* |
					$paras-with-subs[last()]/following-sibling::*" />

				<xsl:if test="$intro">
					<intro><xsl:apply-templates select="$intro" /></intro>
				</xsl:if>

				<xsl:apply-templates select="*[not(self::CommentaryRef)] except ($headers union $intro union $wrap)">
					<xsl:with-param name="exclude" select="$intro union $wrap" />
					<xsl:with-param name="wrap" select="true()" />
				</xsl:apply-templates>

				<xsl:if test="$wrap">
					<wrapUp><xsl:apply-templates select="$wrap" /></wrapUp>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<content>
					<xsl:apply-templates select="*[not(self::CommentaryRef)] except $headers" />
				</content>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:element>

	<xsl:call-template name="alt-versions" />
	
</xsl:template>


<!-- the higher-level elements in the CLML hierarchy
These require only a straightforward application of the hierarchy template. The PsubBlock element is rarely used.
-->
<xsl:template match="Group | Part | Chapter | Pblock | PsubBlock">

	<xsl:call-template name="hierarchy">
		<xsl:with-param name="name">
			<xsl:choose>
				<xsl:when test="self::Group">hcontainer</xsl:when>
				<xsl:when test="self::Part">part</xsl:when>
				<xsl:when test="self::Chapter">chapter</xsl:when>
				<xsl:when test="self::Pblock">hcontainer</xsl:when>
				<xsl:when test="self::PsubBlock">hcontainer</xsl:when>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="hcontainer-name">
			<xsl:choose>
				<xsl:when test="self::Group">group</xsl:when>
				<xsl:when test="self::Pblock">crossheading</xsl:when>
				<xsl:when test="self::PsubBlock">PsubBlock</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:call-template>

</xsl:template>


<!-- groups of numbered provisions: P1group and P2group

Usually these elements have only one child, and they serve only to provide a title for a child that cannot
have its own title. In such cases, this template merely passes control to the template corresponding to the
child, along with a refernce to the Title element and some attributes (extent, period, etc). If there is more
than one child, this template is merely a hcontainer wrapper with a heading.
-->
<xsl:template match="P1group[P1] | P2group[P2]">

	<xsl:variable name="children" select="P1 | P2 | P | P2para" />	<!-- P2para added for ukpga/1978/5 -->
	<xsl:choose>
		<xsl:when test="count($children) = 1">

			<!-- pass control to child template, with Title and certain attributes -->
			<xsl:apply-templates select="$children">
				<xsl:with-param name="attrs" as="attribute()*">
					<xsl:if test="@Layout = 'default'">
						<xsl:attribute name="class">heading-above</xsl:attribute>
					</xsl:if>
					<xsl:if test="@RestrictStartDate | @RestrictEndDate">
						<xsl:attribute name="period">
							<xsl:text>#</xsl:text>
							<xsl:value-of select="clml2akn:period-id(@RestrictStartDate,@RestrictEndDate)" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@Status">
						<xsl:attribute name="class"><xsl:value-of select="lower-case(@Status)" /></xsl:attribute>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="title" select="Title" />
			</xsl:apply-templates>
			<xsl:call-template name="alt-versions" />
		</xsl:when>

		<xsl:otherwise>
			<xsl:call-template name="hierarchy">
				<xsl:with-param name="name" select="'hcontainer'" />
				<xsl:with-param name="hcontainer-name" select="local-name()" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<!-- These functions determine the proper name for a hierarchical provision, in accordance with the rules
set forth in the Office of Public Sector Information's "Statutory Instrument Practice" manual, available at
http://www.opsi.gov.uk/si/si-practice.doc
-->
<xsl:function name="clml2akn:provision-name" as="xs:string">

	<xsl:param name="context" as="element()" />
	<xsl:param name="name" as="xs:string" />
	
	<xsl:variable name="type" as="xs:string">
		<xsl:choose>
			<xsl:when test="$context/ancestor::BlockAmendment">
				<xsl:choose>
					<xsl:when test="$context/ancestor::BlockAmendment[1]/@Context = 'schedule'">schedule</xsl:when>
					<xsl:when test="$context/ancestor::BlockAmendment[1]/@TargetClass = 'primary'">act</xsl:when>
					<xsl:when test="$context/ancestor::BlockAmendment[1]/@TargetClass = 'secondary' or
						($context/ancestor::BlockAmendment[1]/@TargetClass = 'unknown' and exists($minor-type))">
						<xsl:variable name="subclass" select="$context/ancestor::BlockAmendment[1]/@TargetSubClass" />
						<xsl:choose>
							<xsl:when test="$subclass != 'unknown'"><xsl:value-of select="$subclass" /></xsl:when>
							<xsl:when test="exists($minor-type)"><xsl:value-of select="$minor-type" /></xsl:when>
							<xsl:otherwise>order</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>act</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$context/ancestor::Schedule">schedule</xsl:when>
			<xsl:when test="$context/ancestor::ExplanatoryNotes">act</xsl:when>
			<xsl:when test="$context/ancestor::EarlierOrders">act</xsl:when>
			<xsl:when test="exists($minor-type)"><xsl:value-of select="$minor-type" /></xsl:when>
			<xsl:otherwise>act</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:value-of>
		<xsl:choose>
			<xsl:when test="$type = 'act'">
				<xsl:choose>
					<xsl:when test="$name = 'P1'">section</xsl:when>
					<xsl:when test="$name = 'P2'">subsection</xsl:when>
					<xsl:when test="$name = 'P3'">paragraph</xsl:when>
					<xsl:when test="$name = 'P4'">subparagraph</xsl:when>
					<xsl:when test="$name = 'P5'">clause</xsl:when>
					<xsl:when test="$name = 'P6'">subclause</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = 'bill'">
				<xsl:choose>
					<!-- unless Scotish -->
					<xsl:when test="$name = 'P1'">clause</xsl:when>
					<xsl:when test="$name = 'P2'">subsection</xsl:when>
					<xsl:when test="$name = 'P3'">paragraph</xsl:when>
					<xsl:when test="$name = 'P4'">subparagraph</xsl:when>
					<xsl:when test="$name = 'P5'">clause</xsl:when>
					<xsl:when test="$name = 'P6'">subclause</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = 'order'">
				<xsl:choose>
					<xsl:when test="$name = 'P1'">article</xsl:when>
					<xsl:when test="$name = 'P2'">paragraph</xsl:when>
					<xsl:when test="$name = 'P3'">subparagraph</xsl:when>
					<xsl:when test="$name = 'P4'">clause</xsl:when>
					<xsl:when test="$name = 'P5'">subclause</xsl:when>
					<xsl:when test="$name = 'P6'">point</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = 'regulation'">
				<xsl:choose>
					<xsl:when test="$name = 'P1'">hcontainer</xsl:when>
					<xsl:when test="$name = 'P2'">paragraph</xsl:when>
					<xsl:when test="$name = 'P3'">subparagraph</xsl:when>
					<xsl:when test="$name = 'P4'">clause</xsl:when>
					<xsl:when test="$name = 'P5'">subclause</xsl:when>
					<xsl:when test="$name = 'P6'">point</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = 'rule'">
				<xsl:choose>
					<xsl:when test="$name = 'P1'">rule</xsl:when>
					<xsl:when test="$name = 'P2'">paragraph</xsl:when>
					<xsl:when test="$name = 'P3'">subparagraph</xsl:when>
					<xsl:when test="$name = 'P4'">clause</xsl:when>
					<xsl:when test="$name = 'P5'">subclause</xsl:when>
					<xsl:when test="$name = 'P6'">point</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = 'schedule'">
				<xsl:choose>
					<xsl:when test="$name = 'P1'">paragraph</xsl:when>
					<xsl:when test="$name = 'P2'">subparagraph</xsl:when>
					<xsl:when test="$name = 'P3'">paragraph</xsl:when>
					<xsl:when test="$name = 'P4'">subparagraph</xsl:when>
					<xsl:when test="$name = 'P5'">clause</xsl:when>
					<xsl:when test="$name = 'P6'">subclause</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="($type != 'unknown') and ($type != 'scheme')">
					<xsl:message>unknown provision type: <xsl:value-of select="$type" /></xsl:message>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$name = 'P1'">section</xsl:when>
					<xsl:when test="$name = 'P2'">subsection</xsl:when>
					<xsl:when test="$name = 'P3'">paragraph</xsl:when>
					<xsl:when test="$name = 'P4'">subparagraph</xsl:when>
					<xsl:when test="$name = 'P5'">clause</xsl:when>
					<xsl:when test="$name = 'P6'">subclause</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:value-of>
</xsl:function>

<xsl:function name="clml2akn:provision-name" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:value-of select="clml2akn:provision-name($e, local-name($e))" />
</xsl:function>

<!-- When a P1group has a P as a child, or when a P2group has a P2para as a direct child (e.g., ukpga/2005/4),
they always require a new level in the hierarchy.
-->
<xsl:template match="P1group[P][not(P1)] | P2group[P2para][not(P2)]">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="name" select="clml2akn:provision-name(., substring(local-name(), 1, 2))" />
	</xsl:call-template>
</xsl:template>


<!-- numbered provisions: P1, P2, etc.

These are named hcontainers, without a Title of their own, although they often receive a Title reference
from a calling template via the 'title' parameter.

The appearance of these elements within the IntroductoryText of a Preamble is treated as a special case:
because I have run accross no case in which those occurrances have any hierarchical children, the extra
wrapping needed to include a full hierarchical element seems unnecessarily clumsy.
-->

<xsl:template match="IntroductoryText//P1 | IntroductoryText//P2 | IntroductoryText//P3 | IntroductoryText//P4">
	<tblock class="{local-name()}"><xsl:apply-templates /></tblock>
</xsl:template>


<xsl:template match="P1 | P2 | P3 | P4 | P5 | P6">

	<xsl:param name="attrs" select="()" as="attribute()*" />
	<xsl:param name="title" select="Title" as="element()?" />

	<xsl:variable name="name" select="clml2akn:provision-name(.)" />
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="name" select="$name" />
		<!-- this is out of place -->
		<xsl:with-param name="hcontainer-name">
			<xsl:text>regulation</xsl:text>
		</xsl:with-param>
		<xsl:with-param name="attrs" select="$attrs" />
		<xsl:with-param name="title" select="$title" />
	</xsl:call-template>

</xsl:template>


<!-- P & P#para

P elements are difficult to map because of their flexibility. When a direct child of the Body element,
they always require a hierarchical wrapper. I have chosen to do the same with P elements that are direct
children of a ScheduleBody or an AppendixBody, although a more complex algorithm could treat special cases
more elegantly.

P elements that occur elsewhere generally do not create a new level in the hierarchy, although a wrapper is
sometimes needed, when they have a @RestrictExtent, @RestrictStartDate, @RestrictEndDate, @AltVersionRefs
attribute (which is not common).

P#para elements never create a new level in the hierarchy, although they sometimes occur between hierarchical
subsection. In such a case, they wrap their children in hierarchical wrappers, to conform to Akoma Ntoso's
requirement that nothing but hierarchical containers appear between the <intro> and <wrapUp> elements in a
hierarchical container.
-->

<xsl:template match="Body/P | ScheduleBody/P | AppendixBody/P">
	<xsl:param name="wrap" select="true()" as="xs:boolean" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<xsl:call-template name="hierarchy">
				<xsl:with-param name="name" select="'hcontainer'" />
				<xsl:with-param name="hcontainer-name" select="'wrapper'" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@RestrictStartDate | @RestrictEndDate">
			<blockContainer eId="{clml2akn:id(.)}">
				<xsl:call-template name="period" />
				<xsl:apply-templates />
			</blockContainer>
			<xsl:call-template name="alt-versions" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="P">
	<xsl:param name="exclude" select="()" as="element()*" />
	<xsl:param name="wrap" select="false()" as="xs:boolean" />
	<xsl:choose>
		<xsl:when test="@RestrictStartDate | @RestrictEndDate | @AltVersionRefs">
			<xsl:choose>
				<xsl:when test="$wrap">
					<hcontainer name="wrapper" eId="{clml2akn:id(.)}">
						<xsl:call-template name="period" />
						<content><xsl:apply-templates select="* except $exclude" /></content>
					</hcontainer>
					<xsl:call-template name="alt-versions" />
				</xsl:when>
				<xsl:otherwise>
					<blockContainer eId="{clml2akn:id(.)}">
						<xsl:call-template name="period" />
						<xsl:apply-templates select="* except $exclude" />
					</blockContainer>
					<xsl:call-template name="alt-versions" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="para">
				<xsl:with-param name="exclude" select="$exclude" />
				<xsl:with-param name="wrap" select="$wrap" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="P1para | P2para | P3para | P4para | P5para | P6para" name="para">
	<xsl:param name="exclude" select="()" as="element()*" />
	<xsl:param name="wrap" select="false()" as="xs:boolean" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<xsl:for-each select="* except $exclude">
				<xsl:choose>
					<xsl:when test="self::Part | self::Chapter | self::Pblock | self::PsubBlock |
						self::P1 | self::P1group | self::P2 | self::P2group | self::P3 | self::P4 | self::P5 | self::P6">
						<xsl:apply-templates select="." />
					</xsl:when>
					<xsl:otherwise>
						<hcontainer name="wrapper">
							<xsl:call-template name="period" />
							<content>
								<xsl:apply-templates select="." />
							</content>
						</hcontainer>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="* except $exclude" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- numbers and titles -->

<!--
Reference and CommentaryRef elements cannot be mapped to anything permitted within an Akoma Ntoso
hierarchical containers, but they sometimes appear as direct children of a P1 or other hierarchical element
in CLML. They must therefore be included within preceding <num> or <heading> inline elements. The following
helper template is called from the mapping templates for <num>, <heading> and <subheading>.
-->
<xsl:template name="reference">
	<xsl:if test="following-sibling::*[1][self::Reference]">
		<authorialNote placement="right">
			<p><xsl:apply-templates select="following-sibling::*[1]/node()" /></p>
		</authorialNote>
	</xsl:if>
	<xsl:if test="following-sibling::*[1][self::CommentaryRef]">
		<xsl:apply-templates select="following-sibling::*[1]" />
	</xsl:if>
</xsl:template>
<xsl:template match="Reference" />

<xsl:template match="Number | Pnumber">
	<num>
		<xsl:if test="@PuncBefore != '' or @PuncAfter != ''">
			<xsl:attribute name="title">
				<xsl:value-of select="@PuncBefore" />
				<xsl:value-of select="." />
				<xsl:value-of select="@PuncAfter" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
		<xsl:call-template name="reference" />
	</num>
</xsl:template>

<xsl:template match="TitleBlock">
	<heading>
		<xsl:choose>
			<xsl:when test="count(Title) > 1">
				<xsl:for-each select="Title">
					<inline name="multi-heading">
						<xsl:apply-templates select="." />
					</inline>
					<xsl:if test="position() != last()"><br/></xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="Title" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="Subtitle" />
		<xsl:call-template name="reference" />
	</heading>
</xsl:template>

<xsl:template match="TitleBlock/Title">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Title">
	<heading>
		<xsl:apply-templates />
		<xsl:call-template name="reference" />
	</heading>
</xsl:template>

<xsl:template match="Subtitle">
	<subheading>
		<xsl:apply-templates />
		<xsl:call-template name="reference" />
	</subheading>
</xsl:template>


<!-- amendments  -->

<xsl:template match="BlockAmendment">
	<p class="BlockAmendment">
		<mod>
			<quotedStructure>
				<xsl:variable name="classes" as="xs:string*">
					<xsl:sequence select="@TargetClass" />
					<xsl:sequence select="@TargetSubClass" />
					<xsl:sequence select="@Context" />
					<xsl:sequence select="@Format" />
				</xsl:variable>
				<xsl:attribute name="class">
					<xsl:value-of select="string-join($classes, ' ')" />
				</xsl:attribute>
				<!-- it appears there are double quotes in 'default' @Format only sometimes !? -->
				<!-- perhaps if @Context = 'main' ?? -->
				<xsl:if test="@Format = 'default' or @Format = 'double'">
					<xsl:attribute name="startQuote"><xsl:text>&#8220;</xsl:text></xsl:attribute>
					<xsl:attribute name="endQuote"><xsl:text>&#8221;</xsl:text></xsl:attribute>			
				</xsl:if>
				<xsl:if test="@Format = 'single'">
					<xsl:attribute name="startQuote"><xsl:text>&#8216;</xsl:text></xsl:attribute>
					<xsl:attribute name="endQuote"><xsl:text>&#8217;</xsl:text></xsl:attribute>			
				</xsl:if>
				<xsl:apply-templates />
			</quotedStructure>
		</mod>
		<xsl:if test="following-sibling::*[1][self::AppendText]">
			<inline name="AppendText">
				<xsl:apply-templates select="following-sibling::*[1]/node()" />
			</inline>
		</xsl:if>
	</p>
</xsl:template>
<xsl:template match="BlockAmendment[P1 | P2 | P3 | P4 | P5]/*[1][self::Text]">
	<p class="run-on"><xsl:apply-templates /></p>
</xsl:template>
<xsl:template match="AppendText" />

<xsl:template match="FragmentNumber | FragmentTitle">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="InlineAmendment">
	<mod>
		<quotedText>
			<xsl:apply-templates />
		</quotedText>
	</mod>
</xsl:template>


<!-- changes -->

<xsl:key name="change" match="Addition | Repeal | Substitution" use="@ChangeId" />

<xsl:template name="change">
	<xsl:variable name="classes" as="xs:string*">
		<xsl:if test="self::Substitution">
			<xsl:sequence select="lower-case(local-name())" />
		</xsl:if>
		<xsl:sequence select="@ChangeId" />
		<xsl:if test="generate-id() = generate-id(key('change', @ChangeId)[1])">
			<xsl:sequence select="'first'" />
		</xsl:if>
		<xsl:if test="generate-id() = generate-id(key('change', @ChangeId)[last()])">
			<xsl:sequence select="'last'" />
		</xsl:if>
	</xsl:variable>
	<xsl:attribute name="class">
		<xsl:value-of select="string-join($classes, ' ')" />
	</xsl:attribute>
	<xsl:if test="generate-id() = generate-id(key('change', @ChangeId)[1])">
		<xsl:apply-templates select="@CommentaryRef" />
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Addition | Substitution">
	<ins><xsl:call-template name="change" /></ins>
</xsl:template>

<xsl:template match="Repeal">
	<del><xsl:call-template name="change" /></del>
</xsl:template>


<!-- lists -->

<xsl:template match="UnorderedList | OrderedList">
	<blockList class="{lower-case(substring(local-name(), 1, string-length(local-name()) - 4))}">
		<xsl:apply-templates />
	</blockList>
</xsl:template>

<xsl:template match="KeyList">
	<blockList class="{string-join(('Key', @Separator), ' ')}">
		<xsl:apply-templates />
	</blockList>
</xsl:template>

<xsl:template match="KeyListItem">
	<xsl:apply-templates select="ListItem">
		<xsl:with-param name="key" select="Key" />
	</xsl:apply-templates>
</xsl:template>
<xsl:template match="Key">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ListItem">
	<xsl:param name="key" select="()" as="element()?" />
	<item>
		<xsl:if test="$key">
			<heading><xsl:apply-templates select="$key" /></heading>
		</xsl:if>
		<xsl:if test="parent::OrderedList">
			<xsl:variable name="num">
				<xsl:choose>
					<xsl:when test="@NumberOverride">
						<xsl:value-of select="@NumberOverride" />
					</xsl:when>
					<xsl:when test="../@Type = 'arabic'">
						<xsl:number value="position()" format="1" />
					</xsl:when>
					<xsl:when test="../@Type = 'roman'">
						<xsl:number value="position()" format="i" />
					</xsl:when>
					<xsl:when test="../@Type = 'romanUpper'">
						<xsl:number value="position()" format="I" />
					</xsl:when>
					<xsl:when test="../@Type = 'alpha'">
						<xsl:number value="position()" format="a" />
					</xsl:when>
					<xsl:when test="../@Type = 'alphaUpper'">
						<xsl:number value="position()" format="A" />
					</xsl:when>
					<xsl:otherwise><xsl:value-of select="position()" /></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<num>
				<xsl:attribute name="title">
					<xsl:choose>
						<xsl:when test="../@Decoration = 'parens'">(</xsl:when>
						<xsl:when test="../@Decoration = 'parenRight'"></xsl:when>
						<xsl:when test="../@Decoration = 'brackets'">[</xsl:when>
						<xsl:when test="../@Decoration = 'bracketRight'"></xsl:when>
						<xsl:when test="../@Decoration = 'period'"></xsl:when>
						<xsl:when test="../@Decoration = 'colon'"></xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="$num" />
					<xsl:choose>
						<xsl:when test="../@Decoration = 'parens'">)</xsl:when>
						<xsl:when test="../@Decoration = 'parenRight'">)</xsl:when>
						<xsl:when test="../@Decoration = 'brackets'">]</xsl:when>
						<xsl:when test="../@Decoration = 'bracketRight'">]</xsl:when>
						<xsl:when test="../@Decoration = 'period'">.</xsl:when>
						<xsl:when test="../@Decoration = 'colon'">:</xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:value-of select="$num" />
			</num>
		</xsl:if>
		<xsl:apply-templates />
	</item>
</xsl:template>


<!-- tables -->

<xsl:template match="Tabular">
	<xsl:param name="wrap" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<hcontainer name="tabular">
				<xsl:apply-templates select="Number | Title | Subtitle" />
				<content>
					<xsl:apply-templates select="*[not(self::Number)][not(self::Title)][not(self::SubTitle)]" />
				</content>
			</hcontainer>
		</xsl:when>
		<xsl:otherwise>
			<tblock class="tabular"><xsl:apply-templates /></tblock>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="TableText">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:table">
	<table>
		<xsl:if test="html:colgroup">
			<xsl:attribute name="style">table-layout:fixed</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="html:*[not(self::html:tfoot)]" />
		<xsl:apply-templates select="html:tfoot" /><!-- last b/c AkN has no <tfoot> -->
	</table>
</xsl:template>
<xsl:template match="html:caption">
	<caption><xsl:apply-templates /></caption>
</xsl:template>
<xsl:template match="html:tbody | html:tfoot"><!-- ??? -->
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:tr">
	<tr>
		<xsl:if test="parent::html:tfoot">
			<xsl:attribute name="class">tfoot</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</tr>
</xsl:template>

<xsl:template match="html:th | html:td">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@colspan | @rowspan" />
		<xsl:variable name="width" as="xs:string?">
			<xsl:if test="ancestor::html:table[1]/html:colgroup and not(ancestor::html:tfoot)">
				<xsl:if test="not(parent::html:tr/preceding-sibling::html:tr)">
					<xsl:variable name="pos" select="position()" />
					<xsl:value-of select="ancestor::html:table[1]/html:colgroup/html:col[$pos]/@width" />
				</xsl:if>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="@align or @fo:* or $width">
			<xsl:variable name="style-attrs" as="xs:string*">
				<xsl:if test="@align"><xsl:value-of select="concat('text-align:', @align)" /></xsl:if>
				<xsl:for-each select="@fo:*"><xsl:value-of select="concat(local-name(), ':', .)" /></xsl:for-each>
				<xsl:if test="$width"><xsl:value-of select="concat('width', ':', $width)" /></xsl:if>
			</xsl:variable>
			<xsl:attribute name="style"><xsl:value-of select="$style-attrs" separator=";" /></xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="text() | Character">
				<p><xsl:apply-templates /></p>
			</xsl:when>
			<xsl:when test="Para">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:when test="Emphasis | Strong | Underline | SmallCaps | Abbreviation | Acronym | Addition | Repeal | Substitution | Citation">
				<p><xsl:apply-templates /></p>
			</xsl:when>
			<xsl:when test="Part | Chapter | Pblock | PsubBlock | P1 | P1group | P2 | P2group | P3 | P4 | P5 | P6">
				<p>
					<subFlow name="wrapper">
						<xsl:apply-templates />
					</subFlow>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>


<!-- images -->

<xsl:template match="Figure[Title]">
	<tblock class="figure"><xsl:apply-templates /></tblock>
</xsl:template>
<xsl:template match="Figure">
	<block name="figure"><xsl:apply-templates /></block>
</xsl:template>

<xsl:template match="Figure[Title]/Image">
	<p><xsl:next-match /></p>
</xsl:template>
<xsl:template match="Image">
	<img>
		<xsl:attribute name="src">
			<xsl:value-of select="key('id', @ResourceRef)/ExternalVersion/@URI" />
		</xsl:attribute>
		<xsl:if test="ends-with(@Width, 'pt') and substring(@Width, 1, string-length(@Width) - 2) castable as xs:decimal">
	 		<xsl:attribute name="width">
	 			<xsl:value-of select="xs:integer(xs:decimal(substring(@Width, 1, string-length(@Width) - 2)))" />
	 		</xsl:attribute>
		</xsl:if>
		<xsl:if test="ends-with(@Height, 'pt') and substring(@Height, 1, string-length(@Height) - 2) castable as xs:decimal">
	 		<xsl:attribute name="height">
	 			<xsl:value-of select="xs:integer(xs:decimal(substring(@Height, 1, string-length(@Height) - 2)))" />
	 		</xsl:attribute>
		</xsl:if>
	</img>
</xsl:template>

<xsl:template match="IncludedDocument">
	<block name="included-document">
		<img src="{key('id', @ResourceRef)/ExternalVersion/@URI}" />
	</block>
</xsl:template>


<!-- math -->

<xsl:template match="Span[math:math]">
	<subFlow name="wrapper"><xsl:call-template name="foreign" /></subFlow>
</xsl:template>

<xsl:template match="Formula" name="foreign">
	<foreign>
		<xsl:apply-templates select="math:*" />
	</foreign>
	<xsl:apply-templates select="Where" />
</xsl:template>

<xsl:template match="MathElement">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="math:math">
	<xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
		<xsl:copy-of select="@*"/>
		<xsl:if test="../@AltVersionRefs">
			<xsl:attribute name="altimg">
				<xsl:variable name="version" select="key('id', ../@AltVersionRefs)" />
				<xsl:variable name="res-id" select="$version/Figure/Image/@ResourceRef | $version/Image/@ResourceRef" />
				<xsl:variable name="url" select="key('id', $res-id)/ExternalVersion/@URI" />
				<xsl:value-of select="$url" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="math:*">
	<xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>


<!-- schedules -->

<xsl:template match="Schedules">
	<hcontainer name="schedules" eId="{clml2akn:id(.)}">
		<xsl:call-template name="period" />
		<xsl:apply-templates select="*[not(self::Reference)][not(self::CommentaryRef)]" />
	</hcontainer>
</xsl:template>

<xsl:template match="Schedule | Appendix">
	<hcontainer name="{lower-case(local-name())}" eId="{clml2akn:id(.)}">
		<xsl:call-template name="period" />
		<xsl:apply-templates select="*[not(self::Reference)][not(self::CommentaryRef)]" />
	</hcontainer>
	<xsl:call-template name="alt-versions" />
</xsl:template>

<xsl:template match="ScheduleBody | AppendixBody">
	<xsl:variable name="wrap" select="count(Part | Chapter | Pblock | PsubBlock | P1 | P1group | P2 | P2group | P3 | P4 | P5 | P6 |
			P/Part | P/Chapter | P/Pblock | P/PsubBlock | P/P1 | P/P1group | P/P2 | P/P2group | P/P3 | P/P4 | P/P5 | P/P6) > 0" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<xsl:apply-templates select="*[not(self::CommentaryRef)]">
				<xsl:with-param name="wrap" select="true()" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<content>
				<xsl:apply-templates select="*[not(self::CommentaryRef)]">
					<xsl:with-param name="wrap" select="false()" />
				</xsl:apply-templates>
			</content>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- conclusions -->

<xsl:template match="Schedules/SignedSection">
	<wrapUp>
		<blockContainer class="signatures">
			<xsl:call-template name="period" />		
			<xsl:apply-templates />
		</blockContainer>
	</wrapUp>
</xsl:template>
<xsl:template match="SignedSection">
	<hcontainer name="signatures">
		<xsl:call-template name="period" />
		<content>
			<xsl:apply-templates />
		</content>	
	</hcontainer>
</xsl:template>
<xsl:template match="Signatory">
	<xsl:apply-templates />
</xsl:template>
<xsl:template match="Signee">
	<block name="signature"><signature><xsl:apply-templates /></signature></block>
</xsl:template>
<xsl:template match="PersonName">
	<person refersTo="#ref-{clml2akn:id(.)}"><xsl:apply-templates /></person>
</xsl:template>
<xsl:template match="JobTitle">
	<role refersTo="#ref-{clml2akn:id(.)}"><xsl:apply-templates /></role>
</xsl:template>
<xsl:template match="Department">
	<organization refersTo="#ref-{clml2akn:id(.)}"><xsl:apply-templates /></organization>
</xsl:template>
<xsl:template match="Address">
	<xsl:apply-templates />
</xsl:template>
<xsl:template match="AddressLine">
	<location refersTo="#{lower-case(translate(.,' ,',''))}"><xsl:apply-templates /></location>
</xsl:template>
<xsl:template match="DateSigned">
	<date date="{@Date}"><xsl:apply-templates /></date>
</xsl:template>

<xsl:template match="LSseal">
	<xsl:choose>
		<xsl:when test="@ResourceRef">
			<img class="seal" src="{key('id', @ResourceRef)/ExternalVersion/@URI}" />
		</xsl:when>
		<xsl:when test="@Date">
			<date class="seal" date="{@Date}"><xsl:value-of select="." /></date>
		</xsl:when>
		<xsl:when test="text()">
			<inline name="seal"><xsl:value-of select="." /></inline>
		</xsl:when>
		<xsl:otherwise><marker name="seal" /></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- ExplanatoryNotes & EarlierOrders: a subFlow element is needed for hierarchical children -->

<xsl:template match="ExplanatoryNotes">
    <blockContainer class="ExplanatoryNotes">
        <xsl:apply-templates select="Title | Comment" />
        <p><authorialNote>
            <xsl:apply-templates select="*[not(self::Title)][not(self::Comment)]" />
        </authorialNote></p>
    </blockContainer>
</xsl:template>

<xsl:template match="EarlierOrders">
    <blockContainer class="EarlierOrders">
        <xsl:apply-templates select="Title | Comment" />
        <p><subFlow name="earlierOrders">
            <xsl:apply-templates select="*[not(self::Title)][not(self::Comment)]" />
        </subFlow></p>
    </blockContainer>
</xsl:template>

<xsl:template match="Comment"><!-- only possible parent ExplanatoryNotes or EarlierOrders  -->
    <intro><xsl:apply-templates /></intro>
</xsl:template>


<!-- commentaries, margin notes  & footnotes -->

<xsl:template match="Commentary | MarginNote | Footnotes/Footnote">
	<note>
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="self::Commentary">
					<xsl:value-of select="string-join(('commentary', @Type), ' ')" />
				</xsl:when>
				<xsl:when test="self::MarginNote">margin-note</xsl:when>
				<xsl:when test="self::Footnote">footnote</xsl:when>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="eId">
			<xsl:value-of select="clml2akn:id(.)" />
		</xsl:attribute>
		<xsl:apply-templates />
	</note>
</xsl:template>

<xsl:template match="Footnote[not(parent::Footnotes)]">	<!-- e.g., in table cells -->
	<tblock class="footnote" eId="{@id}"><xsl:apply-templates /></tblock>
</xsl:template>

<xsl:template match="@CommentaryRef">
	<xsl:variable name="type" select="key('id', .)/@Type" />
	<!-- 'attribute' is added to the class for testing purposes only -->
	<noteRef href="#{.}" marker="{$type}{clml2akn:commentary-num($type, .)}" class="commentary attribute {$type}" />
</xsl:template>

<xsl:template match="Body/CommentaryRef">
	<p><xsl:next-match /></p>
</xsl:template>

<xsl:template match="CommentaryRef">
	<noteRef href="#{@Ref}">
		<xsl:variable name="commentary" as="element()?" select="key('id', @Ref)" />
		<xsl:if test="exists($commentary)">
			<xsl:attribute name="marker">
				<xsl:value-of select="$commentary/@Type" />
				<xsl:value-of select="clml2akn:commentary-num($commentary/@Type, @Ref)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="class">
			<xsl:value-of select="string-join(('commentary', $commentary/@Type), ' ')" />
		</xsl:attribute>	
	</noteRef>
</xsl:template>

<xsl:template match="MarginNoteRef">
	<noteRef href="#{@Ref}" placement="inline" class="margin-note" />
</xsl:template>

<xsl:template match="FootnoteRef">
	<noteRef href="#{@Ref}" class="footnote">
		<xsl:attribute name="marker">
			<xsl:variable name="footnote" select="key('id', @Ref)" />
			<xsl:choose>
				<xsl:when test="$footnote/Number"><xsl:value-of select="$footnote/Number" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="number(substring(@Ref , 2))" /></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</noteRef>
</xsl:template>


<!--  containers -->

<xsl:template match="Where">
	<blockContainer class="where"><xsl:apply-templates /></blockContainer>
</xsl:template>

<xsl:template match="Form">
	<tblock class="form"><xsl:apply-templates /></tblock>
</xsl:template>

<xsl:template match="Correction">
	<container name="correction"><xsl:apply-templates /></container>
</xsl:template>


<!-- citations -->

<xsl:template match="Citation">
	<ref href="{@URI}"><xsl:apply-templates /></ref>
</xsl:template>

<xsl:template match="CitationSubRef">
	<xsl:choose>
		<xsl:when test="@UpTo">
			<rref from="{@URI}" upTo="{@UpTo}"><xsl:apply-templates /></rref>
		</xsl:when>
		<xsl:otherwise>
			<ref href="{@URI}"><xsl:apply-templates /></ref>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- inline templates -->

<xsl:template match="Para | CoverPara">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ExternalLink">
	<a href="{@URI}"><xsl:apply-templates /></a>
</xsl:template>

<xsl:template match="InternalLink">
	<a href="#{@Ref}">
		<xsl:apply-templates />
	</a>
</xsl:template>

<xsl:template match="Term">
	<term refersTo="#{clml2akn:term-id(.)}">
		<xsl:apply-templates />
	</term>
</xsl:template>

<xsl:template match="Abbreviation">
	<abbr title="{@Expansion}" xml:lang="{@xml:lang}"><xsl:apply-templates /></abbr>
</xsl:template>

<xsl:template match="Acronym">
	<abbr class="Acronym" title="{@Expansion}"><xsl:apply-templates /></abbr>
</xsl:template>

<xsl:template match="Definition">
	<def><xsl:apply-templates /></def>
</xsl:template>

<xsl:template match="BlockText">
	<blockContainer class="BlockText">
		<xsl:apply-templates select="*[not(self::CommentaryRef)]" />
	</blockContainer>
</xsl:template>

<xsl:template match="BlockText/Para/Text">
	<p>
		<xsl:apply-templates />
		<xsl:if test="../following-sibling::*[1][self::CommentaryRef]">
			<xsl:apply-templates select="../following-sibling::*[1]" />
		</xsl:if>
	</p>
</xsl:template>

<xsl:template match="BlockText/text()">
	<p><xsl:value-of select="." /></p>
</xsl:template>

<xsl:template match="Text">
	<p>
		<xsl:if test="@Hanging">
			<xsl:attribute name="class"><xsl:value-of select="@Hanging" /></xsl:attribute>
		</xsl:if>
		<xsl:if test="@Align">
			<xsl:attribute name="style">
				<xsl:text>text-align:</xsl:text>
				<xsl:choose>
					<xsl:when test="@Align = 'centre'">center</xsl:when>
					<xsl:otherwise><xsl:value-of select="@Align" /></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="Proviso">
	<inline name="proviso"><xsl:apply-templates /></inline>
</xsl:template>

<xsl:template match="Emphasis">
	<i><xsl:apply-templates /></i>
</xsl:template>
<xsl:template match="Strong">
	<b><xsl:apply-templates /></b>
</xsl:template>
<xsl:template match="Underline">
	<u><xsl:apply-templates /></u>
</xsl:template>

<xsl:template match="SmallCaps">
	<inline name="smallCaps" style="font-variant:small-caps"><xsl:apply-templates /></inline>
</xsl:template>

<xsl:template match="Superior">
	<sup><xsl:apply-templates /></sup>
</xsl:template>
<xsl:template match="Inferior">
	<sub><xsl:apply-templates /></sub>
</xsl:template>

<xsl:template match="Span">
	<span>
		<xsl:copy-of select="@xml:lang" />
		<xsl:apply-templates />
	</span>
</xsl:template>
	
<xsl:template match="Character">
	<xsl:choose>
		<xsl:when test="@Name = 'DotPadding'">&#x2026;</xsl:when> <!-- four times? -->
		<xsl:when test="@Name = 'EmSpace'">&#x2003;</xsl:when>
		<xsl:when test="@Name = 'EnSpace'">&#x2002;</xsl:when>
		<xsl:when test="@Name = 'LinePadding'">&#x0009;</xsl:when>
		<xsl:when test="@Name = 'NonBreakingSpace'">&#x00a0;</xsl:when>
		<xsl:when test="@Name = 'Minus'">&#x2212;</xsl:when>
		<xsl:when test="@Name = 'ThinSpace'">&#x2009;</xsl:when>
	</xsl:choose>
</xsl:template>


<!-- processing instructions -->

<xsl:template match="processing-instruction('new-line')">
	<eol />
</xsl:template>
<xsl:template match="processing-instruction('new-page')">
	<eop />
</xsl:template>
<xsl:template match="processing-instruction('br')">
	<br />
</xsl:template>

</xsl:stylesheet>
