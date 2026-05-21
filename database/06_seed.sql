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
