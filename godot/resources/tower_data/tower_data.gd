extends Resource
class_name TowerData

## Tower Data Resource - Defines all tower properties and upgrades

# Basic Info
@export var tower_name: String = "Tower"
@export var description: String = "A defensive tower"
@export var tower_type: TowerType.Type = TowerType.Type.BASIC

# Stats
@export var base_damage: float = 25.0
@export var base_range: float = 10.0
@export var base_fire_rate: float = 1.0  # shots per second
@export var projectile_speed: float = 20.0

# Costs
@export var base_cost: int = 50
@export var upgrade_costs: Array[int] = [100, 200, 400]  # 3 upgrade levels

# Upgrade Multipliers (per level)
@export var damage_multiplier: float = 1.3
@export var range_multiplier: float = 1.15
@export var fire_rate_multiplier: float = 1.2

# Visual
@export var base_color: Color = Color.GRAY
@export var upgrade_colors: Array[Color] = [Color.LIGHT_GRAY, Color.GOLD, Color.DEEP_SKY_BLUE]

# Projectile
@export var projectile_type: ProjectileType.Type = ProjectileType.Type.ARROW
@export var projectile_color: Color = Color.YELLOW

# Special Effects
@export var special_effect: SpecialEffect.Effect = SpecialEffect.Effect.NONE
@export var effect_duration: float = 0.0
@export var effect_strength: float = 0.0

# Support/Economy specific
@export var aura_range: float = 0.0
@export var damage_buff: float = 0.0
@export var range_buff: float = 0.0
@export var gold_per_second: float = 0.0

# Flags
@export var can_target_air: bool = false
@export var piercing: bool = false
@export var splash_radius: float = 0.0
@export var armor_piercing: float = 0.0  # percentage of armor ignored

enum Category {
	OFFENSIVE,
	DEFENSIVE,
	SUPPORT,
	ECONOMY
}

@export var category: Category = Category.OFFENSIVE

func get_stats_for_level(level: int) -> Dictionary:
	var multiplier := 1.0
	for i in range(level):
		multiplier *= damage_multiplier
	
	var range_mult := 1.0
	for i in range(level):
		range_mult *= range_multiplier
	
	var rate_mult := 1.0
	for i in range(level):
		rate_mult *= fire_rate_multiplier
	
	return {
		"damage": base_damage * multiplier,
		"range": base_range * range_mult,
		"fire_rate": base_fire_rate * rate_mult
	}

func get_upgrade_cost(level: int) -> int:
	if level < upgrade_costs.size():
		return upgrade_costs[level]
	return -1  # Max level reached

func get_color_for_level(level: int) -> Color:
	if level < upgrade_colors.size():
		return upgrade_colors[level]
	return upgrade_colors[-1] if upgrade_colors.size() > 0 else base_color
