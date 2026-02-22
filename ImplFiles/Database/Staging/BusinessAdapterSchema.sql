---------------------------------------------------------------------------
-- sqlcmd script to add tables to the inventory beacon database that are
-- minimally required by the business adapter. This makes it possible to use
-- the business adapter to stage data into the inventory beacon database.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

----------------------------------------------------------------------
-- ComplianceSetting

IF EXISTS (
  SELECT  *
  FROM  sys.objects
  WHERE object_id = OBJECT_ID(N'[dbo].[ComplianceSetting]')
    AND type IN (N'U')
)
  DROP TABLE [dbo].[ComplianceSetting]
GO

CREATE TABLE [dbo].[ComplianceSetting](
  [ComplianceSettingID] [int] IDENTITY(1,1) NOT NULL,
  [SettingName] [nvarchar](128) COLLATE Latin1_General_CI_AS NOT NULL,
  [SettingValue] [nvarchar](128) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO


----------------------------------------------------------------------
-- DatabaseConfiguration

IF EXISTS (
  SELECT  *
  FROM  sys.objects
  WHERE object_id = OBJECT_ID(N'[dbo].[DatabaseConfiguration]')
    AND type IN (N'U')
)
  DROP TABLE [dbo].[DatabaseConfiguration]
GO

CREATE TABLE [dbo].[DatabaseConfiguration](
  [Property] [varchar](32) COLLATE Latin1_General_CI_AS NOT NULL,
  [Value] [varchar](256) COLLATE Latin1_General_CI_AS NOT NULL,
  [Created] [datetime] NOT NULL DEFAULT (getdate()),
  [LastUpdate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]

INSERT INTO DatabaseConfiguration VALUES ('CMSchemaVersion', '8.6', GETDATE(), GETDATE())
GO


----------------------------------------------------------------------
-- ADDomains

IF EXISTS (
  SELECT  *
  FROM  sys.objects
  WHERE object_id = OBJECT_ID(N'[dbo].[ADDomains]')
    AND type IN (N'U')
)
  DROP TABLE [dbo].[ADDomains]
GO

CREATE TABLE [dbo].[ADDomains]
(
  [FQDN] [varchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
  [Domain] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
  [DomainServer] [varchar](100) COLLATE Latin1_General_CI_AS NOT NULL,  
  [SAMAccountName] [varchar](64) COLLATE Latin1_General_CI_AS NOT NULL,
  [DateCreated] [datetime] NOT NULL DEFAULT (getdate()),
  [LastUpdate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]

GO

--INSERT INTO [dbo].[ADDomains] ([FQDN],[Domain],[DomainServer],[SAMAccountName])
--VALUES ('flexdemo.com','FLEXDEMO','flexapp.flexdemo.com','FLEXDEMO\operator2')

INSERT INTO [dbo].[ADDomains] ([FQDN],[Domain],[DomainServer],[SAMAccountName])
VALUES ('nbndc.local','nbndc','server.nbndc.local','nbndc\svc_fnmp_prod')

GO
