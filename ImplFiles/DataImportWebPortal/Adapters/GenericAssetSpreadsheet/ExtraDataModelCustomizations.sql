---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure data model
-- customisations for this FlexNet Manager Suite 2020 R1 implementation.
--
-- See the "Adding Custom Properties" chapter of the FlexNet Manager
-- Suite System Reference guide for information about configuring
-- custom properties.
--
-- Purpose is to add Remedy field as required to 'Mobile Device','Workstation','Laptop','Monitor','Telephone'
-- and another 5 fileds to 'Mobile Device'
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

USE FNMSCompliance
GO

SET NOCOUNT ON

PRINT 'Configuring data model customizations'
GO

SET NOCOUNT ON
GO

----------------------------------------------------------------------

PRINT 'Configuring asset custom properties and property dialogs'

DECLARE @AllButPhoneDeviceTypes VARCHAR(MAX)
DECLARE @AllButMobileDeviceTypes VARCHAR(MAX)
DECLARE @AllButTelephoneDeviceTypes VARCHAR(MAX)
DECLARE @AllButRemedyDeviceTypes VARCHAR(MAX)

-- used for all of the mobile device specific fields
SELECT @AllButMobileDeviceTypes = COALESCE(@AllButMobileDeviceTypes + ',' ,'') + CONVERT(NVARCHAR, AssetTypeID)
FROM dbo.AssetTypeI18N at
WHERE at.AssetTypeName NOT IN ('Mobile Device')

-- used for all of the telephone device specific fields
SELECT @AllButTelephoneDeviceTypes = COALESCE(@AllButTelephoneDeviceTypes + ',' ,'') + CONVERT(NVARCHAR, AssetTypeID)
FROM dbo.AssetTypeI18N at
WHERE at.AssetTypeName NOT IN ('Telephone')

-- used for all of the telephone or mobile device specific fields
SELECT @AllButPhoneDeviceTypes = COALESCE(@AllButPhoneDeviceTypes + ',' ,'') + CONVERT(NVARCHAR, AssetTypeID)
FROM dbo.AssetTypeI18N at
WHERE at.AssetTypeName NOT IN ('Mobile Device','Telephone')

-- used for all of the asset types where remedy SRN is mandatory
SELECT @AllButRemedyDeviceTypes = COALESCE(@AllButRemedyDeviceTypes + ',' ,'') + CONVERT(NVARCHAR, AssetTypeID)
FROM dbo.AssetTypeI18N at
WHERE at.AssetTypeName NOT IN ('Mobile Device','Workstation','Laptop','Monitor','Telephone')


DECLARE @SequenceNumber INT
SET @SequenceNumber = 1

/* Tab: General Properties */

/* Add Remedy SRN to all of the asset types and iterate sequence number */

EXEC dbo.AddPropertyToWebUIPropertiesPage 
  @TargetTypeID = 9 /* asset */,
  @Name = 'NBN-RemedyNumber',
  @TabName='Tab_General',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'Remedy SRN:',
  @DisplayNameInReport = 'NBN-RemedyNumber',
  @UIFieldTypeID = 4 /* text */,
  @UIInsertTypeID = 2 /* after */,
  @RelativePositionTo = 'Asset_tag',
  @Width = 1,
  @Required = 1, /* this only affected the WebUI not BAS and can be reverted in the [UIItem_MT] table */
  @StringLength = 15, /* Remedy ticket length */
  @ExcludeTargetSubTypeIDs = '',
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1


/* Tab: Custom Phone Properties */

EXEC dbo.AddTabToWebUIPropertiesPage
  @TargetTypeID = 9, /* Asset */
  @ExcludeTargetSubTypeIDs = @AllButPhoneDeviceTypes,
  @Name = 'CustomAssetTabPhoneProperties',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'Phone',
  @UIInsertTypeID = 2, -- after
  @RelativeTabName = 'Tab_History',
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1

/* Section: Telephone */

EXEC dbo.AddSectionToWebUIPropertiesPage
  @TargetTypeID = 9, /* Asset */
  @ExcludeTargetSubTypeIDs = @AllButTelephoneDeviceTypes,   
  @Name = 'CustomAssetSectionTelephones',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'Telephone',
  @TabName = 'CustomAssetTabPhoneProperties',
  @UIInsertTypeID = 3, -- start
  @RelativePositionTo = '',
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1

/* Section: Mobile */

EXEC dbo.AddSectionToWebUIPropertiesPage
  @TargetTypeID = 9, /* Asset */
  @ExcludeTargetSubTypeIDs = @AllButMobileDeviceTypes,    
  @Name = 'CustomAssetSectionMobiles',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'Mobile',
  @TabName = 'CustomAssetTabPhoneProperties',
  @UIInsertTypeID = 3, -- start
  @RelativePositionTo = '',
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1

/* Section: Telephone Properties */

/* Add NBN-MACAddress SRN to telephone and DON'T iterate sequence number */

EXEC dbo.AddPropertyToWebUIPropertiesPage
  @TargetTypeID = 9 /* asset */,
  @ExcludeTargetSubTypeIDs = @AllButTelephoneDeviceTypes,  
  @Name = 'NBN-MACAddress',
  @TabName='Tab_General',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'MAC Address:',
  @DisplayNameInReport = 'NBN-MACAddress',
  @UIFieldTypeID = 4 /* text */,
  @UIInsertTypeID = 2 /* after */,
  @RelativePositionTo = 'CustomAssetSectionTelephones',
  @Width = 1,
  @StringLength = 17, /* Max address length */
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1

/* Section: Mobile Properties */

/* Add host of fields for the mobile device asset */

EXEC dbo.AddPropertyToWebUIPropertiesPage
  @TargetTypeID = 9 /* asset */,
  @Name = 'NBN-PhoneNumber',
  @TabName='CustomAssetTabPhoneProperties',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'Phone number:',
  @DisplayNameInReport = 'NBN-PhoneNumber',
  @UIFieldTypeID = 4 /* text */,
  @UIInsertTypeID = 2 /* after */,
  @RelativePositionTo = 'CustomAssetSectionMobiles',
  @Width = 1,
  @StringLength = 32, /* cater for overseas numbers */
  @ExcludeTargetSubTypeIDs = @AllButMobileDeviceTypes,
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
  @TargetTypeID = 9 /* asset */,
  @Name = 'NBN-IMEI',
  @TabName='CustomAssetTabPhoneProperties',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'IMEI number:',
  @DisplayNameInReport = 'NBN-IMEI',
  @UIFieldTypeID = 4 /* text */,
  @UIInsertTypeID = 2 /* after */,
  @RelativePositionTo = 'CustomAssetSectionMobiles',
  @Width = 1,
  @StringLength = 15, /* IMEI number length */
  @ExcludeTargetSubTypeIDs = @AllButMobileDeviceTypes,
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
  @TargetTypeID = 9 /* asset */,
  @Name = 'NBN-PUK',
  @TabName='CustomAssetTabPhoneProperties',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'PUK code:',
  @DisplayNameInReport = 'NBN-PUK',
  @UIFieldTypeID = 4 /* text */,
  @UIInsertTypeID = 2 /* after */,
  @RelativePositionTo = 'CustomAssetSectionMobiles',
  @Width = 1,
  @StringLength = 8, /* PUK number length */
  @ExcludeTargetSubTypeIDs = @AllButMobileDeviceTypes,
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
  @TargetTypeID = 9 /* asset */,
  @Name = 'NBN-SIM',
  @TabName='CustomAssetTabPhoneProperties',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'SIM number:',
  @DisplayNameInReport = 'NBN-SIM',
  @UIFieldTypeID = 4 /* text */,
  @UIInsertTypeID = 2 /* after */,
  @RelativePositionTo = 'CustomAssetSectionMobiles',
  @Width = 1,
  @StringLength = 32, /* cater for overseas numbers */
  @ExcludeTargetSubTypeIDs = @AllButMobileDeviceTypes,
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1


EXEC dbo.AddPropertyToWebUIPropertiesPage
  @TargetTypeID = 9 /* asset */,
  @Name = 'NBN-PIN',
  @TabName='CustomAssetTabPhoneProperties',
  @CultureType = 'en-US',
  @DisplayNameInPage = 'PIN:',
  @DisplayNameInReport = 'NBN-PIN',
  @UIFieldTypeID = 4 /* text */,
  @UIInsertTypeID = 2 /* after */,
  @RelativePositionTo = 'CustomAssetSectionMobiles',
  @Width = 1,
  @StringLength = 8, /* PIN number length */
  @ExcludeTargetSubTypeIDs = @AllButMobileDeviceTypes,
  @SequenceNumber = @SequenceNumber

SET @SequenceNumber = @SequenceNumber + 1



/* ************************************************************************
 * Add custom tabs, sections & properties for user records
 * ************************************************************************ */

/*
EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 9, @Name = 'NBN-PIN', @DeleteFromDB = 1
EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 9, @Name = 'NBN-SIM', @DeleteFromDB = 1
EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 9, @Name = 'NBN-PUK', @DeleteFromDB = 1
EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 9, @Name = 'NBN-IMEI', @DeleteFromDB = 1
EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 9, @Name = 'NBN-PhoneNumber', @DeleteFromDB = 1

EXEC dbo.RemoveSectionFromWebUI  @TargetTypeID = 9, @Name = 'CustomAssetSectionMobiles'

EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 9, @Name = 'NBN-MACAddress', @DeleteFromDB = 1

EXEC dbo.RemoveSectionFromWebUI  @TargetTypeID = 9, @Name = 'CustomAssetSectionTelephones'

EXEC dbo.RemoveTabFromWebUI  @TargetTypeID = 9, @Name = 'CustomAssetTabPhoneProperties'

EXEC dbo.RemovePropertyFromWebUI @TargetTypeID = 9, @Name = 'NBN-RemedyNumber', @DeleteFromDB = 1
*/
