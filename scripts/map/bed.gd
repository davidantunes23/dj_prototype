extends Node

@onready var sprite_closed = $ClosedSprite2D
@onready var sprite_open = $Sprite2D2
var used = false

func interact(player: Player) -> void:
	if used:
		return

	var hand = player.get_hand()
	if hand != null and hand.get_type() == "decoy":
		used = true
		sprite_open.visible = false
		sprite_closed.visible = true

		player.hand.queue_free()
		player.hand = null

		# TODO trigger monster behavior
