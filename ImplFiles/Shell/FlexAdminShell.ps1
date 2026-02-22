###########################################################################
# This script contains various functions available for use in flexadmin
# modules. These functions are not associated with any particular Flexera
# Software product(s)
# Copyright (C) 2020 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

$RegSettingsKey = "HKCU:\SOFTWARE\Flexera Software\FlexAdminSettings"

###########################################################################
## Shell Module Help

function ShellHelp
{
  $moduleConfigs = $GlobalConfigSettings["__ModuleConfigs"]
  Write-Host ""

	$prevName = $null
	$prevDescription = $null
	$prevVersion = $null	
	$prevHelp = $null	

	$moduleConfigs | %{
		$config = $_
		$_.Xml.Configuration.Identity
	} |	%{ @{ Identity = $_; Config = $config } } |
	?{ ($_.Identity.Name -and $_.Identity.Name -like "Shell") } |
	Sort-Object @{ Expression = { $_.Identity.Name } }, @{ Expression = { $_.Config.DepthFirstOrder } } |
	%{
		$identity = $_.Identity
		$config = $_.Config

 		Write-Host "$($identity.Name)" -foregroundcolor "cyan"
  	Write-Host "Description: " -foregroundcolor "gray" -nonewline		
	  Write-Host "$($identity.Description)" -foregroundcolor "white"
 		Write-Host "Version: " -foregroundcolor "gray" -nonewline
	  Write-Host "$($identity.Version)" -foregroundcolor "white"
 		Write-Host "ModulePath: " -foregroundcolor "gray" -nonewline
	  Write-Host "$($_.Config.ModulePath)" -foregroundcolor "white"
	  if ($identity.Help) { Write-Host "$($identity.Help)" -foregroundcolor "white"	}
		Write-Host ""				
	}
	
	return $true
}


############################################################
## Shell PowerShell Get-Help

function PowerShellHelp
{            
  Get-Help $MyInvocation.InvocationName
  return $true
}


############################################################
## Shell List Modules

function ShellListModules
{            
  # prompt for Module match patterns
  HelpGlobalModules * | Out-Null
  return $true
}

function ShellPromptListModules
{            
  # prompt for Module match patterns
  $modulePattern = PromptForInput "Match Target Modules? (default: *)" "*"   

  HelpGlobalModules $modulePattern | Out-Null
  return $true
}

###########################################################################
## Help Global Modules

function HelpGlobalModules([string]$modulePattern)
{
  $moduleConfigs = $GlobalConfigSettings["__ModuleConfigs"]
	Write-Host "Modules matching modules pattern '$modulePattern':"
  Write-Host ""

	$prevName = $null
	$prevDescription = $null
	$prevVersion = $null	
	$prevHelp = $null	

	$moduleConfigs | %{
		$config = $_
		$_.Xml.Configuration.Identity
	} |	%{ @{ Identity = $_; Config = $config } } |
	?{ ($_.Identity.Name -and $_.Identity.Name -like "*$modulePattern*") } |
	Sort-Object @{ Expression = { $_.Identity.Name } }, @{ Expression = { $_.Config.DepthFirstOrder } } |
	%{
		$identity = $_.Identity
		$config = $_.Config

 		Write-Host "$($identity.Name)" -foregroundcolor "cyan"
  	Write-Host "Description: " -foregroundcolor "gray" -nonewline		
	  Write-Host "$($identity.Description)" -foregroundcolor "white"
 		Write-Host "Version: " -foregroundcolor "gray" -nonewline
	  Write-Host "$($identity.Version)" -foregroundcolor "white"
 		Write-Host "ModulePath: " -foregroundcolor "gray" -nonewline
	  Write-Host "$($_.Config.ModulePath)" -foregroundcolor "white"
	  if ($identity.Help) { Write-Host "$($identity.Help)" -foregroundcolor "white"	}
		Write-Host ""				
	}
	Write-Host ""		
	
	return $true
}


############################################################
## Shell list targets

function ShellListTargets
{            
  HelpGlobalTargets * * $false | Out-Null
  return $true
}

function ShellPromptListTargets
{            
  # prompt for Target and Module match patterns
  $targetPattern = PromptForInput "Match Targets? (default: *)" "*"
  $modulePattern = PromptForInput "Match Target Modules? (default: *)" "*"   

  HelpGlobalTargets $targetPattern $modulePattern $false | Out-Null
  return $true
}

###########################################################################
## Help Global Targets

function HelpGlobalTargets([string]$targetPattern, [string]$modulePattern, [bool]$help)
{
  $moduleConfigs = $GlobalConfigSettings["__ModuleConfigs"]
	Write-Host "Targets matching target pattern '$targetPattern' and target modules pattern '$modulePattern':"
  Write-Host ""

	$prevName = $null
	$prevDescription = $null
	$prevHelp = $null	
	$prevModules = @()
	$prevChildTargets = @()

	$moduleConfigs | %{
		$config = $_
		$_.Xml.Configuration.Target
	} |	%{ @{ Target = $_; Config = $config } } |
	?{ $_.Target.Name -and ($_.Target.Name -like "*$targetPattern*" -and $_.Config.ModulePath -like "*$modulePattern*") } |
	Sort-Object @{ Expression = { $_.Target.Name } }, @{ Expression = { $_.Config.DepthFirstOrder } } |
	%{
		$target = $_.Target
		$config = $_.Config

		if ($prevName -and $target.Name -ne $prevName) {
  		Write-Host "$($prevName)" -foregroundcolor "green"
	  	Write-Host "Description: " -foregroundcolor "gray" -nonewline		
		  Write-Host "$prevDescription" -foregroundcolor "white"
  		Write-Host "Modules: " -foregroundcolor "gray" -nonewline
	  	Write-Host "$(($prevModules | Sort-Object -Unique) -join ", ")" -foregroundcolor "white"
		  if ($prevChildTargets.Count -gt 0) {
				Write-Host "Child targets: " -foregroundcolor "gray" -nonewline
				Write-Host "`t$($prevChildTargets -join ", ")" -foregroundcolor "white"
			}
		  if ($help -and $prevHelp) { Write-Host "$prevHelp" -foregroundcolor "white"	}
			Write-Host ""
				
			$prevDescription = $null
			$prevHelp = $null			
			$prevModules = @()
			$prevChildTargets = @()
		}

		$prevName = $target.Name
		if ($target.Description) {
			$prevDescription = $target.Description
		}
		if ($target.Help) {
			$prevHelp = $target.Help
		}
		$prevModules += $config.ModulePath

		$target.Step | ?{ $_.Target } | %{ $prevChildTargets += $_.Target }
	}

	if ($prevName) {
		Write-Host "$($prevName)" -foregroundcolor "green"
		Write-Host "Description: " -foregroundcolor "gray" -nonewline		
		Write-Host "$prevDescription"	-foregroundcolor "white"
		Write-Host "Modules: " -foregroundcolor "gray" -nonewline
		Write-Host "$(($prevModules | Sort-Object -Unique) -join ", ")" -foregroundcolor "white"
		if ($prevChildTargets.Count -gt 0) {
				Write-Host "Child targets: " -foregroundcolor "gray" -nonewline
				Write-Host "`t$($prevChildTargets -join ", ")" -foregroundcolor "white"
			}				
		if ($help -and $prevHelp) { Write-Host "$prevHelp" -foregroundcolor "white" }
		Write-Host ""	
	}
	return $true
}

######################################################################
# ShellListSettings

function ShellListSettings()
{  
  $GlobalConfigSettings.Keys |
  ? { -not ($_ -match "^__") } |
  %{
    $v = $GlobalConfigSettings[$_]
    Log "Found setting $_ = $v" 
  }
  Log ""

  return $true
}

######################################################################
# ShellUpdateRegSettings

function ShellUpdateRegSettings()
{  
  $GlobalConfigSettings.Keys |
  ? { -not ($_ -match "^__") } |
  %{
    $v = $GlobalConfigSettings[$_]
    Set-ItemProperty -path $RegSettingsKey -name $_ -value $v #-ErrorAction Ignore
    Log "Reg setting updated $_ = $v" 
  }
  Log ""

  return $true
}

############################################################
## Shell list Windows installed features

function ShellListWindowsFeatures
{
  # Write feature list to file
  $logdir = GetConfigValue "LogDir"
  $outputfile = Join-Path $logdir ($env:computername + "-features.csv")
  Get-WindowsFeature | Export-CSV $outputfile  
  
  Write-Host
  
  # Get the installed features list
  $winfeatures = Get-WindowsFeature
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

  return $true  
}

############################################################
## Shell list PowerShell and FNMS installed versions

function ShellListInstalledProducts
{
  # Get the installed version
  ListInstalledProductVersions | Out-Null
  return $true  
}

############################################################
# List PowerShell and FNMS installed versions

function ListInstalledProductVersions
{
  # what version of PowerShell are we running?
  $psv = $PSVersionTable.PSVersion
  Write-Host ""
  Write-Host "IIS & PowerShell" -foregroundcolor "green"  
  Write-Host "PowerShell Version: $psv"
  get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\  | select setupstring,versionstring   
  $iisversion = GetMicrosoftRegKeyValue "VersionString" "InetStp"
  if ($iisversion) { Write-Host "IIS: $iisversion" }
  
  # check if the version is 5.1 or greater
  $psva = $psv.ToString().Split(".")
  $psvn = 10 * $psva[0] + $psva[1]
  if ($psvn -lt 51) {
    Write-Host "PowerShell version is less than 5.1 ($psvn). This could result in some loss of functionality" -foregroundcolor "yellow"
    Write-Host "Please consider updrading to PowerShell version 5.1 or greater" -foregroundcolor "yellow"    
  }

  # Get the installed FNMS Compliance version
  $version = GetFNMSVersion
  $installdir = GetFNMSInstallDir
  Write-Host ""
  Write-Host "FlexNet Manager Platform" -foregroundcolor "green"  
  Write-Host "FNMS Version: $version"
  Write-Host "FNMS Install Directory: $installdir"

  if ($psvn -gt 50) {  
    Write-Host "Installed Features" -foregroundcolor "cyan"
    $batchprocessor = GetFlexeraRegKeyValue "BatchProcessor" "Features\CurrentVersion"
    if ($batchprocessor) { Write-Host "Batch processor" }
    $batchserver = GetFlexeraRegKeyValue "BatchServer" "Features\CurrentVersion"
    if ($batchserver) { Write-Host "Batch server" }
    $inventoryserver = GetFlexeraRegKeyValue "InventoryServer" "Features\CurrentVersion"
    if ($inventoryserver) { Write-Host "Inventory server" }
    $presentationserver = GetFlexeraRegKeyValue "PresentationServer" "Features\CurrentVersion"
    if ($presentationserver) { Write-Host "Presentation server" }

    # Get the installed FNMS Inventory Manager version
    $version = GetManageSoftRegKeyValue "ETDPVersion"
    $installdir = GetManageSoftRegKeyValue "ETDPInstallDir"  
    if ($version) {    
      Write-Host ""
      Write-Host "FlexNet Manager Beacon" -foregroundcolor "green"  
      Write-Host "Beacon Version: $version"
      Write-Host "Beacon Install Directory: $installdir"
    }

    # Get the installed FNMS Client version
    $version = GetManageSoftRegKeyValue "ETCPVersion"
    $installdir = GetManageSoftRegKeyValue "ETCPInstallDir"
    if ($version) {
      Write-Host ""
      Write-Host "FlexNet Manager Client" -foregroundcolor "green"  
      Write-Host "Client Version: $version"
      Write-Host "Client Install Directory: $installdir"
    }
  }
  Write-Host ""
}


############################################################
## Shell list configured database tenants

function ShellListTenants
{
  # List the database tenants
  ListDatabaseTenants | Out-Null
  return $true  
}

############################################################
## List configured tenants

function ListDatabaseTenants
{
  # set the database connection
  $dbServer = GetConfigValue "FNMSDBServer"
  $dbName = GetConfigValue "FNMSComplianceDBName"

  $query = "SELECT t.[TenantID], t.[TenantUID], t.[TenantName] `
            FROM [dbo].[Tenant] AS t "

  # tenant query to get tenant list
  $tenants = @(Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
    -Query $query -MaxCharLength 100000)
            
  Write-Host ""
  Write-Host "Tenant List:" 
  foreach ($tenant in $tenants) 
  {
    [int]$tid = $tenant.TenantID  
    $tuid = $tenant.TenantUID  
    $name = $tenant.TenantName
    Write-Host "Tenant $($tid): [$tuid]\$name"  
  }
  Write-Host ""
  
  return $true
}


###########################################################################
## Simulate Target Steps

function SimulateTarget([System.Collections.ArrayList]$moduleConfigs, [string]$target, [int]$startStepNumber, [ref]$currentStepNumber, [hashtable]$loadedScripts, [hashtable]$doneTargets)
{
	if (!$loadedScripts) {
		$loadedScripts = @{}
	}
	foreach ($mc in $moduleConfigs) {
		foreach ($l in $mc.Xml.Configuration.Load) {
			if ($l.Script -and !(. LoadScript $l.Script $mc.ConfigFile $loadedScripts)) {
				return $false
			}
		}
	}

  Log ""
	Log "============================================================"
	Log "Simulating target '$target'"

	if (!$doneTargets) {
		$doneTargets = @{}
	}
	if ($doneTargets[$target]) {
		Log "Already done target '$target'"
		return $true
	}
	$doneTargets[$target] = $true

	$found = $false
	foreach ($mc in $moduleConfigs) {
		foreach ($targetNode in $mc.Xml.Configuration.Target | ?{$_.Name -eq $target}) {
			Log "Found target in '$($mc.ConfigFile)'"
			$found = $true

			foreach ($s in $targetNode.Step) {
				if ($s.Load) {
					if (!(. DoLoadStep $s $target $mc $loadedScripts)) {
						return $false
					}
				}

				if ($s.Target) {
					if ($s.If -and !(Invoke-Expression $s.If)) {
						Log "  Target $($s.Target) skipped as condition step expression evaluated to false"
					} elseif (!(SimulateTarget $moduleConfigs $s.Target $startStepNumber $currentStepNumber $loadedScripts.Clone() $doneTargets)) {
						return $false
					}
				}

				if ($s.Call) {
					$currentStepNumber.Value++
					Log "Executing step $($currentStepNumber.Value) (call $($s.Call))"

					if ($currentStepNumber.Value -lt $startStepNumber) {
						Log "  Step skipped as it is before starting step $startStepNumber"
					}
					elseif ($s.If -and !(Invoke-Expression $s.If)) {
						Log "  Step skipped as condition step expression evaluated to false"
					}
				}

				if ($s.SQLScript) {
					$currentStepNumber.Value++
					Log "Executing step $($currentStepNumber.Value) (execute SQL $($s.SQLScript) on database $($s.DBName))"

					if ($currentStepNumber.Value -lt $startStepNumber) {
						Log "  Step skipped as it is before starting step $startStepNumber"
					}
					elseif ($s.If -and !(Invoke-Expression $s.If)) {
						Log "  Step skipped as condition step expression evaluated to false"
					}
				}

				if ($s.ScheduleFlexAdminTarget) {
					$currentStepNumber.Value++
					Log "Executing step $($currentStepNumber.Value) (schedule flexadmin target $($s.ScheduleFlexAdminTarget))"

					if ($currentStepNumber.Value -lt $startStepNumber) {
						Log "  Step skipped as it is before starting step $startStepNumber"
					}
					elseif ($s.If -and !(Invoke-Expression $s.If)) {
						Log "  Step skipped as condition step expression evaluated to false"
					}
				}
			}
		}
	}

	if (!$found) {
		Log "Target '$target' not found" -level Error
		return $false
	}

	return $true
}

