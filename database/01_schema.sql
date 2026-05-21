
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
