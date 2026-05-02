extends Node
class_name AIController

# Unit costs
const COST_UNIT_BASIC: int = 15
const COST_UNIT_FAST: int = 20
const COST_UNIT_TANK: int = 40
const COST_TOWER: int = 60

# Team this AI controls
@export var team_id: int = 1  # 1 = Enemy1 (Red), 2 = Enemy2 (Green)

# Difficulty settings
var _difficulty: String = "normal"
var _ai_configs: Dictionary = {
	"easy": {
		"spawn_interval": 6.0,
		"build_interval": 20.0,
		"randomness": 0.4,
		"build_near_base": true,
		"defense_priority": 0.3,
		"income_bonus": 0.8,
		"unit_weights": {"basic": 0.7, "fast": 0.2, "tank": 0.1}
	},
	"normal": {
		"spawn_interval": 4.0,
		"build_interval": 12.0,
		"randomness": 0.25,
		"build_near_base": true,
		"defense_priority": 0.5,
		"income_bonus": 1.0,
		"unit_weights": {"basic": 0.5, "fast": 0.35, "tank": 0.15}
	},
	"hard": {
		"spawn_interval": 2.5,
		"build_interval": 8.0,
		"randomness": 0.15,
		"build_near_base": true,
		"defense_priority": 0.7,
		"income_bonus": 1.3,
		"unit_weights": {"basic": 0.3, "fast": 0.4, "tank": 0.3}
	}
}

# Timers
@export var unit_spawn_interval: float = 4.0
@export var tower_build_interval: float = 12.0
var _spawn_timer: float = 0.0
var _tower_timer: float = 0.0

# State
var _base_position: Vector3 = Vector3.ZERO
var _is_active: bool = true
var _our_towers: Array[Tower] = []
var _base_under_attack: bool = false

func _ready() -> void:
	print("AI Controller ready - Team: " + str(team_id))
	
	# Get difficulty from GameManager
	_difficulty = GameManager.get_enemy_difficulty(team_id)
	GameManager.difficulty_changed.connect(_on_difficulty_changed)
	
	# Find our base
	_find_base()
	
	# Connect to unit spawn signal to track our units
	GameManager.unit_spawned.connect(_on_unit_spawned)

func _on_difficulty_changed(team: int, new_difficulty: String) -> void:
	if team == team_id:
		_difficulty = new_difficulty

func _on_unit_spawned(unit: Unit) -> void:
	# Track if it's our unit
	if unit.team_id == team_id:
		unit.died.connect(_on_our_unit_died.bind(unit))

func _on_our_unit_died(unit: Unit) -> void:
	# Could track unit count here for more tactical decisions
	pass

func _find_base() -> void:
	var bases = get_tree().get_nodes_in_group("bases")
	for base in bases:
		if base is Base and base.team_id == team_id:
			_base_position = base.global_position
			base.health_changed.connect(_on_base_health_changed)
			break

func _on_base_health_changed(current: float, max_health: float) -> void:
	_base_under_attack = current < max_health * 0.9

func _get_config() -> Dictionary:
	return _ai_configs.get(_difficulty, _ai_configs["normal"])

func _process(delta: float) -> void:
	if not _is_active:
		return
	
	if not GameManager or not GameManager.is_playing():
		return
	
	var config = _get_config()
	
	_spawn_timer += delta
	_tower_timer += delta
	
	# Try to spawn units
	if _spawn_timer >= unit_spawn_interval:
		_spawn_timer = 0.0
		_try_spawn_unit(config)
	
	# Try to build towers - prioritize defense if under attack
	var build_priority = config["defense_priority"]
	if _base_under_attack:
		_tower_timer += delta * 1.5  # Build faster when under attack
		build_priority = min(0.9, build_priority + 0.2)
	
	if _tower_timer >= tower_build_interval:
		_tower_timer = 0.0
		if randf() < build_priority:
			_try_build_tower(config)

func _try_spawn_unit(config: Dictionary) -> void:
	# Add some randomness to timing
	_spawn_timer = randf() * config["randomness"] * config["spawn_interval"]
	
	var unit_type = _select_unit_type(config["unit_weights"])
	var cost = _get_unit_cost(unit_type)
	
	if GameManager.can_afford(team_id, cost):
		GameManager.spend_gold(team_id, cost)
		# Select target strategically
		var target_team = _select_target_team()
		_spawn_unit_to_target(unit_type, target_team)
	else:
		# Wait a bit and try again
		_spawn_timer = config["spawn_interval"] * 0.3

func _select_target_team() -> int:
	"""Select which enemy base to attack based on strategic priorities"""
	var enemy_bases = _get_enemy_bases()
	if enemy_bases.is_empty():
		return 0  # Default to player base
	
	# Strategy: Attack the weakest base (lowest health percentage)
	enemy_bases.sort_custom(func(a, b): 
		return a.get_health_percentage() < b.get_health_percentage()
	)
	
	return enemy_bases[0].team_id

func _spawn_unit_to_target(unit_type: String, target_team: int) -> void:
	"""Spawn a unit targeting a specific enemy team"""
	# Get the path for the target team
	var path_id = UnitPathing.get_path_for_target(target_team)
	
	# Spawn at the center spawn arena (Path 0 start - all units spawn in center)
	var spawn_pos = Vector3.ZERO
	
	# If we have a path system, get the proper spawn position
	var path_system = get_tree().current_scene.get_node_or_null("PathSystem")
	if path_system:
		# All teams spawn at center (Path 0 start)
		spawn_pos = path_system.get_start_position(0)
	
	# Add small random offset for visual variety
	var spawn_offset = Vector3(randf() - 0.5, 0, randf() - 0.5) * 2
	
	var spawn_data = {
		"type": unit_type,
		"team": team_id,
		"target_team": target_team,
		"path_id": path_id,
		"position": spawn_pos + spawn_offset
	}
	
	ai_spawn_unit_requested.emit(spawn_data)

func _select_unit_type(weights: Dictionary) -> String:
	var roll = randf()
	var cumulative = 0.0
	
	for unit_type in weights.keys():
		cumulative += weights[unit_type]
		if roll <= cumulative:
			return unit_type
	
	return "basic"

func _get_unit_cost(unit_type: String) -> int:
	match unit_type:
		"basic": return COST_UNIT_BASIC
		"fast": return COST_UNIT_FAST
		"tank": return COST_UNIT_TANK
	return COST_UNIT_BASIC

# Signals
signal ai_spawn_unit_requested(data: Dictionary)
signal ai_build_tower_requested(position: Vector3, team: int)

func set_active(active: bool) -> void:
	_is_active = active

func set_difficulty(difficulty: String) -> void:
	_difficulty = difficulty
	GameManager.set_enemy_difficulty(team_id, difficulty)
