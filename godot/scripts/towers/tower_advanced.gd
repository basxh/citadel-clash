extends StaticBody3D
class_name TowerAdvanced

## Advanced Tower Base Class with Upgrade System and Special Effects

@export var team_id: int = 0  # 0 = Player, 1 = Enemy
@export var tower_data: TowerData = null

# Runtime Stats (calculated from base + upgrades)
var current_damage: float = 25.0
var current_range: float = 10.0
var current_fire_rate: float = 1.0
var upgrade_level: int = 0
var max_upgrades: int = 3

# State
var _fire_timer: float = 0.0
var _current_target: Node3D = null
var _is_building: bool = false

# Support/Economy specific
var _support_timer: float = 0.0
var _income_timer: float = 0.0

# Affected units (for effects)
var _affected_units: Dictionary = {}  # unit -> {effect, timer, damage_per_tick}

# References
@onready var _mesh_parent: Node3D = $Meshes if has_node("Meshes") else self
@onready var _range_indicator: MeshInstance3D = $RangeIndicator
@onready var _muzzle: Marker3D = $Muzzle
@onready var _selection_ring: MeshInstance3D = $SelectionRing
@onready var _upgrade_particles: GPUParticles3D = $UpgradeParticles if has_node("UpgradeParticles") else null

# Signals
signal fired(target: Node3D)
signal upgraded(new_level: int)
signal target_acquired(target: Node3D)

func _ready() -> void:
	if tower_data:
		_apply_tower_data()
	_update_visuals()
	_hide_range_indicator()
	
	if _selection_ring:
		_selection_ring.visible = false

func _apply_tower_data() -> void:
	if tower_data == null:
		return
	
	var stats = tower_data.get_stats_for_level(upgrade_level)
	current_damage = stats.damage
	current_range = stats.range
	current_fire_rate = stats.fire_rate
	
	name = tower_data.tower_name

func _update_visuals() -> void:
	if tower_data == null:
		return
	
	# Update color based on upgrade level
	var color = tower_data.get_color_for_level(upgrade_level)
	_update_tower_color(color)
	
	# Update scale slightly with upgrades
	if upgrade_level > 0:
		var scale_mult = 1.0 + (upgrade_level * 0.1)
		if _mesh_parent:
			_mesh_parent.scale = Vector3.ONE * scale_mult

func _update_tower_color(color: Color) -> void:
	# Override in specific tower types
	pass

func _process(delta: float) -> void:
	if tower_data == null or _is_building:
		return
	
	# Handle economy tower
	if tower_data.category == TowerData.Category.ECONOMY:
		_handle_economy(delta)
		return
	
	# Handle support tower
	if tower_data.category == TowerData.Category.SUPPORT:
		_handle_support(delta)
		return
	
	# Combat towers
	_fire_timer += delta
	
	_current_target = _find_target()
	
	if _current_target:
		_aim_at_target()
		if _fire_timer >= 1.0 / current_fire_rate:
			_fire_at_target()

func _handle_economy(delta: float) -> void:
	_income_timer += delta
	if _income_timer >= 1.0:  # Every second
		_income_timer = 0.0
		# Emit gold generation signal
		_income_generated()

func _income_generated() -> void:
	if tower_data and tower_data.gold_per_second > 0:
		# Visual feedback
		_flash_income_effect()

func _flash_income_effect() -> void:
	# Create gold sparkle effect
	if _muzzle:
		var sparkle = _create_particles(Color.GOLD, 0.5)
		_muzzle.add_child(sparkle)
		sprinkle.emitting = true
		await get_tree().create_timer(0.5).timeout
		sparkle.queue_free()

func _handle_support(delta: float) -> void:
	_support_timer += delta
	if _support_timer >= 0.5:  # Check every 0.5 seconds
		_support_timer = 0.0
		_apply_support_aura()

func _apply_support_aura() -> void:
	if tower_data == null:
		return
	
	var towers = get_tree().get_nodes_in_group("towers")
	for tower in towers:
		if tower == self:
			continue
		if tower.team_id != team_id:
			continue
		
		var distance = global_position.distance_to(tower.global_position)
		if distance <= tower_data.aura_range:
			# Apply buffs
			if tower_data.damage_buff > 0:
				tower._apply_damage_buff(tower_data.damage_buff)
			if tower_data.range_buff > 0:
				tower._apply_range_buff(tower_data.range_buff)

func _apply_damage_buff(amount: float) -> void:
	current_damage *= (1.0 + amount)

func _apply_range_buff(amount: float) -> void:
	current_range *= (1.0 + amount)

func _find_target() -> Node3D:
	var best_target: Node3D = null
	var best_score: float = -1.0
	
	# Get all potential targets
	var units = get_tree().get_nodes_in_group("units")
	
	for unit in units:
		if not is_instance_valid(unit):
			continue
		if not unit.has_method("is_alive") or not unit.is_alive():
			continue
		if unit.has("team_id") and unit.team_id == team_id:
			continue
		
		var distance = global_position.distance_to(unit.global_position)
		if distance > current_range:
			continue
		
		# Scoring: prioritize by distance (closer = higher priority)
		var score = current_range - distance
		
		# Bonus for armor-piercing vs armored targets
		if tower_data and tower_data.tower_type == TowerType.Type.ARMOR_PIERCING:
			if unit.has("armor") and unit.armor > 0:
				score += unit.armor * 10
		
		if score > best_score:
			best_target = unit
			best_score = score
	
	if best_target and best_target != _current_target:
		target_acquired.emit(best_target)
	
	return best_target

func _aim_at_target() -> void:
	if _current_target and _muzzle:
		var direction = (_current_target.global_position - global_position).normalized()
		direction.y = 0  # Keep horizontal rotation
		look_at(global_position + direction, Vector3.UP)

func _fire_at_target() -> void:
	if _current_target == null or not is_instance_valid(_current_target):
		return
	
	_fire_timer = 0.0
	
	# Spawn appropriate projectile
	_spawn_projectile()
	
	# Visual feedback
	_flash_fire()
	
	fired.emit(_current_target)

func _spawn_projectile() -> void:
	if tower_data == null:
		return
	
	var projectile_scene = load(ProjectileType.get_mesh_path(tower_data.projectile_type))
	if projectile_scene == null:
		# Fallback to basic projectile
		_create_basic_projectile()
		return
	
	var projectile = projectile_scene.instantiate()
	if projectile == null:
		_create_basic_projectile()
		return
	
	# Configure projectile
	projectile.global_position = _muzzle.global_position if _muzzle else global_position + Vector3.UP * 1.5
	
	# Set projectile properties
	if projectile.has_method("setup"):
		projectile.setup(_current_target, current_damage, tower_data.projectile_speed, team_id, tower_data)
	
	get_parent().add_child(projectile)

func _create_basic_projectile() -> void:
	# Fallback simple projectile
	var projectile = Area3D.new()
	projectile.add_to_group("projectiles")
	
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	mesh.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = tower_data.projectile_color if tower_data else Color.YELLOW
	material.emission = material.albedo_color
	material.emission_energy = 1.0
	mesh.material_override = material
	projectile.add_child(mesh)
	
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.15
	collision.shape = shape
	projectile.add_child(collision)
	
	projectile.global_position = _muzzle.global_position if _muzzle else global_position + Vector3.UP * 1.5
	
	# Animate and apply damage
	if _current_target:
		var tween = create_tween()
		tween.tween_property(projectile, "global_position", _current_target.global_position, 0.15)
		tween.chain().tween_callback(func():
			if is_instance_valid(_current_target) and _current_target.has_method("take_damage"):
				_apply_damage_with_effects(_current_target)
			projectile.queue_free()
		)
	
	get_parent().add_child(projectile)

func _apply_damage_with_effects(target: Node3D) -> void:
	if not target.has_method("take_damage"):
		return
	
	var final_damage = current_damage
	
	# Apply special effects
	if tower_data:
		match tower_data.special_effect:
			SpecialEffect.Effect.SLOW:
				if target.has_method("apply_slow"):
					target.apply_slow(tower_data.effect_strength, tower_data.effect_duration)
			SpecialEffect.Effect.POISON:
				if target.has_method("apply_poison"):
					target.apply_poison(current_damage * 0.3, tower_data.effect_duration)
			SpecialEffect.Effect.MAGIC_DAMAGE:
				# Magic ignores armor
				if target.has_method("take_magic_damage"):
					target.take_magic_damage(final_damage)
					return
			SpecialEffect.Effect.ARMOR_PIERCE:
				if target.has("armor"):
					final_damage *= (1.0 + target.armor * tower_data.armor_piercing)
			SpecialEffect.Effect.SPLASH:
				_apply_splash_damage(target.global_position, final_damage)
			SpecialEffect.Effect.PIERCING:
				# Piercing is handled in projectile
				pass
	
	target.take_damage(final_damage)

func _apply_splash_damage(position: Vector3, damage: float) -> void:
	if tower_data == null or tower_data.splash_radius <= 0:
		return
	
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if not is_instance_valid(unit):
			continue
		if unit.has("team_id") and unit.team_id == team_id:
			continue
		if unit.global_position.distance_to(position) <= tower_data.splash_radius:
			if unit.has_method("take_damage"):
				# Splash damage falls off with distance
				var distance = unit.global_position.distance_to(position)
				var falloff = 1.0 - (distance / tower_data.splash_radius) * 0.5
				unit.take_damage(damage * falloff)

func _flash_fire() -> void:
	# Override in subclasses for visual feedback
	pass

func upgrade() -> bool:
	if upgrade_level >= max_upgrades:
		return false
	
	upgrade_level += 1
	_apply_tower_data()
	_update_visuals()
	
	# Show upgrade particles
	if _upgrade_particles:
		_upgrade_particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		_upgrade_particles.emitting = false
	
	upgraded.emit(upgrade_level)
	return true

func get_upgrade_cost() -> int:
	if tower_data and upgrade_level < max_upgrades:
		return tower_data.get_upgrade_cost(upgrade_level)
	return -1

func show_range_indicator() -> void:
	if _range_indicator:
		_range_indicator.visible = true
		# Create range circle
		var mesh = CylinderMesh.new()
		mesh.top_radius = current_range
		mesh.bottom_radius = current_range
		mesh.height = 0.05
		_range_indicator.mesh = mesh
		
		var material = StandardMaterial3D.new()
		var team_colors = {0: Color(0.2, 0.5, 1.0), 1: Color(1.0, 0.2, 0.2)}
		var team_color = team_colors.get(team_id, Color.WHITE)
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

func set_selected(is_selected: bool) -> void:
	if _selection_ring:
		_selection_ring.visible = is_selected

func get_tower_info() -> Dictionary:
	return {
		"name": tower_data.tower_name if tower_data else "Tower",
		"type": tower_data.tower_type if tower_data else TowerType.Type.BASIC,
		"level": upgrade_level,
		"damage": current_damage,
		"range": current_range,
		"fire_rate": current_fire_rate,
		"upgrade_cost": get_upgrade_cost()
	}

func _create_particles(color: Color, size: float) -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = size
	material.particle_flag_align_y = true
	material.direction = Vector3.UP
	material.gravity = Vector3(0, -9.8, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	material.color = color
	
	var draw_pass = QuadMesh.new()
	draw_pass.size = Vector2(0.1, 0.1)
	
	particles.process_material = material
	particles.draw_pass_1 = draw_pass
	particles.amount = 20
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.explosiveness = 1.0
	
	return particles
