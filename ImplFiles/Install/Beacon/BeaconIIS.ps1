###########################################################################
# This PowerShell script can be used with flexadmin.ps1 to configure IIS
# for FlexNet Beacon software components on any computer running
# Windows Server 2008 R2+ and above
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



########################################################################################
# Load a Self-Signed Certificate for IIS from file

function LoadSelfSignedCertificateFromFile
{
  # get names from environment
  $computername =  [System.Environment]::GetEnvironmentVariable('computername')
  $userdomain =  [System.Environment]::GetEnvironmentVariable('userdnsdomain')  

  # get certificate settings
  $BeaconFQDN = GetConfigValue "FNMSBeaconServerFQDN"
  $FriendlyName = GetConfigValue "CertificateFriendlyName"

  # get file path and secure password
  $PfxFile = GetConfigValue "BeaconCertificateFileName"
  $file = Join-Path $ScriptPath $PfxFile
  #$file = Join-Path $ScriptPath "cert.pfx"

  $cred = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'
  $password = $cred.GetNetworkCredential().Password
  $pwd = ConvertTo-SecureString -String $password -Force –AsPlainText  
  
  # get hard coded password    
  #$pwd = ConvertTo-SecureString -String "Cray0n!" -Force –AsPlainText

  # load the certificate using the following parameters
  $Params = @{
    "FilePath"          = $file
    "CertStoreLocation" = "Cert:\LocalMachine\My"
    "Password"          = $pwd
  }

  try 
  {
    # Load the certificate  
	  Log "Load Self-Signed Certificate from $file"
    $cert = Import-PfxCertificate @Params

    Write-Host
  }
  catch 
  {
		Log "Error loading certificate: $_" -level Error
		return $false
  }
  finally 
  {
    Write-Host
  }
	return $true
}

#C:\Program Files\Git\usr\bin\openssl.exe
#openssl x509 -inform der -in certificate.cer -out certificate.pem
#openssl pkcs12 -in certificate.pfx -out certificate.cer –nodes

#certutil -addstore "Root" "%*"

#######################################################################################
# Create a new Self-Signed Certificate for IIS

function CreateSelfSignedCertificate
{
  # get names from environment
  $computername =  [System.Environment]::GetEnvironmentVariable('computername')
  $userdomain =  [System.Environment]::GetEnvironmentVariable('userdnsdomain')  

  # get certificate settings
  $BeaconFQDN = GetConfigValue "FNMSBeaconServerFQDN"
  $Expiry = (Get-Date).AddYears(5)   
  $FriendlyName = GetConfigValue "CertificateFriendlyName"

  $osv = (Get-WmiObject Win32_OperatingSystem).Version
  $osvx = $osv.Split(".")

  # create the certificate using the following parameters
  $Params = @{
    "DnsName"           = @($BeaconFQDN,$computername)
    "CertStoreLocation" = "Cert:\LocalMachine\My"
    "NotAfter"          = $Expiry
    "FriendlyName"      = $FriendlyName
    "KeyAlgorithm"      = "RSA"
    "KeyLength"         = "2048"
  }

  # check for older versions of Windows that dont support full cryptography in PwoerShell
  if ($osvx[0] -ne "10")
  {
    $Params = @{
      "DnsName"           = @($BeaconFQDN, $computername)
      "CertStoreLocation" = "Cert:\LocalMachine\My"
    }
  }

  # get the pfx file and password
  $PfxFile = GetConfigValue "CertificateFileName"
  $file = Join-Path $ScriptPath $PfxFile

  $cred = Get-Credential -UserName 'Enter pfx file password below' -Message 'Enter password below'
  $pwd = $cred.Password

  # get hard coded password    
  #$pwd = ConvertTo-SecureString -String "password" -Force –AsPlainText

  try 
  {
    # Create the certificate  
	  Log "Create Self-Signed Certificate for $key $BeaconFQDN"
    $cert = New-SelfSignedCertificate @Params

    # Export the certificate
    $path = 'cert:\localMachine\my\' + $cert.thumbprint 
    Export-PfxCertificate -cert $path -FilePath $file -Password $pwd | Out-Null
    Write-Host
  
	  Log "Export Self-Signed Certificate from $path to $file"
  }
  catch 
  {
		Log "Error creating certificate: $_" -level Error
		return $false
  }
  finally 
  {
    Write-Host
  }
	return $true
}

