---------------------------------------------------------------------------
-- sqlcmd script to configure access access to $(StagingAdminsGroup) on the current
-- database.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

EXEC sp_grantlogin '$(StagingAdminsGroup)'

IF NOT EXISTS(SELECT * FROM dbo.sysusers WHERE name = '$(StagingAdminsGroup)' AND islogin = 1)
	EXEC sp_grantdbaccess '$(StagingAdminsGroup)'

ALTER USER [$(StagingAdminsGroup)] WITH DEFAULT_SCHEMA = dbo
EXEC sp_addrolemember 'db_owner', '$(StagingAdminsGroup)'

PRINT 'db_owner access to ' + DB_NAME() + ' granted to $(StagingAdminsGroup)'
GO
