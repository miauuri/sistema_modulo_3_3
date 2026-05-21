<?php
session_start();
header('Content-Type: application/json');

if (!isset($_SESSION['usuario_id'])) {
    echo json_encode(['success' => false, 'error' => 'No autorizado']);
    exit();
}

require_once 'config/database.php';
$database = new Database();
$db = $database->getConnection();

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['items']) || empty($input['items'])) {
    echo json_encode(['success' => false, 'error' => 'El carrito está vacío']);
    exit();
}

$empleado_id = $_SESSION['usuario_id'];
$cliente_id = !empty($input['cliente_id']) ? $input['cliente_id'] : 1; 

$items_json = json_encode($input['items']);

try {
    // LLamada a la funcion en postgres
    $stmt = $db->prepare("CALL registrar_venta(:cliente_id, :empleado_id, :items_json)");
    $stmt->bindParam(':cliente_id', $cliente_id);
    $stmt->bindParam(':empleado_id', $empleado_id);
    $stmt->bindParam(':items_json', $items_json);
    $stmt->execute();
    
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode(['success' => true, 'id_venta' => $row['id_venta']]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
