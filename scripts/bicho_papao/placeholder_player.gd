# placeholder_player.gd
extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(_delta: float) -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * speed
	move_and_slide()

	if Input.is_action_just_pressed("make_sound"):
		SoundEvents.emit_sound(global_position)
