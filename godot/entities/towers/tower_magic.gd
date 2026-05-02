extends TowerAdvanced
class_name MagicTower

## Magic Tower - High damage, ignores armor, magical projectiles

func _ready() -> void:
	if tower_data == null:
		tower_data = load("res://resources/tower_data/magic_tower_data.tres")
	super._ready()
	add_to_group("towers")

func _update_tower_color(color: Color) -> void:
	var meshes = get_children()
	for child in meshes:
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			mat.emission = color
			mat.emission_energy = 0.5
			child.material_override = mat

func _flash_fire() -> void:
	# Pulse the crystal
	var crystal = $Meshes/Crystal if has_node("Meshes/Crystal") else null
	if crystal:
		var tween = create_tween()
		tween.tween_property(crystal, "scale", Vector3.ONE * 1.5, 0.1)
		tween.tween_property(crystal, "scale", Vector3.ONE, 0.2)
		tween.parallel().tween_property(crystal, "rotation:y", crystal.rotation.y + PI, 0.3)
