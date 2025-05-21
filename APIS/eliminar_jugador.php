<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Configuración de la base de datos
$host           = 'localhost';
$usuario        = 'navihqup_litsu';
$contraseña     = 'x_@5wBI{t&C{';
$base_de_datos  = 'navihqup_jhoto';

// Crear conexión
$conexion = new mysqli($host, $usuario, $contraseña, $base_de_datos);
if ($conexion->connect_error) {
    http_response_code(500);
    echo "Error al conectar con la base de datos.";
    exit();
}

// Validar parámetro 'nombre'
if (!isset($_GET['nombre'])) {
    http_response_code(400);
    echo "Falta el parámetro 'nombre'.";
    exit();
}
$nombre = trim($_GET['nombre']);
if ($nombre === '') {
    http_response_code(400);
    echo "El nombre no puede estar vacío.";
    exit();
}

// Validar parámetro 'uid'
if (!isset($_GET['uid'])) {
    http_response_code(400);
    echo "Falta el parámetro 'uid'.";
    exit();
}
$uid = trim($_GET['uid']);
if ($uid === '') {
    http_response_code(400);
    echo "El UUID no puede estar vacío.";
    exit();
}

// Preparar y ejecutar la eliminación
$stmt = $conexion->prepare("DELETE FROM jugadores WHERE nombre = ? AND uid = ?");
$stmt->bind_param("ss", $nombre, $uid);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        http_response_code(200);
        echo "Jugador '$nombre' con UID '$uid' eliminado correctamente.";
    } else {
        http_response_code(404);
        echo "No se encontró ningún jugador con nombre '$nombre' y UID '$uid'.";
    }
} else {
    http_response_code(500);
    echo "Error al eliminar el jugador: " . $stmt->error;
}

$stmt->close();
$conexion->close();
?>
