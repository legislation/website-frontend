<?xml version="1.0" encoding="utf-8"?>

<!-- v2.0.2, written by Jim Mangiafico -->

<xsl:stylesheet version="2.0"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0/CSD13"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:local="http://jurisdatum.com/tna/akn2html"
	exclude-result-prefixes="xs math akn ukl ukm local">

<xsl:param name="css-path" select="'/'" />
<xsl:param name="show-annotations" select="true()" />
<xsl:param name="show-extent" select="false()" />
<xsl:param name="show-prospective" select="true()" />

<xsl:output method="html" version="5" include-content-type="no" encoding="utf-8" indent="yes" />
<xsl:strip-space elements="*" />

<xsl:key name="id" match="*" use="@eId" />
<xsl:key name="note" match="note" use="@eId" />
<xsl:key name="note-ref" match="noteRef" use="substring(@href, 2)" />
<xsl:key name="extent" match="restriction" use="if (ends-with(@href, ']')) then substring-before(substring(@href,2), '[') else substring(@href,2)" />

<xsl:variable name="doc-category" as="xs:string" select="/akomaNtoso/*/meta/proprietary/ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value" />
<xsl:variable name="doc-type" as="xs:string" select="/akomaNtoso/*/meta/proprietary/ukm:*/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />

<xsl:template name="attrs">
	<xsl:attribute name="class"><xsl:value-of select="string-join((local-name(), @class), ' ')" /></xsl:attribute>
	<xsl:apply-templates select="@*[name()!='class']" />
</xsl:template>

<xsl:template name="extent">
	<xsl:variable name="restrictions" select="key('extent', @eId)" as="element()*" />
	<xsl:choose>
		<xsl:when test="count($restrictions) = 1">
			<xsl:attribute name="data-x-extent">
				<xsl:value-of select="upper-case(substring($restrictions[1]/@refersTo, 2))" />
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="count($restrictions) > 1">
			<xsl:variable name="twins" as="xs:string*">
				<xsl:for-each select="key('id', @eId)"><xsl:sequence select="generate-id()" /></xsl:for-each>	
			</xsl:variable>
			<xsl:variable name="num" select="index-of($twins, generate-id())" as="xs:integer" />
			<xsl:variable name="restriction" select="$restrictions[ends-with(@href, concat('[', $num, ']'))]" as="element()?" />
			<xsl:if test="exists($restriction)">
				<xsl:attribute name="data-x-extent">
					<xsl:value-of select="upper-case(substring($restriction/@refersTo, 2))" />
				</xsl:attribute>
			</xsl:if>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:function name="local:is-big-level" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:value-of select="local-name($e) = ('title', 'part', 'chapter', 'section', 'subsection') or $e/self::hcontainer/@name = 'schedule'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$e[self::group] or $e[self::part] or $e[self::chapter] or $e[self::hcontainer][@name='crossheading'] or
				$e[self::hcontainer][@name='P1group'] or $e[self::hcontainer][@name='schedule']" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
<xsl:function name="local:is-p1" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:value-of select="exists($e[self::article] | $e[self::paragraph][ancestor::hcontainer[@name='schedule']][not(ancestor::paragraph)])" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="exists($e[self::section] | $e[self::article] | $e[self::hcontainer][@name='regulation'] |
				$e[self::rule] | $e[self::paragraph][ancestor::hcontainer[@name='schedule']][not(ancestor::paragraph)])" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="/akomaNtoso">
	<html>
		<head>
			<meta charset="utf-8" />
			<title>
				<xsl:choose>
					<xsl:when test="//docTitle"><xsl:value-of select="//docTitle[1]" /></xsl:when>
					<xsl:when test="//shortTitle"><xsl:value-of select="//shortTitle[1]" /></xsl:when>
					<xsl:otherwise><xsl:value-of select="//FRBRWork/FRBRthis/@value" /></xsl:otherwise>
				</xsl:choose>
			</title>
			<xsl:if test="//longTitle">
				<meta name="description" content="{//longTitle[1]}" />
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$doc-type = 'NorthernIrelandAct'">
					<link rel="stylesheet" href="{$css-path}nia.css" type="text/css" />
				</xsl:when>
				<xsl:when test="$doc-category = 'secondary'">
					<link rel="stylesheet" href="{$css-path}secondary.css" type="text/css" />
				</xsl:when>
				<xsl:when test="$doc-category = 'euretained'">
					<link rel="stylesheet" href="{$css-path}euretained.css" type="text/css" />
				</xsl:when>
				<xsl:otherwise>
					<link rel="stylesheet" href="{$css-path}primary.css" type="text/css" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$show-annotations">
				<link rel="stylesheet" href="{$css-path}annotations.css" type="text/css" />
			</xsl:if>
			<xsl:if test="$show-extent">
				<link rel="stylesheet" href="{$css-path}extent.css" type="text/css" />
			</xsl:if>
			<xsl:if test="$show-prospective">
				<link rel="stylesheet" href="{$css-path}prospective.css" type="text/css" />
			</xsl:if>
		</head>
		<body>
			<xsl:if test="*/meta/analysis/restrictions/restriction[not(@href)]">
				<xsl:attribute name="data-x-extent">
					<xsl:value-of select="upper-case(substring(*/meta/analysis/restrictions/restriction[not(@href)]/@refersTo, 2))" />
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
			
			<xsl:call-template name="footnotes" />
		</body>
	</html>
</xsl:template>


<!-- document types -->

<xsl:template match="act">
	<article class="{/akomaNtoso/*/meta/proprietary/ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value}">
		<xsl:apply-templates select="@name" />
		<xsl:apply-templates />
	</article>
</xsl:template>

<xsl:template match="portion">
	<article class="{/akomaNtoso/*/meta/proprietary/ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value}">
		<xsl:apply-templates select="@includedIn" />
		<xsl:apply-templates />
	</article>
</xsl:template>


<!-- metadata -->

<xsl:template match="meta">
	<div class="meta" vocab="{namespace-uri()}/" style="display:none">
		<xsl:apply-templates select="*[not(self::notes)]"/>
	</div>
</xsl:template>

<xsl:template match="meta/proprietary">
	<div resource="#{name()}" typeof="{name()}">
		<xsl:variable name="prefixes" as="xs:string*">
			<xsl:for-each-group select="descendant::*" group-by="prefix-from-QName(resolve-QName(name(), .))">
				<xsl:variable name="prefix" select="prefix-from-QName(resolve-QName(name(), .))" />
				<xsl:variable name="uri" select="namespace-uri-for-prefix($prefix, .)" />
				<xsl:choose>
					<xsl:when test="ends-with($uri, '/') or ends-with($uri, '#')">
						<xsl:value-of select="concat($prefix, ': ', $uri)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($prefix, ': ', $uri, '/')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:attribute name="prefix">
			<xsl:value-of select="string-join($prefixes, ' ')" />
		</xsl:attribute>
		<xsl:apply-templates select="*" />
	</div>
</xsl:template>

<xsl:template match="meta/*[not(self::proprietary)]">
	<div resource="#{name()}" typeof="{name()}">
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="identification/*">
	<div resource="#{name()}" property="{name()}" typeof="{name()}">
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="meta/*//*[not(parent::identification)][not(ancestor-or-self::note)]">
	<xsl:choose>
		<xsl:when test="text()[normalize-space()]">
			<div property="{name()}"><xsl:value-of select="." /></div>
		</xsl:when>
		<xsl:otherwise>
			<div>
				<xsl:if test="not(parent::meta) and ((namespace-uri() = namespace-uri(..)) or parent::proprietary)">
					<xsl:attribute name="property"><xsl:value-of select="name()" /></xsl:attribute>
				</xsl:if>
				<xsl:attribute name="typeof"><xsl:value-of select="name()" /></xsl:attribute>
				<xsl:variable name="prefix" select="prefix-from-QName(resolve-QName(name(), .))" as="xs:string?" />
				<xsl:for-each select="@*">
					<meta>
						<xsl:attribute name="property">
							<xsl:if test="$prefix">
								<xsl:value-of select="$prefix" /><xsl:text>:</xsl:text>
							</xsl:if>
							<xsl:value-of select="name()" />
						</xsl:attribute>
						<xsl:attribute name="content">
							<xsl:value-of select="translate(., '&#128;&#132;&#149;&#150;&#153;&#157;', '')" />
						</xsl:attribute>
					</meta>
				</xsl:for-each>
				<xsl:apply-templates select="*" />
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="note">
	<xsl:param name="marker" />
	<div>
		<xsl:call-template name="attrs" />
		<xsl:if test="$marker != ''">
			<span class="marker"><xsl:value-of select="$marker"/></span>
		</xsl:if>
		<xsl:apply-templates />
	</div>
</xsl:template>

<!-- sequence of unique noteRefs, uniqueness determined by reference to the same note -->
<xsl:variable name="note-refs" as="element()*">
	<xsl:for-each-group select="//noteRef[not(@placement='inline')]" group-by="@href">
		<xsl:variable name="id" select="substring(@href, 2)" as="xs:string" />
		<xsl:variable name="note" select="key('id', $id)" as="element()?" />
		<!-- need to exclude noteRefs to elements that are not in the metadata section, they'll appear in the document in due course -->
		<xsl:if test="exists($note) and $note/ancestor::notes">
			<xsl:sequence select="current-group()[1]" /><!-- select="."? -->
		</xsl:if>
	</xsl:for-each-group>
</xsl:variable>

<xsl:template name="display-note">
	<xsl:variable name="id" select="substring(@href, 2)" as="xs:string" />
	<xsl:variable name="note" select="key('note', $id)" as="element()?" />
	<xsl:apply-templates select="$note">
		<xsl:with-param name="marker" select="@marker" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template name="display-notes">
	<xsl:param name="note-refs" as="element()*" />
	<xsl:param name="heading" as="xs:string" />
	<xsl:if test="exists($note-refs)">
		<div class="{tokenize($note-refs[1]/@class, ' ')[last()]}">
			<div><xsl:value-of select="$heading" /></div>
			<xsl:for-each select="$note-refs">
				<xsl:call-template name="display-note" />
			</xsl:for-each>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template name="annotations">
	<xsl:param name="root" as="element()+" select="." />
	<xsl:param name="wrapper-element-name" select="'footer'" as="xs:string" />
	<xsl:variable name="annotation-root-id" as="xs:string" select="if ($root[1]/@eId) then $root[1]/@eId else local-name($root[1])" />
	<xsl:variable name="all-own-note-refs" as="element()*">
		<xsl:choose>
			<xsl:when test="$root[self::coverPage] or $root[self::preface] or $root[self::preamble]">
				<xsl:sequence select="$root//noteRef" />
			</xsl:when>
			<!-- when larger than section, only those not belonging to a descendant -->
			<xsl:when test="local:is-big-level($root)">
				<xsl:sequence select="$root/num//noteRef | $root/heading//noteRef | $root/subheading//noteRef |
					$root/intro//noteRef | $root/content//noteRef | $root/wrapUp//noteRef" />
			</xsl:when>
			<!-- when a section, everything -->
			<xsl:when test="local:is-p1($root)">
				<xsl:sequence select="$root//noteRef" />
			</xsl:when>
			<!-- when below a section, nothing -->
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="including-footnotes" select="$all-own-note-refs intersect $note-refs" />
	<xsl:variable name="own-note-refs" select="$including-footnotes[not(@class='footnote')]" />
	<xsl:if test="count($own-note-refs) > 0">
		<xsl:element name="{$wrapper-element-name}">
			<xsl:attribute name="class">annotations</xsl:attribute>
			<div>Annotations:</div>
			
			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'I')]" />
				<xsl:with-param name="heading" select="'Commencement Information'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'X')]" />
				<xsl:with-param name="heading" select="'Editorial Information'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'E')]" />
				<xsl:with-param name="heading" select="'Extent Information'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'F')]" />
				<xsl:with-param name="heading" select="'Amendments (Textual)'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'C')]" />
				<xsl:with-param name="heading" select="'Modifications etc. (not altering text)'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'M')]" />
				<xsl:with-param name="heading" select="'Marginal Citations'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'P')]" />
				<xsl:with-param name="heading" select="'Subordinate Legislation Made'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="footnotes">
	<xsl:variable name="notes" as="element()*" select="/akomaNtoso/*/meta/notes/note[@class='footnote']" />
	<xsl:if test="exists($notes)">
		<footer class="footnotes">
			<xsl:for-each select="$notes">
				<xsl:variable name="id" as="xs:string" select="@eId" />
				<xsl:variable name="note-ref" as="element()?" select="key('note-ref', $id)[1]" />
				<xsl:if test="empty($note-ref)">
					<xsl:message>
						<xsl:text>can't find ref for footnote </xsl:text>
						<xsl:value-of select="$id" />
					</xsl:message>
				</xsl:if>
				<xsl:for-each select="$note-ref">
					<xsl:call-template name="display-note" />
				</xsl:for-each>
			</xsl:for-each>
		</footer>
	</xsl:if>
</xsl:template>

<!-- top level -->

<xsl:template match="coverPage">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
	<xsl:if test="$doc-category = 'primary'"><xsl:call-template name="annotations" /></xsl:if>
</xsl:template>

<xsl:template match="preface">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
	<xsl:if test="empty(following-sibling::preamble)">
		<xsl:call-template name="annotations">
			<xsl:with-param name="wrapper-element-name" select="'div'" />
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="preamble">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
	<xsl:call-template name="annotations">
		<xsl:with-param name="root" select="preceding-sibling::preface | ." />
		<xsl:with-param name="wrapper-element-name" select="'div'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="body | mainBody | fragmentBody">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="conclusions | attachments | components">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="attachment">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="doc">
	<article>
		<xsl:apply-templates select="@name" />
		<xsl:variable name="category" as="xs:string?" select="meta/proprietary/ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value" />
		<xsl:if test="exists($category)">
			<xsl:attribute name="class">
				<xsl:value-of select="$category" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</article>
</xsl:template>

<!-- hierarchy -->

<!-- pure containers: part, chapter, crossheading -->

<xsl:template match="hcontainer[@name='group'] | title | part | chapter | hcontainer[@name='crossheading'] | hcontainer[@name='P1group'] |
		hcontainer[@name='schedules'] | hcontainer[@name='schedule'] | level">
	<section>
		<xsl:call-template name="attrs" />
		<xsl:if test="exists(num | heading | subheading)">
			<h2>
				<xsl:if test="exists(num) and empty(heading | subheading)">
					<xsl:attribute name="class">
						<xsl:text>noheading</xsl:text>
					</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="extent" />
				<xsl:apply-templates select="num | heading | subheading" />
			</h2>
		</xsl:if>
		<xsl:apply-templates select="num//authorialNote | heading//authorialNote | subheading//authorialNote" />
		<xsl:if test="empty(ancestor::quotedStructure)">
			<xsl:call-template name="annotations">
				<xsl:with-param name="wrapper-element-name" select="'header'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::num)][not(self::heading)][not(self::subheading)]" />
	</section>
</xsl:template>


<!-- P1 -->

<xsl:template match="section | article | hcontainer[@name='regulation'] | rule | hcontainer[@name='schedule']//paragraph[not(ancestor::paragraph)]">
	<xsl:variable name="invert" as="xs:boolean" select="
		(($doc-category = 'secondary') and not(contains(ancestor::quotedStructure[1]/@class, 'primary'))) or
		contains(ancestor::quotedStructure[1]/@class, 'secondary') or
		ancestor::act[1]/@name = 'NorthernIrelandAct'
	" />
	<section>
		<xsl:call-template name="attrs" />
		<h2>
			<xsl:call-template name="extent" />
			<xsl:choose>
				<xsl:when test="$invert">
					<xsl:apply-templates select="heading | subheading" />			
					<xsl:apply-templates select="num" />			
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="num | heading | subheading" />			
				</xsl:otherwise>
			</xsl:choose>
		</h2>
		<xsl:apply-templates select="num//authorialNote | heading//authorialNote | subheading//authorialNote" />
		<xsl:apply-templates select="*[not(self::num)][not(self::heading)][not(self::subheading)]" />
	</section>
	<xsl:if test="empty(ancestor::quotedStructure)">
		<xsl:call-template name="annotations" />
	</xsl:if>
</xsl:template>


<!-- P2 -->

<xsl:template match="subsection | subparagraph[ancestor::hcontainer[@name='schedule']][not(ancestor::subparagraph)]">
	<section>
		<xsl:call-template name="attrs" />
		<h2>
			<xsl:call-template name="extent" />
			<xsl:apply-templates select="num | heading | subheading" />			
		</h2>
		<xsl:apply-templates select="num//authorialNote | heading//authorialNote | subheading//authorialNote" />
		<xsl:apply-templates select="*[not(self::num)][not(self::heading)][not(self::subheading)]" />
	</section>
</xsl:template>


<xsl:template match="paragraph | subparagraph | clause | subclause | point">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:variable name="h-num">
			<xsl:choose>
				<xsl:when test="self::paragraph">h3</xsl:when>
				<xsl:when test="self::subparagraph">h4</xsl:when>
				<xsl:when test="self::clause">h5</xsl:when>
				<xsl:when test="self::subclause">h6</xsl:when>
				<xsl:when test="self::point">h6</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$h-num}">
			<xsl:call-template name="extent" />
			<xsl:apply-templates select="num | heading | subheading" />			
		</xsl:element>
		<xsl:apply-templates select="num//authorialNote | heading//authorialNote | subheading//authorialNote" />
		<xsl:apply-templates select="intro" />
		<xsl:apply-templates select="*[not(self::num)][not(self::heading)][not(self::subheading)][not(self::intro)]" />
	</div>
</xsl:template>

<xsl:template match="num | heading | subheading">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates select="node()[not(self::authorialNote)]" />
	</span>
</xsl:template>

<xsl:template match="intro | content | wrapUp">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>


<!-- wrappers -->
<xsl:template match="hcontainer[@name='wrapper'][every $child in * satisfies $child/self::content]">
	<xsl:apply-templates select="content/node()" />
</xsl:template>



<!-- LISTS (ordered, unordered, and key) -->

<xsl:template match="item">
	<li>
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates />
	</li>
</xsl:template>

<xsl:template match="listIntroduction | listWrapUp">
	<li>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</li>
</xsl:template>

<!-- ordered lists -->

<xsl:template match="blockList[item/num]">
	<ol><xsl:apply-templates select="@*|node()"/></ol>
</xsl:template>

<xsl:template match="item/num">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:choose>
			<xsl:when test="@title">
				<xsl:attribute name="data-raw"><xsl:value-of select="." /></xsl:attribute>
				<xsl:value-of select="@title" />
				<xsl:apply-templates select="*" /><!-- for notes, etc -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>

<!-- unordered lists -->

<xsl:template match="blockList"><!-- [not(item/num)] -->
	<ul><xsl:apply-templates select="@*|node()"/></ul>
</xsl:template>

<!-- key lists -->

<xsl:template match="blockList[@class='key']">
	<dl>
		<xsl:if test="@ukl:separator = '='">
			<xsl:attribute name="class">equals</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="@*[name()!='class'][local-name()!='separator']" />
		<xsl:apply-templates />
	</dl>
</xsl:template>

<xsl:template match="blockList[@class='key']/item">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="blockList[@class='key']/item/heading">
	<dt><xsl:apply-templates select="@*|node()" /></dt>
</xsl:template>

<xsl:template match="blockList[@class='key']/item/*[not(self::heading)]" priority="1"><!-- could be another blockList -->
	<dd>
		<xsl:next-match />
	</dd>
</xsl:template>


<!-- blocks -->

<xsl:template match="p[docTitle] | p[shortTitle] | p[mod[quotedStructure]] | p[embeddedStructure] | p[subFlow] | p[authorialNote]">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:if test="mod/quotedStructure/*[1][self::p][@class='run-on']">
			<xsl:attribute name="style">
				<xsl:value-of select="string-join((@style, 'display:inline'), ' ')" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="p">
	<p>
		<xsl:apply-templates select="@*" />
		<xsl:if test="following-sibling::*[1][@class='BlockAmendment'][child::mod/quotedStructure/*[1][@class='run-on']]">
			<xsl:attribute name="style">
				<xsl:value-of select="string-join((@style, 'display:inline;'), ' ')" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="block[@name='figure']">
	<figure>
		<xsl:apply-templates select="@*[name() != 'name']" />
		<xsl:apply-templates />
	</figure>
</xsl:template>
<xsl:template match="tblock[@class='figure']">
	<figure>
		<xsl:apply-templates select="@*[name() != 'class']" />
		<xsl:apply-templates />
	</figure>
</xsl:template>
<xsl:template match="tblock[@class='figure']/heading">
	<figcaption>
		<xsl:apply-templates select="@*|node()" />
	</figcaption>
</xsl:template>

<xsl:template match="hcontainer | block | container | tblock | blockContainer | formula | longTitle |
	mod[quotedStructure] | subFlow | authorialNote | signatures | signature">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:if test="quotedStructure/*[1][@class='run-on']">
			<xsl:attribute name="style">
				<xsl:value-of select="string-join((@style, 'display:inline'), ' ')" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="subFlow[@name='wrapper']">
	<xsl:apply-templates />
</xsl:template>

<xsl:template name="blockquote-children">
	<xsl:param name="contents" as="node()*" />
	<xsl:param name="start-quote" select="''" as="xs:string" tunnel="yes" />
	<xsl:param name="first-text-node-id" select="''" as="xs:string" tunnel="yes" />
	<xsl:param name="end-quote" select="''" as="xs:string" tunnel="yes" />
	<xsl:param name="end-quote-anchor-id" select="()" as="xs:string?" tunnel="yes" />
	<xsl:param name="append-text" select="()" as="element()?" tunnel="yes" />
	<xsl:for-each select="$contents">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="$start-quote and $first-text-node-id and (generate-id(text()[1]) = $first-text-node-id)">
				<xsl:attribute name="data-startQuote"><xsl:value-of select="$start-quote" /></xsl:attribute>
			</xsl:if>
			<xsl:call-template name="blockquote-children">
				<xsl:with-param name="contents" select="node()" />
			</xsl:call-template>
		</xsl:copy>
		<xsl:if test="exists(end-quote-anchor-id) and (generate-id(.) = $end-quote-anchor-id)">
			<xsl:if test="$end-quote">
				<span class="endQuote"><xsl:value-of select="$end-quote" /></span>
			</xsl:if>
			<xsl:if test="$append-text">
				<span class="AppendText"><xsl:apply-templates select="$append-text/node()" /></span>
			</xsl:if>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="quotedStructure | embeddedStructure">
	<blockquote class="{ local-name() }">
		<xsl:apply-templates select="@*[not(name()='startQuote')][not(name()='endQuote')]" />
		<xsl:if test="*[1][@class='run-on']">
			<xsl:attribute name="style">
				<xsl:value-of select="string-join((@style, 'display:inline'), ' ')" />
			</xsl:attribute>
		</xsl:if>
		<xsl:variable name="contents">
			<xsl:apply-templates />
		</xsl:variable>
		<xsl:variable name="text-nodes" as="text()*" select="$contents//text()[normalize-space()]" />
		<xsl:variable name="end-quote-anchor-id" as="xs:string?">
			<xsl:variable name="last-text-node" as="text()?" select="$text-nodes[last()]" />
			<xsl:if test="exists($last-text-node)">
				<xsl:choose>
					<xsl:when test="empty($last-text-node/ancestor::math:math)">
						<xsl:value-of select="generate-id($last-text-node)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="generate-id($last-text-node/ancestor::math:math[1])" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:call-template name="blockquote-children">
			<xsl:with-param name="contents" select="$contents" />
			<xsl:with-param name="start-quote" select="string(@startQuote)" tunnel="yes" />
			<xsl:with-param name="first-text-node-id" select="generate-id($text-nodes[1])" tunnel="yes" />
			<xsl:with-param name="end-quote" select="string(@endQuote)" tunnel="yes" />
			<xsl:with-param name="end-quote-anchor-id" select="$end-quote-anchor-id" tunnel="yes" />
			<xsl:with-param name="append-text" select="following-sibling::*[1][@name='AppendText']" tunnel="yes" />
		</xsl:call-template>
	</blockquote>
</xsl:template>

<xsl:template match="inline[@name='AppendText']" />


<!-- contents -->
<xsl:template match="toc">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="tocItem">
	<div class="{string-join((name(), @class), ' ')}">
		<xsl:apply-templates select="@*[not(name() = 'class')][not(name() = 'href')]" />
		<a>
			<xsl:apply-templates select="@href" />
			<xsl:apply-templates />
		</a>
	</div>
</xsl:template>


<!-- same -->

<xsl:template match="img">
	<xsl:element name="{local-name()}">
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="alt"><xsl:value-of select="@alt" /></xsl:attribute>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="i | b | u | br | caption | tr | th | td | abbr | sup | sub |
	a | ol | ul | li | ins | del">
	<xsl:element name="{local-name()}"><xsl:apply-templates select="@*|node()" /></xsl:element>
</xsl:template>

<xsl:template match="table[@cellpadding]">
	<div>
		<style scoped="">
			<xsl:text>th, td { padding: </xsl:text>
			<xsl:value-of select="@cellpadding" />
			<xsl:text>pt }</xsl:text>
		</style>
		<xsl:next-match />
	</div>
</xsl:template>

<xsl:template match="table">
	<table>
		<xsl:apply-templates select="@*[not(name()='width')][not(name()='border')][not(name()='cellspacing')][not(name()='cellpadding')]" />
		<xsl:attribute name="style">
			<xsl:if test="@style">
				<xsl:value-of select="@style" />
				<xsl:if test="not(ends-with(@style, ';'))">;</xsl:if>
			</xsl:if>
			<xsl:if test="@width">
				<xsl:text>width:</xsl:text>
				<xsl:value-of select="@width" />
				<xsl:text>pt;</xsl:text>
			</xsl:if>
			<xsl:if test="@border">
				<xsl:text>border-width:</xsl:text>
				<xsl:value-of select="@border" />
				<xsl:text>pt;</xsl:text>
			</xsl:if>
			<xsl:if test="@cellspacing">
				<xsl:text>border-spacing:</xsl:text>
				<xsl:value-of select="@cellspacing" />
				<xsl:text>pt;</xsl:text>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates />
	</table>
</xsl:template>


<!-- foreign -->

<xsl:template match="foreign">
	<xsl:apply-templates />
<!-- 	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div> -->
</xsl:template>

<xsl:template match="foreign//*[namespace-uri() != 'http://www.w3.org/1998/Math/MathML'][namespace-uri() != namespace-uri-for-prefix('',.)]">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:attribute name="data-xmlns"><xsl:value-of select="namespace-uri()" /></xsl:attribute>
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="math:math">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@*"/>
		<xsl:choose>
			<xsl:when test="@altimg and not(math:semantics)">
				<semantics>
					<xsl:choose>
						<xsl:when test="every $child in * satisfies $child/self::math:mrow">
							<xsl:apply-templates />
						</xsl:when>
						<xsl:otherwise>
							<mrow>
								<xsl:apply-templates />
							</mrow>
						</xsl:otherwise>
					</xsl:choose>
					<annotation-xml encoding="MathML-Presentation">
						<mtext><img src="{ @altimg }" alt="math" /></mtext>
					</annotation-xml>
				</semantics>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose> 
	</xsl:element>
</xsl:template>

<xsl:template match="math:semantics">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@*"/> 
		<xsl:apply-templates />
		<xsl:if test="../@altimg">
			<annotation-xml encoding="MathML-Presentation">
				<mtext><img src="{../@altimg}" alt="math" /></mtext>
			</annotation-xml>
		</xsl:if>
	</xsl:element>
</xsl:template>

<xsl:template match="math:*">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@*" /> 
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>



<!-- inline -->

<xsl:template match="docTitle | shortTitle">
	<h1>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</h1>
</xsl:template>

<xsl:template match="inline">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="inline[@name='uppercase']">
	<span class="uppercase">
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="quotedText">
	<q><xsl:apply-templates select="@*|node()" /></q>
</xsl:template>

<xsl:template match="noteRef">
	<xsl:choose>
		<xsl:when test="@placement = 'inline'">
			<xsl:text> </xsl:text>
			<span class="{string-join((local-name(), @class), ' ')}">
				<xsl:apply-templates select="@*[not(name()='class')][not(name()='href')][not(name()='placement')]" />
				<xsl:text>[</xsl:text>
				<xsl:variable name="note" select="key('id', substring(@href, 2))" />
				<!-- assumes all inline notes have first-level p children -->
				<xsl:apply-templates select="$note/p/node()" />
				<xsl:text>]</xsl:text>
			</span>
			<xsl:text> </xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<a class="{string-join((local-name(), @class), ' ')}">
				<xsl:apply-templates select="@*[not(name() = 'class')][not(name() = 'marker')]" />
				<xsl:value-of select="@marker" />
			</a>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ref">
	<cite>
		<xsl:apply-templates select="@*[not(name()='href')]" />
		<xsl:choose>
			<xsl:when test=".//ref or parent::a">
				<xsl:attribute name="data-href"><xsl:value-of select="@href" /></xsl:attribute>
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:apply-templates select="@href" />
					<xsl:apply-templates />
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</cite>
</xsl:template>

<xsl:template match="rref">
	<cite>
		<xsl:apply-templates select="@*" />
		<xsl:choose>
			<xsl:when test=".//ref">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="@from" />
					</xsl:attribute>
					<xsl:apply-templates />
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</cite>
</xsl:template>

<xsl:template match="date | docDate">
	<time>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</time>
</xsl:template>

<xsl:template match="span">
	<span><xsl:apply-templates select="@*|node()" /></span>
</xsl:template>

<xsl:template match="*">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</span>
</xsl:template>


<!-- markers -->

<!-- eol -> <wbr> -->

<!-- attributes -->

<xsl:template match="@eId">
<!-- 	<xsl:param name="annotation-root-id" as="xs:string?" tunnel="yes" select="()" /> -->
	<xsl:attribute name="id">
<!-- 		<xsl:if test="exists($annotation-root-id)">
			<xsl:value-of select="$annotation-root-id" />
			<xsl:text>-</xsl:text>
		</xsl:if> -->
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@date">
	<xsl:attribute name="datetime"><xsl:value-of select="." /></xsl:attribute>
</xsl:template>

<xsl:template match="@class | @title | @style | @src | @alt | @width | @height | @colspan | @rowspan">
	<xsl:copy />
</xsl:template>

<xsl:template match="@href">
	<xsl:attribute name="href">
		<xsl:value-of select="replace(., ' ', '%20')" />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@xml:lang">
	<xsl:attribute name="{local-name()}"><xsl:value-of select="." /></xsl:attribute>
</xsl:template>

<xsl:template match="@*">
	<xsl:attribute name="data-{replace(name(), ':', '-')}"><xsl:value-of select="." /></xsl:attribute>
</xsl:template>

<xsl:template match="text()">
	<xsl:value-of select="translate(., '&#128;&#132;&#149;&#150;&#153;&#157;', '')" />
</xsl:template>

</xsl:stylesheet>
