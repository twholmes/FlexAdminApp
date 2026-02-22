---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure application settings
-- for this FlexNet Manager Suite implementation.
--
-- Copyright (C) 2014-2016 Flexera Software
---------------------------------------------------------------------------

USE $(DBName)
GO

SET NOCOUNT ON

PRINT 'Configuring application settings'


-- Default MaxDaysToKeepLicenseReconcileResults value is 60 days, but there is no point
-- to keeping data for this long and it can result in a significant amount of disk space
-- being consumed. A lower retention period is used to avoid unnecessary space usage.
--
-- The out-of-the-box default setting may change in a future release (see FNMS-35201),
-- in which case this statement will no longer be needed.
PRINT 'Ensuring MaxDaysToKeepLicenseReconcileResults configuration setting is set to 7 days'
UPDATE dbo.ComplianceSetting SET SettingValue = '7' /* days */ WHERE SettingName = 'MaxDaysToKeepLicenseReconcileResults' AND SettingValue != '7'


-- TODO: Add customization code here
