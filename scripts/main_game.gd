extends Control

const HouseLayoutScript = preload("res://scripts/core/house_layout.gd")
const ObjectiveScript = preload("res://scripts/core/objective.gd")
const SaveDataScript = preload("res://scripts/core/save_data.gd")
const DoorScript = preload("res://scripts/world/door.gd")
const PickupScript = preload("res://scripts/world/pickup.gd")
const AnswerMachineScript = preload("res://scripts/world/answer_machine.gd")
const ScareTriggerScript = preload("res://scripts/world/scare_trigger.gd")
const FuseBoxScript = preload("res://scripts/world/fuse_box.gd")
const MainExitScript = preload("res://scripts/world/main_exit.gd")

@onready var viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var house_builder: Node3D = $SubViewportContainer/SubViewport/HouseBuilder
@onready var player: CharacterBody3D = $SubViewportContainer/SubViewport/Player
@onready var enemy: CharacterBody3D = $SubViewportContainer/SubViewport/Enemy
@onready var ambient_music: AudioStreamPlayer = $AmbientMusic
@onready var heartbeat_player: AudioStreamPlayer = $HeartbeatPlayer

# UI y HUD
@onready var vhs_overlay: Control = $VHSOverlay
@onready var lbl_prompt: Label = $HUD/LblPrompt
@onready var stamina_bar: ProgressBar = $HUD/StaminaBar
@onready var lbl_fuses: Label = $HUD/LblFuses
@onready var lbl_keys: Label = $HUD/LblKeys
@onready var lbl_subtitles: Label = $HUD/LblSubtitles
@onready var lbl_save_indicator: Label = $HUD/LblSaveIndicator
@onready var pause_menu: Control = $PauseMenu
@onready var jumpscare_layer: ColorRect = $JumpscareLayer
@onready var ending_screen: Control = $EndingScreen
@onready var btn_ending_menu: Button = $EndingScreen/VBox/BtnMenu

var objective = ObjectiveScript.new()
var layout: Dictionary
var _save_timer: float = 0.0
var _is_dead: bool = false
var _has_escaped: bool = false


func _ready() -> void:
	if Game:
		Game.set("objective", objective)

	layout = HouseLayoutScript.get_default_layout()

	# 1. Construir la casa
	if house_builder:
		house_builder.build_house(layout)

	# 2. Configurar jugador y enemigo
	var spawn_pos: Vector3 = layout.get("player_spawn", Vector3(0, 0.5, 3))
	if player:
		player.global_position = spawn_pos
		player.stamina_changed.connect(_on_stamina_changed)

	if enemy:
		enemy.global_position = layout.get("enemy_spawn", Vector3(6, 0.5, -6))
		enemy.setup(player, layout.get("patrol_points", []))
		enemy.proximity_updated.connect(_on_enemy_proximity)
		enemy.player_caught.connect(_on_player_caught)

	# 3. Conectar eventos de la casa
	_connect_world_events()

	# 4. Iniciar audio ambiente
	_start_ambient_audio()

	# 5. Cargar partida si existe
	if Game and not Game.current_save_data.is_empty():
		_restore_save_data(Game.current_save_data)

	if btn_ending_menu:
		btn_ending_menu.pressed.connect(func():
			get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
		)

	_update_hud()
	trigger_autosave()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not _is_dead and not _has_escaped:
			if pause_menu.visible:
				pause_menu.close()
			else:
				pause_menu.open()


func _process(delta: float) -> void:
	if _save_timer > 0.0:
		_save_timer -= delta
		if _save_timer <= 0.0 and lbl_save_indicator:
			lbl_save_indicator.hide()

	# Actualizar prompt de interacción
	if player and lbl_prompt and not _is_dead:
		var target = player.get_interaction_target()
		if target and target.has_method("get_prompt"):
			lbl_prompt.text = target.get_prompt()
			lbl_prompt.show()
		else:
			lbl_prompt.hide()


func _connect_world_events() -> void:
	if not house_builder:
		return

	for child in house_builder.get_children():
		if child is DoorScript:
			child.door_unlocked.connect(func(_id): trigger_autosave())
		elif child is PickupScript:
			child.picked_up.connect(_on_item_picked_up)
		elif child is AnswerMachineScript:
			child.subtitle_changed.connect(_on_subtitle_changed)
			child.playback_finished.connect(func(): trigger_autosave())
		elif child is ScareTriggerScript:
			child.scare_triggered.connect(_on_scare_triggered)
		elif child is FuseBoxScript:
			child.power_restored.connect(_on_power_restored)
		elif child is MainExitScript:
			child.player_escaped.connect(_on_player_escaped)


func _on_item_picked_up(item_data: Dictionary) -> void:
	if btn_ending_menu:
		btn_ending_menu.pressed.connect(func():
			get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
		)

	_update_hud()
	trigger_autosave()


func _on_power_restored() -> void:
	objective.restore_power()
	if vhs_overlay:
		vhs_overlay.set_glitch(0.3)
	# Desbloquear puerta de salida
	for child in house_builder.get_children():
		if child is MainExitScript:
			child.unlock()

	_update_hud()
	trigger_autosave()


func _on_player_escaped() -> void:
	if _has_escaped:
		return
	_has_escaped = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if ending_screen:
		ending_screen.show()
	if Game:
		Game.delete_save()


func _on_stamina_changed(percent: float) -> void:
	if stamina_bar:
		stamina_bar.value = percent * 100.0


func _on_enemy_proximity(factor: float) -> void:
	if vhs_overlay:
		vhs_overlay.set_glitch(factor * 0.8)

	if heartbeat_player:
		if factor > 0.1:
			if not heartbeat_player.playing:
				heartbeat_player.play()
			heartbeat_player.pitch_scale = lerpf(0.8, 1.4, factor)
			heartbeat_player.volume_db = lerpf(-15.0, 2.0, factor)
		else:
			if heartbeat_player.playing:
				heartbeat_player.stop()


func _on_player_caught() -> void:
	if _is_dead:
		return
	_is_dead = true

	# Jumpscare feedback
	if jumpscare_layer:
		jumpscare_layer.show()
	if vhs_overlay:
		vhs_overlay.set_glitch(1.0)
	if SoundBank:
		var growl := SoundBank.get_sound("growl")
		if growl:
			var sfx := AudioStreamPlayer.new()
			sfx.stream = growl
			sfx.bus = &"SFX"
			add_child(sfx)
			sfx.play()

	# Recargar tras 2 segundos
	await get_tree().create_timer(2.0).timeout
	if Game and Game.has_save():
		Game.continue_game()
	else:
		get_tree().reload_current_scene()


func _on_subtitle_changed(text: String) -> void:
	if lbl_subtitles:
		lbl_subtitles.text = text
		if text.is_empty():
			lbl_subtitles.hide()
		else:
			lbl_subtitles.show()


func _on_scare_triggered(trig_id: String, s_type: String) -> void:
	if vhs_overlay:
		vhs_overlay.set_glitch(0.6)
		await get_tree().create_timer(0.4).timeout
		vhs_overlay.set_glitch(0.0)


func _update_hud() -> void:
	if lbl_fuses and objective:
		if objective.is_power_restored:
			lbl_fuses.text = "¡ENERGÍA RESTAURADA! Escapá por la puerta principal"
			lbl_fuses.modulate = Color(0.2, 1.0, 0.3)
		else:
			lbl_fuses.text = "Fusibles: %d / %d" % [objective.collected_fuses, objective.total_fuses_required]
			lbl_fuses.modulate = Color(1.0, 0.9, 0.3)

	if lbl_keys and player and player.inventory:
		var keys = player.inventory.get_keys()
		if keys.is_empty():
			lbl_keys.text = "Llaves: Ninguna"
		else:
			lbl_keys.text = "Llaves: " + ", ".join(keys)


func trigger_autosave() -> void:
	if not Game or not player:
		return
	var save := SaveDataScript.new()
	save.player_position = player.global_position
	save.player_rotation_y = player.rotation.y
	save.keys = player.inventory.get_keys() if player.inventory else []
	save.fuses = objective._collected_fuse_ids if objective else []
	save.power_restored = objective.is_power_restored if objective else false

	for child in house_builder.get_children():
		if child is DoorScript and not child.is_locked:
			save.unlocked_doors.append(child.door_id)
		elif child is ScareTriggerScript and child.is_triggered:
			save.triggered_scares.append(child.trigger_id)

	Game.save_game(save.to_dict())

	if lbl_save_indicator:
		lbl_save_indicator.show()
		_save_timer = 2.0


func _restore_save_data(dict: Dictionary) -> void:
	var save = SaveDataScript.from_dict(dict)
	if player and save.player_position != Vector3.ZERO:
		player.global_position = save.player_position
		player.rotation.y = save.player_rotation_y

	if player and player.inventory:
		for k in save.keys:
			player.inventory.add_key(k)

	if objective:
		for f in save.fuses:
			objective.add_fuse(f)
		if save.power_restored:
			_on_power_restored()

	# Restaurar estado de puertas y sustos
	for child in house_builder.get_children():
		if child is DoorScript and save.unlocked_doors.has(child.door_id):
			child.is_locked = false
		elif child is ScareTriggerScript and save.triggered_scares.has(child.trigger_id):
			child.is_triggered = true
		elif child is PickupScript:
			if save.keys.has(child.item_id) or save.fuses.has(child.item_id):
				child.queue_free()


func _start_ambient_audio() -> void:
	if ambient_music and SoundBank:
		var amb := SoundBank.get_sound("ambient")
		if amb:
			ambient_music.stream = amb
			ambient_music.bus = &"Music"
			ambient_music.play()

	if heartbeat_player and SoundBank:
		var hb := SoundBank.get_sound("heartbeat")
		if hb:
			heartbeat_player.stream = hb
			heartbeat_player.bus = &"SFX"
