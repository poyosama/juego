extends "res://tests/test_case.gd"


func test_vhs_shader_compiles() -> void:
	var shader: Shader = load("res://shaders/vhs.gdshader")
	assert_true(shader != null, "el shader vhs.gdshader debe cargar")

	var mat := ShaderMaterial.new()
	mat.shader = shader
	assert_true(mat.shader != null, "ShaderMaterial debe aceptar el shader")

	# Probar asignación de uniforms
	mat.set_shader_parameter("aberration_amount", 0.005)
	mat.set_shader_parameter("glitch_intensity", 0.5)
	mat.set_shader_parameter("brightness_mult", 1.2)
