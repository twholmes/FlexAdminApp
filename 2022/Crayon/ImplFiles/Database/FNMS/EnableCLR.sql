---------------------------------------------------------------------------
-- sqlcmd script to check that CLR is enabled, and attempt to enable it
-- if not.
--
-- Copyright (C) 2017 Flexera Software
---------------------------------------------------------------------------

IF EXISTS(SELECT * FROM sys.configurations WHERE name = 'clr enabled' AND value_in_use = 1)
BEGIN
	PRINT 'The common language runtime (CLR) feature is currently enabled in SQL Server'
END
ELSE
BEGIN
	PRINT 'The common language runtime (CLR) feature is not currently enabled in SQL Server: Attempting to enable'

	BEGIN TRY
		DECLARE @stmt NVARCHAR(MAX)

		SET @stmt = 'sp_configure ''show advanced options'', 1'
		EXEC dbo.sp_executesql @stmt
		SET @stmt = 'RECONFIGURE'
		EXEC dbo.sp_executesql @stmt

		SET @stmt = 'sp_configure ''clr enabled'', 1'
		EXEC dbo.sp_executesql @stmt
		SET @stmt = 'RECONFIGURE'
		EXEC dbo.sp_executesql @stmt
	END TRY
	BEGIN CATCH
		PRINT ''
		PRINT 'ERROR: Failed to enable the common language runtime (CLR) feature in SQL Server. Please enable it manually, then re-run this script.'
		PRINT ''
		PRINT 'To enable CLR integration, you must have ALTER SETTINGS server level permission, which is implicitly held by members of the sysadmin and serveradmin fixed server roles.'
		PRINT 'See https://msdn.microsoft.com/en-us/library/ms131048.aspx for further guidance.'

		DECLARE 
			@ErrorMessage    NVARCHAR(4000),
			@ErrorNumber     INT,
			@ErrorSeverity   INT,
			@ErrorState      INT,
			@ErrorLine       INT,
			@ErrorProcedure  NVARCHAR(200)

		SELECT 
			@ErrorNumber = ERROR_NUMBER(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE(),
			@ErrorLine = ERROR_LINE(),
			@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-')

		SELECT @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: '+ ERROR_MESSAGE()

		-- Raise an error: msg_str parameter of RAISERROR will contain
		-- the original error information.
		RAISERROR(
			@ErrorMessage, 
			@ErrorSeverity, 
			1,               
			@ErrorNumber,    -- parameter: original error number.
			@ErrorSeverity,  -- parameter: original error severity.
			@ErrorState,     -- parameter: original error state.
			@ErrorProcedure, -- parameter: original error procedure name.
			@ErrorLine       -- parameter: original error line number.
		)
	END CATCH
END
GO
