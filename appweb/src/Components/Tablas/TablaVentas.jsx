import { useEffect, useState } from "react";
import "../../Styles/TablaTipo2.css";
import InfoVentas from "../Info/InfoVentas";

function TablaVentas() {
  const [ventas, setVentas] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const [filtros, setFiltros] = useState({
    NumeroFactura: "",
    Nombre: "",
    FechaDesde: "",
    FechaHasta: "",
    MontoMin: "",
    MontoMax: "",
  });

  const [paginaActual, setPaginaActual] = useState(1);
  const ventasPorPagina = 7;
  const [ventaSeleccionada, setVentaSeleccionada] = useState(null);

  const obtenerVentas = async () => {
    try {
      setLoading(true);
      setError(null);

      const query = new URLSearchParams();
        if (filtros.NumeroFactura) query.append("NumeroFactura", filtros.NumeroFactura);
        if (filtros.Nombre.trim()) query.append("NombreCliente", filtros.Nombre);
        if (filtros.FechaDesde) query.append("FechaInicial", filtros.FechaDesde);
        if (filtros.FechaHasta) query.append("FechaFinal", filtros.FechaHasta);
        if (filtros.MontoMin) query.append("MontoMinimo", filtros.MontoMin);
        if (filtros.MontoMax) query.append("MontoMaximo", filtros.MontoMax);

      const response = await fetch(`http://localhost:3000/api/ventas/?${query.toString()}`);
      if (!response.ok) throw new Error(`Error HTTP: ${response.status}`);

      const data = await response.json();
      setVentas(data);
      setPaginaActual(1);
    } catch (err) {
      console.error("Error al obtener las ventas:", err);
      setError("No se pudieron cargar las ventas.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    obtenerVentas();
  }, []);

  const handleChange = (e) => {
    setFiltros({ ...filtros, [e.target.name]: e.target.value });
  };

  const indexUltimo = paginaActual * ventasPorPagina;
  const indexPrimero = indexUltimo - ventasPorPagina;
  const ventasActuales = ventas.slice(indexPrimero, indexUltimo);
  const totalPaginas = Math.ceil(ventas.length / ventasPorPagina);
  const cambiarPagina = (numero) => setPaginaActual(numero);

  const maxPaginasVisibles = 5;
  let startPage = Math.max(1, paginaActual - Math.floor(maxPaginasVisibles / 2));
  let endPage = Math.min(totalPaginas, startPage + maxPaginasVisibles - 1);
  if (endPage - startPage + 1 < maxPaginasVisibles) {
    startPage = Math.max(1, endPage - maxPaginasVisibles + 1);
  }

  return (
    <div className="container">
      <div className="card">
        <h2>Módulo de Ventas</h2>
        <div className="filters-container">
          <div className="filters-inputs">
            <input
              type="text"
              name="Nombre"
              placeholder="Nombre del cliente"
              value={filtros.Nombre}
              onChange={handleChange}
              className="input-filtro"
            />
            <input
              type="date"
              name="FechaDesde"
              placeholder="Fecha Desde"
              value={filtros.FechaDesde}
              onChange={handleChange}
              className="input-filtro"
            />
            <input
              type="date"
              name="FechaHasta"
              placeholder="Fecha Hasta"
              value={filtros.FechaHasta}
              onChange={handleChange}
              className="input-filtro"
            />
            <input
              type="number"
              name="MontoMin"
              placeholder="Monto mínimo"
              min={0}
              step={1}
              value={filtros.MontoMin}
              onChange={handleChange}
              className="input-filtro"
            />
            <input
              type="number"
              name="MontoMax"
              placeholder="Monto máximo"
              min={0}
              step={1}
              value={filtros.MontoMax}
              onChange={handleChange}
              className="input-filtro"
            />
          </div>
          <div className="filters-buttons">
            <button className="btn-buscar" onClick={obtenerVentas}>
              Confirmar búsqueda
            </button>
            <button
              className="btn-limpiar"
              onClick={() => {
                setFiltros({
                  Nombre: "",
                  MetodoEntrega: "",
                  FechaDesde: "",
                  FechaHasta: "",
                  MontoMin: "",
                  MontoMax: "",
                });
                obtenerVentas();
              }}
            >
              Limpiar filtros
            </button>
          </div>
        </div>

        {loading ? (
          <p className="text-center text-gray">Cargando ventas...</p>
        ) : error ? (
          <p className="text-center text-red">{error}</p>
        ) : (
          <>
            <table>
              <thead>
                <tr>
                  <th>Número de factura</th>
                  <th>Fecha</th>
                  <th>Cliente</th>
                  <th>Método de Entrega</th>
                  <th>Monto</th>
                </tr>
              </thead>
              <tbody>
                {ventasActuales.length > 0 ? (
                  ventasActuales.map((venta, index) => (
                    <tr
                      key={index}
                      onClick={() => setVentaSeleccionada(venta.NumeroFactura)}
                      className="fila-cliente"
                    >
                      <td>{venta.NumeroFactura}</td>
                      <td>{new Date(venta.Fecha).toLocaleDateString()}</td>
                      <td>{venta.NombreCliente}</td>
                      <td>{venta.MetodoEntrega}</td>
                      <td>{venta.Monto?.toFixed(2) || "-"}</td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="5" className="text-center italic">
                      No se encontraron resultados.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>

            {totalPaginas > 1 && (
              <div className="pagination">
                {startPage > 1 && (
                  <>
                    <button onClick={() => cambiarPagina(1)}>1</button>
                    <span>...</span>
                  </>
                )}
                {Array.from({ length: endPage - startPage + 1 }, (_, i) => startPage + i).map(
                  (num) => (
                    <button
                      key={num}
                      onClick={() => cambiarPagina(num)}
                      className={paginaActual === num ? "active" : ""}
                    >
                      {num}
                    </button>
                  )
                )}
                {endPage < totalPaginas && (
                  <>
                    <span>...</span>
                    <button onClick={() => cambiarPagina(totalPaginas)}>
                      {totalPaginas}
                    </button>
                  </>
                )}
              </div>
            )}
          </>
        )}
      </div>
      {ventaSeleccionada && (
        <InfoVentas
          numeroFactura={ventaSeleccionada}
          onClose={() => setVentaSeleccionada(null)}
        />
      )}
    </div>
  );
}

export default TablaVentas;
