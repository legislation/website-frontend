<?xml version="1.0" encoding="utf-8"?>

<!-- v2.0.2, written by Jim Mangiafico -->

<xsl:stylesheet version="2.0"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:clml2akn="http://clml2akn.mangiafico.com/"
	exclude-result-prefixes="xs ukl ukm dc dct atom html math fo clml2akn">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />
<xsl:strip-space elements="*" />

<xsl:include href="clml2akn-functions.xsl" />
<xsl:include href="clml2akn-metadata.xsl" />
<xsl:include href="clml2akn-eu.xsl" />

<xsl:variable name="namespace" as="xs:string" select="'http://docs.oasis-open.org/legaldocml/ns/akn/3.0'" />
<xsl:variable name="schema-location" as="xs:string" select="'http://docs.oasis-open.org/legaldocml/akn-core/v1.0/cos01/part2-specs/schemas/akomantoso30.xsd'" />
<!-- https://raw.githubusercontent.com/oasis-open/legaldocml-akomantoso/master/TemporaryRelease20170330Final/akomantoso30.xsd -->

<!-- keys -->

<xsl:key name="id" match="*" use="@id" />
<xsl:key name="commentary" match="Commentary" use="@Type" />


<!-- global variables -->

<xsl:variable name="root" select="/" />

<xsl:variable name="doc-category" as="xs:string" select="/Legislation/ukm:Metadata/ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value" />

<xsl:variable name="ukm-doctype" select="/Legislation/ukm:Metadata/ukm:*/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />

<xsl:variable name="doc-status" select="/Legislation/ukm:Metadata/ukm:*/ukm:DocumentClassification/ukm:DocumentStatus/@Value" />

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
		<xsl:choose>
			<xsl:when test="starts-with($expr-uri, 'http://www.legislation.gov.uk/id/')">
				<xsl:value-of select="$expr-uri" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('http://www.legislation.gov.uk/id/', substring-after($expr-uri, 'http://www.legislation.gov.uk/'))" />
			</xsl:otherwise>
		</xsl:choose>
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

<xsl:variable name="expr-version" as="xs:string?">
	<xsl:choose>
		<xsl:when test="$doc-status = 'revised'">
			<xsl:value-of select="/Legislation/ukm:Metadata/dct:valid" />
		</xsl:when>
		<xsl:when test="$doc-category = 'primary'">
			<xsl:text>enacted</xsl:text>
		</xsl:when>
		<xsl:when test="$ukm-doctype = ('UnitedKingdomChurchInstrument', 'UnitedKingdomMinisterialOrder')">
			<xsl:text>created</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:text>made</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:text>adopted</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="this-uri" as="xs:string">
	<xsl:variable name="base" as="xs:string">
		<xsl:choose>
			<xsl:when test="starts-with($expr-uri, 'http://www.legislation.gov.uk/id/')">
				<xsl:value-of select="$expr-uri" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('http://www.legislation.gov.uk/id/', substring-after($expr-uri, 'http://www.legislation.gov.uk/'))" />
			</xsl:otherwise>
		</xsl:choose>
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
		<xsl:when test="$e/@id">
			<xsl:value-of select="$e/@id" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="generate-id($e)" />
		</xsl:otherwise>
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
			<xsl:value-of select="concat('term-', lower-case(translate(replace($e, ' ', '-'), '&#xA;&#34;“”%', '')))" />
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
	<akomaNtoso xsi:schemaLocation="{ $namespace } { $schema-location }">
		<xsl:apply-templates />
	</akomaNtoso>
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

		<xsl:apply-templates select="Primary | Secondary | EURetained" />

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
				<xsl:apply-templates select="Body/*" />
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
				<xsl:apply-templates select="Body/*" />
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
	<toc>
		<xsl:call-template name="period" />
		<xsl:apply-templates />
	</toc>
</xsl:template>

<xsl:template match="Contents/ContentsTitle">
	<tocItem level="0" class="title" href=""><xsl:apply-templates /></tocItem>
</xsl:template>

<xsl:template match="ContentsPart | ContentsChapter | ContentsPblock | ContentsPsubBlock | ContentsItem | ContentsSubItem | ContentsSchedules | ContentsSchedule | ContentsAppendix">
	<xsl:param name="level" select="1" />
	<xsl:variable name="class" as="xs:string?">
		<xsl:choose>
			<xsl:when test="self::ContentsPart">part</xsl:when>
			<xsl:when test="self::ContentsChapter">chapter</xsl:when>
			<xsl:when test="self::ContentsPblock">heading</xsl:when>
			<xsl:when test="self::ContentsPsubBlock">subheading</xsl:when>
			<xsl:when test="self::ContentsItem">item</xsl:when>
			<xsl:when test="self::ContentsSubItem">subitem</xsl:when>
			<xsl:when test="self::ContentsSchedules">schedules</xsl:when>
			<xsl:when test="self::ContentsSchedule">schedule</xsl:when>
			<xsl:when test="self::ContentsAppendix">appendix</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<tocItem href="{@DocumentURI}" level="{$level}" class="{$class}">
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
	<xsl:if test="exists(child::node())">
		<docDate>
			<xsl:attribute name="date" select="/Legislation/ukm:Metadata/ukm:*/ukm:EnactmentDate/@Date" />
			<xsl:apply-templates />
		</docDate>
	</xsl:if>
</xsl:template>

<xsl:template match="Approved">
	<p class="approved"><xsl:apply-templates /></p>
</xsl:template>

<xsl:template match="LaidDraft | SiftedDate | MadeDate | LaidDate | ComingIntoForce[not(ComingIntoForceClauses)] | ComingIntoForceClauses">
	<p class="{local-name()}"><xsl:apply-templates /></p>
</xsl:template>
<xsl:template match="ComingIntoForce[ComingIntoForceClauses]">
	<container name="{local-name()}"><xsl:apply-templates /></container>
</xsl:template>

<xsl:template match="LaidDraft/Text | SiftedDate/Text | MadeDate/Text | LaidDate/Text | ComingIntoForce[not(ComingIntoForceClauses)]/Text | ComingIntoForceClauses/Text">
	<span><xsl:apply-templates /></span>
</xsl:template>
<xsl:template match="ComingIntoForce[ComingIntoForceClauses]/Text">
	<p><xsl:apply-templates /></p>
</xsl:template>

<xsl:template match="SiftedDate/DateText | MadeDate/DateText | LaidDate/DateText | ComingIntoForce/DateText | ComingIntoForceClauses/DateText">
	<docDate>
		<xsl:attribute name="date">
			<xsl:choose>
				<xsl:when test="parent::SiftedDate">
					<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:Sifted/@Date" />
				</xsl:when>
				<xsl:when test="parent::MadeDate">
					<xsl:choose>
						<xsl:when test="exists(/Legislation/ukm:Metadata/ukm:*/ukm:Made)">
							<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:Made/@Date" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="clml2akn:parse-date(.)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="parent::LaidDate">
					<xsl:variable name="from-text" as="xs:date?" select="clml2akn:parse-date(.)" />
					<xsl:choose>
						<xsl:when test="exists($from-text)">
							<xsl:value-of select="$from-text" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="pos" as="xs:integer" select="count(parent::*/preceding-sibling::LaidDate) + 1" />
							<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:Laid[$pos]/@Date" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="parent::ComingIntoForce">
					<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:ComingIntoForce/ukm:DateTime/@Date" />
				</xsl:when>
				<xsl:when test="parent::ComingIntoForceClauses">
					<xsl:variable name="from-text" as="xs:date?" select="clml2akn:parse-date(.)" />
					<xsl:choose>
						<xsl:when test="exists($from-text)">
							<xsl:value-of select="$from-text" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="pos" as="xs:integer" select="count(../preceding-sibling::ComingIntoForceClauses) + 1" />
							<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:ComingIntoForce/ukm:DateTime[$pos]/@Date" />
						</xsl:otherwise>
					</xsl:choose>
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
		</xsl:when>
		<xsl:when test="empty(*[not(self::EnactingTextOmitted)]) and empty(EnactingTextOmitted/*)" />
		<xsl:otherwise>
			<preamble>
				<xsl:call-template name="period" />
				<xsl:apply-templates />
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
			PsubBlock | P1 | P1group | P2 | P2group | P3 | P3group | P4 | P5 | P6]" />
		
		<xsl:variable name="subs" select="Part | Chapter | Pblock | PsubBlock |
			P1 | P1group | P2 | P2group | P3 | P3group | P4 | P5 | P6 |
			EUPart | EUTitle | EUChapter | EUSection | EUSubsection | Division |
			$paras/Part | $paras/Chapter | $paras/Pblock | $paras/PsubBlock |
			$paras/P1 | $paras/P1group | $paras/P2 | $paras/P2group |
			$paras/P3 | $paras/P3group | $paras/P4 | $paras/P5 | $paras/P6" />
			
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

				<xsl:apply-templates select="* except ($headers union $intro union $wrap)">
					<xsl:with-param name="exclude" select="$intro union $wrap" />
					<xsl:with-param name="wrap" select="true()" />
				</xsl:apply-templates>

				<xsl:if test="$wrap">
					<wrapUp><xsl:apply-templates select="$wrap" /></wrapUp>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<content>
					<xsl:apply-templates select="* except $headers" />
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


<!-- groups of numbered provisions: P1group, P2group and P3group

Usually these elements have only one child, and they serve only to provide a title for a child that cannot
have its own title. In such cases, this template merely passes control to the template corresponding to the
child, along with a refernce to the Title element and some attributes (extent, period, etc). If there is more
than one child, this template is merely a hcontainer wrapper with a heading.
-->
<xsl:template match="P1group[P1] | P2group[P2] | P3group[P3]">

	<xsl:variable name="children" select="P1 | P2 | P3 | P | P2para | P3para" />	<!-- P2para added for ukpga/1978/5 -->
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
<xsl:function name="clml2akn:provision-name" as="xs:string?">

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
					<!-- unless Scottish -->
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
</xsl:function>

<xsl:function name="clml2akn:provision-name" as="xs:string?">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="exists($e/ancestor::EURetained)">
			<xsl:value-of select="clml2akn:eu-provision-name($e)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="clml2akn:provision-name($e, local-name($e))" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- When a P1group has a P as a child, or when a P2group has a P2para as a direct child (e.g., ukpga/2005/4),
they always require a new level in the hierarchy.
-->
<xsl:template match="P1group[P][not(P1)] | P2group[P2para][not(P2)] | P3group[P3para][not(P3)]">
	<xsl:variable name="name" as="xs:string?" select="clml2akn:provision-name(., substring(local-name(), 1, 2))" />
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="name" select="if (exists($name)) then $name else 'hcontainer'" />
		<xsl:with-param name="hcontainer-name" select="if (empty($name)) then 'unknonwn' else ''" />
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

	<xsl:variable name="name" as="xs:string?" select="clml2akn:provision-name(.)" />
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="name" select="if (exists($name)) then $name else 'hcontainer'" />
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

<xsl:template match="Body/P | ScheduleBody/P | AppendixBody/P | EUBody/P">
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
						self::P1 | self::P1group | self::P2 | self::P2group | self::P3 | self::P3group | self::P4 | self::P5 | self::P6">
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
Reference elements cannot be mapped to anything permitted within an Akoma Ntoso
hierarchical containers, but they sometimes appear as direct children of a P1 or other hierarchical element
in CLML. They must therefore be included within preceding <num> or <heading> inline elements. The following
helper template is called from the mapping templates for <num>, <heading> and <subheading>.
-->
<xsl:template name="reference">
	<xsl:apply-templates select="../Reference" mode="force" />
</xsl:template>

<xsl:template match="Reference" />

<xsl:template match="Reference" mode="force">
	<authorialNote class="referenceNote" placement="right">
		<p>
			<xsl:apply-templates />
		</p>
	</authorialNote>
</xsl:template>

<xsl:template match="Number | Pnumber">
	<num>
		<xsl:apply-templates select="clml2akn:get-preceding-skipped-commentary-refs(.)" mode="force" />
		<xsl:apply-templates />
		<xsl:call-template name="reference" />
	</num>
</xsl:template>

<xsl:template match="Title[not(parent::TitleBlock)]" priority="0">
	<heading>
		<xsl:apply-templates />
		<xsl:if test="empty(preceding-sibling::Number) and empty(preceding-sibling::Pnumber)">
			<xsl:call-template name="reference" />
		</xsl:if>
	</heading>
</xsl:template>

<xsl:template match="Subtitle[not(parent::TitleBlock)]" priority="0">
	<subheading>
		<xsl:apply-templates />
	</subheading>
</xsl:template>


<xsl:template match="TitleBlock">
	<heading>
		<xsl:apply-templates select="Title" />
		<xsl:if test="empty(preceding-sibling::Number)">
			<xsl:call-template name="reference" />
		</xsl:if>
	</heading>
	<xsl:if test="exists(Subtitle)">
		<subheading>
			<xsl:apply-templates select="Subtitle" />
		</subheading>
	</xsl:if>
</xsl:template>

<xsl:template match="TitleBlock/Title">
	<xsl:apply-templates />
	<xsl:if test="position() != last()"><br/></xsl:if>
</xsl:template>

<xsl:template match="TitleBlock/Subtitle">
	<xsl:apply-templates />
	<xsl:if test="position() != last()"><br/></xsl:if>
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
				<xsl:choose>
					<xsl:when test="ListItem">
						<blockList>
							<xsl:apply-templates />
						</blockList>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates>
							<xsl:with-param name="context" select="'quote'" tunnel="yes" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
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


<!-- BlockExtract -->

<xsl:template match="BlockExtract">
	<p>
		<embeddedStructure>
			<xsl:apply-templates>
				<xsl:with-param name="context" select="'quote'" tunnel="yes" />
			</xsl:apply-templates>
		</embeddedStructure>
	</p>
</xsl:template>


<!-- changes -->

<xsl:key name="change" match="Addition[not(ancestor::Footnote)] | Repeal[not(ancestor::Footnote)] | Substitution[not(ancestor::Footnote)]" use="@ChangeId" />

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
	<xsl:param name="wrap" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<hcontainer name="wrapper">
				<content>
					<blockList class="{ lower-case(substring(local-name(), 1, string-length(local-name()) - 4)) }">
						<xsl:apply-templates />
					</blockList>
				</content>
			</hcontainer>
		</xsl:when>
		<xsl:otherwise>
			<blockList class="{ lower-case(substring(local-name(), 1, string-length(local-name()) - 4)) }">
				<xsl:apply-templates />
			</blockList>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="KeyList">
	<xsl:param name="wrap" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<hcontainer name="wrapper">
				<content>
					<blockList class="key">
						<xsl:if test="@Separator">
							<xsl:attribute name="separator" namespace="http://www.legislation.gov.uk/namespaces/legislation">
								<xsl:value-of select="@Separator" />
							</xsl:attribute>
						</xsl:if>
						<xsl:apply-templates />
					</blockList>
				</content>
			</hcontainer>
		</xsl:when>
		<xsl:otherwise>
			<blockList class="key">
				<xsl:if test="@Separator">
					<xsl:attribute name="separator" namespace="http://www.legislation.gov.uk/namespaces/legislation">
						<xsl:value-of select="@Separator" />
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates />
			</blockList>
		</xsl:otherwise>
	</xsl:choose>
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
		<xsl:if test="parent::OrderedList or @NumberOverride">
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
<!-- 				<xsl:attribute name="title">
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
				</xsl:attribute> -->
				<xsl:value-of select="$num" />
			</num>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="exists($key) and count(*) > 1">
				<blockContainer>
					<xsl:apply-templates>
						<xsl:with-param name="context" select="'block'" tunnel="yes" /><!-- ?? -->
					</xsl:apply-templates>
				</blockContainer>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="'block'" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
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
					<xsl:apply-templates select="*[not(self::Number)][not(self::Title)][not(self::Subtitle)]" />
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
			<xsl:when test="some $child in * satisfies clml2akn:is-hcontainer($child)">
				<p>
					<embeddedStructure>
						<xsl:apply-templates />
					</embeddedStructure>
				</p>
			</xsl:when>
			<xsl:when test="every $child in * satisfies clml2akn:is-inline($child)">
				<p>
					<xsl:apply-templates>
						<xsl:with-param name="wrapped" select="true()" />
					</xsl:apply-templates>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="wrap-inline-children" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<xsl:template name="wrap-inline-children">
	<xsl:for-each select="node()">
		<xsl:choose>
			<xsl:when test="self::text()">
				<p>
					<xsl:apply-templates select=".">
						<xsl:with-param name="wrapped" select="true()" />
					</xsl:apply-templates>
				</p>
			</xsl:when>
			<xsl:when test="self::processing-instruction()" />
			<xsl:when test="clml2akn:is-inline(.)">
				<p>
					<xsl:apply-templates select=".">
						<xsl:with-param name="wrapped" select="true()" />
					</xsl:apply-templates>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<xsl:template match="html:th/text() | html:td/text()">
	<xsl:param name="wrapped" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$wrapped">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise>
			<p>
				<xsl:next-match />
			</p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="html:td/Image">
	<p>
		<xsl:next-match />
	</p>
</xsl:template>

<!-- images -->

<xsl:template match="Figure">
	<xsl:param name="wrap" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<hcontainer name="figure">
				<xsl:apply-templates select="Title | Subtitle" />
				<content>
					<xsl:apply-templates select="*[not(self::Title) and not(self::Subtitle)]" />
				</content>
			</hcontainer>
		</xsl:when>
		<xsl:when test="Title">
			<tblock class="figure">
				<xsl:apply-templates />
			</tblock>
		</xsl:when>
		<xsl:otherwise>
			<blockContainer class="figure">
				<xsl:apply-templates />
			</blockContainer>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Figure/Image">
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
	<xsl:param name="wrapped" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="false()">
			<p><subFlow name="wrapper"><xsl:call-template name="foreign" /></subFlow></p>
		</xsl:when>
		<xsl:otherwise>
			<subFlow name="wrapper"><xsl:call-template name="foreign" /></subFlow>
		</xsl:otherwise>
	</xsl:choose>
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
			<xsl:variable name="version" select="key('id', ../@AltVersionRefs)" />
			<xsl:variable name="res-id" select="$version/Figure/Image/@ResourceRef | $version/Image/@ResourceRef" />
			<xsl:variable name="url" select="key('id', $res-id)/ExternalVersion/@URI" />
			<xsl:if test="exists($url)">
				<xsl:attribute name="altimg">
					<xsl:value-of select="$url" />
				</xsl:attribute>
			</xsl:if>
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
		<xsl:apply-templates />
	</hcontainer>
</xsl:template>

<xsl:template match="Schedule | Appendix">
	<hcontainer name="{lower-case(local-name())}" eId="{clml2akn:id(.)}">
		<xsl:call-template name="period" />
		<xsl:apply-templates select="node()[not(self::Contents)]" />
	</hcontainer>
	<xsl:call-template name="alt-versions" />
</xsl:template>

<xsl:template match="ScheduleBody | AppendixBody">
	<xsl:variable name="wrap" select="exists(Part | Chapter | Pblock | PsubBlock | P1 | P1group | P2 | P2group | P3 | P4 | P5 | P6 |
			P/Part | P/Chapter | P/Pblock | P/PsubBlock | P/P1 | P/P1group | P/P2 | P/P2group | P/P3 | P/P4 | P/P5 | P/P6 |
			EUPart | EUTitle | EUChapter | EUSection | EUSubsection | Division | Form[some $ch in * satisfies clml2akn:is-hcontainer($ch)])" />
	<xsl:variable name="has-appendix" as="xs:boolean" select="exists(following-sibling::Appendix)" />
	<xsl:choose>
		<xsl:when test="$has-appendix and $wrap">
			<hcontainer name="body">
				<xsl:apply-templates select="preceding-sibling::Contents | *">
					<xsl:with-param name="wrap" select="true()" />
				</xsl:apply-templates>
			</hcontainer>
		</xsl:when>
		<xsl:when test="$has-appendix">
			<hcontainer name="body">
				<content>
					<xsl:apply-templates select="preceding-sibling::Contents | *">
						<xsl:with-param name="wrap" select="false()" />
					</xsl:apply-templates>
				</content>
			</hcontainer>
		</xsl:when>
		<xsl:when test="$wrap">
			<xsl:apply-templates select="preceding-sibling::Contents | *">
				<xsl:with-param name="wrap" select="true()" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<content>
				<xsl:apply-templates select="preceding-sibling::Contents | *">
					<xsl:with-param name="wrap" select="false()" />
				</xsl:apply-templates>
			</content>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ScheduleBody/Figure | AppendixBody/Figure">
	<xsl:param name="wrap" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<hcontainer name="wrapper">
				<content>
					<xsl:next-match />
				</content>
			</hcontainer>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Schedule/Contents | Appendix/Contents">
	<xsl:param name="wrap" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<intro>
				<xsl:next-match />
			</intro>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- conclusions -->

<xsl:template match="ScheduleBody/SignedSection | AppendixBody/SignedSection">
	<xsl:param name="wrap" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$wrap">
			<wrapUp>
				<blockContainer class="signatures">
					<xsl:call-template name="period" />
					<xsl:apply-templates />
				</blockContainer>
			</wrapUp>
		</xsl:when>
		<xsl:otherwise>
			<blockContainer class="signatures">
				<xsl:call-template name="period" />
				<xsl:apply-templates />
			</blockContainer>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="Schedules/SignedSection">
	<xsl:choose>
		<xsl:when test="following-sibling::Appendix">
			<hcontainer name="signatures">
				<xsl:call-template name="period" />
				<content>
					<xsl:apply-templates />
				</content>
			</hcontainer>
		</xsl:when>
		<xsl:otherwise>
			<wrapUp>
				<blockContainer class="signatures">
					<xsl:call-template name="period" />
					<xsl:apply-templates />
				</blockContainer>
			</wrapUp>
		</xsl:otherwise>
	</xsl:choose>
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
	<date date="{ if (@Date) then @Date else clml2akn:parse-date(.) }"><xsl:apply-templates /></date>
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
		<xsl:apply-templates>
			<xsl:with-param name="context" select="'block'" tunnel="yes" />
		</xsl:apply-templates>
	</note>
</xsl:template>

<!-- this should be changed for 2.0? all footnotes should be in Notes section?? -->
<xsl:template match="Footnote[not(parent::Footnotes)]">	<!-- e.g., in table cells -->
	<tblock class="footnote" eId="{@id}">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="'block'" tunnel="yes" />
		</xsl:apply-templates>
	</tblock>
</xsl:template>


<xsl:template match="@CommentaryRef">
	<xsl:variable name="commentary" as="element()?" select="key('id', .)" />
	<xsl:if test="empty($commentary)">
		<xsl:message>
			<xsl:text>commentary does not exist </xsl:text>
			<xsl:value-of select="." />
		</xsl:message>
	</xsl:if>
	<xsl:variable name="type" as="xs:string?" select="$commentary/@Type" />
	<noteRef href="#{.}">
		<xsl:if test="exists($type)">
			<xsl:attribute name="marker">
				<xsl:value-of select="$type" />
				<xsl:value-of select="clml2akn:commentary-num($type, .)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="class">
			<xsl:text>commentary attribute</xsl:text><!-- 'attribute' is added to the class for testing purposes only -->
			<xsl:if test="exists($type)">
				<xsl:text> </xsl:text>
				<xsl:value-of select="$type" />
			</xsl:if>
		</xsl:attribute>
	</noteRef>
</xsl:template>

<xsl:template match="Body/CommentaryRef">
	<p><xsl:next-match /></p>
</xsl:template>

<xsl:function name="clml2akn:node-is-skippable-after-commentary-ref" as="xs:boolean">
	<xsl:param name="node" as="node()" />
	<xsl:value-of select="$node/self::text()[not(normalize-space(.))] or $node/self::CommentaryRef" />
</xsl:function>
<xsl:function name="clml2akn:nodes-are-skippable-after-commentary-ref" as="xs:boolean">
	<xsl:param name="nodes" as="node()*" />
	<xsl:value-of select="every $node in $nodes satisfies clml2akn:node-is-skippable-after-commentary-ref($node)" />
</xsl:function>
<xsl:function name="clml2akn:commentary-ref-can-be-skipped" as="xs:boolean">
	<xsl:param name="commentary-ref" as="element(CommentaryRef)" />
	<xsl:param name="anchor" as="element()" />
	<xsl:variable name="in-between" as="node()*" select="$commentary-ref/following-sibling::node() intersect $anchor/preceding-sibling::node()" />
	<xsl:value-of select="clml2akn:nodes-are-skippable-after-commentary-ref($in-between)" />
</xsl:function>
<xsl:function name="clml2akn:get-preceding-skipped-commentary-refs" as="element(CommentaryRef)*">
	<xsl:param name="anchor" as="element()" />
	<xsl:sequence select="$anchor/preceding-sibling::CommentaryRef[clml2akn:commentary-ref-can-be-skipped(., $anchor)]" />
</xsl:function>

<xsl:template match="CommentaryRef">
	<xsl:variable name="handled-elsewhere" as="xs:boolean">
		<xsl:variable name="next" as="element()?" select="following-sibling::*[self::Number or self::Pnumber or self::Text][1]" />
		<xsl:choose>
			<xsl:when test="empty($next)">
				<xsl:value-of select="false()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="clml2akn:commentary-ref-can-be-skipped(., $next)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="not($handled-elsewhere)">
		<xsl:apply-templates select="." mode="force" />
	</xsl:if>
</xsl:template>

<xsl:template match="CommentaryRef" mode="force">
	<noteRef href="#{@Ref}">
		<xsl:variable name="commentary" as="element()?" select="key('id', @Ref)[1]" />
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
	<xsl:choose>
		<xsl:when test="some $child in child::* satisfies clml2akn:is-hcontainer($child)">
			<hcontainer name="form">
				<xsl:apply-templates />
			</hcontainer>
		</xsl:when>
		<xsl:otherwise>
			<tblock class="form">
				<xsl:apply-templates />
			</tblock>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Correction">
	<container name="correction"><xsl:apply-templates /></container>
</xsl:template>


<!-- citations -->

<xsl:template match="Citation">
	<xsl:choose>
		<xsl:when test="node()[last()][self::FootnoteRef]"><!-- uksi/1999/1750/made -->
			<xsl:variable name="fnRef" as="element()" select="node()[last()]" />
			<ref href="{ @URI }">
				<xsl:apply-templates select="node() except $fnRef" />
			</ref>
			<xsl:apply-templates select="$fnRef" />
		</xsl:when>
		<xsl:otherwise>
			<ref href="{ @URI }">
				<xsl:apply-templates />
			</ref>
		</xsl:otherwise>
	</xsl:choose>
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
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="BlockText/Para/Text">
	<p>
		<xsl:apply-templates select="clml2akn:get-preceding-skipped-commentary-refs(.)" mode="force" />
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="BlockText/text()">
	<p><xsl:next-match /></p>
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
		<xsl:apply-templates select="clml2akn:get-preceding-skipped-commentary-refs(.)" mode="force" />
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


<!-- attributes -->

<xsl:template match="@id">
	<xsl:attribute name="eId">
		<xsl:value-of select="." />
	</xsl:attribute>
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
