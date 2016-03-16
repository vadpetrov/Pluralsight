<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl   = "http://www.w3.org/1999/XSL/Transform"
                xmlns:fn    = "http://www.w3.org/2005/02/xpath-functions"
                xmlns:html  = "http://www.w3.org/TR/REC-html40"
                xmlns:msxsl = "urn:schemas-microsoft-com:xslt"
                xmlns:x     = "urn:schemas-microsoft-com:office:excel"
                xmlns:o     = "urn:schemas-microsoft-com:office:office"
                xmlns:ss    = "urn:schemas-microsoft-com:office:spreadsheet"
                xmlns:v     = "urn:schemas-microsoft-com:vml">

  <xsl:output method="xml" indent="yes" />

  <xsl:decimal-format name="nanFormat" NaN=""/>

  <xsl:variable name="HEAD"         select="//root/table[@id='head']/row"/>
  <xsl:variable name="PRODUCT_DATA" select="//root/table[@id='product_data']/row"/>
  <xsl:variable name="DEAL_DATA"    select="//root/table[@id='deal_data']/row"/>
  <xsl:variable name="CALC_NOTES"   select="//root/table[@id='calc_notes']/row"/>
  <xsl:variable name="ZOOM"         select="80"/>
  <xsl:variable name="FILTERS"      select="count(//root/@*[.!=''][
                                               local-name()='ProductID'
                                            or local-name()='ProductGroupID'
                                            or local-name()='SPV' 
                                            or local-name()='VehicleID'
                                            or local-name()='VintageYearID'
                                            or local-name()='StrategyID'])"/>
  <xsl:variable name="TOP_ROWS"     select="number($FILTERS) + 3"/>
  <xsl:variable name="AUTO_FILTER"  select="$HEAD/item[@id='ExcelAutoFilter']/@value"/>

  <xsl:template match="/">
    <xsl:processing-instruction name="mso-application">
      <xsl:text>progid="Excel.Sheet"</xsl:text>
    </xsl:processing-instruction>

    <ss:Workbook>
      <ss:DocumentProperties>

      </ss:DocumentProperties>

      <ss:OfficeDocumentSettings>

      </ss:OfficeDocumentSettings>

      <ss:ExcelWorkbook>
        <ss:ProtectStructure>False</ss:ProtectStructure>
        <ss:ProtectWindows>False</ss:ProtectWindows>
      </ss:ExcelWorkbook>

      <ss:Styles>
        <ss:Style ss:ID="REPORT_MAIN_TITLE">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="0"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="10" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="REPORT_MAIN_TITLE_TOP">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:WrapText="0"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="10" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="REPORT_MAIN_TITLE_BOTTOM">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="0"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="10" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="HEADER_LEFT">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>
        <ss:Style ss:ID="HEADER_RIGHT">
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>
        <ss:Style ss:ID="HEADER_CENTER">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>

        <ss:Style ss:ID="HEADER_LEFT_TOP">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>
        <ss:Style ss:ID="HEADER_RIGHT_TOP">
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>
        <ss:Style ss:ID="HEADER_CENTER_TOP">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>
        <ss:Style ss:ID="HEADER_CENTER_TOP_BRD">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>

        <ss:Style ss:ID="HEADER_LEFT_BOTTOM_NBB">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>

        <ss:Style ss:ID="HEADER_LEFT_BOTTOM">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>

        <ss:Style ss:ID="HEADER_RIGHT_BOTTOM">
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>
        <ss:Style ss:ID="HEADER_CENTER_BOTTOM">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>
        <ss:Style ss:ID="HEADER_CENTER_BOTTOM_NBB">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
          <ss:Font ss:FontName="Arial Unicode MS" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
        </ss:Style>

        <ss:Style ss:ID="LABEL_TOTAL_LEFT">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="None" ss:Weight="0"/>
          </ss:Borders>
        </ss:Style>
        <ss:Style ss:ID="LABEL_TOTAL_RIGHT">
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="None" ss:Weight="0"/>
          </ss:Borders>
          <ss:NumberFormat ss:Format="#,##0.00;@"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_TOTAL_CENTER">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="None" ss:Weight="0"/>
          </ss:Borders>
        </ss:Style>

        <ss:Style ss:ID="LABEL_ACTIVE_LEFT_TOP">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_ACTIVE_LEFT">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_ACTIVE_CENTER">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_ACTIVE_RIGHT">
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_ACTIVE_RIGHT_TOP">
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Top" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_ACTIVE_LEFT_NOWRAP">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="0"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_LEFT_TOP">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_LEFT">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_LEFT_1">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
        </ss:Style>
        <ss:Style ss:ID="LABEL_RED_TOP">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Color="red"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_RED">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Color="red"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_ISSUE_NEW">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Color="black" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_ISSUE_CHANGED">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Color="blue" ss:Bold="1"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_NOTIFY">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Color="red"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_NOTIFY_LEFT">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Color="red"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_CENTER">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_CENTER_1">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
        </ss:Style>
        <ss:Style ss:ID="LABEL_RIGHT">
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Top" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_LEFT_NOWRAP">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:WrapText="0"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <!--NUMERIC STYLES-->
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL_SHORT">
          <ss:NumberFormat ss:Format="#,##0.0;@"/>
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL_SHORT_CENTER">
          <ss:NumberFormat ss:Format="#,##0.0;@"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL">
          <ss:NumberFormat ss:Format="#,##0.00;@"/>
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL_PERCENT">
          <ss:NumberFormat ss:Format="Percent"/>
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL_PERCENT_TOTAL">
          <ss:NumberFormat ss:Format="Percent"/>
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="None" ss:Weight="0"/>
          </ss:Borders>
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL_PERCENT_TOTAL_CENTER">
          <ss:NumberFormat ss:Format="Percent"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="None" ss:Weight="0"/>
          </ss:Borders>
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL_%">
          <ss:NumberFormat ss:Format="#,##0.0%;@"/>
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL_CENTER_%">
          <ss:NumberFormat ss:Format="#,##0.0%;@"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL_X">
          <ss:NumberFormat ss:Format="##0.00x;@"/>
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_DECIMAL_TOTAL">
          <ss:NumberFormat ss:Format="#,##0.00;@"/>
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="None" ss:Weight="0"/>
          </ss:Borders>
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_INTEGER_LEFT_TOP">
          <ss:NumberFormat ss:Format="#,##0;[Red]\(#,##0\)"/>
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Top"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_INTEGER_LEFT">
          <ss:NumberFormat ss:Format="#,##0;[Red]\(#,##0\)"/>
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_INTEGER">
          <ss:NumberFormat ss:Format="#,##0;[Red]\(#,##0\)"/>
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_INTEGER_CENTER_SIMPLE">
          <ss:NumberFormat ss:Format="####"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_INTEGER_CENTER">
          <ss:NumberFormat ss:Format="#,##0;[Red]\(#,##0\)"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" />
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_INTEGER_TOTAL">
          <ss:NumberFormat ss:Format="#,##0;[Red]\(#,##0\)"/>
          <ss:Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="None" ss:Weight="0"/>
          </ss:Borders>
        </ss:Style>
        <ss:Style ss:ID="LABEL_NUMBER_INTEGER_TOTAL_CENTER">
          <ss:NumberFormat ss:Format="#,##0;[Red]\(#,##0\)"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="Continuous" ss:Weight="1"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="None" ss:Weight="0"/>
          </ss:Borders>
        </ss:Style>

        <!--DATE STYLES-->
        <ss:Style ss:ID="LABEL_DATE_1">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
          <ss:NumberFormat ss:Format="[ENG][$-409]mmm\ d\,\ yyyy;@"/>
          <ss:Borders>
            <ss:Border ss:Position="Top"     ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Bottom"  ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Left"    ss:LineStyle="None" ss:Weight="0"/>
            <ss:Border ss:Position="Right"   ss:LineStyle="Continuous" ss:Weight="1"/>
          </ss:Borders>
        </ss:Style>
        <ss:Style ss:ID="LABEL_DATE_LEFT_TOP">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
          <ss:NumberFormat ss:Format="[ENG][$-409]mmm\ d\,\ yyyy;@"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_DATE_LEFT">
          <ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
          <ss:NumberFormat ss:Format="[ENG][$-409]mmm\ d\,\ yyyy;@"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_DATE_TOP">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
          <ss:NumberFormat ss:Format="[ENG][$-409]mmm\ d\,\ yyyy;@"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_DATE">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
          <ss:NumberFormat ss:Format="[ENG][$-409]mmm\ d\,\ yyyy;@"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_DATE_DEFAULT">
          <ss:NumberFormat ss:Format="mm/dd/yyyy;@"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_DATE_SHORT">
          <ss:NumberFormat ss:Format="m/d/yyyy"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_DATE_MEDIUM">
          <ss:NumberFormat ss:Format="Medium Date"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <ss:Style ss:ID="LABEL_DATE_GENERAL">
          <ss:NumberFormat ss:Format="General Date"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <ss:Style ss:ID="REDUCTION_FEE_0">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
        </ss:Style>
        <ss:Style ss:ID="REDUCTION_FEE_1">
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8" ss:Color="red"/>
        </ss:Style>
        <ss:Style ss:ID="REDUCTION_FEE_2">
          <ss:NumberFormat ss:Format="m/d/yyyy"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
          <ss:Interior ss:Color="#9EE5AC" ss:Pattern="Solid"/>
        </ss:Style>
        <ss:Style ss:ID="REDUCTION_FEE_3">
          <ss:NumberFormat ss:Format="m/d/yyyy"/>
          <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <ss:Font ss:FontName="Verdana" x:Family="Swiss" ss:Size="8"/>
          <ss:Interior ss:Color="#F5A9A9" ss:Pattern="Solid"/>
        </ss:Style>

      </ss:Styles>

      <ss:Worksheet ss:Name="Report Header">
        <x:WorksheetOptions>
          <x:PageSetup>
            <x:Layout x:Orientation="Landscape" x:CenterHorizontal="1" x:CenterVertical="0"/>
            <x:Footer x:Data="&amp;CPage &amp;P of &amp;N&amp;RProduced on &amp;D"/>
          </x:PageSetup>
          <x:FitToPage/>
          <x:Print>
            <x:Scale>50</x:Scale>
            <x:FitHeight>20</x:FitHeight>
            <x:LeftToRight/>
            <x:ValidPrinterInfo/>
            <x:HorizontalResolution>600</x:HorizontalResolution>
            <x:VerticalResolution>600</x:VerticalResolution>
          </x:Print>
          <x:Zoom>
            <xsl:value-of select="$ZOOM"/>
          </x:Zoom>
          <x:DoNotDisplayGridlines/>
          <x:ProtectObjects>False</x:ProtectObjects>
          <x:ProtectScenarios>False</x:ProtectScenarios>
          <x:ActivePane>0</x:ActivePane>
        </x:WorksheetOptions>
        <xsl:call-template name="REPORT_HEADER"/>
      </ss:Worksheet>

      <ss:Worksheet ss:Name="Product Vehicle">
        <x:WorksheetOptions>
          <x:PageSetup>
            <x:Layout x:Orientation="Landscape" x:CenterHorizontal="1" x:CenterVertical="0"/>
            <x:Footer x:Data="&amp;CPage &amp;P of &amp;N&amp;RProduced on &amp;D"/>
          </x:PageSetup>
          <x:FitToPage/>
          <x:Print>
            <x:Scale>50</x:Scale>
            <x:FitHeight>20</x:FitHeight>
            <x:LeftToRight/>
            <x:ValidPrinterInfo/>
            <x:HorizontalResolution>600</x:HorizontalResolution>
            <x:VerticalResolution>600</x:VerticalResolution>
          </x:Print>
          <x:Zoom>
            <xsl:value-of select="$ZOOM"/>
          </x:Zoom>
          <x:DoNotDisplayGridlines/>
          <x:ProtectObjects>False</x:ProtectObjects>
          <x:ProtectScenarios>False</x:ProtectScenarios>
          <x:FreezePanes/>
          <x:FrozenNoSplit/>
          <x:SplitHorizontal>3</x:SplitHorizontal>
          <x:TopRowBottomPane>3</x:TopRowBottomPane>
          <x:SplitVertical>1</x:SplitVertical>
          <x:LeftColumnRightPane>1</x:LeftColumnRightPane>
          <x:ActivePane>0</x:ActivePane>
        </x:WorksheetOptions>

        <xsl:variable name="PRODUCT_TABLE_ROWS" select="count($PRODUCT_DATA)+1"/>
        <xsl:if test ="$AUTO_FILTER = 1 and $PRODUCT_TABLE_ROWS > 1">
          <ss:Names>
            <ss:NamedRange ss:Name="_FilterDatabase" ss:RefersTo="='Product Vehicle'!R3C1:R{$PRODUCT_TABLE_ROWS}C20" ss:Hidden="1"/>
            <ss:NamedRange ss:Name="Print_Titles" ss:RefersTo="='Product Vehicle'!R1:R3"/>
          </ss:Names>
          <x:AutoFilter x:Range="R3C1:R{$PRODUCT_TABLE_ROWS}C20">
          </x:AutoFilter>
        </xsl:if>

        <xsl:call-template name="PRODUCT_VEHCILE"/>
      </ss:Worksheet>

      <ss:Worksheet ss:Name="Product Vehicle Deal">
        <x:WorksheetOptions>
          <x:PageSetup>
            <x:Layout x:Orientation="Landscape" x:CenterHorizontal="0" x:CenterVertical="0"/>
            <x:Footer x:Data="&amp;CPage &amp;P of &amp;N&amp;RProduced on &amp;D"/>
          </x:PageSetup>
          <x:FitToPage/>
          <x:Print>
            <x:Scale>50</x:Scale>
            <x:FitHeight>100</x:FitHeight>
            <x:LeftToRight/>
            <x:ValidPrinterInfo/>
            <x:HorizontalResolution>600</x:HorizontalResolution>
            <x:VerticalResolution>600</x:VerticalResolution>
          </x:Print>
          <x:Zoom>
            <xsl:value-of select="$ZOOM"/>
          </x:Zoom>
          <x:DoNotDisplayGridlines/>
          <x:ProtectObjects>False</x:ProtectObjects>
          <x:ProtectScenarios>False</x:ProtectScenarios>
          <x:FreezePanes/>
          <x:FrozenNoSplit/>
          <x:SplitHorizontal>1</x:SplitHorizontal>
          <x:TopRowBottomPane>1</x:TopRowBottomPane>
          <x:SplitVertical>1</x:SplitVertical>
          <x:LeftColumnRightPane>1</x:LeftColumnRightPane>
          <x:ActivePane>0</x:ActivePane>
        </x:WorksheetOptions>

        <xsl:variable name="DEAL_TABLE_ROWS" select="count($DEAL_DATA)+1"/>
        <xsl:if test ="$AUTO_FILTER = 1 and $DEAL_TABLE_ROWS > 1">
          <ss:Names>
            <ss:NamedRange ss:Name="_FilterDatabase" ss:RefersTo="='Product Vehicle Deal'!R1C1:R{$DEAL_TABLE_ROWS}C9" ss:Hidden="1"/>
            <ss:NamedRange ss:Name="Print_Titles" ss:RefersTo="='Product Vehicle Deal'!R1"/>
          </ss:Names>
          <x:AutoFilter x:Range="R1C1:R{$DEAL_TABLE_ROWS}C9">
          </x:AutoFilter>
        </xsl:if>

        <xsl:call-template name="PRODUCT_VEHCILE_DEALS"/>
      </ss:Worksheet>

    </ss:Workbook>

  </xsl:template>

  <xsl:template name="PRODUCT_VEHCILE_DEALS">
    <ss:Table>
      <ss:Column ss:AutoFitWidth="0" ss:Width="300"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="250"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="80"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="90"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="90"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="90"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="90"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="90"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="70"/>

      <ss:Row ss:AutoFitHeight="1">
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM">
          <ss:Data ss:Type="String">[Product] Vehicle Name</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM">
          <ss:Data ss:Type="String">Deal Name</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Vintage Year</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Initial Commitment Date</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Current/Seller Commitment</ss:Data>
        </ss:Cell>

        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Charge Management Fees</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Management Fees End Date</ss:Data>
        </ss:Cell>

        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Status</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Status Date</ss:Data>
        </ss:Cell>
      </ss:Row>

      <xsl:for-each select="$PRODUCT_DATA">
        <xsl:variable name="PRODUCT_ROW" select="current()"/>
        <xsl:variable name="PRODUCT_ID" select="item[@id='ProductID']/@value"/>
        <xsl:variable name="VEHICLE_ID" select="item[@id='VehicleID']/@value"/>

        <xsl:for-each select="$DEAL_DATA[item[@id='ProductID']/@value[.=$PRODUCT_ID] and item[@id='VehicleID']/@value[.=$VEHICLE_ID]]">
          <ss:Row ss:AutoFitHeight="1">
            <ss:Cell ss:StyleID="LABEL_LEFT">
              <ss:Data ss:Type="String">
                <xsl:value-of select="concat('[', $PRODUCT_ROW/item[@id='ProductShortName']/@value,'] - ', $PRODUCT_ROW/item[@id='VehicleName']/@value)" />
              </ss:Data>
            </ss:Cell>
            <ss:Cell ss:StyleID="LABEL_LEFT">
              <xsl:if test="item[@id='StatusDateShort']/@value[.!='']">
                <xsl:attribute name="ss:StyleID">LABEL_RED</xsl:attribute>
              </xsl:if>
              <ss:Data ss:Type="String">
                <xsl:value-of select="item[@id='DealName']/@value" />
              </ss:Data>
            </ss:Cell>
            <ss:Cell ss:StyleID="LABEL_NUMBER_INTEGER_CENTER_SIMPLE">
              <xsl:call-template name="NOTIFY_FIELD">
                <xsl:with-param name="ITEM_VALUE" select="item[@id='DealVYLabel']/@value"/>
                <xsl:with-param name="ITEM_TYPE" select="'Number'"/>
                <xsl:with-param name="NOTIFY" select="item[@id='DealVYNotify']/@value"/>
              </xsl:call-template>
            </ss:Cell>
            <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
              <ss:Data ss:Type="String">
                <xsl:value-of select="item[@id='EffectiveDateShort']/@value" />
              </ss:Data>
            </ss:Cell>
            <ss:Cell ss:StyleID="LABEL_NUMBER_INTEGER">
              <ss:Data ss:Type="Number">
                <xsl:value-of select="item[@id='CmtmtAmount']/@value" />
              </ss:Data>
            </ss:Cell>
            <ss:Cell ss:StyleID="LABEL_CENTER">
              <xsl:call-template name="NOTIFY_FIELD">
                <xsl:with-param name="ITEM_VALUE" select="item[@id='MgmtFeeChargeLabel']/@value"/>
                <xsl:with-param name="NOTIFY" select="item[@id='MgmtFeeChargeNotify']/@value"/>
              </xsl:call-template>
            </ss:Cell>
            <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
              <xsl:call-template name="NOTIFY_FIELD">
                <xsl:with-param name="ITEM_VALUE" select="item[@id='MgmtFeeEndDateShort']/@value"/>
                <xsl:with-param name="NOTIFY" select="item[@id='MgmtFeeEndDateNotify']/@value"/>
              </xsl:call-template>
            </ss:Cell>
            <ss:Cell ss:StyleID="LABEL_CENTER">
              <ss:Data ss:Type="String">
                <xsl:value-of select="item[@id='StatusName']/@value" />
              </ss:Data>
            </ss:Cell>
            <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
              <ss:Data ss:Type="String">
                <xsl:value-of select="item[@id='StatusDateShort']/@value" />
              </ss:Data>
            </ss:Cell>
          </ss:Row>
        </xsl:for-each>
      </xsl:for-each>

    </ss:Table>

  </xsl:template>

  <xsl:template name="PRODUCT_VEHCILE">
    <ss:Table>
      <ss:Column ss:AutoFitWidth="0" ss:Width="300"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="60"/>

      <ss:Column ss:AutoFitWidth="0" ss:Width="70"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="70"/>

      <ss:Column ss:AutoFitWidth="0" ss:Width="70"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="150"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="150"/>

      <ss:Column ss:AutoFitWidth="0" ss:Width="100"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="100"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="100"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="100"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="100"/>

      <ss:Column ss:AutoFitWidth="0" ss:Width="50"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="90"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="70"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="90"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="100"/>

      <ss:Column ss:AutoFitWidth="0" ss:Width="50"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="80"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="60"/>

      <ss:Row ss:Height="18">
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM_NBB"/>
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM_NBB"/>
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM_NBB" ss:MergeAcross="1"/>
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM_NBB" ss:MergeAcross="2"/>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM" ss:MergeAcross="4">
          <ss:Data ss:Type="String">Programs Management Fee reduced to percentage of :</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM_NBB" ss:MergeAcross="4"/>
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM_NBB" ss:MergeAcross="2"/>
      </ss:Row>

      <ss:Row ss:Height="18">
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM"/>
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM"/>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM" ss:MergeAcross="1">
          <ss:Data ss:Type="String">Initial Closing Date</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM" ss:MergeAcross="2">
          <ss:Data ss:Type="String">Vehicle</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">
            <xsl:value-of select="$HEAD/item[@id='ReportDateShort']/@value"/>
          </ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">25%</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">50%</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">75%</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">100%</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM" ss:MergeAcross="4">
          <ss:Data ss:Type="String">Progam Management Fees</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM" ss:MergeAcross="2">
          <ss:Data ss:Type="String">Deal</ss:Data>
        </ss:Cell>
      </ss:Row>

      <ss:Row ss:AutoFitHeight="1">
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM">
          <ss:Data ss:Type="String">[Product] Vehicle Name</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Currency</ss:Data>
        </ss:Cell>

        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Product</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Vehicle</ss:Data>
        </ss:Cell>

        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Vintage Year</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM">
          <ss:Data ss:Type="String">Sector Focus</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_LEFT_BOTTOM">
          <ss:Data ss:Type="String">Strategy</ss:Data>
        </ss:Cell>

        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Years Since Closing Date</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Fee Reduction</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Fee Reduction</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Fee Reduction</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Shut-Off</ss:Data>
        </ss:Cell>

        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Charging</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">End Date</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Termination Prong</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Termination per GCM Policy</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">In Advance/Arrears</ss:Data>
        </ss:Cell>

        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">All Count</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Done Chraging Count</ss:Data>
        </ss:Cell>
        <ss:Cell ss:StyleID="HEADER_CENTER_BOTTOM">
          <ss:Data ss:Type="String">Done Charging %</ss:Data>
        </ss:Cell>
      </ss:Row>

      <xsl:for-each select="$PRODUCT_DATA">
        <ss:Row ss:AutoFitHeight="1">
          <ss:Cell ss:StyleID="LABEL_LEFT">
            <ss:Data ss:Type="String">
              <xsl:value-of select="concat('[', item[@id='ProductShortName']/@value,'] - ', item[@id='VehicleName']/@value)" />
            </ss:Data>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_CENTER">
            <ss:Data ss:Type="String">
              <xsl:value-of select="item[@id='ProductCurrencyID']/@value"/>
            </ss:Data>
          </ss:Cell>

          <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
            <xsl:call-template name="NOTIFY_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='ProductInitClDateShort']/@value"/>
              <xsl:with-param name="NOTIFY" select="item[@id='ProductInitClDateNotify']/@value"/>
            </xsl:call-template>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
            <xsl:call-template name="NOTIFY_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='VehicleInitClDateShort']/@value"/>
              <xsl:with-param name="NOTIFY" select="item[@id='VehicleInitClDateNotify']/@value"/>
            </xsl:call-template>
          </ss:Cell>

          <ss:Cell ss:StyleID="LABEL_NUMBER_INTEGER_CENTER_SIMPLE">
            <xsl:call-template name="NOTIFY_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='VehicleVYLabel']/@value"/>
              <xsl:with-param name="ITEM_TYPE" select="'Number'"/>
              <xsl:with-param name="NOTIFY" select="item[@id='VehicleVYNotify']/@value"/>
            </xsl:call-template>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_LEFT">
            <xsl:call-template name="NOTIFY_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='MandateNameLabel']/@value"/>
              <xsl:with-param name="NOTIFY" select="item[@id='MandateNameNotify']/@value"/>
              <xsl:with-param name="NOTIFY_CLASS" select="'LABEL_NOTIFY_LEFT'"/>
            </xsl:call-template>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_LEFT">
            <xsl:call-template name="NOTIFY_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='StrategyNameLabel']/@value"/>
              <xsl:with-param name="NOTIFY" select="item[@id='StrategyNameNotify']/@value"/>
              <xsl:with-param name="NOTIFY_CLASS" select="'LABEL_NOTIFY_LEFT'"/>
            </xsl:call-template>
          </ss:Cell>

          <ss:Cell ss:StyleID="LABEL_NUMBER_DECIMAL_SHORT_CENTER">
            <xsl:call-template name="NOTIFY_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='YSCDLabel']/@value"/>
              <xsl:with-param name="ITEM_TYPE" select="'Number'"/>
              <xsl:with-param name="NOTIFY" select="item[@id='YSCDNotify']/@value"/>
            </xsl:call-template>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
            <xsl:call-template name="REDUCTION_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='FeeReduction25Label']/@value"/>
              <xsl:with-param name="CLASS_CODE" select="item[@id='FeeReduction25ClassCode']/@value"/>
            </xsl:call-template>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
            <xsl:call-template name="REDUCTION_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='FeeReduction50Label']/@value"/>
              <xsl:with-param name="CLASS_CODE" select="item[@id='FeeReduction50ClassCode']/@value"/>
            </xsl:call-template>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
            <xsl:call-template name="REDUCTION_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='FeeReduction75Label']/@value"/>
              <xsl:with-param name="CLASS_CODE" select="item[@id='FeeReduction75ClassCode']/@value"/>
            </xsl:call-template>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
            <xsl:call-template name="REDUCTION_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='FeeReduction100Label']/@value"/>
              <xsl:with-param name="CLASS_CODE" select="item[@id='FeeReduction100ClassCode']/@value"/>
            </xsl:call-template>
          </ss:Cell>

          <ss:Cell ss:StyleID="LABEL_CENTER">
            <xsl:call-template name="NOTIFY_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='MgmtFeeChargeLabel']/@value"/>
              <xsl:with-param name="NOTIFY" select="item[@id='MgmtFeeChargeNotify']/@value"/>
            </xsl:call-template>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_DATE_SHORT">
            <xsl:call-template name="NOTIFY_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='MgmtFeeEndDateLabel']/@value"/>
              <xsl:with-param name="NOTIFY" select="item[@id='MgmtFeeEndDateNotify']/@value"/>
            </xsl:call-template>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_CENTER">
            <ss:Data ss:Type="String">
              <xsl:value-of select="item[@id='MgmtFeeTermProng']/@value"/>
            </ss:Data>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_CENTER">
            <ss:Data ss:Type="String">
              <xsl:value-of select="item[@id='MgmtFeeTermGCMPolicy']/@value"/>
            </ss:Data>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_CENTER">
            <ss:Data ss:Type="String">
              <xsl:value-of select="item[@id='AdvanceArrears']/@value"/>
            </ss:Data>
          </ss:Cell>

          <ss:Cell ss:StyleID="LABEL_CENTER">
            <ss:Data ss:Type="Number">
              <xsl:value-of select="item[@id='DealCount']/@value"/>
            </ss:Data>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_CENTER">
            <ss:Data ss:Type="Number">
              <xsl:value-of select="item[@id='DealCMFCountN']/@value"/>
            </ss:Data>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_NUMBER_DECIMAL_SHORT_CENTER">
            <xsl:call-template name="NOTIFY_FIELD">
              <xsl:with-param name="ITEM_VALUE" select="item[@id='DealCMFPctLabel']/@value"/>
              <xsl:with-param name="ITEM_TYPE" select="'Number'"/>
              <xsl:with-param name="NOTIFY" select="item[@id='DealCMFPctNotify']/@value"/>
            </xsl:call-template>
          </ss:Cell>

        </ss:Row>
      </xsl:for-each>

    </ss:Table>
  </xsl:template>

  <xsl:template name="REDUCTION_FIELD">
    <xsl:param name="ITEM_VALUE"/>
    <xsl:param name="CLASS_CODE"/>

    <xsl:attribute name="ss:StyleID">
      <xsl:choose>
        <xsl:when test="$CLASS_CODE[.=0]">REDUCTION_FEE_0</xsl:when>
        <xsl:when test="$CLASS_CODE[.=1]">REDUCTION_FEE_1</xsl:when>
        <xsl:when test="$CLASS_CODE[.=2]">REDUCTION_FEE_2</xsl:when>
        <xsl:when test="$CLASS_CODE[.=3]">REDUCTION_FEE_3</xsl:when>
      </xsl:choose>
    </xsl:attribute>
    <ss:Data ss:Type="String">
      <xsl:value-of select="$ITEM_VALUE" />
    </ss:Data>
  </xsl:template>

  <xsl:template name="NOTIFY_FIELD">
    <xsl:param name="ITEM_VALUE"/>
    <xsl:param name="ITEM_TYPE"/>
    <xsl:param name="NOTIFY"/>
    <xsl:param name="NOTIFY_CLASS"/>

    <xsl:if test="$NOTIFY[.=1]">
      <xsl:attribute name="ss:StyleID">
        <xsl:choose>
          <xsl:when test="$NOTIFY_CLASS != ''">
            <xsl:value-of select="$NOTIFY_CLASS"/>
          </xsl:when>
          <xsl:otherwise>LABEL_NOTIFY</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <ss:Data ss:Type="String">
      <xsl:if test="$ITEM_TYPE!='' and $NOTIFY[.!=1]">
        <xsl:attribute name="ss:Type">
          <xsl:value-of select="$ITEM_TYPE"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$ITEM_VALUE" />
    </ss:Data>
  </xsl:template>

  <xsl:template name="REPORT_HEADER">
    <ss:Table>
      <ss:Column ss:AutoFitWidth="0" ss:Width="150"/>
      <ss:Column ss:AutoFitWidth="0" ss:Width="550"/>

      <xsl:call-template name="HEADER_ITEM">
        <xsl:with-param name="REPORT_TITLE" select="'Management Fees Tracking'"/>
        <xsl:with-param name="COLSPAN"      select="1"/>
      </xsl:call-template>
      <xsl:call-template name="FILTER_DATA_ROW">
        <xsl:with-param name="ITEM_LABEL" select="'Report Date'"/>
        <xsl:with-param name="ITEM_VALUE" select="$HEAD/item[@id='ReportDateShort']/@value"/>
        <xsl:with-param name="ITEM_CLASS" select="'LABEL_DATE_LEFT_TOP'"/>
      </xsl:call-template>
      <xsl:call-template name="FILTER_DATA_ROW">
        <xsl:with-param name="ITEM_LABEL" select="'Product Group'"/>
        <xsl:with-param name="ITEM_VALUE" select="$HEAD/item[@id='ProductGroupName']/@value"/>
        <xsl:with-param name="ITEM_CLASS" select="'LABEL_LEFT_TOP'"/>
      </xsl:call-template>
      <xsl:call-template name="FILTER_DATA_ROW">
        <xsl:with-param name="ITEM_LABEL" select="'Product'"/>
        <xsl:with-param name="ITEM_VALUE" select="//root/@ProductName"/>
        <xsl:with-param name="ROW_AUTOFIT" select="1"/>
        <xsl:with-param name="ITEM_CLASS" select="'LABEL_LEFT_TOP'"/>
      </xsl:call-template>
      <xsl:call-template name="FILTER_DATA_ROW">
        <xsl:with-param name="ITEM_LABEL" select="'Vehicle'"/>
        <xsl:with-param name="ITEM_VALUE" select="//root/@VehicleName"/>
        <xsl:with-param name="ROW_AUTOFIT" select="1"/>
        <xsl:with-param name="ITEM_CLASS" select="'LABEL_LEFT_TOP'"/>
      </xsl:call-template>
      <xsl:call-template name="FILTER_DATA_ROW">
        <xsl:with-param name="ITEM_LABEL" select="'Vintage Year'"/>
        <xsl:with-param name="ITEM_VALUE" select="//root/@VintageYearName"/>
        <xsl:with-param name="ROW_AUTOFIT" select="1"/>
        <xsl:with-param name="ITEM_CLASS" select="'LABEL_LEFT_TOP'"/>
      </xsl:call-template>
      <xsl:call-template name="FILTER_DATA_ROW">
        <xsl:with-param name="ITEM_LABEL" select="'Strtegy'"/>
        <xsl:with-param name="ITEM_VALUE" select="//root/@StrategyName"/>
        <xsl:with-param name="ROW_AUTOFIT" select="1"/>
        <xsl:with-param name="ITEM_CLASS" select="'LABEL_LEFT_TOP'"/>
      </xsl:call-template>
      <xsl:call-template name="FILTER_DATA_ROW">
        <xsl:with-param name="ITEM_LABEL" select="'SPV'"/>
        <xsl:with-param name="ITEM_VALUE" select="//root/@SPV"/>
        <xsl:with-param name="ITEM_CLASS" select="'LABEL_LEFT_TOP'"/>
      </xsl:call-template>


      <ss:Row ss:Height="18">
        <ss:Cell ss:MergeAcross="1">
          <ss:Data ss:Type="String"/>
        </ss:Cell>
      </ss:Row>

      <ss:Row ss:Height="18">
        <ss:Cell>
          <ss:Data ss:Type="String"/>
        </ss:Cell>
        <ss:Cell ss:StyleID="LABEL_ACTIVE_LEFT_TOP">
          <ss:Data ss:Type="String">Strategy notes:</ss:Data>
        </ss:Cell>
      </ss:Row>
      <xsl:for-each select="$CALC_NOTES">
        <ss:Row ss:Height="18">
          <ss:Cell>
            <ss:Data ss:Type="String"/>
          </ss:Cell>
          <ss:Cell ss:StyleID="LABEL_LEFT_TOP">
            <ss:Data ss:Type="String">
              <xsl:value-of select="concat(item[@id='NoteLabel']/@value,' - ',item[@id='NoteText']/@value)"/>
            </ss:Data>
          </ss:Cell>
        </ss:Row>
      </xsl:for-each>

    </ss:Table>
  </xsl:template>

  <xsl:template name="HEADER_ITEM">
    <xsl:param name="REPORT_TITLE"/>
    <xsl:param name="COLSPAN"/>

    <ss:Row ss:Height="30">
      <ss:Cell ss:StyleID="REPORT_MAIN_TITLE" ss:MergeAcross="{number($COLSPAN)}">
        <ss:Data ss:Type="String">
          <xsl:value-of select="$REPORT_TITLE"/>
        </ss:Data>
      </ss:Cell>
    </ss:Row>
    <ss:Row>
      <ss:Cell ss:MergeAcross="{number($COLSPAN)}">
        <ss:Data ss:Type="String"/>
      </ss:Cell>
    </ss:Row>
  </xsl:template>

  <xsl:template name="FILTER_DATA_ROW">
    <xsl:param name="ITEM_LABEL"/>
    <xsl:param name="ITEM_VALUE"/>
    <xsl:param name="ITEM_CLASS"/>
    <xsl:param name="ITEM_DEFAULT"/>
    <xsl:param name="ROW_AUTOFIT"/>
    <ss:Row>
      <xsl:choose>
        <xsl:when test="$ROW_AUTOFIT = 1">
          <xsl:attribute name="ss:AutoFitHeight">1</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="ss:Height">18</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <ss:Cell ss:StyleID="LABEL_ACTIVE_LEFT_TOP">
        <ss:Data ss:Type="String">
          <xsl:value-of  select="$ITEM_LABEL"/>:
        </ss:Data>
      </ss:Cell>
      <ss:Cell ss:StyleID="{$ITEM_CLASS}">
        <xsl:choose>
          <xsl:when test="$ITEM_VALUE != '' and ($ITEM_LABEL = '?NUMBER')">
            <ss:Data ss:Type="Number">
              <xsl:value-of  select="$ITEM_VALUE"/>
            </ss:Data>
          </xsl:when>
          <xsl:when test="$ITEM_LABEL = 'FOF' or $ITEM_LABEL = 'SPV'">
            <ss:Data ss:Type="String">
              <xsl:choose>
                <xsl:when test="$ITEM_VALUE = 'Y'">Yes</xsl:when>
                <xsl:otherwise>No</xsl:otherwise>
              </xsl:choose>
            </ss:Data>
          </xsl:when>
          <xsl:when test="$ITEM_VALUE != ''">
            <ss:Data ss:Type="String">
              <xsl:value-of  select="$ITEM_VALUE"/>
            </ss:Data>
          </xsl:when>
          <xsl:otherwise>
            <ss:Data ss:Type="String">
              <xsl:value-of  select="$ITEM_DEFAULT"/>
            </ss:Data>
          </xsl:otherwise>
        </xsl:choose>
      </ss:Cell>
    </ss:Row>
  </xsl:template>

</xsl:stylesheet>