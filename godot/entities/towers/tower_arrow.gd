extends TowerAdvanced
class_name ArrowTower

## Arrow Tower - Fast firing archer tower with wooden design

func _ready() -> void:
	if tower_data == null:
		tower_data = load("res://resources/tower_data/arrow_tower_data.tres")
	super._ready()
	add_to_group("towers")

func _update_tower_color(color: Color) -> void:
	# Update wood materials
	var meshes = get_children()
	for child in meshes:
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			mat.roughness = 0.7
			child.material_override = mat

func _flash_fire() -> void:
	# Flash the bow tip
	var bow_tip = $Meshes/BowTip if has_node("Meshes/BowTip") else null
	if bow_tip:
		var tween = create_tween()
		var original_scale = bow_tip.scale
		tween.tween_property(bow_tip, "scale", original_scale * 1.3, 0.05)
		tween.tween_property(bow_tip, "scale", original_scale, 0.1)
