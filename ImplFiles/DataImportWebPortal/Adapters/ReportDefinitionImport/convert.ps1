###########################################################################
# Copyright (C) 2019 Crayon Australia
###########################################################################

param (
  [string]$filename = "ReportsView"
)

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Function: Reformat messy XML

function FormatXML ($xmlcontent, $indent=2)
{
  #$xmlcontent = variable which holds xml data in string
  $xml = "<?xml version=`"1.0`" encoding=`"utf-8`"?>" + $xmlcontent
  $xmldoc = New-Object -TypeName System.Xml.XmlDocument
  $xmldoc.LoadXml($xml)  
  
  $StringWriter = New-Object System.IO.StringWriter
  $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
  $xmlWriter.Formatting = "indented"
  $xmlWriter.Indentation = $Indent
  $xmldoc.WriteContentTo($XmlWriter)
  $XmlWriter.Flush()
  $StringWriter.Flush()
  
  return $StringWriter.ToString().Replace("<?xml version=`"1.0`" encoding=`"utf-8`"?>`r`n","")
}

###########################################################################
# Function: Write the XML output report header

function WriteReportHeader($filepath, $report)
{  
  $id = $($report.ComplianceSavedSearchID)
  $rid = $id.Replace(",","")
  $name = $($report.SearchName)
  $description = $($report.Description)  
  $createdate = $($report.CreationDate) 
  $searchtype = $($report.ComplianceSearchType) 
  $searchfolderid = $($report.ComplianceSearchFolderID)
  $folderid = $searchfolderid.Replace(",","")
  $foldername = $($report.FolderName)
  $fullfoldername = $($report.FullFolderName).Replace("Reports/","")  
  $operatorid = $($report.CreatedByOperatorID) 
  $accesstypeid = $($report.RestrictedAccessTypeID) 
  $candelete = $($report.CanDelete)              

  Write-host $id $name
  "  <Report ID=`"$rid`" SearchName=`"$name`" ComplianceSearchType=`"$searchtype`" ComplianceSearchFolderID=`"$folderid`" CreatedByOperatorID=`"$operatorid`" RestrictedAccessTypeID=`"$accesstypeid`" CanDelete=`"$candelete`">" | Out-File -FilePath $filepath -Append
  "    <Description>$description</Description>" | Out-File -FilePath $filepath -Append
  "    <FolderName>$foldername</FolderName>" | Out-File -FilePath $filepath -Append 
  "    <FolderPath>$fullfoldername</FolderPath>" | Out-File -FilePath $filepath -Append   
  "    <CreationDate>$createdate</CreationDate>" | Out-File -FilePath $filepath -Append
}

###########################################################################
# Function: Write the XML output for SearchSQL element

function WriteSearchSQL($filepath, $report, $includeEncoded=$false)
{  
  $esql = $($report.EncodedSearchSQL)
  $xsql = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($esql))
  if ($includeEncoded)
  {
    "    <EncodedSearchSQL>" | Out-File -FilePath $xmlfilepath -Append  
    $esql | Out-File -FilePath $xmlfilepath -Append   
    "    </EncodedSearchSQL>" | Out-File -FilePath $xmlfilepath -Append
  }
       
  "    <SearchSQL>" | Out-File -FilePath $xmlfilepath -Append  
  "      <![CDATA[" | Out-File -FilePath $xmlfilepath -Append    
  if ($xsql.trim().length -GT 0)
  {
    $xsql | Out-File -FilePath $xmlfilepath -Append   
  }
  "      ]]>" | Out-File -FilePath $xmlfilepath -Append   
  "    </SearchSQL>" | Out-File -FilePath $xmlfilepath -Append
}

###########################################################################
# Function: Write the XML output for SearchMapping element

function WriteSearchMapping($filepath, $report, $includeEncoded=$false)
{  
  $emapping = $($report.EncodedSearchMapping)
  $xmapping = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($emapping))
  if ($includeEncoded)
  {       
    "    <EncodedSearchMapping>" | Out-File -FilePath $xmlfilepath -Append  
    $emapping | Out-File -FilePath $xmlfilepath -Append   
    "    </EncodedSearchMapping>" | Out-File -FilePath $xmlfilepath -Append 
  }
     
  "    <SearchMapping>" | Out-File -FilePath $xmlfilepath -Append  
  "      <![CDATA[" | Out-File -FilePath $xmlfilepath -Append    
  if ($xmapping.trim().length -GT 0)
  {
    FormatXML $xmapping | Out-File -FilePath $xmlfilepath -Append   
  }
  "      ]]>" | Out-File -FilePath $xmlfilepath -Append   
  "    </SearchMapping>" | Out-File -FilePath $xmlfilepath -Append
}

###########################################################################
# Function: Write the XML output for SearchXML element

function WriteSearchXML($filepath, $report, $includeEncoded=$false)
{  
  $exml = $($report.EncodedSearchXML)    
  $xml = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($exml))      
  if ($includeEncoded)
  {
    "    <EncodedSearchXML>" | Out-File -FilePath $xmlfilepath -Append  
    $exml | Out-File -FilePath $xmlfilepath -Append   
    "    </EncodedSearchXML>" | Out-File -FilePath $xmlfilepath -Append 
  }

  "    <SearchXML>" | Out-File -FilePath $xmlfilepath -Append  
  "      <![CDATA[" | Out-File -FilePath $xmlfilepath -Append    
  if ($xml.trim().length -GT 0)
  {
    FormatXML $xml | Out-File -FilePath $xmlfilepath -Append
  }
  "      ]]>" | Out-File -FilePath $xmlfilepath -Append   
  "    </SearchXML>" | Out-File -FilePath $xmlfilepath -Append
}

###########################################################################
# Function: Write the XML output report tail

function WriteReportTail($filepath, $report)
{  
  # write xml tail-out
  "  </Report>" | Out-File -FilePath $xmlfilepath -Append
  "</CustomReports>" | Out-File -FilePath $xmlfilepath -Append
}

###########################################################################
# Mainline: Read in the Reports CSV and convert it to an XML format
#

$csvfilepath = Join-Path $ScriptPath ($filename + ".csv")
$includeEncoded = $false

#Clean up the header line on the CSV file
$tempfilepath = Join-Path $ScriptPath "temp.csv"
get-content $csvfilepath | select -First 1 | set-content -Encoding ASCII "$tempfilepath"
((get-content $tempfilepath).Replace("`"[","").Replace("]`"","").Replace("]`",`"[",",")) | set-content -Encoding ASCII "$tempfilepath"

get-content $csvfilepath | select -Skip 1 | add-content $tempfilepath -Encoding ASCII

#loop through reports
$reports = import-csv $tempfilepath
ForEach ($report in $reports)
{ 
  # get this report name
  $name = $($report.SearchName)
  $fname = $name.Replace("`\"," ").Replace("#"," ").Replace("*","Star").Replace(" ","")
  
  Write-Output $("Report: " + $name)
  if ($fname.length -GT 0)
  {
    $xmlfilepath = Join-Path $ScriptPath ($fname + ".xml")

    # write xml lead-in
    "<?xml version=`"1.0`" encoding=`"utf-8`"?>" | Out-File -FilePath $xmlfilepath
    "<CustomReports>" | Out-File -FilePath $xmlfilepath -Append

    WriteReportHeader $xmlfilepath $report
    WriteSearchSQL $xmlfilepath $report $includeEncoded
    WriteSearchMapping $xmlfilepath $report $includeEncoded
    WriteSearchXML $xmlfilepath $report $includeEncoded
    WriteReportTail $xmlfilepath $report

    # rewrite with ascii encodings
    $tempfilepath = Join-Path $ScriptPath "temp.xml"
    get-content $xmlfilepath | set-content -Encoding ASCII "$tempfilepath"
    move "$tempfilepath" $xmlfilepath -Force
  }
}

