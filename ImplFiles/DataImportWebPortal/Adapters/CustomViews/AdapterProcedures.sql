-- Copyright (C) 2020 Crayon Australia

--------------------------------------------------------------------------------------------------------
-- dbo.CustomCreateComplianceSearchFolder


IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomCreateComplianceSearchFolder') AND type = 'P')
  DROP PROCEDURE dbo.CustomCreateComplianceSearchFolder
GO

CREATE PROCEDURE dbo.CustomCreateComplianceSearchFolder
  @SearchFolderName NVARCHAR(128)
AS
  -- make sure that a base Custom Reports Folder exists
  DECLARE @RootViewID int
  SET @RootViewID = (SELECT [ComplianceSearchFolderID] FROM ComplianceSearchFolder WHERE [NameResourceName] like 'ComplianceSearchFolder.Reports')
          
  DECLARE @ComplianceSearchTypeID int
  SET @ComplianceSearchTypeID = (SELECT ComplianceSearchTypeID FROM ComplianceSearchType WHERE TypeName = 'Custom')
        
  DECLARE @NewFolderCount int
  SET @NewFolderCount = 0

  -- initialize parent folder
  DECLARE @ParentFolderName NVARCHAR(128)
  DECLARE @ParentFolderID int
  SET @ParentFolderID = @RootViewID

  -- split target folder path into sub-folders
  DECLARE @FolderPath table (rowid int identity(1,1), foldernode varchar(100))
  DELETE FROM @FolderPath
  INSERT INTO @FolderPath (foldernode) 
  SELECT s FROM Split('/', @SearchFolderName)

  DECLARE @SubFolderResourceName NVARCHAR(128)
  DECLARE @SubFolderName NVARCHAR(128)
  DECLARE @ChildComplianceSearchFolderID INT

  DECLARE @rowid int
  DECLARE @node varchar(100)
  DECLARE @rows int

  SELECT @rows = count(1) from @FolderPath
  WHILE (@rows > 0)
  BEGIN
    SELECT TOP 1 @rowid = rowid, @node = foldernode
    FROM @FolderPath

    -- make sure that the Node Folder exists
    SET @SubFolderResourceName = 'ComplianceSearchFolder.' + REPLACE(@Node, ' ', '')
    SET @SubFolderName = 'Reports.' + REPLACE(@Node, ' ', '')  
    SET @ChildComplianceSearchFolderID = NULL

    -- first check for a manually created folder
    SELECT @ChildComplianceSearchFolderID = ComplianceSearchFolderID FROM ComplianceSearchFolder WHERE [Name] like @Node and [NameResourceName] is null
    IF @ChildComplianceSearchFolderID IS NOT NULL
    BEGIN
    	-- a manually created folder was found but we also needs its parent-id
      SELECT @ParentFolderID = [ParentFolderID] FROM ComplianceSearchFolder WHERE [Name] like @Node and [NameResourceName] is null  
      SET @SubFolderName = @Node          	
    END
    ELSE   
    BEGIN
    	-- if a manually created folder was not found, then check for a folder created with a string table entry
      SELECT @ChildComplianceSearchFolderID = [ComplianceSearchFolderID] FROM ComplianceSearchFolder WHERE [Name] like @SubFolderName and [ParentFolderID] = @ParentFolderID    	
    END

    IF @ChildComplianceSearchFolderID IS NOT NULL
    BEGIN
      PRINT 'ComplianceSearchFolder found, ' + @SubFolderName + ', ' + CONVERT(varchar(20), @ChildComplianceSearchFolderID)
    END
    ELSE
    BEGIN
      PRINT 'ComplianceSearchFolder not found, ' + @SubFolderName + ', ' + CONVERT(varchar(20), @ChildComplianceSearchFolderID)  	  	
      IF EXISTS(select ResourceString from [dbo].[ComplianceResourceString] where [ResourceString] like @SubFolderResourceName)
        PRINT 'ComplianceResourceString ' + @SubFolderResourceName + ' already exists in [ComplianceResourceString]'  
      ELSE
      BEGIN
        INSERT INTO [dbo].[ComplianceResourceString] ([ResourceString])
        VALUES (@SubFolderResourceName)
      END
  	
      IF EXISTS(select ResourceString from [dbo].[ResourceStringCultureType] where [ResourceString] like @SubFolderResourceName)
      BEGIN
        PRINT 'ResourceStringCultureType ' + @SubFolderResourceName + ' en-US already exists in [ResourceStringCultureType]'
        UPDATE [dbo].[ResourceStringCultureType]
        SET [ResourceValue] = @Node
        WHERE [ResourceString] = @SubFolderResourceName and [CultureType] = 'en-US'
      END
      ELSE
      BEGIN
        INSERT INTO [dbo].[ResourceStringCultureType] ([ResourceString],[CultureType],[ResourceValue])
        VALUES (@SubFolderResourceName,'en-US',@Node)
      END
  	
      EXEC @ChildComplianceSearchFolderID = dbo.ComplianceSearchFolderAdd @Name = @SubFolderName, @ParentFolderID = @ParentFolderID, @ComplianceSearchTypeID = @ComplianceSearchTypeID, @NameResourceName = @SubFolderResourceName
      SET @NewFolderCount = @NewFolderCount + 1      
    END

    -- use the Node Folder ID as the next Parent
    SET @ParentFolderID = (SELECT [ComplianceSearchFolderID] FROM ComplianceSearchFolder WHERE [Name] like @SubFolderName and [ParentFolderID] = @ParentFolderID)

    DELETE FROM @FolderPath WHERE rowid = @rowid
    SELECT @rows = count(1) FROM @FolderPath
  END          
               
  -- the new Custom Reports Folder ID is the last itterated ID
  --SET @SearchFolderID = @ParentFolderID
  RETURN @ParentFolderID

GO


---------------------------------------------------------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = 'CustomBase64Encode')
  DROP FUNCTION dbo.CustomBase64Encode
GO

CREATE FUNCTION dbo.CustomBase64Encode(@text NVARCHAR(max))
  RETURNS nvarchar(max)
AS
BEGIN
  DECLARE @Encoded nvarchar(max) 
  -- Encode the string "TestData" in Base64 to get "VGVzdERhdGE="  
  SET @Encoded = (SELECT CAST(@text as varbinary(max)) FOR XML PATH(''), BINARY BASE64)
  RETURN @Encoded
END

GO

---------------------------------------------------------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = 'CustomBase64Decode')
  DROP FUNCTION dbo.CustomBase64Decode
GO

CREATE FUNCTION [dbo].[CustomBase64Decode](@coded NVARCHAR(max))
  RETURNS nvarchar(max)
AS
BEGIN
  DECLARE @text nvarchar(max) 
  -- Encode the string "TestData" in Base64 to get "VGVzdERhdGE="
  SET @text = ( CAST( CAST( @coded as XML ).value('.','varbinary(max)') AS nvarchar(max) ) )
  RETURN @text
END

GO

---------------------------------------------------------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = 'CustomGetFullFolderPath')
  DROP FUNCTION dbo.CustomGetFullFolderPath
GO

CREATE FUNCTION dbo.CustomGetFullFolderPath(@FolderID int)
  RETURNS nvarchar(256)
AS
BEGIN
  DECLARE @path nvarchar(128)
  SELECT @path = [Path] FROM [dbo].[ComplianceSearchFolder_MT] WHERE ComplianceSearchFolderID = @FolderID
  --PRINT @path

  -- split target folder path into sub-foders
  DECLARE @FolderPath table (rowid int identity(1,1), foldernode varchar(100))
  DELETE FROM @FolderPath
  INSERT INTO @FolderPath (foldernode) 
  SELECT s FROM Split('.', @path)

  DECLARE @RowID int
  DECLARE @SubFolderName nvarchar(128)
  DECLARE @NodeName nvarchar(128)   
  DECLARE @FullFolderPath nvarchar(256)  

  DECLARE FolderNodeCursor CURSOR FOR
  SELECT
    fp.rowid,
    csf.Name, 
    ISNULL(rsct.[ResourceValue], csf.[Name]) AS [NodeName]
  FROM @FolderPath as fp
    JOIN [dbo].[ComplianceSearchFolder_MT] as csf on csf.[ComplianceSearchFolderID] = fp.[foldernode]
    LEFT OUTER JOIN [dbo].[ResourceStringCultureType] as rsct on rsct.ResourceString = csf.[NameResourceName] and rsct.[CultureType] = 'en-US'

  OPEN FolderNodeCursor

  FETCH NEXT FROM FolderNodeCursor
  INTO @RowID, @SubFolderName, @NodeName
    
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF (@RowID = 1)
      SET @FullFolderPath = @NodeName
    ELSE
      SET @FullFolderPath = @FullFolderPath + '/' + @NodeName
 
    FETCH NEXT FROM FolderNodeCursor
    INTO @RowID, @SubFolderName, @NodeName
  END

  CLOSE FolderNodeCursor
  DEALLOCATE FolderNodeCursor  

  RETURN @FullFolderPath
END

GO
