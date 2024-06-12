USE AdventureWorksDW2022;

-- nonclustered columstore indeksi
CREATE NONCLUSTERED COLUMNSTORE INDEX fis
ON dbo.FactInternetSales (ProductKey, OrderDate, SalesAmount);

CREATE NONCLUSTERED COLUMNSTORE INDEX fpi 
ON dbo.FactProductInventory (ProductKey, DateKey, UnitCost, UnitsOut);

CREATE NONCLUSTERED COLUMNSTORE INDEX frs 
ON dbo.FactResellerSales (OrderDateKey, SalesTerritoryKey, EmployeeKey, SalesAmount, OrderQuantity, SalesOrderNumber, ResellerKey);

-- clean up
DROP INDEX fis ON dbo.FactInternetSales;
DROP INDEX fpi ON dbo.FactProductInventory;
DROP INDEX frs ON dbo.FactResellerSales;


ALTER TABLE FactInternetSalesReason DROP CONSTRAINT FK_FactInternetSalesReason_FactInternetSales;
ALTER TABLE FactInternetSales DROP CONSTRAINT PK_FactInternetSales_SalesOrderNumber_SalesOrderLineNumber;
ALTER TABLE FactProductInventory DROP CONSTRAINT PK_FactProductInventory;
ALTER TABLE FactResellerSales DROP CONSTRAINT PK_FactResellerSales_SalesOrderNumber_SalesOrderLineNumber;

-- clustered columstore indeksi
CREATE CLUSTERED COLUMNSTORE INDEX cci_fis ON dbo.FactInternetSales;
CREATE CLUSTERED COLUMNSTORE INDEX cci_fpi ON dbo.FactProductInventory;
CREATE CLUSTERED COLUMNSTORE INDEX cci_frs ON dbo.FactResellerSales;

-- clean up
DROP INDEX cci_fis ON dbo.FactInternetSales;
DROP INDEX cci_fpi ON dbo.FactProductInventory;
DROP INDEX cci_frs ON dbo.FactResellerSales;
