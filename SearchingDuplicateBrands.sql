USE Autoplicity_Site
/* Note//

Searching duplicate brands

*/--Note//

--Search Area-----------------------------------------------------------------------------
DECLARE @ManId_1 int = 450
DECLARE @ManId_2 int = 4614
--Search Area-----------------------------------------------------------------------------

--Step 1
SELECT B.Id,B.Name,C.Name,C.ManufacturerPartNumber,C.CreatedOnUtc
FROM Product_Manufacturer_Mapping AS A
JOIN Manufacturer AS B ON B.Id = A.ManufacturerId
JOIN Product AS C ON C.Id = A.ProductId
WHERE B.Id IN (@ManId_1,@ManId_2)
ORDER BY B.Name DESC
--Step 2
SELECT A.ManufacturerPartNumber AS ManId_1,A.Name AS ManId_1Name ,B.ManufacturerPartNumber AS ManId_2,B.Name AS ManId_2Name
FROM
(SELECT B.Id,B.Name,C.ManufacturerPartNumber
FROM Product_Manufacturer_Mapping AS A
JOIN Manufacturer AS B ON B.Id = A.ManufacturerId
JOIN Product AS C ON C.Id = A.ProductId
WHERE B.Id IN(@ManId_1)
) AS A
JOIN
(SELECT B.Id,B.Name,C.ManufacturerPartNumber
FROM Product_Manufacturer_Mapping AS A
JOIN Manufacturer AS B ON B.Id = A.ManufacturerId
JOIN Product AS C ON C.Id = A.ProductId
WHERE B.Id IN(@ManId_2)
) AS B ON B.ManufacturerPartNumber = A.ManufacturerPartNumber
GROUP BY A.ManufacturerPartNumber,A.Name,B.ManufacturerPartNumber,B.Name
--Step 3
SELECT B.Id,B.Name,COUNT(*) AS QtyProducts,B.Published,B.Deleted
FROM
(SELECT B.Id,B.Name,C.ManufacturerPartNumber,B.Published,B.Deleted
FROM Product_Manufacturer_Mapping AS A
JOIN Manufacturer AS B ON B.Id = A.ManufacturerId
JOIN Product AS C ON C.Id = A.ProductId
WHERE B.Id IN(@ManId_1,@ManId_2)
) AS A
JOIN
(SELECT B.Id,B.Name,C.ManufacturerPartNumber,B.Published,B.Deleted
FROM Product_Manufacturer_Mapping AS A
JOIN Manufacturer AS B ON B.Id = A.ManufacturerId
JOIN Product AS C ON C.Id = A.ProductId
) AS B ON B.ManufacturerPartNumber = A.ManufacturerPartNumber
GROUP BY B.Id,B.Name,B.Published,B.Deleted
ORDER BY QtyProducts DESC
--Step 4
SELECT *
FROM [vsql4\instance4].[Autoplicity].[dbo].[PriceSheet]
WHERE ManId IN (@ManId_1,@ManId_2)
--Step 5
SELECT B.Id,B.Name,COUNT(*) AS QtyProducts,B.Published,B.Deleted,B.CreatedOnUtc
FROM Product_Manufacturer_Mapping AS A
JOIN Manufacturer AS B ON B.Id = A.ManufacturerId
JOIN Product AS C ON C.Id = A.ProductId
WHERE B.Id IN (@ManId_1,@ManId_2)
GROUP BY B.Id,B.Name,B.Published,B.Deleted,B.CreatedOnUtc
ORDER BY B.Name DESC

