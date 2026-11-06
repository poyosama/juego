class_name ScareTrigger
extends Area3D

signal scare_triggered(trigger_id, scare_type)

@export var trigger_id: String = ""
@export var scare_type: String = "flicker_and_noise" # "flicker_and_noise", "creak_door", etc.

var is_triggered: bool = false


func _ready() -> void:
	collision_layer = 16 # Layer 5 = bit 16 (trigger)
	collision_mask = 2 # Player (layer 2)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if is_triggered:
		return
	if body.is_in_group("player") or body.has_method("toggle_flashlight"):
		trigger_scare()


func trigger_scare() -> void:
	if is_triggered:
		return
	is_triggered = true
	scare_triggered.emit(trigger_id, scare_type)
	_execute_scare_effects()


func _execute_scare_effects() -> void:
	if SoundBank:
		var snd_name := "tension" if scare_type == "flicker_and_noise" else "door"
		var snd := SoundBank.get_sound(snd_name)
		if snd:
			var p := AudioStreamPlayer.new()
			p.stream = snd
			p.bus = &"SFX"
			add_child(p)
			p.play()
			p.finished.connect(p.queue_free)
