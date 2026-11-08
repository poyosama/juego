class_name Pickup
extends Area3D

signal picked_up(item_data)

@export var item_id: String = ""
@export var item_name: String = "Objeto"
@export var item_type: String = "key" # "key" o "fuse"


func _ready() -> void:
	collision_layer = 4 # Layer 3 = bit 4 (Interactable)
	collision_mask = 0


func get_prompt() -> String:
	return "[E] Recoger " + item_name


func interact(player: Node) -> void:
	if item_type == "key":
		if player and "inventory" in player and player.inventory:
			player.inventory.add_key(item_id)
		_play_sfx("click")
	elif item_type == "fuse":
		register_with(Game)
		_play_sfx("beep")

	picked_up.emit({"id": item_id, "name": item_name, "type": item_type})
	queue_free()


## Suma este fusible al objetivo del juego indicado (autoload Game o un doble de test).
func register_with(game: Object) -> void:
	if game and "objective" in game and game.objective:
		game.objective.add_fuse(item_id)


func _play_sfx(sound_name: String) -> void:
	if not is_inside_tree() or not SoundBank:
		return
	var snd := SoundBank.get_sound(sound_name)
	if snd:
		var sfx := AudioStreamPlayer.new()
		sfx.stream = snd
		sfx.bus = &"SFX"
		get_tree().root.add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
