import React, { useEffect, useState } from "react";
import "../../Styles/InfoTipo1.css";
import InfoProveedores from "../Info/InfoProveedores";

const InfoInventario = ({ nombreCliente, onClose }) => {
  const [cliente, setCliente] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [proveedorSeleccionado, setProveedorSeleccionado] = useState(null);

  useEffect(() => {
    const fetchCliente = async () => {
      if (!nombreCliente) return;

      setLoading(true);
      setError("");

      try {
        const response = await fetch(
          `http://localhost:3000/api/inventarios/info?Nombre=${encodeURIComponent(nombreCliente)}`
        );

        if (!response.ok) throw new Error("Error al obtener la información del Proveedor");

        const data = await response.json();
        if (data && data.length > 0) {
          setCliente(data[0]);
        } else {
          setError("No se encontró información del Proveedor.");
        }
      } catch (err) {
        console.error("Error al obtener Proveedor:", err);
        setError("Ocurrió un error al obtener la información.");
      } finally {
        setLoading(false);
      }
    };

    fetchCliente();
  }, [nombreCliente]);

  if (!nombreCliente) return null;

  return (
    <div className="overlay">
      <div className="overlay-content">
        <div className="overlay-header">
          <h2>Información del Producto</h2>
          <button className="btn-close" onClick={onClose}>
            ✕
          </button>
        </div>

        {loading && <p className="text-center">Cargando información...</p>}
        {error && <p className="text-error">{error}</p>}

        {!loading && cliente && (
          <div className="info-grid">
            <div><strong>Nombre:</strong> {cliente.NombreProducto}</div>
            
            <div
              style={{ color: "#2563eb", cursor: "pointer" }}
              onClick={() => setProveedorSeleccionado(cliente.NombreProveedor)}
            >
              <strong>Nombre del Proveedor:</strong> {cliente.NombreProveedor}
            </div>

            <div><strong>Color:</strong> {cliente.Color || "No especificado"}</div>
            <div><strong>Unidad de Empaquetamiento:</strong> {cliente.UnitPackage || "No especificado"}</div>
            <div><strong>Empaquetamiento:</strong> {cliente.OuterPackage || "No especificado"}</div>
            <div><strong>Marca:</strong> {cliente.Marcas || "No especificado"}</div>
            <div><strong>Cantidad:</strong> {cliente.CantidadProducto || "No especificado"}</div>
            <div><strong>Talla:</strong> {cliente.Tallas}</div>
            <div><strong>Impuesto:</strong> {cliente.Impuesto + "%"}</div>
            <div><strong>Precio Unitario:</strong> {cliente.PrecioUnitario}</div>
          </div>
        )}

        {proveedorSeleccionado && (
          <InfoProveedores
            nombreCliente={proveedorSeleccionado}
            onClose={() => setProveedorSeleccionado(null)}
          />
        )}
      </div>
    </div>
  );
};

export default InfoInventario;
