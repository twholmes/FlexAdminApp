-- Copyright (C) 2020 Crayon Australia

USE $(DBName)
GO

---------------------------------------------------------------------------
PRINT ''
PRINT 'Health-Check 4.4.4: Inventory Coverage For Installed Assets'
PRINT ''

SELECT	
  at.AssetTypeName
  ,[Assets With Current Inventory] = SUM(
       CASE 
         WHEN c.AssetID IS NOT NULL AND c.InventoryDate >= DATEADD(m, -1, GETDATE()) THEN 1 
         ELSE 0 
       END
     )
  ,[Assets With Aged Inventory] = SUM(
       CASE 
         WHEN c.AssetID IS NOT NULL AND c.InventoryDate < DATEADD(m, -1, GETDATE()) THEN 1 
         ELSE 0 
       END
     )
  ,[Assets With No Inventory] = SUM(CASE WHEN c.AssetID IS NULL THEN 1 ELSE 0 END)
FROM dbo.Asset a
  JOIN dbo.AssetType at ON at.AssetTypeID = a.AssetTypeID
  LEFT OUTER JOIN dbo.ComplianceComputer c ON c.AssetID = a.AssetID AND c.ComplianceComputerStatusID != 4 /* dummy */
WHERE a.AssetStatusID = 3 /* installed */
GROUP BY at.AssetTypeName, at.ManagedType
ORDER BY at.ManagedType DESC, COUNT(a.AssetID) DESC

GO