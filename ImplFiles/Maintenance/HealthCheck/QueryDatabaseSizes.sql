-- Copyright (C) 2020 Crayon Australia

USE $(DBName)
GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.2.12'
PRINT ''

---------------------------------------------------------------------------
PRINT 'Health-Check 4.2.12: ComplianceComputer count'
PRINT ''

SELECT 
  ComputerCount = COUNT(*) 
FROM ComplianceComputer
WHERE ComplianceComputerStatusID != 4 /* dummy */

GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.2.12: ComplianceHistory record count'
PRINT ''

SELECT 
  OldestHistory = MIN(HistoryDate)
  ,HistoryAgent = DATEDIFF(d, MIN(HistoryDate)
  ,GETDATE()) / 365.0 
FROM ComplianceHistory

GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.2.12: Database sizes (1)'
PRINT '';

WITH fs
AS
(
  SELECT database_id, type, size * 8.0 / 1024 size
  FROM sys.master_files
)
SELECT 
  name
  ,(SELECT sum(size) FROM fs where type = 0 and fs.database_id = db.database_id) DataFileSizeMB
  ,(SELECT sum(size) FROM fs where type = 1 and fs.database_id = db.database_id) LogFileSizeMB
FROM sys.databases db
WHERE name like 'fnms%'

GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.2.12: Database sizes (2)'
PRINT ''

SELECT 
  RTRIM(name) AS [Segment Name], groupid AS [Group Id], filename AS [File Name]
  ,CAST(size/128.0 AS DECIMAL(10,2)) AS [Allocated Size in MB]
  ,CAST(FILEPROPERTY(name, 'SpaceUsed')/128.0 AS DECIMAL(10,2)) AS [Space Used in MB]
  ,CAST([maxsize]/128.0 AS DECIMAL(10,2)) AS [Max in MB]
  ,CAST(size/128.0-(FILEPROPERTY(name, 'SpaceUsed')/128.0) AS DECIMAL(10,2)) AS [Available Space in MB]
  ,CAST((CAST(FILEPROPERTY(name, 'SpaceUsed')/128.0 AS DECIMAL(10,2))/CAST(size/128.0 AS DECIMAL(10,2)))*100 AS DECIMAL(10,2)) AS [Percent Used]
FROM sysfiles
ORDER BY groupid DESC

GO