extends "res://scripts/characters/player/player_movement.gd"

enum PlayerState {
	ACTIVE,
	DEAD,
	COMPLETED,
	READING_MEMORY,
}

signal player_respawned(respawn_position: Vector2)
signal player_died

@export var respawn_delay: float = 1.5
@export_range(0.1, 0.2, 0.01) var damage_flash_duration: float = 0.15

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $Hurtbox
@onready var hurtbox_collision: CollisionShape2D = (
	$Hurtbox/CollisionShape2D
)
@onready var corruption_component: CorruptionComponent = $CorruptionComponent
@onready var player_corruption: PlayerCorruption = $PlayerCorruption
@onready var combat_controller: Node2D = $Visuals/ScythePivot
@onready var collapse_damage_timer: Timer = $CollapseDamageTimer
@onready var respawn_delay_timer: Timer = $RespawnDelay
@onready var visuals: Node2D = $Visuals

var player_state: PlayerState = PlayerState.ACTIVE
var _death_registered: bool = false
var _respawn_pending: bool = false
var _initial_spawn_position: Vector2 = Vector2.ZERO
var _fallback_respawn_position: Vector2 = Vector2.ZERO
var _has_fallback_respawn_position: bool = false
var _damage_flash_tween: Tween = null


func _ready() -> void:
	super._ready()
	_initial_spawn_position = global_position
	respawn_delay_timer.wait_time = maxf(respawn_delay, 0.001)
	if not respawn_delay_timer.timeout.is_connected(
		_on_respawn_delay_timeout
	):
		respawn_delay_timer.timeout.connect(
			_on_respawn_delay_timeout
		)
	hurtbox_component.health_component = health_component
	if not hurtbox_component.damage_received.is_connected(
		_on_damage_received_visual
	):
		hurtbox_component.damage_received.connect(
			_on_damage_received_visual
		)
	health_component.died.connect(_on_died)
	dodge_started.connect(_on_dodge_started)
	dodge_ended.connect(_on_dodge_ended)
	if not GameState.arena_completed.is_connected(_on_arena_completed):
		GameState.arena_completed.connect(_on_arena_completed)
	if GameState.arena_is_completed:
		_on_arena_completed()


func set_fallback_respawn_position(position: Vector2) -> void:
	if not position.is_finite():
		push_warning("Player received an invalid PlayerSpawn position.")
		return

	_fallback_respawn_position = position
	_has_fallback_respawn_position = true


func _can_start_dodge() -> bool:
	return (
		super._can_start_dodge()
		and player_state == PlayerState.ACTIVE
		and not health_component.is_dead
		and not player_corruption.is_absorbing()
		and not bool(combat_controller.get(&"is_attacking"))
	)


func _on_dodge_started() -> void:
	combat_controller.set_process(false)


func _on_dodge_ended() -> void:
	if (
		not health_component.is_dead
		and not player_corruption.is_absorbing()
		and player_state == PlayerState.ACTIVE
	):
		combat_controller.set_process(true)


func _on_damage_received_visual(_amount: float, _source: Node) -> void:
	if player_state != PlayerState.ACTIVE:
		return

	_stop_damage_flash()
	visuals.modulate = Color(1.35, 0.45, 0.45, 1.0)
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
	if player_state != PlayerState.ACTIVE:
		return

	_stop_damage_flash()
	player_state = PlayerState.DEAD
	enter_dead_state()
	player_corruption.enter_dead_state()
	combat_controller.call(&"enter_dead_state")
	collapse_damage_timer.stop()
	hurtbox_component.incoming_damage_multiplier = 1.0
	velocity = Vector2.ZERO
	visuals.modulate.a = 0.5

	if not _death_registered:
		_death_registered = true
		GameState.register_death()

	player_died.emit()
	_respawn_pending = true
	respawn_delay_timer.start(maxf(respawn_delay, 0.001))


func _on_respawn_delay_timeout() -> void:
	if not _respawn_pending or player_state != PlayerState.DEAD:
		return

	_respawn_pending = false
	var respawn_position: Vector2 = _choose_respawn_position()
	global_position = respawn_position
	velocity = Vector2.ZERO
	health_component.restore_full_health()
	corruption_component.reset_temporary_power()
	collapse_damage_timer.stop()
	hurtbox_component.incoming_damage_multiplier = 1.0
	player_corruption.exit_dead_state()
	combat_controller.call(&"exit_dead_state")
	exit_dead_state()
	_stop_damage_flash()
	player_state = PlayerState.ACTIVE
	_death_registered = false
	player_respawned.emit(respawn_position)


func _choose_respawn_position() -> Vector2:
	if (
		GameState.has_respawn_point
		and GameState.current_respawn_position.is_finite()
	):
		return GameState.current_respawn_position
	if _has_fallback_respawn_position:
		return _fallback_respawn_position

	push_warning(
		"PlayerSpawn is unavailable; using the player's initial position."
	)
	return _initial_spawn_position


func enter_reading_memory() -> bool:
	if player_state != PlayerState.ACTIVE or health_component.is_dead:
		return false

	_stop_damage_flash()
	player_state = PlayerState.READING_MEMORY
	enter_reading_memory_state()
	player_corruption.enter_reading_memory_state()
	combat_controller.call(&"enter_reading_memory_state")
	collapse_damage_timer.stop()
	hurtbox_component.monitoring = false
	hurtbox_component.monitorable = false
	hurtbox_collision.disabled = true
	velocity = Vector2.ZERO
	return true


func exit_reading_memory() -> void:
	if player_state != PlayerState.READING_MEMORY:
		return

	hurtbox_component.monitoring = true
	hurtbox_component.monitorable = true
	hurtbox_collision.disabled = false
	player_corruption.exit_reading_memory_state()
	combat_controller.call(&"exit_reading_memory_state")
	exit_reading_memory_state()
	velocity = Vector2.ZERO
	player_state = PlayerState.ACTIVE


func is_reading_memory() -> bool:
	return player_state == PlayerState.READING_MEMORY


func can_open_pause() -> bool:
	return (
		player_state == PlayerState.ACTIVE
		and not health_component.is_dead
	)


func _on_arena_completed() -> void:
	if player_state != PlayerState.ACTIVE:
		return

	_stop_damage_flash()
	player_state = PlayerState.COMPLETED
	_respawn_pending = false
	respawn_delay_timer.stop()
	player_corruption.enter_completed_state()
	combat_controller.call(&"enter_completed_state")
	enter_completed_state()
	collapse_damage_timer.stop()
	hurtbox_component.incoming_damage_multiplier = 1.0
	hurtbox_component.set_deferred(&"monitoring", false)
	hurtbox_component.set_deferred(&"monitorable", false)
	hurtbox_collision.set_deferred(&"disabled", true)
	velocity = Vector2.ZERO


func _exit_tree() -> void:
	_stop_damage_flash()
	if (
		GameState != null
		and is_instance_valid(GameState)
		and GameState.arena_completed.is_connected(_on_arena_completed)
	):
		GameState.arena_completed.disconnect(_on_arena_completed)
