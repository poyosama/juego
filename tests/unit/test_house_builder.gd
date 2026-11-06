extends "res://tests/test_case.gd"

const HouseBuilderScript = preload("res://scripts/world/house_builder.gd")
const HouseLayoutScript = preload("res://scripts/core/house_layout.gd")
const DoorScript = preload("res://scripts/world/door.gd")
const PickupScript = preload("res://scripts/world/pickup.gd")


func test_house_builder_generates_nodes() -> void:
	var builder = HouseBuilderScript.new()
	var layout = HouseLayoutScript.get_default_layout()

	builder.build_house(layout)

	# Verificar que agregó nodos hijos (paredes, pisos, puertas, pickups)
	assert_true(builder.get_child_count() > 10, "debe generar más de 10 elementos estructurales y de interacción")

	# Contar puertas y pickups generados
	var door_count := 0
	var pickup_count := 0
	for child in builder.get_children():
		if child is DoorScript:
			door_count += 1
		elif child is PickupScript:
			pickup_count += 1

	assert_eq(door_count, layout["doors"].size(), "debe spawnear todas las puertas")
	assert_eq(pickup_count, layout["keys"].size() + layout["fuses"].size(), "debe spawnear todas las llaves y fusibles")

	builder.free()
