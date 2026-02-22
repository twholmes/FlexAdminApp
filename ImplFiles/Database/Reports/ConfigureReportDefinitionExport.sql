---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure custom views, functions
-- and procedures that are used by the Automation reports.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Make sure that an Automation Custom View Folders exists

DECLARE @RootViewID int
SET @RootViewID = (SELECT ComplianceSearchFolderID FROM dbo.ComplianceSearchFolder WHERE NameResourceName = 'ComplianceSearchFolder.Reports')

-- Find and Create the Automation Custom View Folder
DECLARE @AutomationFolder NVARCHAR(128)
SET @AutomationFolder = 'Automation Views'

DECLARE @ComplianceSearchTypeID int
SELECT @ComplianceSearchTypeID = [ComplianceSearchTypeID] FROM [dbo].[ComplianceSearchType] WHERE TypeName = 'Custom'

IF NOT EXISTS (SELECT ComplianceSearchFolderID FROM dbo.ComplianceSearchFolder WHERE Name = @AutomationFolder)
BEGIN
  INSERT INTO [ComplianceSearchFolder] ([Name],[ParentFolderID],[ComplianceSearchTypeID],[PredefinedSearchesCreated],[CanDelete],[RestrictedAccessTypeID])
  VALUES (@AutomationFolder, @RootViewID, @ComplianceSearchTypeID /* custom */, 0, 1, 1)
END

DECLARE @AutomationFolderID int
SET @AutomationFolderID = (SELECT [ComplianceSearchFolderID] FROM dbo.ComplianceSearchFolder WHERE Name = @AutomationFolder)


---------------------------------------------------------------------------
-- Custom View to show report definitions
--

DELETE FROM dbo.ComplianceSavedSearch WHERE SearchName = 'ReportDefinitionsExport' AND RestrictedAccessTypeID = 1

INSERT dbo.ComplianceSavedSearch(
  SearchName,
  [Description],
  SearchSQL,
  SearchMapping,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID,
  CreatedBy,
  CreationDate
)
VALUES(
  'ReportDefinitionsExport',
  'This view shows the definitions of all reports.',
  '
    SELECT  
      ss.[ComplianceSavedSearchID]
      ,ss.[SearchName]
      ,ss.[Description]
      ,dbo.CustomBase64Encode(ss.[SearchSQL])as [EncodedSearchSQL]
      ,dbo.CustomBase64Encode(CONVERT(nvarchar(max),ss.[SearchMapping])) AS [EncodedSearchMapping]
      ,dbo.CustomBase64Encode(CONVERT(nvarchar(max),ss.[SearchXML])) AS [EncodedSearchXML]
      ,ss.[CreationDate]
      --,ss.[ComplianceSearchTypeID]
      ,cst.[TypeName] AS [ComplianceSearchType]
      ,ss.[ComplianceSearchFolderID]
      --,csf.[Name] AS [FolderFullName]
      --,rsct.[ResourceValue] AS [FolderName]
      ,dbo.CustomGetFullFolderPath(ss.[ComplianceSearchFolderID]) AS [FullFolderName]
      ,ss.[CreatedByOperatorID]
      ,ss.[RestrictedAccessTypeID]
      ,ss.[CanDelete]
    FROM [dbo].[ComplianceSavedSearch] AS ss
      JOIN [dbo].[ComplianceSearchType] AS cst ON cst.ComplianceSearchTypeID = ss.ComplianceSearchTypeID
      JOIN [dbo].[ComplianceSearchFolder] as csf ON csf.ComplianceSearchFolderID = ss.ComplianceSearchFolderID
      --JOIN [dbo].[ResourceStringCultureType] as rsct on rsct.[ResourceString] = csf.NameResourceName AND rsct.CultureType = ''en-US''
    WHERE ss.ComplianceSearchTypeID > 0 and ss.ComplianceSavedSearchSystemID is NULL
  ',
  NULL,
  @ComplianceSearchTypeID /* custom query */,
  @AutomationFolderID,
  SYSTEM_USER,
  GETUTCDATE()
)

GO