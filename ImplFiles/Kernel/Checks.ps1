###########################################################################
# This PowerShell script can be used with flexadmin.ps1 to perform a number
# of system readiness checks prior ti installing FlexNet Manager components
#
# Copyright (C) 2020 Crayon
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Check IIS features for Beacon

function CheckIISFeaturesForBeacon
{
  Log "Checking IIS features for FlexNet Beacon"
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
  Write-Host
  
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
  Write-Host

  Log "Done checking IIS feature configuration"
  return $true
}


###########################################################################
# Configure IIS features for Beacon

function ConfigureIISFeaturesForBeacon
{
  Log "Configuring IIS features for FlexNet Beacon"

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
# CheckNetworkConnections

function CheckNetworkConnections
{
  Log "Checking FNMS network connectivity"
  $target = GetConfigValue "FlexeraServerFQDN"  
  
  try 
  {
    # what PowerShell version is installed?
    Log "What PowerShell version is installed?"   
    Log $PSVersionTable.PSVersion -Level "info"
    Log
  
    # test connections to the target computer 
    Log "Running Test-NetConnection for Target $target on Port 80" 
    Test-NetConnection -ComputerName $target -Port 80 
    Log
  
    Log "Running Test-NetConnection for Target $target on Port 443"  
    Test-NetConnection -ComputerName $target -Port 443 
    Log    
  }
  catch 
  {
    Log "Error performing net connection tests: $_" -Level "error"
  }
  finally 
  {
    Log
  }
  Log "Done checking FNMS network connectivity"
  
  return $true
}


###########################################################################
# Test-SQLDatabase

function Test-SQLDatabase 
{
  param
  ( 
    [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True)] [string] $Server,
    [Parameter(Position=1, Mandatory=$True)] [string] $Database,
    [Parameter(Position=2, Mandatory=$True, ParameterSetName="SQLAuth")] [string] $Username,
    [Parameter(Position=3, Mandatory=$True, ParameterSetName="SQLAuth")] [string] $Password,
    [Parameter(Position=2, Mandatory=$True, ParameterSetName="WindowsAuth")] [switch] $UseWindowsAuthentication
  )

  # connect to the database, then immediatly close the connection. If an exception occurrs it indicates the conneciton was not successful. 
  process 
  { 
    $dbConnection = New-Object System.Data.SqlClient.SqlConnection
    if (!$UseWindowsAuthentication) {
        $dbConnection.ConnectionString = "Data Source=$Server; uid=$Username; pwd=$Password; Database=$Database;Integrated Security=False"
        $authentication = "SQL ($Username)"
    }
    else {
        $dbConnection.ConnectionString = "Data Source=$Server; Database=$Database;Integrated Security=True;"
        $authentication = "Windows ($env:USERNAME)"
    }
    try {
        $connectionTime = measure-command {$dbConnection.Open()}
        $Result = @{
            Connection = "Successful"
            ElapsedTime = $connectionTime.TotalSeconds
            Server = $Server
            Database = $Database
            User = $authentication}
    }
    # exceptions will be raised if the database connection failed.
    catch {
            $Result = @{
            Connection = "Failed"
            ElapsedTime = $connectionTime.TotalSeconds
            Server = $Server
            Database = $Database
            User = $authentication}
    }
    Finally{
        # close the database connection
        $dbConnection.Close()
        #return the results as an object
        $outputObject = New-Object -Property $Result -TypeName psobject
        write-output $outputObject 
    }
  }
}

###########################################################################
# CheckDatabaseConnections

function CheckDatabaseConnections
{
  Log "Checking FNMS database connectivity"
  try 
  {    
    # test database connectivity
    Log "Running Test-SqlDatabase function to test connectivity to <master> on @FnmsDatabaseServer"    
    Test-SQLDatabase -Server @FnmsDatabaseServer -Database master -UseWindowsAuthentication
    
    # test database connectivity
    Log "Running Test-SqlDatabase function to test connectivity to FNMSCompliance on @FnmsDatabaseServer"    
    Test-SQLDatabase -Server @FnmsDatabaseServer -Database FNMSCompliance -UseWindowsAuthentication
    
    # test database connectivity
    Log "Running Test-SqlDatabase function to test connectivity to FNMSInventory on @FnmsDatabaseServer"    
    Test-SQLDatabase -Server @FnmsDatabaseServer -Database FNMSInventory -UseWindowsAuthentication
    
    # test database connectivity
    Log "Running Test-SqlDatabase function to test connectivity to FNMSDataWarehouse on @FnmsDatabaseServer"    
    Test-SQLDatabase -Server @FnmsDatabaseServer -Database FNMSDataWarehouse -UseWindowsAuthentication
    
  }
  catch 
  {
    Log "Error performing FNMS database checks: $_" -Level "error"
  }
  finally 
  {
    Log
  }
  Log "Done checking FNMS database connectivity"
  
  return $true
}
  


