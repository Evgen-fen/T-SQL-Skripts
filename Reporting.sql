USE [database];
GO

--Create a schema and table for a report

CREATE SCHEMA [Reporting] ;
GO

CREATE TABLE [Reporting].MergedDuplicateBrandsMapping(
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OldId] [int]  NOT NULL,
	[NewId] [int]  NOT NULL,
	[CreatedOn] [datetime] DEFAULT GETUTCDATE()
);
GO


INSERT INTO [Reporting].MergedDuplicateBrandsMapping (OldId,[NewId])
SELECT OldId,[NewId]
FROM [dbo].[Evgeny_MergedBrands]

SELECT OldId,[NewId]
FROM[Reporting].MergedDuplicateBrandsMapping 
GROUP BY  OldId,[NewId]