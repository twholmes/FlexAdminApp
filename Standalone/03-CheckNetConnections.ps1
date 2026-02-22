###########################################################################
# This PowerShell script checks IP and DNS adresses for network
# connectivity
#
# Copyright (C) 2020 Crayon
###########################################################################

param(
  [string]$target="localhost"  
  , [int]$port="80"
  , [switch]$DiagnoseRouting
  , [ValidateSet("Detailed", "Quiet")][string]$InformationLevel="Detailed"
)

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Key variables

$FlexAdminName = "CheckIIS"
$LogLevel = "info"

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
# TestNetConnections

function TestNetConnection([string]$ComputerName, [int32]$Port)
{
  Log "Running Test-NetConnection for Target $ComputerName on Port $Port"
  $result = Test-NetConnection -ComputerName $ComputerName -Port $Port -InformationLevel $InformationLevel
  $delay = $result.'PingReplyDetails'.Roundtriptime | % { ("$_" + " ms") }
  $IPAddress = ($result.SourceAddress).IPAddress  

  Log -Level "info"
  Log "ComputerName:      $($result.ComputerName)" -Level "info"
  Log "RemoteAddress:     $($result.RemoteAddress)" -Level "info"
  Log "RemotePort:        $($result.RemotePort)" -Level "info"
  Log "InterfaceAlias:    $($result.InterfaceAlias)" -Level "info" 
  Log "SourceAddress:     $IPAddress" -Level "info"     
  Log "PingSucceeded:     $($result.PingSucceeded)" -Level "info"
  Log "PingReplyDetails:  $delay" -Level "info"  
  Log "TcpTestSucceeded:  $($result.TcpTestSucceeded)" -Level "info"
  Log -Level "info"
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

  # what PowerShell version is installed?
  Log "What PowerShell version is installed?"   
  Log $PSVersionTable.PSVersion -Level "info"
  Log -Level "info"
  
  # Running Test-NetConnection for Target on named Port
  TestNetConnection -ComputerName $target -Port $port -InformationLevel $InformationLevel
  
  # Running Test-NetConnection for Target on Port 80
  TestNetConnection -ComputerName $target -Port 80 -InformationLevel $InformationLevel

  # Running Test-NetConnection for Target on Port 443
  TestNetConnection -ComputerName $target -Port 443 -InformationLevel $InformationLevel
}
catch 
{
  Log "Error checking Net-Connections: $_" -Level "Error"
}
finally 
{
  Write-Host
}

