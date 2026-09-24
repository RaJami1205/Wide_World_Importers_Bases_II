# Wide World Importers - Sistema Web de Bases de Datos Distribuidas 🌐📊

Este repositorio contiene el **Proyecto Semestral de Bases de Datos II**, un sistema web Fullstack enfocado en la implementación, gestión y consulta de una arquitectura de **base de datos distribuida, fragmentada y replicada** mediante un entorno de infraestructura virtualizado con contenedores.

El proyecto simula la operación transaccional y analítica de múltiples sucursales independientes de la empresa ficticia *Wide World Importers*, centralizando la lógica mediante una API REST y exponiendo una interfaz web intuitiva.

---

## 🛠️ Stack Tecnológico e Infraestructura

*   **Infraestructura y Virtualización:** Docker (3 contenedores independientes), WSL2 (Windows Subsystem for Linux).
*   **Base de Datos:** SQL Server para Linux (Imágenes oficiales en contenedores) utilizando Transact-SQL.
*   **Backend (API):** Node.js + Express.js.
*   **Frontend:** React.js + Vite, JavaScript, CSS / HTML5.
*   **Lógica de Datos Avanzada:** Fragmentación horizontal/vertical, replicación de datos e interconexión distribuida entre contenedores.

---

## 🏗️ Arquitectura de Infraestructura y Red (Contenedores)

Para simular de manera realista la descentralización física de las sucursales sin depender de hardware físico adicional, el entorno se diseñó utilizando una arquitectura de microservicios locales:

1. **Entorno WSL2:** Ejecución nativa del motor de Docker sobre el subsistema de Linux para optimizar el rendimiento de E/S.
2. **Nodos Distribuidos (Docker):** Despliegue de **3 contenedores Docker independientes**, cada uno instanciando una imagen oficial de SQL Server que representa una sucursal única o nodo central.
3. **Red Virtual y Conectividad:** Interconexión de los contenedores mediante una red puente personalizada de Docker, permitiendo que la API REST de Node.js enrute las consultas transaccionales de forma aislada a cada base de datos según las reglas de fragmentación y replicación.

---

## 📁 Estructura del Repositorio

El proyecto está modularizado de forma clara para separar las responsabilidades de infraestructura, servidor y cliente:

*   **`Script sql/`**: Contiene los scripts transaccionales en T-SQL necesarios para estructurar las bases de datos en los contenedores, configurar servidores vinculados (Linked Servers), y definir las vistas distribuidas.
*   **`API/`**: Backend desarrollado en Node.js y Express.
    *   `app.js`: Servidor y configurador principal de los middlewares.
    *   `routes/`: Enrutamiento lógico que expone los endpoints de autenticación (Login), consultas dirigidas a los contenedores de las sucursales y operaciones CRUD distribuidas.
*   **`appweb/`**: Frontend desarrollado en React. Componentes de interfaz de usuario para el inicio de sesión, visualización de inventarios y monitoreo de transacciones.

---

## 🚀 Estado actual del Desarrollo

El proyecto demuestra las bases técnicas e infraestructura esenciales de un sistema distribuido:
*   [x] Orquestación e instanciación de los 3 nodos de SQL Server en Docker bajo WSL2.
*   [x] Diseño conceptual y scripts SQL de replicación/fragmentación cruzada.
*   [x] Configuración de la API y conexión con los puertos expuestos de los contenedores (levemente desarrollado).
*   [x] Interfaz de usuario (Frontend) funcional con vistas de autenticación y paneles base.
*   [ ] Optimización final de consultas cruzadas distribuidas y flujos transaccionales avanzados *(No logrado)*.
