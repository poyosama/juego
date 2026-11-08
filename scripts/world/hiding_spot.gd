class_name HidingSpot
extends StaticBody3D
## Mueble sólido donde el jugador se puede esconder (armario o debajo de la cama).

@export var spot_id: String = ""
@export var spot_name: String = "Escondite"
@export var kind: String = "closet" # "closet" o "bed"
@export var size: Vector3 = Vector3(1.2, 2.0, 1.0)
@export var exit_position: Vector3 = Vector3.ZERO

var occupant: Node = null


func _ready() -> void:
	collision_layer = 1 | 4 # World (sólido) + Interactable
	collision_mask = 0


func get_prompt() -> String:
	if occupant:
		return "[E] Salir del escondite"
	return "[E] Esconderse en " + spot_name


## Punto (global) donde queda la cámara del jugador mientras está escondido.
func get_camera_position() -> Vector3:
	var pos := global_position if is_inside_tree() else position
	var floor_y := pos.y - size.y * 0.5
	if kind == "bed":
		return Vector3(pos.x, floor_y + 0.25, pos.z)
	# Armario: a la altura de los ojos pero por debajo del techo del mueble
	return Vector3(pos.x, minf(floor_y + 1.5, pos.y + size.y * 0.5 - 0.2), pos.z)


func get_exit_position() -> Vector3:
	if exit_position != Vector3.ZERO:
		return exit_position
	var pos := global_position if is_inside_tree() else position
	return pos + Vector3(0, -size.y * 0.5 + 0.1, size.z * 0.5 + 0.8)


func interact(player: Node) -> void:
	if player == null:
		return
	if occupant == player and player.has_method("exit_hiding"):
		player.exit_hiding()
	elif occupant == null and player.has_method("enter_hiding"):
		player.enter_hiding(self)
