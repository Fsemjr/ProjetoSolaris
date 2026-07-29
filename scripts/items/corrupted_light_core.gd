class_name CorruptedLightCore
extends Area2D

signal interaction_available(core: CorruptedLightCore)
signal interaction_unavailable(core: CorruptedLightCore)
signal absorption_started(core: CorruptedLightCore)
signal absorption_completed(
	core: CorruptedLightCore,
	player: CharacterBody2D
)
signal absorption_cancelled(
	core: CorruptedLightCore,
	player: CharacterBody2D
)

@export var corrupted_light_amount: float = 10.0
@export var instability_amount: float = 6.0
@export var absorption_duration: float = 0.75

@onready var interaction_area: Area2D = $InteractionArea
@onready var absorption_timer: Timer = $AbsorptionTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var nearby_player: CharacterBody2D = null
var absorbing_player: CharacterBody2D = null
var is_being_absorbed: bool = false
var _absorption_tween: Tween = null


func _ready() -> void:
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	absorption_timer.timeout.connect(_on_absorption_timer_timeout)
	absorption_timer.wait_time = maxf(absorption_duration, 0.001)
	animation_player.play(&"pulse")


func can_begin_absorption(player: CharacterBody2D) -> bool:
	return (
		not is_being_absorbed
		and player != null
		and is_instance_valid(player)
		and nearby_player == player
	)


func has_nearby_player() -> bool:
	return nearby_player != null and is_instance_valid(nearby_player)


func begin_absorption(player: CharacterBody2D) -> bool:
	if not can_begin_absorption(player):
		return false

	is_being_absorbed = true
	absorbing_player = player
	_start_absorption_effect()
	absorption_timer.start(maxf(absorption_duration, 0.001))
	absorption_started.emit(self)
	return true


func cancel_absorption(player: CharacterBody2D) -> void:
	if not is_being_absorbed or player != absorbing_player:
		return

	_cancel_current_absorption()


func cancel_pending_absorption() -> void:
	if is_being_absorbed:
		_cancel_current_absorption()


func finish_absorption(player: CharacterBody2D) -> bool:
	if (
		not is_being_absorbed
		or player != absorbing_player
		or player != nearby_player
	):
		return false

	_clear_absorption_state()
	_complete_absorption_effect()
	return true


func _on_interaction_area_body_entered(body: Node2D) -> void:
	var detected_player: CharacterBody2D = body as CharacterBody2D
	if detected_player == null:
		return

	nearby_player = detected_player
	interaction_available.emit(self)


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body != nearby_player:
		return

	nearby_player = null
	if is_being_absorbed and body == absorbing_player:
		_cancel_current_absorption()
	interaction_unavailable.emit(self)


func _on_absorption_timer_timeout() -> void:
	if (
		not is_being_absorbed
		or absorbing_player == null
		or not is_instance_valid(absorbing_player)
		or nearby_player != absorbing_player
	):
		_cancel_current_absorption()
		return

	absorption_completed.emit(self, absorbing_player)
	if is_being_absorbed:
		_cancel_current_absorption()


func _cancel_current_absorption() -> void:
	var cancelled_player: CharacterBody2D = absorbing_player
	_clear_absorption_state()
	_cancel_absorption_effect()
	if cancelled_player != null and is_instance_valid(cancelled_player):
		absorption_cancelled.emit(self, cancelled_player)


func _clear_absorption_state() -> void:
	absorption_timer.stop()
	is_being_absorbed = false
	absorbing_player = null


func _start_absorption_effect() -> void:
	_cancel_absorption_effect()
	_absorption_tween = create_tween()
	_absorption_tween.set_parallel(true)
	_absorption_tween.tween_property(
		self,
		^"scale",
		Vector2(1.35, 1.35),
		absorption_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_absorption_tween.tween_property(
		self,
		^"modulate",
		Color(1.25, 0.75, 1.4, 0.2),
		absorption_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _cancel_absorption_effect() -> void:
	if _absorption_tween != null and _absorption_tween.is_valid():
		_absorption_tween.kill()
	_absorption_tween = null
	scale = Vector2.ONE
	modulate = Color.WHITE


func _complete_absorption_effect() -> void:
	if _absorption_tween != null and _absorption_tween.is_valid():
		_absorption_tween.kill()
	_absorption_tween = null
	scale = Vector2(1.45, 1.45)
	modulate = Color(1.25, 0.75, 1.4, 0.0)


func _exit_tree() -> void:
	if _absorption_tween != null and _absorption_tween.is_valid():
		_absorption_tween.kill()
