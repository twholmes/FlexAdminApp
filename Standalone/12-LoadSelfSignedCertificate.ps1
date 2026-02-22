###########################################################################
# This PowerShell script load a Self-Signed Certificate in a .PFX file to
# the local machine certificate store 
#
# Copyright (C) 2020 Crayon
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Key variables

$PfxFile = "beacon.pfx"
$Password = "Crayon!"

$OpenCertificateManager = "no"

###########################################################################
# Mainline

# get names from environment
$computername =  [System.Environment]::GetEnvironmentVariable('computername')
$userdomain =  [System.Environment]::GetEnvironmentVariable('userdnsdomain')  

# get file path and secure password
$file = Join-Path $ScriptPath $PfxFile
#$file = Join-Path $ScriptPath "cert.pfx"

$cred = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'
$password = $cred.GetNetworkCredential().Password
$pwd = ConvertTo-SecureString -String $password -Force –AsPlainText  

# get hard coded password    
#$pwd = ConvertTo-SecureString -String $Password -Force –AsPlainText

# load the certificate using the following parameters
$Params = @{
  "FilePath"          = $file
  "CertStoreLocation" = "Cert:\LocalMachine\My"
  "Password"          = $pwd
}

try 
{
  # Load the certificate  
  Write-Host "Load Self-Signed Certificate from $file"
  $cert = Import-PfxCertificate @Params

  Write-Host
}
catch 
{
  Write-Host "Error loading certificate: $_"
}
finally 
{
  if ($OpenCertificateManager -eq "yes") {
    &"certlm.msc"
  }
  Write-Host
}

