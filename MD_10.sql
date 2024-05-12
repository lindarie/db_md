use AdventureWorks2019
GO

-- Enable CLR integration
sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

ALTER DATABASE AdventureWorks2019 SET TRUSTWORTHY ON;
GO

-- Importē asembliju
CREATE ASSEMBLY AWorksUtilities
FROM 'C:\database\AWorksUtilities.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS; -- failu piekļūšanai
GO

-- Triggeris EmailChange
CREATE TRIGGER EmailChange ON Person.EmailAddress
FOR UPDATE AS EXTERNAL NAME AWorksUtilities.Triggers.EmailChange;
GO

-- tests
UPDATE Person.EmailAddress SET EmailAddress = 'john8@adwenture-works.com' WHERE EmailAddressID = 1;
UPDATE Person.EmailAddress SET ModifiedDate=GETDATE() WHERE EmailAddressID = 1;
SELECT * FROM Person.EmailAddress WHERE EmailAddressID = 1;

-- Agregācijas funkcija Concatenate
CREATE AGGREGATE Concatenate(@input nvarchar(4000))  
RETURNS nvarchar(4000)  
EXTERNAL NAME AWorksUtilities.Concatenate;  
GO  

-- tests
SELECT dbo.Concatenate(CurrencyCode) AS ConcatenatedCurrencyCodes FROM Sales.Currency;
GO

-- Procedūra SaveXML
CREATE PROCEDURE SaveXML (@XmlData XML, @FileName nvarchar(100))
AS EXTERNAL NAME AWorksUtilities.StoredProcedures.SaveXML;
GO

-- neveiksmīgs tests
ALTER DATABASE AdventureWorks2019 SET TRUSTWORTHY OFF;
GO

EXEC SaveXML @XmlData = '<root><item>Tests</item></root>', @FileName ='C:\database\test.xml';

-- pievieno nepieciešamās atļaujas
ALTER DATABASE AdventureWorks2019 SET TRUSTWORTHY ON;
GO
sp_changedbowner 'sa'

-- veiksmīgs tests
EXEC SaveXML @XmlData = '<root><item>Test</item></root>', @FileName ='C:\database\test.xml';
GO

-- Funkcija GetLongDate 
CREATE FUNCTION GetLongDate(@DateVal datetime)
RETURNS nvarchar(50)
EXTERNAL NAME AWorksUtilities.UserDefinedFunctions.GetLongDate;
GO

-- tests
SELECT dbo.GetLongDate(GETDATE()) AS TodayDate;

-- Datu tips IPAddress
CREATE TYPE IPAddress
EXTERNAL NAME AWorksUtilities.IPAddress;
GO

-- tests 
DECLARE @IP IPAddress = '192.168.1.1';
SELECT @IP.A AS PartA, @IP.B AS PartB, @IP.C AS PartC, @IP.D AS PartD;
SELECT @IP.Ping() AS PingResult;

-- clean up
DROP TRIGGER Person.EmailChange;
DROP AGGREGATE Concatenate;
DROP PROCEDURE SaveXML;
DROP FUNCTION GetLongDate;
DROP TYPE IPAddress;
DROP ASSEMBLY AWorksUtilities;
ALTER DATABASE AdventureWorks2019 SET TRUSTWORTHY OFF;
