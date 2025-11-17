CREATE PROCEDURE EstadisticaProveedores
    @Nombre NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL,
	@Flag INT = 1
AS
BEGIN
	IF @Flag = 1
	BEGIN;
		WITH Sucursales AS (
			SELECT 
				s.SupplierName,
				sg.StockGroupName,
				si.UnitPrice * pol.ReceivedOuters AS Monto
			FROM Purchasing.PurchaseOrders po
			JOIN Purchasing.Suppliers s ON po.SupplierID = s.SupplierID
			JOIN Purchasing.PurchaseOrderLines pol ON po.PurchaseOrderID = pol.PurchaseOrderID
			JOIN Warehouse.StockItems si ON pol.StockItemID = si.StockItemID
			JOIN SANJOSE.Warehouse.StockItemStockGroups sisg ON si.StockItemID = sisg.StockItemID
			JOIN SANJOSE.Warehouse.StockGroups sg ON sisg.StockGroupID = sg.StockGroupID
			WHERE (@Nombre IS NULL OR s.SupplierName LIKE '%' + @Nombre + '%')
			  AND (@Categoria IS NULL OR sg.StockGroupName LIKE '%' + @Categoria + '%')
			UNION ALL
			SELECT 
				s.SupplierName,
				sg.StockGroupName,
				si.UnitPrice * pol.ReceivedOuters AS Monto
			FROM Purchasing.PurchaseOrders po
			JOIN Purchasing.Suppliers s ON po.SupplierID = s.SupplierID
			JOIN Purchasing.PurchaseOrderLines pol ON po.PurchaseOrderID = pol.PurchaseOrderID
			JOIN Warehouse.StockItems si ON pol.StockItemID = si.StockItemID
			JOIN LIMON.Warehouse.StockItemStockGroups sisg ON si.StockItemID = sisg.StockItemID
			JOIN LIMON.Warehouse.StockGroups sg ON sisg.StockGroupID = sg.StockGroupID
			WHERE (@Nombre IS NULL OR s.SupplierName LIKE '%' + @Nombre + '%')
			  AND (@Categoria IS NULL OR sg.StockGroupName LIKE '%' + @Categoria + '%')
		)

		SELECT
			CASE 
				WHEN SupplierName IS NULL THEN 'Total General'
				ELSE SupplierName
			END AS NombreProveedor,
			CASE
				WHEN StockGroupName IS NULL AND SupplierName IS NOT NULL THEN 'Estadísticas por Categoría del Proveedor'
				WHEN StockGroupName IS NULL AND SupplierName IS NULL THEN ''
				ELSE StockGroupName
			END AS Categoria,
			MAX(Monto) AS MontoMaximo,
			MIN(Monto) AS MontoMinimo,
			AVG(Monto) AS MontoPromedio
		FROM Sucursales
		GROUP BY ROLLUP (SupplierName, StockGroupName)
		ORDER BY SupplierName ASC, StockGroupName DESC;

	END

IF @Flag = 2 --Caso SanJose
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
		JOIN SANJOSE.Warehouse.StockItemStockGroups sisg ON si.StockItemID = sisg.StockItemID
		JOIN SANJOSE.Warehouse.StockGroups sg ON sisg.StockGroupID = sg.StockGroupID
		WHERE (@Nombre IS NULL OR s.SupplierName LIKE '%' + @Nombre + '%')
		  AND (@Categoria IS NULL OR sg.StockGroupName LIKE '%' + @Categoria + '%')
		GROUP BY ROLLUP (s.SupplierName, sg.StockGroupName)
		ORDER BY s.SupplierName ASC, sg.StockGroupName DESC;
	END
IF @Flag = 3 --Caso Limon
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
		JOIN LIMON.Warehouse.StockItemStockGroups sisg ON si.StockItemID = sisg.StockItemID
		JOIN LIMON.Warehouse.StockGroups sg ON sisg.StockGroupID = sg.StockGroupID
		WHERE (@Nombre IS NULL OR s.SupplierName LIKE '%' + @Nombre + '%')
		  AND (@Categoria IS NULL OR sg.StockGroupName LIKE '%' + @Categoria + '%')
		GROUP BY ROLLUP (s.SupplierName, sg.StockGroupName)
		ORDER BY s.SupplierName ASC, sg.StockGroupName DESC;
	END
END;
GO

CREATE OR ALTER PROCEDURE EstadisticasVentasClientes
    @Cliente NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(100) = NULL,
    @Flag INT = 1   -- 1 = todos, 2 = San José, 3 = Limón
AS
BEGIN
    WITH Subtotales AS (
        SELECT *
        FROM (
            SELECT 
                c.CustomerName,
                cc.CustomerCategoryName,
                SUM(il.LineProfit) AS TotalFactura
            FROM SANJOSE.Sales.Invoices i
            JOIN SANJOSE.Sales.Customers c ON i.CustomerID = c.CustomerID
            JOIN SANJOSE.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
            JOIN SANJOSE.Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
            WHERE @Flag = 1 OR @Flag = 2
              AND (@Cliente IS NULL OR c.CustomerName LIKE '%' + @Cliente + '%')
              AND (@Categoria IS NULL OR cc.CustomerCategoryName LIKE '%' + @Categoria + '%')
            GROUP BY c.CustomerName, cc.CustomerCategoryName

            UNION ALL

            SELECT 
                c.CustomerName,
                cc.CustomerCategoryName,
                SUM(il.LineProfit) AS TotalFactura
            FROM LIMON.Sales.Invoices i
            JOIN LIMON.Sales.Customers c ON i.CustomerID = c.CustomerID
            JOIN LIMON.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
            JOIN LIMON.Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
            WHERE @Flag = 1 OR @Flag = 3
              AND (@Cliente IS NULL OR c.CustomerName LIKE '%' + @Cliente + '%')
              AND (@Categoria IS NULL OR cc.CustomerCategoryName LIKE '%' + @Categoria + '%')
            GROUP BY c.CustomerName, cc.CustomerCategoryName
        ) AS X
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
    @Flag INT = 1   -- 1 = todos, 2 = San José, 3 = Limón
AS
BEGIN
--Caso Todos
IF @Flag = 1
BEGIN
    WITH Datos AS (
        SELECT 
            YEAR(i.InvoiceDate) AS Anio,
            si.StockItemName AS Producto,
            il.UnitPrice * il.Quantity AS Ganancia,
            il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100)) AS GananciaImp,
            (il.UnitPrice - si.TypicalWeightPerUnit) * il.Quantity AS GananciaReal
        FROM SANJOSE.Sales.Invoices i
        JOIN SANJOSE.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
        JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID

        UNION ALL

        SELECT 
            YEAR(i.InvoiceDate) AS Anio,
            si.StockItemName AS Producto,
            il.UnitPrice * il.Quantity AS Ganancia,
            il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100)) AS GananciaImp,
            (il.UnitPrice - si.TypicalWeightPerUnit) * il.Quantity AS GananciaReal
        FROM LIMON.Sales.Invoices i
        JOIN LIMON.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
        JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
    ),

    Resultados AS (
        SELECT 
            Anio,
            Producto,
            SUM(Ganancia) AS GananciaTotal,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY SUM(GananciaImp) DESC) AS Posicion
        FROM Datos
        WHERE GananciaReal > 0
        GROUP BY Anio, Producto
    )

    SELECT *
    FROM Resultados
    WHERE Posicion <= 5
      AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
      AND (@AnioFin IS NULL OR Anio <= @AnioFin)
    ORDER BY Anio, Posicion;

END 
--Caso SanJose
ELSE IF @Flag = 2
BEGIN
    WITH Datos AS (
        SELECT 
            YEAR(i.InvoiceDate) AS Anio,
            si.StockItemName AS Producto,
            il.UnitPrice * il.Quantity AS Ganancia,
            il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100)) AS GananciaImp,
            (il.UnitPrice - si.TypicalWeightPerUnit) * il.Quantity AS GananciaReal
        FROM SANJOSE.Sales.Invoices i
        JOIN SANJOSE.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
        JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
    ),

    Resultados AS (
        SELECT 
            Anio,
            Producto,
            SUM(Ganancia) AS GananciaTotal,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY SUM(GananciaImp) DESC) AS Posicion
        FROM Datos
        WHERE GananciaReal > 0
        GROUP BY Anio, Producto
    )

    SELECT *
    FROM Resultados
    WHERE Posicion <= 5
      AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
      AND (@AnioFin IS NULL OR Anio <= @AnioFin)
    ORDER BY Anio, Posicion;
END
--Caso Limon
ELSE IF @Flag = 3
BEGIN
    WITH Datos AS (
        SELECT 
            YEAR(i.InvoiceDate) AS Anio,
            si.StockItemName AS Producto,
            il.UnitPrice * il.Quantity AS Ganancia,
            il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100)) AS GananciaImp,
            (il.UnitPrice - si.TypicalWeightPerUnit) * il.Quantity AS GananciaReal
        FROM LIMON.Sales.Invoices i
        JOIN LIMON.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
        JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
    ),

    Resultados AS (
        SELECT 
            Anio,
            Producto,
            SUM(Ganancia) AS GananciaTotal,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY SUM(GananciaImp) DESC) AS Posicion
        FROM Datos
        WHERE GananciaReal > 0
        GROUP BY Anio, Producto
    )

    SELECT *
    FROM Resultados
    WHERE Posicion <= 5
      AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
      AND (@AnioFin IS NULL OR Anio <= @AnioFin)
    ORDER BY Anio, Posicion;
END 

END;
GO

CREATE PROCEDURE Top5ClientesPorFacturas
    @Flag INT = 1, -- 1 = todas, 2 = SanJose, 3 = Limon
    @AnioInicio INT = NULL,
    @AnioFin INT = NULL
AS
BEGIN
--Caso Todos
    IF @Flag = 1
    BEGIN
        WITH TotalFacturas AS (
            SELECT
                i.InvoiceID,
                c.CustomerName,
                YEAR(i.InvoiceDate) AS Anio,
                SUM(il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100))) AS TotalFactura
            FROM (
                SELECT InvoiceID, CustomerID, InvoiceDate FROM SANJOSE.Sales.Invoices
                UNION ALL
                SELECT InvoiceID, CustomerID, InvoiceDate FROM LIMON.Sales.Invoices
            ) i
            JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
            JOIN (
                SELECT InvoiceID, Quantity, UnitPrice, TaxRate FROM SANJOSE.Sales.InvoiceLines
                UNION ALL
                SELECT InvoiceID, Quantity, UnitPrice, TaxRate FROM LIMON.Sales.InvoiceLines
            ) il ON i.InvoiceID = il.InvoiceID
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
        SELECT *
        FROM TotalesPorCliente
        WHERE Posicion <= 5
          AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
          AND (@AnioFin IS NULL OR Anio <= @AnioFin)
        ORDER BY Anio ASC, CantidadFacturas DESC;
    END
--Caso Limon
    IF @Flag = 2
    BEGIN
        WITH TotalFacturas AS (
            SELECT
                i.InvoiceID,
                c.CustomerName,
                YEAR(i.InvoiceDate) AS Anio,
                SUM(il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100))) AS TotalFactura
            FROM SANJOSE.Sales.Invoices i
            JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
            JOIN SANJOSE.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
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
        SELECT *
        FROM TotalesPorCliente
        WHERE Posicion <= 5
          AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
          AND (@AnioFin IS NULL OR Anio <= @AnioFin)
        ORDER BY Anio ASC, CantidadFacturas DESC;
    END
--Caso Limon
    IF @Flag = 3
    BEGIN
        WITH TotalFacturas AS (
            SELECT
                i.InvoiceID,
                c.CustomerName,
                YEAR(i.InvoiceDate) AS Anio,
                SUM(il.Quantity * il.UnitPrice * (1 + (il.TaxRate / 100))) AS TotalFactura
            FROM LIMON.Sales.Invoices i
            JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
            JOIN LIMON.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
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
        SELECT *
        FROM TotalesPorCliente
        WHERE Posicion <= 5
          AND (@AnioInicio IS NULL OR Anio >= @AnioInicio)
          AND (@AnioFin IS NULL OR Anio <= @AnioFin)
        ORDER BY Anio ASC, CantidadFacturas DESC;
    END

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