class_name HidingSpot
extends Area3D

@export var spot_id: String = ""
@export var spot_name: String = "Escondite"
@export var exit_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	collision_layer = 4 # Layer 3 = bit 4 (Interactable)
	collision_mask = 0


func get_prompt() -> String:
	return "[E] Esconderse en " + spot_name


func get_exit_position() -> Vector3:
	return exit_position if exit_position != Vector3.ZERO else global_position + Vector3(0, 0, 1)


func interact(player: Node) -> void:
	if player and player.has_method("enter_hiding"):
		player.enter_hiding(self)
