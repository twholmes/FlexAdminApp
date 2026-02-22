---------------------------------------------------------------------------
-- sqlcmd script to add tables to the inventory beacon database that are
-- minimally required by the business adapter. This makes it possible to use
-- the business adapter to stage data into the inventory beacon database.
--
-- Copyright (C) 2020 Crayon Australia
---------------------------------------------------------------------------

----------------------------------------------------------------------
-- ADUsers

IF EXISTS (
  SELECT  *
  FROM  sys.objects
  WHERE object_id = OBJECT_ID(N'[dbo].[ADUsers]')
    AND type IN (N'U')
)
  DROP TABLE [dbo].[ADUsers]
GO

CREATE TABLE [dbo].[ADUsers]
(
  [SAMAccountName] [varchar](64) COLLATE Latin1_General_CI_AS NOT NULL,
  [Domain] [varchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
  [Surname]  [varchar](64),
  [GivenName] [varchar](64),
  [Title] [varchar](128),  
  [TelephoneNumber] [varchar](64),
  [ExportDate] [varchar](256),
  [Location] [varchar](256),
  [LastLogon] [varchar](64),  
  [BusinessUnit] [varchar](256),      
  [Email] [varchar](200),
  [UserPrincipalName] [varchar](256), 
  [CanonicalName] [varchar](512),   
  [DateCreated] [datetime] NOT NULL DEFAULT (getdate()),
  [LastUpdate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]

GO

CREATE INDEX IDX_ADUSERS_EMAIL
ON [dbo].[ADUsers] (Email)
 
GO
