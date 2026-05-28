<?php
session_start();
if (!isset($_SESSION['usuario_id'])) {
    header("Location: login.php");
    exit();
}
require_once 'config/database.php';
$database = new Database();
$db = $database->getConnection();
?>
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8" />
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <title>TecnoMarket - ERP</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link
        href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap"
        rel="stylesheet" />
    <link
        href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;900&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700&amp;display=swap"
        rel="stylesheet" />
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f7f9fb;
            color: #191c1e;
            -webkit-font-smoothing: antialiased;
        }

        .font-outfit {
            font-family: 'Outfit', sans-serif;
        }

        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }

        .fill-icon {
            font-variation-settings: 'FILL' 1;
        }
    </style>
</head>

<body class="min-h-screen flex">
    <?php include 'sidebar.php'; ?>
    <div class="flex-1 flex flex-col md:ml-[280px] w-full min-h-screen relative">
        <header
            class="flex justify-between items-center h-16 px-6 w-full sticky top-0 z-50 bg-white border-b border-gray-200 shadow-sm">
            <div class="flex items-center gap-4">
                <button class="md:hidden text-gray-500 p-2 -ml-2 rounded-full hover:bg-gray-100 transition-colors">
                    <span class="material-symbols-outlined">menu</span>
                </button>
                <div class="hidden md:flex relative group">
                    <span
                        class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-[20px]">search</span>
                    <input
                        class="pl-10 pr-4 py-2 bg-gray-100 border border-transparent rounded-lg text-sm focus:border-[#2170e4] focus:bg-white focus:ring-2 focus:ring-blue-500/20 transition-all outline-none w-64"
                        placeholder="Buscar..." type="text" />
                </div>
            </div>
            <div class="flex items-center gap-4">
                <div class="flex items-center gap-3">
                    <div class="text-right hidden sm:block">
                        <p class="text-sm font-semibold text-gray-900">
                            <?php echo htmlspecialchars($_SESSION['nombre']); ?></p>
                        <p class="text-[12px] text-gray-500">
                            <?php echo $_SESSION['id_rol'] == 1 ? 'Administrador' : 'Empleado'; ?></p>
                    </div>
                    <div
                        class="w-9 h-9 rounded-full bg-[#2170e4] text-white flex items-center justify-center font-bold shadow-sm">
                        <?php echo substr($_SESSION['nombre'], 0, 1); ?>
                    </div>
                </div>
            </div>
        </header>