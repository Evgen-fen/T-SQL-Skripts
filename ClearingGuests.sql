--USE database;
--GO

--Clearing guests who did not make purchases.

SELECT  A.Id
INTO #DeleteGuests
FROM Customer AS A
JOIN Customer_CustomerRole_Mapping AS B ON B.Customer_Id = A.Id
JOIN CustomerRole AS C ON C.Id = B.CustomerRole_Id AND C.Id = 4
LEFT JOIN [Order] AS D ON D.CustomerId = A.Id AND D.Id IS NULL
LEFT JOIN ShoppingCartItem E ON E.CustomerId = A.Id AND E.Id IS NULL
LEFT JOIN BlogComment AS G ON G.CustomerId = A.Id AND G.Id IS NULL
LEFT JOIN NewsComment AS H ON H.CustomerId = A.Id AND H.Id IS NULL
LEFT JOIN ProductReview AS I ON I.CustomerId = A.Id AND I.Id IS NULL
LEFT JOIN PollVotingRecord AS J ON J.CustomerId = A.Id AND J.Id IS NULL
LEFT JOIN Forums_Topic AS K ON K.CustomerId = A.Id AND K.Id IS NULL
LEFT JOIN Forums_Subscription AS L ON L.CustomerId = A.Id AND L.Id IS NULL
LEFT JOIN BackInStockSubscription AS M ON M.CustomerId = A.Id AND M.Id IS NULL
LEFT JOIN CustomerAddresses AS N ON N.Customer_Id = A.Id AND N.Customer_Id IS NULL
WHERE A.IsSystemAccount = 0 AND  A.CreatedOnUtc <= DATEADD(day,-1,GETUTCDATE()) 
GROUP BY A.Id;

DELETE Customer
FROM #DeleteGuests AS A
WHERE Customer.Id = A.Id;

DELETE B
FROM #DeleteGuests AS A
JOIN GenericAttribute AS B ON B.EntityId = A.Id AND B.KeyGroup = 'Customer'
WHERE B.EntityId = A.Id;

DELETE ActivityLog
FROM #DeleteGuests AS A
WHERE ActivityLog.CustomerId = A.Id

DROP TABLE #DeleteGuests;

