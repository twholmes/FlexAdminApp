---------------------------------------------------------------------------
-- This sqlcmd script can be executed to configure data model
-- customisations for this FlexNet Manager Suite implementation.
--
-- Copyright (C) 2014-2017 Flexera Software
---------------------------------------------------------------------------

SET NOCOUNT ON

PRINT 'Configuring data model customizations'

DECLARE @sn INTEGER

----------------------------------------------------------------------
-- Configure custom properties for assets

SET @sn = 0

-- General tab

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, /* asset */
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetUQAssetTag',
	@DisplayNameInPage = 'UQ asset tag:',
	@DisplayNameInReport = 'UQ Asset Tag',
	@UIFieldTypeID = 4, /* text */
	@UIInsertTypeID = 2, /* after */
	@RelativePositionTo = 'Asset_tag',
	@Required = 0,
	@SequenceNumber = @sn

SET @sn = @sn + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, /* asset */
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetDualBoot',
	@DisplayNameInPage = 'Dual boot:',
	@DisplayNameInReport = 'Dual Boot',
	@UIFieldTypeID = 9, /* checkbox */
	@UIInsertTypeID = 2, /* after */
	@RelativePositionTo = 'Status',
	@Required = 0,
	@SequenceNumber = @sn

SET @sn = @sn + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, /* asset */
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetComputerUsage',
	@DisplayNameInPage = 'Computer Usage:',
	@DisplayNameInReport = 'Computer Usage',
	@UIFieldTypeID = 8, /* drop-down */
	@UIInsertTypeID = 2, /* after */
	@DataSource = ',Specialist Research, Lecture, Meeting, Teaching, Specialist Teaching, Staff Primary, Staff Secondary, HDR Student, Staff Hotdesk, Research Wet Lab, Student General',	
	@RelativePositionTo = 'CustomAssetDualBoot',
	@Required = 0,
	@SequenceNumber = @sn

SET @sn = @sn + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, /* asset */
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetOffNetwork',
	@DisplayNameInPage = 'Off network:',
	@DisplayNameInReport = 'Off Network',
	@UIFieldTypeID = 9, /* checkbox */
	@UIInsertTypeID = 2, /* after */
	@RelativePositionTo = 'CustomAssetComputerUsage',
	@Required = 0,
	@SequenceNumber = @sn

SET @sn = @sn + 1

-- Financial tab

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, /* asset */
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetUQWarrentyType',
	@DisplayNameInPage = 'UQ Warranty Type:',
	@DisplayNameInReport = 'UQ Warranty Type',
	@UIFieldTypeID = 4, /* text */
	@UIInsertTypeID = 2, /* after */
	@RelativePositionTo = 'EndOfWarranty',
	@Required = 0,
	@SequenceNumber = @sn

SET @sn = @sn + 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, /* asset */
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetReplacementBy',
	@DisplayNameInPage = 'Replacement By:',
	@DisplayNameInReport = 'Replacement By',
	@UIFieldTypeID = 8, /* drop-down */
	@UIInsertTypeID = 2, /* after */
	@DataSource = ',Org Unit, ITS',	
	@RelativePositionTo = 'CustomAssetUQWarrentyType',
	@Required = 0,
	@SequenceNumber = @sn

SET @sn = @sn + 1

--EXEC dbo.RemovePropertyFromWebUI
--@TargetTypeID = 9, /* asset */
--@Name = 'CustomAssetUQWarrentyType',
--@DeleteFromDB = 1

EXEC dbo.AddPropertyToWebUIPropertiesPage
	@TargetTypeID = 9, /* asset */
	@ExcludeTargetSubTypeIDs = '',
	@Name = 'CustomAssetReplacementYear',
	@DisplayNameInPage = 'Replacement Year:',
	@DisplayNameInReport = 'Replacement Year',
	@UIFieldTypeID = 8, /* drop-down */
	@UIInsertTypeID = 2, /* after */
	@DataSource = ',2022,2023,2024,2025,2026,2027,2028,2029,2030',	
	@RelativePositionTo = 'CustomAssetReplacementBy',
	@Required = 0,
	@SequenceNumber = @sn

GO
