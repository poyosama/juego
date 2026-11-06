extends SceneTree
## Runner de tests headless.
## Uso: godot --headless --path . -s res://tests/run_tests.gd
## Sale con código 0 si todo pasa y 1 si algo falla.

const UNIT_DIR := "res://tests/unit/"


func _initialize() -> void:
	var files: Array[String] = []
	for f in DirAccess.get_files_at(UNIT_DIR):
		if f.begins_with("test_") and f.ends_with(".gd"):
			files.append(f)
	files.sort()

	var total := 0
	var failed := 0
	for f in files:
		var script: GDScript = load(UNIT_DIR + f)
		if script == null or not script.can_instantiate():
			print("[FAIL] %s no compila" % f)
			failed += 1
			total += 1
			continue
		for m in script.get_script_method_list():
			var name: String = m["name"]
			if not name.begins_with("test_"):
				continue
			total += 1
			var inst = script.new()
			inst.current_test = name
			inst.call(name)
			if inst.failures.is_empty():
				print("  ok   %s :: %s" % [f, name])
			else:
				failed += 1
				for msg in inst.failures:
					print("[FAIL] %s :: %s" % [f, msg])

	print("\n%d tests, %d fallidos" % [total, failed])
	quit(1 if failed > 0 else 0)
