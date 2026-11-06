extends "res://tests/test_case.gd"

const Inventory = preload("res://scripts/core/inventory.gd")


func test_inventory_keys() -> void:
	var inv = Inventory.new()
	assert_false(inv.has_key("llave_sotano"))
	assert_eq(inv.get_keys().size(), 0)

	inv.add_key("llave_sotano")
	assert_true(inv.has_key("llave_sotano"))
	assert_eq(inv.get_keys().size(), 1)

	# No duplicar la misma llave
	inv.add_key("llave_sotano")
	assert_eq(inv.get_keys().size(), 1)

	inv.add_key("llave_segundo_piso")
	assert_true(inv.has_key("llave_segundo_piso"))
	assert_eq(inv.get_keys().size(), 2)


func test_inventory_serialization() -> void:
	var inv = Inventory.new()
	inv.add_key("llave_1")
	inv.add_key("llave_2")

	var data = inv.serialize()
	var inv2 = Inventory.new()
	inv2.deserialize(data)

	assert_true(inv2.has_key("llave_1"))
	assert_true(inv2.has_key("llave_2"))
	assert_false(inv2.has_key("llave_3"))
