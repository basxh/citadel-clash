extends Control

# Main Menu Script

func _ready():
    print("Main menu loaded")

func _on_skirmish_button_pressed():
    print("Starting skirmish mode...")
    GameManager.start_game(GameManager.GameMode.SKIRMISH)
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_campaign_button_pressed():
    print("Campaign mode - not implemented yet")
    # TODO: Show campaign selection or start first mission

func _on_multiplayer_button_pressed():
    print("Multiplayer menu...")
    # TODO: Show multiplayer lobby
    var lobby_scene = load("res://ui/multiplayer_lobby.tscn")
    if lobby_scene:
        get_tree().change_scene_to_packed(lobby_scene)

func _on_settings_button_pressed():
    print("Settings menu...")
    # TODO: Show settings panel

func _on_quit_button_pressed():
    print("Quitting game...")
    get_tree().quit()