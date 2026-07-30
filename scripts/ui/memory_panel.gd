class_name MemoryPanel
extends Control

signal memory_closed(memory_id: StringName)

@export_range(0.15, 0.3, 0.01) var fade_duration: float = 0.2

@onready var title_label: Label = $Panel/Content/TitleLabel
@onready var body_label: Label = $Panel/Content/BodyLabel
@onready var continue_label: Label = $Panel/Content/ContinueLabel

var is_open: bool = false
var current_memory_id: StringName = &""
var _is_closing: bool = false
var _waiting_for_interact_release: bool = false
var _can_close: bool = false
var _fade_tween: Tween = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	modulate.a = 0.0
	hide()


func _process(_delta: float) -> void:
	if (
		is_open
		and _waiting_for_interact_release
		and not Input.is_action_pressed(&"interact")
	):
		_waiting_for_interact_release = false
		_can_close = true


func _unhandled_input(event: InputEvent) -> void:
	if (
		not is_open
		or _is_closing
		or not _can_close
		or not event.is_action_pressed(&"interact")
		or event.is_echo()
	):
		return
	get_viewport().set_input_as_handled()
	close_memory()


func open_memory(
	memory_id: StringName,
	title: String,
	body: String
) -> bool:
	if (
		is_open
		or memory_id == &""
		or title.strip_edges().is_empty()
		or body.strip_edges().is_empty()
	):
		return false

	_stop_fade_tween()
	current_memory_id = memory_id
	title_label.text = title
	body_label.text = body
	continue_label.text = "Press E to continue"
	is_open = true
	_is_closing = false
	_waiting_for_interact_release = true
	_can_close = false
	modulate.a = 0.0
	show()
	_fade_tween = create_tween()
	_fade_tween.tween_property(
		self,
		^"modulate:a",
		1.0,
		maxf(fade_duration, 0.001)
	)
	_fade_tween.tween_callback(_clear_fade_tween)
	return true


func close_memory() -> bool:
	if not is_open or _is_closing:
		return false
	_stop_fade_tween()
	_is_closing = true
	_can_close = false
	_fade_tween = create_tween()
	_fade_tween.tween_property(
		self,
		^"modulate:a",
		0.0,
		maxf(fade_duration, 0.001)
	)
	_fade_tween.tween_callback(_finish_close)
	return true


func _finish_close() -> void:
	var closed_memory_id: StringName = current_memory_id
	is_open = false
	_is_closing = false
	_waiting_for_interact_release = false
	_can_close = false
	current_memory_id = &""
	modulate.a = 0.0
	hide()
	_fade_tween = null
	memory_closed.emit(closed_memory_id)


func _stop_fade_tween() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null


func _clear_fade_tween() -> void:
	_fade_tween = null


func _exit_tree() -> void:
	_stop_fade_tween()
	if get_tree() != null and get_tree().paused:
		get_tree().paused = false
