# Pueblo Azalea: César e inicio de la invasión Rocket

## Mapas y eventos revisados

- Map149, evento 8: presentación de César, llegada de su nieta, revelación del ataque y salida hacia el Pozo Slowpoke.
- Map149, evento 4: diálogo de la nieta después de que César se marcha.
- Map010, evento 26: primer encuentro con el recluta que bloquea el pozo y diálogo al insistir.
- Map010, eventos 33, 34 y 37: César, recluta Rocket y confrontación automática frente al pozo.

## Información narrativa

- César reconoce la Pokédex entregada por Oak, se presenta como viejo amigo del profesor y explica brevemente que fabrica Poké Balls artesanales en Pueblo Azalea.
- La nieta irrumpe para informar de que el Team Rocket ha ocupado el Pozo Slowpoke, ha acorralado a los Slowpoke y pretende cortar sus colas para venderlas.
- Antón ya ha entrado solo en el pozo para detenerlos.
- César recuerda que Red derrotó al Team Rocket tres años atrás y comprende que la organización ha vuelto a comerciar con Pokémon.
- Aunque su nieta le recuerda sus problemas de espalda, César sale para ayudar a Antón y pide al protagonista que acuda al pozo si decide colaborar.
- Frente al pozo, César mantiene ocupado a un recluta mientras el protagonista entra en busca de Antón.

## Implementación conservada

- Se mantuvieron todas las rutas de movimiento del jugador, César, su nieta y el recluta Rocket.
- Se conservaron los sonidos de entrada y salida, la música de peligro y la música de Pueblo Azalea.
- Se conservaron `FollowingPkmn.toggle_off` y `FollowingPkmn.toggle_on`.
- El interruptor 953 sigue activando la entrada de la nieta.
- El interruptor 952 sigue activando la invasión exterior: César, recluta, Slowpoke, Koffing, música de peligro y desbloqueo de la entrada al pozo.
- Los interruptores 954 y 955 siguen controlando al recluta que bloquea inicialmente el pozo.
- El interruptor 944 continúa marcando la finalización de la trama del Pozo Slowpoke.
- No se modificó la escena posterior de recompensa de César: mantiene las diez Quick Balls y sus diálogos posteriores.

## Ritmo visual

- Los retratos desaparecen antes de cada pausa y antes de cualquier movimiento.
- La confrontación exterior alterna correctamente los retratos de César y del recluta Rocket.
