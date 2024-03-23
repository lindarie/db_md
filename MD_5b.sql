CREATE DATABASE Linda_5b;
GO
USE Linda_5b;
GO

CREATE TABLE Student
(StudentID	int IDENTITY PRIMARY KEY,
FirstName nvarchar(30),
LastName nvarchar(30),
FullName AS (FirstName + ' ' + LastName));

CREATE TABLE Course
(CourseID int IDENTITY PRIMARY KEY,
CourseName nvarchar(30));

CREATE TABLE StudentCourse
(StudentCoursesID int IDENTITY PRIMARY KEY,
StudentID int,
CourseID int,
FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
FOREIGN KEY (CourseID) REFERENCES Course(CourseID));

INSERT INTO Student VALUES ('Anna', 'Kalniņa');
INSERT INTO Student VALUES ('Jānis', 'Kalniņš');
INSERT INTO Student VALUES ('Jānis', 'Bērziņš');

INSERT INTO Course VALUES ('Datu bāzes');
INSERT INTO Course VALUES ('OOP');
INSERT INTO Course VALUES ('Tīmekļa dizains');

INSERT INTO StudentCourse VALUES (1,1);
INSERT INTO StudentCourse VALUES (1,2);
INSERT INTO StudentCourse VALUES (2,1);
INSERT INTO StudentCourse VALUES (2,2);
INSERT INTO StudentCourse VALUES (2,3);
INSERT INTO StudentCourse VALUES (3,1);

-- FOR XML RAW
SELECT StudentID, FirstName, LastName, FullName
FROM Student
FOR XML RAW ('Student'), ROOT('Students');

-- FOR XML AUTO
SELECT 
    Student.StudentID, 
    Student.FullName, 
    Course.CourseID, 
    Course.CourseName
FROM Student
JOIN StudentCourse ON Student.StudentID = StudentCourse.StudentID
JOIN Course ON StudentCourse.CourseID = Course.CourseID
FOR XML AUTO, ROOT('Students');

-- FOR XML PATH
SELECT
	-- XML atribūts
    StudentID AS '@StudentID',
	-- XML elements
    FullName AS 'FullName'
FROM Student
FOR XML PATH('Student'), ROOT('Students');

-- TYPE
SELECT 
    s.StudentID AS '@StudentID', 
    s.FullName AS 'FullName', 
    (
		SELECT
			c.CourseID AS '@CourseID',
			c.CourseName AS 'Course'
		FROM Course c
		JOIN StudentCourse sc ON c.CourseID = sc.CourseID
		WHERE sc.StudentID = s.StudentID
		FOR XML PATH('Course'), TYPE
    ) AS 'Courses'
FROM Student s
FOR XML PATH('Student'), ROOT('Students');

-- XML SCHEMA
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

select * from sys.xml_schema_namespaces;

select * from sys.xml_schema_collections;

select * from sys.xml_schema_components where xml_collection_id=65536;

CREATE TABLE StudentGrades (
	StudentID int,
	Transcript xml (CONTENT StudentSchemaCollection)
);

-- korekts
INSERT INTO StudentGrades
VALUES
(1,
'<student xmlns="http://schemas.lu.lv/Student">
	<name>Anna</name>
	<studentID>123456</studentID>
	<courses>
		<course grade="9">OOP</course>
		<course>Datu bāzes</course>
	</courses>
</student>');

-- kļūdaini
INSERT INTO StudentGrades
VALUES
(2,
'<student xmlns="http://schemas.lu.lv/Student">
	<name>Anna</name>
	<studentID>123456</studentID>
	<courses>
		<course grade="9">OOP</course>
		<course2>Datu bāzes</course>
	</courses>
</student>');

INSERT INTO StudentGrades
VALUES
(3,
'<student xmlns="http://schemas.lu.lv/Student">
	<name>Anna</name>
	<studentID>123456</studentID>
	<courses>
		<course grade="A">OOP</course>
		<course>Datu bāzes</course>
	</courses>
</student>');

INSERT INTO StudentGrades
VALUES
(4,
'<student xmlns="http://schemas.lu.lv/Student">
	<name>Anna</name>
	<courses>
		<course grade="A">OOP</course>
		<course>Datu bāzes</course>
	</courses>
</student>');

DROP TABLE StudentCourse;
DROP TABLE Student;
DROP TABLE Course;
DROP TABLE StudentGrades;
DROP XML SCHEMA COLLECTION StudentSchemaCollection;

USE master;
GO
DROP DATABASE Linda_5b;
