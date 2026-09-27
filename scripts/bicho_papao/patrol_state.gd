# patrol_state.gd
extends State

@export var waypoint_reach_radius: float = 15.0

var current_waypoint_index: int = 0
var waypoints: Array[Vector2] = []

func enter() -> void:
	_load_waypoints()
	if waypoints.size() > 0:
		monster.move_to(waypoints[current_waypoint_index])
	SoundEvents.player_made_sound.connect(_on_player_made_sound)

func exit() -> void:
	if SoundEvents.player_made_sound.is_connected(_on_player_made_sound):
		SoundEvents.player_made_sound.disconnect(_on_player_made_sound)

func _on_player_made_sound(sound_position: Vector2) -> void:
	monster.last_player_position = sound_position
	state_machine.transition_to("Investigate")

func _load_waypoints() -> void:
	waypoints.clear()
	for np in monster.patrol_points:
		var node = monster.get_node_or_null(np)
		if node is Node2D:
			waypoints.append(node.global_position)

func physics_update(_delta: float) -> void:
	# Transition Check: If player is spotted, switch to Chase state
	if monster.can_see_player():
		state_machine.transition_to("Chase")
		return

	if waypoints.is_empty():
		return

	var current_target = waypoints[current_waypoint_index]
	
	if monster.global_position.distance_to(current_target) <= waypoint_reach_radius:
		_advance_to_next_waypoint()
	
	monster.execute_movement()

func _advance_to_next_waypoint() -> void:
	current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
	monster.move_to(waypoints[current_waypoint_index])
