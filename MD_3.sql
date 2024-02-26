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
INSERT INTO Users (UserID, UserName, PersonID) VALUES (3, 'l', 0);


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
