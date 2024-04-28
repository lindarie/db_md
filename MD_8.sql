CREATE DATABASE Linda_8;
GO
USE Linda_8;
GO

CREATE TABLE Student
(StudentID	int IDENTITY PRIMARY KEY,
FirstName nvarchar(30),
LastName nvarchar(30));

CREATE TABLE Course
(CourseID int IDENTITY PRIMARY KEY,
CourseName nvarchar(30));

CREATE TABLE StudentCourse
(StudentCoursesID int IDENTITY PRIMARY KEY,
StudentID int,
CourseID int,
CourseStatus nvarchar(30),
FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
FOREIGN KEY (CourseID) REFERENCES Course(CourseID));

INSERT INTO Student VALUES ('Jānis', 'Bērziņš');
INSERT INTO Course VALUES ('Datu bāzes');
INSERT INTO Course VALUES ('OOP');
INSERT INTO Course VALUES ('Tīmekļa dizains');
INSERT INTO StudentCourse VALUES (1,1, 'Reģistrēts');
INSERT INTO StudentCourse VALUES (1,2, 'Nokārtots');
INSERT INTO StudentCourse VALUES (1,3, 'Nav nokārtots');
GO

-- skalāra funkcija
CREATE FUNCTION StudentFullName (@StudentID int, @Delimiter nchar(1))
RETURNS nvarchar(100)
AS
BEGIN
    DECLARE @FullName nvarchar(100)
    SELECT @FullName = CONCAT(FirstName, @Delimiter, LastName)
    FROM Student WHERE StudentID = @StudentID
    RETURN @FullName
END
GO

SELECT dbo.StudentFullName(1, '_') AS FullName;
GO

-- Inline table-valued funkcija
CREATE FUNCTION StudentsForCourse (@CourseID int, @Status nvarchar(30)) 
RETURNS TABLE
AS
RETURN (
	SELECT s.FirstName, s.LastName, c.CourseID, c.CourseName, sc.CourseStatus
	FROM Student AS s
	JOIN StudentCourse AS sc ON s.StudentID = sc.StudentID
	JOIN Course AS c ON sc.CourseID = c.CourseID
	WHERE c.CourseID = @CourseID AND sc.CourseStatus = @Status);
GO

SELECT * FROM StudentsForCourse(1, 'Reģistrēts');
GO

-- Multi-Statement Table-Valued funkcija
CREATE FUNCTION UpdateCourseStatus (@StudentID int, @CourseID int, @Status nvarchar(30))
RETURNS @Result TABLE (
    StudentID int,
    CourseID int,
    CourseStatus nvarchar(30),
	CourseName nvarchar(30)
)
AS
BEGIN
    -- Insert
    INSERT @Result (StudentID, CourseID, CourseStatus, CourseName)
    SELECT sc.StudentID, sc.CourseID, sc.CourseStatus, c.CourseName
    FROM StudentCourse AS sc
	JOIN Course AS c ON c.CourseID = sc.CourseID
    WHERE StudentID = @StudentID;

    -- Update
    UPDATE @Result
    SET CourseStatus = @Status
    WHERE StudentID = @StudentID AND CourseID = @CourseID;

	-- Delete
    DELETE FROM @Result
    WHERE StudentID = @StudentID AND CourseStatus = 'Nav nokārtots';

    RETURN;
END;
GO

SELECT * FROM UpdateCourseStatus(1,1, 'Nokārtots');

DROP FUNCTION StudentFullName;
DROP FUNCTION StudentsForCourse;
DROP FUNCTION UpdateCourseStatus;
USE master;
GO
DROP DATABASE Linda_8;
