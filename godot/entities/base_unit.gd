extends Node3D
class_name BaseUnit

# Base class for all units

@export var unit_name: String = "Unit"
@export var max_health: float = 100.0
@export var move_speed: float = 5.0
@export var attack_damage: float = 10.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.0

var current_health: float = 100.0
var is_alive: bool = true
var target: Node3D = null
var is_selected: bool = false

@onready var health_bar = $HealthBar
@onready var selection_indicator = $SelectionIndicator

func _ready():
    current_health = max_health
    update_health_display()

func take_damage(amount: float):
    current_health -= amount
    update_health_display()
    
    if current_health <= 0:
        die()

func heal(amount: float):
    current_health = min(current_health + amount, max_health)
    update_health_display()

func die():
    is_alive = false
    print("%s died" % unit_name)
    queue_free()

func set_selected(selected: bool):
    is_selected = selected
    if selection_indicator:
        selection_indicator.visible = selected

func update_health_display():
    if health_bar:
        health_bar.value = (current_health / max_health) * 100.0

func move_to(position: Vector3):
    # Override in subclasses for actual movement
    pass

func attack_target(target_unit: Node3D):
    # Override in subclasses for attack logic
    pass