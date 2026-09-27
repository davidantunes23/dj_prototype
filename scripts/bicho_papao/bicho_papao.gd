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

var player: Node2D = null
var last_player_position: Vector2
var facing_direction := "down"
var is_caught: bool = false

func _ready() -> void:
	call_deferred("_setup_navigation")
	
	vision_area.body_entered.connect(_on_vision_area_body_entered)
	vision_area.body_exited.connect(_on_vision_area_body_exited)
	catch_area.body_entered.connect(_on_catch_area_body_entered)

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

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func _on_catch_area_body_entered(body: Node2D) -> void:
	if is_caught or not body.is_in_group("player"):
		return
	is_caught = true
	state_machine.set_physics_process(false)
	await Jumpscare.trigger()
	_teleport_to_furthest_waypoint(body.global_position)
	player = null
	state_machine.transition_to("Patrol")
	state_machine.set_physics_process(true)
	is_caught = false

func _teleport_to_furthest_waypoint(from_position: Vector2) -> void:
	var furthest_point: Vector2 = global_position
	var furthest_distance: float = -1.0
	for np in patrol_points:
		var point_node = get_node_or_null(np)
		if point_node is Node2D:
			var dist = from_position.distance_to(point_node.global_position)
			if dist > furthest_distance:
				furthest_distance = dist
				furthest_point = point_node.global_position
	global_position = furthest_point

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
