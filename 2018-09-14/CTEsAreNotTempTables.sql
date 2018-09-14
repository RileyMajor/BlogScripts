/*
	In most cases, CTEs are mere syntactical conveniences.
	They don't directly affect query plans.
	
*/


DECLARE @t table (n int);
INSERT INTO @t VALUES (1);

/* These have the same query plan. */

SELECT a = n + 1 FROM @t;

WITH t AS
(
	SELECT a = n + 1 FROM @t
)
SELECT a = t.a FROM t;

/* These also have the same query plan. */

SELECT		a1 = t1.a, a2 = t2.a
FROM		(
				SELECT		a = n + 1
				FROM		@t
			) AS t1
CROSS JOIN	(
				SELECT		a = n + 1
				FROM		@t
			) AS t2;

WITH t AS
(
	SELECT		a = n + 1
	FROM		@t
)
SELECT		a1 = t1.a, a2 = t2.a
FROM		t AS t1
CROSS JOIN	t AS t2;