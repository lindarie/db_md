CREATE DATABASE extra2;
GO
USE extra2;
GO

--EXEC sp_configure 'show advanced options', 1;
--RECONFIGURE;
--EXEC sp_configure 'xp_cmdshell', 1;
--RECONFIGURE;

CREATE XML SCHEMA COLLECTION StudentSchemaCollection AS 
N'<?xml version="1.0"?>
<xsd:schema
    targetNamespace="http://schemas.lu.lv/Student" 
    xmlns="http://schemas.lu.lv/Student" 
	elementFormDefault="qualified" 
    attributeFormDefault="unqualified"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <xsd:element name="student">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element name="name" type="xsd:string"/>
                <xsd:element name="studentID" type="xsd:int"/>
                <xsd:element name="courses">
                    <xsd:complexType>
                        <xsd:sequence>
                            <xsd:element name="course" maxOccurs="unbounded">
                                <xsd:complexType>
                                    <xsd:simpleContent>
                                        <xsd:extension base="xsd:string">
                                            <xsd:attribute name="grade" type="xsd:int" use="optional"/>
                                        </xsd:extension>
                                    </xsd:simpleContent>
                                </xsd:complexType>
                            </xsd:element>
                        </xsd:sequence>
                    </xsd:complexType>
                </xsd:element>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>';
GO

CREATE TABLE StudentGrades (
	StudentID int,
	Transcript xml (CONTENT StudentSchemaCollection)
);

CREATE TABLE Students (
  StudentID INT,
  Name NVARCHAR(100),
  Student_number INT,
  Course NVARCHAR(100),
  Grade NVARCHAR(10)
);

CREATE TABLE XmlDataStore (
    XmlDataID int IDENTITY(1,1) PRIMARY KEY,
    XmlContent xml,
    DateAdded datetime DEFAULT GETDATE()
);

INSERT INTO StudentGrades
VALUES
(1,
'<student xmlns="http://schemas.lu.lv/Student">
	<name>Anna</name>
	<studentID>123456</studentID>
	<courses>
		<course grade="9">OOP</course>
		<course grade="8">Algebra</course>
	</courses>
</student>');
GO

CREATE OR ALTER PROCEDURE SaveXml
AS
BEGIN
  DECLARE @xmlData XML;
  DECLARE @filePath NVARCHAR(100);
  DECLARE @cmd NVARCHAR(1000);
  DECLARE @XMLDataFromDisk XML;
  DECLARE @sql NVARCHAR(MAX);
  DECLARE @hdoc INT;

  -- xml no StudentGrades
  SET @xmlData = (SELECT * FROM StudentGrades FOR XML PATH('Student'), ROOT('Students'));
  SET @filePath = 'C:\\database\\students.xml';

  SET @cmd = 'bcp "SELECT * FROM StudentGrades FOR XML PATH(''Student''), ROOT(''Students'')" queryout "' + @filePath + '" -w -T -d extra2';
  EXEC xp_cmdshell @cmd;

  -- nolasa xml no diska
  SET @sql = N'SELECT @xmlDataResult = CAST(x AS XML) FROM OPENROWSET(BULK ''' + @filePath + ''', SINGLE_BLOB) AS T(x);';

BEGIN TRY
    EXEC sp_executesql @sql, N'@xmlDataResult xml OUTPUT', @XMLDataFromDisk OUTPUT;
    INSERT INTO XmlDataStore (XmlContent) VALUES (@XMLDataFromDisk);

	-- OPEN XML
	EXEC sp_xml_preparedocument @hdoc OUTPUT, @XMLDataFromDisk, '<root xmlns:ns="http://schemas.lu.lv/Student"/>';

	INSERT INTO Students(StudentID, Name, Student_number, Course, Grade)
	SELECT Student.StudentID, Student.Name, Student.Student_number, Course.Course, Course.Grade
	FROM (SELECT StudentID, Name, Student_number FROM OPENXML(@hdoc, '/Students/Student/Transcript/ns:student', 2)
	   WITH (
		 StudentID INT '../../StudentID',
		 Name NVARCHAR(100) 'ns:name',
		 Student_number NVARCHAR(100) 'ns:studentID'
	   )) AS Student
	CROSS APPLY
	  (SELECT Course, Grade FROM OPENXML(@hdoc, '/Students/Student/Transcript/ns:student/ns:courses/ns:course', 2)
	   WITH (
		 Course NVARCHAR(100) '.',
		 Grade NVARCHAR(10) '@grade'
	   )) AS Course;

    EXEC sp_xml_removedocument @hdoc;
  END TRY
  BEGIN CATCH
    PRINT ERROR_MESSAGE();
  END CATCH

END;
GO

EXEC SaveXml;
SELECT * FROM XmlDataStore;
SELECT * FROM Students;

-- FOR XML EXPLICIT
SELECT 1 AS Tag, NULL AS Parent, StudentID AS [Student!1!StudentID], NULL AS [Transcript!2!xml]
FROM StudentGrades
UNION ALL
SELECT 2 AS Tag, 1 AS Parent, StudentID, Transcript.query('declare namespace ns="http://schemas.lu.lv/Student"; /ns:student').query('.') AS [Transcript!2!xml]
FROM StudentGrades
FOR XML EXPLICIT, ROOT('Students');

-- clean up
DROP TABLE Students;
USE master;
GO
DROP DATABASE extra2;

