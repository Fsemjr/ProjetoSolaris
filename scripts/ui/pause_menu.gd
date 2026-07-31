class_name PauseMenu
extends Control

signal pause_opened
signal pause_closed

@export_range(0.03, 0.1, 0.01) var input_guard_duration: float = 0.05

@onready var resume_button: Button = $Panel/Content/ResumeButton
@onready var quit_button: Button = $Panel/Content/QuitButton
@onready var input_guard_timer: Timer = $InputGuardTimer

var is_open: bool = false
var _is_closing: bool = false
var _is_configured: bool = false
var _player: Node = null
var _tutorial_controller: TutorialController = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	input_guard_timer.wait_time = maxf(input_guard_duration, 0.001)
	if not input_guard_timer.timeout.is_connected(_finish_close_pause):
		input_guard_timer.timeout.connect(_finish_close_pause)
	if not resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.connect(_on_resume_pressed)
	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)


func configure(
	new_player: Node,
	new_tutorial_controller: TutorialController
) -> void:
	if _is_configured:
		return
	if (
		new_player == null
		or not is_instance_valid(new_player)
		or not new_player.has_method(&"can_open_pause")
		or new_tutorial_controller == null
		or not is_instance_valid(new_tutorial_controller)
	):
		push_error("PauseMenu requires valid arena references.")
		return
	_player = new_player
	_tutorial_controller = new_tutorial_controller
	if (
		_player.has_signal(&"player_died")
		and not _player.is_connected(&"player_died", _on_player_died)
	):
		_player.connect(&"player_died", _on_player_died)
	_is_configured = true


func _unhandled_input(event: InputEvent) -> void:
	if (
		_is_closing
		or not event.is_action_pressed(&"pause")
		or event.is_echo()
	):
		return
	if is_open:
		get_viewport().set_input_as_handled()
		close_pause()
	elif _can_open_pause():
		get_viewport().set_input_as_handled()
		open_pause()


func open_pause() -> void:
	if is_open or _is_closing or not _can_open_pause():
		return

	input_guard_timer.stop()
	resume_button.disabled = false
	quit_button.disabled = false
	is_open = true
	show()
	_tutorial_controller.set_pause_menu_active(true)
	get_tree().paused = true
	resume_button.grab_focus()
	pause_opened.emit()


func close_pause() -> void:
	if not is_open or _is_closing:
		return
	_is_closing = true
	resume_button.disabled = true
	quit_button.disabled = true
	input_guard_timer.start(maxf(input_guard_duration, 0.001))


func toggle_pause() -> void:
	if is_open:
		close_pause()
	else:
		open_pause()


func _can_open_pause() -> bool:
	return (
		_is_configured
		and not get_tree().paused
		and _player != null
		and is_instance_valid(_player)
		and bool(_player.call(&"can_open_pause"))
	)


func _finish_close_pause() -> void:
	if not is_open:
		_is_closing = false
		return

	input_guard_timer.stop()
	is_open = false
	_is_closing = false
	hide()
	get_viewport().gui_release_focus()
	get_tree().paused = false
	if (
		_tutorial_controller != null
		and is_instance_valid(_tutorial_controller)
	):
		_tutorial_controller.set_pause_menu_active(false)
	pause_closed.emit()


func _force_close_pause() -> void:
	input_guard_timer.stop()
	_is_closing = false
	if not is_open:
		return
	is_open = false
	hide()
	get_viewport().gui_release_focus()
	get_tree().paused = false
	if (
		_tutorial_controller != null
		and is_instance_valid(_tutorial_controller)
	):
		_tutorial_controller.set_pause_menu_active(false)
	pause_closed.emit()


func _on_resume_pressed() -> void:
	close_pause()


func _on_quit_pressed() -> void:
	if not is_open or _is_closing:
		return
	get_tree().quit()


func _on_player_died() -> void:
	# A death registered in the same frame has priority over the pause overlay.
	_force_close_pause()


func _exit_tree() -> void:
	input_guard_timer.stop()
	if (
		_player != null
		and is_instance_valid(_player)
		and _player.has_signal(&"player_died")
		and _player.is_connected(&"player_died", _on_player_died)
	):
		_player.disconnect(&"player_died", _on_player_died)
	if is_open or _is_closing:
		get_tree().paused = false
	if (
		_tutorial_controller != null
		and is_instance_valid(_tutorial_controller)
	):
		_tutorial_controller.set_pause_menu_active(false)
