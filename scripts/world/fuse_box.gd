class_name FuseBox
extends StaticBody3D

signal fuses_updated(count)
signal power_restored

@export var required_fuses: int = 5
var installed_fuses: int = 0
var is_powered: bool = false


func _ready() -> void:
	collision_layer = 1 | 4 # World + Interactable


func get_prompt() -> String:
	if is_powered:
		return "Caja de fusibles (energía restaurada)"
	return "[E] Colocar fusibles (%d/%d)" % [installed_fuses, required_fuses]


func interact(player: Node) -> void:
	if is_powered:
		return

	if Game and "objective" in Game and Game.objective:
		var available: int = Game.objective.collected_fuses - installed_fuses
		if available > 0:
			installed_fuses += available
			fuses_updated.emit(installed_fuses)
			if installed_fuses >= required_fuses:
				is_powered = true
				power_restored.emit()
				_play_sfx("beep")
			else:
				_play_sfx("click")
		else:
			_play_sfx("locked")


func _play_sfx(name: String) -> void:
	if SoundBank:
		var snd := SoundBank.get_sound(name)
		if snd:
			var p := AudioStreamPlayer3D.new()
			p.stream = snd
			p.bus = &"SFX"
			add_child(p)
			p.play()
			p.finished.connect(p.queue_free)
