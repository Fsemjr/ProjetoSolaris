class_name HitboxComponent
extends Area2D

@export var damage: float = 0.0

var attack_owner: Node = null
var hit_targets: Array[Node] = []
var is_attack_active: bool = false


func _ready() -> void:
	end_attack()


func begin_attack(new_damage: float, owner_node: Node) -> void:
	damage = maxf(new_damage, 0.0)
	attack_owner = owner_node
	hit_targets.clear()
	is_attack_active = true
	monitoring = true
	monitorable = true


func end_attack() -> void:
	is_attack_active = false
	set_deferred(&"monitoring", false)
	set_deferred(&"monitorable", false)


func can_hit(target: Node) -> bool:
	if not is_attack_active or damage <= 0.0:
		return false
	if target == null or not is_instance_valid(target):
		return false
	if attack_owner == null or not is_instance_valid(attack_owner):
		return false
	if (
		target == attack_owner
		or attack_owner.is_ancestor_of(target)
		or target.is_ancestor_of(attack_owner)
	):
		return false

	return not hit_targets.has(target)


func register_hit(target: Node) -> void:
	if can_hit(target):
		hit_targets.append(target)
