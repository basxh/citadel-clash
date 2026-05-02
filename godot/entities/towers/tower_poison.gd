extends TowerAdvanced
class_name PoisonTower

## Poison Tower - Applies damage over time debuff

func _ready() -> void:
	if tower_data == null:
		tower_data = load("res://resources/tower_data/poison_tower_data.tres")
	super._ready()
	add_to_group("towers")

func _update_tower_color(color: Color) -> void:
	var meshes = get_children()
	for child in meshes:
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			mat.roughness = 0.6
			child.material_override = mat

func _flash_fire() -> void:
	var spout = $Meshes/PoisonSpout if has_node("Meshes/PoisonSpout") else null
	if spout:
		var tween = create_tween()
		tween.tween_property(spout, "rotation:x", 0.5, 0.1)
		tween.tween_property(spout, "rotation:x", 0.0, 0.2)
