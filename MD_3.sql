/*
Izveidot skriptu, kas veic šādas darbības:

Izveido tabulu, kurā būtu
1) NULL un NOT NULL kolonnas,
2) primārā atslēga,
3) unique constraint,
4) check constraint,
6) default constraint.

Izveido 2. tabulu ar ārējo atslēgu uz pirmo tabulu, kas darbojas on delete cascade veidā.
Izveidot datu manipulācijas (ievietošanas/dzēšanas/maiņas) operācijas, kas pārbauda/demonstrē visu uzdevumā izveidoto tabulu ierobežojumu (contstraint) darbību. Skriptam jāsatur veiksmīgas un neveiksmīgas datu manipulācijas operācijas. Uz katru ierobežojumu vismaz pa vienai veiksmīgai/neveiksmīgai ievietošanas vai dzēšanas vai maiņas operācijai (izņemot default constraint, kam jābūt tikai 1 ievietošanas operācijai). Ārējas atslēgas darbības demonstrēšanai jāuzraksta veiksmīga dzēšanas operācija (kas demonstrē on delete cascade) un neveiksmīga maiņas operācijas.
*/

CREATE DATABASE Linda_3;
GO

use Linda_3;
GO

CREATE TABLE Persons
(
	PersonID int IDENTITY(1,1) NOT NULL,
	PhoneNumber nvarchar(100) NULL UNIQUE,
	Height decimal(4,2) NOT NULL,
	PersonName nvarchar(50) NULL,
	DateCreated date DEFAULT GETDATE(),
	CONSTRAINT PK_Person PRIMARY KEY (PersonID),
	CHECK (Height>0 AND Height<3)
)

CREATE TABLE Users
(
	UserID int NOT NULL,
	UserName nvarchar(30) NULL UNIQUE,
	PersonID int NOT NULL,
	CONSTRAINT UserID PRIMARY KEY (UserID),
	CONSTRAINT fk_users_person_id
	FOREIGN KEY (PersonID)
    REFERENCES Persons (PersonID)
    ON DELETE CASCADE
)

-- Veiksmīga ievietošana
-- PK, NULL NOT NULL, UNIQUE, CHECK, DEFAULT 
INSERT INTO Persons (PhoneNumber, Height, PersonName) VALUES ('22200011', 1.72, NULL);

-- PK, UNIQUE, NOT NULL, FK
INSERT INTO Users (UserID, UserName, PersonID) VALUES (1, 'linda', 1);


-- Neveiksmīga ievietošana
-- PhoneNumber UNIQUE
INSERT INTO Persons (PhoneNumber, Height) VALUES ('22200011', 2); 

-- Height CHECK
INSERT INTO Persons (PhoneNumber, Height) VALUES ('22205611', 6); 

-- Height NOT NULL
INSERT INTO Persons (PhoneNumber, Height) VALUES ('22203311', NULL); 

-- PK
INSERT INTO Users (UserID, UserName, PersonID) VALUES (1, 'lr', 1);

-- FK
INSERT INTO Users (UserName, PersonID) VALUES ('l', 0);


-- ON DELETE CASCADE
SELECT * FROM Persons;
SELECT * FROM Users;

DELETE FROM Persons WHERE PersonID = 1;

SELECT * FROM Persons;
SELECT * FROM Users;   


-- Veiksmīga dzēšana
DROP TABLE Users;
DROP TABLE Persons;
USE master;
GO
DROP DATABASE linda_3;
