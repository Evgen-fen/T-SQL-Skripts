USE  [Database];-- CHECK INSTANSE [vsql1\instance1]
GO	
--Rename Brands


	DECLARE @CorrectName varchar(40) = ''
	DECLARE @IncorrectName varchar(40) = ''
	DECLARE @ManID int = 


	UPDATE A
	SET A.Name =			REPLACE(A.Name, @IncorrectName, @CorrectName)
	   ,A.MetaKeywords =	REPLACE(A.MetaKeywords, @IncorrectName, @CorrectName)
	   ,A.MetaDescription = REPLACE(A.MetaDescription, @IncorrectName, @CorrectName)
	   ,A.MetaTitle =		REPLACE(A.MetaTitle, @IncorrectName, @CorrectName)
	--SELECT *
	FROM  Manufacturer AS A 
	WHERE A.id = @ManID

WHILE 1 = 1
BEGIN
    UPDATE TOP (50000) A
	SET A.Name =			REPLACE(A.Name, @IncorrectName, @CorrectName)
	   ,A.FullDescription =	REPLACE(A.Name, @IncorrectName, @CorrectName)
	   ,A.MetaKeywords =	REPLACE(A.MetaKeywords, @IncorrectName ,@CorrectName)
	   ,A.MetaDescription = REPLACE(A.MetaDescription, @IncorrectName, @CorrectName)
	   ,A.MetaTitle =		REPLACE(A.MetaTitle, @IncorrectName, @CorrectName)
	   ,A.UpdatedOnUtc =	GETUTCDATE()
	--SELECT *
	FROM Product AS A
	JOIN Product_Manufacturer_Mapping AS B ON B.ProductId = A.Id
	JOIN Manufacturer AS C ON C.Id = B.ManufacturerId
	WHERE C.Id = @ManID
	    IF @@ROWCOUNT = 0
        BREAK
	WAITFOR DELAY '00:00:30';
END


	UPDATE A
	SET A.Slug = dbo.RemoveNonUrlCharacters(CAST(E.Id AS nvarchar(9)) + ' ' + LTRIM(RTRIM(E.Name)))
	--SELECT *
	FROM UrlRecord AS A
	JOIN Product_Manufacturer_Mapping AS B ON B.ProductId= A.EntityId
	JOIN Product AS C ON C.id = b.ProductId
	JOIN Manufacturer AS E ON E.id = A.EntityId
	WHERE A.EntityName = 'Manufacturer' AND A.EntityId= @ManID

	UPDATE A
	SET A.Slug = dbo.RemoveNonUrlCharacters(CAST(C.Id AS nvarchar(9)) + ' ' + LTRIM(RTRIM(C.Name)))
	--SELECT *
	FROM UrlRecord AS A
	JOIN Product_Manufacturer_Mapping AS B On B.ProductId= A.EntityId
	JOIN Product AS C ON C.Id = B.ProductId
	JOIN Manufacturer AS E ON E.Id = B.ManufacturerId
	WHERE A.EntityName = 'Product' AND E.Id= @ManID;
