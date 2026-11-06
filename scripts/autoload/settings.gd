extends Node

const SETTINGS_FILE := "user://settings.cfg"

var master_volume: float = 1.0:
	set(val):
		master_volume = clampf(val, 0.0, 1.0)
		_apply_audio_volume("Master", master_volume)

var music_volume: float = 1.0:
	set(val):
		music_volume = clampf(val, 0.0, 1.0)
		_apply_audio_volume("Music", music_volume)

var sfx_volume: float = 1.0:
	set(val):
		sfx_volume = clampf(val, 0.0, 1.0)
		_apply_audio_volume("SFX", sfx_volume)

var brightness: float = 1.0:
	set(val):
		brightness = clampf(val, 0.5, 1.5)

var mouse_sensitivity: float = 0.002:
	set(val):
		mouse_sensitivity = clampf(val, 0.0005, 0.01)

var fullscreen: bool = false:
	set(val):
		fullscreen = val
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_FILE)
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
		music_volume = config.get_value("audio", "music_volume", 1.0)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		brightness = config.get_value("display", "brightness", 1.0)
		mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", 0.002)
		fullscreen = config.get_value("display", "fullscreen", false)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("display", "brightness", brightness)
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(SETTINGS_FILE)


func _apply_audio_volume(bus_name: String, volume_linear: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(maxf(volume_linear, 0.0001)))
