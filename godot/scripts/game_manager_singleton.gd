extends Node

# This is a singleton wrapper that provides easy access to the actual GameManager
# The actual GameManager is an Autoload that handles all game logic

# Forward all common calls to the actual GameManager

const TEAM_PLAYER: int = 0
const TEAM_ENEMY_1: int = 1
const TEAM_ENEMY_2: int = 2
const TEAM_NEUTRAL: int = 3

const TEAM_COLORS: Dictionary = {
	TEAM_PLAYER: Color(0.2, 0.5, 1.0),   # Blue
	TEAM_ENEMY_1: Color(1.0, 0.2, 0.2),  # Red
	TEAM_ENEMY_2: Color(0.2, 1.0, 0.2),  # Green
	TEAM_NEUTRAL: Color(0.5, 0.5, 0.5)    # Gray
}

const COST_UNIT_BASIC: int = 15
const COST_UNIT_FAST: int = 20
const COST_UNIT_TANK: int = 40
const COST_TOWER: int = 60

func _ready() -> void:
	pass

func get_gold(team: int) -> int:
	if has_node("/root/GameManager"):
		return $"/root/GameManager".get_gold(team)
	return 0

func add_gold(team: int, amount: int) -> void:
	if has_node("/root/GameManager"):
		$"/root/GameManager".add_gold(team, amount)

func spend_gold(team: int, amount: int) -> bool:
	if has_node("/root/GameManager"):
		return $"/root/GameManager".spend_gold(team, amount)
	return false

func can_afford(team: int, cost: int) -> bool:
	if has_node("/root/GameManager"):
		return $"/root/GameManager".can_afford(team, cost)
	return false

func is_playing() -> bool:
	if has_node("/root/GameManager"):
		return $"/root/GameManager".is_playing()
	return false

func get_game_time() -> float:
	if has_node("/root/GameManager"):
		return $"/root/GameManager".get_game_time()
	return 0.0

func get_player_base() -> Base:
	if has_node("/root/GameManager"):
		return $"/root/GameManager".get_player_base()
	return null

func register_base(base_node: Base) -> void:
	if has_node("/root/GameManager"):
		$"/root/GameManager".register_base(base_node)

func set_player_base(base_node: Base) -> void:
	if has_node("/root/GameManager"):
		$"/root/GameManager".set_player_base(base_node)

func reset_game() -> void:
	if has_node("/root/GameManager"):
		$"/root/GameManager".reset_game()

func get_remaining_enemy_teams() -> Array[int]:
	if has_node("/root/GameManager"):
		return $"/root/GameManager".get_remaining_enemy_teams()
	return []

# Signals
signal gold_changed(team: int, amount: int)
signal unit_spawned(unit: Unit)
signal unit_died(unit: Unit)
signal game_state_changed(state)
signal base_destroyed(team: int)
