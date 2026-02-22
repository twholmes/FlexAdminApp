--------------------------------------------------------------------------------------
-- Copyright (C) 2024 Crayon
-- FNMS CUSTOMISATIONS
-- This file configures FNMSCompliance customisation
--
--------------------------------------------------------------------------------------

USE $(DBName)
GO

---- **************************************************************************************************
---- **************************************************************************************************
---- **************************************************************************************************

----
---- CUSOMISATIONS
----

--------------------------------------------------------------------------------------------------------
-- dbo.CustomGroupsMemberships: Reference table for uploaded file status

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomGroupsMemberships') AND OBJECTPROPERTY(id, 'IsView') = 1)
  DROP VIEW [dbo].[CustomGroupsMemberships]
GO

CREATE VIEW [dbo].[CustomGroupsMemberships] AS
  SELECT * FROM
  (
    SELECT 
      sl.[SoftwareLicenseID] AS [ObjectID]
      ,'License' AS [Object]
      ,sl.[Name] AS [Name]
      ,sl.[BusinessUnitID] AS [GroupExID]
      ,gex.[GroupID]
      ,gex.[Path] as [GroupPath]
    FROM [dbo].[SoftwareLicense_MT] AS sl
    JOIN  [dbo].[GroupEx] as gex on sl.[BusinessUnitID] = gex.[GroupExID]
    WHERE sl.[BusinessUnitID] is not NULL
   
    UNION
   
    SELECT 
      a.[AssetID] AS [ObjectID]
      ,'Asset' AS [Object]
      ,a.[ShortDescription] AS [Name]
      ,a.[BusinessUnitID] AS [GroupExID]
      ,gex.[GroupID]
      ,gex.[Path] as [GroupPath]
    FROM [dbo].[Asset_MT] AS a
    JOIN  [dbo].[GroupEx] as gex on a.[BusinessUnitID] = gex.[GroupExID]
    WHERE a.[BusinessUnitID] is not NULL
   
    UNION
   
    SELECT 
      pod.[PurchaseOrderDetailID] AS [ObjectID]
      ,'PurchaseOrderDetail' AS [Object]
      ,pod.[ItemDescription] AS [Name]
      ,pod.[BusinessUnitID] AS [GroupExID]
      ,gex.[GroupID]
      ,gex.[Path] as [GroupPath]
    FROM [dbo].[PurchaseOrderDetail_MT] AS pod
    JOIN  [dbo].[GroupEx] as gex on pod.[BusinessUnitID] = gex.[GroupExID]
    WHERE pod.[BusinessUnitID] is not NULL
   
    UNION
   
    SELECT 
      c.[ContractID] AS [ObjectID]
      ,'Contract' AS [Object]
      ,c.[ContractNo] AS [Name]
      ,c.[BusinessUnitID] AS [GroupExID]
      ,gex.[GroupID]
      ,gex.[Path] as [GroupPath]
    FROM [dbo].[Contract_MT] AS c
    JOIN  [dbo].[GroupEx] as gex on c.[BusinessUnitID] = gex.[GroupExID]
    WHERE c.[BusinessUnitID] is not NULL
  ) AS gms
   
GO

--SELECT * FROM [dbo].[CustomGroupsMemberships] AS gms
--ORDER BY gms.[Object], gms.[ObjectID]





    SELECT
      gm.[ObjectID]
      ,gm.[Object]
      ,gm.[Name]
      ,gm.[GroupExID]
      ,gm.[GroupID]
      ,gm.[Description]
      ,gm.[GroupPath]
    FROM [dbo].[CustomGroupsMemberships] AS gm



--------------------------------------------------------------------------------------------------------
-- dbo.CustomGroupMembershipProposals: Reference table for uploaded file status

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('dbo.CustomGroupMembershipProposals') AND OBJECTPROPERTY(id, 'IsView') = 1)
  DROP VIEW [dbo].[CustomGroupMembershipProposals]
GO

CREATE VIEW [dbo].[CustomGroupMembershipProposals] AS
   SELECT     
      gm.[ObjectID]
      ,gm.[Object]
      ,gm.[Name]      
      ,gex.[GroupExID]
      ,gex.[GroupID]
      ,gm.[GroupPath]
      ,ngex.[GroupExID] as [NewGroupExID]  
      ,ngex.[GroupID] as [NewGroupID]          
      ,gcp.[NewPath]
    FROM [dbo].[CustomGroupsMemberships] AS gm
    JOIN [dbo].[ECMImport_GroupChangeProposals] AS gcp ON gm.[GroupPath] = gcp.[OldPath]
    JOIN [dbo].[GroupEx] as gex ON gm.[GroupPath] = gex.[Path]   
    JOIN [dbo].[GroupEx] as ngex ON gcp.[NewPath] = ngex.[Path]
;

---- **************************************************************************************************
---- **************************************************************************************************
---- **************************************************************************************************
