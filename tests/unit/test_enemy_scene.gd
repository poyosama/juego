extends "res://tests/test_case.gd"

const EnemyScript = preload("res://scripts/enemy/enemy.gd")


func test_enemy_scene_instantiation() -> void:
	var scene: PackedScene = load("res://scenes/enemy/enemy.tscn")
	assert_true(scene != null, "la escena enemy.tscn debe existir")

	var enemy = scene.instantiate()
	assert_true(enemy != null)
	assert_true(enemy is CharacterBody3D)

	# Agregar al root para que @onready inicialice
	var tree := Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		tree.root.add_child(enemy)

	assert_true(enemy.brain != null, "debe inicializar enemy.brain")

	var patrols: Array[Vector3] = [Vector3(0, 0, 0), Vector3(5, 0, 5)]
	enemy.setup(null, patrols)
	assert_eq(enemy.patrol_points.size(), 2)

	enemy.queue_free()
