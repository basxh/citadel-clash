extends TowerAdvanced
class_name FrostTower

## Frost Tower - Slows enemies with ice attacks

func _ready() -> void:
	if tower_data == null:
		tower_data = load("res://resources/tower_data/frost_tower_data.tres")
	super._ready()
	add_to_group("towers")

func _update_tower_color(color: Color) -> void:
	var meshes = get_children()
	for child in meshes:
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			mat.roughness = 0.1
			mat.metallic = 0.3
			child.material_override = mat

func _flash_fire() -> void:
	var core = $Meshes/IceCore if has_node("Meshes/IceCore") else null
	if core:
		var tween = create_tween()
		tween.tween_property(core, "scale", Vector3.ONE * 1.3, 0.1)
		tween.tween_property(core, "scale", Vector3.ONE, 0.3)
