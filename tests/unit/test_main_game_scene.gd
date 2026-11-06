extends "res://tests/test_case.gd"


func test_main_game_scene_instantiation() -> void:
	var scene: PackedScene = load("res://scenes/main_game.tscn")
	assert_true(scene != null, "main_game.tscn debe existir")

	var game = scene.instantiate()
	assert_true(game != null)

	var tree := Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		tree.root.add_child(game)
	else:
		game._ready()

	assert_true(game.objective != null, "debe inicializar objective")
	assert_true(game.get_node_or_null("SubViewportContainer/SubViewport/HouseBuilder") != null, "debe instanciar house_builder")
	assert_true(game.get_node_or_null("SubViewportContainer/SubViewport/Player") != null, "debe instanciar player")
	assert_true(game.get_node_or_null("SubViewportContainer/SubViewport/Enemy") != null, "debe instanciar enemy")
	assert_true(game.get_node_or_null("PauseMenu") != null, "debe instanciar pause_menu")

	# Simular actualización de HUD
	game.objective.add_fuse("fuse_1")
	var lbl_fuses: Label = game.get_node_or_null("HUD/LblFuses")
	if lbl_fuses:
		game.lbl_fuses = lbl_fuses
		game._update_hud()
		assert_eq(lbl_fuses.text, "Fusibles: 1 / 5")

	if game.is_inside_tree():
		game.get_parent().remove_child(game)
	game.free()
