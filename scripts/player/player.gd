extends CharacterBody2D
class_name Player

const SPEED = 70
const TURN_SPEED = 5.0
const PICKUP_COOLDOWN_MS = 1000.0

@onready var arm_pivot = $ArmPivot
@onready var flashlight_cone = $ArmPivot/FlashlightCone
@onready var ambient_radius = $AmbientRadius
@onready var animated_sprite = $AnimatedSprite2D
@onready var item_holder = $ItemHolder
@onready var footsteps = $Footsteps
@onready var interaction_area = $InteractionArea2D

var facing_direction := "down"  # remembers last facing direction for idle

var hand: Item = null
var pickup_cooldown_time: int
var pickup_cooldown_item: Item

var catch_count: int = 0

func _init() -> void:
	pickup_cooldown_time = 0
	pickup_cooldown_item = null

func _ready() -> void:
	flashlight_cone.scale = Vector2(0.192, 0.2)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("drop"):
		try_drop()
	if Input.is_action_just_pressed("interact"):
		try_interact()

func try_interact() -> void:
	for area in interaction_area.get_overlapping_areas():
		if area.has_method("interact"):
			area.interact(self)
			break

func _physics_process(delta: float) -> void:
	if catch_count >= 3: return
	
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()
	
	if direction != Vector2.ZERO:
		facing_direction = _direction_to_string(direction)
		animated_sprite.play("walk_" + facing_direction)
		velocity = direction * SPEED
	else:
		animated_sprite.play("idle_" + facing_direction)
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
	footsteps.stream_paused = velocity.length() < 1

	var mouse_pos = get_global_mouse_position()
	var target_angle = (mouse_pos - arm_pivot.global_position).angle()

	arm_pivot.global_rotation = lerp_angle(arm_pivot.global_rotation, target_angle, TURN_SPEED * delta)
	
func _direction_to_string(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"

func get_item_holder() -> Node2D:
	return $ItemHolder

func get_hand() -> Item:
	return hand

func try_pickup(item: Item) -> bool:
	if hand == null and (Time.get_ticks_msec() - pickup_cooldown_time > PICKUP_COOLDOWN_MS or pickup_cooldown_item != item):
		hand = item
		return true
	else:
		return false

func try_drop() -> void:
	if hand == null:
		return

	pickup_cooldown_time = Time.get_ticks_msec()
	pickup_cooldown_item = hand

	hand.drop(position)
	hand = null
	
func apply_catch_penalty():
	if catch_count >= 3: return
	
	catch_count += 1
	var tween = create_tween().set_parallel(true)
	
	match catch_count:
		1:
			tween.tween_property(flashlight_cone, "scale", Vector2(0.1, 0.1), 0.5)
			# tween.tween_property(ambient_radius, "scale", Vector2(0.8, 0.8), 0.5)
		2:
			tween.tween_property(flashlight_cone, "energy", 0.0, 0.5)
			# tween.tween_property(ambient_radius, "scale", Vector2(0.5, 0.5), 0.5)
		3:
			tween.tween_property(ambient_radius, "energy", 0.0, 0.5)
			
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://scenes/map/game_over_screen.tscn")
