USE [Database];
GO



--All orders and their amount in the time interval from 00.00 to 19.06 hours and for the last day in the same period.

SELECT MAX(CAST(DATEADD(hour,-3,CreatedOnUtc) AS date)) AS CreatedOnUtcDate, COUNT(*) AS OrderQty, SUM(OrderTotal) AS SumOrderTotal
FROM [Order]
WHERE DATEADD(hour,3,CreatedOnUtc) BETWEEN '2023-07-19 00:00:00.000' AND '2023-07-19 19:06:00.000'
UNION
SELECT MAX(CAST(DATEADD(hour,-3,CreatedOnUtc) AS date)) AS CreatedOnUtcDate, COUNT(*) AS OrderQty, SUM(OrderTotal) AS SumOrderTotal
FROM [Order]
WHERE DATEADD(hour,3,CreatedOnUtc) BETWEEN '2023-07-18 00:00:00.000' AND '2023-07-18 19:06:00.000'

--The difference in the number of orders and the total price between these days.

SELECT A.CreatedOnUtcDate,A.OrderQty - B.OrderQty AS DifferenceOrderQtyToDay,A.SumOrderTotal - B.SumOrderTotal AS DifferenceSumOrderTotalToDay
FROM
(
SELECT 1 AS Id,MAX(CAST(CreatedOnUtc AS date)) AS CreatedOnUtcDate, COUNT(*) AS OrderQty, SUM(OrderTotal) AS SumOrderTotal
FROM [Order]
WHERE DATEADD(hour,3,CreatedOnUtc) BETWEEN '2023-07-19 00:00:00.000' AND '2023-07-19 19:06:00.000'
)AS A
JOIN 
(
SELECT 1 AS Id,MAX(CAST(CreatedOnUtc AS date)) AS CreatedOnUtcDate, COUNT(*) AS OrderQty, SUM(OrderTotal) AS SumOrderTotal
FROM [Order]
WHERE DATEADD(hour,3,CreatedOnUtc) BETWEEN '2023-07-18 00:00:00.000' AND '2023-07-18 19:06:00.000'
) AS B ON B.Id = A.Id




--All orders and their amount in the time interval from 00.00 to the present time and for the last day in the same interval.

SELECT MAX(CAST(DATEADD(hour,-3,CreatedOnUtc) AS date)) AS CreatedOnUtcDate, COUNT(*) AS OrderQty, SUM(OrderTotal) AS SumOrderTotal
FROM [Order]
WHERE DATEADD(hour,3,CreatedOnUtc) BETWEEN CAST(CAST(GETUTCDATE() AS date)AS datetime)  AND DATEADD(hour,3,GETUTCDATE())
UNION
SELECT MAX(CAST(CreatedOnUtc AS date)) AS CreatedOnUtcDate, COUNT(*) AS OrderQty, SUM(OrderTotal) AS SumOrderTotal
FROM [Order]
WHERE DATEADD(hour,3,CreatedOnUtc) BETWEEN DATEADD(hour,-24,(CAST(CAST(GETUTCDATE() AS date)AS datetime))) AND DATEADD(hour,-24,DATEADD(hour,3,GETUTCDATE()))

--The difference in the number of orders and the total price between these days.

SELECT A.CreatedOnUtcDate,A.OrderQty - B.OrderQty AS DifferenceOrderQtyToDay,A.SumOrderTotal - B.SumOrderTotal AS DifferenceSumOrderTotalToDay
FROM
(
SELECT 1 AS Id,MAX(CAST(DATEADD(hour,-3,CreatedOnUtc) AS date)) AS CreatedOnUtcDate, COUNT(*) AS OrderQty, SUM(OrderTotal) AS SumOrderTotal
FROM [Order]
WHERE DATEADD(hour,3,CreatedOnUtc) BETWEEN CAST(CAST(GETUTCDATE() AS date)AS datetime)  AND DATEADD(hour,3,GETUTCDATE())
)AS A
JOIN 
(
SELECT 1 AS Id,MAX(CAST(CreatedOnUtc AS date)) AS CreatedOnUtcDate, COUNT(*) AS OrderQty, SUM(OrderTotal) AS SumOrderTotal
FROM [Order]
WHERE DATEADD(hour,3,CreatedOnUtc) BETWEEN DATEADD(hour,-24,(CAST(CAST(GETUTCDATE() AS date)AS datetime))) AND DATEADD(hour,-24,DATEADD(hour,3,GETUTCDATE()))
) AS B ON B.Id = A.Id
