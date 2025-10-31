import React, { useEffect, useState } from "react";
import "../../Styles/InfoTipo1.css";
import InfoCliente from "../Info/InfoCliente";
import InfoInventario from "../Info/InfoInventario";

const InfoVentas = ({ numeroFactura, onClose }) => {
  const [venta, setVenta] = useState(null);      // Datos generales
  const [detalle, setDetalle] = useState([]);    // Productos
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [clienteSeleccionado, setClienteSeleccionado] = useState(null);
  const [productoSeleccionado, setProductoSeleccionado] = useState(null);

  useEffect(() => {
    const fetchVenta = async () => {
      if (!numeroFactura) return;

      setLoading(true);
      setError("");

      try {
        const response = await fetch(
          `http://localhost:3000/api/ventas/info?NumeroFactura=${encodeURIComponent(numeroFactura)}`
        );
        if (!response.ok) throw new Error("Error al obtener la información de la venta");

        const data = await response.json();
        if (data && data.length === 2) {
          setVenta(data[0][0]);
          setDetalle(data[1]);
        } else {
          setError("No se encontró información de la venta.");
        }
      } catch (err) {
        console.error("Error al obtener venta:", err);
        setError("Ocurrió un error al obtener la información.");
      } finally {
        setLoading(false);
      }
    };

    fetchVenta();
  }, [numeroFactura]);

  if (!numeroFactura) return null;

  return (
    <div className="overlay">
      <div className="overlay-content">
        <div className="overlay-header">
          <h2>Información de la Venta</h2>
          <button className="btn-close" onClick={onClose}>✕</button>
        </div>

        {loading && <p className="text-center">Cargando información...</p>}
        {error && <p className="text-error">{error}</p>}

        {!loading && venta && (
          <>
            <div className="info-grid">
              <div><strong>Número de factura:</strong> {venta.NumeroFactura}</div>
              <div><strong>Fecha:</strong> {new Date(venta.Fecha).toLocaleDateString()}</div>
              <div
                style={{ color: "#2563eb", cursor: "pointer" }}
                onClick={() => setClienteSeleccionado(venta.NombreCliente)}
              >
                <strong>Cliente:</strong> {venta.NombreCliente}
              </div>
              <div><strong>Método de entrega:</strong> {venta.MetodoEntrega}</div>
              <div><strong>Número de orden:</strong> {venta.NumeroOrden}</div>
              <div><strong>Persona contacto:</strong> {venta.PersonaContacto}</div>
              <div><strong>Vendedor:</strong> {venta.Vendedor}</div>
              <div><strong>Instrucciones de entrega:</strong> {venta.InstruccionesEntrega || "No especificado"}</div>
            </div>
            {detalle.length > 0 && (
              <div className="detalle-venta">
                <h3>Detalle de productos</h3>
                <table>
                  <thead>
                    <tr>
                      <th>Producto</th>
                      <th>Cantidad</th>
                      <th>Precio Unitario</th>
                      <th>Impuesto Aplicado</th>
                      <th>Monto Impuesto</th>
                      <th>Total Línea</th>
                    </tr>
                  </thead>
                  <tbody>
                    {detalle.map((item, index) => (
                      <tr key={index}>
                        <td
                          style={{ color: "#2563eb", cursor: "pointer" }}
                          onClick={() => setProductoSeleccionado(item.NombreProducto)}
                        >
                          {item.NombreProducto}
                        </td>
                        <td>{item.Cantidad}</td>
                        <td>{item.PrecioUnitario}</td>
                        <td>{item.ImpuestoAplicado}</td>
                        <td>{item.MontoImpuesto}</td>
                        <td>{item.TotalLinea}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </>
        )}
        {clienteSeleccionado && (
          <InfoCliente
            nombreCliente={clienteSeleccionado}
            onClose={() => setClienteSeleccionado(null)}
          />
        )}

        {productoSeleccionado && (
          <InfoInventario
            nombreCliente={productoSeleccionado}
            onClose={() => setProductoSeleccionado(null)}
          />
        )}
      </div>
    </div>
  );
};

export default InfoVentas;
