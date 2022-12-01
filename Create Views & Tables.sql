/*****************************
  Agent Managment Module
  Created by Thomas Stockwell
  August 17, 2015

  Tables Created:
  codeTSAgent
  configTSAgentContact
  configTSAgentContactType

  Views Created:
  viewTSAgentList
  viewTSAgent

  Custom Tables Configured:
  jbCustomFields3
*/

CREATE TABLE [dbo].[codeTSAgent](
  [recnum]               [INT] IDENTITY(1,1)
                               NOT NULL,
  [code]                 [NVARCHAR](5) NOT NULL,
  [description]          [NVARCHAR](150) NOT NULL,
  [website]              [NVARCHAR](150) NOT NULL,
  [primaryCountryCode]   [NVARCHAR](5) NULL,
  [secondaryCountryCode] [NVARCHAR](5) NULL,
  [primaryPhone]         [NVARCHAR](50) NULL,
  [secondaryPhone]       [NVARCHAR](50) NULL,
  [primaryEmail]         [NVARCHAR](50) NULL,
  [secondaryEmail]       [NVARCHAR](50) NULL,
  [fax]                  [NVARCHAR](50) NULL,
  [isActiveFlag]         [BIT] NOT NULL
                               CONSTRAINT [DF_codeTSAgent_isActiveFlag] DEFAULT((1)),
  [isAccreditedFlag]     [BIT] NULL
                               CONSTRAINT [DF_codeTSAgent_isAccredited] DEFAULT((0)),
  [address1]             [NVARCHAR](50) NULL,
  [address2]             [NVARCHAR](50) NULL,
  [city]                 [NVARCHAR](50) NULL,
  [state]                [NVARCHAR](50) NULL,
  [postal]               [NVARCHAR](50) NULL,
  [countryCode]          [NVARCHAR](5) NULL,
  [notes]                [NVARCHAR](MAX) NULL,
  [username]             [NVARCHAR](20) NOT NULL,
  [datestamp]            [DATETIME] NOT NULL
                                    CONSTRAINT [DF_codeTSAgent_datestamp] DEFAULT(GETDATE()),
  [source]               [NVARCHAR](300) NULL,
  CONSTRAINT [PK_codeTSAgent] PRIMARY KEY CLUSTERED([recnum] ASC)
      WITH(PAD_INDEX = OFF,STATISTICS_NORECOMPUTE = OFF,IGNORE_DUP_KEY = OFF,ALLOW_ROW_LOCKS = ON,ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[configTSAgentContact](
  [recnum]              [INT] IDENTITY(1,1)
                              NOT NULL,
  [agentKey]            [NVARCHAR](5) NOT NULL,
  [agentContactTypeKey] [NVARCHAR](5) NOT NULL,
  [firstname]           [NVARCHAR](50) NOT NULL,
  [lastname]            [NVARCHAR](50) NOT NULL,
  [primaryPhone]        [NVARCHAR](50) NULL,
  [secondaryPhone]      [NVARCHAR](50) NULL,
  [primaryEmail]        [NVARCHAR](50) NULL,
  [secondaryEmail]      [NVARCHAR](50) NULL,
  [fax]                 [NVARCHAR](50) NULL,
  CONSTRAINT [PK_configTSAgentContact] PRIMARY KEY CLUSTERED([recnum] ASC)
      WITH(PAD_INDEX = OFF,STATISTICS_NORECOMPUTE = OFF,IGNORE_DUP_KEY = OFF,ALLOW_ROW_LOCKS = ON,ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
ON [PRIMARY]

CREATE TABLE [dbo].[codeTSAgentContactType](
  [recnum]      [INT] IDENTITY(1,1)
                      NOT NULL,
  [code]        [NVARCHAR](5) NOT NULL,
  [description] [NVARCHAR](50) NOT NULL,
  CONSTRAINT [PK_codeTSAgentContactType] PRIMARY KEY CLUSTERED([recnum] ASC)
      WITH(PAD_INDEX = OFF,STATISTICS_NORECOMPUTE = OFF,IGNORE_DUP_KEY = OFF,ALLOW_ROW_LOCKS = ON,ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
ON [PRIMARY]

CREATE VIEW [dbo].[viewTSAgentList]
AS
     SELECT
       agnt.code,
       agnt.description,
       agnt.website,
       agnt.source,
       primCountry.description AS PrimaryCountry,
       primCountry.region AS PrimaryRegion,
       secCountry.description AS SecondaryCountry,
       secCountry.region AS SecondaryRegion,
       agnt.primaryPhone,
       agnt.secondaryPhone,
       agnt.primaryEmail,
       agnt.secondaryEmail,
       agnt.fax,
       agnt.isActiveFlag,
       agnt.address1,
       agnt.address2,
       agnt.city,
       agnt.state,
       agnt.postal,
       agnt.countryCode,
       agnt.notes,
       agnt.username,
       agnt.datestamp,
       contact1.firstname AS pfirstname,
       contact1.lastname AS plastname,
       contact1.primaryPhone AS pPrimaryPhone,
       contact1.secondaryPhone AS pSecondaryPhone,
       contact1.primaryEmail AS pPrimaryEmail,
       contact1.secondaryEmail AS pSecondaryEmail,
       contact1.fax AS pFax,
       COALESCE(calculations.Total_Students,0) AS TotalStudents,
       COALESCE(calculations.Paid_Students,0) AS PaidStudents,
       COALESCE(calculations.Unpaid_Students,0) AS UnpaidStudents
     FROM
     dbo.codeTSAgent agnt
     LEFT OUTER JOIN dbo.codeCountry primCountry
       ON primCountry.code = agnt.primaryCountryCode
     LEFT OUTER JOIN dbo.codeCountry secCountry
       ON secCountry.code = agnt.secondaryCountryCode
     OUTER APPLY
     (
       SELECT TOP 1
         contc.agentKey,
         contc.firstname,
         contc.lastname,
         contc.primaryPhone,
         contc.secondaryPhone,
         contc.primaryEmail,
         contc.secondaryEmail,
         contc.fax
       FROM dbo.configTSAgentContact contc
       WHERE contc.agentKey = agnt.code) contact1
     OUTER APPLY(
       SELECT
         studAgent.customField1,
         COUNT(*) AS Total_Students,
         COUNT(CASE
                 WHEN CAST(studagent.customField2 AS DECIMAL(9,2)) > 0 THEN 1
               END) AS Paid_Students,
         COUNT(CASE
                 WHEN CAST(studagent.customField2 AS DECIMAL(9,2)) = 0 THEN 1
               END) AS Unpaid_Students
       FROM jbCustomFields3 studAgent
       WHERE studagent.customfield1 = agnt.code
       GROUP BY
         studAgent.customfield1) calculations

CREATE VIEW [dbo].[viewTSAgent]
AS
     SELECT
       dbo.jbCustomFields3.idnumber,
       dbo.viewTSAgentList.code,
       dbo.viewTSAgentList.description,
       dbo.viewTSAgentList.website,
       dbo.viewTSAgentList.source,
       dbo.viewTSAgentList.PrimaryCountry,
       dbo.viewTSAgentList.PrimaryRegion,
       dbo.viewTSAgentList.SecondaryCountry,
       dbo.viewTSAgentList.SecondaryRegion,
       dbo.viewTSAgentList.primaryPhone,
       dbo.viewTSAgentList.secondaryPhone,
       dbo.viewTSAgentList.primaryEmail,
       dbo.viewTSAgentList.secondaryEmail,
       dbo.viewTSAgentList.fax,
       dbo.viewTSAgentList.isActiveFlag,
       dbo.viewTSAgentList.address1,
       dbo.viewTSAgentList.address2,
       dbo.viewTSAgentList.city,
       dbo.viewTSAgentList.state,
       dbo.viewTSAgentList.postal,
       dbo.viewTSAgentList.countryCode,
       dbo.viewTSAgentList.notes,
       dbo.viewTSAgentList.username,
       dbo.viewTSAgentList.datestamp,
       dbo.viewTSAgentList.pfirstname,
       dbo.viewTSAgentList.plastname,
       dbo.viewTSAgentList.pPrimaryPhone,
       dbo.viewTSAgentList.pSecondaryPhone,
       dbo.viewTSAgentList.pPrimaryEmail,
       dbo.viewTSAgentList.pSecondaryEmail,
       dbo.viewTSAgentList.pFax
     FROM
     dbo.viewTSAgentList
     INNER JOIN dbo.jbCustomFields3
       ON dbo.jbCustomFields3.customField1 = dbo.viewTSAgentList.code

	   
	   
INSERT INTO [configCustomTables]([tableName],[label],[description],datestamp)
VALUES('jbCustomFields3','Agents Information','Agents',getdate())

INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields3','customField1','string','Agency','codeTSAgent',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields3','customField2','double','Amount Paid','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields3','customField3','date','Date of Payment','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields3','customField4','label','Updated By','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields3','customField5','memo','Notes','',getdate())
	   
exec spIOfficeRoleUpdate