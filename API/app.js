

app.use(cors({
  origin: true, // permite el origen que venga en la petición
  credentials: true
}));

// Importar las rutas
const clientesRoutes = require('./routes/clientes');
const proveedoresRoutes = require('./routes/proveedores');
const inventariosRoutes = require('./routes/inventarios');
const ventasRoutes = require('./routes/ventas');
const estadisticasRoutes = require('./routes/estadisticas');

// Usarlas en el servidor
app.use('/api/clientes', clientesRoutes);
app.use('/api/proveedores', proveedoresRoutes);
app.use('/api/inventarios', inventariosRoutes);
app.use('/api/ventas', ventasRoutes);
app.use('/api/estadisticas', estadisticasRoutes);

// Servidor escuchando
const PORT = 3000;
app.listen(PORT, () => console.log(`Servidor corriendo en http://localhost:${PORT}`));
