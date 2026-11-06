extends "res://tests/test_case.gd"

const ToneSynthScript = preload("res://scripts/synth/tone_synth.gd")


func test_tone_synth_generates_valid_wav() -> void:
	var tone = ToneSynthScript.generate_tone(440.0, 0.5, 22050)
	assert_true(tone != null, "debe generar AudioStreamWAV")
	assert_eq(tone.format, AudioStreamWAV.FORMAT_16_BITS)
	assert_eq(tone.mix_rate, 22050)
	assert_false(tone.stereo)
	# 0.5 seg * 22050 muestras * 2 bytes por muestra = 22050 bytes
	assert_eq(tone.data.size(), int(0.5 * 22050) * 2)

	var noise = ToneSynthScript.generate_noise(0.2, 22050, 0.05)
	assert_true(noise != null)
	assert_eq(noise.data.size(), int(0.2 * 22050) * 2)

	var ambient = ToneSynthScript.generate_ambient_loop(2.0, 22050)
	assert_true(ambient != null)
	assert_eq(ambient.loop_mode, AudioStreamWAV.LOOP_FORWARD, "ambiente debe tener loop forward")
	assert_eq(ambient.loop_begin, 0)
	assert_eq(ambient.loop_end, int(2.0 * 22050))
