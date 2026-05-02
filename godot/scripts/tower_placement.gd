extends Node
class_name TowerPlacementSystem

## Tower Placement System for Citadel Clash
## Handles restricted tower building to BuildZones only
## Provides visual feedback for valid/invalid placements

signal tower_placement_started
signal tower_placement_valid(position: Vector3, zone: GridSystem.BuildZone)
signal tower_placement_invalid(position: Vector3)
signal tower_placed(tower: Tower, zone: GridSystem.BuildZone)
signal tower_placement_cancelled

# References
@onready var _grid_system: GridSystem = null
@onready var _game_scene: Node3D = null

# State
var _is_placing: bool = false
var _ghost_tower: MeshInstance3D = null
var _range_indicator: MeshInstance3D = null
var _current_zone: GridSystem.BuildZone = null
var _current_team: int = 0

# Materials
var _valid_material: StandardMaterial3D
var _invalid_material: StandardMaterial3D
var _valid_range_material: StandardMaterial3D
var _invalid_range_material: StandardMaterial3D

func _ready():
	_setup_materials()
	# Defer grid system lookup to ensure scene is ready
	call_deferred("_find_grid_system")

func _setup_materials():
	# Valid placement - green
	_valid_material = StandardMaterial3D.new()
	_valid_material.albedo_color = Color(0.3, 1.0, 0.3, 0.6)
	_valid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_valid_material.roughness = 0.5
	
	# Invalid placement - red
	_invalid_material = StandardMaterial3D.new()
	_invalid_material.albedo_color = Color(1.0, 0.3, 0.3, 0.6)
	_invalid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_invalid_material.roughness = 0.5
	
	# Valid range indicator
	_valid_range_material = StandardMaterial3D.new()
	_valid_range_material.albedo_color = Color(0.3, 1.0, 0.3, 0.2)
	_valid_range_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Invalid range indicator
	_invalid_range_material = StandardMaterial3D.new()
	_invalid_range_material.albedo_color = Color(1.0, 0.3, 0.3, 0.1)
	_invalid_range_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func _find_grid_system():
	# Try to find GridSystem in the scene
	var root = get_tree().current_scene
	if root:
		_grid_system = root.get_node_or_null("GridSystem")
		if _grid_system:
			print("TowerPlacementSystem: GridSystem found")
		else:
			push_warning("TowerPlacementSystem: GridSystem not found!")

## Public API

func start_placement(team_id: int = 0) -> void:
	"""Start tower placement mode for a team"""
	_is_placing = true
	_current_team = team_id
	_create_ghost_tower()
	tower_placement_started.emit()
	print("TowerPlacementSystem: Placement started for team ", team_id)

func cancel_placement() -> void:
	"""Cancel tower placement mode"""
	_is_placing = false
	_destroy_ghost_tower()
	tower_placement_cancelled.emit()

func is_placing() -> bool:
	return _is_placing

func try_place_tower(tower_template: PackedScene) -> Tower:
	"""Try to place a tower at current ghost position"""
	if not _is_placing or _ghost_tower == null:
		return null
	
	if _current_zone == null:
		print("TowerPlacementSystem: Cannot place - no valid zone")
		return null
	
	if not _grid_system:
		push_error("TowerPlacementSystem: GridSystem not available")
		return null
	
	# Check if zone is still free
	if _current_zone.is_occupied:
		print("TowerPlacementSystem: Zone already occupied")
		return null
	
	# Place tower
	var tower = tower_template.instantiate() as Tower
	if tower == null:
		push_error("TowerPlacementSystem: Failed to instantiate tower")
		return null
	
	# Position at zone center
	tower.global_position = _current_zone.world_position + Vector3.UP * 1.25
	tower.team_id = _current_team
	
	# Occupy the zone
	_grid_system.occupy_zone(_current_zone, tower, _current_team)
	
	# Emit signal
	tower_placed.emit(tower, _current_zone)
	
	# Continue placement mode (create new ghost)
	_destroy_ghost_tower()
	_create_ghost_tower()
	
	return tower

func get_current_zone() -> GridSystem.BuildZone:
	return _current_zone

func is_position_valid() -> bool:
	return _current_zone != null and not _current_zone.is_occupied

## Ghost Tower Management

func _create_ghost_tower() -> void:
	if _ghost_tower:
		return
	
	# Main ghost mesh
	_ghost_tower = MeshInstance3D.new()
	_ghost_tower.name = "GhostTower"
	
	var mesh = BoxMesh.new()
	mesh.size = Vector3(1.5, 2.5, 1.5)
	_ghost_tower.mesh = mesh
	_ghost_tower.material_override = _invalid_material
	
	# Range indicator
	_range_indicator = MeshInstance3D.new()
	_range_indicator.name = "RangeIndicator"
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 10.0
	cylinder.bottom_radius = 10.0
	cylinder.height = 0.1
	_range_indicator.mesh = cylinder
	_range_indicator.material_override = _invalid_range_material
	_range_indicator.position.y = -1.2
	_ghost_tower.add_child(_range_indicator)
	
	get_tree().current_scene.add_child(_ghost_tower)

func _destroy_ghost_tower() -> void:
	if _ghost_tower:
		_ghost_tower.queue_free()
		_ghost_tower = null
		_range_indicator = null

func _update_ghost_position() -> void:
	if not _ghost_tower or not _is_placing:
		return
	
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collision_mask = 1  # Terrain layer
	
	var result = space_state.intersect_ray(query)
	if result:
		var hit_pos = result.position
		
		# Check if we're over a build zone
		if _grid_system:
			var zone = _grid_system.get_zone_at_position(hit_pos)
			_current_zone = zone
			
			if zone and _grid_system.can_build_in_zone(zone, _current_team):
				# Valid position - snap to zone center
				_ghost_tower.global_position = zone.world_position + Vector3.UP * 1.25
				_ghost_tower.material_override = _valid_material
				_range_indicator.material_override = _valid_range_material
				tower_placement_valid.emit(zone.world_position, zone)
			else:
				# Invalid - follow mouse but show red
				_ghost_tower.global_position = hit_pos + Vector3.UP * 1.25
				_ghost_tower.material_override = _invalid_material
				_range_indicator.material_override = _invalid_range_material
				tower_placement_invalid.emit(hit_pos)
		else:
			# No grid system - invalid
			_ghost_tower.global_override = hit_pos + Vector3.UP * 1.25
			_ghost_tower.material_override = _invalid_material
			_current_zone = null
	else:
		_current_zone = null

## Process

func _process(delta: float) -> void:
	if _is_placing:
		_update_ghost_position()

## Input handling (call this from game scene)

func handle_input(event: InputEvent) -> bool:
	"""Handle input during placement mode. Returns true if input was consumed."""
	if not _is_placing:
		return false
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Try to place tower
			if is_position_valid():
				return true  # Consumed - placement will be handled by caller
			else:
				# Invalid click
				return true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Cancel placement
			cancel_placement()
			return true
	
	return false

## Utility

func get_buildable_zones_count(team_id: int) -> int:
	if not _grid_system:
		return 0
	return _grid_system.get_buildable_zones(team_id).size()

func get_occupied_zones_count(team_id: int) -> int:
	if not _grid_system:
		return 0
	var zones = _grid_system.get_team_zones(team_id)
	var count = 0
	for zone in zones:
		if zone.is_occupied:
			count += 1
	return count

func sell_tower(tower: Tower) -> bool:
	"""Sell a tower and free its zone"""
	if not _grid_system or tower == null:
		return false
	
	# Find zone occupied by this tower
	for zone_id in _grid_system.zones:
		var zone = _grid_system.zones[zone_id]
		if zone.occupied_by == tower:
			_grid_system.free_zone(zone)
			tower.queue_free()
			print("TowerPlacementSystem: Tower sold, zone freed")
			return true
	
	return false