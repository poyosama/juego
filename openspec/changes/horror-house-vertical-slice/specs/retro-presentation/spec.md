# Spec Delta

## Purpose

Da al juego una estética de juego de PS2 grabado en VHS: imagen a baja resolución, niebla, colores lavados y artefactos de cinta, con un brillo que el jugador puede ajustar.

## ADDED Requirements

### Requirement: Low-resolution rendering
El mundo 3D SHALL renderizarse a una resolución interna baja (unos 480x270) y escalarse a la ventana sin suavizado, para que los píxeles se vean nítidos.

#### Scenario: Pixelated output
- **WHEN** el juego corre en una ventana de 1280x720 o más
- **THEN** la imagen 3D se ve pixelada sin bordes borrosos

### Requirement: VHS screen filter
La imagen final SHALL pasar por un filtro VHS con scanlines, ruido, aberración cromática, una línea de tracking que se desplaza y viñeta.

#### Scenario: Filter visible during play
- **WHEN** el jugador está jugando
- **THEN** se ven scanlines, grano animado y separación de color en los bordes

### Requirement: VHS overlay HUD
La pantalla de juego SHALL mostrar un texto tipo VHS ("PLAY ▶") y un contador de tiempo de cinta en una esquina.

#### Scenario: Overlay during play
- **WHEN** empieza una partida
- **THEN** aparece "PLAY ▶" y un contador de tiempo que avanza

### Requirement: Atmospheric fog
Los espacios SHALL tener niebla oscura que limite la visión a distancia.

#### Scenario: Distant objects fade
- **WHEN** un objeto está a más de unos 15 metros
- **THEN** se funde con la oscuridad

### Requirement: Adjustable brightness
El jugador SHALL poder ajustar el brillo desde opciones y el cambio MUST aplicarse de inmediato y guardarse.

#### Scenario: Change brightness
- **WHEN** el jugador mueve el control de brillo
- **THEN** la imagen se aclara u oscurece al instante y el valor se conserva al reiniciar el juego
