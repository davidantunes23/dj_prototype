extends CharacterBody2D

@export_group("Movement")
@export var speed: float = 180.0
@export var chase_speed: float = 200.0

@export_group("Patrol")
@export var patrol_points: Array[NodePath] = []

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var vision_area: Area2D = $VisionArea
@onready var los_ray: RayCast2D = $LineOfSightRay

var player: Node2D = null
var last_player_position: Vector2

func _ready() -> void:
	call_deferred("_setup_navigation")
	
	vision_area.body_entered.connect(_on_vision_area_body_entered)
	vision_area.body_exited.connect(_on_vision_area_body_exited)

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
	
	velocity = current_pos.direction_to(next_path_pos) * move_speed
	move_and_slide()
	
func get_last_player_position() -> Vector2:
	return last_player_position
