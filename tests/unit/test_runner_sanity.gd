extends "res://tests/test_case.gd"


func test_assertions_work() -> void:
	assert_eq(1 + 1, 2, "suma")
	assert_almost(0.1 + 0.2, 0.3, 0.0001, "flotantes")
