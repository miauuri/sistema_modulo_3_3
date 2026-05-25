# Documentación de Endpoints del API - TecnoMarket

Esta documentación detalla los endpoints de la interfaz de programación de aplicaciones (API) del sistema **TecnoMarket**. Todos los endpoints devuelven respuestas en formato **JSON** e incluyen cabeceras para permitir el desarrollo local y el intercambio de recursos de origen cruzado (CORS).

---

## 📌 Información General

* **Base URL:** `/api/` (ejemplo en desarrollo local: `http://localhost/tecnomarket/api/`)
* **Formato de datos:** `application/json` (tanto para peticiones con cuerpo de mensaje como para respuestas)
* **Seguridad y Sesión:** La mayoría de los endpoints protegidos requieren una sesión activa iniciada en el servidor (a través de `session_start()` de PHP).

---

## 📑 Resumen de Endpoints

| Ruta | Método | Descripción | Requiere Sesión |
| :--- | :--- | :--- | :--- |
| [`/api/auth.php`](#1-autenticación-apiauthphp) | `POST` | Inicia sesión del empleado. | ❌ No |
| [`/api/dashboard.php`](#2-métricas-del-dashboard-apidashboardphp) | `GET` | Recupera estadísticas y alertas clave del negocio. | ⚠️ Recomendado |
| [`/api/categorias.php`](#3-categorías-apicategoriasphp) | `GET` | Lista las categorías activas de productos. | ⚠️ Recomendado |
| [`/api/empleados.php`](#4-empleados-apiempleadosphp) | `GET` | Recupera todos los empleados activos. | ⚠️ Recomendado |
| [`/api/clientes.php`](#5-módulo-de-clientes-apiclientesphp) | `GET` | Lista todos los clientes o consulta uno específico. | ⚠️ Recomendado |
| [`/api/clientes.php`](#5-módulo-de-clientes-apiclientesphp) | `POST` | Registra un nuevo cliente en el sistema. | ⚠️ Recomendado |
| [`/api/clientes.php`](#5-módulo-de-clientes-apiclientesphp) | `PUT` | Actualiza un cliente existente. | ⚠️ Recomendado |
| [`/api/clientes.php`](#5-módulo-de-clientes-apiclientesphp) | `DELETE` | Desactiva temporalmente a un cliente. | ⚠️ Recomendado |
| [`/api/productos.php`](#6-módulo-de-productos-apiproductosphp) | `GET` | Lista todos los productos o consulta uno específico. | ⚠️ Recomendado |
| [`/api/productos.php`](#6-módulo-de-productos-apiproductosphp) | `POST` | Agrega un nuevo producto al inventario. | ⚠️ Recomendado |
| [`/api/productos.php`](#6-módulo-de-productos-apiproductosphp) | `PUT` | Edita los detalles de un producto existente. | ⚠️ Recomendado |
| [`/api/productos.php`](#6-módulo-de-productos-apiproductosphp) | `DELETE` | Elimina lógicamente (desactiva) un producto. | ⚠️ Recomendado |
| [`/api/ventas.php`](#7-módulo-de-ventas-apiventasphp) | `GET` | Obtiene el historial de ventas con sus detalles. | ⚠️ Recomendado |
| [`/api/ventas.php`](#7-módulo-de-ventas-apiventasphp) | `POST` | Registra una nueva transacción de venta. | ⚠️ Recomendado |
| [`/api/api_procesar_venta.php`](#8-procesamiento-de-carrito-apiapi_procesar_ventaphp) | `POST` | Valida y almacena una venta desde el POS. | 🔑 **Sí (Obligatorio)** |

---

## 🔌 Detalle de Endpoints

### 1. Autenticación (`api/auth.php`)

Permite a los empleados del sistema iniciar sesión para obtener acceso a los módulos administrativos y al punto de venta.

* **Método:** `POST`
* **CORS:** Soporta petición preliminar `OPTIONS`.
* **Cuerpo de la Petición (JSON):**

| Parámetro | Tipo | Obligatorio | Descripción |
| :--- | :--- | :--- | :--- |
| `usuario` | `string` | Sí | Nombre de usuario del empleado. |
| `password` | `string` | Sí | Contraseña en texto plano. |

* **Ejemplo de Petición:**
```json
{
  "usuario": "admin",
  "password": "mi_password_segura"
}
```

* **Respuestas:**
  * **`200 OK` (Inicio de sesión exitoso):** Crea la sesión en el servidor (`$_SESSION['usuario_id']`, `$_SESSION['nombre']`, `$_SESSION['id_rol']`) y retorna la información básica del usuario.
    ```json
    {
      "id": 1,
      "nombre": "Administrador Sistema",
      "usuario": "admin",
      "id_rol": 1,
      "token": "real-session-started"
    }
    ```
  * **`401 Unauthorized` (Credenciales incorrectas o inactivo):**
    ```json
    {
      "error": "Credenciales incorrectas"
    }
    ```
  * **`500 Internal Server Error` (Fallo de base de datos):**
    ```json
    {
      "error": "Mensaje detallado del error PDOException..."
    }
    ```

---

### 2. Métricas del Dashboard (`api/dashboard.php`)

Proporciona las cifras clave del negocio para renderizar los indicadores rápidos del panel de control. Utiliza la vista SQL `vista_dashboard`.

* **Método:** `GET`
* **Parámetros de URL:** Ninguno.
* **Respuestas:**
  * **`200 OK`:**
    ```json
    {
      "totalClientes": 150,
      "totalProductos": 450,
      "ventasHoy": 12,
      "alertasStock": 4,
      "totalEmpleados": 6
    }
    ```
  * **`500 Internal Server Error`:**
    ```json
    {
      "error": "Error al conectar o consultar la vista vista_dashboard..."
    }
    ```

---

### 3. Categorías (`api/categorias.php`)

Recupera las categorías de productos que se encuentran habilitadas en el sistema.

* **Método:** `GET`
* **Parámetros de URL:** Ninguno.
* **Respuestas:**
  * **`200 OK`:** Retorna un arreglo de objetos de categorías.
    ```json
    [
      {
        "id_categoria": 1,
        "nombre": "Tecnología y Computación"
      },
      {
        "id_categoria": 2,
        "nombre": "Audio y Video"
      }
    ]
    ```

---

### 4. Empleados (`api/empleados.php`)

Obtiene el listado de empleados que actualmente están activos en la organización.

* **Método:** `GET`
* **Parámetros de URL:** Ninguno.
* **Respuestas:**
  * **`200 OK`:** Retorna un arreglo de empleados (sin contraseñas).
    ```json
    [
      {
        "id_empleado": 1,
        "nombre": "Juan Pérez",
        "usuario": "jperez",
        "id_rol": 2
      },
      {
        "id_empleado": 2,
        "nombre": "María López",
        "usuario": "mlopez",
        "id_rol": 1
      }
    ]
    ```

---

### 5. Módulo de Clientes (`api/clientes.php`)

Este endpoint maneja el CRUD (Creación, Lectura, Actualización y Eliminación lógica) para el catálogo de clientes.

#### A. Obtener Clientes (Individual o Colección)
* **Método:** `GET`
* **Parámetros de URL:**
  * `id` (`int`, opcional): Filtra para obtener un solo cliente. Si no se provee, retorna la lista completa.
* **Ejemplo de Petición:** `GET /api/clientes.php?id=3`
* **Respuestas:**
  * **`200 OK` (Con ID provisto):** Devuelve un único objeto.
    ```json
    {
      "id_cliente": 3,
      "identificacion": "12345678-9",
      "nombre": "Juan Soler",
      "direccion": "Av. Las Flores 456",
      "telefono": "+56988887777",
      "correo": "jsoler@correo.com",
      "activo": 1
    }
    ```
  * **`200 OK` (Sin ID provisto):** Devuelve un arreglo de objetos.
    ```json
    [
      {
        "id_cliente": 1,
        "identificacion": "99999999-9",
        "nombre": "Consumidor Final",
        "direccion": "",
        "telefono": "",
        "correo": "",
        "activo": 1
      }
    ]
    ```

#### B. Registrar Cliente
* **Método:** `POST`
* **Cuerpo de la Petición (JSON):**

| Parámetro | Tipo | Obligatorio | Descripción |
| :--- | :--- | :--- | :--- |
| `nombre` | `string` | Sí | Nombre completo o Razón Social. |
| `identificacion` | `string` | Sí | RUT, Cédula o número identificatorio único. |
| `direccion` | `string` | No (por defecto `""`) | Domicilio del cliente. |
| `telefono` | `string` | No (por defecto `""`) | Teléfono de contacto. |
| `correo` | `string` | No (por defecto `""`) | Correo electrónico de facturación. |

* **Ejemplo de Petición:**
```json
{
  "nombre": "Pedro Pascal",
  "identificacion": "18456123-K",
  "direccion": "Santiago Centro",
  "telefono": "+56977766655",
  "correo": "ppascal@correo.com"
}
```
* **Respuestas:**
  * **`200 OK`:** Retorna el mismo objeto de entrada anexando el `id_cliente` generado por el procedimiento almacenado `crear_cliente`.
    ```json
    {
      "nombre": "Pedro Pascal",
      "identificacion": "18456123-K",
      "direccion": "Santiago Centro",
      "telefono": "+56977766655",
      "correo": "ppascal@correo.com",
      "id_cliente": 12
    }
    ```

#### C. Actualizar Cliente
* **Método:** `PUT`
* **Parámetros:**
  * `id` (`int`, opcional en URL `?id=X`): Identifica el cliente a modificar. Como alternativa, puede enviarse en el cuerpo de la petición como `id_cliente`.
* **Cuerpo de la Petición (JSON):**
  * Incluye los mismos campos de la petición `POST`.
* **Ejemplo de Petición:** `PUT /api/clientes.php?id=12` con:
```json
{
  "nombre": "Pedro Pascal Modificado",
  "identificacion": "18456123-K",
  "direccion": "Providencia 1010",
  "telefono": "+56911122233",
  "correo": "ppascal_new@correo.com"
}
```
* **Respuestas:**
  * **`200 OK`:** Retorna el objeto JSON procesado por la base de datos a través del Stored Procedure `actualizar_cliente`.

#### D. Desactivar Cliente (Eliminación Lógica)
* **Método:** `DELETE`
* **Parámetros de URL:**
  * `id` (`int`, obligatorio): El identificador del cliente que se desea dar de baja.
* **Ejemplo de Petición:** `DELETE /api/clientes.php?id=12`
* **Respuestas:**
  * **`200 OK`:**
    ```json
    {
      "success": true
    }
    ```

---

### 6. Módulo de Productos (`api/productos.php`)

Controla el CRUD y consulta de productos del inventario y sus alertas de bajo stock.

#### A. Obtener Productos
* **Método:** `GET`
* **Parámetros de URL:**
  * `id` (`int`, opcional): Filtra para obtener un solo producto. Si se omite, retorna todos los productos activos.
* **Respuestas:**
  * **`200 OK` (Con ID):**
    ```json
    {
      "id_producto": 4,
      "id_categoria": 1,
      "codigo": "PROD-10203",
      "nombre": "Teclado Mecánico RGB",
      "precio": "79.99",
      "stock": 25,
      "stock_minimo": 5,
      "activo": 1,
      "categoria": "Tecnología y Computación"
    }
    ```
  * **`200 OK` (Sin ID):** Retorna una lista con la misma estructura para todos los productos con `activo = TRUE`.

#### B. Registrar Producto
* **Método:** `POST`
* **Cuerpo de la Petición (JSON):**

| Parámetro | Tipo | Obligatorio | Descripción |
| :--- | :--- | :--- | :--- |
| `id_categoria` | `int` | Sí | ID de una categoría activa existente. |
| `codigo` | `string` | Sí | Código de barras o SKU único. |
| `nombre` | `string` | Sí | Nombre comercial del producto. |
| `precio` | `numeric / string` | Sí | Precio de venta unitario. |
| `stock` | `int` | Sí | Cantidad física inicial en inventario. |
| `stock_minimo` | `int` | Sí | Nivel de inventario para activar alerta de reabastecimiento. |

* **Ejemplo de Cuerpo:**
```json
{
  "id_categoria": 1,
  "codigo": "NWE-9988",
  "nombre": "Mouse Óptico Gamer",
  "precio": 24.50,
  "stock": 50,
  "stock_minimo": 10
}
```
* **Respuestas:**
  * **`200 OK`:** Retorna el objeto JSON con el `id_producto` asignado por el Stored Procedure `crear_producto`.
    ```json
    {
      "id_categoria": 1,
      "codigo": "NWE-9988",
      "nombre": "Mouse Óptico Gamer",
      "precio": 24.50,
      "stock": 50,
      "stock_minimo": 10,
      "id_producto": 18
    }
    ```

#### C. Actualizar Producto
* **Método:** `PUT`
* **Parámetros de URL:** `id` (`int`, opcional si se envía `id_producto` en el JSON).
* **Cuerpo de la Petición (JSON):** Estructura idéntica al registro.
* **Respuestas:**
  * **`200 OK`:** Retorna el JSON enviado.

#### D. Desactivar Producto
* **Método:** `DELETE`
* **Parámetros de URL:** `id` (`int`, obligatorio).
* **Respuestas:**
  * **`200 OK`:**
    ```json
    {
      "success": true
    }
    ```

---

### 7. Módulo de Ventas (`api/ventas.php`)

Permite recuperar el registro histórico consolidado de ventas de la tienda y también crear transacciones.

#### A. Obtener Historial de Ventas
* **Método:** `GET`
* **Respuestas:**
  * **`200 OK`:** Retorna un listado estructurado de ventas, agrupando las líneas de detalles por transacción. Proviene de la vista `vista_ventas_detalladas`.
    ```json
    [
      {
        "id_venta": 15,
        "fecha_hora": "2026-05-24 18:22:45",
        "cliente": "Consumidor Final",
        "empleado": "Administrador Sistema",
        "total": "184.48",
        "detalles": [
          {
            "producto": "Teclado Mecánico RGB",
            "cantidad": 2,
            "precio_unitario": "79.99",
            "subtotal": "159.98"
          },
          {
            "producto": "Mouse Óptico Gamer",
            "cantidad": 1,
            "precio_unitario": "24.50",
            "subtotal": "24.50"
          }
        ]
      }
    ]
    ```

#### B. Registrar Nueva Venta
* **Método:** `POST`
* **Cuerpo de la Petición (JSON):**

| Parámetro | Tipo | Obligatorio | Descripción |
| :--- | :--- | :--- | :--- |
| `id_cliente` / `cliente_id` | `int` | No | ID del cliente. Si no se provee, por defecto se usa `1` (Consumidor Final). |
| `detalles` / `items` | `array` | Sí | Arreglo de objetos que representa las líneas de venta. Cada objeto debe tener `{ "id_producto": X, "cantidad": Y }`. |

* **Ejemplo de Cuerpo:**
```json
{
  "cliente_id": 3,
  "items": [
    {
      "id_producto": 4,
      "cantidad": 2
    },
    {
      "id_producto": 18,
      "cantidad": 1
    }
  ]
}
```
* **Respuestas:**
  * **`200 OK`:**
    ```json
    {
      "success": true,
      "id_venta": 16
    }
    ```

---

### 8. Procesamiento de Carrito (`api/api_procesar_venta.php`)

Este es un endpoint dedicado al flujo del módulo Punto de Venta (`pos.php`). Requiere obligatoriamente que el usuario de la terminal tenga una sesión de PHP activa en el servidor, de lo contrario bloqueará la transacción.

* **Método:** `POST`
* **Cuerpo de la Petición (JSON):**

| Parámetro | Tipo | Obligatorio | Descripción |
| :--- | :--- | :--- | :--- |
| `cliente_id` | `int` | No | ID del cliente. Si no se provee, por defecto se usa `1` (Consumidor Final). |
| `items` | `array` | Sí | Listado de productos `{ "id_producto": X, "cantidad": Y }`. |

* **Ejemplo de Petición (desde `pos.php`):**
```json
{
  "cliente_id": 1,
  "items": [
    {
      "id_producto": 4,
      "cantidad": 1
    }
  ]
}
```

* **Respuestas:**
  * **`200 OK` (Venta exitosa):** Llama internamente a la base de datos mediante el stored procedure `registrar_venta` que descuenta el stock de manera atómica.
    ```json
    {
      "success": true,
      "id_venta": 17
    }
    ```
  * **`200 OK` (No autorizado - Sesión inactiva):**
    ```json
    {
      "success": false,
      "error": "No autorizado"
    }
    ```
  * **`200 OK` (Carrito vacío):**
    ```json
    {
      "success": false,
      "error": "El carrito está vacío"
    }
    ```
  * **`200 OK` (Error de procesamiento o de base de datos):**
    ```json
    {
      "success": false,
      "error": "Mensaje detallado de por qué falló la transacción (ej. Stock insuficiente)"
    }
    ```

---

## 🛡️ Gestión de Errores Comunes

El API sigue una estructura de códigos HTTP estándar para simplificar el manejo de errores en el frontend:

| Código HTTP | Significado | Causa Común |
| :--- | :--- | :--- |
| **`200 OK`** | Operación exitosa | La petición fue procesada correctamente por el script y la base de datos. |
| **`401 Unauthorized`** | No autorizado | Credenciales de inicio de sesión inválidas o falta de sesión del servidor en endpoints críticos. |
| **`500 Internal Error`** | Error interno | Excepción atrapada en el bloque `catch (PDOException $e)`. El cuerpo contiene el detalle del error en la llave `"error"`. |
