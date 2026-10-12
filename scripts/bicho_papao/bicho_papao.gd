extends CharacterBody2D

@export_group("Movement")
@export var speed: float = 180.0
@export var chase_speed: float = 200.0

@export_group("Patrol")
@export var patrol_points: Array[NodePath] = []

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var vision_area: Area2D = $VisionArea
@onready var catch_area: Area2D = %CatchArea
@onready var los_ray: RayCast2D = $LineOfSightRay
@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine
@onready var footsteps = $Footsteps

var player: Node2D = null
var bed: Node2D = null
var last_player_position: Vector2
var facing_direction := "down"
var is_caught: bool = false

func _ready() -> void:
	add_to_group("monster")
	call_deferred("_setup_navigation")
	
	vision_area.body_entered.connect(_on_vision_area_body_entered)
	vision_area.body_exited.connect(_on_vision_area_body_exited)
	catch_area.body_entered.connect(_on_catch_area_body_entered)
	
	catch_area.area_entered.connect(_on_catch_area_area_entered)

func _direction_to_string(dir: Vector2) -> String:
	# Collapses the input vector into one of the 4 cardinal directions,
	# favoring whichever axis has the larger magnitude (so diagonal input
	# still picks a single up/down/left/right animation).
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"

func _setup_navigation() -> void:
	await get_tree().physics_frame

# Returns true if the player is within the vision area AND line of sight is unblocked
func can_see_player() -> bool:
	if not is_instance_valid(player):
		return false
	
	# Point the RayCast towards the player's center
	los_ray.global_position = global_position
	los_ray.target_position = los_ray.to_local(player.global_position)
	los_ray.force_raycast_update()
	
	if los_ray.is_colliding():
		var collider = los_ray.get_collider()
		return collider == player
		
	return false
	
func can_see_decoy() -> bool:
	if not is_instance_valid(bed):
		print("bed instance not valid")
		return false
	
	if not bed.get_node("Area2D").has_decoy:
		print("no decoy")
		return false
		
	# Point the RayCast towards the player's center
	los_ray.global_position = global_position
	los_ray.target_position = los_ray.to_local(bed.global_position)
	los_ray.force_raycast_update()
	
	if los_ray.is_colliding():
		print("ray is colliding")
		var collider = los_ray.get_collider()
		print (collider == bed)
		return collider == bed
	print("ray not colliding")
	return false

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
	elif body.get_node("Area2D").is_in_group("bed"):
		bed = body

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
	elif body == bed:
		bed = null

func _on_catch_area_body_entered(body: Node2D) -> void:
	if is_caught or not body.is_in_group("player") or !can_see_player():
		return
		
	_catch_player(body)
	
func _on_catch_area_area_entered(area: Area2D) -> void:
	var current_behavior = state_machine.current_state.name.to_lower()
	
	if area.is_in_group("closet"):
		var is_target = area.global_position.distance_to(last_player_position) < 30
		
		if (current_behavior == "investigate" and is_target) or current_behavior == "chase":
			var target_pos = area.global_position
			if area.has_method("get_break_target_position"):
				target_pos = area.get_break_target_position()
			
			var was_player_inside = area.player_inside
			var trapped_player = area.hidden_player
			
			state_machine.set_physics_process(false)
			footsteps.set_physics_process(false)
			footsteps.stop()
			
			var tween = create_tween()
			tween.tween_property(self, "global_position", target_pos, 0.2)
			await tween.finished
			
			if animated_sprite:
				animated_sprite.play("attack_up")
			
			if area.has_method("break_closet"):
				await area.break_closet()
			
			if was_player_inside and trapped_player != null:
				_catch_player(trapped_player)
			else:
				state_machine.transition_to("Patrol")
				state_machine.set_physics_process(true)
				footsteps.set_physics_process(true)
				
	elif area.is_in_group("bed"):
		var is_target = area.global_position.distance_to(last_player_position) < 30
		
		if current_behavior == "investigate" and is_target:
			if area.has_decoy and not area.is_destroyed:
				var target_pos = area.global_position
				
				if area.has_method("get_break_target_position"):
					target_pos = area.get_break_target_position(global_position)
				
				state_machine.set_physics_process(false)
				footsteps.set_physics_process(false)
				footsteps.stop()
				
				var tween = create_tween()
				tween.tween_property(self, "global_position", target_pos, 0.2)
				await tween.finished
				
				if animated_sprite:
					if target_pos.x < area.global_position.x:
						animated_sprite.play("attack_right")
					else:
						animated_sprite.play("attack_left")
				
				if area.has_method("break_bed"):
					await area.break_bed()
					
				state_machine.transition_to("Patrol")
				state_machine.set_physics_process(true)
				footsteps.set_physics_process(true)


func _catch_player(body: Player) -> void:
	is_caught = true
	state_machine.set_physics_process(false)
	footsteps.set_physics_process(false)
	footsteps.stop()
	
	if body.has_method("apply_catch_penalty"):
		body.apply_catch_penalty()

	print("here")
	await Jumpscare.trigger(body.catch_count)
	print("awop")

	var furthest_waypoint_index = _teleport_to_furthest_waypoint(body.global_position)
	_sync_patrol_waypoint_index(furthest_waypoint_index)
	player = null
	state_machine.transition_to("Patrol")
	state_machine.set_physics_process(true)
	footsteps.set_physics_process(true)
	is_caught = false

func _teleport_to_furthest_waypoint(from_position: Vector2) -> int:
	var furthest_point: Vector2 = global_position
	var furthest_distance: float = -1.0
	var furthest_index: int = -1
	var idx := 0
	for np in patrol_points:
		var point_node = get_node_or_null(np)
		if point_node is Node2D:
			var dist = from_position.distance_to(point_node.global_position)
			if dist > furthest_distance:
				furthest_distance = dist
				furthest_point = point_node.global_position
				furthest_index = idx
		idx += 1
	global_position = furthest_point
	return furthest_index

func _sync_patrol_waypoint_index(waypoint_index: int) -> void:
	if waypoint_index < 0:
		return
	if not (state_machine is Node):
		return
	var patrol_state = state_machine.states.get("patrol")
	if patrol_state != null and patrol_state.has_method("set_current_waypoint_index"):
		patrol_state.set_current_waypoint_index(waypoint_index)

# Shared movement helper
func move_to(target_position: Vector2) -> void:
	nav_agent.target_position = target_position

func execute_movement(custom_speed: float = -1.0) -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return
 
	var move_speed = custom_speed if custom_speed > 0 else speed
	var current_pos: Vector2 = global_position
	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_pos.direction_to(next_path_pos)
 
	velocity = direction * move_speed
	move_and_slide()
 
	if direction != Vector2.ZERO:
		facing_direction = _direction_to_string(direction)
		animated_sprite.play("walk_" + facing_direction)

func get_last_player_position() -> Vector2:
	return last_player_position
