<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

session_start();
require_once '../config/database.php';
$database = new Database();
$db = $database->getConnection();

try {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $stmt = $db->query("SELECT * FROM vista_dashboard");
        $stats = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'totalClientes' => $stats['total_clientes_activos'],
            'totalProductos' => $stats['total_productos_activos'],
            'ventasHoy' => $stats['ventas_del_dia'],
            'alertasStock' => $stats['productos_stock_bajo'],
            'totalEmpleados' => $stats['total_empleados_activos']
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
