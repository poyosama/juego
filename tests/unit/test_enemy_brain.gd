extends "res://tests/test_case.gd"

const EnemyBrainScript = preload("res://scripts/core/enemy_brain.gd")


func test_enemy_brain_patrol_to_chase() -> void:
	var brain = EnemyBrainScript.new()
	assert_eq(brain.state, EnemyBrainScript.State.PATROL)

	# El jugador está a la vista, a 8 metros, no escondido
	brain.update_perception(
		true, # saw_player
		Vector3(0, 0, 8), # player_pos
		false, # player_hidden
		0.0, # noise_level
		Vector3.ZERO, # noise_pos
		1.0 # delta
	)

	assert_eq(brain.state, EnemyBrainScript.State.CHASE, "al ver al jugador debe pasar a CHASE")
	assert_eq(brain.target_position, Vector3(0, 0, 8))


func test_enemy_brain_hearing_noise() -> void:
	var brain = EnemyBrainScript.new()
	assert_eq(brain.state, EnemyBrainScript.State.PATROL)

	# Ruido de carrera (nivel 2.0) a 9 metros (dentro de rango de oído de 12m)
	brain.current_position = Vector3.ZERO
	brain.update_perception(
		false, # saw_player
		Vector3(0, 0, 20),
		false,
		2.0, # noise sprint
		Vector3(0, 0, 9),
		0.1
	)

	assert_eq(brain.state, EnemyBrainScript.State.INVESTIGATE, "ruido fuerte debe pasar a INVESTIGATE")
	assert_eq(brain.target_position, Vector3(0, 0, 9))


func test_enemy_brain_chase_to_search_and_patrol() -> void:
	var brain = EnemyBrainScript.new()
	brain.state = EnemyBrainScript.State.CHASE
	brain.target_position = Vector3(0, 0, 5)

	# Pierde de vista al jugador durante 4.1 segundos
	brain.update_perception(false, Vector3(0, 0, 10), false, 0.0, Vector3.ZERO, 4.2)
	assert_eq(brain.state, EnemyBrainScript.State.SEARCH, "tras 4s sin ver al jugador pasa a SEARCH")

	# Pasan 5 segundos buscando sin pistas
	brain.update_perception(false, Vector3(0, 0, 10), false, 0.0, Vector3.ZERO, 5.2)
	assert_eq(brain.state, EnemyBrainScript.State.PATROL, "tras buscar pasa a PATROL")


func test_enemy_brain_kill_distance() -> void:
	var brain = EnemyBrainScript.new()
	brain.current_position = Vector3.ZERO

	# Jugador a 1 metro (menor a 1.2m) visible
	brain.update_perception(true, Vector3(0, 0, 1.0), false, 0.0, Vector3.ZERO, 0.1)
	assert_eq(brain.state, EnemyBrainScript.State.KILL, "a menos de 1.2m pasa a KILL")
