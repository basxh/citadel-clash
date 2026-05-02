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
		_spawn_unit(unit_type)
	else:
		# Wait a bit and try again
		_spawn_timer = config["spawn_interval"] * 0.3

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

func _spawn_unit(unit_type: String) -> void:
	# Spawn at the center spawn arena (Path 0 start)
	var spawn_pos = Vector3.ZERO  # Center spawn arena
	
	# If we have a path system, get the proper spawn position
	var path_system = get_tree().current_scene.get_node_or_null("PathSystem")
	if path_system:
		# All teams spawn at center
		spawn_pos = path_system.get_start_position(0)
	
	# Add small random offset for visual variety
	var spawn_offset = Vector3(randf() - 0.5, 0, randf() - 0.5) * 2
	
	var spawn_data = {
		"type": unit_type,
		"team": team_id,
		"position": spawn_pos + spawn_offset
	}
	
	ai_spawn_unit_requested.emit(spawn_data)

func _get_enemy_bases() -> Array[Base]:
	var bases = get_tree().get_nodes_in_group("bases")
	var enemy_bases: Array[Base] = []
	for base in bases:
		if base is Base and base.team_id != team_id:
			enemy_bases.append(base)
	return enemy_bases

func _get_enemy_units_in_range(position: Vector3, range: float) -> Array[Unit]:
	var units = get_tree().get_nodes_in_group("units")
	var enemies: Array[Unit] = []
	for unit in units:
		if unit is Unit and unit.team_id != team_id and unit.is_alive():
			if unit.global_position.distance_to(position) <= range:
				enemies.append(unit)
	return enemies

func _try_build_tower(config: Dictionary) -> void:
	# Add randomness
	_tower_timer = randf() * config["randomness"] * config["build_interval"]
	
	if not GameManager.can_afford(team_id, COST_TOWER):
		return
	
	# Find the best position using BuildZones
	var build_pos = _find_tower_position_in_zones()
	if build_pos != Vector3.ZERO:
		GameManager.spend_gold(team_id, COST_TOWER)
		ai_build_tower_requested.emit(build_pos, team_id)

func _find_tower_position_in_zones() -> Vector3:
	"""Find a valid build position using the GridSystem"""
	if _base_position == Vector3.ZERO:
		_find_base()
		if _base_position == Vector3.ZERO:
			return Vector3.ZERO
	
	# Find GridSystem
	var grid_system = get_tree().current_scene.get_node_or_null("GridSystem")
	if not grid_system:
		# Fallback to old behavior
		return _find_tower_position_old()
	
	# Get buildable zones for this team
	var zones = grid_system.get_buildable_zones(team_id)
	
	if zones.is_empty():
		return Vector3.ZERO
	
	# Strategy: pick best zone based on defense needs
	var best_zone = _select_best_zone(zones, grid_system)
	
	if best_zone:
		return best_zone.world_position + Vector3.UP * 1.25
	
	return Vector3.ZERO

func _select_best_zone(zones: Array, grid_system: GridSystem) -> GridSystem.BuildZone:
	"""Select the best build zone based on current situation"""
	var best_zone = null
	var best_score = -999.0
	
	for zone in zones:
		if zone.is_occupied:
			continue
		
		var score = _evaluate_zone(zone)
		if score > best_score:
			best_score = score
			best_zone = zone
	
	return best_zone

func _evaluate_zone(zone: GridSystem.BuildZone) -> float:
	"""Score a zone based on defensive value"""
	var score = 0.0
	
	var zone_pos = zone.world_position
	
	# Closer to base = better defense (higher priority when under attack)
	var dist_to_base = zone_pos.distance_to(_base_position)
	if _base_under_attack:
		score += (30.0 - dist_to_base) * 3.0  # Heavy weight when under attack
	else:
		score += (30.0 - dist_to_base) * 0.5
	
	# Check for nearby enemy units
	var enemy_units = _get_enemy_units_in_range(_base_position, 25.0)
	for enemy in enemy_units:
		var dist = zone_pos.distance_to(enemy.global_position)
		if dist < 10.0:
			score += 20.0  # Good coverage of enemies
		elif dist < 15.0:
			score += 10.0
	
	# Prefer zones towards the center/lanes
	var dist_to_center = zone_pos.distance_to(Vector3.ZERO)
	score += dist_to_center * 0.2
	
	return score

func _find_tower_position_old() -> Vector3:
	"""Fallback positioning when GridSystem is not available"""
	# Strategy depends on difficulty
	if _base_under_attack:
		return _find_defensive_position()
	else:
		return _find_tactical_position(_get_config())

func _find_defensive_position() -> Vector3:
	# Find enemy units near our base
	var enemy_units = _get_enemy_units_in_range(_base_position, 20.0)
	
	if enemy_units.is_empty():
		return _find_position_near_base(6.0, 12.0)
	
	# Calculate average enemy position
	var avg_enemy_pos = Vector3.ZERO
	for unit in enemy_units:
		avg_enemy_pos += unit.global_position
	avg_enemy_pos /= enemy_units.size()
	
	# Place tower between base and enemies
	var direction = (avg_enemy_pos - _base_position).normalized()
	var distance_from_base = clamp(enemy_units[0].global_position.distance_to(_base_position) * 0.6, 8.0, 15.0)
	
	return _base_position + direction * distance_from_base

func _find_tactical_position(config: Dictionary) -> Vector3:
	# Try multiple positions and pick the best one
	var best_pos = Vector3.ZERO
	var best_score = -999.0
	
	for i in range(10):
		var pos = _find_position_near_base(5.0, 15.0)
		if pos == Vector3.ZERO:
			continue
		
		var score = _evaluate_tower_position(pos)
		if score > best_score:
			best_score = score
			best_pos = pos
	
	return best_pos

func _find_position_near_base(min_dist: float, max_dist: float) -> Vector3:
	var angle = randf() * PI * 2
	var distance = min_dist + randf() * (max_dist - min_dist)
	return _base_position + Vector3(cos(angle), 0, sin(angle)) * distance

func _evaluate_tower_position(pos: Vector3) -> float:
	var score = 0.0
	
	# Prefer positions closer to base (more defensible)
	score += (_base_position - pos).length() * -2.0
	
	# Check if position is valid
	if not _is_position_valid_for_tower(pos):
		return -999.0
	
	# Prefer positions with view of enemy approaches
	var enemy_bases = _get_enemy_bases()
	if not enemy_bases.is_empty():
		var nearest_enemy = enemy_bases[0]
		var dist_to_enemy = pos.distance_to(nearest_enemy.global_position)
		score += (25.0 - dist_to_enemy) * 1.5  # Prefer positions closer to enemies
	
	# Check for existing towers nearby (don't cluster too much)
	var towers = get_tree().get_nodes_in_group("towers")
	for tower in towers:
		if tower is Tower and tower.team_id == team_id:
			var dist = pos.distance_to(tower.global_position)
			if dist < 4.0:
				score -= 50.0  # Too close to existing tower
			elif dist < 8.0:
				score -= 10.0  # Moderately close
	
	return score

func _is_position_valid_for_tower(pos: Vector3) -> bool:
	# Check distance from other towers
	var towers = get_tree().get_nodes_in_group("towers")
	for tower in towers:
		if tower is Tower:
			if pos.distance_to(tower.global_position) < 2.5:
				return false
	
	# Check distance from base (don't build on base)
	if pos.distance_to(_base_position) < 3.0:
		return false
	
	return true

# Signals
signal ai_spawn_unit_requested(data: Dictionary)
signal ai_build_tower_requested(position: Vector3, team: int)

func set_active(active: bool) -> void:
	_is_active = active

func set_difficulty(difficulty: String) -> void:
	_difficulty = difficulty
	GameManager.set_enemy_difficulty(team_id, difficulty)
