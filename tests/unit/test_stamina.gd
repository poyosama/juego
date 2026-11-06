extends "res://tests/test_case.gd"

const Stamina = preload("res://scripts/core/stamina.gd")


func test_stamina_initial_state() -> void:
	var s = Stamina.new()
	assert_eq(s.current, 100.0, "stamina inicial debe ser 100")
	assert_false(s.is_exhausted, "no debe arrancar exhausto")
	assert_true(s.can_sprint(), "debe poder correr al inicio")


func test_stamina_drain_and_exhaustion() -> void:
	var s = Stamina.new(100.0, 50.0, 25.0, 1.0, 0.3) # max 100, drain 50/s, recovery 25/s, delay 1s, threshold 0.3
	s.drain(1.0) # pasa 1 segundo -> baja 50 -> queda 50
	assert_almost(s.current, 50.0, 0.01, "tras 1s de drain a 50/s debe quedar 50")
	assert_false(s.is_exhausted, "no debe estar exhausto con 50%")
	assert_true(s.can_sprint(), "puede correr con 50%")

	s.drain(1.0) # pasa otro segundo -> baja 50 -> llega a 0
	assert_almost(s.current, 0.0, 0.01, "llega a 0")
	assert_true(s.is_exhausted, "debe marcarse exhausto al llegar a 0")
	assert_false(s.can_sprint(), "no debe poder correr cuando esta exhausto")


func test_stamina_recovery_threshold() -> void:
	var s = Stamina.new(100.0, 50.0, 20.0, 1.0, 0.3)
	s.drain(2.0) # agota a 0
	assert_true(s.is_exhausted)

	# Mientras transcurre el delay (1.0s), no debe recuperar
	s.tick_recovery(0.5)
	assert_almost(s.current, 0.0, 0.01, "durante delay no recupera")

	# Pasa el segundo completo de delay
	s.tick_recovery(0.6) # 1.1s total -> delay superado, recupera 0.1s * 20 = 2
	assert_true(s.current > 0.0, "debe empezar a recuperar tras delay")
	assert_false(s.can_sprint(), "no puede correr antes del umbral del 30%")

	# Simular recuperación hasta llegar a 35 (supera 30%)
	s.tick_recovery(1.7) # 1.7 * 20 = 34 + 2 = 36 >= 30
	assert_false(s.is_exhausted, "debe salir de exhausto al superar 30%")
	assert_true(s.can_sprint(), "debe volver a poder correr")


func test_stamina_cap_and_percent() -> void:
	var s = Stamina.new(100.0, 20.0, 50.0, 0.0, 0.3)
	s.drain(1.0) # 80 left
	assert_almost(s.get_percent(), 0.8, 0.01)
	s.tick_recovery(2.0) # should cap at 100
	assert_almost(s.current, 100.0, 0.01, "no debe superar el maximo")
	assert_almost(s.get_percent(), 1.0, 0.01)

