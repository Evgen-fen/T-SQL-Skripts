USE [DataBase];
GO

--Merging new products based on recommendations

	--Step 1 Clearing table

	--DELETE [vsql2\instance2].[DataBase].[dbo].Product_Recommendation;
	--DELETE Product_Recommendation ;

	--ALTER TABLE [vsql2\instance2].[DataBase].[dbo].Product_Recommendation 
	--DROP COLUMN Id;
	--ALTER TABLE [vsql2\instance2].[DataBase].[dbo].Product_Recommendation 
	--ADD [Id] [int] IDENTITY(1,1) NOT NULL

	--ALTER TABLE [vsql1\instance1].[DataBase].[dbo].Product_Recommendation 
	--DROP COLUMN Id;
	--ALTER TABLE [vsql1\instance1].[DataBase].[dbo].Product_Recommendation 
	--ADD [Id] [int] IDENTITY(1,1) NOT NULL

	--TRUNCATE TABLE [vsql1\instance1].[DataBase].[dbo].Product_Recommendation;
	--GO

	--Step 2 INSERT

	SELECT A.ParentProductId, A.ProductId, A.SortOrder
	INTO #ToProduct_Recommendation
	FROM 
	(
		SELECT A.ParentProductId, A.ProductId,ROW_NUMBER() OVER(PARTITION BY A.ParentProductId ORDER BY A.QtyOrders DESC) AS SortOrder
		FROM
		(
			SELECT A.ProductId AS ParentProductId,B.ProductId,  COUNT(*) AS QtyOrders
			FROM [vsql3\instance3].[CRM].[dbo].SalesOrderLines AS A
			JOIN [vsql3\instance3].[CRM].[dbo].SalesOrderLines AS B ON B.OrderId = A.OrderId
			JOIN Product AS C ON C.Id = A.ProductId AND C.Published = 1 AND C.Deleted = 0
			JOIN Product AS D ON D.Id = B.ProductId AND D.Published = 1 AND D.Deleted = 0
			JOIN Manufacturer AS E ON E.Id = A.ManufacturerId AND E.Published = 1 AND E.Deleted = 0
			JOIN Manufacturer AS F ON F.Id = B.ManufacturerId AND F.Published = 1 AND F.Deleted = 0
			JOIN WCS_ProductExtra AS G ON G.ProductId = C.Id
			JOIN WCS_ProductExtra AS H ON H.ProductId = D.Id
			WHERE A.ProductId <> B.ProductId 
			AND (C.StockQuantity > 0 OR G.IsShippingFromManufacturer = 1) AND (D.StockQuantity > 0 OR H.IsShippingFromManufacturer = 1)
			AND G.IsWarranty = 0
			AND H.IsWarranty = 0
			GROUP BY A.ProductId, B.ProductId
		) AS A
	) AS A
	WHERE A.SortOrder <= 5


	--Step 3 MERGE

	MERGE Product_Recommendation AS [Target]
	USING #ToProduct_Recommendation AS [Sourse]
	ON [Target].ParentProductId = [Sourse].ParentProductId
	AND [Target].ProductId = [Sourse].ProductId
	WHEN MATCHED THEN UPDATE 
	SET [Target].SortOrder = [Sourse].SortOrder

	WHEN NOT MATCHED BY TARGET THEN
		INSERT 
		(	 Id
			,ParentProductId
			,ProductId
			,SortOrder
		)
		VALUES
		(	 NULL
			,ParentProductId
			,ProductId
			,SortOrder	
		)
	WHEN NOT MATCHED BY SOURCE THEN DELETE;

	DROP TABLE #ToProduct_Recommendation;