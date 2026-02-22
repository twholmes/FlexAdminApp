###########################################################################
# This PowerShell script creates a Self-Signed Certificate in the
# local machine certificate store and exports that certificate to 
# a PFX file
#
# Copyright (C) 2020 Crayon
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Key variables

$CertificateStore = "Cert:\LocalMachine\My"

$BeaconFQDN = "beacon.flexdemo.com"
$FriendlyName = "Beacon"
$Expiry = (Get-Date).AddYears(5) 

$PfxFile = "beacon.pfx"
$Password = "Crayon!"

$OpenCertificateManager = "no"

###########################################################################
# Mainline

# Get names from environment
$computername =  [System.Environment]::GetEnvironmentVariable('computername')
$userdomain =  [System.Environment]::GetEnvironmentVariable('userdnsdomain')  
  
# Create the certificate using the following parameters
$Params = @{
  "DnsName"           = @($BeaconFQDN, $computername)
  "CertStoreLocation" = $CertificateStore
  "NotAfter"          = $Expiry
  "FriendlyName"      = $FriendlyName
  "KeyAlgorithm"      = "RSA"
  "KeyLength"         = "2048"
  "KeyFriendlyName"   = $FriendlyName
  "KeyDescription"    = "Key used for FNMS Beacon connections"  
  "KeyExportPolicy"   = "Exportable"    
}

# check for older versions of Windows that dont support full cryptography in PwoerShell
$osv = (Get-WmiObject Win32_OperatingSystem).Version
$osvx = $osv.Split(".")

if ($osvx[0] -ne "10")
{
  $Params = @{
    "DnsName"           = @($BeaconFQDN, $computername)
    "CertStoreLocation" = $CertificateStore
  }
}

try 
{
  # Create the certificate
	Write-Host "Create Self-Signed Certificate for $key $BeaconFQDN"
  $cert = New-SelfSignedCertificate @Params	

  # Get a secure password
  $pwd = ConvertTo-SecureString -String $Password -Force –AsPlainText

  # Export the certificate
  $file = Join-Path $ScriptPath $PfxFile
  $path = Join-Path $CertificateStore $cert.thumbprint 
  Export-PfxCertificate -cert $path -FilePath $file -Password $pwd
  Write-Host
  
	Write-Host "Export Self-Signed Certificate from $path to $file"
}
catch 
{
	Write-Host "Error creating certificate: $_"
}
finally 
{
  if ($OpenCertificateManager -eq "yes") {
    &"certlm.msc"
  }
  Write-Host
}


