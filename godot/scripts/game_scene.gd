extends Node3D
class_name GameScene

# Templates
@onready var _unit_template: PackedScene = preload("res://entities/unit.tscn")
@onready var _tower_template: PackedScene = preload("res://entities/tower.tscn")

# Nodes
@onready var _units_container: Node3D = $Units
@onready var _towers_container: Node3D = $Towers
@onready var _ui: GameUI = $CanvasLayer/GameUI
@onready var _camera: Camera3D = $Camera3D
@onready var _grid_system: GridSystem = $GridSystem

# Camera settings
var _camera_zoom_min: float = 20.0
var _camera_zoom_max: float = 100.0
var _camera_zoom_current: float = 50.0
var _camera_move_speed: float = 40.0
var _camera_smoothness: float = 10.0
var _camera_target_position: Vector3
var _camera_velocity: Vector3 = Vector3.ZERO

# Build mode
var _build_mode: bool = false

# Selection
var _selected_entity: Node3D = null

# Tower placement system
var _tower_placement: TowerPlacementSystem = null

func _ready() -> void:
	_camera_target_position = _camera.global_position
	
	# Setup TowerPlacementSystem
	_tower_placement = TowerPlacementSystem.new()
	_tower_placement.name = "TowerPlacementSystem"
	add_child(_tower_placement)
	_tower_placement.tower_placed.connect(_on_tower_placed)
	
	# Connect UI signals
	_ui.buy_unit_requested.connect(_on_buy_unit)
	_ui.buy_unit_requested_with_target.connect(_on_buy_unit_with_target)
	_ui.build_mode_toggled.connect(_on_build_mode_toggled)
	_ui.difficulty_selected.connect(_on_difficulty_selected)
	
	# Connect AI signals
	var ai_controllers = $AIControllers.get_children()
	for ai in ai_controllers:
		ai.ai_spawn_unit_requested.connect(_on_ai_spawn_unit)
		ai.ai_build_tower_requested.connect(_on_ai_build_tower)
	
	print("Game scene initialized with TowerPlacementSystem")

func _on_tower_placed(tower: Tower, zone: GridSystem.BuildZone) -> void:
	"""Handle successful tower placement"""
	tower.add_to_group("towers")
	
	# Connect selection signals
	tower.selected.connect(_on_entity_selected)
	tower.deselected.connect(_on_entity_deselected)
	
	_towers_container.add_child(tower)

func _process(delta: float) -> void:
	# Handle camera controls
	_handle_camera_input(delta)

func _input(event: InputEvent) -> void:
	# Let tower placement system handle input first
	if _tower_placement and _tower_placement.is_placing():
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if _tower_placement.is_position_valid():
					if GameManager.can_afford(0, GameManager.COST_TOWER):
						GameManager.spend_gold(0, GameManager.COST_TOWER)
						_tower_placement.try_place_tower(_tower_template)
						_ui.show_message("Tower built!")
					else:
						_ui.show_message("Not enough gold!")
				else:
					_ui.show_message("Invalid placement! Build in a green zone.")
				return
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_tower_placement.cancel_placement()
				_build_mode = false
				_ui.set_build_mode(false)
				return
		return
	
	# Handle unit/tower selection when not in build mode
	if event.is_action_pressed("unit_select") and not _build_mode:
		_select_entity_at_mouse()

func _on_buy_unit(unit_type: String) -> void:
	# Legacy - default to Enemy 1
	_on_buy_unit_with_target(unit_type, 1)

func _on_buy_unit_with_target(unit_type: String, target_team: int) -> void:
	# Spawn unit at player base targeting specific enemy
	var player_base = GameManager.get_player_base()
	if player_base:
		var path_id = UnitPathing.get_path_for_target(target_team)
		_spawn_unit(unit_type, 0, player_base.global_position + Vector3(randf() - 0.5, 0, randf() - 0.5) * 3, path_id, target_team)
		print("GameScene: Player spawned ", unit_type, " targeting Team ", target_team, " on Path ", path_id)

func _on_difficulty_selected(team: int, difficulty: String) -> void:
	GameManager.set_enemy_difficulty(team, difficulty)
	print("Set difficulty for team ", team, " to ", difficulty)

func _on_build_mode_toggled(active: bool) -> void:
	_build_mode = active
	
	if _build_mode:
		if _tower_placement:
			_tower_placement.start_placement(0)  # Player team
	else:
		if _tower_placement:
			_tower_placement.cancel_placement()

func _cancel_build_mode() -> void:
	_on_build_mode_toggled(false)


# Build-related functions (legacy - kept for AI compatibility)
func _build_tower(pos: Vector3, team: int) -> void:
	"""Build tower at position (used by AI or direct placement)"""
	var tower = _tower_template.instantiate() as Tower
	tower.global_position = pos
	tower.team_id = team
	tower.add_to_group("towers")
	
	# Connect selection signals
	tower.selected.connect(_on_entity_selected)
	tower.deselected.connect(_on_entity_deselected)
	
	_towers_container.add_child(tower)

func _spawn_unit(unit_type: String, team: int, spawn_pos: Vector3, path_id: int = -1, target_team: int = -1) -> void:
	var unit = _unit_template.instantiate() as Unit
	unit.global_position = spawn_pos
	unit.team_id = team
	unit.set_stats_from_type(unit_type)
	
	# Set the path ID if provided, otherwise auto-detect
	if path_id >= 0:
		unit.path_id = path_id
	elif target_team >= 0:
		unit.path_id = UnitPathing.get_path_for_target(target_team)
	
	unit.add_to_group("units")
	
	# Connect selection signals
	unit.selected.connect(_on_entity_selected)
	unit.deselected.connect(_on_entity_deselected)
	
	_units_container.add_child(unit)
	
	if GameManager:
		GameManager.unit_spawned.emit(unit)

func _on_ai_spawn_unit(spawn_data: Dictionary) -> void:
	var unit_type = spawn_data["type"]
	var team = spawn_data["team"]
	var pos = spawn_data["position"]
	var path_id = spawn_data.get("path_id", -1)
	var target_team = spawn_data.get("target_team", -1)
	_spawn_unit(unit_type, team, pos, path_id, target_team)

func _on_ai_build_tower(pos: Vector3, team: int) -> void:
	_build_tower(pos, team)

func _handle_camera_input(delta: float) -> void:
	var input_dir = Vector3.ZERO
	
	# WASD movement
	if Input.is_action_pressed("move_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	# Apply movement with smoothing
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized() * _camera_move_speed
		_camera_velocity = _camera_velocity.lerp(input_dir, _camera_smoothness * delta)
	else:
		_camera_velocity = _camera_velocity.lerp(Vector3.ZERO, _camera_smoothness * delta)
	
	_camera.global_position += _camera_velocity * delta
	
	# Mouse wheel zoom
	if Input.is_action_just_pressed("camera_zoom_in"):
		_camera_zoom_current = max(_camera_zoom_min, _camera_zoom_current - 5)
		_update_camera_zoom()
	elif Input.is_action_just_pressed("camera_zoom_out"):
		_camera_zoom_current = min(_camera_zoom_max, _camera_zoom_current + 5)
		_update_camera_zoom()

func _update_camera_zoom() -> void:
	# For orthographic camera, adjust size
	if _camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		var tween = create_tween()
		tween.tween_property(_camera, "size", _camera_zoom_current, 0.2)
	else:
		# For perspective camera, adjust position
		var direction = (_camera.global_position - Vector3.ZERO).normalized()
		var target_pos = Vector3.ZERO + direction * _camera_zoom_current
		var tween = create_tween()
		tween.tween_property(_camera, "global_position", target_pos, 0.2)

func _select_entity_at_mouse() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = _camera.project_ray_origin(mouse_pos)
	var to = from + _camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 6  # Buildings (2) + Units (3)
	
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		if collider is Unit and collider.team_id == 0:  # Player unit
			_select_entity(collider)
		elif collider is Tower and collider.team_id == 0:  # Player tower
			_select_entity(collider)
		else:
			_deselect_entity()
	else:
		_deselect_entity()

func _select_entity(entity: Node3D) -> void:
	_deselect_entity()
	_selected_entity = entity
	
	if entity.has_method("set_selected"):
		entity.set_selected(true)
	
	# Show info in UI
	var info = {}
	if entity is Unit:
		info = entity.get_unit_info()
	elif entity is Tower:
		info = entity.get_tower_info()
	_ui.show_entity_info(info)

func _deselect_entity() -> void:
	if _selected_entity and is_instance_valid(_selected_entity):
		if _selected_entity.has_method("set_selected"):
			_selected_entity.set_selected(false)
	_selected_entity = null
	_ui.hide_entity_info()

func _on_entity_selected(entity: Node3D) -> void:
	if _selected_entity != entity:
		_deselect_entity()

func _on_entity_deselected() -> void:
	# Handle deselection if needed
	pass
