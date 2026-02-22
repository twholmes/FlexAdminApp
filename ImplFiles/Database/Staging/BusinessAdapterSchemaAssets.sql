---------------------------------------------------------------------------
-- sqlcmd script to add tables to the inventory beacon database that are
-- minimally required by the business adapter. This makes it possible to use
-- the business adapter to stage data into the inventory beacon database.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

----------------------------------------------------------------------
-- ADDevices

IF EXISTS (
  SELECT  *
  FROM  sys.objects
  WHERE object_id = OBJECT_ID(N'[dbo].[ADDevices]')
    AND type IN (N'U')
)
  DROP TABLE [dbo].[ADDevices]
GO

CREATE TABLE [dbo].[ADDevices]
(
  [ComputerName] [varchar](64) COLLATE Latin1_General_CI_AS NOT NULL,
  [Domain] [varchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
  [ExportDate] [varchar](256),
  [LastLogon] [varchar](64),
  [OperatingSystem] [varchar](256),
  [OperatingSystemVersion] [varchar](64), 
  [Location] [varchar](256),
  [BusinessUnit] [varchar](256),      
  [CanonicalName] [varchar](512), 
  [DateCreated] [datetime] NOT NULL DEFAULT (getdate()),
  [LastUpdate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]

GO

CREATE INDEX IDX_ADDevices_ComputerName
ON [dbo].[ADDevices] (ComputerName)

GO


