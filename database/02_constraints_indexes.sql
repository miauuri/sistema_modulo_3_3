USE tecnomarket_db;

-- Índices requeridos
CREATE INDEX idx_clientes_nombre ON clientes(nombre);
CREATE INDEX idx_clientes_identificacion ON clientes(identificacion);

CREATE INDEX idx_productos_codigo ON productos(codigo);
CREATE INDEX idx_productos_nombre ON productos(nombre);
CREATE INDEX idx_productos_id_categoria ON productos(id_categoria);

CREATE INDEX idx_empleados_usuario ON empleados(usuario);

CREATE INDEX idx_ventas_fecha_hora ON ventas(fecha_hora);
CREATE INDEX idx_ventas_id_cliente ON ventas(id_cliente);
CREATE INDEX idx_ventas_id_empleado ON ventas(id_empleado);

CREATE INDEX idx_detalle_venta_id_producto ON detalle_venta(id_producto);

-- Constraints adicionales
ALTER TABLE ventas ADD CONSTRAINT chk_ventas_estado CHECK (estado IN ('COMPLETADA', 'ANULADA', 'PENDIENTE'));
ALTER TABLE auditoria ADD CONSTRAINT chk_auditoria_accion CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE'));

-- Asegurar que detalle_venta.subtotal = cantidad * precio_unitario 
-- Se maneja mediante trigger por lo que no se fuerza a nivel de CHECK para evitar
-- conflictos si hay redondeos transitorios. El comentario fue movido a la definición de la tabla.
