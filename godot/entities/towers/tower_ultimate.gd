extends TowerAdvanced
class_name UltimateTower

## Ultimate Tower - Devastating laser damage, endgame tower

var _laser_active: bool = false
var _laser_target: Node3D = null

func _ready() -> void:
	if tower_data == null:
		tower_data = load("res://resources/tower_data/ultimate_tower_data.tres")
	super._ready()
	add_to_group("towers")

func _update_tower_color(color: Color) -> void:
	var meshes = get_children()
	for child in meshes:
		if child is MeshInstance3D and child.name != "LaserBeam":
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			mat.roughness = 0.3
			child.material_override = mat

func _fire_at_target() -> void:
	if _current_target == null or not is_instance_valid(_current_target):
		_stop_laser()
		return
	
	_fire_timer = 0.0
	
	# Activate laser beam
	if not _laser_active:
		_start_laser(_current_target)
	
	_aim_at_target()
	
	# Apply continuous damage
	if _current_target and _current_target.has_method("take_damage"):
		_current_target.take_damage(current_damage * 0.3)  # Damage per tick
	
	fired.emit(_current_target)

func _start_laser(target: Node3D) -> void:
	_laser_active = true
	_laser_target = target
	
	var beam = $Meshes/LaserBeam if has_node("Meshes/LaserBeam") else null
	if beam:
		beam.visible = true
		_update_laser_beam()

func _stop_laser() -> void:
	_laser_active = false
	_laser_target = null
	
	var beam = $Meshes/LaserBeam if has_node("Meshes/LaserBeam") else null
	if beam:
		beam.visible = false

func _process(delta: float) -> void:
	super._process(delta)
	
	if _laser_active:
		if _laser_target == null or not is_instance_valid(_laser_target):
			_stop_laser()
		else:
			_update_laser_beam()

func _update_laser_beam() -> void:
	if _laser_target == null:
		return
	
	var beam = $Meshes/LaserBeam if has_node("Meshes/LaserBeam") else null
	if beam == null:
		return
	
	# Position and scale beam to reach target
	var start_pos = global_position + Vector3.UP * 5.5
	var end_pos = _laser_target.global_position
	var distance = start_pos.distance_to(end_pos)
	
	beam.global_position = (start_pos + end_pos) / 2.0
	beam.scale.z = distance
	beam.look_at(end_pos, Vector3.UP)

func _find_target() -> Node3D:
	var target = super._find_target()
	if target == null:
		_stop_laser()
	return target

func _flash_fire() -> void:
	# Eye pulse when firing laser
	var eye = $Meshes/Eye if has_node("Meshes/Eye") else null
	if eye:
		var tween = create_tween()
		tween.tween_property(eye, "scale", Vector3.ONE * 1.3, 0.1)
		tween.tween_property(eye, "scale", Vector3.ONE, 0.2)
		tween.parallel().tween_property(eye, "rotation:y", eye.rotation.y + PI * 2, 0.5)
