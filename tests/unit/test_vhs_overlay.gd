extends "res://tests/test_case.gd"

const VHSOverlayScript = preload("res://scripts/ui/vhs_overlay.gd")


func test_vhs_overlay_nodes_and_timer() -> void:
	var scene: PackedScene = load("res://scenes/ui/vhs_overlay.tscn")
	assert_true(scene != null, "la escena vhs_overlay.tscn debe existir")

	var overlay = scene.instantiate()
	assert_true(overlay != null)

	overlay._ready()
	overlay._process(125.0) # 2 mins 5 secs
	assert_eq(overlay.lbl_timer.text, "SP 00:02:05", "formato de tiempo SP HH:MM:SS")

	overlay.set_glitch(0.8)
	assert_almost(overlay.glitch_intensity, 0.8, 0.01)

	overlay.queue_free()
