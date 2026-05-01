extends Node

# Game Manager - Autoload Singleton for Game State
# Handles: Game state, resources, victory conditions, scoring

enum GameState {
    MENU,
    LOADING,
    PLAYING,
    PAUSED,
    GAME_OVER,
    VICTORY
}

enum GameMode {
    SKIRMISH,
    CAMPAIGN,
    MULTIPLAYER
}

# Current state
var current_state: GameState = GameState.MENU
var current_mode: GameMode = GameMode.SKIRMISH

# Resources
var resources: Dictionary = {
    "gold": 1000,
    "wood": 500,
    "stone": 300,
    "food": 200
}

# Game settings
var game_settings: Dictionary = {
    "starting_resources": 1000,
    "population_limit": 100,
    "difficulty": "normal"
}

# Multiplayer
var is_multiplayer: bool = false
var local_player_id: int = 1

# Signals
signal state_changed(new_state: GameState, old_state: GameState)
signal resources_updated(resource_type: String, amount: int, total: int)
signal game_over(victory: bool, stats: Dictionary)
signal game_started(mode: GameMode, settings: Dictionary)

func _ready():
    print("GameManager initialized")
    process_mode = Node.PROCESS_MODE_ALWAYS

func change_state(new_state: GameState):
    if new_state == current_state:
        return
    
    var old_state = current_state
    current_state = new_state
    
    match new_state:
        GameState.PLAYING:
            _on_game_start()
        GameState.PAUSED:
            _on_game_pause()
        GameState.GAME_OVER:
            _on_game_over(false)
        GameState.VICTORY:
            _on_game_over(true)
    
    state_changed.emit(new_state, old_state)
    print("Game state changed: %s -> %s" % [_state_to_string(old_state), _state_to_string(new_state)])

func start_game(mode: GameMode = GameMode.SKIRMISH, settings: Dictionary = {}):
    current_mode = mode
    is_multiplayer = (mode == GameMode.MULTIPLAYER)
    
    # Merge settings with defaults
    for key in settings:
        game_settings[key] = settings[key]
    
    # Initialize resources
    _initialize_resources()
    
    change_state(GameState.PLAYING)
    game_started.emit(mode, game_settings)

func pause_game():
    if current_state == GameState.PLAYING:
        change_state(GameState.PAUSED)
        get_tree().paused = true

func resume_game():
    if current_state == GameState.PAUSED:
        get_tree().paused = false
        change_state(GameState.PLAYING)

func end_game(victory: bool = false):
    if victory:
        change_state(GameState.VICTORY)
    else:
        change_state(GameState.GAME_OVER)

func add_resources(type: String, amount: int):
    if resources.has(type):
        resources[type] += amount
        resources_updated.emit(type, amount, resources[type])

func spend_resources(type: String, amount: int) -> bool:
    if not resources.has(type) or resources[type] < amount:
        return false
    
    resources[type] -= amount
    resources_updated.emit(type, -amount, resources[type])
    return true

func can_afford(costs: Dictionary) -> bool:
    for type in costs:
        if not resources.has(type) or resources[type] < costs[type]:
            return false
    return true

func get_resource(type: String) -> int:
    return resources.get(type, 0)

func _initialize_resources():
    resources["gold"] = game_settings.starting_resources
    resources["wood"] = game_settings.starting_resources / 2
    resources["stone"] = game_settings.starting_resources / 3
    resources["food"] = game_settings.starting_resources / 5

func _on_game_start():
    print("Game started in mode: %s" % _mode_to_string(current_mode))

func _on_game_pause():
    print("Game paused")

func _on_game_over(victory: bool):
    var stats = {
        "duration": 0,  # TODO: Track game duration
        "resources_gathered": resources.duplicate(),
        "victory": victory
    }
    game_over.emit(victory, stats)
    print("Game over. Victory: %s" % victory)

func _state_to_string(state: GameState) -> String:
    match state:
        GameState.MENU: return "MENU"
        GameState.LOADING: return "LOADING"
        GameState.PLAYING: return "PLAYING"
        GameState.PAUSED: return "PAUSED"
        GameState.GAME_OVER: return "GAME_OVER"
        GameState.VICTORY: return "VICTORY"
        _: return "UNKNOWN"

func _mode_to_string(mode: GameMode) -> String:
    match mode:
        GameMode.SKIRMISH: return "SKIRMISH"
        GameMode.CAMPAIGN: return "CAMPAIGN"
        GameMode.MULTIPLAYER: return "MULTIPLAYER"
        _: return "UNKNOWN"