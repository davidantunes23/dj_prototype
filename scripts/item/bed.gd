extends Area2D


@export var use_left_marker: bool = true
@export var use_right_marker: bool = true

@onready var sprite = $"../Sprite2D"
@onready var animation = $"../AnimationPlayer"
@onready var marker_left = $"../MarkerLeft"
@onready var marker_right = $"../MarkerRight"

var is_destroyed := false
var has_decoy := false

func _ready() -> void:
	add_to_group("bed")
	sprite.frame = 0

func can_interact(player: Player) -> bool:
	if is_destroyed or has_decoy or animation.is_playing():
		return false
	
	var hand = player.get_hand()
	return hand != null and hand.get_type() == "decoy"

func interact(player: Player) -> void:
	if is_destroyed or has_decoy or animation.is_playing():
		return

	var hand = player.get_hand()
	if hand != null and hand.get_type() == "decoy":
		has_decoy = true
		
		hand.queue_free()
		player.hand = null
		
		animation.play("set_decoy")
		
		var sound_pos = global_position
		if use_left_marker and marker_left != null:
			sound_pos = marker_left.global_position
			print("marker_left")
		elif use_right_marker and marker_right != null:
			sound_pos = marker_right.global_position
			print("marker_right")
		
		# If global_position BUG
		SoundEvents.emit_sound(sound_pos)

func get_break_target_position(monster_pos: Vector2) -> Vector2:
	if use_left_marker and use_right_marker:
		var dist_to_left = monster_pos.distance_to(marker_left.global_position)
		var dist_to_right = monster_pos.distance_to(marker_right.global_position)
		
		if dist_to_left < dist_to_right:
			return marker_left.global_position
		else:
			return marker_right.global_position
	elif use_left_marker:
		return marker_left.global_position
	elif use_right_marker:
		return marker_right.global_position
	else:
		return global_position

func break_bed() -> void:
	if is_destroyed: return
	
	is_destroyed = true
	has_decoy = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	animation.play("brake_decoy")
	await animation.animation_finished
