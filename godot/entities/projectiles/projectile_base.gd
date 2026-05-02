extends Area3D
class_name ProjectileBase

## Base class for all projectiles

var target: Node3D = null
var damage: float = 25.0
var speed: float = 20.0
var team_id: int = 0
var tower_data: TowerData = null
var direction: Vector3 = Vector3.ZERO
var homing: bool = true

# For piercing projectiles
var pierced_targets: Array[Node3D] = []
var max_pierce: int = 0

# For splash
var splash_radius: float = 0.0

# Visual
@onready var _mesh: MeshInstance3D = $Mesh if has_node("Mesh") else null
@onready var _trail: GPUParticles3D = $Trail if has_node("Trail") else null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if _trail:
		_trail.emitting = true

func setup(p_target: Node3D, p_damage: float, p_speed: float, p_team: int, p_tower_data: TowerData = null) -> void:
	target = p_target
	damage = p_damage
	speed = p_speed
	team_id = p_team
	tower_data = p_tower_data
	
	if tower_data:
		max_pierce = 3 if tower_data.piercing else 0
		splash_radius = tower_data.splash_radius
		
		# Set color based on tower
		if _mesh and _mesh.material_override:
			var mat = _mesh.material_override.duplicate()
			mat.albedo_color = tower_data.projectile_color
			mat.emission = tower_data.projectile_color
			_mesh.material_override = mat

func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		queue_free()
		return
	
	# Calculate direction
	if homing:
		direction = (target.global_position - global_position).normalized()
	
	# Move projectile
	global_position += direction * speed * delta
	
	# Look at movement direction
	look_at(global_position + direction, Vector3.UP)
	
	# Check if reached target
	if global_position.distance_to(target.global_position) < 0.5:
		_impact(target)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("units"):
		if body.has("team_id") and body.team_id != team_id:
			if not body in pierced_targets:
				_impact(body)

func _impact(hit_target: Node3D) -> void:
	if hit_target and hit_target.has_method("take_damage"):
		_apply_damage(hit_target)
	
	# Splash damage
	if splash_radius > 0:
		_apply_splash_damage()
	
	# Piercing - continue flying
	if max_pierce > 0 and pierced_targets.size() < max_pierce:
		pierced_targets.append(hit_target)
		return
	
	# Destroy projectile
	_destroy_projectile()

func _apply_damage(target_node: Node3D) -> void:
	var final_damage = damage
	
	if tower_data:
		match tower_data.special_effect:
			SpecialEffect.Effect.MAGIC_DAMAGE:
				if target_node.has_method("take_magic_damage"):
					target_node.take_magic_damage(final_damage)
					return
			SpecialEffect.Effect.POISON:
				if target_node.has_method("apply_poison"):
					target_node.apply_poison(final_damage * 0.4, 3.0)
			SpecialEffect.Effect.SLOW:
				if target_node.has_method("apply_slow"):
					target_node.apply_slow(0.5, 2.0)
			SpecialEffect.Effect.ARMOR_PIERCE:
				if target_node.has("armor"):
					final_damage *= (1.0 + target_node.armor * 0.5)
	
	target_node.take_damage(final_damage)

func _apply_splash_damage() -> void:
	if splash_radius <= 0:
		return
	
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if not is_instance_valid(unit):
			continue
		if unit.has("team_id") and unit.team_id == team_id:
			continue
		if unit.global_position.distance_to(global_position) <= splash_radius:
			if unit.has_method("take_damage"):
				var distance = unit.global_position.distance_to(global_position)
				var falloff = 1.0 - (distance / splash_radius) * 0.5
				unit.take_damage(damage * falloff * 0.7)

func _destroy_projectile() -> void:
	# Spawn impact effect
	_spawn_impact_effect()
	
	# Disable collision
	monitoring = false
	
	# Hide mesh
	if _mesh:
		_mesh.visible = false
	
	# Wait for effects then free
	await get_tree().create_timer(0.3).timeout
	queue_free()

func _spawn_impact_effect() -> void:
	var effect = GPUParticles3D.new()
	effect.global_position = global_position
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.1
	material.direction = Vector3.UP
	material.gravity = Vector3(0, -9.8, 0)
	material.initial_velocity_min = 3.0
	material.initial_velocity_max = 6.0
	
	# Color based on projectile type
	var color = Color.ORANGE
	if tower_data:
		color = tower_data.projectile_color
	material.color = color
	
	var draw_pass = QuadMesh.new()
	draw_pass.size = Vector2(0.1, 0.1)
	
	effect.process_material = material
	effect.draw_pass_1 = draw_pass
	effect.amount = 15
	effect.lifetime = 0.4
	effect.one_shot = true
	effect.explosiveness = 0.8
	
	get_parent().add_child(effect)
	effect.emitting = true
	
	# Auto-cleanup
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(effect):
		effect.queue_free()
