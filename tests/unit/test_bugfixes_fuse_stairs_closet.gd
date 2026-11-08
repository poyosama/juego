extends "res://tests/test_case.gd"
## Tests de regresión para los bugs reportados: fusibles, escalera y armario.

const GameScript = preload("res://scripts/autoload/game.gd")
const ObjectiveScript = preload("res://scripts/core/objective.gd")
const PickupScript = preload("res://scripts/world/pickup.gd")
const FuseBoxScript = preload("res://scripts/world/fuse_box.gd")
const HouseBuilderScript = preload("res://scripts/world/house_builder.gd")
const HidingSpotScript = preload("res://scripts/world/hiding_spot.gd")


# --- Bug 1: el fusible no se cuenta ---

func test_game_autoload_exposes_objective() -> void:
	var g = GameScript.new()
	assert_true("objective" in g, "Game debe declarar la variable objective")
	g.free()


func test_fuse_pickup_and_fusebox_count() -> void:
	var g = GameScript.new()
	var obj = ObjectiveScript.new()
	g.objective = obj

	var pickup = PickupScript.new()
	pickup.item_id = "fuse_1"
	pickup.item_type = "fuse"
	pickup.register_with(g)
	assert_eq(obj.collected_fuses, 1, "recoger un fusible debe sumar 1")

	var box = FuseBoxScript.new()
	box.install_from(obj)
	assert_eq(box.installed_fuses, 1, "la caja debe recibir el fusible juntado")
	assert_eq(box.get_prompt(), "[E] Colocar fusibles (1/5)")

	# Juntar los 4 restantes y colocarlos restaura la energía
	for i in range(2, 6):
		obj.add_fuse("fuse_%d" % i)
	box.install_from(obj)
	assert_true(box.is_powered, "con 5 fusibles la caja se energiza")

	box.free()
	pickup.free()
	g.free()


# --- Bug 2: la escalera no se puede subir ---

func test_stair_ramp_reaches_upper_floor() -> void:
	var b = HouseBuilderScript.new()
	var bottom: float = b.stair_surface_height(b.STAIR_BOTTOM_Z)
	var top: float = b.stair_surface_height(b.STAIR_TOP_Z)
	assert_almost(bottom, b.GROUND_FLOOR_TOP, 0.05, "la rampa arranca al nivel del piso")
	assert_almost(top, b.UPPER_FLOOR_TOP, 0.05, "la rampa llega al nivel del piso de arriba")
	var slope_deg := rad_to_deg(atan2(b.UPPER_FLOOR_TOP - b.GROUND_FLOOR_TOP, absf(b.STAIR_TOP_Z - b.STAIR_BOTTOM_Z)))
	assert_true(slope_deg < 40.0, "la pendiente debe ser caminable (<40°), es %.1f" % slope_deg)
	b.free()


func test_upper_floor_hole_only_over_stairs() -> void:
	var b = HouseBuilderScript.new()
	var mid_z: float = (b.STAIR_BOTTOM_Z + b.STAIR_TOP_Z) * 0.5
	assert_false(b.upper_floor_covers(0.0, mid_z), "sobre la mitad de la escalera debe haber hueco")
	var landing_z: float = b.STAIR_TOP_Z + signf(b.STAIR_TOP_Z - b.STAIR_BOTTOM_Z) * 0.8
	assert_true(b.upper_floor_covers(0.0, landing_z), "al final de la escalera debe haber piso para pararse")
	assert_true(b.upper_floor_covers(0.0, 5.5), "el pasillo de arriba (x=0, z=5.5) debe tener piso")
	assert_true(b.upper_floor_covers(5.0, 4.0), "la habitación de huéspedes debe tener piso")
	b.free()


# --- Bug 3: el armario se buguea ---

func test_hiding_moves_camera_inside_and_exits() -> void:
	var player = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector3(0, 0.1, 0)

	var spot = HidingSpotScript.new()
	spot.kind = "closet"
	spot.size = Vector3(1.2, 2.0, 1.0)
	spot.exit_position = Vector3(3, 0.1, 0)
	spot.position = Vector3(5, 1.1, 0)

	assert_true(spot is StaticBody3D, "el armario debe ser sólido (StaticBody3D)")
	spot.interact(player)
	assert_true(player.is_hidden, "debe quedar escondido")
	var head: Node3D = player.get_node("Head")
	var cam_pos: Vector3 = player.position + head.position
	var half: Vector3 = spot.size * 0.5
	var local: Vector3 = cam_pos - spot.position
	assert_true(absf(local.x) < half.x and absf(local.y) < half.y and absf(local.z) < half.z,
		"la cámara debe quedar dentro del armario (local %s)" % str(local))
	assert_eq(player.get_interaction_target(), spot, "mientras está escondido el target debe ser el propio escondite")
	assert_true(spot.get_prompt().contains("Salir"), "el prompt escondido debe ofrecer salir")

	spot.interact(player)
	assert_false(player.is_hidden)
	assert_true(player.position.distance_to(Vector3(3, 0.1, 0)) < 0.01, "sale en exit_position")
	assert_false(player.collision_shape.disabled, "recupera la colisión al salir")

	spot.free()
	player.free()
