CREATE PROCEDURE ObtenerClientes
	@Nombre NVARCHAR(100)= NULL,
	@Categoria NVARCHAR(100)= NULL,
	@MetodoEntrega NVARCHAR(100)= NULL

AS
BEGIN
	SELECT cu.CustomerName AS NombreCliente, ca.CustomerCategoryName AS CategoriaCliente, dm.DeliveryMethodName AS MetodoEntrega
	FROM Sales.Customers cu
	JOIN Sales.CustomerCategories ca ON (cu.CustomerCategoryID = ca.CustomerCategoryID)
	JOIN Application.DeliveryMethods dm ON (cu.DeliveryMethodID = dm.DeliveryMethodID)
	WHERE ( @Nombre IS NULL OR cu.CustomerName LIKE '%' + @Nombre + '%') AND
	( @Categoria IS NULL OR ca.CustomerCategoryName LIKE '%' + @Categoria + '%') AND
	( @MetodoEntrega IS NULL OR dm.DeliveryMethodName LIKE '%' + @MetodoEntrega + '%')
	ORDER BY cu.CustomerName ASC
END;
GO 


CREATE PROCEDURE InformacionCliente
	@Nombre NVARCHAR(100)

AS 
BEGIN
	SELECT cu.CustomerName AS NombreCliente, 
	ca.CustomerCategoryName AS CategoriaCliente,
	bg.BuyingGroupName AS GrupoCompra, 
	CASE 
		WHEN pe1.FullName IS NOT NULL AND pe1.EmailAddress IS NOT NULL THEN CONCAT(pe1.FullName,',',pe1.EmailAddress)
		WHEN pe1.FullName IS NULL AND pe1.EmailAddress IS NOT NULL THEN pe1.EmailAddress
		WHEN pe1.FullName IS NOT NULL AND pe1.EmailAddress IS NULL THEN pe1.FullName
		ELSE NULL
		END AS ContactoPrincipal,
	CASE
		WHEN pe2.FullName IS NOT NULL AND pe2.EmailAddress IS NOT NULL THEN CONCAT(pe2.FullName,',',pe2.EmailAddress)
		WHEN pe2.FullName IS NULL AND pe2.EmailAddress IS NOT NULL THEN pe2.EmailAddress
		WHEN pe2.FullName IS NOT NULL AND pe2.EmailAddress IS NULL THEN pe2.FullName
		ELSE NULL
		END AS ContactoAlternativo,
	cu.BillToCustomerID AS ClienteAFacturar, 
	dm.DeliveryMethodName AS MetodoEntrega,
	ci.CityName AS CiudadEntrega,
	cu.DeliveryPostalCode AS CodigoPostal,
	cu.FaxNumber AS Fax,
	cu.PhoneNumber AS Telefono,
	cu.PaymentDays AS DiasPagar,
	cu.WebsiteURL AS SitioWeb,
	CASE 
		WHEN cu.DeliveryAddressLine1 IS NOT NULL AND cu.DeliveryAddressLine2 IS NOT NULL THEN CONCAT(cu.DeliveryAddressLine1,',',cu.DeliveryAddressLine2)
		WHEN cu.DeliveryAddressLine1 IS NULL AND cu.DeliveryAddressLine2 IS NOT NULL THEN cu.DeliveryAddressLine2
		WHEN cu.DeliveryAddressLine1 IS NOT NULL AND cu.DeliveryAddressLine2 IS NULL THEN cu.DeliveryAddressLine1
		ELSE NULL
		END AS Direccion,
	CASE
		WHEN cu.PostalAddressLine1 IS NOT NULL AND cu.PostalAddressLine2 IS NOT NULL THEN CONCAT(cu.PostalAddressLine1,',',cu.PostalAddressLine2)
		WHEN cu.PostalAddressLine1 IS NULL AND cu.PostalAddressLine2 IS NOT NULL THEN cu.PostalAddressLine2
		WHEN cu.PostalAddressLine1 IS NOT NULL AND cu.PostalAddressLine2 IS NULL THEN cu.PostalAddressLine1
		ELSE NULL
		END AS DireccionPostal,
	cu.DeliveryLocation AS MapaLocalizacion
	FROM Sales.Customers cu
	LEFT JOIN Sales.CustomerCategories ca ON (cu.CustomerCategoryID = ca.CustomerCategoryID)
	LEFT JOIN Sales.BuyingGroups bg ON (cu.BuyingGroupID = bg.BuyingGroupID)
	LEFT JOIN Application.DeliveryMethods dm ON (cu.DeliveryMethodID = dm.DeliveryMethodID)
	LEFT JOIN Application.Cities ci ON (cu.DeliveryCityID = ci.CityID)
	LEFT JOIN Application.People pe1 ON (cu.PrimaryContactPersonID = pe1.PersonID)
	LEFT JOIN Application.People pe2 ON (cu.AlternateContactPersonID = pe2.PersonID)
	WHERE cu.CustomerName = @Nombre
END;
GO


CREATE PROCEDURE ObtenerProveedores
	@Nombre NVARCHAR(100)= NULL,
	@Categoria NVARCHAR(100)= NULL,
	@MetodoEntrega NVARCHAR(100)= NULL

AS
BEGIN
	SELECT su.SupplierName AS NombreProveedor, sc.SupplierCategoryName AS CategoriaProveedor, dm.DeliveryMethodName AS MetodoEntrega
	FROM Purchasing.Suppliers su
	LEFT JOIN Purchasing.SupplierCategories sc ON (su.SupplierCategoryID = sc.SupplierCategoryID)
	LEFT JOIN Application.DeliveryMethods dm ON (su.DeliveryMethodID = dm.DeliveryMethodID)
	WHERE ( @Nombre IS NULL OR su.SupplierName LIKE '%' + @Nombre + '%') AND
	( @Categoria IS NULL OR sc.SupplierCategoryName LIKE '%' + @Categoria + '%') AND
	( @MetodoEntrega IS NULL OR dm.DeliveryMethodName LIKE '%' + @MetodoEntrega + '%')
	ORDER BY su.SupplierName ASC
END;
GO 

CREATE PROCEDURE InformacionProveedor
	@Nombre NVARCHAR(100)

AS 
BEGIN
	SELECT su.SupplierReference AS CodigoProveedor,
	su.SupplierName AS NombreProveedor, 
	sc.SupplierCategoryName AS CategoriaProveedor,
	CASE 
		WHEN pe1.FullName IS NOT NULL AND pe1.EmailAddress IS NOT NULL THEN CONCAT(pe1.FullName,',',pe1.EmailAddress)
		WHEN pe1.FullName IS NULL AND pe1.EmailAddress IS NOT NULL THEN pe1.EmailAddress
		WHEN pe1.FullName IS NOT NULL AND pe1.EmailAddress IS NULL THEN pe1.FullName
		ELSE NULL
		END AS ContactoPrincipal,
	CASE
		WHEN pe2.FullName IS NOT NULL AND pe2.EmailAddress IS NOT NULL THEN CONCAT(pe2.FullName,',',pe2.EmailAddress)
		WHEN pe2.FullName IS NULL AND pe2.EmailAddress IS NOT NULL THEN pe2.EmailAddress
		WHEN pe2.FullName IS NOT NULL AND pe2.EmailAddress IS NULL THEN pe2.FullName
		ELSE NULL
		END AS ContactoAlternativo,
	dm.DeliveryMethodName AS MetodoEntrega,
	ci.CityName AS CiudadEntrega,
	su.DeliveryPostalCode AS CodigoPostal,
	su.FaxNumber AS FAX,
	su.PhoneNumber AS Telefono,
	su.WebsiteURL AS SitioWeb,
	CASE 
		WHEN su.DeliveryAddressLine1 IS NOT NULL AND su.DeliveryAddressLine2 IS NOT NULL THEN CONCAT(su.DeliveryAddressLine1,',',su.DeliveryAddressLine2)
		WHEN su.DeliveryAddressLine1 IS NULL AND su.DeliveryAddressLine2 IS NOT NULL THEN su.DeliveryAddressLine2
		WHEN su.DeliveryAddressLine1 IS NOT NULL AND su.DeliveryAddressLine2 IS NULL THEN su.DeliveryAddressLine1
		ELSE NULL
		END AS Direccion,
	CASE
		WHEN su.PostalAddressLine1 IS NOT NULL AND su.PostalAddressLine2 IS NOT NULL THEN CONCAT(su.PostalAddressLine1,',',su.PostalAddressLine2)
		WHEN su.PostalAddressLine1 IS NULL AND su.PostalAddressLine2 IS NOT NULL THEN su.PostalAddressLine2
		WHEN su.PostalAddressLine1 IS NOT NULL AND su.PostalAddressLine2 IS NULL THEN su.PostalAddressLine1
		ELSE NULL
		END AS DireccionPostal,
	su.DeliveryLocation AS MapaLocalizacion,
	su.BankAccountName AS NombreBanco,
	su.BankAccountNumber AS NumeroCuentaCorriente,
	su.PaymentDays AS DiasPagar
	FROM Purchasing.Suppliers su
	LEFT JOIN Purchasing.SupplierCategories sc ON (su.SupplierCategoryID = sc.SupplierCategoryID)
	LEFT JOIN Application.DeliveryMethods dm ON (su.DeliveryMethodID = dm.DeliveryMethodID)
	LEFT JOIN Application.Cities ci ON (su.DeliveryCityID = ci.CityID)
	LEFT JOIN Application.People pe1 ON (su.PrimaryContactPersonID = pe1.PersonID)
	LEFT JOIN Application.People pe2 ON (su.AlternateContactPersonID = pe2.PersonID)
	WHERE su.SupplierName = @Nombre
END;
GO

CREATE PROCEDURE ObtenerInventarios
	@Nombre NVARCHAR(100) = NULL,
	@Grupo NVARCHAR(100) = NULL,
	@CantidadMinima INT = NULL,
	@CantidadMaxima INT = NULL
AS
BEGIN
	SELECT 
		si.StockItemName AS NombreProducto,
        STRING_AGG(sg.StockGroupName, ', ') AS GrupoProducto,
		sih.QuantityOnHand AS CantidadProducto
	FROM Warehouse.StockItems si
	JOIN Warehouse.StockItemHoldings sih 
		ON si.StockItemID = sih.StockItemID
	JOIN Warehouse.StockItemStockGroups sisg 
		ON si.StockItemID = sisg.StockItemID
	JOIN Warehouse.StockGroups sg 
		ON sisg.StockGroupID = sg.StockGroupID
	WHERE 
		(@Nombre IS NULL OR si.StockItemName LIKE '%' + @Nombre + '%') AND
		(@Grupo IS NULL OR sg.StockGroupName LIKE '%' + @Grupo + '%') AND
		(@CantidadMinima IS NULL OR sih.QuantityOnHand >= @CantidadMinima) AND
		(@CantidadMaxima IS NULL OR sih.QuantityOnHand <= @CantidadMaxima)
	GROUP BY si.StockItemName, sih.QuantityOnHand
	ORDER BY si.StockItemName ASC;
END;
GO

CREATE PROCEDURE InformacionInventario
	@Nombre NVARCHAR(100)
AS
BEGIN
	SELECT si.StockItemName AS NombreProducto,
	su.SupplierName AS NombreProveedor,
	c.ColorName AS Color,
	sg1.StockGroupName AS UnitPackage,
	sg2.StockGroupName AS OuterPackage,
	sih.QuantityOnHand AS CantidadProducto,
	si.Brand AS Marcas,
	si.Size AS Tallas,
	si.TaxRate AS Impuesto,
	si.UnitPrice AS PrecioUnitario
	FROM Warehouse.StockItems si
	LEFT JOIN Warehouse.StockGroups sg1 ON (si.UnitPackageID = sg1.StockGroupID)
	LEFT JOIN Warehouse.StockGroups sg2 ON (si.OuterPackageID = sg2.StockGroupID)
	LEFT JOIN Warehouse.StockItemHoldings sih ON (si.StockItemID = sih.StockItemID)
	LEFT JOIN Warehouse.Colors c ON (si.ColorID = c.ColorID)
	LEFT JOIN Purchasing.Suppliers su ON (si.SupplierID = su.SupplierID)
	WHERE si.StockItemName = @Nombre
END;
GO

CREATE PROCEDURE ObtenerVentas
    @NumeroFactura INT = NULL,
    @NombreCliente NVARCHAR(100) = NULL,
    @FechaInicial DATE = NULL,
    @FechaFinal DATE = NULL,
    @MontoMinimo DECIMAL(10,2) = NULL,
    @MontoMaximo DECIMAL(10,2) = NULL
AS
BEGIN
    SELECT 
        o.OrderID AS NumeroFactura,
        o.OrderDate AS Fecha,
        c.CustomerName AS NombreCliente,
        d.DeliveryMethodName AS MetodoEntrega,
        SUM(ol.Quantity * ol.UnitPrice * (1 + (ol.TaxRate / 100))) AS Monto
    FROM Sales.Orders o
    JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
    JOIN Application.DeliveryMethods d ON c.DeliveryMethodID = d.DeliveryMethodID
    JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
    WHERE 
        (@NumeroFactura IS NULL OR CAST(o.OrderID AS NVARCHAR(20)) LIKE '%' + CAST(@NumeroFactura AS NVARCHAR(20)) + '%')
        AND (@NombreCliente IS NULL OR c.CustomerName LIKE '%' + @NombreCliente + '%')
        AND (@FechaInicial IS NULL OR o.OrderDate >= @FechaInicial)
        AND (@FechaFinal IS NULL OR o.OrderDate <= @FechaFinal)
    GROUP BY 
        o.OrderID, o.OrderDate, c.CustomerName, d.DeliveryMethodName
    HAVING 
        (@MontoMinimo IS NULL OR SUM(ol.Quantity * ol.UnitPrice * (1 + (ol.TaxRate / 100))) >= @MontoMinimo)
        AND (@MontoMaximo IS NULL OR SUM(ol.Quantity * ol.UnitPrice * (1 + (ol.TaxRate / 100))) <= @MontoMaximo)
    ORDER BY 
        c.CustomerName ASC, 
        Monto DESC;
END;
GO


CREATE PROCEDURE InformacionVentas
	@NumeroFactura INT = NULL
AS
BEGIN
	--Encabezado Factura--
	SELECT 
		o.OrderID AS NumeroFactura,
		c.CustomerName AS NombreCliente,
		d.DeliveryMethodName AS MetodoEntrega,
		o.CustomerPurchaseOrderNumber AS NumeroOrden,
	CASE 
		WHEN p1.FullName IS NOT NULL AND p1.EmailAddress IS NOT NULL THEN CONCAT(p1.FullName,',',p1.EmailAddress)
		WHEN p1.FullName IS NULL AND p1.EmailAddress IS NOT NULL THEN p1.EmailAddress
		WHEN p1.FullName IS NOT NULL AND p1.EmailAddress IS NULL THEN p1.FullName
		ELSE NULL
		END AS PersonaContacto,
	CASE
		WHEN p2.FullName IS NOT NULL AND p2.EmailAddress IS NOT NULL THEN CONCAT(p2.FullName,',',p2.EmailAddress)
		WHEN p1.FullName IS NULL AND p2.EmailAddress IS NOT NULL THEN p2.EmailAddress
		WHEN p1.FullName IS NOT NULL AND p2.EmailAddress IS NULL THEN p2.FullName
		ELSE NULL
		END AS Vendedor,
		o.OrderDate AS Fecha,
		o.DeliveryInstructions AS InstruccionesEntrega
	FROM Sales.Orders o
	LEFT JOIN Sales.Customers c ON (o.CustomerID = c.CustomerID)
	LEFT JOIN Application.DeliveryMethods d ON (c.DeliveryMethodID = d.DeliveryMethodID)
	LEFT JOIN Application.People p1 ON (o.ContactPersonID = p1.PersonID)
	LEFT JOIN Application.People p2 ON (o.SalespersonPersonID = p2.PersonID)
	WHERE (@NumeroFactura IS NULL OR o.OrderID = @NumeroFactura);

	--Detalle Factura--
	SELECT 
		si.StockItemName AS NombreProducto, 
		ol.Quantity AS Cantidad, 
		ol.UnitPrice AS PrecioUnitario, 
		ol.TaxRate / 100 AS ImpuestoAplicado,
		(ol.UnitPrice * (ol.TaxRate / 100)) AS MontoImpuesto,
		(ol.Quantity * ol.UnitPrice) * (1 + ol.TaxRate / 100) AS TotalLinea
	FROM Sales.Orders o
	LEFT JOIN Sales.OrderLines ol ON (o.OrderID = ol.OrderID)
	LEFT JOIN Warehouse.StockItems si ON (ol.StockItemID = si.StockItemID)
	WHERE (@NumeroFactura IS NULL OR o.OrderID = @NumeroFactura);
END;
GO

CREATE PROCEDURE EstadisticaProveedores
    @Nombre NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL
AS
BEGIN
    SELECT 
        CASE 
            WHEN s.SupplierName IS NULL THEN 'Total General'
            ELSE s.SupplierName
        END AS NombreProveedor,
        CASE
            WHEN sg.StockGroupName IS NULL AND s.SupplierName IS NOT NULL THEN 'Estadísticas por Categoría del Proveedor'
            WHEN sg.StockGroupName IS NULL AND s.SupplierName IS NULL THEN ''
            ELSE sg.StockGroupName
        END AS Categoria,
        MAX(si.UnitPrice * pol.ReceivedOuters) AS MontoMaximo,
        MIN(si.UnitPrice * pol.ReceivedOuters) AS MontoMinimo,
        AVG(si.UnitPrice * pol.ReceivedOuters) AS MontoPromedio
    FROM Purchasing.PurchaseOrders po
    JOIN Purchasing.Suppliers s ON po.SupplierID = s.SupplierID
    JOIN Purchasing.PurchaseOrderLines pol ON po.PurchaseOrderID = pol.PurchaseOrderID
    JOIN Warehouse.StockItems si ON pol.StockItemID = si.StockItemID
    JOIN Warehouse.StockItemStockGroups sisg ON si.StockItemID = sisg.StockItemID
    JOIN Warehouse.StockGroups sg ON sisg.StockGroupID = sg.StockGroupID
    WHERE (@Nombre IS NULL OR s.SupplierName LIKE '%' + @Nombre + '%')
      AND (@Categoria IS NULL OR sg.StockGroupName LIKE '%' + @Categoria + '%')
    GROUP BY ROLLUP (s.SupplierName, sg.StockGroupName)
    ORDER BY s.SupplierName ASC, sg.StockGroupName DESC;
END;
GO

CREATE PROCEDURE EstadisticasVentasClientes
    @Cliente NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL
AS
BEGIN
    -- CTE: calcular totales por cliente y categoría
    WITH Subtotales AS (
        SELECT
            c.CustomerName,
            cc.CustomerCategoryName,
            SUM(il.LineProfit) AS TotalFactura
        FROM Sales.Invoices i
        JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
        JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
        JOIN Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
        WHERE 
            (@Cliente IS NULL OR c.CustomerName LIKE '%' + @Cliente + '%') AND
            (@Categoria IS NULL OR cc.CustomerCategoryName LIKE '%' + @Categoria + '%')
        GROUP BY c.CustomerName, cc.CustomerCategoryName
    )

    SELECT
        CASE 
            WHEN CustomerName IS NULL THEN 'Total General'
            ELSE CustomerName
        END AS NombreCliente,
        CASE
            WHEN CustomerName IS NOT NULL AND CustomerCategoryName IS NULL THEN 'Subtotal por Cliente'
            WHEN CustomerName IS NULL AND CustomerCategoryName IS NULL THEN ''
            ELSE CustomerCategoryName
        END AS CategoriaCliente,
        MAX(TotalFactura) AS MontoMaximo,
        MIN(TotalFactura) AS MontoMinimo,
        AVG(TotalFactura) AS MontoPromedio
    FROM Subtotales
    GROUP BY ROLLUP (CustomerName, CustomerCategoryName)
    ORDER BY 
        CASE WHEN CustomerName IS NULL THEN 0 ELSE 1 END,  -- Total General primero
        CustomerName ASC,
        CategoriaCliente ASC;
END;
GO

CREATE PROCEDURE Top5ProductosPorGanancia
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL
AS
BEGIN
	WITH Resultados AS (
		SELECT
			YEAR(i.InvoiceDate) AS Anio,
			si.StockItemName AS Producto,
			SUM(il.UnitPrice * il.Quantity) AS GananciaTotal,
			DENSE_RANK() OVER (PARTITION BY YEAR(i.InvoiceDate) ORDER BY SUM(il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100))) DESC) AS Posicion
		FROM Sales.Invoices i
		JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
		JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
		GROUP BY YEAR(i.InvoiceDate), si.StockItemName
		HAVING SUM((il.UnitPrice - si.TypicalWeightPerUnit) * il.Quantity) > 0
	)
	SELECT *
	FROM Resultados
	WHERE Posicion <= 5 AND (@AnioInicio IS NULL OR Anio >= @AnioInicio) AND (@AnioFin IS NULL OR Anio <= @AnioFin)
	ORDER BY Anio, Posicion;
END;
GO

CREATE PROCEDURE Top5ClientesPorFacturas
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL
AS
BEGIN
    WITH TotalFacturas AS (
        SELECT
            i.InvoiceID,
            c.CustomerName,
            YEAR(i.InvoiceDate) AS Anio,
            SUM(il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100))) AS TotalFactura
        FROM Sales.Invoices i
        JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
        JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
        GROUP BY i.InvoiceID, c.CustomerName, YEAR(i.InvoiceDate)
    ),
    TotalesPorCliente AS (
        SELECT
            Anio,
            CustomerName,
            COUNT(InvoiceID) AS CantidadFacturas,
            SUM(TotalFactura) AS MontoTotalFacturado,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY COUNT(InvoiceID) DESC, SUM(TotalFactura) DESC ) AS Posicion
        FROM TotalFacturas
        GROUP BY Anio, CustomerName
    )
    SELECT 
        Anio,
        CustomerName AS Cliente,
        CantidadFacturas,
        MontoTotalFacturado,
		Posicion
    FROM TotalesPorCliente
    WHERE Posicion <= 5 AND (@AnioInicio IS NULL OR Anio >= @AnioInicio) AND (@AnioFin IS NULL OR Anio <= @AnioFin)
    ORDER BY Anio ASC, CantidadFacturas DESC;
END;
GO

CREATE PROCEDURE Top5ProveedoresPorOrdenes
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL
AS
BEGIN
    WITH TotalOrdenes AS (
        SELECT
            po.PurchaseOrderID,
            s.SupplierName,
            YEAR(po.OrderDate) AS Anio,
            SUM(pol.OrderedOuters * si.UnitPrice * (1 + (si.TaxRate / 100))) AS TotalOrdenes
        FROM Purchasing.PurchaseOrders po
        JOIN Purchasing.Suppliers s ON (po.SupplierID = s.SupplierID)
        JOIN Purchasing.PurchaseOrderLines pol ON (po.PurchaseOrderID= pol.PurchaseOrderID)
		JOIN Warehouse.StockItems si ON (pol.StockItemID = si.StockItemID)
        GROUP BY po.PurchaseOrderID, s.SupplierName, YEAR(po.OrderDate)
    ),
    TotalesPorProveedor AS (
        SELECT
            Anio,
            SupplierName,
            COUNT(PurchaseOrderID) AS CantidadOrdenes,
            SUM(TotalOrdenes) AS MontoTotalFacturado,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY COUNT(PurchaseOrderID) DESC, SUM(TotalOrdenes) DESC ) AS Posicion
        FROM TotalOrdenes
        GROUP BY Anio, SupplierName
    )
    SELECT 
        Anio,
        SupplierName AS Proveedor,
        CantidadOrdenes,
        MontoTotalFacturado,
		Posicion
    FROM TotalesPorProveedor
    WHERE Posicion <= 5 AND (@AnioInicio IS NULL OR Anio >= @AnioInicio) AND (@AnioFin IS NULL OR Anio <= @AnioFin)
    ORDER BY Anio ASC, CantidadOrdenes DESC;
END;
GO

CREATE PROCEDURE ObtenerRangosProductos
AS
BEGIN
	SELECT MAX(sih.QuantityOnHand) AS Maximo, MIN(sih.QuantityOnHand) AS Minimo
	FROM Warehouse.StockItems si
	JOIN Warehouse.StockItemHoldings sih ON (si.StockItemID = sih.StockItemID)
END;
GO