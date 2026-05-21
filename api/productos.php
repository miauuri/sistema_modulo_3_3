<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 
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
                $stmt = $db->prepare("SELECT p.id as id_producto, p.id_categoria, p.codigo, p.nombre, p.precio, p.stock, p.stock_minimo, p.activo, c.nombre as categoria FROM productos p JOIN categorias c ON p.id_categoria = c.id WHERE p.id = :id AND p.activo = TRUE");
                $stmt->bindParam(':id', $id);
                $stmt->execute();
                echo json_encode($stmt->fetch(PDO::FETCH_ASSOC));
            } else {
                $stmt = $db->query("SELECT p.id as id_producto, p.id_categoria, p.codigo, p.nombre, p.precio, p.stock, p.stock_minimo, p.activo, c.nombre as categoria FROM productos p JOIN categorias c ON p.id_categoria = c.id WHERE p.activo = TRUE");
                echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
            }
            break;
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            $stmt = $db->prepare("CALL crear_producto(:id_categoria, :codigo, :nombre, :precio, :stock, :stock_minimo)");
            $stmt->bindParam(':id_categoria', $input['id_categoria']);
            $stmt->bindParam(':codigo', $input['codigo']);
            $stmt->bindParam(':nombre', $input['nombre']);
            $stmt->bindParam(':precio', $input['precio']);
            $stmt->bindParam(':stock', $input['stock']);
            $stmt->bindParam(':stock_minimo', $input['stock_minimo']);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $input['id_producto'] = $row['id'];
            echo json_encode($input);
            break;
        case 'PUT':
            $input = json_decode(file_get_contents('php://input'), true);
            $actual_id = $id ? $id : ($input['id_producto'] ?? null);
            $stmt = $db->prepare("CALL actualizar_producto(:id, :id_categoria, :codigo, :nombre, :precio, :stock, :stock_minimo)");
            $stmt->bindParam(':id', $actual_id);
            $stmt->bindParam(':id_categoria', $input['id_categoria']);
            $stmt->bindParam(':codigo', $input['codigo']);
            $stmt->bindParam(':nombre', $input['nombre']);
            $stmt->bindParam(':precio', $input['precio']);
            $stmt->bindParam(':stock', $input['stock']);
            $stmt->bindParam(':stock_minimo', $input['stock_minimo']);
            $stmt->execute();
            echo json_encode($input);
            break;
        case 'DELETE':
            $stmt = $db->prepare("CALL desactivar_producto(:id)");
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
