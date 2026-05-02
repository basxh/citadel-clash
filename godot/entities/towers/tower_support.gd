extends TowerAdvanced
class_name SupportTower

## Support Tower - Buffs nearby towers with aura effects

var _buffed_towers: Array[TowerAdvanced] = []

func _ready() -> void:
	if tower_data == null:
		tower_data = load("res://resources/tower_data/support_tower_data.tres")
	super._ready()
	add_to_group("towers")
	
	# Always show range indicator for support
	show_range_indicator()

func _process(delta: float) -> void:
	# Support tower doesn't fire, just maintains aura
	if tower_data and tower_data.category == TowerData.Category.SUPPORT:
		_handle_support(delta)

func _flash_fire() -> void:
	# Support tower doesn't fire
	pass

func _aim_at_target() -> void:
	# Support tower doesn't aim
	pass
