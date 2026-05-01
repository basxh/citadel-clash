extends Node3D
class_name Building

# Base class for all buildings

@export var building_name: String = "Building"
@export var max_health: float = 500.0
@export var build_time: float = 5.0
@export var is_defensive: bool = false

@export var build_cost: Dictionary = {
    "gold": 100,
    "wood": 50,
    "stone": 0
}

var current_health: float = 500.0
var is_built: bool = false
var build_progress: float = 0.0
var is_selected: bool = false

@onready var health_bar = $HealthBar
@onready var selection_indicator = $SelectionIndicator
@onready var mesh = $MeshInstance3D

func _ready():
    current_health = max_health
    update_health_display()

func start_construction():
    is_built = false
    build_progress = 0.0
    if mesh:
        # Show construction placeholder
        pass

func progress_build(amount: float):
    build_progress += amount
    if build_progress >= build_time:
        complete_construction()

func complete_construction():
    is_built = true
    build_progress = build_time
    print("%s construction complete" % building_name)

func take_damage(amount: float):
    current_health -= amount
    update_health_display()
    
    if current_health <= 0:
        destroy()

func destroy():
    print("%s destroyed" % building_name)
    queue_free()

func set_selected(selected: bool):
    is_selected = selected
    if selection_indicator:
        selection_indicator.visible = selected

func update_health_display():
    if health_bar:
        health_bar.value = (current_health / max_health) * 100.0

func can_afford() -> bool:
    return GameManager.can_afford(build_cost)