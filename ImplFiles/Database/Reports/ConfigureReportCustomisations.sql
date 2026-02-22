---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure data model
-- customisations for this FlexNet Manager Suite implementation.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

USE $(DBName)
GO

SET NOCOUNT ON
PRINT 'Configuring report customizations'
GO

DECLARE @Query varchar(2000)

-- Configure custom report: Report installation log records from FNMS agent packages
PRINT 'Custom Report: Installation log records from FNMS agent packages'
SET @Query = 
'
  SELECT 
    --ins.[ComputerID]
    c.ComputerCN
    --,ins.[UserID]
    --,ins.[PackageVersionID]
    ,pf.[PackageName]
    ,pp.[PackageFullName]
    ,pv.[Version]
    --,ins.[OrganizationID]
    ,ins.[Action]
    ,ins.[Reported]
    ,ins.[Received]
    --,ins.[FailReasonID]
    ,ins.[Result]
    --,ins.[TenantID]
    --,pv.[PackagePathID]
    --,pv.[PackageFamilyID]
  FROM [FNMSInventory].[dbo].[Installation_MT] AS ins
    JOIN [FNMSInventory].[dbo].[PackageVersion] AS pv ON ins.PackageVersionID = ins.PackageVersionID
    JOIN [FNMSInventory].[dbo].[PackagePath] AS pp ON pp.PackagePathID = pv.PackagePathID
    JOIN [FNMSInventory].[dbo].[PackageFamily] AS pf ON pf.PackageFamilyID = pv.PackageFamilyID
    JOIN [FNMSInventory].[dbo].[Computer_MT] AS c ON c.[ComputerID] = ins.ComputerID
'
EXEC dbo.CustomDefineCustomReport
  @SearchFolder = N'Crayon Diagnostics'
  , @SearchName = N'FNMS Package Install History'
  , @Description = N'This view lists installation log records from FNMS agent packages.'
  , @ComplianceSearchTypeName = 'Custom'  
  , @SearchSQL = @Query
  , @SearchXML = N''  
  , @SearchMapping = N'<ArrayOfCustomViewColumnMapping />'
  , @SearchGridLayout = N''
  , @CanDelete = True
  , @CanChangeMasterObject = True
  , @ComplianceSavedSearchSystemID = NULL
  , @SearchSQLConnection = N'Live'    

-- Configure custom report: Reports import detail result records from an MGSBI run
PRINT 'Custom Report: Business Adapter Import Details'
SET @Query = 
'
SELECT 
  ais.[ImportID]
  ,ais.[ImportName]
  ,ais.[ImportType]
  ,aio.[EndDate]
  ,aid.[RecordNumber]
  ,aid.[Action]
  ,aio.[ObjectName]
  ,aid.[RecordDescription]
  ,aid.[Message]
FROM dbo.[ECMImportLog_Detail] AS aid
  JOIN dbo.[ECMImportLog_Object] as aio on aio.[ImportObjectID] = aid.[ImportObjectID]
	JOIN dbo.[ECMImportLog_Summary] as ais on ais.[ImportID] = aid.[IMportID]      
'
EXEC dbo.CustomDefineCustomReport
  @SearchFolder = N'Crayon Diagnostics'
  , @SearchName = N'Business Adapter Import Details'
  , @Description = N'This report lists import detail result records from an MGSBI run.'
  , @ComplianceSearchTypeName = 'Custom'  
  , @SearchSQL = @Query
  , @SearchXML = N''  
  , @SearchMapping = N'<ArrayOfCustomViewColumnMapping />'
  , @SearchGridLayout = N''
  , @CanDelete = True
  , @CanChangeMasterObject = True
  , @ComplianceSavedSearchSystemID = NULL
  , @SearchSQLConnection = N'Live'    

-- Configure custom report: Reports import summary result records from an MGSBI run
PRINT 'Custom Report: Business Adapter Import Summary'
SET @Query = 
'
SELECT 
  ais.[ImportID]
  ,ais.[ImportName]
  ,ais.[ImportType]
  ,ais.[Action]
  ,ais.[StartDate]
  ,ais.[EndDate]
  ,ais.[Status]
  ,ais.[Processed]
  ,ais.[Rejected]
FROM dbo.[ECMImportLog_Summary] AS ais
'
EXEC dbo.CustomDefineCustomReport
  @SearchFolder = N'Crayon Diagnostics'
  , @SearchName = N'Business Adapter Import Summary'
  , @Description = N'This report lists import summary result records from an MGSBI run.'
  , @ComplianceSearchTypeName = 'Custom'  
  , @SearchSQL = @Query
  , @SearchXML = N''  
  , @SearchMapping = N'<ArrayOfCustomViewColumnMapping />'
  , @SearchGridLayout = N''
  , @CanDelete = True
  , @CanChangeMasterObject = True
  , @ComplianceSavedSearchSystemID = NULL
  , @SearchSQLConnection = N'Live'    

GO
