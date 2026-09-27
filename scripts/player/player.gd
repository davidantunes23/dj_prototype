extends CharacterBody2D

const SPEED = 70
const TURN_SPEED = 5.0

@onready var arm_pivot = $ArmPivot
@onready var flashlight_cone = $ArmPivot/FlashlightCone
@onready var ambient_radius = $AmbientRadius
@onready var animated_sprite = $AnimatedSprite2D

var facing_direction := "down"  # remembers last facing direction for idle


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
