# TecnoMarket — Base de Datos MySQL (XAMPP)

## 1. Requisitos
- MySQL 5.7+ o MariaDB 10.2.7+ (por soporte estándar de funciones JSON).
- XAMPP (recomendado para desarrollo local).

## 2. Instalación
Ejecuta los scripts en el siguiente orden desde tu cliente MySQL (phpMyAdmin, MySQL Workbench o consola):
1. `01_schema.sql` — Crea la BD y las tablas base.
2. `02_constraints_indexes.sql` — Añade restricciones e índices.
3. `03_functions.sql` — Crea procedimientos almacenados y funciones de negocio.
4. `04_triggers.sql` — Establece lógica automática (subtotales, auditoría).
5. `05_views_reports.sql` — Despliega vistas para dashboard y reportes.
6. `06_seed.sql` — Carga datos de prueba y usuarios iniciales.
7. *(Opcional)* `07_backup_restore.sql` contiene los comandos para hacer dump y restore de la BD.

## 3. Tablas
| Tabla | Descripción | Relaciones Clave |
|-------|-------------|------------------|
| `roles` | Roles del sistema. | - |
| `empleados` | Usuarios que usan el POS. | FK `id_rol` -> `roles(id)` |
| `clientes` | Personas que realizan las compras. | - |
| `categorias` | Agrupación de productos. | - |
| `productos` | Catálogo de venta. | FK `id_categoria` -> `categorias(id)` |
| `ventas` | Cabecera del ticket. | FK `id_cliente` -> `clientes(id)`, FK `id_empleado` -> `empleados(id)` |
| `detalle_venta` | Líneas del ticket de venta. | FK `id_venta` -> `ventas(id)`, FK `id_producto` -> `productos(id)` |
| `auditoria` | Registro de cambios (logs). | FK `id_empleado` -> `empleados(id)` |
| `configuracion_sistema` | Parámetros globales. | - |

## 4. Procedimientos principales
- `CALL registrar_venta(p_id_cliente INT, p_id_empleado INT, p_items JSON)`
  - *Uso:* `CALL registrar_venta(1, 1, '[{"id_producto":1,"cantidad":2}]');`
- `CALL obtener_comprobante_venta(p_id_venta INT)`
  - *Uso:* `CALL obtener_comprobante_venta(1);`
- `CALL productos_stock_bajo()`
  - *Uso:* `CALL productos_stock_bajo();`

## 5. Vistas disponibles
- `vista_dashboard`: (total_clientes_activos, total_productos_activos, total_empleados_activos, ventas_del_dia, productos_stock_bajo) para el inicio de la app.
- `vista_productos_stock_bajo`: Solo productos bajo el límite.
- `vista_ventas_detalladas`: Ticket completo con joins descriptivos.
- `vista_inventario`: Estado descriptivo del stock.
- `vista_clientes_frecuentes`: Ranking de compradores.
- `vista_productos_mas_vendidos`: Ranking de items más solicitados.

## 6. Usuarios iniciales
| Usuario | Rol | Contraseña Referencial |
|---------|-----|------------------------|
| admin | Administrador | `admin123` |
| empleado | Empleado | `empleado123` |
> **⚠️ Advertencia de Seguridad:** Los hashes almacenados en `06_seed.sql` son ficticios. La aplicación debe encargarse de reemplazar estas contraseñas usando algoritmos reales como bcrypt u Argon2 desde la capa de autenticación en PHP.

## 7. Reglas de negocio
1. El precio y cantidad de productos siempre debe ser mayor a cero.
2. El stock de inventario nunca puede ser negativo.
3. El estado de una venta debe ser COMPLETADA, ANULADA o PENDIENTE.
4. El subtotal de una venta se calcula automáticamente (`cantidad * precio_unitario`).
5. El total de una venta es recalculado automáticamente mediante triggers ante inserciones de detalle.
6. Ningún cliente con ventas PENDIENTES puede ser desactivado (borrado lógico).
7. Ninguna categoría con productos activos puede ser desactivada.
8. Las inserciones, actualizaciones y eliminaciones en las tablas principales se registran en `auditoria`.
9. `registrar_venta` bloquea stock, calcula precios dinámicamente y asegura atomicidad mediante transacciones.
10. La unicidad se impone estricta en identificaciones, usuarios, códigos de producto y roles.

## 8. Cómo registrar una venta
Ejemplo desde la API:
```sql
CALL registrar_venta(
  1, -- ID del Cliente
  2, -- ID del Empleado
  '[
    {"id_producto": 1, "cantidad": 2},
    {"id_producto": 4, "cantidad": 1}
  ]'
);
```
Devolverá el `id_venta` generado.

## 9. Reportes
Las funciones de reportes operan entre rangos de fechas (inclusive):
```sql
-- Reporte de ventas del mes
CALL reporte_ventas_rango('2023-01-01', '2023-01-31');

-- Top clientes
CALL reporte_clientes_frecuentes('2023-01-01', '2023-12-31');
```

## 10. Backup y restauración
Ver el archivo `07_backup_restore.sql` para ver la lista completa de comandos.
Resumen rápido:
```bash
mysqldump -u root -p tecnomarket_db > backup_tecnomarket.sql
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS tecnomarket_db;"
mysql -u root -p tecnomarket_db < backup_tecnomarket.sql
```

## 11. Integración con PHP / XAMPP
- Configura las credenciales en tu backend (generalmente `root` y sin contraseña para XAMPP local).
- Usa `PDO::MYSQL` o `mysqli` para conectarte a la base de datos.
- Las llamadas a la base de datos deben estar preparadas para prevenir inyección SQL.
