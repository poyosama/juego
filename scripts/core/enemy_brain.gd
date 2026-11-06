class_name EnemyBrain
extends RefCounted
## Lógica pura desacoplada para la máquina de estados del enemigo acechador.

enum State {
	PATROL,
	INVESTIGATE,
	CHASE,
	SEARCH,
	KILL
}

var state: State = State.PATROL
var target_position: Vector3 = Vector3.ZERO
var current_position: Vector3 = Vector3.ZERO

# Rangos de audición según el nivel de ruido del jugador (0=nada, 0.2=agachado, 1.0=caminando, 2.0=corriendo)
var sprint_hear_radius: float = 12.0
var walk_hear_radius: float = 5.0
var crouch_hear_radius: float = 1.5

var kill_distance: float = 1.2
var max_vision_distance: float = 14.0

var _time_since_saw_player: float = 0.0
var _search_timer: float = 0.0


func update_perception(
	saw_player: bool,
	player_pos: Vector3,
	player_hidden: bool,
	noise_level: float,
	noise_pos: Vector3,
	delta: float
) -> void:
	var dist_to_player := current_position.distance_to(player_pos)

	# Si el jugador está escondido, el enemigo no puede verlo ni atraparlo
	if player_hidden:
		saw_player = false

	# 1. Chequeo de Muerte (KILL)
	if saw_player and dist_to_player <= kill_distance and not player_hidden:
		state = State.KILL
		target_position = player_pos
		return

	# 2. Transiciones desde CHASE
	if state == State.CHASE:
		if saw_player:
			_time_since_saw_player = 0.0
			target_position = player_pos
			if dist_to_player <= kill_distance and not player_hidden:
				state = State.KILL
		else:
			_time_since_saw_player += delta
			if _time_since_saw_player >= 4.0:
				state = State.SEARCH
				_search_timer = 0.0
		return

	# 3. Transición a CHASE si ve al jugador
	if saw_player and dist_to_player <= max_vision_distance and not player_hidden:
		state = State.CHASE
		target_position = player_pos
		_time_since_saw_player = 0.0
		return

	# 4. Transiciones desde SEARCH
	if state == State.SEARCH:
		_search_timer += delta
		if _search_timer >= 5.0:
			state = State.PATROL
		return

	# 5. Audición de ruidos (desde PATROL o SEARCH o INVESTIGATE)
	if noise_level > 0.0:
		var dist_to_noise := current_position.distance_to(noise_pos)
		var can_hear := false
		if noise_level >= 1.8 and dist_to_noise <= sprint_hear_radius:
			can_hear = true
		elif noise_level >= 0.8 and dist_to_noise <= walk_hear_radius:
			can_hear = true
		elif noise_level >= 0.1 and dist_to_noise <= crouch_hear_radius:
			can_hear = true

		if can_hear:
			state = State.INVESTIGATE
			target_position = noise_pos
