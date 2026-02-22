---------------------------------------------------------------------------
-- sqlcmd script to create the Staging database if it doesn't already exist.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

IF NOT EXISTS (
	SELECT * FROM master..sysdatabases WHERE name = '$(StagingDBName)'
)
BEGIN
	PRINT '-----------------------'
	PRINT 'Creating database $(StagingDBName)'
	PRINT '-----------------------'

	DECLARE @a NVARCHAR(256)
	SELECT @a = CONVERT(NVARCHAR(256),SERVERPROPERTY('collation')) 

	DECLARE	@collation NVARCHAR(256)

	SELECT	@collation = @a
	WHERE	@a LIKE '%CI_AS' -- the collation we want
		OR @a LIKE '%CI_AS_%' -- there are multiple options that can be on the end

	IF @collation IS NULL
		SET @collation = 'Latin1_General_CI_AS'

	EXECUTE ('CREATE DATABASE $(StagingDBName) COLLATE '+ @collation)
END
GO

ALTER DATABASE $(StagingDBName) SET RECOVERY SIMPLE
GO
