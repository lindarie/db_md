CREATE DATABASE Linda_6;
GO
USE Linda_6;
GO

CREATE TABLE Student
(StudentID	int PRIMARY KEY,
FirstName nvarchar(30),
LastName nvarchar(30),
FullName AS (FirstName + ' ' + LastName));

CREATE TABLE StudentAddress
(AddressID	int PRIMARY KEY,
CountryCode nvarchar(30),
City nvarchar(30),
Street nvarchar(30),
StudentID int,
FOREIGN KEY (StudentID) REFERENCES Student(StudentID));

CREATE TABLE Course
(CourseID int PRIMARY KEY,
CourseName nvarchar(30));

CREATE TABLE StudentCourse
(StudentCoursesID int PRIMARY KEY,
StudentID int,
CourseID int,
FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
FOREIGN KEY (CourseID) REFERENCES Course(CourseID));

INSERT INTO Student VALUES (1,'Anna', 'Kalniņa');
INSERT INTO Student VALUES (2,'Jānis', 'Kalniņš');
INSERT INTO Student VALUES (3,'Jānis', 'Bērziņš');
INSERT INTO Course VALUES (1,'Datu bāzes');
INSERT INTO Course VALUES (2,'OOP');
INSERT INTO Course VALUES (3,'Tīmekļa dizains');
INSERT INTO StudentCourse VALUES (1,1,1);
INSERT INTO StudentCourse VALUES (2,1,2);
INSERT INTO StudentCourse VALUES (3,2,1);
INSERT INTO StudentCourse VALUES (4,2,2);
INSERT INTO StudentCourse VALUES (5,2,3);
INSERT INTO StudentCourse VALUES (6,3,1);
INSERT INTO StudentAddress VALUES (1,'LV','Riga','Brivibas',1);
INSERT INTO StudentAddress VALUES (2,'LV','Riga','Tallinas',2);
INSERT INTO StudentAddress VALUES (3,'LV','Riga','Terbatas',3);
GO

CREATE VIEW vStudentCourses 
WITH SCHEMABINDING
AS
SELECT s.StudentID, s.FullName, c.CourseID, c.CourseName
FROM dbo.Student s
JOIN dbo.StudentCourse sc ON s.StudentID = sc.StudentID
JOIN dbo.Course c ON sc.CourseID = c.CourseID;
GO

SELECT * FROM vStudentCourses;

SELECT * FROM sys.views;

-- Skata definīcija
exec sp_helptext 'vStudentCourses';

select distinct OBJECT_NAME(object_id), OBJECT_DEFINITION(object_id)
from sys.sql_dependencies
where referenced_major_id=
OBJECT_ID('Student');

-- VIEW INDEX
CREATE UNIQUE CLUSTERED INDEX IX_vStudentCourses_Clustered
ON vStudentCourses(StudentID, CourseID);
GO

SELECT index_id, name, is_unique, type_desc,is_primary_key FROM sys.indexes i WHERE i.object_id = OBJECT_ID('vStudentCourses');
GO

CREATE VIEW vStudentAddress
AS
SELECT s.StudentID, s.FirstName, s.LastName, s.FullName, a.AddressID, a.City, a.CountryCode, a.Street
FROM dbo.Student s
JOIN StudentAddress a ON a.StudentID = s.StudentID;
GO

SELECT * FROM vStudentAddress;

-- VIEW UPDATE
UPDATE vStudentAddress
SET Street = 'Brivibas'
WHERE AddressID = 3;

SELECT * FROM vStudentAddress;

-- VIEW INSERT
INSERT INTO vStudentAddress (AddressID, City, CountryCode, Street)   
VALUES (4,'LV','Riga','Terbatas');   
GO  

SELECT * FROM StudentAddress;

DROP VIEW vStudentCourses;
DROP VIEW vStudentAddress;
DROP TABLE StudentAddress;
DROP TABLE StudentCourse;
DROP TABLE Student;
DROP TABLE Course;

USE master;
GO
DROP DATABASE Linda_6;
