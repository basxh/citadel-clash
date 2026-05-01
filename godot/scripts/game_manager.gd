extends Node

# Team constants
const TEAM_PLAYER: int = 0
const TEAM_ENEMY_1: int = 1
const TEAM_ENEMY_2: int = 2
const TEAM_NEUTRAL: int = 3

# Team colors
const TEAM_COLORS: Dictionary = {
	TEAM_PLAYER: Color(0.2, 0.5, 1.0),   # Blue
	TEAM_ENEMY_1: Color(1.0, 0.2, 0.2),  # Red
	TEAM_ENEMY_2: Color(0.2, 1.0, 0.2),  # Green
	TEAM_NEUTRAL: Color(0.5, 0.5, 0.5)    # Gray
}

# Game state
enum GameState { PLAYING, PAUSED, VICTORY, DEFEAT }

# Signals
signal gold_changed(team: int, amount: int)
signal game_state_changed(state: GameState)
signal base_destroyed(team: int)
signal unit_spawned(unit: Unit)
signal unit_died(unit: Unit)

# Game data
var _team_gold: Dictionary = {}
var _income_per_second: float = 5.0
var _income_timer: float = 0.0
var _game_state: GameState = GameState.PLAYING
var _game_time: float = 0.0
var _active_bases: Dictionary = {}
var _player_base: Base = null

# Unit costs
const COST_UNIT_BASIC: int = 10
const COST_UNIT_FAST: int = 15
const COST_UNIT_TANK: int = 25
const COST_TOWER: int = 50

func _ready() -> void:
	# Initialize gold for all teams
	for team in [TEAM_PLAYER, TEAM_ENEMY_1, TEAM_ENEMY_2]:
		_team_gold[team] = 100
	
	print("GameManager initialized")

func _process(delta: float) -> void:
	if _game_state != GameState.PLAYING:
		return
	
	_game_time += delta
	
	# Passive income
	_income_timer += delta
	if _income_timer >= 1.0:
		_income_timer -= 1.0
		_distribute_income()

func _distribute_income() -> void:
	for team in _team_gold.keys():
		add_gold(team, int(_income_per_second))

func get_gold(team: int) -> int:
	return _team_gold.get(team, 0)

func add_gold(team: int, amount: int) -> void:
	if amount <= 0:
		return
	_team_gold[team] = _team_gold.get(team, 0) + amount
	gold_changed.emit(team, _team_gold[team])

func spend_gold(team: int, amount: int) -> bool:
	if get_gold(team) >= amount:
		_team_gold[team] -= amount
		gold_changed.emit(team, _team_gold[team])
		return true
	return false

func can_afford(team: int, cost: int) -> bool:
	return get_gold(team) >= cost

func get_game_state() -> GameState:
	return _game_state

func get_game_time() -> float:
	return _game_time

func set_player_base(base_node: Base) -> void:
	_player_base = base_node

func get_player_base() -> Base:
	return _player_base

func register_base(base_node: Base) -> void:
	_active_bases[base_node.team_id] = base_node
	base_node.destroyed.connect(_on_base_destroyed)

func _on_base_destroyed(team: int) -> void:
	base_destroyed.emit(team)
	_active_bases.erase(team)
	
	if team == TEAM_PLAYER:
		_set_game_over(GameState.DEFEAT)
	elif _active_bases.size() == 1 and _active_bases.has(TEAM_PLAYER):
		_set_game_over(GameState.VICTORY)

func _set_game_over(state: GameState) -> void:
	_game_state = state
	game_state_changed.emit(state)
	print("Game Over! State: " + str(state))

func reset_game() -> void:
	_game_state = GameState.PLAYING
	_game_time = 0.0
	_income_timer = 0.0
	_active_bases.clear()
	_player_base = null
	for team in [TEAM_PLAYER, TEAM_ENEMY_1, TEAM_ENEMY_2]:
		_team_gold[team] = 100
	
	# Reload scene
	get_tree().reload_current_scene()

func is_playing() -> bool:
	return _game_state == GameState.PLAYING

func get_remaining_enemy_teams() -> Array[int]:
	var enemies: Array[int] = []
	for team in _active_bases.keys():
		if team != TEAM_PLAYER:
			enemies.append(team)
	return enemies

func get_random_enemy_team() -> int:
	var enemies = get_remaining_enemy_teams()
	if enemies.is_empty():
		return TEAM_NEUTRAL
	return enemies[randi() % enemies.size()]
