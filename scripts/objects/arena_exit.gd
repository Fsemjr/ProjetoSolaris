class_name ArenaExit
extends Area2D

signal interaction_available(arena_exit: ArenaExit)
signal interaction_unavailable(arena_exit: ArenaExit)
signal prompt_changed(arena_exit: ArenaExit)
signal exit_used(arena_exit: ArenaExit, exit_id: StringName)

@export var exit_id: StringName = &"prototype_exit_01"

@onready var locked_visual: Polygon2D = $LockedVisual
@onready var unlocked_visual: Polygon2D = $UnlockedVisual
@onready var interaction_area: Area2D = $InteractionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var nearby_player: CharacterBody2D = null
var is_unlocked: bool = false
var is_completed: bool = false


func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	if GameState == null or not is_instance_valid(GameState):
		push_error("ArenaExit requires the GameState Autoload.")
		_set_unlocked_visual(false)
		return
	if not GameState.arena_exit_unlocked.is_connected(_on_exit_unlocked):
		GameState.arena_exit_unlocked.connect(_on_exit_unlocked)
	if not GameState.arena_completed.is_connected(_on_arena_completed):
		GameState.arena_completed.connect(_on_arena_completed)
	is_unlocked = GameState.arena_exit_is_unlocked
	is_completed = GameState.arena_is_completed
	_set_unlocked_visual(is_unlocked)
	set_process(not is_completed)


func _process(_delta: float) -> void:
	if (
		is_completed
		or nearby_player == null
		or not is_instance_valid(nearby_player)
		or not Input.is_action_just_pressed(&"interact")
	):
		return
	if not is_unlocked:
		return
	if GameState.complete_arena():
		exit_used.emit(self, exit_id)


func has_nearby_player() -> bool:
	return nearby_player != null and is_instance_valid(nearby_player)


func get_prompt_text() -> String:
	if is_unlocked:
		return "Press E to leave the arena"
	return (
		"Defeat all enemies, remember the memory, "
		+ "and activate the altar"
	)


func _on_exit_unlocked() -> void:
	if is_unlocked:
		return
	is_unlocked = true
	_set_unlocked_visual(true)
	prompt_changed.emit(self)


func _on_arena_completed() -> void:
	if is_completed:
		return
	is_completed = true
	set_process(false)
	if has_nearby_player():
		interaction_unavailable.emit(self)
	nearby_player = null


func _set_unlocked_visual(unlocked: bool) -> void:
	locked_visual.visible = not unlocked
	unlocked_visual.visible = unlocked
	if unlocked:
		animation_player.play(&"unlocked_pulse")
	else:
		animation_player.stop()
		unlocked_visual.scale = Vector2.ONE
		unlocked_visual.modulate = Color.WHITE


func _on_body_entered(body: Node2D) -> void:
	if is_completed:
		return
	var player: CharacterBody2D = body as CharacterBody2D
	if player == null:
		return
	nearby_player = player
	interaction_available.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if body != nearby_player:
		return
	nearby_player = null
	if not is_completed:
		interaction_unavailable.emit(self)


func _exit_tree() -> void:
	if GameState == null or not is_instance_valid(GameState):
		return
	if GameState.arena_exit_unlocked.is_connected(_on_exit_unlocked):
		GameState.arena_exit_unlocked.disconnect(_on_exit_unlocked)
	if GameState.arena_completed.is_connected(_on_arena_completed):
		GameState.arena_completed.disconnect(_on_arena_completed)
