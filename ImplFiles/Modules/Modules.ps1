###########################################################################
# This script contains various functions available for use in flexadmin
# modules. These functions are not associated with any particular Flexera
# Software product(s)
# Copyright (C) 2020 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
## Set default settings

function SetDefaultSettings
{
  # initialise
  $unpacked = 0; $failures = 0;

  # get and set default config values
  $value = GetConfigValue "SetupComputerRole"
  $value = GetConfigValue "SetupComputer"
  $value = GetConfigValue "SetupDnsDomain"
  $value = GetConfigValue "SetupDomain"
  $value = GetConfigValue "SetupUser"
  $value = GetConfigValue "SetupSourceDir"
  $value = GetConfigValue "SetupLogFilesDir"  

  Write-Host ""	
  Write-Host "Completed initialisation of default settings"

	return $true
}


###########################################################################
## Install modules

function InstallModules
{
  # initialise
  $unpacked = 0; $failures = 0;

	Write-Host "Unpacking modules ..."
  $sourcepath = Join-Path $ScriptPath "Install"
  $rootPath = Split-Path $ScriptPath -parent

	Get-ChildItem -LiteralPath $sourcepath |
	?{ $file = $_; -not $_.PSIsContainer -and $file.FullName -like "*.zip" } | 
	%{
		$file = $_
		$fileName = $file.FullName;
		$name = [System.IO.Path]::GetFileNameWithoutExtension($fileName);
		$items = $name.split(".");
    $folder = Join-Path $ScriptPath "temp"
    if (!(Test-Path $folder)) 
    {
      Write-Host "`tCreate Folder $folder" -foregroundcolor "gray"
      New-Item -Path $folder -ItemType Directory | Out-Null
    }
		
		try 
		{
			Write-Host "`tUnpacking $fileName ... " -foregroundcolor "gray" -nonewline
      Expand-Archive -LiteralPath $fileName -DestinationPath $folder
      Write-Host "done" -foregroundcolor "green"	
			++$unpacked;
			
			$targetPath = $rootPath
			$tempModulePath = Join-Path $folder $items[0]
			if ($items[1] -ne $null)
			{
			  $tempModulePath = Join-Path $folder $items[1]
			  $targetPath = Join-Path $rootPath $items[0]
        if (!(Test-Path $targetPath)) 
        {
          Write-Host "`tCreate Folder $targetPath" -foregroundcolor "gray"
          New-Item -Path $targetPath -ItemType Directory | Out-Null
        }
			}

      if (Test-Path $tempModulePath) 
      {
        Write-Host "`tMove Folder $tempModulePath to $targetPath" -foregroundcolor "gray"
        Copy-Item -Path $tempModulePath -Destination $targetPath -recurse -Force -Verbose -ErrorAction Stop
        Remove-Item -Path $tempModulePath -recurse -Force -ErrorAction Stop        			
      }

		} 
		catch 
		{
      Write-Host "failed" -foregroundcolor "red"		
			++$failures;
			Write-Host "Failed to unzip $($fileName): $($_)" -level Warning
		}
	};
	
	# clean out installed modules from install buffer
  Remove-Item -Path (Join-Path $sourcepath "*") -recurse -Force -ErrorAction Stop  
        				
  Write-Host ""	
  Write-Host "Completed unpacking modules ..."

	return $true
}
