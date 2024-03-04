CREATE DATABASE Linda_4;
GO

use Linda_4;
GO

CREATE TABLE Student (
    ID INT,
    First_name NVARCHAR(100),
	Last_name NVARCHAR(100),
	Full_name AS (First_name + ' ' + Last_name) PERSISTED,
	Birth_date DATE,
	Email NVARCHAR(50),
	Enrollment_date DATE,
	Student_status NVARCHAR(30)
);

CREATE CLUSTERED INDEX IX_Student_ID ON dbo.Student (ID);
GO

-- Unique nonclustered composite index with included columns
CREATE UNIQUE NONCLUSTERED INDEX IX_Student_Last_name
ON Student (Last_name, First_name)
INCLUDE (Email, Student_status);

-- filtered
CREATE NONCLUSTERED INDEX IX_Student_Enrollment_date_Active
ON Student (Enrollment_date)
WHERE Student_status = 'Active';

-- on computed column
CREATE NONCLUSTERED INDEX IX_Student_Full_name
ON Student (Full_name);

SELECT index_id, name, is_unique, type_desc,is_primary_key FROM sys.indexes i WHERE i.object_id = OBJECT_ID('Student');


INSERT INTO Student (ID, First_name, Last_name, Birth_date, Email, Enrollment_date, Student_status)
VALUES
(1, 'Anna', 'Kalniņa', '1995-05-15', 'anna.kalnina@email.com', '2022-01-15', 'Active'),
(2, 'Jānis', 'Kalniņš', '1998-08-22', 'janis.kalnins@email.com', '2021-09-10', 'Inactive'),
(3, 'Jānis', 'Bērziņš', '1997-03-08', 'janis.berzins@email.com', '2020-12-05', 'Active');


SELECT * FROM Student;
SELECT * FROM Student WHERE ID=1;
SELECT Last_name, First_name FROM Student WHERE First_name = 'Jānis';
SELECT Enrollment_date, Student_status FROM Student WHERE Student_status = 'Active' AND Enrollment_date >= '2022-01-01';
SELECT Full_name FROM Student;

DROP INDEX IX_Student_ID ON Student;
DROP INDEX IX_Student_Last_name ON Student;
DROP INDEX IX_Student_Enrollment_date_Active ON Student;
DROP INDEX IX_Student_Full_name ON Student;
DROP TABLE Student;
USE master;
GO
DROP DATABASE Linda_4;
