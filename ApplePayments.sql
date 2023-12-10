USE [Database];
GO

--Withdrawal of payment for orders for the last 7 days using the ApplePay payment system.

SELECT CAST(CreatedOnUtc AS date) AS Orderslast_7_days, COUNT(*) AS QtyOrders
FROM [Order]
WHERE PaymentMethodSystemName = 'Payments.ApplePay' 
AND CreatedOnUtc >= GETUTCDATE() - 7
GROUP BY CAST(CreatedOnUtc AS date)
ORDER BY CAST(CreatedOnUtc AS date) DESC