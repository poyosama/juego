extends "res://tests/test_case.gd"

const SCENES := [
	"res://scenes/ui/main_menu.tscn",
	"res://scenes/ui/options_menu.tscn",
	"res://scenes/ui/pause_menu.tscn",
	"res://scenes/ui/vhs_overlay.tscn",
	"res://scenes/player/player.tscn",
	"res://scenes/enemy/enemy.tscn",
	"res://scenes/main_game.tscn"
]


func test_all_scenes_compile_and_instantiate() -> void:
	for path in SCENES:
		var scene: PackedScene = load(path)
		assert_true(scene != null, "la escena %s debe cargar sin errores" % path)
		var inst = scene.instantiate()
		assert_true(inst != null, "la escena %s debe instanciarse" % path)
		inst.free()
