CREATE DATABASE Linda_4b;
GO
USE Linda_4b;
GO

CREATE TABLE Student (
    ID INT,
	Home_address NVARCHAR(200),
    First_name NVARCHAR(100),
	Last_name NVARCHAR(100),
	Student_status NVARCHAR(30)
);

CREATE CLUSTERED INDEX IX_Student_ID ON dbo.Student(ID);
GO

SELECT * FROM sys.indexes WHERE OBJECT_NAME(object_id) = N'Student';
GO
SELECT * FROM sys.key_constraints WHERE OBJECT_NAME(parent_object_id) = N'Student';
GO

SET NOCOUNT ON;
DECLARE @Counter int = 0;
WHILE @Counter < 10000 BEGIN
  INSERT INTO dbo.Student (ID, Home_address, First_name, Last_name, Student_status)
	VALUES(@Counter,CONCAT('Address', @Counter), CONCAT('Name', @Counter), CONCAT('Surname', @Counter),'Active');
  SET @Counter += 1;
END;
GO

SELECT * FROM Student;

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.Student'),NULL,NULL,'DETAILED');
GO

SET NOCOUNT ON;
DECLARE @Counter int = 0;
WHILE @Counter < 10000 BEGIN
  UPDATE dbo.Student 
  SET 
	Home_address = CONCAT('Address', REPLICATE('0',CAST(RAND() * 180 AS int)))
  WHERE ID = @Counter % 10000;
  IF @Counter % 100 = 0 PRINT @Counter;
  SET @Counter += 1;
END;
GO

SELECT * FROM Student;

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.Student'),NULL,NULL,'DETAILED');
GO

SELECT convert(varchar(120),object_name(ios.object_id)) AS [Object Name], 
       i.[name] AS [Index Name], 
	   SUM (ios.range_scan_count + ios.singleton_lookup_count) AS 'Reads',
       SUM (ios.leaf_insert_count + ios.leaf_update_count + ios.leaf_delete_count) AS 'Writes'
FROM   sys.dm_db_index_operational_stats (db_id(),NULL,NULL,NULL ) ios
       INNER JOIN sys.indexes AS i
         ON i.object_id = ios.object_id 
            AND i.index_id = ios.index_id
WHERE  OBJECTPROPERTY(ios.object_id,'IsUserTable') = 1
GROUP BY object_name(ios.object_id),i.name
ORDER BY Reads ASC, Writes DESC

ALTER INDEX IX_Student_ID ON dbo.Student REORGANIZE;
GO

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.Student'),NULL,NULL,'DETAILED');
GO

ALTER INDEX ALL ON dbo.Student REBUILD;
GO

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.Student'),NULL,NULL,'DETAILED');
GO

DROP TABLE Student;
USE master;
GO
DROP DATABASE Linda_4b;


USE AdventureWorks;
GO

-- Join
SELECT sod.*, soh.*, st.* FROM  sales.SalesOrderDetail AS sod
JOIN sales.SalesOrderHeader  AS soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN sales.Customer AS c ON c.CustomerID = soh.CustomerID
JOIN sales.SalesTerritory  AS st ON c.TerritoryID = st.TerritoryID
WHERE st.CostLastYear = 0
ORDER BY st.SalesLastYear DESC;


-- Aritmētiski operatori
-- Apakšvaicājums
SELECT DISTINCT eph.BusinessEntityID, eph.RateChangeDate, eph.Rate, e.SalariedFlag, eph.Rate * 8 AS DailyWage
FROM HumanResources.EmployeePayHistory AS eph
JOIN HumanResources.Employee AS e ON e.BusinessEntityID = eph.BusinessEntityID
WHERE eph.RateChangeDate = (
    SELECT MAX(RateChangeDate)
    FROM HumanResources.EmployeePayHistory
    WHERE BusinessEntityID = eph.BusinessEntityID
) AND e.SalariedFlag = 1;


-- GROUP BY
-- Having
SELECT  d.Name, count(edh.BusinessEntityID) AS Employees, 
SUM(CASE WHEN e.Gender = 'M' THEN 1 ELSE 0 END) AS MaleEmployees, 
SUM(CASE WHEN e.Gender = 'F' THEN 1 ELSE 0 END) AS FemaleEmployees
FROM HumanResources.EmployeeDepartmentHistory AS edh
JOIN HumanResources.Employee AS e ON edh.BusinessEntityID = e.BusinessEntityID
JOIN HumanResources.Department AS d ON edh.DepartmentID = d.DepartmentID
GROUP BY d.Name
HAVING COUNT(edh.BusinessEntityID) > 5;


-- GROUP BY
-- Having
SELECT st."Group" AS Territory, COUNT(sp.BusinessEntityID) AS SalesPersonCount,
SUM(sp.SalesLastYear) AS SalesLastYear, SUM (sp.Bonus) AS TotalBonus 
FROM Sales.SalesPerson AS sp
JOIN Sales.SalesTerritory AS st ON sp.TerritoryID = st.TerritoryID
GROUP BY st."Group"
HAVING SUM(st.CostLAstYear) = 0;


-- Recomendations
CREATE STATISTICS [_dta_stat_1653580929_1_4] ON [Sales].[Customer]([CustomerID], [TerritoryID])
CREATE NONCLUSTERED INDEX [_dta_index_SalesOrderHeader] ON [Sales].[SalesOrderHeader]
(
	[CustomerID] ASC,
	[SalesOrderID] ASC
)
INCLUDE([RevisionNumber],[OrderDate],[DueDate],[ShipDate],[Status],[OnlineOrderFlag],[PurchaseOrderNumber],[AccountNumber],[SalesPersonID],[TerritoryID],[BillToAddressID],[ShipToAddressID],[ShipMethodID],[CreditCardID],[CreditCardApprovalCode],[CurrencyRateID],[SubTotal],[TaxAmt],[Freight],[Comment],[rowguid],[ModifiedDate]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
CREATE STATISTICS [_dta_stat_1922105888_1_11] ON [Sales].[SalesOrderHeader]([SalesOrderID], [CustomerID])


-- Drop statistics
DROP STATISTICS [Sales].[Customer].[_dta_stat_1653580929_1_4];
DROP STATISTICS [Sales].[SalesOrderHeader].[_dta_stat_1922105888_1_11];

-- Drop index
DROP INDEX [Sales].[SalesOrderHeader].[_dta_index_SalesOrderHeader];
