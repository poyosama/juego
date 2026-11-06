# Spec Delta

## Purpose

Crea la tensión del juego con sonido y eventos: ambiente constante, pasos, sustos que se disparan por zonas y mensajes de voz que cuentan la historia sin usar notas escritas.

## ADDED Requirements

### Requirement: Ambient soundscape
Durante la partida SHALL sonar en loop un ambiente grave (zumbido y ruido de cinta).

#### Scenario: Ambient plays
- **WHEN** empieza la partida
- **THEN** se escucha el ambiente en loop, con el volumen definido en opciones

### Requirement: Footsteps
Los pasos del jugador SHALL sonar con un ritmo que depende de la velocidad: más rápido al correr y más suave al agacharse.

#### Scenario: Sprint footsteps
- **WHEN** el jugador corre
- **THEN** los pasos suenan más seguidos y más fuertes que al caminar

### Requirement: Scare triggers
Las zonas de susto SHALL dispararse una sola vez cuando el jugador entra en ellas y ejecutar un evento: ruido, luz que titila u objeto que cae.

#### Scenario: One-shot scare
- **WHEN** el jugador entra en una zona de susto por primera vez
- **THEN** ocurre el evento; al volver a entrar, no ocurre otra vez

### Requirement: Voice messages
Los contestadores y radios SHALL reproducir un mensaje de voz con subtítulos al interactuar; si el mensaje todavía no tiene audio grabado, MUST mostrar los subtítulos igual con un sonido de cinta.

#### Scenario: Play answering machine
- **WHEN** el jugador interactúa con un contestador
- **THEN** suena un bip, se reproduce el mensaje y aparecen los subtítulos línea por línea

#### Scenario: Message replay
- **WHEN** el jugador interactúa de nuevo con un contestador ya escuchado
- **THEN** el mensaje se puede escuchar otra vez

### Requirement: Volume settings
El volumen general, de música/ambiente y de efectos SHALL poder ajustarse desde opciones.

#### Scenario: Mute effects
- **WHEN** el jugador baja el volumen de efectos a cero
- **THEN** dejan de escucharse los pasos y efectos, pero no el ambiente
