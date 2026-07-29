class_name HurtboxComponent
extends Area2D

signal damage_received(amount: float, source: Node)

@export var health_component: HealthComponent
@export var incoming_damage_multiplier: float = 1.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func receive_hit(hitbox: HitboxComponent) -> void:
	if hitbox == null or not is_instance_valid(hitbox):
		return
	if health_component == null or not is_instance_valid(health_component):
		return

	var damage_target: Node = health_component.get_parent()
	if damage_target == null or not hitbox.can_hit(damage_target):
		return

	var previous_health: float = health_component.current_health
	var valid_damage_multiplier: float = maxf(
		incoming_damage_multiplier,
		0.0
	)
	var final_damage: float = maxf(
		hitbox.damage * valid_damage_multiplier,
		0.0
	)
	hitbox.register_hit(damage_target)
	health_component.take_damage(final_damage)

	var applied_damage: float = previous_health - health_component.current_health
	if applied_damage > 0.0:
		damage_received.emit(applied_damage, hitbox.attack_owner)


func _on_area_entered(area: Area2D) -> void:
	var hitbox: HitboxComponent = area as HitboxComponent
	if hitbox != null:
		receive_hit(hitbox)
