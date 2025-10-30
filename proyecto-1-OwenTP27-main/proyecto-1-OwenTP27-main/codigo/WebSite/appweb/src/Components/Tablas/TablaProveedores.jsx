import { useEffect, useState } from "react";
import "../../Styles/TablaTipo1.css";
import InfoProveedores from "../Info/InfoProveedores";

function TablaProveedor() {
  const [clientes, setClientes] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [filtros, setFiltros] = useState({
    Nombre: "",
    Categoria: "",
    MetodoEntrega: "",
  });

  const [paginaActual, setPaginaActual] = useState(1);
  const clientesPorPagina = 7;
  const [clienteSeleccionado, setProp] = useState(null);

  const obtenerClientes = async () => {
    try {
      setLoading(true);
      setError(null);

      const query = new URLSearchParams();
      if (filtros.Nombre) query.append("Nombre", filtros.Nombre);
      if (filtros.Categoria) query.append("Categoria", filtros.Categoria);
      if (filtros.MetodoEntrega) query.append("MetodoEntrega", filtros.MetodoEntrega);

      const response = await fetch(`http://localhost:3000/api/proveedores/?${query.toString()}`);
      if (!response.ok) throw new Error(`Error HTTP: ${response.status}`);

      const data = await response.json();
      setClientes(data);
      setPaginaActual(1);
    } catch (err) {
      console.error("Error al obtener los proveedores:", err);
      setError("No se pudieron cargar los proveedores.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    obtenerClientes();
  }, []);

  const handleChange = (e) => {
    setFiltros({ ...filtros, [e.target.name]: e.target.value });
  };

  const indexUltimo = paginaActual * clientesPorPagina;
  const indexPrimero = indexUltimo - clientesPorPagina;
  const clientesActuales = clientes.slice(indexPrimero, indexUltimo);
  const totalPaginas = Math.ceil(clientes.length / clientesPorPagina);
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
        <h2>Módulo de Proveedores</h2>
        <div className="filters-container">
          <div className="filters-inputs">
            <input
              type="text"
              name="Nombre"
              placeholder="Nombre del Proveedor"
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
            <input
              type="text"
              name="MetodoEntrega"
              placeholder="Método de entrega"
              value={filtros.MetodoEntrega}
              onChange={handleChange}
              className="input-filtro"
            />
          </div>
          <div className="filters-buttons">
            <button className="btn-buscar" onClick={obtenerClientes}>
              Confirmar búsqueda
            </button>
            <button
              className="btn-limpiar"
              onClick={() => {
                setFiltros({ Nombre: "", Categoria: "", MetodoEntrega: "" });
                obtenerClientes();
              }}
            >
              Limpiar filtros
            </button>
          </div>
        </div>
        {loading ? (
          <p className="text-center text-gray">Cargando clientes...</p>
        ) : error ? (
          <p className="text-center text-red">{error}</p>
        ) : (
          <>
            <table>
              <thead>
                <tr>
                  <th>Nombre del Cliente</th>
                  <th>Categoría</th>
                  <th>Método de Entrega</th>
                </tr>
              </thead>
              <tbody>
                {clientesActuales.length > 0 ? (
                  clientesActuales.map((cliente, index) => (
                    <tr
                      key={index}
                      onClick={() => setProp(cliente.NombreProveedor)}
                      className="fila-cliente"
                    >
                      <td>{cliente.NombreProveedor}</td>
                      <td>{cliente.CategoriaProveedor}</td>
                      <td>{cliente.MetodoEntrega || "No especificado"} </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="3" className="text-center italic">
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
      {clienteSeleccionado && (
        <InfoProveedores
          nombreCliente={clienteSeleccionado}
          onClose={() => setProp(null)}
        />
      )}
    </div>
  );
}

export default TablaProveedor;
