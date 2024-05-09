CREATE DATABASE Linda_9;
GO
USE Linda_9;
GO

CREATE TABLE Student
(StudentID int IDENTITY PRIMARY KEY,
FirstName nvarchar(30),
LastName nvarchar(30),
IsDeleted nchar(1) default 'N');

CREATE TABLE StudentLog
(StudentID int,
created_at datetime,
modified_at datetime default NULL,
deleted_at datetime default NULL);
GO

-- after insert
CREATE TRIGGER afterStudentInsert ON Student
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO StudentLog (StudentID, created_at)
    SELECT StudentID, GETDATE() AS InsertedDateTime
    FROM inserted;
END;
GO

INSERT INTO Student(FirstName, LastName) VALUES ('Janis', 'Berzins');
INSERT INTO Student(FirstName, LastName) VALUES ('Anna', 'Kalnina');
INSERT INTO Student(FirstName, LastName) VALUES ('Alise', 'Berzina');
INSERT INTO Student(FirstName, LastName) VALUES ('Annija', 'Kalnina');

SELECT * FROM StudentLog;
GO

-- after update
CREATE TRIGGER afterStudentUpdate ON Student 
AFTER UPDATE
AS
IF (UPDATE(FirstName) OR UPDATE(LastName))
BEGIN
      UPDATE StudentLog
      SET modified_at = GETDATE() FROM inserted
      WHERE inserted.StudentID = StudentLog.StudentID;
END;
GO

UPDATE Student SET FirstName = 'Peteris' WHERE StudentId=1;
UPDATE Student SET FirstName = 'Ilze' WHERE StudentId=2;
SELECT * FROM StudentLog;
GO

-- after delete
CREATE TRIGGER afterStudentDelete ON Student
AFTER DELETE 
AS
BEGIN
    UPDATE sl
    SET sl.deleted_at = GETDATE()
    FROM StudentLog sl
    INNER JOIN deleted d ON sl.StudentID = d.StudentID;
END;
GO

DELETE FROM Student WHERE StudentID=1;
DELETE FROM Student WHERE StudentID=2;
SELECT * FROM StudentLog;
GO

-- instead of delete
CREATE TRIGGER insteadOfStudentDelete ON Student
INSTEAD OF DELETE 
AS
BEGIN
    UPDATE Student SET IsDeleted = 'Y'
    WHERE StudentID IN (SELECT StudentId FROM deleted);
END;
GO

SELECT * FROM Student;
DELETE FROM Student WHERE StudentID=3;
DELETE FROM Student WHERE StudentID=4;
SELECT * FROM Student;


DROP TRIGGER afterStudentInsert;
DROP TRIGGER afterStudentUpdate;
DROP TRIGGER afterStudentDelete;
DROP TRIGGER insteadOfStudentDelete;
DROP TABLE Student;
DROP TABLE StudentLog;

USE master;
GO
DROP DATABASE Linda_9;
