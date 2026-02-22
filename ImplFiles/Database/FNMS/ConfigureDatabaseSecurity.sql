---------------------------------------------------------------------------
-- sqlcmd script to configure access access to $(FNMSAdminsGroup) on the current
-- database.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM sys.syslogins WHERE name = '$(FNMSAdminsGroup)')
	CREATE LOGIN [$(FNMSAdminsGroup)] FROM WINDOWS

IF NOT EXISTS(SELECT * FROM dbo.sysusers WHERE name = '$(FNMSAdminsGroup)' AND islogin = 1)
	CREATE USER [$(FNMSAdminsGroup)]

IF CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR) >= '11' -- Can only set DEFAULT_SCHEMA for a group on SQL Server 2012 and later
	ALTER USER [$(FNMSAdminsGroup)] WITH DEFAULT_SCHEMA = dbo

EXEC sp_addrolemember 'db_owner', '$(FNMSAdminsGroup)'

PRINT 'db_owner access to ' + DB_NAME() + ' granted to $(FNMSAdminsGroup)'
GO
