
--Matching Vendor Brands from inventory.


--||||||||||||||||||||||||||||||||||||||||| Tire Depot Co.-DS 405 ||||||||||||||||||||||||||||||||||||||||||||||
	USE [DataBase]

	SELECT *
	INTO #Inventory_TireDepot_2 --DROP TABLE #Inventory_TireDepot_2
	FROM [vsql4\instance4].vendordata.[dbo].Inventory_TireDepot_2 AS A 
	LEFT JOIN [DataBase].[dbo].[PriceSheet] AS C ON C.Vendorid = 405 and C.VendorBrandName = A.Brand 
	WHERE C.ID IS NULL AND A.Brand <> ''
	UPDATE A
	SET Brand = '[DANGEROUS!]' + A.Brand
	FROM #InventoryAutomaticDistributing AS A
	JOIN Manufacturer AS B ON B.Name = A.Brand
	WHERE B.Id IN(978,14763,1426,11731,67,70,80,103,231,332,417,1004,4476,15534,1653,4245,1008,1781,1011,671,2567,714,1018,36,1419,59,1005,575,11038,1497,12681)



--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

	SELECT A.Brand
		,COUNT(*) AS QtyOfProducts
		,SUM(CASE WHEN A.Quantity > 0 THEN 1 ELSE 0 END) AS StockQty
	FROM #InventoryAutomaticDistributing AS A
	LEFT JOIN [vsql4\instance4].[DataBase].[dbo].[PriceSheet] AS B ON B.Vendorid = 405 and B.VendorBrandName = A.Brand
	WHERE B.id IS NULL  --AND A.Quantity > 0
	GROUP BY A.Brand
	ORDER BY QtyOfProducts DESC--Check Missing Brands



--Search Matching--|

	DECLARE @BrandName varchar(50) = (SELECT TOP 1 A.Brand
										FROM #InventoryAutomaticDistributing AS A
										LEFT JOIN [vsql4\instance4].[DataBase].[dbo].[PriceSheet] AS B ON B.Vendorid = 405 and B.VendorBrandName = A.Brand
										WHERE B.id IS NULL AND A.Brand NOT IN ('')
										GROUP BY A.Brand
										ORDER BY COUNT(*) DESC);
	SELECT TOP 100 B.ManufacturerId
				  ,B.ManufacturerName
				  ,B.QtyProductsMatched
				  ,A.Published
				  ,A.Deleted
				  ,B.StockQty
				  ,B.Brand
				  ,C.VendorBrandName
				  ,C.VendorManCode
				  ,C.ManID
				  ,C.ManName
				  ,C.Published
				  ,C.Deleted
	FROM Manufacturer AS A
	JOIN 
	(
		SELECT   C.ManufacturerId
				,B.Brand
				,COUNT(*) AS QtyProductsMatched
				,MAX(D.Name) AS ManufacturerName
				,SUM(CASE WHEN B.Quantity > 0 THEN 1 ELSE 0 END) AS StockQty
		FROM WC_Product AS A
		JOIN #InventoryAutomaticDistributing AS B ON dbo.RemoveNonAlphaCharacters(B.PartNumber) = A.ManufacturerPartNumberClean --AND B.UPC = A.UPC
		JOIN Product_Manufacturer_Mapping AS C ON C.ProductId = A.ProductId
		JOIN Manufacturer AS D ON D.Id = C.ManufacturerId
		JOIN Product AS E ON E.Id = C.ProductId
		WHERE E.Deleted = 0 AND B.Brand = @BrandName 
		GROUP BY C.ManufacturerId,B.Brand
	) AS B ON B.ManufacturerId = A.Id
	LEFT JOIN (SELECT A.VendorBrandName
					 ,B.Name AS ManName
					 ,A.VendorManCode
					 ,A.ManID
					 ,B.Published
					 ,B.Deleted 
				FROM [vsql4\instance4].[DataBase].[dbo].[PriceSheet] AS A
				JOIN Manufacturer AS B ON B.Id = A.ManID
	) AS C ON C.VendorBrandName LIKE '%'+LEFT(B.Brand,4)+'%'
	ORDER BY B.QtyProductsMatched DESC
	SELECT *
	FROM #InventoryAutomaticDistributing AS A
	LEFT JOIN (SELECT A.VendorBrandName
					 ,B.Name AS ManName
					 ,A.VendorManCode
					 ,A.ManID
					 ,B.Published
					 ,B.Deleted 
				FROM [vsql4\instance4].[DataBase].[dbo].[PriceSheet] AS A
				JOIN Manufacturer AS B ON B.Id = A.ManID
	) AS C ON C.VendorBrandName LIKE '%'+LEFT(A.Brand,4)+'%'
	WHERE A.Brand = @BrandName		
	SELECT Brand,COUNT(*) AS QtyProducts
	,SUM(CASE WHEN Quantity > 0 THEN 1 ELSE 0 END) AS StockQty
	FROM #InventoryAutomaticDistributing
	WHERE Brand = @BrandName										
	GROUP BY Brand
	SELECT  *
	FROM Manufacturer
	WHERE Name Like '%'+ REPLACE(@BrandName,' ','%')+'%'
	SELECT *
	FROM Manufacturer
	WHERE Name LIKE '%'+@BrandName+'%'
	SELECT *
	FROM Manufacturer
	WHERE Name LIKE '%'+@BrandName + '%'
	SELECT *
	FROM Manufacturer
	WHERE Name LIKE '%'+REPLACE(@BrandName,' ','%')+'%'
	SELECT *
	FROM Manufacturer
	WHERE Name LIKE @BrandName
	SELECT *
	FROM Manufacturer
	WHERE Name LIKE '%'+LTRIM(RTRIM(SUBSTRING(@BrandName,1,CHARINDEX(' ',@BrandName))))+'%'
	SELECT *
	FROM Manufacturer
	WHERE Name LIKE '%'+SUBSTRING(@BrandName,1,LEN(@BrandName)/2)+'%'
--Create Manufacturer \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\Disco Automotive Hardware
							USE [DataBase]
							DECLARE @ManufacturerName AS varchar(100) = 'BeadBuster'
							DECLARE @ManufacturerId AS int
							EXEC [vsql1\instance1].[DataBase].[dbo].WC_CreateBrand 
							@ManufacturerName, @manId=@ManufacturerId OUTPUT;
--Matching \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	DECLARE @VendorManCode nvarchar(4) = NULL;
	DECLARE @VendorBrandName nvarchar(40) = 'BEADBUSTER';
	DECLARE @MAnID int = @ManufacturerId;
	DECLARE @venName nvarchar(40) = 'Automatic Distributing';
	DECLARE @VenId int = 405;
	DECLARE @Action varchar(40) = CASE WHEN @MAnID >= 17345  THEN 'Created brand' ELSE 'Matched brand' END 
	DECLARE @Notes varchar(20) = CASE WHEN @MAnID >= 17345  THEN 'Created' ELSE 'Matched' END 
	INSERT INTO [vsql4\instance4].[DataBase].[dbo].[PriceSheet] (VendorName, VendorManCode, VendorBrandName, VendorId, ManId, DisableMatch, CreatedOn) 
	SELECT A.vendorname, A.VendorManCode, A.VendorBrandName, A.VendoriD, A.MAnID, 0, GETDATE()
	FROM (SELECT @venName AS vendorname, @VendorManCode as VendorManCode, @VendorBrandName AS VendorBrandName, @VenId AS VendoriD, @MAnID AS MAnID) AS A
	LEFT JOIN [vsql4\instance4].[DataBase].[dbo].[PriceSheet] AS B ON B.VendorID = A.VendoriD AND B.VendorBrandName = A.VendorBrandName AND B.VendorManCode = A.VendorManCode
	WHERE B.ID is null
	SELECT TOP 1 VendorID	--REVIEW
		 , VendorName																												  AS [Vendor Name]
		 , VendorBrandName																											  AS [Vendor Brand Name]
		 , 'NULL'																													  AS [Vendor Brand Code]
		 , (SELECT COUNT(*) FROM #InventoryAutomaticDistributing WHERE Brand = @VendorBrandName)									  AS [QTY OF PRODUCTS]
		 , (SELECT SUM(CASE WHEN Quantity > 0 THEN 1 ELSE 0 END) FROM #InventoryAutomaticDistributing WHERE Brand = @VendorBrandName) AS [QTY OF PRODUCT IN STOCK]							    
		 , @Action																													  AS [Action]
		 , GETDATE()																												  AS [Date]
		 , @MAnID																													  AS [AP MANID]
		 , @Notes																													  AS Notes
		 ,ID																													      AS [PriceSheet ID]
	FROM [vsql4\instance4].[DataBase].[dbo].[PriceSheet] 
	WHERE Vendorid = @VenId AND ManID = @MAnID 
	ORDER BY ID DESC

-------------------------------------------------------------------------------------------------------------------------------------|
	SELECT  @VenId AS VendorId, @venName AS VendorName, @ManufacturerName AS ManName, @ManufacturerId AS ManId, GETDATE() AS CreatedOn           --Manufacturer
-------------------------------------------------------------------------------------------------------------------------------------|

