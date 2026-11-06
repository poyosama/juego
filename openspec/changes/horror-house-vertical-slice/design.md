# Design

## Context

- Hoy el proyecto es la plantilla de Godot (`config/features` 4.3, Forward Plus). El equipo usa **Godot 4.7.2 de Steam**; el código se limita a APIs presentes desde 4.3 para que abra en ambas versiones.
- Todavía no hay assets (ni modelos, ni texturas, ni audio). El equipo vibecodea: lo que se genere tiene que entenderse y modificarse fácil.
- Referencia visual del usuario: interior de casa estilo PS2 filmado en VHS, con colores lavados violáceos, aberración cromática y baja resolución.
- Strict TDD: hay que poder testear la lógica sin abrir el editor.

## Goals / Non-Goals

**Goals:**
- Un vertical slice jugable de 10 a 20 minutos, de punta a punta, sin assets externos.
- Lógica de juego (resistencia, inventario, objetivo, IA, guardado, opciones, sonido sintetizado) en clases puras y testeables.
- Un nivel fácil de editar: la casa se describe con datos y se construye por código.

**Non-Goals:**
- Steam, logros y nube (etapa 6).
- Modelos, texturas y voces finales: todo es placeholder, pensado para reemplazarse.
- Localización y soporte de joystick.

## Decisions

1. **Lógica pura y nodos aparte.** Clases `RefCounted` con `class_name` (`Stamina`, `Inventory`, `Objective`, `EnemyBrain`, `SaveData`, `Settings`, `ToneSynth`, `HouseLayout`) contienen las reglas. Los nodos (`Player`, `Enemy`, `Door`, etc.) solo las conectan con la física, el input y el audio. *Alternativa:* todo dentro de los nodos. Se descarta porque no se puede testear headless.

2. **Tests con un runner propio.** `tests/run_tests.gd` extiende `SceneTree`, busca `tests/unit/test_*.gd`, ejecuta los métodos `test_*` y sale con código 1 si alguno falla. Comando: `godot --headless --path . -s res://tests/run_tests.gd`. *Alternativa:* el addon GUT. Se descarta para no sumar una dependencia; se puede migrar más adelante.

3. **Casa generada por código a partir de datos.** `HouseLayout` describe pisos, paredes (segmentos con huecos para puertas), escalera, puertas, llaves, fusibles, escondites, contestadores, zonas de susto y puntos de patrulla. `HouseBuilder` genera `StaticBody3D` y `MeshInstance3D` con `BoxMesh` y materiales simples. *Alternativa:* `.tscn` armados a mano. Se descarta porque son frágiles de escribir sin el editor y más difíciles de iterar. El equipo puede seguir agregando props a mano en el editor encima.

4. **Navegación horneada en runtime.** Un `NavigationRegion3D` hornea el navmesh desde la geometría generada al cargar el nivel (`bake_navigation_mesh(false)`). El enemigo usa `NavigationAgent3D`.

5. **Pipeline retro.** El mundo se renderiza en un `SubViewport` de 480x270 con `Viewport.SCALING_3D_MODE_BILINEAR` desactivado, mostrado en un `TextureRect` con filtro *nearest*. Encima va un `ColorRect` con `shaders/vhs.gdshader`. Sus uniforms: `aberration`, `noise_amount`, `distortion` (sube cuando el enemigo está cerca), `brightness`. Para el look PS2 se usan texturas de ruido de baja resolución con filtro *nearest*, una paleta lavada y `Environment` con niebla y luz ambiente baja.

6. **Audio sintetizado.** `ToneSynth` genera `AudioStreamWAV` de 16 bits en memoria: pasos, click, puerta, traba, bip, golpe de tensión, latido, gruñido, ambiente en loop y siseo de cinta. Hay buses `Master`, `Music` y `SFX`, creados por código si no existen. Sirve de placeholder: cada sonido se reemplaza asignando un archivo en `SoundBank`.

7. **Autoloads.** `Game` (estado de partida, guardado y carga, cambio de escenas), `Settings` (persistencia en `user://settings.cfg`) y `SoundBank` (caché de sonidos sintetizados). El guardado se escribe en `user://save.json` como JSON.

8. **Interacción por raycast.** `RayCast3D` en la cámara, de 2,5 m, en la capa de colisión 3 ("interactable"). Todo interactuable implementa `get_prompt() -> String` e `interact(player)`.

9. **IA como máquina de estados pura.** `EnemyBrain` tiene los estados `PATROL`, `INVESTIGATE`, `CHASE`, `SEARCH` y `KILL`. Recibe percepciones (`saw_player`, `heard_at`, `distance`, `player_hidden`, `saw_hide`, delta) y devuelve el estado y el objetivo. El nodo `Enemy` calcula la visión (cono + raycast) y el ruido según el estado de movimiento del jugador.

10. **Mensajes de voz.** Cada `AnswerMachine` tiene un `id`, líneas de subtítulos con su duración y un `AudioStream` opcional. Sin audio, suena el siseo de cinta y los subtítulos avanzan por tiempo.

11. **Datos del objetivo.** 5 fusibles. La caja de fusibles está en el sótano o lavadero, tras una puerta bloqueada. La puerta principal se habilita cuando la caja recibe los 5. Al cruzar la zona exterior de salida se dispara el final.

## Risks / Trade-offs

- [Horneado del navmesh en runtime puede tardar o fallar con la escalera] → la escalera es una rampa con colisión simple y el horneado usa `agent_max_climb` y `agent_max_slope` altos. Si falla, el enemigo se limita a teletransportarse entre puntos de patrulla de cada piso.
- [Los sonidos sintetizados suenan "de juguete"] → son placeholders aislados en `SoundBank`, fáciles de reemplazar por archivos de freesound.org.
- [Geometría por código menos artesanal que el editor] → los datos son legibles y se pueden sumar props en el editor encima.
- [Diferencias entre 4.3 y 4.7] → solo APIs estables. Se valida corriendo los tests y una carga headless de la escena principal en 4.7.2.

## UI Mockups

Decision: no (project policy). El usuario eligió no usar sistema de diseño; la referencia visual es su imagen VHS/PS2.
