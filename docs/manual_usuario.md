# Manual de Usuario - Sistema Punto de Venta Tecnomarket

## 1. Introducción

Este manual describe el uso del sistema de Punto de Venta (POS) Tecnomarket, diseñado para gestionar productos, clientes, ventas y reportes de una tienda.

El sistema está orientado a dos perfiles principales:
- **Administrador**: Gestiona inventario, clientes y accede a reportes.
- **Empleado**: Opera el Punto de Venta y consulta información de clientes y ventas.

---

## 2. Requisitos previos

Para utilizar el sistema, necesitas:
- Servidor local con PHP y MySQL (por ejemplo, XAMPP).
- Base de datos MySQL con el esquema y datos iniciales importados.
- Navegador web moderno.

---

## 3. Acceso al sistema

### 3.1 Iniciar el servidor

1. Inicia Apache y MySQL en tu entorno local (por ejemplo, XAMPP Control Panel).
2. Coloca la carpeta del proyecto en el directorio público de tu servidor.
   - En XAMPP: `C:\xampp\htdocs\sistema_modulo_3_3`
3. Abre el navegador y entra a:
   - `http://localhost/sistema_modulo_3_3/`

### 3.2 Iniciar sesión

Accede a `login.php` y utiliza uno de los siguientes usuarios de prueba:

- **Administrador**
  - Usuario: `admin`
  - Contraseña: `admin123`
- **Empleado**
  - Usuario: `empleado`
  - Contraseña: `empleado123`

> Si los usuarios no funcionan, revisa la importación de la base de datos y la configuración de conexión en `config/database.php`.

---

## 4. Navegación principal

El sistema cuenta con las siguientes páginas principales:

- `index.php`: Panel de control con métricas y resumen del negocio.
- `pos.php`: Punto de Venta para crear y cobrar ventas.
- `productos.php`: Gestión de inventario de productos.
- `clientes.php`: Gestión de clientes.
- `reportes.php`: Consultas y reportes de ventas.
- `logout.php`: Cierre de sesión.

---

## 5. Panel de control (`index.php`)

En el tablero principal podrás ver:
- Total de ventas.
- Número de clientes registrados.
- Número de empleados activos.
- Información de métricas generales.

Este panel es útil para tener una visión rápida del estado del negocio.

---

## 6. Punto de Venta (`pos.php`)

### 6.1 Seleccionar cliente

1. Usa el selector de cliente para elegir el comprador.
2. Si el cliente no está registrado, primero agrégalo en el módulo de clientes.

### 6.2 Agregar productos al carrito

1. Busca el producto por nombre o código.
2. Selecciona la cantidad deseada.
3. Los productos se añaden al carrito en pantalla.

### 6.3 Finalizar venta

1. Revisa los productos y totales.
2. Presiona el botón de cobrar o finalizar venta.
3. El sistema guarda la venta en la base de datos y reduce el stock de los productos.

---

## 7. Gestión de productos (`productos.php`)

### 7.1 Listado de productos

El módulo muestra el inventario con:
- Código.
- Nombre.
- Categoría.
- Precio.
- Stock disponible.
- Estado.

### 7.2 Agregar producto

1. Haz clic en el botón para añadir producto.
2. Completa los datos obligatorios: categoría, código, nombre, precio y stock.
3. Guarda para que el producto se agregue al inventario.

### 7.3 Editar producto

1. Busca el producto en la lista.
2. Haz clic en editar.
3. Actualiza los datos necesarios.
4. Guarda los cambios.

### 7.4 Eliminar o desactivar producto

- El sistema puede permitir desactivar o eliminar productos según la configuración.
- Si el producto no debe aparecer en ventas, cámbialo a inactivo.

---

## 8. Gestión de clientes (`clientes.php`)

### 8.1 Listado de clientes

El módulo muestra los clientes registrados con:
- Identificación.
- Nombre.
- Dirección.
- Teléfono.
- Correo.

### 8.2 Agregar cliente

1. Haz clic en "Agregar cliente".
2. Completa los campos obligatorios.
3. Guarda el cliente.

### 8.3 Editar cliente

1. Selecciona el cliente en la lista.
2. Modifica la información necesaria.
3. Guarda los cambios.

### 8.4 Eliminar o desactivar cliente

- Para mantener el historial, lo ideal es dejar el cliente inactivo en lugar de eliminarlo.
- El cliente inactivo no debe aparecer en nuevos registros de venta.

---

## 9. Reportes de ventas (`reportes.php`)

### 9.1 Filtrar por fechas

1. Selecciona rango de fecha de inicio y fin.
2. Haz clic en "Buscar" o "Generar reporte".
3. Revisa el listado de ventas que corresponde al periodo.

### 9.2 Consultar ventas

- Verás cada venta con su fecha, cliente, empleado y total.
- Utiliza estos datos para análisis de rendimiento.

---

## 10. Cierre de sesión

Para salir del sistema, haz clic en el enlace o botón de `logout`.
Esto cierra la sesión activa y protege la información del usuario.

---

## 11. Recomendaciones de uso

- Mantén los datos de productos y clientes actualizados.
- Registra correctamente cada venta para tener reportes confiables.
- Usa el perfil de administrador para ajustes de inventario y usuarios.

---

## 12. Problemas comunes

### 12.1 No se puede iniciar sesión

- Verifica que la base de datos esté importada correctamente.
- Asegúrate de que el servidor MySQL esté en ejecución.
- Revisa `config/database.php` si los accesos de MySQL son diferentes a `root` sin contraseña.

### 12.2 No aparecen productos o clientes

- Confirma que la tabla `productos` o `clientes` tenga datos.
- Revisa que el usuario esté activo en la base de datos.

### 12.3 Error al procesar venta

- Asegúrate de tener un cliente seleccionado.
- Verifica que los productos tengan stock suficiente.
- Revisa la conexión con el backend si el navegador muestra errores de red.

---

## 13. Seguridad básica

- No compartas las credenciales de administrador.
- Cierra sesión cuando termines.
- Protege el acceso al servidor local de tu entorno.

---

## 14. Referencias técnicas rápidas

- Archivos de interfaz: `index.php`, `pos.php`, `productos.php`, `clientes.php`, `reportes.php`.
- API backend: `api/auth.php`, `api/api_procesar_venta.php`, `api/dashboard.php`, `api/empleados.php`, `api/clientes.php`, `api/productos.php`, `api/ventas.php`.
- Configuración de BD: `config/database.php`.
- Esquema de base de datos: `database/init.sql`.

---

Este manual está pensado para el uso cotidiano del sistema, facilitando el registro de ventas y el control del inventario en la tienda Tecnomarket.