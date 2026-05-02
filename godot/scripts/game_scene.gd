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

# Spawn Test Mode
var _spawn_test_running: bool = false
var _spawn_test_count: int = 0

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
	
	# DEBUG: Add spawn test button (press T to run)
	print("Game scene initialized with TowerPlacementSystem")
	print("DEBUG: Press 'T' to run spawn test")

func _input(event: InputEvent) -> void:
	# DEBUG: Test spawn system with 'T' key
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_T:
			run_spawn_test()
			return

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
	# Spawn unit at CENTER targeting specific enemy
	# All units spawn in center arena
	var spawn_pos = Vector3.ZERO  # Center of map
	
	# Get path for target
	var path_id = UnitPathing.get_path_for_target(target_team)
	
	# Spawn with proper initialization
	_spawn_unit_with_init(unit_type, 0, spawn_pos, path_id, target_team)
	print("GameScene: Player (Team 0) spawned ", unit_type, " targeting Team ", target_team, " on Path ", path_id)

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

func _spawn_unit_with_init(unit_type: String, team: int, spawn_pos: Vector3, path_id: int, target_team: int) -> void:
	"""Spawn unit with proper initialization - units spawn in center"""
	var unit = _unit_template.instantiate() as Unit
	unit.global_position = spawn_pos  # Center position
	unit.set_stats_from_type(unit_type)
	
	# Initialize with sender and target info
	unit.initialize(team, target_team)
	
	unit.add_to_group("units")
	
	# Connect selection signals
	unit.selected.connect(_on_entity_selected)
	unit.deselected.connect(_on_entity_deselected)
	
	_units_container.add_child(unit)
	
	print("GameScene: Unit spawned at ", spawn_pos, " | Sender: ", team, " | Target: ", target_team, " | Path: ", path_id)
	
	if GameManager:
		GameManager.unit_spawned.emit(unit)

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
	var sender_team = spawn_data.get("sender_team", team)
	
	# Use new initialization system
	_spawn_unit_with_init(unit_type, sender_team, pos, path_id, target_team)

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

# =============================================================================
# SPAWN TEST SYSTEM - Debug/Testing
# =============================================================================

func run_spawn_test() -> void:
	"""Run comprehensive spawn test - spawns 10 units per team to all targets"""
	if _spawn_test_running:
		print("Spawn test already running!")
		return
	
	_spawn_test_running = true
	_spawn_test_count = 0
	
	print("")
	print("=" * 60)
	print("SPAWN TEST STARTING")
	print("=" * 60)
	print("Spawning 10 units per team targeting each other team")
	print("Expected: 60 units total, all spawning at center (0, 0, 0)")
	print("")
	
	# Get AI controllers
	var ai_controllers = $AIControllers.get_children()
	var ai_1 = ai_controllers[0] if ai_controllers.size() > 0 else null
	var ai_2 = ai_controllers[1] if ai_controllers.size() > 1 else null
	
	# Spawn 10 batches
	for i in range(10):
		print("\n--- Spawn Batch ", i + 1, " ---")
		
		# Player (Team 0) sends units
		_spawn_unit_with_init("basic", 0, Vector3.ZERO, 1, 1)  # To Team 1
		_spawn_unit_with_init("fast", 0, Vector3.ZERO, 2, 2)   # To Team 2
		print("Player: spawned basic (to Team 1), fast (to Team 2)")
		
		# AI 1 (Team 1) sends units if available
		if ai_1:
			ai_1._spawn_unit_to_target("basic", 0)  # To Player
			ai_1._spawn_unit_to_target("tank", 2)   # To Team 2
			print("AI 1: spawned basic (to Player), tank (to Team 2)")
		
		# AI 2 (Team 2) sends units if available
		if ai_2:
			ai_2._spawn_unit_to_target("basic", 0)  # To Player
			ai_2._spawn_unit_to_target("fast", 1)    # To Team 1
			print("AI 2: spawned basic (to Player), fast (to Team 1)")
		
		_spawn_test_count += 6
		
		# Small delay between batches
		await get_tree().create_timer(0.3).timeout
	
	print("")
	print("=" * 60)
	print("SPAWN TEST COMPLETE")
	print("Total units spawned: ", _spawn_test_count)
	print("All units should have spawned at center (0, 0, 0)")
	print("Check console logs above for verification")
	print("=" * 60)
	print("")
	
	# Schedule verification
	await get_tree().create_timer(2.0).timeout
	_verify_spawn_test()
	
	_spawn_test_running = false

func _verify_spawn_test() -> void:
	"""Verify spawn test results"""
	var units = get_tree().get_nodes_in_group("units")
	
	print("")
	print("SPAWN TEST VERIFICATION")
	print("-" * 40)
	print("Total units in game: ", units.size())
	
	var spawn_issues = 0
	for unit in units:
		if unit is Unit:
			var distance_from_center = unit.global_position.distance_to(Vector3.ZERO)
			if distance_from_center > 10:  # Should spawn near center
				print("WARNING: Unit far from center! Distance: ", distance_from_center)
				spawn_issues += 1
			
			print("Unit - Sender: ", unit.sender_team, 
				" Target: ", unit.target_team, 
				" Path: ", unit.path_index,
				" Pos: ", unit.global_position)
	
	if spawn_issues == 0:
		print("✓ All units spawned correctly at center!")
	else:
		print("✗ Found ", spawn_issues, " units with spawn issues")
	
	print("-" * 40)

func _on_entity_selected(entity: Node3D) -> void:
	if _selected_entity != entity:
		_deselect_entity()

func _on_entity_deselected() -> void:
	# Handle deselection if needed
	pass
