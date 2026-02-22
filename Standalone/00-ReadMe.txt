Copyright (c)2020 Crayon Australia
Standalone Configuration and Test scripts for FNMS

Revision History:
1.0.0.2  Initial Revision  Trevor Holmes 02.11.2020

Overview
These scripts are intended to be used by to assist FNMS Adminsitrators to check that an FNMS server meets pre-requisites for an FNMS install

Install Instructions:
 1) If not installed using the FlexAdmin msi, the create the following folder structure, and copt the script set into the Standalone sub-folder
 
    C:\Crayon
    C:\Crayon\Standalone
    C:\Crayon\LogFiles
 
 2) Copy any SSL Certificates you wll be using into the Standalone sub-folder
 
 3) Run selected .CMD files (as Administrator) as appropriate
 

Available System Check Scripts:

* 01-BasicChecks.cmd (01-BasicChecks.ps1)

  This script performs some basic pre-requisite checks including 
  + lists the installed PowerShell version
  + runs Test-NetConnection to test connectivity to the FNMS AppServer over ports 80 & 443
  + test in the executing user can connect to the FNMS Database Server and read the databases FNMSCompliance, FNMSInventory, and FNMSDataWarehouse

* 02-CheckIIS.com (02-CheckIIS.ps1)

  This script checks if IIS pre-requisite components for FNMS are installed
  The script writes a logfile to the the current directory

* 03-CheckNetConnections.cmd (03-CheckNetConnections.ps1)

  This script performs some net connection checks and outputs results to a log file
  + lists the installed PowerShell version
  + runs Test-NetConnection to test connectivity to the FNMS AppServer over ports 80 & 443


Available Certificate Management Scripts:
  
* 11-CreateSelfSignedCertificate.cmd (11-CreateSelfSignedCertificate.ps1)

  This script created a new self-signed certificate in the "Cert:\LocalMachine\My" certificate store
  
  These certificate is created with a 5-year expiry if the script is run on a Win10/WS2016 server
  but only created with a 1-year expiry if created on a WS2012R2 server (due to PowerShell limitiations)

* 12-LoadSelfSignedCertificate.cmd (12-LoadSelfSignedCertificate.ps1)

  This script loads the certificate created 11-CreateSelfSignedCertificate from a ,PFX file and stores it
  in the "Cert:\LocalMachine\My" certificate store
    
* 13-LoadCertificates.cmd (13-LoadCertificates.ps1)

  This script loads certificates from .CER files to a certificate store. 
  The file name and the store path can be updated by changing the following variables in the .ps1 script:

  $CertificateStore = "Cert:\LocalMachine\Root"
  $CerFile = "cert.cer"  
  
  
  