<?php require_once 'includes/header.php'; ?>
<?php
// Obtener métricas del dashboard
$stmtDash = $db->query("SELECT * FROM vista_dashboard");
$dashboard = $stmtDash->fetch(PDO::FETCH_ASSOC);

// Últimas ventas
$stmtVentas = $db->query("SELECT * FROM vista_ventas_detalladas ORDER BY fecha_hora DESC LIMIT 5");
$ventas = $stmtVentas->fetchAll(PDO::FETCH_ASSOC);

// Productos stock bajo
$stmtStock = $db->query("SELECT * FROM vista_productos_stock_bajo LIMIT 4");
$stock_bajo = $stmtStock->fetchAll(PDO::FETCH_ASSOC);
?>

<main class="flex-1 p-6 bg-[#f7f9fb] w-full flex flex-col gap-8 pb-12">
    <div class="mb-2">
        <h1 class="font-outfit text-3xl font-bold text-gray-900 tracking-tight">Dashboard</h1>
        <p class="text-gray-500 mt-1">Resumen general del sistema TecnoMarket.</p>
    </div>

    <!-- Metrics Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 mb-2">
        <!-- Card 1 -->
        <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm flex flex-col justify-between">
            <div class="flex justify-between items-start mb-4">
                <div class="p-2 bg-blue-50 text-[#2170e4] rounded-lg"><span class="material-symbols-outlined">groups</span></div>
            </div>
            <div>
                <p class="text-xs text-gray-500 uppercase tracking-wider font-semibold mb-1">Total Clientes</p>
                <h3 class="font-outfit text-2xl font-bold text-gray-900"><?php echo number_format($dashboard['total_clientes_activos']); ?></h3>
            </div>
        </div>
        <!-- Card 2 -->
        <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm flex flex-col justify-between">
            <div class="flex justify-between items-start mb-4">
                <div class="p-2 bg-blue-50 text-[#2170e4] rounded-lg"><span class="material-symbols-outlined">inventory_2</span></div>
            </div>
            <div>
                <p class="text-xs text-gray-500 uppercase tracking-wider font-semibold mb-1">Total Productos</p>
                <h3 class="font-outfit text-2xl font-bold text-gray-900"><?php echo number_format($dashboard['total_productos_activos']); ?></h3>
            </div>
        </div>
        <!-- Card 3 -->
        <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm flex flex-col justify-between">
            <div class="flex justify-between items-start mb-4">
                <div class="p-2 bg-blue-50 text-[#2170e4] rounded-lg"><span class="material-symbols-outlined">point_of_sale</span></div>
            </div>
            <div>
                <p class="text-xs text-gray-500 uppercase tracking-wider font-semibold mb-1">Ventas Hoy</p>
                <h3 class="font-outfit text-2xl font-bold text-gray-900"><?php echo number_format($dashboard['ventas_del_dia']); ?></h3>
            </div>
        </div>
        <!-- Card 4 -->
        <div class="bg-white rounded-xl p-5 border border-red-200 bg-red-50/30 shadow-sm flex flex-col justify-between">
            <div class="flex justify-between items-start mb-4">
                <div class="p-2 bg-red-100 text-red-700 rounded-lg"><span class="material-symbols-outlined">warning</span></div>
            </div>
            <div>
                <p class="text-xs text-red-600 uppercase tracking-wider font-semibold mb-1">Alertas Stock</p>
                <h3 class="font-outfit text-2xl font-bold text-red-700"><?php echo number_format($dashboard['productos_stock_bajo']); ?></h3>
            </div>
        </div>
        <!-- Card 5 -->
        <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm flex flex-col justify-between">
            <div class="flex justify-between items-start mb-4">
                <div class="p-2 bg-gray-100 text-gray-600 rounded-lg"><span class="material-symbols-outlined">badge</span></div>
            </div>
            <div>
                <p class="text-xs text-gray-500 uppercase tracking-wider font-semibold mb-1">Total Empleados</p>
                <h3 class="font-outfit text-2xl font-bold text-gray-900"><?php echo number_format($dashboard['total_empleados_activos']); ?></h3>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Últimas Ventas Table -->
        <div class="lg:col-span-2 bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden flex flex-col">
            <div class="p-5 border-b border-gray-200 flex justify-between items-center">
                <h2 class="font-outfit text-xl font-bold text-gray-900">Últimas Ventas</h2>
                <a href="pos.php" class="text-[#2170e4] hover:underline text-sm font-semibold">Ver todas</a>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="border-b-2 border-gray-200 bg-gray-50 text-gray-600 text-xs uppercase tracking-wider">
                            <th class="py-3 px-4 font-semibold">ID Trans.</th>
                            <th class="py-3 px-4 font-semibold">Cliente</th>
                            <th class="py-3 px-4 font-semibold">Fecha</th>
                            <th class="py-3 px-4 font-semibold text-right">Total</th>
                        </tr>
                    </thead>
                    <tbody class="text-sm text-gray-800">
                        <?php foreach($ventas as $v): ?>
                        <tr class="border-b border-gray-100 hover:bg-gray-50 transition-colors">
                            <td class="py-3 px-4 font-mono text-gray-500">#TRX-<?php echo str_pad($v['id_venta'], 4, '0', STR_PAD_LEFT); ?></td>
                            <td class="py-3 px-4 font-medium"><?php echo htmlspecialchars($v['cliente']); ?></td>
                            <td class="py-3 px-4 text-gray-500"><?php echo date('d/m/Y H:i', strtotime($v['fecha_hora'])); ?></td>
                            <td class="py-3 px-4 text-right font-mono font-semibold">$<?php echo number_format($v['total'], 2); ?></td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (count($ventas) == 0): ?>
                        <tr><td colspan="4" class="py-4 text-center text-gray-500">No hay ventas registradas.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Bajo Stock List -->
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden flex flex-col">
            <div class="p-5 border-b border-gray-200 flex justify-between items-center">
                <h2 class="font-outfit text-xl font-bold text-gray-900">Bajo Stock</h2>
                <span class="material-symbols-outlined text-red-600">warning</span>
            </div>
            <div class="overflow-y-auto max-h-[400px]">
                <ul class="divide-y divide-gray-100">
                    <?php foreach($stock_bajo as $item): ?>
                    <li class="p-4 hover:bg-gray-50 transition-colors flex justify-between items-center">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center text-gray-600">
                                <span class="material-symbols-outlined">inventory_2</span>
                            </div>
                            <div>
                                <p class="text-sm font-semibold text-gray-900"><?php echo htmlspecialchars($item['nombre']); ?></p>
                                <p class="text-xs text-gray-500">SKU: <?php echo htmlspecialchars($item['codigo']); ?></p>
                            </div>
                        </div>
                        <div class="text-right">
                            <p class="font-outfit text-lg font-bold <?php echo $item['stock'] == 0 ? 'text-red-600' : 'text-orange-500'; ?>"><?php echo $item['stock']; ?></p>
                            <p class="text-xs text-gray-500">Mín: <?php echo $item['stock_minimo']; ?></p>
                        </div>
                    </li>
                    <?php endforeach; ?>
                    <?php if(count($stock_bajo) == 0): ?>
                    <li class="p-4 text-center text-gray-500 text-sm">Inventario en niveles óptimos.</li>
                    <?php endif; ?>
                </ul>
            </div>
            <div class="p-3 bg-gray-50 border-t border-gray-200 text-center mt-auto">
                <a href="productos.php" class="text-[#2170e4] hover:text-blue-700 text-sm font-semibold w-full py-2 inline-block">Ver inventario completo</a>
            </div>
        </div>
    </div>
</main>
<?php require_once 'includes/footer.php'; ?>