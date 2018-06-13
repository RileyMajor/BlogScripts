/*

1		2		3
4		5		6
7		8		9

Winning states:
	1, 2, 3
	4, 5, 6
	7, 8, 9
	1, 4, 7
	2, 5, 8
	3, 6, 9
	1, 5, 9
	3, 5, 7

*/

USE TempDB;

DROP TABLE IF EXISTS AllGames;

CREATE TABLE AllGames
(
	a1 tinyint NOT NULL,
	b1 tinyint NOT NULL,
	a2 tinyint NOT NULL,
	b2 tinyint NOT NULL,
	a3 tinyint NOT NULL,
	b3 tinyint NOT NULL,
	a4 tinyint NOT NULL,
	b4 tinyint NOT NULL,
	a5 tinyint NOT NULL,
	winner bit -- NULL = none; 0 = A, 1 = B
);

CREATE UNIQUE CLUSTERED INDEX IDX_C_Moves ON AllGames
(
	a1,
	b1,
	a2,
	b2,
	a3,
	b3,
	a4,
	b4,
	a5
);

WITH g AS
(
	SELECT n = 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
)
INSERT INTO AllGames
(
	a1, b1, a2, b2, a3, b3, a4, b4, a5, winner
)
SELECT
	Game.a1,
	Game.b1,
	Game.a2,
	Game.b2,
	Game.a3,
	Game.b3,
	Game.a4,
	Game.b4,
	Game.a5,
	CASE WHEN Winner.Winner = 'A' THEN 0 WHEN Winner.Winner = 'B' THEN 1 ELSE NULL END
	/*
		Game.*,
		Round3Winner.*,
		Round4Winner.*,
		Round5Winner.*,
		Winner.*,
		WinPercentA = AVG(CONVERT(float,CASE WHEN Winner.Winner = 'A' THEN 1 ELSE 0 END)) OVER (PARTITION BY 1),
		WinPercentA1 = AVG(CONVERT(float,CASE WHEN Winner.Winner = 'A' THEN 1 ELSE 0 END)) OVER (PARTITION BY Game.a1)
	*/
FROM		g
CROSS APPLY	(
				SELECT
					n
				FROM		g AS gt
				WHERE		gt.n <> g.n
			) g2
CROSS APPLY	(
				SELECT
					n
				FROM		g AS gt
				WHERE		gt.n <> g.n
				AND			gt.n <> g2.n
			) g3
CROSS APPLY	(
				SELECT
					n
				FROM		g AS gt
				WHERE		gt.n <> g.n
				AND			gt.n <> g2.n
				AND			gt.n <> g3.n
			) g4
CROSS APPLY	(
				SELECT
					n
				FROM		g AS gt
				WHERE		gt.n <> g.n
				AND			gt.n <> g2.n
				AND			gt.n <> g3.n
				AND			gt.n <> g4.n
			) g5
CROSS APPLY	(
				SELECT
					n
				FROM		g AS gt
				WHERE		gt.n <> g.n
				AND			gt.n <> g2.n
				AND			gt.n <> g3.n
				AND			gt.n <> g4.n
				AND			gt.n <> g5.n
			) g6
CROSS APPLY	(
				SELECT
					n
				FROM		g AS gt
				WHERE		gt.n <> g.n
				AND			gt.n <> g2.n
				AND			gt.n <> g3.n
				AND			gt.n <> g4.n
				AND			gt.n <> g5.n
				AND			gt.n <> g6.n
			) g7
CROSS APPLY	(
				SELECT
					n
				FROM		g AS gt
				WHERE		gt.n <> g.n
				AND			gt.n <> g2.n
				AND			gt.n <> g3.n
				AND			gt.n <> g4.n
				AND			gt.n <> g5.n
				AND			gt.n <> g6.n
				AND			gt.n <> g7.n
			) g8
CROSS APPLY	(
				SELECT
					n
				FROM		g AS gt
				WHERE		gt.n <> g.n
				AND			gt.n <> g2.n
				AND			gt.n <> g3.n
				AND			gt.n <> g4.n
				AND			gt.n <> g5.n
				AND			gt.n <> g6.n
				AND			gt.n <> g7.n
				AND			gt.n <> g8.n
			) g9
CROSS APPLY	(
				SELECT
					a1 = g.n,
					b1 = g2.n,
					a2 = g3.n,
					b2 = g4.n,
					a3 = g5.n,
					b3 = g6.n,
					a4 = g7.n,
					b4 = g8.n,
					a5 = g9.n
			) Game
CROSS APPLY	(
				SELECT
					WinMask1 = POWER(2,1) + POWER(2,2) + POWER(2,3),
					WinMask2 = POWER(2,4) + POWER(2,5) + POWER(2,6),
					WinMask3 = POWER(2,7) + POWER(2,8) + POWER(2,9),
					WinMask4 = POWER(2,1) + POWER(2,4) + POWER(2,7),
					WinMask5 = POWER(2,2) + POWER(2,5) + POWER(2,8),
					WinMask6 = POWER(2,3) + POWER(2,6) + POWER(2,9),
					WinMask7 = POWER(2,1) + POWER(2,5) + POWER(2,9),
					WinMask8 = POWER(2,3) + POWER(2,5) + POWER(2,7)
			) w
CROSS APPLY	(
				SELECT
					Round3MaskA = POWER(2,Game.a1) + POWER(2,Game.a2) + POWER(2,Game.a3),
					Round3MaskB = POWER(2,Game.b1) + POWER(2,Game.b2) + POWER(2,Game.b3)
			) Round3Masks
CROSS APPLY	(
				SELECT
					Round4MaskA = Round3Masks.Round3MaskA + POWER(2,Game.a4),
					Round4MaskB = Round3Masks.Round3MaskB + POWER(2,Game.b4)
			) Round4Masks
CROSS APPLY	(
				SELECT
					Round5MaskA = Round4Masks.Round4MaskA + POWER(2,Game.a5)
			) Round5Masks
CROSS APPLY	(
				SELECT
					Round3Winner =
						CASE
							WHEN
								(
									Round3Masks.Round3MaskA & w.WinMask1 = w.WinMask1
								OR
									Round3Masks.Round3MaskA & w.WinMask2 = w.WinMask2
								OR
									Round3Masks.Round3MaskA & w.WinMask3 = w.WinMask3
								OR
									Round3Masks.Round3MaskA & w.WinMask4 = w.WinMask4
								OR
									Round3Masks.Round3MaskA & w.WinMask5 = w.WinMask5
								OR
									Round3Masks.Round3MaskA & w.WinMask6 = w.WinMask6
								OR
									Round3Masks.Round3MaskA & w.WinMask7 = w.WinMask7
								OR
									Round3Masks.Round3MaskA & w.WinMask8 = w.WinMask8
								)
							THEN
								'A'
							WHEN
								(
									Round3Masks.Round3MaskB & w.WinMask1 = w.WinMask1
								OR
									Round3Masks.Round3MaskB & w.WinMask2 = w.WinMask2
								OR
									Round3Masks.Round3MaskB & w.WinMask3 = w.WinMask3
								OR
									Round3Masks.Round3MaskB & w.WinMask4 = w.WinMask4
								OR
									Round3Masks.Round3MaskB & w.WinMask5 = w.WinMask5
								OR
									Round3Masks.Round3MaskB & w.WinMask6 = w.WinMask6
								OR
									Round3Masks.Round3MaskB & w.WinMask7 = w.WinMask7
								OR
									Round3Masks.Round3MaskB & w.WinMask8 = w.WinMask8
								)
							THEN
								'B'
							ELSE
								''
						END
			) Round3Winner
CROSS APPLY	(
				SELECT
					Round4Winner =
						CASE
							WHEN
								Round3Winner.Round3Winner = ''
							AND
								(
									Round4Masks.Round4MaskA & w.WinMask1 = w.WinMask1
								OR
									Round4Masks.Round4MaskA & w.WinMask2 = w.WinMask2
								OR
									Round4Masks.Round4MaskA & w.WinMask3 = w.WinMask3
								OR
									Round4Masks.Round4MaskA & w.WinMask4 = w.WinMask4
								OR
									Round4Masks.Round4MaskA & w.WinMask5 = w.WinMask5
								OR
									Round4Masks.Round4MaskA & w.WinMask6 = w.WinMask6
								OR
									Round4Masks.Round4MaskA & w.WinMask7 = w.WinMask7
								OR
									Round4Masks.Round4MaskA & w.WinMask8 = w.WinMask8
								)
							THEN
								'A'
							WHEN
								Round3Winner.Round3Winner = ''
							AND
								(
									Round4Masks.Round4MaskB & w.WinMask1 = w.WinMask1
								OR
									Round4Masks.Round4MaskB & w.WinMask2 = w.WinMask2
								OR
									Round4Masks.Round4MaskB & w.WinMask3 = w.WinMask3
								OR
									Round4Masks.Round4MaskB & w.WinMask4 = w.WinMask4
								OR
									Round4Masks.Round4MaskB & w.WinMask5 = w.WinMask5
								OR
									Round4Masks.Round4MaskB & w.WinMask6 = w.WinMask6
								OR
									Round4Masks.Round4MaskB & w.WinMask7 = w.WinMask7
								OR
									Round4Masks.Round4MaskB & w.WinMask8 = w.WinMask8
								)
							THEN
								'B'
							ELSE
								''
						END
			) Round4Winner
CROSS APPLY	(
				SELECT
					Round4Winner =
						CASE
							WHEN
								Round3Winner.Round3Winner = ''
							AND
								Round4Winner.Round4Winner = ''
							AND
								(
									Round5Masks.Round5MaskA & w.WinMask1 = w.WinMask1
								OR
									Round5Masks.Round5MaskA & w.WinMask2 = w.WinMask2
								OR
									Round5Masks.Round5MaskA & w.WinMask3 = w.WinMask3
								OR
									Round5Masks.Round5MaskA & w.WinMask4 = w.WinMask4
								OR
									Round5Masks.Round5MaskA & w.WinMask5 = w.WinMask5
								OR
									Round5Masks.Round5MaskA & w.WinMask6 = w.WinMask6
								OR
									Round5Masks.Round5MaskA & w.WinMask7 = w.WinMask7
								OR
									Round5Masks.Round5MaskA & w.WinMask8 = w.WinMask8
								)
							THEN
								'A'
							ELSE
								''
						END
			) Round5Winner
CROSS APPLY	(
				SELECT
					Winner = Round3Winner.Round3Winner + Round4Winner.Round4Winner + Round5Winner.Round4Winner
			) Winner;

GO

DROP FUNCTION IF EXISTS GetNextMoveProbability;
GO

CREATE FUNCTION GetNextMoveProbability
(
	@a1 tinyint,
	@b1 tinyint,
	@a2 tinyint,
	@b2 tinyint,
	@a3 tinyint,
	@b3 tinyint,
	@a4 tinyint,
	@b4 tinyint
)
RETURNS table AS
RETURN
SELECT
	TOP (1)
	NextMove = r.NextMove,
	NextPlayer = CASE r.NextPlayer WHEN 0 THEN 'A' WHEN 1 THEN 'B' ELSE '?' END,
	NextPlayerWinLikelihood = CONVERT(numeric(19,4),SUM(r.NextPlayerWinner)) / CONVERT(numeric(19,4),COUNT(*)),
	NextPlayerTieLikelihood = CONVERT(numeric(19,4),SUM(r.NextPlayerTie)) / CONVERT(numeric(19,4),COUNT(*))
FROM		(
				SELECT
					NextMove = CalcNext.NextMove,
					NextPlayer = CalcNext.NextPlayer,
					NextPlayerWinner = CASE WHEN CalcNext.NextPlayer = ISNULL(CONVERT(int,g.Winner),-1) THEN 1 ELSE 0 END,
					NextPlayerTie = CASE WHEN g.Winner IS NULL THEN 1 ELSE 0 END
				FROM		AllGames g
				CROSS APPLY	(
								SELECT
									NextMove = 
										CASE
											WHEN @b4 IS NOT NULL THEN
												g.a5
											WHEN @a4 IS NOT NULL THEN
												g.b4
											WHEN @b3 IS NOT NULL THEN
												g.a4
											WHEN @a3 IS NOT NULL THEN
												g.b3
											WHEN @b2 IS NOT NULL THEN
												g.a3
											WHEN @a2 IS NOT NULL THEN
												g.b2
											WHEN @b1 IS NOT NULL THEN
												g.a2
											WHEN @a1 IS NOT NULL THEN
												g.b1
											ELSE
												g.a1
										END,
									NextPlayer =
										CASE
											WHEN @b4 IS NOT NULL THEN
												0
											WHEN @a4 IS NOT NULL THEN
												1
											WHEN @b3 IS NOT NULL THEN
												0
											WHEN @a3 IS NOT NULL THEN
												1
											WHEN @b2 IS NOT NULL THEN
												0
											WHEN @a2 IS NOT NULL THEN
												1
											WHEN @b1 IS NOT NULL THEN
												0
											WHEN @a1 IS NOT NULL THEN
												1
											ELSE
												0
										END
							) AS CalcNext
				WHERE		g.a1 = isNull(@a1,g.a1)
				AND			g.b1 = isNull(@b1,g.b1)
				AND			g.a2 = isNull(@a2,g.a2)
				AND			g.b2 = isNull(@b2,g.b2)
				AND			g.a3 = isNull(@a3,g.a3)
				AND			g.b3 = isNull(@b3,g.b3)
				AND			g.a4 = isNull(@a4,g.a4)
				AND			g.b4 = isNull(@b4,g.b4)
		) AS r
GROUP BY	r.NextMove,
			r.NextPlayer
ORDER BY	NextPlayerWinLikelihood DESC,
			NextPlayerTieLikelihood DESC;
GO

SELECT	*
FROM	GetNextMoveProbability
		(
			9,				/*	@a1 tinyint,	*/
			5,				/*	@b1 tinyint,	*/
			6,				/*	@a2 tinyint,	*/
			3,				/*	@b2 tinyint,	*/
			7,				/*	@a3 tinyint,	*/
			NULL,			/*	@b3 tinyint,	*/
			NULL,			/*	@a4 tinyint,	*/
			NULL			/*	@b4 tinyint		*/
		);

GO

DECLARE
	@a1 tinyint = 9,
	@b1 tinyint = 5,
	@a2 tinyint = 6,
	@b2 tinyint = 3,
	@a3 tinyint = 7,
	@b3 tinyint,
	@a4 tinyint,
	@b4 tinyint;

				SELECT
					*,
					NextMove = CalcNext.NextMove,
					NextPlayer = CalcNext.NextPlayer,
					NextPlayerWinner = CASE WHEN CalcNext.NextPlayer = ISNULL(CONVERT(int,g.winner),-1) THEN 1 ELSE 0 END,
					NextPlayerTie = CASE WHEN g.Winner IS NULL THEN 1 ELSE 0 END
				FROM		AllGames g
				CROSS APPLY	(
								SELECT
									NextMove = 
										CASE
											WHEN @b4 IS NOT NULL THEN
												g.a5
											WHEN @a4 IS NOT NULL THEN
												g.b4
											WHEN @b3 IS NOT NULL THEN
												g.a4
											WHEN @a3 IS NOT NULL THEN
												g.b3
											WHEN @b2 IS NOT NULL THEN
												g.a3
											WHEN @a2 IS NOT NULL THEN
												g.b2
											WHEN @b1 IS NOT NULL THEN
												g.a2
											WHEN @a1 IS NOT NULL THEN
												g.b1
											ELSE
												g.a1
										END,
									NextPlayer =
										CASE
											WHEN @b4 IS NOT NULL THEN
												0
											WHEN @a4 IS NOT NULL THEN
												1
											WHEN @b3 IS NOT NULL THEN
												0
											WHEN @a3 IS NOT NULL THEN
												1
											WHEN @b2 IS NOT NULL THEN
												0
											WHEN @a2 IS NOT NULL THEN
												1
											WHEN @b1 IS NOT NULL THEN
												0
											WHEN @a1 IS NOT NULL THEN
												1
											ELSE
												0
										END
							) AS CalcNext
				WHERE		g.a1 = isNull(@a1,g.a1)
				AND			g.b1 = isNull(@b1,g.b1)
				AND			g.a2 = isNull(@a2,g.a2)
				AND			g.b2 = isNull(@b2,g.b2)
				AND			g.a3 = isNull(@a3,g.a3)
				AND			g.b3 = isNull(@b3,g.b3)
				AND			g.a4 = isNull(@a4,g.a4)
				AND			g.b4 = isNull(@b4,g.b4)

GO

DROP TABLE IF EXISTS GameHistory;
CREATE TABLE GameHistory
(
	n int IDENTITY,
	a1 tinyint NOT NULL,
	b1 tinyint NOT NULL,
	a2 tinyint NOT NULL,
	b2 tinyint NOT NULL,
	a3 tinyint NOT NULL,
	b3 tinyint NOT NULL,
	a4 tinyint NOT NULL,
	b4 tinyint NOT NULL,
	a5 tinyint NOT NULL,
	winner bit NULL, -- NULL = none; 0 = A, 1 = B
	player1type tinyint NOT NULL, -- 1 = probability; 2 = learner
	player2type tinyint NOT NULL -- 1 = probability; 2 = learner
)
GO
CREATE CLUSTERED INDEX IDX_C_Moves ON GameHistory
(
	a1,
	b1,
	a2,
	b2,
	a3,
	b3,
	a4,
	b4,
	a5
);
GO

DROP VIEW IF EXISTS ViewTicTacToeRandomNumber;
GO
CREATE VIEW ViewTicTacToeRandomNumber
AS
  SELECT randomNumber = RAND();
GO

DROP FUNCTION IF EXISTS GetTicTacToeRandomNumber;
GO
CREATE FUNCTION GetTicTacToeRandomNumber()
RETURNS DECIMAL(12,11)
AS
BEGIN
    RETURN (SELECT randomNumber FROM ViewTicTacToeRandomNumber);
END
GO

DROP FUNCTION IF EXISTS GetNextMoveLearning;
GO

CREATE FUNCTION GetNextMoveLearning
(
	@a1 tinyint,
	@b1 tinyint,
	@a2 tinyint,
	@b2 tinyint,
	@a3 tinyint,
	@b3 tinyint,
	@a4 tinyint,
	@b4 tinyint
)
RETURNS table AS
RETURN
SELECT
	TOP (1)
	Ordering = 0,
	NextMove = r.NextMove,
	NextPlayer = CASE r.NextPlayer WHEN 0 THEN 'A' WHEN 1 THEN 'B' ELSE '?' END,
	NextPlayerWinLikelihood = CONVERT(numeric(19,4),SUM(r.NextPlayerWinner)) / CONVERT(numeric(19,4),COUNT(*)),
	NextPlayerTieLikelihood = CONVERT(numeric(19,4),SUM(r.NextPlayerTie)) / CONVERT(numeric(19,4),COUNT(*))
FROM		(
				SELECT
					NextMove = CalcNextMove.NextMove,
					NextPlayer = CalcNextPlayer.NextPlayer,
					NextPlayerWinner = CASE WHEN CalcNextPlayer.NextPlayer = ISNULL(CONVERT(int,g.winner),-1) THEN 1 ELSE 0 END,
					NextPlayerTie = CASE WHEN g.Winner IS NULL THEN 1 ELSE 0 END
				FROM		(
								SELECT
									NextPlayer =
										CASE
											WHEN @b4 IS NOT NULL THEN
												0
											WHEN @a4 IS NOT NULL THEN
												1
											WHEN @b3 IS NOT NULL THEN
												0
											WHEN @a3 IS NOT NULL THEN
												1
											WHEN @b2 IS NOT NULL THEN
												0
											WHEN @a2 IS NOT NULL THEN
												1
											WHEN @b1 IS NOT NULL THEN
												0
											WHEN @a1 IS NOT NULL THEN
												1
											ELSE
												0
										END
							) CalcNextPlayer
				CROSS APPLY	(
								SELECT		*
								FROM		(
												SELECT		a1, b1, a2, b2, a3, b3, a4, b4, a5, winner
												FROM		GameHistory g
												WHERE		g.a1 = isNull(@a1,g.a1)
												AND			g.b1 = isNull(@b1,g.b1)
												AND			g.a2 = isNull(@a2,g.a2)
												AND			g.b2 = isNull(@b2,g.b2)
												AND			g.a3 = isNull(@a3,g.a3)
												AND			g.b3 = isNull(@b3,g.b3)
												AND			g.a4 = isNull(@a4,g.a4)
												AND			g.b4 = isNull(@b4,g.b4)
												UNION ALL
												SELECT		
													TOP (1)	nums.n, nums.n, nums.n, nums.n, nums.n, nums.n, nums.n, nums.n, nums.n, CalcNextPlayer.NextPlayer
												FROM		(
																SELECT n = 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
															) AS nums
												WHERE		nums.n NOT IN
															(
																ISNULL(@a1,0),
																ISNULL(@b1,0),
																ISNULL(@a2,0),
																ISNULL(@b2,0),
																ISNULL(@a3,0),
																ISNULL(@b3,0),
																ISNULL(@a4,0),
																ISNULL(@b4,0)
															)
												ORDER BY	dbo.GetTicTacToeRandomNumber() DESC
											) AS u
							) AS g
				CROSS APPLY	(
								SELECT
									NextMove = 
										CASE
											WHEN @b4 IS NOT NULL THEN
												g.a5
											WHEN @a4 IS NOT NULL THEN
												g.b4
											WHEN @b3 IS NOT NULL THEN
												g.a4
											WHEN @a3 IS NOT NULL THEN
												g.b3
											WHEN @b2 IS NOT NULL THEN
												g.a3
											WHEN @a2 IS NOT NULL THEN
												g.b2
											WHEN @b1 IS NOT NULL THEN
												g.a2
											WHEN @a1 IS NOT NULL THEN
												g.b1
											ELSE
												g.a1
										END
							) AS CalcNextMove												
		) AS r
GROUP BY	r.NextMove,
			r.NextPlayer
ORDER BY	NextPlayerWinLikelihood DESC,
			NextPlayerTieLikelihood DESC;
GO

DROP PROCEDURE IF EXISTS PlayGameProbVsLearn;
GO

CREATE PROCEDURE PlayGameLearnVsLearn
AS
	INSERT INTO dbo.GameHistory
	(
		a1,
		b1,
		a2,
		b2,
		a3,
		b3,
		a4,
		b4,
		a5,
		winner,
		player1type,
		player2type
	)
	SELECT
		m1.NextMove,
		m2.NextMove,
		m3.NextMove,
		m4.NextMove,
		m5.NextMove,
		m6.NextMove,
		m7.NextMove,
		m8.NextMove,
		m9.NextMove,
		g.winner,
		2,
		2
	FROM		GetNextMoveLearning
				(
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) AS m1
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) m2
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) m3
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) m4
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					NULL,
					NULL,
					NULL,
					NULL
				) m5
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					NULL,
					NULL,
					NULL
				) m6
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					m6.NextMove,
					NULL,
					NULL
				) m7
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					m6.NextMove,
					m7.NextMove,
					NULL
				) m8
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					m6.NextMove,
					m7.NextMove,
					m8.NextMove
				) m9
	JOIN		dbo.AllGames g
	ON			g.a1 = m1.NextMove
	AND			g.b1 = m2.NextMove
	AND			g.a2 = m3.NextMove
	AND			g.b2 = m4.NextMove
	AND			g.a3 = m5.NextMove
	AND			g.b3 = m6.NextMove
	AND			g.a4 = m7.NextMove
	AND			g.b4 = m8.NextMove
	AND			g.a5 = m9.NextMove;

GO



DROP PROCEDURE IF EXISTS PlayGameProbVsLearn;
GO

CREATE PROCEDURE PlayGameProbVsLearn
AS
IF RAND() > .5
BEGIN
	INSERT INTO dbo.GameHistory
	(
		a1,
		b1,
		a2,
		b2,
		a3,
		b3,
		a4,
		b4,
		a5,
		winner,
		player1type,
		player2type
	)
	SELECT
		m1.NextMove,
		m2.NextMove,
		m3.NextMove,
		m4.NextMove,
		m5.NextMove,
		m6.NextMove,
		m7.NextMove,
		m8.NextMove,
		m9.NextMove,
		g.winner,
		2,
		1
	FROM		GetNextMoveLearning
				(
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) AS m1
	CROSS APPLY	GetNextMoveProbability
				(
					m1.NextMove,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) m2
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) m3
	CROSS APPLY	GetNextMoveProbability
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) m4
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					NULL,
					NULL,
					NULL,
					NULL
				) m5
	CROSS APPLY	GetNextMoveProbability
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					NULL,
					NULL,
					NULL
				) m6
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					m6.NextMove,
					NULL,
					NULL
				) m7
	CROSS APPLY	GetNextMoveProbability
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					m6.NextMove,
					m7.NextMove,
					NULL
				) m8
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					m6.NextMove,
					m7.NextMove,
					m8.NextMove
				) m9
	JOIN		dbo.AllGames g
	ON			g.a1 = m1.NextMove
	AND			g.b1 = m2.NextMove
	AND			g.a2 = m3.NextMove
	AND			g.b2 = m4.NextMove
	AND			g.a3 = m5.NextMove
	AND			g.b3 = m6.NextMove
	AND			g.a4 = m7.NextMove
	AND			g.b4 = m8.NextMove
	AND			g.a5 = m9.NextMove;
END
ELSE
BEGIN
	INSERT INTO dbo.GameHistory
	(
		a1,
		b1,
		a2,
		b2,
		a3,
		b3,
		a4,
		b4,
		a5,
		winner,
		player1type,
		player2type
	)
	SELECT
		m1.NextMove,
		m2.NextMove,
		m3.NextMove,
		m4.NextMove,
		m5.NextMove,
		m6.NextMove,
		m7.NextMove,
		m8.NextMove,
		m9.NextMove,
		g.winner,
		1,
		2
	FROM		GetNextMoveProbability
				(
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) AS m1
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) m2
	CROSS APPLY	GetNextMoveProbability
				(
					m1.NextMove,
					m2.NextMove,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) m3
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL
				) m4
	CROSS APPLY	GetNextMoveProbability
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					NULL,
					NULL,
					NULL,
					NULL
				) m5
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					NULL,
					NULL,
					NULL
				) m6
	CROSS APPLY	GetNextMoveProbability
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					m6.NextMove,
					NULL,
					NULL
				) m7
	CROSS APPLY	GetNextMoveLearning
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					m6.NextMove,
					m7.NextMove,
					NULL
				) m8
	CROSS APPLY	GetNextMoveProbability
				(
					m1.NextMove,
					m2.NextMove,
					m3.NextMove,
					m4.NextMove,
					m5.NextMove,
					m6.NextMove,
					m7.NextMove,
					m8.NextMove
				) m9
	JOIN		dbo.AllGames g
	ON			g.a1 = m1.NextMove
	AND			g.b1 = m2.NextMove
	AND			g.a2 = m3.NextMove
	AND			g.b2 = m4.NextMove
	AND			g.a3 = m5.NextMove
	AND			g.b3 = m6.NextMove
	AND			g.a4 = m7.NextMove
	AND			g.b4 = m8.NextMove
	AND			g.a5 = m9.NextMove
END
GO

SELECT * FROM GameHistory;
GO
EXEC dbo.PlayGameLearnVsLearn
GO 10000

EXEC dbo.PlayGameProbVsLearn
GO 100000
SELECT * FROM GameHistory;
GO






