<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

  <xsl:import href="/usr/share/xml/docbook/stylesheet/nwalsh/fo/docbook.xsl"/>
  <!-- PARAMETER REFERENCE:                                       -->
  <!-- http://docbook.sourceforge.net/release/xsl/current/doc/fo/ -->
  <xsl:param name="fop.extensions" select="0"/>
  <xsl:param name="variablelist.as.blocks" select="1" />
  <xsl:param name="body.start.indent">0pt</xsl:param>
  <xsl:param name="body.font.family">SimSun</xsl:param>
  <xsl:param name="dingbat.font.family">SimSun</xsl:param>
  <xsl:param name="monospace.font.family">SimSun</xsl:param>
  <xsl:param name="title.font.family">SimHei</xsl:param>
  <xsl:param name="admon.textlabel" select="0" />
  <xsl:param name="admon.graphics" select="1" />
  <xsl:param name="admon.graphics.extension">.png</xsl:param>
  <!-- Uncomment this to enable auto-numbering of sections -->
  <!-- xsl:param name="section.autolabel" select="1" / -->
  <xsl:attribute-set name="sidebar.properties" use-attribute-sets="formal.object.properties">
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">.1mm</xsl:attribute>
    <xsl:attribute name="background-color">#EEEEEE</xsl:attribute>
  </xsl:attribute-set>
  

</xsl:stylesheet>
