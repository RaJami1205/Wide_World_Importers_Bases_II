import { Link } from "react-router-dom";
import "../Styles/Navbar.css";

function Navbar() {
  return (
    <nav className="navbar">
      <div className="navbar-logo">
        <h1>Wide World Importers</h1>
      </div>
      <ul className="navbar-links">
        <li>
          <Link to="/">Inicio</Link>
        </li>
        <li>
          <Link to="/ventas">Ventas</Link>
        </li>
        <li>
          <Link to="/inventario">Inventario</Link>
        </li>
        <li>
          <Link to="/clientes">Clientes</Link>
        </li>
        <li>
          <Link to="/proveedores">Proveedores</Link>
        </li>
        <li>
          <Link to="/estadisticas">Estadisticas</Link>
        </li>
      </ul>
    </nav>
  );
}

export default Navbar;
