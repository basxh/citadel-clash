class_name TowerType

enum Type {
	BASIC,
	ARROW,
	BALLISTA,
	CANNON,
	MAGIC,
	FROST,
	POISON,
	ARMOR_PIERCING,
	SUPPORT,
	ECONOMY,
	ULTIMATE
}

static func get_type_name(type: Type) -> String:
	match type:
		Type.ARROW: return "Arrow Tower"
		Type.BALLISTA: return "Ballista Tower"
		Type.CANNON: return "Cannon Tower"
		Type.MAGIC: return "Magic Tower"
		Type.FROST: return "Frost Tower"
		Type.POISON: return "Poison Tower"
		Type.ARMOR_PIERCING: return "Armor-Piercing Tower"
		Type.SUPPORT: return "Support Tower"
		Type.ECONOMY: return "Economy Tower"
		Type.ULTIMATE: return "Ultimate Tower"
		_: return "Basic Tower"

static func get_type_description(type: Type) -> String:
	match type:
		Type.ARROW: return "Fast firing, low damage. Good against light units."
		Type.BALLISTA: return "Heavy projectile with piercing damage. Armor penetrating."
		Type.CANNON: return "Splash damage on impact. Great for groups."
		Type.MAGIC: return "High single-target damage, ignores armor."
		Type.FROST: return "Slows enemies. Minimal damage but great utility."
		Type.POISON: return "Damage over time. Stacks with multiple hits."
		Type.ARMOR_PIERCING: return "Bonus damage against armored targets."
		Type.SUPPORT: return "Buffs nearby towers with damage and range."
		Type.ECONOMY: return "Generates passive gold income."
		Type.ULTIMATE: return "Massive damage with laser beam ability."
		_: return "Standard defensive tower."
