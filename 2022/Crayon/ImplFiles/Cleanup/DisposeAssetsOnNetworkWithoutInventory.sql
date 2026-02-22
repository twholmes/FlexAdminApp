-- Copyright (C) 2015-2017 Flexera Software

-- Mark assets as disposed if they don't have inventory, and aren't
-- explicitly marked as "Off network" in the CustomAssetOffNetwork
-- custom property.

UPDATE a
SET AssetStatusID = 5 -- Disposed
	, DisposalDate = GETDATE()
	, UpdatedUser = SYSTEM_USER + ' (Auto-disposal behaviour)'
	, UpdatedDate = GETDATE()
FROM
	dbo.Asset a
	JOIN dbo.AssetType at ON at.AssetTypeID = a.AssetTypeID
	JOIN dbo.ComplianceComputer cc
		ON cc.AssetID = a.AssetID -- Only dispose "managed" asset types (that have a ComplianceComputer record)
		AND cc.ComplianceComputerStatusID = 4 -- where computer is a "dummy" (missing inventory) record
	LEFT OUTER JOIN (
		dbo.AssetTypeProperty atp
		JOIN dbo.AssetPropertyValue apv ON apv.AssetTypePropertyID = atp.AssetTypePropertyID
	) ON apv.AssetID = a.AssetID AND atp.PropertyName = 'CustomAssetOffNetwork'
WHERE
	ISNULL(apv.PropertyValue, '') != 'true' -- Asset is not explicitly marked as "Off Network"
	AND a.AssetStatusID != 5 -- Disposed

GO
