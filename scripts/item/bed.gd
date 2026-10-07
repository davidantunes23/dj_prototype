extends Area2D

@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer
@onready var market_left = $MarkerLeft
@onready var market_right = $MarkerRight

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

		SoundEvents.emit_sound(market_left.global_position)

func break_bed() -> void:
	if is_destroyed: return
	
	is_destroyed = true
	has_decoy = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	animation.play("brake_decoy")
	await animation.animation_finished
