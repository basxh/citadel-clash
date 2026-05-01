extends Node
class_name AIController

# Constants
const COST_UNIT_BASIC: int = 10
const COST_UNIT_FAST: int = 15
const COST_UNIT_TANK: int = 25
const COST_TOWER: int = 50

# Team this AI controls
@export var team_id: int = 1  # 1 = Enemy1 (Red), 2 = Enemy2 (Green)

# AI Settings
@export var unit_spawn_interval: float = 5.0
@export var tower_build_interval: float = 15.0
@export var randomness_factor: float = 0.3

# Timers
var _spawn_timer: float = 0.0
var _tower_timer: float = 0.0

# State
var _base_position: Vector3 = Vector3.ZERO
var _is_active: bool = true

# Unit type weights for random selection
var _unit_weights: Dictionary = {
	"basic": 0.6,
	"fast": 0.3,
	"tank": 0.1
}

func _ready() -> void:
	print("AI Controller ready - Team: " + str(team_id))
	
	# Find our base
	_find_base()

func _find_base() -> void:
	var bases = get_tree().get_nodes_in_group("bases")
	for base in bases:
		if base is Base and base.team_id == team_id:
			_base_position = base.global_position
			break

func _process(delta: float) -> void:
	if not _is_active:
		return
	
	if not GameManager or not GameManager.is_playing():
		return
	
	_spawn_timer += delta
	_tower_timer += delta
	
	# Try to spawn units
	if _spawn_timer >= unit_spawn_interval:
		_spawn_timer = 0.0
		_try_spawn_unit()
	
	# Try to build towers
	if _tower_timer >= tower_build_interval:
		_tower_timer = 0.0
		_try_build_tower()

func _try_spawn_unit() -> void:
	# Add some randomness to timing
	_spawn_timer = randf() * randomness_factor * unit_spawn_interval
	
	var unit_type = _select_unit_type()
	var cost = _get_unit_cost(unit_type)
	
	if GameManager.can_afford(team_id, cost):
		GameManager.spend_gold(team_id, cost)
		_spawn_unit(unit_type)
	else:
		# Wait a bit and try again
		_spawn_timer = unit_spawn_interval * 0.5

func _select_unit_type() -> String:
	var roll = randf()
	var cumulative = 0.0
	
	for unit_type in _unit_weights.keys():
		cumulative += _unit_weights[unit_type]
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
	if _base_position == Vector3.ZERO:
		_find_base()
	
	# Create unit (we'll spawn it via the game scene)
	var spawn_data = {
		"type": unit_type,
		"team": team_id,
		"position": _base_position + Vector3(randf() - 0.5, 0, randf() - 0.5) * 3
	}
	
	# Emit signal for game scene to handle spawning
	ai_spawn_unit_requested.emit(spawn_data)

func _try_build_tower() -> void:
	# Add randomness
	_tower_timer = randf() * randomness_factor * tower_build_interval
	
	if not GameManager.can_afford(team_id, COST_TOWER):
		return
	
	# Find a good position near base
	var build_pos = _find_tower_position()
	if build_pos != Vector3.ZERO:
		GameManager.spend_gold(team_id, COST_TOWER)
		ai_build_tower_requested.emit(build_pos, team_id)

func _find_tower_position() -> Vector3:
	if _base_position == Vector3.ZERO:
		return Vector3.ZERO
	
	# Try a few random positions around base
	for i in range(5):
		var offset = Vector3(randf() - 0.5, 0, randf() - 0.5) * 8
		var pos = _base_position + offset
		
		# Check if position is valid (not too close to other towers, on ground)
		if _is_valid_tower_position(pos):
			return pos
	
	return Vector3.ZERO

func _is_valid_tower_position(pos: Vector3) -> bool:
	# Simple check - could be expanded
	return true

# Signals
signal ai_spawn_unit_requested(data: Dictionary)
signal ai_build_tower_requested(position: Vector3, team: int)

func set_active(active: bool) -> void:
	_is_active = active
