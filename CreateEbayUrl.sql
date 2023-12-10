USE [Database];
GO


--Creating a temporary table with products that have more than one image

	--//////////////////////////////////////////////////////

	SELECT A.ProductId
			,A.PictureId
			,'https://media.site.com/content/images/' + CAST(A.PictureId/10000 AS varchar(8)) +'/'+ CAST(FORMAT(A.PictureId,'d8') AS varchar(8)) + '_0.'+ 
			CASE WHEN MimeType = 'image/pjpeg' OR MimeType = 'image/jpeg'  THEN 'jpg'
				 WHEN MimeType = 'image/x-png'  THEN 'png'
				ELSE REPLACE(MimeType,'image/','') END AS [Url]	
	FROM
	(
		SELECT A.ProductId, A.PictureId, C.MimeType, ROW_NUMBER() OVER(PARTITION BY A.ProductId ORDER BY A.DisplayOrder) AS RowNum
		FROM Product_Picture_Mapping AS A
		JOIN Product AS B ON B.Id = A.ProductId
		JOIN Picture AS C ON C.Id = A.PictureId
		WHERE B.Published = 1 AND B.Deleted = 0
	) AS A
	JOIN [Database] AS B ON B.ProductId = A.ProductId
	WHERE A.RowNum > 1
	ORDER BY A.PictureId



