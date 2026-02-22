---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure custom views under
-- the Automation custom view folder.   This folder is designed to store
-- views that expose tables that are used to configure automated tasks
-- like adapters.
--
-- Copyright (C) 2024 Crayon
---------------------------------------------------------------------------

USE $(DBName)
GO

---------------------------------------------------------------------------
-- Make sure that an EoSL Custom View Folders exists

DECLARE @RootViewID int
SET @RootViewID= (SELECT [ComplianceSearchFolderID] FROM ComplianceSearchFolder WHERE [Name] like 'Custom Views')

-- Find and Create the EoSL Custom View Folder
DECLARE @EOSLFolder NVARCHAR(128)
SET @EOSLFolder = 'Group Memberships'

IF NOT EXISTS (SELECT ComplianceSearchFolderID FROM ComplianceSearchFolder WHERE [Name] like @EOSLFolder)
BEGIN
  INSERT INTO [ComplianceSearchFolder] ([Name],[ParentFolderID],[ComplianceSearchTypeID],[PredefinedSearchesCreated],[CanDelete],[RestrictedAccessTypeID])
  VALUES (@EOSLFolder, @RootViewID, 1, 0, 1, 1)
END

DECLARE @EOSLFolderID int
SET @EOSLFolderID = (SELECT [ComplianceSearchFolderID] FROM ComplianceSearchFolder WHERE [Name] like @EOSLFolder)

---------------------------------------------------------------------------
-- Custom View to show current Group Memberships
--
DELETE FROM ComplianceSavedSearch WHERE SearchName like 'Group Memberships' AND RestrictedAccessTypeID = 1

INSERT ComplianceSavedSearch
(
  SearchName,
  [Description],
  SearchSQL,
  SearchMapping,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID,
  CreatedBy,
  CreationDate
)
VALUES
(
  'Group Memberships',
  'This report lists all current group memberships. (Based on a custom view CustomGroupsMemberships)',
  '
    SELECT
      gm.[ObjectID]
      ,gm.[Object]
      ,gm.[Name]
      ,gm.[GroupExID]
      ,gm.[GroupID]
      ,gm.[Description]
      ,gm.[GroupPath]
    FROM [dbo].[CustomGroupsMemberships] AS gm
    ORDER BY gm.[Object] DESC, gm.[ObjectID] DESC
  ',
  '<ArrayOfCustomViewColumnMapping />',
  1,
  @EOSLFolderID,
  SYSTEM_USER,
  GETUTCDATE()
)

---------------------------------------------------------------------------
-- Custom View to shows Group Change Proposals
--
DELETE FROM ComplianceSavedSearch WHERE SearchName like 'Group Change Proposals' AND RestrictedAccessTypeID = 1

INSERT ComplianceSavedSearch
(
  SearchName,
  [Description],
  SearchSQL,
  SearchMapping,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID,
  CreatedBy,
  CreationDate
)
VALUES
(
  'Group Change Proposals',
  'This report lists group change proposal. (Based on a custom view ECMImport_GroupChangeProposals)',
  '
    SELECT
      gcp.[ROWNUMBER]
      ,gcp.[OPAL]
      ,gcp.[OldPath]
      ,gcp.[NewPath]
    FROM [dbo].[ECMImport_GroupChangeProposals] AS gcp
    ORDER BY gcp.[OPAL] DESC
  ',
  '<ArrayOfCustomViewColumnMapping />',
  1,
  @EOSLFolderID,
  SYSTEM_USER,
  GETUTCDATE()
)


---------------------------------------------------------------------------
-- Custom View to shows Group Memberships Change Proposals
--
DELETE FROM ComplianceSavedSearch WHERE SearchName like 'Group Memberships Change Proposals' AND RestrictedAccessTypeID = 1

INSERT ComplianceSavedSearch
(
  SearchName,
  [Description],
  SearchSQL,
  SearchMapping,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID,
  CreatedBy,
  CreationDate
)
VALUES
(
  'Group Memberships Change Proposals',
  'This report lists group membership change proposal. (Based on the custom view CustomGroupMemberships, and ECMImport_GroupChangeProposals)',
  '
   SELECT     
      gm.[ObjectID]
      ,gm.[Object]
      ,gm.[Name]      
      ,gex.[GroupExID]
      ,gex.[GroupID]
      ,gm.[GroupPath]
      ,ngex.[GroupExID] as [NewGroupExID]  
      ,ngex.[GroupID] as [NewGroupID]          
      ,gcp.[NewPath]
    FROM [dbo].[CustomGroupsMemberships] AS gm
    JOIN [dbo].[ECMImport_GroupChangeProposals] AS gcp ON gm.[GroupPath] = gcp.[OldPath]
    JOIN [dbo].[GroupEx] as gex ON gm.[GroupPath] = gex.[Path]   
    JOIN [dbo].[GroupEx] as ngex ON gcp.[NewPath] = ngex.[Path] 
  ',
  '<ArrayOfCustomViewColumnMapping />',
  1,
  @EOSLFolderID,
  SYSTEM_USER,
  GETUTCDATE()
)

