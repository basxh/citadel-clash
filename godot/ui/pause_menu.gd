extends Control

# Pause Menu

func _ready():
    visible = false
    GameManager.state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(new_state, old_state):
    visible = (new_state == GameManager.GameState.PAUSED)

func _on_resume_pressed():
    GameManager.resume_game()

func _on_settings_pressed():
    print("Settings - TODO")

func _on_save_pressed():
    print("Save game - TODO")

func _on_main_menu_pressed():
    GameManager.resume_game()
    get_tree().change_scene_to_file("res://ui/main_menu.tscn")