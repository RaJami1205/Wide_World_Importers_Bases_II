import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { useState } from "react";

import Navbar from "./Components/Navbar.jsx";
import TablaVentas from "./Components/Tablas/TablaVentas.jsx";
import TablaClientes from "./Components/Tablas/TablaClientes.jsx";
import TablaInventario from "./Components/Tablas/TablaInventario.jsx";
import TablaProveedor from "./Components/Tablas/TablaProveedores.jsx";
import TablaEstadisticas from "./Components/Tablas/TablaEstadisticas.jsx";
import Inicio from "./Components/Inicio.jsx";
import Login from "./Components/Login.jsx";

import "./Styles/App.css";

function App() {
  const [usuario, setUsuario] = useState(null);

  // Ruta protegida
  function RutaProtegida({ children }) {
    if (!usuario) return <Navigate to="/login" />;
    return children;
  }

  return (
    <Router>

      {/* Si no hay usuario, no mostramos el navbar */}
      {usuario && <Navbar usuario={usuario} />}

      <div className="main-content">

        <Routes>

          {/* LOGIN (solo se muestra si NO hay usuario) */}
          <Route 
            path="/login"
            element={
              usuario ? <Navigate to="/" /> : <Login onLogin={setUsuario} />
            }
          />

          {/* RUTAS PROTEGIDAS */}
          <Route 
            path="/" 
            element={
              <RutaProtegida>
                <Inicio usuario={usuario} />
              </RutaProtegida>
            }
          />

          <Route 
            path="/ventas" 
            element={
              <RutaProtegida>
                <TablaVentas />
              </RutaProtegida>
            }
          />

          <Route 
            path="/clientes" 
            element={
              <RutaProtegida>
                <TablaClientes />
              </RutaProtegida>
            }
          />

          <Route 
            path="/inventario" 
            element={
              <RutaProtegida>
                <TablaInventario />
              </RutaProtegida>
            }
          />

          <Route 
            path="/proveedores" 
            element={
              <RutaProtegida>
                <TablaProveedor />
              </RutaProtegida>
            }
          />

          <Route 
            path="/estadisticas" 
            element={
              <RutaProtegida>
                <TablaEstadisticas />
              </RutaProtegida>
            }
          />

        </Routes>
      </div>

    </Router>
  );
}

export default App;
