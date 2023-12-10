
USE [Database];
GO

--Correcting incorrect or unnecessary templates

DECLARE @SectionAttributeId int = 15336; --Section
DECLARE @AspectRatioAttributeId int = 14528; --Aspect Ratio
DECLARE @RimSizeAttributeId int = 9197;--Rim Size
DECLARE @TiresCategoryId int = 7636;--Tires
DECLARE @OverallDiameterId int = 7735; --Overall Diameter

--Create View #SpecificationProducts

SELECT
	 A.Id AS SpecificationAttributeId
	,A.Name AS SpecificationAttributeName
	,B.Id AS SpecificationAttributeOptionId
	,B.Name AS SpecificationAttributeOptionName
	,C.ProductId
INTO #SpecificationProducts
FROM SpecificationAttribute AS A
JOIN SpecificationAttributeOption AS B ON B.SpecificationAttributeId = A.Id
JOIN Product_SpecificationAttribute_Mapping AS C ON C.SpecificationAttributeOptionId = B.Id
JOIN Product_Category_Mapping AS D ON D.ProductId = C.ProductId
JOIN Category AS E ON E.Id = D.CategoryId
WHERE E.Id = @TiresCategoryId AND A.Id IN(@SectionAttributeId,@AspectRatioAttributeId,@RimSizeAttributeId)
ORDER BY SpecificationAttributeOptionName;

--Create View ##SpecificationOverallDiameterProducts

SELECT
	 A.Id AS SpecificationAttributeId
	,A.Name AS SpecificationAttributeName
	,C.ProductId
	,B.Name AS SpecificationAttributeOptionName
	,B.Id AS SpecificationAttributeOptionId
INTO #SpecificationOverallDiameterProducts
FROM SpecificationAttribute AS A
JOIN SpecificationAttributeOption AS B ON B.SpecificationAttributeId = A.Id
JOIN Product_SpecificationAttribute_Mapping AS C ON C.SpecificationAttributeOptionId = B.Id
JOIN Product AS D ON D.Id = C.ProductId
JOIN Product_Category_Mapping AS E ON E.ProductId = C.ProductId
JOIN Category AS F ON F.Id = E.CategoryId
WHERE D.Published = 1
	AND D.Deleted = 0
	AND TRY_CAST(B.Name AS decimal) IS NOT NULL
	AND A.Id IN( @SectionAttributeId ,@OverallDiameterId)
	AND F.Id = @TiresCategoryId

--Update table with values without "mm"

	UPDATE #SpecificationProducts
	SET SpecificationAttributeOptionName = REPLACE(SpecificationAttributeOptionName,'mm','');

--Update table with values without "00"

	UPDATE #SpecificationProducts
	SET SpecificationAttributeOptionName = CONVERT(nvarchar(max), CONVERT(float,SpecificationAttributeOptionName))
	WHERE TRY_CAST(SpecificationAttributeOptionName AS decimal) IS NOT NULL;

--Update table with values "8.002" , "16.002"

	UPDATE #SpecificationProducts
	SET  SpecificationAttributeOptionName = CAST(SpecificationAttributeOptionName AS decimal)
	WHERE TRY_CAST(SpecificationAttributeOptionName AS decimal) IS NOT NULL AND SpecificationAttributeOptionName LIKE '%.00%';

--Update values Overall Diameter = '.00'

	UPDATE #SpecificationOverallDiameterProducts
	SET SpecificationAttributeOptionName = CONVERT(nvarchar(max),CONVERT(float,SpecificationAttributeOptionName))

--Update values "25545" --Overall Diameter
	UPDATE #SpecificationOverallDiameterProducts
	SET SpecificationAttributeOptionName = LEFT(SpecificationAttributeOptionName,3)
	WHERE LEN(REPLACE(SpecificationAttributeOptionName,'.','')) > 4 
	AND SpecificationAttributeOptionName NOT LIKE '%.%' 
	AND SpecificationAttributeOptionName NOT LIKE '%[A-z]%'

--Update SpecificationAttributeOption

	UPDATE A
	SET A.Name = B.SpecificationAttributeOptionName
	--SELECT A.Name,B.SpecificationAttributeOptionName
	FROM SpecificationAttributeOption AS A
	JOIN #SpecificationOverallDiameterProducts AS B ON B.SpecificationAttributeOptionId = A.Id

--Check for duplicates

	WITH CTE
	AS
	(
		SELECT
			 SpecificationAttributeId
			,SpecificationAttributeOptionId
			,SpecificationAttributeOptionName
			,ROW_NUMBER() OVER(PARTITION BY SpecificationAttributeId,SpecificationAttributeOptionName ORDER BY SpecificationAttributeOptionId) AS RowNum
		FROM #SpecificationProducts
		GROUP BY SpecificationAttributeId,SpecificationAttributeOptionId,SpecificationAttributeOptionName
	)
	SELECT
		 A.SpecificationAttributeOptionId AS SpecificationAttributeOptionIdOld
		,B.SpecificationAttributeOptionId AS SpecificationAttributeOptionIdNew
		,A.RowNum AS RowNumOld
		,B.RowNum AS RowNumNew
	INTO #RowNumSpecification
	FROM CTE AS A
	JOIN CTE AS B ON B.SpecificationAttributeId = A.SpecificationAttributeId
		AND B.SpecificationAttributeOptionName = A.SpecificationAttributeOptionName
		AND B.RowNum > 1
	WHERE A.RowNum = 1

--Removing duplicates

	UPDATE A
	SET A.SpecificationAttributeOptionId = B.SpecificationAttributeOptionIdNew
	--SELECT A.SpecificationAttributeOptionIdNew,B.SpecificationAttributeOptionId
	FROM Product_SpecificationAttribute_Mapping AS A
	JOIN #RowNumSpecification AS B ON B.SpecificationAttributeOptionIdOld = A.SpecificationAttributeOptionId
	--GROUP BY A.SpecificationAttributeOptionId,B.SpecificationAttributeOptionIdNew

	DELETE A
	--SELECT A.Id AS SpecificationAttributeOptionId
	FROM SpecificationAttributeOption  AS A
	JOIN #RowNumSpecification AS B ON B.SpecificationAttributeOptionIdNew = A.Id
	WHERE B.RowNumNew > 1

DROP TABLE #SpecificationProducts;
DROP TABLE #SpecificationOverallDiameterProducts;
DROP TABLE #RowNumSpecification;

