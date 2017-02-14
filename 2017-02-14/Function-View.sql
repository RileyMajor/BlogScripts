USE TempDB;

DROP TABLE IF EXISTS Orders;
DROP VIEW IF EXISTS OrdersWithProfit;
DROP FUNCTION IF EXISTS CalcOrderProfit;
DROP FUNCTION IF EXISTS GetOrdersWithProfit;
GO

CREATE TABLE Orders (OrderID INT IDENTITY PRIMARY KEY, OrderCharges numeric(19,2), OrderCosts numeric(19,2));
INSERT INTO Orders (OrderCharges, OrderCosts) VALUES (200, 100), (100, 50), (300, 200);
GO

CREATE VIEW OrdersWithProfit AS
SELECT OrderID, OrderCharges, OrderCosts, OrderCharges - OrderCosts AS OrderProfit FROM Orders;
GO

CREATE FUNCTION CalcOrderProfit (@Charges numeric(19,2), @Costs numeric(19,2))
RETURNS TABLE AS RETURN
SELECT @Charges - @Costs AS OrderProfit;
GO

CREATE FUNCTION GetOrdersWithProfit()
RETURNS TABLE AS RETURN 
SELECT o.OrderID, o.OrderCharges, o.OrderCosts, p.OrderProfit FROM Orders o
CROSS APPLY CalcOrderProfit(OrderCharges, OrderCosts) AS p;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT		*, OrderCharges - OrderCosts AS OrderProfit
FROM		Orders
WHERE		OrderCharges - OrderCosts = 100;

SELECT		*
FROM		OrdersWithProfit
WHERE		OrderProfit = 100;

SELECT		*
FROM		GetOrdersWithProfit()
WHERE		OrderProfit = 100;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

GO

DROP TABLE IF EXISTS Orders;
DROP VIEW IF EXISTS OrdersWithProfit;
DROP FUNCTION IF EXISTS CalcOrderProfit;
DROP FUNCTION IF EXISTS GetOrdersWithProfit;
GO