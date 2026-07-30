class_name PlayerHUD
extends Control

@export var death_fade_duration: float = 0.25

@onready var health_label: Label = (
	$MarginContainer/VBoxContainer/HealthSection/HealthLabel
)
@onready var health_bar: ProgressBar = (
	$MarginContainer/VBoxContainer/HealthSection/HealthBar
)
@onready var corrupted_light_label: Label = (
	$MarginContainer/VBoxContainer/CorruptedLightSection/CorruptedLightLabel
)
@onready var corrupted_light_bar: ProgressBar = (
	$MarginContainer/VBoxContainer/CorruptedLightSection/CorruptedLightBar
)
@onready var instability_label: Label = (
	$MarginContainer/VBoxContainer/InstabilitySection/InstabilityLabel
)
@onready var instability_bar: ProgressBar = (
	$MarginContainer/VBoxContainer/InstabilitySection/InstabilityBar
)
@onready var instability_section: VBoxContainer = (
	$MarginContainer/VBoxContainer/InstabilitySection
)
@onready var collapse_label: Label = (
	$MarginContainer/VBoxContainer/InstabilitySection/CollapseLabel
)
@onready var death_counter_label: Label = $DeathCounterLabel
@onready var interaction_prompt: Label = $InteractionPrompt
@onready var encounter_message: Label = $EncounterMessage
@onready var encounter_message_timer: Timer = $EncounterMessageTimer
@onready var death_overlay: ColorRect = $DeathOverlay
@onready var death_message: Label = $DeathOverlay/DeathMessage
@onready var objective_title: Label = $ObjectivePanel/ObjectiveContent/Title
@onready var objective_enemies: Label = (
	$ObjectivePanel/ObjectiveContent/Enemies
)
@onready var objective_memory: Label = (
	$ObjectivePanel/ObjectiveContent/Memory
)
@onready var objective_altar: Label = (
	$ObjectivePanel/ObjectiveContent/Altar
)
@onready var objective_summary: Label = (
	$ObjectivePanel/ObjectiveContent/Summary
)
@onready var completion_overlay: ColorRect = $CompletionOverlay

var health_component: HealthComponent = null
var corruption_component: CorruptionComponent = null
var observed_player: Node = null
var _death_transition: Tween = null
var _instability_effect_tween: Tween = null
var _instability_visual_level: int = -1

var _observed_cores: Array[CorruptedLightCore] = []
var _available_cores: Array[CorruptedLightCore] = []
var _active_prompt_core: CorruptedLightCore = null
var _absorbing_core: CorruptedLightCore = null
var _observed_altars: Array[RespawnAltar] = []
var _available_altars: Array[RespawnAltar] = []
var _active_prompt_altar: RespawnAltar = null
var _observed_memories: Array[MemoryFragment] = []
var _available_memories: Array[MemoryFragment] = []
var _active_prompt_memory: MemoryFragment = null
var _observed_arena_exits: Array[ArenaExit] = []
var _available_arena_exits: Array[ArenaExit] = []
var _active_prompt_arena_exit: ArenaExit = null
var _observed_gates: Array[ProgressionGate] = []
var _available_gates: Array[ProgressionGate] = []
var _active_prompt_gate: ProgressionGate = null
var _restart_requested: bool = false

const REQUIRED_ENEMY_SPAWN_COUNT: int = 4


func _ready() -> void:
	death_overlay.modulate.a = 0.0
	death_overlay.hide()
	completion_overlay.hide()
	_hide_encounter_message()
	encounter_message_timer.timeout.connect(_hide_encounter_message)
	if GameState != null and is_instance_valid(GameState):
		if not GameState.death_count_changed.is_connected(
			_on_death_count_changed
		):
			GameState.death_count_changed.connect(
				_on_death_count_changed
			)
		if not GameState.objective_progress_changed.is_connected(
			_on_objective_progress_changed
		):
			GameState.objective_progress_changed.connect(
				_on_objective_progress_changed
			)
		if not GameState.arena_exit_unlocked.is_connected(
			_on_arena_exit_unlocked
		):
			GameState.arena_exit_unlocked.connect(
				_on_arena_exit_unlocked
			)
		if not GameState.arena_completed.is_connected(
			_on_arena_completed
		):
			GameState.arena_completed.connect(_on_arena_completed)
		if not GameState.encounter_activated.is_connected(
			_on_encounter_activated
		):
			GameState.encounter_activated.connect(
				_on_encounter_activated
			)
		if not GameState.encounter_completed.is_connected(
			_on_encounter_completed
		):
			GameState.encounter_completed.connect(
				_on_encounter_completed
			)
		_on_death_count_changed(GameState.death_count)
		_on_objective_progress_changed(
			GameState.get_defeated_enemy_spawn_count(),
			REQUIRED_ENEMY_SPAWN_COUNT,
			GameState.has_memory(&"prototype_memory_01"),
			(
				GameState.has_respawn_point
				and GameState.active_altar_id
				== &"prototype_altar_01"
			)
		)
		if GameState.arena_exit_is_unlocked:
			_on_arena_exit_unlocked()
		if GameState.arena_is_completed:
			_on_arena_completed()
	else:
		push_error("PlayerHUD requires the GameState Autoload.")
	_hide_interaction_prompt()


func bind_player_lifecycle(new_player: Node) -> void:
	if new_player == null or not is_instance_valid(new_player):
		push_error("PlayerHUD requires a valid player lifecycle source.")
		return
	if (
		not new_player.has_signal(&"player_died")
		or not new_player.has_signal(&"player_respawned")
	):
		push_error("PlayerHUD player lifecycle signals are unavailable.")
		return
	_disconnect_player_lifecycle()
	observed_player = new_player
	if not observed_player.is_connected(&"player_died", _on_player_died):
		observed_player.connect(&"player_died", _on_player_died)
	if not observed_player.is_connected(&"player_respawned", _on_player_respawned):
		observed_player.connect(&"player_respawned", _on_player_respawned)


func _disconnect_player_lifecycle() -> void:
	if observed_player == null or not is_instance_valid(observed_player):
		observed_player = null
		return
	if observed_player.is_connected(&"player_died", _on_player_died):
		observed_player.disconnect(&"player_died", _on_player_died)
	if observed_player.is_connected(&"player_respawned", _on_player_respawned):
		observed_player.disconnect(&"player_respawned", _on_player_respawned)
	observed_player = null


func _on_player_died() -> void:
	_hide_encounter_message()
	_stop_instability_effect()
	_replace_death_transition()
	death_overlay.show()
	death_overlay.modulate.a = 0.0
	_death_transition = create_tween()
	_death_transition.tween_property(
		death_overlay,
		^"modulate:a",
		1.0,
		maxf(death_fade_duration, 0.001)
	)


func _on_player_respawned(_respawn_position: Vector2) -> void:
	if corruption_component != null and is_instance_valid(corruption_component):
		_on_instability_level_changed(
			corruption_component.get_instability_level()
		)
	_replace_death_transition()
	_death_transition = create_tween()
	_death_transition.tween_property(
		death_overlay,
		^"modulate:a",
		0.0,
		maxf(death_fade_duration, 0.001)
	)
	_death_transition.tween_callback(_finish_death_overlay_hide)


func _replace_death_transition() -> void:
	if _death_transition != null and _death_transition.is_valid():
		_death_transition.kill()
	_death_transition = null


func _finish_death_overlay_hide() -> void:
	death_overlay.modulate.a = 0.0
	death_overlay.hide()
	_death_transition = null


func bind_player_components(
	new_health_component: HealthComponent,
	new_corruption_component: CorruptionComponent
) -> void:
	if (
		new_health_component == null
		or not is_instance_valid(new_health_component)
		or new_corruption_component == null
		or not is_instance_valid(new_corruption_component)
	):
		push_error("PlayerHUD requires valid player components.")
		return

	_disconnect_player_components()
	health_component = new_health_component
	corruption_component = new_corruption_component

	if not health_component.health_changed.is_connected(
		_on_health_changed
	):
		health_component.health_changed.connect(_on_health_changed)
	if not corruption_component.corrupted_light_changed.is_connected(
		_on_corrupted_light_changed
	):
		corruption_component.corrupted_light_changed.connect(
			_on_corrupted_light_changed
		)
	if not corruption_component.instability_changed.is_connected(
		_on_instability_changed
	):
		corruption_component.instability_changed.connect(
			_on_instability_changed
		)
	if not corruption_component.instability_level_changed.is_connected(
		_on_instability_level_changed
	):
		corruption_component.instability_level_changed.connect(
			_on_instability_level_changed
		)

	_on_health_changed(
		health_component.current_health,
		health_component.maximum_health
	)
	_on_corrupted_light_changed(
		corruption_component.corrupted_light,
		corruption_component.maximum_corrupted_light
	)
	_on_instability_changed(
		corruption_component.instability,
		corruption_component.maximum_instability
	)
	_on_instability_level_changed(
		corruption_component.get_instability_level()
	)


func observe_core(core: CorruptedLightCore) -> void:
	if (
		core == null
		or not is_instance_valid(core)
		or _observed_cores.has(core)
	):
		return

	_observed_cores.append(core)
	if not core.interaction_available.is_connected(
		_on_core_interaction_available
	):
		core.interaction_available.connect(
			_on_core_interaction_available
		)
	if not core.interaction_unavailable.is_connected(
		_on_core_interaction_unavailable
	):
		core.interaction_unavailable.connect(
			_on_core_interaction_unavailable
		)
	if not core.absorption_started.is_connected(
		_on_core_absorption_started
	):
		core.absorption_started.connect(_on_core_absorption_started)
	if not core.absorption_cancelled.is_connected(
		_on_core_absorption_cancelled
	):
		core.absorption_cancelled.connect(_on_core_absorption_cancelled)
	if not core.absorption_completed.is_connected(
		_on_core_absorption_completed
	):
		core.absorption_completed.connect(_on_core_absorption_completed)

	var exiting_callback: Callable = (
		_on_observed_core_tree_exiting.bind(core)
	)
	if not core.tree_exiting.is_connected(exiting_callback):
		core.tree_exiting.connect(exiting_callback)

	if core.has_nearby_player():
		_on_core_interaction_available(core)


func observe_altar(altar: RespawnAltar) -> void:
	if (
		altar == null
		or not is_instance_valid(altar)
		or _observed_altars.has(altar)
	):
		return

	_observed_altars.append(altar)
	if not altar.interaction_available.is_connected(
		_on_altar_interaction_available
	):
		altar.interaction_available.connect(
			_on_altar_interaction_available
		)
	if not altar.interaction_unavailable.is_connected(
		_on_altar_interaction_unavailable
	):
		altar.interaction_unavailable.connect(
			_on_altar_interaction_unavailable
		)
	if not altar.altar_activated.is_connected(_on_altar_activated):
		altar.altar_activated.connect(_on_altar_activated)

	var exiting_callback: Callable = (
		_on_observed_altar_tree_exiting.bind(altar)
	)
	if not altar.tree_exiting.is_connected(exiting_callback):
		altar.tree_exiting.connect(exiting_callback)

	if altar.has_nearby_player() and not altar.is_active:
		_on_altar_interaction_available(altar)


func observe_memory(memory: MemoryFragment) -> void:
	if (
		memory == null
		or not is_instance_valid(memory)
		or memory.is_queued_for_deletion()
		or _observed_memories.has(memory)
	):
		return
	_observed_memories.append(memory)
	memory.interaction_available.connect(_on_memory_interaction_available)
	memory.interaction_unavailable.connect(_on_memory_interaction_unavailable)
	memory.tree_exiting.connect(_on_memory_tree_exiting.bind(memory))
	if memory.has_nearby_player():
		_on_memory_interaction_available(memory)


func observe_arena_exit(arena_exit: ArenaExit) -> void:
	if (
		arena_exit == null
		or not is_instance_valid(arena_exit)
		or _observed_arena_exits.has(arena_exit)
	):
		return
	_observed_arena_exits.append(arena_exit)
	arena_exit.interaction_available.connect(
		_on_arena_exit_interaction_available
	)
	arena_exit.interaction_unavailable.connect(
		_on_arena_exit_interaction_unavailable
	)
	arena_exit.prompt_changed.connect(_on_arena_exit_prompt_changed)
	arena_exit.tree_exiting.connect(
		_on_arena_exit_tree_exiting.bind(arena_exit)
	)
	if arena_exit.has_nearby_player():
		_on_arena_exit_interaction_available(arena_exit)


func observe_gate(gate: ProgressionGate) -> void:
	if (
		gate == null
		or not is_instance_valid(gate)
		or _observed_gates.has(gate)
	):
		return
	_observed_gates.append(gate)
	if not gate.interaction_available.is_connected(
		_on_gate_interaction_available
	):
		gate.interaction_available.connect(
			_on_gate_interaction_available
		)
	if not gate.interaction_unavailable.is_connected(
		_on_gate_interaction_unavailable
	):
		gate.interaction_unavailable.connect(
			_on_gate_interaction_unavailable
		)
	if not gate.gate_opened.is_connected(_on_gate_opened):
		gate.gate_opened.connect(_on_gate_opened)
	var exiting_callback: Callable = _on_gate_tree_exiting.bind(gate)
	if not gate.tree_exiting.is_connected(exiting_callback):
		gate.tree_exiting.connect(exiting_callback)
	if gate.has_nearby_player():
		_on_gate_interaction_available(gate)


func _disconnect_player_components() -> void:
	if health_component != null and is_instance_valid(health_component):
		if health_component.health_changed.is_connected(
			_on_health_changed
		):
			health_component.health_changed.disconnect(
				_on_health_changed
			)
	if (
		corruption_component != null
		and is_instance_valid(corruption_component)
	):
		if corruption_component.corrupted_light_changed.is_connected(
			_on_corrupted_light_changed
		):
			corruption_component.corrupted_light_changed.disconnect(
				_on_corrupted_light_changed
			)
		if corruption_component.instability_changed.is_connected(
			_on_instability_changed
		):
			corruption_component.instability_changed.disconnect(
				_on_instability_changed
			)
		if corruption_component.instability_level_changed.is_connected(
			_on_instability_level_changed
		):
			corruption_component.instability_level_changed.disconnect(
				_on_instability_level_changed
			)


func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "Health: %s / %s" % [
		_format_value(current),
		_format_value(maximum),
	]


func _on_death_count_changed(new_value: int) -> void:
	death_counter_label.text = "Deaths: %d" % new_value


func _on_corrupted_light_changed(
	current: float,
	maximum: float
) -> void:
	corrupted_light_bar.max_value = maximum
	corrupted_light_bar.value = current
	corrupted_light_label.text = "Corrupted Light: %s / %s" % [
		_format_value(current),
		_format_value(maximum),
	]


func _on_instability_changed(current: float, maximum: float) -> void:
	instability_bar.max_value = maximum
	instability_bar.value = current
	instability_label.text = "Instability: %s / %s" % [
		_format_value(current),
		_format_value(maximum),
	]


func _on_instability_level_changed(level: int) -> void:
	if level == _instability_visual_level:
		return

	_instability_visual_level = level
	_stop_instability_effect()
	match level:
		1:
			instability_section.modulate = Color(1.0, 0.72, 0.38, 1.0)
			_start_instability_pulse(0.65, 0.5)
		2:
			instability_section.modulate = Color(1.0, 0.38, 0.2, 1.0)
			collapse_label.show()
			_start_instability_pulse(0.45, 0.25)
		_:
			instability_section.modulate = Color.WHITE


func _on_objective_progress_changed(
	defeated_spawn_count: int,
	required_spawn_count: int,
	memory_collected: bool,
	altar_activated: bool
) -> void:
	var displayed_required_count: int = maxi(
		required_spawn_count,
		REQUIRED_ENEMY_SPAWN_COUNT
	)
	objective_enemies.text = "Enemies: %d / %d" % [
		mini(defeated_spawn_count, displayed_required_count),
		displayed_required_count,
	]
	objective_memory.text = (
		"Memory: Remembered" if memory_collected else "Memory: Missing"
	)
	objective_altar.text = (
		"Altar: Active" if altar_activated else "Altar: Inactive"
	)


func _on_arena_exit_unlocked() -> void:
	objective_title.text = "OBJECTIVE COMPLETE"
	objective_enemies.hide()
	objective_memory.hide()
	objective_altar.hide()
	objective_summary.text = "The arena exit is open"
	objective_summary.show()
	_refresh_interaction_prompt()


func _on_arena_completed() -> void:
	_hide_encounter_message()
	_hide_interaction_prompt()
	death_overlay.hide()
	completion_overlay.show()


func _on_encounter_activated(_encounter_id: StringName) -> void:
	_show_encounter_message("ENCOUNTER STARTED")


func _on_encounter_completed(_encounter_id: StringName) -> void:
	_show_encounter_message("ENCOUNTER CLEARED")


func _show_encounter_message(message: String) -> void:
	if death_overlay.visible or completion_overlay.visible:
		return
	encounter_message_timer.stop()
	encounter_message.text = message
	encounter_message.show()
	encounter_message_timer.start()


func _hide_encounter_message() -> void:
	encounter_message_timer.stop()
	encounter_message.hide()


func _unhandled_input(event: InputEvent) -> void:
	if (
		not completion_overlay.visible
		or _restart_requested
		or not event.is_action_pressed(&"restart_run")
		or event.is_echo()
	):
		return
	_restart_requested = true
	get_viewport().set_input_as_handled()
	GameState.reset_run_state()
	get_tree().reload_current_scene()


func _start_instability_pulse(
	minimum_alpha: float,
	half_duration: float
) -> void:
	_instability_effect_tween = create_tween().set_loops()
	_instability_effect_tween.tween_property(
		instability_section,
		^"modulate:a",
		minimum_alpha,
		half_duration
	).set_trans(Tween.TRANS_SINE)
	_instability_effect_tween.tween_property(
		instability_section,
		^"modulate:a",
		1.0,
		half_duration
	).set_trans(Tween.TRANS_SINE)


func _stop_instability_effect() -> void:
	if (
		_instability_effect_tween != null
		and _instability_effect_tween.is_valid()
	):
		_instability_effect_tween.kill()
	_instability_effect_tween = null
	instability_section.modulate = Color.WHITE
	collapse_label.hide()


func _on_core_interaction_available(
	core: CorruptedLightCore
) -> void:
	if core == null or not is_instance_valid(core):
		return
	if not _available_cores.has(core):
		_available_cores.append(core)
	_refresh_interaction_prompt()


func _on_core_interaction_unavailable(
	core: CorruptedLightCore
) -> void:
	_available_cores.erase(core)
	if _active_prompt_core == core:
		_active_prompt_core = null
	if _absorbing_core == core:
		_absorbing_core = null
	_refresh_interaction_prompt()


func _on_core_absorption_started(core: CorruptedLightCore) -> void:
	if core == null or not is_instance_valid(core):
		return

	_absorbing_core = core
	_active_prompt_core = core
	interaction_prompt.text = "Absorbing..."
	interaction_prompt.show()


func _on_core_absorption_cancelled(
	core: CorruptedLightCore,
	_player: CharacterBody2D
) -> void:
	if _absorbing_core == core:
		_absorbing_core = null
	if core != null and is_instance_valid(core) and core.has_nearby_player():
		if not _available_cores.has(core):
			_available_cores.append(core)
		_active_prompt_core = core
	else:
		_available_cores.erase(core)
		if _active_prompt_core == core:
			_active_prompt_core = null
	_refresh_interaction_prompt()


func _on_core_absorption_completed(
	core: CorruptedLightCore,
	_player: CharacterBody2D
) -> void:
	_available_cores.erase(core)
	if _absorbing_core == core:
		_absorbing_core = null
	if _active_prompt_core == core:
		_active_prompt_core = null
	_refresh_interaction_prompt()


func _on_observed_core_tree_exiting(core: CorruptedLightCore) -> void:
	_observed_cores.erase(core)
	_available_cores.erase(core)
	if _absorbing_core == core:
		_absorbing_core = null
	if _active_prompt_core == core:
		_active_prompt_core = null
	_refresh_interaction_prompt()


func _on_altar_interaction_available(altar: RespawnAltar) -> void:
	if (
		altar == null
		or not is_instance_valid(altar)
		or altar.is_active
	):
		return
	if not _available_altars.has(altar):
		_available_altars.append(altar)
	_refresh_interaction_prompt()


func _on_altar_interaction_unavailable(altar: RespawnAltar) -> void:
	_available_altars.erase(altar)
	if _active_prompt_altar == altar:
		_active_prompt_altar = null
	_refresh_interaction_prompt()


func _on_altar_activated(
	_altar_id: StringName,
	_respawn_position: Vector2
) -> void:
	for altar: RespawnAltar in _available_altars.duplicate():
		if altar != null and is_instance_valid(altar) and altar.is_active:
			_available_altars.erase(altar)
			if _active_prompt_altar == altar:
				_active_prompt_altar = null
	_refresh_interaction_prompt()


func _on_observed_altar_tree_exiting(altar: RespawnAltar) -> void:
	_observed_altars.erase(altar)
	_available_altars.erase(altar)
	if _active_prompt_altar == altar:
		_active_prompt_altar = null
	_refresh_interaction_prompt()


func _on_memory_interaction_available(memory: MemoryFragment) -> void:
	if memory == null or not is_instance_valid(memory) or memory.is_collected:
		return
	if not _available_memories.has(memory):
		_available_memories.append(memory)
	_refresh_interaction_prompt()


func _on_memory_interaction_unavailable(memory: MemoryFragment) -> void:
	_available_memories.erase(memory)
	if _active_prompt_memory == memory:
		_active_prompt_memory = null
	_refresh_interaction_prompt()


func _on_memory_tree_exiting(memory: MemoryFragment) -> void:
	_observed_memories.erase(memory)
	_available_memories.erase(memory)
	if _active_prompt_memory == memory:
		_active_prompt_memory = null
	_refresh_interaction_prompt()


func _on_arena_exit_interaction_available(
	arena_exit: ArenaExit
) -> void:
	if arena_exit == null or not is_instance_valid(arena_exit):
		return
	if not _available_arena_exits.has(arena_exit):
		_available_arena_exits.append(arena_exit)
	_refresh_interaction_prompt()


func _on_arena_exit_interaction_unavailable(
	arena_exit: ArenaExit
) -> void:
	_available_arena_exits.erase(arena_exit)
	if _active_prompt_arena_exit == arena_exit:
		_active_prompt_arena_exit = null
	_refresh_interaction_prompt()


func _on_arena_exit_prompt_changed(_arena_exit: ArenaExit) -> void:
	_refresh_interaction_prompt()


func _on_arena_exit_tree_exiting(arena_exit: ArenaExit) -> void:
	_observed_arena_exits.erase(arena_exit)
	_available_arena_exits.erase(arena_exit)
	if _active_prompt_arena_exit == arena_exit:
		_active_prompt_arena_exit = null
	_refresh_interaction_prompt()


func _on_gate_interaction_available(gate: ProgressionGate) -> void:
	if (
		gate == null
		or not is_instance_valid(gate)
		or gate.is_open
	):
		return
	if not _available_gates.has(gate):
		_available_gates.append(gate)
	_refresh_interaction_prompt()


func _on_gate_interaction_unavailable(gate: ProgressionGate) -> void:
	_available_gates.erase(gate)
	if _active_prompt_gate == gate:
		_active_prompt_gate = null
	_refresh_interaction_prompt()


func _on_gate_opened(_gate_id: StringName) -> void:
	_show_encounter_message("PATH OPENED")


func _on_gate_tree_exiting(gate: ProgressionGate) -> void:
	_observed_gates.erase(gate)
	_available_gates.erase(gate)
	if _active_prompt_gate == gate:
		_active_prompt_gate = null
	_refresh_interaction_prompt()


func _refresh_interaction_prompt() -> void:
	if completion_overlay.visible:
		_hide_interaction_prompt()
		return
	if _absorbing_core != null and is_instance_valid(_absorbing_core):
		interaction_prompt.text = "Absorbing..."
		interaction_prompt.show()
		return

	_remove_invalid_available_cores()
	_remove_invalid_available_altars()
	_remove_invalid_available_memories()
	_remove_invalid_available_arena_exits()
	_remove_invalid_available_gates()
	if not _available_cores.is_empty():
		_active_prompt_core = _available_cores.back()
		_active_prompt_altar = null
		_active_prompt_memory = null
		interaction_prompt.text = "Press E to absorb"
		interaction_prompt.show()
		return

	_active_prompt_core = null
	if not _available_memories.is_empty():
		_active_prompt_memory = _available_memories.back()
		_active_prompt_altar = null
		interaction_prompt.text = "Press E to remember"
		interaction_prompt.show()
		return

	_active_prompt_memory = null
	if not _available_altars.is_empty():
		_active_prompt_altar = _available_altars.back()
		interaction_prompt.text = "Press E to activate altar"
		interaction_prompt.show()
		return

	_active_prompt_altar = null
	if not _available_gates.is_empty():
		_active_prompt_gate = _available_gates.back()
		_active_prompt_arena_exit = null
		interaction_prompt.text = _active_prompt_gate.get_prompt_text()
		interaction_prompt.show()
		return

	_active_prompt_gate = null
	if not _available_arena_exits.is_empty():
		_active_prompt_arena_exit = _available_arena_exits.back()
		interaction_prompt.text = (
			_active_prompt_arena_exit.get_prompt_text()
		)
		interaction_prompt.show()
		return

	_active_prompt_arena_exit = null
	_hide_interaction_prompt()


func _remove_invalid_available_cores() -> void:
	for index: int in range(_available_cores.size() - 1, -1, -1):
		var core: CorruptedLightCore = _available_cores[index]
		if core == null or not is_instance_valid(core):
			_available_cores.remove_at(index)


func _remove_invalid_available_altars() -> void:
	for index: int in range(_available_altars.size() - 1, -1, -1):
		var altar: RespawnAltar = _available_altars[index]
		if (
			altar == null
			or not is_instance_valid(altar)
			or altar.is_active
		):
			_available_altars.remove_at(index)


func _remove_invalid_available_memories() -> void:
	for index: int in range(_available_memories.size() - 1, -1, -1):
		var memory: MemoryFragment = _available_memories[index]
		if (
			memory == null
			or not is_instance_valid(memory)
			or memory.is_collected
			or memory.is_queued_for_deletion()
		):
			_available_memories.remove_at(index)


func _remove_invalid_available_arena_exits() -> void:
	for index: int in range(
		_available_arena_exits.size() - 1,
		-1,
		-1
	):
		var arena_exit: ArenaExit = _available_arena_exits[index]
		if (
			arena_exit == null
			or not is_instance_valid(arena_exit)
			or arena_exit.is_completed
		):
			_available_arena_exits.remove_at(index)


func _remove_invalid_available_gates() -> void:
	for index: int in range(_available_gates.size() - 1, -1, -1):
		var gate: ProgressionGate = _available_gates[index]
		if (
			gate == null
			or not is_instance_valid(gate)
			or gate.is_open
		):
			_available_gates.remove_at(index)


func _hide_interaction_prompt() -> void:
	interaction_prompt.text = "Press E to interact"
	interaction_prompt.hide()


func _format_value(value: float) -> String:
	var rounded_value: float = roundf(value)
	if is_equal_approx(value, rounded_value):
		return str(int(rounded_value))
	return "%.1f" % value


func _exit_tree() -> void:
	_replace_death_transition()
	_stop_instability_effect()
	_disconnect_player_lifecycle()
	_disconnect_player_components()
	if (
		GameState != null
		and is_instance_valid(GameState)
	):
		if GameState.death_count_changed.is_connected(
			_on_death_count_changed
		):
			GameState.death_count_changed.disconnect(
				_on_death_count_changed
			)
		if GameState.objective_progress_changed.is_connected(
			_on_objective_progress_changed
		):
			GameState.objective_progress_changed.disconnect(
				_on_objective_progress_changed
			)
		if GameState.arena_exit_unlocked.is_connected(
			_on_arena_exit_unlocked
		):
			GameState.arena_exit_unlocked.disconnect(
				_on_arena_exit_unlocked
			)
		if GameState.arena_completed.is_connected(_on_arena_completed):
			GameState.arena_completed.disconnect(_on_arena_completed)
		if GameState.encounter_activated.is_connected(
			_on_encounter_activated
		):
			GameState.encounter_activated.disconnect(
				_on_encounter_activated
			)
		if GameState.encounter_completed.is_connected(
			_on_encounter_completed
		):
			GameState.encounter_completed.disconnect(
				_on_encounter_completed
			)
