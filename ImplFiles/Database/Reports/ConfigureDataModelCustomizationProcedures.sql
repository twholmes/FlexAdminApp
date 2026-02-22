---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure data model
-- customisations for this FlexNet Manager Suite implementation.
--
-- Copyright (C) 2017 Flexera Software
---------------------------------------------------------------------------

USE $(DBName)
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

SET NOCOUNT ON
PRINT 'Configuring data model customization procedures'

-- Add CustomCreateComplianceSearchTypeColumn procedure
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.CustomCreateComplianceSearchTypeColumn') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.CustomCreateComplianceSearchTypeColumn
GO

CREATE PROCEDURE dbo.CustomCreateComplianceSearchTypeColumn
	@ComplianceSearchTypeID INT
	, @ColumnName NVARCHAR(128)
	, @FromTable NVARCHAR(MAX)
	, @SelectName NVARCHAR(MAX)
	, @WhereClause NVARCHAR(MAX)
	, @FilterGroupType INT = 1 /* string */
	, @RequiresSearchTypeID INT = NULL
	, @SelectByDefault BIT = 0
	, @Mandatory BIT = 0
	, @PrimaryKey BIT = 0
AS
-- Purpose: Create a ComplianceSearchTypeColumn record

PRINT 'Configuring custom view column "' + @ColumnName + '"'

-- Remove line breaks (since FNMP de-duplicates identical lines)
SET @FromTable = REPLACE(@FromTable, CHAR(10), ' ')
SET @FromTable = REPLACE(@FromTable, CHAR(13), ' ')


MERGE dbo.ComplianceSearchTypeColumn cstp

USING (
	SELECT @ColumnName, @ComplianceSearchTypeID
) AS source(ColumnName, ComplianceSearchTypeID)
	ON source.ColumnName = cstp.ColumnName
	AND source.ComplianceSearchTypeID = cstp.ComplianceSearchTypeID
	
WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		ColumnName, FromTable, SelectName, JoinClause, WhereClause, SelectOptionsSQL,
		FilterGroupType, DefaultFilterType, ComplianceSearchTypeID, RequiresSearchTypeID,
		SelectByDefault, Mandatory, PrimaryKey
	)
	VALUES (
		@ColumnName, @FromTable, @SelectName, '', @WhereClause, '',
		@FilterGroupType, @FilterGroupType, @ComplianceSearchTypeID, @RequiresSearchTypeID,
		@SelectByDefault, @Mandatory, @PrimaryKey
	)

WHEN MATCHED AND (	-- Something has changed?
		ISNULL(cstp.FromTable, '') != ISNULL(@FromTable, '')
		OR cstp.SelectName != @SelectName
		OR cstp.JoinClause != ''
		OR cstp.WhereClause != @WhereClause
		OR cstp.SelectOptionsSQL != ''
		OR cstp.FilterGroupType != @FilterGroupType
		OR cstp.DefaultFilterType != @FilterGroupType
		OR ISNULL(cstp.RequiresSearchTypeID, -1) != ISNULL(@RequiresSearchTypeID, -1)
		OR cstp.SelectByDefault != @SelectByDefault
		OR cstp.Mandatory != @Mandatory
		OR cstp.PrimaryKey != @PrimaryKey
	)
THEN
	UPDATE
	SET	cstp.FromTable = @FromTable,
		cstp.SelectName = @SelectName,
		cstp.JoinClause = '',
		cstp.WhereClause = @WhereClause,
		cstp.SelectOptionsSQL = '',
		cstp.FilterGroupType = @FilterGroupType,
		cstp.DefaultFilterType = @FilterGroupType,
		cstp.RequiresSearchTypeID = @RequiresSearchTypeID,
		cstp.SelectByDefault = @SelectByDefault,
		cstp.Mandatory = @Mandatory,
		cstp.PrimaryKey = @PrimaryKey
;

IF @@ROWCOUNT > 0
BEGIN
	-- Force saved queries using this column to be recalculated
	UPDATE	css
	SET	SearchSQL = NULL
	FROM	(
			SELECT	css.ComplianceSavedSearchID
			FROM	ComplianceSavedSearch AS css
				CROSS APPLY css.SearchXML.nodes('//column[@name]') T(cols)
				INNER JOIN ComplianceSearchTypeColumn AS cstc
					ON cstc.ColumnName = cols.value('@name', 'nvarchar(max)')
					AND cstc.ColumnName = @ColumnName
					AND cstc.ComplianceSearchTypeID = @ComplianceSearchTypeID

			UNION

			SELECT	css.ComplianceSavedSearchID
			FROM	ComplianceSavedSearch AS css
				CROSS APPLY css.SearchXML.nodes('//condition[@column]') T(cols)
				INNER JOIN ComplianceSearchTypeColumn AS cstc
					ON cstc.ColumnName = cols.value('@column', 'nvarchar(max)')
					AND cstc.ColumnName = @ColumnName
					AND cstc.ComplianceSearchTypeID = @ComplianceSearchTypeID
		) AS cols
		INNER JOIN ComplianceSavedSearch css ON css.ComplianceSavedSearchID = cols.ComplianceSavedSearchID
	WHERE	css.SearchSQL IS NOT NULL
END

GO

