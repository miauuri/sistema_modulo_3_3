<?php require_once 'includes/header.php'; ?>
<?php
if ($_SESSION['id_rol'] != 1) {
    echo '<main class="flex-1 p-6 bg-[#f7f9fb] w-full flex flex-col items-center justify-center min-h-[60vh] gap-4">';
    echo '<span class="material-symbols-outlined text-6xl text-red-500">gpp_bad</span>';
    echo '<h2 class="font-outfit text-3xl font-bold text-gray-900">Acceso Denegado</h2>';
    echo '<p class="text-gray-500 text-center max-w-md">No tienes los permisos necesarios para acceder a esta sección. Solo los administradores pueden visualizar la auditoría del sistema.</p>';
    echo '<a href="index.php" class="px-5 py-2.5 bg-[#2170e4] text-white rounded-lg text-sm font-semibold hover:bg-blue-700 transition-colors shadow-sm mt-4">Volver al Inicio</a>';
    echo '</main>';
    require_once 'includes/footer.php';
    exit();
}

// Obtener registros de auditoría
$stmtAuditoria = $db->query("SELECT a.id, a.tabla_afectada, a.accion, a.id_registro, a.descripcion, a.fecha_hora, e.nombre AS empleado_nombre 
    FROM auditoria a 
    LEFT JOIN empleados e ON a.id_empleado = e.id 
    ORDER BY a.fecha_hora DESC");
$registros = $stmtAuditoria->fetchAll(PDO::FETCH_ASSOC);

// Métricas
$total_eventos = count($registros);
?>
<main class="flex-1 p-6 bg-[#f7f9fb] w-full flex flex-col gap-8 pb-12 overflow-x-hidden">
    <!-- Page Header -->
    <div class="mb-8">
        <h2 class="font-outfit text-3xl font-bold text-gray-900">Auditoría</h2>
        <p class="text-gray-500 mt-1">Registro histórico de actividades y cambios en el sistema.</p>
    </div>

    <!-- Data Table -->
    <div class="bg-white rounded-xl border border-gray-200 shadow-sm flex flex-col overflow-hidden">
        <div class="p-4 border-b border-gray-200 bg-white flex justify-between items-center gap-4 flex-wrap">
            <div class="relative w-full md:w-80">
                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-[20px]">search</span>
                <input id="searchInput" class="w-full pl-10 pr-4 py-2 bg-gray-50 border border-transparent rounded-lg text-sm focus:border-[#2170e4] focus:bg-white focus:ring-2 focus:ring-blue-500/20 transition-all outline-none" placeholder="Buscar en auditoría..." type="text"/>
            </div>
            <p class="text-sm text-gray-500">Mostrando <?php echo number_format($total_eventos); ?> registros</p>
        </div>

        <div class="overflow-x-auto w-full custom-scrollbar">
            <table class="w-full text-left border-collapse whitespace-nowrap">
                <thead class="bg-gray-50 text-gray-600 text-xs font-semibold uppercase tracking-wider">
                    <tr>
                        <th class="px-6 py-4">Fecha y Hora</th>
                        <th class="px-6 py-4">Usuario</th>
                        <th class="px-6 py-4">Acción</th>
                        <th class="px-6 py-4">Tabla Afectada</th>
                        <th class="px-6 py-4 text-right">ID Registro</th>
                        <th class="px-6 py-4">Descripción</th>
                    </tr>
                </thead>
                <tbody id="auditoriaTable" class="text-sm text-gray-800 divide-y divide-gray-100">
                    <?php foreach($registros as $r): ?>
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 text-gray-500 font-mono"><?php echo htmlspecialchars($r['fecha_hora']); ?></td>
                        <td class="px-6 py-4 font-medium text-gray-900">
                            <?php if ($r['empleado_nombre']): ?>
                                <?php echo htmlspecialchars($r['empleado_nombre']); ?>
                            <?php else: ?>
                                <span class="text-gray-400 italic">Sistema</span>
                            <?php endif; ?>
                        </td>
                        <td class="px-6 py-4 text-gray-700 font-semibold uppercase text-xs">
                            <?php echo htmlspecialchars($r['accion']); ?>
                        </td>
                        <td class="px-6 py-4 text-gray-500 capitalize"><?php echo htmlspecialchars($r['tabla_afectada']); ?></td>
                        <td class="px-6 py-4 text-right font-mono text-[#2170e4] font-semibold"><?php echo htmlspecialchars($r['id_registro']); ?></td>
                        <td class="px-6 py-4 text-gray-500 truncate max-w-sm" title="<?php echo htmlspecialchars($r['descripcion']); ?>">
                            <?php echo htmlspecialchars($r['descripcion']); ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (count($registros) == 0): ?>
                    <tr><td colspan="6" class="px-6 py-8 text-center text-gray-500">No hay registros de auditoría en la base de datos.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<script>
// Funcionalidad básica del buscador
document.getElementById('searchInput').addEventListener('keyup', function() {
    let filter = this.value.toLowerCase();
    let rows = document.querySelectorAll('#auditoriaTable tr');
    
    rows.forEach(row => {
        let text = row.textContent.toLowerCase();
        row.style.display = text.includes(filter) ? '' : 'none';
    });
});
</script>

<?php require_once 'includes/footer.php'; ?>
