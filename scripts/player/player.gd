extends CharacterBody2D

const SPEED = 100.0
const TURN_SPEED = 5.0

@onready var arm_pivot = $ArmPivot
@onready var flashlight_cone = $ArmPivot/FlashlightCone
@onready var ambient_radius = $AmbientRadius

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()

    var mouse_pos = get_global_mouse_position()
    var target_angle = (mouse_pos - arm_pivot.global_position).angle()

    arm_pivot.global_rotation = lerp_angle(arm_pibot.global_rotation, target_angle, TURN_SPEED * delta)


