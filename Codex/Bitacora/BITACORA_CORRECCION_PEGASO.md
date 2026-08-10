# Corrección del evento de Pegaso

## Map053, evento 6

- Tras añadir ritmo y pausas al diálogo, se comprobó durante una prueba jugable que no aparecía la animación de la Medalla Céfiro ni se entregaba la MT.
- La comparación con las copias recientes mostró que esos comandos ya faltaban antes del último ajuste de pausas.
- Se recuperó el bloque funcional completo desde la versión original de Map053 guardada en Git.
- Se restauraron `renderBadgeAnimation(0)` y `pbGetBadge(:MEDALLACEFIRO)`.
- Se restauró el sonido de obtención y la rama controlada por el interruptor 409: `getItemRandomMTFromPokeball()` en el modo correspondiente y `pbItemBall(:TM51)` en el modo normal.
- Las recompensas vuelven a ejecutarse entre los diálogos de entrega. Se mantienen los textos nuevos, las pausas y la ocultación de retratos.
- El combate, las reglas especiales, los interruptores 60 y 61, el interruptor de progresión y la variable 26 permanecen intactos.
