# patrol_state.gd
extends State

@export var waypoint_reach_radius: float = 15.0

var current_waypoint_index: int = 0
var waypoints: Array[Vector2] = []

# Kept so bicho_papao.gd's _sync_patrol_waypoint_index() keeps working.
# enter() now overrides this with the closest waypoint, so it can be removed
# along with that call in the monster script.
func set_current_waypoint_index(index: int) -> void:
	current_waypoint_index = max(index, 0)

func enter() -> void:
	_load_waypoints()
	if waypoints.size() > 0:
		current_waypoint_index = _get_closest_waypoint_index()
		monster.move_to(waypoints[current_waypoint_index])
	SoundEvents.player_made_sound.connect(_on_player_made_sound)

func exit() -> void:
	if SoundEvents.player_made_sound.is_connected(_on_player_made_sound):
		SoundEvents.player_made_sound.disconnect(_on_player_made_sound)

func _on_player_made_sound(sound_position: Vector2, sound_source: String) -> void:
	var probability
	if sound_source == "door":
		var distance = monster.global_position.distance_to(sound_position)

		var max_distance = 800
		probability = clampf(1.0 - distance / max_distance, 0.0, 1.0)
	else:
		probability = 1
	
	if randf() < probability:
		monster.last_player_position = sound_position
		state_machine.transition_to("Investigate")

func _load_waypoints() -> void:
	waypoints.clear()
	for np in monster.patrol_points:
		var node = monster.get_node_or_null(np)
		if node is Node2D:
			waypoints.append(node.global_position)

# Returns the index of the waypoint with the shortest navigation path from the
# monster's current position. Falls back to straight-line distance if no path
# could be computed (e.g. nav map not synced yet).
func _get_closest_waypoint_index() -> int:
	var agent: NavigationAgent2D = monster.nav_agent
	var map: RID = agent.get_navigation_map()
	var closest_index := -1
	var closest_length := INF

	for i in waypoints.size():
		var path := NavigationServer2D.map_get_path(
			map, monster.global_position, waypoints[i], true, agent.navigation_layers
		)
		if path.is_empty():
			continue  # nav map not ready or no route
		# Skip waypoints the path can't actually reach (it ends somewhere else)
		if path[path.size() - 1].distance_to(waypoints[i]) > waypoint_reach_radius:
			continue
		var length := _path_length(path)
		if length < closest_length:
			closest_length = length
			closest_index = i

	if closest_index == -1:
		return _get_closest_by_distance()
	return closest_index

func _path_length(path: PackedVector2Array) -> float:
	var length := 0.0
	for i in range(1, path.size()):
		length += path[i - 1].distance_to(path[i])
	return length

func _get_closest_by_distance() -> int:
	var closest_index := 0
	var closest_dist_sq := INF
	for i in waypoints.size():
		var dist_sq := monster.global_position.distance_squared_to(waypoints[i])
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest_index = i
	return closest_index

func physics_update(_delta: float) -> void:
	# Transition Check: If player is spotted, switch to Chase state
	if monster.can_see_player():
		monster.last_player_position = monster.player.global_position
		state_machine.transition_to("Chase")
		return
		
	elif monster.can_see_decoy():
		print("can see decoy")
		SoundEvents.emit_sound(monster.bed.global_position, "bed")
		
	if waypoints.is_empty():
		return

	var current_target = waypoints[current_waypoint_index]
	
	if monster.global_position.distance_to(current_target) <= waypoint_reach_radius:
		_advance_to_next_waypoint()
	
	monster.execute_movement()

func _advance_to_next_waypoint() -> void:
	current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
	monster.move_to(waypoints[current_waypoint_index])
