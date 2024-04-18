CREATE DATABASE Linda_7;
GO
USE Linda_7;
GO

CREATE TABLE Student
(StudentID int IDENTITY(1,1) PRIMARY KEY,
StudentName nvarchar(60),
PhoneNumber int,
Gender nchar(1),
Age int CHECK (Age>0));
GO

CREATE PROCEDURE AddStudent
    @StudentName nvarchar(60),
	@PhoneNumber int, 
	@Gender nchar(1),
	@Age int = 18,
	@StudentID int OUTPUT
AS
BEGIN
   IF @Age <= 0
    BEGIN
        RAISERROR ('Age must be greater than 0.', 16, 1);
        RETURN -1
    END
	ELSE IF LEN(@PhoneNumber) != 8 OR (LEFT(@PhoneNumber, 1) NOT IN ('2', '6'))
    BEGIN
        RAISERROR ('Phone number must be 8 digits long and start with 2 or 6.', 16, 1);
        RETURN -1
    END
	ELSE IF UPPER(@Gender) NOT IN ('F', 'M')
    BEGIN
        RAISERROR ('Gender must be "F" or "M".', 16, 1);
        RETURN -1
    END
	INSERT INTO Student (StudentName, PhoneNumber, Gender, Age) VALUES (@StudentName, @PhoneNumber, @Gender, @Age);

	SET @StudentID = SCOPE_IDENTITY();
	RETURN 0
END;
GO

-- veiksmīgi
DECLARE @StudentID INT, @Status INT;
EXEC @Status = AddStudent @StudentName = 'Janis', @PhoneNumber = 22244000, @Gender = 'M', @StudentID = @StudentID OUTPUT;
SELECT @Status as Status, @StudentID as StudentID;
SELECT * FROM Student;
GO

-- neveiksmīgi
DECLARE @StudentID INT, @Status INT;
EXEC  @Status = AddStudent 'Janis', 22244000, 'M', 0, @StudentID OUTPUT;
SELECT @Status as Status, @StudentID as StudentID;
GO

DECLARE @StudentID INT, @Status INT;
EXEC  @Status = AddStudent 'Janis', 123, 'M', 19, @StudentID OUTPUT;
SELECT @Status as Status, @StudentID as StudentID;
GO

DECLARE @StudentID INT, @Status INT;
EXEC  @Status = AddStudent 'Janis', 22244000, 'N', 19, @StudentID OUTPUT;
SELECT @Status as Status, @StudentID as StudentID;
GO

CREATE PROCEDURE UpdateStudentAge
    @StudentID int,
    @NewAge int
AS
BEGIN TRY
	UPDATE Student SET Age = @NewAge WHERE StudentID = @StudentID;
END TRY
BEGIN CATCH 
	SELECT 	ERROR_NUMBER() ErrorNumber, ERROR_MESSAGE() [Message]
END CATCH

-- veiksmīgi
EXEC UpdateStudentAge 1, 22;
SELECT * FROM Student;

-- neveiksmīgi
EXEC UpdateStudentAge 1, 0;
SELECT * FROM Student;


DROP TABLE Student;
DROP PROCEDURE AddStudent;
DROP PROCEDURE UpdateStudentAge;
USE master;
GO
DROP DATABASE Linda_7;
