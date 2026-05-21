
CREATE DATABASE IF NOT EXISTS tecnomarket_db;

USE tecnomarket_db;

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL,
    activo BOOLEAN DEFAULT TRUE
) COMMENT = 'Roles de usuarios en el sistema (ej. Administrador, Empleado)';

CREATE TABLE empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    identificacion VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_rol) REFERENCES roles(id)
) COMMENT = 'Usuarios del sistema punto de venta';

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identificacion VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    direccion TEXT,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
) COMMENT = 'Clientes registrados para ventas';

CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    activo BOOLEAN DEFAULT TRUE
) COMMENT = 'Categorías de productos tecnológicos';

CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(150) UNIQUE NOT NULL,
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo INT NOT NULL DEFAULT 5,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id)
) COMMENT = 'Catálogo de productos de la tienda';

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12, 2) NOT NULL DEFAULT 0 CHECK (total >= 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'COMPLETADA',
    FOREIGN KEY (id_cliente) REFERENCES clientes(id),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id)
) COMMENT = 'Cabecera de las transacciones de venta';

CREATE TABLE detalle_venta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL CHECK (precio_unitario > 0),
    subtotal DECIMAL(12, 2) NOT NULL COMMENT 'Subtotal del item' CHECK (subtotal >= 0),
    FOREIGN KEY (id_venta) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id)
) COMMENT = 'Items o productos vendidos por cada venta';

CREATE TABLE auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT,
    tabla_afectada VARCHAR(50) NOT NULL,
    accion VARCHAR(20) NOT NULL,
    id_registro INT,
    descripcion TEXT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_empleado) REFERENCES empleados(id)
) COMMENT = 'Registro de acciones críticas realizadas en el sistema';

CREATE TABLE configuracion_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(50) UNIQUE NOT NULL,
    valor VARCHAR(255) NOT NULL,
    descripcion TEXT
) COMMENT = 'Parámetros de configuración global del sistema';
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
USE tecnomarket_db;

DELIMITER //

-- FUNCIONES CRUD BÁSICAS

-- Clientes
CREATE PROCEDURE crear_cliente(IN p_nombre VARCHAR(100), IN p_identificacion VARCHAR(50), IN p_direccion TEXT, IN p_telefono VARCHAR(20), IN p_correo VARCHAR(100))
BEGIN
    INSERT INTO clientes (nombre, identificacion, direccion, telefono, correo, activo)
    VALUES (p_nombre, p_identificacion, p_direccion, p_telefono, p_correo, TRUE);
    SELECT LAST_INSERT_ID() AS id;
END //

CREATE PROCEDURE actualizar_cliente(IN p_id INT, IN p_nombre VARCHAR(100), IN p_identificacion VARCHAR(50), IN p_direccion TEXT, IN p_telefono VARCHAR(20), IN p_correo VARCHAR(100))
BEGIN
    UPDATE clientes
    SET nombre = p_nombre, identificacion = p_identificacion, direccion = p_direccion, telefono = p_telefono, correo = p_correo
    WHERE id = p_id;
END //

CREATE PROCEDURE desactivar_cliente(IN p_id INT)
BEGIN
    IF EXISTS (SELECT 1 FROM ventas WHERE id_cliente = p_id AND estado = 'PENDIENTE') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede desactivar un cliente con ventas pendientes';
    END IF;
    UPDATE clientes SET activo = FALSE WHERE id = p_id;
END //

-- Productos
CREATE PROCEDURE crear_producto(IN p_id_categoria INT, IN p_codigo VARCHAR(50), IN p_nombre VARCHAR(150), IN p_precio DECIMAL(10,2), IN p_stock INT, IN p_stock_minimo INT)
BEGIN
    INSERT INTO productos (id_categoria, codigo, nombre, precio, stock, stock_minimo, activo)
    VALUES (p_id_categoria, p_codigo, p_nombre, p_precio, p_stock, p_stock_minimo, TRUE);
    SELECT LAST_INSERT_ID() AS id;
END //

CREATE PROCEDURE actualizar_producto(IN p_id INT, IN p_id_categoria INT, IN p_codigo VARCHAR(50), IN p_nombre VARCHAR(150), IN p_precio DECIMAL(10,2), IN p_stock INT, IN p_stock_minimo INT)
BEGIN
    UPDATE productos
    SET id_categoria = p_id_categoria, codigo = p_codigo, nombre = p_nombre, precio = p_precio, stock = p_stock, stock_minimo = p_stock_minimo
    WHERE id = p_id;
END //

CREATE PROCEDURE desactivar_producto(IN p_id INT)
BEGIN
    UPDATE productos SET activo = FALSE WHERE id = p_id;
END //

-- Categorias
CREATE PROCEDURE crear_categoria(IN p_nombre VARCHAR(100))
BEGIN
    INSERT INTO categorias (nombre, activo) VALUES (p_nombre, TRUE);
    SELECT LAST_INSERT_ID() AS id;
END //

CREATE PROCEDURE actualizar_categoria(IN p_id INT, IN p_nombre VARCHAR(100))
BEGIN
    UPDATE categorias SET nombre = p_nombre WHERE id = p_id;
END //

CREATE PROCEDURE desactivar_categoria(IN p_id INT)
BEGIN
    IF EXISTS (SELECT 1 FROM productos WHERE id_categoria = p_id AND activo = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede desactivar una categoría con productos activos';
    END IF;
    UPDATE categorias SET activo = FALSE WHERE id = p_id;
END //

-- Empleados
CREATE PROCEDURE crear_empleado(IN p_id_rol INT, IN p_identificacion VARCHAR(50), IN p_nombre VARCHAR(100), IN p_usuario VARCHAR(50), IN p_password_hash VARCHAR(255))
BEGIN
    INSERT INTO empleados (id_rol, identificacion, nombre, usuario, password_hash, activo)
    VALUES (p_id_rol, p_identificacion, p_nombre, p_usuario, p_password_hash, TRUE);
    SELECT LAST_INSERT_ID() AS id;
END //

CREATE PROCEDURE actualizar_empleado(IN p_id INT, IN p_id_rol INT, IN p_identificacion VARCHAR(50), IN p_nombre VARCHAR(100), IN p_usuario VARCHAR(50), IN p_password_hash VARCHAR(255))
BEGIN
    UPDATE empleados
    SET id_rol = p_id_rol, 
        identificacion = p_identificacion, 
        nombre = p_nombre, 
        usuario = p_usuario, 
        password_hash = IF(p_password_hash IS NULL OR p_password_hash = '', password_hash, p_password_hash)
    WHERE id = p_id;
END //

CREATE PROCEDURE desactivar_empleado(IN p_id INT)
BEGIN
    UPDATE empleados SET activo = FALSE WHERE id = p_id;
END //

-- FUNCIONES DE NEGOCIO

CREATE PROCEDURE registrar_venta(IN p_id_cliente INT, IN p_id_empleado INT, IN p_items JSON)
BEGIN
    DECLARE v_id_venta INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_length INT;
    DECLARE v_id_producto INT;
    DECLARE v_cantidad INT;
    DECLARE v_precio_unitario DECIMAL(10,2);
    DECLARE v_stock_actual INT;
    DECLARE v_activo BOOLEAN;
    
    DECLARE exit handler for sqlexception
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validar cliente activo
    IF NOT EXISTS (SELECT 1 FROM clientes WHERE id = p_id_cliente AND activo = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente no existe o no está activo';
    END IF;
    
    -- Validar empleado activo
    IF NOT EXISTS (SELECT 1 FROM empleados WHERE id = p_id_empleado AND activo = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empleado no existe o no está activo';
    END IF;

    -- Insertar venta (total se recalcula luego, trigger no siempre es ideal para sumas mutantes, pero lo mantendremos según diseño original)
    INSERT INTO ventas (id_cliente, id_empleado, estado)
    VALUES (p_id_cliente, p_id_empleado, 'COMPLETADA');
    
    SET v_id_venta = LAST_INSERT_ID();

    -- Procesar items (MySQL 5.7+ JSON support)
    SET v_length = JSON_LENGTH(p_items);
    
    WHILE v_i < v_length DO
        SET v_id_producto = JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', v_i, '].id_producto')));
        SET v_cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', v_i, '].cantidad')));
        
        SELECT precio, stock, activo INTO v_precio_unitario, v_stock_actual, v_activo
        FROM productos WHERE id = v_id_producto FOR UPDATE;
        
        IF v_precio_unitario IS NULL OR NOT v_activo THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe o no está activo';
        END IF;
        
        IF v_stock_actual < v_cantidad THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para el producto';
        END IF;
        
        -- Insertar detalle_venta
        INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal)
        VALUES (v_id_venta, v_id_producto, v_cantidad, v_precio_unitario, v_cantidad * v_precio_unitario);
        
        -- Descontar stock
        UPDATE productos SET stock = stock - v_cantidad WHERE id = v_id_producto;
        
        SET v_i = v_i + 1;
    END WHILE;
    
    -- Insertar en auditoria
    INSERT INTO auditoria (id_empleado, tabla_afectada, accion, id_registro, descripcion)
    VALUES (p_id_empleado, 'ventas', 'INSERT', v_id_venta, 'Registro de venta desde JSON');

    COMMIT;
    
    SELECT v_id_venta AS id_venta;
END //

CREATE PROCEDURE obtener_comprobante_venta(IN p_id_venta INT) 
BEGIN
    SELECT 
        v.id AS id_venta,
        v.fecha_hora,
        c.nombre AS nombre_cliente,
        e.nombre AS nombre_empleado,
        p.nombre AS producto,
        dv.cantidad,
        dv.precio_unitario,
        dv.subtotal,
        v.total
    FROM ventas v
    JOIN clientes c ON v.id_cliente = c.id
    JOIN empleados e ON v.id_empleado = e.id
    JOIN detalle_venta dv ON v.id = dv.id_venta
    JOIN productos p ON dv.id_producto = p.id
    WHERE v.id = p_id_venta;
END //

CREATE PROCEDURE productos_stock_bajo() 
BEGIN
    SELECT 
        p.id AS id_producto,
        p.codigo,
        p.nombre,
        c.nombre AS categoria,
        p.stock,
        p.stock_minimo
    FROM productos p
    JOIN categorias c ON p.id_categoria = c.id
    WHERE p.stock <= p.stock_minimo AND p.activo = TRUE;
END //

CREATE PROCEDURE actualizar_stock_minimo(IN p_id_producto INT, IN p_nuevo_minimo INT)
BEGIN
    IF p_id_producto IS NULL THEN
        UPDATE productos SET stock_minimo = p_nuevo_minimo WHERE activo = TRUE;
    ELSE
        UPDATE productos SET stock_minimo = p_nuevo_minimo WHERE id = p_id_producto;
    END IF;
END //

DELIMITER ;
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
USE tecnomarket_db;

CREATE OR REPLACE VIEW vista_dashboard AS
SELECT 
    (SELECT COUNT(*) FROM clientes WHERE activo = TRUE) AS total_clientes_activos,
    (SELECT COUNT(*) FROM productos WHERE activo = TRUE) AS total_productos_activos,
    (SELECT COUNT(*) FROM empleados WHERE activo = TRUE) AS total_empleados_activos,
    (SELECT COUNT(*) FROM ventas WHERE DATE(fecha_hora) = CURRENT_DATE) AS ventas_del_dia,
    (SELECT COUNT(*) FROM productos WHERE stock <= stock_minimo AND activo = TRUE) AS productos_stock_bajo;

CREATE OR REPLACE VIEW vista_productos_stock_bajo AS
SELECT 
    p.id AS id_producto, 
    p.codigo, 
    p.nombre, 
    c.nombre AS categoria, 
    p.stock, 
    p.stock_minimo, 
    p.precio
FROM productos p
JOIN categorias c ON p.id_categoria = c.id
WHERE p.stock <= p.stock_minimo AND p.activo = TRUE;

CREATE OR REPLACE VIEW vista_ventas_detalladas AS
SELECT 
    v.id AS id_venta, 
    v.fecha_hora, 
    c.nombre AS cliente, 
    e.nombre AS empleado, 
    p.nombre AS producto, 
    dv.cantidad, 
    dv.precio_unitario, 
    dv.subtotal, 
    v.total
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id
JOIN empleados e ON v.id_empleado = e.id
JOIN detalle_venta dv ON v.id = dv.id_venta
JOIN productos p ON dv.id_producto = p.id;

CREATE OR REPLACE VIEW vista_inventario AS
SELECT 
    p.nombre AS producto, 
    p.codigo, 
    c.nombre AS categoria, 
    p.precio, 
    p.stock, 
    p.stock_minimo, 
    CASE 
        WHEN p.stock = 0 THEN 'AGOTADO' 
        WHEN p.stock <= p.stock_minimo THEN 'STOCK BAJO' 
        ELSE 'DISPONIBLE' 
    END AS estado_stock
FROM productos p
JOIN categorias c ON p.id_categoria = c.id;

CREATE OR REPLACE VIEW vista_clientes_frecuentes AS
SELECT 
    c.nombre AS cliente, 
    COUNT(v.id) AS cantidad_ventas, 
    COALESCE(SUM(v.total), 0) AS total_comprado
FROM clientes c
JOIN ventas v ON c.id = v.id_cliente
WHERE v.estado = 'COMPLETADA'
GROUP BY c.id, c.nombre
ORDER BY total_comprado DESC;

CREATE OR REPLACE VIEW vista_productos_mas_vendidos AS
SELECT 
    p.nombre AS producto, 
    COALESCE(SUM(dv.cantidad), 0) AS cantidad_vendida, 
    COALESCE(SUM(dv.subtotal), 0) AS total_generado
FROM productos p
JOIN detalle_venta dv ON p.id = dv.id_producto
JOIN ventas v ON dv.id_venta = v.id
WHERE v.estado = 'COMPLETADA'
GROUP BY p.id, p.nombre
ORDER BY cantidad_vendida DESC;

DELIMITER //

-- Funciones de reporte convertidas a Procedimientos Almacenados en MySQL
CREATE PROCEDURE reporte_ventas_rango(IN p_fecha_inicio DATE, IN p_fecha_fin DATE)
BEGIN
    SELECT v.id AS id_venta, v.fecha_hora, c.nombre AS cliente, e.nombre AS empleado, v.total
    FROM ventas v
    JOIN clientes c ON v.id_cliente = c.id
    JOIN empleados e ON v.id_empleado = e.id
    WHERE DATE(v.fecha_hora) BETWEEN p_fecha_inicio AND p_fecha_fin
    ORDER BY v.fecha_hora DESC;
END //

CREATE PROCEDURE reporte_productos_mas_vendidos(IN p_fecha_inicio DATE, IN p_fecha_fin DATE)
BEGIN
    SELECT p.nombre AS producto, SUM(dv.cantidad) AS unidades_vendidas, SUM(dv.subtotal) AS ingresos
    FROM productos p
    JOIN detalle_venta dv ON p.id = dv.id_producto
    JOIN ventas v ON dv.id_venta = v.id
    WHERE DATE(v.fecha_hora) BETWEEN p_fecha_inicio AND p_fecha_fin AND v.estado = 'COMPLETADA'
    GROUP BY p.id, p.nombre
    ORDER BY unidades_vendidas DESC;
END //

CREATE PROCEDURE reporte_clientes_frecuentes(IN p_fecha_inicio DATE, IN p_fecha_fin DATE)
BEGIN
    SELECT c.nombre AS cliente, COUNT(v.id) AS compras, SUM(v.total) AS total_gastado
    FROM clientes c
    JOIN ventas v ON c.id = v.id_cliente
    WHERE DATE(v.fecha_hora) BETWEEN p_fecha_inicio AND p_fecha_fin AND v.estado = 'COMPLETADA'
    GROUP BY c.id, c.nombre
    ORDER BY total_gastado DESC;
END //

CREATE PROCEDURE reporte_ventas_por_empleado(IN p_fecha_inicio DATE, IN p_fecha_fin DATE)
BEGIN
    SELECT e.nombre AS empleado, COUNT(v.id) AS cantidad_ventas, SUM(v.total) AS total_generado
    FROM empleados e
    JOIN ventas v ON e.id = v.id_empleado
    WHERE DATE(v.fecha_hora) BETWEEN p_fecha_inicio AND p_fecha_fin AND v.estado = 'COMPLETADA'
    GROUP BY e.id, e.nombre
    ORDER BY total_generado DESC;
END //

DELIMITER ;
USE tecnomarket_db;

-- 1. roles
INSERT INTO roles (nombre_rol) VALUES ('Administrador'), ('Empleado');

-- 2. empleados
-- IMPORTANTE: Reemplazar password_hash con bcrypt real generado por la capa de aplicación
INSERT INTO empleados (id_rol, identificacion, nombre, usuario, password_hash) VALUES 
(1, 'ADMIN001', 'Admin Principal', 'admin', '$2y$10$Xwml8WSM2u5z0KJbmxfmue.HO0Z0MStuUTrnOMm93k5GwLKswwfge'),
(2, 'EMP001', 'Empleado Ventas', 'empleado', '$2y$10$2/OP0gja2S.y3/brINAqAOSwGVnSkMYYeT8qBsYP2siS6r7Y1HisS');

-- 3. categorias
INSERT INTO categorias (nombre) VALUES 
('Laptops'), ('Periféricos'), ('Monitores'), ('Audio'), 
('Impresoras'), ('Almacenamiento'), ('Componentes'), ('Accesorios móviles');

-- 4. productos
INSERT INTO productos (id_categoria, codigo, nombre, precio, stock, stock_minimo) VALUES 
(1, 'LAP001', 'Laptop Lenovo IdeaPad', 550.00, 20, 5),
(2, 'PER001', 'Mouse Logitech M185', 15.00, 50, 10),
(2, 'PER002', 'Teclado Mecánico Redragon', 45.00, 30, 5),
(3, 'MON001', 'Monitor Samsung 24"', 120.00, 15, 3),
(4, 'AUD001', 'Audífonos HyperX', 70.00, 25, 5),
(5, 'IMP001', 'Impresora Epson EcoTank', 200.00, 10, 2),
(6, 'ALM001', 'Memoria USB Kingston 64GB', 12.00, 100, 20),
(2, 'PER003', 'Cable HDMI 2m', 5.00, 200, 30),
(6, 'ALM002', 'SSD Kingston 480GB', 35.00, 40, 10),
(8, 'ACC001', 'Cargador USB-C', 18.00, 60, 15);

-- 5. clientes
INSERT INTO clientes (identificacion, nombre, direccion, telefono, correo) VALUES 
('CLI001', 'Juan Perez', 'Calle 1', '555-0001', 'juan@ejemplo.com'),
('CLI002', 'Maria Gomez', 'Calle 2', '555-0002', 'maria@ejemplo.com'),
('CLI003', 'Carlos Lopez', 'Calle 3', '555-0003', 'carlos@ejemplo.com'),
('CLI004', 'Ana Torres', 'Calle 4', '555-0004', 'ana@ejemplo.com'),
('CLI005', 'Luis Martinez', 'Calle 5', '555-0005', 'luis@ejemplo.com');

-- 6. configuracion_sistema
INSERT INTO configuracion_sistema (clave, valor, descripcion) VALUES 
('stock_minimo_general', '5', 'Nivel de stock mínimo por defecto'),
('moneda', 'USD', 'Moneda principal del sistema'),
('formato_fecha', 'DD/MM/YYYY', 'Formato de fecha de la aplicación'),
('nombre_sistema', 'TecnoMarket', 'Nombre del sistema de punto de venta');

-- 7. ventas de prueba (Llamando al procedimiento en MySQL)
CALL registrar_venta(1, 1, '[{"id_producto":1,"cantidad":1}, {"id_producto":2,"cantidad":2}]');
CALL registrar_venta(2, 2, '[{"id_producto":4,"cantidad":1}]');
CALL registrar_venta(3, 1, '[{"id_producto":7,"cantidad":5}, {"id_producto":9,"cantidad":1}]');

-- 8. Notas sobre roles en MySQL
-- En un entorno XAMPP (desarrollo local), generalmente se utiliza el usuario 'root'.
-- Para producción en MySQL/MariaDB, crear usuarios específicos y otorgar permisos con GRANT, por ejemplo:
-- CREATE USER 'tecnomarket_app'@'localhost' IDENTIFIED BY 'password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON tecnomarket_db.* TO 'tecnomarket_app'@'localhost';
