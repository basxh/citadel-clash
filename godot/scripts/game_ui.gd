extends Control
class_name GameUI

# Constants
const TEAM_PLAYER: int = 0
const COST_UNIT_BASIC: int = 10
const COST_UNIT_FAST: int = 15
const COST_UNIT_TANK: int = 25
const COST_TOWER: int = 50

# References
@onready var _gold_label: Label = %GoldLabel
@onready var _hp_bar: ProgressBar = %HPBar
@onready var _game_timer: Label = %GameTimer
@onready var _unit_buttons: HBoxContainer = %UnitButtons
@onready var _build_button: Button = %BuildTowerButton
@onready var _cancel_button: Button = %CancelButton
@onready var _game_over_panel: Panel = %GameOverPanel
@onready var _game_over_title: Label = %GameOverTitle
@onready var _restart_button: Button = %RestartButton

# State
var _is_building: bool = false

func _ready() -> void:
	_connect_signals()
	_update_ui()
	_game_over_panel.visible = false

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

func _setup_unit_buttons() -> void:
	var basic_btn = %BasicUnitButton
	var fast_btn = %FastUnitButton
	var tank_btn = %TankUnitButton
	
	if basic_btn:
		basic_btn.pressed.connect(func(): _on_buy_unit("basic", COST_UNIT_BASIC))
	if fast_btn:
		fast_btn.pressed.connect(func(): _on_buy_unit("fast", COST_UNIT_FAST))
	if tank_btn:
		tank_btn.pressed.connect(func(): _on_buy_unit("tank", COST_UNIT_TANK))

func _process(_delta: float) -> void:
	_update_timer()
	_update_hp_bar()

func _update_ui() -> void:
	if GameManager:
		_on_gold_changed(TEAM_PLAYER, GameManager.get_gold(TEAM_PLAYER))

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
			_hp_bar.get_node("Label").text = "Base HP: %d/%d" % [int(base.current_health), int(base.max_health)]

func _on_gold_changed(team: int, amount: int) -> void:
	if team == TEAM_PLAYER:
		if _gold_label:
			_gold_label.text = "Gold: %d" % amount
		
		# Update button availability
		_update_button_states()

func _update_button_states() -> void:
	var gold = GameManager.get_gold(TEAM_PLAYER)
	
	var basic_btn = %BasicUnitButton
	var fast_btn = %FastUnitButton
	var tank_btn = %TankUnitButton
	
	if basic_btn:
		basic_btn.disabled = gold < COST_UNIT_BASIC
	if fast_btn:
		fast_btn.disabled = gold < COST_UNIT_FAST
	if tank_btn:
		tank_btn.disabled = gold < COST_UNIT_TANK
	if _build_button:
		_build_button.disabled = gold < COST_TOWER

func _on_buy_unit(unit_type: String, cost: int) -> void:
	if GameManager.spend_gold(TEAM_PLAYER, cost):
		buy_unit_requested.emit(unit_type)

func _on_build_pressed() -> void:
	_is_building = true
	_build_button.visible = false
	_cancel_button.visible = true
	build_mode_toggled.emit(true)

func _on_cancel_pressed() -> void:
	_is_building = false
	_build_button.visible = true
	_cancel_button.visible = false
	build_mode_toggled.emit(false)

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

func is_build_mode() -> bool:
	return _is_building

# Signals
signal buy_unit_requested(unit_type: String)
signal build_mode_toggled(active: bool)
