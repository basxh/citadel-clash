extends Node3D
class_name PathSystem

## Path System for Citadel Clash - Unit Movement Paths
## Manages waypoints and navigation between spawn and castles

signal path_completed(unit: Node3D)
signal waypoint_reached(unit: Node3D, waypoint_index: int)

@export var debug_draw_paths: bool = true
@export var waypoint_height_offset: float = 0.5

# Path data for each lane (0 = player/defender, 1-2 = enemies)
var paths: Dictionary = {}
var path_visualizers: Dictionary = {}

# Path colors for visualization
const PATH_COLORS = {
    0: Color(0.3, 0.6, 1.0),  # Blue - Player path
    1: Color(1.0, 0.3, 0.3),  # Red - Enemy 1
    2: Color(0.3, 1.0, 0.3),  # Green - Enemy 2
}

func _ready():
    _initialize_paths()
    _setup_path_visualization()

func _initialize_paths():
    """Initialize the three paths from spawn to each castle"""
    
    # Path 0: Center Spawn -> North Castle (Player base)
    paths[0] = [
        Vector3(0, waypoint_height_offset, 0),           # Spawn center
        Vector3(0, waypoint_height_offset, -10),           # Path start
        Vector3(0, waypoint_height_offset, -25),           # Corner/turn
        Vector3(0, waypoint_height_offset, -40),           # Mid path
        Vector3(0, waypoint_height_offset, -55),           # Castle approach
        Vector3(0, waypoint_height_offset, -60),           # Castle entrance
    ]
    
    # Path 1: Center Spawn -> South-East Castle (Enemy 1)
    paths[1] = [
        Vector3(0, waypoint_height_offset, 0),             # Spawn center
        Vector3(6.5, waypoint_height_offset, 11.25),        # Path start (rotated 60 deg)
        Vector3(21.65, waypoint_height_offset, 22.5),       # Corner
        Vector3(38.97, waypoint_height_offset, 45),         # Mid path
        Vector3(48.0, waypoint_height_offset, 52.5),        # Castle approach
        Vector3(51.96, waypoint_height_offset, 60),       # Castle entrance
    ]
    
    # Path 2: Center Spawn -> South-West Castle (Enemy 2)
    paths[2] = [
        Vector3(0, waypoint_height_offset, 0),             # Spawn center
        Vector3(-6.5, waypoint_height_offset, 11.25),       # Path start (rotated -60 deg)
        Vector3(-21.65, waypoint_height_offset, 22.5),      # Corner
        Vector3(-38.97, waypoint_height_offset, 45),        # Mid path
        Vector3(-48.0, waypoint_height_offset, 52.5),       # Castle approach
        Vector3(-51.96, waypoint_height_offset, 60),        # Castle entrance
    ]

func _setup_path_visualization():
    """Create visual markers for path waypoints"""
    if not debug_draw_paths:
        return
    
    for path_id in paths:
        var path = paths[path_id]
        var color = PATH_COLORS[path_id]
        
        # Create debug markers for each waypoint
        for i in range(path.size()):
            var marker = _create_waypoint_marker(path[i], color, i)
            add_child(marker)
            
            # Store for cleanup
            if not path_visualizers.has(path_id):
                path_visualizers[path_id] = []
            path_visualizers[path_id].append(marker)
        
        # Draw path lines
        _draw_path_lines(path_id)

func _create_waypoint_marker(pos: Vector3, color: Color, index: int) -> MeshInstance3D:
    """Create a visual marker for a waypoint - ENHANCED VISIBILITY"""
    var mesh_instance = MeshInstance3D.new()
    
    var cylinder = CylinderMesh.new()
    # LARGER markers for better visibility
    cylinder.top_radius = 0.8
    cylinder.bottom_radius = 0.8
    cylinder.height = 0.3
    
    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy_multiplier = 1.0
    
    mesh_instance.mesh = cylinder
    mesh_instance.material_override = material
    mesh_instance.cast_shadow = false
    mesh_instance.position = pos
    mesh_instance.name = "Waypoint_%d" % index
    
    return mesh_instance

func _draw_path_lines(path_id: int):
    """Draw lines connecting waypoints - ENHANCED VISIBILITY"""
    var path = paths[path_id]
    var color = PATH_COLORS[path_id]
    
    for i in range(path.size() - 1):
        # Draw thicker, more visible lines
        var line = _create_path_line(path[i], path[i + 1], color)
        add_child(line)
        path_visualizers[path_id].append(line)
        
        # Add a second line slightly above for visibility
        var line_glow = _create_path_line(path[i] + Vector3.UP * 0.05, path[i + 1] + Vector3.UP * 0.05, Color.WHITE)
        line_glow.scale = Vector3(0.5, 0.5, 1.0)
        add_child(line_glow)
        path_visualizers[path_id].append(line_glow)

func _create_path_line(start: Vector3, end: Vector3, color: Color) -> MeshInstance3D:
    """Create a line mesh between two points - ENHANCED VISIBILITY"""
    var mesh_instance = MeshInstance3D.new()
    
    var distance = start.distance_to(end)
    var box = BoxMesh.new()
    # THICKER lines for better visibility
    box.size = Vector3(0.8, 0.15, distance)
    
    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy_multiplier = 0.8
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_color.a = 0.7
    
    mesh_instance.mesh = box
    mesh_instance.material_override = material
    mesh_instance.cast_shadow = false
    
    # Position and rotate to connect points
    mesh_instance.position = (start + end) / 2.0
    mesh_instance.look_at(end, Vector3.UP)
    mesh_instance.rotate_object_local(Vector3.RIGHT, PI / 2)
    
    return mesh_instance

## Public API

func get_path(path_id: int) -> Array:
    """Get waypoints for a specific path"""
    if paths.has(path_id):
        return paths[path_id].duplicate()
    return []

func get_next_waypoint(path_id: int, current_index: int) -> Vector3:
    """Get the next waypoint for a unit on a path"""
    if not paths.has(path_id):
        return Vector3.ZERO
    
    var path = paths[path_id]
    if current_index < 0 or current_index >= path.size():
        return Vector3.ZERO
    
    if current_index + 1 < path.size():
        return path[current_index + 1]
    
    return path[path.size() - 1]

func get_start_position(path_id: int) -> Vector3:
    """Get the spawn position for units on this path"""
    if paths.has(path_id) and paths[path_id].size() > 0:
        return paths[path_id][0]
    return Vector3.ZERO

func get_end_position(path_id: int) -> Vector3:
    """Get the target/castle position for this path"""
    if paths.has(path_id) and paths[path_id].size() > 0:
        return paths[path_id][paths[path_id].size() - 1]
    return Vector3.ZERO

func get_waypoint_count(path_id: int) -> int:
    """Get number of waypoints for a path"""
    if paths.has(path_id):
        return paths[path_id].size()
    return 0

func get_path_for_team(team_id: int) -> int:
    """Get the path ID for a team"""
    # Team 0 (Player) defends path 0
    # Team 1 attacks along path 1
    # Team 2 attacks along path 2
    return team_id

func get_target_path_for_team(team_id: int) -> int:
    """Get which path leads to a team's base"""
    # Each team defends their own path
    return team_id

func get_attack_path_for_team(team_id: int) -> Array:
    """Get paths that lead to enemy bases"""
    var attack_paths = []
    for i in range(3):
        if i != team_id:
            attack_paths.append(i)
    return attack_paths

func is_path_complete(path_id: int, current_waypoint_index: int) -> bool:
    """Check if unit has reached the end of the path"""
    if not paths.has(path_id):
        return true
    return current_waypoint_index >= paths[path_id].size() - 1

func get_distance_along_path(path_id: int, from_index: int, to_index: int) -> float:
    """Get total distance between two waypoints"""
    if not paths.has(path_id):
        return 0.0
    
    var path = paths[path_id]
    var distance = 0.0
    
    for i in range(from_index, min(to_index, path.size() - 1)):
        distance += path[i].distance_to(path[i + 1])
    
    return distance

func get_closest_waypoint(path_id: int, world_pos: Vector3) -> int:
    """Find the closest waypoint to a world position"""
    if not paths.has(path_id):
        return -1
    
    var path = paths[path_id]
    var closest_idx = 0
    var closest_dist = world_pos.distance_squared_to(path[0])
    
    for i in range(1, path.size()):
        var dist = world_pos.distance_squared_to(path[i])
        if dist < closest_dist:
            closest_dist = dist
            closest_idx = i
    
    return closest_idx

func get_position_on_path(path_id: int, progress: float) -> Vector3:
    """Get interpolated position along path (0.0 to 1.0)"""
    if not paths.has(path_id):
        return Vector3.ZERO
    
    var path = paths[path_id]
    var total_segments = path.size() - 1
    var segment_progress = progress * total_segments
    var segment_idx = int(segment_progress)
    var local_progress = segment_progress - segment_idx
    
    if segment_idx >= total_segments:
        return path[path.size() - 1]
    
    return path[segment_idx].lerp(path[segment_idx + 1], local_progress)

func get_opposing_team(team_id: int) -> int:
    """Get the team that attacks this team's base"""
    # In a 3-way setup, this is more complex
    # For now, return the "next" team
    return (team_id + 1) % 3

## Navigation helpers

func calculate_move_direction(unit_pos: Vector3, target_waypoint: Vector3) -> Vector3:
    """Calculate normalized direction vector to next waypoint"""
    var direction = target_waypoint - unit_pos
    direction.y = 0  # Keep movement on ground plane
    return direction.normalized()

func calculate_distance_to_waypoint(unit_pos: Vector3, waypoint: Vector3) -> float:
    """Calculate flat distance to waypoint"""
    var diff = waypoint - unit_pos
    diff.y = 0
    return diff.length()

func is_near_waypoint(unit_pos: Vector3, waypoint: Vector3, threshold: float = 1.0) -> bool:
    """Check if unit is close enough to waypoint"""
    return calculate_distance_to_waypoint(unit_pos, waypoint) < threshold

func update_unit_path_progress(unit: Node3D, path_id: int, current_waypoint: int) -> int:
    """Update unit's progress along path, return new waypoint index"""
    if is_path_complete(path_id, current_waypoint):
        path_completed.emit(unit)
        return current_waypoint
    
    var path = paths[path_id]
    var target = path[current_waypoint]
    
    if is_near_waypoint(unit.global_position, target):
        waypoint_reached.emit(unit, current_waypoint)
        return current_waypoint + 1
    
    return current_waypoint

## Debug visualization toggle

func set_debug_visualization(enabled: bool):
    """Toggle debug visualization"""
    debug_draw_paths = enabled
    
    for path_id in path_visualizers:
        for visual in path_visualizers[path_id]:
            visual.visible = enabled

## Process

func _process(delta):
    if debug_draw_paths:
        # Update visualizations if needed
        pass
