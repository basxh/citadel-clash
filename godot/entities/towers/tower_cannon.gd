extends TowerAdvanced
class_name CannonTower

## Cannon Tower - Explosive splash damage

func _ready() -> void:
	if tower_data == null:
		tower_data = load("res://resources/tower_data/cannon_tower_data.tres")
	super._ready()
	add_to_group("towers")

func _update_tower_color(color: Color) -> void:
	var meshes = get_children()
	for child in meshes:
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			mat.metallic = 0.5
			mat.roughness = 0.6
			child.material_override = mat

func _flash_fire() -> void:
	var barrel = $Meshes/CannonBarrel if has_node("Meshes/CannonBarrel") else null
	if barrel:
		var tween = create_tween()
		var original_pos = barrel.position
		tween.tween_property(barrel, "position:z", original_pos.z - 0.4, 0.05)
		tween.tween_property(barrel, "position:z", original_pos.z, 0.2)
	
	# Flash effect
	var flash = $Meshes/Flash if has_node("Meshes/Flash") else null
	if flash:
		flash.visible = true
		await get_tree().create_timer(0.1).timeout
		flash.visible = false
