-- Identify if Site as been auto populated from Active Directory
IF OBJECT_ID('tempdb..#Site') IS NOT NULL
	DROP TABLE #Site

SELECT	site.SiteID
INTO	#Site
FROM	dbo.Site AS site
WHERE	site.AutoPopulated = CAST('True' AS BIT)

-- Identify if Site/Subnet has been auto populated from Active Directory
IF OBJECT_ID('tempdb..#SiteSubnet') IS NOT NULL
	DROP TABLE #SiteSubnet

SELECT	subnet.SubnetID
INTO	#SiteSubnet
FROM	dbo.SiteSubnet AS subnet
WHERE	subnet.AutoPopulated = CAST('True' AS BIT)
										
-- Identify if Site/Subnet to Beacon mapping exists for auto populated records
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