extends TowerAdvanced
class_name EconomyTower

## Economy Tower - Generates passive gold income

@export var gold_accumulated: float = 0.0

func _ready() -> void:
	if tower_data == null:
		tower_data = load("res://resources/tower_data/economy_tower_data.tres")
	super._ready()
	add_to_group("towers")

func _flash_fire() -> void:
	# Flash gold generation
	var coin = $Meshes/Coin if has_node("Meshes/Coin") else null
	if coin:
		var tween = create_tween()
		tween.tween_property(coin, "position:y", coin.position.y + 0.3, 0.2)
		tween.tween_property(coin, "position:y", coin.position.y, 0.2)
		tween.parallel().tween_property(coin, "rotation:y", coin.rotation.y + PI * 2, 0.4)

func get_income_per_second() -> float:
	if tower_data:
		return tower_data.gold_per_second * (1.0 + upgrade_level * 0.5)
	return 0.0
