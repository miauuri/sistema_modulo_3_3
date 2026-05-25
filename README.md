# Sistema Punto de Venta - Tecnomarket (Módulo 3.3)

Este es un sistema de Punto de Venta (POS) desarrollado en PHP y MySQL, orientado a la gestión de productos, clientes, ventas y reportes para una tienda (Tecnomarket).

## Requisitos Previos

Para ejecutar este proyecto, necesitarás un entorno de servidor web local, como **XAMPP**, **WAMP** o **MAMP**, que incluya:
- PHP (versión 7.4 o superior recomendada).
- MySQL.
- Servidor Web (Apache o Nginx).

## Instrucciones de Instalación

1. **Clonar o descargar el proyecto:**
   Coloca los archivos del proyecto dentro de la carpeta pública de tu servidor local. 
   - En XAMPP, esta carpeta es `htdocs` (ejemplo: `C:\xampp\htdocs\sistema_modulo_3_3`).

2. **Configurar la Base de Datos:**
   - Abre tu gestor de base de datos preferido (por ejemplo, phpMyAdmin en `http://localhost/phpmyadmin/`).
   - Crea una nueva base de datos llamada `tecnomarket_db` (el cotejamiento recomendado es `utf8mb4_general_ci`).
   - Importa el archivo SQL unificado que se encuentra en la carpeta `database/`:
     1. `init.sql` (contiene esquema, funciones, triggers y datos iniciales)

3. **Configurar las credenciales (Opcional):**
   Por defecto, el sistema intentará conectarse a la base de datos local usando el usuario `root` sin contraseña. 
   Si tu entorno local requiere contraseña o el nombre de usuario es distinto, edita el archivo `config/database.php` y actualiza las propiedades de la clase `Database`:
   ```php
   private $host = "localhost";
   private $db_name = "tecnomarket_db";
   private $username = "tu_usuario";
   private $password = "tu_contraseña";
   ```

## Ejecución del Sistema

1. Inicia los servicios de Apache y MySQL desde el panel de control de tu entorno (ej. XAMPP Control Panel).
2. Abre tu navegador web e ingresa a la siguiente URL (ajusta el nombre de la carpeta según corresponda):
   `http://localhost/sistema_modulo_3_3/`
3. Si la base de datos incluye los datos iniciales de `init.sql`, podrás iniciar sesión con un usuario administrador predeterminado.
4. Para iniciar sesión, utiliza las credenciales por defecto: **Usuario:** `admin` | **Contraseña:** `admin123` para inicar como administrador, o **Usuario:** `empleado` | **Contraseña:** `empleado123` para inicar como empleado.

## Estructura del Proyecto

- `api/`: Endpoints PHP (API REST) que conectan el frontend con la base de datos (clientes, productos, ventas, login, etc.).
- `config/`: Contiene la configuración de conexión a la base de datos usando PDO.
- `database/`: Scripts SQL para crear y poblar la base de datos (esquema, triggers y stored procedures).
- `docs/`: Documentación adicional sobre la estructura del código y funcionalidades.
- `includes/`: Fragmentos de código PHP reutilizables (cabeceras, pies de página, sidebar).
- `js/`: Archivos y scripts de JavaScript. Destaca `js/api/combinedServices.js`, que gestiona las peticiones Fetch hacia los endpoints de la API.
- Archivos principales en la raíz (`index.php`, `pos.php`, `productos.php`, `clientes.php`, etc.) que renderizan la interfaz (HTML/Tailwind) y conectan con la sesión y la lógica.
