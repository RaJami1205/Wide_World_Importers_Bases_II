import React, { useEffect, useState } from "react";
import "../../Styles/InfoTipo1.css";

const InfoProveedores = ({ nombreCliente, onClose }) => {
  const [cliente, setCliente] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchCliente = async () => {
      if (!nombreCliente) return;

      setLoading(true);
      setError("");

      try {
        const response = await fetch(
          `http://localhost:3000/api/proveedores/info?Nombre=${encodeURIComponent(nombreCliente)}`
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
          <h2>Información del Cliente</h2>
          <button className="btn-close" onClick={onClose}>
            ✕
          </button>
        </div>

        {loading && <p className="text-center">Cargando información...</p>}
        {error && <p className="text-error">{error}</p>}

        {!loading && cliente && (
          <>
            <div className="info-grid">
              <div><strong>Codigo:</strong> {cliente.CodigoProveedor}</div>
              <div><strong>Nombre:</strong> {cliente.NombreProveedor}</div>
              <div><strong>Categoría:</strong> {cliente.CategoriaProveedor}</div>
              <div><strong>Contacto principal:</strong> {cliente.ContactoPrincipal || "No especificado"}</div>
              <div><strong>Contacto alternativo:</strong> {cliente.ContactoAlternativo || "No especificado"}</div>
              <div><strong>Método de entrega:</strong> {cliente.MetodoEntrega || "No especificado"}</div>
              <div><strong>Ciudad de entrega:</strong> {cliente.CiudadEntrega}</div>
              <div><strong>Código postal:</strong> {cliente.CodigoPostal}</div>
              <div><strong>Fax:</strong> {cliente.FAX}</div>
              <div><strong>Teléfono:</strong> {cliente.Telefono}</div>
              <div>
                <strong>Sitio web:</strong>{" "}
                <a href={cliente.SitioWeb} target="_blank" rel="noopener noreferrer">
                  {cliente.SitioWeb}
                </a>
              </div>
              <div><strong>Dirección:</strong> {cliente.Direccion}</div>
              <div><strong>Dirección postal:</strong> {cliente.DireccionPostal}</div>
              <div><strong>Nombre Banco:</strong> {cliente.NombreBanco}</div>
              <div><strong>Dias a Pagar:</strong>{cliente.DiasPagar} </div>
              <div><strong>Numero Cuenta Corriente:</strong>{cliente.NumeroCuentaCorriente}</div>
            </div>

            {cliente.MapaLocalizacion?.points?.length > 0 && (
              <div className="map-section">
                <h3>Ubicación</h3>
                <iframe
                  title="mapa-cliente"
                  width="100%"
                  height="250"
                  src={`https://www.google.com/maps?q=${cliente.MapaLocalizacion.points[0].x},${cliente.MapaLocalizacion.points[0].y}&output=embed`}
                  allowFullScreen
                ></iframe>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};

export default InfoProveedores;
