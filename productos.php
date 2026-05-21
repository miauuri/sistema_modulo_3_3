<?php require_once 'includes/header.php'; ?>
<?php
// Obtener todos los productos con su categoría
$stmtProductos = $db->query("
    SELECT p.*, c.nombre as categoria_nombre 
    FROM productos p 
    JOIN categorias c ON p.id_categoria = c.id 
    ORDER BY p.id DESC
");
$productos = $stmtProductos->fetchAll(PDO::FETCH_ASSOC);

// Categorías para el select y modal
$stmtCategorias = $db->query("SELECT * FROM categorias ORDER BY nombre ASC");
$categorias = $stmtCategorias->fetchAll(PDO::FETCH_ASSOC);

// Métricas
$total_productos = count($productos);
$valor_inventario = 0;
$stock_bajo = 0;
foreach($productos as $p) {
    $valor_inventario += ($p['precio'] * $p['stock']);
    if ($p['stock'] <= $p['stock_minimo']) {
        $stock_bajo++;
    }
}
?>
<main class="flex-1 p-6 bg-[#f7f9fb] w-full flex flex-col gap-8 pb-12">
    <!-- Page Header & Actions -->
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
            <h2 class="font-outfit text-3xl font-bold text-gray-900">Inventario de Productos</h2>
            <p class="text-gray-500 mt-1">Gestiona el catálogo, precios y niveles de stock.</p>
        </div>
        <button class="flex items-center gap-2 bg-[#2170e4] text-white px-5 py-2.5 rounded-lg hover:bg-blue-700 transition-colors shadow-sm text-sm font-semibold" onclick="document.getElementById('productModal').classList.remove('hidden')">
            <span class="material-symbols-outlined text-[18px]">add</span>
            Añadir Producto
        </button>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm flex flex-col gap-4">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center text-[#2170e4]"><span class="material-symbols-outlined">inventory_2</span></div>
                <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Productos</span>
            </div>
            <span class="font-outfit text-4xl font-bold text-gray-900"><?php echo number_format($total_productos); ?></span>
        </div>
        <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm flex flex-col gap-4">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-green-50 flex items-center justify-center text-green-600"><span class="material-symbols-outlined">monetization_on</span></div>
                <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Valor Inventario</span>
            </div>
            <span class="font-outfit text-4xl font-bold text-gray-900">$<?php echo number_format($valor_inventario, 2); ?></span>
        </div>
        <div class="bg-white p-6 rounded-xl border <?php echo $stock_bajo > 0 ? 'border-red-200 bg-red-50/30' : 'border-gray-200'; ?> shadow-sm flex flex-col gap-4">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg <?php echo $stock_bajo > 0 ? 'bg-red-100 text-red-700' : 'bg-gray-100 text-gray-600'; ?> flex items-center justify-center"><span class="material-symbols-outlined">warning</span></div>
                <span class="text-xs font-semibold <?php echo $stock_bajo > 0 ? 'text-red-600' : 'text-gray-500'; ?> uppercase tracking-wider">Stock Crítico</span>
            </div>
            <span class="font-outfit text-4xl font-bold <?php echo $stock_bajo > 0 ? 'text-red-700' : 'text-gray-900'; ?>"><?php echo number_format($stock_bajo); ?></span>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex flex-col md:flex-row gap-4 items-end">
        <div class="flex-1 w-full">
            <label class="block text-sm font-semibold text-gray-700 mb-1">Buscar Producto</label>
            <div class="relative">
                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-[20px]">search</span>
                <input class="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg text-sm focus:border-[#2170e4] focus:ring-1 focus:ring-blue-500/20 outline-none" placeholder="Código o Nombre..." type="text"/>
            </div>
        </div>
        <div class="w-full md:w-64">
            <label class="block text-sm font-semibold text-gray-700 mb-1">Categoría</label>
            <select class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:border-[#2170e4] outline-none bg-white">
                <option value="">Todas las categorías</option>
                <?php foreach($categorias as $cat): ?>
                <option value="<?php echo $cat['id']; ?>"><?php echo htmlspecialchars($cat['nombre']); ?></option>
                <?php endforeach; ?>
            </select>
        </div>
    </div>

    <!-- Data Table -->
    <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden flex-1">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse whitespace-nowrap">
                <thead class="bg-gray-50 border-b-2 border-gray-200">
                    <tr>
                        <th class="py-3 px-4 text-xs font-semibold text-gray-600 uppercase tracking-wider">Código</th>
                        <th class="py-3 px-4 text-xs font-semibold text-gray-600 uppercase tracking-wider">Nombre</th>
                        <th class="py-3 px-4 text-xs font-semibold text-gray-600 uppercase tracking-wider">Categoría</th>
                        <th class="py-3 px-4 text-xs font-semibold text-gray-600 uppercase tracking-wider text-right">Precio</th>
                        <th class="py-3 px-4 text-xs font-semibold text-gray-600 uppercase tracking-wider text-center">Stock</th>
                        <th class="py-3 px-4 text-xs font-semibold text-gray-600 uppercase tracking-wider text-center">Estado</th>
                        <th class="py-3 px-4 text-xs font-semibold text-gray-600 uppercase tracking-wider text-right">Acciones</th>
                    </tr>
                </thead>
                <tbody class="text-sm text-gray-800 divide-y divide-gray-100">
                    <?php foreach($productos as $p): ?>
                    <?php 
                        $estado_clase = "bg-green-100 text-green-800";
                        $estado_texto = "En Stock";
                        if ($p['stock'] == 0) {
                            $estado_clase = "bg-red-100 text-red-800";
                            $estado_texto = "Agotado";
                        } elseif ($p['stock'] <= $p['stock_minimo']) {
                            $estado_clase = "bg-orange-100 text-orange-800";
                            $estado_texto = "Bajo Stock";
                        }
                    ?>
                    <tr class="hover:bg-gray-50 transition-colors group">
                        <td class="py-3 px-4 font-mono text-gray-500"><?php echo htmlspecialchars($p['codigo']); ?></td>
                        <td class="py-3 px-4 font-medium"><?php echo htmlspecialchars($p['nombre']); ?></td>
                        <td class="py-3 px-4"><span class="bg-gray-100 text-gray-600 py-1 px-2 rounded text-xs font-medium"><?php echo htmlspecialchars($p['categoria_nombre']); ?></span></td>
                        <td class="py-3 px-4 text-right font-mono font-medium">$<?php echo number_format($p['precio'], 2); ?></td>
                        <td class="py-3 px-4 text-center">
                            <span class="inline-flex items-center justify-center font-bold px-2.5 py-0.5 rounded-full text-xs <?php echo $estado_clase; ?>">
                                <?php echo $p['stock']; ?>
                            </span>
                        </td>
                        <td class="py-3 px-4 text-center">
                            <span class="text-[11px] uppercase tracking-wider font-bold <?php echo str_replace('bg-', 'text-', str_replace(' text-', ' bg-white text-', $estado_clase)); ?>">
                                <?php echo $estado_texto; ?>
                            </span>
                        </td>
                        <td class="py-3 px-4 text-right">
                            <button class="p-1.5 text-gray-400 hover:text-[#2170e4] rounded transition-colors" title="Editar"><span class="material-symbols-outlined text-[18px]">edit</span></button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if(count($productos) == 0): ?>
                    <tr><td colspan="7" class="py-8 text-center text-gray-500">No se encontraron productos.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Modal Nuevo Producto -->
<div class="fixed inset-0 z-[100] bg-black/50 flex items-center justify-center p-4 hidden" id="productModal">
    <div class="bg-white w-full max-w-2xl rounded-xl shadow-xl flex flex-col max-h-[90vh]">
        <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center bg-gray-50 rounded-t-xl">
            <h3 class="font-outfit text-xl font-bold text-gray-900">Añadir Nuevo Producto</h3>
            <button class="text-gray-400 hover:text-red-500 transition-colors p-1" onclick="document.getElementById('productModal').classList.add('hidden')">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <div class="p-6 overflow-y-auto flex-1">
            <form class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Código de Producto *</label>
                    <input class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:border-[#2170e4] outline-none uppercase" required type="text"/>
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Categoría *</label>
                    <select class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:border-[#2170e4] outline-none" required>
                        <option disabled selected value="">Seleccione...</option>
                        <?php foreach($categorias as $cat): ?>
                        <option value="<?php echo $cat['id']; ?>"><?php echo htmlspecialchars($cat['nombre']); ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Nombre del Producto *</label>
                    <input class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:border-[#2170e4] outline-none" required type="text"/>
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Precio Unitario (USD) *</label>
                    <input class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:border-[#2170e4] outline-none tabular-nums" required step="0.01" type="number"/>
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Stock Inicial *</label>
                    <input class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:border-[#2170e4] outline-none tabular-nums" required type="number"/>
                </div>
            </form>
        </div>
        <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex justify-end gap-3 rounded-b-xl">
            <button class="px-4 py-2 text-sm font-semibold text-gray-600 hover:bg-gray-200 rounded-lg transition-colors" onclick="document.getElementById('productModal').classList.add('hidden')" type="button">Cancelar</button>
            <button class="px-5 py-2 text-sm font-semibold bg-[#2170e4] text-white rounded-lg hover:bg-blue-700 transition-colors shadow-sm" type="submit">Guardar</button>
        </div>
    </div>
</div>
<?php require_once 'includes/footer.php'; ?>