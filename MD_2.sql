CREATE DATABASE Linda_2;
GO

use Linda_2;
GO

CREATE SCHEMA Person;
GO

CREATE TYPE Person.number_type FROM int NOT NULL;
CREATE TYPE Person.name_type FROM nvarchar(50) NOT NULL;
CREATE TYPE Person.date_type FROM smalldatetime NOT NULL;

CREATE PARTITION FUNCTION pf_OrderBirthDate(smalldatetime)
AS RANGE RIGHT
FOR VALUES ('01/01/2000', '01/01/2002');


ALTER DATABASE Linda_2 ADD FILEGROUP fg1;
ALTER DATABASE Linda_2 ADD FILEGROUP fg2;
ALTER DATABASE Linda_2 ADD FILEGROUP fg3;
ALTER DATABASE Linda_2 ADD FILEGROUP fg4;
GO

ALTER DATABASE Linda_2 
ADD FILE 
( NAME = data1,
  FILENAME = 'C:\database\fg1.ndf',
  SIZE = 1MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 1MB)
TO FILEGROUP fg1;
GO

ALTER DATABASE Linda_2 
ADD FILE 
( NAME = data2,
  FILENAME = 'C:\database\fg2.ndf',
  SIZE = 1MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 1MB)
TO FILEGROUP fg2
GO

ALTER DATABASE Linda_2 
ADD FILE 
( NAME = data3,
  FILENAME = 'C:\database\fg3.ndf',
  SIZE = 1MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 1MB)
TO FILEGROUP fg3
GO

ALTER DATABASE Linda_2 
ADD FILE 
( NAME = data4,
  FILENAME = 'C:\database\fg4.ndf',
  SIZE = 1MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 1MB)
TO FILEGROUP fg4
GO

CREATE PARTITION SCHEME ps_PersonBirthDate
AS PARTITION pf_OrderBirthDate 
TO (fg1, fg2, fg3, fg4)
GO

CREATE TABLE PersonPartitionedTable
(
	PersonID int IDENTITY(1,1) NOT NULL,
	HomeAddress nvarchar(100) NULL,
	DateCreated smalldatetime NOT NULL,
	Height decimal(4,2) NULL,
	CurrentWeight float NULL,
	Number Person.number_type,
	Full_name Person.name_type,
	Birthday Person.date_type,
	Age AS DATEDIFF(yy, Birthday, GETDATE())
)
ON ps_PersonBirthDate(birthday);
GO

INSERT INTO PersonPartitionedTable
VALUES  ('Riga', GETDATE(), 1.65, 60.1, 222, 'Janis A', '1999-09-15'),
		('Riga', GETDATE(), 1.70, 68.8, 234, 'Liene B', '1995-09-15'),
		('Riga', GETDATE(), 1.80, 70.5, 234, 'Peteris B', '2000-09-15'),
		('Riga', GETDATE(), 1.72, 80.5, 221, 'Anna S', '2001-09-15'),
		('Riga', GETDATE(), 1.68, 75, 225, 'Alise M', '2002-09-15'),
		('Riga', GETDATE(), 1.7, 76, 223, 'Peteris S', '2003-09-15'),
		('Riga', GETDATE(), 1.5, 75, 225, 'Anna R', '2004-09-15'),
		('Riga', GETDATE(), 1.5, 76, 223, 'Anna K', '2005-09-15');

SELECT * FROM PersonPartitionedTable;

-- View partition metadata
SELECT * FROM sys.partitions
WHERE [object_id] = OBJECT_ID('dbo.PersonPartitionedTable')

-- View data with partition number
SELECT PersonID, Birthday, $Partition.pf_OrderBirthDate(Birthday) PartitionNo
FROM dbo.PersonPartitionedTable

-- Verify lowest and highest value in each partition
SELECT MIN(Birthday) FirstBirthday, MAX(Birthday) LastBirthday, $Partition.pf_OrderBirthDate(Birthday) PartitionNo
FROM dbo.PersonPartitionedTable
GROUP BY $Partition.pf_OrderBirthDate(Birthday)
ORDER BY PartitionNo

-- Switching, merging, splitting
CREATE TABLE dbo.PersonArchive
(
	PersonID int IDENTITY(1,1) NOT NULL,
	HomeAddress nvarchar(100) NULL,
	DateCreated smalldatetime NOT NULL,
	Height decimal(4,2) NULL,
	CurrentWeight float NULL,
	Number Person.number_type,
	Full_name Person.name_type,
	Birthday Person.date_type,
	Age AS DATEDIFF(yy, Birthday, GETDATE())
) ON fg1

ALTER TABLE dbo.PersonPartitionedTable 
SWITCH PARTITION 1
TO dbo.PersonArchive

SELECT * FROM dbo.PersonArchive;

ALTER PARTITION FUNCTION pf_OrderBirthDate() 
MERGE RANGE ('01/01/2000')

ALTER PARTITION FUNCTION pf_OrderBirthDate() 
SPLIT RANGE ('01/01/2004')

-- View data with partition number
SELECT PersonID, Birthday, $Partition.pf_OrderBirthDate(Birthday) PartitionNo
FROM dbo.PersonPartitionedTable

-- Reset database
DROP TABLE dbo.PersonPartitionedTable;
DROP TABLE dbo.PersonArchive;
DROP PARTITION SCHEME ps_PersonBirthDate;
DROP PARTITION FUNCTION pf_OrderBirthDate;
USE master;
GO
DROP DATABASE Linda_2;

-- Temporary Table
USE tempdb;
GO

CREATE TABLE #Person
( PersonID int PRIMARY KEY,
  Age int
);
GO

INSERT #Person (PersonID, Age)
VALUES  (1, 20),
		(2, 21),
		(3, 22);

SELECT * FROM #Person;
GO

-- Disconnect and reconnect 

USE tempdb;
GO

-- Attempt to query the table again (this will fail)
SELECT * FROM #Person;
GO
