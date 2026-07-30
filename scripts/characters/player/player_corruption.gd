class_name PlayerCorruption
extends Node

enum State {
	IDLE,
	ABSORBING,
	DEAD,
	COMPLETED,
	READING_MEMORY,
}

@onready var player: CharacterBody2D = get_parent() as CharacterBody2D
@onready var corruption_component: CorruptionComponent = (
	$"../CorruptionComponent"
)
@onready var hurtbox_component: HurtboxComponent = $"../Hurtbox"
@onready var health_component: HealthComponent = $"../HealthComponent"
@onready var combat_controller: Node2D = $"../Visuals/ScythePivot"
@onready var collapse_damage_timer: Timer = $"../CollapseDamageTimer"

@export var collapse_damage: float = 5.0
@export var collapse_damage_interval: float = 1.0
@export var overloaded_damage_multiplier: float = 1.25

var current_state: State = State.IDLE
var active_core: CorruptedLightCore = null
var current_instability_level: int = 0

var _was_player_physics_processing: bool = true
var _was_combat_processing: bool = true


func _ready() -> void:
	hurtbox_component.damage_received.connect(_on_damage_received)
	health_component.died.connect(_on_player_died)
	corruption_component.instability_level_changed.connect(
		_on_instability_level_changed
	)
	collapse_damage_timer.timeout.connect(_on_collapse_damage_timeout)
	collapse_damage_timer.wait_time = maxf(
		collapse_damage_interval,
		0.001
	)
	current_instability_level = (
		corruption_component.get_instability_level()
	)
	_apply_instability_penalties()


func _process(_delta: float) -> void:
	if (
		current_state == State.IDLE
		and Input.is_action_just_pressed(&"interact")
	):
		_try_start_absorption()


func is_absorbing() -> bool:
	return current_state == State.ABSORBING


func enter_dead_state() -> void:
	if current_state == State.DEAD:
		return

	var core_to_cancel: CorruptedLightCore = active_core
	current_state = State.DEAD
	set_process(false)
	collapse_damage_timer.stop()
	hurtbox_component.incoming_damage_multiplier = 1.0
	player.velocity = Vector2.ZERO

	if core_to_cancel != null and is_instance_valid(core_to_cancel):
		_disconnect_core_signals(core_to_cancel)
		core_to_cancel.cancel_absorption(player)
	active_core = null


func exit_dead_state() -> void:
	if current_state != State.DEAD:
		return

	active_core = null
	collapse_damage_timer.stop()
	hurtbox_component.incoming_damage_multiplier = 1.0
	current_state = State.IDLE
	set_process(true)


func enter_completed_state() -> void:
	if current_state == State.COMPLETED:
		return

	var core_to_cancel: CorruptedLightCore = active_core
	current_state = State.COMPLETED
	set_process(false)
	collapse_damage_timer.stop()
	hurtbox_component.incoming_damage_multiplier = 1.0
	player.velocity = Vector2.ZERO

	if core_to_cancel != null and is_instance_valid(core_to_cancel):
		_disconnect_core_signals(core_to_cancel)
		core_to_cancel.cancel_absorption(player)
	active_core = null


func enter_reading_memory_state() -> bool:
	if (
		current_state == State.DEAD
		or current_state == State.COMPLETED
		or current_state == State.READING_MEMORY
	):
		return false

	var core_to_cancel: CorruptedLightCore = active_core
	current_state = State.READING_MEMORY
	set_process(false)
	collapse_damage_timer.stop()
	player.velocity = Vector2.ZERO
	if core_to_cancel != null and is_instance_valid(core_to_cancel):
		_disconnect_core_signals(core_to_cancel)
		core_to_cancel.cancel_absorption(player)
	active_core = null
	return true


func exit_reading_memory_state() -> void:
	if current_state != State.READING_MEMORY:
		return
	active_core = null
	current_state = State.IDLE
	set_process(true)
	_apply_instability_penalties()


func _try_start_absorption() -> void:
	if (
		current_state != State.IDLE
		or _is_attack_in_progress()
		or _is_player_dodging()
	):
		return

	var core: CorruptedLightCore = _find_available_core()
	if core == null or not core.begin_absorption(player):
		return

	active_core = core
	current_state = State.ABSORBING
	_connect_core_signals(core)
	_block_player_actions()


func _find_available_core() -> CorruptedLightCore:
	for node: Node in get_tree().get_nodes_in_group(&"corrupted_light_cores"):
		var core: CorruptedLightCore = node as CorruptedLightCore
		if core != null and core.can_begin_absorption(player):
			return core
	return null


func _is_attack_in_progress() -> bool:
	return bool(combat_controller.get(&"is_attacking"))


func _is_player_dodging() -> bool:
	return (
		player.has_method(&"is_dodging")
		and bool(player.call(&"is_dodging"))
	)


func _block_player_actions() -> void:
	_was_player_physics_processing = player.is_physics_processing()
	_was_combat_processing = combat_controller.is_processing()
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	combat_controller.set_process(false)


func _restore_player_actions() -> void:
	player.velocity = Vector2.ZERO
	if (
		current_state == State.DEAD
		or current_state == State.COMPLETED
		or health_component.is_dead
	):
		return
	player.set_physics_process(_was_player_physics_processing)
	combat_controller.set_process(_was_combat_processing)


func _connect_core_signals(core: CorruptedLightCore) -> void:
	core.absorption_completed.connect(_on_absorption_completed)
	core.absorption_cancelled.connect(_on_absorption_cancelled)
	core.tree_exiting.connect(_on_active_core_tree_exiting)


func _disconnect_core_signals(core: CorruptedLightCore) -> void:
	if core.absorption_completed.is_connected(_on_absorption_completed):
		core.absorption_completed.disconnect(_on_absorption_completed)
	if core.absorption_cancelled.is_connected(_on_absorption_cancelled):
		core.absorption_cancelled.disconnect(_on_absorption_cancelled)
	if core.tree_exiting.is_connected(_on_active_core_tree_exiting):
		core.tree_exiting.disconnect(_on_active_core_tree_exiting)


func _on_absorption_completed(
	core: CorruptedLightCore,
	absorbing_player: CharacterBody2D
) -> void:
	if (
		current_state != State.ABSORBING
		or core != active_core
		or absorbing_player != player
	):
		return
	if not core.finish_absorption(player):
		core.cancel_absorption(player)
		return

	var light_amount: float = core.corrupted_light_amount
	var instability_amount: float = core.instability_amount
	_finish_absorption_state(core)
	corruption_component.absorb(light_amount, instability_amount)
	core.queue_free()


func _on_absorption_cancelled(
	core: CorruptedLightCore,
	absorbing_player: CharacterBody2D
) -> void:
	if (
		current_state == State.ABSORBING
		and core == active_core
		and absorbing_player == player
	):
		_finish_absorption_state(core)


func _on_damage_received(_amount: float, _source: Node) -> void:
	if current_state == State.DEAD:
		return
	if current_state != State.ABSORBING:
		return
	if active_core == null or not is_instance_valid(active_core):
		_finish_absorption_state(null)
		return

	active_core.cancel_absorption(player)


func _on_instability_level_changed(level: int) -> void:
	current_instability_level = level
	_apply_instability_penalties()


func _apply_instability_penalties() -> void:
	if health_component.is_dead:
		hurtbox_component.incoming_damage_multiplier = 1.0
		collapse_damage_timer.stop()
		return
	if current_state == State.READING_MEMORY:
		collapse_damage_timer.stop()
		return

	hurtbox_component.incoming_damage_multiplier = (
		maxf(overloaded_damage_multiplier, 0.0)
		if current_instability_level >= 1
		else 1.0
	)
	if current_instability_level >= 2:
		collapse_damage_timer.wait_time = maxf(
			collapse_damage_interval,
			0.001
		)
		if collapse_damage_timer.is_stopped():
			collapse_damage_timer.start()
	else:
		collapse_damage_timer.stop()


func _on_collapse_damage_timeout() -> void:
	if current_instability_level < 2 or health_component.is_dead:
		collapse_damage_timer.stop()
		return

	var previous_health: float = health_component.current_health
	health_component.take_damage(maxf(collapse_damage, 0.0))
	var applied_damage: float = (
		previous_health - health_component.current_health
	)
	if applied_damage <= 0.0:
		return

	if current_state == State.ABSORBING:
		if active_core != null and is_instance_valid(active_core):
			active_core.cancel_absorption(player)


func _on_player_died() -> void:
	enter_dead_state()


func _on_active_core_tree_exiting() -> void:
	if current_state == State.ABSORBING:
		_finish_absorption_state(active_core)


func _finish_absorption_state(core: CorruptedLightCore) -> void:
	if current_state == State.DEAD:
		return
	if core != null and is_instance_valid(core):
		_disconnect_core_signals(core)
	active_core = null
	current_state = State.IDLE
	_restore_player_actions()


func _exit_tree() -> void:
	if (
		current_state == State.ABSORBING
		and active_core != null
		and is_instance_valid(active_core)
	):
		active_core.cancel_absorption(player)
