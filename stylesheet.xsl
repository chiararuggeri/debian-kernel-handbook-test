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
<xsl:param name="html.stylesheet">kernel-handbook.css</xsl:param>

<!-- Replace standard header and footer to match Debian style -->

<xsl:param name="suppress.navigation">1</xsl:param>

<xsl:template name="user.header.navigation">
  <!-- Get the title of this page -->
  <xsl:variable name="doc" select="self::*"/>
  <xsl:variable name="title">
    <xsl:apply-templates select="$doc" mode="object.title.markup.textonly"/>
  </xsl:variable>

  <!-- Get the id of this book/chapter -->
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="."/>
    </xsl:call-template>
  </xsl:variable>

  <div id="header">
    <div id="logo">
      <a href="https://www.debian.org" title="Debian Home"><img src="./Pics/openlogo-50.png" alt="Debian" width="50" height="61"/></a>
    </div>
    <div id="navbar">
      <p class="hidecss">
	<a>
          <xsl:attribute name="href">
	    #<xsl:copy-of select="$id"/>
	  </xsl:attribute>
	  Skip Quicknav
	</a>
      </p>
      <ul>
	<li><a href="https://salsa.debian.org/kernel-team">Kernel team</a></li>
      </ul>
    </div>
    <p id="breadcrumbs">
      <xsl:if test="$title != 'Debian Linux Kernel Handbook'">
	<a href="index.html">Debian Linux Kernel Handbook</a> /
      </xsl:if>
      <xsl:copy-of select="$title"/>
    </p>
  </div>
</xsl:template>

<xsl:template name="user.footer.navigation">
  <xsl:param name="prev"/>
  <xsl:param name="next"/>
  <xsl:variable name="home" select="/*[1]"/>

  <div id="footer">
    <hr class="hidecss"/>
    <div id="footer-nav">
      <div id="prev-link">
	<xsl:if test="$prev != ''">
	  <a accesskey="p">
            <xsl:attribute name="href">
	      <xsl:call-template name="href.target">
		<xsl:with-param name="object" select="$prev"/>
	      </xsl:call-template>
            </xsl:attribute>
            <xsl:call-template name="navig.content">
	      <xsl:with-param name="direction" select="'prev'"/>
            </xsl:call-template>:
            <xsl:apply-templates select="$prev" mode="object.title.markup"/>
	  </a>
	</xsl:if>
	&#160;
      </div>
      <div id="home-link">
	<xsl:if test="$home != .">
	  <a accesskey="h">
            <xsl:attribute name="href">
	      <xsl:call-template name="href.target">
		<xsl:with-param name="object" select="$home"/>
	      </xsl:call-template>
            </xsl:attribute>
            <xsl:call-template name="navig.content">
	      <xsl:with-param name="direction" select="'home'"/>
            </xsl:call-template>
	  </a>
	</xsl:if>
      </div>
      <div id="next-link">
	&#160;
	<xsl:if test="$next != ''">
	  <a accesskey="n">
            <xsl:attribute name="href">
	      <xsl:call-template name="href.target">
		<xsl:with-param name="object" select="$next"/>
	      </xsl:call-template>
            </xsl:attribute>
            <xsl:call-template name="navig.content">
	      <xsl:with-param name="direction" select="'next'"/>
            </xsl:call-template>:
            <xsl:apply-templates select="$next" mode="object.title.markup"/>
	  </a>
	</xsl:if>
      </div>
    </div>
  </div>
</xsl:template>

</xsl:stylesheet>
