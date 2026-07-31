extends Node

signal death_count_changed(new_value: int)
signal respawn_point_changed(
	new_position: Vector2,
	altar_id: StringName
)
signal memory_collected(memory_id: StringName)
signal objective_progress_changed(
	defeated_spawn_count: int,
	required_spawn_count: int,
	memory_collected: bool,
	altar_activated: bool
)
signal arena_exit_unlocked
signal arena_completed
signal encounter_activated(encounter_id: StringName)
signal encounter_completed(encounter_id: StringName)
signal tutorial_step_completed(step_id: StringName)

var death_count: int = 0
var current_respawn_position: Vector2 = Vector2.ZERO
var active_altar_id: StringName = &""
var has_respawn_point: bool = false
var collected_memory_ids: Array[StringName] = []
var defeated_enemy_spawn_ids: Array[StringName] = []
var arena_exit_is_unlocked: bool = false
var arena_is_completed: bool = false
var activated_encounter_ids: Array[StringName] = []
var completed_encounter_ids: Array[StringName] = []
var completed_tutorial_steps: Array[StringName] = []

var _required_enemy_spawn_count: int = 0
var _last_progress_spawn_count: int = -1
var _last_progress_required_count: int = -1
var _last_progress_memory_collected: bool = false
var _last_progress_altar_activated: bool = false

const REQUIRED_MEMORY_ID: StringName = &"prototype_memory_01"
const REQUIRED_ALTAR_ID: StringName = &"prototype_altar_01"


func register_death() -> void:
	death_count += 1
	death_count_changed.emit(death_count)


func set_respawn_point(position: Vector2, altar_id: StringName) -> void:
	if not position.is_finite():
		return

	var respawn_point_changed_value: bool = (
		not has_respawn_point
		or current_respawn_position != position
		or active_altar_id != altar_id
	)

	current_respawn_position = position
	active_altar_id = altar_id
	has_respawn_point = true

	if respawn_point_changed_value:
		respawn_point_changed.emit(current_respawn_position, active_altar_id)


func clear_respawn_point() -> void:
	var respawn_point_changed_value: bool = (
		has_respawn_point
		or current_respawn_position != Vector2.ZERO
		or active_altar_id != &""
	)

	current_respawn_position = Vector2.ZERO
	active_altar_id = &""
	has_respawn_point = false

	if respawn_point_changed_value:
		respawn_point_changed.emit(current_respawn_position, active_altar_id)


func register_memory(memory_id: StringName) -> bool:
	if memory_id == &"" or collected_memory_ids.has(memory_id):
		return false
	collected_memory_ids.append(memory_id)
	memory_collected.emit(memory_id)
	return true


func has_memory(memory_id: StringName) -> bool:
	return memory_id != &"" and collected_memory_ids.has(memory_id)


func clear_memories() -> void:
	collected_memory_ids.clear()


func register_defeated_enemy_spawn(spawn_id: StringName) -> bool:
	if spawn_id == &"" or defeated_enemy_spawn_ids.has(spawn_id):
		return false
	defeated_enemy_spawn_ids.append(spawn_id)
	return true


func has_defeated_enemy_spawn(spawn_id: StringName) -> bool:
	return spawn_id != &"" and defeated_enemy_spawn_ids.has(spawn_id)


func get_defeated_enemy_spawn_count() -> int:
	return defeated_enemy_spawn_ids.size()


func activate_encounter(encounter_id: StringName) -> bool:
	if encounter_id == &"" or activated_encounter_ids.has(encounter_id):
		return false
	activated_encounter_ids.append(encounter_id)
	encounter_activated.emit(encounter_id)
	return true


func complete_encounter(encounter_id: StringName) -> bool:
	if (
		encounter_id == &""
		or not activated_encounter_ids.has(encounter_id)
		or completed_encounter_ids.has(encounter_id)
	):
		return false
	completed_encounter_ids.append(encounter_id)
	encounter_completed.emit(encounter_id)
	return true


func is_encounter_activated(encounter_id: StringName) -> bool:
	return encounter_id != &"" and activated_encounter_ids.has(encounter_id)


func is_encounter_completed(encounter_id: StringName) -> bool:
	return encounter_id != &"" and completed_encounter_ids.has(encounter_id)


func clear_encounter_progress() -> void:
	activated_encounter_ids.clear()
	completed_encounter_ids.clear()


func complete_tutorial_step(step_id: StringName) -> bool:
	if step_id == &"" or completed_tutorial_steps.has(step_id):
		return false
	completed_tutorial_steps.append(step_id)
	tutorial_step_completed.emit(step_id)
	return true


func is_tutorial_step_completed(step_id: StringName) -> bool:
	return step_id != &"" and completed_tutorial_steps.has(step_id)


func clear_tutorial_progress() -> void:
	completed_tutorial_steps.clear()


func evaluate_arena_objective(required_spawn_count: int) -> bool:
	_required_enemy_spawn_count = maxi(required_spawn_count, 0)
	var memory_is_collected: bool = has_memory(REQUIRED_MEMORY_ID)
	var altar_is_activated: bool = (
		has_respawn_point
		and active_altar_id == REQUIRED_ALTAR_ID
	)
	_emit_objective_progress_if_changed(
		memory_is_collected,
		altar_is_activated
	)

	var objective_is_complete: bool = (
		defeated_enemy_spawn_ids.size() >= _required_enemy_spawn_count
		and _required_enemy_spawn_count > 0
		and memory_is_collected
		and altar_is_activated
	)
	if objective_is_complete and not arena_exit_is_unlocked:
		arena_exit_is_unlocked = true
		arena_exit_unlocked.emit()
	return arena_exit_is_unlocked


func complete_arena() -> bool:
	if not arena_exit_is_unlocked or arena_is_completed:
		return false
	arena_is_completed = true
	arena_completed.emit()
	return true


func clear_arena_progress() -> void:
	var progress_changed: bool = (
		not defeated_enemy_spawn_ids.is_empty()
		or arena_exit_is_unlocked
		or arena_is_completed
	)
	defeated_enemy_spawn_ids.clear()
	arena_exit_is_unlocked = false
	arena_is_completed = false
	if progress_changed:
		_reset_progress_snapshot()
	_emit_objective_progress_if_changed(
		has_memory(REQUIRED_MEMORY_ID),
		has_respawn_point and active_altar_id == REQUIRED_ALTAR_ID
	)


func _emit_objective_progress_if_changed(
	memory_is_collected: bool,
	altar_is_activated: bool
) -> void:
	var defeated_spawn_count: int = defeated_enemy_spawn_ids.size()
	if (
		defeated_spawn_count == _last_progress_spawn_count
		and _required_enemy_spawn_count == _last_progress_required_count
		and memory_is_collected == _last_progress_memory_collected
		and altar_is_activated == _last_progress_altar_activated
	):
		return

	_last_progress_spawn_count = defeated_spawn_count
	_last_progress_required_count = _required_enemy_spawn_count
	_last_progress_memory_collected = memory_is_collected
	_last_progress_altar_activated = altar_is_activated
	objective_progress_changed.emit(
		defeated_spawn_count,
		_required_enemy_spawn_count,
		memory_is_collected,
		altar_is_activated
	)


func _reset_progress_snapshot() -> void:
	_last_progress_spawn_count = -1
	_last_progress_required_count = -1
	_last_progress_memory_collected = false
	_last_progress_altar_activated = false


func reset_run_state() -> void:
	# A complete new run clears run-scoped memories and arena progress.
	if death_count != 0:
		death_count = 0
		death_count_changed.emit(death_count)

	clear_respawn_point()
	clear_memories()
	clear_arena_progress()
	clear_encounter_progress()
	clear_tutorial_progress()
