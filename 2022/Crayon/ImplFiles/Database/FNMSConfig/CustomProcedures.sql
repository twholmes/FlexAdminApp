---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure data model
-- customisations for this FlexNet Manager Suite implementation.
--
-- Copyright (C) 2014-2017 Flexera Software
---------------------------------------------------------------------------

SET NOCOUNT ON

PRINT 'Configuring custom procedures'

/****** Object:  UserDefinedFunction [dbo].[ConvertSearchColumnNamesToSearchXML]    Script Date: 23/03/2016 08:30:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ConvertSearchColumnNamesToSearchXML]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ConvertSearchColumnNamesToSearchXML]
GO

/****** Object:  UserDefinedFunction [dbo].[ConvertSearchColumnNamesToSearchXML]    Script Date: 23/03/2016 08:30:00 ******/
CREATE FUNCTION [dbo].[ConvertSearchColumnNamesToSearchXML](@SearchName nvarchar(64), @SearchColumnNames nvarchar(800))
RETURNS nvarchar(MAX)
AS
BEGIN          
  DECLARE
    @Buffer NVARCHAR(800),
    @SearchMapping NVARCHAR(MAX)  

  -- We only want to perform the character replacement if the string contains characters between
  -- NCHAR(0) and NCHAR(31)
  IF PATINDEX('%[' + NCHAR(0) + NCHAR(1) + NCHAR(2) + NCHAR(3) + NCHAR(4) + NCHAR(5) + NCHAR(6) + NCHAR(7) + NCHAR(8) + NCHAR(9) + NCHAR(10) +
            NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(14) + NCHAR(15) + NCHAR(16) + NCHAR(17) + NCHAR(18) + NCHAR(19) + NCHAR(20) +
            NCHAR(21) + NCHAR(22) + NCHAR(23) + NCHAR(24) + NCHAR(25) + NCHAR(26) + NCHAR(27) + NCHAR(28) + NCHAR(29) + NCHAR(30) +
            NCHAR(31) + ']%', @SearchColumnNames COLLATE Latin1_General_BIN) > 0
  BEGIN
    DECLARE
      @i int,
      @SearchColumnNamesLen int,
      @UnicodeValue int

    SET @Buffer = ''
    SET @i = 1

    -- By passing the length of the input string into a variable, we only have to perform the LEN function once
    SET @SearchColumnNamesLen = LEN(@SearchColumnNames)

    -- Cycle through all of the characters in the input string
    WHILE @i <= @SearchColumnNamesLen
    BEGIN
      -- Get the character code for the character that we are up to
      SET @UnicodeValue = UNICODE(SUBSTRING(@SearchColumnNames, @i, 1))

      -- If the current character code is less than 32, we need to replace it with the underscore(95)/space(32) character
      IF @UnicodeValue < 32
        SET @UnicodeValue = 32 -- This is the underscore(95)/space(32) character

      -- Append the current character to the output string
      SET @Buffer = @Buffer + NCHAR(@UnicodeValue)

      SET @i = @i + 1
    END
  END
  ELSE
  BEGIN
    SET @Buffer = @SearchColumnNames
  END

  SET @SearchMapping = N'<customview><!--Custom view properties--><name>' + RTRIM(LTRIM(@SearchName)) + N'</name>'
  SET @SearchMapping = @SearchMapping + N'<description /><schemaVersion>2.0</schemaVersion><productVersion>11.0</productVersion>'
  SET @SearchMapping = @SearchMapping + N'<!--Master custom view object--><object name="LicensePositions" major="true">'

  DECLARE 
    @rowid int,
    @node varchar(100),
    @rows int

  -- loop through the column names and adjust the mapping xml
  DECLARE @ColumnNames table (rowid int identity(1,1), node varchar(100))
  DELETE FROM @ColumnNames
  INSERT INTO @ColumnNames (node)
  SELECT s FROM Split(',', @Buffer)

  SET @i = 0

  SELECT @rows = count(1) from @ColumnNames
  WHILE (@rows > 0)
  BEGIN
    SELECT TOP 1 @rowid = rowid, @node = RTRIM(LTRIM(node))
    FROM @ColumnNames

    SET @SearchMapping = @SearchMapping + N'  <column index="' + CONVERT(nvarchar(2), @i, 2) + '" name="' + @node + 'Edition" show="true" />'
 
    DELETE FROM @ColumnNames WHERE rowid = @rowid
    SELECT @rows = count(1) FROM @ColumnNames
    
    SET @i = @i + 1
  END
    
  SET @SearchMapping = @SearchMapping + N'</object></customview>'

  RETURN @SearchMapping
END


GO



/****** Object:  UserDefinedFunction [dbo].[ConvertSearchColumnNamesToSearchMapping]    Script Date: 05/16/2015 17:16:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ConvertSearchColumnNamesToSearchMapping]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ConvertSearchColumnNamesToSearchMapping]
GO

/****** Object:  UserDefinedFunction [dbo].[ConvertSearchColumnNamesToSearchMapping]    Script Date: 05/16/2015 17:16:16 ******/
CREATE FUNCTION [dbo].[ConvertSearchColumnNamesToSearchMapping](@SearchName nvarchar(64), @SearchColumnNames nvarchar(800))
RETURNS nvarchar(MAX)
AS
BEGIN          
  DECLARE
    @Buffer NVARCHAR(800),
    @SearchMapping NVARCHAR(MAX)  

  -- We only want to perform the character replacement if the string contains characters between
  -- NCHAR(0) and NCHAR(31)
  IF PATINDEX('%[' + NCHAR(0) + NCHAR(1) + NCHAR(2) + NCHAR(3) + NCHAR(4) + NCHAR(5) + NCHAR(6) + NCHAR(7) + NCHAR(8) + NCHAR(9) + NCHAR(10) +
            NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(14) + NCHAR(15) + NCHAR(16) + NCHAR(17) + NCHAR(18) + NCHAR(19) + NCHAR(20) +
            NCHAR(21) + NCHAR(22) + NCHAR(23) + NCHAR(24) + NCHAR(25) + NCHAR(26) + NCHAR(27) + NCHAR(28) + NCHAR(29) + NCHAR(30) +
            NCHAR(31) + ']%', @SearchColumnNames COLLATE Latin1_General_BIN) > 0
  BEGIN
    DECLARE
      @i int,
      @SearchColumnNamesLen int,
      @UnicodeValue int

    SET @Buffer = ''
    SET @i = 1

    -- By passing the length of the input string into a variable, we only have to perform the LEN function once
    SET @SearchColumnNamesLen = LEN(@SearchColumnNames)

    -- Cycle through all of the characters in the input string
    WHILE @i <= @SearchColumnNamesLen
    BEGIN
      -- Get the character code for the character that we are up to
      SET @UnicodeValue = UNICODE(SUBSTRING(@SearchColumnNames, @i, 1))

      -- If the current character code is less than 32, we need to replace it with the underscore(95)/space(32) character
      IF @UnicodeValue < 32
        SET @UnicodeValue = 32 -- This is the underscore(95)/space(32) character

      -- Append the current character to the output string
      SET @Buffer = @Buffer + NCHAR(@UnicodeValue)

      SET @i = @i + 1
    END
  END
  ELSE
  BEGIN
    SET @Buffer = @SearchColumnNames
  END
  
  SET @SearchMapping = N'<ArrayOfCustomViewColumnMapping xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
  SET @SearchMapping = @SearchMapping + N'<CustomViewColumnMapping><Column /><FieldName>' + RTRIM(LTRIM(@Buffer))
  SET @SearchMapping = @SearchMapping + N'</FieldName><ShowInGrid>true</ShowInGrid><Hidden>false</Hidden><ParentName /></CustomViewColumnMapping></ArrayOfCustomViewColumnMapping>'

  SET @SearchMapping = REPLACE(@SearchMapping, N',', N'</FieldName><ShowInGrid>true</ShowInGrid><Hidden>false</Hidden><ParentName /></CustomViewColumnMapping><CustomViewColumnMapping><Column /><FieldName>')
  SET @SearchMapping = REPLACE(@SearchMapping, N'<ParentName />', N'<ParentName>' + RTRIM(LTRIM(@SearchName)) + N'</ParentName>')

  DECLARE @rowid int
  DECLARE @node varchar(100)
  DECLARE @rows int

  -- loop through the column names and adjust the mapping xml
  DECLARE @ColumnNames table (rowid int identity(1,1), node varchar(100))
  DELETE FROM @ColumnNames
  INSERT INTO @ColumnNames (node)
  SELECT s FROM Split(',', @Buffer)

  SELECT @rows = count(1) from @ColumnNames
  WHILE (@rows > 0)
  BEGIN
    SELECT TOP 1 @rowid = rowid, @node = RTRIM(LTRIM(node))
    FROM @ColumnNames

    SET @SearchMapping = REPLACE(@SearchMapping, N'<Column /><FieldName>'+@node, N'<Column ColumnName="' + @node + N'"></Column><FieldName>'+@node)
  
    DELETE FROM @ColumnNames WHERE rowid = @rowid
    SELECT @rows = count(1) FROM @ColumnNames
  END

  RETURN @SearchMapping
END



GO


-- This is an optimisation to the out of the box trigger which addresses a performance problem.
-- The trigger typically takes around 4 hours every time an update is made to the entire
-- PurchaseOrderDetail table.  This happens several times in the UnifiPO business adapter.
-- This optimisation only synchs the SoftwareSkuID column if the update has changed the SKU.

EXEC DeleteTriggerIfPresent N'[dbo].PurchaseOrderDetailSynchSKU'
GO
CREATE TRIGGER [dbo].[PurchaseOrderDetailSynchSKU]
on [dbo].[PurchaseOrderDetail_MT]
FOR INSERT, UPDATE
AS
	Declare @RowCount int
	set @RowCount = @@RowCount
	if (@RowCount = 0)
		return

	SET NOCOUNT ON
	
DECLARE @inserted TABLE (
	PurchaseOrderDetailID int primary key,
	LicensePartNo nvarchar(100),
	Prefix nvarchar(10),
	UNIQUE(LicensePartNo, PurchaseOrderDetailID)
)

	DECLARE @TenantID smallint

	DECLARE PurchaseOrderDetailSynchSKU_Cursor CURSOR FOR SELECT DISTINCT TenantID FROM inserted

	OPEN PurchaseOrderDetailSynchSKU_Cursor
	FETCH NEXT FROM PurchaseOrderDetailSynchSKU_Cursor INTO @TenantID

	WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM @inserted

			INSERT INTO @inserted
			SELECT	
				ISNULL(i.PurchaseOrderDetailID, d.PurchaseOrderDetailID) AS PurchaseOrderDetailID, 
				LTRIM(RTRIM(i.LicensePartNo)), 
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(LTRIM(RTRIM(i.LicensePartNo)), 7), '\', '\\' ), '%', '\%' ), '_', '\_' ), '[', '\[' ), ']', '\]') + '%'
			FROM	
				inserted i
				LEFT OUTER JOIN deleted d
					ON i.PurchaseOrderDetailID = d.PurchaseOrderDetailID
						AND
						i.TenantID = d.TenantID
			WHERE 	i.TenantID = @TenantID
					AND (binary_checksum(IsNull(d.LicensePartNo,'')) <> binary_checksum(IsNull(i.LicensePartNo,''))); 
			

			WITH matches AS (
				SELECT	i.PurchaseOrderDetailID, sku.SoftwareSkuID, sku.SKU
				FROM	@inserted AS i
						INNER JOIN dbo.SoftwareSku AS sku WITH (NOLOCK) ON sku.SKU LIKE i.Prefix ESCAPE '\' COLLATE database_default AND i.LicensePartNo LIKE sku.SKU ESCAPE '\' COLLATE database_default
				UNION ALL
				SELECT	i.PurchaseOrderDetailID, sku.SoftwareSkuID, sku.SKU
				FROM	@inserted AS i
						INNER JOIN dbo.SoftwareSku AS sku WITH (NOLOCK) ON sku.SKUPrefixLength BETWEEN 1 AND 7 AND i.LicensePartNo LIKE sku.SKU ESCAPE '\' COLLATE database_default
				UNION ALL
				SELECT	i.PurchaseOrderDetailID, sku.SoftwareSkuID, sku.SKU
				FROM	@inserted AS i
						INNER JOIN dbo.SoftwareSku AS sku WITH (NOLOCK) ON sku.SKUPrefixLength = 0 AND i.LicensePartNo = sku.SKU COLLATE database_default
			)
			UPDATE
				pod
			SET
				pod.SoftwareSkuID = sstpod.SoftwareSkuID
			FROM	PurchaseOrderDetail_MT AS pod
					INNER JOIN @inserted as i ON pod.PurchaseOrderDetailID = i.PurchaseOrderDetailID
					LEFT OUTER JOIN (
						SELECT	matches.*,
								ROW_NUMBER() OVER (PARTITION BY matches.PurchaseOrderDetailID ORDER BY LEN(matches.SKU) DESC, matches.SoftwareSkuID) AS RowRank
						FROM	matches
					) AS sstpod ON sstpod.PurchaseOrderDetailID = pod.PurchaseOrderDetailID AND sstpod.RowRank = 1
			WHERE pod.TenantID = @TenantID
			AND ISNULL(pod.SoftwareSkuID, 0) <> ISNULL(sstpod.SoftwareSkuID, 0)
			OPTION (RECOMPILE)

			FETCH NEXT FROM PurchaseOrderDetailSynchSKU_Cursor INTO @TenantID
		END

	CLOSE PurchaseOrderDetailSynchSKU_Cursor
	DEALLOCATE PurchaseOrderDetailSynchSKU_Cursor
GO


-- This trigger automatically sets:
-- - The Asset disposal date to the current day on Assets that have been disposed and do not currently have a disposal date
-- - The Asset retirement date to the current day on Assets that have been retired and do not currently have a retirement date


EXEC DeleteTriggerIfPresent N'[dbo].CustomUpdateAssetRetireOrDispose'
GO

CREATE TRIGGER [dbo].[CustomUpdateAssetRetireOrDispose]
ON [dbo].[Asset_MT]
FOR UPDATE
AS
BEGIN
	
	IF (UPDATE(AssetStatusID))
	BEGIN
		CREATE TABLE #CustomAssetsWithChangedStatus(
			AssetID BIGINT NOT NULL,
			OldAssetStatusID INT NOT NULL,
			NewAssetStatusID INT NOT NULL
		)

		DECLARE @Today DATETIME
		SET @Today = CONVERT(DATE, GETDATE())

		INSERT INTO #CustomAssetsWithChangedStatus(AssetID, OldAssetStatusID, NewAssetStatusID)
			SELECT d.AssetID, d.AssetStatusID, i.AssetStatusID
				FROM deleted d
				INNER JOIN inserted i
					ON i.AssetID = d.AssetID
					AND i.AssetStatusID != d.AssetStatusID -- Only those where AssetStatusID has changed

		-- Set the Asset retirement date
		UPDATE a
		SET a.RetirementDate = @Today
		FROM dbo.Asset_MT a
			JOIN #CustomAssetsWithChangedStatus awcs
				ON awcs.AssetID = a.AssetID
		WHERE 
			awcs.NewAssetStatusID = 4 -- Retired
			AND
			a.RetirementDate IS NULL
			AND
			awcs.OldAssetStatusID != 5 -- Do not set the retirement date if the asset was already disposed.

		-- Set the Asset disposal date
		UPDATE a
		SET a.DisposalDate = @Today
		FROM dbo.Asset_MT a
			JOIN #CustomAssetsWithChangedStatus awcs
				ON awcs.AssetID = a.AssetID
		WHERE 
			awcs.NewAssetStatusID = 5 -- Disposed
			AND
			a.DisposalDate IS NULL
	END
	
END

GO


