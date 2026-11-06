extends "res://tests/test_case.gd"

const DoorScript = preload("res://scripts/world/door.gd")
const InventoryScript = preload("res://scripts/core/inventory.gd")


func test_door_unlocked_toggle() -> void:
	var door = DoorScript.new()
	door.door_id = "test_door"
	door.door_name = "Cocina"
	door.is_locked = false
	door._ready()

	assert_eq(door.get_prompt(), "[E] Abrir Cocina")
	assert_false(door.is_open)

	door.interact(null)
	assert_true(door.is_open)
	assert_eq(door.get_prompt(), "[E] Cerrar Cocina")

	door.interact(null)
	assert_false(door.is_open)
	assert_eq(door.get_prompt(), "[E] Abrir Cocina")
	door.free()


func test_door_locked_requires_key() -> void:
	var door = DoorScript.new()
	door.door_id = "test_locked_door"
	door.door_name = "Sótano"
	door.is_locked = true
	door.required_key = "llave_sotano"
	door._ready()

	assert_eq(door.get_prompt(), "Está cerrada con llave")

	# Mock player con la llave en metadata
	var player_mock = Node.new()
	var inv = InventoryScript.new()
	player_mock.set_meta("inventory", inv)

	door.interact(player_mock)
	assert_true(door.is_locked, "sin llave debe seguir bloqueada")
	assert_false(door.is_open)

	# Darle la llave
	inv.add_key("llave_sotano")
	door.interact(player_mock)
	assert_false(door.is_locked, "con la llave debe desbloquearse")
	assert_true(door.is_open, "y debe abrirse")

	door.free()
	player_mock.free()
