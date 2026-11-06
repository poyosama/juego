extends Node

const ToneSynth = preload("res://scripts/synth/tone_synth.gd")

var sounds: Dictionary = {}


func _ready() -> void:
	_ensure_audio_buses()
	_generate_default_sounds()


func _ensure_audio_buses() -> void:
	if AudioServer.get_bus_index("Music") < 0:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, "Music")
		AudioServer.set_bus_send(idx, "Master")

	if AudioServer.get_bus_index("SFX") < 0:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, "SFX")
		AudioServer.set_bus_send(idx, "Master")


func _generate_default_sounds() -> void:
	sounds["step"] = ToneSynth.generate_noise(0.08, 22050, 0.05)
	sounds["click"] = ToneSynth.generate_tone(1200.0, 0.04, 22050, 0.005, 0.02)
	sounds["door"] = ToneSynth.generate_tone(150.0, 0.4, 22050, 0.05, 0.2)
	sounds["locked"] = ToneSynth.generate_tone(80.0, 0.15, 22050, 0.01, 0.1)
	sounds["beep"] = ToneSynth.generate_tone(880.0, 0.25, 22050, 0.01, 0.05)
	sounds["tension"] = ToneSynth.generate_tone(70.0, 0.8, 22050, 0.1, 0.4)
	sounds["heartbeat"] = ToneSynth.generate_tone(45.0, 0.2, 22050, 0.02, 0.15)
	sounds["growl"] = ToneSynth.generate_noise(0.6, 22050, 0.2)
	sounds["ambient"] = ToneSynth.generate_ambient_loop(4.0, 22050)
	sounds["tape_hiss"] = ToneSynth.generate_noise(1.5, 22050, 0.0)


func get_sound(name: String) -> AudioStream:
	if sounds.has(name):
		return sounds[name]
	return null
