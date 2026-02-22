###########################################################################
# This PowerShell script load a .CER Certificate file to the local machine
# certificate store 
#
# Copyright (C) 2020 Crayon
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
# Key variables

$CertificateStore = "Cert:\LocalMachine\Root"
$CerFile = "cert.cer"

###########################################################################
# Mainline

try 
{
  # load the certificates using the following parameters
  Write-Host "Load Certificate from $CerFile to $CertificateStore"
  $file = Join-Path $ScriptPath $CerFile
  Import-Certificate -FilePath $file -CertStoreLocation $CertificateStore
  Write-Host
}
catch 
{
  Write-Host "Error loading certificate: $_"
}
finally 
{
  Write-Host
}
