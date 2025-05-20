<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Conexión a la base de datos
$host = 'localhost';
$usuario = 'navihqup_litsu';
$contraseña = 'x_@5wBI{t&C{';
$base_de_datos = 'navihqup_jhoto';

$conexion = new mysqli($host, $usuario, $contraseña, $base_de_datos);
if ($conexion->connect_error) {
    http_response_code(500);
    echo "Error de conexión con la base de datos.";
    exit();
}

// Verificamos parámetros
if (
    empty($_GET["uid_jugador"]) ||  // Recibimos el uid del jugador para buscarlo en la base de datos
    empty($_GET["nombre_pokemon"]) ||
    empty($_GET["ruta"]) ||
    empty($_GET["uuid"])  // Recibimos el uuid del pokemon
) {
    http_response_code(400);
    echo "Faltan parámetros requeridos: uid_jugador, nombre_pokemon, ruta, uuid.";
    exit();
}

$uid_jugador = $_GET["uid_jugador"];  // El uid del jugador
$nombre_pokemon = $_GET["nombre_pokemon"];
$ruta = $_GET["ruta"];
$uuid_pokemon = $_GET["uuid"];  // El uuid del Pokémon

// Buscar el jugador por su uid
$stmt_jugador = $conexion->prepare("SELECT id FROM jugadores WHERE uid = ?");
$stmt_jugador->bind_param("s", $uid_jugador);  // Buscamos al jugador por su uid
$stmt_jugador->execute();
$resultado = $stmt_jugador->get_result();

if ($resultado->num_rows === 0) {
    http_response_code(404);
    echo "Jugador con UID '$uid_jugador' no encontrado.";
    exit();
}

$fila = $resultado->fetch_assoc();
$id_jugador = $fila["id"];  // Obtenemos el id del jugador con ese uid

$stmt_jugador->close();

// Insertar el Pokémon para este jugador
$stmt = $conexion->prepare("INSERT INTO pokemons (id_jugador, nombre, ruta, uid) VALUES (?, ?, ?, ?)");
$stmt->bind_param("issi", $id_jugador, $nombre_pokemon, $ruta, $uuid_pokemon);  // Insertamos el Pokémon

if ($stmt->execute()) {
    http_response_code(200);
    echo "Pokémon '$nombre_pokemon' registrado para el jugador con UID '$uid_jugador'.";
} else {
    http_response_code(500);
    echo "Error al registrar el Pokémon: " . $stmt->error;
}

$stmt->close();
$conexion->close();
?>
