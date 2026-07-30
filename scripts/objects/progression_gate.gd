@tool
class_name ProgressionGate
extends StaticBody2D

signal gate_opened(gate_id: StringName)
signal gate_state_changed(gate_id: StringName, is_open: bool)
signal interaction_available(gate: ProgressionGate)
signal interaction_unavailable(gate: ProgressionGate)

@export var gate_id: StringName = &""
@export var required_encounter_id: StringName = &""
@export var opening_duration: float = 0.3
@export var gate_size: Vector2 = Vector2(40.0, 240.0):
	set(value):
		gate_size = Vector2(maxf(value.x, 1.0), maxf(value.y, 1.0))
		_update_geometry()
@export var interaction_margin: Vector2 = Vector2(96.0, 96.0):
	set(value):
		interaction_margin = Vector2(
			maxf(value.x, 0.0),
			maxf(value.y, 0.0)
		)
		_update_geometry()

@onready var locked_visual: Polygon2D = $LockedVisual
@onready var open_visual: Polygon2D = $OpenVisual
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_collision: CollisionShape2D = (
	$InteractionArea/CollisionShape2D
)

var is_open: bool = false
var nearby_player: CharacterBody2D = null
var _opening_tween: Tween = null


func _ready() -> void:
	_update_geometry()
	if Engine.is_editor_hint():
		return
	if GameState == null or not is_instance_valid(GameState):
		push_error("ProgressionGate requires the GameState Autoload.")
		_apply_closed_state()
		return
	if gate_id == &"" or required_encounter_id == &"":
		push_error("ProgressionGate requires gate and encounter IDs.")
		_apply_closed_state()
		return

	if not interaction_area.body_entered.is_connected(
		_on_interaction_body_entered
	):
		interaction_area.body_entered.connect(
			_on_interaction_body_entered
		)
	if not interaction_area.body_exited.is_connected(
		_on_interaction_body_exited
	):
		interaction_area.body_exited.connect(
			_on_interaction_body_exited
		)

	if GameState.is_encounter_completed(required_encounter_id):
		_apply_open_state(false)
	else:
		_apply_closed_state()


func open_gate() -> bool:
	if is_open:
		return false
	_apply_open_state(true)
	gate_opened.emit(gate_id)
	gate_state_changed.emit(gate_id, true)
	return true


func has_nearby_player() -> bool:
	return (
		not is_open
		and nearby_player != null
		and is_instance_valid(nearby_player)
	)


func get_prompt_text() -> String:
	return "The path is sealed"


func _apply_closed_state() -> void:
	_stop_opening_tween()
	is_open = false
	nearby_player = null
	locked_visual.show()
	locked_visual.modulate = Color.WHITE
	locked_visual.scale = Vector2.ONE
	open_visual.hide()
	body_collision.disabled = false
	interaction_area.monitoring = true
	interaction_collision.disabled = false


func _apply_open_state(animate: bool) -> void:
	_stop_opening_tween()
	is_open = true
	if nearby_player != null and is_instance_valid(nearby_player):
		interaction_unavailable.emit(self)
	nearby_player = null
	body_collision.set_deferred(&"disabled", true)
	interaction_area.set_deferred(&"monitoring", false)
	interaction_collision.set_deferred(&"disabled", true)
	open_visual.show()

	if not animate:
		locked_visual.hide()
		locked_visual.modulate = Color.WHITE
		locked_visual.scale = Vector2.ONE
		return

	locked_visual.show()
	locked_visual.modulate = Color.WHITE
	locked_visual.scale = Vector2.ONE
	var target_scale: Vector2 = (
		Vector2(0.08, 1.0)
		if gate_size.y >= gate_size.x
		else Vector2(1.0, 0.08)
	)
	_opening_tween = create_tween().set_parallel()
	_opening_tween.tween_property(
		locked_visual,
		^"modulate:a",
		0.0,
		maxf(opening_duration, 0.001)
	)
	_opening_tween.tween_property(
		locked_visual,
		^"scale",
		target_scale,
		maxf(opening_duration, 0.001)
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_opening_tween.chain().tween_callback(_finish_opening_visual)


func _finish_opening_visual() -> void:
	locked_visual.hide()
	locked_visual.modulate = Color.WHITE
	locked_visual.scale = Vector2.ONE
	_opening_tween = null


func _stop_opening_tween() -> void:
	if _opening_tween != null and _opening_tween.is_valid():
		_opening_tween.kill()
	_opening_tween = null


func _on_interaction_body_entered(body: Node2D) -> void:
	if is_open:
		return
	var player: CharacterBody2D = body as CharacterBody2D
	if player == null:
		return
	nearby_player = player
	interaction_available.emit(self)


func _on_interaction_body_exited(body: Node2D) -> void:
	if body != nearby_player:
		return
	nearby_player = null
	interaction_unavailable.emit(self)


func _update_geometry() -> void:
	_update_shape(^"CollisionShape2D", gate_size)
	_update_shape(
		^"InteractionArea/CollisionShape2D",
		gate_size + interaction_margin
	)
	_update_visual(^"LockedVisual", gate_size)
	_update_visual(^"OpenVisual", gate_size)


func _update_shape(path: NodePath, size: Vector2) -> void:
	var collision: CollisionShape2D = get_node_or_null(
		path
	) as CollisionShape2D
	if collision == null or not collision.shape is RectangleShape2D:
		return
	var rectangle: RectangleShape2D = (
		collision.shape.duplicate() as RectangleShape2D
	)
	rectangle.size = size
	collision.shape = rectangle


func _update_visual(path: NodePath, size: Vector2) -> void:
	var visual: Polygon2D = get_node_or_null(path) as Polygon2D
	if visual == null:
		return
	var half_size: Vector2 = size * 0.5
	visual.polygon = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y),
	])


func _exit_tree() -> void:
	_stop_opening_tween()
