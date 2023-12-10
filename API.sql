USE Creating a stored procedure for adding new products from the scraper, taking into account the existing asyns or their absence.;
GO

--Creating a stored procedure for adding new products from the scraper, taking into account the existing asyns or their absence.

--///////////////////////////////////////////////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[SearchQueueAPI]
(
	[ProductId] [int] NOT NULL,
	[SearchMethod] [varchar](64) NOT NULL,
	[SearchValue] [varchar](512) NOT NULL,
	[SearchRank] [int] NOT NULL,
	[ProcessedOn] [datetime] NULL
 CONSTRAINT [PK_SearchQueueAPI] PRIMARY KEY CLUSTERED 
	(
		[ProductId] ASC
	) ON [PRIMARY]
);
GO

SELECT TOP 1000 *
INTO #SearchQueue
FROM SearchQueue


SELECT TOP 1000 *
INTO #SearchQueueAPI
FROM SearchQueueAPI

DROP TABLE #SearchQueueAPI

--///////////////////////////////////////////////////////////////////////////////////////////////////////////

ALTER PROCEDURE [dbo].[GetSearchQueueAPIItems]
AS
BEGIN 
	BEGIN TRANSACTION;

	INSERT INTO SearchQueueAPI (ProductId, SearchValue, SearchRank ,ProcessedOn)
	SELECT TOP 1000 ProductId, SearchValue, SearchRank ,NULL
	FROM SearchQueue
	WHERE SearchMethod = 'Term'
	ORDER BY SearchRank DESC;
	
	DELETE SearchQueue
	FROM SearchQueue AS A
	JOIN SearchQueueAPI AS B ON B.ProductId = A.ProductId
	WHERE A.SearchMethod = 'Term';

	SELECT ProductId, SearchValue, SearchRank, ProcessedOn
	FROM SearchQueueAPI
	WHERE ProcessedOn IS NULL;

COMMIT TRANSACTION; 
END
GO;


--///////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @SearchResult TABLE ;
EXEC [dbo].[SaveSearchResultAPI] @SearchResult ;


CREATE PROCEDURE [dbo].[SearchResultAPI]
(
	@SearchResult SearchResult READONLY
)
AS
BEGIN 
	BEGIN TRY
	BEGIN TRANSACTION;

	MERGE SearchTermsWithoutResults AS T
	USING 
	(
		SELECT ProductId, SearchValue, 'Automotive' AS SearchIn, SearchMethod, GETUTCDATE() AS CreatedOn
		FROM @SearchResult 
		WHERE [Asin] IS NULL AND NumberOfResults = 0
		GROUP BY ProductId, SearchValue, SearchMethod
	)  AS S
	ON T.ProductId = S.ProductId
	WHEN NOT MATCHED THEN
		INSERT (ProductId, Term, SearchIn, SearchBy, CreatedOn, HandledOn, NumberOfResults, SearchRank)
		VALUES (S.ProductId, S.SearchValue, S.SearchIn, S.SearchMethod, S.CreatedOn, NULL, 0, 0)
	WHEN MATCHED THEN
		UPDATE SET
		T.CreatedOn = GETUTCDATE();

	MERGE SearchResult AS T
	USING 
	(
		SELECT ProductId, [Asin], SearchMethod, SearchValue, NumberOfResults, SearchRank, UpdatedOn
		FROM 
		(
			SELECT ProductId, [Asin], SearchMethod, SearchValue, NumberOfResults, SearchRank, GETUTCDATE() AS UpdatedOn, ROW_NUMBER() OVER(PARTITION BY ProductId, [Asin], SearchMethod ORDER BY SearchRank DESC) AS RowNumber
			FROM @SearchResult
			WHERE [Asin] IS NOT NULL
		) AS A
		WHERE A.RowNumber = 1
	)  AS S
	ON T.[Asin] = S.[Asin] AND T.SearchMethod = S.SearchMethod AND T.ProductId = S.ProductId 
	WHEN NOT MATCHED THEN
		INSERT (ProductId, [Asin], SearchMethod, SearchValue, NumberOfResults, SearchRank, UpdatedOn)
		VALUES (S.ProductId, S.[Asin], S.SearchMethod, S.SearchValue, S.NumberOfResults, S.SearchRank, S.UpdatedOn)
	WHEN MATCHED THEN
		UPDATE SET
		T.UpdatedOn = GETUTCDATE(),
		T.NumberOfResults = S.NumberOfResults,
		T.SearchRank = S.SearchRank;

	DELETE A
	FROM SearchTermsWithoutResults AS A
	JOIN @SearchResult AS B ON B.ProductId = A.ProductId
	WHERE B.[Asin] IS NOT NULL;

	INSERT AsinQueue([Asin], CreatedOn, SearchRank, SearchType)
	SELECT C.[Asin], C.CreatedOn, C.SearchRank, 3
	FROM
	(
		SELECT A.[Asin], GETUTCDATE() AS CreatedOn, A.SearchRank, ROW_NUMBER() OVER(PARTITION BY A.[Asin] ORDER BY A.SearchRank DESC) AS RowNumber
		FROM @SearchResult AS A
		LEFT JOIN AsinQueue AS B ON B.[Asin] = A.[Asin] AND B.SearchType = 3
		WHERE A.[Asin] IS NOT NULL AND B.[Asin] IS NULL
	) AS C
	WHERE C.RowNumber = 1; 

	INSERT AsinQueue([Asin], CreatedOn, SearchRank, SearchType, Url)
	SELECT C.[Asin], C.CreatedOn, C.SearchRank, C.SearchType, C.Url
	FROM
	(
		SELECT A.[Asin], A.SearchRank, GETUTCDATE() AS CreatedOn, 5 AS SearchType, A.Url, ROW_NUMBER() OVER(PARTITION BY A.[Asin] ORDER BY A.SearchRank DESC) AS RowNumber
		FROM @SearchResult AS A
		LEFT JOIN AsinQueue AS B ON B.[Asin] = A.[Asin] AND B.SearchType = 5 AND A.Url IS NOT NULL
		WHERE A.[Asin] IS NOT NULL AND B.[Asin] IS NULL
	) AS C
	WHERE C.RowNumber = 1; 

	UPDATE SearchQueueAPI 
	SET ProcessedOn = GETUTCDATE()
	WHERE ProcessedOn IS NULL;

		COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;

	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY(); 
	DECLARE @ErrorState INT = ERROR_STATE();

	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
END

GO
