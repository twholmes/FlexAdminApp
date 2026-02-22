###########################################################################
# This PowerShell script can be used with flexadmin.ps1 to configure IIS
# to use a certificate for encrypted traffic
#
# Copyright (C) 2020 Crayon
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

########################################################################################
# Load a Certificate for IIS from PFX file

function LoadCertificateFromPfxFile
{
  # get names from environment
  $computername =  [System.Environment]::GetEnvironmentVariable('computername')
  $userdomain =  [System.Environment]::GetEnvironmentVariable('userdnsdomain')  

  # get certificate settings
  $ServerFQDN = GetConfigValue "FlexeraServerFQDN"
  $FriendlyName = GetConfigValue "CertificateFriendlyName"

  # get file path and secure password
  $PfxFile = GetConfigValue "ServerCertificateFileName"
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

#######################################################################################
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
  $ServerFQDN = GetConfigValue "FlexeraServerFQDN"
  $Expiry = (Get-Date).AddYears(5)   
  $FriendlyName = GetConfigValue "CertificateFriendlyName"

  $osv = (Get-WmiObject Win32_OperatingSystem).Version
  $osvx = $osv.Split(".")

  # create the certificate using the following parameters
  $Params = @{
    "DnsName"           = @($ServerFQDN,$computername)
    "CertStoreLocation" = "Cert:\LocalMachine\My"
    "NotAfter"          = $Expiry
    "FriendlyName"      = $FriendlyName
    "KeyAlgorithm"      = "RSA"
    "KeyLength"         = "2048"
  }

  # check for older versions of Windows that dont support full cryptography in PowerShell
  if ($osvx[0] -ne "10")
  {
    $Params = @{
      "DnsName"           = @($ServerFQDN, $computername)
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
	  Log "Create Self-Signed Certificate for $key $ServerFQDN"
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

