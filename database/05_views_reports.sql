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
