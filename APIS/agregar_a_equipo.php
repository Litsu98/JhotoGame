<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Conexión a la base de datos
$host = 'localhost';
$usuario = 'root';
$contraseña = '';
$base_de_datos = 'jhoto';

$conexion = new mysqli();
$conexion->options(MYSQLI_OPT_CONNECT_TIMEOUT, 2);  // Timeout corto
$conexion->real_connect($host, $usuario, $contraseña, $base_de_datos);

if ($conexion->connect_error) {
    http_response_code(500);
    echo "Error de conexión con la base de datos.";
    exit();
}

// Verificar que se haya enviado el uid del jugador
if (!isset($_GET["uid_jugador"])) {
    http_response_code(400);
    echo "Falta el parámetro: uid_jugador";
    exit();
}

$uid_jugador = $_GET["uid_jugador"];  // Usamos el uid_jugador en lugar del nombre_jugador

// Arreglo para almacenar los Pokémon a insertar
$pokemons = [];

// Caso 1: Parámetros indexados (ej. especie0, especie1, ...)
if (isset($_GET["especie0"])) {
    $index = 0;
    while (isset($_GET["especie" . $index])) {
        $pokemon = [
            'especie'         => $_GET["especie" . $index],
            'mote'            => $_GET["mote" . $index],
            'genero'          => $_GET["genero" . $index],
            'hp'              => (int) $_GET["hp" . $index],
            'ataque'          => (int) $_GET["ataque" . $index],
            'defensa'         => (int) $_GET["defensa" . $index],
            'velocidad'       => (int) $_GET["velocidad" . $index],
            'ataque_especial' => (int) $_GET["ataque_especial" . $index],
            'defensa_especial'=> (int) $_GET["defensa_especial" . $index],
            'uuid'            => $_GET["uuid" . $index],
            'habilidad'       => $_GET["habilidad" . $index],
            'titular'         => (isset($_GET["titular" . $index]) && $_GET["titular" . $index] === "true") ? 1 : 0
        ];
        $pokemons[] = $pokemon;
        $index++;
    }
}
// Caso 2: Parámetros sin índice (un solo Pokémon)
elseif (isset($_GET["especie"])) {
    $pokemons[] = [
        'especie'         => $_GET["especie"],
        'mote'            => $_GET["mote"],
        'genero'          => $_GET["genero"],
        'hp'              => (int) $_GET["hp"],
        'ataque'          => (int) $_GET["ataque"],
        'defensa'         => (int) $_GET["defensa"],
        'velocidad'       => (int) $_GET["velocidad"],
        'ataque_especial' => (int) $_GET["ataque_especial"],
        'defensa_especial'=> (int) $_GET["defensa_especial"],
        'uuid'            => $_GET["uuid"],
        'habilidad'       => $_GET["habilidad"],
        'titular'         => (isset($_GET["titular"]) && $_GET["titular"] === "true") ? 1 : 0
    ];
} else {
    http_response_code(400);
    echo "No se han recibido parámetros de Pokémon.";
    exit();
}

// Obtener ID del jugador usando el uid_jugador
$stmt_jugador = $conexion->prepare("SELECT id FROM jugadores WHERE uid = ?");  // Cambiamos "nombre" por "uid"
$stmt_jugador->bind_param("s", $uid_jugador);  // Usamos el uid_jugador
$stmt_jugador->execute();
$resultado = $stmt_jugador->get_result();

if ($resultado->num_rows === 0) {
    http_response_code(404);
    echo "Jugador con UID '$uid_jugador' no encontrado.";
    exit();
}
$id_jugador = $resultado->fetch_assoc()["id"];
$stmt_jugador->close();

// Eliminar los Pokémon anteriores del jugador
$stmt_eliminar = $conexion->prepare("DELETE FROM equipo WHERE id_jugador = ?");
$stmt_eliminar->bind_param("i", $id_jugador);
if (!$stmt_eliminar->execute()) {
    http_response_code(500);
    echo "Error al eliminar los Pokémon anteriores: " . $stmt_eliminar->error;
    exit();
}
$stmt_eliminar->close();

// Insertar cada Pokémon en la base de datos
foreach ($pokemons as $pokemon) {
    $stmt = $conexion->prepare("INSERT INTO equipo (
        id_jugador, especie, mote, genero, hp, ataque, defensa, velocidad,
        ataque_especial, defensa_especial, uid, habilidad, titular
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

    $stmt->bind_param("isssiiiiiiiss", 
        $id_jugador,
        $pokemon['especie'],
        $pokemon['mote'],
        $pokemon['genero'],
        $pokemon['hp'],
        $pokemon['ataque'],
        $pokemon['defensa'],
        $pokemon['velocidad'],
        $pokemon['ataque_especial'],
        $pokemon['defensa_especial'],
        $pokemon['uuid'],
        $pokemon['habilidad'],
        $pokemon['titular']
    );
    
    if (!$stmt->execute()) {
        http_response_code(500);
        echo "Error al agregar el Pokémon al equipo: " . $stmt->error;
        exit();
    }
    $stmt->close();
}

echo "Pokémon(s) agregado(s) al equipo del jugador con UID '$uid_jugador'.";
$conexion->close();
?>
