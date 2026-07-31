class_name TutorialController
extends Node

const MOVEMENT_STEP: StringName = &"movement"
const ATTACK_STEP: StringName = &"attack"
const DODGE_STEP: StringName = &"dodge"
const INTERACT_STEP: StringName = &"interact"
const ABSORB_STEP: StringName = &"absorb"
const FIRST_ENCOUNTER_ID: StringName = &"encounter_01"

var player: CharacterBody2D = null
var player_hud: PlayerHUD = null
var tutorial_prompt: TutorialPrompt = null
var combat_controller: Node2D = null
var corruption_controller: PlayerCorruption = null

var _available_cores: Array[CorruptedLightCore] = []
var _available_altars: Array[RespawnAltar] = []
var _available_memories: Array[MemoryFragment] = []
var _combat_context_active: bool = false
var _absorbing_core: CorruptedLightCore = null
var _memory_panel_active: bool = false
var _player_is_dead: bool = false
var _arena_is_completed: bool = false
var _is_configured: bool = false


func configure(
	new_player: CharacterBody2D,
	new_player_hud: PlayerHUD,
	new_tutorial_prompt: TutorialPrompt
) -> void:
	if _is_configured:
		return
	if (
		new_player == null
		or not is_instance_valid(new_player)
		or new_player_hud == null
		or not is_instance_valid(new_player_hud)
		or new_tutorial_prompt == null
		or not is_instance_valid(new_tutorial_prompt)
	):
		push_error("TutorialController requires valid scene references.")
		return

	player = new_player
	player_hud = new_player_hud
	tutorial_prompt = new_tutorial_prompt
	combat_controller = player.get_node_or_null(
		^"Visuals/ScythePivot"
	) as Node2D
	corruption_controller = player.get_node_or_null(
		^"PlayerCorruption"
	) as PlayerCorruption
	if combat_controller == null or corruption_controller == null:
		push_error("TutorialController could not find player controllers.")
		return

	_connect_player_signals()
	_connect_game_state_signals()
	if not tutorial_prompt.prompt_visibility_changed.is_connected(
		player_hud.set_tutorial_prompt_active
	):
		tutorial_prompt.prompt_visibility_changed.connect(
			player_hud.set_tutorial_prompt_active
		)

	_combat_context_active = GameState.is_encounter_activated(
		FIRST_ENCOUNTER_ID
	)
	_arena_is_completed = GameState.arena_is_completed
	_is_configured = true
	_refresh_prompt()


func observe_core(core: CorruptedLightCore) -> void:
	if core == null or not is_instance_valid(core):
		return
	if not core.interaction_available.is_connected(
		_on_core_interaction_available
	):
		core.interaction_available.connect(_on_core_interaction_available)
	if not core.interaction_unavailable.is_connected(
		_on_core_interaction_unavailable
	):
		core.interaction_unavailable.connect(_on_core_interaction_unavailable)
	if not core.absorption_started.is_connected(_on_absorption_started):
		core.absorption_started.connect(_on_absorption_started)
	if not core.absorption_cancelled.is_connected(_on_absorption_cancelled):
		core.absorption_cancelled.connect(_on_absorption_cancelled)
	var exiting_callback: Callable = _on_core_tree_exiting.bind(core)
	if not core.tree_exiting.is_connected(exiting_callback):
		core.tree_exiting.connect(exiting_callback)
	if core.has_nearby_player():
		_on_core_interaction_available(core)


func observe_altar(altar: RespawnAltar) -> void:
	if altar == null or not is_instance_valid(altar):
		return
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
	var exiting_callback: Callable = _on_altar_tree_exiting.bind(altar)
	if not altar.tree_exiting.is_connected(exiting_callback):
		altar.tree_exiting.connect(exiting_callback)
	if altar.has_nearby_player() and not altar.is_active:
		_on_altar_interaction_available(altar)


func observe_memory(memory: MemoryFragment) -> void:
	if (
		memory == null
		or not is_instance_valid(memory)
		or memory.is_queued_for_deletion()
	):
		return
	if not memory.interaction_available.is_connected(
		_on_memory_interaction_available
	):
		memory.interaction_available.connect(
			_on_memory_interaction_available
		)
	if not memory.interaction_unavailable.is_connected(
		_on_memory_interaction_unavailable
	):
		memory.interaction_unavailable.connect(
			_on_memory_interaction_unavailable
		)
	if not memory.memory_remembered.is_connected(_on_memory_remembered):
		memory.memory_remembered.connect(_on_memory_remembered)
	var exiting_callback: Callable = _on_memory_tree_exiting.bind(memory)
	if not memory.tree_exiting.is_connected(exiting_callback):
		memory.tree_exiting.connect(exiting_callback)
	if memory.has_nearby_player() and not memory.is_collected:
		_on_memory_interaction_available(memory)


func set_memory_panel_active(active: bool) -> void:
	_memory_panel_active = active
	_refresh_prompt(true)


func _connect_player_signals() -> void:
	_connect_signal_if_available(player, &"movement_performed", _on_movement_performed)
	_connect_signal_if_available(player, &"dodge_started", _on_dodge_started)
	_connect_signal_if_available(player, &"player_died", _on_player_died)
	_connect_signal_if_available(player, &"player_respawned", _on_player_respawned)
	_connect_signal_if_available(
		combat_controller,
		&"attack_performed",
		_on_attack_performed
	)
	_connect_signal_if_available(
		corruption_controller,
		&"absorption_succeeded",
		_on_absorption_succeeded
	)


func _connect_game_state_signals() -> void:
	if not GameState.tutorial_step_completed.is_connected(
		_on_tutorial_step_completed
	):
		GameState.tutorial_step_completed.connect(
			_on_tutorial_step_completed
		)
	if not GameState.encounter_activated.is_connected(
		_on_encounter_activated
	):
		GameState.encounter_activated.connect(_on_encounter_activated)
	if not GameState.arena_completed.is_connected(_on_arena_completed):
		GameState.arena_completed.connect(_on_arena_completed)


func _connect_signal_if_available(
	source: Object,
	signal_name: StringName,
	callback: Callable
) -> void:
	if not source.has_signal(signal_name):
		push_error("TutorialController requires signal %s." % signal_name)
		return
	if not source.is_connected(signal_name, callback):
		source.connect(signal_name, callback)


func _on_movement_performed() -> void:
	GameState.complete_tutorial_step(MOVEMENT_STEP)


func _on_attack_performed() -> void:
	GameState.complete_tutorial_step(ATTACK_STEP)


func _on_dodge_started() -> void:
	GameState.complete_tutorial_step(DODGE_STEP)


func _on_absorption_succeeded(core: CorruptedLightCore) -> void:
	if _absorbing_core == core:
		_absorbing_core = null
	_available_cores.erase(core)
	GameState.complete_tutorial_step(ABSORB_STEP)
	_refresh_prompt()


func _on_tutorial_step_completed(_step_id: StringName) -> void:
	_refresh_prompt()


func _on_encounter_activated(encounter_id: StringName) -> void:
	if encounter_id != FIRST_ENCOUNTER_ID:
		return
	_combat_context_active = true
	_refresh_prompt()


func _on_player_died() -> void:
	_player_is_dead = true
	_absorbing_core = null
	_available_cores.clear()
	_available_altars.clear()
	_available_memories.clear()
	_refresh_prompt(true)


func _on_player_respawned(_respawn_position: Vector2) -> void:
	_player_is_dead = false
	_refresh_prompt()


func _on_arena_completed() -> void:
	_arena_is_completed = true
	_refresh_prompt(true)


func _on_core_interaction_available(core: CorruptedLightCore) -> void:
	if core == null or not is_instance_valid(core):
		return
	if not _available_cores.has(core):
		_available_cores.append(core)
	_refresh_prompt()


func _on_core_interaction_unavailable(core: CorruptedLightCore) -> void:
	_available_cores.erase(core)
	_refresh_prompt()


func _on_absorption_started(core: CorruptedLightCore) -> void:
	_absorbing_core = core
	_refresh_prompt(true)


func _on_absorption_cancelled(
	core: CorruptedLightCore,
	_player: CharacterBody2D
) -> void:
	if _absorbing_core == core:
		_absorbing_core = null
	_refresh_prompt()


func _on_core_tree_exiting(core: CorruptedLightCore) -> void:
	_available_cores.erase(core)
	if _absorbing_core == core:
		_absorbing_core = null
	_refresh_prompt()


func _on_altar_interaction_available(altar: RespawnAltar) -> void:
	if altar == null or not is_instance_valid(altar) or altar.is_active:
		return
	if not _available_altars.has(altar):
		_available_altars.append(altar)
	_refresh_prompt()


func _on_altar_interaction_unavailable(altar: RespawnAltar) -> void:
	_available_altars.erase(altar)
	_refresh_prompt()


func _on_altar_activated(
	_altar_id: StringName,
	_respawn_position: Vector2
) -> void:
	_remove_active_altars()
	GameState.complete_tutorial_step(INTERACT_STEP)


func _on_altar_tree_exiting(altar: RespawnAltar) -> void:
	_available_altars.erase(altar)
	_refresh_prompt()


func _on_memory_interaction_available(memory: MemoryFragment) -> void:
	if memory == null or not is_instance_valid(memory) or memory.is_collected:
		return
	if not _available_memories.has(memory):
		_available_memories.append(memory)
	_refresh_prompt()


func _on_memory_interaction_unavailable(memory: MemoryFragment) -> void:
	_available_memories.erase(memory)
	_refresh_prompt()


func _on_memory_remembered(
	memory: MemoryFragment,
	_memory_id: StringName
) -> void:
	_available_memories.erase(memory)
	GameState.complete_tutorial_step(INTERACT_STEP)


func _on_memory_tree_exiting(memory: MemoryFragment) -> void:
	_available_memories.erase(memory)
	_refresh_prompt()


func _refresh_prompt(immediate_hide: bool = false) -> void:
	if not _is_configured or tutorial_prompt == null:
		return
	if (
		_memory_panel_active
		or _player_is_dead
		or _arena_is_completed
		or (_absorbing_core != null and is_instance_valid(_absorbing_core))
	):
		tutorial_prompt.hide_prompt(true)
		return

	_remove_invalid_contexts()
	var step_id: StringName = _get_contextual_step()
	if step_id == &"":
		tutorial_prompt.hide_prompt(immediate_hide)
		return
	_show_step(step_id)


func _get_contextual_step() -> StringName:
	if not GameState.is_tutorial_step_completed(MOVEMENT_STEP):
		return MOVEMENT_STEP
	if (
		not _available_cores.is_empty()
		and not GameState.is_tutorial_step_completed(ABSORB_STEP)
	):
		return ABSORB_STEP
	if (
		(not _available_memories.is_empty() or not _available_altars.is_empty())
		and not GameState.is_tutorial_step_completed(INTERACT_STEP)
	):
		return INTERACT_STEP
	if (
		_combat_context_active
		and not GameState.is_tutorial_step_completed(ATTACK_STEP)
	):
		return ATTACK_STEP
	if (
		_combat_context_active
		and not GameState.is_tutorial_step_completed(DODGE_STEP)
	):
		return DODGE_STEP
	return &""


func _show_step(step_id: StringName) -> void:
	match step_id:
		MOVEMENT_STEP:
			tutorial_prompt.show_step(step_id, "WASD", "MOVE")
		ATTACK_STEP:
			tutorial_prompt.show_step(step_id, "LEFT MOUSE", "ATTACK")
		DODGE_STEP:
			tutorial_prompt.show_step(step_id, "SPACE", "DODGE")
		INTERACT_STEP:
			tutorial_prompt.show_step(step_id, "E", "INTERACT")
		ABSORB_STEP:
			tutorial_prompt.show_step(
				step_id,
				"E",
				"ABSORB CORRUPTED LIGHT"
			)


func _remove_active_altars() -> void:
	for index: int in range(_available_altars.size() - 1, -1, -1):
		var altar: RespawnAltar = _available_altars[index]
		if altar == null or not is_instance_valid(altar) or altar.is_active:
			_available_altars.remove_at(index)


func _remove_invalid_contexts() -> void:
	for index: int in range(_available_cores.size() - 1, -1, -1):
		var core: CorruptedLightCore = _available_cores[index]
		if core == null or not is_instance_valid(core):
			_available_cores.remove_at(index)
	_remove_active_altars()
	for index: int in range(_available_memories.size() - 1, -1, -1):
		var memory: MemoryFragment = _available_memories[index]
		if (
			memory == null
			or not is_instance_valid(memory)
			or memory.is_collected
			or memory.is_queued_for_deletion()
		):
			_available_memories.remove_at(index)


func _exit_tree() -> void:
	if tutorial_prompt != null and is_instance_valid(tutorial_prompt):
		tutorial_prompt.hide_prompt(true)
	if GameState == null or not is_instance_valid(GameState):
		return
	if GameState.tutorial_step_completed.is_connected(
		_on_tutorial_step_completed
	):
		GameState.tutorial_step_completed.disconnect(
			_on_tutorial_step_completed
		)
	if GameState.encounter_activated.is_connected(_on_encounter_activated):
		GameState.encounter_activated.disconnect(_on_encounter_activated)
	if GameState.arena_completed.is_connected(_on_arena_completed):
		GameState.arena_completed.disconnect(_on_arena_completed)
