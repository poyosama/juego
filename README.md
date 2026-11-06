# Juego de Terror 3D (VHS / PS2) 🎮

Juego de terror en primera persona ambientado en una casa de 2 pisos, estilo *Amnesia* con estética retro VHS y gráficos PS2. Desarrollado en **Godot 4.3+** por poyosama y Santiago (Santiago-btto).

## Características principales
- **Perspectiva en primera persona:** movimiento con paso, carrera con resistencia y linterna.
- **Atmósfera retro:** render de baja resolución con filtro de pantalla VHS (scanlines, tracking, aberración cromática).
- **Casa de 2 pisos:** exploración, puertas con llaves, escondites (armarios/camas) y mensajes de voz en contestadores.
- **Enemigo acechador:** inteligencia artificial que patrulla, oye pasos/carreras y persigue.
- **Objetivo:** encontrar los 5 fusibles para restablecer la energía de la puerta principal y escapar.

## Controles
- **W, A, S, D:** Moverse
- **Mouse:** Mirar / apuntar
- **Shift:** Correr (consume resistencia)
- **Ctrl / C:** Agacharse (más sigiloso)
- **F:** Encender / apagar linterna
- **E:** Interactuar (puertas, llaves, fusibles, contestadores, escondites)
- **Escape:** Menú de pausa

## Cómo abrirlo y jugar
1. Abrí Godot (versión 4.3 o superior, compatible con versión Steam 4.7+).
2. Importá el archivo `project.godot`.
3. Presioná **F5** para ejecutar.

## Ejecución de Tests (TDD)
El proyecto incluye un runner de tests headless que no requiere abrir el editor gráfico:
```powershell
.\run_tests.ps1
```
O directamente con Godot:
```powershell
godot --headless --path . -s res://tests/run_tests.gd
```

## Estructura del Proyecto
```
scenes/        # Escenas (.tscn): menús, jugador, casa, objetos, enemigo
scripts/       # Lógica en GDScript (.gd)
  autoload/    # Singletons: Game, Settings, SoundBank
  core/        # Lógica pura desacoplada: Stamina, Inventory, Objective, EnemyBrain, etc.
  synth/       # Generador procedural de audio (ToneSynth)
  ui/          # Controladores de interfaz y HUD
shaders/       # Shaders de post-procesado (vhs.gdshader)
tests/         # Runner de testing y tests unitarios (tests/unit/)
openspec/      # Especificaciones, propuestas y tareas (OpenSpec)
```
