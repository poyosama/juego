# Spec Delta

## Purpose

Define cómo se mueve y percibe el jugador en primera persona: caminar, correr con resistencia limitada, agacharse, mirar con el mouse y usar la linterna.

## ADDED Requirements

### Requirement: First-person movement
El jugador SHALL moverse con WASD relativo a la dirección de la cámara y mirar con el mouse, con el giro vertical limitado para no dar la vuelta.

#### Scenario: Walking forward
- **WHEN** el jugador mantiene W
- **THEN** el personaje avanza en la dirección horizontal de la cámara a velocidad de caminata

#### Scenario: Vertical look clamp
- **WHEN** el jugador mueve el mouse muy arriba o muy abajo
- **THEN** la cámara se detiene cerca de los ±85 grados

### Requirement: Limited sprint
El jugador SHALL poder correr manteniendo Shift solo mientras tenga resistencia; la resistencia MUST bajar al correr y recuperarse tras un breve descanso.

#### Scenario: Stamina drains while sprinting
- **WHEN** el jugador corre en movimiento
- **THEN** la resistencia baja y la velocidad es mayor que al caminar

#### Scenario: Exhaustion
- **WHEN** la resistencia llega a cero
- **THEN** el jugador no puede volver a correr hasta recuperar al menos el 30%

#### Scenario: Recovery
- **WHEN** el jugador deja de correr
- **THEN** después de una pausa corta la resistencia se recupera gradualmente hasta el máximo

### Requirement: Crouch
El jugador SHALL poder agacharse con Ctrl o C, lo que reduce la altura de la cámara y la velocidad y hace menos ruido.

#### Scenario: Crouching
- **WHEN** el jugador mantiene la tecla de agacharse
- **THEN** la cámara baja y el personaje se mueve más lento y más silencioso

### Requirement: Flashlight
El jugador SHALL tener una linterna que se prende y apaga con F y no tiene límite de batería.

#### Scenario: Toggle flashlight
- **WHEN** el jugador presiona F
- **THEN** la linterna cambia de encendida a apagada o al revés, con un sonido de click

#### Scenario: No battery drain
- **WHEN** la linterna está encendida durante mucho tiempo
- **THEN** su intensidad no disminuye
