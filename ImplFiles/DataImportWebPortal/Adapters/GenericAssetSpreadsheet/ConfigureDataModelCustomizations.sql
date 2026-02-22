---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure data model
-- customisations for this FlexNet Manager Suite implementation.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

USE $(DBName)
GO

SET NOCOUNT ON
PRINT 'Configuring data model customizations for NBN'

GO


-- Clear out previous customisations

/*
EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 13, @Name = 'CustomSoftwareTitlesCounterfeit', @DeleteFromDB = 1
*/


/* ************************************************************************
 * Add custom tabs, sections & properties for asset records
 * ************************************************************************ */

DECLARE @sn INT
SET @sn = 0

-- Tab: Custom Properties
EXEC dbo.AddTabToWebUIPropertiesPage
	@TargetTypeID = 9, -- Asset
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetTabCustomProperties',
	@CultureType = 'en-US',
	@DisplayNameInPage = 'Custom Properties',
	@UIInsertTypeID = 2, -- after
	@RelativeTabName = 'Tab_History',
	@SequenceNumber = @sn

SET @sn = @sn + 1

-- Section: Asset Register
EXEC dbo.AddSectionToWebUIPropertiesPage
	@TargetTypeID = 9, -- Asset
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetSectionAssetRegister',
	@CultureType = 'en-US',
	@DisplayNameInPage = 'Asset Register',
	@TabName = 'CustomAssetTabCustomProperties',
	@UIInsertTypeID = 3, -- start
	@RelativePositionTo = '',
	@SequenceNumber = @sn

SET @sn = @sn + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, -- Asset
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetRemedySRN',
	@DisplayNameInPage = 'Remedy SRN:',
	@DisplayNameInReport = 'Remedy SRN',
	@UIFieldTypeID = 4, -- Text
	@UIInsertTypeID = 2, -- After
	@RelativePositionTo = 'CustomAssetSectionAssetRegister',
	@SequenceNumber = @sn

SET @sn = @sn + 1

-- Section: Other Details
EXEC dbo.AddSectionToWebUIPropertiesPage
	@TargetTypeID = 9, -- Asset
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetSectionOtherDetails',
	@CultureType = 'en-US',
	@DisplayNameInPage = 'Other Details',
	--@TabName = 'Tab_Custom',
	@UIInsertTypeID = 2, -- after
	@RelativePositionTo = 'CustomAssetRemedySRN',
	@SequenceNumber = @sn

SET @sn = @sn + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, -- Asset
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetMacAddress',
	@DisplayNameInPage = 'MAC Address:',
	@DisplayNameInReport = 'MAC Address',
	@UIFieldTypeID = 4, -- Text
	@UIInsertTypeID = 2, -- After
	@RelativePositionTo = 'CustomAssetSectionOtherDetails',
	@SequenceNumber = @sn

SET @sn = @sn + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, -- Asset
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetIMEI',
	@DisplayNameInPage = 'IMEI:',
	@DisplayNameInReport = 'IMEI',
	@UIFieldTypeID = 4, -- Text
	@UIInsertTypeID = 2, -- After
	@RelativePositionTo = 'CustomAssetMacAddress',
	@SequenceNumber = @sn

SET @sn = @sn + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, -- Asset
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetPhoneNumber',
	@DisplayNameInPage = 'Phone NUmber:',
	@DisplayNameInReport = 'Phone Number',
	@UIFieldTypeID = 4, -- Text
	@UIInsertTypeID = 2, -- After
	@RelativePositionTo = 'CustomAssetIMEI',
	@SequenceNumber = @sn

SET @sn = @sn + 1

GO


/* ************************************************************************
 * Add custom tabs, sections & properties for user records
 * ************************************************************************ */

/*
EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 15, @Name = 'CustomUserNormalised', @DeleteFromDB = 1
EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 15, @Name = 'CustomUserPrimaryUserAccount', @DeleteFromDB = 1
EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 15, @Name = 'CustomUserPrimaryUserDomain', @DeleteFromDB = 1
*/

