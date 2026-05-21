<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

session_start();
require_once '../config/database.php';
$database = new Database();
$db = $database->getConnection();

$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($method === 'GET') {
        $stmt = $db->query("SELECT * FROM vista_ventas_detalladas ORDER BY fecha_hora DESC");
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $ventas = [];
        foreach($resultados as $row) {
            $id = $row['id_venta'];
            if(!isset($ventas[$id])) {
                $ventas[$id] = [
                    'id_venta' => $id,
                    'fecha_hora' => $row['fecha_hora'],
                    'cliente' => $row['cliente'],
                    'empleado' => $row['empleado'],
                    'total' => $row['total'],
                    'detalles' => []
                ];
            }
            $ventas[$id]['detalles'][] = [
                'producto' => $row['producto'],
                'cantidad' => $row['cantidad'],
                'precio_unitario' => $row['precio_unitario'],
                'subtotal' => $row['subtotal']
            ];
        }
        echo json_encode(array_values($ventas));
    } elseif ($method === 'POST') {
        $input = json_decode(file_get_contents('php://input'), true);
        
        $empleado_id = $_SESSION['usuario_id'] ?? 1;
        $cliente_id = !empty($input['id_cliente']) ? $input['id_cliente'] : (!empty($input['cliente_id']) ? $input['cliente_id'] : 1);
        
        $items = isset($input['detalles']) ? $input['detalles'] : (isset($input['items']) ? $input['items'] : []);
        $items_json = json_encode($items);

        $stmt = $db->prepare("CALL registrar_venta(:cliente_id, :empleado_id, :items_json)");
        $stmt->bindParam(':cliente_id', $cliente_id);
        $stmt->bindParam(':empleado_id', $empleado_id);
        $stmt->bindParam(':items_json', $items_json);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'id_venta' => $row['id_venta']]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
