<#
.SYNOPSIS
  This script retrieves VDI inventory and access data from a VMWare Horizon Connection Server

.DESCRIPTION
  This script retrieves VDI inventory and access data from single VMWare Horizon Connection Server.  It
  is designed to be run on either an Inventory Beacon or an FNMS server with the Inventory components
  Installed.

  The information that is gathered is written to two separate XML files and copied to the local incoming folder.
  The format of the XML file is recognised by the FNMS importers. 

  Copyright Crayon Australia 2021

  The two files are:
  - Inventory File (.ndi)
  This contains a list of all devices that managed by VMWare Horizon and the VDI pool that they belong to

  - VDI Access Files (.vdi)
  This contains a list of all VDI pools that VMWare Horizon and which AD groups are entitled to access VDIs in them.

.PARAMETER LogFile
  Specifies the path of the log file.  If not specified then the default "$($env:TEMP)\GatherHorizonInventory.ps1" 
  will be used.

.PARAMETER ConnectionServer
  Specifies the DNS name or IP address of the VMWare Horizon Connection Server to connect to.

.INPUTS
  None

.OUTPUTS
  - Log file stored in "$($env:temp)\GatherHorizonInventory.log".   This can be overridden with the -LogFile parameter
  - For each VMWare vCenter server that the VMWare Horizon Connection Server manages the script will generate
    the following two files:
    - .ndi file
      e.g. "myVCServerName at 20210822T101636 (VMWare Horizon).ndi"
      This will be placed in the C:\ProgramData\Flexera Software\Incoming\Inventories folder.  
    - .vdi file
      e.g. "myVCServerName at 20210822T101636 (VMWare Horizon).vdi"
      This will be placed in the C:\ProgramData\Flexera Software\Incoming\VDIaccess folder.  


.NOTES
  Version:        1.0
  Author:         Peter Osang
  Creation Date:  22/08/2021
  Purpose/Change: Initial script development
  
  Prerequisites:
  This script requires the VMWare PowerCLI to be installed on the server on which it is run.  
  See the following URL for details about installing it:
  https://developer.vmware.com/powercli/installation-guide 

  The user account that the script runs in the context of must be granted read access to VMWare Horizon.

  Logging:
  If the log file grows beyond 1 MB then, at the next run of the script, the log will be rolled.  This means that
  the old log will be renamed with the additional extension ".old" and a new log created.   If there is an existing
  log with the ".old" extension it will be deleted.

.EXAMPLE
  GatherHorizonInventory.ps1 -ConnectionServer myhorizonsrv.mydomain.com -LogFile "C:\FNMS\LogFiles\GatherHorizonInventory.log"

#>

param(
	[string] $LogFolder,
	[string] $ConnectionServer,
    [switch] $UseStoredCredentials,
    [string] $UserName,
    [string] $Password,
    [string] $CredentialStoreName,
    [switch] $StoreCredentials,
	[switch] $Help
)


#----------------------------------------------------------[Declarations]----------------------------------------------------------

$ScriptVersion = "1.0"
$ScriptPath = Split-Path $PSCommandPath 
$ScriptName = Split-Path $PSCommandPath -Leaf
$script:StartTime = $(Get-Date).ToString("yyyyMMddTHHmmss")
$script:LogFileName = "GatherHorizonInventory_$($script:StartTime).log"
$Script:AgentVersion = "16.0" #"@FLX_RELEASE_STRING@"
$script:CachedDesktopPoolUids = @{}

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function InitialiseLog ()
{	  
	if(!(Test-Path -Path $Script:LogFolder -PathType Container))
	{
		New-Item -Path $Script:LogFolder -ItemType Container -ErrorAction Stop | Out-Null
	}		
    $Script:LogFile = Join-Path $Script:LogFolder $Script:LogFileName

	New-Item -Path $Script:LogFile -ItemType File -ErrorAction Stop | Out-Null

	Add-Content -Path $Script:LogFile -Value "***************************************************************************************************"
	Add-Content -Path $Script:LogFile -Value $("Started processing at [{0:yyyy-MM-dd} {0:HH:mm:ss}]" -f (Get-Date))
	Add-Content -Path $Script:LogFile -Value "***************************************************************************************************"
	Add-Content -Path $Script:LogFile -Value ""
	Add-Content -Path $Script:LogFile -Value "Running script '$ScriptName' version [$ScriptVersion]."
	Add-Content -Path $Script:LogFile -Value ""
	Add-Content -Path $Script:LogFile -Value "***************************************************************************************************"
	Add-Content -Path $Script:LogFile -Value ""	
}

#-----------------------------------------------------------

Function Log (
	[string] $Msg,
	[string] [ValidateSet("Output","Error")] $Level = "Output"
)
{

	$LogMsg = "[{0:yyyy-MM-dd} {0:HH:mm:ss}] $Msg" -f (Get-Date)

	Add-Content -Path $Script:LogFile -Value $LogMsg
	
	# Write message to STDOUT
	switch ($Level) {
		"Error" { Write-Error $Msg }
		"Message" { Write-Host $Msg }
		Default {Write-Host $Msg }
	}
}
  

#-----------------------------------------------------------

Function FinaliseLog()
{
	Add-Content -Path $LogFile -Value ""
	Add-Content -Path $LogFile -Value "***************************************************************************************************"
	Add-Content -Path $LogFile -Value "Finished processing at [$([DateTime]::Now)]."
	Add-Content -Path $LogFile -Value "***************************************************************************************************"
	Add-Content -Path $LogFile -Value ""			
}

#-----------------------------------------------------------

function ConnectHVServer([PSCredential]$Credential)
{
    try {
        if ($Credential)
        {
            $u = $Credential.UserName
            $p = $Credential.Password
            $con = Connect-HVServer $ConnectionServer -User $Credential.UserName -Password $Credential.Password    
        }
        else
        {
            $con = Connect-HVServer $ConnectionServer 
        }
    } catch {
        throw "Failed to connect to the Connection Server '$ConnectionServer'.  Details: $($_.Exception.Message)"
    }

    return $con
}



#-----------------------------------------------------------

function WriteVDIAccessData ([hashtable] $DesktopPools, [string]$SiteName, [string]$ConnectionServer)
{

    # Initialise XML file
	$xmlVDIAccess = New-Object System.IO.MemoryStream
	$xmlVDIAccessWriterSettings = New-Object System.XML.XmlWriterSettings
	$xmlVDIAccessWriterSettings.Indent = $true
	$xmlVDIAccessWriterSettings.Encoding = [System.Text.Encoding]::UTF8
	$xmlVDIAccessWriter = [System.XML.XMLWriter]::Create($xmlVDIAccess, $xmlVDIAccessWriterSettings)
	$xmlVDIAccessWriter.WriteStartDocument()	

    # Build root vdiGroups node
    # It will be in the form:
    #   <vdiGroups brokerType="VMwareView" siteName="{Site name}" scanTime="{YYYYMMDDTHHMMSS}">
    #
    # e.g. 
    #   <vdiGroups brokerType="VMwareView" siteName="Cluster-UQ-DW-DEV-CS01" scanTime="20210128T123848">
	$xmlVDIAccessWriter.WriteStartElement("vdiGroups")
	$xmlVDIAccessWriter.WriteAttributeString("brokerType", "VMwareView")
	$xmlVDIAccessWriter.WriteAttributeString("siteName", $SiteName)
	$xmlVDIAccessWriter.WriteAttributeString("scanTime", $script:StartTime)

    foreach ($dpId in $DesktopPools.Keys)
    {
        # Build root vdiGroup nodes and the list of AD user/group SIDs that have been 
        # granted access to them.
        #
        # Each will be in the form:
        #   <vdiGroup name="{Desktop pool name}">
        #     <object Sid="{AD group or user SID 1}">
        #     <object Sid="{AD group or user SID 2}">
        #     ...
        #   </vdiGroup>
        #
        # e.g. 
        #   <vdiGroup name="My VMWare Horizon VDI Group">
        #     <object Sid="S-1-5-21-620321403-24207062-1845911597-1128381">
        #     <object Sid="S-1-5-21-620321403-24207062-1845911597-740437">
        #     ...
        #   </vdiGroup>
        # 

        
        $dp = $DesktopPools[$dpId]
        Log "Adding the vdiGroup '$($dp.Name)' to VDI access file"
    	$xmlVDIAccessWriter.WriteStartElement("vdiGroup")
    	$xmlVDIAccessWriter.WriteAttributeString("name", $dp.Name)

        foreach ($sid in $dp.Sids)
        {
			$xmlVDIAccessWriter.WriteStartElement("object")
			$xmlVDIAccessWriter.WriteAttributeString("Sid", $sid)
			$xmlVDIAccessWriter.WriteEndElement() # object
        }            
        
        $xmlVDIAccessWriter.WriteEndElement() # vdiGroup        
    }

	$xmlVDIAccessWriter.WriteEndElement() #vdiGroups
	$xmlVDIAccessWriter.WriteEndDocument()
	$xmlVDIAccessWriter.Flush()
	$xmlVDIAccessWriter.Close()

    
    $vdifilename = $ConnectionServer + " at " + $script:StartTime + " (VMwareView).vdi"
    $vdiFilePath = join-path -path $env:TEMP -childpath $vdifilename 

    if (Test-Path $vdiFilePath) {
        Remove-Item $vdiFilePath -Force
    }
	$streamWriter = New-Object System.IO.StreamWriter($vdiFilePath)
	$strVDIAccessXML = [System.Text.Encoding]::GetEncoding("UTF-8").GetString($xmlVDIAccess.ToArray())
	$streamWriter.Write($strVDIAccessXML)
	$streamWriter.Close()

	Log("Generated VDI Access file $vdiFilePath")

    $vdiUploadDirectory = Join-Path (GetUploadDirectory) "VdiAccess"

    if (!(Test-Path $vdiUploadDirectory)) {
        throw "ERROR: Unable to locate the VDI upload directory '$vdiUploadDirectory'"
    }
    Move-Item -Path $vdiFilePath -Destination $vdiUploadDirectory -Force
    Log("The file '$vdiFileName' has been moved to the folder '$vdiUploadDirectory'")

}


#-----------------------------------------------------------

function WriteInventoryData([hashtable]$MachineData, [string]$SiteName, [string]$ConnectionServer)
{
    # Initialise XML file
   	$xmlInventory = New-Object System.IO.MemoryStream
	$xmlInventoryWriterSettings = New-Object System.XML.XmlWriterSettings
	$xmlInventoryWriterSettings.Indent = $true
	$xmlInventoryWriterSettings.Encoding = [System.Text.Encoding]::UTF8
	$xmlInventoryWriter = [System.XML.XMLWriter]::Create($xmlInventory, $xmlInventoryWriterSettings)
	$xmlInventoryWriter.WriteStartDocument()	
	
	# Work around known bug in powershell "cannot pass null into .NET method that has a parameter of type string
	# = Set up the parameters you want to pass to the method: # And invoke it using .Net reflection:
	$params = @("Inventory", "Inventory", "http://www.managesoft.com/inventory.dtd", $null)
	$xmlInventoryWriter.GetType().GetMethod("WriteDocType").Invoke($xmlInventoryWriter, $params) | Out-Null


    # Build root Inventory node
    # It will be in the form:
    #   <Inventory Tracker="{Agent Version}" Audience="Machine" Scope="{Connection Server FQDN}" MachineName="{Connection Server}" UserName="system" Hardware="False" Software="False" ServiceProviders="True" DateTime="{YYYYMMDDTHHMMSS}" Type="Full">
    #
    # e.g. 
    #   <Inventory Tracker="16.0" Audience="Machine" Scope="myconnectionserver.mydomain.com" MachineName="myconnectionserver" UserName="system" Hardware="False" Software="False" ServiceProviders="True" DateTime="20210128T123848" Type="Full">
	$xmlInventoryWriter.WriteStartElement("Inventory")		
	$xmlInventoryWriter.WriteAttributeString("Tracker", $Script:AgentVersion)
	$xmlInventoryWriter.WriteAttributeString("Audience", "Machine")
	$xmlInventoryWriter.WriteAttributeString("Scope", $ConnectionServer)
	$xmlInventoryWriter.WriteAttributeString("MachineName", $ConnectionServer.Split(".")[0])
	$xmlInventoryWriter.WriteAttributeString("Username", "system")
	$xmlInventoryWriter.WriteAttributeString("Hardware", "False")
	$xmlInventoryWriter.WriteAttributeString("Software", "False")
	$xmlInventoryWriter.WriteAttributeString("ServiceProviders", "True")
	$xmlInventoryWriter.WriteAttributeString("DateTime", $script:StartTime)
	$xmlInventoryWriter.WriteAttributeString("Type", "Full")

    # Build ServiceProvider node
    # It will be in the form:
    #   <ServiceProvider Type="VDIBroker" Name="{Connection Server}">
    #       <Property Name="VDIBrokerType" Value="VMWareView"/>
    #       <Property Name="VDISiteName" Value="{Site Name}"/>
    #       <ServiceProvider Type="VDIDevice" Name="{domain}\{machine 1 name}">
    #           <Property Name="MachineId" Value="{Machine ID}" />
    #           <Property Name="MachineName" Value="{domain}\{machine 1 name}" />
    #           <Property Name="DNSFullName" Value="{machine 1 FQDN}" />
    #           <Property Name="VDIGroupName" Value="{Desktop Pool Name}" />
    #           <Property Name="VDITemplateName" Value="{Desktop Pool Name} (Template)" />
    #           <Property Name="PersistentVDI" Value="{Persistence}" />
    #       </ServiceProvider> 
    #       <ServiceProvider Type="VDIDevice" Name="{domain}\{machine 2 name}">
    #           ...
    #       </ServiceProvider>
    #       ...
    #   </ServiceProvider>
    #

    # VDIBroker ServiceProvider element
    $xmlInventoryWriter.WriteStartElement("ServiceProvider")
	$xmlInventoryWriter.WriteAttributeString("Type", "VDIBroker")
	$xmlInventoryWriter.WriteAttributeString("Name", $ConnectionServer.Split(".")[0])

    # VDIBroker ServiceProvider properties
	$xmlInventoryWriter.WriteStartElement("Property")
	$xmlInventoryWriter.WriteAttributeString("Name", "VDIBrokerType")
	$xmlInventoryWriter.WriteAttributeString("Value", "VMWareView")
	$xmlInventoryWriter.WriteEndElement()

	$xmlInventoryWriter.WriteStartElement("Property")
	$xmlInventoryWriter.WriteAttributeString("Name", "VDISiteName")
	$xmlInventoryWriter.WriteAttributeString("Value", $SiteName)
	$xmlInventoryWriter.WriteEndElement()

    foreach ($machineID in $MachineData.Keys)
    {   
        $machine = $MachineData[$machineId]

        Log "Adding the VDI Device '$($machine.NetBiosDomain)\$($machine.Name)' to the VDI access file"
        # VDIDevice ServiceProvider element
        $xmlInventoryWriter.WriteStartElement("ServiceProvider")
	    $xmlInventoryWriter.WriteAttributeString("Type", "VDIDevice")
	    $xmlInventoryWriter.WriteAttributeString("Name", "$($machine.NetBiosDomain)\$($machine.Name))")

        # VDIDevice ServiceProvider properties
	    $xmlInventoryWriter.WriteStartElement("Property")
	    $xmlInventoryWriter.WriteAttributeString("Name", "MachineId")
	    $xmlInventoryWriter.WriteAttributeString("Value", $machine.MachineId)
	    $xmlInventoryWriter.WriteEndElement() 

	    $xmlInventoryWriter.WriteStartElement("Property")
	    $xmlInventoryWriter.WriteAttributeString("Name", "MachineName")
	    $xmlInventoryWriter.WriteAttributeString("Value", "$($machine.NetBiosDomain)\$($machine.Name)")
	    $xmlInventoryWriter.WriteEndElement() 

	    $xmlInventoryWriter.WriteStartElement("Property")
	    $xmlInventoryWriter.WriteAttributeString("Name", "DNSFullName")
	    $xmlInventoryWriter.WriteAttributeString("Value", $machine.DnsName)
	    $xmlInventoryWriter.WriteEndElement() 

	    $xmlInventoryWriter.WriteStartElement("Property")
	    $xmlInventoryWriter.WriteAttributeString("Name", "VDIGroupName")
	    $xmlInventoryWriter.WriteAttributeString("Value", $machine.DesktopPoolName)
	    $xmlInventoryWriter.WriteEndElement() 

	    $xmlInventoryWriter.WriteStartElement("Property")
	    $xmlInventoryWriter.WriteAttributeString("Name", "VDITemplateName")
	    $xmlInventoryWriter.WriteAttributeString("Value", "$($machine.DesktopPoolName) (Template)")
	    $xmlInventoryWriter.WriteEndElement() 

	    $xmlInventoryWriter.WriteStartElement("Property")
	    $xmlInventoryWriter.WriteAttributeString("Name", "PersistentVDI")
	    $xmlInventoryWriter.WriteAttributeString("Value", $machine.Persistent)
	    $xmlInventoryWriter.WriteEndElement()

	    $xmlInventoryWriter.WriteStartElement("Property")
	    $xmlInventoryWriter.WriteAttributeString("Name", "VDIGroupUUID")
	    $xmlInventoryWriter.WriteAttributeString("Value", $machine.DesktopPoolUid)
	    $xmlInventoryWriter.WriteEndElement()
        
	    $xmlInventoryWriter.WriteStartElement("Property")
	    $xmlInventoryWriter.WriteAttributeString("Name", "ApplicationDeliveryOnly")
	    $xmlInventoryWriter.WriteAttributeString("Value", "0")
	    $xmlInventoryWriter.WriteEndElement()
        
        $xmlInventoryWriter.WriteEndElement() # VDIDevice ServiceProvider        
    }

    $xmlInventoryWriter.WriteEndElement() # VDIBroker ServiceProvider        


	$xmlInventoryWriter.WriteEndDocument()
	$xmlInventoryWriter.Flush()
	$xmlInventoryWriter.Close()

    
    $ndifilename = $ConnectionServer + " at " + $script:StartTime + " (VMwareView).ndi"
    $ndiFilePath = join-path -path $env:TEMP -childpath $ndifilename 

    if (Test-Path $ndiFilePath -PathType Leaf) {
        Remove-Item $ndiFilePath -Force
    }
	$streamWriter = New-Object System.IO.StreamWriter($ndiFilePath)
	$strInventoryXML = [System.Text.Encoding]::GetEncoding("UTF-8").GetString($xmlInventory.ToArray())
	$streamWriter.Write($strInventoryXML)
	$streamWriter.Close()

	Log("Generated Inventory file $ndiFilePath")

    $ndiUploadDirectory = Join-Path (GetUploadDirectory) "Inventories"

    if (!(Test-Path $ndiUploadDirectory)) {
        throw "ERROR: Unable to locate the Inventories upload directory '$ndiUploadDirectory'"
    }
    Move-Item -Path $ndiFilePath -Destination $ndiUploadDirectory -Force
    Log("The file '$ndifilename' has been moved to the folder '$ndiUploadDirectory'")
 
}


#-----------------------------------------------------------

function GetUploadDirectory()
{
    $manageSoftCommonKey = "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\Common"

    if (Test-Path $manageSoftCommonKey) {
        $key = Get-ItemProperty -Path $manageSoftCommonKey

        return $key.UploadDirectory
    } else {
        throw "ERROR: The registry name 'UploadDirectory' does not exist under the key '$manageSoftCommonKey'"
    }
}

#-----------------------------------------------------------

function GetDesktopPoolUid($desktopPoolId)
{		
	if ($script:CachedDesktopPoolUids.ContainsKey($desktopPoolId) -ne $true)
	{
        # VMWare Horizon does not use GUIDs for identification, so we create one here.
        # This means that every time that the script runs that there will be a new GUID
        # generated for each desktop pool.  This is not expected to be a problem
        # as the Guids are only used for internal references.
		$uid = [System.Guid]::NewGuid()
		$script:CachedDesktopPoolUids[$desktopPoolId] = $uid
	}

	return $script:CachedDesktopPoolUids[$desktopPoolId].ToString()
}

#-----------------------------------------------------------

function GetDesktopPools([object] $HVConnection)
{
    # Returns a hash in the form GlobalEntitlementID => object (Properties: Sids)
    $globalEntitlements = GetGlobalEntitlements($HVConnection)

    # Returns a hash in the form DesktopPoolId => object (Properties: Sids)
    $localDesktopPoolEntitlements = GetLocalDesktopPoolEntitlements($HVConnection)

    $query = New-Object "Vmware.Hv.QueryDefinition"
    $query.QueryEntityType = 'DesktopSummaryView'

    Log ""
    Log "------------------------------------------------------------------------------------------------------------------------------------------"
    Log " Reading Desktop Pools"
    Log "------------------------------------------------------------------------------------------------------------------------------------------"
    Log ""

    $desktopPools = @{}
    $queryResults = $con.ExtensionData.QueryService.QueryService_Create($query)
    $queryID =  $queryResults.id
    
    while ($queryResults.results)
    {
        $resultsPage = $queryResults.results

        foreach ($record in $resultsPage)
        {
            if ($record.desktopSummaryData) {
                $name = $record.desktopSummaryData.name
                $enabled = $record.desktopSummaryData.enabled
                $source = $record.desktopSummaryData.source
            } else {
                continue
            }

            $desktopPoolId = $record.id.id
            Log "Found Desktop Pool: name=$name; enabled=$enabled; source=$source; id=$desktopPoolId"
            if (!$enabled) 
            {
                Log "Skipping this desktop pool as it is not currently enabled"
                continue
            }


            $desktopPool = New-Object -TypeName PSObject
            $desktopPool | Add-Member -MemberType NoteProperty -Name "Name" -Value $name
            $desktopPool | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $enabled 
            $desktopPool | Add-Member -MemberType NoteProperty -Name "DesktopPoolUid" -Value (GetDesktopPoolUid($desktopPoolId))

            # According to the VMWare Horizon documentation "In VMware Horizon, you can create non-persistent desktops by leveraging instant clones"            
            # (https://docs.vmware.com/en/VMware-Horizon/2106/horizon-architecture-planning/GUID-AED54AE0-76A5-479B-8CD6-3331A85526D2.html)
            if ($source -eq "INSTANT_CLONE_ENGINE") {
                $persistent = $false
            } else {
                $persistent = $true
            }
            $desktopPool | Add-Member -MemberType NoteProperty -Name "Persistent" -Value $Persistent 

            $localEntitlementSids = @()
            if ($localDesktopPoolEntitlements.ContainsKey($desktopPoolID))
            {
                $localEntitlementSids = $localDesktopPoolEntitlements[$desktopPoolID].Sids        
            }

            $globalEntitlementSids = @()
            if ($record.desktopSummaryData.globalEntitlement) {
                Log "The desktop pool '$name' is linked to the '$($record.desktopSummaryData.globalEntitlement.id)' global entitlement"
                $globalEntitlementID = $record.desktopSummaryData.globalEntitlement.id
                if ($globalEntitlements.ContainsKey($globalEntitlementID))
                {
                    $globalEntitlementSids = $globalEntitlements[$globalEntitlementID].Sids
                }

            } else {
                Log "The desktop pool '$name' does not have a global entitlement"
            }

            $sids = ($localEntitlementSids + $globalEntitlementSids) | Select-Object -Unique

            $desktopPool | Add-Member -MemberType NoteProperty -Name "Sids" -Value $sids 

            $desktopPools.Add($desktopPoolID, $desktopPool)
        }

        $queryResults = $con.ExtensionData.QueryService.QueryService_GetNext($queryID)
    }
    
    $con.ExtensionData.QueryService.QueryService_Delete($queryID)

    return $desktopPools
}


#-----------------------------------------------------------

function GetGlobalEntitlements([object] $HVConnection)
{
    Log ""
    Log "------------------------------------------------------------------------------------------------------------------------------------------"
    Log "Listing Globally Entitled Users or Groups"
    Log "------------------------------------------------------------------------------------------------------------------------------------------"
    Log ""
    
    $query = New-Object "Vmware.Hv.QueryDefinition"
    $query.QueryEntityType = 'EntitledUserOrGroupGlobalSummaryView'


    $globalEntitlements = @{}
    $queryResults = $con.ExtensionData.QueryService.QueryService_Create($query)
    $queryID =  $queryResults.id
    

    while ($queryResults.results)
    {
        $resultsPage = $queryResults.results

        foreach ($record in $resultsPage)
        {
            if ($record.base) {
                $sID = $record.base.sid
                $isGroup = $record.base.group
                $domain = $record.base.domain
                $loginName = $record.base.loginName
            } else {
                continue
            }

            Log "Reading global entitlements for the Active Directory user or group: sID=$sID; Domain=$domain; loginName=$loginName; isGroup=$isGroup"

            if ($record.globalData) 
            {
                if (!$record.globalData.globalEntitlements)
                {
                    Log "There are no global entitlements for the AD group/user '$domain\$loginName'"
                }

                foreach ($ge in $record.globalData.globalEntitlements) 
                {                    
                    Log "Found global entitlement '$($ge.id)' for AD group/user '$domain\$loginName'"
                    if (!$globalEntitlements.ContainsKey($ge.id)) 
                    {
                        $globalEntitlement = New-Object -TypeName PSObject
                        $globalEntitlement | Add-Member -MemberType NoteProperty -Name "Sids" -Value @()
                        $globalEntitlements.Add($ge.id, $globalEntitlement)
                    }

                    $existingSids = $globalEntitlements[$ge.id].Sids
      
                    if (!$($existingSids.Contains($sID))) 
                    {
                        $globalEntitlements[$ge.id].Sids = $existingSids + $sID 
                    }
                }
            }
        }

        $queryResults = $con.ExtensionData.QueryService.QueryService_GetNext($queryID)
    }
    
    $con.ExtensionData.QueryService.QueryService_Delete($queryID)

    return $globalEntitlements
}


#-----------------------------------------------------------

function GetLocalDesktopPoolEntitlements([object] $HVConnection)
{
    Log ""
    Log "------------------------------------------------------------------------------------------------------------------------------------------"
    Log "Listing Locally Entitled Users or Groups"
    Log "------------------------------------------------------------------------------------------------------------------------------------------"
    Log ""
    
    $query = New-Object "Vmware.Hv.QueryDefinition"
    $query.QueryEntityType = 'EntitledUserOrGroupLocalSummaryView'

    $localDesktopPoolEntitlements = @{}
    $queryResults = $con.ExtensionData.QueryService.QueryService_Create($query)
    $queryID =  $queryResults.id
    
    while ($queryResults.results)
    {
        $resultsPage = $queryResults.results

        foreach ($record in $resultsPage)
        {
            if ($record.base) {
                $sID = $record.base.sid
                $isGroup = $record.base.group
                $domain = $record.base.domain
                $loginName = $record.base.loginName
            } else {
                continue
            }

            Log "Reading local entitlements for the Active Directory user or group: sID=$sID; Domain=$domain; loginName=$loginName; isGroup=$isGroup"

            if ($record.localData) 
            {
                if (!$record.localData.desktops)
                {
                    Log "There are no local desktop pool entitlements for the AD group/user '$domain\$loginName'"
                }

                foreach ($dp in $record.localData.desktops) 
                {                    
                    Log "Found desktop pool '$($dp.id)' that AD group/user '$domain\$loginName' is entitled to"
                    if (!$localDesktopPoolEntitlements.ContainsKey($dp.id)) 
                    {
                        $localDesktopPoolEntitlement = New-Object -TypeName PSObject
                        $localDesktopPoolEntitlement | Add-Member -MemberType NoteProperty -Name "Sids" -Value @()
                        $localDesktopPoolEntitlements.Add($dp.id, $localDesktopPoolEntitlement)
                    }

                    $existingSids = $localDesktopPoolEntitlements[$dp.id].Sids
      
                    if (!$($existingSids.Contains($sID))) 
                    {
                        $localDesktopPoolEntitlements[$dp.id].Sids = $existingSids + $sID 
                    }
                }
            }
        }

        $queryResults = $con.ExtensionData.QueryService.QueryService_GetNext($queryID)
    }
    
    $con.ExtensionData.QueryService.QueryService_Delete($queryID)

    return $localDesktopPoolEntitlements
}


#-----------------------------------------------------------
# This function returns a hashtable containing all VMs that
# are managed within this Connection Server's Pod.
#
# The hashtable key value pairs are in the form machineId = MachineObject
# where MachineObject is a custom object that has the following attributes:
# - Name
# - DnsName
# - DesktopPoolName
# - Persistent
# - MachineID
# - NetBiosDomain
#

function GetMachineData([object] $HVConnection, [hashtable] $DesktopPools)
{
    $query = New-Object "Vmware.Hv.QueryDefinition"
    $query.QueryEntityType = 'MachineSummaryView'

    Log ""
    Log "------------------------------------------------------------------------------------------------------------------------------------------"
    Log " Reading Machines"
    Log "------------------------------------------------------------------------------------------------------------------------------------------"
    Log ""

    $machines = @{}
    $queryResults = $con.ExtensionData.QueryService.QueryService_Create($query)
    $queryID =  $queryResults.id
    $domains = @{}

    while ($queryResults.results)
    {
        $resultsPage = $queryResults.results

        foreach ($record in $resultsPage)
        {
            $machineId = $record.id.id
            if (!$record.Base) {
                continue
            }

            $name = $record.Base.name
            $dnsName = $record.Base.dnsName
            if (($dnsName) -and ($dnsName.IndexOf('.') -gt 0)) { 
                $qualifieddomain = $dnsName.Substring($dnsName.IndexOf('.') +1)
                if ($domains.ContainsKey("$qualifieddomain"))
                {
                    $netBiosDomain = $domains[$qualifieddomain]
                } else {
                    $netBiosDomain = (Get-ADDomain $qualifieddomain).NetBIOSName
                    $domains.Add($qualifieddomain, $netBiosDomain)
                }
            } else {
                $netBiosDomain = ""
            }
            $desktopPoolId = $record.Base.Desktop.id

            if ($DesktopPools.ContainsKey($desktopPoolId))
            {
                $desktopPoolName = $DesktopPools[$desktopPoolId].Name
                $persistent = $DesktopPools[$desktopPoolId].Persistent
                $DesktopPoolUid = $DesktopPools[$desktopPoolId].DesktopPoolUid
            }

            Log "Found machine: name=$name; dnsName=$dnsName; desktopPool=$desktopPoolName; persistent=$persistent; id=$machineId; netBiosDomain=$netBiosDomain"

            $machine = New-Object -TypeName PSObject
            $machine | Add-Member -MemberType NoteProperty -Name "Name" -Value $name
            $machine | Add-Member -MemberType NoteProperty -Name "DnsName" -Value $dnsName
            $machine | Add-Member -MemberType NoteProperty -Name "DesktopPoolName" -Value $desktopPoolName
            $machine | Add-Member -MemberType NoteProperty -Name "Persistent" -Value $persistent
            $machine | Add-Member -MemberType NoteProperty -Name "MachineID" -Value $machineId
            $machine | Add-Member -MemberType NoteProperty -Name "NetBiosDomain" -Value $netBiosDomain
            $machine | Add-Member -MemberType NoteProperty -Name "DesktopPoolUid" -Value $DesktopPoolUid

            $machines.Add($machineId, $machine)
        }

        $queryResults = $con.ExtensionData.QueryService.QueryService_GetNext($queryID)
    }
    
    $con.ExtensionData.QueryService.QueryService_Delete($queryID)

    return $machines
}

#-----------------------------------------------------------
# 

function AddCredManager()
{
    $credManDefinition = @"
    using System.Text;
    using System;
    using System.Runtime.InteropServices;

    namespace CredManager {
      [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
      public struct CredentialMem
      {
        public int flags;
        public int type;
        public string targetName;
        public string comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME lastWritten; // .NET 2.0
        public int credentialBlobSize;
        public IntPtr credentialBlob;
        public int persist;
        public int attributeCount;
        public IntPtr credAttribute;
        public string targetAlias;
        public string userName;
      }

      public class Credential {
        public string target;
        public string username;
        public string password;
        public Credential(string target, string username, string password) {
          this.target = target;
          this.username = username;
          this.password = password;
        }
      }

      public class Util
      {
        [DllImport("advapi32.dll", EntryPoint = "CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool CredRead(string target, int type, int reservedFlag, out IntPtr credentialPtr);

        public static Credential GetUserCredential(string target)
        {
          CredentialMem credMem;
          IntPtr credPtr;

          if (CredRead(target, 1, 0, out credPtr))
          {
            credMem = Marshal.PtrToStructure<CredentialMem>(credPtr);
            byte[] passwordBytes = new byte[credMem.credentialBlobSize];
            Marshal.Copy(credMem.credentialBlob, passwordBytes, 0, credMem.credentialBlobSize);
            Credential cred = new Credential(credMem.targetName, credMem.userName, Encoding.Unicode.GetString(passwordBytes));
            return cred;
          } else {
            throw new Exception("Failed to retrieve credentials");
          }
        }

        [DllImport("Advapi32.dll", SetLastError = true, EntryPoint = "CredWriteW", CharSet = CharSet.Unicode)]
        private static extern bool CredWrite([In] ref CredentialMem userCredential, [In] int flags);

        public static void SetUserCredential(string target, string userName, string password)
        {
          CredentialMem userCredential = new CredentialMem();

          userCredential.targetName = target;
          userCredential.type = 1;
          userCredential.userName = userName;
          userCredential.attributeCount = 0;
          userCredential.persist = 3;
          byte[] bpassword = Encoding.Unicode.GetBytes(password);
          userCredential.credentialBlobSize = (int)bpassword.Length;
          userCredential.credentialBlob = Marshal.StringToCoTaskMemUni(password);
          if (!CredWrite(ref userCredential, 0))
          {
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
          }
        }
      }
    }
"@

	try
	{
		Log "Checking if CredManager.Util type is already added"
		$null = [CredManager.Util]
	}
	catch
	{
		Log "Adding CredMan type"
		Add-Type $credManDefinition -Language CSharp -ErrorAction Stop
	}
}

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Process parameters
if ($help) {
	Get-Help $MyInvocation.InvocationName 
	exit
}

if (!($LogFolder))
{
	Write-Host "No log folder has been specified"

	$Script:LogFolder = $env:TEMP

	Write-Host "The log file '$LogFileName' will be written to $LogFolder"
}
InitialiseLog

if ($StoreCredentials) 
{
    if (!($CredentialStoreName))
    {
        Write-Host "No credential store name has been specified"
	    Get-Help $MyInvocation.InvocationName 
	    exit
    }

    if (!($UserName))
    {
        Write-Host "No user name has been specified"
	    Get-Help $MyInvocation.InvocationName 
	    exit
    }

    if (!($Password))
    {
        Write-Host "No password has been specified"
	    Get-Help $MyInvocation.InvocationName 
	    exit
    }
    AddCredManager
    try {
        [CredManager.Util]::SetUserCredential($credentialStoreName, $UserName, $Password)
    } catch {
        Write-Host "$_"
        Write-Host "Failed to register credentials in the credential store under the name '$credentialStoreName'.  Details: $($_.Exception.Message)"
        exit
    }

    Write-Host "Successfully registered the credentials in the Windows Credential Store."
    exit
}


if (!($ConnectionServer))
{
	Write-Host "No Horizon Connection Server has been specified"

	Get-Help $MyInvocation.InvocationName 
	exit
}

[pscredential]$Credential = $null
if ($UseStoredCredentials) 
{
    AddCredManager

    if (!($CredentialStoreName))
    {
        Write-Host "No credential store name has been specified"
	    Get-Help $MyInvocation.InvocationName 
	    exit
    }

    Write-Host "Checking the Windows Credential Manager for generic credentials named '$CredentialStoreName' ..."
    try {
        $credManCred = [CredManager.Util]::GetUserCredential($CredentialStoreName)
        $Credential = New-Object PSCredential($credManCred.username, (ConvertTo-SecureString $credManCred.password -AsPlainText -Force))
    } catch {
        Write-Host "$_"
        Write-Host "No credentials named '$CredentialStoreName' are registered in the current user's Windows Credential Store on this machine."
        exit
    }
} else {
    if (!($UserName))
    {
        Write-Host "No user name has been specified"
	    Get-Help $MyInvocation.InvocationName 
	    exit
    }

    if (!($Password))
    {
        Write-Host "No password has been specified"
	    Get-Help $MyInvocation.InvocationName 
	    exit
    }

    $Credential = New-Object PSCredential($UserName, (ConvertTo-SecureString $Password -AsPlainText -Force))
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------

try {
    $con = ConnectHVServer $Credential

    # For informational purposes, let's find out which Pod Federation this Pod is in
    $podFederation = $con.ExtensionData.PodFederation.PodFederation_Get()

    if (($podFederation) -and ($podFederation.Data)) {
        Log "Pod Federation: Name=$($podFederation.Data.DisplayName); Guid=$($podFederation.Data.Guid)"
    } else {
        Log "This Pod is not in a Pod Federation"
    }

    # The VMWare Pod is the equivalent of a what FNMS considers to be a "site".  Each POD will have its own set of 
    # desktop pools.  These pools can be assigned to AD users or groups through either local entitlements (i.e. local to the Pod) 
    # or global entitlements (i.e. used across the whole Pod Federation).

    Log "Listing all Pods ..."
    $pods = $con.ExtensionData.Pod.Pod_List()
    $localPod = $null
    foreach ($pod in $pods)
    {
        Log "Pod: DisplayName=$($pod.DisplayName); LocalPod=$($pod.LocalPod)"
        if ($pod.LocalPod){
            $localPod = $pod
        }
    }

    $desktopPools = GetDesktopPools($con)
    WriteVDIAccessData -DesktopPools $desktopPools -SiteName $localPod.DisplayName -ConnectionServer $ConnectionServer

    $machineData = GetMachineData -HVConnection $con -DesktopPools $desktopPools
    WriteInventoryData -MachineData $machineData -SiteName $localPod.DisplayName -ConnectionServer $ConnectionServer
} catch {
    Log "ERROR: $_" -Level Error
}

FinaliseLog

