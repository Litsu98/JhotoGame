<?php
// Mostrar errores para depuración
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Conexión a la base de datos
$host = 'localhost';
$usuario = 'root';
$contraseña = '';
$base_de_datos = 'jhoto';

$conexion = new mysqli($host, $usuario, $contraseña, $base_de_datos);
if ($conexion->connect_error) {
    http_response_code(500);
    echo "Error de conexión con la base de datos.";
    exit();
}

// Verificar que los parámetros existan
if (
    empty($_GET["uid_jugador"]) ||  // Cambiado a 'uid_jugador'
    empty($_GET["nombre"]) ||
    !isset($_GET["apodo"]) ||
    !isset($_GET["uuid"])  // Asegurarse de que también se recibe el 'uuid'
) {
    http_response_code(400);
    echo "Faltan parámetros: uid_jugador, nombre, apodo, uuid.";
    exit();
}

$uid_jugador = $_GET["uid_jugador"];  // Recibimos el 'uid_jugador'
$nombre = $_GET["nombre"];
$apodo = $_GET["apodo"];
$uuid = $_GET["uuid"];  // Recibimos el 'uuid'

// Buscar el ID del jugador por su 'uid_jugador'
$stmt_jugador = $conexion->prepare("SELECT id FROM jugadores WHERE uid = ?");
$stmt_jugador->bind_param("s", $uid_jugador);  // Buscamos por 'uid' en lugar de 'nombre'
$stmt_jugador->execute();
$resultado = $stmt_jugador->get_result();

if ($resultado->num_rows === 0) {
    http_response_code(404);
    echo "Jugador con UID '$uid_jugador' no encontrado.";
    exit();
}

$fila = $resultado->fetch_assoc();
$id_jugador = $fila["id"];

$stmt_jugador->close();

// Insertar el Pokémon debilitado en la base de datos
$stmt = $conexion->prepare("INSERT INTO debilitados (id_jugador, nombre, apodo, uid) VALUES (?, ?, ?, ?)");
$stmt->bind_param("issi", $id_jugador, $nombre, $apodo, $uuid);

if ($stmt->execute()) {
    http_response_code(200);
    echo "Pokémon '$nombre' con apodo '$apodo' registrado como debilitado para el jugador con UID '$uid_jugador'.";
} else {
    http_response_code(500);
    echo "Error al registrar Pokémon debilitado: " . $stmt->error;
}

$stmt->close();
$conexion->close();
?>
