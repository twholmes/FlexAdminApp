---------------------------------------------------------------------------
-- sqlcmd script to create and configure access to the Cognos Content
-- Store database if it does not already exist.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

IF NOT EXISTS (
	SELECT * FROM master..sysdatabases WHERE name = '$(ContentStoreDBName)'
)
BEGIN
	PRINT '-----------------------'
	PRINT 'Creating database $(ContentStoreDBName)'
	PRINT '-----------------------'

	DECLARE @a NVARCHAR(256)
	SELECT @a = CONVERT(NVARCHAR(256),SERVERPROPERTY('collation')) 

	DECLARE	@collation NVARCHAR(256)

	SELECT	@collation = @a
	WHERE	@a LIKE '%CI_AS' -- the collation we want
		OR @a LIKE '%CI_AS_%' -- there are multiple options that can be on the end

	IF @collation IS NULL
		SET @collation = 'Latin1_General_CI_AS'

	EXECUTE ('CREATE DATABASE $(ContentStoreDBName) COLLATE '+ @collation)
END
GO


-- USE $(ContentStoreDBName)
-- GO

-- IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'FlexNetReportDesignerSchema')
-- BEGIN
	-- PRINT 'Creating FlexNetReportDesignerSchema'
	-- EXEC('CREATE SCHEMA [FlexNetReportDesignerSchema]')
-- END
-- GO


-- IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'$(ContentStoreServiceAccount)')
-- BEGIN
	-- PRINT 'Creating user $(ContentStoreServiceAccount)'
	-- CREATE USER [$(ContentStoreServiceAccount)] FOR LOGIN [$(ContentStoreServiceAccount)]
-- END
-- GO


-- PRINT 'Configuring access to $(ContentStoreDBName) for user $(ContentStoreServiceAccount)'

-- ALTER USER [$(ContentStoreServiceAccount)] WITH DEFAULT_SCHEMA=[FlexNetReportDesignerSchema]

-- ALTER AUTHORIZATION ON SCHEMA::[FlexNetReportDesignerSchema] TO [$(ContentStoreServiceAccount)]

-- EXEC sp_addrolemember 'db_ddladmin', '$(ContentStoreServiceAccount)'
-- EXEC sp_addrolemember 'db_datareader', '$(ContentStoreServiceAccount)'
-- EXEC sp_addrolemember 'db_datawriter', '$(ContentStoreServiceAccount)'
-- GO
