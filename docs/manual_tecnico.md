# Manual Técnico - Sistema Punto de Venta Tecnomarket

## 1. Visión General

Este documento describe la arquitectura técnica del sistema Punto de Venta Tecnomarket, sus componentes, la estructura de la base de datos, los servicios backend, los endpoints API y la integración frontend.

- Lenguaje del servidor: PHP.
- Base de datos: MySQL.
- Interfaz web: HTML, Tailwind CSS, JavaScript.
- Conexión a base de datos: PDO.
- Comunicación frontend-backend: Fetch API con JSON.

---

## 2. Estructura del Proyecto

Carpeta principal:
- `index.php`: Dashboard principal.
- `pos.php`: Interfaz de Punto de Venta.
- `productos.php`: Módulo de inventario.
- `clientes.php`: Módulo de clientes.
- `reportes.php`: Reportes de ventas.
- `login.php` / `logout.php`: Autenticación y cierre de sesión.

Configuración y backend:
- `config/database.php`: Clase `Database` con conexión PDO a MySQL.
- `api/`: Endpoints REST-like que exponen servicios JSON.
- `database/init.sql`: Esquema, datos iniciales, procedimientos almacenados, triggers y vistas.
- `includes/header.php` / `includes/footer.php`: Layout común y control de sesión.
- `js/api/combinedServices.js`: Cliente JavaScript para llamar a la API.

---

## 3. Configuración de la Conexión a la BD

Archivo: `config/database.php`

- Clase: `Database`
- Método: `getConnection()`
- Conexión PDO con:
  - host: `localhost`
  - dbname: `tecnomarket_db`
  - charset: `utf8mb4`
  - usuario: `root`
  - contraseña: `""` (vacía por defecto)
- Modo de errores: `PDO::ERRMODE_EXCEPTION`
- Modo fetch por defecto: `PDO::FETCH_ASSOC`

> Si el entorno usa credenciales distintas de MySQL, actualizar `username` y `password`.

---

## 4. Base de Datos y Modelo de Datos

### 4.1 Tablas principales

- `roles`
  - `id`, `nombre_rol`, `activo`
- `empleados`
  - `id`, `id_rol`, `identificacion`, `nombre`, `usuario`, `password_hash`, `activo`
- `clientes`
  - `id`, `identificacion`, `nombre`, `direccion`, `telefono`, `correo`, `activo`
- `categorias`
  - `id`, `nombre`, `activo`
- `productos`
  - `id`, `id_categoria`, `codigo`, `nombre`, `precio`, `stock`, `stock_minimo`, `activo`
- `ventas`
  - `id`, `id_cliente`, `id_empleado`, `fecha_hora`, `total`, `estado`
- `detalle_venta`
  - `id`, `id_venta`, `id_producto`, `cantidad`, `precio_unitario`, `subtotal`
- `auditoria`
  - `id`, `id_empleado`, `tabla_afectada`, `accion`, `id_registro`, `descripcion`, `fecha_hora`
- `configuracion_sistema`
  - `id`, `clave`, `valor`, `descripcion`

### 4.2 Relaciones

- `empleados.id_rol` → `roles.id`
- `productos.id_categoria` → `categorias.id`
- `ventas.id_cliente` → `clientes.id`
- `ventas.id_empleado` → `empleados.id`
- `detalle_venta.id_venta` → `ventas.id`
- `detalle_venta.id_producto` → `productos.id`
- `auditoria.id_empleado` → `empleados.id`

---

## 5. Procedimientos Almacenados

### 5.1 Cliente

- `crear_cliente(p_nombre, p_identificacion, p_direccion, p_telefono, p_correo)`
- `actualizar_cliente(p_id, p_nombre, p_identificacion, p_direccion, p_telefono, p_correo)`
- `desactivar_cliente(p_id)`
  - Valida que no existan ventas pendientes para el cliente.

### 5.2 Producto

- `crear_producto(p_id_categoria, p_codigo, p_nombre, p_precio, p_stock, p_stock_minimo)`
- `actualizar_producto(p_id, p_id_categoria, p_codigo, p_nombre, p_precio, p_stock, p_stock_minimo)`
- `desactivar_producto(p_id)`

### 5.3 Categoría

- `crear_categoria(p_nombre)`
- `actualizar_categoria(p_id, p_nombre)`
- `desactivar_categoria(p_id)`
  - Evita desactivar categorías con productos activos.

### 5.4 Empleado

- `crear_empleado(p_id_rol, p_identificacion, p_nombre, p_usuario, p_password_hash)`
- `actualizar_empleado(p_id, p_id_rol, p_identificacion, p_nombre, p_usuario, p_password_hash)`
- `desactivar_empleado(p_id)`

### 5.5 Venta y negocio

- `registrar_venta(p_id_cliente, p_id_empleado, p_items JSON)`
  - Valida cliente y empleado activos.
  - Inserta cabecera en `ventas`.
  - Recorre el JSON de `items` y crea `detalle_venta`.
  - Valida stock, actualiza inventario y registra auditoría.
  - Devuelve `id_venta`.

- `obtener_comprobante_venta(p_id_venta)`
  - Devuelve datos de cabecera y detalle para un ticket.

- `productos_stock_bajo()`
  - Devuelve productos con stock igual o menor al mínimo.

- `actualizar_stock_minimo(p_id_producto, p_nuevo_minimo)`
  - Actualiza mínimo global o por producto.

---

## 6. Triggers y Auditoría

### 6.1 Auditoría automática

Se crean triggers para INSERT, UPDATE y DELETE en:
- `clientes`
- `productos`
- `categorias`
- `empleados`
- `ventas`

Cada trigger inserta un registro en `auditoria` con `tabla_afectada`, `accion`, `id_registro` y `descripcion`.

### 6.2 Cálculo y validaciones en `detalle_venta`

- `trg_01_calcular_subtotal`: Antes de insertar `detalle_venta`, calcula `subtotal = cantidad * precio_unitario`.
- `trg_02_validar_stock`: Valida stock suficiente antes de insertar el detalle.
- `trg_recalcular_total`: Después de insertar un detalle, recalcula el total de la venta.
- `trg_evitar_stock_negativo`: Antes de actualizar `productos`, impide `stock < 0`.

---

## 7. Vistas de Base de Datos

- `vista_dashboard`
  - Total clientes activos.
  - Total productos activos.
  - Total empleados activos.
  - Ventas del día.
  - Productos con stock bajo.

- `vista_productos_stock_bajo`
  - Detalle de productos con stock bajo.

- `vista_ventas_detalladas`
  - Unión de ventas, clientes, empleados y detalles de productos.

---

## 8. Servicios Backend y APIs

### 8.1 Autenticación

Archivo: `api/auth.php`

- Método: `POST`
- Entrada: JSON `{ usuario, password }`
- Proceso:
  - Busca empleado activo por `usuario`.
  - Verifica contraseña con `password_verify()`.
  - Inicia sesión PHP (`session_start()`).
  - Define variables de sesión: `usuario_id`, `nombre`, `id_rol`.
- Salida:
  - JSON del usuario (sin `password_hash`).
  - Estado 401 en credenciales inválidas.

### 8.2 Dashboard

Archivo: `api/dashboard.php`

- Método: `GET`
- Retorna JSON con estadísticas de `vista_dashboard`.

### 8.3 Clientes

Archivo: `api/clientes.php`

- `GET /api/clientes.php`
  - Lista clientes activos.
- `GET /api/clientes.php?id=ID`
  - Cliente por ID.
- `POST /api/clientes.php`
  - Crea cliente con `crear_cliente(...)`.
- `PUT /api/clientes.php?id=ID`
  - Actualiza cliente con `actualizar_cliente(...)`.
- `DELETE /api/clientes.php?id=ID`
  - Desactiva cliente con `desactivar_cliente(...)`.

### 8.4 Productos

Archivo: `api/productos.php`

- `GET /api/productos.php`
  - Lista productos activos.
- `GET /api/productos.php?id=ID`
  - Producto por ID.
- `POST /api/productos.php`
  - Crea producto con `crear_producto(...)`.
- `PUT /api/productos.php?id=ID`
  - Actualiza producto con `actualizar_producto(...)`.
- `DELETE /api/productos.php?id=ID`
  - Desactiva producto con `desactivar_producto(...)`.

### 8.5 Categorías

Archivo: `api/categorias.php`

- `GET /api/categorias.php`
  - Lista categorías activas.

### 8.6 Empleados

Archivo: `api/empleados.php`

- `GET /api/empleados.php`
  - Lista empleados activos.

### 8.7 Ventas

Archivo: `api/ventas.php`

- `GET /api/ventas.php`
  - Lista de ventas detalladas desde `vista_ventas_detalladas`.
- `POST /api/ventas.php`
  - Crea venta llamando a `registrar_venta(...)`.
  - Entrada JSON con `detalles` o `items` y `id_cliente`.

### 8.8 Venta por API alternativa

Archivo: `api/api_procesar_venta.php`

- `POST /api/api_procesar_venta.php`
  - Similar a `ventas.php`.
  - Recibe `cliente_id` y `items`.
  - Llama a `CALL registrar_venta(...)`.

---

## 9. Flujo de Sesión y Autorización

- El sistema usa `session_start()` en cada endpoint y en páginas que requieren usuario.
- `includes/header.php` redirige a `login.php` si `$_SESSION['usuario_id']` no está definido.
- La API valida sesión en endpoints sensibles (`ventas.php`, `api_procesar_venta.php`).
- La sesión se cierra en `logout.php`.

---

## 10. Integración Frontend

### 10.1 Servicio de JavaScript

Archivo: `js/api/combinedServices.js`

- `API_BASE_URL = "/sistema_modulo_3_3/api"`
- Función común: `apiCall(endpoint, options)`.
- Servicios disponibles:
  - `getClientes()`, `createCliente()`, `updateCliente()`, `deleteCliente()`
  - `getProductos()`, `createProducto()`, `updateProducto()`, `deleteProducto()`
  - `getCategorias()`
  - `getEmpleados()`
  - `getVentas()`, `createVenta()`
  - `login()`
  - `getDashboardStats()`

### 10.2 Páginas principales

- `login.php`
  - Formulario de autenticación.
  - Verifica usuario contra tabla `empleados`.
- `index.php`
  - Carga estadísticas con `dashboard.php`.
- `pos.php`
  - Construye carrito.
  - Llama a `createVenta()` o `api_procesar_venta.php`.
- `productos.php`
  - CRUD de productos usando `productos.php`.
- `clientes.php`
  - CRUD de clientes usando `clientes.php`.
- `reportes.php`
  - Muestra ventas y permite impresión de ticket.

---

## 11. Diseño de Datos y Flujo Principal

### 11.1 Flujo de venta

1. Usuario inicia sesión.
2. `pos.php` recupera clientes, productos y empleados desde API.
3. Se crea un carrito con productos seleccionados.
4. Se envía JSON al backend.
5. Backend llama `registrar_venta(...)`.
6. Se guarda la venta, se reduce stock y se calcula total.
7. El frontend recibe `id_venta` y muestra confirmación.

### 11.2 Flujo de CRUD de inventario

1. El frontend solicita datos con `GET /api/productos.php`.
2. El usuario crea/edita/elimina productos.
3. El backend ejecuta procedimientos almacenados.
4. Los triggers generan auditoría y validaciones.

---

## 12. Seguridad y Buenas Prácticas Técnicas

- El backend usa PDO y parámetros enlazados para reducir inyección SQL.
- Las contraseñas se almacenan con `password_hash` y se comprueban con `password_verify`.
- Se realiza validación de sesión antes de procesar ventas.
- El acceso CORS se permite con `Access-Control-Allow-Origin: *` en los endpoints API.
  - Esto es útil en desarrollo local, pero debería restringirse en producción.

---

## 13. Despliegue y Configuración

### 13.1 Base de datos

1. Crear la base de datos `tecnomarket_db`.
2. Importar `database/init.sql`.
3. Confirmar que las tablas, vistas y procedimientos se crearon correctamente.

### 13.2 Configuración PHP

- Verificar `config/database.php`.
- Ajustar credenciales de MySQL si no se usa `root` sin contraseña.

### 13.3 Servidor web

- Copiar la carpeta del proyecto al directorio público de Apache.
- Asegurarse de que Apache y MySQL estén ejecutándose.
- Acceder a través de `http://localhost/sistema_modulo_3_3/`.

---

## 14. Archivos Relevantes

- Backend: `api/auth.php`, `api/clientes.php`, `api/productos.php`, `api/ventas.php`, `api/dashboard.php`, `api/categorias.php`, `api/empleados.php`, `api/api_procesar_venta.php`
- Configuración: `config/database.php`
- Interfaz: `index.php`, `pos.php`, `productos.php`, `clientes.php`, `reportes.php`, `login.php`, `logout.php`
- Base de datos: `database/init.sql`
- Servicios JS: `js/api/combinedServices.js`
- Includes: `includes/header.php`, `includes/footer.php`

---

## 15. Notas Técnicas Adicionales

- El sistema mezcla páginas PHP tradicionales con un cliente JavaScript que consume APIs REST-like.
- El diseño de ventas usa JSON nativo de MySQL para procesar arrays de productos.
- El modelo de datos separa cabecera de venta (`ventas`) y detalle (`detalle_venta`), permitiendo consistencia y auditoría.
- Los triggers y procedimientos almacenados encapsulan reglas de negocio clave como stock, totales y auditoría.

Este manual técnico ofrece una visión completa del sistema, permitiendo entender su arquitectura, sus servicios y cómo interactúan los componentes backend y frontend.