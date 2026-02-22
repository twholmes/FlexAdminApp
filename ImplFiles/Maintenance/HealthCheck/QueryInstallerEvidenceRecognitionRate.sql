-- Copyright (C) 2020 Crayon Australia

USE $(DBName)
GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.4.2: Installer Evidence Recognition Rate'
PRINT '';

WITH Evidence AS
(
  SELECT 
    CASE 
      WHEN IsAssigned = 0 AND Ignored = 0 THEN 0 
    ELSE MatchedCount 
    END AS InScopeEvidence
    ,MatchedCount
  FROM dbo.InstallerEvidenceInfo
)
SELECT 
  100.0 * SUM(InScopeEvidence) / SUM(MatchedCount) AS RecognitionPercentage
FROM Evidence

GO