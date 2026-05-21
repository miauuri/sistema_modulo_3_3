<?php require_once 'includes/header.php'; ?>
<?php
// Obtener todos los clientes
$stmtClientes = $db->query("SELECT * FROM clientes ORDER BY id DESC");
$clientes = $stmtClientes->fetchAll(PDO::FETCH_ASSOC);

// Métricas
$total_clientes = count($clientes);
$activos = 0;
foreach($clientes as $c) {
    if ($c['activo']) $activos++;
}
$tasa_actividad = $total_clientes > 0 ? round(($activos / $total_clientes) * 100) : 0;
?>
<main class="flex-1 p-6 bg-[#f7f9fb] w-full flex flex-col gap-8 pb-12">
    <!-- Page Header -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
            <h2 class="font-outfit text-3xl font-bold text-gray-900">Clientes</h2>
            <p class="text-gray-500 mt-1">Gestión y administración del directorio comercial</p>
        </div>
        <div class="flex items-center gap-3">
            <button class="flex items-center gap-2 px-4 py-2.5 bg-white border border-gray-200 rounded-lg text-sm font-semibold text-gray-700 hover:bg-gray-50 transition-colors shadow-sm">
                <span class="material-symbols-outlined text-[18px]">download</span> Exportar
            </button>
            <button class="flex items-center gap-2 px-5 py-2.5 bg-[#2170e4] text-white rounded-lg text-sm font-semibold hover:bg-blue-700 transition-colors shadow-sm">
                <span class="material-symbols-outlined text-[18px]">person_add</span> Nuevo Cliente
            </button>
        </div>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm flex flex-col gap-4 relative overflow-hidden group">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center text-[#2170e4]"><span class="material-symbols-outlined">groups</span></div>
                <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Clientes</span>
            </div>
            <div class="flex items-baseline gap-2">
                <span class="font-outfit text-4xl font-bold text-gray-900"><?php echo number_format($total_clientes); ?></span>
            </div>
        </div>
        
        <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm flex flex-col gap-4 relative overflow-hidden group">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-green-50 flex items-center justify-center text-green-600"><span class="material-symbols-outlined">check_circle</span></div>
                <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Clientes Activos</span>
            </div>
            <div class="flex items-baseline gap-2">
                <span class="font-outfit text-4xl font-bold text-gray-900"><?php echo number_format($activos); ?></span>
            </div>
        </div>

        <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm flex flex-col gap-4 relative overflow-hidden group">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-purple-50 flex items-center justify-center text-purple-600"><span class="material-symbols-outlined">trending_up</span></div>
                <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Tasa de Actividad</span>
            </div>
            <div class="flex items-baseline gap-2">
                <span class="font-outfit text-4xl font-bold text-gray-900"><?php echo $tasa_actividad; ?>%</span>
                <span class="text-sm text-gray-500">del total</span>
            </div>
        </div>
    </div>

    <!-- Data Table -->
    <div class="bg-white rounded-xl border border-gray-200 shadow-sm flex flex-col overflow-hidden">
        <div class="p-4 border-b border-gray-200 bg-white flex justify-between items-center gap-4 flex-wrap">
            <div class="relative w-full md:w-80">
                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-[20px]">search</span>
                <input class="w-full pl-10 pr-4 py-2 bg-gray-50 border border-transparent rounded-lg text-sm focus:border-[#2170e4] focus:bg-white focus:ring-2 focus:ring-blue-500/20 transition-all outline-none" placeholder="Buscar clientes..." type="text"/>
            </div>
        </div>

        <div class="overflow-x-auto w-full">
            <table class="w-full text-left border-collapse whitespace-nowrap">
                <thead class="bg-gray-50 text-gray-600 text-xs font-semibold uppercase tracking-wider">
                    <tr>
                        <th class="px-6 py-4">Nombre</th>
                        <th class="px-6 py-4">Identificación</th>
                        <th class="px-6 py-4">Teléfono</th>
                        <th class="px-6 py-4">Correo</th>
                        <th class="px-6 py-4">Estado</th>
                        <th class="px-6 py-4 text-right">Acciones</th>
                    </tr>
                </thead>
                <tbody class="text-sm text-gray-800 divide-y divide-gray-100">
                    <?php foreach($clientes as $c): ?>
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4">
                            <div class="flex flex-col">
                                <span class="font-medium text-gray-900"><?php echo htmlspecialchars($c['nombre']); ?></span>
                                <span class="text-xs text-gray-500"><?php echo htmlspecialchars($c['direccion']); ?></span>
                            </div>
                        </td>
                        <td class="px-6 py-4 font-mono text-gray-500"><?php echo htmlspecialchars($c['identificacion']); ?></td>
                        <td class="px-6 py-4"><?php echo htmlspecialchars($c['telefono']); ?></td>
                        <td class="px-6 py-4 text-[#2170e4]"><?php echo htmlspecialchars($c['correo']); ?></td>
                        <td class="px-6 py-4">
                            <?php if($c['activo']): ?>
                                <span class="px-2 py-1 bg-green-100 text-green-800 text-xs font-semibold rounded-full uppercase">Activo</span>
                            <?php else: ?>
                                <span class="px-2 py-1 bg-red-100 text-red-800 text-xs font-semibold rounded-full uppercase">Inactivo</span>
                            <?php endif; ?>
                        </td>
                        <td class="px-6 py-4 text-right">
                            <button class="p-1.5 text-gray-500 hover:text-[#2170e4] rounded-md transition-colors" title="Editar"><span class="material-symbols-outlined text-[20px]">edit</span></button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (count($clientes) == 0): ?>
                    <tr><td colspan="6" class="px-6 py-8 text-center text-gray-500">No hay clientes registrados en la base de datos.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</main>
<?php require_once 'includes/footer.php'; ?>