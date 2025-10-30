import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Navbar from "./Components/Navbar.jsx";
import TablaVentas from "./Components/Tablas/TablaVentas.jsx";
import TablaClientes from "./Components/Tablas/TablaClientes.jsx";
import TablaInventario from "./Components/Tablas/TablaInventario.jsx";
import TablaProveedor from "./Components/Tablas/TablaProveedores.jsx";
import TablaEstadisticas from "./Components/Tablas/TablaEstadisticas.jsx";
import Inicio from "./Components/Inicio.jsx";
import "./Styles/App.css"



function App() {
  return (
    <Router>
      <Navbar />
      <div className="main-content">
        <Routes>
          <Route path="/" element={<Inicio />}></Route>
          <Route path="/ventas" element={<TablaVentas />} />
          <Route path="/clientes" element={<TablaClientes />} />
          <Route path="/inventario" element={<TablaInventario />}></Route>
          <Route path="/proveedores" element={<TablaProveedor />}></Route>
          <Route path="/estadisticas" element={<TablaEstadisticas />}></Route>
        </Routes>
      </div>
    </Router>
  );
}

export default App;
