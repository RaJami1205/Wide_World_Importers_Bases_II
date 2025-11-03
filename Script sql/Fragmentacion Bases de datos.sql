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
	   DeliveryLocation,
	   CityName
INTO Sales.Customers
FROM WideWorldImporters.Sales.Customers cu
JOIN WideWorldImporters.Application.Cities ci ON (cu.DeliveryCityID = ci.CityID)
WHERE 1=0;

--Estructura Items
SELECT * INTO Warehouse.StockItems FROM WideWorldImporters.Warehouse.StockItems WHERE 1=0;
--Estructura Proveedores
SELECT * INTO Purchasing.Suppliers FROM WideWorldImporters.Purchasing.Suppliers WHERE 1=0;
--Estructura Personas
SELECT * INTO Application.People FROM WideWorldImporters.Application.People WHERE 1=0;

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

--Estructura clientes
SELECT CustomerID,
	   CustomerName,
	   BuyingGroupName,
	   CustomerCategoryName,
	   BillToCustomerID,
	   CreditLimit,
	   PaymentDays,
	   AccountOpenedDate

INTO Sales.Customers
FROM WideWorldImporters.Sales.Customers cu
JOIN WideWorldImporters.Sales.BuyingGroups bg ON (cu.BuyingGroupID = bg.BuyingGroupID)
JOIN WideWorldImporters.Sales.CustomerCategories cg ON (cu.CustomerCategoryID = cg.CustomerCategoryID)
WHERE 1=0;

--Estructura Items
SELECT * INTO Warehouse.StockItems FROM WideWorldImporters.Warehouse.StockItems WHERE 1=0;
--Estructura Proveedores
SELECT * INTO Purchasing.Suppliers FROM WideWorldImporters.Purchasing.Suppliers WHERE 1=0;

-- Pedidos y facturación
SELECT * INTO Sales.Orders FROM WideWorldImporters.Sales.Orders WHERE 1=0;
SELECT * INTO Sales.OrderLines FROM WideWorldImporters.Sales.OrderLines WHERE 1=0;

-- Inventario local
SELECT * INTO Warehouse.StockItemHoldings FROM WideWorldImporters.Warehouse.StockItemHoldings WHERE 1=0;


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

--Estructura clientes
SELECT CustomerID,
	   CustomerName,
	   BuyingGroupName,
	   CustomerCategoryName,
	   BillToCustomerID,
	   CreditLimit,
	   PaymentDays,
	   AccountOpenedDate

INTO Sales.Customers
FROM WideWorldImporters.Sales.Customers cu
JOIN WideWorldImporters.Sales.BuyingGroups bg ON (cu.BuyingGroupID = bg.BuyingGroupID)
JOIN WideWorldImporters.Sales.CustomerCategories cg ON (cu.CustomerCategoryID = cg.CustomerCategoryID)
WHERE 1=0;

--Estructura Items
SELECT * INTO Warehouse.StockItems FROM WideWorldImporters.Warehouse.StockItems WHERE 1=0;
--Estructura Proveedores
SELECT * INTO Purchasing.Suppliers FROM WideWorldImporters.Purchasing.Suppliers WHERE 1=0;

-- Pedidos y facturación
SELECT * INTO Sales.Orders FROM WideWorldImporters.Sales.Orders WHERE 1=0;
SELECT * INTO Sales.OrderLines FROM WideWorldImporters.Sales.OrderLines WHERE 1=0;

-- Inventario local
SELECT * INTO Warehouse.StockItemHoldings FROM WideWorldImporters.Warehouse.StockItemHoldings WHERE 1=0;


--Migracion de Datos

USE CORPORATIVO
GO
-- Catálogos
INSERT INTO Warehouse.StockItems SELECT * FROM WideWorldImporters.Warehouse.StockItems;
INSERT INTO Purchasing.Suppliers SELECT * FROM WideWorldImporters.Purchasing.Suppliers;
INSERT INTO Application.People SELECT * FROM WideWorldImporters.Application.People;
INSERT INTO Sales.Customers (CustomerID, CustomerName,PrimaryContactPersonID,AlternateContactPersonID, PhoneNumber, FaxNumber, WebsiteURL,
       DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, CityName)
SELECT CustomerID, CustomerName,PrimaryContactPersonID,AlternateContactPersonID, PhoneNumber, FaxNumber, WebsiteURL,
       DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, CityName
FROM WideWorldImporters.Sales.Customers cu
JOIN WideWorldImporters.Application.Cities ci ON (cu.DeliveryCityID = ci.CityID)

USE SANJOSE
GO
-- Catálogos
INSERT INTO Warehouse.StockItems SELECT * FROM WideWorldImporters.Warehouse.StockItems;
INSERT INTO Purchasing.Suppliers SELECT * FROM WideWorldImporters.Purchasing.Suppliers;
INSERT INTO Warehouse.StockItemHoldings SELECT * FROM WideWorldImporters.Warehouse.StockItemHoldings;

INSERT INTO Sales.Customers (CustomerID,CustomerName,BuyingGroupName,CustomerCategoryName,BillToCustomerID,CreditLimit,PaymentDays, AccountOpenedDate) 
SELECT CustomerID,CustomerName,
CASE 
 WHEN BuyingGroupName IS NULL THEN ''
 ELSE BuyingGroupName
 END AS BuyingGroupName,
CustomerCategoryName,
BillToCustomerID,
CreditLimit,
PaymentDays,
AccountOpenedDate
FROM WideWorldImporters.Sales.Customers cu
LEFT JOIN WideWorldImporters.Sales.BuyingGroups bg ON (cu.BuyingGroupID = bg.BuyingGroupID)
LEFT JOIN WideWorldImporters.Sales.CustomerCategories cg ON (cu.CustomerCategoryID = cg.CustomerCategoryID)



USE LIMON
GO
-- Catálogos
INSERT INTO Warehouse.StockItems SELECT * FROM WideWorldImporters.Warehouse.StockItems;
INSERT INTO Purchasing.Suppliers SELECT * FROM WideWorldImporters.Purchasing.Suppliers;
INSERT INTO Warehouse.StockItemHoldings SELECT * FROM WideWorldImporters.Warehouse.StockItemHoldings;

INSERT INTO Sales.Customers (CustomerID,CustomerName,BuyingGroupName,CustomerCategoryName,BillToCustomerID,CreditLimit,PaymentDays, AccountOpenedDate) 
SELECT CustomerID,
CustomerName,
CASE 
 WHEN BuyingGroupName IS NULL THEN ''
 ELSE BuyingGroupName
 END AS BuyingGroupName,
CustomerCategoryName,
BillToCustomerID,
CreditLimit,
PaymentDays,
AccountOpenedDate
FROM WideWorldImporters.Sales.Customers cu
LEFT JOIN WideWorldImporters.Sales.BuyingGroups bg ON (cu.BuyingGroupID = bg.BuyingGroupID)
LEFT JOIN WideWorldImporters.Sales.CustomerCategories cg ON (cu.CustomerCategoryID = cg.CustomerCategoryID)
