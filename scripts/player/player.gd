class_name Player
extends CharacterBody3D

signal interacted_with(target)
signal stamina_changed(percent)
signal flashlight_toggled(is_on)

const Stamina = preload("res://scripts/core/stamina.gd")
const Inventory = preload("res://scripts/core/inventory.gd")

@export var walk_speed: float = 3.2
@export var sprint_speed: float = 5.8
@export var crouch_speed: float = 1.6
@export var jump_velocity: float = 4.0
@export var gravity: float = 14.0

@export var standing_height: float = 1.7
@export var crouching_height: float = 0.95
@export var crouch_transition_speed: float = 10.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var flashlight: SpotLight3D = $Head/Camera3D/Flashlight
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var step_player: AudioStreamPlayer3D = $StepPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

var stamina: Stamina
var inventory: Inventory = Inventory.new()
var is_crouching: bool = false
var is_sprinting: bool = false
var is_hidden: bool = false
var hiding_spot: Node = null

# Ruido generado para la IA del enemigo: 0 = nada, 1 = caminar, 2 = correr
var noise_level: float = 0.0

var _step_timer: float = 0.0
var _camera_bob_timer: float = 0.0
var _initial_head_y: float = 1.6


func _ready() -> void:
	stamina = Stamina.new(100.0, 25.0, 20.0, 1.2, 0.3)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Pendiente de la escalera (~35°) caminable y pegado al piso al bajar
	floor_max_angle = deg_to_rad(46.0)
	floor_snap_length = 0.5
	if head:
		_initial_head_y = head.position.y
	if flashlight:
		flashlight.visible = true


func _unhandled_input(event: InputEvent) -> void:
	# Mirar con el mouse funciona también escondido (para espiar por las rendijas)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sens: float = Settings.mouse_sensitivity if Settings else 0.002
		rotate_y(-event.relative.x * sens)
		if head:
			head.rotate_x(-event.relative.y * sens)
			head.rotation.x = clampf(head.rotation.x, deg_to_rad(-85.0), deg_to_rad(85.0))

	if is_hidden:
		if event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
			exit_hiding()
		return

	if event.is_action_pressed("toggle_flashlight"):
		toggle_flashlight()

	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		try_interact()


func _physics_process(delta: float) -> void:
	if is_hidden:
		velocity = Vector3.ZERO
		return

	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Input de agacharse
	is_crouching = Input.is_action_pressed("crouch")

	# Input de dirección
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1.0
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1.0
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1.0
	input_dir = input_dir.normalized()

	var is_moving := input_dir.length_squared() > 0.01

	# Lógica de sprint & stamina
	if is_moving and Input.is_action_pressed("sprint") and not is_crouching and stamina.can_sprint():
		is_sprinting = true
		stamina.drain(delta)
	else:
		is_sprinting = false
		stamina.tick_recovery(delta)

	stamina_changed.emit(stamina.get_percent())

	# Velocidad y ruido
	var current_speed := walk_speed
	if is_crouching:
		current_speed = crouch_speed
		noise_level = 0.2 if is_moving else 0.0
	elif is_sprinting:
		current_speed = sprint_speed
		noise_level = 2.0
	else:
		current_speed = walk_speed
		noise_level = 1.0 if is_moving else 0.0

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# Transición suave de altura de cabeza
	var target_y := crouching_height if is_crouching else standing_height
	if head:
		head.position.y = move_toward(head.position.y, target_y, crouch_transition_speed * delta)

	move_and_slide()

	# Pasos de audio y movimiento de cámara (head bob)
	_handle_footsteps_and_bob(delta, is_moving, current_speed)


func _handle_footsteps_and_bob(delta: float, is_moving: bool, speed: float) -> void:
	if not is_on_floor() or not is_moving:
		_step_timer = 0.0
		return

	var step_interval := 0.55
	if is_sprinting:
		step_interval = 0.35
	elif is_crouching:
		step_interval = 0.75

	_step_timer += delta
	if _step_timer >= step_interval:
		_step_timer = 0.0
		_play_step_sound()


func _play_step_sound() -> void:
	if step_player and SoundBank:
		var snd := SoundBank.get_sound("step")
		if snd:
			step_player.stream = snd
			# Variación leve de pitch y volumen
			step_player.pitch_scale = randf_range(0.9, 1.1)
			if is_crouching:
				step_player.volume_db = -12.0
			elif is_sprinting:
				step_player.volume_db = 2.0
			else:
				step_player.volume_db = -4.0
			step_player.play()


func toggle_flashlight() -> void:
	if flashlight:
		flashlight.visible = not flashlight.visible
		flashlight_toggled.emit(flashlight.visible)
		if sfx_player and SoundBank:
			var click := SoundBank.get_sound("click")
			if click:
				sfx_player.stream = click
				sfx_player.play()


func try_interact() -> void:
	if interaction_ray and interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider and collider.has_method("interact"):
			collider.interact(self)
			interacted_with.emit(collider)


func get_interaction_target():
	if is_hidden:
		return hiding_spot
	if interaction_ray and interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider and collider.has_method("get_prompt"):
			return collider
	return null


func enter_hiding(spot: Node) -> void:
	is_hidden = true
	hiding_spot = spot
	velocity = Vector3.ZERO
	noise_level = 0.0
	is_sprinting = false
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape3D")
	if not head:
		head = get_node_or_null("Head")
	if not flashlight:
		flashlight = get_node_or_null("Head/Camera3D/Flashlight")
	if collision_shape:
		collision_shape.disabled = true
	if flashlight:
		flashlight.visible = false
	if spot:
		if "occupant" in spot:
			spot.occupant = self
		# Mover al jugador para que la cámara quede dentro del mueble y mirando hacia la salida
		if spot.has_method("get_camera_position") and head:
			var target_pos: Vector3 = spot.get_camera_position() - Vector3(0, head.position.y, 0)
			if is_inside_tree():
				global_position = target_pos
			else:
				position = target_pos
		if spot.has_method("get_exit_position"):
			var exit_pos: Vector3 = spot.get_exit_position()
			var spot_pos: Vector3 = spot.global_position if spot.is_inside_tree() else spot.position
			var to_exit := Vector3(exit_pos.x - spot_pos.x, 0.0, exit_pos.z - spot_pos.z)
			if to_exit.length_squared() > 0.001:
				rotation.y = atan2(-to_exit.x, -to_exit.z)


func exit_hiding() -> void:
	is_hidden = false
	if hiding_spot:
		if "occupant" in hiding_spot:
			hiding_spot.occupant = null
		if hiding_spot.has_method("get_exit_position"):
			var exit_pos: Vector3 = hiding_spot.get_exit_position()
			if is_inside_tree():
				global_position = exit_pos
			else:
				position = exit_pos
	hiding_spot = null
	velocity = Vector3.ZERO
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape3D")
	if collision_shape:
		collision_shape.disabled = false
