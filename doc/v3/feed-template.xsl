<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:atom="http://www.w3.org/2005/Atom">
<xsl:output cdata-section-elements="atom:content"
            indent="yes" />
<xsl:template match="/">
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <atom:link href="https://hangprinter.org/doc/v3/feed.xml" rel="self" type="application/rss+xml" />
    <title>Hangprinter v3 Manual</title>
    <description>How to Build and Use Hangprinter v3</description>
    <link>https://hangprinter.org/doc/v3</link>
    <xsl:variable name="array" select="document('catalouge.xml')/filelist/file"/>
    <xsl:for-each select="$array">
      <xsl:variable name="filename" select="."/>
      <xsl:for-each select="document($filename)/page/post">
        <item>
          <title><xsl:value-of select="./@heading" /></title>
          <description></description>
          <link>https://hangprinter.org/doc/v3/<xsl:value-of select="$filename" /></link>
          <guid>https://hangprinter.org/doc/v3/<xsl:value-of select="$filename" /></guid>
        </item>
    </xsl:for-each>
    </xsl:for-each>
  </channel>
</rss>
</xsl:template>
</xsl:stylesheet>
