# Proposal

## Why

El repositorio es solo la plantilla vacía de Godot. Queremos un juego de terror en primera persona estilo *Amnesia*, pero con gráficos simples (estética PS2 filmada en VHS), ambientado en una casa de dos pisos con algo que persigue al jugador. Este cambio construye el primer "vertical slice" jugable de punta a punta (menú → partida → final), para después iterar sobre contenido y, más adelante, integrar Steam.

## What Changes

- Reemplazar la escena 2D de ejemplo por una escena 3D en primera persona.
- Jugador con `CharacterBody3D`: caminar, agacharse, correr limitado por resistencia y linterna (`SpotLight3D`) sin batería.
- Presentación retro: render a baja resolución con filtro *nearest*, niebla, texturas simples y un filtro VHS de pantalla completa (scanlines, ruido, aberración cromática, línea de tracking, viñeta, HUD tipo "PLAY").
- Casa de dos pisos con escalera, habitaciones, puertas que se abren y puertas bloqueadas que piden una llave.
- Sistema de interacción (tecla E) e inventario de llaves.
- Sonido ambiente, pasos y efectos sintetizados por código (sin archivos de audio externos por ahora).
- Sustos disparados por zonas: ruidos, luces que titilan, objetos que caen.
- Enemigo con IA (patrulla, oye, ve, persigue, pierde el rastro) y escondites (armarios, debajo de la cama).
- Muerte y reaparición en el último punto guardado.
- Historia contada por contestadores automáticos / radios con mensajes de voz y subtítulos (en lugar de notas).
- Objetivo: juntar 5 fusibles, devolver la energía a la puerta principal y escapar.
- Menú principal, pausa, opciones (volumen, brillo, sensibilidad), guardado/carga, pantalla de final y créditos.
- Fuera de alcance: integración con Steam (etapa 6), assets definitivos (modelos y voces reales).

## Capabilities

### New Capabilities
- `player-controller`: movimiento en primera persona, resistencia para correr, agacharse y linterna.
- `retro-presentation`: estética PS2 + VHS (baja resolución, niebla, filtro de pantalla, brillo configurable).
- `house-interaction`: interacción con objetos, puertas, llaves, puertas bloqueadas y escondites.
- `horror-atmosphere`: audio ambiente, pasos, sustos por zonas y mensajes de voz con subtítulos.
- `stalker-enemy`: comportamiento del enemigo que persigue al jugador y la muerte del jugador.
- `game-flow`: objetivo de fusibles y escape, puntos de guardado, guardar y cargar, menús, opciones, final y créditos.

### Modified Capabilities
<!-- Ninguna: no hay specs existentes. -->

## Impact

- Se reemplazan `scenes/main.tscn` y `scripts/main.gd`; se agregan carpetas `scenes/`, `scripts/`, `shaders/` y `tests/`.
- `project.godot`: escena principal, autoloads, acciones de input y ajustes de render.
- Sin dependencias externas. Los tests corren con Godot en modo headless y un runner propio en GDScript.
