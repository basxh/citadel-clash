extends Node3D
class_name GridSystem

## Grid System for Citadel Clash - Build Zones Management
## Handles grid-based building zones along the paths

signal zone_selected(zone: BuildZone)
signal zone_hovered(zone: BuildZone, can_build: bool)
signal zone_state_changed(zone: BuildZone)

@export var grid_size: Vector2 = Vector2(3, 3)
@export var cell_size: float = 5.0
@export var show_debug_gizmos: bool = true

# Build zone data structure
class BuildZone:
    var id: String
    var grid_position: Vector2i
    var world_position: Vector3
    var is_occupied: bool = false
    var occupied_by: Node3D = null
    var team_id: int = -1
    var mesh_instance: MeshInstance3D
    var original_material: Material
    
    func _init(p_id: String, p_grid_pos: Vector2i, p_world_pos: Vector3, p_mesh: MeshInstance3D):
        id = p_id
        grid_position = p_grid_pos
        world_position = p_world_pos
        mesh_instance = p_mesh
        if mesh_instance and mesh_instance.material_override:
            original_material = mesh_instance.material_override.duplicate()
    
    func occupy(entity: Node3D, p_team_id: int):
        is_occupied = true
        occupied_by = entity
        team_id = p_team_id
    
    func free_zone():
        is_occupied = false
        occupied_by = null
        team_id = -1

# Materials
var buildable_material: StandardMaterial3D
var occupied_material: StandardMaterial3D
var invalid_material: StandardMaterial3D
var hover_material: StandardMaterial3D

# Zone storage
var zones: Dictionary = {}  # id -> BuildZone
var team_zones: Dictionary = {}  # team_id -> Array[BuildZone]

# Current state
var selected_zone: BuildZone = null
var hovered_zone: BuildZone = null

func _ready():
    _setup_materials()
    _initialize_zones()
    _assign_zones_to_teams()

func _setup_materials():
    # Green - buildable
    buildable_material = StandardMaterial3D.new()
    buildable_material.albedo_color = Color(0.3, 0.75, 0.3, 0.6)
    buildable_material.roughness = 0.8
    buildable_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    # Red - occupied/enemy
    occupied_material = StandardMaterial3D.new()
    occupied_material.albedo_color = Color(0.75, 0.3, 0.3, 0.8)
    occupied_material.roughness = 0.8
    occupied_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    # Gray - invalid
    invalid_material = StandardMaterial3D.new()
    invalid_material.albedo_color = Color(0.5, 0.5, 0.5, 0.3)
    invalid_material.roughness = 0.9
    invalid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    # Yellow - hover highlight
    hover_material = StandardMaterial3D.new()
    hover_material.albedo_color = Color(1.0, 0.9, 0.3, 0.7)
    hover_material.roughness = 0.5
    hover_material.emission_enabled = true
    hover_material.emission = Color(0.3, 0.27, 0.09, 1)
    hover_material.emission_energy_multiplier = 0.5
    hover_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func _initialize_zones():
    # Find all build zones in scene
    var zone_nodes = get_tree().get_nodes_in_group("build_zones")
    
    for i in range(zone_nodes.size()):
        var mesh = zone_nodes[i] as MeshInstance3D
        if mesh:
            var zone_id = "zone_%d" % i
            var world_pos = mesh.global_position
            var grid_pos = Vector2i(int(world_pos.x / cell_size), int(world_pos.z / cell_size))
            
            var zone = BuildZone.new(zone_id, grid_pos, world_pos, mesh)
            zones[zone_id] = zone
            
            # Store original material
            if mesh.material_override:
                zone.original_material = mesh.material_override.duplicate()

func _assign_zones_to_teams():
    # Assign zones to teams based on their position relative to paths
    team_zones[0] = []  # Player
    team_zones[1] = []  # Enemy 1
    team_zones[2] = []  # Enemy 2
    
    for zone_id in zones:
        var zone = zones[zone_id]
        var pos = zone.world_position
        
        # Path 1 zones (North, negative Z) - Player
        if pos.z < -10:
            team_zones[0].append(zone)
        # Path 2 zones (South-East, positive X and Z) - Enemy 1
        elif pos.x > 5 and pos.z > 5:
            team_zones[1].append(zone)
        # Path 3 zones (South-West, negative X and positive Z) - Enemy 2
        elif pos.x < -5 and pos.z > 5:
            team_zones[2].append(zone)

## Public API

func get_zone_at_position(world_pos: Vector3) -> BuildZone:
    """Find build zone closest to world position"""
    var closest_zone: BuildZone = null
    var closest_dist = cell_size * 1.5
    
    for zone_id in zones:
        var zone = zones[zone_id]
        var dist = world_pos.distance_to(zone.world_position)
        if dist < closest_dist:
            closest_dist = dist
            closest_zone = zone
    
    return closest_zone

func get_team_zones(team_id: int) -> Array:
    """Get all zones assigned to a team"""
    if team_zones.has(team_id):
        return team_zones[team_id].duplicate()
    return []

func can_build_in_zone(zone: BuildZone, team_id: int) -> bool:
    """Check if team can build in this zone"""
    if zone == null:
        return false
    if zone.is_occupied:
        return false
    
    # Check if zone belongs to team
    if team_zones.has(team_id):
        return zone in team_zones[team_id]
    
    return false

func get_buildable_zones(team_id: int) -> Array:
    """Get all zones where team can build"""
    var result = []
    if team_zones.has(team_id):
        for zone in team_zones[team_id]:
            if not zone.is_occupied:
                result.append(zone)
    return result

func occupy_zone(zone: BuildZone, entity: Node3D, team_id: int) -> bool:
    """Mark zone as occupied by entity"""
    if zone == null or zone.is_occupied:
        return false
    
    zone.occupy(entity, team_id)
    _update_zone_visual(zone)
    zone_state_changed.emit(zone)
    return true

func free_zone(zone: BuildZone) -> bool:
    """Free a zone (e.g., when tower is destroyed)"""
    if zone == null or not zone.is_occupied:
        return false
    
    zone.free_zone()
    _update_zone_visual(zone)
    zone_state_changed.emit(zone)
    return true

func highlight_zones(team_id: int, highlight: bool):
    """Highlight all buildable zones for a team"""
    if not team_zones.has(team_id):
        return
    
    for zone in team_zones[team_id]:
        if highlight and not zone.is_occupied:
            zone.mesh_instance.material_override = buildable_material
        else:
            _update_zone_visual(zone)

func highlight_zone_hover(zone: BuildZone, can_build: bool):
    """Highlight zone on hover"""
    if zone == null:
        return
    
    hovered_zone = zone
    
    if can_build:
        zone.mesh_instance.material_override = hover_material
    else:
        zone.mesh_instance.material_override = invalid_material
    
    zone_hovered.emit(zone, can_build)

func clear_hover():
    """Clear hover highlight"""
    if hovered_zone != null:
        _update_zone_visual(hovered_zone)
        hovered_zone = null

func select_zone(zone: BuildZone):
    """Select a zone for building"""
    selected_zone = zone
    zone_selected.emit(zone)

func get_selected_zone() -> BuildZone:
    return selected_zone

func clear_selection():
    selected_zone = null

## Private methods

func _update_zone_visual(zone: BuildZone):
    """Update visual state of zone"""
    if zone.is_occupied:
        zone.mesh_instance.material_override = occupied_material
    else:
        zone.mesh_instance.material_override = zone.original_material

func _draw_debug_gizmos():
    if not show_debug_gizmos:
        return
    
    for zone_id in zones:
        var zone = zones[zone_id]
        var color = Color.GREEN if not zone.is_occupied else Color.RED
        DebugDraw3D.draw_box(zone.world_position, Vector3.ONE * cell_size * 0.8, color, 0.1)

## Signals

func _on_zone_clicked(zone: BuildZone):
    select_zone(zone)

func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        # Raycast to find clicked zone
        var camera = get_viewport().get_camera_3d()
        if camera:
            var mouse_pos = get_viewport().get_mouse_position()
            var from = camera.project_ray_origin(mouse_pos)
            var to = from + camera.project_ray_normal(mouse_pos) * 1000
            
            var space_state = get_world_3d().direct_space_state
            var query = PhysicsRayQueryParameters3D.new()
            query.from = from
            query.to = to
            query.collision_mask = 1
            
            var result = space_state.intersect_ray(query)
            if result:
                var clicked_zone = get_zone_at_position(result.position)
                if clicked_zone:
                    _on_zone_clicked(clicked_zone)

## Process

func _process(delta):
    _draw_debug_gizmos()
    
    # Update hover state
    var camera = get_viewport().get_camera_3d()
    if camera:
        var mouse_pos = get_viewport().get_mouse_position()
        var from = camera.project_ray_origin(mouse_pos)
        var to = from + camera.project_ray_normal(mouse_pos) * 1000
        
        var space_state = get_world_3d().direct_space_state
        var query = PhysicsRayQueryParameters3D.new()
        query.from = from
        query.to = to
        query.collision_mask = 1
        
        var result = space_state.intersect_ray(query)
        if result:
            var hover_zone = get_zone_at_position(result.position)
            if hover_zone != hovered_zone:
                clear_hover()
                if hover_zone:
                    # Assume player team (0) for hover check
                    highlight_zone_hover(hover_zone, can_build_in_zone(hover_zone, 0))
        else:
            clear_hover()
