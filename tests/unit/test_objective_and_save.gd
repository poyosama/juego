extends "res://tests/test_case.gd"

const ObjectiveScript = preload("res://scripts/core/objective.gd")
const SaveDataScript = preload("res://scripts/core/save_data.gd")


func test_objective_progression() -> void:
	var obj = ObjectiveScript.new()
	assert_eq(obj.collected_fuses, 0)
	assert_false(obj.is_power_restored)
	assert_false(obj.can_escape())

	obj.add_fuse("fuse_1")
	assert_eq(obj.collected_fuses, 1)
	assert_false(obj.can_escape())

	# Agregar hasta 5
	obj.add_fuse("fuse_2")
	obj.add_fuse("fuse_3")
	obj.add_fuse("fuse_4")
	obj.add_fuse("fuse_5")
	assert_eq(obj.collected_fuses, 5)

	obj.restore_power()
	assert_true(obj.is_power_restored)
	assert_true(obj.can_escape(), "con 5 fusibles y energia restaurada puede escapar")

	obj.escape()
	assert_true(obj.is_escaped)


func test_save_data_roundtrip() -> void:
	var save = SaveDataScript.new()
	save.player_position = Vector3(1.2, 3.4, 5.6)
	save.player_rotation_y = 1.57
	save.keys = ["llave_sotano", "llave_principal"]
	save.fuses = ["fuse_1", "fuse_2"]
	save.unlocked_doors = ["door_basement"]
	save.triggered_scares = ["scare_hall_light"]
	save.power_restored = false

	var dict = save.to_dict()
	var loaded = SaveDataScript.from_dict(dict)

	assert_almost(loaded.player_position.x, 1.2, 0.01)
	assert_almost(loaded.player_position.y, 3.4, 0.01)
	assert_almost(loaded.player_position.z, 5.6, 0.01)
	assert_eq(loaded.keys.size(), 2)
	assert_true(loaded.keys.has("llave_sotano"))
	assert_eq(loaded.fuses.size(), 2)
	assert_true(loaded.unlocked_doors.has("door_basement"))
	assert_true(loaded.triggered_scares.has("scare_hall_light"))
	assert_false(loaded.power_restored)
