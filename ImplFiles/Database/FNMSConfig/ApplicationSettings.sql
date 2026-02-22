---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure application settings
-- for this FlexNet Manager Suite implementation.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

SET NOCOUNT ON

PRINT 'Configuring application settings'


---------------------------------------------------------
-- Configure inventory directory exclusions. (This is done via SQL as there is no user interface to apply this configuration.)
--
-- The list of directories here is based on:
-- 1. Common directories which may contain a large number of files unrelated to identification of installed software
--
-- 2. Discovery of particular directories on individual computers which have been found to contain an unusually large number of files.
--    Having a huge number of files can cause inventory gathering to perform poorly.

-- Ensure Target__unix exists
EXEC dbo.BeaconTargetPutByNameInternal @Name = 'Target__unix', @Internal = 1, @Description = NULL, @Visible = 0

DECLARE @btid INT
SELECT @btid = BeaconTargetID FROM dbo.BeaconTarget WHERE Name = 'Target__unix'

-- NB. The value must be no longer than 256 characters.
EXEC dbo.BeaconTargetPropertyValuePutByKeyNameBeaconTargetID
	@KeyName = 'CTrackerExcludeDirectory',
	@BeaconTargetID = @btid,
	@Value = '/var/spool,/var/log'

-- Force beacons to update their policy to get latest settings
EXEC dbo.BeaconPolicyUpdateRevision

GO


---------------------------------------------------------
-- Configure an "All IP Addresses" target which can be used to do things like enabling usage & CAL inventory gathering across all devices

-- Ensure "All IP Addresses" target exists
EXEC dbo.BeaconTargetPutByNameInternal @Name = 'All IP Addresses', @Internal = 0, @Description = 'This target covers all IP address from 0.0.0.0 through 255.255.255.255.

Settings on this target are maintained and configured by the "flexadmin" script, so avoid changing them in the web UI.', @Visible = 1

DECLARE @btid INT
SELECT @btid = BeaconTargetID FROM dbo.BeaconTarget WHERE Name = 'All IP Addresses'

IF NOT EXISTS(SELECT 1 FROM dbo.BeaconFilter WHERE BeaconTargetID = @btid AND Include = 1 AND Value = '0.0.0.0/1' AND FilterType = 'SubnetFilter')
	EXEC dbo.BeaconFilterAdd @BeaconTargetID=@btid,@Include=1,@IsLinked=0,@Value='0.0.0.0/1',@FilterType='SubnetFilter'

IF NOT EXISTS(SELECT 1 FROM dbo.BeaconFilter WHERE BeaconTargetID = @btid AND Include = 1 AND Value = '128.0.0.0/1' AND FilterType = 'SubnetFilter')
	EXEC dbo.BeaconFilterAdd @BeaconTargetID=@btid,@Include=1,@IsLinked=0,@Value='128.0.0.0/1',@FilterType='SubnetFilter'


PRINT 'Configuring CAL inventory gathering option on All IP Addresses target: $(AllIPAddressesCALInventoryGatheringOption)'

IF '$(AllIPAddressesCALInventoryGatheringOption)' = 'NotSpecified'
	EXEC dbo.BeaconTargetPropertyValueRemoveByKeyNameBeaconTargetID @KeyName = 'CTrackerCALInventory', @BeaconTargetID = @btid
ELSE IF '$(AllIPAddressesCALInventoryGatheringOption)' = 'Allow'
	EXEC dbo.BeaconTargetPropertyValuePutByKeyNameBeaconTargetID @KeyName = 'CTrackerCALInventory', @BeaconTargetID = @btid, @Value = 'true'
ELSE IF '$(AllIPAddressesCALInventoryGatheringOption)' = 'DoNotAllow'
	EXEC dbo.BeaconTargetPropertyValuePutByKeyNameBeaconTargetID @KeyName = 'CTrackerCALInventory', @BeaconTargetID = @btid, @Value = 'false'
ELSE
	RAISERROR('Unexpected value for AllIPAddressesCALInventoryGatheringOption setting: $(AllIPAddressesCALInventoryGatheringOption)', 16, 1)

PRINT 'Configuring application usage gathering option on All IP Addresses target: $(AllIPAddressesUsageGatheringOption)'

IF '$(AllIPAddressesUsageGatheringOption)' = 'NotSpecified'
	EXEC dbo.BeaconTargetPropertyValueRemoveByKeyNameBeaconTargetID @KeyName = 'CUsageAgentDisabled', @BeaconTargetID = @btid
ELSE IF '$(AllIPAddressesUsageGatheringOption)' = 'Allow'
	EXEC dbo.BeaconTargetPropertyValuePutByKeyNameBeaconTargetID @KeyName = 'CUsageAgentDisabled', @BeaconTargetID = @btid, @Value = 'false'
ELSE IF '$(AllIPAddressesUsageGatheringOption)' = 'DoNotAllow'
	EXEC dbo.BeaconTargetPropertyValuePutByKeyNameBeaconTargetID @KeyName = 'CUsageAgentDisabled', @BeaconTargetID = @btid, @Value = 'true'
ELSE
	RAISERROR('Unexpected value for AllIPAddressesUsageGatheringOption setting: $(AllIPAddressesUsageGatheringOption)', 16, 1)

-- Force beacons to update their policy to get latest settings
EXEC dbo.BeaconPolicyUpdateRevision

GO
