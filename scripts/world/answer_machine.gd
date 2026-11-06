class_name AnswerMachine
extends Area3D

signal subtitle_changed(text)
signal playback_finished

@export var machine_id: String = ""
@export var machine_name: String = "Contestador"
@export var subtitles: Array = [] # Array de {"time": float, "text": String}

var is_playing: bool = false
var _playback_time: float = 0.0
var _current_sub_idx: int = -1
var _audio_player: AudioStreamPlayer3D


func _ready() -> void:
	collision_layer = 4 # Interactable
	collision_mask = 0

	_audio_player = AudioStreamPlayer3D.new()
	_audio_player.bus = &"SFX"
	add_child(_audio_player)


func get_prompt() -> String:
	if is_playing:
		return "Reproduciendo..."
	return "[E] Escuchar " + machine_name


func interact(player: Node) -> void:
	if is_playing:
		return
	start_playback()


func start_playback() -> void:
	is_playing = true
	_playback_time = 0.0
	_current_sub_idx = -1

	if SoundBank:
		var beep := SoundBank.get_sound("beep")
		if beep and _audio_player and is_inside_tree():
			_audio_player.stream = beep
			_audio_player.play()


func _process(delta: float) -> void:
	if not is_playing:
		return

	_playback_time += delta
	_update_subtitles()

	# Chequear fin de mensaje
	var last_time := 0.0
	if not subtitles.is_empty():
		var last_sub: Dictionary = subtitles[subtitles.size() - 1]
		last_time = last_sub.get("time", 0.0) + 4.0

	if _playback_time >= last_time:
		is_playing = false
		subtitle_changed.emit("")
		playback_finished.emit()


func _update_subtitles() -> void:
	var active_text := ""
	for item in subtitles:
		if item is Dictionary:
			var t: float = item.get("time", 0.0)
			if _playback_time >= t:
				active_text = item.get("text", "")

	subtitle_changed.emit(active_text)
