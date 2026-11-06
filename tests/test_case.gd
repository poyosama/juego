extends RefCounted
## Clase base para tests. Cada archivo tests/unit/test_*.gd la extiende
## y define métodos que empiezan con "test_".

var failures: Array[String] = []
var current_test := ""


func fail(msg: String) -> void:
	failures.append("%s: %s" % [current_test, msg])


func assert_true(cond: bool, msg := "se esperaba true") -> void:
	if not cond:
		fail(msg)


func assert_false(cond: bool, msg := "se esperaba false") -> void:
	if cond:
		fail(msg)


func assert_eq(actual, expected, msg := "") -> void:
	if typeof(actual) != typeof(expected) or actual != expected:
		fail("%s (esperado %s, obtenido %s)" % [msg, str(expected), str(actual)])


func assert_almost(actual: float, expected: float, tolerance := 0.001, msg := "") -> void:
	if absf(actual - expected) > tolerance:
		fail("%s (esperado ~%s, obtenido %s)" % [msg, str(expected), str(actual)])
