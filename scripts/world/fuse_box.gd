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


func interact(_player: Node) -> void:
	if is_powered:
		return
	var obj = Game.objective if Game and "objective" in Game else null
	if obj == null:
		_play_sfx("locked")
		return
	var before := installed_fuses
	install_from(obj)
	if is_powered:
		_play_sfx("beep")
	elif installed_fuses > before:
		_play_sfx("click")
	else:
		_play_sfx("locked")


## Coloca en la caja todos los fusibles juntados que todavía no se pusieron.
func install_from(obj) -> void:
	if is_powered or obj == null:
		return
	var available: int = obj.collected_fuses - installed_fuses
	if available <= 0:
		return
	installed_fuses += available
	fuses_updated.emit(installed_fuses)
	if installed_fuses >= required_fuses:
		is_powered = true
		power_restored.emit()


func _play_sfx(sound_name: String) -> void:
	if not is_inside_tree() or not SoundBank:
		return
	var snd := SoundBank.get_sound(sound_name)
	if snd:
		var p := AudioStreamPlayer3D.new()
		p.stream = snd
		p.bus = &"SFX"
		add_child(p)
		p.play()
		p.finished.connect(p.queue_free)
