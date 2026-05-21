# Documentación del Código

El sistema Tecnomarket está diseñado utilizando un enfoque procedimental y por procedimientos/funciones en la base de datos para la lógica de negocio compleja (como el registro de ventas).

## Archivos Principales

- `index.php`: Panel de control principal (Dashboard) que muestra un resumen de las métricas de la tienda (ventas totales, clientes, etc.).
- `pos.php`: Interfaz del Punto de Venta donde el empleado puede agregar productos al carrito, seleccionar el cliente y procesar la venta.
- `api_procesar_venta.php`: Endpoint (API) que recibe la información del carrito desde `pos.php` en formato JSON y llama al procedimiento almacenado de MySQL (`registrar_venta`) para guardar la transacción.
- `productos.php`: Módulo CRUD para la gestión del inventario de productos.
- `clientes.php`: Módulo CRUD para la gestión de la cartera de clientes.
- `reportes.php`: Sección para generar reportes de ventas filtrados por fechas.
- `login.php` y `logout.php`: Gestión de sesiones de usuario.

## Flujo de Venta

1. En `pos.php`, el usuario busca y añade productos a su carrito (manejado en JavaScript).
2. Al presionar "Cobrar", el frontend envía una solicitud POST a `api_procesar_venta.php` con el ID del cliente y la lista de items en formato JSON.
3. `api_procesar_venta.php` valida la sesión, lee el JSON y utiliza `PDO` para llamar al Stored Procedure `registrar_venta`.
4. El Stored Procedure en la base de datos se encarga de:
   - Crear el registro en la tabla de `ventas`.
   - Iterar el JSON de items para crear registros en `detalle_ventas`.
   - Descontar el stock de los productos vendidos usando Triggers o dentro del mismo procedimiento.
5. Si todo es correcto, la API devuelve el `id_venta`, y el frontend notifica al usuario del éxito de la transacción.

## Consideraciones de Seguridad

- **Sesiones**: Todos los archivos principales y de la API verifican que la variable `$_SESSION['usuario_id']` esté definida.
- **Inyección SQL**: El uso de la clase `PDO` y `bindParam` previene las inyecciones SQL en consultas dinámicas.
- **JSON**: La comunicación entre frontend (POS) y el backend se realiza usando `application/json` y `json_encode`/`json_decode`.
