-- test script
-- Copyright (c) 2019 Crayon Australia

PRINT 'this is a test'
PRINT 'SQL Server Version is: ' + @@version

DECLARE @FnmsVersion nvarchar(10)
SELECT @FnmsVersion = Value FROM DataBaseConfiguration where Property like 'CMSchemaVersion'
PRINT 'FNMS Version is: ' + @FnmsVersion

-- cursor to print list of tenants
DECLARE @TenantID int
DECLARE @TenantUID nvarchar(20)
DECLARE @TenantName nvarchar(256)
DECLARE @TenantComment nvarchar(128)

DECLARE c CURSOR FOR SELECT TenantID, TenantUID, TenantName, Comments FROM dbo.Tenant
OPEN c

FETCH NEXT FROM c INTO @TenantID, @TenantUID, @TenantName, @TenantComment
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT N'TENANT-' + convert(nvarchar(2),@TenantID) + ' ' + @TenantName
	PRINT N'  UID=' + @TenantUID) + ' COMMENTS=' + @TenantComment
	PRINT ''		
	--EXEC dbo.SetTenantID @TenantID

	FETCH NEXT FROM c INTO @TenantID, @TenantUID, @TenantName, @TenantComment
END

CLOSE c
DEALLOCATE c




GO
