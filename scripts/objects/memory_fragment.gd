class_name MemoryFragment
extends Area2D

signal interaction_available(memory: MemoryFragment)
signal interaction_unavailable(memory: MemoryFragment)
signal memory_remembered(memory: MemoryFragment, memory_id: StringName)
signal memory_opened(
	memory: MemoryFragment,
	memory_id: StringName,
	title: String,
	text: String
)

@export var memory_id: StringName = &"prototype_memory_01"
@export var memory_title: String = "ECHO OF THE FALL"
@export_multiline var memory_text: String = (
	"When the sky split, no one understood the light that fell upon us.\n\n"
	+ "Some called it a blessing. Others, corruption.\n\n"
	+ "I remember only the sound...\n"
	+ "like glass breaking inside the world."
)

@onready var visual: Polygon2D = $Visual
@onready var interaction_area: Area2D = $InteractionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var nearby_player: CharacterBody2D = null
var is_collected: bool = false


func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	if GameState.has_memory(memory_id):
		is_collected = true
		hide()
		queue_free()
		return
	animation_player.play(&"pulse")


func _process(_delta: float) -> void:
	if (
		not is_collected
		and nearby_player != null
		and is_instance_valid(nearby_player)
		and Input.is_action_just_pressed(&"interact")
	):
		remember()


func remember() -> bool:
	if (
		is_collected
		or nearby_player == null
		or not is_instance_valid(nearby_player)
	):
		return false
	var was_registered: bool = GameState.register_memory(memory_id)
	is_collected = true
	interaction_unavailable.emit(self)
	if was_registered:
		memory_remembered.emit(self, memory_id)
		memory_opened.emit(
			self,
			memory_id,
			memory_title,
			memory_text
		)
	visual.hide()
	interaction_area.set_deferred(&"monitoring", false)
	queue_free()
	return was_registered


func has_nearby_player() -> bool:
	return nearby_player != null and is_instance_valid(nearby_player)


func _on_body_entered(body: Node2D) -> void:
	var player: CharacterBody2D = body as CharacterBody2D
	if player == null or is_collected:
		return
	nearby_player = player
	interaction_available.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if body != nearby_player:
		return
	nearby_player = null
	if not is_collected:
		interaction_unavailable.emit(self)
