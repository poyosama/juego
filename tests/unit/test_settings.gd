extends "res://tests/test_case.gd"

const SettingsScript = preload("res://scripts/autoload/settings.gd")


func test_settings_save_and_load() -> void:
	var s = SettingsScript.new()
	s.master_volume = 0.75
	s.music_volume = 0.5
	s.sfx_volume = 0.8
	s.brightness = 1.3
	s.mouse_sensitivity = 0.0035
	s.fullscreen = false

	s.save_settings()

	var s2 = SettingsScript.new()
	s2.load_settings()

	assert_almost(s2.master_volume, 0.75, 0.01)
	assert_almost(s2.music_volume, 0.5, 0.01)
	assert_almost(s2.sfx_volume, 0.8, 0.01)
	assert_almost(s2.brightness, 1.3, 0.01)
	assert_almost(s2.mouse_sensitivity, 0.0035, 0.0001)

	s.free()
	s2.free()
