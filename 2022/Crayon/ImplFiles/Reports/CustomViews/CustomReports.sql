---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure custom reports
--
-- Copyright (C) 2021 Crayon Austrlia
---------------------------------------------------------------------------

DECLARE @ReportFolderID int

SET @ReportFolderID = (
	SELECT csf.[ComplianceSearchFolderID] 
	FROM dbo.ComplianceSearchFolder csf
	WHERE csf.Name = 'Reports.Inventory'
)


---------------------------------------------------------------------------------------------
-- Custom View to compare raw fnMS inventory to those  
--
DELETE FROM dbo.ComplianceSavedSearch WHERE SearchName = 'Raw User Virtual Application Access' AND RestrictedAccessTypeID = 1

INSERT dbo.ComplianceSavedSearch(
	SearchName,
	[Description],
	SearchSQL,
	SearchMapping,
	ComplianceSearchTypeID,
	ComplianceSearchFolderID,
	RestrictedAccessTypeID,
	CreatedBy,
	CreationDate
)
VALUES(
	'Raw User to Virtual Application Access',
	'This report returns a list of access that users have been given to virtualised applications.  This includes VMWare App Volumes and VMWare Horizon Apps.  NOTE: This report has been authored in SQL query and can therefore not be edited in the FNMS Web UI',
	'SELECT 
	iu.UserName,
	iu.Domain AS UserDomain,
	iu.SAMAccountName,
	iie.DisplayName,
	iie.Version,
	iie.Publisher,
	iie.Evidence,
	am.DefaultValue AS AccessMode,
	ccn.ConnectionName
FROM dbo.ImportedInstallerEvidence iie
	JOIN dbo.ComplianceConnection ccn
		ON ccn.ComplianceConnectionID = iie.ComplianceConnectionID
	JOIN dbo.ImportedRemoteUserToApplicationAccess irutaa
		ON irutaa.ExternalInstallerEvidenceID = iie.ExternalInstallerID
			AND irutaa.ComplianceConnectionID = iie.ComplianceConnectionID
	JOIN dbo.ImportedUser iu
		ON iu.ExternalID = irutaa.ExternalUserID
			AND
			iu.ComplianceConnectionID = irutaa.ComplianceConnectionID
	JOIN dbo.AccessModeI18N am
		ON am.AccessModeID = iie.AccessModeID
ORDER BY iu.SAMAccountName, iu.Domain, iie.DisplayName, iie.Version
		',
	'<ArrayOfCustomViewColumnMapping />',
	1 /* custom query */,
	@ReportFolderID,
	1 /* RestrictedAccessTypeID */,
	SYSTEM_USER,
	GETUTCDATE()
)




