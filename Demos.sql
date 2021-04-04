
/* 1.1 Select*/
SELECT Name, StandardCost, ListPrice
FROM SalesLT.Product; 


SELECT Name, ListPrice - StandardCost
FROM SalesLT.Product;


SELECT Name, ListPrice - StandardCost AS Markup
FROM SalesLT.Product;


SELECT ProductNumber, Color, Size, Color + ', ' + Size AS ProductDetails
FROM SalesLT.Product; 


SELECT ProductID + ': ' + Name
FROM SalesLT.Product; 

/* 1.2 Converting types*/

SELECT CAST(ProductID AS varchar(5)) + ': ' + Name AS ProductName
FROM SalesLT.Product;

SELECT CONVERT(varchar(5), ProductID) + ': ' + Name AS ProductName
FROM SalesLT.Product;

SELECT SellStartDate,
       CONVERT(nvarchar(30), SellStartDate) AS ConvertedDate,
	   CONVERT(nvarchar(30), SellStartDate, 126) AS ISO8601FormatDate
FROM SalesLT.Product;

SELECT Name, CAST (Size AS Integer) AS NumericSize
FROM SalesLT.Product; --(note error - some sizes are incompatible)

SELECT Name, TRY_CAST (Size AS Integer) AS NumericSize
FROM SalesLT.Product; --(note incompatible sizes are returned as NULL)

/* 1.3 Null Values*/

SELECT Name, ISNULL(TRY_CAST(Size AS Integer),0) AS NumericSize
FROM SalesLT.Product;

SELECT ProductNumber, ISNULL(Color, '') + ', ' + ISNULL(Size, '') AS ProductDetails
FROM SalesLT.Product;

SELECT Name, NULLIF(Color, 'Multi') AS SingleColor
FROM SalesLT.Product;

SELECT Name, COALESCE(DiscontinuedDate, SellEndDate, SellStartDate) AS FirstNonNullDate
FROM SalesLT.Product;

--Searched case
SELECT Name,
		CASE
			WHEN SellEndDate IS NULL THEN 'On Sale'
			ELSE 'Discontinued'
		END AS SalesStatus
FROM SalesLT.Product;

--Simple case
SELECT Name,
		CASE Size
			WHEN 'S' THEN 'Small'
			WHEN 'M' THEN 'Medium'
			WHEN 'L' THEN 'Large'
			WHEN 'XL' THEN 'Extra-Large'
			ELSE ISNULL(Size, 'n/a')
		END AS ProductSize
FROM SalesLT.Product;

/* 2.1 Eliminating duplicates and sorting */

--Display a list of product colors
SELECT Color FROM SalesLT.Product;

--Display a list of product colors with the word 'None' if the value is null
SELECT DISTINCT ISNULL(Color, 'None') AS Color FROM SalesLT.Product;

--Display a list of product colors with the word 'None' if the value is null sorted by color
SELECT DISTINCT ISNULL(Color, 'None') AS Color FROM SalesLT.Product ORDER BY Color;

--Display a list of product colors with the word 'None' if the value is null and a dash if the size is null sorted by color
SELECT DISTINCT ISNULL(Color, 'None') AS Color, ISNULL(Size, '-') AS Size FROM SalesLT.Product ORDER BY Color;


--Display the top 100 products by list price
SELECT TOP 100 Name, ListPrice FROM SalesLT.Product ORDER BY ListPrice DESC;

--Display the first ten products by product number
SELECT Name, ListPrice FROM SalesLT.Product ORDER BY ProductNumber OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY; 

--Display the next ten products by product number
SELECT Name, ListPrice FROM SalesLT.Product ORDER BY ProductNumber OFFSET 10 ROWS FETCH FIRST 10 ROW ONLY;

/* 2.2 Filtering with predicates */

--List information about product model 6
SELECT Name, Color, Size FROM SalesLT.Product WHERE ProductModelID = 6;

--List information about products that have a product number beginning FR
SELECT productnumber,Name, ListPrice FROM SalesLT.Product WHERE ProductNumber LIKE 'FR%';

--Filter the previous query to ensure that the product number contains two sets of two didgets
SELECT Name, ListPrice FROM SalesLT.Product WHERE ProductNumber LIKE 'FR-_[0-9][0-9]_-[0-9][0-9]';

--Find products that have no sell end date
SELECT Name FROM SalesLT.Product WHERE SellEndDate IS NOT NULL;

--Find products that have a sell end date in 2006
SELECT Name FROM SalesLT.Product WHERE SellEndDate BETWEEN '2006/1/1' AND '2006/12/31';

--Find products that have a category ID of 5, 6, or 7.
SELECT ProductCategoryID, Name, ListPrice FROM SalesLT.Product WHERE ProductCategoryID IN (5, 6, 7);

--Find products that have a category ID of 5, 6, or 7 and have a sell end date
SELECT ProductCategoryID, Name, ListPrice, SellEndDate FROM SalesLT.Product WHERE ProductCategoryID IN (5, 6, 7) AND SellEndDate IS NULL;

--Select products that have a category ID of 5, 6, or 7 and a product number that begins FR
SELECT Name, ProductCategoryID, ProductNumber FROM SalesLT.Product WHERE ProductNumber LIKE 'FR%' OR ProductCategoryID IN (5,6,7);

/* 3.1 inner joins */

--Basic inner join
SELECT SalesLT.Product.Name As ProductName, SalesLT.ProductCategory.Name AS Category
FROM SalesLT.Product
INNER JOIN SalesLT.ProductCategory
ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID;

-- Table aliases
SELECT p.Name As ProductName, c.Name AS Category
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory As c
ON p.ProductCategoryID = c.ProductCategoryID;

-- Joining more than 2 tables
SELECT oh.OrderDate, oh.SalesOrderNumber, p.Name As ProductName, od.OrderQty, od.UnitPrice, od.LineTotal
FROM SalesLT.SalesOrderHeader AS oh
JOIN SalesLT.SalesOrderDetail AS od
ON od.SalesOrderID = oh.SalesOrderID
JOIN SalesLT.Product AS p
ON od.ProductID = p.ProductID
ORDER BY oh.OrderDate, oh.SalesOrderID, od.SalesOrderDetailID;

-- Multiple join predicates
SELECT oh.OrderDate, oh.SalesOrderNumber, p.Name As ProductName, od.OrderQty, od.UnitPrice, od.LineTotal
FROM SalesLT.SalesOrderHeader AS oh
JOIN SalesLT.SalesOrderDetail AS od
ON od.SalesOrderID = oh.SalesOrderID
JOIN SalesLT.Product AS p
ON od.ProductID = p.ProductID AND od.UnitPrice = p.ListPrice --Note multiple predicates
ORDER BY oh.OrderDate, oh.SalesOrderID, od.SalesOrderDetailID; 

/* 3.2 Outer joins */

--Get all customers, with sales orders for those who've bought anything
SELECT c.FirstName, c.LastName, oh.SalesOrderNumber
FROM SalesLT.Customer AS c
LEFT OUTER JOIN SalesLT.SalesOrderHeader AS oh
ON c.CustomerID = oh.CustomerID
ORDER BY c.CustomerID;

--Return only customers who haven't purchased anything
SELECT c.FirstName, c.LastName, oh.SalesOrderNumber
FROM SalesLT.Customer AS c
LEFT OUTER JOIN SalesLT.SalesOrderHeader AS oh
ON c.CustomerID = oh.CustomerID
WHERE oh.SalesOrderNumber IS NULL 
ORDER BY c.CustomerID;


--More than 2 tables
SELECT p.Name As ProductName, oh.SalesOrderNumber
FROM SalesLT.Product AS p
LEFT JOIN SalesLT.SalesOrderDetail AS od
ON p.ProductID = od.ProductID
LEFT JOIN SalesLT.SalesOrderHeader AS oh --Additional tables added to the right must also use a left join
ON od.SalesOrderID = oh.SalesOrderID
ORDER BY p.ProductID;


SELECT p.Name As ProductName, c.Name AS Category, oh.SalesOrderNumber
FROM SalesLT.Product AS p
LEFT OUTER JOIN SalesLT.SalesOrderDetail AS od
ON p.ProductID = od.ProductID
LEFT OUTER JOIN SalesLT.SalesOrderHeader AS oh
ON od.SalesOrderID = oh.SalesOrderID
INNER JOIN SalesLT.ProductCategory AS c --Added to the left, so can use inner join
ON p.ProductCategoryID = c.ProductCategoryID
ORDER BY p.ProductID;

/* 3.3 cross join */

--Call each customer once per product
SELECT p.Name, c.FirstName, c.LastName, c.Phone
FROM SalesLT.Product as p
CROSS JOIN SalesLT.Customer as c;

/* 3.4 self join */

--note there's no employee table, so we'll create one for this example
CREATE TABLE SalesLT.Employee
(EmployeeID int IDENTITY PRIMARY KEY,
EmployeeName nvarchar(256),
ManagerID int);
GO
-- Get salesperson from Customer table and generate managers
INSERT INTO SalesLT.Employee (EmployeeName, ManagerID)
SELECT DISTINCT Salesperson, NULLIF(CAST(RIGHT(SalesPerson, 1) as INT), 0)
FROM SalesLT.Customer;
GO
UPDATE SalesLT.Employee
SET ManagerID = (SELECT MIN(EmployeeID) FROM SalesLT.Employee WHERE ManagerID IS NULL)
WHERE ManagerID IS NULL
AND EmployeeID > (SELECT MIN(EmployeeID) FROM SalesLT.Employee WHERE ManagerID IS NULL);
GO
 
-- Here's the actual self-join demo
SELECT e.EmployeeName, m.EmployeeName AS ManagerName
FROM SalesLT.Employee AS e
LEFT JOIN SalesLT.Employee AS m
ON e.ManagerID = m.EmployeeID
ORDER BY e.ManagerID;

/* 4.1 Union */

-- Setup
CREATE VIEW [SalesLT].[Customers]
as
select distinct firstname,lastname
from saleslt.customer
where lastname >='m'
or customerid=3;
GO
CREATE VIEW [SalesLT].[Employees]
as
select distinct firstname,lastname
from saleslt.customer
where lastname <='m'
or customerid=3;
GO

-- Union example
SELECT FirstName, LastName
FROM SalesLT.Employees
UNION
SELECT FirstName, LastName
FROM SalesLT.Customers
ORDER BY LastName;


/* 4.2 iNTERSECT */

SELECT FirstName, LastName
FROM SalesLT.Customers
INTERSECT
SELECT FirstName, LastName
FROM SalesLT.Employees;

/* 4.3 Except */

SELECT FirstName, LastName
FROM SalesLT.Customers
EXCEPT
SELECT FirstName, LastName
FROM SalesLT.Employees;

/* 5.1 Functions */ 
-- Scalar functions
SELECT YEAR(SellStartDate) SellStartYear, ProductID, Name
FROM SalesLT.Product
ORDER BY SellStartYear;

SELECT YEAR(SellStartDate) SellStartYear, DATENAME(mm,SellStartDate) SellStartMonth,
       DAY(SellStartDate) SellStartDay, DATENAME(dw, SellStartDate) SellStartWeekday,
	   ProductID, Name
FROM SalesLT.Product
ORDER BY SellStartYear;

SELECT DATEDIFF(yy,SellStartDate, GETDATE()) YearsSold, ProductID, Name
FROM SalesLT.Product
ORDER BY ProductID;

SELECT UPPER(Name) AS ProductName
FROM SalesLT.Product;

SELECT CONCAT(FirstName + ' ', LastName) AS FullName
FROM SalesLT.Customer;

SELECT Name, ProductNumber, LEFT(ProductNumber, 2) AS ProductType
FROM SalesLT.Product;

SELECT Name, ProductNumber, LEFT(ProductNumber, 2) AS ProductType,
                            SUBSTRING(ProductNumber,CHARINDEX('-', ProductNumber) + 1, 4) AS ModelCode,
							SUBSTRING(ProductNumber, LEN(ProductNumber) - CHARINDEX('-', REVERSE(RIGHT(ProductNumber, 3))) + 2, 2) AS SizeCode
FROM SalesLT.Product;


-- Logical functions
SELECT Name, Size AS NumericSize
FROM SalesLT.Product
WHERE ISNUMERIC(Size) = 1;

SELECT Name, IIF(ProductCategoryID IN (5,6,7), 'Bike', 'Other') ProductType
FROM SalesLT.Product;

SELECT Name, IIF(ISNUMERIC(Size) = 1, 'Numeric', 'Non-Numeric') SizeType
FROM SalesLT.Product;

SELECT prd.Name AS ProductName, cat.Name AS Category,
      CHOOSE (cat.ParentProductCategoryID, 'Bikes','Components','Clothing','Accessories') AS ProductType
FROM SalesLT.Product AS prd
JOIN SalesLT.ProductCategory AS cat
ON prd.ProductCategoryID = cat.ProductCategoryID;


-- Window functions
SELECT TOP(100) ProductID, Name, ListPrice,
	RANK() OVER(ORDER BY ListPrice DESC) AS RankByPrice
FROM SalesLT.Product AS p
ORDER BY RankByPrice;

SELECT c.Name AS Category, p.Name AS Product, ListPrice,
	RANK() OVER(PARTITION BY c.Name ORDER BY ListPrice DESC) AS RankByPrice
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS c
ON p.ProductCategoryID = c.ProductcategoryID
ORDER BY Category, RankByPrice;


-- Aggregate Functions
SELECT COUNT(*) AS Products, COUNT(DISTINCT ProductCategoryID) AS Categories, AVG(ListPrice) AS AveragePrice
FROM SalesLT.Product;

SELECT COUNT(p.ProductID) BikeModels, AVG(p.ListPrice) AveragePrice
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS c
ON p.ProductCategoryID = c.ProductCategoryID
WHERE c.Name LIKE '%Bikes';

/* 5.2 Group By */
SELECT Salesperson, COUNT(CustomerID) Customers
FROM SalesLT.Customer
GROUP BY Salesperson
ORDER BY Salesperson;

SELECT c.Name AS Category, COUNT(p.ProductID) AS Products
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS c
ON p.ProductCategoryID = c.ProductCategoryID
GROUP BY c.Name
ORDER BY Category;

SELECT c.Salesperson, SUM(oh.SubTotal) SalesRevenue
FROM SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
GROUP BY c.Salesperson
ORDER BY SalesRevenue DESC;

SELECT c.Salesperson, ISNULL(SUM(oh.SubTotal), 0.00) SalesRevenue
FROM SalesLT.Customer c
LEFT JOIN SalesLT.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
GROUP BY c.Salesperson
ORDER BY SalesRevenue DESC;

SELECT c.Salesperson, CONCAT(c.FirstName +' ', c.LastName) AS Customer, ISNULL(SUM(oh.SubTotal), 0.00) SalesRevenue
FROM SalesLT.Customer c
LEFT JOIN SalesLT.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
GROUP BY c.Salesperson, CONCAT(c.FirstName +' ', c.LastName)
ORDER BY SalesRevenue DESC, Customer;

/* 5.3 Having */

-- Try to find salespeople with over 150 customers (fails with error)
SELECT Salesperson, COUNT(CustomerID) Customers
FROM SalesLT.Customer
WHERE COUNT(CustomerID) > 100
GROUP BY Salesperson
ORDER BY Salesperson;

--Need to use HAVING clause to filter based on aggregate
SELECT Salesperson, COUNT(CustomerID) Customers
FROM SalesLT.Customer
GROUP BY Salesperson
HAVING COUNT(CustomerID) > 100
ORDER BY Salesperson;


/* 6.1 Scalar subquery */
--Display a list of products whose list price is higher than the highest unit price of items that have sold

SELECT MAX(UnitPrice) FROM SalesLT.SalesOrderDetail

SELECT * from SalesLT.Product
WHERE ListPrice >


SELECT * from SalesLT.Product
WHERE ListPrice >
(SELECT MAX(UnitPrice) FROM SalesLT.SalesOrderDetail)


/* 6.2 Multi-Valued subquery */
--List products that have an order quantity greater than 20

SELECT Name FROM SalesLT.Product
WHERE ProductID IN
(SELECT ProductID from SalesLT.SalesOrderDetail
WHERE OrderQty>20)

SELECT Name 
FROM SalesLT.Product P
JOIN SalesLT.SalesOrderDetail SOD
ON P.ProductID=SOD.ProductID
WHERE OrderQty>20

/*6.3 Correlated Subquery */

--For each customer list all sales on the last day that they made a sale

SELECT CustomerID, SalesOrderID, OrderDate
FROM SalesLT.SalesOrderHeader AS SO1
ORDER BY CustomerID,OrderDate

SELECT CustomerID, SalesOrderID, OrderDate
FROM SalesLT.SalesOrderHeader AS SO1
WHERE orderdate =
(SELECT MAX(orderdate)
FROM SalesLT.SalesOrderHeader)


SELECT CustomerID, SalesOrderID, OrderDate
FROM SalesLT.SalesOrderHeader AS SO1
WHERE orderdate =
(SELECT MAX(orderdate)
FROM SalesLT.SalesOrderHeader AS SO2
WHERE SO2.CustomerID = SO1.CustomerID)
ORDER BY CustomerID

/* 6.4 Correlated subquery */

-- Setup
CREATE FUNCTION SalesLT.udfMaxUnitPrice (@SalesOrderID int)
RETURNS TABLE
AS
RETURN
SELECT SalesOrderID,Max(UnitPrice) as MaxUnitPrice FROM 
SalesLT.SalesOrderDetail
WHERE SalesOrderID=@SalesOrderID
GROUP BY SalesOrderID;

--Display the sales order details for items that are equal to
-- the maximum unit price for that sales order
SELECT * FROM SalesLT.SalesOrderDetail AS SOH
CROSS APPLY SalesLT.udfMaxUnitPrice(SOH.SalesOrderID) AS MUP
WHERE SOH.UnitPrice=MUP.MaxUnitPrice
ORDER BY SOH.SalesOrderID;

/* 7.1 Views */

-- Create a view
CREATE VIEW SalesLT.vCustomerAddress
AS
SELECT C.CustomerID, FirstName, LastName, AddressLine1, City, StateProvince 
FROM
SalesLT.Customer C JOIN SalesLT.CustomerAddress CA
ON C.CustomerID=CA.CustomerID
JOIN SalesLT.Address A
ON CA.AddressID=A.AddressID

-- Query the view
SELECT CustomerID, City
FROM SalesLT.vCustomerAddress

-- Join the view to a table
SELECT c.StateProvince, c.City, ISNULL(SUM(s.TotalDue), 0.00) AS Revenue
FROM SalesLT.vCustomerAddress AS c
LEFT JOIN SalesLT.SalesOrderHeader AS s
ON s.CustomerID = c.CustomerID
GROUP BY c.StateProvince, c.City
ORDER BY c.StateProvince, Revenue DESC;

/* 7.2 Temp Tables and Variables */

-- Temporary table
CREATE TABLE #Colors
(Color varchar(15));

INSERT INTO #Colors
SELECT DISTINCT Color FROM SalesLT.Product;

SELECT * FROM #Colors;

-- Table variable
DECLARE @Colors AS TABLE (Color varchar(15));

INSERT INTO @Colors
SELECT DISTINCT Color FROM SalesLT.Product;

SELECT * FROM @Colors;

-- New batch
SELECT * FROM #Colors;

SELECT * FROM @Colors; -- now out of scope

/* 7.3 TVFs */

CREATE FUNCTION SalesLT.udfCustomersByCity
(@City AS VARCHAR(20))
RETURNS TABLE
AS
RETURN
(SELECT C.CustomerID, FirstName, LastName, AddressLine1, City, StateProvince
 FROM SalesLT.Customer C JOIN SalesLT.CustomerAddress CA
 ON C.CustomerID=CA.CustomerID
 JOIN SalesLT.Address A ON CA.AddressID=A.AddressID
 WHERE City=@City);


SELECT * FROM SalesLT.udfCustomersByCity('Bellevue')

/* 7.4 Derived Tables */

SELECT Category, COUNT(ProductID) AS Products
FROM
	(SELECT p.ProductID, p.Name AS Product, c.Name AS Category
	 FROM SalesLT.Product AS p
	 JOIN SalesLT.ProductCategory AS c
	 ON p.ProductCategoryID = c.ProductCategoryID) AS ProdCats
GROUP BY Category
ORDER BY Category;


/* 7.5 CTEs */

--Using a CTE
WITH ProductsByCategory (ProductID, ProductName, Category)
AS
(
	SELECT p.ProductID, p.Name, c.Name AS Category
	 FROM SalesLT.Product AS p
	 JOIN SalesLT.ProductCategory AS c
	 ON p.ProductCategoryID = c.ProductCategoryID
)

SELECT Category, COUNT(ProductID) AS Products
FROM ProductsByCategory
GROUP BY Category
ORDER BY Category;


-- Recursive CTE
SELECT * FROM SalesLT.Employee

-- Using the CTE to perform recursion
WITH OrgReport (ManagerID, EmployeeID, EmployeeName, Level)
AS
(
	-- Anchor query
	SELECT e.ManagerID, e.EmployeeID, EmployeeName, 0
	FROM SalesLT.Employee AS e
	WHERE ManagerID IS NULL

	UNION ALL

	-- Recursive query
	SELECT e.ManagerID, e.EmployeeID, e.EmployeeName, Level + 1
	FROM SalesLT.Employee AS e
	INNER JOIN OrgReport AS o ON e.ManagerID = o.EmployeeID
)

SELECT * FROM OrgReport
OPTION (MAXRECURSION 3);

/* 8.1 Grouping Sets */

SELECT cat.ParentProductCategoryName, cat.ProductCategoryName, count(prd.ProductID) AS Products
FROM SalesLT.vGetAllCategories as cat
LEFT JOIN SalesLT.Product AS prd
ON prd.ProductCategoryID = cat.ProductcategoryID
GROUP BY cat.ParentProductCategoryName, cat.ProductCategoryName
--GROUP BY GROUPING SETS(cat.ParentProductCategoryName, cat.ProductCategoryName, ())
--GROUP BY ROLLUP (cat.ParentProductCategoryName, cat.ProductCategoryName)
--GROUP BY CUBE (cat.ParentProductCategoryName, cat.ProductCategoryName)
ORDER BY cat.ParentProductCategoryName, cat.ProductCategoryName;

/* 8.2 Pivot */

SELECT * FROM
(SELECT P.ProductID, PC.Name,ISNULL(P.Color, 'Uncolored') AS Color
 FROM saleslt.productcategory AS PC
 JOIN SalesLT.Product AS P
 ON PC.ProductCategoryID=P.ProductCategoryID
 ) AS PPC
PIVOT(COUNT(ProductID) FOR Color IN([Red],[Blue],[Black],[Silver],[Yellow],[Grey], [Multi], [Uncolored])) as pvt
ORDER BY Name;

-- Unpivot
CREATE TABLE #ProductColorPivot
(Name varchar(50), Red int, Blue int, Black int, Silver int, Yellow int, Grey int , multi int, uncolored int);

INSERT INTO #ProductColorPivot
SELECT * FROM
(SELECT P.ProductID, PC.Name,ISNULL(P.Color, 'Uncolored') AS Color
 FROM saleslt.productcategory AS PC
 JOIN SalesLT.Product AS P
 ON PC.ProductCategoryID=P.ProductCategoryID
 ) AS PPC
PIVOT(COUNT(ProductID) FOR Color IN([Red],[Blue],[Black],[Silver],[Yellow],[Grey], [Multi], [Uncolored])) as pvt
ORDER BY Name;

SELECT Name, Color, ProductCount
FROM
(SELECT Name,
[Red],[Blue],[Black],[Silver],[Yellow],[Grey], [Multi], [Uncolored]
FROM #ProductColorPivot) pcp
UNPIVOT
(ProductCount FOR Color IN ([Red],[Blue],[Black],[Silver],[Yellow],[Grey], [Multi], [Uncolored])
) AS ProductCounts







-- Unpivot
CREATE TABLE #SalesByQuarter
(ProductID int,
 Q1 money,
 Q2 money,
 Q3 money,
 Q4 money);

INSERT INTO #SalesByQuarter
VALUES
(1, 19999.00, 21567.00, 23340.00, 25876.00),
(2, 10997.00, 12465.00, 13367.00, 14365.00),
(3, 21900.00, 21999.00, 23376.00, 23676.00);

SELECT * FROM #SalesByQuarter;

SELECT ProductID, Period, Revenue
FROM
(SELECT ProductID,
Q1, Q2, Q3, Q4
FROM #SalesByQuarter) sbq
UNPIVOT
(Revenue FOR Period IN (Q1, Q2, Q3, Q4)
) AS RevenueReport

/* 9.1 Inserting Data */

-- Create a table for the demo
CREATE TABLE SalesLT.CallLog
(
	CallID int IDENTITY PRIMARY KEY NOT NULL,
	CallTime datetime NOT NULL DEFAULT GETDATE(),
	SalesPerson nvarchar(256) NOT NULL,
	CustomerID int NOT NULL REFERENCES SalesLT.Customer(CustomerID),
	PhoneNumber nvarchar(25) NOT NULL,
	Notes nvarchar(max) NULL
);
GO

-- Insert a row
INSERT INTO SalesLT.CallLog
VALUES
('2015-01-01T12:30:00', 'adventure-works\pamela0', 1, '245-555-0173', 'Returning call re: enquiry about delivery');

SELECT * FROM SalesLT.CallLog;

-- Insert defaults and nulls
INSERT INTO SalesLT.CallLog
VALUES
(DEFAULT, 'adventure-works\david8', 2, '170-555-0127', NULL);

SELECT * FROM SalesLT.CallLog;

-- Insert a row with explicit columns
INSERT INTO SalesLT.CallLog (SalesPerson, CustomerID, PhoneNumber)
VALUES
('adventure-works\jillian0', 3, '279-555-0130');

SELECT * FROM SalesLT.CallLog;

-- Insert multiple rows
INSERT INTO SalesLT.CallLog
VALUES
(DATEADD(mi,-2, GETDATE()), 'adventure-works\jillian0', 4, '710-555-0173', NULL),
(DEFAULT, 'adventure-works\shu0', 5, '828-555-0186', 'Called to arrange deliver of order 10987');

SELECT * FROM SalesLT.CallLog;

-- Insert the results of a query
INSERT INTO SalesLT.CallLog (SalesPerson, CustomerID, PhoneNumber, Notes)
SELECT SalesPerson, CustomerID, Phone, 'Sales promotion call'
FROM SalesLT.Customer
WHERE CompanyName = 'Big-Time Bike Store';

SELECT * FROM SalesLT.CallLog;

-- Retrieving inserted identity
INSERT INTO SalesLT.CallLog (SalesPerson, CustomerID, PhoneNumber)
VALUES
('adventure-works\jos�1', 10, '150-555-0127');

SELECT SCOPE_IDENTITY();

SELECT * FROM SalesLT.CallLog;

--Overriding Identity
SET IDENTITY_INSERT SalesLT.CallLog ON;

INSERT INTO SalesLT.CallLog (CallID, SalesPerson, CustomerID, PhoneNumber)
VALUES
(9, 'adventure-works\jos�1', 11, '926-555-0159');

SET IDENTITY_INSERT SalesLT.CallLog OFF;

SELECT * FROM SalesLT.CallLog;

/* 9.2 Updating and deleting */

-- Update a table
UPDATE SalesLT.CallLog
SET Notes = 'No notes'
WHERE Notes IS NULL;

SELECT * FROM SalesLT.CallLog;

-- Update multiple columns
UPDATE SalesLT.CallLog
SET SalesPerson = '', PhoneNumber = ''

SELECT * FROM SalesLT.CallLog;

-- Update from results of a query
UPDATE SalesLT.CallLog
SET SalesPerson = c.SalesPerson, PhoneNumber = c.Phone
FROM SalesLT.Customer AS c
WHERE c.CustomerID = SalesLT.CallLog.CustomerID;

SELECT * FROM SalesLT.CallLog;

-- Delete rows
DELETE FROM SalesLT.CallLog
WHERE CallTime < DATEADD(dd, -7, GETDATE());

SELECT * FROM SalesLT.CallLog;

-- Truncate the table
TRUNCATE TABLE SalesLT.CallLog;

SELECT * FROM SalesLT.CallLog;


/* 10.0 Setup */
IF OBJECT_ID('SalesLT.DemoTable') IS NOT NULL
	BEGIN
	DROP TABLE SalesLT.DemoTable
	END
GO


CREATE TABLE SalesLT.DemoTable
(ID INT IDENTITY(1,1),
Description Varchar(20),
CONSTRAINT [PK_DemoTable] PRIMARY KEY CLUSTERED(ID) 
)
GO

/* 10.1 Variables */

--Search by city using a variable
DECLARE @City VARCHAR(20)='Toronto'
Set @City='Bellevue'



Select FirstName +' '+LastName as [Name],AddressLine1 as Address,City
FROM SalesLT.Customer as C
JOIN SalesLT.CustomerAddress as CA
ON C.CustomerID=CA.CustomerID
JOIN SalesLT.Address as A
ON CA.AddressID=A.AddressID
WHERE City=@City

--Use a variable as an output
DECLARE @Result money
SELECT @Result=MAX(TotalDue)
FROM SalesLT.SalesOrderHeader

PRINT @Result

/* 10.2 If Else */

--Simple logical test
If 'Yes'='Yes'
Print 'True'

--Change code based on a condition
UPDATE SalesLT.Product
SET DiscontinuedDate=getdate()
WHERE ProductID=1;

IF @@ROWCOUNT<1
BEGIN
	PRINT 'Product was not found'
END
ELSE
BEGIN
	PRINT 'Product Updated'
END


/* 10.3 While */

DECLARE @Counter int=1

WHILE @Counter <=5

BEGIN
	INSERT SalesLT.DemoTable(Description)
	VALUES ('ROW '+CONVERT(varchar(5),@Counter))
	SET @Counter=@Counter+1
END

SELECT Description FROM SalesLT.DemoTable


--Testing for existing values
DECLARE @Counter int=1

DECLARE @Description int
SELECT @Description=MAX(ID)
FROM SalesLT.DemoTable

WHILE @Counter <5
BEGIN
	INSERT SalesLT.DemoTable(Description)
	VALUES ('ROW '+CONVERT(varchar(5),@Description))
	SET @Description=@Description+1
	SET @Counter=@Counter+1
END

SELECT Description FROM SalesLT.DemoTable

/* 10.4 Stored procedure */

-- Create a stored procedure
CREATE PROCEDURE SalesLT.GetProductsByCategory (@CategoryID INT = NULL)
AS
IF @CategoryID IS NULL
	SELECT ProductID, Name, Color, Size, ListPrice
	FROM SalesLT.Product
ELSE
	SELECT ProductID, Name, Color, Size, ListPrice
	FROM SalesLT.Product
	WHERE ProductCategoryID = @CategoryID;


-- Execute the procedure without a parameter
EXEC SalesLT.GetProductsByCategory

-- Execute the procedure with a parameter
EXEC SalesLT.GetProductsByCategory 6

/* 11.1 Raising errors */

-- View a system error
INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
VALUES
(100000, 1, 680, 1431.50, 0.00);





-- Raise an error with RAISERROR
UPDATE SalesLT.Product
SET DiscontinuedDate = GETDATE()
WHERE ProductID = 0;

IF @@ROWCOUNT < 1
	RAISERROR('The product was not found - no products have been updated', 16, 0);





-- Raise an error with THROW
UPDATE SalesLT.Product
SET DiscontinuedDate = GETDATE()
WHERE ProductID = 0;

IF @@ROWCOUNT < 1
	THROW 50001, 'The product was not found - no products have been updated', 0;

	/* 11.2 Handling Errors */

-- catch an error
BEGIN TRY
	UPDATE SalesLT.Product
	SET ProductNumber = ProductID / ISNULL(Weight, 0);
END TRY
BEGIN CATCH
	PRINT 'The following error occurred:';
	PRINT ERROR_MESSAGE();
END CATCH;

-- Catch and rethrow
BEGIN TRY
	UPDATE SalesLT.Product
	SET ProductNumber = ProductID / ISNULL(Weight, 0);
END TRY
BEGIN CATCH
	PRINT 'The following error occurred:';
	PRINT ERROR_MESSAGE();
	THROW;
END CATCH;

-- Catch, log, and throw a custom error
BEGIN TRY
	UPDATE SalesLT.Product
	SET ProductNumber = ProductID / ISNULL(Weight, 0);
END TRY
BEGIN CATCH
	DECLARE @ErrorLogID as int, @ErrorMsg AS varchar(250);
	EXECUTE dbo.uspLogError @ErrorLogID OUTPUT;
	SET @ErrorMsg = 'The update failed because of an error. View error #'
	                 + CAST(@ErrorLogID AS varchar)
					 + ' in the error log for details.';
	THROW 50001, @ErrorMsg, 0;
END CATCH;

-- View the error log
SELECT * FROM dbo.ErrorLog;

/* 11.3 Transactions */

-- No transaction
BEGIN TRY
	INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod)
	VALUES
	(DATEADD(dd, 7, GETDATE()), 1, 'STD DELIVERY');

	DECLARE @SalesOrderID int = SCOPE_IDENTITY();

	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
	VALUES
	(@SalesOrderID, 1, 99999, 1431.50, 0.00);
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH;

-- View orphaned orders
SELECT h.SalesOrderID, h.DueDate, h.CustomerID, h.ShipMethod, d.SalesOrderDetailID
FROM SalesLT.SalesOrderHeader AS h
LEFT JOIN SalesLT.SalesOrderDetail AS d
ON d.SalesOrderID = h.SalesOrderID
WHERE D.SalesOrderDetailID IS NULL;

-- Manually delete orphaned record
DELETE FROM SalesLT.SalesOrderHeader
WHERE SalesOrderID = SCOPE_IDENTITY();

-- Use a transaction
BEGIN TRY
  BEGIN TRANSACTION
	INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod)
	VALUES
	(DATEADD(dd, 7, GETDATE()), 1, 'STD DELIVERY');

	DECLARE @SalesOrderID int = SCOPE_IDENTITY();

	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
	VALUES
	(@SalesOrderID, 1, 99999, 1431.50, 0.00);
  COMMIT TRANSACTION
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0
  BEGIN
    PRINT XACT_STATE();
	ROLLBACK TRANSACTION;
  END
  PRINT ERROR_MESSAGE();
  THROW 50001,'An insert failed. The transaction was cancelled.', 0;
END CATCH;

-- Check for orphaned orders
SELECT h.SalesOrderID, h.DueDate, h.CustomerID, h.ShipMethod, d.SalesOrderDetailID
FROM SalesLT.SalesOrderHeader AS h
LEFT JOIN SalesLT.SalesOrderDetail AS d
ON d.SalesOrderID = h.SalesOrderID
WHERE D.SalesOrderDetailID IS NULL

-- Use XACT_ABORT
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRANSACTION
	INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod)
	VALUES
	(DATEADD(dd, 7, GETDATE()), 1, 'STD DELIVERY');

	DECLARE @SalesOrderID int = SCOPE_IDENTITY();

	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
	VALUES
	(@SalesOrderID, 1, 99999, 1431.50, 0.00);
  COMMIT TRANSACTION
END TRY
BEGIN CATCH
  PRINT ERROR_MESSAGE();
  THROW 50001,'An insert failed. The transaction was cancelled.', 0;
END CATCH;
SET XACT_ABORT OFF;

-- Check for orphaned orders
SELECT h.SalesOrderID, h.DueDate, h.CustomerID, h.ShipMethod, d.SalesOrderDetailID
FROM SalesLT.SalesOrderHeader AS h
LEFT JOIN SalesLT.SalesOrderDetail AS d
ON d.SalesOrderID = h.SalesOrderID
WHERE D.SalesOrderDetailID IS NULL

/* SQL Fundamentals Master */

/* 1. */

-- Unlock HR user account
ALTER USER hr IDENTIFIED BY hrpassword ACCOUNT UNLOCK;
ALTER USER oe IDENTIFIED BY oepassword ACCOUNT UNLOCK;

-- Using the SELECT Statement
SELECT * FROM jobs;

SELECT job_title, min_salary FROM jobs;

SELECT job_title AS Title,
min_salary AS "Minimum Salary" FROM jobs;

SELECT DISTINCT department_id FROM
employees;

SELECT DISTINCT department_id, job_id
FROM employees;

-- The DUAL table
SELECT * FROM dual;
SELECT SYSDATE, USER FROM dual;
SELECT 'I''m ' || user || ' Today is ' || SYSDATE FROM DUAL;

-- ***Limiting rows***
--Employees who work for dept 90
SELECT first_name || ' ' || last_name "Name",
department_id FROM employees
WHERE department_id = 90;

-- Comparison operators
-- !=, <>, ^= (Inequality)
SELECT first_name || ' ' || last_name "Name",
commission_pct FROM employees
WHERE commission_pct != .35;

-- < (Less than)
SELECT first_name || ' ' || last_name "Name",
commission_pct FROM employees
WHERE commission_pct < .15;

-- > (Greater than)
SELECT first_name || ' ' || last_name "Name",
commission_pct FROM employees
WHERE commission_pct != .35;

-- <= (Less than or equal to)
SELECT first_name || ' ' || last_name "Name",
commission_pct FROM employees
WHERE commission_pct <= .15;

-- >= (Greater than or equal to)
SELECT first_name || ' ' || last_name "Name",
commission_pct FROM employees
WHERE commission_pct >= .35;

-- ANY or SOME
SELECT first_name || ' ' || last_name "Name",
department_id FROM employees
WHERE department_id <= ANY (10, 15, 20, 25);

-- ALL
SELECT first_name || ' ' || last_name "Name",
department_id FROM employees
WHERE department_id >= ALL (80, 90, 100);

-- *For all the comparison operators discussed, if one side of the operator is NULL, the result is NULL.

-- NOT
SELECT first_name, department_id
FROM employees
WHERE not (department_id >= 30);

-- AND
SELECT first_name, salary
FROM employees
WHERE last_name = 'Smith'
AND salary > 7500;

-- OR
SELECT first_name, last_name
FROM employees
WHERE first_name = 'Kelly'
OR last_name = 'Smith';

-- *When a logical operator is applied to NULL, the result is UNKNOWN. UNKNOWN acts similarly to FALSE; the only difference is that NOT FALSE is TRUE, whereas NOT UNKNOWN is also UNKNOWN.

-- Other operators

-- IN and NOT IN
-- IN is equivalent to =ANY
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id IN (10, 20, 90);

--NOT IN is equivalent to !=ALL
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id NOT IN
(10, 30, 40, 50, 60, 80, 90, 110, 100);

-- *When using the NOT IN operator, if any value in the list or the result returned from the subquery is NULL, the NOT IN condition is evaluated to FALSE.

-- BETWEEN (is inclusive)
SELECT first_name, last_name, salary
FROM employees
WHERE salary BETWEEN 5000 AND 6000;

-- EXISTS
-- The EXISTS operator is always followed by a subquery in parentheses. EXISTS evaluates to
-- TRUE if the subquery returns at least one row. The following example lists the employees
-- who work for the administration department.
SELECT last_name, first_name, department_id
FROM employees e
WHERE EXISTS (select 1 FROM departments d
				WHERE d.department_id = e.department_id
				AND d.department_name = 'Administration');

-- IS NULL and IS NOT NULL
-- The = or != operator will not work with NULL values.

-- employees who do not have a department assigned
SELECT last_name, department_id
FROM employees
WHERE department_id IS NULL;

-- This doesn't work correctly
SELECT last_name, department_id
FROM employees
WHERE department_id = NULL;

-- LIKE
SELECT first_name, last_name
FROM employees
WHERE first_name LIKE 'Su%'
AND last_name NOT LIKE 'S%';

-- Escaping the _ character
SELECT job_id, job_title
FROM jobs
WHERE job_id like 'AC\_%' ESCAPE '\';  --'

-- ***Sorting rows

-- ASC is the default sorting
SELECT first_name || ' ' || last_name "Employee Name"
FROM employees
WHERE department_id = 90
ORDER BY last_name;

-- Multiple column sorting
SELECT first_name, hire_date, salary, manager_id mid
FROM employees
WHERE department_id IN (110,100)
ORDER BY mid ASC, salary DESC, hire_date;

-- *You can use column alias names in the ORDER BY clause.

-- If the DISTINCT keyword is used in the SELECT clause, you can use only those columns
-- listed in the SELECT clause in the ORDER BY clause. If you have used any operators on columns in
-- the SELECT clause, the ORDER BY clause also should use them.

-- Incorrect
SELECT DISTINCT 'Region ' || region_id
FROM countries
ORDER BY region_id;

-- Correct
SELECT DISTINCT 'Region ' || region_id
FROM countries
ORDER BY 'Region ' || region_id;

-- Sorting by column number
SELECT first_name, hire_date, salary, manager_id mid
FROM employees
WHERE department_id IN (110,100)
ORDER BY 4, 2, 3;

-- *The ORDER BY clause cannot have more than 255 columns or expressions.

-- ***Sorting NULLs
--By default, in an ascending-order sort, the NULL values appear at the bottom of the result set;
--that is, NULLs are sorted higher.

-- Nulls are sorted higher
SELECT last_name, commission_pct
FROM employees
WHERE last_name LIKE 'R%'
ORDER BY commission_pct ASC, last_name DESC;

-- Null first
SELECT last_name, commission_pct
FROM employees
WHERE last_name LIKE 'R%'
ORDER BY commission_pct ASC NULLS FIRST, last_name DESC;

-- *** The CASE expression

SELECT country_name, region_id,
		CASE region_id WHEN 1 THEN 'Europe'
									 WHEN 2 THEN 'America'
									 WHEN 3 THEN 'Asia'
									 ELSE 'Other' END Continent
FROM countries
WHERE country_name LIKE 'I%';

SELECT first_name, department_id, salary,
		CASE WHEN salary < 6000 THEN 'Low'
				 WHEN salary < 10000 THEN 'Medium'
				 WHEN salary >= 10000 THEN 'High' END Category
FROM employees
WHERE department_id <= 30
ORDER BY first_name;

-- *** Accepting values at runtime
SELECT department_name
FROM departments
WHERE department_id = &dept;

-- Execute in sql plus
DEFINE DEPT = 20
DEFINE DEPT
LIST
/

--A . (dot) is used to append characters immediately after the substitution variable.
SELECT job_id, job_title FROM jobs
WHERE job_id = '&JOB._REP';
/

--You can turn off the old/new display by using the command SET VERIFY OFF.
SELECT &COL1, &COL2
FROM &TABLE
WHERE &COL1 = '&VAL'
ORDER BY &COL2;

SAVE ex01
@ex01
-- FIRST_NAME, LAST_NAME, EMPLOYEES, FIRST_NAME, John, LAST_NAME

--To clear a defined variable, you can use the UNDEFINE command.

--Edit buffer
SELECT &&COL1, &&COL2
FROM &TABLE
WHERE &COL1 = �&VAL�
ORDER BY &COL2;

--** Using positional Notation for Variables
SELECT department_name, department_id
FROM departments
WHERE &1 = &2;
--department_id, 20

SAVE ex02
SET VERIFY OFF
@ex02 department_id 20

/* 2. */

/* Using Single-Row Functions */

--***Functions for NULL Handling

-- NVL(x1, x2)
/* The NVL function returns x2 if x1 is
NULL. If x1 is not NULL, then x1 is returned. */
SELECT last_name, NVL(department_id,0)
FROM employees
ORDER BY 2;

SELECT first_name, salary, commission_pct,
salary + (salary * commission_pct) compensation
FROM employees
WHERE first_name LIKE 'T%';

SELECT first_name, salary, commission_pct,
salary + (salary * NVL(commission_pct,0)) compensation
FROM employees
WHERE first_name LIKE 'T%';

-- NVL2(x1, x2, x3)
/* NVL2 returns x3 if x1 is NULL, and x2 if x1 is not NULL.*/
SELECT first_name, salary, commission_pct, NVL2(commission_pct,
salary + salary * commission_pct, salary) compensation
FROM employees
WHERE first_name LIKE 'T%';

-- COALESCE(exp_list)
/*COALESCE(x1, x2, x3) would be evaluated as the following:
If x1 is NULL, check x2, or else return x1. Stop.
If x2 is NULL, check x3, or else return x2. Stop.
If x3 is NULL, return NULL, or else return x3. Stop.*/

SELECT last_name, salary, commission_pct AS comm,
COALESCE(salary+salary*commission_pct,
salary+100, 900) compensation
FROM employees
WHERE last_name like 'T%';

-- Alternative to the last example using CASE
SELECT last_name, salary, commission_pct AS comm,
(CASE WHEN salary IS NULL THEN 900
	  WHEN commission_pct IS NOT NULL THEN salary+salary*commission_pct
	  WHEN commission_pct IS NULL THEN salary+100
      ELSE 0 END) AS compensation
FROM employees
WHERE last_name like 'T%';

--*** Using Single-Row Character Functions

-- ASCII(c1) 
/* This function returns
the ASCII decimal equivalent of the first character in c1.*/
SELECT ASCII('A') Big_A, ASCII('z') Little_Z, ASCII('AMER')
FROM dual;

-- CHR(i)
/* Returns the character equivalent of the decimal (binary) 
representation of the character*/
SELECT CHR(65), CHR(122), CHR(223)
FROM dual;

-- CONCAT(c1,c2)
/*This function returns c2 appended to c1. If c1 is NULL, 
then c2 is returned. If c2 is NULL, then c1 is 
returned. If both c1 and c2 are NULL, then NULL is returned.*/
SELECT CONCAT(CONCAT(first_name, ' '), last_name) employee_name,
first_name || ' ' || last_name AS alternate_method
FROM employees
WHERE department_id = 30;

-- INITCAP(c1)
/*This function returns
c1 with the first character of each word in uppercase 
and all others in lowercase.*/
SELECT 'prueba de initcap', INITCAP('prueba de initcap') 
FROM dual;

SELECT 'otra*prueba*initcap', INITCAP('otra*prueba*initcap') 
FROM dual;

-- INSTR(c1,c2[,i[,j]])
/* This function returns the numeric character position in c1 where the j
occurrence of c2 is found. The search begins at the i character position in c1. INSTR returns
a 0 when the requested string is not found. If i is negative, the search is performed backward,
from right to left, but the position is still counted from left to right. Both i and j
default to 1, and j cannot be negative. */

SELECT INSTR(3 + 0.14, '.') 
FROM dual;

SELECT INSTR(sysdate, 'DEC') 
FROM dual;

SELECT INSTR('1#3#5#7#9#', '#') 
FROM dual;

SELECT INSTR('1#3#5#7#9#', '#', 5) 
FROM dual;

SELECT INSTR('1#3#5#7#9#', '#', 3, 4) 
FROM dual;

SELECT * FROM departments
WHERE INSTR(department_name, 'on') = 2;

-- LENGTH(c)
/* This function returns the numeric length in characters of c. 
If c is NULL, a NULL is returned.*/

SELECT LENGTH(1 + 2.14 || ' approximates pi') 
FROM dual;

SELECT LENGTH(SYSDATE) 
FROM dual;

SELECT * FROM countries
WHERE LENGTH(country_name) > 10;

-- LOWER(c)
/* This function returns the character string c with all 
characters in lowercase. */
SELECT LOWER('Hola mundo') 
FROM dual;

SELECT LOWER(100 + 100) 
FROM dual;

SELECT LOWER('The SUM ' || '100+100' || ' = 200') 
FROM dual;

SELECT LOWER(SYSDATE) 
FROM dual;

SELECT LOWER(SYSDATE + 2) 
FROM dual;

SELECT first_name, last_name, LOWER(last_name)
FROM employees
WHERE LOWER(last_name) LIKE '%ur%';

-- LPAD(c1, i [,c2])
/* This function returns the character string c1 expanded in length to i characters,
using c2 to fill in space as needed on the left side of c1. If c1 is more than i characters, it is
truncated to i characters. c2 defaults to a single space */

SELECT LPAD(1000 + 200.55, 14, '*') 
FROM dual;

SELECT LPAD(SYSDATE, 14, '$#') 
FROM dual;

SELECT LPAD(last_name, 10) lpad_lname,
	   LPAD(salary, 8, '*') lpad_salary
FROM employees
WHERE last_name like 'J%';

-- RPAD(c1, i [, c2])
/* This function returns the character string c1 expanded in length to i characters,
using c2 to fill in space as needed on the right side of c1. If c1 is more than i characters, it
is truncated to i characters. c2 defaults to a single space.*/

SELECT RPAD(1000 + 200.55, 14, '*')
FROM dual;

SELECT RPAD(SYSDATE, 4, '$#')
FROM dual;

SELECT RPAD(first_name, 15, '.') rpad_fname, LPAD(job_id, 12, '.') lpad_jid
FROM employees
WHERE first_name LIKE 'B%';

-- REPLACE(c1, c2 [,c3])
/* This function returns c1 with all occurrences of c2 replaced with c3. c3 defaults to NULL. If
c3 is NULL, all occurrences of c2 are removed. If c2 is NULL, then c1 is returned unchanged.
If c1 is NULL, then NULL is returned. */

SELECT REPLACE('uptown', 'up', 'down') 
FROM dual;

SELECT REPLACE(10000-3, '9', '85') 
FROM dual;

SELECT REPLACE(SYSDATE, '01', '08') 
FROM dual

SELECT last_name, salary, REPLACE(salary, '0', '000') "Dream salary"
FROM employees
WHERE job_id = 'SA_MAN';

-- SUBSTR(c1, x [, y])
/* This function returns the portion of c1 that is y characters long, beginning
at position x. If x is negative, the position is counted backward (that is, right to left). This
function returns NULL if y is 0 or negative. y defaults to the remainder of string c1. */

SELECT SUBSTR(10000-3, 3, 2)
FROM dual;

SELECT SUBSTR(SYSDATE, 4, 3)
FROM dual;

SELECT SUBSTR('1#3#5#7#9#', 5)
FROM dual;

SELECT SUBSTR('1#3#5#7#9#', 5, 6)
FROM dual;

SELECT SUBSTR('1#3#5#7#9#', -3, 2)
FROM dual;

SELECT 'Advertising Team Member' || SUBSTR(first_name, 1, 1)
|| '. ' || last_name "Name"
FROM employees
WHERE SUBSTR(job_id, 1, 2) = 'AD';

-- Execute as sys
-- extract only the filename from dba_data_files without the path name
SELECT file_name, 
	   SUBSTR(file_name, INSTR(file_name,'\', -1,1)+1) name --'
FROM dba_data_files;

-- TRIM([[c1] c2 FROM ] c3)
/* If present, c1 can be one of the following literals: LEADING, TRAILING, or BOTH. This function
returns c3 with all c1 (leading, trailing, or both) occurrences of characters in c2 removed.
A NULL is returned if any of c1, c2, or c3 is NULL. c1 defaults to BOTH. c2 defaults to a space
character. c3 is the only mandatory argument. If c2or c3 is NULL, the function returns a NULL.*/

SELECT TRIM('   fully padded   ') test1,
	   TRIM('   left padded') test2,
	   TRIM('right padded   ') test3
FROM dual;

SELECT TRIM(TRAILING 'e' from 1+2.14||' is pie') 
FROM dual;

SELECT TRIM(BOTH '*' from '*******Hidden*******') 
FROM dual;

-- UPPER(c)
/* This function returns
the character string c with all characters in uppercase.*/

SELECT UPPER(1+2.14) 
FROM dual;

SELECT UPPER(SYSDATE) 
FROM dual;

SELECT * FROM countries
WHERE UPPER(country_name) LIKE '%U%S%A%';

-----------------------------------------------------------------------------------------
--*** Using Single-Row Numeric Functions
-- Most important are ROUND, TRUNC and MOD

-- ABS(n)
/*This function returns the absolute value of n.*/
SELECT ABS(-52) negative, ABS(52) positive
FROM dual;

-- ACOS(n)
/*This function returns the arc cosine of n expressed in radians*/
SELECT ACOS(-1) PI, ACOS(0) ACOSZERO,
	   ACOS(.045) ACOS045, ACOS(1) ZERO
FROM dual;

-- ASIN(n) 
/* This function returns the arc sine of n expressed in radians*/
SELECT ASIN(1) high, ASIN(0) middle, ASIN(-1) low
FROM dual;

-- ATAN(n)
/*This function returns the arc tangent of n expressed in radians*/
SELECT ATAN(9E99) high, ATAN(0) middle, ATAN(-9E99) low
FROM dual;

-- ATAN2(n1, n2)
/*This function returns the arc tangent of n1 and n2 expressed in radians*/
SELECT ATAN2(9E99,1) high, ATAN2(0,3.1415) middle, ATAN2(-9E99,1) low
FROM dual;

-- BITAND(n1, n2)
/*This function performs a bitwise AND operation 
on the two input values and returns the results, also an integer*/
SELECT BITAND(6,3) T1, BITAND(8,2) T2
FROM dual;

-- CEIL(n)
/* This function returns the smallest integer that is greater than or equal to n.*/
SELECT CEIL(9.8), CEIL(-32.85), CEIL(0), CEIL(5)
FROM dual;

-- COS(n)
/* This function returns the cosine of n*/
SELECT COS(-3.14159) FROM dual;

-- COSH(n)
/* This function returns the hyperbolic cosine of n */
SELECT COSH(1.4) FROM dual;

-- EXP(n)
/* This function returns e (the base of natural logarithms) raised to the n power*/
SELECT EXP(1) "e" FROM dual;

-- FLOOR(n)
/* This function returns the largest integer that is less than or equal to n*/
SELECT FLOOR(9.8), FLOOR(-32.85), FLOOR(137)
FROM dual;

-- LN(n)
/* This function returns the natural logarithm of n*/
SELECT LN(2.7) FROM dual;

-- LOG(n1, n2)
/* This function returns the logarithm base n1 of n2*/
SELECT LOG(8,64), LOG(3,27), LOG(2,1024), LOG(2,8)
FROM dual;

---- MOD(n1, n2)
/* This function returns n1 modulo n2, or the remainder of n1 divided by n2. If n1 is negative, the result
is negative. The sign of n2 has no effect on the result. If n2 is zero, the result is n1.*/
SELECT MOD(14,5), MOD(8,2.5), MOD(-64,7), MOD(12,0)
FROM dual;

-- POWER(n1, n2)
/* This function returns n1 to the n2 power*/
SELECT POWER(2,10), POWER(3,3), POWER(5,3), POWER(2,-3)
FROM dual;

-- REMAINDER(n1, n2)
/* This function returns the remainder of n1 divided by n2. If n1 is negative, the result is negative.
The sign of n2 has no effect on the result. If n2 is zero and the datatype of n1 is NUMBER,
an error is returned; if the datatype of n1 is BINARY_FLOAT or BINARY_DOUBLE,
NaNis returned. */
SELECT REMAINDER(13,5), REMAINDER(12,5), REMAINDER(12.5, 5)
FROM dual;

SELECT REMAINDER(TO_BINARY_FLOAT(�13.0�), 0) RBF
FROM dual;

/* The difference between MOD and REMAINDER is that MOD uses the FLOOR function, whereas
REMAINDER uses the ROUND function in the formula. */
SELECT MOD(13,5), MOD(12,5), MOD(12.5, 5)
FROM dual;

----- ROUND(n1 [,n2])
/* This function returns n1 rounded to n2 digits of precision to the right of the decimal. If n2
is negative, n1 is rounded to the left of the decimal. If n2 is omitted, the default is zero. */
SELECT ROUND(123.489), ROUND(123.489, 2),
	   ROUND(123.489, -2), ROUND(1275, -2)
FROM dual;

-- SIGN(n)
/* This function returns �1 if n is negative, 1 if n is positive, and 0 if n is 0. */  
SELECT SIGN(-2.3), SIGN(0), SIGN(47)
FROM dual;

-- SIN(n)
/* This function returns the sine of n */
SELECT SIN(1.57079) FROM dual;

-- SINH(n)
/* This function returns the hyperbolic sine of n*/
SELECT SINH(1) FROM dual;

-- SQRT(n)
/* This function returns the square root of n*/
SELECT SQRT(64), SQRT(49), SQRT(5)
FROM dual;

-- TAN(n)
/* This function returns the tangent of n*/
SELECT TAN(1.57079633/2) "45_degrees"
FROM dual;

-- TANH(n)
/* This function returns the hyperbolic tangent of n */
SELECT TANH( ACOS(-1) ) hyp_tan_of_pi
FROM dual;

----- TRUNC(n1 [,n2])
/* This function returns n1 truncated to n2 digits of precision to the right of the decimal. If n2
is negative, n1 is truncated to the left of the decimal.*/
SELECT TRUNC(123.489), TRUNC(123.489, 2),
	   TRUNC(123.489, -2), TRUNC(1275, -2)
FROM dual;

-- WIDTH_BUCKET(n1, min_val, max_val, buckets)
/* This function builds histograms of equal
width. The first argument n1 can be an expression of a numeric or datetime datatype. The
second and third arguments, min_val and max_val, indicate the end points for the histogram�s
range. The fourth argument, buckets, indicates the number of buckets./

/* The following example divides the salary into a 10-bucket histogram within the range
2,500 to 11,000. If the salary falls below 2500, it will be in the underflow bucket (bucket 0),
and if the salary exceeds 11,000, it will be in the overflow bucket (buckets + 1). */
SELECT first_name, salary,
	WIDTH_BUCKET(salary, 2500, 11000, 10) hist
FROM employees
WHERE first_name like 'J%';

-----------------------------------------------------------------------------------------
--*** Using Single-Row Date Functions
--Most important are ADD_MONTHS, MONTHS_BETWEEN, LAST_DAY, NEXT_DAY, 
--ROUND, and TRUNC

-- Date-Format Conversion
SELECT SYSDATE FROM dual;
ALTER SESSION SET NLS_DATE_FORMAT='DD-Mon-YYYY HH24:MI:SS';

-- SYSDATE
/* returns the current date and time to the second for the
operating-system host where the database resides. The value is returned in a DATE datatype. */
SELECT SYSDATE FROM dual;

-- SYSTIMESTAMP
/* returns a TIMESTAMP WITH TIME ZONE for
the current database date and time (the time of the host server where the database resides)*/
SELECT SYSDATE, SYSTIMESTAMP FROM dual;

-- LOCALTIMESTAMP([p])
/* returns the current date and time in the session�s time zone to p digits
of precision. p can be 0 to 9 and defaults to 6. */
SELECT SYSTIMESTAMP, LOCALTIMESTAMP FROM dual;

----- ADD_MONTHS(d, i)
/* This function returns the date d plus i months. */
SELECT SYSDATE, ADD_MONTHS(SYSDATE, -1) PREV_MONTH,
		ADD_MONTHS(SYSDATE, 12) NEXT_YEAR
FROM dual;

-- CURRENT_DATE
/* returns the current date in the Gregorian calendar for the session�s (client) time zone.*/
ALTER SESSION SET NLS_DATE_FORMAT='DD-Mon-YYYY HH24:MI:SS';
SELECT SYSDATE, CURRENT_DATE FROM dual;

ALTER SESSION SET TIME_ZONE = 'US/Eastern';
SELECT SYSDATE, CURRENT_DATE FROM dual;

-- CURRENT_TIMESTAMP([p])
/* returns the current date and time in the session�s time zone to p digits
of precision. p can be an integer 0 through 9 and defaults to 6 */
SELECT CURRENT_DATE, CURRENT_TIMESTAMP FROM dual;

-- DBTIMEZONE
/* returns the database�s time zone, as set by the latest CREATE DATABASE or ALTER
DATABASE SET TIME_ZONE statement */
SELECT DBTIMEZONE FROM dual;

-- EXTRACT(c FROM dt)
/* extracts and returns the specified component c of date/time or interval
expression dt. The valid components are YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, TIMEZONE_
HOUR, TIMEZONE_MINUTE, TIMEZONE_REGION, and TIMEZONE_ABBR. */
SELECT SYSDATE, EXTRACT(YEAR FROM SYSDATE) year_d
FROM dual;

SELECT LOCALTIMESTAMP,
		EXTRACT(YEAR FROM LOCALTIMESTAMP) YEAR_TS,
		EXTRACT(DAY FROM LOCALTIMESTAMP) DAY_TS,
		EXTRACT(SECOND FROM LOCALTIMESTAMP) SECOND_TS
FROM dual;

-- FROM_TZ(ts, tz)
/* returns a TIMESTAMP WITH TIME ZONE for the timestamp ts using
time zone value tz. */
SELECT LOCALTIMESTAMP, FROM_TZ(LOCALTIMESTAMP, 'Japan') Japan,
FROM_TZ(LOCALTIMESTAMP, '-5:00') Central
FROM dual;

----- LAST_DAY(d)
/* This function returns the last day
of the month for the date d. The return datatype is DATE. */
SELECT SYSDATE,
		LAST_DAY(SYSDATE) END_OF_MONTH,
		LAST_DAY(SYSDATE) + 1 NEXT_MONTH
FROM dual;

----- MONTHS_BETWEEN(d1, d2)
/* This function returns the number of months that d2 is later than d1.*/
SELECT MONTHS_BETWEEN('31-MAR-08', '30-SEP-08') E1,
	   MONTHS_BETWEEN('11-MAR-08', '30-SEP-08') E2,
	   MONTHS_BETWEEN('01-MAR-08', '30-SEP-08') E3,
	   MONTHS_BETWEEN('31-MAR-08', '30-SEP-07') E4
FROM dual;

-- NEW_TIME(d>, tz1, tz2)
/* This function returns the date in time zone tz2 for date d in
time zone tz1. */
SELECT SYSDATE Dallas, NEW_TIME(SYSDATE, 'CDT', 'HDT') Hawaii
FROM dual;

----- NEXT_DAY(d, dow) dow is a text string containing the full or abbreviated day of the week
/* This function returns the next dow following d.*/
SELECT SYSDATE, NEXT_DAY(SYSDATE,'Thu') NEXT_THU,
NEXT_DAY('31-OCT-2008', 'Tue') Election_Day
FROM dual;

----- ROUND(<d> [,fmt])
/* This function returns d rounded to the granularity specified
in fmt. If fmt is omitted, d is rounded to the nearest day. */
SELECT SYSDATE, ROUND(SYSDATE, 'HH24') ROUND_HOUR,
	ROUND(SYSDATE) ROUND_DATE, ROUND(SYSDATE, 'MM') NEW_MONTH,
	ROUND(SYSDATE, 'YY') NEW_YEAR
FROM dual;

-- SESSIONTIMEZONE
/* returns the database�s time zone offset as per
the last ALTER SESSION statement. SESSIONTIMEZONE will default to DBTIMEZONE if it is not
changed with an ALTER SESSION statement. */
SELECT DBTIMEZONE, SESSIONTIMEZONE
FROM dual;

-- SYS_EXTRACT_UTC(ts)
/* This function returns the UTC (GMT) time for the timestamp ts. */
SELECT CURRENT_TIMESTAMP local,
SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) GMT
FROM dual;

----- TRUNC(d [,fmt])
/* This function returns d truncated to the granularity specified
in fmt. */
SELECT SYSDATE, TRUNC(SYSDATE, 'HH24') CURR_HOUR,
TRUNC(SYSDATE) CURR_DATE, TRUNC(SYSDATE, 'MM') CURR_MONTH,
TRUNC(SYSDATE, 'YY') CURR_YEAR
FROM dual;

-- TZ_OFFSET(tz)
/* This function returns the numeric time zone offset for a textual time zone name. */
SELECT TZ_OFFSET(SESSIONTIMEZONE) NEW_YORK,
TZ_OFFSET('US/Pacific') LOS_ANGELES,
TZ_OFFSET('Europe/London') LONDON,
TZ_OFFSET('Asia/Singapore') SINGAPORE
FROM dual;

-----------------------------------------------------------------------------------------
--*** Using Single-Row Conversion Functions

-- Implicit conversion functions

SELECT LENGTH(1234567890) 
FROM dual;

SELECT LENGTH(SYSDATE) 
FROM dual;

SELECT mod('11',2) 
FROM dual;

SELECT mod('11.123',2) 
FROM dual;

SELECT mod('11.123.456',2) 
FROM dual;

SELECT mod('$11',2) 
FROM dual;

-- ASCIISTR(c1)
/* This function returns
the ASCII equivalent of all the characters in c1. This function leaves ASCII characters
unchanged, but non-ASCII characters are returned in the format \xxxx where xxxx represents
a UTF-16 code unit. */
SELECT ASCIISTR('ca�on') E1, ASCIISTR('fa�') E2
FROM dual;

-- BIN_TO_NUM(b), b is a comma-delimited list of bits
/* This function returns the numeric representation of all the bit-field set b. It essentially converts a
base 2 number into a base 10 number */
SELECT BIN_TO_NUM(1,1,0,1) bitfield1,
	   BIN_TO_NUM(0,0,0,1) bitfield2,
	   BIN_TO_NUM(1,1) bitfield3
FROM dual;

-- CAST(exp AS t)
/* This function converts the expression exp into the datatype t */
SELECT CAST(SYSDATE AS TIMESTAMP WITH LOCAL TIME ZONE) DT_2_TS
FROM dual;

-- CHARTOROWID(c)
/* This function returns c as a ROWID datatype. */
/*Each row in the database is uniquely identified by a ROWID. ROWID shows
the physical location of the row stored in the database.*/
SELECT rowid, first_name
FROM employees
WHERE first_name = 'Sarath';

SELECT first_name, last_name
FROM employees
WHERE rowid = CHARTOROWID('AAARAgAAFAAAABYAA9');

-- CONVERT(c, dset [,sset]) dset and sset are character-set names
/* This function returns the character string c converted
from the source character set sset to the destination character set dset */
SELECT CONVERT('vis-�-vis', 'AL16UTF16', 'AL32UTF8')
FROM dual;

-- NUMTODSINTERVAL(x , c)
/* This function converts the number x into an INTERVAL
DAY TO SECOND datatype. */
SELECT SYSDATE,
		SYSDATE + NUMTODSINTERVAL(2, 'HOUR') "2 hours later",
		SYSDATE + NUMTODSINTERVAL(30, 'MINUTE') "30 minutes later"
FROM dual;

-- NUMTOYMINTERVAL(x , c)
/* This function converts the number x into an INTERVAL
YEAR TO MONTH datatype. */
SELECT SYSDATE,
		SYSDATE+NUMTOYMINTERVAL(2,�YEAR�) "2 years later",
		SYSDATE+NUMTOYMINTERVAL(5,�MONTH�) "5 months later"
FROM dual;

-- ROWIDTOCHAR(c)
/* This function returns the ROWID string c converted to a VARCHAR2 datatype.
No translation is performed; only the datatype is changed */
SELECT ROWIDTOCHAR(ROWID) Char_RowID, first_name
FROM employees
WHERE first_name = 'Sarath';

-- SCN_TO_TIMESTAMP (n)
/* This function returns the timestamp associated with the SCN. 
An SCN is a number that gets incremented when a commit occurs in the database. The
SCN identifies the state of the database uniquely */
SELECT SCN_TO_TIMESTAMP(ORA_ROWSCN) mod_time, last_name
FROM employees
WHERE first_name = 'Lex';

-- TIMESTAMP_TO_SCN (<ts>)
/* identify the SCN associated with a particular timestamp. */
SELECT TIMESTAMP_TO_SCN('14-JAN-14 09.52.20') DB_SCN
FROM dual;

-- TO_BINARY_DOUBLE(<expr> [,<fmt> [,<nlsparm>] ])
/* where expr is
a character or numeric string, fmt is a format string specifying the format that c appears in,
and nlsparm specifies language- or location-formatting conventions */
/* This function returns a binary double-precision floating-point number 
of datatype BINARY_DOUBLE represented by expr. */
SELECT TO_BINARY_DOUBLE('1234.5678','999999.9999') CHR_FMT_DOUBLE,
TO_BINARY_DOUBLE('1234.5678') CHR_DOUBLE,
TO_BINARY_DOUBLE(1234.5678) NUM_DOUBLE,
TO_BINARY_DOUBLE('INF') INF_DOUBLE
FROM dual;

-- TO_BINARY_FLOAT(<expr> [,<fmt> [,<nlsparm>] ])
/* This function returns a binary single-precision floating-point 
number of datatype BINARY_FLOAT represented by expr. */
SELECT TO_BINARY_FLOAT('1234.5678','999999.9999') CHR_FMT_FLOAT,
		TO_BINARY_FLOAT('1234.5678') CHR_FLOAT,
		TO_BINARY_FLOAT(1234.5678) NUM_FLOAT,
		TO_BINARY_FLOAT('INF') INF_FLOAT
FROM dual;

/* NOTE: Converting from a character or NUMBER to BINARY_FLOAT and BINARY_
DOUBLE may not be exact since BINARY_FLOAT and BINARY_DOUBLE
use binary precision, whereas NUMBER uses decimal precision*/


----- TO_CHAR(<expr> [,<fmt >[,<nlsparm>] ])
/* This function returns expr converted into a character string (the VARCHAR2 datatype) */
SELECT TO_CHAR(00001) 
FROM dual;

SELECT TO_CHAR(00001,'0999999')
FROM dual;

SELECT job_title, max_salary, TO_CHAR(max_salary, '$99,999.99'),
	TO_CHAR(max_salary, '$9,999.99')
FROM jobs
WHERE UPPER(job_title) LIKE '%PRESIDENT%';

SELECT TO_CHAR(SYSDATE)
FROM dual;

SELECT TO_CHAR(SYSDATE,'Month')
FROM dual;

SELECT last_name, TO_CHAR(hire_date, 'fmDD Month YYYY') "Hire Date"
FROM employees;

SELECT TO_CHAR(SYSDATE,'Day Ddspth,Month YYYY'
 	,'NLS_DATE_LANGUAGE=German') Today_Heute
FROM dual;

SELECT TO_CHAR(SYSDATE ,'"On the "Ddspth" day of "Month, YYYY') Today
FROM dual;

/* For any of the numeric codes, the ordinal and/or spelled-out representation can be displayed
with the modifier codes th (for ordinal) and sp (for spelled out). Here is an example: */
SELECT SYSDATE,
		TO_CHAR(SYSDATE,'Mmspth') Month,
		TO_CHAR(SYSDATE,'DDth') Day,
		TO_CHAR(SYSDATE,'Yyyysp') Year
FROM dual;

/* Excercise 
Assuming SYSDATE is 23/01/2015 generate the following formats 
23-01-15                    
twenty-three january two thousand fifteen                         
JAN 23, 2015                    
january twenty-third, fifteenth           
TWENTY FIFTEEN JANUARY FRIDAY 23

SELECT TO_CHAR(SYSDATE, 'DD-MM-YY') FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'fmddsp month yyyysp') FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'fmMON DD, YYYY') FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'fmmonth ddthsp, yyspth') FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'YEAR fmMONTH DAY DD') FROM DUAL;*/

----- TO_DATE(<c> [,<fmt> [,<nlsparm>] ])
/* This function returns c converted into the DATE datatype. */
ALTER SESSION SET nls_date_format = 'DD-MON-RR HH24:MI:SS';

SELECT TO_DATE('25-DEC-2010')
FROM dual;

SELECT TO_DATE('25-DEC')
FROM dual;

SELECT TO_DATE('25-DEC', 'DD-MON')
FROM dual;

SELECT TO_DATE('25-DEC-2010 18:03:45', 'DD-MON-YYYY HH24:MI:SS')
FROM dual;

SELECT TO_DATE('25-DEC-10', 'fxDD-MON-YYYY')
FROM dual; 

SELECT TO_DATE('30-SEP-2007', 'DD/MON/YY')
FROM dual;

SELECT TO_DATE('SEP-2007 13', 'MON/YYYY HH24')
FROM dual;

SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date > TO_DATE('01/12/2000', 'MM/DD/YYYY')
ORDER BY hire_date;

--** Converting Numbers to Words
SELECT TO_CHAR(TO_DATE(&NUM, 'J'), 'jsp') num_to_spell
FROM dual;

-- TO_DSINTERVAL(<c> [,<nlsparm>])
/* This function returns c converted into an INTERVAL DAY TO SECOND */
SELECT SYSDATE,
		SYSDATE+TO_DSINTERVAL('007 12:00:00') "+7 1/2 days",
		SYSDATE+TO_DSINTERVAL('030 00:00:00') "+30 days"
FROM dual;

----- TO_NUMBER(<expr> [,<fmt> [,<nlsparm>] ])
/* This function returns the numeric value represented by expr. */

SELECT TO_NUMBER('$1,000.55') -- Invalid because $
FROM dual;

SELECT TO_NUMBER('$1,000.55','$999,999.99') 
FROM dual;

SELECT TO_NUMBER('234.89'), TO_NUMBER(1E-3) 
FROM dual;

-- TO_TIMESTAMP(<c> [,<fmt> [,<nlsparm>] ])
/* The return value is of the TIMESTAMP datatype. */
SELECT TO_TIMESTAMP('30-SEP-2007 08:51:23.456',
'DD-MON-YYYY HH24:MI:SS.FF')
FROM dual;

-- TO_TIMESTAMP(<c> [,<fmt> [,<nlsparm>] ])
/* The return datatype is TIMESTAMP WITH TIME ZONE. */
SELECT TO_TIMESTAMP_TZ('30-SEP-2007 08:51:23.456',
		'DD-MON-YYYY HH24:MI:SS.FF') TS_TZ_Example
FROM dual;

-- TO_YMINTERVAL(<c>)
/* This function returns c converted into an INTERVAL YEAR TO MONTH datatype. */
SELECT SYSDATE,
SYSDATE+TO_YMINTERVAL('01-03') "+15 months",
SYSDATE-TO_YMINTERVAL('00-03') "-3 months"
FROM dual;

-- UNISTR(<c>)
/* This function returns c in Unicode in the database Unicode character set. */
SELECT UNISTR('\00A3'), UNISTR('\00F1'), UNISTR('ca\00F1on')
FROM dual;

-----------------------------------------------------------------------------------------
--*** Function nesting
SELECT LENGTH(TO_CHAR(TO_DATE('28/10/09', 'DD/MM/RR'),'fmMonth'))
FROM dual;

--*** Other functions

----- DECODE(x ,m1, r1 [,m2 ,r2]�[,d])
/* x is an expression. m1
is a matching expression to compare with x. If m1 is equivalent to x, then r1 is returned;
otherwise, additional matching expressions (m2, m3, m4, and so on) are compared, if they
are included, and the corresponding result (r2, r3, r4, and so on) is returned. If no match is
found and the default expression d is included, then d is returned.*/
SELECT country_id, country_name, region_id,
		DECODE(region_id, 1, 'Europe',
						  2, 'Americas',
						  3, 'Asia',
							 'Other') Region
FROM countries
WHERE SUBSTR(country_id,1,1) = 'I'
		OR SUBSTR(country_id,2,1) = 'R';

-- GREATEST(exp_list)
/* This function returns the expression that sorts highest in the 
datatype of the first expression. */
SELECT GREATEST('01-ARP-08','30-DEC-01','12-SEP-09')
FROM dual;

-- SELECT GREATEST(345, �XYZ�, 2354) FROM dual; -- Error
SELECT GREATEST('XYZ', 345, 2354) FROM dual;

-- LEAST(exp_list)
/* This function returns the expression that sorts lowest in the 
datatype of the first expression */
SELECT LEAST(SYSDATE,'15-MAR-2002','17-JUN-2002') oldest
FROM dual;

/* The following SQL is used to calculate a bonus of 15 percent of salary to employees,
with a maximum bonus at 500 and a minimum bonus at 400: */
SELECT last_name, salary, GREATEST(LEAST(salary*0.15, 500), 400) bonus
FROM employees
WHERE department_id IN (30, 10)
ORDER BY last_name;

/* To remember the comparison rules for trailing and leading space in character
literals, think �leading equals least.� */

----- NULLIF(x1 , x2)
/* This function returns NULL if x1 equals x2; otherwise, 
it returns x1. If x1 is NULL, NULLIF returns NULL. */
SELECT ename, mgr, comm
		NULLIF(comm,0) test1,
		NULLIF(0,comm) test2,
		NULLIF(mgr,comm) test3
FROM scott.emp
WHERE empno IN (7844,7839,7654,7369);

-- SYS_GUID()
/* GUID() returns a 32-bit hexadecimal representation of the 16-byte RAW value. */
SELECT SYS_GUID() FROM DUAL;

-- UID
/* returns the integer user ID for the current user connected to
the session. */
SELECT username, account_status
FROM dba_users
WHERE user_id = UID;

-- USER
/* returns a character string containing the username for the
current user.*/
SELECT default_tablespace, temporary_tablespace
FROM dba_users
WHERE username = USER;

/* 3. */ 

/***** USING GROUP FUNCTIONS******/
/* 	Group functions do not consider NULL values, 
except the COUNT(*) and GROUPING functions. */

/*	Most of the group functions can be applied either 
to ALL values or to only the DISTINCT values for the specified expression.*/

--*** COUNT({*|[DISTINCT|ALL ] expr});
/* The execution of COUNT on a column or an expression returns an integer value
that represents the number of rows in the group. */

-- counts the rows in the EMPLOYEES table
SELECT COUNT(*) 
FROM employees;

-- counts the rows with nonnull COMMISSION_PCT values
SELECT COUNT(commission_pct) 
FROM employees;

-- considers the nonnull rows and deterMINes the number of unique values
SELECT COUNT(DISTINCT commission_pct) 
FROM employees;

-- return the nonnull hire_date count, and manager id_count
SELECT COUNT(hire_date), COUNT(manager_id) 
FROM employees;

/* There are 107 employee records in the EMPLOYEES
table. These 107 employees are allocated to 12 departments, including null
departments, and work in 19 unique jobs.*/
SELECT COUNT(*),
	   COUNT(DISTINCT NVL(department_id, 0)),
	   COUNT(DISTINCT NVL(job_id, 0))
FROM employees;	 

--*** SUM([DISTINCT|ALL ] expr);
/* The aggregated total of a column or an expression is computed with the SUM
function. */

-- adds the number 2 across 107 rows
SELECT sum(2) 
FROM employees;

-- takes the SALARY column value for every row in the group
SELECT sum(salary) 
FROM employees;

-- only adds unique values in the column
SELECT sum(distinct salary) 
FROM employees;

-- sum of nonnull commission_pct
SELECT sum(commission_pct) 
FROM employees;

SELECT SUM(SYSDATE - hire_date) / 365.25 "Total years worked by all"
FROM employees;

-- error, sum expects NUMBER
SELECT SUM(hire_date)
FROM employees;

--*** AVG([DISTINCT|ALL ] expr);
/* The average value of a column or expression divides the sum by the number of
nonnull rows in the group. */

-- Numeric literals submitted to the AVG function are returned unchanged
SELECT AVG(5) 
FROM employees;

SELECT AVG(salary) 
FROM employees;

SELECT AVG(DISTINCT salary) 
FROM employees;

SELECT AVG(commission_pct) 
FROM employees;

SELECT last_name, job_id, (SYSDATE - hire_date) / 365.25 "Years worked"
FROM employees
WHERE job_id = 'IT_PROG';

SELECT AVG((SYSDATE - hire_date) / 365.25) "Avg years worked IT members"
FROM employees
WHERE job_id = 'IT_PROG';

--*** MAX([DISTINCT|ALL] expr); MIN([DISTINCT|ALL] expr)
/* The MAX and MIN functions operate on NUMBER, DATE, CHAR, and
VARCHAR2 data types. They return a value of the same data type as their input
arguments, which are either the largest or smallest items in the group. */

SELECT MIN(commission_pct), MAX(commission_pct)
FROM employees;

SELECT MIN(start_date),MAX(end_date)
FROM job_history;

SELECT MIN(job_id),MAX(job_id) 
FROM employees;

SELECT MIN(hire_date), MIN(salary), MAX(hire_date), MAX(salary)
FROM employees
WHERE job_id = 'SA_REP';

/* Excercise
You are required to calculate the average length of all the 
country names. Any fractional components must be rounded to 
the nearest whole number.*/
SELECT ROUND(AVG(LENGTH(country_name))) AVG_COUNTRY_NAME_LENGTH
FROM countries;

--*** Nested Group Functions
-- Group functions may only be nested two levels deep.

SELECT SUM(commission_pct), NVL(department_id, 0)
FROM employees
WHERE NVL(department_id, 0) IN (40, 80, 0)
GROUP BY department_id;

SELECT AVG(SUM(commission_pct))
FROM employees
WHERE NVL(department_id, 0) IN (40, 80, 0)
GROUP BY department_id;

--*** GROUP BY Clause

-- Count of employees per department
SELECT department_id, COUNT(*) "#Employees"
FROM employees
GROUP BY department_id;

-- Average of salary per department
SELECT AVG(salary), department_id
FROM employees
GROUP BY department_id;

-- Number of employees per manager
SELECT COUNT(*), manager_id
FROM employees
GROUP BY manager_id
ORDER BY 1 DESC, 2 NULLS LAST;

-- Max salary and count of employees per department
SELECT MAX(salary), COUNT(*)
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- Number of countries per region
SELECT COUNT(*), region_id
FROM countries
GROUP BY region_id;

-- Employees per year of quitting
-- Group by can have grouping expressions, not only columns
SELECT TO_CHAR(END_DATE, 'YYYY') "Year",
	COUNT(*) "Employees"
FROM job_history
GROUP BY TO_CHAR(END_DATE, 'YYYY')
ORDER BY COUNT(*) DESC;

-- Common errors

-- fails to add the group by clause
SELECT end_date, COUNT(*)
FROM job_history;

-- start_date must be in the group by clause
SELECT end_date, start_date, COUNT(*)
FROM job_history
GROUP BY end_date;

-- Group by cannot use ordinal column notation
SELECT department_id, COUNT(*) �#Employees�
FROM employees
GROUP BY 1;

-- Group by cannot use column alias notation
SELECT department_id di, COUNT(*) emp_cnt
FROM employees
GROUP BY di;

-- Group by cannot appear within Where clause
SELECT department_id, COUNT(*) emp_cnt
FROM employees
WHERE COUNT(*) > 10
GROUP BY department_id;

/* GROUP BY Golden Rule
Any item in the SELECT list that is not a group function or a constant
must be a grouping attribute of the GROUP BY clause. */

--*** Grouping by multiple columns
SELECT department_id, SUM(commission_pct)
FROM employees
WHERE commission_pct IS NOT NULL 
GROUP BY department_id;

SELECT department_id, job_id, SUM(commission_pct)
FROM employees
WHERE commission_pct IS NOT NULL
GROUP BY department_id, job_id;

/* Excercise
Create a report containing the number of employees who left their jobs, grouped by
the year in which they left. The jobs they performed are also required. The results
must be sorted in descending order based on the number of employees in each group.
The report must list the year, the JOB_ID, and the number of employees who left a
particular job in that year. */

SELECT TO_CHAR(end_date, 'YYYY'), job_id, COUNT(*)
FROM job_history
GROUP BY TO_CHAR(end_date, 'YYYY'), job_id
ORDER BY COUNT(*) DESC;

-- Select the length of the shortest and longest LAST_NAME
-- who are sales representatives
SELECT MAX(LENGTH(last_name)), MIN(LENGTH(last_name))
FROM employees
WHERE job_id = 'SA_REP';

--*** Using the HAVING clause

SELECT department_id
FROM job_history
WHERE department_id IN (50, 60, 80, 110);

SELECT department_id, COUNT(*)
FROM job_history
WHERE department_id IN (50, 60, 80, 110)
GROUP BY department_id;

-- HAVING can appear before of after GROUP BY
SELECT department_id, COUNT(*)
FROM job_history
WHERE department_id IN (50, 60, 80, 110)
GROUP BY department_id
HAVING COUNT(*) > 1;

-- Average and count per job
SELECT job_id, AVG(salary), COUNT(*)
FROM employees
GROUP BY job_id;

-- Average and count per job if average is greater than 10000
SELECT job_id, AVG(salary), COUNT(*)
FROM employees
GROUP BY job_id
HAVING AVG(salary) > 10000;

-- Average and count per job if average > 10000
-- and count > 1
SELECT job_id, AVG(salary), COUNT(*)
FROM employees
GROUP BY job_id
HAVING AVG(salary) > 10000
AND COUNT(*) > 1;

-- HAVING may only be specified when a GROUP BY clause is present

/* Excercise
Identify the days of the week on which 15 or more staff members 
were hired. Your report must list the days and the number of 
employees hired on each of them.*/

SELECT TO_CHAR(hire_date, 'DAY'), COUNT(*)
from employees
GROUP BY TO_CHAR(hire_date, 'DAY')
HAVING COUNT(*) > 15
ORDER BY COUNT(*);

/* 4. */ 

/*** Using Joins and Subqueries ***/

-- Canada's region
-- Natural join
SELECT region_name
FROM regions NATURAL JOIN countries
WHERE country_name = 'Canada';

-- Countries belonging to Americas
SELECT country_name
FROM countries NATURAL JOIN regions
WHERE region_name = 'Americas';

-- Using join syntax
SELECT region_name
FROM regions JOIN countries
USING (region_id)
WHERE country_name = 'Canada';

-- Join on syntax
SELECT country_name
FROM countries JOIN regions
ON (countries.region_id = regions.region_id)
WHERE region_name = 'Americas';

--*** Cross join
SELECT COUNT(*)
FROM countries;

SELECT COUNT(*)
FROM regions;

SELECT COUNT(*)
FROM regions
CROSS JOIN countries;

SELECT *
FROM regions
CROSS JOIN countries
WHERE country_id = 'CA';

--*** Oracle syntax

-- Countries with their region (natural join)
SELECT region_name, country_name
FROM regions, countries
WHERE regions.region_id = countries.region_id;

-- Employees and departments without employees
-- Oracle syntax for nonequijoins
SELECT last_name, department_name
FROM employees, departments
WHERE  employees.department_id(+) = departments.department_id;

-- Cartesian product
SELECT * 
FROM regions, countries;

--*** Resolving ambiguous column names

-- The column in USING and NATURAL JOIN can't be qualified
SELECT emp.employee_id, department_id, emp.manager_id,
	departments.manager_id
FROM employees emp JOIN departments
USING(department_id)
WHERE department_id > 80;

--*** NATURAL JOIN
/* SELECT table1.column, table2.column
FROM table1
NATURAL JOIN table2; */
SELECT *
FROM locations NATURAL JOIN countries;

-- Equivalent join
SELECT * 
FROM locations l, countries c
WHERE l.country_id = c.country_id;

-- No matching columns, cartesian join performed
SELECT *
FROM jobs NATURAL JOIN countries;

-- Equivalent join
SELECT *
FROM jobs, countries;

/* Warining: if the matching columns are not related or
have different data types an error will be raised */

/* Excercise 
The JOB_HISTORY table shares three identically named columns with the
EMPLOYEES table: EMPLOYEE_ID, JOB_ID, and DEPARTMENT_ID. You
are required to describe the tables and fetch the EMPLOYEE_ID, JOB_ID,
DEPARTMENT_ID, LAST_NAME, HIRE_DATE, and END_DATE values for all
rows retrieved using a pure natural join. Alias the EMPLOYEES table as EMP and
the JOB_HISTORY table as JH and use dot notation where possible.*/

SELECT employee_id, job_id, department_id,
e.last_name, e.hire_date, jh.end_date
FROM job_history jh NATURAL JOIN employees e;

--*** Natural JOIN USING Clause
/* SELECT table1.column, table2.column
FROM table1
JOIN table2 USING (join_column1, join_column2�); */

-- It is illegal to put NATURAL and USING in the same query

SELECT *
FROM locations JOIN countries
USING(country_id);

SELECT emp.last_name, emp.department_id, 
	jh.end_date, job_id, employee_id
FROM job_history jh JOIN employees emp
USING (job_id, employee_id);

--***Natural JOIN ON Clause
/* SELECT table1.column, table2.column
FROM table1
JOIN table2 ON (table1.column_name = table2.column_name);*/

-- The ON and NATURAL keywords cannot appear together in a join clause.
SELECT * 
FROM departments d JOIN employees e 
ON (e.employee_id = d.department_id);

-- Equivalent join
SELECT *
FROM employees e, departments d
WHERE e.employee_id = d.department_id;

-- employees who worked for the organization and changed jobs.
SELECT e.employee_id, e.last_name, j.start_date,
	e.hire_date, j.end_date, j.job_id previous,
	e.job_id current
FROM job_history j JOIN employees e
ON j.start_date = e.hire_date;

/* Excercise 
Each record in the DEPARTMENTS table has a MANAGER_ID column matching
an EMPLOYEE_ID value in the EMPLOYEES table. You are required to produce a
report with one column aliased as Managers. Each row must contain a sentence of the
format FIRST_NAME LAST_NAME is manager of the DEPARTMENT_NAME
department. */

SELECT first_name || ' ' || last_name || ' is manager of the ' ||
	department_name || ' department'
FROM employees e JOIN departments d
ON (e.employee_id = d.manager_id);

--*** Multiple table JOINS

-- List departments, their location, including country and region
SELECT r.region_name, c.country_name, l.city, d.department_name
FROM departments d 
NATURAL JOIN locations l
NATURAL JOIN countries c 
NATURAL JOIN regions r;

-- Equivalent join
SELECT r.region_name, c.country_name, l.city, d.department_name
FROM departments d 
JOIN locations l on (d.location_id = l.location_id)
JOIN countries c on (l.country_id = c.country_id)
JOIN regions r on (c.region_id = r.region_id);

-- Yet another equivalent join
SELECT r.region_name, c.country_name, l.city, d.department_name
FROM departments d
JOIN locations l USING(location_id)
JOIN countries c USING(country_id)
JOIN regions r USING(region_id);

-- Restrict rows with where or join on
SELECT d.department_name, l.city 
FROM departments d
JOIN locations l ON (l.location_id = d.location_id)
WHERE d.department_name LIKE 'P%';

-- Equivalent join
SELECT d.department_name, l.city 
FROM departments d
JOIN locations l ON l.location_id = d.location_id
					AND d.department_name LIKE 'P%';

/* list describing the top earning employees and 
geographical information about their departments.*/
SELECT r.region_name, c.country_name, l.city, d.department_name,
	e.last_name, e.salary
FROM employees e
JOIN departments d ON (e.department_id = d.department_id AND salary > 12000)
JOIN locations l ON (d.location_id = l.location_id)
JOIN countries c ON (l.country_id = c.country_id)
JOIN regions r ON (c.region_id = r.region_id);

/* Remember the USING, ON, and NATURAL keywords are
mutually exclusive in the context of the same join clause.*/

--*** Nonequijoins
/* A nonequijoin is specified using the JOIN�ON syntax, but the join condition
contains an inequality operator instead of an equal sign. */

/* SELECT table1.column, table2.column
FROM table1
[JOIN table2 ON (table1.column_name < table2.column_name)]|
[JOIN table2 ON (table1.column_name > table2.column_name)]|
[JOIN table2 ON (table1.column_name <= table2.column_name)]|
[JOIN table2 ON (table1.column_name >= table2.column_name)]|
[JOIN table2 ON (table1.column BETWEEN table2.col1 AND table2.col2)]|*/

SELECT e.job_id current_job, last_name || ' can earn twice their salary by changing jobs to: ' ||
	j.job_id options, e.salary current_salary, j.max_salary potential_max_salary
FROM employees e
JOIN jobs j ON (2 * e.salary < j.max_salary)
WHERE e.salary > 5000
ORDER BY last_name;

--*** Self join
SELECT e.last_name employee, e.employee_id, e.manager_id, m.last_name manager,
	e.department_id
FROM employees e
JOIN employees m ON (e.manager_id = m.employee_id)
WHERE e.department_id IN (10, 20, 30)
ORDER BY e.department_id;

--*** Left outer join
/* A left outer join between the source and target tables returns the results of an
inner join as well as rows from the source table excluded by that inner join. */

/* SELECT table1.column, table2.column
FROM table1
LEFT OUTER JOIN table2
ON (table1.column = table2.column); */

SELECT e.employee_id, e.department_id EMP_DEPT_ID,
	d.department_id DEPT_DEPT_ID, d.department_name
FROM departments d 
LEFT OUTER JOIN employees e ON (d.DEPARTMENT_ID=e.DEPARTMENT_ID)
WHERE d.department_name LIKE 'P%';

SELECT e.employee_id, e.department_id EMP_DEPT_ID,
	d.department_id DEPT_DEPT_ID, d.department_name
FROM departments d 
JOIN employees e ON (d.DEPARTMENT_ID=e.DEPARTMENT_ID)
WHERE d.department_name LIKE 'P%';

--*** Right outer join
/* A right outer join between the source and target tables returns the results of an inner join
as well as rows from the target table excluded by that inner join.*/

/* SELECT table1.column, table2.column
FROM table1
RIGHT OUTER JOIN table2
ON (table1.column = table2.column);*/

SELECT e.last_name, d.department_name 
FROM departments d
RIGHT OUTER JOIN employees e
ON (e.department_id=d.department_id)
WHERE e.last_name LIKE 'G%';

SELECT DISTINCT jh.job_id "Jobs in job history", e.job_id "jobs in employees"
FROM job_history jh
RIGHT OUTER JOIN employees e ON (jh.job_id = e.job_id)
ORDER BY jh.job_id;

--*** Full outer join
/* SELECT table1.column, table2.column
FROM table1
FULL OUTER JOIN table2
ON (table1.column = table2.column); */

SELECT e.last_name, d.department_name
FROM departments d 
FULL OUTER JOIN employees e
ON (e.department_id = d.department_id)
WHERE e.department_id IS NULL;

--*** Cartesian product
/* A Cartesian product freely associates the rows from table1 with every row
in table2. If table1 and table2 contain x and y number of rows, respectively,
the Cartesian product will contain x times y number of rows. */

/* SELECT table1.column, table2.column
FROM table1
CROSS JOIN table2;*/

SELECT * 
FROM jobs 
CROSS JOIN job_history;

SELECT * 
FROM jobs j 
CROSS JOIN job_history jh
WHERE j.job_id='AD_PRES';

SELECT r.region_name, c.country_name 
FROM regions r CROSS JOIN countries c
WHERE r.region_id IN (3, 4) 
ORDER BY region_name, country_name;

SELECT COUNT(*) 
FROM employees;

SELECT COUNT(*)
FROM departments;

SELECT COUNT(*)
FROM employees CROSS JOIN departments;



--------------------------------------
------Set Operators-------------------
--------------------------------------

-- Consider these two queries.

SELECT last_name, hire_date
FROM employees
WHERE department_id = 90;

SELECT last_name, hire_date
FROM employees
WHERE last_name LIKE 'K%';

/* The UNION operator is used to return rows from either query, 
	without any duplicate rows.*/

SELECT last_name, hire_date
FROM employees
WHERE department_id = 90
UNION
SELECT last_name, hire_date
FROM employees
WHERE last_name LIKE 'K%';

/* The UNION ALL operator does not sort or filter the result set; 
	it returns all rows from both queries. */

SELECT last_name, hire_date
FROM employees
WHERE department_id = 90
UNION ALL
SELECT last_name, hire_date
FROM employees
WHERE last_name LIKE 'K%';

/* The INTERSECT operator is used to return the rows returned 
	by both queries.*/

SELECT last_name, hire_date
FROM employees
WHERE department_id = 90
INTERSECT
SELECT last_name, hire_date
FROM employees
WHERE last_name LIKE 'K%';

/* The MINUS operator returns rows from the first query but not 
in the second query.*/

-- There can be only one ORDER BY clause in the query at the very end

SELECT last_name, hire_date
FROM employees
WHERE department_id = 90
ORDER BY last_name -- error
UNION ALL
SELECT first_name, hire_date
FROM employees
WHERE first_name LIKE 'K%'
ORDER BY first_name;

/* You can use the column name or alias name used in the first query 
	or positional notation in the ORDER BY clause.*/

SELECT last_name, hire_date "Join Date"
FROM employees
WHERE department_id = 90
UNION ALL
SELECT first_name, hire_date
FROM employees
WHERE first_name LIKE 'K%'
ORDER BY last_name, "Join Date";

SELECT last_name, hire_date "Join Date"
FROM employees
WHERE department_id = 90
UNION ALL
SELECT first_name, hire_date
FROM employees
WHERE first_name LIKE 'K%'
ORDER BY 1, 2;

/* When using set operators, the number of columns in the SELECT clause
of the queries appearing on either side of the set operator should be the
same. The column datatypes should be compatible. If the datatypes are
different, Oracle tries to do an implicit conversion of data.*/

--------------------------
--------Subqueries--------
--------------------------

----*** Single-row subqueries

-- find the name of the employee with the highest salary

SELECT last_name, first_name, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);

-- find the names and salaries of employees who work in the accounting department
SELECT last_name, first_name, salary
FROM employees
WHERE department_id = (SELECT department_id
						FROM departments
						WHERE department_name = 'Accounting');

SELECT last_name, first_name, department_id
FROM employees
WHERE department_id < (SELECT MAX(department_id)
						FROM departments
						WHERE location_id = 1500)
AND hire_date >= (SELECT MIN(hire_date)
					FROM employees
					WHERE department_id = 30);

/* lists the latest hire dates by departments that have hired an employee 
after the first employee was hired in department 80 */

SELECT department_id, MAX(hire_date)
FROM employees
GROUP BY department_id
HAVING MAX(hire_date) > (SELECT MIN(hire_date)
							FROM employees
							WHERE department_id = 80);

-- Thes queries will fail if the result have more than 1 row

----*** Multi Row subqueries

SELECT last_name, first_name, department_id
FROM employees
WHERE department_id = (SELECT department_id -- error
						FROM employees
						WHERE first_name = 'John');

SELECT last_name, first_name, department_id
FROM employees
WHERE department_id IN (SELECT department_id -- correct
						FROM employees
						WHERE first_name = 'John');

SELECT last_name, salary, department_id
FROM employees
WHERE salary >= ANY (SELECT salary FROM employees
						WHERE department_id = 110)
						AND department_id != 80;

SELECT last_name, salary, department_id
FROM employees
WHERE salary > ALL (SELECT salary FROM employees
					WHERE department_id = 110)
					AND department_id != 80;

--**** Subquery returns no rows

SELECT last_name, first_name, salary
FROM employees
WHERE department_id = (SELECT department_id
						FROM departments
						WHERE department_name = 'No existe');

SELECT first_name, last_name, salary
FROM employees
WHERE salary NOT IN (
			SELECT salary
			FROM employees
			WHERE department_id = 30);

/* The SQL does not return any rows because one of the rows returned 
	by the inner query is NULL.*/

SELECT first_name, last_name, salary
FROM employees
WHERE salary NOT IN (
			SELECT salary
			FROM employees
			WHERE department_id = 30 -- solution
			AND salary is NOT NULL);

--**** Correlated subqueries

/* Oracle performs a correlated subquery when the subquery references a column from a
table referred to in the parent statement. A correlated subquery is evaluated once for each
row processed by the parent statement.*/

 -- List the highest-paid employee of each department is selected.

SELECT department_id, last_name, salary
FROM employees e1
WHERE salary = (SELECT MAX(salary)
				FROM employees e2
				WHERE e1.department_id = e2.department_id)
ORDER BY 1, 2, 3;

SELECT last_name, first_name, department_id
FROM employees e1
WHERE EXISTS (SELECT *
				FROM employees e2
				WHERE first_name = 'John'
				AND e1.department_id = e2.department_id);

/* The column names in the parent queries are available for reference in
subqueries. The column names from the tables in the subquery cannot be
used in the parent queries. The scope is only the current query level and its
subqueries.*/

---**** Scalar subqueries
/* A scalar subquery returns exactly one column value from one row. You can use scalar
subqueries in most places where you would use a column name or expression*/

-- Case expression
SELECT city, country_id, (CASE
	WHEN country_id IN (SELECT country_id
						FROM countries
						WHERE country_name = 'India')
	THEN 'Indian'
	ELSE 'Non-Indian'
	END) "INDIA?"
FROM locations
WHERE city LIKE 'B%';

-- Select statement
-- Report the employee name, the department, and the highest salary in that department
SELECT last_name, department_id,
	(SELECT MAX(salary)
	FROM employees sq
	WHERE sq.department_id = e.department_id) HSAL
FROM employees e;


/* find the department names and their manager
names for all departments that are in the United States or Canada */
SELECT department_name, manager_id, (SELECT last_name
	FROM employees e
	WHERE e.employee_id = d.manager_id) MGR_NAME
FROM departments d
WHERE ((SELECT country_id FROM locations l
	WHERE d.location_id = l.location_id)
	IN (SELECT country_id FROM countries c
	WHERE c.country_name = 'United States of America'
	OR c.country_name = 'Canada'))
AND d.manager_id IS NOT NULL;
WHERE last_name like 'R%';

-- Order by clause
SELECT country_id, city, state_province
FROM locations l
ORDER BY (SELECT country_name
			FROM countries c
			WHERE l.country_id = c.country_id);

----**** Multiple column subqueries

SELECT * FROM state;
SELECT * FROM city;

-- List the cities in Texas
SELECT cty_name
FROM city
WHERE (cnt_code, st_code) IN
	(SELECT cnt_code, st_code
	FROM state
	WHERE st_name = 'TEXAS');


----**** Subqueries in Other DML Statements

/* You can use subqueries in DML statements such as INSERT, UPDATE, DELETE, and MERGE. */

-- update the salary of all employees to the maximum salary
UPDATE employees e1
SET salary = (SELECT MAX(salary)
FROM employees e2
WHERE e1.department_id = e2.department_id);

/* delete the records of employees whose salary is less than the average salary in the
department */
DELETE FROM employees e
WHERE salary < (SELECT AVG(salary) FROM employees
WHERE department_id = e.department_id);

-- insert records to a table u NN sing a subquery
INSERT INTO employee_archive
SELECT * FROM employees;

-- specify a subquery in the VALUES clause of the INSERT statement
INSERT INTO departments
(department_id, department_name)
VALUES ((SELECT MAX(department_id)
FROM departments), 'EDP');



---*** Finding Total Space and Free Space Using Dictionary Views

-- query to get the tablespace names and type of tablespace
SELECT tablespace_name, contents
FROM dba_tablespaces;

-- find the total space allocated to each tablespace
SELECT tablespace_name, SUM(bytes)/1048576 MBytes
FROM dba_data_files
GROUP BY tablespace_name;

SELECT tablespace_name, SUM(bytes)/1048576 MBytes
FROM dba_temp_files
GROUP BY tablespace_name;

-- find the total free space in each tablespace
SELECT tablespace_name, SUM(bytes)/1048576 MBytesFree
FROM dba_free_space
GROUP BY tablespace_name;


--display the total size of the tablespaces and their free space

SELECT tablespace_name, SUM(bytes)/1048576 MBytes, 0 MBytesFree
FROM dba_data_files
GROUP BY tablespace_name
UNION ALL
SELECT tablespace_name, SUM(bytes)/1048576 MBytes, 0
FROM dba_temp_files
GROUP BY tablespace_name
UNION ALL
SELECT tablespace_name, 0, SUM(bytes)/1048576
FROM dba_free_space
GROUP BY tablespace_name;

-- better output
SELECT tablespace_name, MBytes, MBytesFree
FROM
(SELECT tablespace_name, SUM(bytes)/1048576 MBytes
FROM dba_data_files
GROUP BY tablespace_name
UNION ALL
SELECT tablespace_name, SUM(bytes)/1048576 MBytes
FROM dba_temp_files
GROUP BY tablespace_name) totalspace
JOIN
(SELECT tablespace_name, 0, SUM(bytes)/1048576 MBytesFree
FROM dba_free_space
GROUP BY tablespace_name) freespace
USING (tablespace_name);

-- includes temp tablespace

SELECT tablespace_name, MBytes, MBytesFree
FROM
	(SELECT tablespace_name, SUM(bytes)/1048576 MBytes
	FROM dba_data_files
	GROUP BY tablespace_name
	UNION ALL
	SELECT tablespace_name, SUM(bytes)/1048576 MBytes
	FROM dba_temp_files
	GROUP BY tablespace_name) totalspace
LEFT OUTER JOIN
	(SELECT tablespace_name, 0, SUM(bytes)/1048576 MBytesFree
	FROM dba_free_space
	GROUP BY tablespace_name) freespace
	USING (tablespace_name)
ORDER BY 1;

-- another method

SELECT tsname, sum(MBytes) MBytes, sum(MBytesFree) MBytesFree
FROM (
	SELECT tablespace_name tsname, SUM(bytes)/1048576 MBytes, 0 MBytesFree
	FROM dba_data_files
	GROUP BY tablespace_name
	UNION ALL
	SELECT tablespace_name, SUM(bytes)/1048576 MBytes, 0
	FROM dba_temp_files
	GROUP BY tablespace_name
	UNION ALL
	SELECT tablespace_name, 0, SUM(bytes)/1048576
	FROM dba_free_space
	GROUP BY tablespace_name)
GROUP BY tsname
ORDER BY 1;

/* 5. */

CREATE TABLE myaccounts(
	acc_no NUMBER(5) NOT NULL,
	acc_dt DATE NOT NULL,
	dr_cr CHAR,
	amount NUMBER(15, 2)
);

INSERT INTO myaccounts (acc_no, acc_dt, amount)
VALUES (120003, TRUNC(SYSDATE), 400);

INSERT INTO myaccounts (acc_no, acc_dt, dr_cr, amount)
VALUES (120003, TRUNC(SYSDATE), DEFAULT, 400);

CREATE TABLE accounts(
	cust_name VARCHAR2(20),
	acc_open_date DATE,
	balance NUMBER(15, 2)
);

INSERT INTO accounts VALUES ('John', '13/05/68', 2300.45);

INSERT INTO hr.accounts (cust_name, acc_open_date)
VALUES (Shine, 'April-23-2001'); -- error 1st value

INSERT INTO hr.accounts (cust_name, acc_open_date)
VALUES ('Shine', 'April-23-2001'); -- error date

-- correct 
INSERT INTO hr.accounts (cust_name, acc_open_date)
VALUES ('Shine', TO_DATE('April-23-2001','Month-DD-YYYY'));

-- not enough values
INSERT INTO accounts VALUES ('Jishi', '4-AUG-72');

-- using functions
INSERT INTO accounts VALUES (USER, SYSDATE, 345);

---**** Inserting Rows from a Subquery

INSERT INTO accounts
SELECT first_name, hire_date, salary
FROM hr.employees
WHERE first_name like 'R%';

-- error too many values
INSERT INTO accounts (cust_name, balance)
SELECT first_name, hire_date, salary
FROM hr.employees
WHERE first_name like 'T%';

-- correct
INSERT INTO accounts (cust_name, acc_open_date)
2 SELECT UPPER(first_name), ADD_MONTHS(hire_date,2)
3 FROM hr.employees
4 WHERE first_name like 'T%';

-- Inserting Rows into Multiple Tables
/* INSERT [ALL | FIRST] {WHEN <condition> 
THEN INTO <insert_clause> � � �} [ELSE
<insert_clause>}*/

---*** Updating rows in a table

/* UPDATE <table_name>
SET <column> = <value>
[,<column> = <value> � � �]
[WHERE <condition>]*/

SELECT first_name, last_name, department_id
FROM employees
WHERE employee_id = 200;

UPDATE employees
SET department_id = 20
WHERE employee_id = 200;

SELECT first_name, last_name, department_id
FROM employees
WHERE employee_id = 200;

CREATE TABLE old_employees AS
SELECT * FROM employees;

UPDATE old_employees
SET manager_id = NULL,
commission_pct = 0;

-- Updating Rows Using a Subquery
SELECT first_name, last_name, job_id
FROM employees
WHERE department_id = 30;

/* the job_id values of all employees in department 30 are changed to match
the job_id of employee 114 */
UPDATE employees
SET job_id = (SELECT job_id
FROM employees
WHERE employee_id = 114)
WHERE department_id = 30;

SELECT first_name, last_name, job_id
FROM employees
WHERE department_id = 30;

-- Deleting Rows from a Table

/* DELETE [FROM] <table>
[WHERE <condition>] */

-- Delete some rows from old_employees

/* Removing all rows from a large table can take a long time and require significant rollback
segment space.*/

TRUNCATE TABLE old_employees;

/* A DDL statement cannot be rolled back; only DML statements can be 
rolled back.*/

------------------------------------------------
-------- Understanding Transaction Control -----
------------------------------------------------

/* A transaction can include one or more DML statements. A transaction ends when you
save the transaction (COMMIT) or undo the changes (ROLLBACK). When DDL statements are
executed, Oracle implicitly ends the previous transaction by saving the changes. It also
begins a new transaction for the DDL and ends the transaction after the DDL is completed.*/


/* 6. */ 

---**** Creating tables

CREATE TABLE products( 
	prod_id NUMBER (4),
	prod_name VARCHAR2 (20),
	stock_qty NUMBER (15,3)
);

/*Table and column names are identifiers and can be up to 
30 characters long. 
Special characters allowed #, $, _
For case sensitivity use "" double quotes */

CREATE TABLE MyTable (
Column_1 NUMBER,
Column_2 CHAR);

DESC mytable

SELECT table_name FROM user_tables
WHERE table_name = 'MyTable';

CREATE TABLE "MyTable" (
"Column1" number,
"Column2" char);

DESC "MyTable"

SELECT table_name FROM user_tables
WHERE UPPER(table_name) = 'MYTABLE';

--*** Specifying default values for columns

-- The default values can include SYSDATE, USER, USERENV, and UID.

CREATE TABLE orders (
order_number NUMBER (8),
status VARCHAR2 (10) DEFAULT 'PENDING');

INSERT INTO orders (order_number) VALUES (4004);

SELECT * FROM orders;

CREATE TABLE emp_punch (
emp_id NUMBER (6) NOT NULL,
time_in DATE,
time_out DATE,
updated_by VARCHAR2 (30) DEFAULT USER,
update_time TIMESTAMP WITH LOCAL TIME ZONE
DEFAULT SYSTIMESTAMP
);

DESCRIBE emp_punch

INSERT INTO emp_punch (emp_id, time_in)
VALUES (1090, TO_DATE('062801-2121','MMDDYY-HH24MI'));

SELECT * FROM emp_punch;

/* If you explicitly insert a NULL value for a column with DEFAULT defined, 
the value in the DEFAULT clause will not be used.*/
INSERT INTO emp_punch
VALUES (104, TO_DATE('062801-2121','MMDDYY-HH24MI'),
DEFAULT, DEFAULT, NULL);

SELECT * FROM emp_punch;

---*** Comments

COMMENT ON TABLE mytable IS
'Oracle 11g Study Guide Example Table';

COMMENT ON COLUMN mytable.column_1 is
'First column in MYTABLE';

---*** Creating a table from another table

-- CREATE TABLE <table characteristics> AS SELECT <query>

CREATE TABLE emp 
AS SELECT * FROM employees;

CREATE TABLE depts
AS SELECT * FROM departments WHERE 1 = 2;

CREATE TABLE regions_2
AS SELECT region_id REG_ID, region_name REG_NAME
FROM regions;

SELECT COUNT(*) FROM regions_2;

DESC regions_2;

/* The CREATE TABLE � AS SELECT � statement will not work if the query
refers to columns of the LONG datatype. */


/* When you create a table using the subquery, only the NOT NULL constraints
associated with the columns are copied to the new table. Other constraints and
column default definitions are not copied. */  

------------------------------
---- Modifying tables --------
------------------------------

---*** Adding columns

-- ALTER TABLE [<schema>.]<table_name> ADD <column_definitions>;

DESCRIBE orders

SELECT * FROM orders;

ALTER TABLE orders ADD order_date DATE;

DESC orders

SELECT * FROM orders;

ALTER TABLE orders ADD
(quantity NUMBER (13,3),
update_dt DATE DEFAULT SYSDATE);

SELECT * FROM orders;

/* When adding a new column, you cannot specify the NOT NULL constraint if the table
already has rows. */

-- error table already contains rows
ALTER TABLE orders
ADD updated_by VARCHAR2 (30) NOT NULL;

ALTER TABLE orders ADD updated_by VARCHAR2 (30)
DEFAULT 'JOHN' NOT NULL;


---*** Modifying columns

-- ALTER TABLE [<schema>.]<table_name> MODIFY <column_name> <new_attributes>;

ALTER TABLE orders MODIFY (quantity NUMBER (10,3),
status VARCHAR2 (15));

/* Removes the default SYSDATE value from the UPDATE_DT column of the ORDERS table */
ALTER TABLE orders
MODIFY update_dt DEFAULT NULL;

---*** Renaming columns

-- ALTER TABLE [<schema>.]<table_name> RENAME COLUMN <column_name> TO <new_name>;

CREATE TABLE sample_data(
	data_value VARCHAR2(20),
	data_type VARCHAR2(10)
);

ALTER TABLE sample_data
RENAME COLUMN data_value to sample_value;

DESCRIBE sample_data

---*** Dropping columns

--DROP
/* ALTER TABLE [<schema>.]<table_name>
DROP {COLUMN <column_name> | (<column_names>)}
[CASCADE CONSTRAINTS] */

---SET UNUSED
/* ALTER TABLE [<schema>.]<table_name>
SET UNUSED {COLUMN <column_name> | (<column_names>)}
[CASCADE CONSTRAINTS] */

ALTER TABLE orders SET UNUSED COLUMN update_dt;

DESCRIBE orders

-- Drop a column already marked as unused
/* ALTER TABLE [<schema>.]<table_name>
DROP {UNUSED COLUMNS | COLUMNS CONTINUE} */

ALTER TABLE orders DROP UNUSED COLUMNS;

/* The data dictionary views DBA_UNUSED_COL_TABS, ALL_UNUSED_COL_TABS,
and USER_UNUSED_COL_TABS provide the names of tables in which you have
columns marked as unused. */

---*** Dropping tables

-- DROP TABLE [schema.]table_name [CASCADE CONSTRAINTS]

DROP TABLE sample_data;

---*** Renaming tables
 
/* Oracle invalidates all objects that depend on the renamed table, 
such as views, synonyms, stored procedures, and functions. */

-- RENAME old_name TO new_name;

RENAME orders TO purchase_orders;
DESCRIBE purchase_orders

-- Other technique

ALTER TABLE scott.purchase_orders
RENAME TO orders;

---*** Making tables read-only

ALTER TABLE products READ ONLY;

/* The following operations on
the read-only table are not allowed:
* INSERT, UPDATE, DELETE, or MERGE statements
* The TRUNCATE operation
* Adding, modifying, renaming, or dropping a column
* Flashing back a table
* SELECT FOR UPDATE*/

/* The following operations are allowed on the read-only table:
* SELECT
* Creating or modifying indexes
* Creating or modifying constraints
* Changing the storage characteristics of the table
* Renaming the table
* Dropping the table*/

-- Not allowed
TRUNCATE TABLE products;
DELETE FROM products;
INSERT INTO products (prod_id) VALUES (200);

-- Back to normal
ALTER TABLE products READ WRITE;

---------------------------------
------ Managing Constraints -----
---------------------------------

/* Types of constraints: NOT NULL, CHECK, UNIQUE, 
	PRIMARY KEY, FOREIGN KEY */

/* NOT NULL Constraint
 A NOT NULL constraint is defined at the column level 
 [CONSTRAINT <constraint name>] [NOT] NULL*/

-- DROP TABLE orders; -- just in case
CREATE TABLE orders (
order_num NUMBER (4) CONSTRAINT nn_order_num NOT NULL,
order_date DATE NOT NULL,
product_id NUMBER (6))

-- Add or remove NOT NULL
ALTER TABLE orders MODIFY order_date NULL;
ALTER TABLE orders MODIFY product_id NOT NULL;

/* Check Constraint
 You can define a check constraint at the column level or table level 
 [CONSTRAINT <constraint name>] CHECK ( <condition> )*/

CREATE TABLE bonus (
emp_id VARCHAR2 (40) NOT NULL,
salary NUMBER (9,2),
bonus NUMBER (9,2),
CONSTRAINT ck_bonus check (bonus > 0));

ALTER TABLE bonus
ADD CONSTRAINT ck_bonus2 CHECK (bonus < salary);

/* You cannot use the ALTER TABLE MODIFY clause to add or modify check constraints (only
NOT NULL constraints can be modified this way).*/

ALTER TABLE orders ADD cust_id number (5)
CONSTRAINT ck_cust_id CHECK (cust_id > 0);

-- simulate NOT NULL on multiple columns
ALTER TABLE bonus ADD CONSTRAINT ck_sal_bonus
CHECK ((bonus IS NULL AND salary IS NULL) OR
(bonus IS NOT NULL AND salary IS NOT NULL));

/* Unique Constraints
Unique constraints can be defined at the column level for 
single-column unique keys
[CONSTRAINT <constraint name>] UNIQUE
-- Multiple column up to 32
[CONSTRAINT <constraint name>]
UNIQUE (<column>, <column>, �)*/

CREATE TABLE employee(
	emp_id NUMBER(4),
	dept VARCHAR2(10)
);

ALTER TABLE employee
ADD CONSTRAINT uq_emp_id UNIQUE (dept, emp_id);

ALTER TABLE employee ADD
ssn VARCHAR2 (11) CONSTRAINT uq_ssn unique;

/* Primary Key
-- column level
[CONSTRAINT <constraint name>] PRIMARY KEY
-- table level
[CONSTRAINT <constraint name>]
PRIMARY KEY (<column>, <column>, �)*/

DROP TABLE employee;

CREATE TABLE employee (
dept_no VARCHAR2 (2),
emp_id NUMBER (4),
name VARCHAR2 (20) NOT NULL,
ssn VARCHAR2 (11),
salary NUMBER (9,2) CHECK (salary > 0),
CONSTRAINT pk_employee primary key (dept_no, emp_id),
CONSTRAINT uq_ssn unique (ssn));

-- add PK to existing table
ALTER TABLE employee
ADD CONSTRAINT pk_employee PRIMARY KEY (dept_no, emp_id);

/* Foreign Key
[CONSTRAINT <constraint name>]
REFERENCES [<schema>.]<table> [(<column>, <column>, �]
[ON DELETE {CASCADE | SET NULL}] */

/* You can query the constraint information from the Oracle dictionary using
the following views: USER_CONSTRAINTS, ALL_CONSTRAINTS, USER_CONS_
COLUMNS, and ALL_CONS_COLUMNS. */

-- Create a disabled constraint

ALTER TABLE bonus
ADD CONSTRAINT ck_bonus CHECK (bonus > 0) DISABLE;

---*** Drop constraints 

ALTER TABLE bonus DROP CONSTRAINT ck_bonus;

ALTER TABLE employee MODIFY name NULL;

-- Drop unique or primary key constraint with referenced FK

ALTER TABLE employee DROP UNIQUE (emp_id) CASCADE;

ALTER TABLE bonus DROP PRIMARY KEY CASCADE;

---*** Enabling and disabling constriants

ALTER TABLE bonus DISABLE CONSTRAINT ck_bonus;
ALTER TABLE employee DISABLE CONSTRAINT uq_ssn;

ALTER TABLE bonus ENABLE CONSTRAINT ck_bonus;


-- Validate constraints
ALTER TABLE wh01 MODIFY CONSTRAINT pk_wh01
DISABLE NOVALIDATE;

ALTER TABLE wh01 MODIFY CONSTRAINT pk_wh01
ENABLE NOVALIDATE;

-- Another example

create table emp as
select employee_id empno, last_name ename, department_id deptno
from employees;

create table dept as
select department_id deptno, department_name dname from departments;

DESC emp
DESC dept

alter table emp add constraint emp_pk primary key (empno);
alter table dept add constraint dept_pk primary key (deptno);
alter table emp add constraint
dept_fk foreign key (deptno) references dept on delete set null;

/* The preceding last constraint does not specify which column of DEPT to
reference; this will default to the primary key column.*/

insert into dept values(10,'New Department');
insert into emp values(9999,'New emp',99);
truncate table dept;

drop table emp;
drop table dept;


/* 7. */

-------------------------------------
---- Creating and Modifying View ----
-------------------------------------

CREATE VIEW admin_employees AS
SELECT first_name || last_name NAME,
email, job_id POSITION
FROM employees
WHERE department_id = 10;

DESCRIBE admin_employees

CREATE VIEW emp_sal_comm AS
SELECT employee_id, salary,
salary * NVL(commission_pct,0) commission
FROM employees;

DESCRIBE emp_sal_comm

---*** Using defined column names

CREATE VIEW emp_hire
(employee_id, employee_name, department_name,
hire_date, commission_amt)
AS SELECT employee_id, first_name || ' ' || last_name,
	department_name, TO_CHAR(hire_date,'DD-MM-YYYY'),
	salary * NVL(commission_pct, .5)
	FROM employees JOIN departments USING (department_id)
	ORDER BY first_name || ' ' || last_name;

DESC emp_hire

---*** Create views with errors

CREATE VIEW test_view AS
SELECT c1, c2 FROM test_table; -- error

CREATE FORCE VIEW test_view AS -- correct
SELECT c1, c2 FROM test_table;

CREATE TABLE test_table (
c1 NUMBER (10),
c2 VARCHAR2 (20));

SELECT * FROM test_view;

---*** Creating Read-Only views

CREATE VIEW all_locations
AS SELECT country_id, country_name, location_id, city
FROM locations NATURAL JOIN countries
WITH READ ONLY;

---*** Creating Constraints on Views

/* When creating constraints on views, you must always include the DISABLE
NOVALIDATE clause. You can define primary key, unique key, and foreign key constraints on
views.*/

CREATE VIEW emp_details
(employee_no CONSTRAINT fk_employee_no
REFERENCES employees DISABLE NOVALIDATE,
manager_no,
phone_number CONSTRAINT uq_email unique
DISABLE NOVALIDATE,
CONSTRAINT fk_manager_no FOREIGN KEY (manager_no)
REFERENCES employees DISABLE NOVALIDATE)
AS SELECT employee_id, manager_id, phone_number
FROM employees
WHERE department_id = 40;

---*** Modifying Views

/* To change the definition of the view, use the CREATE VIEW statement with the OR REPLACE
option. The ALTER VIEW statement can be used to compile an invalid view or to add and
drop constraints. */

CREATE OR REPLACE VIEW admin_employees AS
SELECT first_name ||' '|| last_name NAME,
email, job_id
FROM employees
WHERE department_id = 10;

---*** Recompiling a view

SELECT last_ddl_time, status FROM user_objects
WHERE object_name = 'TEST_VIEW';

ALTER TABLE test_table MODIFY c2 VARCHAR2 (8);

SELECT last_ddl_time, status FROM user_objects
WHERE object_name = 'TEST_VIEW';

ALTER VIEW test_view compile;

SELECT last_ddl_time, status FROM user_objects
WHERE object_name = 'TEST_VIEW';

-- adds a primary key constraint on the TEST_VIEW view

ALTER VIEW hr.test_view
ADD CONSTRAINT pk_test_view
PRIMARY KEY (C1) DISABLE NOVALIDATE;

-- drop the constraint you just added

ALTER VIEW test_view DROP CONSTRAINT pk_test_view;

---*** Droping a view

/* The view definition is dropped from the dictionary,
and the privileges and grants on the view are also dropped. Other views and stored
programs that refer to the dropped view become invalid.*/

DROP VIEW test_view;

---*** Using Views in Queries

SELECT * FROM emp_details;

SELECT department_name, SUM(commission_amt) comm_amt
FROM emp_hire
WHERE commission_amt > 100
GROUP BY department_name;

---*** Inserting, Updating, and Deleting Data through Views

/* DML cannot be done if the view containts at least one of
the following: DISTINCT , GROU BY, START WITH, CONNECT BY,
ROWNUM, set operators, a subquery in the SELECT clause */

CREATE OR REPLACE VIEW dept_above_250
AS SELECT department_id DID, department_name
FROM departments
WHERE department_id > 250;
SELECT * FROM dept_above_250;

INSERT INTO dept_above_250
VALUES (199, 'Temporary Dept');

SELECT * FROM departments
WHERE department_id = 199;

/* The WITH CHECK OPTION clause creates a check constraint on the view to
enforce the condition */

CREATE OR REPLACE VIEW dept_above_250
AS SELECT department_id DID, department_name
FROM departments
WHERE department_id > 250
WITH CHECK OPTION;

INSERT INTO dept_above_250
VALUES (199, 'Temporary Dept'); -- error

SELECT constraint_name, table_name
FROM user_constraints
WHERE constraint_type = 'V';

CREATE OR REPLACE VIEW dept_above_250
AS SELECT department_id DID, department_name
FROM departments
WHERE department_id > 250
WITH CHECK OPTION CONSTRAINT check_dept_250;

FROM user_constraints
WHERE constraint_type = 'V';
SELECT constraint_name, table_name

/* Using Join Views */

CREATE OR REPLACE VIEW country_region AS
SELECT a.country_id, a.country_name, a.region_id,
b.region_name
FROM countries a, regions b
WHERE a.region_id = b.region_id;

/* In the COUNTRY_REGION view, the COUNTRIES table is key-preserved because it is the primary
key in the COUNTRIES table and its uniqueness is kept in the view also. The REGIONS
table is not key-preserved because its primary key REGION_ID is duplicated several times for
each country.*/

UPDATE country_region
SET region_name = 'Testing Update'
WHERE region_id = 1;

UPDATE country_region
SET region_id = 1
WHERE country_id = 'EG';

CREATE OR REPLACE VIEW country_region AS
SELECT a.country_id, a.country_name, a.region_id,
b.region_name
FROM countries a, regions b
WHERE a.region_id = b.region_id
WITH CHECK OPTION;

-- WITH CHECK OPTION prevents DML even if is a key-preserved table
UPDATE country_region
SET region_id = 1
WHERE country_id = 'EG';

---*** Viewing Allowable DML operations

SELECT column_name, updatable, insertable, deletable
FROM user_updatable_columns
WHERE owner = 'HR'
AND table_name = �COUNTRY_REGION�;

---*** Using Inline Views

--report the employee names, their salaries, and the average salary
in their department
SELECT first_name, salary, avg_salary
FROM employees, (SELECT department_id,
AVG(salary) avg_salary FROM employees e2
GROUP BY department_id) dept
WHERE employees.department_id = dept.department_id
AND first_name like 'B%';


---*** Performing Top-n Analysis

-- top five highest-paid employees
SELECT * FROM
(SELECT last_name, salary
FROM employees
ORDER BY salary DESC)
WHERE ROWNUM <= 5;

SELECT first_name, salary, avg_salary
FROM employees
NATURAL JOIN (SELECT department_id,
AVG(salary) avg_salary FROM employees e2
GROUP BY department_id) dept
WHERE first_name like 'B%';

-- find the newest employee in each department
SELECT department_name, first_name, last_name,
hire_date
FROM employees JOIN departments
USING (department_id)
JOIN (SELECT department_id, max(hire_date) hire_date
FROM employees
GROUP BY department_id)
USING (department_id, hire_date);

-----------------------------------------
---- Creating and Managing Sequences ----
-----------------------------------------

CREATE SEQUENCE hr.employee_identity START WITH 2001;

DROP SEQUENCE sequence_name;

/* The syntax for accessing the next sequence number is as follows:
	sequence_name.nextval
Here is the syntax for accessing the last-used sequence number:
	sequence_name.currval*/

CREATE SEQUENCE emp_seq NOMAXVALUE NOCYCLE;

/* DDL Test */

--https://kasabiann.files.wordpress.com/2011/01/entidad-relacion.png

CREATE TABLE autores(
	id NUMBER(4) PRIMARY KEY,
	nombre VARCHAR2(50) NOT NULL,
	apellido_paterno VARCHAR2(50) NOT NULL,
	apellido_materno VARCHAR2(50) NOT NULL
);

CREATE TABLE libros(
	isbn VARCHAR2(13) PRIMARY KEY,
	titulo VARCHAR2(255) NOT NULL,
	sinopsis VARCHAR2(1000),
	num_paginas NUMBER(4),
	editorial_id NUMBER(4)
);

CREATE TABLE autores_libros(
	autor_id NUMBER(4),
	libro_id VARCHAR2(13)
);

CREATE TABLE editoriales(
	id NUMBER(4) PRIMARY KEY,
	nombre VARCHAR2(100) NOT NULL,
	sede VARCHAR2(255)
);

ALTER TABLE autores_libros
ADD CONSTRAINT autor_fk FOREIGN KEY(autor_id)
REFERENCES autores(id);

ALTER TABLE autores_libros
ADD CONSTRAINT libro_fk FOREIGN KEY(libro_id)
REFERENCES libros(isbn);

ALTER TABLE libros
ADD CONSTRAINT libro_editorial_fk FOREIGN KEY(editorial_id)
REFERENCES editoriales(id);

/* PL SQL Examples */

DECLARE
  -- Este ejemplo es Hola Mundo
  mensaje VARCHAR2(20) := 'Hola mundo';
BEGIN
  /*
  Estas son
  l�neas ejecutables
  */
  dbms_output.put_line(mensaje);
END;

DECLARE 
  num1 INTEGER;
  num2 REAL;
  num3 DOUBLE PRECISION;
  nombre VARCHAR2(50);
  CP CHAR(5);
BEGIN
  NULL;
END;
  

  DECLARE
  num1 INTEGER;
  ventas NUMBER(10, 2);
  pi CONSTANT DOUBLE PRECISION := 3.14159;
  nombre VARCHAR(2);
  direccion VARCHAR2(100);
  var FLOAT DEFAULT 1.5;
BEGIN
  -- Este programa declara variables
  NULL;
  
  /*
    Y demuestra el uso de comentarios
  */
END;



DECLARE
  a INTEGER := 10;
  b INTEGER := 20;
  c INTEGER;
  f REAL;
BEGIN
  c := a + b;
  dbms_output.put_line('Valor de c: ' || c);
  f := 70.0 / 3.0;
  dbms_output.put_line('Valor de f: ' || f);
END;

DECLARE
  -- Variables globales
  num1 NUMBER := 95;
  num2 NUMBER := 85;
BEGIN
  dbms_output.put_line('Variable global num1: ' || num1);
  dbms_output.put_line('Variable global num2: ' || num2);
  
  DECLARE
    num1 NUMBER := 195;
    num2 NUMBER := 185;
  BEGIN
    dbms_output.put_line('Variable local num1: ' || num1);
    dbms_output.put_line('Variable local num2: ' || num2);
  END;
END;

DECLARE 
  nombre    employees.first_name%type; 
  apellido  employees.last_name%type;
  sueldo    employees.salary%type;
BEGIN
  SELECT first_name, last_name, salary
    INTO nombre, apellido, sueldo
  FROM employees
  WHERE employee_id = 110;
  dbms_output.put_line('Nombre: ' || nombre);
  dbms_output.put_line('Apellido: ' || apellido);
  dbms_output.put_line('Sueldo: ' || sueldo);
END;

BEGIN
  dbms_output.put_line('10 + 5: ' || (10 + 5));
  dbms_output.put_line('10 - 5: ' || (10 - 5));
  dbms_output.put_line('10 * 5: ' || (10 * 5));
  dbms_output.put_line('10 / 5: ' || (10 / 5));
  dbms_output.put_line('10 ** 5: ' || (10 ** 5));
END;

DECLARE
  a NUMBER(2) := 21;
  b NUMBER(2) := 10;
BEGIN
  IF(a = b) THEN
    dbms_output.put_line('A es igual a B');
  ELSE
    dbms_output.put_line('A no es igual a B');
  END IF;
  
  IF(a < b) THEN
    dbms_output.put_line('A es menor que B');
  ELSE
    dbms_output.put_line('A no es menor que B');
  END IF;  
  
  IF(a > b) THEN
    dbms_output.put_line('A es mayor que B');
  ELSE
    dbms_output.put_line('A no es mayor que B');
  END IF;  
  
  a := 5;
  b := 20;
  
  IF(a <= b) THEN
    dbms_output.put_line('A es menor o igual que B');
  ELSE
    dbms_output.put_line('A no es menor o igual que B');
  END IF;  
  
  IF(a >= b) THEN
    dbms_output.put_line('A es mayor o igual que B');
  ELSE
    dbms_output.put_line('A no es mayor o igual que B');
  END IF;
  
  IF(a <> b) THEN
    dbms_output.put_line('A es diferente de B');
  ELSE
    dbms_output.put_line('A no es diferente de B');
  END IF;
END;

DECLARE
  a BOOLEAN := TRUE;
  b BOOLEAN := FALSE;
BEGIN
  IF(a AND b) THEN
    dbms_output.put_line('1a condici�n: TRUE');
  END IF;
  
  IF(a OR b) THEN
    dbms_output.put_line('2a condici�n: TRUE');
  END IF;
  
  IF(NOT a) THEN
    dbms_output.put_line('3a condici�n: a no es TRUE');
  ELSE
    dbms_output.put_line('3a condici�n: a es TRUE');
  END IF;
  
  IF(NOT b) THEN
    dbms_output.put_line('4a condici�n: b no es TRUE');
  ELSE
    dbms_output.put_line('4a condici�n: b es TRUE');
  END IF;
END;

DECLARE 
  a NUMBER(2) := 10;
BEGIN
   a := 30;
   -- revisar condici�n
   IF( a < 20) THEN
      -- La condici�n fue verdadera
      dbms_output.put_line('A es mayor que 20');
   END IF;
   
   dbms_output.put_line('Valor de a: ' || a);
END;

DECLARE
  a NUMBER(3) := 20;
BEGIN
  IF(a < 50) THEN
    dbms_output.put_line('A es menor que 50');
  ELSE
    dbms_output.put_line('A no es menor que 50');
  END IF;  
  
  dbms_output.put_line('Valor de a: ' || a);
END;

DECLARE
  A number(3) := 30;
BEGIN
  IF(a = 10) THEN
    dbms_output.put_line('A es igual a 10');
  ELSIF(a = 20) THEN
    dbms_output.put_line('A es igual a 20');
  ELSIF(a = 30) THEN
    dbms_output.put_line('A es igual a 30');
  ELSE
    dbms_output.put_line('El valor de a no coincidio');
  END IF;
  
  dbms_output.put_line('Valor de A: ' || a);
END;

DECLARE
  calif CHAR(2) := '10';
BEGIN
  CASE 
    WHEN calif = '10' THEN dbms_output.put_line('Excelente');
    WHEN calif = '9' THEN dbms_output.put_line('Muy bien');
    WHEN calif = '8' THEN dbms_output.put_line('Bien hecho');
    WHEN calif = '7' THEN dbms_output.put_line('Pasaste');
    WHEN calif = '5' THEN dbms_output.put_line('Reprobado');
  END CASE;
END;

DECLARE
  x NUMBER := 10;
BEGIN
  LOOP
    dbms_output.put_line(x);
    x := x + 10;
    
    EXIT WHEN x > 50;
  END LOOP;
  
  dbms_output.put_line('Al terminar el ciclo x: ' || x);
END;

DECLARE 
  a NUMBER(2) := 10;
BEGIN
  WHILE a < 20 LOOP
    dbms_output.put_line('Valor de a: ' || a);
    a := a + 1;
  END LOOP;
END;

DECLARE 
  a NUMBER(2);
BEGIN
  FOR a IN REVERSE 10 .. 20 LOOP
    dbms_output.put_line('Valor de a: ' || a);
  END LOOP;
END;

CREATE OR REPLACE PROCEDURE saludos
AS
BEGIN
  dbms_output.put_line('Saludos desde procedimiento');
END;

--EXECUTE saludos;

BEGIN
  saludos;
END;

DROP PROCEDURE saludos;

DECLARE
  a NUMBER;
  b NUMBER;
  c NUMBER;
PROCEDURE findMin(x IN number, y IN number, z OUT number) IS
BEGIN
  IF x < y THEN
    z := x;
  ELSE
    z := y;
  END IF;
END;
BEGIN
  a := 23;
  b := 45;
  findMin(a, b, c);
  dbms_output.put_line('El m�nimo de 45 y 23 es: ' || c);
END;

DECLARE
  a NUMBER;
PROCEDURE cuadrado(x IN OUT NUMBER) IS
BEGIN
  x := x ** 2;
END;
BEGIN
  a := 9;
  cuadrado(a);
  dbms_output.put_line('Cuadrado de 9: ' || a);
END;

CREATE OR REPLACE FUNCTION totalEmpleados
RETURN NUMBER IS
  total NUMBER(3) := 0;
BEGIN
  SELECT COUNT(*) INTO total
  FROM employees;
  
  RETURN total;
END;

DECLARE
  c NUMBER(3);
BEGIN
  c := totalEmpleados();
  dbms_output.put_line('Total: ' || c);
END;

-- DROP function nombre;

DECLARE
  a NUMBER;
  b NUMBER;
  c NUMBER;
FUNCTION findMax(x IN NUMBER, y IN NUMBER)
RETURN NUMBER
IS 
  z NUMBER;
BEGIN
  IF x > y THEN
    z := x;
  ELSE
    z := y;
  END IF;
  
  RETURN z;
END;
BEGIN
  a := 55;
  b := 31;
  
  c := findMax(a, b);
  dbms_output.put_line('El mayor de a y b es: ' || c);
END;

DECLARE 
  num NUMBER;
  factorial NUMBER;
FUNCTION fact(x NUMBER)
RETURN NUMBER
IS
  f NUMBER;
BEGIN
  IF x = 0 THEN
    f := 1;
  ELSE
    f := x * fact(x - 1);
  END IF;
  
  RETURN f;
END;  
BEGIN
  num := 6;
  factorial := fact(num);
  dbms_output.put_line('Factorial de 6: ' || factorial);
END;

/* Practices */

/* Pr�ctica: Restricting and Sorting Data */

SELECT last_name, salary
FROM employees
WHERE salary > 12000;

SELECT last_name, department_id
FROM employees
WHERE employee_id = 176;

SELECT last_name, salary
FROM employees
WHERE salary NOT BETWEEN 5000 AND 12000;

SELECT last_name, job_id, hire_date
FROM employees
WHERE last_name IN ('Matos', 'Taylor')
ORDER BY hire_date;

SELECT last_name, department_id
FROM employees
WHERE department_id IN (20, 50)
ORDER BY last_name ASC;

SELECT last_name "Employee", salary "Monthly Salary"
FROM employees
WHERE salary BETWEEN 5000 AND 12000
  AND department_id IN (20, 50);
  
SELECT last_name, hire_date
FROM employees
WHERE hire_date LIKE '%94';

SELECT last_name, job_id
FROM employees
WHERE manager_id IS NULL;


SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct IS NOT NULL
ORDER BY 2 DESC, 3 DESC;

SELECT last_name, salary
FROM employees
WHERE salary > &sal;

SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE manager_id = &man
ORDER BY &order_col;

SELECT last_name
FROM employees
WHERE last_name LIKE '__a%';

SELECT last_name
FROM employees
WHERE last_name LIKE '%a%' OR last_name LIKE '%e%';

SELECT last_name, job_id, salary
FROM employees
WHERE job_id IN ('SA_REP', 'ST_CLERK')
  AND salary NOT IN (2500, 3500, 7000);
  
SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct = .2;

/* Pr�ctica: Using Single-Row functions to customize output*/

SELECT SYSDATE "Date"
FROM dual;

SELECT employee_id, last_name, salary,
        ROUND(salary * 1.155, 0) "New Salary"
FROM employees;       

SELECT employee_id, last_name, salary,
      ROUND(salary * 1.155, 0) "New Salary",
      ROUND(salary * 1.155, 0) - salary "Increment"
FROM employees;      

SELECT INITCAP(last_name) "Name",
       LENGTH(last_name) "Length"
FROM employees
WHERE last_name LIKE 'J%'
  OR last_name LIKE 'A%'
  OR last_name LIKE 'M%'
ORDER BY last_name;  

SELECT INITCAP(last_name) "Name",
       LENGTH(last_name) "Length"
FROM employees
WHERE last_name LIKE '&letra%'
ORDER BY last_name;

SELECT INITCAP(last_name) "Name",
       LENGTH(last_name) "Length"
FROM employees
WHERE last_name LIKE UPPER('&letra%')
ORDER BY last_name;

SELECT last_name, ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) "Months Worked"
FROM employees
ORDER BY 2;

SELECT last_name, LPAD(salary, 15, '$') SALARY
FROM employees;


SELECT RPAD(last_name, 8) || ' ' ||
      RPAD(' ', salary / 1000 + 1, '*')
        EMPLOYEES_AND_THEIR_SALARIES
FROM employees
ORDER BY salary DESC;


SELECT last_name, TRUNC((SYSDATE - hire_date) / 7)
FROM employees
WHERE department_id = 90
ORDER BY 2;

/* Pr�ctica: Funciones de Conversi�n y Condicionales*/

SELECT last_name || ' earns '
      || TO_CHAR(salary, 'fm$99,999.00')
      || ' monthly but wants '
      || TO_CHAR(salary * 3, 'fm$99,999.00')
      || '.' "Dream Salaries"
FROM employees;      

SELECT last_name, hire_date,
      TO_CHAR(NEXT_DAY(ADD_MONTHS(hire_date, 6), 'LUNES'),
        'fmDay, "the" Ddspth "of" Month, YYYY') REVIEW
FROM employees;  

SELECT last_name, hire_date,
      TO_CHAR(hire_date, 'DAY') DAY
FROM employees
ORDER BY TO_CHAR(hire_date - 1, 'd');

SELECT last_name, NVL(TO_CHAR(commission_pct), 'No commission') COMM
FROM employees;

SELECT job_id, DECODE(job_id, 
                        'ST_CLERK', 'E',
                        'SA_REP', 'D',
                        'IT_PROG', 'C',
                        'ST_MAN', 'B',
                        'AD_PRES', 'A',
                        '0') GRADE
FROM employees;             

SELECT job_id, CASE job_id
              WHEN 'ST_CLERK' THEN 'E'
              WHEN 'SA_REP' THEN 'D'
              WHEN 'IT_PROG' THEN 'C'
              WHEN 'ST_MAN' THEN 'B'
              WHEN 'AD_PRES' THEN 'A'
              ELSE '0' END GRADE
From employees;              

/* Pr�ctica: Reporting Aggregated Data Using group functions */

SELECT ROUND(MAX(salary), 0) "Maximum",
       ROUND(MIN(salary), 0) "Minimum",
       ROUND(SUM(salary), 0) "Sum",
       ROUND(AVG(salary), 0) "Average"
FROM employees;       

SELECT job_id, ROUND(MAX(salary), 0) "Maximum",
       ROUND(MIN(salary), 0) "Minimum",
       ROUND(SUM(salary), 0) "Sum",
       ROUND(AVG(salary), 0) "Average"
FROM employees
GROUP BY job_id;       

SELECT job_id, COUNT(*)
FROM employees
GROUP BY job_id
ORDER BY COUNT(*) DESC;

SELECT job_id, COUNT(*)
FROM employees
WHERE job_id = '&job_title'
GROUP BY job_id;

SELECT COUNT(DISTINCT manager_id) "Number of managers"
FROM employees;

SELECT MAX(salary) - MIN(salary) DIFFERENCE
FROM employees;


SELECT manager_id, MIN(salary)
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING MIN(salary) > 6000
ORDER BY MIN(salary) DESC;

SELECT COUNT(*) total,
        SUM(DECODE(TO_CHAR(hire_date, 'YYYY'), 2001, 1, 0)) "2001",
        SUM(DECODE(TO_CHAR(hire_date, 'YYYY'), 2002, 1, 0)) "2002",
        SUM(DECODE(TO_CHAR(hire_date, 'YYYY'), 2003, 1, 0)) "2003",
        SUM(DECODE(TO_CHAR(hire_date, 'YYYY'), 2004, 1, 0)) "2004"
FROM employees;    

SELECT job_id "Job",
       SUM(DECODE(department_id, 20, salary)) "Dep 20",
       SUM(DECODE(department_id, 50, salary)) "Dep 50",
       SUM(DECODE(department_id, 80, salary)) "Dep 80",
       SUM(DECODE(department_id, 90, salary)) "Dep 90",
       SUM(salary) "Total"
FROM employees
GROUP BY job_id;

/* Pr�ctica: Displaying Data from Multiple Tables Using Joins */

SELECT location_id, street_address, city, state_province,
      country_name
FROM locations
NATURAL JOIN countries;

SELECT last_name, department_id, department_name
FROM employees
--JOIN departments USING(department_id);
NATURAL JOIN departments;

SELECT e.last_name, e.job_id, e.department_id,
      d.department_name
FROM employees e JOIN departments d      
ON (e.department_id = d.department_id)
JOIN locations l
ON (d.location_id = l.location_id)
WHERE LOWER(city) = 'toronto';


SELECT w.last_name "Employee", w.employee_id "EMP#",
      m.last_name "Manager", m.employee_id "MGR#"
FROM employees w JOIN employees m
ON (w.manager_id = m.employee_id);

SELECT w.last_name "Employee", w.employee_id "EMP#",
      m.last_name "Manager", m.employee_id "MGR#"
FROM employees w
LEFT JOIN employees m
ON (w.manager_id = m.employee_id)
ORDER BY 2;

SELECT e.department_id department, e.last_name employee,
    c.last_name colleague
FROM employees e JOIN employees c
ON (e.department_id = c.department_id)
WHERE e.employee_id <> c.employee_id
ORDER BY e.department_id, e.last_name, c.last_name;

SELECT e.last_name, e.hire_date
FROM employees e JOIN employees davies
ON (davies.last_name = 'Davies')
WHERE davies.hire_date < e.hire_date;

SELECT w.last_name, w.hire_date, m.last_name, m.hire_Date
FROM employees w JOIN employees m
ON (w.manager_id = m.employee_id)
WHERE w.hire_date < m.hire_date;

/* Pr�ctica: Using subqueries to solve queries */

UNDEFINE name;

SELECT last_name, hire_date
FROM employees
WHERE department_id = (SELECT department_id
                        FROM employees
                        WHERE last_name = '&&name')
      AND last_name <> '&&name';   
      
      
SELECT employee_id, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary)
                  FROM  employees)
ORDER BY salary;  


SELECT employee_id, last_name
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM employees
                        WHERE last_name LIKE '%u%');
                        
SELECT last_name, department_id, job_id
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM departments
                        WHERE location_id = 1700);
                        
SELECT last_name, department_id, job_id
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM departments
                        WHERE location_id = &loc);       
                        
SELECT last_name, salary
FROM employees
WHERE manager_id = (SELECT employee_id
                    FROM employees
                    WHERE employee_id = 100);
                    
SELECT department_id, last_name, job_id
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM departments
                        WHERE department_name = 'Executive');
                        
SELECT last_name 
FROM employees
WHERE salary > ANY (SELECT salary
                    FROM employees
                    WHERE department_id = 60);
                    
SELECT employee_id, last_name, salary
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM employees
                        WHERE last_name LIKE '%u%')
AND salary > (SELECT AVG(salary)
              FROM employees);                        


/* Pr�ctica: Using the Set Operators */

SELECT department_id
FROM departments
MINUS
SELECT department_id
FROM employees
WHERE job_id = 'ST_CLERK';

SELECT country_id, country_name
FROM countries
MINUS
SELECT l.country_id, c.country_name
FROM locations l JOIN countries c
ON (l.country_id = c.country_id)
JOIN departments d
ON d.location_id = l.location_id;

SELECT DISTINCT job_id, department_id
FROM employees
WHERE department_id = 10
UNION ALL
SELECT DISTINCT job_id, department_id
FROM employees
WHERE department_id = 50
UNION ALL
SELECT DISTINCT job_id, department_id
FROM employees
WHERE department_id = 20;


SELECT employee_id, job_id
FROM employees
INTERSECT
SELECT employee_id, job_id
FROM job_history;

/* Pr�ctica: Managing Schema Objects */

CREATE TABLE dept2(
  id NUMBER(7),
  name VARCHAR2(25)
);

DESCRIBE dept2;

INSERT INTO dept2
SELECT department_id, department_name
FROM departments;

SELECT * FROM dept2;

CREATE TABLE emp2(
  id NUMBER(7),
  last_name VARCHAR2(25),
  first_name VARCHAR2(25),
  dept_id NUMBER(7)
);

DESC emp2;

ALTER TABLE emp2
MODIFY(last_name  VARCHAR2(50));

DESC emp2;

CREATE TABLE employees2 AS
SELECT employee_id id, first_name, last_name, salary,
      department_id dept_id
FROM employees;    

DROP TABLE emp2;

SELECT original_name, operation, droptime
FROM recyclebin;

FLASHBACK TABLE emp2 TO BEFORE DROP;

DESC emp2;

ALTER TABLE employees2
DROP COLUMN first_name;

DESC employees2;

ALTER TABLE employees2
SET UNUSED(dept_id);

DESC employees2;

ALTER TABLE employees2
DROP UNUSED COLUMNS;

DESC employees2;

ALTER TABLE emp2
ADD CONSTRAINT emp2_pk PRIMARY KEY(id);

ALTER TABLE dept2
ADD CONSTRAINT dep2_pk PRIMARY KEY(id);

ALTER TABLE emp2
ADD CONSTRAINT dept_emp_fk 
FOREIGN KEY(dept_id) REFERENCES
dept2(id);

ALTER TABLE emp2
ADD commission NUMBER(2,2)
CONSTRAINT emp_comm_chk CHECK(commission > 0);

DROP TABLE emp2 PURGE;
DROP TABLE dept2 PURGE;

SELECT original_name, operation, droptime
FROM recyclebin;

CREATE TABLE dept_named_index(
deptno NUMBER(4)
PRIMARY KEY USING INDEX(
CREATE INDEX dept_pk_idx ON
dept_named_index(deptno)),
dname VARCHAR2(30)

);

/* Pr�ctica: Managing Objects with Data Dictionary Views*/

SELECT table_name
FROM user_tables;

SELECT table_name owner
FROM all_tables
WHERE UPPER(owner) <> 'HR';

SELECT column_name, data_type, data_length,
    data_precision PRECISION, data_scale SCALE, nullable
FROM user_tab_columns
WHERE table_name = UPPER('&tab_name');


SELECT ucc.column_name, uc.constraint_name,
  uc.constraint_type, uc.search_condition, uc.status
FROM user_constraints uc JOIN user_cons_columns ucc 
ON (uc.table_name = ucc.table_name
    AND uc.constraint_name = ucc.constraint_name
    AND uc.table_name = UPPER('&tab_name'));
    
COMMENT ON TABLE departments IS
  'Este es un comentario sobre departments';
  
SELECT comments
FROM user_tab_comments
WHERE table_name = 'DEPARTMENTS';

CREATE SYNONYM emp FOR employees;
SELECT * FROM user_synonyms;

SELECT view_name, text
FROM user_views;

SELECT sequence_name, max_value, increment_by, last_number
FROM user_sequences;

SELECT table_name
FROM user_tables
WHERE table_name IN ('DEPT2', 'EMP2');

CREATE TABLE sales_dept(
  team_id NUMBER(3)
  PRIMARY KEY USING INDEX(
    CREATE INDEX sales_pk_idx ON
    SALES_DEPT(team_id)
  ),
  location VARCHAR2(30)
);

SELECT index_name, table_name, uniqueness
FROM user_indexes
WHERE table_name = 'SALES_DEPT';


/* Pr�ctica: Creating Other Schema Objects */

CREATE OR REPLACE VIEW employees_vu AS
  SELECT employee_id, last_name employee, department_id
  FROM employees;
  
SELECT * FROM employees_vu; 

SELECT employee, department_id
FROM employees_vu;

CREATE VIEW dept50 AS
  SELECT employee_id empno, last_name employee,
        department_id deptno
  FROM employees
  WHERE department_id = 50
  WITH CHECK OPTION CONSTRAINT emp_dept_50;
  
DESC dept50;

SELECT * FROM dept50;

UPDATE dept50
SET deptno = 80
WHERE employee = 'Weiss';


CREATE SEQUENCE dept_id_seq
START WITH 200
INCREMENT BY 10
MAXVALUE 1000;

CREATE TABLE prueba2(col1 NUMBER);

INSERT INTO prueba2 VALUES (dept_id_seq.nextval);

SELECT * FROM prueba;

CREATE INDEX prueba_idx ON prueba(col1);

CREATE SYNONYM pr2 FOR prueba2;

ROLLBACK;

/* Pr�ctica: Oracle Join Syntax */

SELECT location_id, street_address, city, state_province,
      country_name
FROM locations, countries  
WHERE locations.country_id = countries.country_id;

SELECT e.last_name, e.department_id, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id;

SELECT e.last_name, e.job_id, e.department_id,
    d.department_name
FROM employees e, departments d, locations l
WHERE e.department_id = d.department_id AND
  d.location_id = l.location_id AND
  LOWER(l.city) = 'toronto';
  
SELECT w.last_name "Employee", w.employee_id "EMP#",
    m.last_name "Manager", m.employee_id "MGR#"
FROM employees w, employees m
WHERE w.manager_id = m.employee_id;

SELECT w.last_name "Employee", w.employee_id "EMP#",
    m.last_name "Manager", m.employee_id "MGR#"
FROM employees w, employees m
WHERE w.manager_id = m.employee_id(+);

SELECT e1.department_id department, e1.last_name employee,
    e2.last_name colleague
FROM employees e1, employees e2
WHERE e1.department_id = e2.department_id
  AND e1.employee_id <> e2.employee_id
ORDER BY e1.department_id, e1.last_name, e2.last_name; 


SELECT e.last_name, e.hire_date
FROM employees e, employees davies
WHERE davies.last_name = 'Davies'
  AND davies.hire_date < e.hire_date;
  
  
SELECT w.last_name, w.hire_Date, m.last_name, m.hire_date
FROM employees w, employees m
WHERE w.manager_id = m.employee_id
  AND w.hire_date < m.hire_date;

  /* Pr�ctica: Managing Data in Different Time Zones */

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';

SELECT SYSDATE FROM dual;

SELECT TZ_OFFSET('US/Pacific-New') FROM dual;
SELECT TZ_OFFSET('Singapore') FROM dual;
SELECT TZ_OFFSET('Egypt') FROM dual;

ALTER SESSION SET TIME_ZONE = '-7:00';

SELECT CURRENT_DATE, CURRENT_TIMESTAMP,
  LOCALTIMESTAMP
  FROM dual;
  
ALTER SESSION SET TIME_ZONE = '+8:00';  

SELECT CURRENT_DATE, CURRENT_TIMESTAMP,
  LOCALTIMESTAMP
  FROM dual;
  
SELECT DBTIMEZONE, SESSIONTIMEZONE FROM dual;

SELECT last_name, EXTRACT(YEAR FROM hire_date)
FROM employees
WHERE department_id = 80;

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

SELECT SYSDATE FROM dual;

SELECT e.last_name,
(CASE EXTRACT(YEAR FROM e.hire_date) WHEN 2004 THEN 'Needs Review'
ELSE 'Not this year' END) AS "Review"
FROM employees e
ORDER BY e.hire_date;


SELECT e.last_name, hire_date, SYSDATE,
        (CASE
          WHEN (SYSDATE - TO_YMINTERVAL('15-0')) >= hire_date
            THEN '15 year of service'
          WHEN (SYSDATE - TO_YMINTERVAL('10-0')) >= hire_date
            THEN '10 years of service'
          WHEN  (SYSDATE - TO_YMINTERVAL('5-0')) >= hire_date  
            THEN '5 years of service'
          ELSE 'Maybe next year' END) AS "Awards"
FROM employees e;          

/* SQL Exercises */

-- HR schema excercises

------- SELECT STATEMENT AND SINGLE-ROW FUNCTIONS

/* 1. Mostrar las columnas de jobs donde el salario m�nimo es
	mayor que 10000 */

SELECT * FROM JOBS WHERE MIN_SALARY > 10000;

/* 2. Mostrar first_name y hire_date de los empleados
	que ingresaron entre 2002 y 2005*/

SELECT FIRST_NAME, HIRE_DATE FROM EMPLOYEES 
WHERE TO_CHAR(HIRE_DATE, 'YYYY') BETWEEN 2002 AND 2005 ORDER BY HIRE_DATE;

/* 3. Mostrar first_name y hire_Date de los empleados que son
	IT Programmer o Sales Man*/

SELECT FIRST_NAME, HIRE_DATE
FROM EMPLOYEES WHERE JOB_ID IN ('IT_PROG', 'SA_MAN');

/* 4. Mostrar empleados que ingresaron despu�s del 1� de enero de 2008*/

SELECT * FROM EMPLOYEES  where hire_date > '01-jan-2008';

/* 5. Mostrar los detalles de los empleados con id 150 o 160*/

SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID in (150,160);

/* 6. Mostrar first_name, salary, commission_pct y hire_date de los
	empleados con salario menor a 10000*/

SELECT FIRST_NAME, SALARY, COMMISSION_PCT, HIRE_DATE 
FROM EMPLOYEES WHERE SALARY < 10000;

/* 7. Mostrar job_title, la diferencia etre el salario m�nimo y m�ximo
	para los jobs con max_salary en el rango de 10000 a 20000*/

SELECT JOB_TITLE, MAX_SALARY-MIN_SALARY DIFFERENCE 
FROM JOBS WHERE MAX_SALARY BETWEEN 10000 AND 20000;

/* 8. Mostrar first_name, salary y redondear el salario a millares
	de todos los empleados*/

SELECT FIRST_NAME, SALARY, ROUND(SALARY, -3) FROM EMPLOYEES;

/* 9. Mostrar los detalles de los jobs en orden descendente por title*/

SELECT * FROM JOBS ORDER BY JOB_TITLE;

/* 10. Mostrar el nombre completo de los empleados cuyo first_name
	o last_name comiece con S*/

SELECT FIRST_NAME, LAST_NAME 
FROM EMPLOYEES 
WHERE  FIRST_NAME  LIKE 'S%' OR LAST_NAME LIKE 'S%';

/* 11. Mostrar los datos de los empleados que ingresaron durante
	el mes de mayo*/

SELECT * FROM EMPLOYEES WHERE TO_CHAR(HIRE_DATE, 'MON') = 'MAY';

/* 12. Mostrar los datos de los empleados cuyo commission_pct es nulo,
tienen un salario en el rango de 5000 y 10000 y su departamento es 30*/

SELECT * FROM EMPLOYEES 
WHERE COMMISSION_PCT IS NULL 
AND SALARY BETWEEN 5000 AND 10000 AND DEPARTMENT_ID=30;

/* 13. Mostrar first_name, fecha de ingreso y el primer d�a del siguiente
  mes a la fecha de ingreso de los empleados*/

SELECT FIRST_NAME, HIRE_DATE, LAST_DAY(HIRE_DATE)+1 FROM EMPLOYEES;

/* 14. Mostrar first_name y a�os de experiencia de los empleados*/

SELECT FIRST_NAME, HIRE_DATE, FLOOR((SYSDATE-HIRE_DATE)/365)FROM EMPLOYEES;

/* 15. Mostrar first_name de los empleados que ingresaron durante
	el a�o 2001*/

SELECT first_name
FROM employees
WHERE TO_CHAR(hire_date, 'YYYY') = '2001';

/* 16. Mostrar first_name, last_name despu�s de convertir la primera letra
	de cada uno a may�scula y el resto a min�scula*/

SELECT INITCAP(FIRST_NAME), INITCAP(LAST_NAME) FROM EMPLOYEES;

/* 17. Mostrar la primera palabra de cada job_title*/

SELECT JOB_TITLE,  SUBSTR(JOB_TITLE,1, INSTR(JOB_TITLE, ' ')-1) FROM JOBS;

/* 18. Mostrar la longitud de first_name de los empelados si
	el last_name contiene el car�cter 'b' despu�s de la 3a posici�n*/

SELECT FIRST_NAME, LAST_NAME FROM EMPLOYEES WHERE INSTR(LAST_NAME,'b') > 3;

/* 19. Mostrar first_name en may�sculas, last_name en min�suclas 
	para los empleados cuya primera letra de first_name sea distinta
	de la primera letra de last_name*/

SELECT UPPER(FIRST_NAME), LOWER(LAST_NAME) 
FROM EMPLOYEES WHERE SUBSTR(FIRST_NAME, 1, 1) <> SUBSTR(LAST_NAME, 1, 1);

/* 20. Mostrar datos de los empleados que han ingresado este a�o */

SELECT * FROM EMPLOYEES 
WHERE TO_CHAR(HIRE_DATE,'YYYY') = TO_CHAR(SYSDATE, 'YYYY');

/* 21. Mostrar el n�mero de d�as entre la fecha actual y el
	1� de enero de 2011 */

SELECT SYSDATE - to_date('01-jan-2011') FROM DUAL


------ AGGREGATE FUNCTIONS AND GROUP BY CLAUSE
/* 22. Mostrar cuantos empleados por cada mes del a�o actual
	han ingresado a la compa�ia*/

SELECT TO_CHAR(HIRE_DATE,'MM'), COUNT (*) FROM EMPLOYEES 
WHERE TO_CHAR(HIRE_DATE,'YYYY') = TO_CHAR(SYSDATE,'YYYY') 
GROUP BY TO_CHAR(HIRE_DATE,'MM');

/* 23. Mostrar el manager_id y cuantos empleados tiene a su cargo*/

SELECT MANAGER_ID, COUNT(*) FROM EMPLOYEES GROUP BY MANAGER_ID;

/* 24. Mostrar el employee_id y la fecha en que termin� su
	puesto anterior (end_date)*/

SELECT EMPLOYEE_ID, MAX(END_DATE) FROM JOB_HISTORY GROUP BY EMPLOYEE_ID;

/* 25. Mostrar la cantidad de empleados que ingresaron en un d�a
	de mes mayor a 15*/

SELECT COUNT(*) FROM EMPLOYEES WHERE TO_CHAR(HIRE_DATE,'DD') > 15;

/* 26. Mostrar el country_id y el n�mero de ciudades que hay
	en ese pa�s*/

SELECT COUNTRY_ID,  COUNT(*)  FROM LOCATIONS GROUP BY COUNTRY_ID;

/* 27. Mostrar el promedio de salario de los empleados por departamento
	que tengan asignado un porcentaje de comisi�n */

SELECT DEPARTMENT_ID, AVG(SALARY) FROM EMPLOYEES 
WHERE COMMISSION_PCT IS NOT NULL GROUP BY DEPARTMENT_ID;

/* 28. Mostrar el job_id, n�mero de empleados, suma de salarios
	y diferencia del mayor y el menor salario por puesto (job_id)*/

SELECT JOB_ID, COUNT(*), SUM(SALARY), MAX(SALARY)-MIN(SALARY) SALARY 
FROM EMPLOYEES GROUP BY JOB_ID;

/* 29. Mostrar el job_id y el promedio de salarios para los puestos 
	con promedio de salario	mayor a 10000*/

SELECT JOB_ID, AVG(SALARY) FROM EMPLOYEES 
GROUP BY JOB_ID 
HAVING AVG(SALARY) > 10000;

/* 30. Mostrar los a�os en que ingresaron m�s de 10 empleados*/

SELECT TO_CHAR(HIRE_DATE,'YYYY') FROM EMPLOYEES 
GROUP BY TO_CHAR(HIRE_DATE,'YYYY') 
HAVING COUNT(EMPLOYEE_ID) > 10;

/* 31. Mostrar los departamentos en los cu�les m�s de 5 empleados
	tengan porcentaje de comisi�n */

SELECT DEPARTMENT_ID FROM EMPLOYEES 
WHERE COMMISSION_PCT IS NOT NULL
GROUP BY DEPARTMENT_ID 
HAVING COUNT(COMMISSION_PCT) > 5;

/* 32. Mostrar el employee_id de los empleados que tuvieron 
	m�s de un puesto en la compa��a*/
SELECT EMPLOYEE_ID 
FROM JOB_HISTORY GROUP BY EMPLOYEE_ID HAVING COUNT(*) > 1;

/* 33. Mostrar el job_id de los puestos que fueron ocupados
	por m�s de tres empleados que hayan trabajado m�s de 100 d�as*/

SELECT JOB_ID FROM JOB_HISTORY 
WHERE END_DATE-START_DATE > 100 
GROUP BY JOB_ID 
HAVING COUNT(*) > 3;

/* 34. Mostrar por departamento y a�o la cantidad de empleados 
	que ingresaron*/

SELECT DEPARTMENT_ID, TO_CHAR(HIRE_DATE,'YYYY'), COUNT(EMPLOYEE_ID) 
FROM EMPLOYEES 
GROUP BY DEPARTMENT_ID, TO_CHAR(HIRE_DATE, 'YYYY');
ORDER BY DEPARTMENT_ID;

/* 35. Mostrar los departament_id de los departamentos que tienen
	managers que tienen a cargo m�s de 5 empleados */

SELECT DISTINCT DEPARTMENT_ID
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID, MANAGER_ID 
HAVING COUNT(EMPLOYEE_ID) > 5;


------------------- INSERT, UPDATE, DELETE

/* 36. Cambiar el salario del empleado 115 a 8000 si el salario
	existente es menor que 6000*/

UPDATE EMPLOYEES 
SET SALARY = 8000 
WHERE EMPLOYEE_ID = 115 AND SALARY < 6000;

/* 37. Insertar un nuevo empleado con todos los campos*/

INSERT INTO EMPLOYEES  (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE,JOB_ID, SALARY, DEPARTMENT_ID) 
VALUES (207, 'ANGELA', 'SNYDER','ANGELA@DOMAIN.COM','215 253 4737', SYSDATE, 'SA_MAN', 12000, 80);

/* 38. Borrar el departamento 20 */

DELETE FROM DEPARTMENTS 
WHERE DEPARTMENT_ID=20;

/* 39. Cambiar el job_id del empleado 110 a IT_PRGO si el empleado pertenece 
	al departamento 10 y el job_id existente no empieza con 'IT' */
UPDATE EMPLOYEES SET JOB_ID= 'IT_PROG' 
WHERE EMPLOYEE_ID=110 AND DEPARTMENT_ID=10 AND NOT JOB_ID LIKE 'IT%';

/* 40. Insertar una fila en la tabla de departamentos con manager id 120
	y location id en cualquier ciudad de Tokyo */

INSERT INTO DEPARTMENTS (150,'SPORTS',120,1200);

------------------- JOINS

/* 41. Mostrar el nombre del departamento y el n�mero de empleados
	en cada uno*/

SELECT DEPARTMENT_NAME, COUNT(*) 
FROM EMPLOYEES NATURAL JOIN DEPARTMENTS GROUP BY DEPARTMENT_NAME;

/* 42. Mostrar job_title, employee_id y n�mero de d�as de diferencia
	entre end_date y start_date para los jobs del departamento 30,
	de la tabla job_history */

SELECT EMPLOYEE_ID, JOB_TITLE, END_DATE-START_DATE DAYS 
FROM JOB_HISTORY NATURAL JOIN JOBS 
WHERE DEPARTMENT_ID = 30;

/* 43. Mostrar el nombre del departamento y el nombre del manager
	a cargo del departamento*/

SELECT DEPARTMENT_NAME, FIRST_NAME 
FROM DEPARTMENTS D JOIN EMPLOYEES E ON (D.MANAGER_ID=E.EMPLOYEE_ID);

/* 44. Mostrar el nombre del departamento, el del manager a cargo
	y la ciudad a la que pertenece*/

SELECT DEPARTMENT_NAME, FIRST_NAME, CITY 
FROM DEPARTMENTS D JOIN EMPLOYEES E 
ON (D.MANAGER_ID=E.EMPLOYEE_ID) JOIN LOCATIONS L USING (LOCATION_ID);

/* 45. Mostrar nombre de departamento, y su pa�s*/

SELECT COUNTRY_NAME, DEPARTMENT_NAME 
FROM COUNTRIES JOIN LOCATIONS USING (COUNTRY_ID) 
JOIN DEPARTMENTS USING (LOCATION_ID)

/* 46. Mostrar job_title, department_name, last_name de empleado y la fecha
	de inicio de todos los puestos de 2000 a 2005*/

SELECT JOB_TITLE, DEPARTMENT_NAME, LAST_NAME, START_DATE 
FROM JOB_HISTORY 
JOIN JOBS USING (JOB_ID) 
JOIN DEPARTMENTS USING (DEPARTMENT_ID) 
JOIN  EMPLOYEES USING (EMPLOYEE_ID) 
WHERE TO_CHAR(START_DATE,'YYYY') BETWEEN 2000 AND 2005;

/* 47. Mostrar job_title y promedio de los salarios de los empleados */

SELECT JOB_TITLE, AVG(SALARY) 
FROM EMPLOYEES 
NATURAL JOIN JOBS GROUP BY JOB_TITLE;

/* 48. Mostrar job_title, first_name de empleado, y la diferencia entre al
	salary mayor y el menor para el puesto del empleado*/

SELECT JOB_TITLE, FIRST_NAME, MAX_SALARY-SALARY DIFFERENCE 
FROM EMPLOYEES NATURAL JOIN JOBS;

/* 49. Mostrar last_name, job_title de los empleados que tienen un 
	commission_pct y pertenecen al departamento 30 */

SELECT LAST_NAME, JOB_TITLE
FROM EMPLOYEES NATURAL JOIN JOBS 
WHERE COMMISSION_PCT IS NOT NULL AND DEPARTMENT_ID  = 80;

/* 50. Mostrar los detalles de los puestos ocupados por cualquier empleado
	que actualmente tenga m�s de 15000 de salario*/

SELECT JH.*
FROM  JOB_HISTORY JH 
JOIN EMPLOYEES E ON (JH.EMPLOYEE_ID = E.EMPLOYEE_ID)
WHERE SALARY > 15000;

/* 51. Mostrar department_name, nombre y salario de los managers con experiencia
	mayor a 5 a�os*/

SELECT DEPARTMENT_NAME, FIRST_NAME, SALARY 
FROM DEPARTMENTS D 
JOIN EMPLOYEES E ON (D.MANAGER_ID=E.MANAGER_ID) 
WHERE  (SYSDATE-HIRE_DATE) / 365 > 5;

/* 52. Mostrar nombre de los empleados que ingresaron antes que su manager*/ 

SELECT E1.FIRST_NAME 
FROM  EMPLOYEES E1 JOIN EMPLOYEES E2 ON (E1.MANAGER_ID=E2.EMPLOYEE_ID) 
WHERE E1.HIRE_DATE < E2.HIRE_DATE;

/* 53. Mostrar nombre, job_title para los puestos que un empleado tuvo 
	anteriormente y que dur� menos de 6 meses */
SELECT FIRST_NAME, JOB_TITLE 
FROM EMPLOYEES E 
JOIN JOB_HISTORY JH ON (JH.EMPLOYEE_ID = E.EMPLOYEE_ID) 
JOIN JOBS J  ON( JH.JOB_ID = J.JOB_ID) 
WHERE  MONTHS_BETWEEN(END_DATE,START_DATE)  < 6 ;

/* 54. Mostrar nombre del empleado y el pa�s en el que trabaja */

SELECT FIRST_NAME, COUNTRY_NAME 
FROM EMPLOYEES 
JOIN DEPARTMENTS USING(DEPARTMENT_ID) 
JOIN LOCATIONS USING( LOCATION_ID) 
JOIN COUNTRIES USING ( COUNTRY_ID);

/* 55. Mostrar department_name, promedio del salario y numero de
	empleados con commission_pct en el departamento*/

SELECT DEPARTMENT_NAME, AVG(SALARY), COUNT(COMMISSION_PCT) 
FROM DEPARTMENTS 
JOIN EMPLOYEES USING (DEPARTMENT_ID) 
GROUP BY DEPARTMENT_NAME;

/* 56. Mostrar el mes en q�e m�s de 5 empleados ingresaron
	a un departamento ubicado en Seattle*/

SELECT TO_CHAR(HIRE_DATE,'MON-YY')
FROM EMPLOYEES 
JOIN DEPARTMENTS USING (DEPARTMENT_ID) 
JOIN LOCATIONS USING (LOCATION_ID) 
WHERE  CITY = 'Seattle'
GROUP BY TO_CHAR(HIRE_DATE,'MON-YY')
HAVING COUNT(*) > 5;

-------- SUBQUERIES

/* 57. Mostrar los detalles de los departamentos en los cuales
	el salario m�ximo sea mayor a 10000*/

SELECT * 
FROM DEPARTMENTS 
WHERE DEPARTMENT_ID IN 
(SELECT DEPARTMENT_ID FROM EMPLOYEES 
  GROUP BY DEPARTMENT_ID 
  HAVING MAX(SALARY)>10000);

/* 58. Mostrar los detalles de los departamentos a cargo
	de 'Smith' */

SELECT * FROM DEPARTMENTS WHERE MANAGER_ID IN 
  (SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE last_name='SMITH');

 /* 59. Mostrar los puestos de los empleados se unieron durante el 2008 */

SELECT * FROM JOBS 
WHERE JOB_ID IN 
       (SELECT JOB_ID FROM EMPLOYEES 
       	WHERE TO_CHAR(HIRE_DATE,'YYYY')= '2008');

/* 60. Mostrar los empleados que no tienen un puesto previo
	en la compa��a */

SELECT * FROM EMPLOYEES 
WHERE EMPLOYEE_ID NOT IN 
       (SELECT EMPLOYEE_ID FROM JOB_HISTORY);


/* 61. Mostrar job_title y promedio de salario para empleados
	que ten�an un puesto previo en la compa��a */

SELECT JOB_TITLE, AVG(SALARY) 
FROM JOBS NATURAL JOIN EMPLOYEES 
GROUP BY JOB_TITLE 
WHERE EMPLOYEE_ID IN
    (SELECT EMPLOYEE_ID FROM JOB_HISTORY);

/* 62. Mostrar country_name, city y n�mero de departamentos
	donde el departamento tenga m�s de 5 empleados */

SELECT COUNTRY_NAME, CITY, COUNT(DEPARTMENT_ID)
FROM COUNTRIES 
JOIN LOCATIONS USING (COUNTRY_ID) 
JOIN DEPARTMENTS USING (LOCATION_ID) 
WHERE DEPARTMENT_ID IN 
    (SELECT DEPARTMENT_ID FROM EMPLOYEES 
	 GROUP BY DEPARTMENT_ID 
	 HAVING COUNT(DEPARTMENT_ID)>5)
GROUP BY COUNTRY_NAME, CITY;

/* 63. Mostrar el nombre de los manager que tengan a su
	cargo m�s de 5 personas */

SELECT FIRST_NAME 
FROM EMPLOYEES 
WHERE EMPLOYEE_ID IN 
(SELECT MANAGER_ID FROM EMPLOYEES 
 GROUP BY MANAGER_ID 
 HAVING COUNT(*)>5);

/* 64. Mostrar para los empleados: nombre, job_title, start_date 
	y end_date de los trabajos previos, que no tengan 
	commission_pct*/

SELECT FIRST_NAME, JOB_TITLE, START_DATE, END_DATE
FROM JOB_HISTORY JH 
JOIN JOBS J USING (JOB_ID) 
JOIN EMPLOYEES E  ON ( JH.EMPLOYEE_ID = E.EMPLOYEE_ID)
WHERE COMMISSION_PCT IS NULL;

/* 65. Mostrar los departamentos en los cuales no ha ingresado
	un empleado durante los �ltimos dos a�os */

SELECT  * FROM DEPARTMENTS
WHERE DEPARTMENT_ID NOT IN 
( SELECT DEPARTMENT_ID 
	FROM EMPLOYEES 
   WHERE FLOOR((SYSDATE-HIRE_DATE)/365) < 2);

/* 66. Mostrar los detalles de los departamentos en los cuales
	el salario m�ximo es mayor que 10000 para los empleados
	que no tuvieron un puesto previamente */

SELECT * FROM DEPARTMENTS
WHERE DEPARTMENT_ID IN 
(SELECT DEPARTMENT_ID 
  FROM EMPLOYEES 
 WHERE EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM JOB_HISTORY) 
 GROUP BY DEPARTMENT_ID
 HAVING MAX(SALARY) > 10000);

/* 67. Mostrar detalles del job actual para los empleados
	que trabajaron previamente en IT_PROG */

SELECT * 
FROM JOBS 
WHERE JOB_ID IN 
 (SELECT JOB_ID FROM EMPLOYEES WHERE EMPLOYEE_ID IN 
        (SELECT EMPLOYEE_ID FROM JOB_HISTORY WHERE JOB_ID='IT_PROG'));

 /* 68. Mostrar los detalles de los empleados que tienen el
 	mayor salario de su departamento*/

 SELECT DEPARTMENT_ID,FIRST_NAME, SALARY 
 FROM EMPLOYEES OUTER WHERE SALARY = 
    (SELECT MAX(SALARY) 
    FROM EMPLOYEES 
    WHERE DEPARTMENT_ID = OUTER.DEPARTMENT_ID);

/* 69. Mostrar la ciudad del empleado 105 */

SELECT CITY FROM LOCATIONS 
WHERE LOCATION_ID = 
    (SELECT LOCATION_ID 
    	FROM DEPARTMENTS 
    	WHERE DEPARTMENT_ID =
             	(SELECT DEPARTMENT_ID 
             		FROM EMPLOYEES 
             		WHERE EMPLOYEE_ID=105))

 /* 70. Mostrar el tercer mayor salario de los empleados */

SELECT SALARY 
FROM EMPLOYEES main
WHERE  2 = (SELECT COUNT( DISTINCT SALARY ) 
            FROM EMPLOYEES
            WHERE  SALARY > main.SALARY);

/* PLSQL Excercises */

/* 1. Programa que intercambie los salarios de los empleados
   con id 120 y 122. */
   
DECLARE
  V_salary_120 employees.salary%type;
Begin
  SELECT salary INTO V_salary_120
  FROM employees WHERE employee_id = 120;
  
  UPDATE employees SET salary = ( SELECT salary FROM employees 
                              WHERE employee_id = 122)
  WHERE employee_id = 120;            
  
  UPDATE employees SET  salary = V_salary_120 WHERE employee_id = 122;
  
  COMMIT;
END;


/* 2. Incrementar el salario del empleado 115 basado en las siguientes
  condiciones: Si la experiencia es de m�s de 10 a�os aumentar 20%,
  si la experiencia es mayor que 5 a�os aumentar 10%, en otro caso 5%.*/
  
DECLARE
  v_exp NUMBER(2);
  v_aumento NUMBER(5,2);
BEGIN
  SELECT FLOOR((SYSDATE - hire_date) / 365) INTO v_exp
  FROM employees
  WHERE employee_id = 115;
  
  v_aumento := 1.05;
  
  CASE 
    WHEN v_exp > 10 THEN
          v_aumento := 1.20;
    WHEN v_exp > 5 THEN
          v_aumento := 1.10;
  END CASE;
  
  UPDATE employees SET salary = salary * v_aumento
  WHERE employee_id = 115;
END;



/* 3. Cambiar el porcentaje de comisi�n para el empleado con id 150. Si el
  salario es mayor que 10000 cambiarlo a 0.4%. Si el salario es menor a
  10000 pero la experiencia es mayor a 10 a�os, entonces 0.35%. Si el salario
  es menor a 3000 entonces a 0.25%, en otro caso 0.15%.*/


DECLARE
  v_salary employee.salary%type;
  v_exp    NUMBER(2);
  v_porcentaje NUMBER(5,2);
BEGIN
  SELECT salary, FLOOR((SYSDATE - hire_date) / 365) INTO v_salary, v_exp
  FROM employees
  WHERE employee_id = 150;
  
  IF v_salary > 10000 THEN
          v_porcentaje := 0.4;
  ELSIF v_exp > 10 THEN
          v_porcentaje := 0.35;
  ELSIF v_salary < 3000 THEN
          v_porcentaje := 0.25;
  ELSE
          v_porcentaje := 0.15;
  END IF;
  
  UPDATE employees SET commission_pct = v_porcentaje
  WHERE employee_id = 150;
END;


/* 4. Encontrar el nombre del empleado y del departamento para el manager
    que est� a cargo del empleado id 103*/
    
DECLARE
  v_name      employees.first_name%type;
  v_deptname  departments.department_name%type;
BEGIN
  SELECT first_name, department_name INTO v_name, v_deptname
  FROM employees JOIN departments USING(department_id)
  WHERE employee_id = (SELECT manager_id FROM employees
                                    WHERE employee_id = 103);
                                    
  dbms_output.put_line(v_name);
  dbms_output.put_line(v_deptname);
END;

/* 5. Mostrar los ids de los empleados que faltan. */

DECLARE
  v_min NUMBER(3);
  v_max NUMBER(3);
  v_c   NUMBER(1);
BEGIN
  SELECT MIN(employee_id), MAX(employee_id) INTO v_min, v_max
  FROM employees;
  
  FOR i in v_min + 1 .. v_max - 1
  LOOP
      SELECT COUNT(*) INTO v_c
      FROM employees
      WHERE employee_id = i;
      
      IF v_c = 0 THEN
          dbms_output.put_line(i);
      END IF;
  END LOOP;
END;

/* 6. Mostrar el a�o en que se uni� el m�ximo n�mero de empleados
    y mostrar cuantos empleados por mes se unieron dicho a�o. */

DECLARE
  v_year  NUMBER(4);
  v_c     NUMBER(2);
BEGIN
  SELECT TO_CHAR(hire_date, 'YYYY') INTO v_year
  FROM employees
  GROUP BY TO_CHAR(hire_date, 'YYYY')
  HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                      FROM employees
                      GROUP BY TO_CHAR(hire_date, 'YYYY'));
                      
  dbms_output.put_line('Year: ' || v_year);
  
  FOR month IN 1 .. 12
  LOOP
    SELECT COUNT(*) INTO v_c
    FROM employees
    WHERE TO_CHAR(hire_date, 'MM') = month AND TO_CHAR(hire_date, 'YYYY') = v_year;
    
    dbms_output.put_line('Month: ' || TO_CHAR(month) || '# Emp: ' || TO_CHAR(v_c));
  END LOOP;
END;


/* 7. Cambiar el salario del empleado 130 por el salario del empleado de
  nombre 'Joe'. Si no se encuentra Joe, se debe tomar el promedio del 
  salario de todos los empleados. Si hay m�s de un empleado con el nombre Joe
  se deber� tomar el menor de todos los salarios de los empleados de nombre Joe*/
  
DECLARE
  v_salary employee.salary%type;
BEGIN
  SELECT salary INTO v_salary
  FROM employees
  WHERE first_name = 'Joe';
  
  UPDATE employees SET salary = v_salary
  WHERE employee_id = 130;
  
EXCEPTION
  WHEN no_data_found THEN
    UPDATE employees SET salary = (SELECT AVG(salary) FROM employees)
    WHERE employee_id = 130;
END;

/* 8. Mostrar el nombre del puesto y el nombre del empleado que
  ingres� primero a ese puesto. */
  
DECLARE
  CURSOR jobscur IS SELECT job_id, job_title FROM jobs;
  v_name employees.first_name%type;
BEGIN
  FOR jobrec IN jobscur
  LOOP
    SELECT first_name into v_name
    FROM employees
    WHERE hire_date = (SELECT MIN(hire_date)
                        FROM employees WHERE job_id = jobrec.job_id)
          AND job_id = jobrec.job_id;      
    
    dbms_output.put_line(jobrec.job_title || '-' || v_name);
  END LOOP;
END;

/* 9. Mostrar del 5� al 10� empleado de la tabla de employees */

DECLARE
  CURSOR empcur IS SELECT employee_id, first_name FROM employees;
BEGIN
  FOR emprec IN empcur
  LOOP
    IF empcur%rowcount > 4 THEN
      dbms_output.put_line(emprec.employee_id || ' ' || emprec.first_name);
      EXIT WHEN empcur%rowcount >= 10;
    END IF;
  END LOOP;
END;

/* 10. Acualizar el salario de un empleado basado en su departamento y 
  porcentaje de comisi�n. Si el departamento es 40 aumentar un 10%, si el
  departamento es 70 aumentar 15%. Si el porcentaje de comisi�n es mayor que
  0.3% aumentar 5%, en otro caso aumentar 10%*/
  
DECLARE
  CURSOR empcur IS SELECT employee_id, department_id, commission_pct
                   FROM employees;
  v_aumento NUMBER(2);                 
BEGIN
  FOR emprec IN empcur
  LOOP
    IF emprec.department_id = 40 THEN
      v_aumento := 10;
    ELSIF emprec.department_id = 70 THEN
      v_aumento := 15;
    ELSIF emprec.commission_pct > 0.3 THEN
      v_aumento := 5;
    ELSE
      v_aumento := 10;
    END IF;
    
    UPDATE employees SET salary = salary + (salary * v_aumento / 100)
    WHERE employee_id = emprec.employee_id;
  END LOOP;
END;

/* 12. Crear una funci�n que reciba el id de empleado y regrese
  el n�mero de puestos que ha tenido dicho empleado. */
  
CREATE OR REPLACE FUNCTION get_no_of_jobs(empid NUMBER)
RETURN NUMBER IS
  v_count NUMBER(2);
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM job_history
  WHERE employee_id = empid;
  
  RETURN v_count;
END;

/* 13. Crear un procedimiento que reciba el ID de departamento y cambie su
  manager por el empleado en dicho departamento con el salario m�s alto*/
  
CREATE OR REPLACE PROCEDURE change_dept_manager(deptid NUMBER)
IS
  v_empid employees.employee_id%type;
BEGIN
  SELECT employee_id INTO v_empid
  FROM employees
  WHERE salary = (SELECT MAX(salary)
                    FROM employees
                    WHERE department_id = deptid)
        AND department_id = deptid;
        
  UPDATE departments SET manager_id = v_empid
  WHERE department_id = deptid;
END;

/* 14. Crear una funci�n que reciba el manager id y regrese el nombre
  de los empleados a cargo de dicho manager, los nombres deben ser
  retornados como una cadena separada por comas. */
  
CREATE OR REPLACE FUNCTION get_employees_for_manager(manager NUMBER)
RETURN VARCHAR2 IS
  v_employees VARCHAR2(1000) := '';
  CURSOR empcur IS
    SELECT first_name FROM employees
    WHERE manager_id = manager;
BEGIN
  FOR emprec IN empcur
  LOOP
    v_employees := v_employees || ',' || emprec.first_name;
  END LOOP;
  
  RETURN LTRIM(v_employees, ',');
END;

/* 15. Asegurar que no se puedan hacer cambios en la tabla de empleados
  antes de las 6am y despu�s de las 10pm*/
  
CREATE OR REPLACE TRIGGER trg_employees_time_check
BEFORE UPDATE OR INSERT OR DELETE
ON employees
FOR EACH ROW
BEGIN
  IF TO_CHAR(SYSDATE, 'hh24') < 6 OR TO_CHAR(SYSDATE, 'hh24') > 22 THEN
    raise_application_error(-20111, 'No se permiten modificaciones');
  END IF;
END;

/* 16. Crear un trigger para asegurar que el salario de un empleado
  no disminuya */
  
CREATE OR REPLACE TRIGGER trg_employees_salary_check
BEFORE UPDATE
ON employees
FOR EACH ROW
BEGIN
  IF :old.salary > :new.salary THEN
    raise_application_error(-20111, 'No es posible cambiar el salario a
      una cantidad menor');
  END IF;
END;

/* 17. Cada que se cambie un puesto para un empleado, escribir los siguientes
  detalles en la tabla job_history. Id del empleado, antiguo job_id, fecha
    de contrataci�n para la nueva fecha de inicio, y sysdate para la fecha
    de fin. Si la fila ya existe, entonces la fecha de inicio debe ser la
    fecha de fin de esa fila + 1.*/

CREATE OR REPLACE TRIGGER trg_log_job_change
AFTER UPDATE OF job_id
ON employees
FOR EACH ROW
  v_enddate DATE;
  v_startdate DATE;
BEGIN
  SELECT MAX(end_date) INTO v_enddate
  FROM job_history
  WHERE employee_id = :old.employee_id;
  
  IF v_enddate IS NULL THEN
    v_startdate := :old.hire_date
  ELSE
    v_startdate := v_enddate + 1;
  END IF;
  
  INSERT INTO job_history VALUES (:old.employee_id, v_startdate, sysdate,
    :old.job_id, :old.department_id);
END;  


