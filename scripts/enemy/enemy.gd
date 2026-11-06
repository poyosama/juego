class_name Enemy
extends CharacterBody3D

signal proximity_updated(dist_factor)
signal player_caught

const EnemyBrain = preload("res://scripts/core/enemy_brain.gd")

@export var patrol_speed: float = 1.8
@export var chase_speed: float = 4.2
@export var gravity: float = 14.0

@onready var vision_ray: RayCast3D = get_node_or_null("VisionRay")
@onready var nav_agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D")
@onready var sound_player: AudioStreamPlayer3D = get_node_or_null("SoundPlayer")

var brain: EnemyBrain = EnemyBrain.new()
var player_ref: Node3D = null
var patrol_points: Array[Vector3] = []
var current_patrol_idx: int = 0


func _ready() -> void:
	if brain == null:
		brain = EnemyBrain.new()
	collision_layer = 8 # Layer 4 = bit 8 (enemy)
	collision_mask = 1 | 2 # World + Player


func setup(p_player: Node3D, p_patrols: Array) -> void:
	player_ref = p_player
	patrol_points.clear()
	for p in p_patrols:
		if p is Vector3:
			patrol_points.append(p)
	if not patrol_points.is_empty():
		brain.target_position = patrol_points[0]


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	brain.current_position = global_position

	var saw_player := false
	var player_pos := Vector3.ZERO
	var player_hidden := false
	var noise_level := 0.0
	var noise_pos := Vector3.ZERO

	if player_ref and is_instance_valid(player_ref):
		player_pos = player_ref.global_position
		player_hidden = player_ref.get("is_hidden") == true
		noise_level = player_ref.get("noise_level") if "noise_level" in player_ref else 0.0
		noise_pos = player_pos
		saw_player = _check_vision(player_pos, player_hidden)

		# Feedback de proximidad
		var dist := global_position.distance_to(player_pos)
		if dist <= 10.0 and not player_hidden:
			var factor := 1.0 - clampf(dist / 10.0, 0.0, 1.0)
			proximity_updated.emit(factor)
		else:
			proximity_updated.emit(0.0)

	brain.update_perception(saw_player, player_pos, player_hidden, noise_level, noise_pos, delta)

	# Manejo de estados y movimiento
	if brain.state == EnemyBrain.State.KILL:
		velocity.x = 0.0
		velocity.z = 0.0
		player_caught.emit()
		return

	if brain.state == EnemyBrain.State.PATROL:
		_process_patrol()

	_move_towards_target(brain.target_position, delta)
	move_and_slide()


func _check_vision(target_pos: Vector3, is_hidden: bool) -> bool:
	if is_hidden:
		return false

	var to_target := target_pos - global_position
	var dist := to_target.length()
	if dist > brain.max_vision_distance:
		return false

	# Cono de visión frontal (~130 grados total = ±65 grados)
	var forward := -global_transform.basis.z
	var angle := forward.angle_to(to_target.normalized())
	if angle > deg_to_rad(65.0):
		return false

	# Raycast para obstáculos de pared
	if vision_ray:
		vision_ray.target_position = vision_ray.to_local(target_pos + Vector3(0, 1.2, 0))
		vision_ray.force_raycast_update()
		if vision_ray.is_colliding():
			var collider = vision_ray.get_collider()
			if collider == player_ref or (collider and collider.is_in_group("player")):
				return true
			return false

	return true


func _process_patrol() -> void:
	if patrol_points.is_empty():
		return
	var target := patrol_points[current_patrol_idx]
	if global_position.distance_to(target) < 1.5:
		current_patrol_idx = (current_patrol_idx + 1) % patrol_points.size()
		target = patrol_points[current_patrol_idx]
	brain.target_position = target


func _move_towards_target(target: Vector3, delta: float) -> void:
	var move_speed := chase_speed if brain.state == EnemyBrain.State.CHASE else patrol_speed
	var dir := (target - global_position)
	dir.y = 0.0 # movimiento horizontal

	if dir.length_squared() > 0.04:
		dir = dir.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed

		# Rotar hacia el destino
		var target_rot_y := atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot_y, 6.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
