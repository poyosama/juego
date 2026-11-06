class_name Door
extends AnimatableBody3D

signal door_unlocked(id)
signal door_toggled(id, is_open)

@export var door_id: String = ""
@export var door_name: String = "Puerta"
@export var is_locked: bool = false
@export var required_key: String = ""
@export var open_angle: float = 90.0

var is_open: bool = false
var _target_rotation_y: float = 0.0
var _initial_rotation_y: float = 0.0


func _ready() -> void:
	collision_layer = 1 | 4 # World (1) + Interactable (3 = bit 4)
	_initial_rotation_y = rotation_degrees.y
	_target_rotation_y = _initial_rotation_y


func _process(delta: float) -> void:
	rotation_degrees.y = move_toward(rotation_degrees.y, _target_rotation_y, 180.0 * delta)


func get_prompt() -> String:
	if is_locked:
		return "Está cerrada con llave"
	if is_open:
		return "[E] Cerrar " + door_name
	return "[E] Abrir " + door_name


func interact(player: Node) -> void:
	if is_locked:
		var has_key := false
		if player != null:
			if "inventory" in player and player.get("inventory") != null:
				has_key = player.get("inventory").has_key(required_key)
			elif player.has_meta("inventory"):
				has_key = player.get_meta("inventory").has_key(required_key)
		if not has_key and Game and Game.current_save_data.has("inventory"):
			var keys: Array = Game.current_save_data["inventory"].get("keys", [])
			has_key = keys.has(required_key)

		if has_key:
			is_locked = false
			door_unlocked.emit(door_id)
			_play_sound("click")
			_toggle_door()
		else:
			_play_sound("locked")
		return

	_toggle_door()


func _toggle_door() -> void:
	is_open = not is_open
	_play_sound("door")
	if is_open:
		_target_rotation_y = _initial_rotation_y + open_angle
	else:
		_target_rotation_y = _initial_rotation_y
	door_toggled.emit(door_id, is_open)


func _play_sound(sound_name: String) -> void:
	if SoundBank:
		var snd := SoundBank.get_sound(sound_name)
		if snd:
			var player := AudioStreamPlayer3D.new()
			player.stream = snd
			player.bus = &"SFX"
			add_child(player)
			player.play()
			player.finished.connect(player.queue_free)
