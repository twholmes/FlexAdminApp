---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure custom views, functions
-- and procedures that are used by the Automation reports.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Find ComplianceSearchTypeID for Custom

DECLARE @ComplianceSearchTypeID int
SET @ComplianceSearchTypeID = (SELECT ComplianceSearchTypeID FROM dbo.ComplianceSearchType_MT WHERE TypeName = 'Custom' and TenantID = @TenantID)

---------------------------------------------------------------------------
-- Make sure that an Automation Custom View Folders exists

DECLARE @RootViewID int
SET @RootViewID= (SELECT ComplianceSearchFolderID FROM dbo.ComplianceSearchFolder WHERE NameResourceName = 'ComplianceSearchFolder.Reports')

-- Find and Create the Automation Custom View Folder
DECLARE @AutomationFolder NVARCHAR(128)
SET @AutomationFolder = 'Automation Views'

IF NOT EXISTS (SELECT ComplianceSearchFolderID FROM dbo.ComplianceSearchFolder WHERE Name = @AutomationFolder)
BEGIN
  INSERT INTO [ComplianceSearchFolder] ([Name],[ParentFolderID],[ComplianceSearchTypeID],[PredefinedSearchesCreated],[CanDelete],[RestrictedAccessTypeID])
  VALUES (@AutomationFolder, @RootViewID, @ComplianceSearchTypeID /* custom */, 0, 1, 1)
END

DECLARE @AutomationFolderID int
SET @AutomationFolderID = (SELECT [ComplianceSearchFolderID] FROM dbo.ComplianceSearchFolder WHERE Name = @AutomationFolder)

---------------------------------------------------------------------------
-- Custom View to show report definitions
--
DELETE FROM dbo.ComplianceSavedSearch WHERE SearchName = '000.01.001-ReportDefinitionsExport' AND RestrictedAccessTypeID = 1

INSERT dbo.ComplianceSavedSearch(
  SearchName,
  [Description],
  SearchSQL,
  SearchMapping,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID,
  CreatedBy,
  CreationDate
)
VALUES(
  '000.01.001-ReportDefinitionsExport',
  'This view shows the definitions of all reports.',
  '
    SELECT  
       ss.[ComplianceSavedSearchID]
       ,ss.[SearchName]
       ,ss.[Description]
       ,dbo.CustomBase64Encode(ss.[SearchSQL])as [EncodedSearchSQL]
       ,dbo.CustomBase64Encode(CONVERT(nvarchar(max),ss.[SearchMapping])) AS [EncodedSearchMapping]
       ,dbo.CustomBase64Encode(CONVERT(nvarchar(max),ss.[SearchXML])) AS [EncodedSearchXML]
       ,ss.[CreationDate]
       ,ss.[ComplianceSearchTypeID]
       ,ss.[ComplianceSearchFolderID]
       --,csf.[Name] AS [FolderFullName]
       --,rsct.[ResourceValue] AS [FolderName]
       ,dbo.CustomGetFullFolderPath(ss.[ComplianceSearchFolderID]) AS [FullFolderName]
       ,ss.[CreatedByOperatorID]
       ,ss.[RestrictedAccessTypeID]
       ,ss.[CanDelete]
     FROM [dbo].[ComplianceSavedSearch_MT] AS ss
       JOIN [dbo].[ComplianceSearchFolder_MT] as csf ON csf.ComplianceSearchFolderID = ss.ComplianceSearchFolderID
       --JOIN [dbo].[ResourceStringCultureType] as rsct on rsct.[ResourceString] = csf.NameResourceName AND rsct.CultureType = ''en-US''
     WHERE ss.ComplianceSearchTypeID > 0 and ss.ComplianceSavedSearchSystemID is NULL
  ',
  NULL,
  @ComplianceSearchTypeID  /* custom query */,
  @AutomationFolderID,
  SYSTEM_USER,
  GETUTCDATE()
)

---------------------------------------------------------------------------
-- Make sure that a NBN Custom Reports Folders exists

--DECLARE @RootViewID int
--SET @RootViewID= (SELECT ComplianceSearchFolderID FROM dbo.ComplianceSearchFolder WHERE NameResourceName = 'ComplianceSearchFolder.Reports')

-- Find and Create the NBN Custom Reports Folder
DECLARE @NBNReportsFolder NVARCHAR(128)
SET @NBNReportsFolder = 'NBN Standard Reports'

IF NOT EXISTS (SELECT ComplianceSearchFolderID FROM dbo.ComplianceSearchFolder WHERE Name = @NBNReportsFolder)
BEGIN
  INSERT INTO [ComplianceSearchFolder] ([Name],[ParentFolderID],[ComplianceSearchTypeID],[PredefinedSearchesCreated],[CanDelete],[RestrictedAccessTypeID])
  VALUES (@NBNReportsFolder, @RootViewID, @ComplianceSearchTypeID /* custom */, 0, 1, 1)
END

DECLARE @NBNReportsFolderID int
SET @NBNReportsFolderID = (SELECT [ComplianceSearchFolderID] FROM dbo.ComplianceSearchFolder WHERE Name = @NBNReportsFolder)

---------------------------------------------------------------------------
-- Custom View to report Software License Positions
--
DELETE FROM dbo.ComplianceSavedSearch WHERE SearchName = '090.01.03 Software License Positions' AND RestrictedAccessTypeID = 1

INSERT dbo.ComplianceSavedSearch(
  SearchName,
  [Description],
  SearchSQL,
  SearchMapping,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID,
  CreatedBy,
  CreationDate
)
VALUES(
  '090.01.03 Software License Positions',
  'This report mimics the standard FNMS Compliance grid view.',
  '
    SELECT  
      --SoftwareLicenseID,
      [Name] as [LicenseName],
      case PublisherName when ''Not Set'' then '''' else PublisherName end as [Publisher],
      ProductName,
      case VersionName when ''Not Set'' then '''' else VersionName end as [Version],    
      case EditionName when ''Not Set'' then '''' else EditionName end as [Edition],  
      ComplianceStatus,
      LicenseType,
      NumberPurchased as [Purchased],
      NumberInstalled as [Consumed],
      NumberUsed as [Used],
      NumberAllocated as [Allocated]
    FROM  
      [dbo].[SoftwareLicenseByApplication]
  ',
  NULL,
  @ComplianceSearchTypeID  /* custom query */,
  @NBNReportsFolderID,
  SYSTEM_USER,
  GETUTCDATE()
)

---------------------------------------------------------------------------
-- Custom View to report License TrueUp
--
DELETE FROM dbo.ComplianceSavedSearch WHERE SearchName = '090.01.05 License TrueUp' AND RestrictedAccessTypeID = 1

INSERT dbo.ComplianceSavedSearch(
  SearchName,
  [Description],
  SearchSQL,
  SearchMapping,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID,
  CreatedBy,
  CreationDate
)
VALUES(
  '090.01.05 License TrueUp',
  'Ability to report on cost of licenses. Required to support License Compliance Reporting. (Identifies value of licenses in use, cost of resolving licenses in breach and value of unused licenses to review).',
  '
    SELECT
      --sl.SoftwareLicenseID AS [SoftwareLicenseID]
      sl.Name AS [Name]
      ,ISNULL(sl.Version,'') AS [Version]
      ,ISNULL(sl.Edition,'') AS [Edition]
      --,ISNULL(sl.VendorName,'') AS [PublisherName]
      ,ISNULL(slp.ProductName,'') AS [ProductName]
      ,sl.TypeDefaultValue AS [LicenseType]
      --,sl.SoftwareLicenseMetricID
      ,case
         -- custom metrics
         when slmx.[LicenseMetric] is not null then slmx.[LicenseMetric]
         -- microsoft types
         when sl.TypeDefaultValue like ''Microsoft Server%'' and sl.Edition = ''Datacenter'' then ''Datacenter Server''
         when sl.TypeDefaultValue like ''Microsoft Server%'' and sl.Edition = ''Standard'' then ''Standard Server''
         -- generic types
         when sl.TypeDefaultValue = ''User'' or sl.TypeDefaultValue = ''Named User'' then ''User''
         when sl.TypeDefaultValue = ''Volume'' or sl.TypeDefaultValue = ''Device'' then ''Device''       
         else ''
       end [LicenseMetric]
      ,sl.NumberPurchased AS [Purchased]
      ,sl.NumberInstalled AS [Consumed]
      --,sl.NumberCalculated
      --,sl.NumberUsed AS [Used]
      ,(sl.NumberPurchased - sl.NumberInstalled) AS [Shortfall/Availability]
      ,case
         when ISNULL(sl.[PurchasePrice],0) > 0 THEN sl.[PurchasePrice]
         else ISNULL(lpo.AvUnitPrice,0) 
       end AS [UnitPrice]
      ,case
         when sl.NumberPurchased - sl.NumberInstalled > 0 then ''
         when ISNULL(sl.[PurchasePrice],0) > 0 THEN CONVERT(nvarchar(20),-(sl.NumberPurchased - sl.NumberInstalled) * sl.[PurchasePrice])
         when ISNULL(lpo.AvUnitPrice,0) > 0 THEN CONVERT(nvarchar(20),-(sl.NumberPurchased - sl.NumberInstalled) * lpo.AvUnitPrice)
         else ''
       end AS [TrueUpCost]
      --,ISNULL(sl.[ChargeBackPrice],0) AS [ChargeBackPrice]      
      --,sl.ParentLicenseID AS [ParentLicenseID]
    FROM 
    (
      SELECT slcus.*, pub.VendorName, slt.TypeDefaultValue FROM SoftwareLicenseCurrentUserScoped AS slcus
        LEFT OUTER JOIN Vendor AS pub ON pub.VendorID = slcus.PublisherID
        LEFT OUTER JOIN SoftwareLicenseTypeI18N AS slt ON slt.SoftwareLicenseTypeID = slcus.LicenseTypeID
    ) AS sl
      -- Additional joins
      LEFT OUTER JOIN 
      (
        SELECT 
          slp_maxed.SoftwareLicenseID, 
          CASE 
            WHEN slp_maxed.ProductCount = 1 THEN stp.ProductName 
            ELSE ( SELECT ResourceValue FROM dbo.GetTranslation(''SoftwareLicenseProduct.Multiple'') ) 
          END AS ProductName 
        FROM 
        (
          SELECT 
            slp_inner.SoftwareLicenseID, 
            MIN(slp_inner.SoftwareTitleProductID) AS SoftwareTitleProductID, 
            COUNT(slp_inner.SoftwaretitleProductID) AS ProductCount 
          FROM dbo.SoftwareLicenseProduct AS slp_inner 
          WHERE slp_inner.Supplementary = 0 
          GROUP BY slp_inner.SoftwareLicenseID
        ) AS slp_maxed 
        INNER JOIN dbo.SoftwareTitleProduct AS stp ON stp.SoftwareTitleProductID = slp_maxed.SoftwareTitleProductID
      ) slp ON slp.SoftwareLicenseID = sl.SoftwareLicenseID
      -- Purchase Orders
      LEFT OUTER JOIN 
      (      
        SELECT
          lpox.SoftwareLicenseID
          ,SUM(lpox.Quantity * lpox.UnitPrice) AS TotalPrice
          ,SUM(lpox.Quantity) AS TotalQuantity
          ,case 
             when SUM(lpox.UnitPrice) is NULL THEN 0
             when SUM(lpox.UnitPrice) = 0 THEN 0
             when SUM(lpox.Quantity) = 0 THEN 0
             else SUM(lpox.Quantity * lpox.UnitPrice) / SUM(lpox.Quantity)
           end as AvUnitPrice
        FROM 
        (
          SELECT 
            lpo_inner.SoftwareLicenseID
            ,lpo_inner.Quantity
            ,lpo_inner.UnitPrice
          FROM
          (
            SELECT
              slpodi.[SoftwareLicenseID]
              ,sl.[Name]
              ,slpodi.[PurchaseOrderID]
              ,slpodi.[PurchaseOrderDetailID]
              ,slpodi.[PurchaseOrderNo]
              ,pod.[SequenceNumber]
              ,slpodi.[PurchaseOrderDetailItemDescription]
              --,slpodi.[PurchaseOrderDetailQuantity]
              ,pod.PurchaseOrderDetailTypeID
              ,pod.Quantity
              ,pod.LicenseQuantity
              ,pod.UnitPrice
              ,pod.TotalPrice
              ,slpodi.[PurchaseOrderDetailLicensePartNo]
              ,v.[VendorName]
              ,slpodi.[PurchaseOrderDate]
            FROM dbo.[SoftwareLicensePurchaseOrderDetailInfo] as slpodi
              JOIN dbo.[SoftwareLicense] as sl on sl.[SoftwareLicenseID] = slpodi.[SoftwareLicenseID]
              JOIN dbo.[PurchaseOrderDetail] as pod on pod.[PurchaseOrderDetailID] = slpodi.[PurchaseOrderDetailID]
              JOIN dbo.[PurchaseOrder] as po on po.[PurchaseOrderID] = slpodi.[PurchaseOrderID]
              JOIN dbo.[Vendor] as v on v.[VendorID] = po.[VendorID]
            WHERE pod.PurchaseOrderDetailTypeID = 2
          ) as lpo_inner
        ) lpox
        GROUP BY lpox.SoftwareLicenseID       
      ) AS lpo ON lpo.SoftwareLicenseID = sl.SoftwareLicenseID
      -- License Metrics
      LEFT OUTER JOIN 
      (      
        SELECT
          slm.[SoftwareLicenseMetricID]
          ,slm.[SoftwareLicenseTypeID]
          ,slm.[ResourceName]
          ,rsct.ResourceValue AS [LicenseMetric]
          ,slm.[DefaultValue]
        FROM [dbo].[SoftwareLicenseMetric] AS slm
          JOIN [dbo].[ResourceStringCultureType] AS rsct ON rsct.ResourceString = slm.ResourceName and rsct.CultureType = ''en-US''
      ) AS slmx ON slmx.SoftwareLicenseMetricID = sl.SoftwareLicenseMetricID
  ',
  NULL,
  @ComplianceSearchTypeID  /* custom query */,
  @NBNReportsFolderID,
  SYSTEM_USER,
  GETUTCDATE()
)

---------------------------------------------------------------------------
-- Custom View to report Software Title Summary
--
DELETE FROM dbo.ComplianceSavedSearch WHERE SearchName = '090.01.09 Software Title Summary' AND RestrictedAccessTypeID = 1

INSERT dbo.ComplianceSavedSearch(
  SearchName,
  [Description],
  SearchSQL,
  SearchMapping,
  ComplianceSearchTypeID,
  ComplianceSearchFolderID,
  CreatedBy,
  CreationDate
)
VALUES(
  '090.01.09 Software Title Summary',
  'Report Software Title Summary records.',
  '
    SELECT
      sts.[SoftwareTitleID]
      --,[SoftwareTitleTypeID]
      ,sts.[SoftwareTitleName]
      ,sts.[SoftwareTitleVersion]
      ,sts.[EditionName]
      ,sts.[ProductName]
      ,sts.[Publisher]
      ,(ROW_NUMBER() OVER(PARTITION BY sts.[SoftwareTitleProductID], sts.[EditionName] ORDER BY sts.[SoftwareTitleName], sts.[VersionWeight] desc) - 1) AS [NMinus]         
      ,sts.[EditionWeight]
      ,sts.[VersionWeight]
      --,[SoftwareTitleProductID]
      --,[SoftwareTitleActionID]
      --,sts.[SoftwareTitleClassificationID]
      ,sc.[DefaultValue] as [Classification]
      --,[SoftwareTitlePublisherID]
      --,[IsMonitoringSessions]
      --,[UsageSessions]
      --,[IsMonitoringActiveTime]
      --,[UsageActiveTime]
      --,[UsagePeriod]
      --,[Comments]
      --,[SKU]
      ,sts.[CategoryID]
      ,sts.[IsLicensable]
      ,sts.[IsSoftwareSuite]
      ,sts.[IsSoftwareSuiteMember]
      --,[IsSharableToLibrary]
      --,[OperatorManageStateID]
      ,sts.[HasInstalls]
      ,inst.[InstallCount]
      ,inst.[UsedCount]
      ,sts.[StartOfLifeDate]
      ,sts.[ReleaseDate]
      ,sts.[EndOfSalesDate]
      ,sts.[SupportedUntil]
      ,sts.[ExtendedSupportUntil]
      ,sts.[EndOfLifeDate]
   FROM [dbo].[SoftwareTitleSummary] as sts
   JOIN [dbo].[SoftwareTitleClassificationI18N] as sc on sc.[SoftwareTitleClassificationID] = sts.[SoftwareTitleClassificationID]
   LEFT OUTER JOIN
   (
     SELECT
     isw.[SoftwareTitleID]
       ,count(isw.[SoftwareTitleID]) as [InstallCount]
       ,count(isw.[IsUsed]) as [UsedCount]
     FROM [dbo].[InstalledSoftware] as isw
     GROUP BY isw.[SoftwareTitleID]
   ) as inst on inst.[SoftwareTitleID] = sts.[SoftwareTitleID]
  ',
  NULL,
  @ComplianceSearchTypeID  /* custom query */,
  @NBNReportsFolderID,
  SYSTEM_USER,
  GETUTCDATE()
)

GO
