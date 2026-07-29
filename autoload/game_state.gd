extends Node

signal death_count_changed(new_value: int)
signal respawn_point_changed(
	new_position: Vector2,
	altar_id: StringName
)
signal memory_collected(memory_id: StringName)

var death_count: int = 0
var current_respawn_position: Vector2 = Vector2.ZERO
var active_altar_id: StringName = &""
var has_respawn_point: bool = false
var collected_memory_ids: Array[StringName] = []


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


func reset_run_state() -> void:
	# This represents a new complete run, so run-scoped memories are cleared.
	if death_count != 0:
		death_count = 0
		death_count_changed.emit(death_count)

	clear_respawn_point()
	clear_memories()
