<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"
            doctype-system="about:legacy-compat"
            encoding="UTF-8"
            indent="yes" />
<xsl:template match="/">
<html>
<head>
  <meta name="author" content="tobben and the Hangprinter Community" />
  <meta name="keywords" content="Reprap, Manual, Hangprinter" />
  <meta name="description" content="Hangprinter v3 Manual" />
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <link rel="stylesheet" href="style.css" type="text/css" />
  <link href="https://hangprinter.org/doc/v3/feed.xml" rel="alternate" type="application/rss+xml" title="Hangprinter v3 Manual" />
  <xsl:choose>
    <xsl:when test="page/@mathjax">
      <script type="text/javascript"
               src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS_HTML">
      </script>
    </xsl:when>
  </xsl:choose>
  <title>Hangprinter Assembly</title>
</head>
<body>
<div id="SiteName">
  Hangprinter v3 Assembly Manual
</div>
<div id="MainContent">
  <figure>
    <a href="../v3"><img src="./media/logo-banner.png" alt="" /> </a>
  </figure>
  <xsl:for-each select="page/post">
    <h3><xsl:attribute name="id" > <xsl:value-of select="./@id" /></xsl:attribute>
      <a><xsl:attribute name="href">#<xsl:value-of select="./@id" /></xsl:attribute><xsl:value-of select="./@heading" /></a>
    </h3>
    <xsl:copy-of select="./*" />
  </xsl:for-each>
</div>
<xsl:choose>
  <xsl:when test="page/@mathjax">
    <script type="text/javascript">
      MathJax.Hub.Configured()
    </script>
  </xsl:when>
</xsl:choose>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
