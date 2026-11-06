extends "res://tests/test_case.gd"

const ScareTriggerScript = preload("res://scripts/world/scare_trigger.gd")
const AnswerMachineScript = preload("res://scripts/world/answer_machine.gd")


func test_scare_trigger_once() -> void:
	var scare = ScareTriggerScript.new()
	scare.trigger_id = "test_scare"
	scare._ready()

	assert_false(scare.is_triggered)
	scare.trigger_scare()
	assert_true(scare.is_triggered, "debe marcarse como disparado")

	var triggered_again := false
	scare.scare_triggered.connect(func(_id, _type): triggered_again = true)
	scare.trigger_scare()
	assert_false(triggered_again, "no debe dispararse una segunda vez")

	scare.free()


func test_answer_machine_subtitles_advance() -> void:
	var machine = AnswerMachineScript.new()
	machine.subtitles = [
		{"time": 0.0, "text": "Hola"},
		{"time": 2.0, "text": "Mensaje importante"}
	]
	machine._ready()

	var captured := [""]
	machine.subtitle_changed.connect(func(txt): captured[0] = txt)

	machine.start_playback()
	assert_true(machine.is_playing)

	# Simular 0.5s -> primer subtítulo
	machine._process(0.5)
	assert_eq(captured[0], "Hola")

	# Simular 2.0s más (2.5s total) -> segundo subtítulo
	machine._process(2.0)
	assert_eq(captured[0], "Mensaje importante")

	# Simular 5.0s más -> debe finalizar
	machine._process(5.0)
	assert_false(machine.is_playing)
	assert_eq(captured[0], "")

	machine.free()
