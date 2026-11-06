# Spec Delta

## Purpose

Define cómo el jugador interactúa con la casa de dos pisos: mirar y usar objetos, abrir puertas, juntar llaves, abrir puertas bloqueadas y esconderse.

## ADDED Requirements

### Requirement: Two-floor house
El nivel SHALL ser una casa con planta baja y primer piso conectados por una escalera transitable, con varias habitaciones por piso.

#### Scenario: Reaching the upper floor
- **WHEN** el jugador sube la escalera
- **THEN** llega al primer piso y puede recorrer sus habitaciones

### Requirement: Interaction prompt
Cuando el jugador mira un objeto interactuable a menos de 2,5 metros, el juego SHALL mostrar un texto indicando la acción y la tecla E MUST ejecutarla.

#### Scenario: Looking at a door
- **WHEN** el jugador apunta a una puerta cerrada cercana
- **THEN** aparece "[E] Abrir"

#### Scenario: Nothing in sight
- **WHEN** el jugador no apunta a ningún interactuable cercano
- **THEN** no aparece ningún texto de acción

### Requirement: Doors
Las puertas SHALL abrirse y cerrarse girando sobre su bisagra al interactuar, con sonido.

#### Scenario: Open and close
- **WHEN** el jugador interactúa con una puerta cerrada y desbloqueada
- **THEN** la puerta se abre; si interactúa de nuevo, se cierra

### Requirement: Keys inventory
Las llaves recogidas SHALL guardarse en un inventario con su nombre y verse en el HUD.

#### Scenario: Pick up a key
- **WHEN** el jugador interactúa con una llave
- **THEN** la llave desaparece del mundo, se agrega al inventario y se muestra un aviso con su nombre

### Requirement: Locked doors
Una puerta bloqueada SHALL abrirse solo si el jugador tiene la llave correspondiente; si no la tiene, MUST avisar qué falta.

#### Scenario: Without key
- **WHEN** el jugador interactúa con una puerta bloqueada sin la llave
- **THEN** la puerta no se abre, suena trabada y aparece "Está cerrada con llave"

#### Scenario: With key
- **WHEN** el jugador interactúa con la llave correcta en el inventario
- **THEN** la puerta se desbloquea de forma permanente y se abre

### Requirement: Hiding spots
El jugador SHALL poder esconderse en armarios y debajo de camas; mientras está escondido no puede moverse y el enemigo MUST NOT verlo salvo que lo haya visto entrar.

#### Scenario: Hide and exit
- **WHEN** el jugador interactúa con un armario
- **THEN** la cámara pasa adentro del armario; al interactuar de nuevo, sale

#### Scenario: Unseen while hidden
- **WHEN** el enemigo pasa cerca y no vio al jugador esconderse
- **THEN** el enemigo no lo detecta
