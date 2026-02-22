-- Copyright (C) 2020 Crayon Australia

USE $(DBName)
GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.1.5: Query SQL Blocking tasks (1)'
PRINT ''

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT
  r.session_id
  ,r.blocking_session_id
  ,r.wait_time
  ,r.wait_type
  ,r.wait_resource 
  ,r.last_wait_type
  ,ElapsedSec = DATEDIFF(s, r.start_time, GETDATE())
  ,ExecutingStatement = SUBSTRING(t.text, (r.statement_start_offset/2) + 1, (
      CASE 
        WHEN r.statement_end_offset IN (-1, 0) THEN (CONVERT(int, DATALENGTH(t.text)) - CONVERT(int, r.statement_start_offset/2)) + 1 
        ELSE (r.statement_end_offset - r.statement_start_offset)/2 + 1
      END)
    )
  ,r.status
  ,s.program_name
  ,DatabaseName = DB_NAME(r.database_id)
FROM sys.dm_exec_requests r
  OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
  JOIN sys.dm_exec_sessions s ON s.session_id = r.session_id
  LEFT OUTER JOIN sys.dm_exec_query_memory_grants mg ON mg.session_id = r.session_id
WHERE r.session_id != @@SPID     -- don't show this query
  AND r.session_id > 50          -- don't show system queries
ORDER BY r.start_time

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.1.5: Query SQL Blocking tasks (2)'
PRINT ''

SELECT
  db.name DBName,
  tl.request_session_id,
  wt.blocking_session_id,
  OBJECT_NAME(p.OBJECT_ID) BlockedObjectName,
  tl.resource_type,
  h1.TEXT AS RequestingText,
  h2.TEXT AS BlockingTest,
  tl.request_mode
FROM sys.dm_tran_locks AS tl
  INNER JOIN sys.databases db ON db.database_id = tl.resource_database_id
  INNER JOIN sys.dm_os_waiting_tasks AS wt ON tl.lock_owner_address = wt.resource_address
  INNER JOIN sys.partitions AS p ON p.hobt_id = tl.resource_associated_entity_id
  INNER JOIN sys.dm_exec_connections ec1 ON ec1.session_id = tl.request_session_id
  INNER JOIN sys.dm_exec_connections ec2 ON ec2.session_id = wt.blocking_session_id
  CROSS APPLY sys.dm_exec_sql_text(ec1.most_recent_sql_handle) AS h1
  CROSS APPLY sys.dm_exec_sql_text(ec2.most_recent_sql_handle) AS h2

GO



GO
