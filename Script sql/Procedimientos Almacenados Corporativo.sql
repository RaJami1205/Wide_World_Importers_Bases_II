CREATE OR ALTER PROCEDURE EstadisticaProveedores
    @Nombre NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL,
    @Flag INT = 1   -- 1=Todos, 2=SanJose, 3=Limon
AS
BEGIN

--Tablas temporales
    CREATE TABLE #StockItems (
        StockItemID INT,
        StockItemName NVARCHAR(100),
        UnitPrice DECIMAL(18,2)
    );
--DESKTOP-BE6OQQA\NODO_CORPORATIVO
    CREATE TABLE #StockGroups (
        StockGroupID INT,
        StockGroupName NVARCHAR(100)
    );

    CREATE TABLE #StockItemStockGroups (
        StockItemID INT,
        StockGroupID INT
    );

    INSERT INTO #StockItems
    SELECT StockItemID, StockItemName, UnitPrice
    FROM (
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
                'SELECT StockItemID, StockItemName, UnitPrice 
                 FROM SanJose.Warehouse.StockItems')
        WHERE @Flag = 1 OR @Flag = 2

        UNION ALL
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
                'SELECT StockItemID, StockItemName, UnitPrice 
                 FROM Limon.Warehouse.StockItems')
        WHERE @Flag = 1 OR @Flag = 3
    ) AS Temp;


    INSERT INTO #StockGroups
    SELECT StockGroupID, StockGroupName
    FROM (SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
                'SELECT StockGroupID, StockGroupName 
                 FROM SanJose.Warehouse.StockGroups')
        WHERE @Flag = 1 OR @Flag = 2

        UNION ALL
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
                'SELECT StockGroupID, StockGroupName 
                 FROM Limon.Warehouse.StockGroups')
        WHERE @Flag = 1 OR @Flag = 3
    ) AS Temp;


    INSERT INTO #StockItemStockGroups
    SELECT StockItemID, StockGroupID
    FROM (SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
                'SELECT StockItemID, StockGroupID 
                 FROM SanJose.Warehouse.StockItemStockGroups')
        WHERE @Flag = 1 OR @Flag = 2

        UNION ALL
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
                'SELECT StockItemID, StockGroupID 
                 FROM Limon.Warehouse.StockItemStockGroups')
        WHERE @Flag = 1 OR @Flag = 3
    ) AS Temp;


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

    JOIN #StockItems si ON pol.StockItemID = si.StockItemID
    JOIN #StockItemStockGroups sisg ON si.StockItemID = sisg.StockItemID
    JOIN #StockGroups sg ON sisg.StockGroupID = sg.StockGroupID

    WHERE (@Nombre IS NULL OR s.SupplierName LIKE '%' + @Nombre + '%')
      AND (@Categoria IS NULL OR sg.StockGroupName LIKE '%' + @Categoria + '%')

    GROUP BY ROLLUP (s.SupplierName, sg.StockGroupName)

    ORDER BY s.SupplierName ASC, sg.StockGroupName DESC;

END;
GO

CREATE PROCEDURE EstadisticasVentasClientes
    @Cliente NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL,
    @Flag INT = 1 -- 1=Ambas, 2=SanJose, 3=Limon
AS
BEGIN
-- Tablas temporales
    DECLARE @Invoices TABLE (
        InvoiceID INT,
        CustomerID INT
    );

    DECLARE @InvoiceLines TABLE (
        InvoiceID INT,
        LineProfit DECIMAL(18,2)
    );

    DECLARE @CustomerCategories TABLE (
        CustomerCategoryID INT,
        CustomerCategoryName NVARCHAR(100)
    );

    DECLARE @Customers_Corporativo TABLE (
        CustomerID INT,
        CustomerName NVARCHAR(100)
    );

    DECLARE @Customers_Sucursal TABLE (
        CustomerID INT,
        CustomerCategoryID INT
    );

    INSERT INTO @Customers_Corporativo
    SELECT CustomerID, CustomerName
    FROM CORPORATIVO.Sales.Customers;

    IF @Flag =1 OR @Flag = 2
    BEGIN
        INSERT INTO @Invoices
        SELECT InvoiceID, CustomerID
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, CustomerID FROM SanJose.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT InvoiceID, LineProfit
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, LineProfit FROM SanJose.Sales.InvoiceLines');

        INSERT INTO @Customers_Sucursal
        SELECT CustomerID, CustomerCategoryID
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT CustomerID, CustomerCategoryID FROM SanJose.Sales.Customers');

        INSERT INTO @CustomerCategories
        SELECT CustomerCategoryID, CustomerCategoryName
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT CustomerCategoryID, CustomerCategoryName FROM SanJose.Sales.CustomerCategories');
    END

    IF @Flag = 1 OR @Flag = 3
    BEGIN
        INSERT INTO @Invoices
        SELECT InvoiceID, CustomerID
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, CustomerID FROM Limon.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT InvoiceID, LineProfit
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, LineProfit FROM Limon.Sales.InvoiceLines');

        INSERT INTO @Customers_Sucursal
        SELECT CustomerID, CustomerCategoryID
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT CustomerID, CustomerCategoryID FROM Limon.Sales.Customers');

        INSERT INTO @CustomerCategories
        SELECT CustomerCategoryID, CustomerCategoryName
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT CustomerCategoryID, CustomerCategoryName FROM Limon.Sales.CustomerCategories');
    END


    ;WITH Subtotales AS (
        SELECT
            c.CustomerName,
            cc.CustomerCategoryName,
            SUM(il.LineProfit) AS TotalFactura
        FROM @Invoices i
        JOIN @InvoiceLines il ON i.InvoiceID = il.InvoiceID

        JOIN @Customers_Corporativo c ON i.CustomerID = c.CustomerID
        JOIN @Customers_Sucursal cs ON i.CustomerID = cs.CustomerID
        JOIN @CustomerCategories cc ON cs.CustomerCategoryID = cc.CustomerCategoryID

        WHERE
            (@Cliente IS NULL OR c.CustomerName LIKE '%' + @Cliente + '%')
            AND (@Categoria IS NULL OR cc.CustomerCategoryName LIKE '%' + @Categoria + '%')

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
        CASE WHEN CustomerName IS NULL THEN 0 ELSE 1 END,
        CustomerName ASC,
        CategoriaCliente ASC;
END;
GO

CREATE PROCEDURE Top5ProductosPorGanancia
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL,
    @Flag INT = 1 -- 1 = Ambas, 2 = San Jose, 3 = Limon
AS
BEGIN
-- Tablas Temporales
    DECLARE @Invoices TABLE (
        InvoiceID INT,
        InvoiceDate DATE
    );
    DECLARE @InvoiceLines TABLE (
        InvoiceID INT,
        StockItemID INT,
        UnitPrice DECIMAL(18,2),
        Quantity INT,
        TaxRate DECIMAL(18,2)
    );
    DECLARE @StockItems TABLE (
        StockItemID INT,
        StockItemName NVARCHAR(200),
        TypicalWeightPerUnit DECIMAL(18,2)
    );
-- AMBAS
    IF @Flag = 1
    BEGIN
        -- SAN JOSE
        INSERT INTO @Invoices
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, InvoiceDate FROM SanJose.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, StockItemID, UnitPrice, Quantity, TaxRate 
             FROM SanJose.Sales.InvoiceLines');

        INSERT INTO @StockItems
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT StockItemID, StockItemName, TypicalWeightPerUnit
              FROM SanJose.Warehouse.StockItems');
        -- LIMON
        INSERT INTO @Invoices
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, InvoiceDate FROM Limon.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, StockItemID, UnitPrice, Quantity, TaxRate 
             FROM Limon.Sales.InvoiceLines');

        INSERT INTO @StockItems
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT StockItemID, StockItemName, TypicalWeightPerUnit
              FROM Limon.Warehouse.StockItems');
    END
-- Caso San Jose
    IF @Flag = 2
    BEGIN
        INSERT INTO @Invoices
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, InvoiceDate FROM SanJose.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, StockItemID, UnitPrice, Quantity, TaxRate 
             FROM SanJose.Sales.InvoiceLines');

        INSERT INTO @StockItems
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT StockItemID, StockItemName, TypicalWeightPerUnit
              FROM SanJose.Warehouse.StockItems');
    END

-- Caso Limon
    IF @Flag = 3
    BEGIN
        INSERT INTO @Invoices
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, InvoiceDate FROM Limon.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, StockItemID, UnitPrice, Quantity, TaxRate 
             FROM Limon.Sales.InvoiceLines');

        INSERT INTO @StockItems
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT StockItemID, StockItemName, TypicalWeightPerUnit
              FROM Limon.Warehouse.StockItems');
    END;
	SELECT *
	FROM (
			SELECT
				YEAR(i.InvoiceDate) AS Anio,
				si.StockItemName AS Producto,
				SUM(il.UnitPrice * il.Quantity) AS GananciaTotal,
				DENSE_RANK() OVER (
					PARTITION BY YEAR(i.InvoiceDate)
					ORDER BY SUM(il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100))) DESC
				) AS Posicion
			FROM @Invoices i
			JOIN @InvoiceLines il ON i.InvoiceID = il.InvoiceID
			JOIN @StockItems si ON il.StockItemID = si.StockItemID
			GROUP BY YEAR(i.InvoiceDate), si.StockItemName
			HAVING SUM((il.UnitPrice - si.TypicalWeightPerUnit) * il.Quantity) > 0
		) Query
	WHERE Query.Posicion <=5 AND (@AnioInicio IS NULL OR Anio >= @AnioInicio) AND (@AnioFin IS NULL OR Anio <= @AnioFin)
	ORDER BY Anio,Query.Posicion
END;
GO

CREATE PROCEDURE Top5ClientesPorFacturas
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL,
    @Flag INT = 1 -- 1 = Todas, 2 = SanJose, 3 = Limon
AS
BEGIN
--Tablas Temporales
    DECLARE @Invoices TABLE (
        InvoiceID INT,
        CustomerID INT,
        InvoiceDate DATE
    );

    DECLARE @InvoiceLines TABLE (
        InvoiceID INT,
        Quantity INT,
        UnitPrice DECIMAL(18,2),
        TaxRate DECIMAL(18,2)
    );

    DECLARE @Customers TABLE (
        CustomerID INT,
        CustomerName NVARCHAR(100)
    );


--Caso Todos
    IF @Flag = 1
    BEGIN
        INSERT INTO @Invoices
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, CustomerID, InvoiceDate FROM SanJose.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, Quantity, UnitPrice, TaxRate FROM SanJose.Sales.InvoiceLines');

        INSERT INTO @Customers
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT CustomerID, CustomerName FROM SanJose.Sales.Customers');

        INSERT INTO @Invoices
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, CustomerID, InvoiceDate FROM Limon.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, Quantity, UnitPrice, TaxRate FROM Limon.Sales.InvoiceLines');

    END

--Caso San Jose
    IF @Flag = 2
    BEGIN
        INSERT INTO @Invoices
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, CustomerID, InvoiceDate FROM SanJose.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, Quantity, UnitPrice, TaxRate FROM SanJose.Sales.InvoiceLines');

    END

--Caso Limon
    IF @Flag = 3
    BEGIN
        INSERT INTO @Invoices
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, CustomerID, InvoiceDate FROM Limon.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT InvoiceID, Quantity, UnitPrice, TaxRate FROM Limon.Sales.InvoiceLines');
    END;

    WITH TotalFacturas AS (
        SELECT
            i.InvoiceID,
            c.CustomerName,
            YEAR(i.InvoiceDate) AS Anio,
            SUM(il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100))) AS TotalFactura
        FROM @Invoices i
        JOIN Sales.Customers c ON c.CustomerID = i.CustomerID 
        JOIN @InvoiceLines il ON i.InvoiceID = il.InvoiceID
        GROUP BY i.InvoiceID, c.CustomerName, YEAR(i.InvoiceDate)
    ),

    TotalesPorCliente AS (
        SELECT
            Anio,
            CustomerName,
            COUNT(InvoiceID) AS CantidadFacturas,
            SUM(TotalFactura) AS MontoTotalFacturado,
            DENSE_RANK() OVER (
                PARTITION BY Anio 
                ORDER BY COUNT(InvoiceID) DESC, SUM(TotalFactura) DESC
            ) AS Posicion
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
    WHERE 
        Posicion <= 5
        AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
        AND (@AnioFin IS NULL OR Anio <= @AnioFin)
    ORDER BY Anio ASC, CantidadFacturas DESC;

END;
GO

CREATE PROCEDURE Top5ProveedoresPorOrdenes
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL,
    @Flag INT = 1   -- 1 = todos, 2 = San José, 3 = Limón
AS
BEGIN
    DECLARE @StockItems TABLE (
        StockItemID INT,
        StockItemName NVARCHAR(200),
        UnitPrice DECIMAL(18,5),
        TaxRate DECIMAL(18,5)
    );

-- Caso Todos
    IF @Flag = 1
    BEGIN
        INSERT INTO @StockItems
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT StockItemID, StockItemName, UnitPrice, TaxRate  
             FROM Limon.Warehouse.StockItems');

        INSERT INTO @StockItems
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT StockItemID, StockItemName, UnitPrice, TaxRate  
             FROM SanJose.Warehouse.StockItems');
    END
--Caso San Jose
    IF @Flag = 2
    BEGIN
        INSERT INTO @StockItems
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT StockItemID, StockItemName, UnitPrice, TaxRate  
             FROM SanJose.Warehouse.StockItems');
    END
--Caso Limon
    IF @Flag = 3
    BEGIN
        INSERT INTO @StockItems
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT StockItemID, StockItemName, UnitPrice, TaxRate  
             FROM Limon.Warehouse.StockItems');
    END;

    WITH TotalOrdenes AS (
        SELECT
            po.PurchaseOrderID,
            s.SupplierName,
            YEAR(po.OrderDate) AS Anio,
            SUM(pol.OrderedOuters * si.UnitPrice * (1 + (si.TaxRate / 100))) AS TotalOrdenes
        FROM Purchasing.PurchaseOrders po
        JOIN Purchasing.Suppliers s 
            ON po.SupplierID = s.SupplierID
        JOIN Purchasing.PurchaseOrderLines pol
            ON po.PurchaseOrderID = pol.PurchaseOrderID
        JOIN @StockItems si
            ON pol.StockItemID = si.StockItemID
        GROUP BY po.PurchaseOrderID, s.SupplierName, YEAR(po.OrderDate)
    ),
    TotalesPorProveedor AS (
        SELECT
            Anio,
            SupplierName,
            COUNT(PurchaseOrderID) AS CantidadOrdenes,
            SUM(TotalOrdenes) AS MontoTotalFacturado,
            DENSE_RANK() OVER (PARTITION BY Anio 
                               ORDER BY COUNT(PurchaseOrderID) DESC, SUM(TotalOrdenes) DESC)
            AS Posicion
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
    WHERE Posicion <= 5
      AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
      AND (@AnioFin IS NULL OR Anio <= @AnioFin)
    ORDER BY Anio ASC, CantidadOrdenes DESC;

END;
GO


CREATE PROCEDURE GetClientes
    @CustomerID INT = NULL,
    @Nombre NVARCHAR(100) = NULL,
    @Flag INT = 1   -- 1=Todos, 2=SANJOSE, 3=LIMON
AS
BEGIN

    DECLARE @CustomersCorporativo TABLE (
        CustomerID INT,
        CustomerName NVARCHAR(100),
        PrimaryContactPersonID INT,
        AlternateContactPersonID INT,
        PhoneNumber NVARCHAR(20),
        FaxNumber NVARCHAR(20),
        WebsiteURL NVARCHAR(256),
        DeliveryAddressLine1 NVARCHAR(60),
        DeliveryAddressLine2 NVARCHAR(60),
        DeliveryPostalCode NVARCHAR(10),
        DeliveryCityID INT,
        PostalCityID INT
    );

    DECLARE @CustomersSucursales TABLE (
        CustomerID INT,
        CustomerName NVARCHAR(100),
        BuyingGroupID INT,
        CustomerCategoryID INT,
        BillToCustomerID INT,
        CreditLimit DECIMAL(18,2),
        PaymentDays INT,
        AccountOpenedDate DATE,
        DeliveryMethodID INT,
        Sucursal NVARCHAR(20)
    );
    IF @Flag =1 OR @Flag = 2
    BEGIN
        INSERT INTO @CustomersSucursales
        SELECT *, 'SANJOSE'
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT CustomerID, CustomerName, BuyingGroupID, CustomerCategoryID,
                    BillToCustomerID, CreditLimit, PaymentDays, AccountOpenedDate,
                    DeliveryMethodID
             FROM SANJOSE.Sales.Customers'
        );
    END

    IF @Flag = 1 OR @Flag = 3
    BEGIN
        INSERT INTO @CustomersSucursales
        SELECT *, 'LIMON'
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT CustomerID, CustomerName, BuyingGroupID, CustomerCategoryID,
                    BillToCustomerID, CreditLimit, PaymentDays, AccountOpenedDate,
                    DeliveryMethodID
             FROM LIMON.Sales.Customers'
        );
    END

    SELECT 
        bc.Sucursal,
        bc.CustomerID,
        cc.CustomerName,
        cc.PhoneNumber,
        cc.FaxNumber,
        cc.WebsiteURL,
        cc.DeliveryAddressLine1,
        cc.DeliveryAddressLine2,
        cc.DeliveryPostalCode,
        cc.DeliveryCityID,
        cc.PostalCityID,
        bc.CustomerCategoryID,
        bc.CreditLimit,
        bc.PaymentDays,
        bc.AccountOpenedDate,
        bc.DeliveryMethodID
    FROM @CustomersSucursales bc
    INNER JOIN @CustomersCorporativo cc ON cc.CustomerID = bc.CustomerID
    WHERE 
        (@CustomerID IS NULL OR bc.CustomerID = @CustomerID)
        AND (@Nombre IS NULL OR cc.CustomerName LIKE '%' + @Nombre + '%')
    ORDER BY cc.CustomerName;

END;
GO

		 