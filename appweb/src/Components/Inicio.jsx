import React from "react";
import { useNavigate } from "react-router-dom";
import { FaShoppingCart, FaUsers, FaBoxes, FaTruck, FaChartBar } from "react-icons/fa";
import "../Styles/Inicio.css";

const modulos = [
  {
    nombre: "Ventas",
    descripcion: "Consulta y administra las ventas registradas en el sistema.",
    ruta: "/ventas",
    icono: <FaShoppingCart />,
    color: "#2563eb", // azul
  },
  {
    nombre: "Clientes",
    descripcion: "Gestiona la información y detalles de los clientes.",
    ruta: "/clientes",
    icono: <FaUsers />,
    color: "#10b981", // verde
  },
  {
    nombre: "Inventario",
    descripcion: "Visualiza y administra los productos disponibles en el inventario.",
    ruta: "/inventario",
    icono: <FaBoxes />,
    color: "#f59e0b", // amarillo
  },
  {
    nombre: "Proveedores",
    descripcion: "Consulta y gestiona los proveedores del sistema.",
    ruta: "/proveedores",
    icono: <FaTruck />,
    color: "#ef4444", // rojo
  },
  {
    nombre: "Estadísticas",
    descripcion: "Obtén estadísticas y reportes del sistema.",
    ruta: "/estadisticas",
    icono: <FaChartBar />,
    color: "#8b5cf6", // morado
  },
];

function Inicio() {
  const navigate = useNavigate();

  return (
    <div className="inicio-container">
      <h2>Bienvenido al Sistema</h2>
      <div className="tarjetas-container">
        {modulos.map((modulo) => (
          <div
            key={modulo.nombre}
            className="tarjeta-modulo"
            style={{ borderTop: `5px solid ${modulo.color}` }}
            onClick={() => navigate(modulo.ruta)}
          >
            <div className="tarjeta-icono" style={{ color: modulo.color }}>
              {modulo.icono}
            </div>
            <h3>{modulo.nombre}</h3>
            <p>{modulo.descripcion}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default Inicio;
