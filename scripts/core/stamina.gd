class_name Stamina
extends RefCounted
## Manejo de resistencia física y agotamiento.

var max_stamina: float = 100.0
var current: float = 100.0
var drain_rate: float = 25.0 # Unidades consumidas por segundo al correr
var recovery_rate: float = 20.0 # Unidades recuperadas por segundo tras delay
var recovery_delay: float = 1.0 # Segundos de espera tras dejar de correr
var exhaustion_threshold: float = 0.3 # 30% necesario para poder correr de nuevo tras agotarse

var is_exhausted: bool = false
var _time_since_drain: float = 0.0


func _init(
	p_max: float = 100.0,
	p_drain: float = 25.0,
	p_rec: float = 20.0,
	p_delay: float = 1.0,
	p_threshold: float = 0.3
) -> void:
	max_stamina = p_max
	current = p_max
	drain_rate = p_drain
	recovery_rate = p_rec
	recovery_delay = p_delay
	exhaustion_threshold = p_threshold


func can_sprint() -> bool:
	if is_exhausted:
		return false
	return current > 0.0


func drain(delta: float) -> void:
	_time_since_drain = 0.0
	current = maxf(0.0, current - drain_rate * delta)
	if current <= 0.001:
		current = 0.0
		is_exhausted = true


func tick_recovery(delta: float) -> void:
	_time_since_drain += delta
	if _time_since_drain < recovery_delay:
		return

	# Si ya pasó el delay, recuperamos el excedente
	var effective_time := delta
	if _time_since_drain - delta < recovery_delay:
		effective_time = _time_since_drain - recovery_delay

	current = minf(max_stamina, current + recovery_rate * effective_time)

	if is_exhausted and current >= max_stamina * exhaustion_threshold:
		is_exhausted = false


func get_percent() -> float:
	if max_stamina <= 0.0:
		return 0.0
	return current / max_stamina
