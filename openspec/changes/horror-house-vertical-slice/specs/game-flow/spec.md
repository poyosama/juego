# Spec Delta

## Purpose

Define el ciclo completo de una partida: menú, objetivo de juntar fusibles y escapar, puntos de guardado, guardar y cargar, pausa, opciones, final y créditos.

## ADDED Requirements

### Requirement: Main menu
Al iniciar, el juego SHALL mostrar un menú principal con Nueva partida, Continuar (solo si hay guardado), Opciones y Salir.

#### Scenario: No save present
- **WHEN** no existe una partida guardada
- **THEN** la opción Continuar está deshabilitada

#### Scenario: Continue
- **WHEN** existe un guardado y el jugador elige Continuar
- **THEN** la partida se carga en el último punto guardado

### Requirement: Fuse objective
El jugador SHALL juntar 5 fusibles repartidos por la casa; el HUD MUST mostrar cuántos lleva.

#### Scenario: Collect fuse
- **WHEN** el jugador recoge un fusible
- **THEN** el contador sube (por ejemplo "Fusibles 3/5")

### Requirement: Escape
La puerta principal SHALL abrirse solo cuando estén colocados los 5 fusibles en la caja de luz; al cruzarla, el jugador escapa y termina la partida.

#### Scenario: Missing fuses
- **WHEN** el jugador interactúa con la caja de fusibles con menos de 5
- **THEN** aparece cuántos faltan

#### Scenario: Escape the house
- **WHEN** la energía está restaurada y el jugador sale por la puerta principal
- **THEN** se muestra la pantalla de final y después los créditos

### Requirement: Checkpoints and save
El juego SHALL guardar automáticamente al recoger un fusible o una llave y al usar un contestador. El guardado MUST incluir la posición del jugador, el inventario, los fusibles, las puertas desbloqueadas y los sustos ya disparados.

#### Scenario: Autosave on pickup
- **WHEN** el jugador recoge un fusible
- **THEN** se guarda la partida y aparece un indicador breve de guardado

#### Scenario: Load restores state
- **WHEN** se carga una partida guardada
- **THEN** los objetos ya recogidos no aparecen, las puertas desbloqueadas siguen desbloqueadas y el jugador está en el punto guardado

### Requirement: Pause menu
Con Escape, el juego SHALL pausarse y mostrar Continuar, Opciones y Salir al menú.

#### Scenario: Pause
- **WHEN** el jugador presiona Escape durante la partida
- **THEN** el juego se detiene y aparece el menú de pausa con el cursor visible

### Requirement: Options persistence
Las opciones (volúmenes, brillo, sensibilidad del mouse, pantalla completa) SHALL guardarse en disco y aplicarse al iniciar.

#### Scenario: Restart keeps settings
- **WHEN** el jugador cambia la sensibilidad y reinicia el juego
- **THEN** la sensibilidad sigue siendo la elegida

### Requirement: Ending and credits
Al escapar, el juego SHALL mostrar un texto de final y luego créditos que suben, y MUST volver al menú principal al terminar o al presionar Escape. El guardado en curso se borra al terminar.

#### Scenario: Credits finish
- **WHEN** terminan los créditos o el jugador presiona Escape
- **THEN** vuelve al menú principal y Continuar queda deshabilitado
