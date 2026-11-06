extends Control

signal resumed

@onready var btn_resume: Button = $Panel/VBox/BtnResume
@onready var btn_options: Button = $Panel/VBox/BtnOptions
@onready var btn_quit: Button = $Panel/VBox/BtnQuit
@onready var options_menu: Control = $OptionsMenu


func _ready() -> void:
	btn_resume.pressed.connect(_on_resume_pressed)
	btn_options.pressed.connect(_on_options_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)


func open() -> void:
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close() -> void:
	hide()
	if options_menu:
		options_menu.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	resumed.emit()


func _on_resume_pressed() -> void:
	close()


func _on_options_pressed() -> void:
	if options_menu:
		options_menu.show()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
