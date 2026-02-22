###########################################################################
# This PowerShell script performs some basic checks for an FNMS system
#
# Copyright (C) 2020 Crayon
###########################################################################

param(
  [string]$target="localhost"  
)

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Key variables



###########################################################################
# Functions

function Test-SQLDatabase 
{
    param( 
    [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True)] [string] $Server,
    [Parameter(Position=1, Mandatory=$True)] [string] $Database,
    [Parameter(Position=2, Mandatory=$True, ParameterSetName="SQLAuth")] [string] $Username,
    [Parameter(Position=3, Mandatory=$True, ParameterSetName="SQLAuth")] [string] $Password,
    [Parameter(Position=2, Mandatory=$True, ParameterSetName="WindowsAuth")] [switch] $UseWindowsAuthentication
    )

    # connect to the database, then immediatly close the connection. If an exception occurrs it indicates the conneciton was not successful. 
    process { 
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
# Mainline

try 
{
  # what PowerShell version is installed?
  Write-Host "What PowerShell version is installed?"   
  Write-Host $PSVersionTable.PSVersion
  Write-Host

  # test connections to the target computer 
  Write-Host "Running Test-NetConnection for Target $target on Port 80" 
  Test-NetConnection -ComputerName $target -Port 80 
  Write-Host

  Write-Host "Running Test-NetConnection for Target $target on Port 443"  
  Test-NetConnection -ComputerName $target -Port 443 
  Write-Host
  
  # test database connectivity
  Write-Host "Running Test-SqlDatabase function to test connectivity to <master> on @FnmsDatabaseServer"    
  Test-SQLDatabase -Server @FnmsDatabaseServer -Database master -UseWindowsAuthentication
  
  # test database connectivity
  Write-Host "Running Test-SqlDatabase function to test connectivity to FNMSCompliance on @FnmsDatabaseServer"    
  Test-SQLDatabase -Server @FnmsDatabaseServer -Database FNMSCompliance -UseWindowsAuthentication
  
  # test database connectivity
  Write-Host "Running Test-SqlDatabase function to test connectivity to FNMSInventory on @FnmsDatabaseServer"    
  Test-SQLDatabase -Server @FnmsDatabaseServer -Database FNMSInventory -UseWindowsAuthentication
  
  # test database connectivity
  Write-Host "Running Test-SqlDatabase function to test connectivity to FNMSDataWarehouse on @FnmsDatabaseServer"    
  Test-SQLDatabase -Server @FnmsDatabaseServer -Database FNMSDataWarehouse -UseWindowsAuthentication
  
}
catch 
{
  Write-Host "Error performing basic checks: $_"
}
finally 
{
  Write-Host
}

