extends "res://tests/test_case.gd"

const HouseLayout = preload("res://scripts/core/house_layout.gd")


func test_house_layout_consistency() -> void:
	var layout = HouseLayout.get_default_layout()
	assert_true(layout != null, "layout no debe ser nulo")

	# 1. Exactamente 5 fusibles
	var fuses: Array = layout.get("fuses", [])
	assert_eq(fuses.size(), 5, "debe haber exactamente 5 fusibles")

	var fuse_ids := {}
	for f in fuses:
		var id: String = f["id"]
		assert_false(fuse_ids.has(id), "id de fusible duplicado: " + id)
		fuse_ids[id] = true

	# 2. Llaves únicas
	var keys: Array = layout.get("keys", [])
	var key_ids := {}
	for k in keys:
		var id: String = k["id"]
		assert_false(key_ids.has(id), "id de llave duplicada: " + id)
		key_ids[id] = true

	# 3. Puertas y sus cerraduras
	var doors: Array = layout.get("doors", [])
	var door_ids := {}
	for d in doors:
		var id: String = d["id"]
		assert_false(door_ids.has(id), "id de puerta duplicada: " + id)
		door_ids[id] = true
		if d.get("is_locked", false):
			var required_key: String = d.get("required_key", "")
			assert_true(key_ids.has(required_key), "la puerta " + id + " requiere una llave inexistente: " + required_key)

	# 4. Escondites y contestadores
	var hiding_spots: Array = layout.get("hiding_spots", [])
	assert_true(hiding_spots.size() >= 2, "debe haber al menos 2 escondites")

	var answering_machines: Array = layout.get("answering_machines", [])
	assert_true(answering_machines.size() >= 3, "debe haber al menos 3 contestadores para la historia")

	# 5. Puntos de patrulla para el enemigo
	var patrol_points: Array = layout.get("patrol_points", [])
	assert_true(patrol_points.size() >= 4, "debe haber al menos 4 puntos de patrulla")

	# 6. Spawn del jugador y caja de fusibles
	assert_true(layout.has("player_spawn"), "debe tener player_spawn")
	assert_true(layout.has("fuse_box"), "debe tener fuse_box")
	assert_true(layout.has("main_exit"), "debe tener main_exit")
