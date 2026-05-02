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
enum GameMode { SKIRMISH, CAMPAIGN, MULTIPLAYER }

# Signals
signal gold_changed(team: int, amount: int)
signal game_state_changed(state: GameState)
signal state_changed(new_state: GameState, old_state: GameState)
signal base_destroyed(team: int)
signal unit_spawned(unit: Unit)
signal unit_died(unit: Unit)
signal difficulty_changed(team: int, difficulty: String)

# Game mode
var current_game_mode: GameMode = GameMode.SKIRMISH

# Game data
var _team_gold: Dictionary = {}
var _income_per_second: float = 3.0
var _income_timer: float = 0.0
var _game_state: GameState = GameState.PLAYING
var _game_time: float = 0.0
var _active_bases: Dictionary = {}
var _player_base: Base = null

# Unit costs
const COST_UNIT_BASIC: int = 15
const COST_UNIT_FAST: int = 20
const COST_UNIT_TANK: int = 40
const COST_TOWER: int = 60

# Income settings
const BASE_INCOME: int = 3
const INCOME_GROWTH_RATE: float = 0.15  # Income grows by 15% per minute
const STARTING_GOLD: int = 80

# Difficulty multipliers
var _enemy_difficulty: Dictionary = {
	TEAM_ENEMY_1: "normal",
	TEAM_ENEMY_2: "normal"
}

func _ready() -> void:
	# Initialize gold for all teams
	for team in [TEAM_PLAYER, TEAM_ENEMY_1, TEAM_ENEMY_2]:
		_team_gold[team] = STARTING_GOLD
	
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
	# Calculate growing income based on game time
	var current_income = _income_per_second + (_game_time / 60.0) * INCOME_GROWTH_RATE * BASE_INCOME
	for team in _team_gold.keys():
		add_gold(team, int(current_income))

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
	var old_state = _game_state
	_game_state = state
	game_state_changed.emit(state)
	state_changed.emit(state, old_state)
	print("Game Over! State: " + str(state))

func start_game(mode: GameMode) -> void:
	current_game_mode = mode
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func resume_game() -> void:
	if _game_state == GameState.PAUSED:
		var old_state = _game_state
		_game_state = GameState.PLAYING
		state_changed.emit(_game_state, old_state)
		game_state_changed.emit(_game_state)

func reset_game() -> void:
	_game_state = GameState.PLAYING
	_game_time = 0.0
	_income_timer = 0.0
	_income_per_second = BASE_INCOME
	_active_bases.clear()
	_player_base = null
	for team in [TEAM_PLAYER, TEAM_ENEMY_1, TEAM_ENEMY_2]:
		_team_gold[team] = STARTING_GOLD
	
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

func set_enemy_difficulty(team: int, difficulty: String) -> void:
	if team in _enemy_difficulty:
		_enemy_difficulty[team] = difficulty
		difficulty_changed.emit(team, difficulty)

func get_enemy_difficulty(team: int) -> String:
	return _enemy_difficulty.get(team, "normal")

func get_difficulty_multiplier(team: int) -> float:
	var diff = get_enemy_difficulty(team)
	match diff:
		"easy": return 0.7
		"normal": return 1.0
		"hard": return 1.4
		_: return 1.0
