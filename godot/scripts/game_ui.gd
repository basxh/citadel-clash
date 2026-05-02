extends Control
class_name GameUI

# References
@onready var _gold_label: Label = %GoldLabel
@onready var _hp_bar: ProgressBar = %HPBar
@onready var _game_timer: Label = %GameTimer
@onready var _build_button: Button = %BuildTowerButton
@onready var _cancel_button: Button = %CancelButton
@onready var _game_over_panel: Panel = %GameOverPanel
@onready var _game_over_title: Label = %GameOverTitle
@onready var _restart_button: Button = %RestartButton
@onready var _message_label: Label = %MessageLabel
@onready var _entity_info_panel: Panel = %EntityInfoPanel
@onready var _difficulty_menu: PopupMenu = %DifficultyMenu

# State
var _is_building: bool = false
var _message_timer: Timer = null
var _target_team: int = 1  # Default target is Enemy 1

func _ready() -> void:
	_connect_signals()
	_update_ui()
	_game_over_panel.visible = false
	_entity_info_panel.visible = false
	
	# Create message timer
	_message_timer = Timer.new()
	_message_timer.one_shot = true
	_message_timer.timeout.connect(_hide_message)
	add_child(_message_timer)

func _connect_signals() -> void:
	# GameManager signals
	if GameManager:
		GameManager.gold_changed.connect(_on_gold_changed)
		GameManager.game_state_changed.connect(_on_game_state_changed)
	
	# Button signals
	if _build_button:
		_build_button.pressed.connect(_on_build_pressed)
	if _cancel_button:
		_cancel_button.pressed.connect(_on_cancel_pressed)
		_cancel_button.visible = false
	if _restart_button:
		_restart_button.pressed.connect(_on_restart_pressed)
	
	# Unit buttons
	_setup_unit_buttons()
	
	# Difficulty menu
	_setup_difficulty_menu()

func _setup_unit_buttons() -> void:
	var basic_btn = %BasicUnitButton
	var fast_btn = %FastUnitButton
	var tank_btn = %TankUnitButton
	
	if basic_btn:
		basic_btn.pressed.connect(func(): _on_buy_unit("basic", GameManager.COST_UNIT_BASIC, _target_team))
	if fast_btn:
		fast_btn.pressed.connect(func(): _on_buy_unit("fast", GameManager.COST_UNIT_FAST, _target_team))
	if tank_btn:
		tank_btn.pressed.connect(func(): _on_buy_unit("tank", GameManager.COST_UNIT_TANK, _target_team))
	
	# Setup target selection buttons
	_setup_target_buttons()

func _setup_target_buttons() -> void:
	var target_e1_btn = %TargetEnemy1Button
	var target_e2_btn = %TargetEnemy2Button
	
	if target_e1_btn:
		target_e1_btn.pressed.connect(func(): _set_target_team(1))
		_update_target_button_style(target_e1_btn, true)
	if target_e2_btn:
		target_e2_btn.pressed.connect(func(): _set_target_team(2))
		_update_target_button_style(target_e2_btn, false)

func _set_target_team(team: int) -> void:
	_target_team = team
	
	var target_e1_btn = %TargetEnemy1Button
	var target_e2_btn = %TargetEnemy2Button
	
	if target_e1_btn:
		_update_target_button_style(target_e1_btn, team == 1)
	if target_e2_btn:
		_update_target_button_style(target_e2_btn, team == 2)
	
	show_message("Target: Enemy " + str(team), 1.0)

func _update_target_button_style(button: Button, is_active: bool) -> void:
	if is_active:
		button.modulate = Color(1.2, 1.2, 1.2)  # Highlight
	else:
		button.modulate = Color(1, 1, 1)  # Normal

func _setup_difficulty_menu() -> void:
	if _difficulty_menu:
		_difficulty_menu.clear()
		_difficulty_menu.add_item("Easy", 0)
		_difficulty_menu.add_item("Normal", 1)
		_difficulty_menu.add_item("Hard", 2)
		_difficulty_menu.index_pressed.connect(_on_difficulty_selected)
	
	var difficulty_btn = %DifficultyButton
	if difficulty_btn:
		difficulty_btn.pressed.connect(_show_difficulty_menu)

func _show_difficulty_menu() -> void:
	if _difficulty_menu:
		_difficulty_menu.popup(Rect2i(get_viewport().get_mouse_position(), Vector2i(120, 90)))

func _on_difficulty_selected(index: int) -> void:
	var difficulties = ["easy", "normal", "hard"]
	if index >= 0 and index < difficulties.size():
		# Apply to enemy team 1
		difficulty_selected.emit(GameManager.TEAM_ENEMY_1, difficulties[index])
		show_message("Difficulty set to " + difficulties[index].capitalize())

func _process(_delta: float) -> void:
	_update_timer()
	_update_hp_bar()
	_update_button_states()

func _update_ui() -> void:
	if GameManager:
		_on_gold_changed(GameManager.TEAM_PLAYER, GameManager.get_gold(GameManager.TEAM_PLAYER))

func _update_timer() -> void:
	if GameManager:
		var time = int(GameManager.get_game_time())
		var minutes = time / 60
		var seconds = time % 60
		if _game_timer:
			_game_timer.text = "%02d:%02d" % [minutes, seconds]

func _update_hp_bar() -> void:
	if GameManager and GameManager.get_player_base():
		var base = GameManager.get_player_base()
		if _hp_bar and base:
			_hp_bar.max_value = base.max_health
			_hp_bar.value = base.current_health
			var label = _hp_bar.get_node_or_null("Label")
			if label:
				label.text = "Base HP: %d/%d" % [int(base.current_health), int(base.max_health)]

func _on_gold_changed(team: int, amount: int) -> void:
	if team == GameManager.TEAM_PLAYER:
		if _gold_label:
			_gold_label.text = "Gold: %d" % amount

func _update_button_states() -> void:
	var gold = GameManager.get_gold(GameManager.TEAM_PLAYER)
	
	var basic_btn = %BasicUnitButton
	var fast_btn = %FastUnitButton
	var tank_btn = %TankUnitButton
	
	if basic_btn:
		basic_btn.disabled = gold < GameManager.COST_UNIT_BASIC
	if fast_btn:
		fast_btn.disabled = gold < GameManager.COST_UNIT_FAST
	if tank_btn:
		tank_btn.disabled = gold < GameManager.COST_UNIT_TANK
	if _build_button:
		_build_button.disabled = gold < GameManager.COST_TOWER or _is_building
	if _cancel_button:
		_cancel_button.visible = _is_building

func _on_buy_unit(unit_type: String, cost: int, target_team: int = 1) -> void:
	if GameManager.can_afford(GameManager.TEAM_PLAYER, cost):
		if GameManager.spend_gold(GameManager.TEAM_PLAYER, cost):
			# Include target team in the signal
			buy_unit_requested_with_target.emit(unit_type, target_team)
			buy_unit_requested.emit(unit_type)
	else:
		show_message("Not enough gold!")

func _on_build_pressed() -> void:
	_is_building = true
	build_mode_toggled.emit(true)
	_update_button_states()

func _on_cancel_pressed() -> void:
	_is_building = false
	build_mode_toggled.emit(false)
	_update_button_states()

func _on_restart_pressed() -> void:
	if GameManager:
		GameManager.reset_game()

func _on_game_state_changed(state) -> void:
	match state:
		GameManager.GameState.VICTORY:
			_show_game_over("VICTORY!", Color.GREEN)
		GameManager.GameState.DEFEAT:
			_show_game_over("DEFEAT!", Color.RED)
		GameManager.GameState.PAUSED:
			pass
		GameManager.GameState.PLAYING:
			_game_over_panel.visible = false

func _show_game_over(title: String, color: Color) -> void:
	if _game_over_panel:
		_game_over_panel.visible = true
	if _game_over_title:
		_game_over_title.text = title
		_game_over_title.modulate = color

func set_build_mode(active: bool) -> void:
	_is_building = active
	_update_button_states()

func is_build_mode() -> bool:
	return _is_building

func show_message(text: String, duration: float = 2.0) -> void:
	if _message_label:
		_message_label.text = text
		_message_label.visible = true
		_message_timer.start(duration)

func _hide_message() -> void:
	if _message_label:
		_message_label.visible = false

func show_entity_info(info: Dictionary) -> void:
	var info_label = %EntityInfoLabel
	if info_label and _entity_info_panel:
		var text = ""
		if info.has("type"):
			if info["type"] == "tower":
				text = "Tower\n"
				text += "Range: %.1f\n" % info.get("range", 0)
				text += "Damage: %.1f\n" % info.get("damage", 0)
				text += "Fire Rate: %.1f/s" % info.get("fire_rate", 0)
			else:
				text = "Unit: %s\n" % info["type"].capitalize()
				text += "Health: %.0f/%.0f\n" % [info.get("health", 0), info.get("max_health", 1)]
				text += "Damage: %.1f\n" % info.get("damage", 0)
				text += "Speed: %.1f" % info.get("speed", 0)
		
		info_label.text = text
		_entity_info_panel.visible = true

func hide_entity_info() -> void:
	if _entity_info_panel:
		_entity_info_panel.visible = false

# Signals
signal buy_unit_requested(unit_type: String)
signal buy_unit_requested_with_target(unit_type: String, target_team: int)
signal build_mode_toggled(active: bool)
signal difficulty_selected(team: int, difficulty: String)
