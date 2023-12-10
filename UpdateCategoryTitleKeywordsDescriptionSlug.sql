USE [DataBase];
GO

--CREATE VIEW TABLE #CorrectCategoryTitle\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


SELECT A.Id,A.Name,A.CorrectKeywords,A.CorrectTitle,A.CorrectDescription
INTO #CorrectCategoryTitle
FROM
(
	SELECT  B.Id
		,B.Name
		,LTRIM(RTRIM(C.[Recommended Keywords])) AS CorrectKeywords
		,LTRIM(RTRIM(REPLACE(C.[Recommended Title],'Discount',''))) AS CorrectTitle
		,REPLACE(C.[Recommended Description],' [StoreName]','') AS CorrectDescription
	FROM
	(
		SELECT EntityId,'https://site.com/'+ Slug AS [URL]
		FROM UrlRecord
		WHERE EntityName = 'Category' 
	) AS A
	JOIN Category AS B ON B.Id = A.EntityId
	JOIN [vsql2\instance2].[Autoplicity_Site_Beta].[dbo].[NavigationalKeywordResearchJuly2023] AS C ON C.[URL] = A.[URL]
	UNION
	SELECT  B.Id
		,B.Name
		,LTRIM(RTRIM(C.[Recommended Keywords])) AS CorrectKeywords
		,LTRIM(RTRIM(REPLACE(C.[Recommended Title],'Discount',''))) AS CorrectTitle
		,REPLACE(C.[Recommended Description],' [StoreName]','') AS CorrectDescription
	FROM
	(
		SELECT EntityId,'https://site.com/'+ Slug AS [URL]
		FROM UrlRecord
		WHERE EntityName = 'Category' 
	) AS A
	JOIN Category AS B ON B.Id = A.EntityId
	JOIN [vsql2\instance2].[Autoplicity_Site_Beta].[dbo].[NavigationalKeywordResearchJune2023] AS C ON C.[URL] = A.[URL]
) AS A


----UPDATE Category\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

UPDATE A
SET  A.Name = B.CorrectTitle
	,A.MetaKeywords = B.CorrectKeywords
	,A.MetaDescription = B.CorrectDescription
	,A.MetaTitle = B.CorrectTitle
	,A.UpdatedOnUtc = GETUTCDATE()
FROM Category AS A
JOIN #CorrectCategoryTitle AS B ON B.Id = A.Id;

----UPDATE UrlRecord\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

UPDATE A
SET A.IsActive = 0
FROM UrlRecord AS A
JOIN #CorrectCategoryTitle AS B ON B.Id = A.EntityId
WHERE A.EntityName = 'Category';

UPDATE A
SET A.IsActive = 0
FROM UrlRecord AS A
JOIN #CorrectCategoryTitle AS B ON B.Id = A.EntityId AND A.EntityName = 'CategoryManufacturer'
JOIN WCS_UrlRecordExtra AS C ON C.Id = A.Id
JOIN Manufacturer AS D ON D.Id = C.AdditionalEntityId;

UPDATE A
SET A.IsActive = 0
FROM UrlRecord AS A
JOIN WCS_UrlRecordExtra AS B ON B.Id = A.Id
JOIN #CorrectCategoryTitle AS C ON C.Id = B.AdditionalEntityId AND A.EntityName = 'ManufacturerCategory'
JOIN Manufacturer AS D ON D.Id = A.EntityId;

----INSERT UrlRecord\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

INSERT INTO UrlRecord
SELECT  B.Id AS EntityId
	  , 'Category' AS EntityName
	  , LOWER(REPLACE(CONCAT(B.Id,'-',B.CorrectTitle),' ','-')) AS Slug
	  , 1 AS IsActive
	  , 0 AS LanguageId
FROM UrlRecord AS A
JOIN #CorrectCategoryTitle AS B ON B.Id = A.EntityId
WHERE A.EntityName = 'Category';

INSERT INTO UrlRecord
SELECT  B.Id AS EntityId
	  , 'CategoryManufacturer' AS EntityName
	  , LOWER(REPLACE(CONCAT(D.Id,'-',D.Name,'-',B.CorrectTitle,'-',B.Id),' ','-')) AS Slug
	  , 1 AS IsActive
	  , 0 AS LanguageId
FROM UrlRecord AS A
JOIN #CorrectCategoryTitle AS B ON B.Id = A.EntityId AND A.EntityName = 'CategoryManufacturer'
JOIN WCS_UrlRecordExtra AS C ON C.Id = A.Id
JOIN Manufacturer AS D ON D.Id = C.AdditionalEntityId;

INSERT INTO UrlRecord
SELECT  D.Id AS EntityId
	  , 'ManufacturerCategory' AS EntityName
	  , LOWER(REPLACE(CONCAT(C.Id,'-',C.CorrectTitle,'-',D.Name,'-',D.Id),' ','-')) AS Slug
	  , 1 AS IsActive
	  , 0 AS LanguageId
FROM UrlRecord AS A
JOIN WCS_UrlRecordExtra AS B ON B.Id = A.Id
JOIN #CorrectCategoryTitle AS C ON C.Id = B.AdditionalEntityId AND A.EntityName = 'ManufacturerCategory'
JOIN Manufacturer AS D ON D.Id = A.EntityId;

----UPDATE WCS_UrlRecordRedirect\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


UPDATE A
SET  A.IsActive = 0
FROM WCS_UrlRecordRedirect AS A
JOIN #CorrectCategoryTitle AS B ON B.Id = A.NewEntityId
WHERE A.EntityName = 'Category';

UPDATE A
SET  A.IsActive = 0
FROM WCS_UrlRecordRedirect AS A 
JOIN #CorrectCategoryTitle AS B ON B.Id = A.NewEntityId  AND A.EntityName = 'CategoryManufacturer';

UPDATE A
SET A.IsActive = 0
FROM WCS_UrlRecordRedirect AS A
JOIN WCS_UrlRecordExtra AS B ON B.Id = A.Id
JOIN #CorrectCategoryTitle AS C ON C.Id = B.AdditionalEntityId AND A.EntityName =  'ManufacturerCategory' 
JOIN Manufacturer AS D ON D.Id = A.NewEntityId;

----INSERT WCS_UrlRecordRedirect\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

INSERT INTO WCS_UrlRecordRedirect
SELECT A.NewEntityId AS OldEntityId
	  ,B.Id AS NewEntityId
	  ,'Category' AS EntityName
	  ,A.NewSlug AS OldSlug
	  ,LOWER(REPLACE(CONCAT(B.Id,'-',B.CorrectTitle),' ','-')) AS NewSlug
	  ,NULL AS AdditionalEntityId
	  ,1 AS IsActive
FROM WCS_UrlRecordRedirect AS A
JOIN #CorrectCategoryTitle AS B ON B.Id = A.NewEntityId
WHERE A.EntityName = 'Category'
GROUP BY A.NewEntityId,B.Id,A.NewSlug,B.CorrectTitle

INSERT INTO WCS_UrlRecordRedirect
SELECT A.NewEntityId AS OldEntityId
	 , B.Id AS NewEntityId
	 , 'CategoryManufacturer' AS EntityName
	 , A.NewSlug AS OldSlug
	 , LOWER(REPLACE(CONCAT(B.Id,'-',B.CorrectTitle,'-',C.Name,'-',C.Id),' ','-')) AS NewSlug
	 , C.Id AS AdditionalEntityId
	 , 1 AS IsActive
FROM  WCS_UrlRecordRedirect AS A 
JOIN #CorrectCategoryTitle AS B ON B.Id = A.NewEntityId  AND A.EntityName = 'CategoryManufacturer'
JOIN Manufacturer AS C ON C.Id = A.AdditionalEntityId
GROUP BY A.NewEntityId,B.Id,A.NewSlug,C.Id,C.Name,B.CorrectTitle;

INSERT INTO WCS_UrlRecordRedirect
SELECT A.NewEntityId AS OldEntityId
	 , D.Id AS NewEntityId
	 , 'ManufacturerCategory' AS EntityName
	 , A.NewSlug AS OldSlug
	 ,LOWER(REPLACE(CONCAT(D.Id,'-',D.Name,'-',C.CorrectTitle,'-',C.Id),' ','-')) AS NewSlug
	 , C.Id AS AdditionalEntityId 
	 , 1 AS IsActive
FROM WCS_UrlRecordRedirect AS A
JOIN WCS_UrlRecordExtra AS B ON B.Id = A.Id
JOIN #CorrectCategoryTitle AS C ON C.Id = B.AdditionalEntityId AND A.EntityName =  'ManufacturerCategory' 
JOIN Manufacturer AS D ON D.Id = A.NewEntityId
GROUP BY A.NewEntityId,C.Id,A.NewSlug,D.Id,D.Name,C.CorrectTitle;

DROP TABLE #CorrectCategoryTitle;
