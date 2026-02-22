-- Copyright (C) 2020 Crayon Australia

USE $(DBName)
GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.2.14'
PRINT ''

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.2.14: Fragmentation stats (1)'
PRINT ''

SELECT
  OBJECT_NAME(i.object_id) AS TableName
  ,i.name AS IndexName
  ,s.index_type_desc
  ,s.avg_fragmentation_in_percent
  ,s.page_count
  ,s.fragment_count
  ,s.avg_fragment_size_in_pages
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,NULL) s
  JOIN sys.indexes I ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE	s.avg_fragmentation_in_percent > 30 AND s.page_count > 2500
ORDER BY s.avg_fragmentation_in_percent DESC

GO

