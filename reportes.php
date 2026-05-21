<?php require_once 'includes/header.php'; ?>
<?php
// Reporte General de Ventas Diarias
$stmtReporte = $db->query("SELECT DATE(fecha_hora) AS fecha, COUNT(id) AS cantidad_ventas, SUM(total) AS total_recaudado FROM ventas WHERE estado = 'COMPLETADA' GROUP BY DATE(fecha_hora) ORDER BY fecha DESC LIMIT 30");
$reporte_diario = $stmtReporte->fetchAll(PDO::FETCH_ASSOC);

// Métricas KPI Globales
$stmtTotal = $db->query("SELECT COALESCE(SUM(total), 0) FROM ventas WHERE estado = 'COMPLETADA'");
$ventas_totales = $stmtTotal->fetchColumn();

// Productos más vendidos
$stmtTopProductos = $db->query("SELECT producto AS nombre, cantidad_vendida, total_generado AS ingresos_generados FROM vista_productos_mas_vendidos LIMIT 5");
$top_productos = $stmtTopProductos->fetchAll(PDO::FETCH_ASSOC);
?>
<main class="flex-1 p-6 bg-[#f7f9fb] w-full flex flex-col gap-8 pb-12">
    <div class="mb-2">
        <h2 class="font-outfit text-3xl font-bold text-gray-900">Reportes y Analíticas</h2>
        <p class="text-gray-500 mt-1">Métricas y rendimiento financiero del negocio</p>
    </div>

    <!-- KPIs -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm flex flex-col gap-4">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-green-50 flex items-center justify-center text-green-600"><span class="material-symbols-outlined">payments</span></div>
                <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Ingresos Históricos</span>
            </div>
            <span class="font-outfit text-4xl font-bold text-gray-900">$<?php echo number_format($ventas_totales, 2); ?></span>
        </div>
        
        <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm flex flex-col gap-4">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-purple-50 flex items-center justify-center text-purple-600"><span class="material-symbols-outlined">trending_up</span></div>
                <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Ventas de Hoy</span>
            </div>
            <span class="font-outfit text-4xl font-bold text-gray-900">
                <?php 
                $stmtHoy = $db->query("SELECT COALESCE(SUM(total),0) FROM ventas WHERE estado = 'COMPLETADA' AND DATE(fecha_hora) = CURRENT_DATE");
                echo "$" . number_format($stmtHoy->fetchColumn(), 2);
                ?>
            </span>
        </div>
        
        <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm flex flex-col gap-4">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center text-[#2170e4]"><span class="material-symbols-outlined">receipt_long</span></div>
                <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Tickets Emitidos</span>
            </div>
            <span class="font-outfit text-4xl font-bold text-gray-900">
                <?php 
                $stmtTickets = $db->query("SELECT COUNT(*) FROM ventas WHERE estado = 'COMPLETADA'");
                echo number_format($stmtTickets->fetchColumn());
                ?>
            </span>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Ventas Diarias -->
        <div class="bg-white border border-gray-200 rounded-xl shadow-sm p-6 overflow-hidden">
            <h3 class="font-outfit text-xl font-bold text-gray-900 mb-6 border-b border-gray-100 pb-4">Ventas de los últimos 30 días</h3>
            <div class="overflow-y-auto max-h-[400px]">
                <table class="w-full text-left border-collapse">
                    <thead class="bg-gray-50 text-xs text-gray-500 uppercase sticky top-0">
                        <tr>
                            <th class="py-2 px-3">Fecha</th>
                            <th class="py-2 px-3 text-center">Transacciones</th>
                            <th class="py-2 px-3 text-right">Total Generado</th>
                        </tr>
                    </thead>
                    <tbody class="text-sm">
                        <?php foreach($reporte_diario as $d): ?>
                        <tr class="border-b border-gray-100 hover:bg-gray-50">
                            <td class="py-3 px-3 font-medium text-gray-700"><?php echo date('d/m/Y', strtotime($d['fecha'])); ?></td>
                            <td class="py-3 px-3 text-center"><span class="px-2.5 py-1 bg-blue-50 text-[#2170e4] rounded-full text-xs font-bold"><?php echo $d['cantidad_ventas']; ?></span></td>
                            <td class="py-3 px-3 text-right font-mono font-semibold text-green-700">$<?php echo number_format($d['total_recaudado'], 2); ?></td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (count($reporte_diario) == 0): ?>
                        <tr><td colspan="3" class="py-6 text-center text-gray-500">No hay datos suficientes para generar el reporte.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- Productos top -->
        <div class="bg-white border border-gray-200 rounded-xl shadow-sm p-6 overflow-hidden">
            <h3 class="font-outfit text-xl font-bold text-gray-900 mb-6 border-b border-gray-100 pb-4">Top 5 Productos Más Vendidos</h3>
            <div class="space-y-4">
                <?php $i=1; foreach($top_productos as $tp): ?>
                <div class="flex items-center gap-4 p-2 hover:bg-gray-50 rounded-lg transition-colors">
                    <div class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center font-bold text-gray-500">#<?php echo $i++; ?></div>
                    <div class="flex-1">
                        <p class="font-semibold text-gray-900"><?php echo htmlspecialchars($tp['nombre']); ?></p>
                        <p class="text-xs text-gray-500"><?php echo $tp['cantidad_vendida']; ?> unidades vendidas</p>
                    </div>
                    <div class="text-right">
                        <p class="font-bold text-green-600 font-mono">$<?php echo number_format($tp['ingresos_generados'], 2); ?></p>
                    </div>
                </div>
                <?php endforeach; ?>
                <?php if (count($top_productos) == 0): ?>
                <div class="py-6 text-center text-gray-500">No hay datos de ventas de productos.</div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</main>
<?php require_once 'includes/footer.php'; ?>