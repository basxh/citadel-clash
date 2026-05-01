extends Node3D

# Main Scene Script - Entry point for gameplay

@onready var camera_rig = $CameraRig
@onready var camera = $CameraRig/Camera3D
@onready var units_node = $Units
@onready var buildings_node = $Buildings
@onready var projectiles_node = $Projectiles

# Camera settings
var camera_speed: float = 30.0
var camera_rotation_speed: float = 1.5
var camera_zoom_speed: float = 5.0
var min_zoom: float = 20.0
var max_zoom: float = 80.0

# Mouse state
var mouse_position: Vector2 = Vector2.ZERO
var is_dragging: bool = false

func _ready():
	print("Main scene loaded")
	
	# Connect to GameManager signals
	if GameManager:
		GameManager.game_state_changed.connect(_on_game_state_changed)
	
	# Initialize camera
	_setup_camera()

func _process(delta):
	if GameManager and GameManager.is_playing():
		_handle_camera_movement(delta)

func _unhandled_input(event):
	if GameManager and not GameManager.is_playing():
		return
	
	# Camera rotation
	if event.is_action_pressed("camera_rotate_left"):
		_rotate_camera(-camera_rotation_speed)
	elif event.is_action_pressed("camera_rotate_right"):
		_rotate_camera(camera_rotation_speed)
	
	# Camera zoom
	if event.is_action_pressed("camera_zoom_in"):
		_zoom_camera(-camera_zoom_speed)
	elif event.is_action_pressed("camera_zoom_out"):
		_zoom_camera(camera_zoom_speed)
	
	# Pause
	if event.is_action_pressed("ui_pause"):
		_toggle_pause()

func _setup_camera():
	# Set initial camera position
	if camera:
		camera.position = Vector3(0, 40, 40)
		camera.look_at(Vector3.ZERO, Vector3.UP)

func _handle_camera_movement(delta: float):
	var movement = Vector3.ZERO
	
	# WASD movement
	if Input.is_action_pressed("move_up"):
		movement.z -= 1
	if Input.is_action_pressed("move_down"):
		movement.z += 1
	if Input.is_action_pressed("move_left"):
		movement.x -= 1
	if Input.is_action_pressed("move_right"):
		movement.x += 1
	
	# Apply movement relative to camera rotation
	if movement.length() > 0:
		movement = movement.normalized() * camera_speed * delta
		movement = movement.rotated(Vector3.UP, camera_rig.rotation.y)
		camera_rig.position += movement
	
	# Clamp camera position to game area
	camera_rig.position.x = clamp(camera_rig.position.x, -60, 60)
	camera_rig.position.z = clamp(camera_rig.position.z, -60, 60)

func _rotate_camera(amount: float):
	if camera_rig:
		camera_rig.rotate_y(amount)

func _zoom_camera(amount: float):
	if camera:
		var new_height = camera.position.y + amount
		new_height = clamp(new_height, min_zoom, max_zoom)
		var direction = camera.position.normalized()
		camera.position = direction * new_height

func _toggle_pause():
	if GameManager:
		if GameManager.get_game_state() == GameManager.GameState.PLAYING:
			GameManager.game_state_changed.emit(GameManager.GameState.PAUSED)
		elif GameManager.get_game_state() == GameManager.GameState.PAUSED:
			GameManager.game_state_changed.emit(GameManager.GameState.PLAYING)

func _on_game_state_changed(state):
	match state:
		GameManager.GameState.PLAYING:
			print("Game is now playing")
		GameManager.GameState.PAUSED:
			print("Game paused - show pause menu")
		GameManager.GameState.VICTORY:
			print("Victory!")
		GameManager.GameState.DEFEAT:
			print("Defeat!")
