Use [FNMSCompliance]

/*
SELECT
  [ROWNUMBER]
  ,[Fund]
  ,[Dept]
  ,[Project]
  ,[Long Descr]
  ,[matched]
  ,[created]
  ,[updated]
  ,[rejected]
  ,[deleted]
  ,[rejectedreason]
  ,[Path]
  ,[CostCenter_ID]
FROM [dbo].[ECMImport_CostCenters
*/

SELECT
  [GroupID]
  ,[GroupTypeID]
  ,[BusinessView]
  ,[Path]
  ,[NextChild]
  ,[GroupExID]
  ,[BusinessPhoneNumber]
  ,[FaxPhoneNumber]
  ,[Address_Street]
  ,[Address_City]
  ,[Address_State]
  ,[Address_ZIP]
  ,[Address_Country]
  ,[Email]
  ,[Comments]
  ,[IsStockLocation]
  ,[ContactID]
  ,[ManagerID]
  ,[GroupCN]
  ,[NameResourceName]
  ,[DescriptionResourceName]
  ,[ParentGroupExID]
  ,[TreeLevel]
  ,[TreePath]
  ,[SpecifiedRegion]
  ,[RegionID]
  ,[IsShared]
FROM [dbo].[CostCenter]
WHERE [Path] like 'ANU/%'

DELETE  FROM [FNMSCompliance].[dbo].[CostCenter]
--where GroupID > 40000  and GroupID < 90000
WHERE [Path] like 'ANU/%'
