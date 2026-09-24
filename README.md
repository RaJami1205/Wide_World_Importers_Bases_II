# Wide World Importers - Sistema Web de Bases de Datos Distribuidas 🌐📊

Este repositorio contiene el **Proyecto Semestral de Bases de Datos II**, un sistema web Fullstack enfocado en la implementación, gestión y consulta de una arquitectura de **base de datos distribuida, fragmentada y replicada** utilizando como entorno de datos **SQL Server**.

El proyecto simula la operación transaccional y analítica de múltiples sucursales de la empresa ficticia *Wide World Importers*, centralizando la lógica de datos mediante una API REST y exponiendo una interfaz web intuitiva.

---

## 🛠️ Stack Tecnológico

*   **Frontend:** React.js + Vite, JavaScript, CSS / HTML5.
*   **Backend (API):** Node.js + Express.js.
*   **Base de Datos:** SQL Server (Transact-SQL).
*   **Lógica de Datos Avanzada:** Fragmentación horizontal/vertical, replicación de datos e interconexión distribuida de sucursales.

---

## 🏗️ Arquitectura del Sistema y Datos

El núcleo del proyecto radica en la estrategia de almacenamiento distribuido diseñado para optimizar el rendimiento y la disponibilidad entre nodos:

1. **Diseño de Base de Datos Distribuidia:** Configuración de múltiples servidores de SQL Server que actúan como sucursales independientes pero interconectadas.
2. **Fragmentación:** División lógica de las tablas transaccionales de la base de datos de plantilla *Wide World Importers* para distribuir la carga según criterios geográficos o de sucursal.
3. **Replicación:** Mecanismos de copia de tablas críticas de catálogo para asegurar tolerancia a fallos y lecturas rápidas a nivel local en cada nodo.

---

## 📁 Estructura del Repositorio

El proyecto está modularizado de forma clara para separar las responsabilidades de infraestructura, servidor y cliente:

*   **`Script sql/`**: Contiene los scripts transaccionales en T-SQL necesarios para estructurar las bases de datos locales, configurar los servidores vinculados (Linked Servers), y definir las vistas e instrucciones distribuidas.
*   **`API/`**: Backend desarrollado en Node.js y Express.
    *   `app.js`: Servidor y configurador principal de los middlewares.
    *   `routes/`: Enrutamiento lógico que expone los endpoints de autenticación (Login), consultas a las sucursales y operaciones CRUD distribuidas.
*   **`appweb/`**: Frontend desarrollado en React. Componentes de interfaz de usuario para el inicio de sesión, visualización de inventarios, gestión de reportes y monitoreo de las transacciones entre sucursales.

---

## 🚀 Estado actual del Desarrollo

El proyecto demuestra las bases técnicas e infraestructura esenciales de un sistema distribuido:
*   [x] Diseño conceptual y scripts SQL iniciales de replicación/fragmentación.
*   [x] Configuración de la API y conexión con las instancias de bases de datos (levemente desarrollada).
*   [x] Interfaz de usuario (Frontend) funcional con vistas de autenticación y paneles base.
*   [ ] Optimización final de consultas cruzadas distribuidas y flujos transaccionales avanzados.
