extends Node
class_name UnitPathing

## Unit Pathing System for Citadel Clash
## Makes units follow the path waypoints and attack base at the end

signal path_completed(unit: Node3D)
signal waypoint_reached(unit: Node3D, waypoint_index: int)
signal base_reached(unit: Node3D, base: Base)
signal unit_despawned(unit: Node3D)

# Movement settings
@export var waypoint_reach_threshold: float = 1.5  # Distance to consider waypoint reached
@export var rotation_speed: float = 10.0  # How fast unit rotates towards target

# Debug visualization
@export var show_debug_info: bool = true
var _debug_label: Label3D = null

# Path data
var _path_id: int = -1
var _waypoints: Array[Vector3] = []
var _current_waypoint_index: int = 0
var _path_system: PathSystem = null

# NEW: Target tracking
var _target_team: int = -1  # Which team/base this unit is attacking

# Unit reference
var _unit: Unit = null

# State
var _is_following_path: bool = false
var _has_reached_base: bool = false
var _base_to_attack: Base = null

func _ready():
	print("[DEBUG PATHING] _ready() called on UnitPathing")
	call_deferred("_find_path_system")
	
	# Debug timer
	if show_debug_info:
		var timer = Timer.new()
		timer.wait_time = 0.5
		timer.autostart = true
		timer.timeout.connect(_update_debug_info)
		add_child(timer)

func _find_path_system():
	print("[DEBUG PATHING] _find_path_system() called")
	var root = get_tree().current_scene
	if root:
		_path_system = root.get_node_or_null("PathSystem")
		if _path_system:
			print("[DEBUG PATHING] PathSystem found!")
		else:
			print("[DEBUG PATHING] PathSystem NOT found in scene!")
			push_warning("UnitPathing: PathSystem not found!")
	else:
		print("[DEBUG PATHING] No current scene!")

## Initialize pathing for a unit
## spawn_position: Where the unit spawns (should be center arena)
## path_id: Which path to follow (0, 1, or 2 - matches target base team)
## target_team: Which base to attack (0, 1, or 2)
func initialize(unit: Unit, path_id: int, target_team: int = -1) -> void:
	print("[DEBUG PATHING] initialize() called")
	print("[DEBUG PATHING]   unit: ", unit != null)
	print("[DEBUG PATHING]   path_id: ", path_id)
	print("[DEBUG PATHING]   target_team: ", target_team)
	
	_unit = unit
	_path_id = path_id
	_target_team = target_team if target_team >= 0 else path_id
	
	if not _path_system:
		_find_path_system()
	
	if _path_system:
		print("[DEBUG PATHING]   PathSystem found, getting waypoints...")
		_waypoints = _path_system.get_path(path_id)
		print("[DEBUG PATHING]   Waypoints count: ", _waypoints.size())
		if _waypoints.size() > 0:
			_is_following_path = true
			_current_waypoint_index = 0
			_has_reached_base = false
			
			print("[DEBUG PATHING]   Initialized successfully!")
			print("[DEBUG PATHING]   First waypoint: ", _waypoints[0])
		else:
			push_warning("UnitPathing: No waypoints found for path " + str(path_id))
	else:
		push_warning("UnitPathing: Cannot initialize - PathSystem not available")

## Get the current target waypoint
func get_current_waypoint() -> Vector3:
	if _current_waypoint_index < _waypoints.size():
		return _waypoints[_current_waypoint_index]
	return _waypoints[_waypoints.size() - 1] if _waypoints.size() > 0 else Vector3.ZERO

## Get the final base position
func get_base_position() -> Vector3:
	if _path_system:
		return _path_system.get_end_position(_path_id)
	return Vector3.ZERO

## Check if we've reached the end of the path
func is_at_final_waypoint() -> bool:
	return _current_waypoint_index >= _waypoints.size() - 1

## Main update - call from unit's _physics_process
func update_movement(delta: float) -> void:
	if not _unit or not _is_following_path:
		return
	
	# If we've reached the base, handle base attack
	if _has_reached_base:
		_handle_base_attack(delta)
		return
	
	# Get current waypoint
	var target = get_current_waypoint()
	var current_pos = _unit.global_position
	
	# Calculate distance to waypoint
	var distance = _calculate_flat_distance(current_pos, target)
	
	# Check if we've reached the waypoint
	if distance < waypoint_reach_threshold:
		_waypoint_reached()
		return
	
	# Move towards waypoint
	_move_towards_waypoint(target, delta)

func _move_towards_waypoint(target: Vector3, delta: float) -> void:
	var current_pos = _unit.global_position
	
	# Calculate direction
	var direction = target - current_pos
	direction.y = 0  # Keep movement on ground plane
	direction = direction.normalized()
	
	# Apply movement
	if _unit is CharacterBody3D:
		_unit.velocity = direction * _unit.move_speed
		_unit.velocity.y = 0
		
		# Smooth rotation
		if direction.length() > 0.01:
			var target_rotation = atan2(direction.x, direction.z)
			_unit.rotation.y = lerp_angle(_unit.rotation.y, target_rotation, rotation_speed * delta)
		
		_unit.move_and_slide()
	else:
		# Fallback for non-CharacterBody3D
		_unit.global_position += direction * _unit.move_speed * delta
		_unit.global_position.y = current_pos.y  # Maintain height
	
	# DEBUG: Update debug display
	_update_debug_info()

func _calculate_flat_distance(a: Vector3, b: Vector3) -> float:
	var diff = b - a
	diff.y = 0
	return diff.length()

func _waypoint_reached() -> void:
	waypoint_reached.emit(_unit, _current_waypoint_index)
	
	# Check if this was the final waypoint
	if is_at_final_waypoint():
		_has_reached_base = true
		
		# Find the base to attack
		_base_to_attack = _find_target_base()
		if _base_to_attack:
			base_reached.emit(_unit, _base_to_attack)
			print("UnitPathing: Unit reached base for team ", _unit.team_id)
		
		path_completed.emit(_unit)
	else:
		# Move to next waypoint
		_current_waypoint_index += 1
		print("UnitPathing: Waypoint ", _current_waypoint_index - 1, " reached, moving to ", _current_waypoint_index)

func _find_target_base() -> Base:
	"""Find the base at the end of this path"""
	var bases = _unit.get_tree().get_nodes_in_group("bases")
	
	# Use stored target team, or fall back to path_id
	var team_to_attack = _target_team if _target_team >= 0 else _path_id
	
	for base in bases:
		if base is Base:
			# Path N leads to base team N
			if base.team_id == team_to_attack:
				return base
	
	return null

func _handle_base_attack(delta: float) -> void:
	"""Handle unit attacking the base once it reaches the end"""
	if not _base_to_attack or not is_instance_valid(_base_to_attack):
		_despawn_unit()
		return
	
	if not _base_to_attack.is_alive():
		_despawn_unit()
		return
	
	# Move to base position if not close enough
	var distance_to_base = _calculate_flat_distance(_unit.global_position, _base_to_attack.global_position)
	
	if distance_to_base > _unit.attack_range:
		# Move closer to base
		_move_towards_waypoint(_base_to_attack.global_position, delta)
		return
	
	# We're in attack range - deal damage to base
	_deal_base_damage(delta)
	
	# After dealing damage, despawn (unit dies after attacking)
	# Or keep attacking until base destroyed or unit dies
	if _unit.current_health <= 0:
		_despawn_unit()

var _attack_timer: float = 0.0

func _deal_base_damage(delta: float) -> void:
	if not _base_to_attack:
		return
	
	_attack_timer += delta
	
	if _attack_timer >= 1.0 / _unit.attack_rate:
		_attack_timer = 0.0
		_base_to_attack.take_damage(_unit.attack_damage)
		
		# Visual feedback
		_unit._flash_attack() if _unit.has_method("_flash_attack") else null
		
		print("UnitPathing: Unit dealt ", _unit.attack_damage, " damage to base")

func _despawn_unit() -> void:
	"""Remove unit from the game"""
	if not _unit:
		return
	
	unit_despawned.emit(_unit)
	
	# Create despawn effect
	_create_despawn_effect()
	
	print("UnitPathing: Unit despawned")
	
	# Queue free the unit
	_unit.queue_free()

func _create_despawn_effect() -> void:
	if not _unit:
		return
	
	# Simple particle burst
	for i in range(3):
		var particle = MeshInstance3D.new()
		particle.mesh = BoxMesh.new()
		particle.scale = Vector3(0.1, 0.1, 0.1)
		particle.position = _unit.position + Vector3(randf() - 0.5, randf() * 0.3, randf() - 0.5)
		_unit.get_parent().add_child(particle)
		
		var tween = _unit.create_tween().set_parallel() if _unit else null
		if tween:
			tween.tween_property(particle, "position", particle.position + Vector3(randf() - 0.5, 0.5, randf() - 0.5), 0.5)
			tween.tween_property(particle, "scale", Vector3.ZERO, 0.5)
			tween.chain().tween_callback(particle.queue_free)

## Stop pathing
func stop_pathing() -> void:
	_is_following_path = false

## Debug info display
func _update_debug_info() -> void:
	if not show_debug_info or not _unit:
		return
	
	# Create/update 3D label
	if not _debug_label:
		_debug_label = Label3D.new()
		_debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_debug_label.no_depth_test = true
		_debug_label.font_size = 64
		_debug_label.position.y = 1.5
		_unit.add_child(_debug_label)
	
	# Update text
	var target_str = str(_target_team) if _target_team >= 0 else "?"
	var waypoint_str = str(_current_waypoint_index) + "/" + str(_waypoints.size() - 1)
	_debug_label.text = "S:" + str(_unit.sender_team) + " T:" + target_str + "\nWP:" + waypoint_str

## Get progress info
func get_progress() -> Dictionary:
	return {
		"path_id": _path_id,
		"current_waypoint": _current_waypoint_index,
		"total_waypoints": _waypoints.size(),
		"progress_percent": float(_current_waypoint_index) / max(1, _waypoints.size() - 1) * 100.0,
		"has_reached_base": _has_reached_base
	}

## Static helper - get path for a team targeting a specific enemy team
static func get_path_for_target(target_team: int) -> int:
	"""
	Returns the path ID that leads to the target team's base.
	Path 0 leads to Team 0 (Player) base
	Path 1 leads to Team 1 (Enemy1) base
	Path 2 leads to Team 2 (Enemy2) base
	"""
	return target_team

## Static helper - get path for a team (legacy, defaults to attacking player)
static func get_path_for_team(team_id: int) -> int:
	"""
	DEPRECATED: Use get_path_for_target(target_team) instead.
	Team 0 (Player) attacks along paths 1 and 2 (to enemy bases)
	Team 1 attacks along path 0 (to player base)
	Team 2 attacks along path 0 (to player base)
	"""
	match team_id:
		0: return 1  # Player attacks enemy 1 by default
		1: return 0  # Enemy 1 attacks path 0 (player base)
		2: return 0  # Enemy 2 attacks path 0 (player base)
		_: return 0

## Static helper - get spawn position for team
static func get_spawn_position_for_team(team_id: int, path_system: PathSystem) -> Vector3:
	if not path_system:
		return Vector3.ZERO
	
	var path_id = get_path_for_team(team_id)
	return path_system.get_start_position(path_id)