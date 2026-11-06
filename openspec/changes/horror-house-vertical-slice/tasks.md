# Tasks

## 1. Base del proyecto y tests

- [x] 1.1 Crear el runner `tests/run_tests.gd` y un test de ejemplo; verificar que `godot --headless --path . -s res://tests/run_tests.gd` sale con código 0, y con código 1 cuando un test falla
- [x] 1.2 Configurar `project.godot` (escena principal = menú, autoloads `Settings`/`SoundBank`/`Game`, acciones de input WASD/Shift/Ctrl/F/E/Esc, capas de física) y verificar que el proyecto carga headless sin errores
- [x] 1.3 Documentar en el README cómo correr los tests y la estructura nueva

## 2. Jugador (player-controller)

- [x] 2.1 `Stamina` (gasto, agotamiento con umbral del 30%, demora y recuperación); verificar con tests unitarios
- [x] 2.2 Escena `Player` (`CharacterBody3D`, cámara, mouse look con límite de ±85°, caminar, correr, agacharse, bob de cámara) usando `Stamina`; verificar cargando la escena headless
- [x] 2.3 Linterna `SpotLight3D` con F y sonido de click, sin batería; verificar en la escena de juego

## 3. Presentación retro (retro-presentation)

- [x] 3.1 Shader `vhs.gdshader` (scanlines, ruido, aberración, tracking, viñeta, distorsión, brillo); verificar que compila al cargar la escena headless
- [x] 3.2 Pipeline `SubViewport` de 480x270 con filtro nearest y overlay "PLAY ▶" con contador; verificar visualmente al correr el juego
- [x] 3.3 `Environment` con niebla, ambiente bajo y materiales retro (texturas de ruido nearest); verificar visualmente

## 4. Casa e interacción (house-interaction)

- [ ] 4.1 `HouseLayout` (datos de dos pisos, puertas, llaves, fusibles, escondites, contestadores, sustos, patrulla) con tests de consistencia (ids únicos, cada puerta bloqueada tiene su llave alcanzable, 5 fusibles)
- [ ] 4.2 `HouseBuilder` que genera paredes, pisos, techos, escalera, muebles simples y navmesh; verificar cargando el nivel headless
- [ ] 4.3 `Inventory` (agregar, tener y listar llaves, serializar); verificar con tests unitarios
- [ ] 4.4 Raycast de interacción, texto de acción y nodos `Door` (bisagra animada, bloqueada con llave), `Pickup` (llave/fusible) y `HidingSpot`; verificar con tests de la lógica de bloqueo y jugando

## 5. Atmósfera y audio (horror-atmosphere)

- [ ] 5.1 `ToneSynth` (genera WAV: pasos, click, puerta, traba, bip, golpe, latido, gruñido, ambiente en loop, siseo); verificar con tests de longitud, formato y loop
- [ ] 5.2 `SoundBank` y buses Master/Music/SFX; ambiente en loop y pasos según la velocidad; verificar jugando
- [ ] 5.3 `ScareTrigger` de un solo uso (ruido, luz que titila, objeto que cae) con estado guardable; verificar con test de "una sola vez" y jugando
- [ ] 5.4 `AnswerMachine` con subtítulos por tiempo y audio opcional, más 3 mensajes de historia; verificar con test del avance de subtítulos

## 6. Enemigo (stalker-enemy)

- [ ] 6.1 `EnemyBrain` (máquina de estados patrullar/investigar/perseguir/buscar/matar, radios de oído por ruido, escondite); verificar con tests de cada transición de la spec
- [ ] 6.2 Nodo `Enemy` (cuerpo low-poly con ojos, `NavigationAgent3D`, cono de visión con raycast, velocidades, sonidos); verificar jugando
- [ ] 6.3 Feedback de cercanía (latidos y distorsión VHS) y muerte con susto en pantalla y recarga; verificar jugando

## 7. Flujo de juego (game-flow)

- [ ] 7.1 `Objective` (fusibles 0..5, energía restaurada, salida habilitada); verificar con tests unitarios
- [ ] 7.2 `SaveData` (serializar y deserializar posición, inventario, fusibles, puertas, recogidos, sustos) y `Game` (autoguardado, cargar, borrar); verificar con test de ida y vuelta
- [ ] 7.3 `Settings` (volúmenes, brillo, sensibilidad, pantalla completa; persistencia en ConfigFile); verificar con test de ida y vuelta
- [ ] 7.4 Menú principal (Continuar deshabilitado sin guardado), pausa y opciones; verificar jugando
- [ ] 7.5 Caja de fusibles, puerta principal, zona de escape, pantalla de final y créditos que vuelven al menú y borran el guardado; verificar jugando
- [ ] 7.6 HUD (texto de acción, barra de resistencia, fusibles, llaves, aviso de guardado, subtítulos); verificar jugando

## 8. Integración

- [ ] 8.1 Correr toda la suite de tests y una carga headless de cada escena sin errores ni warnings de script
- [ ] 8.2 Commit y push a `origin/main` con la identidad Santiago-btto

## Workflow follow-up

- Que el equipo juegue la partida completa y haga ajustes.
- Archivar el cambio con `/opsx:archive` cuando el equipo apruebe.
