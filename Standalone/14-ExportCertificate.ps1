###########################################################################
# This PowerShell script finds a Certificate in the local machine
# certificate store and exports that certificate to a PFX file.
# The script alos converts the PFX file to two PEM files
#
# Copyright (C) 2020 Crayon
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Key variables

$CertificateStore = "Cert:\LocalMachine\My"

$BeaconFQDN = "beacon.flexdemo.com"
$FriendlyName = "Beacon"

$PfxFile = "cert.pfx"
$Password = "Crayon!"

$CerFile = "cert.cer"
$PemClientFile = "client_cert.pem"
$PemCAFile = "ca_cert.pem"


###########################################################################
# Mainline

# Get names from environment
$computername =  [System.Environment]::GetEnvironmentVariable('computername')
$userdomain =  [System.Environment]::GetEnvironmentVariable('userdnsdomain')  

$pfxpath    = Join-Path $ScriptPath $PfxFile
$cerpath    = Join-Path $ScriptPath $CerFile
$pempath    = Join-Path $ScriptPath $PemClientFile
$pemcapath  = Join-Path $ScriptPath $PemCAFile

try 
{
  $cert = Get-ChildItem -Path $CertificateStore | Where-Object { $_.Subject.Contains($BeaconFQDN) }

  # Get a secure password
  $pwd = ConvertTo-SecureString -String $Password -Force –AsPlainText

  # Export the stored certificate to .pfx
	Write-Host "Export Certificate from $path to $pfxpath"
  $path = Join-Path $CertificateStore $cert.thumbprint 
  Export-PfxCertificate -cert $path -FilePath $pfxpath -Password $pwd
  Write-Host

  # Export the stored certificate to .cer
	Write-Host "Export Certificate from $path to $cerpath"
  Export-Certificate -cert $path -FilePath $cerpath -Type CERT -Force
  Write-Host
  
  # Convert the exported certificate to (client) .pem
	Write-Host "Convert Certificate from $pfxpath to $pempath"
  &"C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -in $pfxpath -out $pempath -clcerts
  Write-Host

  # Convert the exported certificate to (ca) .pem
	Write-Host "Convert Certificate from $pfxpath to $pemcapath"
  &"C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -in $pfxpath -out $pemcapath -cacerts
    
  Write-Host
}
catch 
{
	Write-Host "Error exporting certificate: $_"
}
finally 
{
  Write-Host
}


