extends Node2D

@onready var entities: Node2D = $Entities
@onready var objects: Node2D = $Objects
@onready var pickups: Node2D = $Pickups
@onready var encounter_zones: Node2D = $EncounterZones
@onready var progression_gates: Node2D = $ProgressionGates
@onready var player: CharacterBody2D = $Entities/Player
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var player_hud: PlayerHUD = $CanvasLayer/PlayerHUD

var _common_enemy_spawns: Array[Dictionary] = []
var _encounter_spawn_ids: Dictionary = {}
var _spawn_encounter_ids: Dictionary = {}

const REQUIRED_ENEMY_SPAWN_COUNT: int = 4


func _ready() -> void:
	_connect_objective_signals()
	_configure_player_spawn()
	_bind_player_hud()
	if player.has_signal(&"player_died"):
		player.connect(&"player_died", _on_player_died)
	else:
		push_error("PrototypeArena could not observe player death.")
	for pickup: Node in pickups.get_children():
		var existing_core: CorruptedLightCore = (
			pickup as CorruptedLightCore
		)
		if existing_core != null:
			player_hud.observe_core(existing_core)

	for object: Node in objects.get_children():
		var altar: RespawnAltar = object as RespawnAltar
		if altar != null:
			player_hud.observe_altar(altar)
		var memory: MemoryFragment = object as MemoryFragment
		if memory != null and not memory.is_queued_for_deletion():
			player_hud.observe_memory(memory)
		var arena_exit: ArenaExit = object as ArenaExit
		if arena_exit != null:
			player_hud.observe_arena_exit(arena_exit)

	_configure_progression_gates()
	_register_common_enemy_spawns()
	_configure_encounters()
	for entity: Node in entities.get_children():
		_connect_enemy_signals(entity)
	_evaluate_all_encounter_completions()
	_evaluate_arena_objective()


func clear_corrupted_light_cores() -> void:
	for node: Node in get_tree().get_nodes_in_group(
		&"corrupted_light_cores"
	):
		var core: CorruptedLightCore = node as CorruptedLightCore
		if (
			core == null
			or not is_instance_valid(core)
			or not is_ancestor_of(core)
			or core.is_queued_for_deletion()
		):
			continue
		core.cancel_pending_absorption()
		core.queue_free()


func _on_player_died() -> void:
	clear_corrupted_light_cores()
	restore_common_enemies()


func _register_common_enemy_spawns() -> void:
	var registered_spawn_ids: Array[StringName] = []
	for entity: Node in entities.get_children():
		if not entity.is_in_group(&"common_enemies"):
			continue
		var enemy: Node2D = entity as Node2D
		if enemy == null or enemy.scene_file_path.is_empty():
			push_error("Common enemy requires a reusable scene.")
			continue
		var spawn_id: StringName = enemy.get(&"spawn_id") as StringName
		if spawn_id == &"":
			push_error("Common enemy requires a stable spawn_id.")
			continue
		if registered_spawn_ids.has(spawn_id):
			push_error("Common enemy spawn_id must be unique.")
			continue
		var enemy_scene: PackedScene = load(
			enemy.scene_file_path
		) as PackedScene
		if enemy_scene == null:
			push_error("Could not load common enemy scene.")
			continue
		registered_spawn_ids.append(spawn_id)
		_common_enemy_spawns.append({
			"id": spawn_id,
			"scene": enemy_scene,
			"transform": enemy.global_transform,
			"enemy": enemy,
		})


func restore_common_enemies() -> void:
	for spawn: Dictionary in _common_enemy_spawns:
		var enemy_value: Variant = spawn.get("enemy")
		var enemy: Node2D = null
		if is_instance_valid(enemy_value):
			enemy = enemy_value as Node2D
		if (
			enemy == null
			or enemy.is_queued_for_deletion()
		):
			var enemy_scene: PackedScene = spawn.get("scene") as PackedScene
			if enemy_scene == null:
				continue
			enemy = enemy_scene.instantiate() as Node2D
			if enemy == null:
				push_error("Common enemy scene must instantiate Node2D.")
				continue
			enemy.set(&"spawn_id", spawn.get("id", &""))
			entities.add_child(enemy)
			spawn["enemy"] = enemy
			_connect_enemy_signals(enemy)

		if not enemy.has_method(&"reset_enemy"):
			push_error("Common enemy requires reset_enemy().")
			continue
		var spawn_transform: Transform2D = spawn.get(
			"transform",
			Transform2D.IDENTITY
		)
		enemy.call(&"reset_enemy", spawn_transform)
		_apply_enemy_encounter_state(
			enemy,
			spawn.get("id", &"") as StringName
		)


func _connect_enemy_signals(entity: Node) -> void:
	if not entity.has_signal(&"enemy_died"):
		return
	if not entity.is_connected(&"enemy_died", _on_enemy_died):
		entity.connect(&"enemy_died", _on_enemy_died)


func _configure_player_spawn() -> void:
	if not player.has_method(&"set_fallback_respawn_position"):
		push_error("PrototypeArena could not configure PlayerSpawn.")
		return
	player.call(
		&"set_fallback_respawn_position",
		player_spawn.global_position
	)


func _bind_player_hud() -> void:
	var health_component: HealthComponent = player.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	var corruption_component: CorruptionComponent = player.get_node_or_null(
		"CorruptionComponent"
	) as CorruptionComponent
	if health_component == null or corruption_component == null:
		push_error("PrototypeArena could not bind the PlayerHUD.")
		return

	player_hud.bind_player_components(
		health_component,
		corruption_component
	)
	player_hud.bind_player_lifecycle(player)


func _on_enemy_died(enemy: Node2D, death_position: Vector2) -> void:
	if not is_instance_valid(enemy):
		return
	var spawn_id: StringName = _find_spawn_id_for_enemy(enemy)
	if spawn_id != &"":
		if GameState.register_defeated_enemy_spawn(spawn_id):
			_evaluate_arena_objective()
			_evaluate_encounter_completion_for_spawn(spawn_id)
	if not enemy.has_method(&"claim_corrupted_light_core_scene"):
		return

	var drop_scene_value: Variant = enemy.call(
		&"claim_corrupted_light_core_scene"
	)
	var drop_scene: PackedScene = drop_scene_value as PackedScene
	if drop_scene == null:
		return

	var core: CorruptedLightCore = (
		drop_scene.instantiate() as CorruptedLightCore
	)
	if core == null:
		push_error(
			"CorruptedLightCore scene must use CorruptedLightCore."
		)
		return

	pickups.add_child(core)
	core.global_position = death_position
	player_hud.observe_core(core)


func _find_spawn_id_for_enemy(enemy: Node2D) -> StringName:
	for spawn: Dictionary in _common_enemy_spawns:
		var enemy_value: Variant = spawn.get("enemy")
		if is_instance_valid(enemy_value) and enemy_value == enemy:
			return spawn.get("id", &"") as StringName
	return &""


func _configure_encounters() -> void:
	for child: Node in encounter_zones.get_children():
		var zone: EncounterZone = child as EncounterZone
		if zone == null:
			continue
		if zone.encounter_id == &"" or zone.enemy_spawn_ids.is_empty():
			push_error("EncounterZone requires an ID and spawn IDs.")
			continue
		if _encounter_spawn_ids.has(zone.encounter_id):
			push_error("Encounter IDs must be unique.")
			continue

		var valid_spawn_ids: Array[StringName] = []
		for spawn_id: StringName in zone.enemy_spawn_ids:
			if spawn_id == &"" or not _has_registered_spawn(spawn_id):
				push_error("EncounterZone references an invalid spawn ID.")
				continue
			if _spawn_encounter_ids.has(spawn_id):
				push_error("Enemy spawn belongs to more than one encounter.")
				continue
			valid_spawn_ids.append(spawn_id)
			_spawn_encounter_ids[spawn_id] = zone.encounter_id

		if valid_spawn_ids.is_empty():
			push_error("EncounterZone has no valid registered spawns.")
			continue
		_encounter_spawn_ids[zone.encounter_id] = valid_spawn_ids
		if not zone.encounter_activated.is_connected(
			_on_encounter_zone_activated
		):
			zone.encounter_activated.connect(
				_on_encounter_zone_activated
			)

	for spawn: Dictionary in _common_enemy_spawns:
		var enemy_value: Variant = spawn.get("enemy")
		if not is_instance_valid(enemy_value):
			continue
		_apply_enemy_encounter_state(
			enemy_value as Node2D,
			spawn.get("id", &"") as StringName
		)


func _configure_progression_gates() -> void:
	var registered_gate_ids: Array[StringName] = []
	for child: Node in progression_gates.get_children():
		var gate: ProgressionGate = child as ProgressionGate
		if gate == null:
			continue
		if gate.gate_id == &"" or gate.required_encounter_id == &"":
			push_error("ProgressionGate requires gate and encounter IDs.")
			continue
		if registered_gate_ids.has(gate.gate_id):
			push_error("ProgressionGate IDs must be unique.")
			continue
		registered_gate_ids.append(gate.gate_id)
		player_hud.observe_gate(gate)


func _has_registered_spawn(spawn_id: StringName) -> bool:
	for spawn: Dictionary in _common_enemy_spawns:
		if spawn.get("id", &"") as StringName == spawn_id:
			return true
	return false


func _on_encounter_zone_activated(
	encounter_id: StringName,
	_enemy_spawn_ids: Array[StringName]
) -> void:
	var spawn_ids: Array[StringName] = _get_encounter_spawn_ids(
		encounter_id
	)
	for spawn_id: StringName in spawn_ids:
		var enemy: Node2D = _find_enemy_for_spawn(spawn_id)
		if enemy != null:
			_apply_enemy_encounter_state(enemy, spawn_id)
	_evaluate_encounter_completion(encounter_id)


func _find_enemy_for_spawn(spawn_id: StringName) -> Node2D:
	for spawn: Dictionary in _common_enemy_spawns:
		if spawn.get("id", &"") as StringName != spawn_id:
			continue
		var enemy_value: Variant = spawn.get("enemy")
		if is_instance_valid(enemy_value):
			return enemy_value as Node2D
	return null


func _apply_enemy_encounter_state(
	enemy: Node2D,
	spawn_id: StringName
) -> void:
	if enemy == null or not enemy.has_method(&"set_encounter_active"):
		push_error("Common enemy requires set_encounter_active().")
		return
	var encounter_id: StringName = (
		_spawn_encounter_ids.get(spawn_id, &"") as StringName
	)
	var active: bool = (
		encounter_id != &""
		and GameState.is_encounter_activated(encounter_id)
	)
	enemy.call(&"set_encounter_active", active)


func _evaluate_encounter_completion_for_spawn(
	spawn_id: StringName
) -> void:
	var encounter_id: StringName = (
		_spawn_encounter_ids.get(spawn_id, &"") as StringName
	)
	if encounter_id != &"":
		_evaluate_encounter_completion(encounter_id)


func _evaluate_all_encounter_completions() -> void:
	for encounter_id_value: Variant in _encounter_spawn_ids.keys():
		_evaluate_encounter_completion(
			encounter_id_value as StringName
		)


func _evaluate_encounter_completion(
	encounter_id: StringName
) -> void:
	if (
		not GameState.is_encounter_activated(encounter_id)
		or GameState.is_encounter_completed(encounter_id)
	):
		return
	for spawn_id: StringName in _get_encounter_spawn_ids(encounter_id):
		if not GameState.has_defeated_enemy_spawn(spawn_id):
			return
	GameState.complete_encounter(encounter_id)


func _get_encounter_spawn_ids(
	encounter_id: StringName
) -> Array[StringName]:
	var stored_value: Variant = _encounter_spawn_ids.get(
		encounter_id,
		[]
	)
	if stored_value is Array[StringName]:
		return stored_value as Array[StringName]
	var spawn_ids: Array[StringName] = []
	return spawn_ids


func _connect_objective_signals() -> void:
	if not GameState.memory_collected.is_connected(_on_objective_state_changed):
		GameState.memory_collected.connect(_on_objective_state_changed)
	if not GameState.respawn_point_changed.is_connected(
		_on_respawn_point_changed
	):
		GameState.respawn_point_changed.connect(_on_respawn_point_changed)
	if not GameState.encounter_completed.is_connected(
		_on_encounter_completed_for_gates
	):
		GameState.encounter_completed.connect(
			_on_encounter_completed_for_gates
		)


func _evaluate_arena_objective() -> void:
	GameState.evaluate_arena_objective(REQUIRED_ENEMY_SPAWN_COUNT)


func _on_objective_state_changed(_memory_id: StringName) -> void:
	_evaluate_arena_objective()


func _on_respawn_point_changed(
	_position: Vector2,
	_altar_id: StringName
) -> void:
	_evaluate_arena_objective()


func _on_encounter_completed_for_gates(
	encounter_id: StringName
) -> void:
	for child: Node in progression_gates.get_children():
		var gate: ProgressionGate = child as ProgressionGate
		if (
			gate != null
			and gate.required_encounter_id == encounter_id
		):
			gate.open_gate()


func _exit_tree() -> void:
	if GameState == null or not is_instance_valid(GameState):
		return
	if GameState.memory_collected.is_connected(_on_objective_state_changed):
		GameState.memory_collected.disconnect(_on_objective_state_changed)
	if GameState.respawn_point_changed.is_connected(
		_on_respawn_point_changed
	):
		GameState.respawn_point_changed.disconnect(
			_on_respawn_point_changed
		)
	if GameState.encounter_completed.is_connected(
		_on_encounter_completed_for_gates
	):
		GameState.encounter_completed.disconnect(
			_on_encounter_completed_for_gates
		)
