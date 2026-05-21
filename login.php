<?php
session_start();
require_once 'config/database.php';

if (isset($_SESSION['usuario_id'])) {
    header("Location: index.php");
    exit();
}

$error = '';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';

    if (!empty($username) && !empty($password)) {
        $database = new Database();
        $db = $database->getConnection();

        $stmt = $db->prepare("SELECT id, nombre, usuario, password_hash, id_rol FROM empleados WHERE usuario = :usuario AND activo = true");
        $stmt->bindParam(':usuario', $username);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            if (password_verify($password, $row['password_hash'])) {
                $_SESSION['usuario_id'] = $row['id'];
                $_SESSION['nombre'] = $row['nombre'];
                $_SESSION['usuario'] = $row['usuario'];
                $_SESSION['id_rol'] = $row['id_rol'];
                header("Location: index.php");
                exit();
            } else {
                $error = 'Credenciales incorrectas.';
            }
        } else {
            $error = 'Usuario no encontrado o inactivo.';
        }
    } else {
        $error = 'Por favor complete ambos campos.';
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>TecnoMarket - Login</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700&amp;family=Plus+Jakarta+Sans:wght@400;500;600&amp;display=swap" rel="stylesheet"/>
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #e6e8ea; }
        .font-outfit { font-family: 'Outfit', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        .fill-icon { font-variation-settings: 'FILL' 1; }
    </style>
</head>
<body class="flex items-center justify-center min-h-screen p-4 text-gray-900">
    <div class="bg-white w-full max-w-md rounded-xl shadow-md p-8 flex flex-col items-center">
        <div class="mb-8 text-center">
            <span class="material-symbols-outlined text-[48px] text-[#2170e4] mb-4">storefront</span>
            <h1 class="font-outfit text-[32px] font-bold text-gray-900 tracking-tight">TecnoMarket</h1>
            <p class="text-gray-500 mt-1">Acceso Administrativo</p>
        </div>
        
        <?php if (!empty($error)): ?>
        <div class="w-full bg-red-100 text-red-800 p-3 rounded-lg mb-6 flex items-start gap-3">
            <span class="material-symbols-outlined fill-icon mt-0.5">error</span>
            <p class="text-sm"><?php echo htmlspecialchars($error); ?></p>
        </div>
        <?php endif; ?>
        
        <form class="w-full space-y-6" method="POST" action="">
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2" for="username">Usuario</label>
                <input class="w-full bg-white border border-gray-300 rounded-lg px-4 py-3 focus:ring-2 focus:ring-[#2170e4] focus:border-transparent outline-none transition-shadow" id="username" name="username" placeholder="admin" type="text" required autofocus/>
            </div>
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2" for="password">Contraseña</label>
                <input class="w-full bg-white border border-gray-300 rounded-lg px-4 py-3 focus:ring-2 focus:ring-[#2170e4] focus:border-transparent outline-none transition-shadow" id="password" name="password" placeholder="••••••••" type="password" required/>
            </div>
            <button class="w-full bg-[#2170e4] hover:bg-blue-700 text-white font-semibold py-3 rounded-lg transition-colors shadow-sm mt-2" type="submit">
                Ingresar al Sistema
            </button>
        </form>
    </div>
</body>
</html>
