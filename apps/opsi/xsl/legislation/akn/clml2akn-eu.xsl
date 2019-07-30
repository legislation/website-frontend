<?xml version="1.0" encoding="utf-8"?>

<!-- v2.0.2, written by Jim Mangiafico -->

<xsl:transform version="2.0"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:clml2akn="http://clml2akn.mangiafico.com/"
	exclude-result-prefixes="xs ukm clml2akn">

<xsl:template match="ukm:EURLexMetadata" priority="1" />

<xsl:template match="Legislation/EURetained">
	<xsl:choose>
		<xsl:when test="$is-fragment">
			<portionBody>
				<xsl:if test="EUBody/@RestrictExtent">
					<xsl:attribute name="eId">body</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="period"><xsl:with-param name="e" select="EUBody" /></xsl:call-template>
				<xsl:apply-templates select="*" />
			</portionBody>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="EUPrelims" />
			<body>
				<xsl:if test="EUBody/@RestrictExtent">
					<xsl:attribute name="eId">body</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="period"><xsl:with-param name="e" select="Body" /></xsl:call-template>
				<xsl:apply-templates select="EUBody/*[not(self::CommentaryRef)]" />
				<xsl:apply-templates select="Schedules" />
			</body>
			<xsl:call-template name="attachments" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="EUPrelims">
	<preface>
		<xsl:choose>
			<xsl:when test="exists(EUPreamble)">
				<xsl:apply-templates select="EUPreamble/preceding-sibling::*" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</preface>
	<xsl:apply-templates select="EUPreamble" />
</xsl:template>

<xsl:template match="MultilineTitle">
	<longTitle>
		<xsl:apply-templates />
	</longTitle>
</xsl:template>

<xsl:template match="EUPrelims/Number">
	<p class="number"><docNumber><xsl:apply-templates /></docNumber></p>
</xsl:template>

<xsl:template match="EUPreamble">
	<xsl:choose>
		<xsl:when test="$is-fragment">
			<xsl:apply-templates>
				<xsl:with-param name="context" select="'block'" tunnel="yes" />
			</xsl:apply-templates>
			<xsl:apply-templates select="../../EUBody/CommentaryRef" />
		</xsl:when>
		<xsl:otherwise>
			<preamble>
				<xsl:call-template name="period" />
				<xsl:apply-templates>
					<xsl:with-param name="context" select="'block'" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:apply-templates select="../../EUBody/CommentaryRef" />
			</preamble>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="EUPreamble/CommentaryRef[following-sibling::*[1][self::P][Text]]">
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$force">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise />
	</xsl:choose>
</xsl:template>
<xsl:template match="EUPreamble/P[preceding-sibling::*[1][self::CommentaryRef]]/Text">
	<p>
		<xsl:apply-templates select="parent::P/preceding-sibling::*[1]">
			<xsl:with-param name="force" select="true()" />
		</xsl:apply-templates>
		<xsl:apply-templates />
	</p>
</xsl:template>


<!-- structure -->

<xsl:template match="EUPart | EUTitle | EUChapter | EUSection | EUSubsection">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="name" select="lower-case(substring(local-name(), 3))" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Division">
	<xsl:param name="context" as="xs:string?" select="()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$context = 'block'">
			<tblock>
				<xsl:if test="@Type">
					<xsl:attribute name="class">
						<xsl:value-of select="lower-case(@Type)" />
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates />
				<xsl:if test="empty(*[not(self::Number or self::Title)])">
					<p/>
				</xsl:if>
			</tblock>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="hierarchy">
				<xsl:with-param name="name" select="'level'" />
				<xsl:with-param name="attrs" as="attribute()*">
					<xsl:if test="@Type">
						<xsl:attribute name="class">
							<xsl:value-of select="@Type" />
						</xsl:attribute>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:function name="clml2akn:eu-provision-name" as="xs:string?">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/self::P1">article</xsl:when>
		<xsl:when test="$e/self::P2">paragraph</xsl:when>
		<xsl:when test="$e/self::P3">subparagraph</xsl:when>
	</xsl:choose>
</xsl:function>


<!-- signatures -->

<xsl:template match="EURetained//Signatory">
	<xsl:apply-templates select="Para" />
	<xsl:if test="exists(Signee)">
		<blockContainer class="signees">
			<xsl:apply-templates select="Signee" />
		</blockContainer>
	</xsl:if>
</xsl:template>

<xsl:template match="EURetained//Signee">
	<blockContainer class="signee">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>


<!-- new inline -->

<xsl:template match="Uppercase">
	<inline name="uppercase"><xsl:apply-templates /></inline>
</xsl:template>
<xsl:template match="Expanded">
	<inline name="expanded"><xsl:apply-templates /></inline>
</xsl:template>


<!-- BlockExtract -->

<xsl:template match="BlockExtract/EUPreamble">
	<container name="preamble">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="'block'" tunnel="yes" />
		</xsl:apply-templates>
	</container>
</xsl:template>


<!-- attachments -->

<xsl:template name="attachments">
	<xsl:if test="exists(Attachments)">
		<attachments>
			<xsl:apply-templates select="Attachments/*" />
		</attachments>
	</xsl:if>
</xsl:template>

<xsl:template match="Attachments/Title">
	<attachment>
		<interstitial>
			<p>
				<xsl:apply-templates />
			</p>
		</interstitial>
	</attachment>
</xsl:template>

<xsl:template match="AttachmentGroup">
	<attachment>
		<documentCollection name="attachmentGroup">
			<xsl:call-template name="attachment-metadata" />
			<xsl:if test="exists(Number | Title)">
				<preface>
					<xsl:apply-templates select="Number | Title" />
				</preface>
			</xsl:if>
			<collectionBody>
				<xsl:apply-templates select="*[not(self::Number or self::Title)]" />
			</collectionBody>
		</documentCollection>
	</attachment>
</xsl:template>

<xsl:template match="AttachmentGroup/Number | AttachmentGroup/Title">
	<block name="{ lower-case(local-name()) }">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="AttachmentGroup/Attachment">
	<component>
		<xsl:apply-templates />
	</component>
</xsl:template>

<xsl:template match="Attachment">
	<attachment>
		<xsl:apply-templates />
	</attachment>
</xsl:template>

<xsl:template match="Attachment/EURetained">
	<doc name="unknown">
		<xsl:call-template name="attachment-metadata" />
		<xsl:apply-templates select="EUPrelims" />
		<mainBody>
			<xsl:if test="empty(EUBody/* | Schedules)">
				<p></p>
			</xsl:if>
			<xsl:apply-templates select="EUBody/*" />
			<xsl:apply-templates select="Schedules" />
		</mainBody>
		<xsl:call-template name="attachments" />
	</doc>
</xsl:template>

</xsl:transform>
