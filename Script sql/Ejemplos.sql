-- Pruebas para ObtenerClientes
EXEC ObtenerClientes;
EXEC ObtenerClientes @Nombre = 'Abel';
EXEC ObtenerClientes @Categoria = 'Novelty';
EXEC ObtenerClientes @MetodoEntrega = 'Van';
EXEC ObtenerClientes @Nombre = 'Aak', @Categoria = 'Super', @MetodoEntrega = 'Van';

-- Pruebas para InformacionCliente
EXEC InformacionCliente @Nombre = 'Aive Petrov';

-- Pruebas para ObtenerProveedores
EXEC ObtenerProveedores;
EXEC ObtenerProveedores @Nombre = 'A Dat';
EXEC ObtenerProveedores @Categoria = 'Novelty';
EXEC ObtenerProveedores @MetodoEntrega = 'Refri';
EXEC ObtenerProveedores @Nombre = 'Con', @Categoria = 'Nov', @MetodoEntrega = 'Ref';

-- Pruebas para InformacionProveedor
EXEC InformacionProveedor @Nombre = 'A Datum Corporation';

-- Pruebas para ObtenerInventarios
EXEC ObtenerInventarios;
EXEC ObtenerInventarios @Nombre = 'Mug';
EXEC ObtenerInventarios @Grupo = 'Nov';
EXEC ObtenerInventarios @CantidadMinima = 10;
EXEC ObtenerInventarios @CantidadMaxima = 100;
EXEC ObtenerInventarios @Nombre = 'Mug', @Grupo = 'Com', @CantidadMinima = 60000, @CantidadMaxima = 100000;

-- Pruebas para InformacionInventario
EXEC InformacionInventario @Nombre = 'DBA joke mug - you might be a DBA if (Black)';

-- Pruebas para ObtenerVentas
EXEC ObtenerVentas;
EXEC ObtenerVentas @NumeroFactura = 1001;
EXEC ObtenerVentas @NombreCliente = 'Linh Dao';
EXEC ObtenerVentas @FechaInicial = '2015-01-01', @FechaFinal = '2016-12-31';
EXEC ObtenerVentas @MontoMinimo = 500, @MontoMaximo = 5000;
EXEC ObtenerVentas @NombreCliente = 'Aakriti Byrraju', @FechaInicial = '2012-01-01', @FechaFinal = '2013-12-31', @MontoMinimo = 500, @MontoMaximo = 5000;

-- Pruebas para InformacionVentas
EXEC InformacionVentas @NumeroFactura = 1001;

-- Pruebas para EstadisticaProveedores
EXEC EstadisticaProveedores;
EXEC EstadisticaProveedores @Nombre = 'Fabrikam, Inc.';
EXEC EstadisticaProveedores @Categoria = 'Novelty Items';
EXEC EstadisticaProveedores @Nombre = 'Contoso, Ltd.', @Categoria = 'Toys';

-- Pruebas para EstadisticasVentasClientes
EXEC EstadisticasVentasClientes;
EXEC EstadisticasVentasClientes @Cliente = 'Adrian Andreasson';
EXEC EstadisticasVentasClientes @Categoria = 'Gift Store';
EXEC EstadisticasVentasClientes @Cliente = 'Agrita Abele', @Categoria = 'Computer Store';

-- Pruebas para Top5ProductosPorGanancia
EXEC Top5ProductosPorGanancia;
EXEC Top5ProductosPorGanancia @AnioInicio = 2014, @AnioFin = 2015;

-- Pruebas para Top5ClientesPorFacturas
EXEC Top5ClientesPorFacturas;
EXEC Top5ClientesPorFacturas @AnioInicio = 2013, @AnioFin = 2015;

-- Pruebas para Top5ProveedoresPorOrdenes
EXEC Top5ProveedoresPorOrdenes;
EXEC Top5ProveedoresPorOrdenes @AnioInicio = 2013, @AnioFin = 2013;

-- Pruebas para ObtenerRangosProductos
EXEC ObtenerRangosProductos;
