class_name VHSOverlay
extends Control

@onready var vhs_rect: ColorRect = $VHSRect
@onready var lbl_play: Label = $HUD/LblPlay
@onready var lbl_timer: Label = $HUD/LblTimer

var elapsed_seconds: float = 0.0
var glitch_intensity: float = 0.0


func _ready() -> void:
	if Settings:
		update_brightness(Settings.brightness)


func _process(delta: float) -> void:
	elapsed_seconds += delta
	_update_timer_label()

	if vhs_rect and vhs_rect.material is ShaderMaterial:
		vhs_rect.material.set_shader_parameter("glitch_intensity", glitch_intensity)


func _update_timer_label() -> void:
	if not lbl_timer:
		return
	var total_sec := int(elapsed_seconds)
	var hrs := total_sec / 3600
	var mins := (total_sec % 3600) / 60
	var secs := total_sec % 60
	lbl_timer.text = "SP %02d:%02d:%02d" % [hrs, mins, secs]


func update_brightness(val: float) -> void:
	if vhs_rect and vhs_rect.material is ShaderMaterial:
		vhs_rect.material.set_shader_parameter("brightness_mult", val)


func set_glitch(intensity: float) -> void:
	glitch_intensity = clampf(intensity, 0.0, 1.0)
