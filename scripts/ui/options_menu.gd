extends Control

signal closed

@onready var sld_master: HSlider = $Panel/VBox/RowMaster/SldMaster
@onready var sld_music: HSlider = $Panel/VBox/RowMusic/SldMusic
@onready var sld_sfx: HSlider = $Panel/VBox/RowSFX/SldSFX
@onready var sld_brightness: HSlider = $Panel/VBox/RowBrightness/SldBrightness
@onready var sld_sens: HSlider = $Panel/VBox/RowSens/SldSens
@onready var chk_fullscreen: CheckBox = $Panel/VBox/RowFullscreen/ChkFullscreen
@onready var btn_back: Button = $Panel/VBox/BtnBack


func _ready() -> void:
	if Settings:
		sld_master.value = Settings.master_volume
		sld_music.value = Settings.music_volume
		sld_sfx.value = Settings.sfx_volume
		sld_brightness.value = Settings.brightness
		sld_sens.value = Settings.mouse_sensitivity * 1000.0 # escalar para slider
		chk_fullscreen.button_pressed = Settings.fullscreen

	sld_master.value_changed.connect(_on_master_changed)
	sld_music.value_changed.connect(_on_music_changed)
	sld_sfx.value_changed.connect(_on_sfx_changed)
	sld_brightness.value_changed.connect(_on_brightness_changed)
	sld_sens.value_changed.connect(_on_sens_changed)
	chk_fullscreen.toggled.connect(_on_fullscreen_toggled)
	btn_back.pressed.connect(_on_back_pressed)


func _on_master_changed(v: float) -> void:
	Settings.master_volume = v


func _on_music_changed(v: float) -> void:
	Settings.music_volume = v


func _on_sfx_changed(v: float) -> void:
	Settings.sfx_volume = v


func _on_brightness_changed(v: float) -> void:
	Settings.brightness = v


func _on_sens_changed(v: float) -> void:
	Settings.mouse_sensitivity = v / 1000.0


func _on_fullscreen_toggled(btn: bool) -> void:
	Settings.fullscreen = btn


func _on_back_pressed() -> void:
	Settings.save_settings()
	closed.emit()
	hide()
