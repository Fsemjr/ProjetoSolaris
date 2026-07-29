class_name HealthComponent
extends Node

signal health_changed(current_health: float, maximum_health: float)
signal died

@export var maximum_health: float = 100.0

var current_health: float
var is_dead: bool = false


func _ready() -> void:
	maximum_health = maxf(maximum_health, 0.0)
	current_health = maximum_health


func take_damage(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return

	_set_current_health(current_health - amount)
	if current_health <= 0.0:
		is_dead = true
		died.emit()


func heal(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return

	_set_current_health(current_health + amount)


func restore_full_health() -> void:
	is_dead = false
	_set_current_health(maximum_health)


func _set_current_health(new_health: float) -> void:
	var clamped_health: float = clampf(new_health, 0.0, maximum_health)
	if clamped_health == current_health:
		return

	current_health = clamped_health
	health_changed.emit(current_health, maximum_health)
