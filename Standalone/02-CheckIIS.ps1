###########################################################################
# This PowerShell script checks IIS for FNMS pre-requisite components
#
# Copyright (C) 2020 Crayon
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Key variables

$FlexAdminName = "CheckIIS"
$LogLevel = "info"

$InstallMissingFeatures = "no"

###########################################################################
# Check IIS features for FNMS pre-requisites

function CheckIISFeatures
{
	Log "Checking IIS features for FlexNet pre-requisites"
	Import-Module ServerManager

	$features = (
		"Web-Server", "Web-WebServer",

		# Common HTTP Features
		"Web-Common-Http", "Web-Static-Content", "Web-Default-Doc",
		"Web-Dir-Browsing", "Web-Http-Errors",

		# Application Development
		"Web-App-Dev", "Web-CGI", "Web-ISAPI-Ext", "Web-ISAPI-Filter",

		# Health and Diagnostics
		"Web-Health", "Web-Http-Logging",

		# Security
		"Web-Security", "Web-Basic-Auth", "Web-Windows-Auth",

		# Performance
		"Web-Performance", "Web-Stat-Compression", "Web-Dyn-Compression",

		# Management Tools
		"Web-Mgmt-Tools", "Web-Mgmt-Console"
	)

	if (Get-WindowsFeature Web-Asp-Net45) { 
		$features += (
			"Web-Asp-Net45", "Web-Net-Ext45"
		)
	} elseif (Get-WindowsFeature Web-Asp-Net) {
		$features += (
			"Web-Asp-Net", "Web-Net-Ext"
		)
	}
  Log
  
  # Get the installed features list
  $winfeatures = Get-WindowsFeature $features
  $winfeatures |
  % {
    $f = "[{0}] {1,-72} {2,-50} {3}"  
    if ($_.Depth -eq 1) { $f = "[{0}] {1,-72} {2,-50} {3}" }
    if ($_.Depth -eq 2) { $f = "    [{0}] {1,-68} {2,-50} {3}" }
    if ($_.Depth -eq 3) { $f = "        [{0}] {1,-64} {2,-50} {3}" }
    if ($_.Depth -eq 4) { $f = "            [{0}] {1,-60} {2,-50} {3}" }    
    $x = " "
    if ($_.InstallState -eq "Installed") { $x = "x" }
    Log $([string]::Format($f, $x, $_.DisplayName, $_.Name, $_.InstallState)) -Level "info"
  }   
  Log

	Log "Done checking IIS feature configuration"
	return $true
}


###########################################################################
# Configure IIS features for Beacon

function ConfigureIISFeatures
{
	Log "Configuring IIS features for FlexNet"

	Import-Module ServerManager

	$restartNeeded = $false
	$features = (
		"Web-Server", "Web-WebServer",

		# Common HTTP Features
		"Web-Common-Http", "Web-Static-Content", "Web-Default-Doc",
		"Web-Dir-Browsing", "Web-Http-Errors",

		# Application Development
		"Web-App-Dev", "Web-CGI", "Web-ISAPI-Ext", "Web-ISAPI-Filter",

		# Health and Diagnostics
		"Web-Health", "Web-Http-Logging",

		# Security
		"Web-Security", "Web-Basic-Auth", "Web-Windows-Auth",

		# Performance
		"Web-Performance", "Web-Stat-Compression", "Web-Dyn-Compression",

		# Management Tools
		"Web-Mgmt-Tools", "Web-Mgmt-Console"
	)

	if (Get-WindowsFeature Web-Asp-Net45) { 
		$features += (
			"Web-Asp-Net45", "Web-Net-Ext45"
		)
	} elseif (Get-WindowsFeature Web-Asp-Net) {
		$features += (
			"Web-Asp-Net", "Web-Net-Ext"
		)
	}

	Log ""
	Log "Adding Windows features:"
	$features | %{ Log "`t$_" }

	$result = Add-WindowsFeature $features
	if (!$result.Success) {
		Log "ERROR: Failed to configure IIS features" -level Error
		return $false
	}

	$restartNeeded = $restartNeeded -or $result.RestartNeeded

	$result = Remove-WindowsFeature Web-DAV-Publishing
	$restartNeeded = $restartNeeded -or $result.RestartNeeded

	if ($restartNeeded) {
		Log "WARNING: System restart may be needed to complete configuration of IIS features" -level Warning
	}

	Log "Done IIS feature configuration"
	return $true
}


############################################################
# Set the name of the log file to write logging to

function SetLogFile([string]$logFile)
{
  $previousLog = GetLogFile

  Log "Further logging from this session will be written to $logFile"

  [System.Diagnostics.Debug]::Listeners |
  ? { $_.Name -eq "Default" } |
  % { $_.LogFileName = $logFile }

  $msg = "{0} {1}" -f (Get-Date -format "yyyy-MM-dd HH:mm:ss"), "This is $FlexAdminName"
  [System.Diagnostics.Debug]::WriteLine($msg)

  $msg = "{0} {1}" -f (Get-Date -format "yyyy-MM-dd HH:mm:ss"), ("Computer: " + [System.Net.Dns]::GetHostName())
  [System.Diagnostics.Debug]::WriteLine($msg)

  $msg = "{0} {1}" -f (Get-Date -format "yyyy-MM-dd HH:mm:ss"), ("User: " + [System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
  [System.Diagnostics.Debug]::WriteLine($msg)

  if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $hasLocalAdminRights = "YES"
  } else {
    $hasLocalAdminRights = "NO"
    Write-Warning "$FlexAdminName script is running without local administrator rights"
  }
  $msg = "{0} {1}" -f (Get-Date -format "yyyy-MM-dd HH:mm:ss"), "Running with local administrator rights? $hasLocalAdminRights"
  [System.Diagnostics.Debug]::WriteLine($msg)

  [System.Diagnostics.Debug]::WriteLine("")
  
  if ($previousLog) {
    Log "Previous logging from this session can be found in $previousLog"
    Log ""
  }
}


############################################################
# Get the name of the log file

function GetLogFile
{
  [System.Diagnostics.Debug]::Listeners |
  ? { $_.Name -eq "Default" } |
  % { return $_.LogFileName }
}


###########################################################################
# Write a log message

$global:ErrorLogMessages = @()

function Log([Parameter(ValueFromPipeline=$true)][string]$msg, [switch]$noHost, [ValidateSet("Default", "Error", "Warning", "Info", "Debug")][string]$level="Default")
{
  if ($level -eq "Error") {
    $global:ErrorLogMessages += $msg
  }

  if (($level -eq "Error" -and $GlobalLogLevel -lt 0) -or
    ($level -eq "Warning" -and $GlobalLogLevel -lt 1) -or
    ($level -eq "Info" -and $GlobalLogLevel -lt 2) -or
    ($level -eq "Debug" -and $GlobalLogLevel -lt 3)
  ) {
    return
  }

  if (!$noHost) {
    if ($level -eq "Error") {
      Write-Host -ForegroundColor Red $msg
    } elseif ($level -eq "Warning") {
      Write-Host -ForegroundColor Yellow $msg
    } elseif ($level -eq "Info") {
      Write-Host -ForegroundColor White $msg
    } elseif ($level -eq "Default") {
      Write-Host -ForegroundColor Green $msg
    } else {
      Write-Host $msg
    }
  }

  $msg = "{0} [{2,-7}] {1}" -f (Get-Date -format "yyyy-MM-dd HH:mm:ss"), $msg, $level
  [System.Diagnostics.Debug]::WriteLine($msg)
}

###########################################################################
# Initialise logging

function InitialiseLogging([string]$logDirectory, [string]$logFileNamePrefix)
{
  Write-Host "Initialising logging to $logDirectory"
  if (!(Test-Path $logDirectory -PathType Container)) {
    New-Item $logDirectory -type Directory | Out-Null
  }

  $logFileName = "{0}_{1}.log" -f $logFileNamePrefix, (Get-Date -format "yyyyMMdd_HHmmss")
  SetLogFile (Join-Path $logDirectory $logFileName)
}


###########################################################################
# Mainline

switch ($LogLevel) {
  "Error" { $GlobalLogLevel = 0 }
  "Warning" { $GlobalLogLevel = 1 }
  "Info" { $GlobalLogLevel = 2 }
  "Debug" { $GlobalLogLevel = 3 }
}

try 
{
  # initialise for logging to file
  InitialiseLogging $ScriptPath $FlexAdminName

  # load the certificates using the following parameters
  CheckIISFeatures
  Write-Host

  # (optionally) install missing features
  if ($InstallMissingFeatures -eq "yes") {
    ConfigureIISFeatures
  }

  Write-Host
}
catch 
{
  Write-Host "Error checking for IIS feature pre-repuisites: $_"
}
finally 
{
  Write-Host
}

