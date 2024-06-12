CREATE DATABASE extra3;
GO
USE extra3;
GO

-- Enable CLR integration
sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

ALTER DATABASE extra2 SET TRUSTWORTHY ON;
GO

-- Importē asembliju
CREATE ASSEMBLY KolonnuMaxSummaAssembly
FROM 'C:\database\KolonnuMaxSumma.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS; -- failu piekļūšanai
GO

-- Agregācijas funkcija KolonnuMaxSumma
CREATE AGGREGATE KolonnuMaxSumma(@Value1 int, @Value2 int)
RETURNS int
EXTERNAL NAME KolonnuMaxSummaAssembly.KolonnuMaxSumma;  
GO 

CREATE TABLE Tabula (
    Kolonna1 INT,
    Kolonna2 INT,
	Kolonna3 INT,
);

INSERT INTO Tabula VALUES (1, 0, 1);
INSERT INTO Tabula VALUES (1, 5, 3);
INSERT INTO Tabula VALUES (1, 4, 3);
INSERT INTO Tabula VALUES (2, 7, 3);
INSERT INTO Tabula VALUES (2, 1, 5);
INSERT INTO Tabula VALUES (3, 6, 3);

Select Kolonna1, dbo.KolonnuMaxSumma(Kolonna2, Kolonna3) funkcijas_rezultāts from Tabula group by Kolonna1;

DROP AGGREGATE dbo.KolonnuMaxSumma;
DROP ASSEMBLY KolonnuMaxSummaAssembly;
DROP TABLE Tabula;
USE master;
GO
DROP DATABASE extra3;