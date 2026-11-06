class_name ToneSynth
extends RefCounted
## Generador de AudioStreamWAV procedurasles de 16 bits mono en memoria.

static func generate_tone(freq: float, duration: float, sample_rate: int = 22050, attack: float = 0.01, decay: float = 0.05) -> AudioStreamWAV:
	var total_samples := int(duration * sample_rate)
	var byte_array := PackedByteArray()
	byte_array.resize(total_samples * 2)

	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		# Envolvente simple attack / decay
		var env := 1.0
		if t < attack and attack > 0.0:
			env = t / attack
		elif t > duration - decay and decay > 0.0:
			env = maxf(0.0, (duration - t) / decay)

		var val := sin(TAU * freq * t) * env
		var sample_int := int(clampf(val, -1.0, 1.0) * 32767.0)
		byte_array.encode_s16(i * 2, sample_int)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = byte_array
	return wav


static func generate_noise(duration: float, sample_rate: int = 22050, decay: float = 0.0) -> AudioStreamWAV:
	var total_samples := int(duration * sample_rate)
	var byte_array := PackedByteArray()
	byte_array.resize(total_samples * 2)

	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		var env := 1.0
		if decay > 0.0 and t > duration - decay:
			env = maxf(0.0, (duration - t) / decay)
		var val := (randf() * 2.0 - 1.0) * env
		var sample_int := int(clampf(val, -1.0, 1.0) * 32767.0)
		byte_array.encode_s16(i * 2, sample_int)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = byte_array
	return wav


static func generate_ambient_loop(duration: float = 4.0, sample_rate: int = 22050) -> AudioStreamWAV:
	var total_samples := int(duration * sample_rate)
	var byte_array := PackedByteArray()
	byte_array.resize(total_samples * 2)

	for i in range(total_samples):
		var t := float(i) / float(sample_rate)
		# Drone grave + siseo leve
		var drone := sin(TAU * 55.0 * t) * 0.4 + sin(TAU * 110.0 * t) * 0.2
		var hiss := (randf() * 2.0 - 1.0) * 0.05
		var val := drone + hiss
		var sample_int := int(clampf(val, -1.0, 1.0) * 32767.0)
		byte_array.encode_s16(i * 2, sample_int)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_samples
	wav.data = byte_array
	return wav
