USE tecnomarket_db;

DELIMITER //

-- Auditoría (MySQL requiere triggers separados por tabla y operación)

-- Clientes
CREATE TRIGGER trg_auditoria_clientes_ins AFTER INSERT ON clientes FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('clientes', 'INSERT', NEW.id, 'Operación INSERT en clientes');
END //

CREATE TRIGGER trg_auditoria_clientes_upd AFTER UPDATE ON clientes FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('clientes', 'UPDATE', NEW.id, 'Operación UPDATE en clientes');
END //

CREATE TRIGGER trg_auditoria_clientes_del AFTER DELETE ON clientes FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('clientes', 'DELETE', OLD.id, 'Eliminación en clientes');
END //

-- Productos
CREATE TRIGGER trg_auditoria_productos_ins AFTER INSERT ON productos FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('productos', 'INSERT', NEW.id, 'Operación INSERT en productos');
END //

CREATE TRIGGER trg_auditoria_productos_upd AFTER UPDATE ON productos FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('productos', 'UPDATE', NEW.id, 'Operación UPDATE en productos');
END //

CREATE TRIGGER trg_auditoria_productos_del AFTER DELETE ON productos FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('productos', 'DELETE', OLD.id, 'Eliminación en productos');
END //

-- Categorias
CREATE TRIGGER trg_auditoria_categorias_ins AFTER INSERT ON categorias FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('categorias', 'INSERT', NEW.id, 'Operación INSERT en categorias');
END //

CREATE TRIGGER trg_auditoria_categorias_upd AFTER UPDATE ON categorias FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('categorias', 'UPDATE', NEW.id, 'Operación UPDATE en categorias');
END //

CREATE TRIGGER trg_auditoria_categorias_del AFTER DELETE ON categorias FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('categorias', 'DELETE', OLD.id, 'Eliminación en categorias');
END //

-- Empleados
CREATE TRIGGER trg_auditoria_empleados_ins AFTER INSERT ON empleados FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('empleados', 'INSERT', NEW.id, 'Operación INSERT en empleados');
END //

CREATE TRIGGER trg_auditoria_empleados_upd AFTER UPDATE ON empleados FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('empleados', 'UPDATE', NEW.id, 'Operación UPDATE en empleados');
END //

CREATE TRIGGER trg_auditoria_empleados_del AFTER DELETE ON empleados FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('empleados', 'DELETE', OLD.id, 'Eliminación en empleados');
END //

-- Ventas
CREATE TRIGGER trg_auditoria_ventas_ins AFTER INSERT ON ventas FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('ventas', 'INSERT', NEW.id, 'Operación INSERT en ventas');
END //

CREATE TRIGGER trg_auditoria_ventas_upd AFTER UPDATE ON ventas FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('ventas', 'UPDATE', NEW.id, 'Operación UPDATE en ventas');
END //

CREATE TRIGGER trg_auditoria_ventas_del AFTER DELETE ON ventas FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_registro, descripcion)
    VALUES ('ventas', 'DELETE', OLD.id, 'Eliminación en ventas');
END //

-- Trigger 3 — Calcular subtotal automáticamente
-- NOTA DE DISEÑO: En MySQL, los triggers del mismo tipo en la misma tabla 
-- se pueden ordenar usando PRECEDES o FOLLOWS, o se ejecutan en orden de creación por defecto.
CREATE TRIGGER trg_01_calcular_subtotal BEFORE INSERT ON detalle_venta FOR EACH ROW
BEGIN
    SET NEW.subtotal = NEW.cantidad * NEW.precio_unitario;
END //

-- Trigger 2 — Validar stock antes de insertar detalle_venta
CREATE TRIGGER trg_02_validar_stock BEFORE INSERT ON detalle_venta FOR EACH ROW
FOLLOWS trg_01_calcular_subtotal
BEGIN
    DECLARE v_stock INT;
    SELECT stock INTO v_stock FROM productos WHERE id = NEW.id_producto;
    IF v_stock < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para producto';
    END IF;
END //

-- Trigger 4 — Recalcular total de venta
CREATE TRIGGER trg_recalcular_total AFTER INSERT ON detalle_venta FOR EACH ROW
BEGIN
    UPDATE ventas 
    SET total = (SELECT COALESCE(SUM(subtotal), 0) FROM detalle_venta WHERE id_venta = NEW.id_venta) 
    WHERE id = NEW.id_venta;
END //

-- Trigger 5 — Evitar stock negativo en UPDATE
CREATE TRIGGER trg_evitar_stock_negativo BEFORE UPDATE ON productos FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
END //

DELIMITER ;
