--Estructuracion de Limon
CREATE DATABASE LIMON
GO
USE LIMON
--Configuracion Linked-Servers
--De Limon a Corporativo
EXEC sp_addlinkedserver 
    @server = 'Corporativo', 
    @srvproduct = '',
    @provider = 'SQLNCLI',
    @datasrc = 'Corporativo';

EXEC sp_addlinkedsrvlogin 
    @rmtsrvname = 'Corporativo',
    @useself = 'false',
    @locallogin = NULL,
    @rmtuser = 'sa',
    @rmtpassword = 'Contrasena1234';

--De Limon a San Jose

EXEC sp_addlinkedserver 
    @server = 'Sucursal_SanJose', 
    @srvproduct = '',
    @provider = 'SQLNCLI',
    @datasrc = 'Sucursal_SanJose';

EXEC sp_addlinkedsrvlogin 
    @rmtsrvname = 'Sucursal_SanJose',
    @useself = 'false',
    @locallogin = NULL,
    @rmtuser = 'sa',
    @rmtpassword = 'Contrasena1234';

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
SELECT * INTO Sales.Invoices FROM WideWorldImporters.Sales.Invoices WHERE 1=0;
SELECT * INTO Sales.InvoiceLines FROM WideWorldImporters.Sales.InvoiceLines WHERE 1=0;
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
INSERT INTO Sales.Invoices SELECT * FROM WideWorldImporters.Sales.Invoices;
INSERT INTO Sales.InvoiceLines SELECT * FROM WideWorldImporters.Sales.InvoiceLines;

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

