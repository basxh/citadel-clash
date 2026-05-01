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

# Build mode
var _build_mode: bool = false
var _build_preview: MeshInstance3D = null

func _ready() -> void:
	# Connect UI signals
	_ui.buy_unit_requested.connect(_on_buy_unit)
	_ui.build_mode_toggled.connect(_on_build_mode_toggled)
	
	# Connect AI signals
	var ai_controllers = $AIControllers.get_children()
	for ai in ai_controllers:
		ai.ai_spawn_unit_requested.connect(_on_ai_spawn_unit)
		ai.ai_build_tower_requested.connect(_on_ai_build_tower)
	
	print("Game scene initialized")

func _process(_delta: float) -> void:
	# Handle build preview
	if _build_mode:
		_update_build_preview()
	
	# Handle camera controls
	_handle_camera_input()

func _input(event: InputEvent) -> void:
	if _build_mode and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_try_build_tower()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_on_build_mode_toggled(false)

func _on_buy_unit(unit_type: String) -> void:
	# Spawn unit at player base
	var player_base = GameManager.get_player_base()
	if player_base:
		_spawn_unit(unit_type, GameManager.TEAM_PLAYER, player_base.global_position + Vector3(randf() - 0.5, 0, randf() - 0.5) * 3)

func _on_build_mode_toggled(active: bool) -> void:
	_build_mode = active
	
	if _build_mode:
		_create_build_preview()
	else:
		_destroy_build_preview()

func _create_build_preview() -> void:
	_build_preview = MeshInstance3D.new()
	_build_preview.mesh = BoxMesh.new()
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.5, 0.5, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_build_preview.material_override = material
	
	add_child(_build_preview)

func _destroy_build_preview() -> void:
	if _build_preview:
		_build_preview.queue_free()
		_build_preview = null

func _update_build_preview() -> void:
	if not _build_preview:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = _camera.project_ray_origin(mouse_pos)
	var to = from + _camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # Terrain layer
	
	var result = space_state.intersect_ray(query)
	if result:
		_build_preview.global_position = result.position + Vector3.UP * 1.25

func _try_build_tower() -> void:
	if not _build_preview:
		return
	
	var pos = _build_preview.global_position
	
	# Check if we can afford
	if not GameManager.can_afford(GameManager.TEAM_PLAYER, GameManager.COST_TOWER):
		return
	
	# Check if position is valid (not too close to other towers)
	if _is_position_valid_for_tower(pos):
		GameManager.spend_gold(GameManager.TEAM_PLAYER, GameManager.COST_TOWER)
		_build_tower(pos, GameManager.TEAM_PLAYER)
		_on_build_mode_toggled(false)

func _is_position_valid_for_tower(pos: Vector3) -> bool:
	# Check distance from other towers
	for tower in _towers_container.get_children():
		if pos.distance_to(tower.global_position) < 3.0:
			return false
	return true

func _build_tower(pos: Vector3, team: int) -> void:
	var tower = _tower_template.instantiate() as Tower
	tower.global_position = pos	tower.team_id = team
	_towers_container.add_child(tower)

func _spawn_unit(unit_type: String, team: int, spawn_pos: Vector3) -> void:
	var unit = _unit_template.instantiate() as Unit
	unit.global_position = spawn_pos
	unit.team_id = team
	unit.set_stats_from_type(unit_type)
	unit.add_to_group("units")
	_units_container.add_child(unit)
	
	if GameManager:
		GameManager.unit_spawned.emit(unit)

func _on_ai_spawn_unit(spawn_data: Dictionary) -> void:
	var unit_type = spawn_data["type"]
	var team = spawn_data["team"]
	var pos = spawn_data["position"]
	_spawn_unit(unit_type, team, pos)

func _on_ai_build_tower(pos: Vector3, team: int) -> void:
	_build_tower(pos, team)

func _handle_camera_input() -> void:
	var move_speed = 20.0
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	if input_dir != Vector3.ZERO:
		_camera.global_position += input_dir.normalized() * move_speed * get_process_delta_time()
	
	# Zoom
	if Input.is_action_pressed("camera_zoom_in"):
		_camera.size = max(20, _camera.size - 2)
	if Input.is_action_pressed("camera_zoom_out"):
		_camera.size = min(120, _camera.size + 2)
