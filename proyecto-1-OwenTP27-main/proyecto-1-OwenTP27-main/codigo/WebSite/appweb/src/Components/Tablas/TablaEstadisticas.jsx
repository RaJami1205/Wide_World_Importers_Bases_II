import { useState } from "react";
import "../../Styles/TablaTipo3.css";

function TablaEstadisticas() {
  const [datos, setDatos] = useState([]);
  const [tipoConsulta, setTipoConsulta] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [filtros, setFiltros] = useState({
    Cliente: "",
    Categoria: "",
    Nombre: "",
    AnioInicio: "",
    AnioFin: "",
  });
  const [paginaActual, setPaginaActual] = useState(1);
  const filasPorPagina = 7;
  const handleChange = (e) => {
    setFiltros({ ...filtros, [e.target.name]: e.target.value });
  };
  const obtenerDatos = async () => {
    if (!tipoConsulta) return;
    setLoading(true);
    setError(null);

    try {
      const query = new URLSearchParams();

      switch (tipoConsulta) {
        case "clientes":
          if (filtros.Cliente.trim()) query.append("Cliente", filtros.Cliente);
          if (filtros.Categoria.trim()) query.append("Categoria", filtros.Categoria);
          break;
        case "topclientes":
          if (filtros.AnioInicio) query.append("AnioInicio", filtros.AnioInicio);
          if (filtros.AnioFin) query.append("AnioFin", filtros.AnioFin);
          break;
        case "proveedores":
          if (filtros.Nombre.trim()) query.append("Nombre", filtros.Nombre);
          if (filtros.Categoria.trim()) query.append("Categoria", filtros.Categoria);
          break;
        case "topproveedores":
          if (filtros.AnioInicio) query.append("AnioInicio", filtros.AnioInicio);
          if (filtros.AnioFin) query.append("AnioFin", filtros.AnioFin);
          break;
        case "productos":
          if (filtros.AnioInicio) query.append("AnioInicio", filtros.AnioInicio);
          if (filtros.AnioFin) query.append("AnioFin", filtros.AnioFin);
          break;
        default:
          break;
      }

      const response = await fetch(
        `http://localhost:3000/api/estadisticas/${tipoConsulta}?${query.toString()}`
      );

      if (!response.ok) throw new Error(`Error HTTP: ${response.status}`);

      const data = await response.json();
      setDatos(data);
      setPaginaActual(1);
    } catch (err) {
      console.error("Error al obtener datos:", err);
      setError("No se pudieron cargar los datos.");
    } finally {
      setLoading(false);
    }
  };

  const renderFiltros = () => {
    switch (tipoConsulta) {
      case "clientes":
        return (
          <>
            <input
              type="text"
              name="Cliente"
              placeholder="Nombre del cliente"
              value={filtros.Cliente}
              onChange={handleChange}
              className="input-filtro"
            />
            <input
              type="text"
              name="Categoria"
              placeholder="Categoría"
              value={filtros.Categoria}
              onChange={handleChange}
              className="input-filtro"
            />
          </>
        );

      case "topclientes":
      case "topproveedores":
      case "productos":
        return (
          <>
            <input
              type="number"
              name="AnioInicio"
              placeholder="Año inicio"
              min={0}
              step={1}
              value={filtros.AnioInicio}
              onChange={handleChange}
              className="input-filtro"
            />
            <input
              type="number"
              name="AnioFin"
              placeholder="Año fin"
              min={0}
              step={1}
              value={filtros.AnioFin}
              onChange={handleChange}
              className="input-filtro"
            />
          </>
        );

      case "proveedores":
        return (
          <>
            <input
              type="text"
              name="Nombre"
              placeholder="Nombre del proveedor"
              value={filtros.Nombre}
              onChange={handleChange}
              className="input-filtro"
            />
            <input
              type="text"
              name="Categoria"
              placeholder="Categoría"
              value={filtros.Categoria}
              onChange={handleChange}
              className="input-filtro"
            />
          </>
        );

      default:
        return null;
    }
  };

  const indexUltimo = paginaActual * filasPorPagina;
  const indexPrimero = indexUltimo - filasPorPagina;
  const datosActuales = datos.slice(indexPrimero, indexUltimo);
  const totalPaginas = Math.ceil(datos.length / filasPorPagina);

  const cambiarPagina = (num) => setPaginaActual(num);

  const maxPaginasVisibles = 5;
  let startPage = Math.max(1, paginaActual - Math.floor(maxPaginasVisibles / 2));
  let endPage = Math.min(totalPaginas, startPage + maxPaginasVisibles - 1);
  if (endPage - startPage + 1 < maxPaginasVisibles) {
    startPage = Math.max(1, endPage - maxPaginasVisibles + 1);
  }

  return (
    <div className="container">
      <div className="card">
        <h2>Modulo de Estadisticas</h2>
        <div className="filters-buttons main-buttons">
          <button onClick={() => setTipoConsulta("clientes")}>Reporte Clientes</button>
          <button onClick={() => setTipoConsulta("topclientes")}>Top 5 Clientes</button>
          <button onClick={() => setTipoConsulta("proveedores")}>Reporte Proveedores</button>
          <button onClick={() => setTipoConsulta("topproveedores")}>Top 5 Productos</button>
          <button onClick={() => setTipoConsulta("productos")}>Top Productos</button>
        </div>
        {tipoConsulta && (
          <div className="filters-container">
            <div className="filters-inputs">{renderFiltros()}</div>

            <div className="filters-buttons">
              <button className="btn-buscar" onClick={obtenerDatos}>
                Confirmar búsqueda
              </button>
              <button
                className="btn-limpiar"
                onClick={() => {
                  setFiltros({
                    Cliente: "",
                    Categoria: "",
                    Nombre: "",
                    AnioInicio: "",
                    AnioFin: "",
                  });
                  setDatos([]);
                }}
              >
                Limpiar filtros
              </button>
            </div>
          </div>
        )}

        {loading ? (
          <p className="text-center text-gray">Cargando datos...</p>
        ) : error ? (
          <p className="text-center text-red">{error}</p>
        ) : datosActuales.length > 0 ? (
          <>
            <table>
              <thead>
                <tr>
                  {Object.keys(datos[0]).map((col) => (
                    <th key={col}>{col}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {datosActuales.map((fila, i) => (
                  <tr key={i}>
                    {Object.values(fila).map((valor, j) => (
                      <td key={j}>{valor ?? "-"}</td>
                    ))}
                  </tr>
                ))}
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

                {Array.from(
                  { length: endPage - startPage + 1 },
                  (_, i) => startPage + i
                ).map((num) => (
                  <button
                    key={num}
                    onClick={() => cambiarPagina(num)}
                    className={paginaActual === num ? "active" : ""}
                  >
                    {num}
                  </button>
                ))}

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
        ) : (
          tipoConsulta && <p className="text-center italic">No hay datos disponibles.</p>
        )}
      </div>
    </div>
  );
}

export default TablaEstadisticas;
