USE [FNMSCompliance]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Object:  View [dbo].[ExportPurchases]    Script Date: 6/10/2021 4:21:20 PM ******/
DROP VIEW [dbo].[XportPurchases]
GO

CREATE VIEW [dbo].[XportPurchases]
AS
SELECT
    pod.[PurchaseOrderDetailID]
    ,po.[PurchaseOrderNo]
    ,pod.[SequenceNumber]
    ,pod.[ItemDescription]   
    ,v.[VendorName]
    ,ISNULL(pub.[VendorName],v.[VendorName]) AS [PublisherName]
    ,podtx.[PurchaseType]    
    ,pod.[PartNo]
    ,pod.[LicensePartNo]
    ,pod.[Quantity] AS [PurchaseQuantity]
    ,pod.[QuantityPerUnit]
    ,case
	   when posx.[PurchaseOrderStatus] is NULL then 'New'
	   when posx.[PurchaseOrderStatus] like 'Item%' then 'Completed'
	   else posx.[PurchaseOrderStatus]
	 end AS [Status]
    ,pod.[UnitPrice]
    ,pod.[SalesTax]
    ,pod.[ShippingAndHandling]
    ,pod.[ShippingDate]
    ,pod.[TotalPrice]
    ,po.[PurchaseOrderDate] AS [PurchaseDate]
    ,c.[ContractNo]
    ,ISNULL(cri.[CurrencyCode],'AUD') AS [CurrencyCode]
    ,cri.[SnapshotDate] AS [CurrencyDate]
    ,cri.[SnapshotName] AS [CurrencySnapshotName]
    ,cri.[Rate] AS [CurrencyRate]
    ,po.[RequestNo]
    ,po.[RequestDate]
    ,pod.[InvoiceNo]
    ,pod.[InvoiceDate]
    ,g1.[Path] AS [Location]
    ,g3.[Path] AS [BusinessUnit]
    ,g2.[Path] AS [CostCenter]
    ,g4.[Path] AS [Category]
    ,pod.[Comments]
  FROM dbo.[PurchaseOrderDetail] AS pod
    JOIN dbo.[PurchaseOrder] AS po ON po.PurchaseOrderID = pod.PurchaseOrderID
    LEFT OUTER JOIN dbo.[Vendor] as pub ON pub.VendorID = pod.PublisherID
    LEFT OUTER JOIN dbo.[Vendor] as v ON v.VendorID = po.VendorID
    LEFT OUTER JOIN dbo.[Contract] AS c ON pod.[ContractID] = c.[ContractID]
    LEFT OUTER JOIN dbo.[GroupEx] AS g1 ON pod.[LocationID] = g1.[GroupExID]
    LEFT OUTER JOIN dbo.[GroupEx] AS g2 ON pod.[CostCenterID] = g2.[GroupExID]
    LEFT OUTER JOIN dbo.[GroupEx] AS g3 ON pod.[BusinessUnitID] = g3.[GroupExID]
    LEFT OUTER JOIN dbo.[GroupEx] AS g4 ON pod.[CategoryID] = g4.[GroupExID]
    LEFT OUTER JOIN dbo.CurrencyRateInfo AS cri ON cri.CurrencyRateID = pod.UnitPriceRateID
    LEFT OUTER JOIN
    (
      SELECT
        podt.[PurchaseOrderDetailTypeID],
        rsct.[ResourceValue] AS [PurchaseType]
      FROM dbo.[PurchaseOrderDetailType] podt
        JOIN dbo.ResourceStringCultureType rsct ON podt.ResourceName = rsct.ResourceString and rsct.CultureType = 'en-US'
    ) podtx ON podtx.[PurchaseOrderDetailTypeID] = pod.[PurchaseOrderDetailTypeID]
    LEFT OUTER JOIN
    (
      SELECT
        pos.[PurchaseOrderStatusID],
        rsct.[ResourceValue] AS [PurchaseOrderStatus]
      FROM dbo.[PurchaseOrderStatusI18N] pos
        JOIN dbo.ResourceStringCultureType rsct ON pos.ResourceName = rsct.ResourceString and rsct.CultureType = 'en-US'
    ) posx ON posx.[PurchaseOrderStatusID] = po.[PurchaseOrderStatusID]

GO


/****** Object:  View [dbo].[Exportontracts]    Script Date: 6/10/2021 4:21:20 PM ******/
DROP VIEW [dbo].[XportContracts]
GO

CREATE VIEW [dbo].[XportContracts]
AS
SELECT
  Contract.ContractID AS [ContractID],
  Contract.ContractNo AS [ContractNumber],
  Contract.ContractName AS [ContractName],
  v.VendorName AS [Vendor],
  ContractTypeI18N.ContractTypeDefaultValue AS [ContractType],
  case 
    when ContractStatusI18N.DefaultValue like 'Closed' THEN 'Archived'
    else ContractStatusI18N.DefaultValue
  end AS [ContractStatus],
  ContractState.DefaultValue AS [ContractState],
  CAST(Contract.TotalValue * TotalValueRate.Rate AS money) AS [TotalValue],
  Contract.StartDate AS [StartDate],
  Contract.EndDate AS [EndDate],
  Contract.NeverExpires AS [NeverExpires],
  Contract.PreExpiryDate AS [PreExpiryDate],
  Contract.RenewalDate AS [RenewalDate],
  PurchaseProgram.Name AS [PurchaseProgram],
  MasterContract.ContractNo AS [MasterContractNumber],
  Project.ProjectName AS [ProjectName],
  (SELECT ContractName FROM dbo.GetReplacementContractName(Contract.ContractID)) AS [ReplacementContractName],
  Contract.Comments AS [Comments],
  Contract.MasterContractID AS [MasterContractID]
FROM Contract
	LEFT OUTER JOIN dbo.Vendor AS v ON v.VendorID = Contract.VendorID
  LEFT OUTER JOIN dbo.ContractTypeI18N ON ContractTypeI18N.ContractTypeID = Contract.ContractTypeID
  LEFT OUTER JOIN dbo.ContractStatusI18N ON ContractStatusI18N.ContractStatusID = Contract.ContractStatusID
  LEFT OUTER JOIN ContractState ON ContractState.ContractStateID = Contract.ContractStateID
  LEFT OUTER JOIN GetCurrencyExchangeRates(0) AS TotalValueRate ON TotalValueRate.CurrencyRateID = Contract.TotalValueRateID
  LEFT OUTER JOIN PurchaseProgram ON PurchaseProgram.PurchaseProgramID = Contract.PurchaseProgramID
  LEFT OUTER JOIN [Contract] AS MasterContract ON MasterContract.ContractID = [Contract].MasterContractID
  LEFT OUTER JOIN Project ON Project.ProjectID = Contract.ProjectID

GO
