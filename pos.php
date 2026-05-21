<?php require_once 'includes/header.php'; ?>
<?php
// Obtener todos los clientes
$stmtClientes = $db->query("SELECT id, nombre, identificacion FROM clientes WHERE activo = true ORDER BY nombre");
$clientes = $stmtClientes->fetchAll(PDO::FETCH_ASSOC);

// Obtener productos
$stmtProductos = $db->query("SELECT id, codigo, nombre, precio, stock FROM productos WHERE stock > 0 AND activo = true");
$productos = $stmtProductos->fetchAll(PDO::FETCH_ASSOC);
?>
<main class="flex-1 p-6 bg-[#f7f9fb] w-full flex flex-col gap-6">
    <div class="mb-2 flex justify-between items-end">
        <div>
            <h2 class="font-outfit text-3xl font-bold text-gray-900">Punto de Venta</h2>
            <p class="text-gray-500 mt-1">Gestión de ventas y facturación rápida.</p>
        </div>
        <div class="bg-white border border-gray-200 text-gray-500 px-3 py-1.5 rounded-md text-sm font-semibold shadow-sm">
            Terminal 01 • Sesión Activa
        </div>
    </div>

    <!-- Grid Layout -->
    <div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
        <!-- Left Column (Client & Cart) -->
        <div class="xl:col-span-8 space-y-4">
            <!-- 1. Select Client -->
            <div class="bg-white border border-gray-200 rounded-xl p-5 shadow-sm">
                <div class="flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-[#2170e4]">person_search</span>
                    <h3 class="font-outfit text-xl font-bold text-gray-900">Cliente</h3>
                </div>
                <div class="flex gap-3">
                    <div class="relative flex-1">
                        <select id="cliente_id" class="w-full px-4 py-2.5 bg-gray-50 border border-gray-300 rounded-lg text-sm focus:border-[#2170e4] focus:bg-white outline-none">
                            <option value="">Seleccione un cliente (Consumidor Final por defecto)...</option>
                            <?php foreach($clientes as $c): ?>
                            <option value="<?php echo $c['id']; ?>"><?php echo htmlspecialchars($c['nombre'] . ' - ' . $c['identificacion']); ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <button class="bg-gray-100 border border-gray-200 text-gray-700 hover:bg-gray-200 px-4 py-2.5 rounded-lg text-sm font-semibold flex items-center gap-2 transition-colors">
                        <span class="material-symbols-outlined text-[18px]">add</span> Nuevo
                    </button>
                </div>
            </div>

            <!-- 2. Add Products -->
            <div class="bg-white border border-gray-200 rounded-xl p-5 shadow-sm">
                <div class="flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-[#2170e4]">barcode_scanner</span>
                    <h3 class="font-outfit text-xl font-bold text-gray-900">Agregar Producto</h3>
                </div>
                <div class="flex gap-3">
                    <div class="relative flex-1">
                        <select id="producto_select" class="w-full px-4 py-2.5 bg-gray-50 border border-gray-300 rounded-lg text-sm focus:border-[#2170e4] focus:bg-white outline-none">
                            <option value="">Seleccione un producto para agregar...</option>
                            <?php foreach($productos as $p): ?>
                            <option value="<?php echo $p['id']; ?>" data-codigo="<?php echo htmlspecialchars($p['codigo']); ?>" data-nombre="<?php echo htmlspecialchars($p['nombre']); ?>" data-precio="<?php echo $p['precio']; ?>" data-stock="<?php echo $p['stock']; ?>">
                                <?php echo htmlspecialchars($p['codigo'] . ' - ' . $p['nombre'] . ' ($' . $p['precio'] . ') - Stock: ' . $p['stock']); ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <input id="producto_cant" class="w-24 px-3 py-2.5 bg-gray-50 border border-gray-300 rounded-lg text-sm text-center focus:border-[#2170e4] outline-none" min="1" type="number" value="1"/>
                    <button id="btn_agregar" class="bg-[#2170e4] text-white hover:bg-blue-700 px-6 py-2.5 rounded-lg text-sm font-semibold transition-colors shadow-sm">
                        Agregar
                    </button>
                </div>
            </div>

            <!-- 3. Cart Table -->
            <div class="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden flex flex-col" style="min-height: 400px;">
                <div class="overflow-x-auto flex-1">
                    <table class="w-full text-left border-collapse">
                        <thead class="bg-gray-50 border-b border-gray-200 text-xs text-gray-600 uppercase tracking-wider font-semibold sticky top-0">
                            <tr>
                                <th class="p-4">Producto</th>
                                <th class="p-4 w-24 text-center">Cant.</th>
                                <th class="p-4 text-right">Precio Unit.</th>
                                <th class="p-4 text-right">Subtotal</th>
                                <th class="p-4 w-16 text-center"></th>
                            </tr>
                        </thead>
                        <tbody id="cart_body" class="text-sm text-gray-800 divide-y divide-gray-100">
                            <!-- Items agregados por JS -->
                            <tr id="empty_cart"><td colspan="5" class="p-8 text-center text-gray-500">El carrito está vacío.</td></tr>
                        </tbody>
                    </table>
                </div>
                <div class="bg-gray-50 p-4 border-t border-gray-200 flex justify-between items-center text-sm text-gray-500">
                    <span id="cart_count">0 items en el carrito</span>
                    <button id="btn_vaciar" class="text-red-500 hover:text-red-700 font-semibold flex items-center gap-1 transition-colors">
                        <span class="material-symbols-outlined text-[18px]">remove_shopping_cart</span> Vaciar Carrito
                    </button>
                </div>
            </div>
        </div>

        <!-- Right Column (Totals) -->
        <div class="xl:col-span-4 space-y-4 flex flex-col">
            <div class="bg-white border border-gray-200 rounded-xl shadow-sm p-6 flex-1 flex flex-col">
                <h3 class="font-outfit text-2xl font-bold text-gray-900 border-b border-gray-100 pb-4 mb-6">Resumen de Venta</h3>
                
                <div class="space-y-4 text-sm text-gray-600 flex-1">
                    <div class="flex justify-between">
                        <span>Subtotal</span>
                        <span id="resumen_subtotal" class="font-semibold text-gray-900 font-mono">$0.00</span>
                    </div>
                    <div class="flex justify-between">
                        <span>Descuento (0%)</span>
                        <span class="font-semibold text-gray-900 font-mono">$0.00</span>
                    </div>
                    <div class="flex justify-between">
                        <span>Impuestos (0%)</span>
                        <span class="font-semibold text-gray-900 font-mono">$0.00</span>
                    </div>
                </div>

                <div class="border-t border-gray-200 pt-6 mt-6">
                    <div class="flex justify-between items-end mb-8">
                        <span class="text-xl font-bold text-gray-900">Total a Pagar</span>
                        <span id="resumen_total" class="font-outfit text-4xl font-black text-[#2170e4] leading-none">$0.00</span>
                    </div>
                    
                    <button id="btn_confirmar" class="w-full bg-[#2170e4] text-white hover:bg-blue-700 py-4 rounded-xl text-lg font-bold shadow-md transition-all flex justify-center items-center gap-2">
                        <span class="material-symbols-outlined">check_circle</span>
                        Confirmar Venta
                    </button>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
let carrito = [];

function actualizarCarrito() {
    const tbody = document.getElementById('cart_body');
    tbody.innerHTML = '';
    
    let total = 0;
    
    if (carrito.length === 0) {
        tbody.innerHTML = '<tr id="empty_cart"><td colspan="5" class="p-8 text-center text-gray-500">El carrito está vacío.</td></tr>';
        document.getElementById('cart_count').innerText = '0 items en el carrito';
        document.getElementById('resumen_subtotal').innerText = '$0.00';
        document.getElementById('resumen_total').innerText = '$0.00';
        return;
    }
    
    carrito.forEach((item, index) => {
        let subtotal = item.precio * item.cantidad;
        total += subtotal;
        
        let tr = document.createElement('tr');
        tr.className = "hover:bg-gray-50 transition-colors group";
        tr.innerHTML = `
            <td class="p-4">
                <p class="font-medium text-gray-900">${item.nombre}</p>
                <p class="text-gray-500 text-[11px] uppercase tracking-wider mt-0.5">SKU: ${item.codigo}</p>
            </td>
            <td class="p-4 text-center font-semibold text-gray-900">${item.cantidad}</td>
            <td class="p-4 text-right font-mono text-gray-600">$${parseFloat(item.precio).toFixed(2)}</td>
            <td class="p-4 text-right font-mono font-bold text-gray-900">$${subtotal.toFixed(2)}</td>
            <td class="p-4 text-center">
                <button onclick="eliminarItem(${index})" class="text-gray-400 hover:text-red-500 transition-colors opacity-0 group-hover:opacity-100">
                    <span class="material-symbols-outlined text-[20px]">delete</span>
                </button>
            </td>
        `;
        tbody.appendChild(tr);
    });
    
    document.getElementById('cart_count').innerText = `${carrito.length} items en el carrito`;
    document.getElementById('resumen_subtotal').innerText = `$${total.toFixed(2)}`;
    document.getElementById('resumen_total').innerText = `$${total.toFixed(2)}`;
}

document.getElementById('btn_agregar').addEventListener('click', () => {
    const select = document.getElementById('producto_select');
    const cantInput = document.getElementById('producto_cant');
    const option = select.options[select.selectedIndex];
    
    if (!select.value) {
        alert("Seleccione un producto.");
        return;
    }
    
    let cantidad = parseInt(cantInput.value);
    if (cantidad <= 0) {
        alert("La cantidad debe ser mayor a 0.");
        return;
    }
    
    let id_producto = parseInt(select.value);
    let stock_disponible = parseInt(option.getAttribute('data-stock'));
    
    // Check if item exists in cart
    let existe = carrito.find(i => i.id_producto === id_producto);
    let cant_total = existe ? existe.cantidad + cantidad : cantidad;
    
    if (cant_total > stock_disponible) {
        alert("No hay stock suficiente. Stock disponible: " + stock_disponible);
        return;
    }
    
    if (existe) {
        existe.cantidad += cantidad;
    } else {
        carrito.push({
            id_producto: id_producto,
            codigo: option.getAttribute('data-codigo'),
            nombre: option.getAttribute('data-nombre'),
            precio: parseFloat(option.getAttribute('data-precio')),
            cantidad: cantidad
        });
    }
    
    actualizarCarrito();
    
    // Reset inputs
    select.value = '';
    cantInput.value = 1;
});

function eliminarItem(index) {
    carrito.splice(index, 1);
    actualizarCarrito();
}

document.getElementById('btn_vaciar').addEventListener('click', () => {
    carrito = [];
    actualizarCarrito();
});

document.getElementById('btn_confirmar').addEventListener('click', () => {
    if (carrito.length === 0) {
        alert("El carrito está vacío.");
        return;
    }
    
    const cliente_id = document.getElementById('cliente_id').value;
    
    const payload = {
        cliente_id: cliente_id ? parseInt(cliente_id) : 1, // 1 is default public customer
        items: carrito.map(i => ({ id_producto: i.id_producto, cantidad: i.cantidad }))
    };
    
    fetch('api_procesar_venta.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert("Venta registrada con éxito. Ticket #" + data.id_venta);
            carrito = [];
            actualizarCarrito();
            window.location.reload();
        } else {
            alert("Error al procesar la venta: " + data.error);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert("Error de comunicación con el servidor.");
    });
});
</script>

<?php require_once 'includes/footer.php'; ?>