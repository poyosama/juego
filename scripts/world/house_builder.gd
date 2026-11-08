class_name HouseBuilder
extends Node3D

const DoorScript = preload("res://scripts/world/door.gd")
const PickupScript = preload("res://scripts/world/pickup.gd")
const HidingSpotScript = preload("res://scripts/world/hiding_spot.gd")
const FuseBoxScript = preload("res://scripts/world/fuse_box.gd")
const MainExitScript = preload("res://scripts/world/main_exit.gd")
const AnswerMachineScript = preload("res://scripts/world/answer_machine.gd")
const ScareTriggerScript = preload("res://scripts/world/scare_trigger.gd")

# Geometría de pisos y escalera (metros). La escalera sube hacia +z y desemboca en el pasillo de arriba.
const GROUND_FLOOR_TOP := 0.1
const UPPER_FLOOR_TOP := 3.6
const STAIR_BOTTOM_Z := -3.5
const STAIR_TOP_Z := 1.5
const STAIR_WIDTH := 2.0
const STAIR_HOLE_HALF_X := 1.25

var wall_material: StandardMaterial3D
var floor_material: StandardMaterial3D
var wood_material: StandardMaterial3D
var metal_material: StandardMaterial3D


func _init() -> void:
	_init_materials()


func _init_materials() -> void:
	wall_material = StandardMaterial3D.new()
	wall_material.albedo_color = Color(0.68, 0.65, 0.72) # violeta pálido desaturado (como en la foto del usuario)
	wall_material.roughness = 0.9

	floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.35, 0.32, 0.38) # piso alfombrado grisáceo oscuro
	floor_material.roughness = 0.85

	wood_material = StandardMaterial3D.new()
	wood_material.albedo_color = Color(0.42, 0.28, 0.20) # madera muebles y puertas
	wood_material.roughness = 0.7

	metal_material = StandardMaterial3D.new()
	metal_material.albedo_color = Color(0.3, 0.3, 0.35)
	metal_material.metallic = 0.6


func build_house(layout: Dictionary) -> void:
	# 1. Pisos y techos
	_create_floor_slab(Vector3(0, 0, 0), Vector3(16, 0.2, 14), floor_material) # Planta baja
	for r in upper_floor_rects():
		# r = Rect2 en (x, z); se genera un bloque de piso por rectángulo, dejando el hueco de la escalera
		_create_floor_slab(Vector3(r.get_center().x, UPPER_FLOOR_TOP - 0.1, r.get_center().y), Vector3(r.size.x, 0.2, r.size.y), floor_material)
	_create_floor_slab(Vector3(0, 7.0, 0), Vector3(16, 0.2, 14), wall_material) # Techo planta alta

	# 2. Paredes exteriores (Planta Baja y Planta Alta)
	_create_wall(Vector3(0, 1.75, 7), Vector3(16, 3.5, 0.3))   # PB Frente
	_create_wall(Vector3(0, 1.75, -7), Vector3(16, 3.5, 0.3))  # PB Fondo
	_create_wall(Vector3(-8, 1.75, 0), Vector3(0.3, 3.5, 14))  # PB Izq
	_create_wall(Vector3(8, 1.75, 0), Vector3(0.3, 3.5, 14))   # PB Der

	_create_wall(Vector3(0, 5.25, 7), Vector3(16, 3.5, 0.3))   # PA Frente
	_create_wall(Vector3(0, 5.25, -7), Vector3(16, 3.5, 0.3))  # PA Fondo
	_create_wall(Vector3(-8, 5.25, 0), Vector3(0.3, 3.5, 14))  # PA Izq
	_create_wall(Vector3(8, 5.25, 0), Vector3(0.3, 3.5, 14))   # PA Der

	# 3. Paredes divisorias interiores
	# PB: División cocina y sótano
	_create_wall(Vector3(2.5, 1.75, 4.0), Vector3(0.3, 3.5, 6))
	_create_wall(Vector3(-2.5, 1.75, -4.5), Vector3(0.3, 3.5, 5))
	# PA: Habitaciones
	_create_wall(Vector3(2.5, 5.25, 3.5), Vector3(0.3, 3.5, 7))
	_create_wall(Vector3(-2.5, 5.25, 3.5), Vector3(0.3, 3.5, 7))
	# PA: división del fondo, recortada para no tapar el hueco de la escalera
	_create_wall(Vector3(0, 5.25, (-7.0 + STAIR_BOTTOM_Z) * 0.5), Vector3(0.3, 3.5, absf(STAIR_BOTTOM_Z + 7.0)))
	# Barandas del hueco en planta alta (laterales y fondo), para no caerse
	_create_wall(Vector3(-STAIR_HOLE_HALF_X, UPPER_FLOOR_TOP + 0.5, (STAIR_BOTTOM_Z + STAIR_TOP_Z) * 0.5), Vector3(0.1, 1.0, absf(STAIR_TOP_Z - STAIR_BOTTOM_Z)))
	_create_wall(Vector3(STAIR_HOLE_HALF_X, UPPER_FLOOR_TOP + 0.5, (STAIR_BOTTOM_Z + STAIR_TOP_Z) * 0.5), Vector3(0.1, 1.0, absf(STAIR_TOP_Z - STAIR_BOTTOM_Z)))
	_create_wall(Vector3(0, UPPER_FLOOR_TOP + 0.5, STAIR_BOTTOM_Z), Vector3(STAIR_HOLE_HALF_X * 2.0, 1.0, 0.1))

	# 4. Escalera entre pisos
	_create_staircase()

	# 5. Instanciar puertas
	for d_data in layout.get("doors", []):
		_spawn_door(d_data)

	# 6. Instanciar llaves y fusibles
	for k_data in layout.get("keys", []):
		_spawn_pickup(k_data, "key")
	for f_data in layout.get("fuses", []):
		_spawn_pickup(f_data, "fuse")

	# 7. Instanciar escondites
	for h_data in layout.get("hiding_spots", []):
		_spawn_hiding_spot(h_data)

	# 8. Instanciar contestadores con subtítulos
	for am_data in layout.get("answering_machines", []):
		_spawn_answer_machine(am_data)

	# 9. Instanciar zonas de sustos
	for st_data in layout.get("scare_triggers", []):
		_spawn_scare_trigger(st_data)

	# 10. Caja de fusibles y salida principal
	if layout.has("fuse_box"):
		_spawn_fuse_box(layout["fuse_box"])
	if layout.has("main_exit"):
		_spawn_main_exit(layout["main_exit"])


func _create_wall(pos: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.position = pos

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	col.shape = box
	body.add_child(col)

	var mesh_inst := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	box_mesh.material = wall_material
	mesh_inst.mesh = box_mesh
	body.add_child(mesh_inst)

	add_child(body)
	return body


func _create_floor_slab(pos: Vector3, size: Vector3, mat: Material, has_hole: bool = false) -> void:
	if not has_hole:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.position = pos

		var col := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		col.shape = box
		body.add_child(col)

		var mesh_inst := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = size
		box_mesh.material = mat
		mesh_inst.mesh = box_mesh
		body.add_child(mesh_inst)
		add_child(body)
	else:
		# Piso con hueco para la escalera (se crean dos mitades)
		var left_size := Vector3((size.x - 2.5) * 0.5, size.y, size.z)
		var right_size := Vector3((size.x - 2.5) * 0.5, size.y, size.z)
		_create_floor_slab(pos + Vector3(-size.x * 0.25 - 0.6, 0, 0), left_size, mat, false)
		_create_floor_slab(pos + Vector3(size.x * 0.25 + 0.6, 0, 0), right_size, mat, false)


func _create_staircase() -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1

	var run := STAIR_TOP_Z - STAIR_BOTTOM_Z # positivo: sube hacia +z
	var rise := UPPER_FLOOR_TOP - GROUND_FLOOR_TOP
	var hw := STAIR_WIDTH * 0.5
	var slab_drop := 0.25

	# Rampa prisma convexa: arranca al ras de GROUND_FLOOR_TOP y termina al ras de UPPER_FLOOR_TOP
	var col := CollisionShape3D.new()
	var wedge := ConvexPolygonShape3D.new()
	wedge.points = PackedVector3Array([
		Vector3(-hw, GROUND_FLOOR_TOP, STAIR_BOTTOM_Z),
		Vector3(hw, GROUND_FLOOR_TOP, STAIR_BOTTOM_Z),
		Vector3(-hw, UPPER_FLOOR_TOP, STAIR_TOP_Z),
		Vector3(hw, UPPER_FLOOR_TOP, STAIR_TOP_Z),
		Vector3(-hw, GROUND_FLOOR_TOP - slab_drop, STAIR_BOTTOM_Z),
		Vector3(hw, GROUND_FLOOR_TOP - slab_drop, STAIR_BOTTOM_Z),
		Vector3(-hw, UPPER_FLOOR_TOP - slab_drop, STAIR_TOP_Z),
		Vector3(hw, UPPER_FLOOR_TOP - slab_drop, STAIR_TOP_Z),
	])
	col.shape = wedge
	body.add_child(col)

	# Escalones visuales (sin colisión propia; la rampa es la que se camina)
	var steps := 14
	var step_h := rise / float(steps)
	var step_d := run / float(steps)
	for i in range(steps):
		var mesh_inst := MeshInstance3D.new()
		var step_mesh := BoxMesh.new()
		var h := step_h * (i + 1)
		step_mesh.size = Vector3(STAIR_WIDTH, h, absf(step_d))
		step_mesh.material = wood_material
		mesh_inst.mesh = step_mesh
		mesh_inst.position = Vector3(0, GROUND_FLOOR_TOP + h * 0.5, STAIR_BOTTOM_Z + step_d * (i + 0.5))
		body.add_child(mesh_inst)

	add_child(body)


## Altura de la superficie de la rampa en una coordenada z dada.
func stair_surface_height(z: float) -> float:
	var t := clampf((z - STAIR_BOTTOM_Z) / (STAIR_TOP_Z - STAIR_BOTTOM_Z), 0.0, 1.0)
	return lerpf(GROUND_FLOOR_TOP, UPPER_FLOOR_TOP, t)


## Rectángulos (x, z) que forman el piso de planta alta: toda la casa menos el hueco de la escalera.
func upper_floor_rects() -> Array[Rect2]:
	var hx := STAIR_HOLE_HALF_X
	var z_min := minf(STAIR_BOTTOM_Z, STAIR_TOP_Z)
	var z_max := maxf(STAIR_BOTTOM_Z, STAIR_TOP_Z)
	return [
		Rect2(Vector2(-8.0, -7.0), Vector2(8.0 - hx, 14.0)),      # lado izquierdo
		Rect2(Vector2(hx, -7.0), Vector2(8.0 - hx, 14.0)),        # lado derecho
		Rect2(Vector2(-hx, -7.0), Vector2(hx * 2.0, z_min + 7.0)), # franja del fondo
		Rect2(Vector2(-hx, z_max), Vector2(hx * 2.0, 7.0 - z_max)) # franja del frente (descanso)
	]


func upper_floor_covers(x: float, z: float) -> bool:
	for r in upper_floor_rects():
		if r.has_point(Vector2(x, z)):
			return true
	return false


func _spawn_door(data: Dictionary) -> void:
	var door := DoorScript.new()
	door.door_id = data.get("id", "")
	door.door_name = data.get("name", "Puerta")
	door.is_locked = data.get("is_locked", false)
	door.required_key = data.get("required_key", "")
	door.position = data.get("position", Vector3.ZERO)

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.2, 2.2, 0.15)
	col.shape = box
	col.position = Vector3(0.6, 1.1, 0) # Offset para bisagra en x=0
	door.add_child(col)

	var mesh_inst := MeshInstance3D.new()
	var door_mesh := BoxMesh.new()
	door_mesh.size = Vector3(1.2, 2.2, 0.1)
	door_mesh.material = wood_material
	mesh_inst.mesh = door_mesh
	mesh_inst.position = Vector3(0.6, 1.1, 0)
	door.add_child(mesh_inst)

	add_child(door)


func _spawn_pickup(data: Dictionary, p_type: String) -> void:
	var pickup := PickupScript.new()
	pickup.item_id = data.get("id", "")
	pickup.item_name = data.get("name", "Objeto")
	pickup.item_type = p_type
	pickup.position = data.get("position", Vector3.ZERO)

	var col := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.4
	col.shape = sphere
	pickup.add_child(col)

	var mesh_inst := MeshInstance3D.new()
	var m := BoxMesh.new()
	if p_type == "key":
		m.size = Vector3(0.1, 0.05, 0.25)
		m.material = metal_material
	else:
		m.size = Vector3(0.12, 0.3, 0.12)
		var fuse_mat := StandardMaterial3D.new()
		fuse_mat.albedo_color = Color(0.9, 0.7, 0.1) # fusible amarillo
		m.material = fuse_mat
	mesh_inst.mesh = m
	pickup.add_child(mesh_inst)

	add_child(pickup)


func _spawn_hiding_spot(data: Dictionary) -> void:
	var spot := HidingSpotScript.new()
	spot.spot_id = data.get("id", "")
	spot.spot_name = data.get("name", "Escondite")
	spot.kind = data.get("kind", "closet")
	spot.size = data.get("size", Vector3(1.6, 0.8, 2.0) if spot.kind == "bed" else Vector3(1.2, 2.0, 1.0))
	spot.position = data.get("position", Vector3.ZERO)
	spot.exit_position = data.get("exit_position", Vector3.ZERO)

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = spot.size
	col.shape = box
	spot.add_child(col)

	# Mueble visual (armario o cama)
	var mesh_inst := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = spot.size - Vector3(0.06, 0.06, 0.06)
	m.material = wood_material
	mesh_inst.mesh = m
	spot.add_child(mesh_inst)

	add_child(spot)


func _spawn_answer_machine(data: Dictionary) -> void:
	var am := AnswerMachineScript.new()
	am.machine_id = data.get("id", "")
	am.machine_name = data.get("name", "Contestador")
	am.subtitles = data.get("subtitles", [])
	am.position = data.get("position", Vector3.ZERO)

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 0.4, 0.5)
	col.shape = box
	am.add_child(col)

	var mesh_inst := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = Vector3(0.4, 0.3, 0.4)
	m.material = metal_material
	mesh_inst.mesh = m
	am.add_child(mesh_inst)

	add_child(am)


func _spawn_scare_trigger(data: Dictionary) -> void:
	var st := ScareTriggerScript.new()
	st.trigger_id = data.get("id", "")
	st.scare_type = data.get("type", "flicker_and_noise")
	st.position = data.get("position", Vector3.ZERO)

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = data.get("size", Vector3(2.0, 2.0, 2.0))
	col.shape = box
	st.add_child(col)

	add_child(st)


func _spawn_fuse_box(data: Dictionary) -> void:
	var fb := FuseBoxScript.new()
	fb.position = data.get("position", Vector3.ZERO)

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.6, 0.8, 0.3)
	col.shape = box
	fb.add_child(col)

	var mesh_inst := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = Vector3(0.6, 0.8, 0.3)
	m.material = metal_material
	mesh_inst.mesh = m
	fb.add_child(mesh_inst)

	add_child(fb)


func _spawn_main_exit(data: Dictionary) -> void:
	var exit := MainExitScript.new()
	exit.position = data.get("position", Vector3.ZERO)

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = data.get("size", Vector3(2.0, 2.4, 0.3))
	col.shape = box
	exit.add_child(col)

	var mesh_inst := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = data.get("size", Vector3(2.0, 2.4, 0.3))
	var exit_mat := StandardMaterial3D.new()
	exit_mat.albedo_color = Color(0.2, 0.1, 0.1) # Puerta roja pesada
	m.material = exit_mat
	mesh_inst.mesh = m
	exit.add_child(mesh_inst)

	add_child(exit)
