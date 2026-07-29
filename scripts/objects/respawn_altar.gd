class_name RespawnAltar
extends Area2D

signal interaction_available(altar: RespawnAltar)
signal interaction_unavailable(altar: RespawnAltar)
signal altar_activated(
	altar_id: StringName,
	respawn_position: Vector2
)

@export var altar_id: StringName = &"prototype_altar_01"

@onready var altar_visual: Polygon2D = $Visuals/AltarVisual
@onready var active_glow: Polygon2D = $Visuals/ActiveGlow
@onready var interaction_area: Area2D = $InteractionArea
@onready var respawn_marker: Marker2D = $RespawnMarker
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_active: bool = false
var nearby_player: Node2D = null

const INACTIVE_COLOR: Color = Color(0.34, 0.36, 0.42, 1.0)
const ACTIVE_COLOR: Color = Color(0.88, 0.68, 0.24, 1.0)
const ACTIVE_BRIGHTNESS: Color = Color(1.25, 1.1, 0.75, 1.0)


func _ready() -> void:
	interaction_area.body_entered.connect(
		_on_interaction_area_body_entered
	)
	interaction_area.body_exited.connect(
		_on_interaction_area_body_exited
	)
	if not _is_game_state_available():
		push_error("RespawnAltar requires the GameState Autoload.")
		_set_active_visual(false)
		return
	_restore_active_state()


func _process(_delta: float) -> void:
	if (
		is_active
		or nearby_player == null
		or not is_instance_valid(nearby_player)
	):
		return
	if Input.is_action_just_pressed(&"interact"):
		activate()


func activate() -> bool:
	if (
		is_active
		or nearby_player == null
		or not is_instance_valid(nearby_player)
	):
		return false
	if not _is_game_state_available():
		push_error("RespawnAltar could not access GameState.")
		return false

	var respawn_position: Vector2 = respawn_marker.global_position
	if not respawn_position.is_finite():
		push_error("RespawnAltar has an invalid RespawnMarker position.")
		return false

	GameState.set_respawn_point(respawn_position, altar_id)
	if (
		not GameState.has_respawn_point
		or GameState.active_altar_id != altar_id
		or GameState.current_respawn_position != respawn_position
	):
		push_error("RespawnAltar could not register its respawn point.")
		return false

	is_active = true
	_set_active_visual(true)
	interaction_unavailable.emit(self)
	altar_activated.emit(
		altar_id,
		respawn_position
	)
	return true


func has_nearby_player() -> bool:
	return (
		nearby_player != null
		and is_instance_valid(nearby_player)
	)


func get_respawn_position() -> Vector2:
	return respawn_marker.global_position


func _is_game_state_available() -> bool:
	return GameState != null and is_instance_valid(GameState)


func _restore_active_state() -> void:
	is_active = (
		GameState.has_respawn_point
		and GameState.active_altar_id == altar_id
	)
	_set_active_visual(is_active)


func _set_active_visual(active: bool) -> void:
	altar_visual.color = ACTIVE_COLOR if active else INACTIVE_COLOR
	altar_visual.modulate = ACTIVE_BRIGHTNESS if active else Color.WHITE
	active_glow.visible = active
	if active:
		animation_player.play(&"active_pulse")
	else:
		animation_player.stop()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	var detected_player: CharacterBody2D = body as CharacterBody2D
	if detected_player == null:
		return

	nearby_player = detected_player
	if not is_active:
		interaction_available.emit(self)


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body != nearby_player:
		return

	nearby_player = null
	if not is_active:
		interaction_unavailable.emit(self)
