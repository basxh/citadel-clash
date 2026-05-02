class_name SpecialEffect

enum Effect {
	NONE,
	SLOW,
	POISON,
	SPLASH,
	PIERCING,
	MAGIC_DAMAGE,
	ARMOR_PIERCE,
	BUFF_DAMAGE,
	BUFF_RANGE,
	INCOME,
	LASER
}

static func get_effect_name(effect: Effect) -> String:
	match effect:
		Effect.SLOW: return "Slow"
		Effect.POISON: return "Poison"
		Effect.SPLASH: return "Splash"
		Effect.PIERCING: return "Piercing"
		Effect.MAGIC_DAMAGE: return "Magic Damage"
		Effect.ARMOR_PIERCE: return "Armor Pierce"
		Effect.BUFF_DAMAGE: return "Damage Buff"
		Effect.BUFF_RANGE: return "Range Buff"
		Effect.INCOME: return "Gold Income"
		Effect.LASER: return "Laser"
		_: return ""

static func get_effect_description(effect: Effect) -> String:
	match effect:
		Effect.SLOW: return "Reduces movement speed"
		Effect.POISON: return "Deals damage over time"
		Effect.SPLASH: return "Damages nearby enemies"
		Effect.PIERCING: return "Passes through multiple targets"
		Effect.MAGIC_DAMAGE: return "Ignores armor"
		Effect.ARMOR_PIERCE: return "Bonus vs armored units"
		Effect.BUFF_DAMAGE: return "Increases tower damage"
		Effect.BUFF_RANGE: return "Increases tower range"
		Effect.INCOME: return "Generates gold"
		Effect.LASER: return "Continuous beam damage"
		_: return ""
