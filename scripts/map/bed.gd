extends Area2D

@onready var sprite_closed = $"../ClosedSprite2D"
@onready var sprite_open = $"../Sprite2D2"
@onready var destruction_point = $"DestructionPoint"

var used = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

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

		SoundEvents.emit_sound(destruction_point.global_position)

func _on_body_entered(body: Node2D) -> void:
	if used and body.is_in_group("monster"):
		sprite_closed.visible = false
		sprite_open.visible = true
