extends Control
class_name TowerTooltip

## Tooltip UI for displaying tower information

@export var title_label: Label
@export var description_label: Label
@export var stats_container: VBoxContainer
@export var cost_label: Label
@export var upgrade_label: Label

func _ready() -> void:
	visible = false

func show_tower_info(tower_data: TowerData, position: Vector2) -> void:
	if tower_data == null:
		hide()
		return
	
	# Position tooltip
	global_position = position + Vector2(10, 10)
	
	# Set title and description
	if title_label:
		title_label.text = tower_data.tower_name
	
	if description_label:
		description_label.text = tower_data.description
	
	# Build stats string
	if stats_container:
		# Clear existing stats
		for child in stats_container.get_children():
			child.queue_free()
		
		# Add stats
		_add_stat("Damage:", str(int(tower_data.base_damage)))
		_add_stat("Range:", str(int(tower_data.base_range)))
		_add_stat("Fire Rate:", "%.1f/s" % tower_data.base_fire_rate)
		
		# Add special effect info
		if tower_data.special_effect != SpecialEffect.Effect.NONE:
			_add_stat("Effect:", SpecialEffect.get_effect_name(tower_data.special_effect))
		
		# Add category specific info
		if tower_data.category == TowerData.Category.ECONOMY:
			_add_stat("Gold/sec:", "%.1f" % tower_data.gold_per_second)
		elif tower_data.category == TowerData.Category.SUPPORT:
			if tower_data.damage_buff > 0:
				_add_stat("Damage Buff:", "+%d%%" % int(tower_data.damage_buff * 100))
			if tower_data.range_buff > 0:
				_add_stat("Range Buff:", "+%d%%" % int(tower_data.range_buff * 100))
	
	# Set cost
	if cost_label:
		cost_label.text = "Cost: %d Gold" % tower_data.base_cost
	
	# Set upgrade info
	if upgrade_label:
		if tower_data.upgrade_costs.size() > 0:
			upgrade_label.text = "Upgrade: %d Gold" % tower_data.upgrade_costs[0]
		else:
			upgrade_label.text = "Max Level"
	
	visible = true

func _add_stat(name: String, value: String) -> void:
	var hbox = HBoxContainer.new()
	
	var name_label = Label.new()
	name_label.text = name
	name_label.add_theme_color_override("font_color", Color.GRAY)
	
	var value_label = Label.new()
	value_label.text = value
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	hbox.add_child(name_label)
	hbox.add_child(value_label)
	stats_container.add_child(hbox)

func hide_tooltip() -> void:
	visible = false

func update_position(position: Vector2) -> void:
	global_position = position + Vector2(10, 10)
	
	# Keep on screen
	var viewport_size = get_viewport_rect().size
	if global_position.x + size.x > viewport_size.x:
		global_position.x = position.x - size.x - 10
	if global_position.y + size.y > viewport_size.y:
		global_position.y = position.y - size.y - 10
