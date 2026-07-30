@tool
class_name EncounterZone
extends Area2D

signal encounter_activated(
	encounter_id: StringName,
	enemy_spawn_ids: Array[StringName]
)

@export var encounter_id: StringName = &""
@export var enemy_spawn_ids: Array[StringName] = []
@export var activate_once: bool = true
@export var show_debug_visual: bool = false:
	set(value):
		show_debug_visual = value
		_update_debug_visibility()
@export var zone_size: Vector2 = Vector2(100.0, 100.0):
	set(value):
		zone_size = Vector2(
			maxf(value.x, 1.0),
			maxf(value.y, 1.0)
		)
		_update_zone_geometry()

var has_activated: bool = false


func _ready() -> void:
	_update_zone_geometry()
	_update_debug_visibility()
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	if GameState == null or not is_instance_valid(GameState):
		push_error("EncounterZone requires the GameState Autoload.")
		_disable_zone()
		return
	if encounter_id == &"" or enemy_spawn_ids.is_empty():
		push_error("EncounterZone requires an ID and enemy spawn IDs.")
		_disable_zone()
		return
	has_activated = GameState.is_encounter_activated(encounter_id)
	if has_activated and activate_once:
		_disable_zone()


func _on_body_entered(body: Node2D) -> void:
	if has_activated and activate_once:
		return
	var player: CharacterBody2D = body as CharacterBody2D
	if player == null:
		return
	if not GameState.activate_encounter(encounter_id):
		has_activated = GameState.is_encounter_activated(encounter_id)
		if has_activated and activate_once:
			_disable_zone()
		return

	has_activated = true
	var activated_spawn_ids: Array[StringName] = (
		enemy_spawn_ids.duplicate()
	)
	encounter_activated.emit(encounter_id, activated_spawn_ids)
	if activate_once:
		_disable_zone()


func _disable_zone() -> void:
	set_deferred(&"monitoring", false)
	var collision: CollisionShape2D = get_node_or_null(
		^"CollisionShape2D"
	) as CollisionShape2D
	if collision != null:
		collision.set_deferred(&"disabled", true)


func _update_zone_geometry() -> void:
	var collision: CollisionShape2D = get_node_or_null(
		^"CollisionShape2D"
	) as CollisionShape2D
	if collision != null and collision.shape is RectangleShape2D:
		var rectangle: RectangleShape2D = (
			collision.shape.duplicate() as RectangleShape2D
		)
		rectangle.size = zone_size
		collision.shape = rectangle

	var debug_visual: Polygon2D = get_node_or_null(
		^"DebugVisual"
	) as Polygon2D
	if debug_visual == null:
		return
	var half_size: Vector2 = zone_size * 0.5
	debug_visual.polygon = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y),
	])


func _update_debug_visibility() -> void:
	var debug_visual: Polygon2D = get_node_or_null(
		^"DebugVisual"
	) as Polygon2D
	if debug_visual != null:
		debug_visual.visible = (
			Engine.is_editor_hint()
			or show_debug_visual
		)
