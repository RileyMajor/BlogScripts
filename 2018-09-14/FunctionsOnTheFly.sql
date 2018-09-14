USE TempDB;
GO

DROP FUNCTION IF EXISTS PhoneFormatter;
GO

CREATE FUNCTION PhoneFormatter
(
	@Phone varchar(50)
)
RETURNS table AS
RETURN
(
	SELECT
		FormattedPhone = REPLACE(REPLACE(REPLACE(REPLACE(@Phone,'(',''),')',''),' ',''),'-','')
);
GO

/* ********************************************************************* */

DECLARE @Contacts table (ContactName varchar(50), Phone1 varchar(50), Phone2 varchar(50));
INSERT INTO @Contacts (ContactName, Phone1, Phone2)
	VALUES
		('Belkis Hine',				'(956) 280-2836',	'(582) 761-3714'),
		('Wanda Um',				'(773) 768-8506', 	'(928) 538-1180'),
		('Loni Vivas',				'(430) 833-6063', 	'(532) 819-3106'),
		('Zofia Schweinsberg',		'(650) 463-7229', 	'(304) 584-0421'),
		('Molly Poli',				'(468) 466-0940', 	'(432) 700-1395'),
		('Francene Alegria',		'(551) 860-8338', 	'(584) 548-0906'),
		('Samual Dooling',			'(313) 464-8311', 	'(269) 382-9269'),
		('Elnora Mastin',			'(836) 815-1659', 	'(822) 600-2384'),
		('Kathryn Franco',			'(627) 264-0615', 	'(862) 220-0895'),
		('Margaret Sides',			'(533) 242-3970', 	'(492) 338-9920');

/* ********************************************************************* */

PRINT CHAR(13) + CHAR(10) + '******************** Plain Select';

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
	c.ContactName,
	c.Phone1,
	c.Phone2
FROM		@Contacts AS c
OPTION		(RECOMPILE);

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

/* ********************************************************************* */

PRINT CHAR(13) + CHAR(10) + '******************** Real Inline Function';

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
	'Inline Function',
	c.ContactName,
	Phone1Formatted = Phone1Formatted.FormattedPhone,
	Phone2Formatted = Phone2Formatted.FormattedPhone
FROM		@Contacts AS c
CROSS APPLY	PhoneFormatter(c.Phone1) AS Phone1Formatted
CROSS APPLY	PhoneFormatter(c.Phone2) AS Phone2Formatted
OPTION		(RECOMPILE);

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

/* ********************************************************************* */

PRINT CHAR(13) + CHAR(10) + '******************** Repeated Code Method';

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
	'Repeated Code',
	ContactName = c.ContactName,
	Phone1Formatted = REPLACE(REPLACE(REPLACE(REPLACE(c.Phone1,'(',''),')',''),' ',''),'-',''),
	Phone2Formatted = REPLACE(REPLACE(REPLACE(REPLACE(c.Phone2,'(',''),')',''),' ',''),'-','')
FROM		@Contacts AS c
OPTION		(RECOMPILE);

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;


/* ********************************************************************* */

PRINT CHAR(13) + CHAR(10) + '******************** Function on the Fly Method';

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
	'Function on the Fly',
	ContactName = c.ContactName,
	Phone1Formatted = t.Phone1Formatted,
	Phone2Formatted = t.Phone2Formatted
FROM		@Contacts AS c
CROSS APPLY	(
				SELECT
					Phone1Formatted = MAX(CASE WHEN Exploder.n = 1 THEN PhoneFormatter.PhoneFormatted ELSE '' END),
					Phone2Formatted = MAX(CASE WHEN Exploder.n = 2 THEN PhoneFormatter.PhoneFormatted ELSE '' END)
				FROM		(SELECT n = 1 UNION ALL SELECT 2) AS Exploder
				CROSS APPLY	(
								SELECT
									Phone = 
										CASE Exploder.n
											WHEN 1 THEN c.Phone1
											WHEN 2 THEN c.Phone2
											ELSE NULL
										END
							) AS Chooser
				CROSS APPLY	(
								SELECT
									PhoneFormatted =
										REPLACE(REPLACE(REPLACE(REPLACE(Chooser.Phone,'(',''),')',''),' ',''),'-','')
							) AS PhoneFormatter
			) AS t
OPTION		(RECOMPILE);

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;


/* ********************************************************************* */

GO

DROP FUNCTION IF EXISTS PhoneFormatter;
GO