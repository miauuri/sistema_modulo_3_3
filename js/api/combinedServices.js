const API_BASE_URL = "/sistema_modulo_3_3/api";

async function apiCall(endpoint, options = {}) {
  const response = await fetch(`${API_BASE_URL}/${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    }
  });
  
  if (!response.ok) {
      let errorMessage = 'Error en la petición';
      try {
          const errorData = await response.json();
          errorMessage = errorData.error || errorMessage;
      } catch (e) {
          // Si no es JSON el error
      }
      throw new Error(errorMessage);
  }
  
  return await response.json();
}

// CLIENTES SERVICE
async function getClientes() {
  return await apiCall('clientes.php');
}

async function createCliente(data) {
  return await apiCall('clientes.php', { method: 'POST', body: JSON.stringify(data) });
}

async function updateCliente(id, data) {
  return await apiCall(`clientes.php?id=${id}`, { method: 'PUT', body: JSON.stringify(data) });
}

async function deleteCliente(id) {
  return await apiCall(`clientes.php?id=${id}`, { method: 'DELETE' });
}

// PRODUCTOS SERVICE
async function getProductos() {
  return await apiCall('productos.php');
}

async function createProducto(data) {
  return await apiCall('productos.php', { method: 'POST', body: JSON.stringify(data) });
}

async function updateProducto(id, data) {
  return await apiCall(`productos.php?id=${id}`, { method: 'PUT', body: JSON.stringify(data) });
}

async function deleteProducto(id) {
  return await apiCall(`productos.php?id=${id}`, { method: 'DELETE' });
}

// CATEGORIAS SERVICE
async function getCategorias() {
  return await apiCall('categorias.php');
}

// EMPLEADOS SERVICE
async function getEmpleados() {
  return await apiCall('empleados.php');
}

// VENTAS SERVICE
async function getVentas() {
  return await apiCall('ventas.php');
}

async function createVenta(data) {
  return await apiCall('ventas.php', { method: 'POST', body: JSON.stringify(data) });
}

// AUTH SERVICE
async function login(usuario, password) {
  const data = await apiCall('auth.php', { method: 'POST', body: JSON.stringify({ usuario, password }) });
  localStorage.setItem('currentUser', JSON.stringify(data));
  return data;
}

// REPORTES SERVICE
async function getDashboardStats() {
  return await apiCall('dashboard.php');
}