class_name Inventory
extends RefCounted
## Inventario de llaves y elementos del jugador.

var _keys: Array[String] = []


func add_key(key_id: String) -> void:
	if not _keys.has(key_id):
		_keys.append(key_id)


func has_key(key_id: String) -> bool:
	return _keys.has(key_id)


func get_keys() -> Array[String]:
	return _keys.duplicate()


func serialize() -> Dictionary:
	return {
		"keys": _keys.duplicate()
	}


func deserialize(data: Dictionary) -> void:
	_keys.clear()
	if data.has("keys"):
		for k in data["keys"]:
			_keys.append(str(k))
