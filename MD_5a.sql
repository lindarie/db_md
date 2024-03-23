CREATE DATABASE Linda_5a;
GO
USE Linda_5a;
GO

CREATE TABLE Student
(StudentID	int IDENTITY PRIMARY KEY,
FirstName nvarchar(30),
LastName nvarchar(30),
FullName AS (FirstName + ' ' + LastName),
StudentInfo xml);

 -- Primary xml index
CREATE PRIMARY XML INDEX IX_StudentInfo_XML 
ON Student(StudentInfo);

-- Path secondary xml index
CREATE XML INDEX IX_StudentInfo_Path ON Student(StudentInfo)
USING XML INDEX IX_StudentInfo_XML
FOR PATH;

-- Value secondary xml index
CREATE XML INDEX IX_StudentInfo_Value ON Student(StudentInfo)
USING XML INDEX IX_StudentInfo_XML
FOR VALUE;

-- Property secondary xml index
CREATE XML INDEX IX_StudentInfo_Property ON Student(StudentInfo)
USING XML INDEX IX_StudentInfo_XML 
FOR PROPERTY;

-- Data insert
INSERT INTO Student
VALUES ('Anna', 'Kalniņa','
	<InfoList>
		<Info>
			<PhoneNumber>22200000</PhoneNumber>
			<Faculty>DF</Faculty>
			<Address Street="Brīvības iela" City="Rīga" ZipCode="1000"/>
		</Info>
	</InfoList>');

INSERT INTO Student
VALUES ('Jānis', 'Kalniņš','
<InfoList>
	<Info>
		<PhoneNumber>22200022</PhoneNumber>
		<Faculty>DF</Faculty>
		<Address Street="Rīgas iela" City="Liepāja" ZipCode="3401"/>
	</Info>
</InfoList>');

INSERT INTO Student
VALUES ('Jānis', 'Bērziņš','
<InfoList>
	<Info>
		<PhoneNumber>22200023</PhoneNumber>
		<Faculty>DF</Faculty>
		<Address Street="Kāpu iela" City="Jūrmala" ZipCode="2008"/>
		<Address Street="Tallinas iela" City="Rīga" ZipCode="1000"/>
	</Info>
</InfoList>');

SELECT * FROM Student;

-- query metode
SELECT StudentInfo.query('
<DetailedInfo>
	<StudentName>{sql:column("FullName")}</StudentName>
	{
		for $i in /InfoList/Info
		return $i
	}
</DetailedInfo>') DetailedStudentInfo
FROM Student;

-- value metode
-- for property index
SELECT FullName, 
	   StudentInfo.value('(InfoList/Info/Address/@Street)[1]', 'nvarchar(50)') AS Street,
       StudentInfo.value('(InfoList/Info/Address/@City)[1]', 'nvarchar(50)') AS City,
       StudentInfo.value('(InfoList/Info/Address/@ZipCode)[1]', 'nvarchar(10)') AS ZipCode
FROM Student
WHERE StudentInfo.exist('//Faculty') = 1;

DROP INDEX IX_StudentInfo_Property ON Student;

-- exist metode
-- for value and path index
SELECT FullName AS Students
FROM Student
WHERE StudentInfo.exist('/InfoList/Info/Faculty[text()="DF"]') = 1 
AND StudentInfo.exist('/InfoList/Info/PhoneNumber') = 1;

-- New Node
UPDATE Student
SET StudentInfo.modify('insert element Email {"student@example.com"} as first into (/InfoList/Info)[1]')
WHERE StudentID = 1;

SELECT StudentInfo.query('(InfoList/Info)[1]') InsertedEmail FROM Student WHERE StudentID = 1;

-- Update Node
UPDATE Student
SET StudentInfo.modify('replace value of (InfoList/Info/Email/text())[1] with "student@lu.lv"')
WHERE StudentID = 1;

SELECT StudentInfo.query('(InfoList/Info)[1]') InsertedEmail FROM Student WHERE StudentID = 1;

-- Delete Node
UPDATE Student
SET StudentInfo.modify('delete (InfoList/Info/Email)[1]')
WHERE StudentID = 1;

SELECT StudentInfo.query('(InfoList/Info)[1]') InsertedEmail FROM Student WHERE StudentID = 1;

-- Extract to table
SELECT nCol.value('(/InfoList/Info/PhoneNumber)[1]', 'nvarchar(20)') PhoneNumber,
	   nCol.value('(/InfoList/Info/Faculty)[1]', 'nvarchar(20)') Faculty,
       nCol.value('@Street[1]', 'nvarchar(100)') Street,
       nCol.value('@City[1]', 'nvarchar(100)') City,
       nCol.value('@ZipCode[1]', 'nvarchar(20)') ZipCode
FROM Student CROSS APPLY StudentInfo.nodes('/InfoList/Info/Address') AS nTable(nCol)
ORDER BY PhoneNumber;

DROP TABLE Student;
USE master;
GO
DROP DATABASE Linda_5a;
