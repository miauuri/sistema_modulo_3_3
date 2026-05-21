# Sistema Punto de Venta - Tecnomarket (Módulo 3.3)

Este es un sistema de Punto de Venta (POS) desarrollado en PHP y MySQL, orientado a la gestión de productos, clientes, ventas y reportes para una tienda (Tecnomarket).

## Requisitos Previos

Para ejecutar este proyecto, necesitarás un entorno de servidor web local, como **XAMPP**, **WAMP** o **MAMP**, que incluya:
- PHP (versión 7.4 o superior recomendada).
- MySQL o MariaDB.
- Servidor Web (Apache o Nginx).

## Instrucciones de Instalación

1. **Clonar o descargar el proyecto:**
   Coloca los archivos del proyecto dentro de la carpeta pública de tu servidor local. 
   - En XAMPP, esta carpeta es `htdocs` (ejemplo: `C:\xampp\htdocs\sistema_modulo_3_3`).

2. **Configurar la Base de Datos:**
   - Abre tu gestor de base de datos preferido (por ejemplo, phpMyAdmin en `http://localhost/phpmyadmin/`).
   - Crea una nueva base de datos llamada `tecnomarket_db` (el cotejamiento recomendado es `utf8mb4_general_ci`).
   - Importa los archivos SQL que se encuentran en la carpeta `database/` en orden:
     1. `01_schema.sql`
     2. `02_constraints_indexes.sql`
     3. `03_functions.sql`
     4. `04_triggers.sql`
     5. `05_views_reports.sql`
     6. `06_seed.sql` (para datos iniciales)

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
3. Si la base de datos incluye datos de semilla (`06_seed.sql`), podrás iniciar sesión con un usuario administrador predeterminado (consulta los datos en la base de datos si es necesario).

## Estructura del Proyecto

- `config/`: Contiene la configuración de conexión a la base de datos.
- `database/`: Scripts SQL para crear y poblar la base de datos.
- `docs/`: Documentación adicional sobre la estructura del código y funcionalidades.
- `includes/`: Fragmentos de código reutilizables (cabeceras, pies de página, menús).
- `js/`: Archivos y scripts de JavaScript.
- Archivos principales en la raíz (`index.php`, `pos.php`, `productos.php`, etc.) que manejan la interfaz y la lógica de cada sección.
