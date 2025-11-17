--Estructuracion de Corporativo
CREATE DATABASE CORPORATIVO
GO
USE CORPORATIVO
-- Tabla Usuarios
-- rol = 0: Corporativo
-- rol = 1: Administrador
CREATE TABLE Usuarios (
	iduser INT IDENTITY,
	username NVARCHAR(30),
	password VARBINARY(8000),
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
	   PostalCityID,
	   PostalAddressLine1,
	   PostalAddressLine2,
	   DeliveryLocation
INTO Sales.Customers
FROM WideWorldImporters.Sales.Customers cu
WHERE 1=0;

--Estructura Items
SELECT * INTO Warehouse.StockItems FROM WideWorldImporters.Warehouse.StockItems WHERE 1=0;
--Estructura Proveedores
SELECT * INTO Purchasing.Suppliers FROM WideWorldImporters.Purchasing.Suppliers WHERE 1=0;
SELECT * INTO Purchasing.SupplierCategories FROM WideWorldImporters.Purchasing.SupplierCategories WHERE 1=0;
SELECT * INTO Purchasing.PurchaseOrders FROM WideWorldImporters.Purchasing.PurchaseOrders WHERE 1=0;
SELECT * INTO Purchasing.PurchaseOrderLines FROM WideWorldImporters.Purchasing.PurchaseOrderLines WHERE 1=0;
--Estructura Personas
SELECT * INTO Application.People FROM WideWorldImporters.Application.People WHERE 1=0;
SELECT * INTO Application.Cities FROM WideWorldImporters.Application.Cities WHERE 1=0;
SELECT * INTO Application.DeliveryMethods FROM WideWorldImporters.Application.DeliveryMethods WHERE 1=0;

--Migracion de Datos
-- Cat�logos
INSERT INTO Warehouse.StockItems SELECT * FROM WideWorldImporters.Warehouse.StockItems;
ALTER TABLE Warehouse.StockItems
ADD CONSTRAINT PK_StockItems PRIMARY KEY (StockItemID);
INSERT INTO Purchasing.Suppliers SELECT * FROM WideWorldImporters.Purchasing.Suppliers;
INSERT INTO Purchasing.SupplierCategories SELECT * FROM WideWorldImporters.Purchasing.SupplierCategories;
INSERT INTO Application.People SELECT * FROM WideWorldImporters.Application.People;
INSERT INTO Application.Cities SELECT * FROM WideWorldImporters.Application.Cities;
INSERT INTO Application.DeliveryMethods SELECT * FROM WideWorldImporters.Application.DeliveryMethods;
INSERT INTO Purchasing.PurchaseOrders SELECT * FROM WideWorldImporters.Purchasing.PurchaseOrders;
INSERT INTO Purchasing.PurchaseOrderLines SELECT * FROM WideWorldImporters.Purchasing.PurchaseOrderLines;
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
	   PostalCityID,
	   PostalAddressLine1,
	   PostalAddressLine2,
	   DeliveryLocation)
SELECT CustomerID, CustomerName,PrimaryContactPersonID,AlternateContactPersonID, PhoneNumber, FaxNumber, WebsiteURL,
       DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryCityID, PostalCityID, PostalAddressLine1, PostalAddressLine2, DeliveryLocation
FROM WideWorldImporters.Sales.Customers

INSERT INTO Usuarios (username, fullname, email, password, rol, active)
VALUES 
('admin', 'Administrador General', 'admin@empresa.com',
 HASHBYTES('SHA2_512', 'admin123'), 0, 1),

('corporativo', 'Usuario Corporativo', 'corporativo@empresa.com',
 HASHBYTES('SHA2_512', 'corporativo123'), 1, 1);