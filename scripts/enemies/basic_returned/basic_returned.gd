extends CharacterBody2D

signal enemy_died(enemy: Node2D, death_position: Vector2)

enum State {
	IDLE,
	CHASE,
	ATTACK,
	DEAD,
}

@export var movement_speed: float = 110.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var death_removal_delay: float = 0.5
@export_range(0.1, 0.2, 0.01) var damage_flash_duration: float = 0.15
@export var corrupted_light_core_scene: PackedScene
@export var spawn_id: StringName = &""

@onready var visuals: Node2D = $Visuals
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $Hurtbox
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_collision: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_area_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_hitbox: HitboxComponent = $AttackArea/AttackHitbox
@onready var attack_collision: CollisionShape2D = $AttackArea/AttackHitbox/CollisionShape2D
@onready var attack_cooldown_timer: Timer = $AttackCooldown
@onready var attack_duration_timer: Timer = $AttackDuration
@onready var death_removal_timer: Timer = $DeathRemoval

var current_state: State = State.IDLE
var chase_target: CharacterBody2D = null
var is_target_in_attack_range: bool = false
var death_position: Vector2 = Vector2.ZERO
var has_died: bool = false
var has_dropped_corrupted_light_core: bool = false
var has_started_death_removal: bool = false
var _initial_collision_layer: int = 0
var _initial_collision_mask: int = 0
var _last_health: float = 0.0
var _damage_flash_tween: Tween = null


func _ready() -> void:
	_initial_collision_layer = collision_layer
	_initial_collision_mask = collision_mask
	hurtbox_component.health_component = health_component
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	attack_duration_timer.timeout.connect(_on_attack_duration_timeout)
	death_removal_timer.timeout.connect(_on_death_removal_timeout)
	attack_cooldown_timer.wait_time = attack_cooldown
	death_removal_timer.wait_time = death_removal_delay
	_end_attack_window()
	velocity = Vector2.ZERO
	_last_health = health_component.current_health


func reset_enemy(spawn_transform: Transform2D) -> void:
	attack_cooldown_timer.stop()
	attack_duration_timer.stop()
	death_removal_timer.stop()
	_end_attack_window()
	_stop_damage_flash()

	has_died = false
	has_dropped_corrupted_light_core = false
	has_started_death_removal = false
	death_position = Vector2.ZERO
	chase_target = null
	is_target_in_attack_range = false
	velocity = Vector2.ZERO
	global_transform = spawn_transform

	health_component.restore_full_health()
	_last_health = health_component.current_health
	collision_layer = _initial_collision_layer
	collision_mask = _initial_collision_mask
	body_collision.set_deferred(&"disabled", false)
	_restore_area(hurtbox_component, hurtbox_collision, true, true, false)
	_restore_area(detection_area, detection_collision, true, false, false)
	_restore_area(attack_area, attack_area_collision, true, false, false)
	_restore_area(attack_hitbox, attack_collision, false, false, true)

	visuals.modulate = Color.WHITE
	current_state = State.IDLE
	set_physics_process(true)


func _restore_area(
	area: Area2D,
	collision: CollisionShape2D,
	should_monitor: bool,
	should_be_monitorable: bool,
	collision_disabled: bool
) -> void:
	area.set_deferred(&"monitoring", should_monitor)
	area.set_deferred(&"monitorable", should_be_monitorable)
	collision.set_deferred(&"disabled", collision_disabled)


func _physics_process(_delta: float) -> void:
	match current_state:
		State.CHASE:
			_chase_player()
		State.ATTACK:
			velocity = Vector2.ZERO
			_try_attack()
		State.IDLE, State.DEAD:
			velocity = Vector2.ZERO

	move_and_slide()


func _chase_player() -> void:
	if chase_target == null or not is_instance_valid(chase_target):
		_enter_idle()
		return
	if is_target_in_attack_range:
		current_state = State.ATTACK
		velocity = Vector2.ZERO
		return

	var direction: Vector2 = (
		chase_target.global_position - global_position
	).normalized()
	velocity = direction * movement_speed


func _enter_idle() -> void:
	_cancel_attack()
	current_state = State.IDLE
	chase_target = null
	is_target_in_attack_range = false
	velocity = Vector2.ZERO


func _on_detection_area_body_entered(body: Node2D) -> void:
	if current_state == State.DEAD:
		return

	var detected_player: CharacterBody2D = body as CharacterBody2D
	if detected_player == null:
		return

	chase_target = detected_player
	current_state = State.ATTACK if is_target_in_attack_range else State.CHASE


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body != chase_target or current_state == State.DEAD:
		return

	_enter_idle()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if current_state == State.DEAD:
		return

	var detected_player: CharacterBody2D = body as CharacterBody2D
	if detected_player == null:
		return

	chase_target = detected_player
	is_target_in_attack_range = true
	current_state = State.ATTACK
	velocity = Vector2.ZERO


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body != chase_target or current_state == State.DEAD:
		return

	is_target_in_attack_range = false
	_cancel_attack()
	if detection_area.overlaps_body(body):
		current_state = State.CHASE
	else:
		_enter_idle()


func _try_attack() -> void:
	if current_state != State.ATTACK or not is_target_in_attack_range:
		return
	if not attack_cooldown_timer.is_stopped() or not attack_duration_timer.is_stopped():
		return
	if chase_target == null or not is_instance_valid(chase_target):
		_enter_idle()
		return

	attack_hitbox.begin_attack(attack_damage, self)
	attack_collision.set_deferred(&"disabled", false)
	attack_duration_timer.start()
	attack_cooldown_timer.start(maxf(attack_cooldown, 0.001))


func _cancel_attack() -> void:
	attack_duration_timer.stop()
	_end_attack_window()


func _end_attack_window() -> void:
	attack_hitbox.end_attack()
	attack_collision.set_deferred(&"disabled", true)


func _on_attack_duration_timeout() -> void:
	_end_attack_window()


func _on_health_changed(
	current_health: float,
	_maximum_health: float
) -> void:
	if current_health < _last_health and current_state != State.DEAD:
		_play_damage_flash()
	_last_health = current_health


func _play_damage_flash() -> void:
	_stop_damage_flash()
	visuals.modulate = Color(1.4, 0.45, 0.45, 1.0)
	_damage_flash_tween = create_tween()
	_damage_flash_tween.tween_property(
		visuals,
		^"modulate",
		Color.WHITE,
		damage_flash_duration
	)
	_damage_flash_tween.tween_callback(_clear_damage_flash_tween)


func _stop_damage_flash() -> void:
	if _damage_flash_tween != null and _damage_flash_tween.is_valid():
		_damage_flash_tween.kill()
	_damage_flash_tween = null
	visuals.modulate = Color.WHITE


func _clear_damage_flash_tween() -> void:
	_damage_flash_tween = null


func _on_died() -> void:
	if has_died:
		return

	_stop_damage_flash()
	has_died = true
	current_state = State.DEAD
	death_position = global_position
	chase_target = null
	is_target_in_attack_range = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	attack_cooldown_timer.stop()
	_cancel_attack()
	_disable_collisions()
	_apply_death_feedback()
	call_deferred(&"_emit_death_and_start_removal")


func _emit_death_and_start_removal() -> void:
	if not has_died or has_started_death_removal:
		return

	has_started_death_removal = true
	enemy_died.emit(self, death_position)
	death_removal_timer.start(maxf(death_removal_delay, 0.001))


func claim_corrupted_light_core_scene() -> PackedScene:
	if not has_died or has_dropped_corrupted_light_core:
		return null
	if corrupted_light_core_scene == null:
		return null

	has_dropped_corrupted_light_core = true
	return corrupted_light_core_scene


func _disable_collisions() -> void:
	set_deferred(&"collision_layer", 0)
	set_deferred(&"collision_mask", 0)
	body_collision.set_deferred(&"disabled", true)

	_disable_area(hurtbox_component, hurtbox_collision)
	_disable_area(detection_area, detection_collision)
	_disable_area(attack_area, attack_area_collision)
	_disable_area(attack_hitbox, attack_collision)


func _disable_area(area: Area2D, collision: CollisionShape2D) -> void:
	area.set_deferred(&"monitoring", false)
	area.set_deferred(&"monitorable", false)
	collision.set_deferred(&"disabled", true)


func _apply_death_feedback() -> void:
	var faded_color: Color = visuals.modulate
	faded_color.a = 0.35
	visuals.modulate = faded_color


func _on_death_removal_timeout() -> void:
	if current_state == State.DEAD and has_died:
		queue_free()


func _exit_tree() -> void:
	if _damage_flash_tween != null and _damage_flash_tween.is_valid():
		_damage_flash_tween.kill()
