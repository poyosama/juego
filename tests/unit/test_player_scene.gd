extends "res://tests/test_case.gd"


func test_player_instantiation_and_nodes() -> void:
	var scene: PackedScene = load("res://scenes/player/player.tscn")
	assert_true(scene != null, "la escena player.tscn debe existir")

	var player = scene.instantiate()
	assert_true(player != null, "player debe poder instanciarse")
	assert_true(player is CharacterBody3D, "debe ser CharacterBody3D")

	# Simular ready
	player._ready()
	assert_true(player.stamina != null, "debe instanciar stamina")
	assert_true(player.flashlight != null, "debe tener linterna")
	assert_true(player.flashlight.visible, "linterna debe arrancar encendida")

	# Test toggle flashlight
	player.toggle_flashlight()
	assert_false(player.flashlight.visible, "tras toggle debe apagarse")
	player.toggle_flashlight()
	assert_true(player.flashlight.visible, "tras toggle debe encenderse")

	# Test hiding logic
	player.enter_hiding(null)
	assert_true(player.is_hidden, "debe quedar escondido")
	assert_false(player.flashlight.visible, "debe apagar linterna al esconderse")
	player.exit_hiding()
	assert_false(player.is_hidden, "debe salir de esconderse")

	player.queue_free()
