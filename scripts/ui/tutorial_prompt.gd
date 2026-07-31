class_name TutorialPrompt
extends Control

signal prompt_visibility_changed(is_visible: bool)

@export_range(0.15, 0.25, 0.01) var fade_duration: float = 0.2

@onready var action_label: Label = $Panel/Content/ActionLabel
@onready var description_label: Label = $Panel/Content/DescriptionLabel

var current_step_id: StringName = &""
var _fade_tween: Tween = null


func _ready() -> void:
	modulate.a = 0.0
	hide()


func show_step(
	step_id: StringName,
	action_text: String,
	description_text: String
) -> bool:
	if (
		step_id == &""
		or action_text.strip_edges().is_empty()
		or description_text.strip_edges().is_empty()
	):
		return false

	var was_visible: bool = visible
	var is_same_step: bool = current_step_id == step_id
	_stop_fade_tween()
	current_step_id = step_id
	action_label.text = action_text
	description_label.text = description_text
	if was_visible and is_same_step and is_equal_approx(modulate.a, 1.0):
		return true

	if not was_visible:
		modulate.a = 0.0
		show()
		prompt_visibility_changed.emit(true)

	_fade_tween = create_tween()
	_fade_tween.tween_property(
		self,
		^"modulate:a",
		1.0,
		maxf(fade_duration, 0.001)
	)
	_fade_tween.tween_callback(_clear_fade_tween)
	return true


func hide_prompt(immediate: bool = false) -> void:
	if not visible:
		current_step_id = &""
		return

	_stop_fade_tween()
	if immediate:
		_finish_hide()
		return

	_fade_tween = create_tween()
	_fade_tween.tween_property(
		self,
		^"modulate:a",
		0.0,
		maxf(fade_duration, 0.001)
	)
	_fade_tween.tween_callback(_finish_hide)


func _finish_hide() -> void:
	var was_visible: bool = visible
	modulate.a = 0.0
	hide()
	current_step_id = &""
	_fade_tween = null
	if was_visible:
		prompt_visibility_changed.emit(false)


func _stop_fade_tween() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null


func _clear_fade_tween() -> void:
	_fade_tween = null


func _exit_tree() -> void:
	_stop_fade_tween()
