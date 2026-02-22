---------------------------------------------------------------------------
-- This sqlcmd script can be executed to delete old IIS logs details from
-- the dbo.CustomIISLogs table.
--
-- Copyright (C) 2017 Flexera Software
---------------------------------------------------------------------------

PRINT 'Deleting IIS logs older than $(MonthsToKeepIISLogs) months'

DELETE FROM dbo.CustomIISLogs WHERE [date] < DATEADD(m, -$(MonthsToKeepIISLogs), GETUTCDATE())

PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' log entries'

GO
