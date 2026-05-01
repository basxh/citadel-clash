extends StaticBody3D
class_name Base

# Team identification
@export var team_id: int = 0  # 0 = Player (Blue), 1 = Enemy1 (Red), 2 = Enemy2 (Green)

# Health
@export var max_health: float = 1000.0
var current_health: float = max_health

# Constants
const TEAM_PLAYER: int = 0
const TEAM_ENEMY_1: int = 1
const TEAM_ENEMY_2: int = 2

# Signals
signal destroyed(team: int)
signal health_changed(current: float, max: float)

# References
@onready var _mesh: MeshInstance3D = $BaseMesh
@onready var _health_label: Label3D = $HealthLabel
@onready var _collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	# Set team color
	_update_color()
	_update_health_label()
	
	# Register with GameManager (Autoload)
	GameManager.register_base(self)
	if team_id == TEAM_PLAYER:
		GameManager.set_player_base(self)
	
	print("Base initialized - Team: " + str(team_id))

func _update_color() -> void:
	if _mesh and _mesh.material_override:
		var material = StandardMaterial3D.new()
		material.albedo_color = GameManager.TEAM_COLORS.get(team_id, Color.WHITE)
		material.roughness = 0.7
		_mesh.material_override = material

func _update_health_label() -> void:
	if _health_label:
		_health_label.text = str(int(current_health)) + "/" + str(int(max_health))

func take_damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	_update_health_label()
	
	# Visual feedback - flash white
	_flash_damage()
	
	if current_health <= 0:
		_destroy()

func _flash_damage() -> void:
	if _mesh and _mesh.material_override:
		var tween = create_tween()
		var material = _mesh.material_override as StandardMaterial3D
		if material:
			var original_color = material.albedo_color
			material.albedo_color = Color(1, 1, 1, 0.8)
			tween.tween_property(material, "albedo_color", original_color, 0.2)

func _destroy() -> void:
	print("Base destroyed! Team: " + str(team_id))
	
	# Spawn explosion particles or effect
	_create_destroy_effect()
	
	# Hide the base
	visible = false
	if _collision:
		_collision.disabled = true
	
	destroyed.emit(team_id)
	queue_free()

func _create_destroy_effect() -> void:
	# Simple particle burst effect
	for i in range(10):
		var particle = MeshInstance3D.new()
		particle.mesh = BoxMesh.new()
		particle.scale = Vector3(0.2, 0.2, 0.2)
		particle.position = position + Vector3(randf() - 0.5, randf() * 0.5, randf() - 0.5) * 2
		get_parent().add_child(particle)
		
		var tween = create_tween().set_parallel()
		tween.tween_property(particle, "position", particle.position + Vector3(randf() - 0.5, 1, randf() - 0.5), 1.0)
		tween.tween_property(particle, "scale", Vector3.ZERO, 1.0)
		tween.chain().tween_callback(particle.queue_free)

func get_health_percentage() -> float:
	return current_health / max_health if max_health > 0 else 0.0

func is_alive() -> bool:
	return current_health > 0
