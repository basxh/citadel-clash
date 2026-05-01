extends Node

# Network Manager - Autoload Singleton for Multiplayer
# Handles: Connection, lobby, player synchronization

enum NetworkState {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    HOSTING,
    ERROR
}

# Network configuration
const DEFAULT_PORT: int = 7777
const MAX_PLAYERS: int = 8

# State
var current_state: NetworkState = NetworkState.DISCONNECTED
var multiplayer_peer: ENetMultiplayerPeer = null

# Player data
var players: Dictionary = {}  # id -> {name, team, ready}
var local_player_name: String = "Player"
var local_player_team: int = 0

# Signals
signal state_changed(new_state: NetworkState, old_state: NetworkState)
signal player_connected(id: int, player_info: Dictionary)
signal player_disconnected(id: int)
signal connection_failed(error: String)
signal connection_succeeded()
signal server_disconnected()

func _ready():
    print("NetworkManager initialized")
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)

# Host a game
func host_game(port: int = DEFAULT_PORT, max_players: int = MAX_PLAYERS) -> bool:
    if current_state != NetworkState.DISCONNECTED:
        print("Already connected! Disconnect first.")
        return false
    
    multiplayer_peer = ENetMultiplayerPeer.new()
    var error = multiplayer_peer.create_server(port, max_players)
    
    if error != OK:
        print("Failed to create server: %s" % error)
        connection_failed.emit("Failed to create server")
        return false
    
    multiplayer.multiplayer_peer = multiplayer_peer
    _change_state(NetworkState.HOSTING)
    
    # Add host as player
    _register_player(multiplayer.get_unique_id(), local_player_name, local_player_team)
    
    print("Server hosted on port %d" % port)
    return true

# Join a game
func join_game(address: String, port: int = DEFAULT_PORT) -> bool:
    if current_state != NetworkState.DISCONNECTED:
        print("Already connected! Disconnect first.")
        return false
    
    _change_state(NetworkState.CONNECTING)
    
    multiplayer_peer = ENetMultiplayerPeer.new()
    multiplayer_peer.create_client(address, port)
    multiplayer.multiplayer_peer = multiplayer_peer
    
    print("Connecting to %s:%d..." % [address, port])
    return true

# Disconnect from current game
func disconnect_game():
    if multiplayer_peer:
        multiplayer_peer.close()
        multiplayer_peer = null
    
    multiplayer.multiplayer_peer = null
    players.clear()
    _change_state(NetworkState.DISCONNECTED)
    print("Disconnected from game")

# Get local player ID
func get_local_player_id() -> int:
    return multiplayer.get_unique_id() if multiplayer.has_multiplayer_peer() else 1

# Check if we're the server/host
func is_server() -> bool:
    return multiplayer.is_server() if multiplayer.has_multiplayer_peer() else false

# Send player info to server
@rpc(any_peer, reliable)
func _register_player(id: int, player_name: String, team: int):
    players[id] = {
        "name": player_name,
        "team": team,
        "ready": false
    }
    player_connected.emit(id, players[id])
    print("Player registered: %s (ID: %d, Team: %d)" % [player_name, id, team])
    
    # If we're server, broadcast to all clients
    if is_server():
        _sync_players.rpc(players)

# Sync all players (server to clients)
@rpc(reliable)
func _sync_players(server_players: Dictionary):
    players = server_players
    print("Players synced from server")

# Set player ready state
func set_ready(ready: bool):
    var id = get_local_player_id()
    if players.has(id):
        players[id].ready = ready
        _update_ready_state.rpc(id, ready)

@rpc(any_peer, reliable)
func _update_ready_state(id: int, ready: bool):
    if players.has(id):
        players[id].ready = ready

# Callbacks
func _on_peer_connected(id: int):
    print("Peer connected: %d" % id)
    if is_server():
        # Send local player info to new peer
        _register_player.rpc_id(id, get_local_player_id(), local_player_name, local_player_team)

func _on_peer_disconnected(id: int):
    print("Peer disconnected: %d" % id)
    if players.has(id):
        player_disconnected.emit(id)
        players.erase(id)

func _on_connected_to_server():
    print("Connected to server!")
    _change_state(NetworkState.CONNECTED)
    connection_succeeded.emit()
    
    # Register with server
    _register_player.rpc_id(1, get_local_player_id(), local_player_name, local_player_team)

func _on_connection_failed():
    print("Connection failed!")
    _change_state(NetworkState.ERROR)
    connection_failed.emit("Connection failed")

func _on_server_disconnected():
    print("Server disconnected!")
    disconnect_game()
    server_disconnected.emit()

func _change_state(new_state: NetworkState):
    if new_state != current_state:
        var old_state = current_state
        current_state = new_state
        state_changed.emit(new_state, old_state)
        print("Network state: %s" % _state_to_string(new_state))

func _state_to_string(state: NetworkState) -> String:
    match state:
        NetworkState.DISCONNECTED: return "DISCONNECTED"
        NetworkState.CONNECTING: return "CONNECTING"
        NetworkState.CONNECTED: return "CONNECTED"
        NetworkState.HOSTING: return "HOSTING"
        NetworkState.ERROR: return "ERROR"
        _: return "UNKNOWN"