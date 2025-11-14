--Estructuracion de Sucursales

--Creacion de bases de datos
CREATE DATABASE CORPORATIVO
CREATE DATABASE SANJOSE
CREATE DATABASE LIMON
GO

--Estructuracion de Corporativo
USE CORPORATIVO

-- Tabla Usuarios
-- rol = 0: Corporativo
-- rol = 1: Administrador
CREATE TABLE Usuarios (
	iduser INT IDENTITY,
	username NVARCHAR(30),
	password NVARCHAR(30),
	fullname NVARCHAR(40),
	active INT CHECK (active = 0 OR active = 1),
	rol INT CHECK (rol = 0 OR rol = 1),
	email NVARCHAR(30),
	hiredate DATE
);
GO
--Creacion de esquemas
CREATE SCHEMA Sales
GO
CREATE SCHEMA Warehouse
GO
CREATE SCHEMA Purchasing
GO
CREATE SCHEMA Application
GO
--Estructuracion de Clientes
SELECT CustomerID,
	   CustomerName,
	   PrimaryContactPersonID,
	   AlternateContactPersonID, 
	   PhoneNumber, 
	   FaxNumber, 
	   WebsiteURL, 
	   DeliveryAddressLine1,
       DeliveryAddressLine2,
	   DeliveryPostalCode, 
	   DeliveryCityID,
	   PostalCityID
INTO Sales.Customers
FROM WideWorldImporters.Sales.Customers cu
WHERE 1=0;

--Estructura Items
SELECT * INTO Warehouse.StockItems FROM WideWorldImporters.Warehouse.StockItems WHERE 1=0;
--Estructura Proveedores
SELECT * INTO Purchasing.Suppliers FROM WideWorldImporters.Purchasing.Suppliers WHERE 1=0;
SELECT * INTO Purchasing.PurchaseOrders FROM WideWorldImporters.Purchasing.PurchaseOrders WHERE 1=0;
SELECT * INTO Purchasing.PurchaseOrderLines FROM WideWorldImporters.Purchasing.PurchaseOrderLines WHERE 1=0;
--Estructura Personas
SELECT * INTO Application.People FROM WideWorldImporters.Application.People WHERE 1=0;
SELECT * INTO Application.Cities FROM WideWorldImporters.Application.Cities WHERE 1=0;
--Estructuracion de San Jose
USE SANJOSE
--Creacion de esquemas
GO
CREATE SCHEMA Sales
GO
CREATE SCHEMA Warehouse
GO
CREATE SCHEMA Purchasing
GO
CREATE SCHEMA Application
GO

--Estructura clientes
SELECT CustomerID,
	   CustomerName,
	   BuyingGroupID,
	   CustomerCategoryID,
	   BillToCustomerID,
	   CreditLimit,
	   PaymentDays,
	   AccountOpenedDate,
	   DeliveryMethodID
INTO Sales.Customers
FROM WideWorldImporters.Sales.Customers
WHERE 1=0;

SELECT * INTO Sales.BuyingGroups FROM WideWorldImporters.Sales.BuyingGroups WHERE 1=0;
SELECT * INTO Sales.CustomerCategories FROM WideWorldImporters.Sales.CustomerCategories WHERE 1=0;
-- Pedidos y facturación
SELECT * INTO Sales.Orders FROM WideWorldImporters.Sales.Orders WHERE 1=0;
SELECT * INTO Sales.OrderLines FROM WideWorldImporters.Sales.OrderLines WHERE 1=0;

--Estructura Items
SELECT * INTO Warehouse.StockItems FROM WideWorldImporters.Warehouse.StockItems WHERE 1=0;
-- Inventario local
SELECT * INTO Warehouse.StockItemHoldings FROM WideWorldImporters.Warehouse.StockItemHoldings WHERE 1=0;
SELECT * INTO Warehouse.StockItemStockGroups FROM WideWorldImporters.Warehouse.StockItemStockGroups WHERE 1=0;
SELECT * INTO Warehouse.StockGroups FROM WideWorldImporters.Warehouse.StockGroups WHERE 1=0;
SELECT * INTO Warehouse.Colors FROM WideWorldImporters.Warehouse.Colors WHERE 1=0;
SELECT * INTO Warehouse.PackageTypes FROM WideWorldImporters.Warehouse.PackageTypes WHERE 1=0;
--Estructura Proveedores
SELECT * INTO Purchasing.Suppliers FROM WideWorldImporters.Purchasing.Suppliers WHERE 1=0;

SELECT * INTO Application.DeliveryMethods FROM WideWorldImporters.Application.DeliveryMethods WHERE 1=0;




--Estructuracion de Limon
USE LIMON
--Creacion de esquemas
GO
CREATE SCHEMA Sales
GO
CREATE SCHEMA Warehouse
GO
CREATE SCHEMA Purchasing
GO
CREATE SCHEMA Application
GO

--Estructura clientes
SELECT CustomerID,
	   CustomerName,
	   BuyingGroupID,
	   CustomerCategoryID,
	   BillToCustomerID,
	   CreditLimit,
	   PaymentDays,
	   AccountOpenedDate,
	   DeliveryMethodID
INTO Sales.Customers
FROM WideWorldImporters.Sales.Customers
WHERE 1=0;

SELECT * INTO Sales.BuyingGroups FROM WideWorldImporters.Sales.BuyingGroups WHERE 1=0;
SELECT * INTO Sales.CustomerCategories FROM WideWorldImporters.Sales.CustomerCategories WHERE 1=0;
-- Pedidos y facturación
SELECT * INTO Sales.Orders FROM WideWorldImporters.Sales.Orders WHERE 1=0;
SELECT * INTO Sales.OrderLines FROM WideWorldImporters.Sales.OrderLines WHERE 1=0;

--Estructura Items
SELECT * INTO Warehouse.StockItems FROM WideWorldImporters.Warehouse.StockItems WHERE 1=0;
-- Inventario local
SELECT * INTO Warehouse.StockItemHoldings FROM WideWorldImporters.Warehouse.StockItemHoldings WHERE 1=0;
SELECT * INTO Warehouse.StockItemStockGroups FROM WideWorldImporters.Warehouse.StockItemStockGroups WHERE 1=0;
SELECT * INTO Warehouse.StockGroups FROM WideWorldImporters.Warehouse.StockGroups WHERE 1=0;
SELECT * INTO Warehouse.Colors FROM WideWorldImporters.Warehouse.Colors WHERE 1=0;
SELECT * INTO Warehouse.PackageTypes FROM WideWorldImporters.Warehouse.PackageTypes WHERE 1=0;
--Estructura Proveedores
SELECT * INTO Purchasing.Suppliers FROM WideWorldImporters.Purchasing.Suppliers WHERE 1=0;

SELECT * INTO Application.DeliveryMethods FROM WideWorldImporters.Application.DeliveryMethods WHERE 1=0;


--Migracion de Datos

USE CORPORATIVO
GO
-- Catálogos
INSERT INTO Warehouse.StockItems SELECT * FROM WideWorldImporters.Warehouse.StockItems;
INSERT INTO Purchasing.Suppliers SELECT * FROM WideWorldImporters.Purchasing.Suppliers;
INSERT INTO Application.People SELECT * FROM WideWorldImporters.Application.People;
INSERT INTO Application.Cities SELECT * FROM WideWorldImporters.Application.Cities WHERE 1=0;
INSERT INTO Sales.Customers (CustomerID,
	   CustomerName,
	   PrimaryContactPersonID,
	   AlternateContactPersonID, 
	   PhoneNumber, 
	   FaxNumber, 
	   WebsiteURL, 
	   DeliveryAddressLine1,
       DeliveryAddressLine2,
	   DeliveryPostalCode, 
	   DeliveryCityID,
	   PostalCityID)
SELECT CustomerID, CustomerName,PrimaryContactPersonID,AlternateContactPersonID, PhoneNumber, FaxNumber, WebsiteURL,
       DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryCityID, PostalCityID
FROM WideWorldImporters.Sales.Customers

USE SANJOSE
GO
-- Catálogos
INSERT INTO Sales.CustomerCategories SELECT * FROM WideWorldImporters.Sales.CustomerCategories;
INSERT INTO Sales.BuyingGroups SELECT * FROM WideWorldImporters.Sales.BuyingGroups;
INSERT INTO Sales.OrderLines SELECT * FROM WideWorldImporters.Sales.OrderLines;
INSERT INTO Sales.Orders SELECT * FROM WideWorldImporters.Sales.Orders;
INSERT INTO Warehouse.StockItemStockGroups SELECT * FROM WideWorldImporters.Warehouse.StockItemStockGroups;
INSERT INTO Warehouse.StockGroups SELECT * FROM WideWorldImporters.Warehouse.StockGroups;
INSERT INTO Warehouse.Colors SELECT * FROM WideWorldImporters.Warehouse.Colors;
INSERT INTO Application.DeliveryMethods SELECT * FROM WideWorldImporters.Application.DeliveryMethods;
INSERT INTO Warehouse.StockItems SELECT * FROM WideWorldImporters.Warehouse.StockItems;
INSERT INTO Purchasing.Suppliers SELECT * FROM WideWorldImporters.Purchasing.Suppliers;
INSERT INTO Warehouse.StockItemHoldings SELECT * FROM WideWorldImporters.Warehouse.StockItemHoldings;
INSERT INTO Warehouse.PackageTypes SELECT * FROM WideWorldImporters.Warehouse.PackageTypes;

INSERT INTO Sales.Customers (CustomerID,
	   CustomerName,
	   BuyingGroupID,
	   CustomerCategoryID,
	   BillToCustomerID,
	   CreditLimit,
	   PaymentDays,
	   AccountOpenedDate,
	   DeliveryMethodID) 
SELECT CustomerID,CustomerName,BuyingGroupID,
CustomerCategoryID,
BillToCustomerID,
CreditLimit,
PaymentDays,
AccountOpenedDate,
DeliveryMethodID
FROM WideWorldImporters.Sales.Customers cu



USE LIMON
GO
-- Catálogos
INSERT INTO Sales.CustomerCategories SELECT * FROM WideWorldImporters.Sales.CustomerCategories;
INSERT INTO Sales.BuyingGroups SELECT * FROM WideWorldImporters.Sales.BuyingGroups;
INSERT INTO Sales.OrderLines SELECT * FROM WideWorldImporters.Sales.OrderLines;
INSERT INTO Sales.Orders SELECT * FROM WideWorldImporters.Sales.Orders;
INSERT INTO Warehouse.StockItemStockGroups SELECT * FROM WideWorldImporters.Warehouse.StockItemStockGroups;
INSERT INTO Warehouse.StockGroups SELECT * FROM WideWorldImporters.Warehouse.StockGroups;
INSERT INTO Warehouse.Colors SELECT * FROM WideWorldImporters.Warehouse.Colors;
INSERT INTO Application.DeliveryMethods SELECT * FROM WideWorldImporters.Application.DeliveryMethods;
INSERT INTO Warehouse.StockItems SELECT * FROM WideWorldImporters.Warehouse.StockItems;
INSERT INTO Purchasing.Suppliers SELECT * FROM WideWorldImporters.Purchasing.Suppliers;
INSERT INTO Warehouse.StockItemHoldings SELECT * FROM WideWorldImporters.Warehouse.StockItemHoldings;
INSERT INTO Warehouse.PackageTypes SELECT * FROM WideWorldImporters.Warehouse.PackageTypes;

INSERT INTO Sales.Customers (CustomerID,
	   CustomerName,
	   BuyingGroupID,
	   CustomerCategoryID,
	   BillToCustomerID,
	   CreditLimit,
	   PaymentDays,
	   AccountOpenedDate,
	   DeliveryMethodID) 
SELECT CustomerID,CustomerName,BuyingGroupID,
CustomerCategoryID,
BillToCustomerID,
CreditLimit,
PaymentDays,
AccountOpenedDate,
DeliveryMethodID
FROM WideWorldImporters.Sales.Customers cu

