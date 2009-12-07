<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!-- 设置输出文件编码，否则为 ISO8859-1 (from chunker.xsl) -->
<xsl:param name="chunker.output.encoding">gb2312</xsl:param>

<!-- 更好的输出: 输出文件缩进控制, yes/no (from chunker.xsl) -->
<xsl:param name="chunker.output.indent">yes</xsl:param>

<!-- 提供分页速度。需要 EXSLT node-set() 函数支持，Saxon, Xalan, 
     和 xsltproc 均支持 (from chunk-code.xsl) -->
<xsl:param name="chunk.fast" select="1"/>


<!-- 以图标方式显示警告 (admonitions) (from param.xsl) -->
<xsl:param name="admon.graphics" select="1"/>
<xsl:param name="admon.textlabel" select="0"/>
<xsl:param name="admon.graphics.path">images/</xsl:param>
<xsl:param name="admon.graphics.extension">.png</xsl:param>

<!-- 以图标方式显示导航 (from param.xsl) -->
<xsl:param name="navig.graphics" select="1"/>
<xsl:param name="navig.graphics.path">images/</xsl:param>
<xsl:param name="navig.graphics.extension">.png</xsl:param>

<!-- 以图标方式显示 callout (from param.xsl) -->
<xsl:param name="callout.graphics" select="1"/>
<xsl:param name="callout.graphics.path">images/callouts/</xsl:param>
<xsl:param name="callout.graphics.extension">.png</xsl:param>
<xsl:param name="callout.graphics.number.limit">15</xsl:param>

<!-- 标题显示位置 (from param.xsl) -->
<xsl:param name="formal.title.placement">
figure after
example before
equation after
table before
procedure before
task before
</xsl:param>

<!-- 是否根据元素 ID 确定文件名？ (from param.xsl) -->
<xsl:param name="use.id.as.filename" select="1"/>

<!-- 章节编号 (from param.xsl) -->
<xsl:param name="section.autolabel"   select="1"/>
<xsl:param name="section.label.includes.component.label"   select="1"/>
<xsl:param name="section.autolabel.max.depth" select="8"/>

<!-- 目录的级别，3 含义为显示到 sect3 (from param.xsl) -->
<xsl:param name="toc.section.depth">3</xsl:param>

</xsl:stylesheet>
