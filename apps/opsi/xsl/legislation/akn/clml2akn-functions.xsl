<?xml version="1.0" encoding="utf-8"?>

<!-- v2.0.2, written by Jim Mangiafico -->

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:clml2akn="http://clml2akn.mangiafico.com/"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	exclude-result-prefixes="xs clml2akn">

<xsl:function name="clml2akn:is-hcontainer" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="name" as="xs:string" select="local-name($e)" />
	<xsl:choose>
		<xsl:when test="$name = ('Group', 'Part', 'Chapter', 'Pblock', 'PsubBlock')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('P')">
			<xsl:value-of select="some $child in $e/* satisfies clml2akn:is-hcontainer($child)" />
		</xsl:when>
		<xsl:when test="$name = ('P1', 'P1group', 'P2', 'P2group', 'P3', 'P3group', 'P4', 'P5', 'P6')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('Schedules', 'Schedule', 'Appendix', 'AttachmentGroup', 'Attachment')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('EUPart', 'EUTitle', 'EUChapter', 'EUSection', 'EUSubsection', 'Division')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>	

<xsl:function name="clml2akn:is-inline" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/self::Emphasis">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Strong">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Underline">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::SmallCaps">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Uppercase">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Expanded">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Abbreviation">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Acronym">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Addition">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Repeal">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Substitution">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Citation">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Span">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::FootnoteRef">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Superior">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Inferior">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Character">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Strike">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::InternalLink">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::CommentaryRef">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Term">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="clml2akn:parse-date" as="xs:date?">
	<xsl:param name="text" as="xs:string" />
	<xsl:analyze-string regex="(\d{{1,2}})(st|nd|th)?( day of)? (January|February|March|April|May|June|July|August|September|October|November|December) (\d{{4}})" select="normalize-space($text)">
		<xsl:matching-substring>
			<xsl:variable name="day" as="xs:string" select="format-number(number(regex-group(1)), '00')" />
			<xsl:variable name="months" as="xs:string*" select="('January','February','March','April','May','June','July','August','September','October','November','December')" />
			<xsl:variable name="month" as="xs:string" select="format-number(index-of($months, regex-group(4)), '00')" />
			<xsl:variable name="year" as="xs:string" select="regex-group(5)" />
			<xsl:value-of select="concat($year, '-', $month, '-', $day)" />
		</xsl:matching-substring>
	</xsl:analyze-string>
</xsl:function>

</xsl:transform>