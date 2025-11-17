CREATE OR ALTER PROCEDURE CrearUsuario
    @Username NVARCHAR(30),
    @Password NVARCHAR(200),
    @Fullname NVARCHAR(40),
    @Active INT,
    @Rol INT,
    @Email NVARCHAR(30)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @PasswordHash VARBINARY(64) = HASHBYTES(
            'SHA2_512',
            CONVERT(VARBINARY(200), @Password)
        );

        INSERT INTO Usuarios (username, password, fullname, active, rol, email, hiredate)
        VALUES (@Username, @PasswordHash, @Fullname, @Active, @Rol, @Email, GETDATE());

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE LoginUsuario
    @Username NVARCHAR(30),
    @Password NVARCHAR(200)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    DECLARE @PasswordHash VARBINARY(64) = HASHBYTES(
        'SHA2_512',
        CONVERT(VARBINARY(200), @Password)
    );

    IF EXISTS (
        SELECT 1
        FROM Usuarios
        WHERE username = @Username
          AND password = @PasswordHash
    )
    BEGIN
        SELECT 'Acceso permitido' AS Mensaje, 1 AS Acceso;
    END
    ELSE
    BEGIN
        SELECT 'Usuario o contraseña inválidos' AS Mensaje, 0 AS Acceso;
    END
END;
GO

CREATE OR ALTER PROCEDURE EstadisticaProveedores
    @Nombre NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL,
    @Flag INT = 1   -- 1=Todos, 2=SanJose, 3=Limon
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    -- Tablas temporales
    CREATE TABLE #StockItems (
        StockItemID INT,
        StockItemName NVARCHAR(100),
        UnitPrice DECIMAL(18,2)
    );

    CREATE TABLE #StockGroups (
        StockGroupID INT,
        StockGroupName NVARCHAR(100)
    );

    CREATE TABLE #StockItemStockGroups (
        StockItemID INT,
        StockGroupID INT
    );

    -- StockItems
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

    -- StockGroups
    INSERT INTO #StockGroups
    SELECT StockGroupID, StockGroupName
    FROM (
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT StockGroupID, StockGroupName 
             FROM SanJose.Warehouse.StockGroups')
        WHERE @Flag = 1 OR @Flag = 2

        UNION ALL
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT StockGroupID, StockGroupName 
             FROM Limon.Warehouse.StockGroups')
        WHERE @Flag = 1 OR @Flag = 3
    ) AS Temp;

    -- StockItemStockGroups
    INSERT INTO #StockItemStockGroups
    SELECT StockItemID, StockGroupID
    FROM (
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT StockItemID, StockGroupID 
             FROM SanJose.Warehouse.StockItemStockGroups')
        WHERE @Flag = 1 OR @Flag = 2

        UNION ALL
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],
            'SELECT StockItemID, StockGroupID 
             FROM Limon.Warehouse.StockItemStockGroups')
        WHERE @Flag = 1 OR @Flag = 3
    ) AS Temp;

    -- Resultados
    SELECT 
        CASE WHEN s.SupplierName IS NULL THEN 'Total General' ELSE s.SupplierName END AS NombreProveedor,
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


CREATE OR ALTER PROCEDURE EstadisticasVentasClientes
    @Cliente NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL,
    @Flag INT = 1
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @Invoices TABLE (InvoiceID INT, CustomerID INT);
    DECLARE @InvoiceLines TABLE (InvoiceID INT, LineProfit DECIMAL(18,2));
    DECLARE @CustomerCategories TABLE (CustomerCategoryID INT, CustomerCategoryName NVARCHAR(100));
    DECLARE @Customers_Corporativo TABLE (CustomerID INT, CustomerName NVARCHAR(100));
    DECLARE @Customers_Sucursal TABLE (CustomerID INT, CustomerCategoryID INT);

    INSERT INTO @Customers_Corporativo
    SELECT CustomerID, CustomerName
    FROM CORPORATIVO.Sales.Customers;

    -- SAN JOSE
    IF @Flag = 1 OR @Flag = 2
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

    -- LIMON
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
    END;
	WITH Subtotales AS (
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

CREATE OR ALTER PROCEDURE Top5ProductosPorGanancia
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL,
    @Flag INT = 1 -- 1 = Ambas, 2 = San Jose, 3 = Limon
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

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

    -- SOLO SAN JOSE
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

    -- SOLO LIMON
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
    WHERE Query.Posicion <= 5
      AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
      AND (@AnioFin IS NULL OR Anio <= @AnioFin)
    ORDER BY Anio, Query.Posicion;

END;
GO


CREATE OR ALTER PROCEDURE Top5ClientesPorFacturas
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL,
    @Flag INT = 1
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

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

    IF @Flag = 2
    BEGIN
        INSERT INTO @Invoices
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, CustomerID, InvoiceDate FROM SanJose.Sales.Invoices');

        INSERT INTO @InvoiceLines
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT InvoiceID, Quantity, UnitPrice, TaxRate FROM SanJose.Sales.InvoiceLines');
    END

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
    WHERE Posicion <= 5
      AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
      AND (@AnioFin IS NULL OR Anio <= @AnioFin)
    ORDER BY Anio ASC, CantidadFacturas DESC;

END;
GO

CREATE OR ALTER PROCEDURE Top5ProveedoresPorOrdenes
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL,
    @Flag INT = 1
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @StockItems TABLE (
        StockItemID INT,
        StockItemName NVARCHAR(200),
        UnitPrice DECIMAL(18,5),
        TaxRate DECIMAL(18,5)
    );

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

    IF @Flag = 2
    BEGIN
        INSERT INTO @StockItems
        SELECT * FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],
            'SELECT StockItemID, StockItemName, UnitPrice, TaxRate  
             FROM SanJose.Warehouse.StockItems');
    END

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

CREATE OR ALTER PROCEDURE ObtenerClientes
    @Nombre NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL,
    @MetodoEntrega NVARCHAR(100) = NULL,
    @Flag INT = 1
AS
BEGIN
    -- Tabla temporal
    CREATE TABLE #Clientes(
        NombreCliente NVARCHAR(100),
        CategoriaCliente NVARCHAR(100),
        MetodoEntrega NVARCHAR(100)
    );
    -- San José
    IF @Flag IN (1, 2)
    BEGIN
        INSERT INTO #Clientes(NombreCliente, CategoriaCliente, MetodoEntrega)
        SELECT cu.CustomerName,
               ca.CustomerCategoryName,
               dm.DeliveryMethodName
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.Customers') cu
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.CustomerCategories') ca ON cu.CustomerCategoryID = ca.CustomerCategoryID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Application.DeliveryMethods') dm ON cu.DeliveryMethodID = dm.DeliveryMethodID
        WHERE (@Nombre IS NULL OR cu.CustomerName LIKE '%' + @Nombre + '%')
          AND (@Categoria IS NULL OR ca.CustomerCategoryName LIKE '%' + @Categoria + '%')
          AND (@MetodoEntrega IS NULL OR dm.DeliveryMethodName LIKE '%' + @MetodoEntrega + '%');
    END
    -- Limón
    IF @Flag = 1 OR @Flag = 3
    BEGIN
        INSERT INTO #Clientes(NombreCliente, CategoriaCliente, MetodoEntrega)
        SELECT cu.CustomerName,
               ca.CustomerCategoryName,
               dm.DeliveryMethodName
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.Customers') cu
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.CustomerCategories') ca ON cu.CustomerCategoryID = ca.CustomerCategoryID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Application.DeliveryMethods') dm ON cu.DeliveryMethodID = dm.DeliveryMethodID
        WHERE (@Nombre IS NULL OR cu.CustomerName LIKE '%' + @Nombre + '%')
          AND (@Categoria IS NULL OR ca.CustomerCategoryName LIKE '%' + @Categoria + '%')
          AND (@MetodoEntrega IS NULL OR dm.DeliveryMethodName LIKE '%' + @MetodoEntrega + '%');
    END

    SELECT *
    FROM #Clientes
    ORDER BY NombreCliente;

    DROP TABLE #Clientes;
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


CREATE OR ALTER PROCEDURE ObtenerInventarios
    @Nombre NVARCHAR(100) = NULL,
    @Grupo NVARCHAR(100) = NULL,
    @CantidadMinima INT = NULL,
    @CantidadMaxima INT = NULL,
    @Flag INT = 1 -- 1 = Todas, 2 = SanJose, 3 = Limon
AS
BEGIN
    SELECT *
    FROM
    (
        -- San José
        SELECT 
            si.StockItemName AS NombreProducto,
            STRING_AGG(sg.StockGroupName, ', ') AS GrupoProducto,
            sih.QuantityOnHand AS CantidadProducto,
            'SANJOSE' AS Sucursal
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE], 'SELECT * FROM SANJOSE.Warehouse.StockItems') si
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE], 'SELECT * FROM SANJOSE.Warehouse.StockItemHoldings') sih ON si.StockItemID = sih.StockItemID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE], 'SELECT * FROM SANJOSE.Warehouse.StockItemStockGroups') sisg ON si.StockItemID = sisg.StockItemID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE], 'SELECT * FROM SANJOSE.Warehouse.StockGroups') sg ON sisg.StockGroupID = sg.StockGroupID
        WHERE (@Flag = 1 OR @Flag = 2)
          AND (@Nombre IS NULL OR si.StockItemName LIKE '%' + @Nombre + '%')
          AND (@Grupo IS NULL OR sg.StockGroupName LIKE '%' + @Grupo + '%')
          AND (@CantidadMinima IS NULL OR sih.QuantityOnHand >= @CantidadMinima)
          AND (@CantidadMaxima IS NULL OR sih.QuantityOnHand <= @CantidadMaxima)
        GROUP BY si.StockItemName, sih.QuantityOnHand
        UNION ALL
        -- Limón
        SELECT 
            si.StockItemName AS NombreProducto,
            STRING_AGG(sg.StockGroupName, ', ') AS GrupoProducto,
            sih.QuantityOnHand AS CantidadProducto,
            'LIMON' AS Sucursal
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON], 'SELECT * FROM LIMON.Warehouse.StockItems') si
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON], 'SELECT * FROM LIMON.Warehouse.StockItemHoldings') sih ON si.StockItemID = sih.StockItemID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON], 'SELECT * FROM LIMON.Warehouse.StockItemStockGroups') sisg ON si.StockItemID = sisg.StockItemID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON], 'SELECT * FROM LIMON.Warehouse.StockGroups') sg ON sisg.StockGroupID = sg.StockGroupID
        WHERE (@Flag = 1 OR @Flag = 3)
          AND (@Nombre IS NULL OR si.StockItemName LIKE '%' + @Nombre + '%')
          AND (@Grupo IS NULL OR sg.StockGroupName LIKE '%' + @Grupo + '%')
          AND (@CantidadMinima IS NULL OR sih.QuantityOnHand >= @CantidadMinima)
          AND (@CantidadMaxima IS NULL OR sih.QuantityOnHand <= @CantidadMaxima)
        GROUP BY si.StockItemName, sih.QuantityOnHand
    ) AS Inventarios
    ORDER BY Sucursal,NombreProducto;
END;
GO


CREATE OR ALTER PROCEDURE ObtenerVentas
    @NumeroFactura INT = NULL,
    @NombreCliente NVARCHAR(100) = NULL,
    @FechaInicial DATE = NULL,
    @FechaFinal DATE = NULL,
    @MontoMinimo DECIMAL(10,2) = NULL,
    @MontoMaximo DECIMAL(10,2) = NULL,
    @Flag INT = 1  -- 1 = Todas, 2 = SanJose, 3 = Limon
AS
BEGIN
    SELECT *
    FROM
    (
        -- San José
        SELECT 
            o.OrderID AS NumeroFactura,
            o.OrderDate AS Fecha,
            c.CustomerName AS NombreCliente,
            d.DeliveryMethodName AS MetodoEntrega,
            SUM(ol.Quantity * ol.UnitPrice * (1 + (ol.TaxRate / 100))) AS Monto,
            'SANJOSE' AS Sucursal
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.Orders') o
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.OrderLines') ol ON o.OrderID = ol.OrderID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.Customers') c ON o.CustomerID = c.CustomerID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Application.DeliveryMethods') d ON c.DeliveryMethodID = d.DeliveryMethodID
        WHERE (@Flag=1 OR @Flag=2)
          AND (@NumeroFactura IS NULL OR CAST(o.OrderID AS NVARCHAR(20)) LIKE '%' + CAST(@NumeroFactura AS NVARCHAR(20)) + '%')
          AND (@NombreCliente IS NULL OR c.CustomerName LIKE '%' + @NombreCliente + '%')
          AND (@FechaInicial IS NULL OR o.OrderDate >= @FechaInicial)
          AND (@FechaFinal IS NULL OR o.OrderDate <= @FechaFinal)
        GROUP BY o.OrderID, o.OrderDate, c.CustomerName, d.DeliveryMethodName

        UNION ALL

        -- Limón
        SELECT 
            o.OrderID AS NumeroFactura,
            o.OrderDate AS Fecha,
            c.CustomerName AS NombreCliente,
            d.DeliveryMethodName AS MetodoEntrega,
            SUM(ol.Quantity * ol.UnitPrice * (1 + (ol.TaxRate / 100))) AS Monto,
            'LIMON' AS Sucursal
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.Orders') o
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.OrderLines') ol ON o.OrderID = ol.OrderID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.Customers') c ON o.CustomerID = c.CustomerID
        JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Application.DeliveryMethods') d ON c.DeliveryMethodID = d.DeliveryMethodID
        WHERE (@Flag=1 OR @Flag=3)
          AND (@NumeroFactura IS NULL OR CAST(o.OrderID AS NVARCHAR(20)) LIKE '%' + CAST(@NumeroFactura AS NVARCHAR(20)) + '%')
          AND (@NombreCliente IS NULL OR c.CustomerName LIKE '%' + @NombreCliente + '%')
          AND (@FechaInicial IS NULL OR o.OrderDate >= @FechaInicial)
          AND (@FechaFinal IS NULL OR o.OrderDate <= @FechaFinal)
        GROUP BY o.OrderID, o.OrderDate, c.CustomerName, d.DeliveryMethodName
    ) AS Ventas
    ORDER BY NombreCliente ASC, Monto DESC;
END;
GO

CREATE OR ALTER PROCEDURE InformacionCliente
    @Nombre NVARCHAR(100),
    @Flag INT = 1  -- 1 = SANJOSE, 2 = LIMON
AS
BEGIN
    IF @Flag = 1
    BEGIN
        SELECT cu.CustomerName AS NombreCliente,
               ca.CustomerCategoryName AS CategoriaCliente,
               bg.BuyingGroupName AS GrupoCompra,
               CASE 
                   WHEN pe1.FullName IS NOT NULL AND pe1.EmailAddress IS NOT NULL THEN CONCAT(pe1.FullName, ',', pe1.EmailAddress)
                   WHEN pe1.FullName IS NULL AND pe1.EmailAddress IS NOT NULL THEN pe1.EmailAddress
                   WHEN pe1.FullName IS NOT NULL AND pe1.EmailAddress IS NULL THEN pe1.FullName
                   ELSE NULL
               END AS ContactoPrincipal,
               CASE
                   WHEN pe2.FullName IS NOT NULL AND pe2.EmailAddress IS NOT NULL THEN CONCAT(pe2.FullName, ',', pe2.EmailAddress)
                   WHEN pe2.FullName IS NULL AND pe2.EmailAddress IS NOT NULL THEN pe2.EmailAddress
                   WHEN pe2.FullName IS NOT NULL AND pe2.EmailAddress IS NULL THEN pe2.FullName
                   ELSE NULL
               END AS ContactoAlternativo,
               cu_suc.BillToCustomerID AS ClienteAFacturar,
               dm.DeliveryMethodName AS MetodoEntrega,
               ci.CityName AS CiudadEntrega,
               cu.DeliveryPostalCode AS CodigoPostal,
               cu.FaxNumber AS Fax,
               cu.PhoneNumber AS Telefono,
               cu_suc.PaymentDays AS DiasPagar,
               cu.WebsiteURL AS SitioWeb,
               CASE 
                   WHEN cu.DeliveryAddressLine1 IS NOT NULL AND cu.DeliveryAddressLine2 IS NOT NULL THEN CONCAT(cu.DeliveryAddressLine1, ',', cu.DeliveryAddressLine2)
                   WHEN cu.DeliveryAddressLine1 IS NULL AND cu.DeliveryAddressLine2 IS NOT NULL THEN cu.DeliveryAddressLine2
                   WHEN cu.DeliveryAddressLine1 IS NOT NULL AND cu.DeliveryAddressLine2 IS NULL THEN cu.DeliveryAddressLine1
                   ELSE NULL
               END AS Direccion,
               CASE
                   WHEN cu.PostalAddressLine1 IS NOT NULL AND cu.PostalAddressLine2 IS NOT NULL THEN CONCAT(cu.PostalAddressLine1, ',', cu.PostalAddressLine2)
                   WHEN cu.PostalAddressLine1 IS NULL AND cu.PostalAddressLine2 IS NOT NULL THEN cu.PostalAddressLine2
                   WHEN cu.PostalAddressLine1 IS NOT NULL AND cu.PostalAddressLine2 IS NULL THEN cu.PostalAddressLine1
                   ELSE NULL
               END AS DireccionPostal,
               cu.DeliveryLocation AS MapaLocalizacion,
               'SANJOSE' AS Sucursal
        FROM CORPORATIVO.Sales.Customers cu
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.CustomerCategories') ca
               ON cu.CustomerID = ca.CustomerCategoryID
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.BuyingGroups') bg
               ON cu.CustomerID = bg.BuyingGroupID
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.Customers') cu_suc
               ON cu.CustomerID = cu_suc.CustomerID
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Application.DeliveryMethods') dm
               ON cu_suc.DeliveryMethodID = dm.DeliveryMethodID
        LEFT JOIN Application.Cities ci
               ON cu.DeliveryCityID = ci.CityID
        LEFT JOIN Application.People pe1
               ON cu.PrimaryContactPersonID = pe1.PersonID
        LEFT JOIN Application.People pe2
               ON cu.AlternateContactPersonID = pe2.PersonID
        WHERE cu.CustomerName = @Nombre
    END
-- Limon
    IF @Flag = 2
    BEGIN
        SELECT cu.CustomerName AS NombreCliente,
               ca.CustomerCategoryName AS CategoriaCliente,
               bg.BuyingGroupName AS GrupoCompra,
               CASE 
                   WHEN pe1.FullName IS NOT NULL AND pe1.EmailAddress IS NOT NULL THEN CONCAT(pe1.FullName, ',', pe1.EmailAddress)
                   WHEN pe1.FullName IS NULL AND pe1.EmailAddress IS NOT NULL THEN pe1.EmailAddress
                   WHEN pe1.FullName IS NOT NULL AND pe1.EmailAddress IS NULL THEN pe1.FullName
                   ELSE NULL
               END AS ContactoPrincipal,
               CASE
                   WHEN pe2.FullName IS NOT NULL AND pe2.EmailAddress IS NOT NULL THEN CONCAT(pe2.FullName, ',', pe2.EmailAddress)
                   WHEN pe2.FullName IS NULL AND pe2.EmailAddress IS NOT NULL THEN pe2.EmailAddress
                   WHEN pe2.FullName IS NOT NULL AND pe2.EmailAddress IS NULL THEN pe2.FullName
                   ELSE NULL
               END AS ContactoAlternativo,
               cu_suc.BillToCustomerID AS ClienteAFacturar,
               dm.DeliveryMethodName AS MetodoEntrega,
               ci.CityName AS CiudadEntrega,
               cu.DeliveryPostalCode AS CodigoPostal,
               cu.FaxNumber AS Fax,
               cu.PhoneNumber AS Telefono,
               cu_suc.PaymentDays AS DiasPagar,
               cu.WebsiteURL AS SitioWeb,
               CASE 
                   WHEN cu.DeliveryAddressLine1 IS NOT NULL AND cu.DeliveryAddressLine2 IS NOT NULL THEN CONCAT(cu.DeliveryAddressLine1, ',', cu.DeliveryAddressLine2)
                   WHEN cu.DeliveryAddressLine1 IS NULL AND cu.DeliveryAddressLine2 IS NOT NULL THEN cu.DeliveryAddressLine2
                   WHEN cu.DeliveryAddressLine1 IS NOT NULL AND cu.DeliveryAddressLine2 IS NULL THEN cu.DeliveryAddressLine1
                   ELSE NULL
               END AS Direccion,
               CASE
                   WHEN cu.PostalAddressLine1 IS NOT NULL AND cu.PostalAddressLine2 IS NOT NULL THEN CONCAT(cu.PostalAddressLine1, ',', cu.PostalAddressLine2)
                   WHEN cu.PostalAddressLine1 IS NULL AND cu.PostalAddressLine2 IS NOT NULL THEN cu.PostalAddressLine2
                   WHEN cu.PostalAddressLine1 IS NOT NULL AND cu.PostalAddressLine2 IS NULL THEN cu.PostalAddressLine1
                   ELSE NULL
               END AS DireccionPostal,
               cu.DeliveryLocation AS MapaLocalizacion,
               'LIMON' AS Sucursal
        FROM CORPORATIVO.Sales.Customers cu
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.CustomerCategories') ca
               ON cu.CustomerID = ca.CustomerCategoryID
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.BuyingGroups') bg
               ON cu.CustomerID = bg.BuyingGroupID
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.Customers') cu_suc
               ON cu.CustomerID = cu_suc.CustomerID
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Application.DeliveryMethods') dm
               ON cu_suc.DeliveryMethodID = dm.DeliveryMethodID
        LEFT JOIN Application.Cities ci
               ON cu.DeliveryCityID = ci.CityID
        LEFT JOIN Application.People pe1
               ON cu.PrimaryContactPersonID = pe1.PersonID
        LEFT JOIN Application.People pe2
               ON cu.AlternateContactPersonID = pe2.PersonID
        WHERE cu.CustomerName = @Nombre
    END
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

CREATE OR ALTER PROCEDURE InformacionInventario
    @Nombre NVARCHAR(100) = NULL,
    @Flag INT = 1 -- 1 = Todas, 2 = SanJose, 3 = Limon
AS
BEGIN
    -- San José
    SELECT si.StockItemName AS NombreProducto,
           su.SupplierName AS NombreProveedor,
           c.ColorName AS Color,
           sg1.StockGroupName AS UnitPackage,
           sg2.StockGroupName AS OuterPackage,
           sih.QuantityOnHand AS CantidadProducto,
           si.Brand AS Marcas,
           si.Size AS Tallas,
           si.TaxRate AS Impuesto,
           si.UnitPrice AS PrecioUnitario,
           'SANJOSE' AS Sucursal
    FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Warehouse.StockItems') si
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Warehouse.StockGroups') sg1
           ON si.UnitPackageID = sg1.StockGroupID
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Warehouse.StockGroups') sg2
           ON si.OuterPackageID = sg2.StockGroupID
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Warehouse.StockItemHoldings') sih
           ON si.StockItemID = sih.StockItemID
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Warehouse.Colors') c
           ON si.ColorID = c.ColorID
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Purchasing.Suppliers') su
           ON si.SupplierID = su.SupplierID
    WHERE (@Nombre IS NULL OR si.StockItemName = @Nombre)
      AND (@Flag = 1 OR @Flag = 2)

    UNION ALL

    -- Limón
    SELECT si.StockItemName AS NombreProducto,
           su.SupplierName AS NombreProveedor,
           c.ColorName AS Color,
           sg1.StockGroupName AS UnitPackage,
           sg2.StockGroupName AS OuterPackage,
           sih.QuantityOnHand AS CantidadProducto,
           si.Brand AS Marcas,
           si.Size AS Tallas,
           si.TaxRate AS Impuesto,
           si.UnitPrice AS PrecioUnitario,
           'LIMON' AS Sucursal
    FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Warehouse.StockItems') si
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Warehouse.StockGroups') sg1
           ON si.UnitPackageID = sg1.StockGroupID
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Warehouse.StockGroups') sg2
           ON si.OuterPackageID = sg2.StockGroupID
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Warehouse.StockItemHoldings') sih
           ON si.StockItemID = sih.StockItemID
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Warehouse.Colors') c
           ON si.ColorID = c.ColorID
    LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Purchasing.Suppliers') su
           ON si.SupplierID = su.SupplierID
    WHERE (@Nombre IS NULL OR si.StockItemName = @Nombre)
      AND (@Flag = 1 OR @Flag = 3)
END;
GO

CREATE OR ALTER PROCEDURE InformacionVentas
    @NumeroFactura INT = NULL,
    @Flag INT = 1 -- 1 = Todas, 2 = SanJose, 3 = Limon
AS
BEGIN
    -- Encabezado Factura
    SELECT *
    FROM
    (
		--San Jose
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
                WHEN p2.FullName IS NULL AND p2.EmailAddress IS NOT NULL THEN p2.EmailAddress
                WHEN p2.FullName IS NOT NULL AND p2.EmailAddress IS NULL THEN p2.FullName
                ELSE NULL
            END AS Vendedor,
            o.OrderDate AS Fecha,
            o.DeliveryInstructions AS InstruccionesEntrega,
            'SANJOSE' AS Sucursal
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.Orders') o
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.Customers') c
            ON o.CustomerID = c.CustomerID
        LEFT JOIN Application.DeliveryMethods d
            ON c.DeliveryMethodID = d.DeliveryMethodID
        LEFT JOIN Application.People p1
            ON o.ContactPersonID = p1.PersonID
        LEFT JOIN Application.People p2
            ON o.SalespersonPersonID = p2.PersonID
        WHERE (@NumeroFactura IS NULL OR o.OrderID = @NumeroFactura)
          AND (@Flag = 1 OR @Flag = 2)

        UNION ALL

        -- Limón
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
                WHEN p2.FullName IS NULL AND p2.EmailAddress IS NOT NULL THEN p2.EmailAddress
                WHEN p2.FullName IS NOT NULL AND p2.EmailAddress IS NULL THEN p2.FullName
                ELSE NULL
            END AS Vendedor,
            o.OrderDate AS Fecha,
            o.DeliveryInstructions AS InstruccionesEntrega,
            'LIMON' AS Sucursal
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.Orders') o
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.Customers') c
            ON o.CustomerID = c.CustomerID
        LEFT JOIN Application.DeliveryMethods d
            ON c.DeliveryMethodID = d.DeliveryMethodID
        LEFT JOIN Application.People p1
            ON o.ContactPersonID = p1.PersonID
        LEFT JOIN Application.People p2
            ON o.SalespersonPersonID = p2.PersonID
        WHERE (@NumeroFactura IS NULL OR o.OrderID = @NumeroFactura)
          AND (@Flag = 1 OR @Flag = 3)
    ) AS Encabezado
    ORDER BY NumeroFactura;

    -- Detalle Factura
    SELECT *
    FROM
    (
        -- San José
        SELECT 
            ol.OrderID AS NumeroFactura,
            si.StockItemName AS NombreProducto, 
            ol.Quantity AS Cantidad, 
            ol.UnitPrice AS PrecioUnitario, 
            ol.TaxRate / 100 AS ImpuestoAplicado,
            (ol.UnitPrice * (ol.TaxRate / 100)) AS MontoImpuesto,
            (ol.Quantity * ol.UnitPrice) * (1 + ol.TaxRate / 100) AS TotalLinea,
            'SANJOSE' AS Sucursal
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Sales.OrderLines') ol
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_SANJOSE],'SELECT * FROM SANJOSE.Warehouse.StockItems') si
            ON ol.StockItemID = si.StockItemID
        WHERE (@NumeroFactura IS NULL OR ol.OrderID = @NumeroFactura)
          AND (@Flag = 1 OR @Flag = 2)
        UNION ALL
        -- Limón
        SELECT 
            ol.OrderID AS NumeroFactura,
            si.StockItemName AS NombreProducto, 
            ol.Quantity AS Cantidad, 
            ol.UnitPrice AS PrecioUnitario, 
            ol.TaxRate / 100 AS ImpuestoAplicado,
            (ol.UnitPrice * (ol.TaxRate / 100)) AS MontoImpuesto,
            (ol.Quantity * ol.UnitPrice) * (1 + ol.TaxRate / 100) AS TotalLinea,
            'LIMON' AS Sucursal
        FROM OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Sales.OrderLines') ol
        LEFT JOIN OPENQUERY([DESKTOP-BE6OQQA\NODO_LIMON],'SELECT * FROM LIMON.Warehouse.StockItems') si
            ON ol.StockItemID = si.StockItemID
        WHERE (@NumeroFactura IS NULL OR ol.OrderID = @NumeroFactura)
          AND (@Flag = 1 OR @Flag = 3)
    ) AS Detalle
    ORDER BY NumeroFactura, NombreProducto;
END;
GO
