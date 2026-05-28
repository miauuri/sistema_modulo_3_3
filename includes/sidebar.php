<?php
$currentPage = basename($_SERVER['PHP_SELF']);
?>
<nav class="hidden md:flex flex-col h-screen fixed left-0 top-0 py-2 bg-[#131b2e] text-[#7c839b] shadow-md w-[280px] z-40">
    <div class="px-6 py-6 flex items-center gap-4 mb-4">
        <div class="w-10 h-10 bg-[#2170e4] rounded-lg flex items-center justify-center shadow-sm">
            <span class="material-symbols-outlined text-white">devices</span>
        </div>
        <div>
            <h2 class="font-outfit text-xl font-black text-white">TecnoMarket</h2>
            <p class="text-xs opacity-80 tracking-wider">ENTERPRISE ERP</p>
        </div>
    </div>
    
    <div class="flex-1 overflow-y-auto px-2 space-y-1">
        <a class="flex items-center gap-3 px-4 py-3 rounded-lg mx-2 transition-all <?php echo $currentPage == 'index.php' ? 'bg-[#2170e4] text-white shadow-sm' : 'hover:bg-white/10 hover:translate-x-1'; ?>" href="index.php">
            <span class="material-symbols-outlined <?php echo $currentPage == 'index.php' ? 'fill-icon' : ''; ?>">dashboard</span>
            <span class="font-semibold text-[13px] tracking-wide">Dashboard</span>
        </a>
        <a class="flex items-center gap-3 px-4 py-3 rounded-lg mx-2 transition-all <?php echo $currentPage == 'clientes.php' ? 'bg-[#2170e4] text-white shadow-sm' : 'hover:bg-white/10 hover:translate-x-1'; ?>" href="clientes.php">
            <span class="material-symbols-outlined <?php echo $currentPage == 'clientes.php' ? 'fill-icon' : ''; ?>">groups</span>
            <span class="font-semibold text-[13px] tracking-wide">Clientes</span>
        </a>
        <a class="flex items-center gap-3 px-4 py-3 rounded-lg mx-2 transition-all <?php echo $currentPage == 'productos.php' ? 'bg-[#2170e4] text-white shadow-sm' : 'hover:bg-white/10 hover:translate-x-1'; ?>" href="productos.php">
            <span class="material-symbols-outlined <?php echo $currentPage == 'productos.php' ? 'fill-icon' : ''; ?>">inventory_2</span>
            <span class="font-semibold text-[13px] tracking-wide">Productos</span>
        </a>
        <a class="flex items-center gap-3 px-4 py-3 rounded-lg mx-2 transition-all <?php echo $currentPage == 'pos.php' ? 'bg-[#2170e4] text-white shadow-sm' : 'hover:bg-white/10 hover:translate-x-1'; ?>" href="pos.php">
            <span class="material-symbols-outlined <?php echo $currentPage == 'pos.php' ? 'fill-icon' : ''; ?>">point_of_sale</span>
            <span class="font-semibold text-[13px] tracking-wide">Ventas (POS)</span>
        </a>
        <a class="flex items-center gap-3 px-4 py-3 rounded-lg mx-2 transition-all <?php echo $currentPage == 'reportes.php' ? 'bg-[#2170e4] text-white shadow-sm' : 'hover:bg-white/10 hover:translate-x-1'; ?>" href="reportes.php">
            <span class="material-symbols-outlined <?php echo $currentPage == 'reportes.php' ? 'fill-icon' : ''; ?>">analytics</span>
            <span class="font-semibold text-[13px] tracking-wide">Reportes</span>
        </a>
        <?php if ($_SESSION['id_rol'] == 1): ?>
        <a class="flex items-center gap-3 px-4 py-3 rounded-lg mx-2 transition-all <?php echo $currentPage == 'auditoria.php' ? 'bg-[#2170e4] text-white shadow-sm' : 'hover:bg-white/10 hover:translate-x-1'; ?>" href="auditoria.php">
            <span class="material-symbols-outlined <?php echo $currentPage == 'auditoria.php' ? 'fill-icon' : ''; ?>">history</span>
            <span class="font-semibold text-[13px] tracking-wide">Auditoría</span>
        </a>
        <?php endif; ?>
    </div>
    
    <div class="mt-auto px-2 pb-4 pt-4 border-t border-white/10 space-y-1">
        <a class="flex items-center gap-3 px-4 py-3 text-red-400 hover:bg-red-500/10 rounded-lg mx-2 transition-all" href="logout.php">
            <span class="material-symbols-outlined">logout</span>
            <span class="font-semibold text-[13px] tracking-wide">Cerrar Sesión</span>
        </a>
    </div>
</nav>
