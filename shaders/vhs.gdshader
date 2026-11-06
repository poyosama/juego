shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float aberration_amount : hint_range(0.0, 0.05) = 0.003;
uniform float noise_amount : hint_range(0.0, 0.3) = 0.06;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.18;
uniform float tracking_distortion : hint_range(0.0, 0.1) = 0.01;
uniform float tracking_speed : hint_range(0.1, 5.0) = 0.6;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.75;
uniform float brightness_mult : hint_range(0.5, 2.0) = 1.0;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;

// Generador de pseudo-ruido
float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// Línea de tracking VHS desplazándose verticalmente
	float tracking_line = sin(uv.y * 3.0 - TIME * tracking_speed);
	float tracking_bump = smoothstep(0.92, 1.0, tracking_line) * (tracking_distortion + glitch_intensity * 0.03);
	uv.x += tracking_bump * sin(uv.y * 100.0 + TIME * 10.0);

	// Distorsión horizontal extra cuando glitch_intensity es alto (cercanía del monstruo)
	if (glitch_intensity > 0.01) {
		float glitch_wave = sin(uv.y * 40.0 + TIME * 25.0) * glitch_intensity * 0.01;
		uv.x += glitch_wave;
	}

	// Aberración cromática (desfase R y B)
	float split = aberration_amount + glitch_intensity * 0.008;
	float r = texture(screen_texture, vec2(uv.x + split, uv.y)).r;
	float g = texture(screen_texture, vec2(uv.x, uv.y)).g;
	float b = texture(screen_texture, vec2(uv.x - split, uv.y)).b;
	vec3 col = vec3(r, g, b);

	// Ruido analógico animado
	float n = (random(uv + vec2(TIME * 0.05, -TIME * 0.05)) - 0.5) * (noise_amount + glitch_intensity * 0.1);
	col += vec3(n);

	// Scanlines de TV CRT / VHS
	float scanline = sin(SCREEN_UV.y * 540.0 * PI) * 0.5 + 0.5;
	col -= scanline * scanline_strength;

	// Viñeta en los bordes
	vec2 uv_vignette = SCREEN_UV * (1.0 - SCREEN_UV.yx);
	float vig = uv_vignette.x * uv_vignette.y * 15.0;
	vig = clamp(pow(vig, vignette_intensity), 0.0, 1.0);
	col *= vig;

	// Brillo global configurable
	col *= brightness_mult;

	// Tinte ligeramente violáceo / desaturado clásico PS2 / cinta desgastada
	vec3 desat = vec3(dot(col, vec3(0.299, 0.587, 0.114)));
	col = mix(desat, col, 0.85);
	col.b *= 1.04; // toque frío/azul violeta

	COLOR = vec4(col, 1.0);
}
