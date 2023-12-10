
USE [Database];
GO

--Update Dimensions From FedEx

CREATE PROCEDURE WC_UpdateDimensionsFromFedExInvoices
	AS
		BEGIN

	SELECT *
	INTO #ShipHistory
	FROM OPENQUERY ([vsql3\instance3],'
			 SELECT A.ProductID
				,AvgInvoiceActual_Weight = CAST(AVG(TRY_CAST(B.[Actual Weight Amount] AS decimal(10,2))) AS decimal(10,2))
				,AvgInvoice_Width  = CAST(AVG(TRY_CAST(B.[Dim Width] AS decimal(10,2))) AS decimal(10,2))
				,AvgInvoice_Length = CAST(AVG(TRY_CAST(B.[Dim Length] AS decimal(10,2))) AS decimal(10,2))
				,AvgInvoice_Height = CAST(AVG(TRY_CAST(B.[Dim Height] AS decimal(10,2))) AS decimal(10,2))
		FROM [CrmApTools].[dbo].[Database] AS A
		JOIN [PowerBI].[dbo].[View_CarrierInvoices_FedEx] B ON B.[Tracking Number] = A.TrackingNumber 
		JOIN 
			(
				SELECT TrackingNumber
				FROM [CrmApTools].[dbo].[Database]
				GROUP BY TrackingNumber
				HAVING COUNT(DISTINCT ProductID) = 1
			)AS C ON C.TrackingNumber = A.TrackingNumber
		WHERE   ISNULL(B.[Actual Weight Amount],'''') <> ''''
			AND ISNULL(B.[Dim Width ],'''') <> ''''
			AND ISNULL(B.[Dim Length],'''') <> ''''
			AND ISNULL(B.[Dim Height],'''') <> ''''
		GROUP BY  A.ProductID
		HAVING COUNT(DISTINCT A.TrackingNumber) > 1
	');

	SELECT    A.ProductId
			, A.AvgInvoiceActual_Weight
			, A.AvgInvoice_Width
			, A.AvgInvoice_Length
			, A.AvgInvoice_Height
	INTO #Dimensions--DROP TABLE #Dimensions
	FROM #ShipHistory AS A
	JOIN Product AS B ON B.Id = A.ProductID;
	--ORDER BY A.ProductID ASC



	WHILE 1 = 1 
	BEGIN 
		UPDATE TOP (5000) A
	SET A.Weight = B.AvgInvoiceActual_Weight,
		A.Height = B.AvgInvoice_Height,
		A.Length = B.AvgInvoice_Length,
		A.Width  = B.AvgInvoice_Width
	FROM Product AS A
	JOIN #Dimensions AS B ON B.ProductID = A.Id
	WHERE  A.Weight <> B.AvgInvoiceActual_Weight 
		OR A.Height <> B.AvgInvoice_Height 
		OR A.Length <> B.AvgInvoice_Length 
		OR A.Width  <> B.AvgInvoice_Width;
	IF @@ROWCOUNT = 0
					break
				WAITFOR DELAY '00:00:15'
	END

	WHILE 1 = 1 
	BEGIN 
		UPDATE TOP (5000) A
	SET A.DimmensionDataSourceID = 20,
		A.WeightDataSourceID = 20,
		A.DimmensionUpdatedOn = GETUTCDATE(),
		A.WeightUpdatedOn = GETUTCDATE()
	FROM WC_Product AS A
	JOIN #Dimensions AS B ON B.ProductID = A.ProductId
	WHERE A.DimmensionDataSourceID <> 20 AND A.WeightDataSourceID <> 20;
	IF @@ROWCOUNT = 0
					break
				WAITFOR DELAY '00:00:15'
	END

	DROP TABLE #ShipHistory;
	DROP TABLE #Dimensions;

END