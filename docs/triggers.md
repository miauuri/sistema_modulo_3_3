# 🎬 Guía de Demostración Técnica (5 minutos)

## ⚡ PARTE 1 — Disparar un Trigger (1.5 min)

Abre **phpMyAdmin → `tecnomarket_db` → SQL** y ejecuta estos comandos uno por uno para ver los triggers en acción:

### Trigger de auditoría automático (`trg_auditoria_clientes_ins`)

```sql
-- Al insertar un cliente, el trigger lo registra en auditoria AUTOMÁTICAMENTE
INSERT INTO clientes (identificacion, nombre, direccion, telefono, correo)
VALUES ('CLI999', 'Cliente Demo', 'Calle Demo', '555-9999', 'demo@test.com');

-- Verificar que el trigger escribió en auditoria sin que nosotros lo hiciéramos
SELECT * FROM auditoria ORDER BY id DESC LIMIT 3;
```

### Trigger de stock negativo (`trg_evitar_stock_negativo`)

```sql
-- Intentar poner stock negativo — el trigger lo BLOQUEA
UPDATE productos SET stock = -5 WHERE id = 1;
-- Resultado esperado: ERROR 1644 - "El stock no puede ser negativo"
```

### Trigger de recálculo de total (`trg_recalcular_total`)

```sql
-- El total de la venta se actualiza SOLO al insertar detalles
SELECT id, total FROM ventas WHERE id = 1; -- Ver total actual
```

---

## 🗄️ PARTE 2 — Ejecutar Stored Procedures (2 min)

### SP de negocio principal — `registrar_venta`

```sql
-- Procesar una venta completa en UNA sola instrucción
CALL registrar_venta(
    1,   -- id_cliente: Juan Perez
    1,   -- id_empleado: Admin
    '[{"id_producto": 3, "cantidad": 1}, {"id_producto": 8, "cantidad": 3}]'
);
-- Muestra el id_venta generado
-- Internamente: crea venta, detalle, descuenta stock, registra auditoría
```

### Verificar que el SP actualizó el stock

```sql
-- Ver stock antes/después del producto 3 (Teclado Mecánico)
SELECT id, nombre, stock FROM productos WHERE id IN (3, 8);
```

### SP de reporte

```sql
-- Reporte de ventas del mes actual
CALL reporte_ventas_rango('2026-05-01', '2026-05-31');

-- Productos más vendidos
CALL reporte_productos_mas_vendidos('2026-05-01', '2026-05-31');

-- Stock bajo
CALL productos_stock_bajo();
```

### SP con validación de negocio (error controlado)

```sql
-- Intentar vender más stock del disponible (Mouse tiene 50 unidades)
CALL registrar_venta(1, 1, '[{"id_producto": 2, "cantidad": 9999}]');
-- Resultado: ERROR controlado "Stock insuficiente para el producto"
```

---

## 🔒 PARTE 3 — Intentar Acceso No Autorizado (1.5 min)

Hay **dos niveles** que puedes demostrar:

### A) A nivel de aplicación (desde el navegador)

```
1. Cierra sesión en http://localhost/sistema_modulo_3_3/logout.php
2. Intenta acceder directamente a:
   http://localhost/sistema_modulo_3_3/pos.php
   http://localhost/sistema_modulo_3_3/reportes.php
   http://localhost/sistema_modulo_3_3/api/dashboard.php
→ Todos redirigen a login.php (verifican $_SESSION['usuario_id'])
```

### B) A nivel de base de datos (desde MySQL con usuario restringido)

```sql
-- Crear usuario con permisos limitados (solo lectura)
CREATE USER 'empleado_demo'@'localhost' IDENTIFIED BY 'pass123';
GRANT SELECT ON tecnomarket_db.ventas TO 'empleado_demo'@'localhost';
GRANT SELECT ON tecnomarket_db.productos TO 'empleado_demo'@'localhost';
FLUSH PRIVILEGES;
```

Luego en phpMyAdmin, desconéctate de `root` y conecta con `empleado_demo`/`pass123`:

```sql
-- Esto SÍ funciona (tiene permiso)
SELECT * FROM ventas;

-- Esto FALLA (sin permiso)
DELETE FROM ventas WHERE id = 1;
-- ERROR: Access denied for user 'empleado_demo'@'localhost'

-- Esto también FALLA (sin permiso)
DROP TABLE clientes;
-- ERROR: Access denied
```

---

## 📋 Script completo para copiar/pegar en orden

Guarda este archivo para la demo:

```sql
-- ===== DEMO TECNOMARKET =====

-- 1. TRIGGER: Auditoría automática
INSERT INTO clientes (identificacion, nombre, direccion, telefono, correo)
VALUES ('CLI999', 'Cliente Demo', 'Calle Demo', '555-9999', 'demo@test.com');
SELECT tabla_afectada, accion, id_registro, descripcion, fecha_hora 
FROM auditoria ORDER BY id DESC LIMIT 5;

-- 2. TRIGGER: Bloqueo de stock negativo
UPDATE productos SET stock = -1 WHERE id = 1;

-- 3. SP: Registrar venta completa
CALL registrar_venta(2, 1, '[{"id_producto":5,"cantidad":1},{"id_producto":10,"cantidad":2}]');

-- 4. SP: Ver stock descontado
SELECT nombre, stock FROM productos WHERE id IN (5, 10);

-- 5. SP: Error controlado por stock
CALL registrar_venta(1, 1, '[{"id_producto":6,"cantidad":9999}]');

-- 6. SP: Reporte
CALL reporte_ventas_rango('2026-05-01', '2026-05-31');
```

---

## 💡 Tips para la presentación

| Momento | Qué decir |
|---|---|
| Trigger auditoría | *"Cada operación queda registrada automáticamente, sin código en PHP"* |
| Trigger stock negativo | *"La BD se protege sola; la regla vive en la capa de datos, no en el frontend"* |
| `registrar_venta` | *"Un solo CALL reemplaza 5 queries y maneja la transacción completa con ROLLBACK automático"* |
| Error controlado | *"El SP valida stock y lanza una excepción estructurada que la app captura"* |
| Acceso no autorizado | *"Doble capa de seguridad: sesiones PHP + permisos de MySQL"* |
