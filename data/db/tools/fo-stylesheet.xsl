<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
   <xsl:import href="/opt/docbook/tools/xml/stylesheet/worldhello.net/fo/docbook.xsl"/>
   <xsl:param name="document_root">/docbook</xsl:param>
  
  <xsl:param name="body.font.family">SimSun</xsl:param>
  <xsl:param name="body.font.size">12</xsl:param>
  <xsl:param name="monospace.font.family">SimSun</xsl:param>
  <xsl:param name="title.font.family">SimSun</xsl:param>
  <xsl:param name="page.margin.inner">2cm</xsl:param>
  <xsl:param name="page.margin.outer">2cm</xsl:param>
  <xsl:param name="paper.type" select="'A4'"/>
  <xsl:param name="hyphenate">false</xsl:param>
  <xsl:param name="fop.extensions" select="0"/>
</xsl:stylesheet>
