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

var facing_direction := "down"  # remembers last facing direction for idle

var hand: Item = null
var pickup_cooldown_time: int
var pickup_cooldown_item: Item

func _init() -> void:
	pickup_cooldown_time = 0
	pickup_cooldown_item = null

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("drop"):
		try_drop()

func _physics_process(delta: float) -> void:
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
