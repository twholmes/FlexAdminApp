Copyright (c)2019-2020 Crayon Australia
Packaged Application ReadMe

Revision History:
1.0.1.1  Initial Revision  Trevor Holmes 17.04.2020

Overview
This package has been compiled to help configure a Beacon from reading data from Active Directory and ServiceNow

Install Instructions:
 1) Create a new directory to hold the unpacked ImplFiles. eg. C:\ImplFilesBeaconBoQ
 2) Copy the FlexAdmin app into this folder, run the app, and set the Working directory to "local"
 3) Click the UNPACK button to unpack the the ImplFiles source and scripts
 
 4) RUN the required Reports configuration targets
    * ConfigureReportProcedures   	Configure FNMS Custom Report procedures
    * ConfigureReports              Create and configure FNMS Custom Reports

 5) RUN the required Agent configuration targets
    * PrepareInvAgentInstallers     Prepare directories containing files that can be used to install Flexera Inventory Manager software components on other computers

All Available Targets:
(Note that you can alternately get this help by executing the target -> ShellListModules)

Shell targets include:
  * ShellHelp           Displays this help
  * ShellListModules    List all FlexAdmin modules
  * ShellListTargets    List all target names and descriptions
  * ShellListInstalled  List all installed FNMS products
  * ShellListTenants    Lists configured database tenants

