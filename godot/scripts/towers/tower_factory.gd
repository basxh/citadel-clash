class_name TowerFactory

## Factory for creating tower instances with proper data

const TOWER_SCENES := {
	TowerType.Type.ARROW: "res://entities/towers/tower_arrow.tscn",
	TowerType.Type.BALLISTA: "res://entities/towers/tower_ballista.tscn",
	TowerType.Type.CANNON: "res://entities/towers/tower_cannon.tscn",
	TowerType.Type.MAGIC: "res://entities/towers/tower_magic.tscn",
	TowerType.Type.FROST: "res://entities/towers/tower_frost.tscn",
	TowerType.Type.POISON: "res://entities/towers/tower_poison.tscn",
	TowerType.Type.ARMOR_PIERCING: "res://entities/towers/tower_armor_piercing.tscn",
	TowerType.Type.SUPPORT: "res://entities/towers/tower_support.tscn",
	TowerType.Type.ECONOMY: "res://entities/towers/tower_economy.tscn",
	TowerType.Type.ULTIMATE: "res://entities/towers/tower_ultimate.tscn"
}

const TOWER_DATA := {
	TowerType.Type.ARROW: "res://resources/tower_data/arrow_tower_data.tres",
	TowerType.Type.BALLISTA: "res://resources/tower_data/ballista_tower_data.tres",
	TowerType.Type.CANNON: "res://resources/tower_data/cannon_tower_data.tres",
	TowerType.Type.MAGIC: "res://resources/tower_data/magic_tower_data.tres",
	TowerType.Type.FROST: "res://resources/tower_data/frost_tower_data.tres",
	TowerType.Type.POISON: "res://resources/tower_data/poison_tower_data.tres",
	TowerType.Type.ARMOR_PIERCING: "res://resources/tower_data/armor_tower_data.tres",
	TowerType.Type.SUPPORT: "res://resources/tower_data/support_tower_data.tres",
	TowerType.Type.ECONOMY: "res://resources/tower_data/economy_tower_data.tres",
	TowerType.Type.ULTIMATE: "res://resources/tower_data/ultimate_tower_data.tres"
}

static func create_tower(tower_type: TowerType.Type, team_id: int = 0) -> TowerAdvanced:
	var scene_path = TOWER_SCENES.get(tower_type, "")
	var data_path = TOWER_DATA.get(tower_type, "")
	
	if scene_path.is_empty() or data_path.is_empty():
		push_error("Unknown tower type: " + str(tower_type))
		return null
	
	var scene = load(scene_path)
	if scene == null:
		push_error("Failed to load tower scene: " + scene_path)
		return null
	
	var tower = scene.instantiate()
	if tower == null:
		push_error("Failed to instantiate tower")
		return null
	
	# Load and assign tower data
	var tower_data = load(data_path)
	if tower_data:
		tower.tower_data = tower_data
	
	tower.team_id = team_id
	
	return tower

static func get_tower_cost(tower_type: TowerType.Type) -> int:
	var data_path = TOWER_DATA.get(tower_type, "")
	if data_path.is_empty():
		return -1
	
	var tower_data = load(data_path) as TowerData
	if tower_data:
		return tower_data.base_cost
	return -1

static func get_tower_data(tower_type: TowerType.Type) -> TowerData:
	var data_path = TOWER_DATA.get(tower_type, "")
	if data_path.is_empty():
		return null
	
	return load(data_path) as TowerData

static func get_all_tower_types() -> Array[TowerType.Type]:
	return [
		TowerType.Type.ARROW,
		TowerType.Type.BALLISTA,
		TowerType.Type.CANNON,
		TowerType.Type.MAGIC,
		TowerType.Type.FROST,
		TowerType.Type.POISON,
		TowerType.Type.ARMOR_PIERCING,
		TowerType.Type.SUPPORT,
		TowerType.Type.ECONOMY,
		TowerType.Type.ULTIMATE
	]
