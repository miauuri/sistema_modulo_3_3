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

// Historial de Ventas Detalladas
$stmtVentas = $db->query("SELECT * FROM vista_ventas_detalladas ORDER BY fecha_hora DESC");
$resultadosVentas = $stmtVentas->fetchAll(PDO::FETCH_ASSOC);
$historial_ventas = [];
foreach($resultadosVentas as $row) {
    $id = $row['id_venta'];
    if(!isset($historial_ventas[$id])) {
        $historial_ventas[$id] = [
            'id_venta' => $id,
            'fecha_hora' => $row['fecha_hora'],
            'cliente' => $row['cliente'],
            'empleado' => $row['empleado'],
            'total' => $row['total'],
            'detalles' => []
        ];
    }
    $historial_ventas[$id]['detalles'][] = [
        'producto' => $row['producto'],
        'cantidad' => $row['cantidad'],
        'precio_unitario' => $row['precio_unitario'],
        'subtotal' => $row['subtotal']
    ];
}
$historial_ventas = array_values($historial_ventas);
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

    <!-- Historial de Tickets -->
    <div class="bg-white border border-gray-200 rounded-xl shadow-sm p-6 overflow-hidden flex flex-col">
        <h3 class="font-outfit text-xl font-bold text-gray-900 mb-6 border-b border-gray-100 pb-4">Historial de Tickets</h3>
        <div class="overflow-x-auto flex-1">
            <table class="w-full text-left border-collapse whitespace-nowrap">
                <thead class="bg-gray-50 text-gray-600 text-xs font-semibold uppercase tracking-wider">
                    <tr>
                        <th class="px-4 py-3">Ticket ID</th>
                        <th class="px-4 py-3">Fecha</th>
                        <th class="px-4 py-3">Cliente</th>
                        <th class="px-4 py-3">Cajero</th>
                        <th class="px-4 py-3 text-right">Total</th>
                        <th class="px-4 py-3 text-center">Acciones</th>
                    </tr>
                </thead>
                <tbody class="text-sm text-gray-800 divide-y divide-gray-100">
                    <?php foreach($historial_ventas as $v): ?>
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-4 py-3 font-mono font-medium text-gray-900">#TK-<?php echo str_pad($v['id_venta'], 5, '0', STR_PAD_LEFT); ?></td>
                        <td class="px-4 py-3 text-gray-500"><?php echo date('d M Y H:i', strtotime($v['fecha_hora'])); ?></td>
                        <td class="px-4 py-3"><?php echo htmlspecialchars($v['cliente'] ?? 'Consumidor Final'); ?></td>
                        <td class="px-4 py-3 text-gray-500"><?php echo htmlspecialchars($v['empleado']); ?></td>
                        <td class="px-4 py-3 text-right font-semibold text-green-600">$<?php echo number_format($v['total'], 2); ?></td>
                        <td class="px-4 py-3 text-center">
                            <button class="px-3 py-1.5 bg-blue-50 text-[#2170e4] font-semibold rounded-lg text-xs hover:bg-blue-100 transition-colors flex items-center gap-1 mx-auto" onclick='openTicketModal(<?php echo json_encode($v); ?>)'>
                                <span class="material-symbols-outlined text-[16px]">receipt_long</span> Ver
                            </button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (count($historial_ventas) == 0): ?>
                    <tr><td colspan="6" class="px-4 py-6 text-center text-gray-500">No hay tickets registrados.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Receipt Modal -->
<div class="fixed inset-0 z-[100] bg-black/50 flex items-center justify-center p-4 hidden" id="ticketModal">
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-[400px] overflow-hidden flex flex-col border border-gray-200">
        <!-- Receipt Header -->
        <div class="bg-gray-50 p-6 text-center border-b border-gray-300 border-dashed relative">
            <button class="absolute top-4 right-4 text-gray-400 hover:text-red-500 transition-colors p-1" onclick="document.getElementById('ticketModal').classList.add('hidden')">
                <span class="material-symbols-outlined">close</span>
            </button>
            <h2 class="font-outfit text-2xl font-black text-gray-900 uppercase tracking-wider mb-1">TecnoMarket</h2>
            <p class="text-sm text-gray-500">RUC: 20123456789</p>
            <p class="text-sm text-gray-500 mb-4">Av. Tecnológica 1024, Distrito Central</p>
            <div class="inline-block bg-white px-3 py-1 rounded border border-gray-200 text-sm font-semibold text-gray-800" id="ticketModalNumber">
                TICKET DE VENTA #TK-00000
            </div>
        </div>
        <!-- Receipt Info -->
        <div class="p-6 text-sm text-gray-800 space-y-1 border-b border-gray-300 border-dashed">
            <div class="flex justify-between"><span class="text-gray-500">Fecha:</span> <span id="ticketModalDate">--</span></div>
            <div class="flex justify-between"><span class="text-gray-500">Cajero:</span> <span id="ticketModalCashier">--</span></div>
            <div class="flex justify-between"><span class="text-gray-500">Cliente:</span> <span id="ticketModalClient">--</span></div>
        </div>
        <!-- Receipt Items -->
        <div class="p-6 border-b border-gray-300 border-dashed max-h-60 overflow-y-auto">
            <table class="w-full text-left text-sm">
                <thead class="text-gray-500 border-b border-gray-200">
                    <tr>
                        <th class="pb-2 font-medium">Cant.</th>
                        <th class="pb-2 font-medium">Descripción</th>
                        <th class="pb-2 font-medium text-right">Importe</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100" id="ticketModalItems">
                    <!-- Items populated via JS -->
                </tbody>
            </table>
        </div>
        <!-- Receipt Totals -->
        <div class="p-6 bg-gray-50 space-y-1 border-b border-gray-200">
            <div class="flex justify-between text-sm text-gray-500">
                <span>Subtotal:</span> <span class="tabular-nums" id="ticketModalSubtotal">$0.00</span>
            </div>
            <div class="flex justify-between text-sm text-gray-500">
                <span>Impuestos (0%):</span> <span class="tabular-nums">$0.00</span>
            </div>
            <div class="flex justify-between text-lg font-bold text-gray-900 mt-2 pt-2 border-t border-gray-300">
                <span>TOTAL:</span> <span class="tabular-nums" id="ticketModalTotal">$0.00</span>
            </div>
        </div>
        <!-- Receipt Actions -->
        <div class="p-4 flex gap-3 bg-white">
            <button class="flex-1 border border-gray-300 text-gray-700 hover:bg-gray-50 py-2.5 rounded-lg text-sm font-semibold transition-colors" onclick="document.getElementById('ticketModal').classList.add('hidden')">
                Cerrar
            </button>
            <button class="flex-1 bg-[#2170e4] text-white hover:bg-blue-700 py-2.5 rounded-lg text-sm font-semibold transition-colors flex items-center justify-center gap-2" onclick="printTicket()">
                <span class="material-symbols-outlined text-[18px]">print</span> Imprimir
            </button>
        </div>
    </div>
</div>


<script>
let _currentTicket = null;

function openTicketModal(ticket) {
    _currentTicket = ticket;
    document.getElementById('ticketModalNumber').innerText = 'TICKET DE VENTA #TK-' + String(ticket.id_venta).padStart(5, '0');
    
    const dateObj = new Date(ticket.fecha_hora);
    const options = { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' };
    document.getElementById('ticketModalDate').innerText = isNaN(dateObj) ? ticket.fecha_hora : dateObj.toLocaleDateString('es-ES', options);
    
    document.getElementById('ticketModalCashier').innerText = ticket.empleado || 'Admin';
    document.getElementById('ticketModalClient').innerText = ticket.cliente || 'Consumidor Final';
    
    const itemsContainer = document.getElementById('ticketModalItems');
    itemsContainer.innerHTML = '';
    
    ticket.detalles.forEach(item => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td class="py-2 align-top">${item.cantidad}</td>
            <td class="py-2 pr-2 text-gray-800 font-medium">${item.producto}</td>
            <td class="py-2 text-right tabular-nums align-top">$${parseFloat(item.subtotal).toFixed(2)}</td>
        `;
        itemsContainer.appendChild(tr);
    });
    
    document.getElementById('ticketModalSubtotal').innerText = '$' + parseFloat(ticket.total).toFixed(2);
    document.getElementById('ticketModalTotal').innerText = '$' + parseFloat(ticket.total).toFixed(2);
    
    document.getElementById('ticketModal').classList.remove('hidden');
}

function printTicket() {
    if (!_currentTicket) return;
    const t = _currentTicket;

    const dateObj = new Date(t.fecha_hora);
    const options = { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' };
    const fechaStr = isNaN(dateObj) ? t.fecha_hora : dateObj.toLocaleDateString('es-ES', options);

    let itemRows = t.detalles.map(item => `
        <tr>
            <td style="padding:6px 4px;">${item.cantidad}</td>
            <td style="padding:6px 4px;">${item.producto}</td>
            <td style="padding:6px 4px; text-align:right;">$${parseFloat(item.subtotal).toFixed(2)}</td>
        </tr>
    `).join('');

    const html = `<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8"/>
    <title>Ticket #TK-${String(t.id_venta).padStart(5,'0')}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Courier New', monospace; font-size: 13px; width: 80mm; margin: 0 auto; padding: 12px; color: #111; }
        .center { text-align: center; }
        .store-name { font-size: 20px; font-weight: bold; letter-spacing: 2px; margin-bottom: 4px; }
        .subtitle { font-size: 11px; color: #555; margin-bottom: 2px; }
        .divider { border: none; border-top: 1px dashed #aaa; margin: 10px 0; }
        .ticket-num { display: inline-block; border: 1px solid #ccc; padding: 3px 10px; font-size: 12px; font-weight: bold; margin: 8px 0; }
        .info-row { display: flex; justify-content: space-between; margin: 3px 0; font-size: 12px; }
        .info-label { color: #666; }
        table { width: 100%; border-collapse: collapse; font-size: 12px; }
        thead tr { border-bottom: 1px solid #ccc; }
        th { text-align: left; padding: 4px; font-size: 11px; color: #555; }
        th:last-child { text-align: right; }
        .totals-row { display: flex; justify-content: space-between; margin: 3px 0; font-size: 12px; color: #555; }
        .total-final { display: flex; justify-content: space-between; font-size: 16px; font-weight: bold; margin-top: 6px; padding-top: 6px; border-top: 1px solid #ccc; }
        .footer { text-align: center; font-size: 11px; color: #888; margin-top: 14px; }
        @media print { @page { margin: 0; size: 80mm auto; } }
    </style>
</head>
<body>
    <div class="center">
        <div class="store-name">TECNOMARKET</div>
        <div class="subtitle">RUC: 20123456789</div>
        <div class="subtitle">Av. Tecnol&oacute;gica 1024, Distrito Central</div>
        <div class="ticket-num">TICKET DE VENTA #TK-${String(t.id_venta).padStart(5,'0')}</div>
    </div>
    <hr class="divider">
    <div class="info-row"><span class="info-label">Fecha:</span><span>${fechaStr}</span></div>
    <div class="info-row"><span class="info-label">Cajero:</span><span>${t.empleado || 'Admin'}</span></div>
    <div class="info-row"><span class="info-label">Cliente:</span><span>${t.cliente || 'Consumidor Final'}</span></div>
    <hr class="divider">
    <table>
        <thead><tr><th>Cant.</th><th>Descripci&oacute;n</th><th style="text-align:right">Importe</th></tr></thead>
        <tbody>${itemRows}</tbody>
    </table>
    <hr class="divider">
    <div class="totals-row"><span>Subtotal:</span><span>$${parseFloat(t.total).toFixed(2)}</span></div>
    <div class="totals-row"><span>Impuestos (0%):</span><span>$0.00</span></div>
    <div class="total-final"><span>TOTAL:</span><span>$${parseFloat(t.total).toFixed(2)}</span></div>
    <div class="footer">¡Gracias por su compra!</div>
</body>
</html>`;

    const popup = window.open('', '_blank', 'width=400,height=600,scrollbars=yes');
    popup.document.write(html);
    popup.document.close();
    popup.focus();
    popup.print();
    popup.onafterprint = () => popup.close();
}
</script>

<?php require_once 'includes/footer.php'; ?>