# Pozo Slowpoke: corrección de codificación

## Mapas revisados

- Map010: exterior del Pozo Slowpoke.
- Map046: entrada del pozo.
- Map058: mapa principal del Pozo Slowpoke y escena inicial con Antón.
- Map113 y Map117: plantas secundarias del pozo.

## Correcciones aplicadas

- Se normalizaron 24 cadenas de texto a UTF-8 válido.
- Map010 contenía cuatro copias corruptas de la pregunta sobre arrojar la Piedra Espíritu al pozo.
- Map058 contenía veinte diálogos con doble codificación: reclutas Rocket, Antón, Atenea y conversaciones posteriores a los combates.
- Se corrigieron secuencias visibles como `Â¡`, `Â¿`, `Ã¡`, `Ã©`, `Ã­`, `Ã³`, `Ãº` y `Ã±`.
- Se realizó una segunda pasada y Map058 ya no contiene `Â`, `Ã` ni escapes octales visibles.

## Elementos preservados

- No se modificó el contenido narrativo de los diálogos.
- No se modificaron retratos, pausas, movimientos, combates, equipos, rutas, condiciones, interruptores, recompensas ni llamadas a Antón, Atenea o los reclutas.
