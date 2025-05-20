<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Configuración de la base de datos
$host = 'localhost';
$usuario = 'navihqup_litsu';
$contraseña = 'x_@5wBI{t&C{';
$base_de_datos = 'navihqup_jhoto';

$conexion = new mysqli($host, $usuario, $contraseña, $base_de_datos);

if ($conexion->connect_error) {
    http_response_code(500);
    echo "Error al conectar con la base de datos.";
    exit();
}

// Obtener el nombre desde el parámetro GET
if (!isset($_GET['nombre'])) {
    http_response_code(400); // Bad Request
    echo "Falta el parámetro 'nombre'.";
    exit();
}

$nombre = trim($_GET['nombre']);
if (empty($nombre)) {
    http_response_code(400);
    echo "El nombre no puede estar vacío.";
    exit();
}

// Obtener el UUID desde el parámetro GET
if (!isset($_GET['uid'])) {
    http_response_code(400); // Bad Request
    echo "Falta el parámetro 'uid'.";
    exit();
}

$uid = trim($_GET['uid']);
if (empty($uid)) {
    http_response_code(400);
    echo "El UUID no puede estar vacío.";
    exit();
}

// Preparar e insertar
$stmt = $conexion->prepare("INSERT INTO jugadores (nombre, uid) VALUES (?, ?)");
$stmt->bind_param("ss", $nombre, $uid); // Usamos 'ss' para los dos parámetros de tipo string (nombre y uid)

if ($stmt->execute()) {
    http_response_code(200);
    echo "Jugador '$nombre' registrado con éxito con UID: $uid.";
} else {
    http_response_code(500);
    echo "Error al registrar el jugador: " . $stmt->error;
}

$conexion->close();
?>
