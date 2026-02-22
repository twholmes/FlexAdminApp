-- Identify all Sites
IF OBJECT_ID('tempdb..#Site') IS NOT NULL
	DROP TABLE #Site

SELECT	site.SiteID
INTO	#Site
FROM	dbo.Site AS site

-- Identify all Sites/Subnets
IF OBJECT_ID('tempdb..#SiteSubnet') IS NOT NULL
	DROP TABLE #SiteSubnet

SELECT	subnet.SubnetID
INTO	#SiteSubnet
FROM	dbo.SiteSubnet AS subnet
WHERE	subnet.AutoPopulated = CAST('True' AS BIT)
										
-- Identify if Site/Subnet to Beacon mapping exists
IF OBJECT_ID('tempdb..#BeaconSiteSubnetMapping') IS NOT NULL
	DROP TABLE #BeaconSiteSubnetMapping

SELECT	bsm.SubnetID,
		bsm.BeaconID
INTO	#BeaconSiteSubnetMapping
FROM	dbo.BeaconSiteSubnetMapping AS bsm
INNER JOIN
		#SiteSubnet AS subnet On subnet.SubnetID = bsm.SubnetID

BEGIN TRANSACTION T1

-- Remove Site
EXEC dbo.SiteRemoveBatch
					
-- Remove Site/Subnet to Beacon mapping
EXEC dbo.BeaconSiteSubnetMappingRemoveBatch
										
-- Remove Site/Subnet records
EXEC dbo.SiteSubnetRemoveBatch
										
COMMIT TRANSACTION T1