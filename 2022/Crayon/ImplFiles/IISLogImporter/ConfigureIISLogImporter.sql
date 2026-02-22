---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure a table to store IIS
-- log details.
--
-- Copyright (C) 2017 Flexera Software
---------------------------------------------------------------------------


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CustomIISLogs')
BEGIN
	CREATE TABLE dbo.CustomIISLogs(
		LogFilename VARCHAR(255),
		LogRow INT,
		[date] DATETIME, -- Nominally a DATE value, but LogParser.exe requires this to be a DATETIME - any time part should be ignored
		[time] DATETIME, -- Nominally a TIME value, but LogParser.exe requires this to be a DATETIME - any date part should be ignored
		cIp VARCHAR(255),
		csUsername VARCHAR(255),
		sSitename VARCHAR(255),
		sComputername VARCHAR(255),
		sIp VARCHAR(255),
		sPort INT,
		csMethod VARCHAR(255),
		csUriStem VARCHAR(255),
		csUriQuery VARCHAR(255),
		scStatus INT,
		scSubstatus INT,
		scWin32Status INT,
		scBytes INT,
		csBytes INT,
		timeTaken INT,
		csVersion VARCHAR(255),
		csHost VARCHAR(255),
		csUserAgent VARCHAR(255),
		csCookie VARCHAR(255),
		csReferer VARCHAR(255),
		sEvent VARCHAR(255),
		sProcessType VARCHAR(255),
		sUserTime REAL,
		sKernelTime REAL,
		sPageFaults INT,
		sTotalProcs INT,
		sActiveProcs INT,
		sStoppedProcs INT NULL		
	)
END
GO

IF OBJECT_ID('dbo.CustomIISLogsEx') IS NOT NULL
	DROP VIEW dbo.CustomIISLogsEx
GO

CREATE VIEW dbo.CustomIISLogsEx AS
SELECT *, csUriStemWithoutTrailingDigits = LEFT(csUriStem, LEN(csUriStem) - PATINDEX('%[^0-9]%', REVERSE(csUriStem)) + 1)
FROM dbo.CustomIISLogs
GO

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = N'CL_CustomIISLogs' AND id = OBJECT_ID(N'dbo.CustomIISLogs'))
BEGIN
	CREATE CLUSTERED INDEX CL_CustomIISLogs ON dbo.CustomIISLogs([date], [time])
END

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = N'IX_CustomIISLogsBysIp' AND id = OBJECT_ID(N'dbo.CustomIISLogs'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_CustomIISLogsBysIp ON dbo.CustomIISLogs(sIP)
END

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = N'IX_CustomIISLogsBycIp' AND id = OBJECT_ID(N'dbo.CustomIISLogs'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_CustomIISLogsBycIp ON dbo.CustomIISLogs(cIP)
END

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = N'IX_CustomIISLogsBycsUsername' AND id = OBJECT_ID(N'dbo.CustomIISLogs'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_CustomIISLogsBycsUsername ON dbo.CustomIISLogs(csUsername)
END

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = N'IX_CustomIISLogsBytimeTaken' AND id = OBJECT_ID(N'dbo.CustomIISLogs'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_CustomIISLogsBytimeTaken ON dbo.CustomIISLogs(timeTaken)
END

GO
