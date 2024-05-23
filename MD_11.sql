use AdventureWorks2019
GO
-- 1
BEGIN TRAN
PRINT @@TRANCOUNT
SELECT * FROM Person.Address WHERE AddressID = 1;
UPDATE Person.Address SET PostalCode = 100 WHERE AddressID = 1;
-- jaunā logā: SELECT * FROM Person.Address WHERE AddressID = 1;
COMMIT
PRINT @@TRANCOUNT

-- 2
BEGIN TRAN
PRINT @@TRANCOUNT
SELECT * FROM Person.Address WHERE AddressID = 1;
UPDATE Person.Address SET PostalCode = 200 WHERE AddressID = 1;
-- jaunā logā: SELECT * FROM Person.Address WHERE AddressID = 1;
ROLLBACK
PRINT @@TRANCOUNT

-- 3
SET IMPLICIT_TRANSACTIONS ON;
SELECT * FROM Person.Address WHERE AddressID = 1;
UPDATE Person.Address SET PostalCode = 300 WHERE AddressID = 1;
PRINT @@TRANCOUNT -- pēc UPDATE automātiski uzsāk jaunu transakciju
-- jaunā logā: SELECT * FROM Person.Address WHERE AddressID = 1;
COMMIT
PRINT @@TRANCOUNT
SET IMPLICIT_TRANSACTIONS OFF;

-- 4
BEGIN TRAN A
UPDATE Person.Address SET PostalCode = 400 WHERE AddressID = 1;
WAITFOR DELAY '00:02:00'

/*READ UNCOMMITTED
jaunā logā:
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	BEGIN TRAN B
	SELECT * FROM Person.Address WHERE AddressID = 1;
*/

/*READ COMMITTED
jaunā logā:
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	BEGIN TRAN B
	SELECT * FROM Person.Address WHERE AddressID = 1;
*/

COMMIT;
PRINT @@TRANCOUNT

-- 5
BEGIN TRAN A
UPDATE Person.Address SET PostalCode = 500 WHERE AddressID = 1; -- bloķē Address tabulu

/*jaunā logā: (bloķē Person tabulu)
	BEGIN TRAN B
	UPDATE Person.Person SET FirstName = 'John' WHERE BusinessEntityID=1;
*/

UPDATE Person.Person SET FirstName = 'Ben' WHERE BusinessEntityID=1;

/*TRAN B logā:
	UPDATE Person.Address SET PostalCode = 600 WHERE AddressID = 1;
	COMMIT;
*/

PRINT @@TRANCOUNT

SELECT PostalCode FROM Person.Address WHERE AddressID = 1;
SELECT FirstName FROM Person.Person WHERE BusinessEntityID = 1;
