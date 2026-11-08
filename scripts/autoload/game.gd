extends Node

const SAVE_PATH := "user://save.json"

signal game_saved
signal game_loaded

var current_save_data: Dictionary = {}
var is_paused: bool = false
## Objetivo de la partida en curso (lo asigna main_game.gd al iniciar).
var objective = null


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game(data: Dictionary) -> bool:
	current_save_data = data.duplicate(true)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	var json_str := JSON.stringify(current_save_data, "\t")
	file.store_string(json_str)
	file.close()
	game_saved.emit()
	return true


func load_game() -> Dictionary:
	if not has_save():
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) == TYPE_DICTIONARY:
		current_save_data = parsed
		game_loaded.emit()
		return current_save_data
	return {}


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
	current_save_data.clear()


func start_new_game() -> void:
	current_save_data.clear()
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func continue_game() -> void:
	if has_save():
		load_game()
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")
