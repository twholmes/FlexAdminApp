---------------------------------------------------------------------------
-- sqlcmd script to configure recovery model for a database.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

PRINT 'Ensuring recovery model on database $(DBName) is set to $(RecoveryModel)'
IF DATABASEPROPERTYEX('$(DBName)', 'RECOVERY') != '$(RecoveryModel)'
	ALTER DATABASE $(DBName) SET RECOVERY $(RecoveryModel)
GO
