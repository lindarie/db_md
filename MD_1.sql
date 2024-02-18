IF NOT EXISTS (
   SELECT name
   FROM sys.databases
   WHERE name = 'Linda_1'
)
CREATE DATABASE Linda_1 
ON (NAME='Linda_1_Data',
    FILENAME='C:\database\Linda_1.mdf',
	SIZE=100 MB,
	FILEGROWTH=10 MB)
LOG ON (NAME='Linda_1_Log',
	FILENAME='C:\database\Linda_1_Log.ldf',
	SIZE=5 MB,
	FILEGROWTH=1 MB);
GO

use Linda_1;
GO

ALTER DATABASE Linda_1 ADD FILEGROUP DataFilegroup

ALTER DATABASE Linda_1 ADD FILE (
	NAME='Linda_1_Data2',
	FILENAME='C:\database\Linda_1_Data2.ndf')
TO FILEGROUP DataFilegroup;
GO

CREATE SCHEMA test1;
GO

CREATE SCHEMA test2;
GO

CREATE TABLE test1.testTable(
	id int,
	text nvarchar(100)
)

CREATE TABLE test2.testTable2(
	id int,
	text nvarchar(100)
)

INSERT INTO test1.testTable (test1.id, test1.text)
VALUES  (1, 'TEXT1'),
		(2, 'TEXT2'),
		(3, 'TEXT3'),
		(4, 'TEXT4'),
		(5, 'TEXT5');

SELECT * FROM test1.testTable;

INSERT INTO test2.testTable2 (test2.id, test2.text)
VALUES  (1, 'TEXT1'),
		(2, 'TEXT2'),
		(3, 'TEXT3'),
		(4, 'TEXT4'),
		(5, 'TEXT5');

SELECT * FROM test2.testTable2;

CREATE DATABASE Linda_1_Snapshot ON
(NAME='Linda_1_Data', 
FILENAME='C:\database\Linda_1_Snapshot.ss'),
(NAME='Linda_1_Data2', 
FILENAME='C:\database\Linda_1_Snapshot2.ss')
AS SNAPSHOT OF Linda_1

SELECT * FROM Linda_1_Snapshot.test1.testTable;

UPDATE test1.testTable
SET text = 'new value'
WHERE id IN (1, 3);

SELECT * FROM test1.testTable;
SELECT * FROM Linda_1_Snapshot.test1.testTable;

DROP DATABASE Linda_1_Snapshot;
USE master;
DROP DATABASE Linda_1;