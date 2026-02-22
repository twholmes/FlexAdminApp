---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure data model
-- customisations for this FlexNet Manager Suite implementation.
--
-- Copyright (C) 2017 Flexera Software
---------------------------------------------------------------------------

USE $(DBName)
GO

SET NOCOUNT ON
PRINT 'Configuring reports procedure customizations'

---------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.CustomCreateComplianceSearchTypeColumn') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.CustomCreateComplianceSearchTypeColumn
GO

CREATE PROCEDURE dbo.CustomCreateComplianceSearchTypeColumn
  @ComplianceSearchTypeName NVARCHAR(64)
  , @ColumnName NVARCHAR(128)
  , @FromTable NVARCHAR(MAX)
  , @SelectName NVARCHAR(MAX)
  , @WhereClause NVARCHAR(MAX)
  , @ColumnNameResourceName NVARCHAR(128) = NULL
  , @FilterGroupType INT = 1 /* string */
  , @RequiresSearchTypeName NVARCHAR(64) = NULL
  , @SelectByDefault BIT = 0
  , @Mandatory BIT = 0
  , @PrimaryKey BIT = 0
AS
-- Purpose: Create a ComplianceSearchTypeColumn record
--
PRINT 'Configuring custom view column "' + @ColumnName + '"'

-- Get local IDs for ComplianceSearchType
DECLARE @ComplianceSearchTypeID INT
SELECT @ComplianceSearchTypeID = ComplianceSearchTypeID FROM dbo.ComplianceSearchType WHERE TypeName = @ComplianceSearchTypeName

DECLARE @RequiresSearchTypeID INT
SELECT @RequiresSearchTypeID = ComplianceSearchTypeID FROM dbo.ComplianceSearchType WHERE TypeName = @RequiresSearchTypeName

-- Add custom software title classification
IF EXISTS(select ResourceString from [dbo].[ComplianceResourceString] where [ResourceString] like @ColumnNameResourceName)
  PRINT 'ComplianceResourceString ' + @ColumnNameResourceName + ' already exists in [ComplianceResourceString]'  
ELSE
BEGIN
  SET @ColumnNameResourceName = 'ComplianceSearchTypeColumn.' + @ColumnName
  INSERT INTO [dbo].[ComplianceResourceString] ([ResourceString])
  VALUES (@ColumnNameResourceName)
END

IF EXISTS(select ResourceString from [dbo].[ResourceStringCultureType] where [ResourceString] like @ColumnNameResourceName)
  PRINT 'ResourceStringCultureType ' + @ColumnNameResourceName + ' en-US already exists in [ResourceStringCultureType]'
ELSE
BEGIN
  SET @ColumnNameResourceName = 'ComplianceSearchTypeColumn.' + @ColumnName 
  INSERT INTO [dbo].[ResourceStringCultureType] ([ResourceString],[CultureType],[ResourceValue])
  VALUES (@ColumnNameResourceName,'en-US',@ColumnName)
END

-- Remove line breaks (since FNMP de-duplicates identical lines)
SET @FromTable = REPLACE(@FromTable, '
', ' ')

INSERT INTO dbo.ComplianceSearchTypeColumn (
  ColumnName,
  ColumnNameResourceName,
  FromTable,
  SelectName,
  JoinClause,
  WhereClause,
  SelectOptionsSQL,
  FilterGroupType,
  DefaultFilterType,
  ComplianceSearchTypeID,
  RequiresSearchTypeID,
  SelectByDefault,
  Mandatory,
  PrimaryKey
)
SELECT
  @ColumnName,
  @ColumnNameResourceName,
  @FromTable,
  @SelectName,
  '',
  @WhereClause,
  '',
  @FilterGroupType,
  @FilterGroupType,
  @ComplianceSearchTypeID,
  @RequiresSearchTypeID,
  @SelectByDefault,
  @Mandatory,
  @PrimaryKey
WHERE
  NOT EXISTS (
    SELECT 1
    FROM dbo.ComplianceSearchTypeColumn
    WHERE ColumnName = @ColumnName AND ComplianceSearchTypeID = @ComplianceSearchTypeID
  )

UPDATE dbo.ComplianceSearchTypeColumn
SET ColumnNameResourceName = @ColumnNameResourceName,
  FromTable = @FromTable,
  SelectName = @SelectName,
  JoinClause = '',
  WhereClause = @WhereClause,
  SelectOptionsSQL = '',
  FilterGroupType = @FilterGroupType,
  DefaultFilterType = @FilterGroupType,
  RequiresSearchTypeID = @RequiresSearchTypeID,
  SelectByDefault = @SelectByDefault,
  Mandatory = @Mandatory,
  PrimaryKey = @PrimaryKey
WHERE ColumnName = @ColumnName
  AND ComplianceSearchTypeID = @ComplianceSearchTypeID
  AND (
    ISNULL(ColumnNameResourceName, '') != ISNULL(@ColumnNameResourceName, '')
    OR ISNULL(FromTable, '') != ISNULL(@FromTable, '')
    OR SelectName != @SelectName
    OR JoinClause != ''
    OR WhereClause != @WhereClause
    OR SelectOptionsSQL != ''
    OR FilterGroupType != @FilterGroupType
    OR DefaultFilterType != @FilterGroupType
    OR ISNULL(RequiresSearchTypeID, -1) != ISNULL(@RequiresSearchTypeID, -1)
    OR SelectByDefault != @SelectByDefault
    OR Mandatory != @Mandatory
    OR PrimaryKey != @PrimaryKey
  )

IF @@ROWCOUNT > 0
BEGIN
  -- Force saved queries using this column to be recalculated
  UPDATE  css
  SET SearchSQL = NULL
  FROM  (
      SELECT  css.ComplianceSavedSearchID
      FROM  dbo.ComplianceSavedSearch AS css
        CROSS APPLY css.SearchXML.nodes('//column[@name]') T(cols)
        INNER JOIN dbo.ComplianceSearchTypeColumn AS cstc
          ON cstc.ColumnName = cols.value('@name', 'nvarchar(max)')
          AND cstc.ColumnName = @ColumnName
          AND cstc.ComplianceSearchTypeID = @ComplianceSearchTypeID

      UNION

      SELECT  css.ComplianceSavedSearchID
      FROM  dbo.ComplianceSavedSearch AS css
        CROSS APPLY css.SearchXML.nodes('//condition[@column]') T(cols)
        INNER JOIN dbo.ComplianceSearchTypeColumn AS cstc
          ON cstc.ColumnName = cols.value('@column', 'nvarchar(max)')
          AND cstc.ColumnName = @ColumnName
          AND cstc.ComplianceSearchTypeID = @ComplianceSearchTypeID
    ) AS cols
    INNER JOIN dbo.ComplianceSavedSearch css ON css.ComplianceSavedSearchID = cols.ComplianceSavedSearchID
  WHERE css.SearchSQL IS NOT NULL
END
GO

-- MUST UPDATE TO FIX @ComplianceSearchTypeID    !!!!!!
---------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.CustomDefineCustomView') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.CustomDefineCustomView
GO

CREATE PROCEDURE dbo.CustomDefineCustomView
  @SearchName NVARCHAR(64),
  @Description NVARCHAR(1000) = NULL,
  @SearchFolder NVARCHAR(128),
  @SearchGridLayout NTEXT = NULL,
  @SearchXML XML = NULL,
  @SearchSQL NTEXT = NULL,
  @SearchMapping XML = NULL,
  @ComplianceSearchTypeID INT
AS

-- Traverse down custom view folder hierarchy to find the required folder,
-- creating intermediate folder nodes as needed on the way down
DECLARE @n NVARCHAR(128)
DECLARE @Path NVARCHAR(128)
DECLARE @ComplianceSearchFolderID INT

SELECT @Path = ParentFolderID, @ComplianceSearchFolderID = ComplianceSearchFolderID
FROM dbo.ComplianceSearchFolder
WHERE ParentFolderID IS NULL and Name = 'Reports.Reports'

DECLARE c CURSOR STATIC FOR
SELECT s
FROM dbo.Split('/', @SearchFolder)
WHERE s != ''
ORDER BY pn

OPEN c

FETCH NEXT FROM c INTO @n
WHILE @@FETCH_STATUS = 0
BEGIN
  DECLARE @ChildComplianceSearchFolderID INT

  SET @ChildComplianceSearchFolderID = NULL

  SELECT @ChildComplianceSearchFolderID = ComplianceSearchFolderID
  FROM dbo.ComplianceSearchFolder
  WHERE ParentFolderID = @ComplianceSearchFolderID
    AND Name = @n

  IF @ChildComplianceSearchFolderID IS NULL
  BEGIN
    EXEC @ChildComplianceSearchFolderID = dbo.ComplianceSearchFolderAdd @Name = @n, @ParentFolderID = @ComplianceSearchFolderID, @ComplianceSearchTypeID = -1
  END

  SET @ComplianceSearchFolderID = @ChildComplianceSearchFolderID

  FETCH NEXT FROM c INTO @n
END
CLOSE c
DEALLOCATE c

-- Configure custom view (if it does not already exist)
INSERT INTO ComplianceSavedSearch (
  SearchName,
  Description,
  SearchGridLayout,
  SearchSQL,
  SearchMapping,
  SearchXML,
  CreatedBy,
  CreationDate,
  ModifiedBy,
  ModificationDate,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID
)
SELECT  @SearchName,
  @Description,
  @SearchGridLayout,
  @SearchSQL,
  @SearchMapping,
  @SearchXML,
  'Flexera Software',
  GETUTCDATE(),
  'Flexera Software',
  GETUTCDATE(),
  @ComplianceSearchTypeID,
  @ComplianceSearchFolderID
WHERE
  NOT EXISTS( -- Check  view of same name in same folder doesn't already exist
    SELECT  1
    FROM  ComplianceSavedSearch css
    WHERE css.SearchName = @SearchName
      AND css.ComplianceSearchFolderID = @ComplianceSearchFolderID
  )

GO

------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('dbo.CustomDefineReport') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
  DROP PROCEDURE dbo.CustomDefineReport
GO

CREATE PROCEDURE dbo.CustomDefineReport
  @SearchName NVARCHAR(64)
  ,@Description nvarchar(1000) = NULL
  ,@SearchFolder NVARCHAR(128) -- Separate folder levels with "/"
  ,@SearchGridLayout NTEXT = NULL
  ,@SearchXML XML = NULL
  ,@SearchSQL NTEXT = NULL
  ,@SearchMapping XML = NULL
  ,@ComplianceSearchTypeName NVARCHAR(64) = 'Custom'
AS
-- Purpose: Configure a report
PRINT 'Configuring report ' + @SearchFolder + '/' + @SearchName

-- Translate the SearchTypeName
DECLARE @ComplianceSearchTypeID INT
SELECT @ComplianceSearchTypeID = ComplianceSearchTypeID FROM dbo.ComplianceSearchType WHERE TypeName = @ComplianceSearchTypeName

-- Traverse down custom view folder hierarchy to find the required folder,
-- creating intermediate folder nodes as needed on the way down
DECLARE @FolderName NVARCHAR(128)
DECLARE @Path NVARCHAR(128)
DECLARE @ComplianceSearchFolderID INT

SELECT @Path = ParentFolderID, @ComplianceSearchFolderID = ComplianceSearchFolderID
FROM dbo.ComplianceSearchFolder
WHERE ParentFolderID IS NULL and Name = 'Reports.Reports'

DECLARE c CURSOR STATIC FOR
SELECT s FROM dbo.Split('/', @SearchFolder) WHERE s != '' ORDER BY pn

OPEN c

FETCH NEXT FROM c INTO @FolderName
WHILE @@FETCH_STATUS = 0
BEGIN
  DECLARE @ChildComplianceSearchFolderID INT
  SET @ChildComplianceSearchFolderID = NULL

  SELECT @ChildComplianceSearchFolderID = ComplianceSearchFolderID FROM dbo.ComplianceSearchFolder WHERE ParentFolderID = @ComplianceSearchFolderID AND Name = @FolderName
  IF @ChildComplianceSearchFolderID IS NULL
  BEGIN
    EXEC @ChildComplianceSearchFolderID = dbo.ComplianceSearchFolderAdd @Name = @FolderName, @ParentFolderID = @ComplianceSearchFolderID, @ComplianceSearchTypeID = @ComplianceSearchTypeID
  END

  SET @ComplianceSearchFolderID = @ChildComplianceSearchFolderID

  FETCH NEXT FROM c INTO @FolderName
END
CLOSE c
DEALLOCATE c

-- Only update changed custom views with a type of "1" (custom query) since they are not-editable in the console.
-- Other types of custom views are never updated, as the user may have modified them and we do not
-- want to overwrite user changes.

UPDATE css
SET Description = ISNULL(@Description, Description),
  SearchGridLayout = ISNULL(@SearchGridLayout, SearchGridLayout),
  SearchSQL = ISNULL(@SearchSQL, SearchSQL),
  SearchMapping = ISNULL(@SearchMapping, SearchMapping),
  SearchXML = ISNULL(@SearchXML, SearchXML),
  ModifiedBy = 'Flexera Software',
  ModificationDate = GETUTCDATE()
FROM  dbo.ComplianceSavedSearch css
WHERE css.ComplianceSearchFolderID = @ComplianceSearchFolderID
  AND css.SearchName = @SearchName
  AND @ComplianceSearchTypeID = 1 /* custom query */
  AND (
    ISNULL(Description, '') != ISNULL(@Description, '') OR
    ISNULL(CAST(SearchGridLayout AS NVARCHAR(MAX)), '') != ISNULL(CAST(@SearchGridLayout AS NVARCHAR(MAX)), '') OR
    ISNULL(CAST(SearchSQL AS NVARCHAR(MAX)), '') != ISNULL(CAST(@SearchSQL AS NVARCHAR(MAX)), '') OR
    ISNULL(CAST(SearchMapping AS NVARCHAR(MAX)), '') != ISNULL(CAST(@SearchMapping AS NVARCHAR(MAX)), '') OR
    ISNULL(CAST(SearchXML AS NVARCHAR(MAX)), '') != ISNULL(CAST(@SearchXML AS NVARCHAR(MAX)), '')
  )

INSERT INTO dbo.ComplianceSavedSearch (
  SearchName,
  Description,
  SearchGridLayout,
  SearchSQL,
  SearchSQLConnection,
  SearchMapping,
  SearchXML,
  CreatedBy,
  CreationDate,
  ModifiedBy,
  ModificationDate,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID,
  RestrictedAccessTypeID,
  CanDelete,
  CanChangeMasterObject
)
SELECT
  @SearchName,
  @Description,
  @SearchGridLayout,
  @SearchSQL,
  'Live',
  @SearchMapping,
  @SearchXML,
  'Flexera Software',
  GETUTCDATE(),
  'Flexera Software',
  GETUTCDATE(),
  @ComplianceSearchTypeID,
  @ComplianceSearchFolderID,
  1,
  1,
  1
WHERE 
  NOT EXISTS( -- Don't touch existing view of same name in same folder
    SELECT  1
    FROM  dbo.ComplianceSavedSearch css
    WHERE css.SearchName = @SearchName
      AND css.ComplianceSearchFolderID = @ComplianceSearchFolderID
  )
GO

