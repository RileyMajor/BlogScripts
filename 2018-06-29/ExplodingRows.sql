DECLARE @Contact table
	(
		ContactName varchar(50),
		Phone1 varchar(50),
		Phone2 varchar(50)
	);

INSERT INTO @Contact (ContactName, Phone1, Phone2)
	VALUES
		('A','555-1212','555-1213'),
		('B','555-1214','555-1215');
		SET STATISTICS IO ON;
/* UNION Method */
SELECT
	ContactName,
	PhoneNum = 1,
	Phone = Phone1
FROM		@Contact
UNION ALL
SELECT
	ContactName,
	PhoneNum = 2,
	Phone = Phone2
FROM		@Contact;

/* Exploding Rows Method */
SELECT
	ContactName,
	PhoneNum = t.n,
	CASE WHEN t.n = 1 THEN Phone1 ELSE Phone2 END
FROM		@Contact
CROSS JOIN	(SELECT n = 1 UNION ALL SELECT n = 2) AS t;


SELECT		*
FROM		(SELECT 'A' UNION ALL SELECT 'B') AS L(Col)
JOIN		(SELECT 'A' UNION ALL SELECT 'B') AS R(Col)
ON			L.Col = R.Col;

SELECT		*
FROM		(SELECT 'A' UNION ALL SELECT 'B') AS L(Col)
CROSS JOIN	(SELECT 'A' UNION ALL SELECT 'B') AS R(Col)
WHERE		L.Col = R.Col;

SELECT		*
FROM		(SELECT 'A') AS C(Col)
CROSS JOIN	(SELECT 1 UNION ALL SELECT 2) AS TallyTable(n);