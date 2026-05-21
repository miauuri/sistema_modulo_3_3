const MOCK_CATEGORIAS = [
  { id_categoria: 1, nombre: 'Laptops', descripcion: 'Computadoras portátiles de alto rendimiento' },
  { id_categoria: 2, nombre: 'Periféricos', descripcion: 'Mouses, teclados y complementos' },
  { id_categoria: 3, nombre: 'Monitores', descripcion: 'Pantallas de alta resolución' },
  { id_categoria: 4, nombre: 'Audio', descripcion: 'Audífonos, parlantes y micrófonos' },
  { id_categoria: 5, nombre: 'Almacenamiento', descripcion: 'Discos duros y memorias USB' },
  { id_categoria: 6, nombre: 'Accesorios Móviles', descripcion: 'Fundas, cables y cargadores' }
];

const MOCK_PRODUCTOS = [
  { id_producto: 1, codigo: 'LAP-001', nombre: 'MacBook Air M2', descripcion: 'Apple MacBook Air con chip M2, 8GB RAM, 256GB SSD', precio: 1199.00, stock: 15, id_categoria: 1 },
  { id_producto: 2, codigo: 'MS-002', nombre: 'Logitech G502', descripcion: 'Mouse Gamer Hero 25K', precio: 49.99, stock: 3, id_categoria: 2 },
  { id_producto: 3, codigo: 'MON-003', nombre: 'Samsung Odyssey G7', descripcion: 'Monitor curvo 27", 240Hz', precio: 699.00, stock: 8, id_categoria: 3 },
  { id_producto: 4, codigo: 'AUD-004', nombre: 'Sony WH-1000XM5', descripcion: 'Audífonos Noise Cancelling', precio: 349.00, stock: 12, id_categoria: 4 },
  { id_producto: 5, codigo: 'USB-005', nombre: 'Kingston DataTraveler 128GB', descripcion: 'Memoria USB 3.2', precio: 15.50, stock: 50, id_categoria: 5 },
  { id_producto: 6, codigo: 'LAP-006', nombre: 'Dell XPS 13', descripcion: 'Intel Core i7, 16GB RAM', precio: 1399.00, stock: 2, id_categoria: 1 },
  { id_producto: 7, codigo: 'TECL-007', nombre: 'Keychron K2', descripcion: 'Teclado mecánico inalámbrico', precio: 89.00, stock: 10, id_categoria: 2 },
  { id_producto: 8, codigo: 'IMP-008', nombre: 'Epson EcoTank L3250', descripcion: 'Impresora multifuncional WiFi', precio: 199.00, stock: 5, id_categoria: 2 },
  { id_producto: 9, codigo: 'CABLE-009', nombre: 'Cable HDMI 2.1 2m', descripcion: 'Soporta 8K @ 60Hz', precio: 12.00, stock: 45, id_categoria: 6 },
  { id_producto: 10, codigo: 'SSD-010', nombre: 'Samsung 980 Pro 1TB', descripcion: 'NVMe M.2 Gen4', precio: 109.00, stock: 20, id_categoria: 5 },
  { id_producto: 11, codigo: 'HUB-011', nombre: 'Anker USB-C Hub 7-in-1', descripcion: 'Adaptador para laptops', precio: 45.00, stock: 30, id_categoria: 6 },
  { id_producto: 12, codigo: 'MON-012', nombre: 'LG UltraWide 34"', descripcion: 'WQHD, HDR10', precio: 450.00, stock: 0, id_categoria: 3 }
];

const MOCK_CLIENTES = [
  { id_cliente: 1, nombre: 'Juan Pérez', identificacion: '123456789', direccion: 'Av. Siempre Viva 123', telefono: '555-0101', correo: 'juan.perez@example.com', fecha_registro: '2023-01-15T10:30:00Z' },
  { id_cliente: 2, nombre: 'María García', identificacion: '987654321', direccion: 'Calle Falsa 456', telefono: '555-0202', correo: 'maria.garcia@example.com', fecha_registro: '2023-02-20T14:45:00Z' },
  { id_cliente: 3, nombre: 'Carlos López', identificacion: '456789123', direccion: 'Paseo de la Reforma 789', telefono: '555-0303', correo: 'carlos.lopez@example.com', fecha_registro: '2023-03-05T09:15:00Z' },
  { id_cliente: 4, nombre: 'Ana Martínez', identificacion: '321654987', direccion: 'Colonia Roma Norte 10', telefono: '555-0404', correo: 'ana.martinez@example.com', fecha_registro: '2023-04-10T11:20:00Z' },
  { id_cliente: 5, nombre: 'Roberto Sánchez', identificacion: '789123456', direccion: 'Santa Fe Local 5', telefono: '555-0505', correo: 'roberto.sanchez@example.com', fecha_registro: '2023-05-12T16:00:00Z' }
];

const MOCK_EMPLEADOS = [
  { id_empleado: 1, nombre: 'Admin Master', identificacion: 'ADMIN-01', cargo: 'Gerente General', usuario: 'admin', password_hash: 'admin123', rol: 'Administrador', id_rol: 1 },
  { id_empleado: 2, nombre: 'Vendedor Senior', identificacion: 'EMP-01', cargo: 'Vendedor', usuario: 'empleado', password_hash: 'empleado123', rol: 'Empleado', id_rol: 2 },
  { id_empleado: 3, nombre: 'Laura Inventarios', identificacion: 'EMP-02', cargo: 'Analista de Stock', usuario: 'empleado2', password_hash: 'empleado123', rol: 'Empleado', id_rol: 2 }
];

const MOCK_VENTAS = [
  { id_venta: 1, fecha_hora: '2023-10-01T10:00:00Z', total: 1248.99, id_cliente: 1, id_empleado: 2 },
  { id_venta: 2, fecha_hora: '2023-10-02T11:30:00Z', total: 49.99, id_cliente: 2, id_empleado: 2 },
  { id_venta: 3, fecha_hora: '2023-10-05T15:20:00Z', total: 1048.00, id_cliente: 3, id_empleado: 2 },
  { id_venta: 4, fecha_hora: '2023-10-10T09:45:00Z', total: 349.00, id_cliente: 4, id_empleado: 2 },
  { id_venta: 5, fecha_hora: '2023-10-12T14:10:00Z', total: 124.50, id_cliente: 5, id_empleado: 2 }
];

const MOCK_DETALLE_VENTAS = [
  { id_detalle: 1, id_venta: 1, id_producto: 1, cantidad: 1, precio_unitario: 1199.00, subtotal: 1199.00 },
  { id_detalle: 2, id_venta: 1, id_producto: 2, cantidad: 1, precio_unitario: 49.99, subtotal: 49.99 },
  { id_detalle: 3, id_venta: 2, id_producto: 2, cantidad: 1, precio_unitario: 49.99, subtotal: 49.99 },
  { id_detalle: 4, id_venta: 3, id_producto: 3, cantidad: 1, precio_unitario: 699.00, subtotal: 699.00 },
  { id_detalle: 5, id_venta: 3, id_producto: 4, cantidad: 1, precio_unitario: 349.00, subtotal: 349.00 }
];