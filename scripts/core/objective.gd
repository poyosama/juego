class_name Objective
extends RefCounted
## Gestión del objetivo de fusibles y escape.

signal fuse_collected(count, total)
signal power_restored
signal escaped

var total_fuses_required: int = 5
var collected_fuses: int = 0
var is_power_restored: bool = false
var is_escaped: bool = false
var _collected_fuse_ids: Array[String] = []


func add_fuse(fuse_id: String) -> void:
	if not _collected_fuse_ids.has(fuse_id):
		_collected_fuse_ids.append(fuse_id)
		collected_fuses = _collected_fuse_ids.size()
		fuse_collected.emit(collected_fuses, total_fuses_required)


func restore_power() -> void:
	if collected_fuses >= total_fuses_required:
		is_power_restored = true
		power_restored.emit()


func can_escape() -> bool:
	return is_power_restored and collected_fuses >= total_fuses_required


func escape() -> void:
	if can_escape():
		is_escaped = true
		escaped.emit()


func serialize() -> Dictionary:
	return {
		"fuse_ids": _collected_fuse_ids.duplicate(),
		"power_restored": is_power_restored,
		"escaped": is_escaped
	}


func deserialize(data: Dictionary) -> void:
	_collected_fuse_ids.clear()
	if data.has("fuse_ids"):
		for id in data["fuse_ids"]:
			_collected_fuse_ids.append(str(id))
	collected_fuses = _collected_fuse_ids.size()
	is_power_restored = data.get("power_restored", false)
	is_escaped = data.get("escaped", false)
