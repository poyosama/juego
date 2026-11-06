extends Control

@onready var btn_continue: Button = $VBoxContainer/BtnContinue
@onready var btn_new_game: Button = $VBoxContainer/BtnNewGame
@onready var btn_options: Button = $VBoxContainer/BtnOptions
@onready var btn_quit: Button = $VBoxContainer/BtnQuit
@onready var options_menu: Control = $OptionsMenu


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if btn_continue:
		btn_continue.disabled = not Game.has_save()
		btn_continue.pressed.connect(_on_continue_pressed)
	if btn_new_game:
		btn_new_game.pressed.connect(_on_new_game_pressed)
	if btn_options:
		btn_options.pressed.connect(_on_options_pressed)
	if btn_quit:
		btn_quit.pressed.connect(_on_quit_pressed)


func _on_options_pressed() -> void:
	if options_menu:
		options_menu.show()


func _on_new_game_pressed() -> void:
	Game.start_new_game()


func _on_continue_pressed() -> void:
	Game.continue_game()


func _on_quit_pressed() -> void:
	get_tree().quit()
