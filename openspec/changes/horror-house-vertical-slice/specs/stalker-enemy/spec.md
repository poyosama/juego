# Spec Delta

## Purpose

Define a "la cosa" que habita la casa: cómo patrulla, cómo detecta al jugador por vista y oído, cómo lo persigue y qué pasa cuando lo atrapa.

## ADDED Requirements

### Requirement: Patrol
Cuando no detecta al jugador, el enemigo SHALL recorrer puntos de patrulla de la casa en ambos pisos, caminando despacio.

#### Scenario: Idle patrol
- **WHEN** el enemigo no tiene pistas del jugador
- **THEN** camina hacia el siguiente punto de patrulla, espera un momento y sigue

### Requirement: Hearing
El enemigo SHALL oír los ruidos del jugador dentro de un radio que depende del ruido: correr se oye lejos, caminar menos y agachado casi nada. Al oír, MUST investigar el lugar del ruido.

#### Scenario: Hears sprinting
- **WHEN** el jugador corre a menos de 12 metros
- **THEN** el enemigo va a investigar ese lugar

#### Scenario: Crouching is quiet
- **WHEN** el jugador camina agachado a más de 2 metros
- **THEN** el enemigo no lo oye

### Requirement: Sight
El enemigo SHALL ver al jugador si está dentro de su cono de visión, a una distancia razonable, sin paredes entre ellos y sin estar escondido. Si lo ve, MUST perseguirlo.

#### Scenario: Spotted
- **WHEN** el jugador está frente al enemigo, sin obstáculos y a menos de 14 metros
- **THEN** el enemigo pasa a perseguirlo y suena un golpe de tensión

#### Scenario: Behind a wall
- **WHEN** hay una pared entre el enemigo y el jugador
- **THEN** el enemigo no lo ve

### Requirement: Chase and lose track
Al perseguir, el enemigo SHALL moverse más rápido que la caminata del jugador pero más lento que su carrera. Si deja de verlo varios segundos, MUST ir a su última posición conocida, buscar y volver a patrullar.

#### Scenario: Lose the player
- **WHEN** el enemigo deja de ver al jugador por más de 4 segundos
- **THEN** va a la última posición conocida, busca un rato y vuelve a patrullar

### Requirement: Player death
Si el enemigo alcanza al jugador, el jugador SHALL morir con un susto en pantalla y MUST reaparecer en el último punto guardado.

#### Scenario: Caught
- **WHEN** el enemigo llega a menos de 1,2 metros del jugador que no está escondido
- **THEN** se muestra la pantalla de muerte y luego se recarga el último guardado

### Requirement: Presence feedback
Cuando el enemigo está cerca, el jugador SHALL notarlo por sonido (respiración/gruñido y latidos) y por más distorsión del filtro VHS.

#### Scenario: Enemy nearby
- **WHEN** el enemigo está a menos de 8 metros
- **THEN** aumentan los latidos y la distorsión de la imagen
