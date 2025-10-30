import React, { useEffect, useState } from "react";
import "../../Styles/InfoTipo1.css";

const InfoCliente = ({ nombreCliente, onClose }) => {
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
          `http://localhost:3000/api/clientes/info?Nombre=${encodeURIComponent(nombreCliente)}`
        );
        if (!response.ok) throw new Error("Error al obtener la información del cliente");

        const data = await response.json();
        if (data && data.length > 0) {
          setCliente(data[0]);
        } else {
          setError("No se encontró información del cliente.");
        }
      } catch (err) {
        console.error("Error al obtener cliente:", err);
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
              <div><strong>Nombre:</strong> {cliente.NombreCliente}</div>
              <div><strong>Categoría:</strong> {cliente.CategoriaCliente}</div>
              <div><strong>Grupo de compra:</strong> {cliente.GrupoCompra || "No especificado"}</div>
              <div><strong>Contacto principal:</strong> {cliente.ContactoPrincipal}</div>
              <div><strong>Contacto alternativo:</strong> {cliente.ContactoAlternativo || "No especificado"}</div>
              <div><strong>Cliente a facturar:</strong> {cliente.ClienteAFacturar}</div>
              <div><strong>Método de entrega:</strong> {cliente.MetodoEntrega}</div>
              <div><strong>Ciudad de entrega:</strong> {cliente.CiudadEntrega}</div>
              <div><strong>Código postal:</strong> {cliente.CodigoPostal}</div>
              <div><strong>Fax:</strong> {cliente.Fax}</div>
              <div><strong>Teléfono:</strong> {cliente.Telefono}</div>
              <div><strong>Días para pagar:</strong> {cliente.DiasPagar}</div>
              <div>
                <strong>Sitio web:</strong>{" "}
                <a href={cliente.SitioWeb} target="_blank" rel="noopener noreferrer">
                  {cliente.SitioWeb}
                </a>
              </div>
              <div><strong>Dirección:</strong> {cliente.Direccion}</div>
              <div><strong>Dirección postal:</strong> {cliente.DireccionPostal}</div>
            </div>

            {cliente.MapaLocalizacion?.points?.length > 0 && (
              <div className="map-section">
                <h3>Ubicación aproximada</h3>
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

export default InfoCliente;
