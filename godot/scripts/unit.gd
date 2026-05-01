extends CharacterBody3D
class_name Unit

# Team
@export var team_id: int = 0  # 0 = Player, 1 = Enemy1, 2 = Enemy2

# Stats
@export var unit_type: String = "basic"
@export var max_health: float = 100.0
@export var move_speed: float = 3.0
@export var attack_damage: float = 10.0
@export var attack_range: float = 2.0
@export var attack_rate: float = 1.0  # attacks per second

# Current state
var current_health: float = max_health
var _target_base: Base = null
var _is_attacking: bool = false
var _attack_timer: float = 0.0

# Navigation
var _path_points: Array[Vector3] = []
var _current_path_index: int = 0

# Signals
signal died(unit: Unit)
signal health_changed(current: float, max: float)

# References
@onready var _mesh: MeshInstance3D = $UnitMesh
@onready var _health_bar: MeshInstance3D = $HealthBar

func _ready() -> void:
	_update_color()
	_update_health_bar()
	
	# Find target base
	_find_target_base()
	
	print("Unit spawned - Team: " + str(team_id) + ", Type: " + unit_type)

func _update_color() -> void:
	if _mesh:
		var material = StandardMaterial3D.new()
		var colors = {0: Color(0.2, 0.5, 1.0), 1: Color(1.0, 0.2, 0.2), 2: Color(0.2, 1.0, 0.2)}
		material.albedo_color = colors.get(team_id, Color.WHITE)
		material.roughness = 0.5
		_mesh.material_override = material

func _update_health_bar() -> void:
	if _health_bar:
		var percent = current_health / max_health
		_health_bar.scale.x = percent
		_health_bar.position.x = (1.0 - percent) * -0.5
		
		var material = StandardMaterial3D.new()
		if percent > 0.5:
			material.albedo_color = Color.GREEN
		elif percent > 0.25:
			material.albedo_color = Color.YELLOW
		else:
			material.albedo_color = Color.RED
		_health_bar.material_override = material

func _find_target_base() -> void:
	# Find enemy bases
	var bases = get_tree().get_nodes_in_group("bases")
	var enemy_bases: Array[Base] = []
	
	for base in bases:
		if base is Base and base.team_id != team_id:
			enemy_bases.append(base)
	
	if enemy_bases.is_empty():
		_target_base = null
		return
	
	# Find closest base
	enemy_bases.sort_custom(func(a, b): return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position))
	_target_base = enemy_bases[0]

func _physics_process(delta: float) -> void:
	if current_health <= 0:
		return
	
	if _is_attacking:
		_handle_attack(delta)
	else:
		_handle_movement(delta)

func _handle_movement(delta: float) -> void:
	if _target_base == null or not is_instance_valid(_target_base):
		_find_target_base()
		return
	
	if not _target_base.is_alive():
		_find_target_base()
		return
	
	var direction = (_target_base.global_position - global_position).normalized()
	var distance = global_position.distance_to(_target_base.global_position)
	
	if distance <= attack_range:
		_start_attack()
		return
	
	# Move towards target
	velocity = direction * move_speed
	velocity.y = 0  # Keep on ground
	
	# Look at target
	if direction.length() > 0.01:
		look_at(global_position + direction, Vector3.UP)
	
	move_and_slide()

func _start_attack() -> void:
	_is_attacking = true
	_attack_timer = 0.0
	velocity = Vector3.ZERO

func _handle_attack(delta: float) -> void:
	if _target_base == null or not is_instance_valid(_target_base) or not _target_base.is_alive():
		_is_attacking = false
		_find_target_base()
		return
	
	_attack_timer += delta
	if _attack_timer >= 1.0 / attack_rate:
		_attack_timer = 0.0
		_deal_damage()

func _deal_damage() -> void:
	if _target_base and is_instance_valid(_target_base):
		_target_base.take_damage(attack_damage)
		
		# Visual feedback
		_flash_attack()

func _flash_attack() -> void:
	if _mesh and _mesh.material_override:
		var tween = create_tween()
		var material = _mesh.material_override as StandardMaterial3D
		if material:
			var original_emission = material.emission
			material.emission = Color(1, 0.8, 0.5)
			material.emission_energy = 2.0
			tween.tween_property(material, "emission_energy", 0.0, 0.3)

func take_damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	_update_health_bar()
	
	if current_health <= 0:
		_die()

func _die() -> void:
	print("Unit died - Team: " + str(team_id))
	
	if GameManager:
		GameManager.unit_died.emit(self)
	
	# Spawn death particles
	_create_death_effect()
	
	died.emit(self)
	queue_free()

func _create_death_effect() -> void:
	for i in range(5):
		var particle = MeshInstance3D.new()
		particle.mesh = BoxMesh.new()
		particle.scale = Vector3(0.1, 0.1, 0.1)
		particle.position = position + Vector3(randf() - 0.5, randf() * 0.3, randf() - 0.5)
		get_parent().add_child(particle)
		
		var tween = create_tween().set_parallel()
		tween.tween_property(particle, "position", particle.position + Vector3(randf() - 0.5, 0.5, randf() - 0.5), 0.5)
		tween.tween_property(particle, "scale", Vector3.ZERO, 0.5)
		tween.chain().tween_callback(particle.queue_free)

func get_health_percentage() -> float:
	return current_health / max_health if max_health > 0 else 0.0

func is_alive() -> bool:
	return current_health > 0

func set_stats_from_type(type_name: String) -> void:
	unit_type = type_name
	match type_name:
		"basic":
			max_health = 100.0
			move_speed = 3.0
			attack_damage = 10.0
			attack_rate = 1.0
		"fast":
			max_health = 60.0
			move_speed = 6.0
			attack_damage = 7.0
			attack_rate = 1.5
		"tank":
			max_health = 300.0
			move_speed = 1.5
			attack_damage = 25.0
			attack_rate = 0.5
	
	current_health = max_health
	_update_health_bar()
