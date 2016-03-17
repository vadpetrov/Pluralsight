<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:msxsl="urn:schemas-microsoft-com:xslt"	xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">
  <xsl:output omit-xml-declaration="yes" method="html" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:decimal-format name="nanFormat" NaN="0"/>
  
  <xsl:variable name="DATA"       select="//root/table[@id='deal_list']/row"/>
  <xsl:variable name="COLSPAN"    select="17"/>
  <xsl:variable name="TOP_ROWS"   select="3"/>

  <xsl:template match="/">
    <html>
      <head>
        <style>
          <xsl:comment>
            <![CDATA[            
		            @page
		            {
			            margin:1.0in .75in 1.0in .75in;
			            mso-header-margin:.5in;
			            mso-footer-margin:.5in;
			            mso-footer-data:"&CPage &P of &N&RProduced on &D";
                  mso-page-orientation:landscape;
			            mso-horizontal-page-align:center;
			            mso-vertical-page-align:top;
		            }            
                .LABELACTIVE
                {
			            font-size:xx-small;
			            font-family:Verdana, Arial;
			            font-weight:bolder;	
                  text-align:left;
                  vertical-align:top;                  
                }      
                .LABEL_DATE
	              {
	                font-size:xx-small;
      				    font-family:Verdana, Arial; 	                
	                mso-number-format:"\[ENG\]\[$-409\]mmm\\ d\\\,\\ yyyy\;\@";
                  text-align:center;
                  vertical-align:top;                                             
	              }                   
                .LABEL
                {
		              font-size:xx-small;
		              font-family:Verdana, Arial; 
                  text-align:left;
                  vertical-align:top;
                }                                  
		            .HEADER
		            {
			            background:gainsboro;
			            font-size: xx-small;
			            font-weight:bolder;
			            border:.5pt solid windowtext;
			            padding-left:4px;
			            padding-right:4px;
                  text-align:left;
                  vertical-align:middle;
                  white-space:nowrap;
		            }                
            ]]>
          </xsl:comment>
        </style>
        <xml>
          <x:ExcelWorkbook>
            <x:ExcelWorksheets>
              <x:ExcelWorksheet>
                <x:Name>DealReference</x:Name>
                <x:WorksheetOptions>
                  <x:FitToPage/>
                  <x:Print>
                    <x:FitWidth>1</x:FitWidth>
                    <x:FitHeight>250</x:FitHeight>
                    <x:ValidPrinterInfo/>
                    <x:LeftToRight/>
                    <x:PaperSizeIndex>0</x:PaperSizeIndex>
                    <x:Scale>75</x:Scale>
                    <x:HorizontalResolution>600</x:HorizontalResolution>
                    <x:VerticalResolution>600</x:VerticalResolution>
                  </x:Print>
                  <x:Zoom>80</x:Zoom>
                  <x:SplitHorizontal>
                    <xsl:value-of select ="number($TOP_ROWS)"/>
                  </x:SplitHorizontal>
                  <x:TopRowBottomPane>
                    <xsl:value-of select ="number($TOP_ROWS)"/>
                  </x:TopRowBottomPane>
                  <x:SplitVertical>1</x:SplitVertical>
                  <x:LeftColumnRightPane>1</x:LeftColumnRightPane>
                  <x:ActivePane>0</x:ActivePane>
                  <x:DoNotDisplayGridlines/>
                  <x:Selected/>
                  <x:FreezePanes/>
                  <x:FrozenNoSplit/>
                </x:WorksheetOptions>
              </x:ExcelWorksheet>
            </x:ExcelWorksheets>
          </x:ExcelWorkbook>
          <x:ExcelName>
            <x:Name>Print_Titles</x:Name>
            <x:SheetIndex>1</x:SheetIndex>
            <x:Formula>='DealReference'!$<xsl:value-of select="number($TOP_ROWS)"/>:$<xsl:value-of select="number($TOP_ROWS)"/></x:Formula>
          </x:ExcelName>
        </xml>
      </head>
      <body>
        <table border="0" width="100%" style="border-collapse:collapse;table-layout:fixed;">
          <xsl:call-template name="REPORT_COLUMNS"/>
          <xsl:call-template name="REPORT_HEADER"/>
          <xsl:call-template name="REPORT_DATA"/>
        </table>
      </body>
    </html>
  </xsl:template>
  
  
  <xsl:template name="REPORT_DATA">
    <tr>
      <td class="HEADER">Deal Name</td>
      <td class="HEADER">Deal Short Name</td>
      <td class="HEADER" style="text-align:center;">Direct / Fund</td>
      <td class="HEADER" style="text-align:center;">Final Closing Date</td>
      <td class="HEADER" style="text-align:center;">Currency</td>
      <td class="HEADER" style="text-align:center;">Industry</td>
      <td class="HEADER" style="text-align:center;">Geography</td>
      <td class="HEADER" style="text-align:center;">Domicile</td>
      <!--New Columns-->
      <td class="HEADER">Fund Administrator</td>
      <td class="HEADER">General Partner</td>
      <td class="HEADER">Auditor</td>
      <!--End of New Columns-->
      <td class="HEADER" style="text-align:center;">Investment Type</td>
      <td class="HEADER" style="text-align:center;">Vintage Year</td>
      <td class="HEADER" style="text-align:center;">Investran ID</td>
      <td class="HEADER">Deal Ownership</td>
      <td class="HEADER">AS Product</td>
      <td class="HEADER" style="text-align:center;">Limited Info</td>
    </tr>
    <xsl:for-each select="$DATA">				  
      <tr>
        <td class="LABEL" style="padding-left:5px;">
          <xsl:value-of select="item[@id='DName']/@value" />
        </td>
        <td class="LABEL" style="padding-left:5px;">
          <xsl:value-of select="item[@id='DShortName']/@value"/>
        </td>          
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DDF']/@value"/>
        </td>
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DFCDate']/@value"/>
        </td>
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DCur']/@value"/>
        </td>
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DInd']/@value"/>
        </td>
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DLoc']/@value"/>
        </td>
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DDom']/@value"/>
        </td>
        <!--New Columns-->
        <td class="LABEL" style="padding-left:5px;">
          <xsl:value-of select="item[@id='DAdmin']/@value"/>
        </td>
        <td class="LABEL" style="padding-left:5px;">
          <xsl:value-of select="item[@id='DGenpartner']/@value"/>
        </td>
        <td class="LABEL" style="padding-left:5px;">
          <xsl:value-of select="item[@id='DAuditor']/@value"/>
        </td>
        <!--End of New Columns-->
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DInvType']/@value"/>
        </td>   
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DVintageYr']/@value"/>
        </td>
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DInvestranID']/@value"/>
        </td>
        <td class="LABEL" style="padding-left:5px;">
          <xsl:value-of select="item[@id='DOwnership']/@value"/>
        </td>
        <td class="LABEL" style="padding-left:5px;">
          <xsl:value-of select="item[@id='ProductName']/@value"/>
        </td>
        <td class="LABEL" style="text-align:center;">
          <xsl:value-of select="item[@id='DLtdInfo']/@value"/>
        </td>         
      </tr>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="REPORT_HEADER">
    <tr>
      <td colspan="{$COLSPAN}" class="LABELACTIVE" style="height:30.0pt;font-size:10.0pt;vertical-align:middle;">
        Deal Reference
      </td>
    </tr> 
    <tr>
      <td colspan="{$COLSPAN}">
        <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template name="REPORT_COLUMNS">
    <col style="mso-width-source:userset;width:250px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
    <col style="mso-width-source:userset;width:100px;"/>      
    <col style="mso-width-source:userset;width:120px;"/>
    <col style="mso-width-source:userset;width:120px;"/>
    <col style="mso-width-source:userset;width:120px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
    <col style="mso-width-source:userset;width:110px;"/>    
    <col style="mso-width-source:userset;width:110px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
    <col style="mso-width-source:userset;width:150px;"/>
  </xsl:template>  
  
</xsl:stylesheet>