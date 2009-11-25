<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

  <xsl:import href="/usr/share/xml/docbook/stylesheet/nwalsh/html/docbook.xsl"/>


<xsl:param name="l10n.gentext.language" select="'zh_cn'"/>

<!-- 设置输出文件编码，否则为 ISO8859-1 (from chunker.xsl) -->
<xsl:param name="chunker.output.encoding">gb2312</xsl:param>

<!-- 更好的输出: 输出文件缩进控制, yes/no (from chunker.xsl) -->
<xsl:param name="chunker.output.indent">yes</xsl:param>

<!-- 设置 CSS 样式表. (from param.xsl) -->
<xsl:param name="html.stylesheet.type">text/css</xsl:param>
<xsl:param name="generate.id.attributes" select="0"/>

<!-- 以图标方式显示警告 (admonitions) (from param.xsl) -->
<xsl:param name="admon.graphics" select="1"/>
<xsl:param name="admon.textlabel" select="0"/>
<xsl:param name="admon.graphics.extension">.png</xsl:param>
</xsl:stylesheet>
