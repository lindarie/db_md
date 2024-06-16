CREATE DATABASE extra6;
GO
USE extra6;
GO

CREATE TABLE Taisnsturi (
    tid INT PRIMARY KEY IDENTITY(1,1),
    x1 FLOAT,
    y1 FLOAT,
    x2 FLOAT,
    y2 FLOAT,
    figura AS geometry::STGeomFromText('POLYGON((' + 
		CAST(x1 AS VARCHAR(20)) + ' ' + CAST(y1 AS VARCHAR(20)) + ', ' + 
		CAST(x2 AS VARCHAR(20)) + ' ' + CAST(y1 AS VARCHAR(20)) + ', ' + 
		CAST(x2 AS VARCHAR(20)) + ' ' + CAST(y2 AS VARCHAR(20)) + ', ' + 
		CAST(x1 AS VARCHAR(20)) + ' ' + CAST(y2 AS VARCHAR(20)) + ', ' + 
		CAST(x1 AS VARCHAR(20)) + ' ' + CAST(y1 AS VARCHAR(20)) + '))', 0) PERSISTED
);

INSERT INTO Taisnsturi (x1, y1, x2, y2) VALUES
(0, 0, 4, 4),
(2, 2, 6, 6),
(5, 5, 9, 9),
(1, 1, 3, 3),
(7, 7, 11, 11);


-- pārklājošais laukums
WITH Parklajumi AS (
    SELECT t1.tid AS t1_id, t2.tid AS t2_id, ROUND(t1.figura.STIntersection(t2.figura).STArea(), 2) AS parklajumu_laukums,
        CASE
			-- pilnībā ietver citu taisnstūri
            WHEN t1.figura.STContains(t2.figura) = 1 THEN t2.tid
            WHEN t2.figura.STContains(t1.figura) = 1 THEN t1.tid
            ELSE NULL
        END AS ietverosa_taisnastura_id
    FROM Taisnsturi t1
	-- katru pāri salīdzina vienu reizi
    INNER JOIN Taisnsturi t2 ON t1.tid < t2.tid
    WHERE
        t1.figura.STOverlaps(t2.figura) = 1
		OR t1.figura.STContains(t2.figura) = 1
        OR t2.figura.STContains(t1.figura) = 1
),

-- taisnstūru laukumi (izņemot laukumus, kas pilnībā pārklājas)
TainsturuLaukumi AS (
    SELECT tid, ROUND(figura.STArea(), 2) AS laukums FROM Taisnsturi
    WHERE tid NOT IN (SELECT ietverosa_taisnastura_id FROM Parklajumi WHERE ietverosa_taisnastura_id IS NOT NULL)
),

-- pārklājumu laukumu summa (izņemot laukumus, kas pilnībā pārklājas)
KopejaisParklajums AS (
    SELECT ROUND(SUM(parklajumu_laukums), 2) as kopejais_parklajumu_laukums FROM Parklajumi WHERE ietverosa_taisnastura_id IS NULL
),

-- pārbauda, vai ir super taisnstūris
SuperTainsturis AS (
    SELECT tid FROM Taisnsturi
    WHERE NOT EXISTS (SELECT 1 FROM Taisnsturi t2 WHERE Taisnsturi.tid <> t2.tid AND NOT Taisnsturi.figura.STContains(t2.figura) = 1)
)

SELECT 
    CASE
		-- super taisnstūra laukums
        WHEN EXISTS (SELECT 1 FROM SuperTainsturis) THEN (SELECT ROUND(SUM(laukums), 2) FROM TainsturuLaukumi)

		-- kopējais laukums = taisnstūru laukumi - pārklājumi
        ELSE (SELECT ROUND(SUM(laukums), 2) FROM TainsturuLaukumi) - (SELECT kopejais_parklajumu_laukums FROM KopejaisParklajums)
    END AS Kopējais_laukums;


-- clean up
DELETE FROM Taisnsturi;
DROP TABLE Taisnsturi;
USE master;
GO
DROP DATABASE extra6;
