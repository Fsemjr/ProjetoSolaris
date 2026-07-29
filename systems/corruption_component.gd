class_name CorruptionComponent
extends Node

signal corrupted_light_changed(current: float, maximum: float)
signal instability_changed(current: float, maximum: float)
signal instability_level_changed(level: int)

@export var maximum_corrupted_light: float = 100.0
@export var maximum_instability: float = 100.0
@export var instability_level_one_threshold: float = 70.0
@export var instability_level_two_threshold: float = 90.0
@export var corrupted_light_per_bonus_step: float = 20.0
@export var damage_bonus_per_step: float = 0.05

var corrupted_light: float = 0.0
var instability: float = 0.0

var _current_instability_level: int = 0


func _ready() -> void:
	maximum_corrupted_light = maxf(maximum_corrupted_light, 0.0)
	maximum_instability = maxf(maximum_instability, 0.0)
	corrupted_light = clampf(
		corrupted_light,
		0.0,
		maximum_corrupted_light
	)
	instability = clampf(instability, 0.0, maximum_instability)
	_current_instability_level = get_instability_level()


func absorb(light_amount: float, instability_amount: float) -> void:
	if light_amount > 0.0:
		_set_corrupted_light(corrupted_light + light_amount)
	if instability_amount > 0.0:
		_set_instability(instability + instability_amount)


func reset_temporary_power() -> void:
	_set_corrupted_light(0.0)
	_set_instability(0.0)


func get_damage_multiplier() -> float:
	var bonus_steps: int = floori(
		corrupted_light / maxf(corrupted_light_per_bonus_step, 0.001)
	)
	return 1.0 + float(bonus_steps) * maxf(damage_bonus_per_step, 0.0)


func get_instability_level() -> int:
	if instability >= instability_level_two_threshold:
		return 2
	if instability >= instability_level_one_threshold:
		return 1
	return 0


func _set_corrupted_light(new_value: float) -> void:
	var clamped_value: float = clampf(
		new_value,
		0.0,
		maximum_corrupted_light
	)
	if clamped_value == corrupted_light:
		return

	corrupted_light = clamped_value
	corrupted_light_changed.emit(
		corrupted_light,
		maximum_corrupted_light
	)


func _set_instability(new_value: float) -> void:
	var clamped_value: float = clampf(
		new_value,
		0.0,
		maximum_instability
	)
	if clamped_value == instability:
		return

	instability = clamped_value
	instability_changed.emit(instability, maximum_instability)
	_update_instability_level()


func _update_instability_level() -> void:
	var new_level: int = get_instability_level()
	if new_level == _current_instability_level:
		return

	_current_instability_level = new_level
	instability_level_changed.emit(_current_instability_level)
