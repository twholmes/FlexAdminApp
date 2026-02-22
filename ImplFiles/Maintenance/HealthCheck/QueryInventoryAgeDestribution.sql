-- Copyright (C) 2020 Crayon Australia

USE $(DBName)
GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.4.3: Inventory Age Destribution'

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.4.3: Inventory Age Destribution (1)'
PRINT ''

SELECT	
  DATEDIFF(m, c.InventoryDate, GETDATE()) AS MonthsOld
  ,COUNT(c.ComplianceComputerID) AS Count
FROM	dbo.ComplianceComputer c
WHERE	c.ComplianceComputerStatusID = 1 /* active */ AND c.InventoryDate IS NOT NULL
GROUP BY DATEDIFF(m, c.InventoryDate, GETDATE())
ORDER BY DATEDIFF(m, c.InventoryDate, GETDATE())

GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.4.3: Inventory Age Destribution (2)'
PRINT ''

SELECT 
  100.0 * SUM(
    CASE 
      WHEN c.InventoryDate >= DATEADD(m, -1, GETDATE()) THEN 1.0 
      ELSE 0.0
    END
  ) / COUNT(c.ComplianceComputerID) AS PercentOfComputersWithCurrentInventory
FROM dbo.ComplianceComputer c
WHERE c.ComplianceComputerStatusID = 1 /* active */


GO
