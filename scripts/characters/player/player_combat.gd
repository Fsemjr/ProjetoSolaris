extends Node2D

@export var base_damage: float = 20.0
@export var attack_cooldown: float = 0.5
@export var attack_duration: float = 0.15

@onready var scythe_visual: Line2D = $ScytheVisual
@onready var scythe_trail: Line2D = $ScytheTrail
@onready var attack_hitbox: HitboxComponent = $AttackHitbox
@onready var attack_collision: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_cooldown_timer: Timer = $"../../AttackCooldown"
@onready var attack_owner_node: Node = $"../.."
@onready var corruption_component: CorruptionComponent = (
	get_node_or_null(^"../../CorruptionComponent") as CorruptionComponent
)

var is_attacking: bool = false
var is_on_cooldown: bool = false
var is_dead: bool = false
var is_completed: bool = false
var is_reading_memory: bool = false
var current_attack_damage: float = 0.0


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	attack_cooldown_timer.wait_time = attack_cooldown
	_set_hitbox_active(false)
	_set_scythe_trail_visible(false)


func _process(_delta: float) -> void:
	if is_dead or is_completed or is_reading_memory:
		return

	if not is_attacking:
		_update_aim(get_global_mouse_position())

	if Input.is_action_just_pressed(&"attack_primary"):
		_try_attack()


func _update_aim(mouse_position: Vector2) -> void:
	var aim_direction: Vector2 = global_position.direction_to(mouse_position)
	if aim_direction != Vector2.ZERO:
		global_rotation = aim_direction.angle()


func _try_attack() -> void:
	if (
		is_dead
		or is_completed
		or is_reading_memory
		or is_attacking
		or is_on_cooldown
	):
		return

	is_attacking = true
	is_on_cooldown = true
	current_attack_damage = _calculate_attack_damage()
	attack_cooldown_timer.start(maxf(attack_cooldown, 0.001))
	_set_scythe_trail_visible(true)

	var playback_speed: float = 1.0 / maxf(attack_duration, 0.001)
	animation_player.play(&"attack", -1.0, playback_speed)


func _set_hitbox_active(is_active: bool) -> void:
	var should_activate: bool = (
		is_active
		and not is_dead
		and not is_completed
		and not is_reading_memory
	)
	if should_activate:
		attack_hitbox.begin_attack(current_attack_damage, attack_owner_node)
	else:
		attack_hitbox.end_attack()
	attack_collision.set_deferred(&"disabled", not should_activate)


func _calculate_attack_damage() -> float:
	var damage_multiplier: float = 1.0
	if (
		corruption_component != null
		and is_instance_valid(corruption_component)
	):
		damage_multiplier = corruption_component.get_damage_multiplier()
	return base_damage * damage_multiplier


func _finish_attack() -> void:
	_set_hitbox_active(false)
	_set_scythe_trail_visible(false)
	scythe_visual.rotation = 0.0
	attack_hitbox.rotation = 0.0
	is_attacking = false


func _set_scythe_trail_visible(should_show: bool) -> void:
	scythe_trail.visible = (
		should_show
		and not is_dead
		and not is_completed
		and not is_reading_memory
	)


func enter_dead_state() -> void:
	if is_dead:
		return

	is_dead = true
	set_process(false)
	attack_cooldown_timer.stop()
	is_on_cooldown = false
	animation_player.stop()
	_finish_attack()
	_set_scythe_trail_visible(false)


func exit_dead_state() -> void:
	if not is_dead:
		return

	attack_cooldown_timer.stop()
	animation_player.stop()
	_finish_attack()
	_set_scythe_trail_visible(false)
	is_on_cooldown = false
	is_dead = false
	set_process(true)


func enter_completed_state() -> void:
	if is_completed:
		return
	is_completed = true
	set_process(false)
	attack_cooldown_timer.stop()
	is_on_cooldown = false
	animation_player.stop()
	_finish_attack()
	_set_scythe_trail_visible(false)


func enter_reading_memory_state() -> bool:
	if is_dead or is_completed or is_reading_memory:
		return false
	is_reading_memory = true
	set_process(false)
	attack_cooldown_timer.stop()
	is_on_cooldown = false
	animation_player.stop()
	_finish_attack()
	_set_scythe_trail_visible(false)
	return true


func exit_reading_memory_state() -> void:
	if not is_reading_memory or is_dead or is_completed:
		return
	attack_cooldown_timer.stop()
	animation_player.stop()
	_finish_attack()
	_set_scythe_trail_visible(false)
	is_on_cooldown = false
	is_reading_memory = false
	set_process(true)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == &"attack":
		_finish_attack()


func _on_attack_cooldown_timeout() -> void:
	if is_dead or is_completed:
		return
	is_on_cooldown = false


func _exit_tree() -> void:
	_finish_attack()
