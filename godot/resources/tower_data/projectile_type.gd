class_name ProjectileType

enum Type {
	ARROW,
	BOLT,
	CANNONBALL,
	MAGIC_BOLT,
	ICE_SHARD,
	POISON_DART,
	PIERCING_BOLT,
	LASER_BEAM,
	SUPPORT_AURA,
	GOLD_PARTICLE
}

static func get_mesh_path(type: Type) -> String:
	match type:
		Type.ARROW: return "res://entities/projectiles/projectile_arrow.tscn"
		Type.BOLT: return "res://entities/projectiles/projectile_bolt.tscn"
		Type.CANNONBALL: return "res://entities/projectiles/projectile_cannonball.tscn"
		Type.MAGIC_BOLT: return "res://entities/projectiles/projectile_magic.tscn"
		Type.ICE_SHARD: return "res://entities/projectiles/projectile_ice.tscn"
		Type.POISON_DART: return "res://entities/projectiles/projectile_poison.tscn"
		Type.PIERCING_BOLT: return "res://entities/projectiles/projectile_piercing.tscn"
		Type.LASER_BEAM: return "res://entities/projectiles/projectile_laser.tscn"
		_: return ""

static func get_type_name(type: Type) -> String:
	match type:
		Type.ARROW: return "Arrow"
		Type.BOLT: return "Heavy Bolt"
		Type.CANNONBALL: return "Cannonball"
		Type.MAGIC_BOLT: return "Magic Bolt"
		Type.ICE_SHARD: return "Ice Shard"
		Type.POISON_DART: return "Poison Dart"
		Type.PIERCING_BOLT: return "Piercing Bolt"
		Type.LASER_BEAM: return "Laser"
		Type.SUPPORT_AURA: return "Support"
		Type.GOLD_PARTICLE: return "Gold"
		_: return "Projectile"
