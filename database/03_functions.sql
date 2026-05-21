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
