---------------------------------------------------------------------------
-- sqlcmd script to configure access to the Beacon database
--
-- Copyright (C) 2015 Flexera Software
---------------------------------------------------------------------------

IF '$(XenAppStagingDBSQLAccount)' != 'Not set'
BEGIN
	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'$(XenAppStagingDBSQLAccount)')
	BEGIN
		PRINT 'Creating user $(XenAppStagingDBSQLAccount)'
		CREATE USER [$(XenAppStagingDBSQLAccount)] FOR LOGIN [$(XenAppStagingDBSQLAccount)]
	END

	PRINT 'Configuring access for user $(XenAppStagingDBSQLAccount) to ' + DB_NAME()

	EXEC sp_addrolemember 'db_ddladmin', '$(XenAppStagingDBSQLAccount)'
	EXEC sp_addrolemember 'db_datareader', '$(XenAppStagingDBSQLAccount)'
	EXEC sp_addrolemember 'db_datawriter', '$(XenAppStagingDBSQLAccount)'
END
ELSE
BEGIN
	-- Grant database access rights to the group for Beacon administrators
	DECLARE @loginame sysname
	SET @loginame = '$(XenAppServiceAccount)'

	EXEC sp_grantlogin '$(XenAppServiceAccount)'

	IF NOT EXISTS(SELECT * FROM dbo.sysusers WHERE name = '$(XenAppServiceAccount)' AND islogin = 1)
		EXEC sp_grantdbaccess '$(XenAppServiceAccount)'

	EXEC sp_addrolemember 'db_owner', '$(XenAppServiceAccount)'

	PRINT 'db_owner access to ' + DB_NAME() + ' granted to $(XenAppServiceAccount)'
END
GO
