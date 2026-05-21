const API_BASE_URL = "http://localhost:3000/api";

// CLIENTES SERVICE
async function getClientes() {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/clientes`)
  return JSON.parse(localStorage.getItem('clientes')) || MOCK_CLIENTES;
}

async function createCliente(data) {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/clientes`, { method: 'POST', body: JSON.stringify(data) })
  const clientes = await getClientes();
  data.id_cliente = Date.now();
  data.fecha_registro = new Date().toISOString();
  clientes.push(data);
  localStorage.setItem('clientes', JSON.stringify(clientes));
  return data;
}

async function updateCliente(id, data) {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/clientes/${id}`, { method: 'PUT', body: JSON.stringify(data) })
  const clientes = await getClientes();
  const index = clientes.findIndex(c => c.id_cliente == id);
  if (index !== -1) {
    clientes[index] = { ...clientes[index], ...data };
    localStorage.setItem('clientes', JSON.stringify(clientes));
    return clientes[index];
  }
  throw new Error('Cliente no encontrado');
}

async function deleteCliente(id) {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/clientes/${id}`, { method: 'DELETE' })
  let clientes = await getClientes();
  clientes = clientes.filter(c => c.id_cliente != id);
  localStorage.setItem('clientes', JSON.stringify(clientes));
  return true;
}

// PRODUCTOS SERVICE
async function getProductos() {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/productos`)
  return JSON.parse(localStorage.getItem('productos')) || MOCK_PRODUCTOS;
}

async function createProducto(data) {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/productos`, { method: 'POST', body: JSON.stringify(data) })
  const productos = await getProductos();
  data.id_producto = Date.now();
  productos.push(data);
  localStorage.setItem('productos', JSON.stringify(productos));
  return data;
}

async function updateProducto(id, data) {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/productos/${id}`, { method: 'PUT', body: JSON.stringify(data) })
  const productos = await getProductos();
  const index = productos.findIndex(p => p.id_producto == id);
  if (index !== -1) {
    productos[index] = { ...productos[index], ...data };
    localStorage.setItem('productos', JSON.stringify(productos));
    return productos[index];
  }
}

async function deleteProducto(id) {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/productos/${id}`, { method: 'DELETE' })
  let productos = await getProductos();
  productos = productos.filter(p => p.id_producto != id);
  localStorage.setItem('productos', JSON.stringify(productos));
  return true;
}

// CATEGORIAS SERVICE
async function getCategorias() {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/categorias`)
  return JSON.parse(localStorage.getItem('categorias')) || MOCK_CATEGORIAS;
}

// EMPLEADOS SERVICE
async function getEmpleados() {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/empleados`)
  return JSON.parse(localStorage.getItem('empleados')) || MOCK_EMPLEADOS;
}

// VENTAS SERVICE
async function getVentas() {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/ventas`)
  return JSON.parse(localStorage.getItem('ventas')) || MOCK_VENTAS;
}

async function createVenta(data) {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/ventas`, { method: 'POST', body: JSON.stringify(data) })
  // El descuento de inventario se simula aquí
  const ventas = await getVentas();
  const productos = await getProductos();
  
  data.id_venta = Date.now();
  data.fecha_hora = new Date().toISOString();
  
  // Simular descuento de stock
  data.detalles.forEach(item => {
    const prod = productos.find(p => p.id_producto == item.id_producto);
    if (prod) prod.stock -= item.cantidad;
  });
  
  ventas.push(data);
  localStorage.setItem('ventas', JSON.stringify(ventas));
  localStorage.setItem('productos', JSON.stringify(productos));
  return data;
}

// AUTH SERVICE
async function login(usuario, password) {
  // TODO: Reemplazar por → fetch(`${API_BASE_URL}/auth/login`, { method: 'POST', ... })
  const empleados = await getEmpleados();
  const user = empleados.find(e => e.usuario === usuario && e.password_hash === password);
  if (user) {
    const sessionData = { ...user, token: 'mock-jwt-token' };
    localStorage.setItem('currentUser', JSON.stringify(sessionData));
    return sessionData;
  }
  throw new Error('Credenciales incorrectas');
}

// REPORTES SERVICE
async function getDashboardStats() {
  const clientes = await getClientes();
  const productos = await getProductos();
  const ventas = await getVentas();
  const stockBajo = productos.filter(p => p.stock <= 5).length;
  
  return {
    totalClientes: clientes.length,
    totalProductos: productos.length,
    ventasHoy: ventas.length, // Simplificado
    alertasStock: stockBajo,
    totalEmpleados: (await getEmpleados()).length
  };
}