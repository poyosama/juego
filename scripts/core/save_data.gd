class_name SaveData
extends RefCounted
## Representa el estado persistente guardable de una partida.

var player_position: Vector3 = Vector3.ZERO
var player_rotation_y: float = 0.0
var keys: Array = []
var fuses: Array = []
var unlocked_doors: Array = []
var triggered_scares: Array = []
var power_restored: bool = false


func to_dict() -> Dictionary:
	return {
		"pos": [player_position.x, player_position.y, player_position.z],
		"rot_y": player_rotation_y,
		"keys": keys.duplicate(),
		"fuses": fuses.duplicate(),
		"unlocked_doors": unlocked_doors.duplicate(),
		"triggered_scares": triggered_scares.duplicate(),
		"power_restored": power_restored
	}


static func from_dict(dict: Dictionary) -> RefCounted:
	var script: GDScript = load("res://scripts/core/save_data.gd")
	var s = script.new()
	if dict.has("pos") and dict["pos"] is Array and dict["pos"].size() >= 3:
		s.player_position = Vector3(dict["pos"][0], dict["pos"][1], dict["pos"][2])
	s.player_rotation_y = dict.get("rot_y", 0.0)

	if dict.has("keys"):
		for k in dict["keys"]:
			s.keys.append(str(k))
	if dict.has("fuses"):
		for f in dict["fuses"]:
			s.fuses.append(str(f))
	if dict.has("unlocked_doors"):
		for d in dict["unlocked_doors"]:
			s.unlocked_doors.append(str(d))
	if dict.has("triggered_scares"):
		for sc in dict["triggered_scares"]:
			s.triggered_scares.append(str(sc))
	s.power_restored = dict.get("power_restored", false)
	return s
