<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:param name="chunk.quietly">1</xsl:param>
<!-- One file per chapter, not per section -->
<xsl:param name="chunk.section.depth">0</xsl:param>
<!-- Label chapters and sections like DebianDoc -->
<xsl:param name="chapter.autolabel">1</xsl:param>
<xsl:param name="section.autolabel">1</xsl:param>
<xsl:param name="section.label.includes.component.label">1</xsl:param>
<!-- Where auto-generated IDs are needed, generate them consistently,
     for reproducible builds -->
<xsl:param name="generate.consistent.ids">1</xsl:param>
<!-- Put each <term> on a separate line, with no other separator -->
<xsl:param name="variablelist.term.break.after">1</xsl:param>
<xsl:param name="variablelist.term.separator"/>
<xsl:param name="html.stylesheet">debian.css</xsl:param>
</xsl:stylesheet>
