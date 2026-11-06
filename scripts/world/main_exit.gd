class_name MainExit
extends Area3D

signal player_escaped

@export var is_unlocked: bool = false


func _ready() -> void:
	collision_layer = 4 # Interactable
	collision_mask = 2 # Player


func get_prompt() -> String:
	if is_unlocked:
		return "[E] ¡Escapar de la casa!"
	return "La puerta principal no tiene energía. Necesita los 5 fusibles."


func interact(player: Node) -> void:
	if is_unlocked:
		player_escaped.emit()
	else:
		if SoundBank:
			var snd := SoundBank.get_sound("locked")
			if snd:
				var p := AudioStreamPlayer.new()
				p.stream = snd
				p.bus = &"SFX"
				add_child(p)
				p.play()
				p.finished.connect(p.queue_free)


func unlock() -> void:
	is_unlocked = true
