extends CharacterBody2D

signal dodge_started
signal dodge_ended

enum MovementState {
	NORMAL,
	DODGING,
	DEAD,
}

@export var movement_speed: float = 220.0
@export var dodge_speed: float = 520.0
@export var dodge_duration: float = 0.20
@export var dodge_cooldown: float = 1.0

@onready var dodge_duration_timer: Timer = $DodgeDuration
@onready var dodge_cooldown_timer: Timer = $DodgeCooldown

var movement_state: MovementState = MovementState.NORMAL
var last_movement_direction: Vector2 = Vector2.DOWN

var _dodge_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	dodge_duration_timer.wait_time = maxf(dodge_duration, 0.001)
	dodge_cooldown_timer.wait_time = maxf(dodge_cooldown, 0.001)
	if not dodge_duration_timer.timeout.is_connected(
		_on_dodge_duration_timeout
	):
		dodge_duration_timer.timeout.connect(
			_on_dodge_duration_timeout
		)


func _physics_process(_delta: float) -> void:
	if movement_state == MovementState.DEAD:
		velocity = Vector2.ZERO
		return

	var direction: Vector2 = Input.get_vector(
		&"move_left",
		&"move_right",
		&"move_up",
		&"move_down"
	)
	if movement_state == MovementState.DODGING:
		velocity = _dodge_direction * dodge_speed
		move_and_slide()
		return

	if direction != Vector2.ZERO:
		last_movement_direction = direction.normalized()

	if (
		Input.is_action_just_pressed(&"dodge")
		and _can_start_dodge()
		and dodge_cooldown_timer.is_stopped()
	):
		var requested_direction: Vector2 = (
			direction.normalized()
			if direction != Vector2.ZERO
			else last_movement_direction
		)
		_start_dodge(requested_direction)
		velocity = _dodge_direction * dodge_speed
		move_and_slide()
		return

	velocity = direction * movement_speed
	move_and_slide()


func is_dodging() -> bool:
	return movement_state == MovementState.DODGING


func cancel_dodge() -> void:
	if movement_state != MovementState.DODGING:
		return

	dodge_duration_timer.stop()
	_finish_dodge()


func enter_dead_state() -> void:
	dodge_duration_timer.stop()
	dodge_cooldown_timer.stop()
	movement_state = MovementState.DEAD
	velocity = Vector2.ZERO
	set_physics_process(false)


func exit_dead_state() -> void:
	if movement_state != MovementState.DEAD:
		return

	dodge_duration_timer.stop()
	dodge_cooldown_timer.stop()
	velocity = Vector2.ZERO
	movement_state = MovementState.NORMAL
	set_physics_process(true)


func is_dead_state() -> bool:
	return movement_state == MovementState.DEAD


func _can_start_dodge() -> bool:
	return movement_state == MovementState.NORMAL


func _start_dodge(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		direction = Vector2.DOWN

	_dodge_direction = direction.normalized()
	movement_state = MovementState.DODGING
	dodge_duration_timer.start(maxf(dodge_duration, 0.001))
	dodge_started.emit()


func _finish_dodge() -> void:
	if movement_state != MovementState.DODGING:
		return

	movement_state = MovementState.NORMAL
	velocity = Vector2.ZERO
	dodge_cooldown_timer.start(maxf(dodge_cooldown, 0.001))
	dodge_ended.emit()


func _on_dodge_duration_timeout() -> void:
	_finish_dodge()

