extends TowerAdvanced
class_name BallistaTower

## Ballista Tower - Heavy piercing projectile launcher

func _ready() -> void:
	if tower_data == null:
		tower_data = load("res://resources/tower_data/ballista_tower_data.tres")
	super._ready()
	add_to_group("towers")

func _update_tower_color(color: Color) -> void:
	var meshes = get_children()
	for child in meshes:
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			mat.metallic = 0.4
			mat.roughness = 0.5
			child.material_override = mat

func _flash_fire() -> void:
	var barrel = $Meshes/Barrel if has_node("Meshes/Barrel") else null
	if barrel:
		var tween = create_tween()
		var original_pos = barrel.position
		tween.tween_property(barrel, "position:z", original_pos.z - 0.3, 0.05)
		tween.tween_property(barrel, "position:z", original_pos.z, 0.15)
