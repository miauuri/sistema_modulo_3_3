<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // Allow local development
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
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
$id = isset($_GET['id']) ? intval($_GET['id']) : null;

try {
    switch ($method) {
        case 'GET':
            if ($id) {
                $stmt = $db->prepare("SELECT id as id_cliente, identificacion, nombre, direccion, telefono, correo, activo FROM clientes WHERE id = :id AND activo = TRUE");
                $stmt->bindParam(':id', $id);
                $stmt->execute();
                echo json_encode($stmt->fetch(PDO::FETCH_ASSOC));
            } else {
                $stmt = $db->query("SELECT id as id_cliente, identificacion, nombre, direccion, telefono, correo, activo FROM clientes WHERE activo = TRUE");
                echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
            }
            break;
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            $stmt = $db->prepare("CALL crear_cliente(:nombre, :identificacion, :direccion, :telefono, :correo)");
            $stmt->bindValue(':nombre', $input['nombre']);
            $stmt->bindValue(':identificacion', $input['identificacion']);
            $stmt->bindValue(':direccion', $input['direccion'] ?? '');
            $stmt->bindValue(':telefono', $input['telefono'] ?? '');
            $stmt->bindValue(':correo', $input['correo'] ?? '');
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $input['id_cliente'] = $row['id'];
            echo json_encode($input);
            break;
        case 'PUT':
            $input = json_decode(file_get_contents('php://input'), true);
            $actual_id = $id ? $id : ($input['id_cliente'] ?? null);
            $stmt = $db->prepare("CALL actualizar_cliente(:id, :nombre, :identificacion, :direccion, :telefono, :correo)");
            $stmt->bindValue(':id', $actual_id);
            $stmt->bindValue(':nombre', $input['nombre']);
            $stmt->bindValue(':identificacion', $input['identificacion']);
            $stmt->bindValue(':direccion', $input['direccion'] ?? '');
            $stmt->bindValue(':telefono', $input['telefono'] ?? '');
            $stmt->bindValue(':correo', $input['correo'] ?? '');
            $stmt->execute();
            echo json_encode($input);
            break;
        case 'DELETE':
            $stmt = $db->prepare("CALL desactivar_cliente(:id)");
            $stmt->bindParam(':id', $id);
            $stmt->execute();
            echo json_encode(['success' => true]);
            break;
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
