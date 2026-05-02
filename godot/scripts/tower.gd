extends StaticBody3D
class_name Tower

# Team
@export var team_id: int = 0  # 0 = Player, 1 = Enemy1, 2 = Enemy2

# Stats - Balanced for 5-10 minute matches
@export var range: float = 10.0
@export var damage: float = 25.0
@export var fire_rate: float = 1.2  # shots per second
@export var projectile_speed: float = 20.0

# State
var _fire_timer: float = 0.0
var _current_target: Unit = null

# Packed scene references (will be set at runtime)
var _projectile_scene: PackedScene = null

# Signals
signal fired(target: Unit)
signal selected(tower: Tower)
signal deselected()

# References
@onready var _mesh: MeshInstance3D = $TowerMesh
@onready var _range_indicator: MeshInstance3D = $RangeIndicator
@onready var _muzzle: Marker3D = $Muzzle
@onready var _selection_ring: MeshInstance3D = $SelectionRing

func _ready() -> void:
	_update_color()
	_hide_range_indicator()
	
	# Hide selection ring by default
	if _selection_ring:
		_selection_ring.visible = false
	
	print("Tower placed - Team: " + str(team_id))

func _update_color() -> void:
	if _mesh:
		var material = StandardMaterial3D.new()
		var colors = {0: Color(0.2, 0.5, 1.0), 1: Color(1.0, 0.2, 0.2), 2: Color(0.2, 1.0, 0.2)}
		material.albedo_color = colors.get(team_id, Color.WHITE)
		material.roughness = 0.4
		_mesh.material_override = material

func _process(delta: float) -> void:
	_fire_timer += delta
	
	# Find target
	_current_target = _find_target()
	
	if _current_target and _fire_timer >= 1.0 / fire_rate:
		_fire_at_target()

func _find_target() -> Unit:
	var units = get_tree().get_nodes_in_group("units")
	var best_target: Unit = null
	var best_distance: float = range + 1.0
	
	for unit in units:
		if not unit is Unit:
			continue
		if unit.team_id == team_id:
			continue
		if not unit.is_alive():
			continue
		
		var distance = global_position.distance_to(unit.global_position)
		if distance <= range and distance < best_distance:
			best_target = unit
			best_distance = distance
	
	return best_target

func _fire_at_target() -> void:
	if _current_target == null or not is_instance_valid(_current_target):
		return
	
	_fire_timer = 0.0
	
	# Look at target
	if _current_target:
		var direction = (_current_target.global_position - global_position).normalized()
		look_at(global_position + direction, Vector3.UP)
	
	# Spawn projectile
	_spawn_projectile()
	
	# Visual feedback
	_flash_fire()
	
	fired.emit(_current_target)

func _spawn_projectile() -> void:
	# Create simple projectile
	var projectile = Area3D.new()
	projectile.add_to_group("projectiles")
	
	# Add mesh
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	mesh.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.YELLOW
	material.emission = Color.ORANGE
	material.emission_energy = 1.0
	mesh.material_override = material
	projectile.add_child(mesh)
	
	# Add collision
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.15
	collision.shape = shape
	projectile.add_child(collision)
	
	# Set position
	projectile.global_position = _muzzle.global_position if _muzzle else global_position + Vector3.UP * 1.5
	
	# Calculate direction to target
	var target_pos = _current_target.global_position
	var direction = (target_pos - projectile.global_position).normalized()
	
	# Add script for projectile movement
	projectile.set_meta("direction", direction)
	projectile.set_meta("speed", projectile_speed)
	projectile.set_meta("damage", damage)
	projectile.set_meta("target_team", team_id)
	
	# Connect body_entered signal
	projectile.body_entered.connect(_on_projectile_hit.bind(projectile))
	
	# Add to scene
	get_parent().add_child(projectile)
	
	# Animate projectile
	var tween = create_tween()
	tween.tween_property(projectile, "global_position", target_pos, 0.15)
	tween.chain().tween_callback(projectile.queue_free)
	
	# Apply damage immediately (hitscan style for simplicity)
	_current_target.take_damage(damage)

func _on_projectile_hit(body: Node3D, projectile: Area3D) -> void:
	if body is Unit and body.team_id != team_id:
		body.take_damage(damage)
	projectile.queue_free()

func _flash_fire() -> void:
	if _mesh and _mesh.material_override:
		var tween = create_tween()
		var material = _mesh.material_override as StandardMaterial3D
		if material:
			material.emission = Color.YELLOW
			material.emission_energy = 2.0
			tween.tween_property(material, "emission_energy", 0.0, 0.2)

func show_range_indicator() -> void:
	if _range_indicator:
		_range_indicator.visible = true
		# Create range circle
		var mesh = CylinderMesh.new()
		mesh.top_radius = range
		mesh.bottom_radius = range
		mesh.height = 0.05
		_range_indicator.mesh = mesh
		
		var material = StandardMaterial3D.new()
		var colors = {0: Color(0.2, 0.5, 1.0), 1: Color(1.0, 0.2, 0.2), 2: Color(0.2, 1.0, 0.2)}
		var team_color = colors.get(team_id, Color.WHITE)
		material.albedo_color = Color(team_color.r, team_color.g, team_color.b, 0.3)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_range_indicator.material_override = material

func _hide_range_indicator() -> void:
	if _range_indicator:
		_range_indicator.visible = false

func highlight(is_highlighted: bool) -> void:
	if is_highlighted:
		show_range_indicator()
	else:
		_hide_range_indicator()

func set_selected(selected: bool) -> void:
	if _selection_ring:
		_selection_ring.visible = selected
		if selected:
			selected.emit(self)
		else:
			deselected.emit()

func get_tower_info() -> Dictionary:
	return {
		"type": "tower",
		"range": range,
		"damage": damage,
		"fire_rate": fire_rate,
		"team_id": team_id
	}

func is_in_range_of(position: Vector3) -> bool:
	return global_position.distance_to(position) <= range
