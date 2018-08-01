SET STATISTICS IO OFF;

USE tempdb;

DROP TABLE IF EXISTS #Orders;
GO

CREATE TABLE #Orders
(
	OrderID			int IDENTITY,
	OrderStatusID	int NOT NULL,
	OrderDate		datetime
);
GO

CREATE CLUSTERED INDEX IDX_Orders_OrderStatusID ON #Orders(OrderStatusID);
GO

INSERT INTO #Orders
(
	OrderStatusID, OrderDate
)
SELECT
	OrderStatusID, OrderDate
FROM		(
				SELECT
					OrderStatusID	= (RAND()*9) + 1,
					OrderDate		= DATEADD(DAY,RAND()*-50,GETDATE())
			) AS t;
GO 10000

DROP FUNCTION IF EXISTS GetSpecialOrderStatusIDs;
GO

CREATE FUNCTION GetSpecialOrderStatusIDs()
RETURNS TABLE AS
RETURN
	SELECT
		s.OrderStatusID
	FROM		(
					SELECT		3
					UNION ALL
					SELECT		8
				) AS s(OrderStatusID);
GO

DROP FUNCTION IF EXISTS IsOrderStatusSpecialScalar;
GO

CREATE FUNCTION IsOrderStatusSpecialScalar
(
	@OrderStatusID int
)
RETURNS bit AS
BEGIN
RETURN
(
	CASE
		WHEN @OrderStatusID IN (3,8) THEN
			1
		ELSE
			0
	END
);
END
GO

DROP FUNCTION IF EXISTS IsOrderStatusSpecial;
GO

CREATE FUNCTION IsOrderStatusSpecial
(
	@OrderStatusID int
)
RETURNS TABLE AS
RETURN
	SELECT
		OrderStatusIsSpecial =
			CASE
				WHEN @OrderStatusID IN (3,8) THEN
					1
				ELSE
					0
			END;
GO

DROP FUNCTION IF EXISTS IsOrderStatusSpecialLimiter;
GO

CREATE FUNCTION IsOrderStatusSpecialLimiter
(
	@OrderStatusID int
)
RETURNS TABLE AS
RETURN
	SELECT
		OrderIsSpecial = CONVERT(bit,1)
	WHERE	@OrderStatusID IN (3,8);
GO

SET STATISTICS IO ON;

PRINT 'Raw:';

SELECT		o.*
FROM		#Orders o
WHERE		o.OrderStatusID IN (3,8);

PRINT 'Raw with odd syntax:';

SELECT		o.*
FROM		#Orders o
WHERE		1 = 
				CASE
					WHEN o.OrderStatusID IN (3,8) THEN
						1
					ELSE
						0
				END;

PRINT 'Scalar Function';

SELECT		o.*
FROM		#Orders o
WHERE		dbo.IsOrderStatusSpecialScalar(o.OrderStatusID) = 1;

PRINT 'EXISTS Inline Function';

SELECT		o.*
FROM		#Orders o
WHERE		EXISTS
			(
				SELECT		*
				FROM		GetSpecialOrderStatusIDs() s
				WHERE		s.OrderStatusID = o.OrderStatusID
			);

PRINT 'CROSS APPLY Inline Function with Interior Calc';

SELECT		o.*
FROM		#Orders o
CROSS APPLY	IsOrderStatusSpecial
			(
				o.OrderStatusID
			) s
WHERE		s.OrderStatusIsSpecial = 1;

PRINT 'CROSS APPLY Inline Function with Limiting WHERE';

SELECT		o.*
FROM		#Orders o
CROSS APPLY	IsOrderStatusSpecialLimiter
			(
				o.OrderStatusID
			) s;