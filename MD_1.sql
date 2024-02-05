IF NOT EXISTS (
   SELECT name
   FROM sys.databases
   WHERE name = 'name'
)
CREATE DATABASE name 
ON (NAME='name_Data',
    FILENAME='C:\database\name.mdf',
	SIZE=100 MB,
	FILEGROWTH=10 MB)
LOG ON (NAME='name_Log',
	FILENAME='C:\database\name_Log.ldf',
	SIZE=5 MB,
	FILEGROWTH=1 MB)

use name
GO

ALTER DATABASE name ADD FILEGROUP CustomerDataFilegroup

ALTER DATABASE name ADD FILE (
	NAME='name_Data2',
	FILENAME='C:\database\name_Data2.ndf')
TO FILEGROUP CustomerDataFilegroup

CREATE SCHEMA test1

CREATE SCHEMA test2

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

CREATE DATABASE name_Snapshot ON
(NAME='name_Data', 
FILENAME='C:\database\name_Snapshot.ss'),
(NAME='name_Data2', 
FILENAME='C:\database\name_Snapshot2.ss')
AS SNAPSHOT OF name

select * from name_Snapshot.test1.testTable;

UPDATE test1.testTable
SET text = 'new value'
WHERE id IN (1, 3);

SELECT * FROM test1.testTable;
SELECT * FROM name_Snapshot.test1.testTable;

DROP DATABASE name_Snapshot;
USE master;
DROP DATABASE name;